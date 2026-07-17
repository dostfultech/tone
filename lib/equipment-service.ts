import type { SupabaseClient } from "@supabase/supabase-js";
import type { GearSearchItem } from "@/lib/my-gear";

type SupabaseQuery = any;
type RowRecord = Record<string, unknown>;

type EquipmentTableKind = "guitar" | "amp";
type InstrumentFilter = "guitar" | "bass" | "acoustic" | "both";
type MasterEquipmentType = "electric_guitar" | "bass_guitar" | "guitar_amp" | "bass_amp";

type EquipmentSearchOptions = {
  query?: string;
  limit?: number;
  brandId?: string;
  instrumentType?: InstrumentFilter;
};

type EquipmentBrand = {
  id: string;
  name: string;
  slug: string;
};

type EquipmentBrandOptions = {
  query?: string;
  limit?: number;
};

export type EquipmentModelItem = {
  id: string;
  kind: EquipmentTableKind;
  equipmentType: MasterEquipmentType;
  brandId: string | null;
  brandName: string;
  modelName: string;
  displayName: string;
  category: string;
  tags: string[];
  pickupConfiguration: string | null;
  ampType: string | null;
  pedalType: string | null;
  instrumentType: string | null;
};

const MAX_LIMIT = 1000;
const DEFAULT_LIMIT = 24;

export async function searchEquipmentModels(
  supabase: SupabaseClient | null,
  kind: EquipmentTableKind,
  options: EquipmentSearchOptions = {}
): Promise<EquipmentModelItem[] | null> {
  if (!supabase) {
    return null;
  }

  const equipmentTypes = resolveEquipmentTypes(kind, options.instrumentType);
  if (!equipmentTypes.length) {
    return [];
  }

  const query = normalizeQuery(options.query);
  const tokens = tokenizeQuery(query);
  const limit = normalizeLimit(options.limit);
  const fetchLimit = normalizeLimit(tokens.length > 1 ? Math.min(limit * 4, MAX_LIMIT) : limit, limit);

  let builder: SupabaseQuery = supabase
    .from("equipment")
    .select("id, equipment_type, brand, brand_slug, model, series, display_name, description, is_popular, search_terms, pickup_configuration, amp_type, tone_characteristics, status, sort_order")
    .eq("status", "active")
    .in("equipment_type", equipmentTypes)
    .order("is_popular", { ascending: false })
    .order("sort_order", { ascending: true })
    .order("brand", { ascending: true })
    .order("model", { ascending: true })
    .limit(fetchLimit);

  if (options.brandId) {
    builder = builder.eq("brand_slug", slugify(options.brandId));
  }

  if (query) {
    const filters = buildSearchFilters(["search_text", "display_name", "brand", "model", "series"], query, tokens);
    builder = builder.or(filters.join(","));
  }

  const { data, error } = await builder;
  if (error) {
    return [];
  }

  const rows = Array.isArray(data) ? (data as RowRecord[]) : [];
  const mapped = rows.map((row) => toEquipmentModelItem(kind, row));
  return rankAndLimitEquipmentResults(mapped, query, limit);
}

export async function listEquipmentBrands(
  supabase: SupabaseClient | null,
  kind: EquipmentTableKind,
  options: EquipmentBrandOptions = {}
): Promise<EquipmentBrand[] | null> {
  if (!supabase) {
    return null;
  }

  const equipmentTypes = resolveEquipmentTypes(kind, undefined);
  if (!equipmentTypes.length) {
    return [];
  }

  const query = normalizeQuery(options.query);
  const limit = normalizeLimit(options.limit, 60);

  let builder: SupabaseQuery = supabase
    .from("equipment")
    .select("brand, brand_slug")
    .eq("status", "active")
    .in("equipment_type", equipmentTypes)
    .order("brand", { ascending: true })
    .limit(Math.min(limit * 10, MAX_LIMIT));

  if (query) {
    const escaped = escapeLike(query);
    builder = builder.or(`brand.ilike.%${escaped}%,brand_slug.ilike.%${escaped}%`);
  }

  const { data, error } = await builder;
  if (error) {
    return [];
  }

  const rows = Array.isArray(data) ? (data as RowRecord[]) : [];
  const seen = new Set<string>();
  const results: EquipmentBrand[] = [];

  for (const row of rows) {
    const name = asString(row.brand);
    const slug = asString(row.brand_slug) || slugify(name);
    const key = slug.toLowerCase();
    if (!name || seen.has(key)) {
      continue;
    }

    seen.add(key);
    results.push({ id: slug, name, slug });

    if (results.length >= limit) {
      break;
    }
  }

  return results;
}

export function toGearSearchItem(item: EquipmentModelItem): GearSearchItem {
  return {
    modelId: item.id,
    brandName: item.brandName,
    modelName: item.modelName,
    name: item.displayName,
    category: item.category,
    tags: item.tags,
    pickupConfiguration: item.pickupConfiguration,
    ampType: item.ampType,
    pedalType: item.pedalType
  };
}

export function toCatalogItem(item: EquipmentModelItem) {
  const details = [
    item.category,
    item.instrumentType,
    item.pickupConfiguration,
    item.ampType,
    ...item.tags.slice(0, 4)
  ].filter((value): value is string => Boolean(value));

  return {
    id: item.id,
    name: item.displayName,
    description: details.join(" | "),
    category: item.category,
    itemType: item.category,
    details
  };
}

