"use client";

import { brand } from "@/lib/brand";

type AnalyticsValue = string | number | boolean | null | undefined;
type AnalyticsParams = Record<string, AnalyticsValue>;

declare global {
  interface Window {
    gtag?: (...args: unknown[]) => void;
  }
}

const consentCookieName = `${brand.storagePrefix}_cookie_consent`;

export function trackEvent(eventName: string, params: AnalyticsParams = {}) {
  if (!isAnalyticsAllowed() || typeof window.gtag !== "function") {
    return;
  }

  window.gtag("event", eventName, sanitizeParams(params));
}

export function trackCheckoutStarted(planId: string, billing: "monthly" | "annual", value?: number) {
  trackEvent("begin_checkout", {
    currency: "USD",
    value,
    plan_id: planId,
    billing_interval: billing,
    source: "pricing_page"
  });
}

export function trackCheckoutCompleted(details: { planId?: string; billingInterval?: string }) {
  trackEvent("purchase", {
    transaction_id: `${Date.now()}`,
    currency: "USD",
    value: details.billingInterval === "annual" ? 49.99 : 10.99,
    plan_id: details.planId || "unknown",
    billing_interval: details.billingInterval || "unknown",
    source: "checkout_return"
  });
}

export function trackToneGenerated(details: { mode: "guitar" | "bass"; source?: string }) {
  trackEvent("tone_generated", {
    mode: details.mode,
    source: details.source || "unknown"
  });
}

export function trackToneSaved(outcome: "synced" | "local") {
  trackEvent("tone_saved", {
    save_outcome: outcome
  });
}

function isAnalyticsAllowed() {
  if (typeof document === "undefined") {
    return false;
  }

  const consentCookie = document.cookie
    .split(";")
    .map((entry) => entry.trim())
    .find((entry) => entry.startsWith(`${consentCookieName}=`));

  if (!consentCookie) {
    return false;
  }

  const [, value] = consentCookie.split("=");
  return value === "accepted";
}

function sanitizeParams(params: AnalyticsParams) {
  return Object.fromEntries(Object.entries(params).filter(([, value]) => value !== undefined));
}
