import { NextRequest } from "next/server";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { searchMultiFxModels } from "@/lib/equipment-service";
import { normalizeQuery, resultsResponse } from "../_shared";

export const dynamic = "force-dynamic";

export async function GET(request: NextRequest) {
  const query = normalizeQuery(request.nextUrl.searchParams.get("q"));
  const limit = normalizeLimit(request.nextUrl.searchParams.get("limit"));
  const supabase = await createSupabaseServerClient();
  const results = await searchMultiFxModels(supabase, { query, limit });
  return resultsResponse(results || []);
}

function normalizeLimit(value: string | null) {
  const parsed = Number(value ?? "200");
  if (!Number.isFinite(parsed) || parsed <= 0) {
    return 200;
  }
  return Math.min(Math.trunc(parsed), 200);
}