function resolveEquipmentTypes(kind: EquipmentTableKind, instrumentType?: InstrumentFilter): MasterEquipmentType[] {
  if (kind === "guitar") {
    if (instrumentType === "bass") {
      return ["bass_guitar"];
    }

    if (instrumentType === "acoustic") {
      return [];
    }

    if (instrumentType === "both") {
      return ["electric_guitar", "bass_guitar"];
    }

    return ["electric_guitar"];
  }

  if (kind === "amp") {
    if (instrumentType === "bass") {
      return ["bass_amp"];
    }

    if (instrumentType === "both") {
      return ["guitar_amp", "bass_amp"];
    }

    return ["guitar_amp"];
  }

  return [];
}

function toEquipmentModelItem(kind: EquipmentTableKind, row: RowRecord): EquipmentModelItem {
  const equipmentType = asEquipmentType(row.equipment_type);
  const brandName = asString(row.brand, "Unknown");
  const modelName = asString(row.model, "Unknown");
  const displayName = asString(row.display_name, `${brandName} ${modelName}`.trim());
  const category = categoryFromEquipmentType(equipmentType);

  return {
    id: asString(row.id),
    kind,
    equipmentType,
    brandId: asString(row.brand_slug) || null,
    brandName,
    modelName,
    displayName,
    category,
    tags: asStringArray(row.tone_characteristics),
    pickupConfiguration: nullableString(row.pickup_configuration),
    ampType: nullableString(row.amp_type),
    pedalType: null,
    instrumentType: instrumentLabelFromEquipmentType(equipmentType)
  };
}

function buildSearchFilters(columns: string[], rawQuery: string, tokens: string[]) {
  const escapedRaw = escapeLike(rawQuery);
  const filters = new Set<string>();

  for (const column of Array.from(new Set(columns))) {
    filters.add(`${column}.ilike.%${escapedRaw}%`);
  }

  for (const token of tokens) {
    const escapedToken = escapeLike(token);
    for (const column of Array.from(new Set(columns))) {
      filters.add(`${column}.ilike.%${escapedToken}%`);
    }
  }

  return Array.from(filters);
}

function rankAndLimitEquipmentResults(items: EquipmentModelItem[], query: string, limit: number) {
  if (!query) {
    return items.slice(0, limit);
  }

  const loweredQuery = query.toLowerCase();
  const tokens = tokenizeQuery(query);

  return items
    .map((item) => ({ item, score: scoreEquipmentItem(item, loweredQuery, tokens) }))
    .filter((entry) => entry.score >= 0)
    .sort((left, right) => {
      if (right.score !== left.score) {
        return right.score - left.score;
      }
      return left.item.displayName.localeCompare(right.item.displayName);
    })
    .slice(0, limit)
    .map((entry) => entry.item);
}

function scoreEquipmentItem(item: EquipmentModelItem, loweredQuery: string, tokens: string[]) {
  const displayName = item.displayName.toLowerCase();
  const haystack = `${item.displayName} ${item.brandName} ${item.modelName} ${item.tags.join(" ")}`.toLowerCase();

  let score = 0;
  if (displayName === loweredQuery) {
    score += 220;
  }
  if (displayName.startsWith(loweredQuery)) {
    score += 160;
  }
  if (displayName.includes(loweredQuery)) {
    score += 120;
  }

  if (!tokens.length) {
    return score;
  }

  const tokenMatches = tokens.filter((token) => haystack.includes(token));
  if (!tokenMatches.length) {
    return -1;
  }

  score += tokenMatches.length * 30;

  if (tokenMatches.length === tokens.length) {
    score += 40;
  }

  if (item.equipmentType === "electric_guitar" || item.equipmentType === "guitar_amp") {
    score += 8;
  }

  return score;
}

function tokenizeQuery(query: string) {
  const STOP_WORDS = new Set(["the", "with", "and", "for", "a", "an", "to", "of", "my", "in", "on", "at"]);

  return Array.from(
    new Set(
      query
        .toLowerCase()
        .split(/[^a-z0-9]+/)
        .map((token) => token.trim())
        .filter((token) => token.length >= 2 && !STOP_WORDS.has(token))
    )
  );
}

function categoryFromEquipmentType(equipmentType: MasterEquipmentType) {
  if (equipmentType === "electric_guitar") return "guitar";
  if (equipmentType === "bass_guitar") return "bass_guitar";
  if (equipmentType === "guitar_amp") return "amp";
  return "bass_amp";
}

function instrumentLabelFromEquipmentType(equipmentType: MasterEquipmentType) {
  return equipmentType.startsWith("bass") ? "bass" : "guitar";
}

function asEquipmentType(value: unknown): MasterEquipmentType {
  if (value === "electric_guitar" || value === "bass_guitar" || value === "guitar_amp" || value === "bass_amp") {
    return value;
  }
  return "electric_guitar";
}

function normalizeQuery(value: string | undefined) {
  return (value || "").trim().slice(0, 120);
}

function normalizeLimit(value: number | undefined, fallback = DEFAULT_LIMIT) {
  const numeric = Number(value);
  if (!Number.isFinite(numeric) || numeric <= 0) {
    return fallback;
  }
  return Math.min(Math.max(Math.trunc(numeric), 1), MAX_LIMIT);
}

function escapeLike(value: string) {
  return value.replaceAll("%", "\\%").replaceAll("_", "\\_");
}

function slugify(value: string) {
  return value
    .trim()
    .toLowerCase()
    .replace(/&/g, " and ")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

function asString(value: unknown, fallback = "") {
  return typeof value === "string" ? value.trim() : fallback;
}

function nullableString(value: unknown) {
  return typeof value === "string" && value.trim().length > 0 ? value.trim() : null;
}

function asStringArray(value: unknown) {
  if (!Array.isArray(value)) {
    return [];
  }

  return value
    .filter((item): item is string => typeof item === "string")
    .map((item) => item.trim())
    .filter((item) => item.length > 0);
}
