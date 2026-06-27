import type { SupabaseClient, User } from "@supabase/supabase-js";
import { planLimits } from "@/lib/entitlements";
import { plans } from "@/lib/mock-data";

export type PlanId = "beginner" | "expert";
export type BillingInterval = "monthly" | "annual";

type RawSubscription = {
  plan_id: string | null;
  status: string;
  billing_interval: string | null;
  current_period_end: string | null;
};

type UsageSnapshot = {
  adaptationsUsed: number;
  adaptationsRemaining: number | null;
  savedTonesUsed: number;
  savedTonesRemaining: number | null;
  gearPresetsUsed: number;
  gearPresetsRemaining: number | null;
  starterAdaptationsRemaining: number | null;
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
  usage: UsageSnapshot;
  totals: {
    savedTones: number;
    gearPresets: number;
  };
};

const starterAdaptationLimits: Record<PlanId, number | null> = {
  beginner: 5,
  expert: null
};

export async function loadClientSubscriptionSnapshot(client: SupabaseClient): Promise<ClientSubscriptionSnapshot> {
  const {
    data: { user }
  } = await client.auth.getUser();

  if (!user) {
    return emptySnapshot();
  }

  const [activeResult, latestResult] = await Promise.all([
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
      .maybeSingle()
  ]);

  const subscription = normalizeSubscription(activeResult.data || latestResult.data || null);
  const usageWindow = currentUsageWindow();

  const [monthlyUsageResult, savedThisMonthResult, presetsThisMonthResult, savedTotalResult, presetsTotalResult] = await Promise.all([
    client
      .from("monthly_usage")
      .select("adaptations_used")
      .eq("user_id", user.id)
      .eq("usage_month", usageWindow.usageMonth)
      .maybeSingle(),
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
  const adaptationsUsed = monthlyUsageResult.data?.adaptations_used || 0;
  const savedTonesUsed = savedThisMonthResult.count || 0;
  const gearPresetsUsed = presetsThisMonthResult.count || 0;
  const starterLimit = planId ? starterAdaptationLimits[planId] : null;

  return {
    user,
    planId,
    planName: plan?.name || null,
    status: subscription?.status || null,
    billingInterval: subscription?.billingInterval || null,
    renewalDate: subscription?.renewalDate || null,
    hasAccess: Boolean(subscription?.isActive && planId),
    features: plan?.perks || [],
    usage: {
      adaptationsUsed,
      adaptationsRemaining: limits?.monthlyAdaptations == null ? null : Math.max(limits.monthlyAdaptations - adaptationsUsed, 0),
      savedTonesUsed,
      savedTonesRemaining: limits?.savedTonesLimit == null ? null : Math.max(limits.savedTonesLimit - savedTonesUsed, 0),
      gearPresetsUsed,
      gearPresetsRemaining: limits?.gearPresetsLimit == null ? null : Math.max(limits.gearPresetsLimit - gearPresetsUsed, 0),
      starterAdaptationsRemaining: starterLimit == null ? null : Math.max(starterLimit - adaptationsUsed, 0)
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
    usage: {
      adaptationsUsed: 0,
      adaptationsRemaining: null,
      savedTonesUsed: 0,
      savedTonesRemaining: null,
      gearPresetsUsed: 0,
      gearPresetsRemaining: null,
      starterAdaptationsRemaining: null
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
