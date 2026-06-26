export function getSiteUrl() {
  const explicitSiteUrl = process.env.NEXT_PUBLIC_SITE_URL;
  if (explicitSiteUrl) {
    return normalizeUrl(explicitSiteUrl);
  }

  if (process.env.NODE_ENV === "production") {
    return "https://tonefex.com";
  }

  const vercelUrl = process.env.VERCEL_PROJECT_PRODUCTION_URL || process.env.VERCEL_URL;
  if (vercelUrl) {
    return normalizeUrl(vercelUrl);
  }

  const checkoutReturnUrl = process.env.DODO_PAYMENTS_RETURN_URL?.replace(/\/checkout\/success\/?$/, "");
  if (checkoutReturnUrl) {
    return normalizeUrl(checkoutReturnUrl);
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
  return Boolean(process.env.NEXT_PUBLIC_SUPABASE_URL && process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY);
}

export function isSupabaseAdminConfigured() {
  return Boolean(process.env.NEXT_PUBLIC_SUPABASE_URL && process.env.SUPABASE_SERVICE_ROLE_KEY);
}
