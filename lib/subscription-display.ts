import type { ClientSubscriptionSnapshot } from "@/lib/subscription-client";

const earlyTesterMode = process.env.NEXT_PUBLIC_EARLY_TESTER_MODE === "true";

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

  if (snapshot.usage.freeAdaptationLimit > 0 && snapshot.usage.freeAdaptationsRemaining > 0) {
    const r = snapshot.usage.freeAdaptationsRemaining;
    return {
      remaining: r,
      limit: snapshot.usage.freeAdaptationLimit,
      unlimited: false,
      label: earlyTesterMode
        ? `${r} Free Adaptation${r === 1 ? "" : "s"} Remaining`
        : `${r} Free Adaptation${r === 1 ? "" : "s"} Remaining`,
      helpText: earlyTesterMode
        ? "Share feedback after your adaptations to unlock unlimited access."
        : "Only successful Generate My Tone clicks use one.",
      valueText: earlyTesterMode
        ? (r === 1 ? "This is your final free adaptation" : `${r} free adaptation${r === 1 ? "" : "s"} remaining`)
        : "Generate My Tone only"
    };
  }

  if (earlyTesterMode) {
    return {
      remaining: 0,
      limit: 0,
      unlimited: false,
      showFeedbackCta: true,
      label: "Adaptations Used",
      helpText: "Share your feedback to unlock unlimited access.",
      valueText: "Share feedback to continue"
    };
  }

  return {
    remaining: 0,
    limit: 0,
    unlimited: false,
    showTrialCta: true,
    label: "No Active Plan",
    helpText: "Start a free trial to unlock adaptations.",
    valueText: "3-day free trial available"
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
  const limit = snapshot.usage.freeAdaptationLimit;

  if (limit > 0 && remaining > 0) {
    return {
      title: `You have ${remaining} free adaptation${remaining === 1 ? "" : "s"} remaining.`,
      body: "Only a successful adapted tone uses a credit. Searching, browsing, and changing your gear do not."
    };
  }

  if (earlyTesterMode) {
    return {
      title: "You've used all your free adaptations.",
      body: "Share your feedback to unlock a complimentary Expert Plan with unlimited access."
    };
  }

  return {
    title: "Start your 3-day free trial to get started.",
    body: "Pick a plan and try Tonefex free — cancel anytime."
  };
}
