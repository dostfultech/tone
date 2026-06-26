import { redirect } from "next/navigation";
import type { SupabaseClient, User } from "@supabase/supabase-js";
import { getBypassEntitlement, mapSubscriptionEntitlement, type Entitlement } from "@/lib/entitlements";
import { createSupabaseServerClient } from "@/lib/supabase/server";

export type CurrentSession = {
  supabase: SupabaseClient | null;
  user: User | null;
};

export async function getCurrentSession(): Promise<CurrentSession> {
  const supabase = await createSupabaseServerClient();
  if (!supabase) {
    return { supabase: null, user: null };
  }

  const {
    data: { user }
  } = await supabase.auth.getUser();

  return { supabase, user };
}

export async function getEntitlement(supabase: SupabaseClient | null, user: User | null): Promise<Entitlement> {
  const bypass = getBypassEntitlement(user);
  if (bypass) {
    return bypass;
  }

  if (!supabase || !user) {
    return mapSubscriptionEntitlement(null);
  }

  const { data } = await supabase
    .from("subscriptions")
    .select("status, plan_id")
    .eq("user_id", user.id)
    .in("status", ["active", "trialing"])
    .in("plan_id", ["beginner", "expert"])
    .order("updated_at", { ascending: false })
    .limit(1)
    .maybeSingle();

  return mapSubscriptionEntitlement(data);
}

export async function requirePaidUser() {
  const { supabase, user } = await getCurrentSession();
  if (!user) {
    redirect("/login");
  }

  const entitlement = await getEntitlement(supabase, user);
  if (!entitlement.hasAccess) {
    redirect("/plans?required=subscription");
  }

  return { supabase, user, entitlement };
}
