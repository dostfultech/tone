import { NextResponse, type NextRequest } from "next/server";
import { brand } from "@/lib/brand";
import { type BillingInterval, createDodoClient, getDodoProductId, isDodoConfigured, type PlanId } from "@/lib/dodo";
import { getSiteUrl } from "@/lib/env";
import { createSupabaseAdminClient } from "@/lib/supabase/admin";
import { getCurrentSession } from "@/lib/server-access";

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
    return NextResponse.json({ error: "Dodo Payments is not configured. Add DODO_PAYMENTS_API_KEY to .env.local." }, { status: 503 });
  }

  const productId = getDodoProductId(planId as PlanId, billing as BillingInterval);
  if (!productId) {
    return NextResponse.json({ error: `Missing Dodo product ID for ${planId} ${billing}.` }, { status: 503 });
  }

  const client = createDodoClient();
  if (!client) {
    return NextResponse.json({ error: "Dodo client unavailable" }, { status: 503 });
  }

  const siteUrl = process.env.NODE_ENV === "production" ? getSiteUrl() : request.nextUrl.origin;
  const returnUrl = new URL("/checkout/success", siteUrl);
  returnUrl.searchParams.set("plan_id", planId);
  returnUrl.searchParams.set("billing_interval", billing);

  const checkout = await client.checkoutSessions.create({
    product_cart: [{ product_id: productId, quantity: 1 }],
    customer: {
      email: user.email || "",
      name: user.user_metadata?.full_name || user.email || `${brand.appName} user`
    },
    return_url: returnUrl.toString(),
    metadata: {
      user_id: user.id,
      plan_id: planId,
      billing_interval: billing
    }
  } as never);

  const admin = createSupabaseAdminClient();
  await admin?.from("usage_events").insert({
    user_id: user.id,
    event_type: "checkout_started",
    metadata: { plan_id: planId, billing_interval: billing, product_id: productId }
  });

  const checkoutUrl = (checkout as { checkout_url?: string; payment_link?: string; url?: string }).checkout_url ||
    (checkout as { checkout_url?: string; payment_link?: string; url?: string }).payment_link ||
    (checkout as { checkout_url?: string; payment_link?: string; url?: string }).url;

  if (!checkoutUrl) {
    return NextResponse.json({ error: "Dodo did not return a checkout URL." }, { status: 502 });
  }

  return NextResponse.json({ checkoutUrl });
}
