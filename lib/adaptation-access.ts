import type { Entitlement } from "@/lib/entitlements";

export const DEFAULT_FREE_ADAPTATION_LIMIT = 0;

export type ProfileAccessRow = {
  free_adaptation_limit?: number | null;
  free_adaptations_used?: number | null;
  welcome_completed_at?: string | null;
  gear_onboarding_completed_at?: string | null;
  tone_database_seen_at?: string | null;
  first_adaptation_completed_at?: string | null;
};

export type FreeAdaptationQuota = {
  limit: number;
  used: number;
  remaining: number;
};

export type OnboardingProgressState = {
  welcomeCompleted: boolean;
  gearSetupCompleted: boolean;
  toneDatabaseVisited: boolean;
  firstAdaptationCompleted: boolean;
};

export type AdaptationAccessState = {
  free: FreeAdaptationQuota;
  onboarding: OnboardingProgressState;
  canAdapt: boolean;
  requiresUpgrade: boolean;
  isUnlimited: boolean;
  path: "expert" | "beginner" | "free" | "anonymous";
};

export function createFreeAdaptationQuota(limit?: number | null, used?: number | null): FreeAdaptationQuota {
  const normalizedLimit = normalizeNonNegativeInteger(limit, DEFAULT_FREE_ADAPTATION_LIMIT);
  const normalizedUsed = Math.min(normalizeNonNegativeInteger(used, 0), normalizedLimit);

  return {
    limit: normalizedLimit,
    used: normalizedUsed,
    remaining: Math.max(normalizedLimit - normalizedUsed, 0)
  };
}

export function createOnboardingProgressState(profile?: ProfileAccessRow | null): OnboardingProgressState {
  return {
    welcomeCompleted: Boolean(profile?.welcome_completed_at),
    gearSetupCompleted: Boolean(profile?.gear_onboarding_completed_at),
    toneDatabaseVisited: Boolean(profile?.tone_database_seen_at),
    firstAdaptationCompleted: Boolean(profile?.first_adaptation_completed_at)
  };
}

export function resolveAdaptationAccessState(input: {
  entitlement: Entitlement;
  isAuthenticated: boolean;
  freeQuota: FreeAdaptationQuota;
  onboarding: OnboardingProgressState;
}): AdaptationAccessState {
  const { entitlement, isAuthenticated, freeQuota, onboarding } = input;

  if (!isAuthenticated) {
    return {
      free: freeQuota,
      onboarding,
      canAdapt: false,
      requiresUpgrade: false,
      isUnlimited: false,
      path: "anonymous"
    };
  }

  if (entitlement.source === "test" || (entitlement.hasAccess && entitlement.planId === "expert")) {
    return {
      free: freeQuota,
      onboarding,
      canAdapt: true,
      requiresUpgrade: false,
      isUnlimited: true,
      path: "expert"
    };
  }

  if (entitlement.hasAccess) {
    return {
      free: freeQuota,
      onboarding,
      canAdapt: true,
      requiresUpgrade: false,
      isUnlimited: entitlement.monthlyAdaptations == null,
      path: "beginner"
    };
  }

  return {
    free: freeQuota,
    onboarding,
    canAdapt: freeQuota.remaining > 0,
    requiresUpgrade: freeQuota.remaining <= 0,
    isUnlimited: false,
    path: "free"
  };
}

function normalizeNonNegativeInteger(value: number | null | undefined, fallback: number) {
  if (typeof value === "number" && Number.isFinite(value)) {
    return Math.max(Math.trunc(value), 0);
  }

  return fallback;
}
