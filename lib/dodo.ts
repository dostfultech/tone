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

export function isDodoConfigured() {
  return Boolean(process.env.DODO_PAYMENTS_API_KEY);
}

export function createDodoClient() {
  const bearerToken = process.env.DODO_PAYMENTS_API_KEY;
  if (!bearerToken) {
    return null;
  }

  return new DodoPayments({
    bearerToken,
    environment: process.env.DODO_PAYMENTS_ENVIRONMENT === "live_mode" ? "live_mode" : "test_mode"
  });
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
