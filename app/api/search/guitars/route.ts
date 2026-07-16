import { NextRequest } from "next/server";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import type { GearSearchItem } from "@/lib/my-gear";
import { escapeLike, extractJoinedBrandName, normalizeQuery, resultsResponse } from "../_shared";

export const dynamic = "force-dynamic";

export async function GET(request: NextRequest) {
  const query = normalizeQuery(request.nextUrl.searchParams.get("q"));
  const supabase = await createSupabaseServerClient();

  if (!supabase) {
    return resultsResponse([]);
  }

  let builder = supabase
    .from("guitar_models")
    .select("id, name, category, pickup_configuration, tags, brand:guitar_brands!brand_id(name)")
    .eq("is_active", true)
    .limit(20)
    .order("name", { ascending: true });

  if (query) {
    const escaped = escapeLike(query);
    builder = builder.or(`search_text.ilike.%${escaped}%,name.ilike.%${escaped}%`);
  }

  const { data, error } = await builder;
  if (error) {
    return resultsResponse([]);
  }

  const rows = Array.isArray(data) ? (data as Array<Record<string, unknown>>) : [];

  const results: GearSearchItem[] = rows.map((row) => {
    const brandName = extractJoinedBrandName(row.brand);
    const modelName = typeof row.name === "string" && row.name.trim() ? row.name : "Unknown";

    return {
      modelId: String(row.id || ""),
      brandName,
      modelName,
      name: `${brandName} ${modelName}`.trim(),
      category: typeof row.category === "string" ? row.category : "guitar",
      tags: Array.isArray(row.tags) ? row.tags.filter((item): item is string => typeof item === "string") : [],
      pickupConfiguration: typeof row.pickup_configuration === "string" ? row.pickup_configuration : null,
      ampType: null,
      pedalType: null
    };
  });

  return resultsResponse(results);
}
