import type { SupabaseClient, User } from "@supabase/supabase-js";
import { createFreeAdaptationQuota } from "@/lib/adaptation-access";
import { type Entitlement } from "@/lib/entitlements";

export function currentUsageMonth() {
  const now = new Date();
  return `${now.getUTCFullYear()}-${String(now.getUTCMonth() + 1).padStart(2, "0")}-01`;
}

type ProfileUsageRow = {
  free_adaptation_limit: number | null;
  free_adaptations_used: number | null;
  first_adaptation_completed_at?: string | null;
};

export type AdaptationEligibility = {
  ok: boolean;
  error?: string;
  path?: "expert" | "beginner" | "free";
  freeAdaptationsRemaining?: number;
  monthlyAdaptationsRemaining?: number | null;
};

export type AdaptationRequestSource = "manual_generate" | "tone_database_adapt_to_my_gear" | "saved_tone_readapt";

export type AdaptationConfirmationResult = {
  ok: boolean;
  confirmed: boolean;
  usageApplied: boolean;
  freeAdaptationsRemaining: number;
  freeAdaptationsUsed: number;
  freeAdaptationLimit: number;
  monthlyAdaptationsRemaining: number | null;
  firstAdaptationCompleted: boolean;
  error?: string;
};

export async function assertCanCreateAdaptation(
  admin: SupabaseClient | null,
  user: User,
  entitlement: Entitlement,
  requestSource: AdaptationRequestSource = "manual_generate"
): Promise<AdaptationEligibility> {
  if (!admin) {
    return { ok: false, error: "SUPABASE_SERVICE_ROLE_KEY is required for usage enforcement." };
  }

  await ensureProfileUsageRow(admin, user);
  const profileQuota = await loadProfileUsage(admin, user.id);

  if (entitlement.source === "test" || (entitlement.hasAccess && entitlement.planId === "expert")) {
    return {
      ok: true,
      path: "expert",
      freeAdaptationsRemaining: profileQuota.remaining,
      monthlyAdaptationsRemaining: null
    };
  }

  if (entitlement.hasAccess && entitlement.monthlyAdaptations !== null) {
    const { data } = await admin
      .from("monthly_usage")
      .select("adaptations_used")
      .eq("user_id", user.id)
      .eq("usage_month", currentUsageMonth())
      .maybeSingle();

    const used = data?.adaptations_used || 0;
    if (used >= entitlement.monthlyAdaptations) {
      return {
        ok: false,
        error: "Monthly adaptation limit reached. Upgrade to Expert for unlimited matching.",
        path: "beginner",
        freeAdaptationsRemaining: profileQuota.remaining,
        monthlyAdaptationsRemaining: 0
      };
    }

    return {
      ok: true,
      path: "beginner",
      freeAdaptationsRemaining: profileQuota.remaining,
      monthlyAdaptationsRemaining: Math.max(entitlement.monthlyAdaptations - used, 0)
    };
  }

  if (requestSource !== "manual_generate") {
    return {
      ok: false,
      error: "This adaptation workflow requires a paid subscription. Start a free trial or upgrade for full access.",
      path: "free",
      freeAdaptationsRemaining: profileQuota.remaining,
      monthlyAdaptationsRemaining: null
    };
  }

  if (profileQuota.remaining <= 0) {
    return {
      ok: false,
      error: "Start a free trial to unlock tone adaptations, or upgrade to Expert for unlimited access.",
      path: "free",
      freeAdaptationsRemaining: 0,
      monthlyAdaptationsRemaining: null
    };
  }

  return {
    ok: true,
    path: "free",
    freeAdaptationsRemaining: profileQuota.remaining,
    monthlyAdaptationsRemaining: null
  };
}

