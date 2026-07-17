import { NextRequest, NextResponse } from "next/server";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { listEquipmentBrands } from "@/lib/equipment-service";

export const dynamic = "force-dynamic";

const ALLOWED_TYPES = new Set(["guitar", "amp", "pedal", "multifx"]);

export async function GET(request: NextRequest) {
  const equipmentType = (request.nextUrl.searchParams.get("type") || "").trim().toLowerCase();
  if (!ALLOWED_TYPES.has(equipmentType)) {
    return NextResponse.json({ results: [] }, { status: 400 });
  }

  const query = request.nextUrl.searchParams.get("q") || "";
  const limit = Number(request.nextUrl.searchParams.get("limit") || "60");
  const supabase = await createSupabaseServerClient();

  const results = await listEquipmentBrands(supabase, equipmentType as "guitar" | "amp" | "pedal" | "multifx", {
    query,
    limit
  });

  return NextResponse.json({ results: results || [] });
}
