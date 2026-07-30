"use client";

import { useState } from "react";
import { AlertTriangle } from "lucide-react";

/**
 * Shown across the in-app shell when a subscription is in a failed-payment state
 * (Dodo `on_hold` while retrying, or `failed`). Access is already revoked for these
 * statuses — this turns the silent revoke into a recoverable "update your card"
 * prompt that deep-links to the billing portal.
 */
export function PaymentFailedBanner({ status }: { status: string | null }) {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  if (status !== "on_hold" && status !== "failed") {
    return null;
  }

  async function openPortal() {
    setLoading(true);
    setError("");
    try {
      const response = await fetch("/api/dodo/customer-portal");
      const data = await response.json().catch(() => ({}));
      if (!response.ok || !data.portalUrl) {
        setError(data.error || "The billing portal is unavailable right now.");
        setLoading(false);
        return;
      }
      window.location.href = data.portalUrl;
    } catch {
      setError("Could not open the billing portal in this environment.");
      setLoading(false);
    }
  }

  return (
    <div className="border-b border-amber-300 bg-amber-50 px-4 py-3">
      <div className="mx-auto flex max-w-5xl flex-col items-center gap-3 sm:flex-row sm:justify-between">
        <div className="flex items-center gap-3 text-sm text-amber-900">
          <AlertTriangle className="h-5 w-5 shrink-0" />
          <span>
            <strong className="font-bold">Your payment didn&apos;t go through.</strong> Update your card to restore your
            plan and keep matching tones.
          </span>
        </div>
        <button type="button" className="button-primary shrink-0" onClick={openPortal} disabled={loading}>
          {loading ? "Opening…" : "Update payment method"}
        </button>
      </div>
      {error ? <p className="mx-auto mt-2 max-w-5xl text-center text-xs font-semibold text-red-700 sm:text-left">{error}</p> : null}
    </div>
  );
}