export async function incrementAdaptationUsage(admin: SupabaseClient | null, userId: string, toneJobId: string | null) {
  if (!admin) {
    return;
  }

  const month = currentUsageMonth();
  const { data } = await admin.from("monthly_usage").select("adaptations_used").eq("user_id", userId).eq("usage_month", month).maybeSingle();
  const nextCount = (data?.adaptations_used || 0) + 1;

  await admin.from("monthly_usage").upsert({
    user_id: userId,
    usage_month: month,
    adaptations_used: nextCount
  });

  await admin.from("usage_events").insert({
    user_id: userId,
    event_type: "tone_adaptation",
    tone_job_id: toneJobId,
    quantity: 1
  });
}

export async function recordSuccessfulAdaptationUsage(
  admin: SupabaseClient | null,
  user: User,
  toneResultId: string,
  entitlement: Entitlement
): Promise<AdaptationConfirmationResult> {
  if (!admin) {
    return {
      ok: false,
      confirmed: false,
      usageApplied: false,
      freeAdaptationsRemaining: 0,
      freeAdaptationsUsed: 0,
      freeAdaptationLimit: 0,
      monthlyAdaptationsRemaining: null,
      firstAdaptationCompleted: false,
      error: "SUPABASE_SERVICE_ROLE_KEY is required for usage confirmation."
    };
  }

  const userId = user.id;
  await ensureProfileUsageRow(admin, user);

  const { data: toneResult, error: toneResultError } = await admin
    .from("tone_results")
    .select("id, job_id")
    .eq("id", toneResultId)
    .eq("user_id", userId)
    .maybeSingle();

  if (toneResultError || !toneResult) {
    return {
      ok: false,
      confirmed: false,
      usageApplied: false,
      freeAdaptationsRemaining: 0,
      freeAdaptationsUsed: 0,
      freeAdaptationLimit: 0,
      monthlyAdaptationsRemaining: null,
      firstAdaptationCompleted: false,
      error: toneResultError?.message || "Tone result not found."
    };
  }

  const profileQuota = await loadProfileUsage(admin, userId);
  const alreadyConfirmed = await hasUsageEventForToneResult(admin, userId, toneResultId);

  if (alreadyConfirmed) {
    const currentMonthlyRemaining = await readMonthlyAdaptationsRemaining(admin, userId, entitlement);
    return {
      ok: true,
      confirmed: true,
      usageApplied: false,
      freeAdaptationsRemaining: profileQuota.remaining,
      freeAdaptationsUsed: profileQuota.used,
      freeAdaptationLimit: profileQuota.limit,
      monthlyAdaptationsRemaining: currentMonthlyRemaining,
      firstAdaptationCompleted: true
    };
  }

  await markFirstAdaptationCompleted(admin, userId, new Date().toISOString());

  if (entitlement.source === "test" || (entitlement.hasAccess && entitlement.planId === "expert")) {
    const refreshedQuota = await loadProfileUsage(admin, userId);
    return {
      ok: true,
      confirmed: true,
      usageApplied: false,
      freeAdaptationsRemaining: refreshedQuota.remaining,
      freeAdaptationsUsed: refreshedQuota.used,
      freeAdaptationLimit: refreshedQuota.limit,
      monthlyAdaptationsRemaining: null,
      firstAdaptationCompleted: true
    };
  }

  if (entitlement.hasAccess && entitlement.monthlyAdaptations !== null) {
    const month = currentUsageMonth();
    const { data } = await admin.from("monthly_usage").select("adaptations_used").eq("user_id", userId).eq("usage_month", month).maybeSingle();
    const nextCount = (data?.adaptations_used || 0) + 1;

    const { error: monthlyUsageError } = await admin.from("monthly_usage").upsert({
      user_id: userId,
      usage_month: month,
      adaptations_used: nextCount
    });

    if (monthlyUsageError) {
      return {
        ok: false,
        confirmed: false,
        usageApplied: false,
        freeAdaptationsRemaining: profileQuota.remaining,
        freeAdaptationsUsed: profileQuota.used,
        freeAdaptationLimit: profileQuota.limit,
        monthlyAdaptationsRemaining: entitlement.monthlyAdaptations,
        firstAdaptationCompleted: Boolean(profileQuota.firstAdaptationCompletedAt),
        error: monthlyUsageError.message
      };
    }

    const { error: eventError } = await admin.from("usage_events").insert({
      user_id: userId,
      event_type: "tone_adaptation",
      tone_job_id: toneResult.job_id,
      quantity: 1,
      metadata: { source: "tone_result_confirmation", tone_result_id: toneResultId }
    });

    if (eventError) {
      return {
        ok: false,
        confirmed: false,
        usageApplied: false,
        freeAdaptationsRemaining: profileQuota.remaining,
        freeAdaptationsUsed: profileQuota.used,
        freeAdaptationLimit: profileQuota.limit,
        monthlyAdaptationsRemaining: entitlement.monthlyAdaptations,
        firstAdaptationCompleted: Boolean(profileQuota.firstAdaptationCompletedAt),
        error: eventError.message
      };
    }

    const refreshedQuota = await loadProfileUsage(admin, userId);
    return {
      ok: true,
      confirmed: true,
      usageApplied: true,
      freeAdaptationsRemaining: refreshedQuota.remaining,
      freeAdaptationsUsed: refreshedQuota.used,
      freeAdaptationLimit: refreshedQuota.limit,
      monthlyAdaptationsRemaining: Math.max(entitlement.monthlyAdaptations - nextCount, 0),
      firstAdaptationCompleted: true
    };
  }

  if (profileQuota.remaining <= 0) {
    return {
      ok: false,
      confirmed: false,
      usageApplied: false,
      freeAdaptationsRemaining: 0,
      freeAdaptationsUsed: profileQuota.used,
      freeAdaptationLimit: profileQuota.limit,
      monthlyAdaptationsRemaining: null,
      firstAdaptationCompleted: Boolean(profileQuota.firstAdaptationCompletedAt),
      error: "You've used your 3 free adaptations. Upgrade to Expert for unlimited tone adaptations."
    };
  }

  const nextFreeUsed = Math.min(profileQuota.used + 1, profileQuota.limit);
  const { error: eventError } = await admin.from("usage_events").insert({
    user_id: userId,
    event_type: "tone_adaptation",
    tone_job_id: toneResult.job_id,
    quantity: 1,
    metadata: { source: "tone_result_confirmation", tone_result_id: toneResultId, plan: "free" }
  });

  if (eventError) {
    return {
      ok: false,
      confirmed: false,
      usageApplied: false,
      freeAdaptationsRemaining: profileQuota.remaining,
      freeAdaptationsUsed: profileQuota.used,
      freeAdaptationLimit: profileQuota.limit,
      monthlyAdaptationsRemaining: null,
      firstAdaptationCompleted: Boolean(profileQuota.firstAdaptationCompletedAt),
      error: eventError.message
    };
  }

  const { error: freeUsageError } = await admin
    .from("profiles")
    .update({
      free_adaptations_used: nextFreeUsed
    })
    .eq("id", userId);

  if (freeUsageError) {
    console.error("[tonefex:usage] Failed to update profile free adaptation counter after recording event.", {
      userId,
      toneResultId,
      message: freeUsageError.message
    });
  }

  const refreshedQuota = await loadProfileUsage(admin, userId);

  return {
    ok: true,
    confirmed: true,
    usageApplied: true,
    freeAdaptationsRemaining: refreshedQuota.remaining,
    freeAdaptationsUsed: refreshedQuota.used,
    freeAdaptationLimit: refreshedQuota.limit,
    monthlyAdaptationsRemaining: null,
    firstAdaptationCompleted: true
  };
}

