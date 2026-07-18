import { NextRequest, NextResponse } from "next/server";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { searchEquipmentModels, searchMultiFxModels, searchPedalModels, toGearSearchItem } from "@/lib/equipment-service";

export const dynamic = "force-dynamic";

const ALLOWED_TYPES = new Set(["guitar", "amp", "pedal", "multifx"]);

export async function GET(request: NextRequest) {
  const equipmentType = (request.nextUrl.searchParams.get("type") || "").trim().toLowerCase();
  if (!ALLOWED_TYPES.has(equipmentType)) {
    return NextResponse.json({ results: [] }, { status: 400 });
  }

  const query = request.nextUrl.searchParams.get("q") || "";
  const limit = Number(request.nextUrl.searchParams.get("limit") || "24");
  const brandId = request.nextUrl.searchParams.get("brandId") || undefined;
  const instrumentType = normalizeInstrumentType(request.nextUrl.searchParams.get("instrumentType"));
  const supabase = await createSupabaseServerClient();

  if (equipmentType === "pedal") {
    const results = await searchPedalModels(supabase, { query, limit, brandId });
    return NextResponse.json({ results: results || [] });
  }

  if (equipmentType === "multifx") {
    const results = await searchMultiFxModels(supabase, { query, limit, brandId });
    return NextResponse.json({ results: results || [] });
  }

  const results = await searchEquipmentModels(supabase, equipmentType as "guitar" | "amp", {
    query,
    limit,
    brandId,
    instrumentType
  });

  return NextResponse.json({ results: (results || []).map(toGearSearchItem) });
}

function normalizeInstrumentType(value: string | null) {
  if (value === "guitar" || value === "bass" || value === "acoustic" || value === "both") {
    return value;
  }

  return undefined;
}
