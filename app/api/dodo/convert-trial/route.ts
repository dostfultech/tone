import { NextResponse } from "next/server";
import { createDodoClient } from "@/lib/dodo";
import { getCurrentSession } from "@/lib/server-access";
import { createSupabaseAdminClient } from "@/lib/supabase/admin";

/**
 * Convert the signed-in user's free trial into a full paid subscription NOW —
 * "Unlock Full Access". This ends the trial on the EXISTING Dodo subscription
 * (billing immediately) instead of starting a second checkout / second trial, then
 * activates it in our DB and resets the monthly quota so the full plan is available.
 */
export async function POST() {
  const { user } = await getCurrentSession();
  if (!user) {
    return NextResponse.json({ error: "Authentication required" }, { status: 401 });
  }

  const admin = createSupabaseAdminClient();
  if (!admin) {
    return NextResponse.json({ error: "Billing backend is not configured." }, { status: 503 });
  }

  const { data: sub } = await admin
    .from("subscriptions")
    .select("id, dodo_subscription_id, plan_id, billing_interval, status")
    .eq("user_id", user.id)
    .in("status", ["trialing", "active"])
    .not("dodo_subscription_id", "is", null)
    .order("updated_at", { ascending: false })
    .limit(1)
    .maybeSingle();

  if (!sub?.dodo_subscription_id || sub.dodo_subscription_id.startsWith("checkout-return-")) {
    return NextResponse.json({ error: "No active trial to unlock. Start a plan first.", code: "no_subscription" }, { status: 400 });
  }

  if (sub.status === "active") {
    return NextResponse.json({ ok: true, alreadyActive: true });
  }

  // Tell Dodo to end the trial and bill this subscription now. If this fails we do
  // NOT grant paid access — the customer must not get the full plan without the
  // conversion being accepted by the processor.
  const client = createDodoClient();
  if (!client) {
    return NextResponse.json({ error: "Dodo client unavailable" }, { status: 503 });
  }

  try {
    // Dodo requires next_billing_date to be strictly in the future ("should be
    // greater than current time"), so we schedule the first charge a couple of
    // minutes out — that ends the trial and bills the single scheduled charge
    // shortly, rather than at the original trial-end mark.
    const billAt = new Date(Date.now() + 2 * 60 * 1000).toISOString();
    await client.subscriptions.update(sub.dodo_subscription_id, { next_billing_date: billAt });
  } catch (error) {
    return NextResponse.json(
      { error: error instanceof Error ? error.message : "Could not end the trial with the payment provider." },
      { status: 502 }
    );
  }

  const now = new Date();
  const periodEnd = new Date(now);
  if (sub.billing_interval === "annual") {
    periodEnd.setFullYear(periodEnd.getFullYear() + 1);
  } else {
    periodEnd.setMonth(periodEnd.getMonth() + 1);
  }

  // Activate authoritatively in our DB. trial_end = now marks the trial as over, so
  // the app switches from trial limits (5 / 8) to the full plan limits immediately.
  await admin
    .from("subscriptions")
    .update({
      status: "active",
      trial_end: now.toISOString(),
      trial_period_days: 0,
      current_period_start: now.toISOString(),
      current_period_end: periodEnd.toISOString()
    })
    .eq("id", sub.id);

  // Fresh billing period → reset this month's adaptation counter so the full plan
  // quota is available (trial adaptations don't eat into the paid quota).
  const usageMonth = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), 1)).toISOString().slice(0, 10);
  await admin.from("monthly_usage").update({ adaptations_used: 0 }).eq("user_id", user.id).eq("usage_month", usageMonth);

  // Remove any duplicate trial rows so the account resolves to the one converted sub.
  await admin.from("subscriptions").delete().eq("user_id", user.id).eq("status", "trialing").neq("id", sub.id);

  await admin.from("admin_audit_logs").insert({
    actor_id: user.id,
    action: "dodo_trial_converted",
    target_table: "subscriptions",
    target_id: sub.dodo_subscription_id,
    metadata: { planId: sub.plan_id, billingInterval: sub.billing_interval }
  });

  return NextResponse.json({ ok: true });
}
