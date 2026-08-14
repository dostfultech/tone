"use client";

import { useEffect } from "react";
import { useSearchParams } from "next/navigation";

// Captures ?ref=CODE into a 30-day cookie so we can attribute the referrer after the visitor
// signs up (the auth callback reads this cookie). Renders nothing.
export function ReferralCapture() {
  const params = useSearchParams();

  useEffect(() => {
    const raw = params.get("ref");
    if (!raw) {
      return;
    }
    const code = raw.trim().toUpperCase().replace(/[^A-Z0-9]/g, "").slice(0, 12);
    if (code.length >= 6) {
      document.cookie = `tf_ref=${code}; path=/; max-age=${60 * 60 * 24 * 30}; samesite=lax`;
    }
  }, [params]);

  return null;
}
