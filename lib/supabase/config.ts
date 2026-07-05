export interface SupabaseConfigResolution {
  url: string | null;
  anonKey: string | null;
  serviceRoleKey: string | null;
  expectedProjectRef: string | null;
  urlProjectRef: string | null;
  anonProjectRef: string | null;
  serviceRoleProjectRef: string | null;
  issues: string[];
}

function safeBase64UrlDecode(value: string): string | null {
  try {
    const normalized = value.replace(/-/g, "+").replace(/_/g, "/");
    const padding = normalized.length % 4;
    const padded = normalized + "=".repeat((4 - padding) % 4);

    if (typeof atob === "function") {
      const binary = atob(padded);
      return decodeURIComponent(
        binary
          .split("")
          .map((char) => `%${char.charCodeAt(0).toString(16).padStart(2, "0")}`)
          .join("")
      );
    }

    if (typeof Buffer !== "undefined") {
      return Buffer.from(padded, "base64").toString("utf8");
    }
  } catch {
    return null;
  }

  return null;
}

function extractProjectRefFromUrl(url: string | null): string | null {
  if (!url) return null;
  const match = /^https:\/\/([a-z0-9-]+)\.supabase\.co\/?/.exec(url);
  return match?.[1] || null;
}

function extractProjectRefFromJwt(token: string | null): string | null {
  if (!token) return null;
  const parts = token.split(".");
  if (parts.length !== 3) return null;

  const payload = safeBase64UrlDecode(parts[1]);
  if (!payload) return null;

  try {
    const parsed = JSON.parse(payload) as { ref?: string };
    return typeof parsed.ref === "string" ? parsed.ref : null;
  } catch {
    return null;
  }
}

function resolveSupabaseProjectRefs() {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL || process.env.SUPABASE_URL || null;
  const anonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || process.env.SUPABASE_ANON_KEY || null;
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY || null;

  return {
    url,
    anonKey,
    serviceRoleKey,
    urlProjectRef: extractProjectRefFromUrl(url),
    anonProjectRef: extractProjectRefFromJwt(anonKey),
    serviceRoleProjectRef: extractProjectRefFromJwt(serviceRoleKey),
    expectedProjectRef: process.env.TONEFEX_EXPECTED_SUPABASE_PROJECT_REF || process.env.SUPABASE_PROJECT_REF || null,
  };
}

export function getSupabaseConfiguration(options?: { requireServiceRole?: boolean }): SupabaseConfigResolution {
  const resolution = resolveSupabaseProjectRefs();
  const issues: string[] = [];
  const requireServiceRole = Boolean(options?.requireServiceRole);

  if (!resolution.url) {
    issues.push("NEXT_PUBLIC_SUPABASE_URL (or SUPABASE_URL) is not set.");
  }

  if (!resolution.anonKey) {
    issues.push("NEXT_PUBLIC_SUPABASE_ANON_KEY (or SUPABASE_ANON_KEY) is not set.");
  }

  if (requireServiceRole && !resolution.serviceRoleKey) {
    issues.push("SUPABASE_SERVICE_ROLE_KEY is not set.");
  }

  if (resolution.urlProjectRef && resolution.anonProjectRef && resolution.urlProjectRef !== resolution.anonProjectRef) {
    issues.push(
      `Supabase URL project (${resolution.urlProjectRef}) does not match anon key project (${resolution.anonProjectRef}).`
    );
  }

  if (
    resolution.urlProjectRef &&
    resolution.serviceRoleProjectRef &&
    resolution.urlProjectRef !== resolution.serviceRoleProjectRef
  ) {
    issues.push(
      `Supabase URL project (${resolution.urlProjectRef}) does not match service role key project (${resolution.serviceRoleProjectRef}).`
    );
  }

  if (
    resolution.anonProjectRef &&
    resolution.serviceRoleProjectRef &&
    resolution.anonProjectRef !== resolution.serviceRoleProjectRef
  ) {
    issues.push(
      `Supabase anon key project (${resolution.anonProjectRef}) does not match service role key project (${resolution.serviceRoleProjectRef}).`
    );
  }

  if (resolution.expectedProjectRef) {
    const expected = resolution.expectedProjectRef;
    const refsToValidate = [
      resolution.urlProjectRef,
      resolution.anonProjectRef,
      resolution.serviceRoleProjectRef,
    ].filter((candidate): candidate is string => Boolean(candidate));

    const unexpected = refsToValidate.find((candidate) => candidate !== expected);
    if (unexpected) {
      issues.push(`Expected Supabase project "${expected}", but resolved project "${unexpected}".`);
    }
  }

  return {
    url: resolution.url,
    anonKey: resolution.anonKey,
    serviceRoleKey: resolution.serviceRoleKey,
    expectedProjectRef: resolution.expectedProjectRef,
    urlProjectRef: resolution.urlProjectRef,
    anonProjectRef: resolution.anonProjectRef,
    serviceRoleProjectRef: resolution.serviceRoleProjectRef,
    issues,
  };
}

export function logSupabaseConfigIssues(context: string, issues: string[]) {
  console.error(`[tonefex-supabase-config][${context}] ${issues.join(" | ")}`);
}
