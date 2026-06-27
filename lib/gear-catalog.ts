import { createSupabaseServerClient } from "@/lib/supabase/server";

export type GearLookupType =
  | "guitar"
  | "acoustic_guitar"
  | "bass_guitar"
  | "amp"
  | "bass_amp"
  | "cabinet"
  | "pedal"
  | "pickup"
  | "multi_fx"
  | "effect";

export type GearCatalogItem = {
  id: string;
  name: string;
  description: string;
  category: string;
  itemType: string;
  brand: string;
  model: string;
  details: string[];
  sourceUrls: string[];
};

type LookupOptions = {
  limit?: number;
  instrumentType?: "guitar" | "bass" | "acoustic" | "both";
};

export async function lookupGearFromSupabase(itemTypes: GearLookupType[], query: string, options: LookupOptions = {}) {
  const supabase = await createSupabaseServerClient();
  if (!supabase) {
    return null;
  }

  const normalized = query.trim();
  const limit = Math.min(Math.max(options.limit || 24, 1), 120);
  let builder = supabase
    .from("gear_items")
    .select("id, brand, model, item_type, category, instrument_type, pickup_type, amp_type, gain_range, voicing_tags, notable_use_cases, source_urls")
    .eq("is_active", true)
    .in("item_type", itemTypes)
    .order("brand", { ascending: true })
    .order("model", { ascending: true })
    .limit(limit);

  if (options.instrumentType) {
    builder = builder.eq("instrument_type", options.instrumentType);
  }

  if (normalized) {
    builder = builder.or(`search_text.ilike.%${escapeIlike(normalized)}%,model.ilike.%${escapeIlike(normalized)}%,brand.ilike.%${escapeIlike(normalized)}%`);
  }

  const { data, error } = await builder;
  if (error) {
    return null;
  }

  return (data || []).map(formatGearItem);
}

function formatGearItem(item: {
  id: string;
  brand: string;
  model: string;
  item_type: string;
  category: string | null;
  instrument_type: string | null;
  pickup_type: string | null;
  amp_type: string | null;
  gain_range: string | null;
  voicing_tags: string[] | null;
  notable_use_cases: string[] | null;
  source_urls: string[] | null;
}) {
  const details = [
    item.category,
    item.instrument_type && item.instrument_type !== "both" ? item.instrument_type : null,
    item.pickup_type,
    item.amp_type,
    item.gain_range,
    ...(item.voicing_tags || []).slice(0, 4),
    ...(item.notable_use_cases || []).slice(0, 2)
  ].filter(Boolean) as string[];

  return {
    id: item.id,
    name: `${item.brand} ${item.model}`,
    description: details.join(" | "),
    category: item.category || item.item_type,
    itemType: item.item_type,
    brand: item.brand,
    model: item.model,
    details,
    sourceUrls: item.source_urls || []
  };
}

function escapeIlike(value: string) {
  return value.replaceAll("%", "\\%").replaceAll("_", "\\_");
}
