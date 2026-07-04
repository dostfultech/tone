import { NextResponse } from "next/server";
import { createToneAdaptationController } from "@/lib/backend/tone-adaptation";
import { createSupabaseAdminClient } from "@/lib/supabase/admin";

export const runtime = "nodejs";

export async function POST(request: Request) {
  const supabase = createSupabaseAdminClient();

  if (!supabase) {
    return NextResponse.json(
      {
        error: {
          code: "SUPABASE_ADMIN_UNAVAILABLE",
          message: "Tone adaptation backend is not configured with a Supabase service role key.",
          status: 503
        }
      },
      { status: 503 }
    );
  }

  return createToneAdaptationController(supabase).adapt(request);
}
