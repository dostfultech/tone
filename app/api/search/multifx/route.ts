import { NextRequest } from "next/server";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { escapeLike, extractJoinedBrandName, normalizeQuery, resultsResponse } from "../_shared";

export const dynamic = "force-dynamic";

export async function GET(request: NextRequest) {
  const query = normalizeQuery(request.nextUrl.searchParams.get("q"));
  const limit = normalizeLimit(request.nextUrl.searchParams.get("limit"));
  const supabase = (await createSupabaseServerClient())!;

  let builder = supabase
    .from("multifx_models")
    .select("id, name, category, tags, brand:multifx_brands!brand_id(name)")
    .eq("is_active", true)
    .order("name", { ascending: true })
    .limit(limit);

  if (query) {
    const escaped = escapeLike(query);
    builder = builder.or(`search_text.ilike.%${escaped}%,name.ilike.%${escaped}%,category.ilike.%${escaped}%`);
  }

  const { data } = await builder;
  const results = (Array.isArray(data) ? data : []).map((row) => {
    const brandName = extractJoinedBrandName(row.brand);
    const modelName = String(row.name ?? "");
    return {
      modelId: String(row.id),
      brandName,
      modelName,
      name: `${brandName} ${modelName}`.trim(),
      category: String(row.category ?? "multi-fx"),
      tags: Array.isArray(row.tags) ? row.tags.filter((tag): tag is string => typeof tag === "string") : [],
      pickupConfiguration: null,
      ampType: null,
      pedalType: null
    };
  });

  return resultsResponse(results);
}

function normalizeLimit(value: string | null) {
  const parsed = Number(value ?? "200");
  if (!Number.isFinite(parsed) || parsed <= 0) {
    return 200;
  }
  return Math.min(Math.trunc(parsed), 200);
}
