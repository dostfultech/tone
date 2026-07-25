"use client";

import { useState } from "react";
import { Loader2, Sparkles, X } from "lucide-react";
import { plans } from "@/lib/mock-data";
import { trackCheckoutStarted, trackEvent } from "@/lib/analytics";

async function startExpertCheckout(): Promise<{ ok: boolean; error?: string }> {
  const expert = plans.find((plan) => plan.id === "expert");
  try {
    const response = await fetch("/api/dodo/checkout", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ planId: "expert", billing: "monthly" })
    });
    const data = await response.json();
    if (!response.ok) {
      trackEvent("checkout_start_failed", {
        plan_id: "expert",
        billing_interval: "monthly",
        reason: data.error || "request_failed"
      });
      return { ok: false, error: data.error || "Checkout could not be started." };
    }
    if (data.checkoutUrl) {
      trackCheckoutStarted("expert", "monthly", expert?.monthly);
      window.location.href = data.checkoutUrl;
      return { ok: true };
    }
    return { ok: false, error: "Checkout session created, but no redirect URL was returned." };
  } catch {
    trackEvent("checkout_start_failed", {
      plan_id: "expert",
      billing_interval: "monthly",
      reason: "network_or_runtime"
    });
    return { ok: false, error: "Checkout could not be started in this environment." };
  }
}

export function UnlockAccessModal({ open, onClose }: { open: boolean; onClose: () => void }) {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const expert = plans.find((plan) => plan.id === "expert");
  const price = expert ? expert.monthly.toFixed(2) : "10.99";

  if (!open) {
    return null;
  }

  async function confirm() {
    setLoading(true);
    setError("");
    const outcome = await startExpertCheckout();
    if (!outcome.ok) {
      setError(outcome.error || "Checkout could not be started.");
      setLoading(false);
    }
    // On success the browser redirects to the checkout URL.
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
            End your free trial now and start your subscription immediately. You&apos;ll be charged today and gain full
            access to your plan&apos;s features.
          </p>
          <div className="rounded-lg border border-white/80 bg-white/70 px-4 py-4">
            <div className="flex items-center justify-between">
              <span className="text-sm font-semibold text-slate-500">Plan</span>
              <span className="text-sm font-bold text-ocean">Expert</span>
            </div>
            <div className="mt-1 flex items-center justify-between">
              <span className="text-sm text-slate-600">Monthly billing</span>
              <span className="text-lg font-bold text-ink">${price}/month</span>
            </div>
          </div>
          <div className="rounded-lg border border-amber-200 bg-amber-50 px-4 py-3 text-sm text-amber-900">
            <strong className="font-bold">Note:</strong> Your trial will end immediately and you&apos;ll be charged the
            full subscription amount.
          </div>
          {error ? <p className="text-sm font-semibold text-red-600">{error}</p> : null}
          <div className="mt-1 flex gap-3">
            <button
              type="button"
              className="button-secondary flex-1 justify-center"
              onClick={onClose}
              disabled={loading}
            >
              Cancel
            </button>
            <button
              type="button"
              className="button-primary min-h-12 flex-1 justify-center"
              onClick={confirm}
              disabled={loading}
            >
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

export function UnlockAccessButton({ className, label = "Unlock Full Access" }: { className?: string; label?: string }) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" className={className || "button-primary w-full justify-center"} onClick={() => setOpen(true)}>
        {label}
      </button>
      <UnlockAccessModal open={open} onClose={() => setOpen(false)} />
    </>
  );
}
