import { getSupabaseConfiguration } from "@/lib/supabase/config";

export function getSiteUrl() {
  const explicitSiteUrl = process.env.NEXT_PUBLIC_SITE_URL;
  if (explicitSiteUrl) {
    return normalizeUrl(explicitSiteUrl);
  }

  const vercelUrl = process.env.VERCEL_PROJECT_PRODUCTION_URL || process.env.VERCEL_URL;
  if (vercelUrl) {
    return normalizeUrl(vercelUrl);
  }

  const checkoutReturnUrl = process.env.DODO_PAYMENTS_RETURN_URL?.replace(/\/checkout\/success\/?$/, "");
  if (checkoutReturnUrl) {
    return normalizeUrl(checkoutReturnUrl);
  }

  if (process.env.NODE_ENV === "production") {
    return "https://tonefex.com";
  }

  return "http://localhost:3000";
}

function normalizeUrl(url: string) {
  const trimmed = url.trim().replace(/\/+$/, "");
  if (/^https?:\/\//i.test(trimmed)) {
    return trimmed;
  }

  return `https://${trimmed}`;
}

export function getTestAccessEmails() {
  return new Set(
    (process.env.TEST_ACCESS_EMAILS || "")
      .split(",")
      .map((email) => email.trim().toLowerCase())
      .filter(Boolean)
  );
}

export function isSupabaseConfigured() {
  const config = getSupabaseConfiguration();
  return (
    Boolean(config.url && config.anonKey && config.issues.length === 0)
  );
}

export function isSupabaseAdminConfigured() {
  const config = getSupabaseConfiguration();
  return (
    Boolean(config.url && config.serviceRoleKey && config.issues.length === 0)
  );
}
