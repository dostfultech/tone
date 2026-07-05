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

export function resolveDodoEnvironment(): "live_mode" | "test_mode" {
  return normalizeDodoEnvironment(process.env.DODO_PAYMENTS_ENVIRONMENT) ?? "test_mode";
}

export function normalizeDodoStatus(status: string | undefined) {
  const normalized = (status || "").toLowerCase();
  if (["active", "subscription.active", "success", "succeeded", "complete", "completed", "paid"].includes(normalized)) return "active";
  if (["trialing", "trial"].includes(normalized)) return "trialing";
  if (["on_hold", "onhold", "hold"].includes(normalized)) return "on_hold";
  if (["cancelled", "canceled", "subscription.cancelled"].includes(normalized)) return "cancelled";
  if (["failed", "payment_failed", "subscription.failed"].includes(normalized)) return "failed";
  if (["expired", "subscription.expired"].includes(normalized)) return "expired";
  return normalized || "inactive";
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
