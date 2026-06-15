import { redirect } from "next/navigation";
import { normalizeDodoStatus, type BillingInterval, type PlanId } from "@/lib/dodo";
import { getCurrentSession } from "@/lib/server-access";
import { createSupabaseAdminClient } from "@/lib/supabase/admin";

type CheckoutSuccessPageProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

export default async function CheckoutSuccessPage({ searchParams }: CheckoutSuccessPageProps) {
  const params = await searchParams;
  const { user } = await getCurrentSession();

  if (!user) {
    redirect(`/login?redirect=${encodeURIComponent("/app")}`);
  }

  const rawStatus = stringParam(params.status) || stringParam(params.subscription_status) || "active";
  const status = normalizeDodoStatus(rawStatus);

  if (status !== "active" && status !== "trialing") {
    redirect("/plans?checkout=not_active");
  }

  const activated = await activateReturnedSubscription(params, user.id, status);

  if (!activated) {
    redirect("/plans?checkout=sync_pending");
  }

  redirect("/app?checkout=success");
}

async function activateReturnedSubscription(
  params: Record<string, string | string[] | undefined>,
  userId: string,
  status: "active" | "trialing"
) {
  const admin = createSupabaseAdminClient();
  if (!admin) {
    return false;
  }

  const checkoutMetadata = await getLatestCheckoutMetadata(userId);
  const subscriptionId = stringParam(params.subscription_id) || stringParam(params.subscriptionId);
  const planId = validPlanId(stringParam(params.plan_id) || stringParam(params.planId) || stringValue(checkoutMetadata?.plan_id));
  const billingInterval = validBillingInterval(
    stringParam(params.billing_interval) || stringParam(params.billingInterval) || stringValue(checkoutMetadata?.billing_interval)
  );
  const productId = stringParam(params.product_id) || stringParam(params.productId) || stringValue(checkoutMetadata?.product_id);

  if (!subscriptionId || !planId || !billingInterval) {
    return false;
  }

  const now = new Date();
  const periodEnd = new Date(now);
  if (billingInterval === "annual") {
    periodEnd.setFullYear(periodEnd.getFullYear() + 1);
  } else {
    periodEnd.setMonth(periodEnd.getMonth() + 1);
  }

  const { error } = await admin.from("subscriptions").upsert(
    {
      user_id: userId,
      plan_id: planId,
      billing_interval: billingInterval,
      status,
      dodo_subscription_id: subscriptionId,
      dodo_product_id: productId || null,
      current_period_start: now.toISOString(),
      current_period_end: periodEnd.toISOString(),
      cancel_at_period_end: false,
      metadata: {
        source: "checkout_return",
        returned_params: params,
        checkout_metadata: checkoutMetadata
      }
    },
    { onConflict: "dodo_subscription_id" }
  );

  if (!error) {
    await admin.from("admin_audit_logs").insert({
      actor_id: userId,
      action: "dodo_checkout_return_sync",
      target_table: "subscriptions",
      target_id: subscriptionId,
      metadata: { status, planId, billingInterval, productId }
    });
  }

  return !error;
}

async function getLatestCheckoutMetadata(userId: string) {
  const admin = createSupabaseAdminClient();
  if (!admin) {
    return null;
  }

  const { data } = await admin
    .from("usage_events")
    .select("metadata")
    .eq("user_id", userId)
    .eq("event_type", "checkout_started")
    .order("created_at", { ascending: false })
    .limit(1)
    .maybeSingle();

  return (data?.metadata || null) as Record<string, unknown> | null;
}

function stringParam(value: string | string[] | undefined) {
  return Array.isArray(value) ? value[0] || "" : value || "";
}

function stringValue(value: unknown) {
  return typeof value === "string" ? value : "";
}

function validPlanId(value: string): PlanId | "" {
  return value === "beginner" || value === "expert" ? value : "";
}

function validBillingInterval(value: string): BillingInterval | "" {
  return value === "monthly" || value === "annual" ? value : "";
}
