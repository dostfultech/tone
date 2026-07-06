export const SUBSCRIPTION_REFRESH_EVENT = "tonefex:subscription-refresh";

export function dispatchSubscriptionRefresh() {
  if (typeof window === "undefined") {
    return;
  }

  window.dispatchEvent(new CustomEvent(SUBSCRIPTION_REFRESH_EVENT));
}

export function addSubscriptionRefreshListener(callback: () => void) {
  if (typeof window === "undefined") {
    return () => undefined;
  }

  window.addEventListener(SUBSCRIPTION_REFRESH_EVENT, callback);
  return () => window.removeEventListener(SUBSCRIPTION_REFRESH_EVENT, callback);
}
