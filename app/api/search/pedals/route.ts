import { NextRequest } from "next/server";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { searchEquipmentModels, toGearSearchItem } from "@/lib/equipment-service";
import { normalizeQuery, resultsResponse } from "../_shared";

export const dynamic = "force-dynamic";

export async function GET(request: NextRequest) {
  const query = normalizeQuery(request.nextUrl.searchParams.get("q"));
  const supabase = await createSupabaseServerClient();

  const results = await searchEquipmentModels(supabase, "pedal", {
    query,
    limit: 20
  });

  return resultsResponse((results || []).map(toGearSearchItem));
}
