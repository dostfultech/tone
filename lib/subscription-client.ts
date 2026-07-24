import type { SupabaseClient, User } from "@supabase/supabase-js";
import {
  createFreeAdaptationQuota,
  createOnboardingProgressState,
  resolveAdaptationAccessState
} from "@/lib/adaptation-access";
import { EARLY_TESTER_FREE_ADAPTATIONS } from "@/lib/early-tester";
import { planLimits } from "@/lib/entitlements";
import { plans } from "@/lib/mock-data";

const earlyTesterMode = process.env.NEXT_PUBLIC_EARLY_TESTER_MODE === "true";

export type PlanId = "beginner" | "expert";
export type BillingInterval = "monthly" | "annual";

type RawSubscription = {
  plan_id: string | null;
  status: string;
  billing_interval: string | null;
  current_period_end: string | null;
};

type RawProfile = {
  free_adaptation_limit: number | null;
  free_adaptations_used: number | null;
  welcome_completed_at: string | null;
  gear_onboarding_completed_at: string | null;
  tone_database_seen_at: string | null;
  first_adaptation_completed_at: string | null;
};

type UsageSnapshot = {
  adaptationsUsed: number;
  adaptationsRemaining: number | null;
  savedTonesUsed: number;
  savedTonesRemaining: number | null;
  gearPresetsUsed: number;
  gearPresetsRemaining: number | null;
  freeAdaptationLimit: number;
  freeAdaptationsUsed: number;
  freeAdaptationsRemaining: number;
};

export type ClientSubscriptionSnapshot = {
  user: User | null;
  planId: PlanId | null;
  planName: string | null;
  status: string | null;
  billingInterval: BillingInterval | null;
  renewalDate: string | null;
  hasAccess: boolean;
  features: string[];
  adaptationAccess: ReturnType<typeof resolveAdaptationAccessState>;
  onboarding: ReturnType<typeof createOnboardingProgressState>;
  usage: UsageSnapshot;
  totals: {
    savedTones: number;
    gearPresets: number;
  };
};

export async function loadClientSubscriptionSnapshot(client: SupabaseClient): Promise<ClientSubscriptionSnapshot> {
  const {
    data: { session }
  } = await client.auth.getSession();
  const sessionUser = session?.user || null;
  const {
    data: { user: verifiedUser }
  } = sessionUser ? { data: { user: sessionUser } } : await client.auth.getUser();
  const user = verifiedUser || sessionUser;

  if (!user) {
    return emptySnapshot();
  }

  const [activeResult, latestResult, profileResult] = await Promise.all([
    client
      .from("subscriptions")
      .select("plan_id, status, billing_interval, current_period_end")
      .eq("user_id", user.id)
      .in("status", ["active", "trialing"])
      .in("plan_id", ["beginner", "expert"])
      .order("updated_at", { ascending: false })
      .limit(1)
      .maybeSingle(),
    client
      .from("subscriptions")
      .select("plan_id, status, billing_interval, current_period_end")
      .eq("user_id", user.id)
      .order("updated_at", { ascending: false })
      .limit(1)
      .maybeSingle(),
    client
      .from("profiles")
      .select("free_adaptation_limit, free_adaptations_used, welcome_completed_at, gear_onboarding_completed_at, tone_database_seen_at, first_adaptation_completed_at")
      .eq("id", user.id)
      .maybeSingle()
  ]);

  const subscription = normalizeSubscription(activeResult.data || latestResult.data || null);
  const usageWindow = currentUsageWindow();

  const [monthlyUsageResult, freeUsageEventsResult, savedThisMonthResult, presetsThisMonthResult, savedTotalResult, presetsTotalResult] = await Promise.all([
    client
      .from("monthly_usage")
      .select("adaptations_used")
      .eq("user_id", user.id)
      .eq("usage_month", usageWindow.usageMonth)
      .maybeSingle(),
    client
      .from("usage_events")
      .select("id", { count: "exact", head: true })
      .eq("user_id", user.id)
      .eq("event_type", "tone_adaptation")
      .contains("metadata", { plan: "free" }),
    client
      .from("saved_tones")
      .select("id", { count: "exact", head: true })
      .eq("user_id", user.id)
      .gte("created_at", usageWindow.monthStartIso),
    client
      .from("gear_presets")
      .select("id", { count: "exact", head: true })
      .eq("user_id", user.id)
      .gte("created_at", usageWindow.monthStartIso),
    client
      .from("saved_tones")
      .select("id", { count: "exact", head: true })
      .eq("user_id", user.id),
    client
      .from("gear_presets")
      .select("id", { count: "exact", head: true })
      .eq("user_id", user.id)
  ]);

  const planId = subscription?.planId || null;
  const plan = planId ? plans.find((item) => item.id === planId) || null : null;
  const limits = planId ? planLimits[planId] : null;
  const profile = (profileResult.data as RawProfile | null) || null;
  let effectiveFreeLimit = profile?.free_adaptation_limit;
  if (earlyTesterMode && (effectiveFreeLimit === null || effectiveFreeLimit === 0) && (profile?.free_adaptations_used === null || profile?.free_adaptations_used === 0)) {
    effectiveFreeLimit = EARLY_TESTER_FREE_ADAPTATIONS;
  }
  const freeAdaptationsUsed = Math.max(profile?.free_adaptations_used || 0, freeUsageEventsResult.count || 0);
  const freeQuota = createFreeAdaptationQuota(effectiveFreeLimit, freeAdaptationsUsed);
  const onboarding = createOnboardingProgressState(profile);
  const adaptationsUsed = monthlyUsageResult.data?.adaptations_used || 0;
  const savedTonesUsed = savedThisMonthResult.count || 0;
  const gearPresetsUsed = presetsThisMonthResult.count || 0;
  const hasPaidAccess = Boolean(subscription?.isActive && planId);
  const adaptationAccess = resolveAdaptationAccessState({
    entitlement: {
      hasAccess: hasPaidAccess,
      source: hasPaidAccess ? "subscription" : "none",
      planId,
      status: subscription?.status || null,
      monthlyAdaptations: limits?.monthlyAdaptations ?? null,
      savedTonesLimit: limits?.savedTonesLimit ?? null
    },
    isAuthenticated: true,
    freeQuota,
    onboarding
  });
  const visibleAdaptationsUsed = hasPaidAccess ? adaptationsUsed : freeQuota.used;
  const visibleAdaptationsRemaining = hasPaidAccess ? limits?.monthlyAdaptations == null ? null : Math.max(limits.monthlyAdaptations - adaptationsUsed, 0) : freeQuota.remaining;

  return {
    user,
    planId,
    planName: plan?.name || (user ? "Free" : null),
    status: subscription?.status || null,
    billingInterval: subscription?.billingInterval || null,
    renewalDate: subscription?.renewalDate || null,
    hasAccess: hasPaidAccess,
    features: plan?.perks || [],
    adaptationAccess,
    onboarding,
    usage: {
      adaptationsUsed: visibleAdaptationsUsed,
      adaptationsRemaining: visibleAdaptationsRemaining,
      savedTonesUsed,
      savedTonesRemaining: limits?.savedTonesLimit == null ? null : Math.max(limits.savedTonesLimit - savedTonesUsed, 0),
      gearPresetsUsed,
      gearPresetsRemaining: limits?.gearPresetsLimit == null ? null : Math.max(limits.gearPresetsLimit - gearPresetsUsed, 0),
      freeAdaptationLimit: freeQuota.limit,
      freeAdaptationsUsed: freeQuota.used,
      freeAdaptationsRemaining: freeQuota.remaining
    },
    totals: {
      savedTones: savedTotalResult.count || 0,
      gearPresets: presetsTotalResult.count || 0
    }
  };
}

