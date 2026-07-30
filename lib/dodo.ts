import DodoPayments from "dodopayments";

export type BillingInterval = "monthly" | "annual";
export type PlanId = "beginner" | "expert";

const productEnvMap: Record<PlanId, Record<BillingInterval, string>> = {
  beginner: {
    monthly: "DODO_BEGINNER_MONTHLY_PRODUCT_ID",
    annual: "DODO_BEGINNER_ANNUAL_PRODUCT_ID"
  },
  expert: {
    monthly: "DODO_EXPERT_MONTHLY_PRODUCT_ID",
    annual: "DODO_EXPERT_ANNUAL_PRODUCT_ID"
  }
};

export function getDodoProductId(planId: PlanId, billing: BillingInterval) {
  return process.env[productEnvMap[planId][billing]] || "";
}

export function inferPlanIdFromProductId(productId: string | null | undefined): PlanId | "" {
  const normalized = (productId || "").trim();
  if (!normalized) {
    return "";
  }

  if (normalized === process.env.DODO_BEGINNER_MONTHLY_PRODUCT_ID || normalized === process.env.DODO_BEGINNER_ANNUAL_PRODUCT_ID) {
    return "beginner";
  }
  if (normalized === process.env.DODO_EXPERT_MONTHLY_PRODUCT_ID || normalized === process.env.DODO_EXPERT_ANNUAL_PRODUCT_ID) {
    return "expert";
  }
  return "";
}

export function inferBillingIntervalFromProductId(productId: string | null | undefined): BillingInterval | "" {
  const normalized = (productId || "").trim();
  if (!normalized) {
    return "";
  }

  if (normalized === process.env.DODO_BEGINNER_MONTHLY_PRODUCT_ID || normalized === process.env.DODO_EXPERT_MONTHLY_PRODUCT_ID) {
    return "monthly";
  }
  if (normalized === process.env.DODO_BEGINNER_ANNUAL_PRODUCT_ID || normalized === process.env.DODO_EXPERT_ANNUAL_PRODUCT_ID) {
    return "annual";
  }
  return "";
}

export function isDodoConfigured() {
  return Boolean(process.env.DODO_PAYMENTS_API_KEY && normalizeDodoEnvironment(process.env.DODO_PAYMENTS_ENVIRONMENT));
}

export function createDodoClient() {
  const bearerToken = process.env.DODO_PAYMENTS_API_KEY;
  if (!bearerToken) {
    return null;
  }

  return new DodoPayments({
    bearerToken,
    environment: resolveDodoEnvironment()
  });
}

export type DodoSubscription = Awaited<ReturnType<DodoPayments["subscriptions"]["retrieve"]>>;

/**
 * Fetch the authoritative subscription object straight from Dodo. Webhook payload
 * shapes vary between events, so we treat the webhook purely as a trigger and read
 * the canonical customer id, status, trial window, and billing dates from the API.
 */
export async function retrieveDodoSubscription(subscriptionId: string | null | undefined): Promise<DodoSubscription | null> {
  const id = (subscriptionId || "").trim();
  if (!id) {
    return null;
  }

  const client = createDodoClient();
  if (!client) {
    return null;
  }

  try {
    return await client.subscriptions.retrieve(id);
  } catch (error) {
    console.error("[dodo] failed to retrieve subscription", id, error instanceof Error ? error.message : error);
    return null;
  }
}

/**
 * Find the most recent Dodo subscription that belongs to a given app user, by
 * matching the `user_id` we stamp into checkout metadata. Used by the checkout
 * return page so a trial reflects immediately even when Dodo's return URL omits
 * the subscription id and before the webhook lands.
 */
export async function findLatestDodoSubscriptionIdForUser(userId: string): Promise<string | null> {
  const client = createDodoClient();
  if (!client || !userId) {
    return null;
  }

  try {
    const since = new Date(Date.now() - 72 * 60 * 60 * 1000).toISOString();
    const list = await client.subscriptions.list({ created_at_gte: since } as never);
    let bestId: string | null = null;
    let bestCreated = -1;
    let scanned = 0;
    for await (const item of list as AsyncIterable<Record<string, unknown>>) {
      if (++scanned > 200) {
        break;
      }
      const metadata = ((item.metadata || {}) ?? {}) as Record<string, unknown>;
      if (metadata.user_id !== userId) {
        continue;
      }
      const created = new Date(String(item.created_at || "")).getTime();
      if (Number.isFinite(created) && created > bestCreated) {
        bestCreated = created;
        bestId = typeof item.subscription_id === "string" ? item.subscription_id : null;
      }
    }
    return bestId;
  } catch (error) {
    console.error("[dodo] failed to list subscriptions for user", userId, error instanceof Error ? error.message : error);
    return null;
  }
}

export function resolveDodoEnvironment(): "live_mode" | "test_mode" {
  return normalizeDodoEnvironment(process.env.DODO_PAYMENTS_ENVIRONMENT) ?? "test_mode";
}

export function normalizeDodoStatus(status: string | undefined) {
  const normalized = (status || "").toLowerCase().trim();
  if (["active", "subscription.active", "success", "succeeded", "complete", "completed", "paid"].includes(normalized)) return "active";
  if (["trialing", "trial"].includes(normalized)) return "trialing";
  if (["on_hold", "onhold", "hold"].includes(normalized)) return "on_hold";
  if (["cancelled", "canceled", "subscription.cancelled"].includes(normalized)) return "cancelled";
  if (["failed", "payment_failed", "subscription.failed"].includes(normalized)) return "failed";
  if (["expired", "subscription.expired"].includes(normalized)) return "expired";
  // pending / "not initiated" / processing / any unknown value is not one of the
  // statuses our subscriptions CHECK constraint allows — normalize to "inactive"
  // (no access) so a row is never silently rejected. A live trial window is
  // promoted to "trialing" separately (see resolveInternalStatus).
  return "inactive";
}

function normalizeDodoEnvironment(value: string | undefined) {
  const normalized = (value || "").trim().toLowerCase();
  if (!normalized) {
    return null;
  }

  if (["live", "live_mode", "production", "prod"].includes(normalized)) {
    return "live_mode" as const;
  }

  if (["test", "test_mode", "sandbox", "development", "dev"].includes(normalized)) {
    return "test_mode" as const;
  }

  return null;
}
