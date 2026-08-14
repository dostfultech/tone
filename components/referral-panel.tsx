"use client";

import { useState } from "react";
import { BadgeCheck, Check, Copy, Share2, Users } from "lucide-react";

export function ReferralPanel({
  link,
  code,
  referredCount,
  subscribedCount
}: {
  link: string;
  code: string;
  referredCount: number;
  subscribedCount: number;
}) {
  const [copied, setCopied] = useState(false);

  async function copy() {
    try {
      await navigator.clipboard.writeText(link);
      setCopied(true);
      setTimeout(() => setCopied(false), 1800);
    } catch {
      /* clipboard blocked — user can select manually */
    }
  }

  async function share() {
    const nav = navigator as Navigator & { share?: (data: ShareData) => Promise<void> };
    if (typeof nav.share === "function") {
      try {
        await nav.share({ title: "Tonefex", text: "Dial in any song's tone on your own gear:", url: link });
        return;
      } catch {
        /* user cancelled — fall through to copy */
      }
    }
    copy();
  }

  return (
    <div className="px-4 pb-16 pt-24 sm:px-6 lg:px-8">
      <div className="mx-auto max-w-2xl">
        <div className="text-center">
          <h1 className="text-3xl font-bold sm:text-4xl">Invite guitarists, earn rewards</h1>
          <p className="mx-auto mt-3 max-w-md text-slate-600">
            Share your link. When players you invite join Tonefex, we&apos;ll credit you. Post it in your videos, bio, or
            group chats.
          </p>
        </div>

        <div className="compact-card mt-8 p-5 sm:p-7">
          <div className="text-xs font-bold uppercase tracking-[0.14em] text-slate-500">Your invite link</div>
          <div className="mt-3 flex flex-col gap-2 sm:flex-row">
            <input
              readOnly
              value={link}
              onFocus={(event) => event.currentTarget.select()}
              className="field h-12 flex-1 font-medium"
            />
            <button type="button" onClick={copy} className="button-primary min-h-12 justify-center px-6">
              {copied ? <Check className="h-4 w-4" /> : <Copy className="h-4 w-4" />}
              {copied ? "Copied" : "Copy"}
            </button>
          </div>
          <button type="button" onClick={share} className="button-secondary mt-3 min-h-12 w-full justify-center">
            <Share2 className="h-4 w-4" />
            Share
          </button>
          <p className="mt-3 text-center text-xs text-slate-500">
            Your code: <span className="font-bold tracking-wider text-ink">{code}</span>
          </p>
        </div>

        <div className="mt-6 grid grid-cols-2 gap-4">
          <div className="compact-card p-5 text-center">
            <Users className="mx-auto h-6 w-6 text-ocean" />
            <div className="mt-2 text-4xl font-bold text-ink">{referredCount}</div>
            <div className="mt-1 text-sm font-semibold text-slate-500">Signed up</div>
          </div>
          <div className="compact-card p-5 text-center">
            <BadgeCheck className="mx-auto h-6 w-6 text-emerald-600" />
            <div className="mt-2 text-4xl font-bold text-ink">{subscribedCount}</div>
            <div className="mt-1 text-sm font-semibold text-slate-500">Subscribed</div>
          </div>
        </div>

        <p className="mt-6 text-center text-xs text-slate-400">
          Rewards are handled personally for now — reach out and we&apos;ll sort you out for the players you bring in.
        </p>
      </div>
    </div>
  );
}
