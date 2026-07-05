import { createClient } from "@supabase/supabase-js";
import type { SupabaseClient } from "@supabase/supabase-js";
import { getSupabaseConfiguration, logSupabaseConfigIssues } from "@/lib/supabase/config";

export function createSupabaseAdminClient(): SupabaseClient | null {
  const config = getSupabaseConfiguration({ requireServiceRole: true });

  if (config.issues.length > 0) {
    logSupabaseConfigIssues("admin", config.issues);
    return null;
  }

  const { url, serviceRoleKey } = config;

  if (!url || !serviceRoleKey) {
    return null;
  }

  return createClient(url, serviceRoleKey, {
    auth: {
      persistSession: false,
      autoRefreshToken: false
    }
  });
}
