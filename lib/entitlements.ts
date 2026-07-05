import type { User } from "@supabase/supabase-js";
import { getTestAccessEmails } from "@/lib/env";

export type Entitlement = {
  hasAccess: boolean;
  source: "test" | "subscription" | "none";
  planId: "beginner" | "expert" | null;
  status: string | null;
  monthlyAdaptations: number | null;
  savedTonesLimit: number | null;
};

export const planLimits = {
  beginner: {
    monthlyAdaptations: 20,
    savedTonesLimit: 15,
    gearPresetsLimit: 10
  },
  expert: {
    monthlyAdaptations: null,
    savedTonesLimit: null,
    gearPresetsLimit: null
  }
} as const;

export function getBypassEntitlement(user: User | null): Entitlement | null {
  if (!isTestAccessEnabled()) {
    return null;
  }

  const email = user?.email?.toLowerCase();
  if (!email || !getTestAccessEmails().has(email)) {
    return null;
  }

  return {
    hasAccess: true,
    source: "test",
    planId: "expert",
    status: "test_access",
    monthlyAdaptations: null,
    savedTonesLimit: null
  };
}

function isTestAccessEnabled() {
  if (process.env.NODE_ENV !== "production") {
    return true;
  }

  return process.env.ENABLE_TEST_ACCESS_IN_PRODUCTION === "true";
}

export function mapSubscriptionEntitlement(subscription: {
  status: string;
  plan_id: string | null;
} | null): Entitlement {
  const status = subscription?.status || null;
  const planId = subscription?.plan_id === "expert" ? "expert" : subscription?.plan_id === "beginner" ? "beginner" : null;
  const active = status === "active" || status === "trialing";
  const limits = planId ? planLimits[planId] : null;

  return {
    hasAccess: Boolean(active && planId),
    source: active ? "subscription" : "none",
    planId,
    status,
    monthlyAdaptations: limits?.monthlyAdaptations ?? null,
    savedTonesLimit: limits?.savedTonesLimit ?? null
  };
}
