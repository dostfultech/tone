"use client";

import { brand } from "@/lib/brand";

type AnalyticsValue = string | number | boolean | null | undefined;
type AnalyticsParams = Record<string, AnalyticsValue>;
type EventCategory = "page_view" | "ui_action" | "custom_event";

type AppEventPayload = {
  category: EventCategory;
  name: string;
  path: string | null;
  referrer: string | null;
  element: string | null;
  metadata: Record<string, AnalyticsValue>;
  occurredAt: string;
  sessionId: string;
};

declare global {
  interface Window {
    gtag?: (...args: unknown[]) => void;
  }
}

const consentCookieName = `${brand.storagePrefix}_cookie_consent`;
const sessionStorageKey = `${brand.storagePrefix}_session_id`;
const eventIngestionPath = "/api/v1/events";
const eventQueueMax = 240;
const eventFlushBatchSize = 20;
const eventFlushIntervalMs = 4000;

let eventQueue: AppEventPayload[] = [];
let flushTimer: number | null = null;
let isFlushing = false;
let hasBoundLifecycleHandlers = false;
let cachedSessionId: string | null = null;

export function trackEvent(eventName: string, params: AnalyticsParams = {}) {
  const sanitizedParams = sanitizeParams(params);

  if (isAnalyticsAllowed() && typeof window.gtag === "function") {
    window.gtag("event", eventName, sanitizedParams);
  }

  enqueueAppEvent({
    category: "custom_event",
    name: eventName,
    path: getCurrentPath(),
    referrer: getCurrentReferrer(),
    metadata: sanitizedParams
  });
}

export function trackPageView(path?: string) {
  enqueueAppEvent({
    category: "page_view",
    name: "page_view",
    path: normalizePath(path ?? getCurrentPath()),
    referrer: getCurrentReferrer(),
    metadata: {}
  });
}

export function trackUiAction(actionName: string, details: { element?: string; path?: string; metadata?: AnalyticsParams } = {}) {
  enqueueAppEvent({
    category: "ui_action",
    name: actionName,
    path: normalizePath(details.path ?? getCurrentPath()),
    referrer: getCurrentReferrer(),
    element: details.element,
    metadata: sanitizeParams(details.metadata || {})
  });
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

function enqueueAppEvent(event: {
  category: EventCategory;
  name: string;
  path?: string | null;
  referrer?: string | null;
  element?: string | null;
  metadata?: AnalyticsParams;
}) {
  if (typeof window === "undefined") {
    return;
  }

  const name = event.name.trim();
  if (!name) {
    return;
  }

  bindLifecycleHandlers();

  eventQueue.push({
    category: event.category,
    name: name.slice(0, 120),
    path: normalizePath(event.path ?? null),
    referrer: normalizeText(event.referrer ?? null, 2048),
    element: normalizeText(event.element ?? null, 220),
    metadata: sanitizeParams(event.metadata || {}),
    occurredAt: new Date().toISOString(),
    sessionId: getOrCreateSessionId()
  });

  if (eventQueue.length > eventQueueMax) {
    eventQueue = eventQueue.slice(-eventQueueMax);
  }

  if (eventQueue.length >= eventFlushBatchSize) {
    void flushEventQueue();
    return;
  }

  scheduleFlush();
}

function scheduleFlush() {
  if (typeof window === "undefined" || flushTimer !== null) {
    return;
  }

  flushTimer = window.setTimeout(() => {
    flushTimer = null;
    void flushEventQueue();
  }, eventFlushIntervalMs);
}

async function flushEventQueue(forceBeacon = false) {
  if (typeof window === "undefined" || eventQueue.length === 0) {
    return;
  }

  if (flushTimer !== null) {
    window.clearTimeout(flushTimer);
    flushTimer = null;
  }

  if (forceBeacon && typeof navigator.sendBeacon === "function") {
    const batch = eventQueue.splice(0, eventFlushBatchSize);
    const payload = JSON.stringify({ events: batch });
    const sent = navigator.sendBeacon(eventIngestionPath, new Blob([payload], { type: "application/json" }));
    if (!sent) {
      requeueBatch(batch);
    }
    return;
  }

  if (isFlushing) {
    return;
  }

  isFlushing = true;
  const batch = eventQueue.splice(0, eventFlushBatchSize);

  try {
    const response = await fetch(eventIngestionPath, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ events: batch }),
      cache: "no-store",
      keepalive: true
    });

    if (!response.ok) {
      requeueBatch(batch);
    }
  } catch {
    requeueBatch(batch);
  } finally {
    isFlushing = false;
    if (eventQueue.length > 0) {
      scheduleFlush();
    }
  }
}

function requeueBatch(batch: AppEventPayload[]) {
  eventQueue = [...batch, ...eventQueue].slice(-eventQueueMax);
}

function bindLifecycleHandlers() {
  if (hasBoundLifecycleHandlers || typeof window === "undefined") {
    return;
  }

  hasBoundLifecycleHandlers = true;

  document.addEventListener("visibilitychange", () => {
    if (document.visibilityState === "hidden") {
      void flushEventQueue(true);
    }
  });

  window.addEventListener("pagehide", () => {
    void flushEventQueue(true);
  });
}

function getCurrentPath() {
  if (typeof window === "undefined") {
    return "/";
  }

  return `${window.location.pathname}${window.location.search}`;
}

function getCurrentReferrer() {
  if (typeof document === "undefined") {
    return null;
  }

  return document.referrer || null;
}

function getOrCreateSessionId() {
  if (cachedSessionId) {
    return cachedSessionId;
  }

  const fallback = `${Date.now()}-${Math.random().toString(36).slice(2, 10)}`;
  if (typeof window === "undefined") {
    cachedSessionId = fallback;
    return cachedSessionId;
  }

  try {
    const existing = window.sessionStorage.getItem(sessionStorageKey);
    if (existing) {
      cachedSessionId = existing;
      return cachedSessionId;
    }

    const generated = typeof crypto.randomUUID === "function" ? crypto.randomUUID() : fallback;
    window.sessionStorage.setItem(sessionStorageKey, generated);
    cachedSessionId = generated;
    return cachedSessionId;
  } catch {
    cachedSessionId = fallback;
    return cachedSessionId;
  }
}

function normalizePath(value: string | null | undefined) {
  if (!value) {
    return null;
  }

  const trimmed = value.trim();
  if (!trimmed) {
    return null;
  }

  return trimmed.slice(0, 2048);
}

function normalizeText(value: string | null | undefined, maxLength: number) {
  if (!value) {
    return null;
  }

  const trimmed = value.trim();
  if (!trimmed) {
    return null;
  }

  return trimmed.slice(0, maxLength);
}
