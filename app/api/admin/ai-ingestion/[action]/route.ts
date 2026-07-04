import { NextResponse } from "next/server";
import { createAdminIngestionController } from "@/lib/backend/ai-ingestion";
import { createSupabaseAdminClient } from "@/lib/supabase/admin";

export const runtime = "nodejs";
export const maxDuration = 60;

type RouteContext = {
  params: Promise<{ action: string }>;
};

export async function POST(request: Request, context: RouteContext) {
  return handle(request, context);
}

export async function PATCH(request: Request, context: RouteContext) {
  return handle(request, context);
}

export async function DELETE(request: Request, context: RouteContext) {
  return handle(request, context);
}

async function handle(request: Request, context: RouteContext) {
  const supabase = createSupabaseAdminClient();
  if (!supabase) {
    return NextResponse.json(
      {
        error: {
          code: "SUPABASE_ADMIN_UNAVAILABLE",
          message: "SUPABASE_SERVICE_ROLE_KEY is required for admin AI ingestion.",
          status: 503
        }
      },
      { status: 503 }
    );
  }

  const { action } = await context.params;
  return createAdminIngestionController(supabase).handle(action, request);
}
