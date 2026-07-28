import { NextResponse, type NextRequest } from "next/server";
import { syncDodoSubscription } from "@/lib/dodo-webhooks";

export async function POST(request: NextRequest) {
  const webhookKey = process.env.DODO_PAYMENTS_WEBHOOK_KEY;
  if (!webhookKey) {
    console.error("[dodo-webhook] received event but DODO_PAYMENTS_WEBHOOK_KEY is not configured");
    return NextResponse.json({ error: "DODO_PAYMENTS_WEBHOOK_KEY is not configured." }, { status: 503 });
  }

  // Delivery confirmation (headers only, does not consume the body). If this line
  // never appears in the logs, Dodo is not reaching this endpoint for this mode.
  console.log("[dodo-webhook] received", {
    webhookId: request.headers.get("webhook-id"),
    hasSignature: Boolean(request.headers.get("webhook-signature"))
  });

  const { Webhooks } = await import("@dodopayments/nextjs");
  const handler = Webhooks({
    webhookKey,
    onPayload: async (payload) => {
      await syncDodoSubscription(payload);
    },
    onSubscriptionActive: async (payload) => {
      await syncDodoSubscription(payload);
    },
    onSubscriptionRenewed: async (payload) => {
      await syncDodoSubscription(payload);
    },
    onSubscriptionPlanChanged: async (payload) => {
      await syncDodoSubscription(payload);
    },
    onSubscriptionCancelled: async (payload) => {
      await syncDodoSubscription(payload);
    },
    onSubscriptionFailed: async (payload) => {
      await syncDodoSubscription(payload);
    },
    onSubscriptionExpired: async (payload) => {
      await syncDodoSubscription(payload);
    }
  });

  const response = await handler(request);
  if (response.status >= 400) {
    console.error("[dodo-webhook] handler rejected event", response.status, "(likely a signing-secret/mode mismatch)");
  }
  return response;
}