export async function confirmToneAdaptationUsage(
  admin: SupabaseClient | null,
  user: User,
  toneResultId: string,
  entitlement: Entitlement
): Promise<AdaptationConfirmationResult> {
  return recordSuccessfulAdaptationUsage(admin, user, toneResultId, entitlement);
}

async function loadProfileUsage(admin: SupabaseClient, userId: string) {
  const { data, error } = await admin
    .from("profiles")
    .select("free_adaptation_limit, free_adaptations_used, first_adaptation_completed_at")
    .eq("id", userId)
    .maybeSingle();

  if (error) {
    console.error("[tonefex:usage] Failed to load free adaptation profile.", {
      userId,
      message: error.message
    });
  }

  const row = (data as ProfileUsageRow | null) || null;
  const eventUsage = await countConfirmedFreeAdaptations(admin, userId);
  const rawQuota = createFreeAdaptationQuota(row?.free_adaptation_limit, row?.free_adaptations_used);
  const reconciledUsed = Math.min(Math.max(rawQuota.used, eventUsage), rawQuota.limit);
  const quota = createFreeAdaptationQuota(rawQuota.limit, reconciledUsed);

  if (row && reconciledUsed > rawQuota.used) {
    const { error: reconcileError } = await admin
      .from("profiles")
      .update({ free_adaptations_used: reconciledUsed })
      .eq("id", userId);

    if (reconcileError) {
      console.error("[tonefex:usage] Failed to reconcile free adaptation counter.", {
        userId,
        message: reconcileError.message
      });
    }
  }

  return {
    ...quota,
    firstAdaptationCompletedAt: row?.first_adaptation_completed_at || null
  };
}

