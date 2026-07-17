import { NextRequest } from "next/server";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { escapeLike, extractJoinedBrandName, normalizeQuery, resultsResponse } from "../_shared";

export const dynamic = "force-dynamic";

export async function GET(request: NextRequest) {
  const query = normalizeQuery(request.nextUrl.searchParams.get("q"));
  const limit = normalizeLimit(request.nextUrl.searchParams.get("limit"));
  const supabase = (await createSupabaseServerClient())!;

  let builder = supabase
    .from("pedal_models")
    .select("id, name, model_name, category, tags, pedal_type, brand:pedal_brands!brand_id(name)")
    .eq("is_active", true)
    .order("brand_id", { ascending: true })
    .order("name", { ascending: true })
    .limit(limit);

  if (query) {
    const escaped = escapeLike(query);
    builder = builder.or(`search_text.ilike.%${escaped}%,name.ilike.%${escaped}%,model_name.ilike.%${escaped}%`);
  }

  const { data } = await builder;
  const results = (Array.isArray(data) ? data : []).map((row) => ({
    modelId: String(row.id),
    brandName: extractJoinedBrandName(row.brand),
    modelName: String(row.model_name ?? row.name ?? ""),
    name: `${extractJoinedBrandName(row.brand)} ${String(row.model_name ?? row.name ?? "")}`.trim(),
    category: String(row.category ?? row.pedal_type ?? "pedal"),
    tags: Array.isArray(row.tags) ? row.tags.filter((tag): tag is string => typeof tag === "string") : [],
    pickupConfiguration: null,
    ampType: null,
    pedalType: typeof row.pedal_type === "string" ? row.pedal_type : null
  }));

  return resultsResponse(results);
}

function normalizeLimit(value: string | null) {
  const parsed = Number(value ?? "200");
  if (!Number.isFinite(parsed) || parsed <= 0) {
    return 200;
  }
  return Math.min(Math.trunc(parsed), 200);
}
