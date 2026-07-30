import {
  type DodoSubscription,
  inferBillingIntervalFromProductId,
  inferPlanIdFromProductId,
  normalizeDodoStatus,
  retrieveDodoSubscription
} from "@/lib/dodo";
import { createSupabaseAdminClient } from "@/lib/supabase/admin";

type DodoWebhookPayload = {
  type?: string;
  event_type?: string;
  data?: Record<string, unknown>;
  payload?: Record<string, unknown>;
  [key: string]: unknown;
};

type SubscriptionRow = {
  user_id: string;
  plan_id: string | null;
  billing_interval: string | null;
  status: string;
  dodo_customer_id: string | null;
  dodo_subscription_id: string | null;
  dodo_product_id: string | null;
  current_period_start: string | null;
  current_period_end: string | null;
  trial_end: string | null;
  trial_period_days: number;
  cancel_at_period_end: boolean;
  metadata: unknown;
};

/**
 * Entry point for Dodo webhook events. We only trust the webhook for the
 * subscription id, then read the canonical record from the Dodo API so the
 * customer id, trial window, and billing dates are always correct regardless of
 * which event fired or how its payload was shaped.
 */
export async function syncDodoSubscription(payload: DodoWebhookPayload) {
  const admin = createSupabaseAdminClient();
  if (!admin) {
    return;
  }

  const eventType = String(payload.type || payload.event_type || "");
  const data = ((payload.data || payload.payload || payload) ?? {}) as Record<string, unknown>;
  const metadata = ((data.metadata || {}) ?? {}) as Record<string, unknown>;
  const fallbackUserId = stringValue(metadata.user_id || data.user_id);
  const subscriptionId = stringValue(data.subscription_id || nestedIdentifier(data.subscription) || data.id);

  const authoritative = await retrieveDodoSubscription(subscriptionId);
  const row = authoritative
    ? buildRowFromSubscription(authoritative, fallbackUserId, payload)
    : buildRowFromPayload(data, metadata, eventType, fallbackUserId, subscriptionId, payload);

  if (!row.user_id) {
    await admin.from("admin_audit_logs").insert({
      action: "dodo_webhook_missing_user",
      metadata: payload
    });
    return;
  }

  await persistSubscriptionRow(admin, row, { eventType, source: authoritative ? "api" : "payload" });
}

/**
 * Reusable path for the checkout-success page: given a real Dodo subscription id,
 * pull the authoritative record and upsert it so the row carries the customer id
 * and trial window immediately (before the webhook lands).
 */
export async function syncDodoSubscriptionById(subscriptionId: string, fallbackUserId?: string): Promise<string | null> {
  const admin = createSupabaseAdminClient();
  if (!admin) {
    return null;
  }

  const authoritative = await retrieveDodoSubscription(subscriptionId);
  if (!authoritative) {
    return null;
  }

  const row = buildRowFromSubscription(authoritative, fallbackUserId || "", { source: "checkout_return_api" });
  if (!row.user_id) {
    return null;
  }

  const persisted = await persistSubscriptionRow(admin, row, { eventType: "checkout_return", source: "api" });
  return persisted ? row.status : null;
}