async function ensureProfileUsageRow(admin: SupabaseClient, user: User) {
  const { data: existingProfile, error: readError } = await admin
    .from("profiles")
    .select("id")
    .eq("id", user.id)
    .maybeSingle();

  if (existingProfile?.id) {
    return;
  }

  if (readError) {
    console.error("[tonefex:usage] Failed to check profile row for adaptation usage.", {
      userId: user.id,
      message: readError.message
    });
  }

  const { error } = await admin.from("profiles").insert({
    id: user.id,
    email: user.email || `${user.id}@tonefex.local`
  });

  if (error && error.code !== "23505") {
    console.error("[tonefex:usage] Failed to ensure profile row for adaptation usage.", {
      userId: user.id,
      message: error.message
    });
  }
}

async function countConfirmedFreeAdaptations(admin: SupabaseClient, userId: string) {
  const { count, error } = await admin
    .from("usage_events")
    .select("id", { count: "exact", head: true })
    .eq("user_id", userId)
    .eq("event_type", "tone_adaptation")
    .contains("metadata", { plan: "free" });

  if (error) {
    console.error("[tonefex:usage] Failed to count confirmed free adaptations.", {
      userId,
      message: error.message
    });
  }

  return count || 0;
}

async function hasUsageEventForToneResult(admin: SupabaseClient, userId: string, toneResultId: string) {
  const { data, error } = await admin
    .from("usage_events")
    .select("id")
    .eq("user_id", userId)
    .eq("event_type", "tone_adaptation")
    .contains("metadata", { tone_result_id: toneResultId })
    .limit(1)
    .maybeSingle();

  if (error) {
    console.error("[tonefex:usage] Failed to check existing adaptation usage event.", {
      userId,
      toneResultId,
      message: error.message
    });
  }

  return Boolean(data?.id);
}

async function readMonthlyAdaptationsRemaining(admin: SupabaseClient, userId: string, entitlement: Entitlement) {
  if (!entitlement.hasAccess || entitlement.monthlyAdaptations === null) {
    return entitlement.planId === "expert" || entitlement.source === "test" ? null : null;
  }

  const { data } = await admin
    .from("monthly_usage")
    .select("adaptations_used")
    .eq("user_id", userId)
    .eq("usage_month", currentUsageMonth())
    .maybeSingle();

  return Math.max(entitlement.monthlyAdaptations - (data?.adaptations_used || 0), 0);
}

async function markFirstAdaptationCompleted(admin: SupabaseClient, userId: string, confirmedAt: string) {
  const { error } = await admin
    .from("profiles")
    .update({ first_adaptation_completed_at: confirmedAt })
    .eq("id", userId)
    .is("first_adaptation_completed_at", null);

  if (error) {
    console.error("[tonefex:usage] Failed to mark first adaptation completed.", {
      userId,
      message: error.message
    });
  }
}
