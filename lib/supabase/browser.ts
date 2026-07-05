"use client";

import { createBrowserClient } from "@supabase/ssr";
import type { SupabaseClient } from "@supabase/supabase-js";
import { getSupabaseConfiguration, logSupabaseConfigIssues } from "@/lib/supabase/config";

export function createSupabaseBrowserClient(): SupabaseClient | null {
  const config = getSupabaseConfiguration();

  if (config.issues.length > 0) {
    logSupabaseConfigIssues("browser", config.issues);
    return null;
  }

  const { url, anonKey } = config;

  if (!url || !anonKey) {
    return null;
  }

  return createBrowserClient(url, anonKey);
}
