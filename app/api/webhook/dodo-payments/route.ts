import { NextResponse, type NextRequest } from "next/server";
import { resolveDodoEnvironment } from "@/lib/dodo";
import { syncDodoSubscription } from "@/lib/dodo-webhooks";

/**
 * Diagnostic only (no secrets revealed). Open this URL in a browser to confirm the
 * endpoint is deployed/reachable, that the signing secret env var is present, and
 * which Dodo environment the app is verifying against — the three things that make
 * webhook delivery silently fail. Dodo never GETs this; it always POSTs events.
 */
export async function GET() {
  const secret = process.env.DODO_PAYMENTS_WEBHOOK_KEY || "";
  return NextResponse.json({
    endpoint: "dodo-payments webhook",
    reachable: true,
    webhookSecretConfigured: Boolean(secret),
    // Debug fingerprint (not the full secret): compare these against the Signing
    // Secret shown on your Dodo webhook page. If the first chars or the length
    // differ, Vercel has the wrong/stale secret — re-copy it and redeploy.
    webhookSecretStartsWith: secret ? secret.slice(0, 9) : null,
    webhookSecretLength: secret.length || null,
    apiKeyConfigured: Boolean(process.env.DODO_PAYMENTS_API_KEY),
    environment: resolveDodoEnvironment(),
    note: "Dodo must POST live-mode events here with a signature from the LIVE webhook whose secret matches DODO_PAYMENTS_WEBHOOK_KEY."
  });
}

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
