import { NextRequest } from "next/server";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { searchEquipmentModels, toGearSearchItem } from "@/lib/equipment-service";
import { normalizeQuery, resultsResponse } from "../_shared";

export const dynamic = "force-dynamic";

export async function GET(request: NextRequest) {
  const query = normalizeQuery(request.nextUrl.searchParams.get("q"));
  const limit = Number(request.nextUrl.searchParams.get("limit") || "200");
  const instrumentType = normalizeInstrumentType(request.nextUrl.searchParams.get("instrumentType"));
  const supabase = await createSupabaseServerClient();

  const results = await searchEquipmentModels(supabase, "guitar", {
    query,
    limit,
    instrumentType
  });

  return resultsResponse((results || []).map(toGearSearchItem));
}

function normalizeInstrumentType(value: string | null) {
  if (value === "guitar" || value === "bass" || value === "acoustic" || value === "both") {
    return value;
  }

  return undefined;
}
