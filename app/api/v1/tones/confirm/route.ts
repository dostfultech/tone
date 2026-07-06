import { NextResponse, type NextRequest } from "next/server";
import { getEntitlement, getCurrentSession } from "@/lib/server-access";
import { createSupabaseAdminClient } from "@/lib/supabase/admin";
import { confirmToneAdaptationUsage } from "@/lib/usage";

export const runtime = "nodejs";

export async function POST(request: NextRequest) {
  const admin = createSupabaseAdminClient();
  if (!admin) {
    return NextResponse.json(
      {
        error: {
          code: "SUPABASE_ADMIN_UNAVAILABLE",
          message: "Tone adaptation confirmation is unavailable.",
          status: 503
        }
      },
      { status: 503 }
    );
  }

  const { supabase, user } = await getCurrentSession();
  if (!user) {
    return NextResponse.json(
      {
        error: {
          code: "AUTHENTICATION_REQUIRED",
          message: "Sign in to confirm this tone adaptation.",
          status: 401
        }
      },
      { status: 401 }
    );
  }

  const body = await request.json().catch(() => ({}));
  const toneResultId = typeof body.toneResultId === "string" ? body.toneResultId : "";

  if (!toneResultId) {
    return NextResponse.json(
      {
        error: {
          code: "INVALID_REQUEST",
          message: "toneResultId is required.",
          status: 400
        }
      },
      { status: 400 }
    );
  }

  const entitlement = await getEntitlement(supabase, user);
  const confirmation = await confirmToneAdaptationUsage(admin, user, toneResultId, entitlement);

  if (!confirmation.ok) {
    return NextResponse.json(
      {
        error: {
          code: "USAGE_CONFIRMATION_FAILED",
          message: confirmation.error || "Tone adaptation confirmation failed.",
          status: 500
        }
      },
      { status: 500 }
    );
  }

  return NextResponse.json({
    confirmed: confirmation.confirmed,
    usageApplied: confirmation.usageApplied,
    freeAdaptationsRemaining: confirmation.freeAdaptationsRemaining,
    freeAdaptationsUsed: confirmation.freeAdaptationsUsed,
    freeAdaptationLimit: confirmation.freeAdaptationLimit,
    monthlyAdaptationsRemaining: confirmation.monthlyAdaptationsRemaining,
    firstAdaptationCompleted: confirmation.firstAdaptationCompleted
  });
}