function buildRowFromSubscription(
  subscription: DodoSubscription,
  fallbackUserId: string,
  metadataEnvelope: unknown
): SubscriptionRow {
  const sub = subscription as unknown as Record<string, unknown>;
  const subMetadata = ((sub.metadata || {}) ?? {}) as Record<string, unknown>;
  const userId = stringValue(subMetadata.user_id) || fallbackUserId;

  const productId = stringValue(sub.product_id);
  const planId = stringValue(subMetadata.plan_id) || inferPlanIdFromProductId(productId);
  const billingInterval =
    stringValue(subMetadata.billing_interval) ||
    inferBillingIntervalFromProductId(productId) ||
    intervalFromDodo(stringValue(sub.subscription_period_interval) || stringValue(sub.payment_frequency_interval));

  const customerId = nestedCustomerId(sub.customer) || stringValue(sub.customer_id);
  const trialPeriodDays = numberValue(sub.trial_period_days);
  const createdAt = dateValue(sub.created_at);
  const nextBillingDate = dateValue(sub.next_billing_date);
  const previousBillingDate = dateValue(sub.previous_billing_date);

  // The trial always ends `trial_period_days` after creation. Deriving it from
  // created_at keeps it stable across renewals (next_billing_date moves forward
  // once the trial converts, but the original trial end must not drift).
  const trialEnd =
    trialPeriodDays > 0
      ? createdAt
        ? new Date(new Date(createdAt).getTime() + trialPeriodDays * 86_400_000).toISOString()
        : nextBillingDate
      : null;

  // Once Dodo's next billing has moved more than a day past the trial window, the
  // trial has already converted to a paid period (manually via "Unlock", or by the
  // trial expiring). Treat it as active so a later re-sync doesn't flip it back to
  // trialing.
  const converted = Boolean(
    trialEnd && nextBillingDate && new Date(nextBillingDate).getTime() > new Date(trialEnd).getTime() + 86_400_000
  );
  const status = resolveInternalStatus(stringValue(sub.status), converted ? null : trialEnd);

  return {
    user_id: userId,
    plan_id: planId || null,
    billing_interval: billingInterval || null,
    status,
    dodo_customer_id: customerId || null,
    dodo_subscription_id: stringValue(sub.subscription_id) || null,
    dodo_product_id: productId || null,
    current_period_start: previousBillingDate,
    current_period_end: nextBillingDate,
    trial_end: converted ? null : trialEnd,
    trial_period_days: trialPeriodDays,
    cancel_at_period_end: Boolean(sub.cancel_at_next_billing_date),
    metadata: metadataEnvelope
  };
}

function buildRowFromPayload(
  data: Record<string, unknown>,
  metadata: Record<string, unknown>,
  eventType: string,
  fallbackUserId: string,
  subscriptionId: string,
  payload: DodoWebhookPayload
): SubscriptionRow {
  const productId = stringValue(data.product_id || nestedIdentifier(data.product) || nestedIdentifier(data.product_cart));
  const planId = stringValue(metadata.plan_id || data.plan_id) || inferPlanIdFromProductId(productId);
  const billingInterval = stringValue(metadata.billing_interval || data.billing_interval) || inferBillingIntervalFromProductId(productId);
  const trialPeriodDays = numberValue(data.trial_period_days);
  const trialEnd =
    dateValue(data.trial_end || data.trial_ends_at) ||
    (trialPeriodDays > 0 ? dateValue(data.next_billing_date || data.current_period_end || data.period_end) : null);
  const status = resolveInternalStatus(stringValue(data.status || eventType), trialEnd);

  return {
    user_id: fallbackUserId,
    plan_id: planId || null,
    billing_interval: billingInterval || null,
    status,
    dodo_customer_id: stringValue(data.customer_id) || nestedCustomerId(data.customer) || nestedCustomerId(data.customer_details) || null,
    dodo_subscription_id: subscriptionId || null,
    dodo_product_id: productId || null,
    current_period_start: dateValue(data.current_period_start || data.period_start || data.previous_billing_date),
    current_period_end: dateValue(data.current_period_end || data.period_end || data.next_billing_date),
    trial_end: trialEnd,
    trial_period_days: trialPeriodDays,
    cancel_at_period_end: Boolean(data.cancel_at_period_end || data.cancel_at_next_billing_date),
    metadata: payload
  };
}

