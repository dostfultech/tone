import { NextResponse, type NextRequest } from "next/server";
import { getCurrentSession } from "@/lib/server-access";
import { createSupabaseAdminClient } from "@/lib/supabase/admin";

export async function POST(request: NextRequest) {
  const { supabase, user } = await getCurrentSession();
  if (!user || !supabase) {
    return NextResponse.json({ error: "Authentication required." }, { status: 401 });
  }

  const { data: profile } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .maybeSingle();

  if (profile?.role !== "admin") {
    return NextResponse.json({ error: "Admin access required." }, { status: 403 });
  }

  const admin = createSupabaseAdminClient();
  if (!admin) {
    return NextResponse.json({ error: "Service unavailable." }, { status: 503 });
  }

  let body: Record<string, unknown>;
  try {
    body = await request.json();
  } catch {
    return NextResponse.json({ error: "Invalid request body." }, { status: 400 });
  }

  const userId = body.userId as string;
  const feedbackId = body.feedbackId as string;
  if (!userId || !feedbackId) {
    return NextResponse.json({ error: "userId and feedbackId are required." }, { status: 400 });
  }

  const now = new Date().toISOString();
  const periodEnd = new Date(Date.now() + 365 * 24 * 60 * 60 * 1000).toISOString();

  await admin
    .from("subscriptions")
    .update({ status: "cancelled" })
    .eq("user_id", userId)
    .in("status", ["active", "trialing"]);

  const { error: subError } = await admin.from("subscriptions").insert({
    user_id: userId,
    plan_id: "expert",
    status: "active",
    billing_interval: "annual",
    current_period_start: now,
    current_period_end: periodEnd,
    metadata: { source: "early_tester_upgrade", feedback_id: feedbackId, upgraded_by: user.id }
  });

  if (subError) {
    console.error("[tonefex:admin] Subscription insert failed:", subError.message);
    return NextResponse.json({ error: "Failed to create subscription." }, { status: 500 });
  }

  await admin
    .from("feedback_submissions")
    .update({ status: "upgraded", reviewed_at: now, reviewed_by: user.id })
    .eq("id", feedbackId);

  await admin.from("admin_audit_logs").insert({
    actor_id: user.id,
    action: "early_tester_upgraded_to_expert",
    target_table: "subscriptions",
    target_id: userId,
    metadata: { feedback_id: feedbackId }
  });

  return NextResponse.json({ ok: true });
}
