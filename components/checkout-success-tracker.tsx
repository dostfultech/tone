"use client";

import { useEffect, useRef } from "react";
import { useSearchParams } from "next/navigation";
import { trackCheckoutCompleted, trackEvent } from "@/lib/analytics";

export function CheckoutSuccessTracker() {
  const searchParams = useSearchParams();
  const trackedRef = useRef(false);

  useEffect(() => {
    if (trackedRef.current) {
      return;
    }

    const status = searchParams.get("checkout");
    if (status !== "success") {
      return;
    }

    trackedRef.current = true;
    const planId = searchParams.get("planId") || searchParams.get("plan_id") || undefined;
    const billingInterval = searchParams.get("billingInterval") || searchParams.get("billing_interval") || undefined;

    trackCheckoutCompleted({ planId, billingInterval });
    trackEvent("conversion", {
      conversion_type: "paid_subscription",
      plan_id: planId || "unknown"
    });
  }, [searchParams]);

  return null;
}
