import type { ClientSubscriptionSnapshot } from "@/lib/subscription-client";

export function getAdaptationSummaryProps(snapshot: ClientSubscriptionSnapshot) {
  if (snapshot.adaptationAccess.isUnlimited) {
    return {
      remaining: 0,
      limit: 0,
      unlimited: true,
      label: "Adaptations Remaining",
      helpText: "Unlimited adaptations are available with your current plan.",
      valueText: "Unlimited adaptations available."
    };
  }

  if (snapshot.hasAccess) {
    const remaining = snapshot.usage.adaptationsRemaining ?? 0;
    return {
      remaining,
      limit: snapshot.usage.adaptationsUsed + remaining,
      unlimited: false,
      label: "Adaptations Remaining",
      helpText: "Your paid usage refreshes each billing cycle.",
      valueText: `${remaining} plan adaptations remaining`
    };
  }

  return {
    remaining: snapshot.usage.freeAdaptationsRemaining,
    limit: snapshot.usage.freeAdaptationLimit,
    unlimited: false,
    label: `${snapshot.usage.freeAdaptationsRemaining} Free Adaptation${snapshot.usage.freeAdaptationsRemaining === 1 ? "" : "s"} Remaining`,
    helpText: "Only successful Generate My Tone clicks use one.",
    valueText: "Generate My Tone only"
  };
}

export function shouldShowFreeOnboardingJourney(snapshot: ClientSubscriptionSnapshot | null, onboardingMode: boolean) {
  return Boolean(onboardingMode && snapshot?.user && !snapshot.hasAccess && !snapshot.onboarding.firstAdaptationCompleted);
}

export function getFreeAdaptationBannerCopy(snapshot: ClientSubscriptionSnapshot | null) {
  if (!snapshot || snapshot.hasAccess) {
    return null;
  }

  const remaining = snapshot.usage.freeAdaptationsRemaining;
  if (remaining <= 0) {
    return {
      title: "You’ve used all 3 free adaptations.",
      body: "Upgrade to Expert to keep adapting tones with your saved gear."
    };
  }

  return {
    title: `You have ${remaining} free adaptation${remaining === 1 ? "" : "s"} remaining.`,
    body: "Only a successful adapted tone uses a credit. Searching, browsing, and changing your gear do not."
  };
}
