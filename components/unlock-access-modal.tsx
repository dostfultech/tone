"use client";

import { useState } from "react";
import { Loader2, Sparkles, X } from "lucide-react";
import { plans } from "@/lib/mock-data";
import { trackCheckoutStarted, trackEvent } from "@/lib/analytics";

type PlanId = "beginner" | "expert";
type BillingInterval = "monthly" | "annual";

function normalizePlanId(value: string | null | undefined): PlanId {
  return value === "beginner" ? "beginner" : "expert";
}

function normalizeBilling(value: string | null | undefined): BillingInterval {
  return value === "annual" ? "annual" : "monthly";
}

async function convertTrialNow(): Promise<{ ok: boolean; error?: string }> {
  try {
    const response = await fetch("/api/dodo/convert-trial", { method: "POST" });
    const data = await response.json().catch(() => ({}));
    if (!response.ok) {
      trackEvent("trial_convert_failed", { reason: data.error || "request_failed" });
      return { ok: false, error: data.error || "Could not unlock full access." };
    }
    return { ok: true };
  } catch {
    trackEvent("trial_convert_failed", { reason: "network_or_runtime" });
    return { ok: false, error: "Could not unlock full access in this environment." };
  }
}

async function startCheckout(planId: PlanId, billing: BillingInterval): Promise<{ ok: boolean; error?: string }> {
  const plan = plans.find((item) => item.id === planId);
  const amount = plan ? (billing === "annual" ? plan.annual : plan.monthly) : undefined;
  try {
    const response = await fetch("/api/dodo/checkout", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ planId, billing })
    });
    const data = await response.json();
    if (!response.ok) {
      trackEvent("checkout_start_failed", { plan_id: planId, billing_interval: billing, reason: data.error || "request_failed" });
      return { ok: false, error: data.error || "Checkout could not be started." };
    }
    if (data.checkoutUrl) {
      trackCheckoutStarted(planId, billing, amount);
      window.location.href = data.checkoutUrl;
      return { ok: true };
    }
    return { ok: false, error: "Checkout session created, but no redirect URL was returned." };
  } catch {
    trackEvent("checkout_start_failed", { plan_id: planId, billing_interval: billing, reason: "network_or_runtime" });
    return { ok: false, error: "Checkout could not be started in this environment." };
  }
}

export function UnlockAccessModal({
  open,
  onClose,
  planId,
  billingInterval,
  convert = false
}: {
  open: boolean;
  onClose: () => void;
  planId?: string | null;
  billingInterval?: string | null;
  convert?: boolean;
}) {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const resolvedPlanId = normalizePlanId(planId);
  const resolvedBilling = normalizeBilling(billingInterval);
  const plan = plans.find((item) => item.id === resolvedPlanId) || plans.find((item) => item.id === "expert");
  const isAnnual = resolvedBilling === "annual";
  const price = (plan ? (isAnnual ? plan.annual : plan.monthly) : isAnnual ? 49.99 : 10.99).toFixed(2);
  const intervalLabel = isAnnual ? "year" : "month";
  const billingLabel = isAnnual ? "Annual billing" : "Monthly billing";
  const planName = plan?.name || "Expert";

  if (!open) {
    return null;
  }

  async function confirm() {
    setLoading(true);
    setError("");
    const outcome = convert ? await convertTrialNow() : await startCheckout(resolvedPlanId, resolvedBilling);
    if (!outcome.ok) {
      setError(outcome.error || (convert ? "Could not unlock full access." : "Checkout could not be started."));
      setLoading(false);
      return;
    }
    // Convert updates the existing subscription server-side (no redirect) — reload
    // so the account reflects the now-active plan and full quota. Checkout mode
    // redirects the browser to the payment URL instead.
    if (convert) {
      window.location.reload();
    }
  }

  return (
    <div className="fixed inset-0 z-[95] grid place-items-center bg-ink/45 p-4" role="dialog" aria-modal="true">
      <div className="theme-panel w-full max-w-md overflow-hidden">
        <div className="flex items-center justify-between border-b border-white/80 px-6 py-5">
          <div className="flex items-center gap-3">
            <div className="grid h-11 w-11 place-items-center rounded-md bg-ocean/10 text-ocean">
              <Sparkles className="h-5 w-5" />
            </div>
            <h2 className="text-xl font-bold">Start Your Subscription</h2>
          </div>
          <button type="button" className="button-quiet px-2" onClick={onClose} aria-label="Close subscription modal">
            <X className="h-5 w-5" />
          </button>
        </div>
        <div className="grid gap-4 px-6 py-6">
          <p className="text-sm text-slate-600">
            {convert
              ? "End your free trial now and start your subscription immediately. You'll be charged today and get your full plan quota right away."
              : "Start your subscription to unlock the full plan and keep matching tones to your gear."}
          </p>
          <div className="rounded-lg border border-white/80 bg-white/70 px-4 py-4">
            <div className="flex items-center justify-between">
              <span className="text-sm font-semibold text-slate-500">Plan</span>
              <span className="text-sm font-bold text-ocean">{planName}</span>
            </div>
            <div className="mt-1 flex items-center justify-between">
              <span className="text-sm text-slate-600">{billingLabel}</span>
              <span className="text-lg font-bold text-ink">
                ${price}/{intervalLabel}
              </span>
            </div>
          </div>
          {convert ? (
            <div className="rounded-lg border border-amber-200 bg-amber-50 px-4 py-3 text-sm text-amber-900">
              <strong className="font-bold">Note:</strong> Your trial will end immediately and you&apos;ll be charged the
              full subscription amount.
            </div>
          ) : null}
          {error ? <p className="text-sm font-semibold text-red-600">{error}</p> : null}
          <div className="mt-1 flex gap-3">
            <button type="button" className="button-secondary flex-1 justify-center" onClick={onClose} disabled={loading}>
              Cancel
            </button>
            <button type="button" className="button-primary min-h-12 flex-1 justify-center" onClick={confirm} disabled={loading}>
              {loading ? (
                <>
                  <Loader2 className="h-4 w-4 animate-spin" /> Starting…
                </>
              ) : (
                "Unlock Full Access Now"
              )}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

export function UnlockAccessButton({
  className,
  label = "Unlock Full Access",
  planId,
  billingInterval,
  convert = false
}: {
  className?: string;
  label?: string;
  planId?: string | null;
  billingInterval?: string | null;
  convert?: boolean;
}) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" className={className || "button-primary w-full justify-center"} onClick={() => setOpen(true)}>
        {label}
      </button>
      <UnlockAccessModal open={open} onClose={() => setOpen(false)} planId={planId} billingInterval={billingInterval} convert={convert} />
    </>
  );
}
