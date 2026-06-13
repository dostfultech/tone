import { NextResponse, type NextRequest } from "next/server";
import { syncDodoSubscription } from "@/lib/dodo-webhooks";

export async function POST(request: NextRequest) {
  const webhookKey = process.env.DODO_PAYMENTS_WEBHOOK_KEY;
  if (!webhookKey) {
    return NextResponse.json({ error: "DODO_PAYMENTS_WEBHOOK_KEY is not configured." }, { status: 503 });
  }

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

  return handler(request);
}
