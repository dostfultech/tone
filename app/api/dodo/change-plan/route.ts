import { NextResponse, type NextRequest } from "next/server";
import {
  type BillingInterval,
  createDodoClient,
  getDodoProductId,
  isDodoConfigured,
  resolveDodoEnvironment,
  type PlanId
} from "@/lib/dodo";
import { createSupabaseAdminClient } from "@/lib/supabase/admin";
import { getCurrentSession } from "@/lib/server-access";

/**
 * Convert / upgrade an in-flight subscription immediately using Dodo's changePlan.
 *
 * A checkout would only start ANOTHER trial (the product carries a 7-day trial), so to
 * charge a trialing user now — or move a Beginner subscriber to Expert — we change the
 * existing subscription's plan with immediate proration. The card is already on file,
 * so no redirect is needed. The webhook then syncs the resulting status.
 */
export async function POST(request: NextRequest) {
  const { user } = await getCurrentSession();
  if (!user) {
    return NextResponse.json({ error: "Authentication required" }, { status: 401 });
  }

  const body = await request.json().catch(() => ({}));
  const planId = body.planId === "expert" ? "expert" : body.planId === "beginner" ? "beginner" : null;
  const billing = body.billing === "monthly" ? "monthly" : body.billing === "annual" ? "annual" : null;

  if (!planId || !billing) {
    return NextResponse.json({ error: "Invalid plan or billing interval" }, { status: 400 });
  }

  if (!isDodoConfigured()) {
    return NextResponse.json({ error: "Dodo Payments is not configured for this environment." }, { status: 503 });
  }

  const productId = getDodoProductId(planId as PlanId, billing as BillingInterval);
  if (!productId) {
    return NextResponse.json({ error: `Missing Dodo product ID for ${planId} ${billing}.` }, { status: 503 });
  }

  const admin = createSupabaseAdminClient();
  if (!admin) {
    return NextResponse.json({ error: "Server unavailable" }, { status: 503 });
  }

  // The subscription being converted must belong to this user and be live (trialing or
  // active) with a real Dodo id (not a checkout-return placeholder).
  const { data: sub } = await admin
    .from("subscriptions")
    .select("dodo_subscription_id, status, plan_id, billing_interval")
    .eq("user_id", user.id)
    .in("status", ["trialing", "active"])
    .not("dodo_subscription_id", "is", null)
    .order("updated_at", { ascending: false })
    .limit(1)
    .maybeSingle();

  const subscriptionId = sub?.dodo_subscription_id || "";
  if (!subscriptionId || subscriptionId.startsWith("checkout-return-")) {
    return NextResponse.json(
      { error: "No active subscription to change. Start a plan first.", code: "no_subscription" },
      { status: 409 }
    );
  }

  // No-op guard: same plan + same billing that is already active (not a trial) needs no charge.
  if (sub?.status === "active" && sub.plan_id === planId && sub.billing_interval === billing) {
    return NextResponse.json({ ok: true, planId, billing, unchanged: true });
  }

  const client = createDodoClient();
  if (!client) {
    return NextResponse.json({ error: "Dodo client unavailable" }, { status: 503 });
  }

  try {
    // full_immediately bills the new plan now (ends the trial), rather than a prorated
    // or scheduled amount that could come out to $0 during a trial.
    await client.subscriptions.changePlan(subscriptionId, {
      product_id: productId,
      proration_billing_mode: "full_immediately",
      quantity: 1
    });
  } catch (error) {
    return NextResponse.json(
      { error: error instanceof Error ? error.message : "Unable to change plan." },
      { status: 502 }
    );
  }

  // Activate authoritatively in our DB so access reflects immediately (the webhook can
  // lag). New plan, trial cleared, and a fresh monthly quota.
  const now = new Date();
  const periodEnd = new Date(now);
  if (billing === "annual") {
    periodEnd.setFullYear(periodEnd.getFullYear() + 1);
  } else {
    periodEnd.setMonth(periodEnd.getMonth() + 1);
  }
  await admin
    .from("subscriptions")
    .update({
      status: "active",
      plan_id: planId,
      billing_interval: billing,
      dodo_product_id: productId,
      trial_end: now.toISOString(),
      trial_period_days: 0,
      current_period_start: now.toISOString(),
      current_period_end: periodEnd.toISOString()
    })
    .eq("user_id", user.id)
    .eq("dodo_subscription_id", subscriptionId);

  const usageMonth = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), 1)).toISOString().slice(0, 10);
  await admin.from("monthly_usage").update({ adaptations_used: 0 }).eq("user_id", user.id).eq("usage_month", usageMonth);

  await admin.from("usage_events").insert({
    user_id: user.id,
    event_type: sub?.status === "trialing" ? "trial_converted" : "plan_changed",
    metadata: {
      from_plan: sub?.plan_id,
      from_status: sub?.status,
      to_plan: planId,
      billing_interval: billing,
      product_id: productId,
      environment: resolveDodoEnvironment()
    }
  });

  return NextResponse.json({ ok: true, planId, billing });
}
