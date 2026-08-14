import { createHash } from "node:crypto";

export const REF_COOKIE = "tf_ref";
export const REF_COOKIE_MAX_AGE = 60 * 60 * 24 * 30; // 30 days

// Deterministic, stable per-user code — must match the SQL backfill
// (upper(substring(md5('tonefex-ref:' || id) from 1 for 8))).
export function computeReferralCode(userId: string): string {
  return createHash("md5").update(`tonefex-ref:${userId}`).digest("hex").slice(0, 8).toUpperCase();
}

// Accept a raw ?ref / cookie value and return a clean code, or null if it isn't a plausible one.
export function normalizeRefCode(value: string | null | undefined): string | null {
  if (!value) {
    return null;
  }
  const cleaned = value.trim().toUpperCase().replace(/[^A-Z0-9]/g, "");
  return /^[A-Z0-9]{6,12}$/.test(cleaned) ? cleaned : null;
}
