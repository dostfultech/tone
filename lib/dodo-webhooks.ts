import { inferBillingIntervalFromProductId, inferPlanIdFromProductId, normalizeDodoStatus } from "@/lib/dodo";
import { createSupabaseAdminClient } from "@/lib/supabase/admin";

type DodoWebhookPayload = {
  type?: string;
  event_type?: string;
  data?: Record<string, unknown>;
  payload?: Record<string, unknown>;
  [key: string]: unknown;
};

export async function syncDodoSubscription(payload: DodoWebhookPayload) {
  const admin = createSupabaseAdminClient();
  if (!admin) {
    return;
  }

  const eventType = String(payload.type || payload.event_type || "");
  const data = ((payload.data || payload.payload || payload) ?? {}) as Record<string, unknown>;
  const metadata = ((data.metadata || {}) ?? {}) as Record<string, unknown>;
  const userId = stringValue(metadata.user_id || data.user_id);
  const planIdFromPayload = stringValue(metadata.plan_id || data.plan_id);
  const billingIntervalFromPayload = stringValue(metadata.billing_interval || data.billing_interval);
  const customerId = stringValue(data.customer_id || nestedIdentifier(data.customer) || nestedIdentifier(data.customer_details));
  const subscriptionId = stringValue(data.subscription_id || nestedIdentifier(data.subscription) || data.id);
  const productId = stringValue(data.product_id || nestedIdentifier(data.product) || nestedIdentifier(data.product_cart));
  const inferredPlanId = inferPlanIdFromProductId(productId);
  const inferredBillingInterval = inferBillingIntervalFromProductId(productId);
  const planId = planIdFromPayload || inferredPlanId;
  const billingInterval = billingIntervalFromPayload || inferredBillingInterval;
  const rawStatus = stringValue(data.status || eventType);
  const status = normalizeDodoStatus(rawStatus);

  if (!userId) {
    await admin.from("admin_audit_logs").insert({
      action: "dodo_webhook_missing_user",
      metadata: payload
    });
    return;
  }

  await admin.from("subscriptions").upsert(
    {
      user_id: userId,
      plan_id: planId || null,
      billing_interval: billingInterval || null,
      status,
      dodo_customer_id: customerId || null,
      dodo_subscription_id: subscriptionId || null,
      dodo_product_id: productId || null,
      current_period_start: dateValue(data.current_period_start || data.period_start),
      current_period_end: dateValue(data.current_period_end || data.period_end || data.next_billing_date),
      cancel_at_period_end: Boolean(data.cancel_at_period_end),
      metadata: payload
    },
    { onConflict: "dodo_subscription_id" }
  );

  await admin.from("admin_audit_logs").insert({
    actor_id: userId,
    action: "dodo_subscription_sync",
    target_table: "subscriptions",
    target_id: subscriptionId || userId,
    metadata: { eventType, status, planId, billingInterval }
  });
}

function stringValue(value: unknown) {
  return typeof value === "string" && value.trim() ? value.trim() : "";
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
  return stringValue(record.id || record.product_id || record.subscription_id || record.customer_id);
}

function dateValue(value: unknown) {
  if (typeof value !== "string" || !value) {
    return null;
  }
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? null : date.toISOString();
}