export function isActiveSubscriptionStatus(status: string | null | undefined) {
  return status === "active" || status === "trialing";
}

export function formatSubscriptionStatus(status: string | null | undefined) {
  if (!status) {
    return "Inactive";
  }

  return status.replaceAll("_", " ");
}

export function formatSubscriptionDate(value: string | null | undefined) {
  if (!value) {
    return "soon";
  }

  const date = new Date(value);
  if (Number.isNaN(date.getTime())) {
    return "soon";
  }

  return date.toLocaleDateString(undefined, {
    year: "numeric",
    month: "short",
    day: "numeric"
  });
}

function currentUsageWindow() {
  const now = new Date();
  const monthStart = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), 1, 0, 0, 0, 0));

  return {
    usageMonth: monthStart.toISOString().slice(0, 10),
    monthStartIso: monthStart.toISOString()
  };
}

function emptySnapshot(): ClientSubscriptionSnapshot {
  return {
    user: null,
    planId: null,
    planName: null,
    status: null,
    billingInterval: null,
    renewalDate: null,
    hasAccess: false,
    features: [],
    adaptationAccess: resolveAdaptationAccessState({
      entitlement: {
        hasAccess: false,
        source: "none",
        planId: null,
        status: null,
        monthlyAdaptations: null,
        savedTonesLimit: null
      },
      isAuthenticated: false,
      freeQuota: createFreeAdaptationQuota(),
      onboarding: createOnboardingProgressState(null)
    }),
    onboarding: createOnboardingProgressState(null),
    usage: {
      adaptationsUsed: 0,
      adaptationsRemaining: null,
      savedTonesUsed: 0,
      savedTonesRemaining: null,
      gearPresetsUsed: 0,
      gearPresetsRemaining: null,
      freeAdaptationLimit: createFreeAdaptationQuota().limit,
      freeAdaptationsUsed: 0,
      freeAdaptationsRemaining: createFreeAdaptationQuota().remaining
    },
    totals: {
      savedTones: 0,
      gearPresets: 0
    }
  };
}

function normalizeSubscription(subscription: RawSubscription | null): {
  planId: PlanId | null;
  billingInterval: BillingInterval | null;
  status: string | null;
  renewalDate: string | null;
  isActive: boolean;
} | null {
  if (!subscription) {
    return null;
  }

  const planId = subscription.plan_id === "beginner" || subscription.plan_id === "expert" ? subscription.plan_id : null;
  const billingInterval = subscription.billing_interval === "monthly" ? "monthly" : subscription.billing_interval === "annual" ? "annual" : null;

  return {
    planId,
    billingInterval,
    status: subscription.status || null,
    renewalDate: subscription.current_period_end || null,
    isActive: isActiveSubscriptionStatus(subscription.status)
  };
}
