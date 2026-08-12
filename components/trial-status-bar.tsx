"use client";

import { Flame } from "lucide-react";
import { UnlockAccessButton } from "@/components/unlock-access-modal";
import type { ClientSubscriptionSnapshot } from "@/lib/subscription-client";

/**
 * ToneAdapt-style trial banner for the Match Tone page: adaptations remaining +
 * days left in the trial + an Unlock Full Access CTA that converts the existing
 * trial (no second checkout). Renders only while the user is on a free trial.
 */
export function TrialStatusBar({ snapshot }: { snapshot: ClientSubscriptionSnapshot | null }) {
  if (!snapshot?.isTrialing) {
    return null;
  }

  const unlimited = snapshot.adaptationAccess.isUnlimited;
  const remaining = snapshot.usage.adaptationsRemaining ?? 0;
  const limit = snapshot.usage.adaptationsUsed + remaining;
  const days = snapshot.trialDaysRemaining;

  return (
    <div className="relative mx-auto mt-6 max-w-3xl">
      {typeof days === "number" ? (
        <span className="absolute -top-3 right-4 z-10 flex items-center gap-1 rounded-full bg-amber-500 px-3 py-1 text-xs font-bold text-white shadow-md">
          <Flame className="h-3.5 w-3.5" />
          {days} day{days === 1 ? "" : "s"} left in trial
        </span>
      ) : null}
      <div className="flex flex-col items-center justify-between gap-4 rounded-2xl border border-moss/60 bg-white/90 px-5 py-4 shadow-sm sm:flex-row">
        <div className="flex items-center gap-3">
          <span className="grid h-9 w-9 shrink-0 place-items-center rounded-full bg-moss/25">
            <span className="h-2.5 w-2.5 rounded-full bg-emerald-500" />
          </span>
          <div className="text-left">
            <div className="text-sm font-bold text-ink">
              Free trial{unlimited ? "" : `: ${limit} total`}
            </div>
            <div className="text-sm text-slate-600">
              {unlimited ? "Unlimited adaptations during your trial" : `${remaining} adaptation${remaining === 1 ? "" : "s"} remaining`}
            </div>
          </div>
        </div>
        <UnlockAccessButton
          className="button-primary w-full justify-center sm:w-auto"
          label="Unlock Full Access"
          planId={snapshot.planId}
          billingInterval={snapshot.billingInterval}
          convert
        />
      </div>
    </div>
  );
}
