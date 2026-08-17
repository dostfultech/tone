"use client";

import { useState } from "react";
import { BadgeCheck, Check, Copy, Share2, Users } from "lucide-react";

type Conversion = { plan: string; interval: string; amount: number; commission: number };

const money = (value: number) => `$${value.toFixed(2)}`;

export function ReferralPanel({
  link,
  code,
  referredCount,
  subscribedCount,
  totalEarned,
  conversions
}: {
  link: string;
  code: string;
  referredCount: number;
  subscribedCount: number;
  totalEarned: number;
  conversions: Conversion[];
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
        /* cancelled — fall through to copy */
      }
    }
    copy();
  }

  return (
    <div className="px-4 pb-16 pt-24 sm:px-6 lg:px-8">
      <div className="mx-auto max-w-2xl">
        <div className="text-center">
          <h1 className="text-3xl font-bold sm:text-4xl">Invite guitarists, earn 20%</h1>
          <p className="mx-auto mt-3 max-w-md text-slate-600">
            Share your link. You earn <span className="font-bold text-ink">20% of every plan</span> someone buys through
            it. Post it in your videos, bio, or group chats.
          </p>
        </div>

        {/* Earnings hero */}
        <div className="mt-8 rounded-2xl border border-emerald-200 bg-gradient-to-br from-emerald-50 to-white p-6 text-center shadow-sm sm:p-8">
          <div className="text-xs font-bold uppercase tracking-[0.16em] text-emerald-700">You&apos;ve earned</div>
          <div className="mt-2 text-5xl font-bold text-emerald-600 sm:text-6xl">{money(totalEarned)}</div>
          <div className="mt-2 text-sm font-semibold text-slate-500">
            from {subscribedCount} paid subscriber{subscribedCount === 1 ? "" : "s"}
          </div>
        </div>

        {/* Invite link */}
        <div className="compact-card mt-6 p-5 sm:p-7">
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

        {/* Stats */}
        <div className="mt-6 grid grid-cols-2 gap-4">
          <div className="compact-card p-5 text-center">
            <Users className="mx-auto h-6 w-6 text-ocean" />
            <div className="mt-2 text-4xl font-bold text-ink">{referredCount}</div>
            <div className="mt-1 text-sm font-semibold text-slate-500">Signed up</div>
          </div>
          <div className="compact-card p-5 text-center">
            <BadgeCheck className="mx-auto h-6 w-6 text-emerald-600" />
            <div className="mt-2 text-4xl font-bold text-ink">{subscribedCount}</div>
            <div className="mt-1 text-sm font-semibold text-slate-500">Subscribed (paid)</div>
          </div>
        </div>

        {/* Conversions breakdown (anonymized) */}
        {conversions.length > 0 ? (
          <div className="compact-card mt-6 overflow-hidden">
            <div className="border-b border-slate-100 px-5 py-4 text-xs font-bold uppercase tracking-[0.14em] text-slate-500">
              Your earnings
            </div>
            <ul className="divide-y divide-slate-100">
              {conversions.map((conversion, index) => (
                <li key={index} className="flex items-center justify-between gap-3 px-5 py-4">
                  <div className="min-w-0">
                    <div className="font-bold text-ink">{conversion.plan} plan</div>
                    <div className="text-sm text-slate-500">
                      {money(conversion.amount)}/{conversion.interval === "annual" ? "yr" : "mo"} · someone subscribed
                    </div>
                  </div>
                  <div className="shrink-0 text-right">
                    <div className="font-bold text-emerald-600">+{money(conversion.commission)}</div>
                    <div className="text-xs text-slate-400">your 20%</div>
                  </div>
                </li>
              ))}
            </ul>
          </div>
        ) : (
          <p className="mt-6 text-center text-sm text-slate-400">
            No paid subscribers yet — share your link and your earnings will show up here.
          </p>
        )}

        <p className="mt-6 text-center text-xs text-slate-400">
          Payouts are handled personally for now — reach out and we&apos;ll settle up for the players you bring in.
        </p>
      </div>
    </div>
  );
}
