import { NextResponse } from "next/server";
import { getSiteUrl } from "@/lib/env";
import { getCurrentSession } from "@/lib/server-access";

export async function GET() {
  const { supabase, user } = await getCurrentSession();
  if (!supabase || !user) {
    return NextResponse.json({ error: "Authentication required" }, { status: 401 });
  }

  const { data: subscription } = await supabase
    .from("subscriptions")
    .select("dodo_customer_id")
    .eq("user_id", user.id)
    .not("dodo_customer_id", "is", null)
    .order("updated_at", { ascending: false })
    .limit(1)
    .maybeSingle();

  if (!subscription?.dodo_customer_id) {
    return NextResponse.json({ error: "No Dodo customer is linked to this account yet." }, { status: 404 });
  }

  const portalUrl = new URL("/customer-portal", getSiteUrl());
  portalUrl.searchParams.set("customer_id", subscription.dodo_customer_id);
  return NextResponse.json({ portalUrl: portalUrl.toString() });
}
