import type { User } from "@supabase/supabase-js";
import { getTestAccessEmails } from "@/lib/env";

export type Entitlement = {
  hasAccess: boolean;
  source: "test" | "subscription" | "none";
  planId: "beginner" | "expert" | null;
  status: string | null;
  monthlyAdaptations: number | null;
  savedTonesLimit: number | null;
  isTrial: boolean;
  // Total adaptations allowed during the 7-day free trial (null when not on trial).
  trialAdaptations: number | null;
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

// 7-day free trial caps (ToneAdapt-style): total adaptations allowed before the trial converts.
export const trialLimits = {
  beginner: 5,
  expert: 8
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
    savedTonesLimit: null,
    isTrial: false,
    trialAdaptations: null
  };
}

function isTestAccessEnabled() {
  return process.env.NODE_ENV !== "production";
}

export function mapSubscriptionEntitlement(subscription: {
  status: string;
  plan_id: string | null;
} | null): Entitlement {
  const status = subscription?.status || null;
  const planId = subscription?.plan_id === "expert" ? "expert" : subscription?.plan_id === "beginner" ? "beginner" : null;
  // Access is granted while active OR trialing (7-day free trial). The webhook marks a
  // subscription "trialing" while it is inside its Dodo trial window.
  const active = status === "active";
  const trialing = status === "trialing";
  const limits = planId ? planLimits[planId] : null;
  const isTrial = trialing && Boolean(planId);

  return {
    hasAccess: Boolean((active || trialing) && planId),
    source: active || trialing ? "subscription" : "none",
    planId,
    status,
    monthlyAdaptations: limits?.monthlyAdaptations ?? null,
    savedTonesLimit: limits?.savedTonesLimit ?? null,
    isTrial,
    trialAdaptations: isTrial && planId ? trialLimits[planId] : null
  };
}
