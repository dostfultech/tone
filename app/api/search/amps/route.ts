import { NextRequest } from "next/server";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { searchEquipmentModels, toGearSearchItem } from "@/lib/equipment-service";
import { normalizeQuery, resultsResponse } from "../_shared";

export const dynamic = "force-dynamic";

export async function GET(request: NextRequest) {
  const query = normalizeQuery(request.nextUrl.searchParams.get("q"));
  const limit = Number(request.nextUrl.searchParams.get("limit") || "200");
  const supabase = await createSupabaseServerClient();

  const results = await searchEquipmentModels(supabase, "amp", {
    query,
    limit
  });

  return resultsResponse((results || []).map(toGearSearchItem));
}
