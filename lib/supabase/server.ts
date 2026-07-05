import { cookies } from "next/headers";
import { createServerClient } from "@supabase/ssr";
import type { SupabaseClient } from "@supabase/supabase-js";
import { getSupabaseConfiguration, logSupabaseConfigIssues } from "@/lib/supabase/config";

export async function createSupabaseServerClient(): Promise<SupabaseClient | null> {
  const config = getSupabaseConfiguration();

  if (config.issues.length > 0) {
    logSupabaseConfigIssues("server", config.issues);
    return null;
  }

  const { url, anonKey } = config;

  if (!url || !anonKey) {
    return null;
  }

  const cookieStore = await cookies();

  return createServerClient(url, anonKey, {
    cookies: {
      getAll() {
        return cookieStore.getAll();
      },
      setAll(cookiesToSet) {
        try {
          cookiesToSet.forEach(({ name, value, options }) => {
            cookieStore.set(name, value, options);
          });
        } catch {
          // Server Components cannot set cookies. Middleware refreshes sessions.
        }
      }
    }
  });
}
