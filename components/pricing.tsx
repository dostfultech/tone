"use client";

import { useEffect, useMemo, useState } from "react";
import { Check, Crown, Loader2 } from "lucide-react";
import { plans } from "@/lib/mock-data";
import {
  formatSubscriptionDate,
  formatSubscriptionStatus,
  loadClientSubscriptionSnapshot,
  type ClientSubscriptionSnapshot
} from "@/lib/subscription-client";
import { createSupabaseBrowserClient } from "@/lib/supabase/browser";

type Billing = "monthly" | "annual";

export function Pricing() {
  const [billing, setBilling] = useState<Billing>("annual");
  const [loadingPlan, setLoadingPlan] = useState<string | null>(null);
  const [message, setMessage] = useState("");
  const [snapshot, setSnapshot] = useState<ClientSubscriptionSnapshot | null>(null);

  useEffect(() => {
    const stored = localStorage.getItem("plans_default_variant") as Billing | null;
    if (stored === "monthly" || stored === "annual") {
      setBilling(stored);
      return;
    }

    const variant = Math.random() > 0.5 ? "annual" : "monthly";
    localStorage.setItem("plans_default_variant", variant);
    setBilling(variant);
    fetch("/api/ab-variant/view", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ page: "plans", variant })
    }).catch(() => undefined);
  }, []);

  useEffect(() => {
    const supabase = createSupabaseBrowserClient();
    if (!supabase) {
      return;
    }
    const client = supabase;

    async function refreshSnapshot() {
      setSnapshot(await loadClientSubscriptionSnapshot(client));
    }

    void refreshSnapshot();

    const {
      data: { subscription }
    } = client.auth.onAuthStateChange(() => {
      refreshSnapshot().catch(() => undefined);
    });

    return () => subscription.unsubscribe();
  }, []);

  const computedPlans = useMemo(
    () =>
      plans.map((plan) => ({
        ...plan,
        displayPrice: billing === "annual" ? plan.annual / 12 : plan.monthly,
        subline: billing === "annual" ? `$${plan.annual.toFixed(2)}/year` : "billed monthly",
        savings: billing === "annual" ? Math.round((1 - plan.annual / (plan.monthly * 12)) * 100) : 0
      })),
    [billing]
  );

  const activePlan = snapshot?.planId ? computedPlans.find((plan) => plan.id === snapshot.planId) || null : null;
  const availablePlans = snapshot?.planId === "expert"
    ? []
    : snapshot?.planId === "beginner"
      ? computedPlans.filter((plan) => plan.id === "expert")
      : computedPlans;

  async function startCheckout(planId: string) {
    setLoadingPlan(planId);
    setMessage("");
    try {
      const response = await fetch("/api/dodo/checkout", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ planId, billing })
      });
      const data = await response.json();
      if (!response.ok) {
        setMessage(data.error || "Checkout could not be started.");
        return;
      }
      if (data.checkoutUrl) {
        window.location.href = data.checkoutUrl;
        return;
      }
      setMessage("Checkout session created, but no redirect URL was returned.");
    } catch {
      setMessage("Checkout could not be started in this environment.");
    } finally {
      setLoadingPlan(null);
    }
  }

  return (
    <section className="px-4 pb-14 pt-24 sm:px-6 lg:px-8">
      <div className="mx-auto max-w-3xl text-center">
        <div className="inline-flex rounded-lg border border-white/80 bg-white/80 px-5 py-3 text-sm font-bold uppercase tracking-[0.08em] text-slate-700 shadow-sm">
          Cancel anytime
        </div>
        <h1 className="mt-7 text-4xl font-bold tracking-normal sm:text-5xl">Unlock Your <span className="lime-highlight">Perfect Tone</span></h1>
        <p className="mt-4 text-lg leading-8 text-neutral-600">
          Get exact amp settings from favorite songs, adapted to your gear.
        </p>
        <div className="mt-7 inline-flex rounded-lg border border-neutral-200 bg-white p-1 shadow-sm">
          {(["monthly", "annual"] as Billing[]).map((option) => (
            <button
              key={option}
              className={`rounded-md px-4 py-2 text-sm font-semibold transition ${billing === option ? "bg-ink text-white" : "text-neutral-700 hover:bg-neutral-100"}`}
              onClick={() => setBilling(option)}
            >
              {option === "monthly" ? "Monthly" : "Annual"}
              {option === "annual" ? <span className="ml-2 rounded-md bg-moss px-2 py-0.5 text-xs text-ink">Best deal</span> : null}
            </button>
          ))}
        </div>
      </div>

      {snapshot?.hasAccess && activePlan ? (
        <div className="mx-auto mt-10 max-w-5xl rounded-2xl border border-neutral-200 bg-white p-6 shadow-soft">
          <div className="flex flex-col gap-6 lg:flex-row lg:items-start lg:justify-between">
            <div>
              <div className="text-sm font-semibold uppercase tracking-[0.16em] text-slate-500">Current Plan</div>
              <h2 className="mt-2 text-3xl font-semibold">{snapshot.planName || activePlan.name}</h2>
              <p className="mt-2 text-sm text-neutral-600">
                Status: {formatSubscriptionStatus(snapshot.status)} - Renews {formatSubscriptionDate(snapshot.renewalDate)}
              </p>
              <div className="mt-4 grid gap-2 text-sm text-neutral-700">
                {snapshot.features.map((perk) => (
                  <div key={perk} className="flex items-center gap-2">
                    <Check className="h-4 w-4 text-moss" />
                    <span>{perk}</span>
                  </div>
                ))}
              </div>
            </div>

            <div className="grid min-w-[300px] gap-3 rounded-xl border border-neutral-200 bg-neutral-50 p-4 text-sm text-neutral-700">
              <UsageRow label="Current plan" value={snapshot.planName || activePlan.name} />
              <UsageRow label="Adaptations" value={formatUsage(snapshot.usage.adaptationsUsed, snapshot.usage.adaptationsRemaining)} />
              <UsageRow label="Saved tones" value={formatUsage(snapshot.usage.savedTonesUsed, snapshot.usage.savedTonesRemaining)} />
              <UsageRow label="Saved tones in library" value={String(snapshot.totals.savedTones)} />
              <UsageRow label="Gear presets" value={formatUsage(snapshot.usage.gearPresetsUsed, snapshot.usage.gearPresetsRemaining)} />
              <UsageRow
                label="Starter adaptations remaining"
                value={snapshot.usage.starterAdaptationsRemaining === null ? "Unlimited" : String(snapshot.usage.starterAdaptationsRemaining)}
              />
              <UsageRow label="Billing" value={snapshot.billingInterval === "annual" ? "Annual" : "Monthly"} />
              <UsageRow label="Plan status" value={formatSubscriptionStatus(snapshot.status)} />
            </div>
          </div>

          {snapshot.planId === "beginner" ? (
            <div className="mt-6 flex justify-end">
              <button className="button-primary" onClick={() => startCheckout("expert")} disabled={loadingPlan !== null}>
                {loadingPlan === "expert" ? <Loader2 className="h-4 w-4 animate-spin" /> : null}
                Upgrade to Expert
              </button>
            </div>
          ) : null}
        </div>
      ) : null}

      {availablePlans.length ? (
        <div className="mx-auto mt-10 grid max-w-5xl gap-6 lg:grid-cols-2">
          {availablePlans.map((plan) => (
            <article key={plan.id} className={`compact-card relative p-6 ${plan.id === "expert" ? "border-ink shadow-soft" : ""}`}>
              {plan.id === "expert" ? (
                <div className="absolute right-4 top-4 inline-flex items-center gap-2 rounded-md bg-ink px-3 py-1 text-xs font-semibold text-white">
                  <Crown className="h-3.5 w-3.5" />
                  Most popular
                </div>
              ) : null}
              <div className="text-sm font-semibold uppercase tracking-[0.18em] text-slate-500">Flexible subscription</div>
              <h2 className="mt-3 text-2xl font-semibold">{plan.name}</h2>
              <div className="mt-5 flex items-end gap-2">
                <span className="text-5xl font-semibold">${plan.displayPrice.toFixed(2)}</span>
                <span className="pb-2 text-neutral-500">/mo</span>
              </div>
              <p className="mt-2 text-sm text-neutral-600">{plan.subline}</p>
              {plan.savings ? <p className="mt-2 text-sm font-semibold text-ink"><span className="lime-highlight">Save {plan.savings}%</span> per year</p> : null}
              <div className="mt-6 grid gap-3 text-sm">
                <Feature>{plan.trialAdaptations} starter adaptations included</Feature>
                <Feature>{plan.adaptations}</Feature>
                <Feature>{plan.saved}</Feature>
                {plan.perks.map((perk) => (
                  <Feature key={perk}>{perk}</Feature>
                ))}
              </div>
              <button className="button-primary mt-7 w-full" onClick={() => startCheckout(plan.id)} disabled={loadingPlan !== null}>
                {loadingPlan === plan.id ? <Loader2 className="h-4 w-4 animate-spin" /> : null}
                {snapshot?.planId === "beginner" && plan.id === "expert" ? "Upgrade to Expert" : "Choose Plan"}
              </button>
              <p className="mt-3 text-center text-xs text-neutral-500">Cancel anytime from the customer portal.</p>
            </article>
          ))}
        </div>
      ) : null}

      {message ? <div className="mx-auto mt-6 max-w-2xl rounded-md bg-ink px-4 py-3 text-center text-sm font-semibold text-white">{message}</div> : null}

      <div className="mx-auto mt-14 max-w-3xl">
        <h2 className="text-2xl font-semibold">Frequently Asked Questions</h2>
        <div className="mt-5 divide-y divide-neutral-200 rounded-lg border border-neutral-200 bg-white">
          {[
            ["How does access work?", "A successful subscription unlocks the tone features included in your selected plan."],
            ["Can I cancel anytime?", "Dodo Payments handles subscription management through the customer portal."],
            ["How accurate are recommendations?", "Recommendations combine structured AI output with your selected guitar, amp, pickups, and effects."]
          ].map(([question, answer]) => (
            <div key={question} className="p-5">
              <h3 className="font-semibold">{question}</h3>
              <p className="mt-2 text-sm leading-6 text-neutral-600">{answer}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

function UsageRow({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex items-center justify-between gap-3">
      <span className="text-neutral-500">{label}</span>
      <span className="text-right font-semibold text-ink">{value}</span>
    </div>
  );
}

function formatUsage(used: number, remaining: number | null) {
  if (remaining === null) {
    return `${used} used - Unlimited remaining`;
  }

  return `${used} used - ${remaining} remaining`;
}

function Feature({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex items-start gap-3">
      <Check className="mt-0.5 h-4 w-4 shrink-0 text-moss" />
      <span className="text-neutral-700">{children}</span>
    </div>
  );
}
