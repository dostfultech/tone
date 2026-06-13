import { createSupabaseServerClient } from "@/lib/supabase/server";

type GearLookupType = "guitar" | "bass_guitar" | "amp" | "bass_amp" | "pedal" | "pickup" | "multi_fx";

export async function lookupGearFromSupabase(itemTypes: GearLookupType[], query: string) {
  const supabase = await createSupabaseServerClient();
  if (!supabase) {
    return null;
  }

  const normalized = query.trim();
  let builder = supabase
    .from("gear_items")
    .select("id, brand, model, item_type, category, pickup_type, amp_type, gain_range, voicing_tags, notable_use_cases, source_urls")
    .eq("is_active", true)
    .in("item_type", itemTypes)
    .limit(10);

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
  pickup_type: string | null;
  amp_type: string | null;
  gain_range: string | null;
  voicing_tags: string[] | null;
  notable_use_cases: string[] | null;
  source_urls: string[] | null;
}) {
  const details = [item.category, item.pickup_type, item.amp_type, item.gain_range, ...(item.voicing_tags || []).slice(0, 4)].filter(Boolean);
  return {
    id: item.id,
    name: `${item.brand} ${item.model}`,
    description: details.join(" | "),
    category: item.item_type,
    sourceUrls: item.source_urls || []
  };
}

function escapeIlike(value: string) {
  return value.replaceAll("%", "\\%").replaceAll("_", "\\_");
}
