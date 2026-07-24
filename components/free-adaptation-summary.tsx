"use client";

import Link from "next/link";
import { Gift, MessageSquareHeart, Play, Sparkles } from "lucide-react";

export function FreeAdaptationSummary({
  remaining,
  limit,
  unlimited = false,
  showTrialCta = false,
  showFeedbackCta = false,
  label,
  helpText,
  valueText,
  className = ""
}: {
  remaining: number;
  limit: number;
  unlimited?: boolean;
  showTrialCta?: boolean;
  showFeedbackCta?: boolean;
  label?: string;
  helpText?: string;
  valueText?: string;
  className?: string;
}) {
  if (showFeedbackCta) {
    return (
      <Link href="/feedback" className={`block rounded-lg border border-amber-200 bg-gradient-to-r from-amber-50 to-orange-50 px-4 py-3 shadow-sm transition-colors hover:from-amber-100 hover:to-orange-100 ${className}`.trim()}>
        <div className="flex items-center gap-3">
          <div className="grid h-10 w-10 place-items-center rounded-md bg-amber-500 text-white">
            <MessageSquareHeart className="h-5 w-5" />
          </div>
          <div>
            <div className="text-xs font-bold uppercase tracking-[0.14em] text-amber-700">
              Help Shape Tonefex
            </div>
            <div className="mt-1 text-sm font-semibold text-amber-900">
              Share feedback &amp; unlock unlimited access
            </div>
          </div>
        </div>
      </Link>
    );
  }

  if (showTrialCta) {
    return (
      <Link href="/plans" className={`block rounded-lg border border-ink/20 bg-ink px-4 py-3 shadow-sm transition-colors hover:bg-ink/90 ${className}`.trim()}>
        <div className="flex items-center gap-3">
          <div className="grid h-10 w-10 place-items-center rounded-md bg-moss text-ink">
            <Play className="h-5 w-5" />
          </div>
          <div>
            <div className="text-xs font-bold uppercase tracking-[0.14em] text-white/70">
              No Active Plan
            </div>
            <div className="mt-1 text-sm font-semibold text-white">
              Start 3-Day Free Trial
            </div>
          </div>
        </div>
      </Link>
    );
  }

  return (
    <div className={`rounded-lg border border-white/80 bg-white/80 px-4 py-3 shadow-sm ${className}`.trim()}>
      <div className="flex items-center justify-between gap-4">
        <div className="flex items-center gap-3">
          <div className={`grid h-10 w-10 place-items-center rounded-md ${unlimited ? "bg-ink text-moss" : "bg-moss text-ink"}`}>
            {unlimited ? <Sparkles className="h-5 w-5" /> : <Gift className="h-5 w-5" />}
          </div>
          <div>
            <div className="text-xs font-bold uppercase tracking-[0.14em] text-slate-500">
              {unlimited ? "Expert Access" : label || "Free Adaptations Remaining"}
            </div>
            <div className="mt-1 text-sm font-semibold text-ink">
              {unlimited ? "Unlimited adaptations available." : valueText || `${remaining} / ${limit}`}
            </div>
          </div>
        </div>
        {!unlimited ? <div className="text-xs text-slate-500">{helpText || "Only successful adaptations use a credit."}</div> : null}
      </div>
    </div>
  );
}
