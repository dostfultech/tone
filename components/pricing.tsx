"use client";

import { useEffect, useMemo, useState } from "react";
import { Check, Crown, Loader2 } from "lucide-react";
import { plans } from "@/lib/mock-data";
import { createSupabaseBrowserClient } from "@/lib/supabase/browser";

type Billing = "monthly" | "annual";

type ActiveSubscription = {
  planId: "beginner" | "expert";
  status: string;
  billingInterval: Billing;
  currentPeriodEnd: string | null;
};

type UsageSnapshot = {
  adaptationsUsed: number;
  savedTonesUsed: number;
  starterAdaptationsRemaining: number | null;
};

const planUsageLimits = {
  beginner: {
    monthlyAdaptations: 20,
    savedTones: 15,
    starterAdaptations: 5
  },
  expert: {
    monthlyAdaptations: null,
    savedTones: null,
    starterAdaptations: null
  }
} as const;

export function Pricing() {
  const [billing, setBilling] = useState<Billing>("annual");
  const [loadingPlan, setLoadingPlan] = useState<string | null>(null);
  const [message, setMessage] = useState("");
  const [activeSubscription, setActiveSubscription] = useState<ActiveSubscription | null>(null);
  const [usage, setUsage] = useState<UsageSnapshot | null>(null);

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

    async function loadSubscriptionState() {
      const { data: authData } = await supabase.auth.getUser();
      const user = authData.user;
      if (!user) {
        setActiveSubscription(null);
        setUsage(null);
        return;
      }

      const { data: subscription } = await supabase
        .from("subscriptions")
        .select("plan_id, status, billing_interval, current_period_end")
        .eq("user_id", user.id)
        .in("status", ["active", "trialing"])
        .in("plan_id", ["beginner", "expert"])
        .order("updated_at", { ascending: false })
        .limit(1)
        .maybeSingle();

      if (!subscription?.plan_id) {
        setActiveSubscription(null);
        setUsage(null);
        return;
      }

      const nextSubscription: ActiveSubscription = {
        planId: subscription.plan_id,
        status: subscription.status,
        billingInterval: subscription.billing_interval === "monthly" ? "monthly" : "annual",
        currentPeriodEnd: subscription.current_period_end || null
      };
      setActiveSubscription(nextSubscription);

      const monthStart = new Date();
      monthStart.setDate(1);
      monthStart.setHours(0, 0, 0, 0);

      const { data: monthlyUsage } = await supabase
        .from("monthly_usage")
        .select("adaptations_used, saved_tones_created")
        .eq("user_id", user.id)
        .eq("usage_month", monthStart.toISOString().slice(0, 10))
        .maybeSingle();

      const limits = planUsageLimits[nextSubscription.planId];
      const starterLimit = limits.starterAdaptations;
      const usedAdaptations = monthlyUsage?.adaptations_used || 0;
      setUsage({
        adaptationsUsed: usedAdaptations,
        savedTonesUsed: monthlyUsage?.saved_tones_created || 0,
        starterAdaptationsRemaining: starterLimit === null ? null : Math.max(starterLimit - usedAdaptations, 0)
      });
    }

    loadSubscriptionState();

    const {
      data: { subscription }
    } = supabase.auth.onAuthStateChange(() => {
      loadSubscriptionState().catch(() => undefined);
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

  const activePlan = activeSubscription ? computedPlans.find((plan) => plan.id === activeSubscription.planId) || null : null;
  const availablePlans = activeSubscription?.planId === "expert"
    ? []
    : activeSubscription?.planId === "beginner"
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
    <section className="px-4 pb-16 pt-28 sm:px-6 lg:px-8">
      <div className="mx-auto max-w-3xl text-center">
        <div className="inline-flex rounded-lg border border-white/80 bg-white/80 px-5 py-3 text-sm font-bold uppercase tracking-[0.08em] text-slate-700 shadow-sm">
          Cancel anytime
        </div>
        <h1 className="mt-7 text-5xl font-bold tracking-normal">Unlock Your <span className="lime-highlight">Perfect Tone</span></h1>
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

      {activeSubscription && activePlan ? (
        <div className="mx-auto mt-10 max-w-5xl rounded-2xl border border-neutral-200 bg-white p-6 shadow-soft">
          <div className="flex flex-col gap-6 lg:flex-row lg:items-start lg:justify-between">
            <div>
              <div className="text-sm font-semibold uppercase tracking-[0.16em] text-slate-500">Current Plan</div>
              <h2 className="mt-2 text-3xl font-semibold">{activePlan.name}</h2>
              <p className="mt-2 text-sm text-neutral-600">
                Status: {activeSubscription.status} · Renews {formatDate(activeSubscription.currentPeriodEnd)}
              </p>
              <div className="mt-4 grid gap-2 text-sm text-neutral-700">
                {activePlan.perks.map((perk) => (
                  <div key={perk} className="flex items-center gap-2">
                    <Check className="h-4 w-4 text-moss" />
                    <span>{perk}</span>
                  </div>
                ))}
              </div>
            </div>
            <div className="grid min-w-[280px] gap-3 rounded-xl border border-neutral-200 bg-neutral-50 p-4 text-sm text-neutral-700">
              <UsageRow
                label="Adaptations"
                value={formatUsage(usage?.adaptationsUsed ?? 0, planUsageLimits[activeSubscription.planId].monthlyAdaptations)}
              />
              <UsageRow
                label="Saved tones"
                value={formatUsage(usage?.savedTonesUsed ?? 0, planUsageLimits[activeSubscription.planId].savedTones)}
              />
              <UsageRow
                label="Starter adaptations remaining"
                value={usage?.starterAdaptationsRemaining === null ? "Unlimited" : String(usage?.starterAdaptationsRemaining ?? 0)}
              />
              <UsageRow label="Billing" value={activeSubscription.billingInterval === "monthly" ? "Monthly" : "Annual"} />
            </div>
          </div>
          {activeSubscription.planId === "beginner" ? (
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
              {activeSubscription?.planId === "beginner" && plan.id === "expert" ? "Upgrade to Expert" : "Choose Plan"}
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
      <span className="font-semibold text-ink">{value}</span>
    </div>
  );
}

function formatUsage(used: number, limit: number | null) {
  if (limit === null) {
    return `${used} used · Unlimited remaining`;
  }

  return `${used} used · ${Math.max(limit - used, 0)} remaining`;
}

function formatDate(value: string | null) {
  if (!value) {
    return "soon";
  }

  const date = new Date(value);
  if (Number.isNaN(date.getTime())) {
    return "soon";
  }

  return date.toLocaleDateString(undefined, {
    year: "numeric",
    month: "short",
    day: "numeric"
  });
}

function Feature({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex items-start gap-3">
      <Check className="mt-0.5 h-4 w-4 shrink-0 text-moss" />
      <span className="text-neutral-700">{children}</span>
    </div>
  );
}
