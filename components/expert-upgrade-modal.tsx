"use client";

import Link from "next/link";
import { Lock, Sparkles, X } from "lucide-react";

export function ExpertUpgradeModal({
  open,
  onClose,
  redirect = "/app",
  title = "You've used your 3 free adaptations.",
  body = "Upgrade to keep adapting every song to your rig."
}: {
  open: boolean;
  onClose: () => void;
  redirect?: string;
  title?: string;
  body?: string;
}) {
  if (!open) {
    return null;
  }

  return (
    <div className="fixed inset-0 z-[90] grid place-items-center bg-ink/45 p-4">
      <div className="theme-panel w-full max-w-md overflow-hidden">
        <div className="flex items-center justify-between border-b border-white/80 px-6 py-5">
          <div className="flex items-center gap-3">
            <div className="grid h-11 w-11 place-items-center rounded-md bg-ink text-moss">
              <Lock className="h-5 w-5" />
            </div>
            <div>
              <h2 className="text-xl font-bold">{title}</h2>
              <p className="text-sm text-slate-500">{body}</p>
            </div>
          </div>
          <button type="button" className="button-quiet px-2" onClick={onClose} aria-label="Close upgrade modal">
            <X className="h-5 w-5" />
          </button>
        </div>
        <div className="grid gap-4 px-6 py-6">
          {[
            "Unlimited Tone Adaptations",
            "Unlimited Future Songs",
            "Unlimited Gear Adaptation"
          ].map((item) => (
            <div key={item} className="flex items-center gap-3 rounded-lg border border-white/80 bg-white/70 px-4 py-3 text-sm font-semibold text-ink">
              <Sparkles className="h-4 w-4 text-ocean" />
              {item}
            </div>
          ))}
          <Link
            href={`/plans?required=subscription&redirect=${encodeURIComponent(redirect)}&source=free-adaptation-limit`}
            className="button-primary mt-2 min-h-12 justify-center"
          >
            Upgrade to Expert
          </Link>
        </div>
      </div>
    </div>
  );
}
