import { createHash } from "node:crypto";

export const REF_COOKIE = "tf_ref";
export const REF_COOKIE_MAX_AGE = 60 * 60 * 24 * 30; // 30 days

// Deterministic, stable per-user code — must match the SQL backfill
// (upper(substring(md5('tonefex-ref:' || id) from 1 for 8))).
export function computeReferralCode(userId: string): string {
  return createHash("md5").update(`tonefex-ref:${userId}`).digest("hex").slice(0, 8).toUpperCase();
}

// Referrer commission on every plan bought through their link.
export const COMMISSION_RATE = 0.2; // 20%

// Plan prices — keep in sync with the `plans` array in lib/mock-data.ts.
const PLAN_PRICES: Record<string, { name: string; monthly: number; annual: number }> = {
  beginner: { name: "Beginner", monthly: 6.99, annual: 39.99 },
  expert: { name: "Expert", monthly: 10.99, annual: 49.99 }
};

export function planName(planId: string): string {
  return PLAN_PRICES[planId]?.name ?? planId;
}

export function planPrice(planId: string, billingInterval: string): number {
  const plan = PLAN_PRICES[planId];
  if (!plan) {
    return 0;
  }
  return billingInterval === "annual" ? plan.annual : plan.monthly;
}

export function commissionFor(planId: string, billingInterval: string): number {
  return Math.round(planPrice(planId, billingInterval) * COMMISSION_RATE * 100) / 100;
}

// Accept a raw ?ref / cookie value and return a clean code, or null if it isn't a plausible one.
export function normalizeRefCode(value: string | null | undefined): string | null {
  if (!value) {
    return null;
  }
  const cleaned = value.trim().toUpperCase().replace(/[^A-Z0-9]/g, "");
  return /^[A-Z0-9]{6,12}$/.test(cleaned) ? cleaned : null;
}