async function persistSubscriptionRow(
  admin: NonNullable<ReturnType<typeof createSupabaseAdminClient>>,
  row: SubscriptionRow,
  audit: { eventType: string; source: string }
) {
  // Never downgrade an already-converted (active) subscription back to trialing. A
  // webhook re-sync in the brief window between "Unlock Full Access" and the actual
  // charge would otherwise revert it and hand the user another free trial.
  if (row.status === "trialing" && row.dodo_subscription_id) {
    const { data: existing } = await admin
      .from("subscriptions")
      .select("status")
      .eq("dodo_subscription_id", row.dodo_subscription_id)
      .maybeSingle();
    if (existing?.status === "active") {
      row.status = "active";
      row.trial_end = null;
    }
  }

  const { error: upsertError } = await admin.from("subscriptions").upsert(row, { onConflict: "dodo_subscription_id" });
  if (upsertError) {
    console.error("[dodo] subscription upsert failed", {
      status: row.status,
      subscriptionId: row.dodo_subscription_id,
      message: upsertError.message
    });
  }

  // Remove any provisional checkout-return placeholder rows now that we have the
  // real Dodo-issued subscription, so the account only ever resolves one row.
  if (!upsertError && row.dodo_subscription_id && !row.dodo_subscription_id.startsWith("checkout-return-")) {
    await admin
      .from("subscriptions")
      .delete()
      .eq("user_id", row.user_id)
      .like("dodo_subscription_id", "checkout-return-%");
  }

  await admin.from("admin_audit_logs").insert({
    actor_id: row.user_id,
    action: "dodo_subscription_sync",
    target_table: "subscriptions",
    target_id: row.dodo_subscription_id || row.user_id,
    metadata: {
      eventType: audit.eventType,
      source: audit.source,
      status: row.status,
      planId: row.plan_id,
      billingInterval: row.billing_interval,
      trialEnd: row.trial_end,
      hasCustomerId: Boolean(row.dodo_customer_id),
      upsertError: upsertError?.message || null
    }
  });

  return !upsertError;
}

/**
 * Dodo does not expose a `trialing` status — a subscription in its trial window is
 * reported as `active` with `trial_period_days > 0`. We map it to our internal
 * `trialing` status while now is before the captured trial end, and let it fall
 * back to the real status once the trial has converted.
 */
function resolveInternalStatus(rawStatus: string, trialEnd: string | null) {
  const base = normalizeDodoStatus(rawStatus);
  // A subscription inside its trial window is "trialing" for us — even when Dodo
  // still reports it as pending / "Not Initiated" / active in the seconds right
  // after checkout, before the mandate finishes initializing. Terminal states
  // (cancelled/failed/expired) are never overridden.
  const terminal = base === "cancelled" || base === "failed" || base === "expired";
  if (!terminal && trialEnd) {
    const endsAt = new Date(trialEnd).getTime();
    if (Number.isFinite(endsAt) && Date.now() < endsAt) {
      return "trialing";
    }
  }
  return base;
}

function intervalFromDodo(value: string): "monthly" | "annual" | "" {
  const normalized = value.toLowerCase();
  if (normalized === "month") {
    return "monthly";
  }
  if (normalized === "year") {
    return "annual";
  }
  return "";
}

function stringValue(value: unknown) {
  return typeof value === "string" && value.trim() ? value.trim() : "";
}

function numberValue(value: unknown) {
  const parsed = typeof value === "number" ? value : typeof value === "string" ? Number(value) : NaN;
  return Number.isFinite(parsed) && parsed > 0 ? Math.floor(parsed) : 0;
}

function nestedIdentifier(value: unknown): string {
  if (typeof value === "string" && value.trim()) {
    return value.trim();
  }

  if (Array.isArray(value)) {
    for (const entry of value) {
      const identifier = nestedIdentifier(entry);
      if (identifier) {
        return identifier;
      }
    }
    return "";
  }

  if (!value || typeof value !== "object") {
    return "";
  }

  const record = value as Record<string, unknown>;
  return stringValue(record.id || record.subscription_id || record.product_id);
}

function nestedCustomerId(value: unknown): string {
  if (typeof value === "string" && value.trim()) {
    return value.trim();
  }

  if (Array.isArray(value)) {
    for (const entry of value) {
      const identifier = nestedCustomerId(entry);
      if (identifier) {
        return identifier;
      }
    }
    return "";
  }

  if (!value || typeof value !== "object") {
    return "";
  }

  const record = value as Record<string, unknown>;
  return stringValue(record.customer_id || record.id);
}

function dateValue(value: unknown) {
  if (typeof value !== "string" || !value) {
    return null;
  }
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? null : date.toISOString();
}
