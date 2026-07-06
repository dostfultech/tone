"use client";

import { Gift, Sparkles } from "lucide-react";

export function FreeAdaptationSummary({
  remaining,
  limit,
  unlimited = false,
  label,
  helpText,
  className = ""
}: {
  remaining: number;
  limit: number;
  unlimited?: boolean;
  label?: string;
  helpText?: string;
  className?: string;
}) {
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
              {unlimited ? "Unlimited adaptations available." : `${remaining} / ${limit}`}
            </div>
          </div>
        </div>
        {!unlimited ? <div className="text-xs text-slate-500">{helpText || "Only successful adaptations use a credit."}</div> : null}
      </div>
    </div>
  );
}
