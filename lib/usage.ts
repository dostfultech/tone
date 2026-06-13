import type { SupabaseClient, User } from "@supabase/supabase-js";
import { type Entitlement } from "@/lib/entitlements";

export function currentUsageMonth() {
  const now = new Date();
  return `${now.getUTCFullYear()}-${String(now.getUTCMonth() + 1).padStart(2, "0")}-01`;
}

export async function assertCanCreateAdaptation(admin: SupabaseClient | null, user: User, entitlement: Entitlement) {
  if (!entitlement.hasAccess) {
    return { ok: false, error: "A paid subscription is required to create tone adaptations." };
  }

  if (entitlement.source === "test" || entitlement.monthlyAdaptations === null) {
    return { ok: true };
  }

  if (!admin) {
    return { ok: false, error: "SUPABASE_SERVICE_ROLE_KEY is required for usage enforcement." };
  }

  const { data } = await admin
    .from("monthly_usage")
    .select("adaptations_used")
    .eq("user_id", user.id)
    .eq("usage_month", currentUsageMonth())
    .maybeSingle();

  const used = data?.adaptations_used || 0;
  if (used >= entitlement.monthlyAdaptations) {
    return { ok: false, error: "Monthly adaptation limit reached. Upgrade to Expert for unlimited matching." };
  }

  return { ok: true };
}

export async function incrementAdaptationUsage(admin: SupabaseClient | null, userId: string, toneJobId: string | null) {
  if (!admin) {
    return;
  }

  const month = currentUsageMonth();
  const { data } = await admin.from("monthly_usage").select("adaptations_used").eq("user_id", userId).eq("usage_month", month).maybeSingle();
  const nextCount = (data?.adaptations_used || 0) + 1;

  await admin.from("monthly_usage").upsert({
    user_id: userId,
    usage_month: month,
    adaptations_used: nextCount
  });

  await admin.from("usage_events").insert({
    user_id: userId,
    event_type: "tone_adaptation",
    tone_job_id: toneJobId,
    quantity: 1
  });
}
