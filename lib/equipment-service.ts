import type { SupabaseClient } from "@supabase/supabase-js";
import type { GearSearchItem } from "@/lib/my-gear";

type SupabaseQuery = any;
type RowRecord = Record<string, unknown>;

type EquipmentTableKind = "guitar" | "amp" | "pedal" | "multifx" | "pickup" | "cabinet";
type InstrumentFilter = "guitar" | "bass" | "acoustic" | "both";

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

type EquipmentTableConfig = {
  table: string;
  select: string;
  defaultCategory: string;
  defaultItemType: string;
  nameColumns: string[];
  searchColumns: string[];
  brandIdColumn: string;
  instrumentColumn?: string;
  brandTable?: string;
};

const MAX_LIMIT = 120;
const DEFAULT_LIMIT = 24;

const EQUIPMENT_TABLES: Record<EquipmentTableKind, EquipmentTableConfig> = {
  guitar: {
    table: "guitar_models",
    select: "id, brand_id, name, model_name, category, pickup_configuration, tags, instrument_type, brand:guitar_brands!brand_id(name)",
    defaultCategory: "guitar",
    defaultItemType: "guitar",
    nameColumns: ["name", "model_name"],
    searchColumns: ["search_text", "name", "model_name"],
    brandIdColumn: "brand_id",
    instrumentColumn: "instrument_type",
    brandTable: "guitar_brands"
  },
  amp: {
    table: "amp_models",
    select: "id, brand_id, name, model_name, category, amp_type, tags, instrument_type, brand:amp_brands!brand_id(name)",
    defaultCategory: "amp",
    defaultItemType: "amp",
    nameColumns: ["name", "model_name"],
    searchColumns: ["search_text", "name", "model_name"],
    brandIdColumn: "brand_id",
    instrumentColumn: "instrument_type",
    brandTable: "amp_brands"
  },
  pedal: {
    table: "pedal_models",
    select: "id, brand_id, name, model_name, category, pedal_type, tags, brand:pedal_brands!brand_id(name)",
    defaultCategory: "pedal",
    defaultItemType: "pedal",
    nameColumns: ["name", "model_name"],
    searchColumns: ["search_text", "name", "model_name"],
    brandIdColumn: "brand_id",
    brandTable: "pedal_brands"
  },
  multifx: {
    table: "multifx_models",
    select: "id, brand_id, name, category, tags, brand:multifx_brands!brand_id(name)",
    defaultCategory: "multi-fx",
    defaultItemType: "multi_fx",
    nameColumns: ["name"],
    searchColumns: ["search_text", "name"],
    brandIdColumn: "brand_id",
    brandTable: "multifx_brands"
  },
  pickup: {
    table: "pickup_models",
    select: "id, manufacturer_id, model_name, pickup_type_id, search_text, manufacturer:equipment_manufacturers!manufacturer_id(name)",
    defaultCategory: "pickup",
    defaultItemType: "pickup",
    nameColumns: ["model_name"],
    searchColumns: ["search_text", "model_name"],
    brandIdColumn: "manufacturer_id"
  },
  cabinet: {
    table: "cabinet_models",
    select: "id, manufacturer_id, model_name, back_type, search_text, manufacturer:equipment_manufacturers!manufacturer_id(name)",
    defaultCategory: "cabinet",
    defaultItemType: "cabinet",
    nameColumns: ["model_name"],
    searchColumns: ["search_text", "model_name"],
    brandIdColumn: "manufacturer_id"
  }
};

export async function searchEquipmentModels(
  supabase: SupabaseClient | null,
  kind: EquipmentTableKind,
  options: EquipmentSearchOptions = {}
): Promise<EquipmentModelItem[] | null> {
  if (!supabase) {
    return null;
  }

  const config = EQUIPMENT_TABLES[kind];
  const query = normalizeQuery(options.query);
  const limit = normalizeLimit(options.limit);
  let builder: SupabaseQuery = supabase
    .from(config.table)
    .select(config.select)
    .eq("is_active", true)
    .order(config.nameColumns[0], { ascending: true })
    .limit(limit);

  if (options.brandId) {
    builder = builder.eq(config.brandIdColumn, options.brandId);
  }

  if (options.instrumentType && config.instrumentColumn) {
    builder = builder.eq(config.instrumentColumn, options.instrumentType);
  }

  if (query) {
    const escaped = escapeLike(query);
    const filters = Array.from(new Set(config.searchColumns)).map((column) => `${column}.ilike.%${escaped}%`);
    builder = builder.or(filters.join(","));
  }

  const { data, error } = await builder;
  if (error) {
    return [];
  }

  const rows = Array.isArray(data) ? (data as RowRecord[]) : [];
  return rows.map((row) => toEquipmentModelItem(kind, row));
}

export async function listEquipmentBrands(
  supabase: SupabaseClient | null,
  kind: Extract<EquipmentTableKind, "guitar" | "amp" | "pedal" | "multifx">,
  options: EquipmentBrandOptions = {}
): Promise<EquipmentBrand[] | null> {
  if (!supabase) {
    return null;
  }

  const config = EQUIPMENT_TABLES[kind];
  if (!config.brandTable) {
    return [];
  }

  const query = normalizeQuery(options.query);
  const limit = normalizeLimit(options.limit, 60);
  let builder: SupabaseQuery = supabase
    .from(config.brandTable)
    .select("id, name, slug")
    .eq("is_active", true)
    .order("name", { ascending: true })
    .limit(limit);

  if (query) {
    const escaped = escapeLike(query);
    builder = builder.or(`search_text.ilike.%${escaped}%,name.ilike.%${escaped}%`);
  }

  const { data, error } = await builder;
  if (error) {
    return [];
  }

  const rows = Array.isArray(data) ? (data as RowRecord[]) : [];
  return rows.map((row) => ({
    id: asString(row.id),
    name: asString(row.name, "Unknown"),
    slug: asString(row.slug)
  }));
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
    item.instrumentType && item.instrumentType !== "both" ? item.instrumentType : null,
    item.pickupConfiguration,
    item.ampType,
    item.pedalType,
    ...item.tags.slice(0, 4)
  ].filter((value): value is string => Boolean(value));

  return {
    id: item.id,
    name: item.displayName,
    description: details.join(" | "),
    category: item.category,
    itemType: EQUIPMENT_TABLES[item.kind].defaultItemType,
    details
  };
}

function toEquipmentModelItem(kind: EquipmentTableKind, row: RowRecord): EquipmentModelItem {
  const config = EQUIPMENT_TABLES[kind];
  const brandName = extractJoinedName(row.brand) || extractJoinedName(row.manufacturer) || "Unknown";
  const modelName = firstNonEmpty(row, config.nameColumns) || "Unknown";
  const category = asString(row.category, config.defaultCategory);

  return {
    id: asString(row.id),
    kind,
    brandId: nullableString(row[config.brandIdColumn]),
    brandName,
    modelName,
    displayName: `${brandName} ${modelName}`.trim(),
    category,
    tags: asStringArray(row.tags),
    pickupConfiguration: nullableString(row.pickup_configuration),
    ampType: nullableString(row.amp_type),
    pedalType: nullableString(row.pedal_type) || nullableString(row.pedal_type_id),
    instrumentType: nullableString(row.instrument_type)
  };
}

function extractJoinedName(value: unknown) {
  if (Array.isArray(value)) {
    return extractJoinedName(value[0]);
  }

  if (value && typeof value === "object") {
    const record = value as RowRecord;
    return nullableString(record.name);
  }

  return null;
}

function firstNonEmpty(row: RowRecord, keys: string[]) {
  for (const key of keys) {
    const next = nullableString(row[key]);
    if (next) {
      return next;
    }
  }

  return null;
}

function normalizeQuery(value: string | undefined) {
  return (value || "").trim().slice(0, 80);
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

function asString(value: unknown, fallback = "") {
  return typeof value === "string" ? value : fallback;
}

function nullableString(value: unknown) {
  return typeof value === "string" && value.trim().length > 0 ? value.trim() : null;
}

function asStringArray(value: unknown) {
  if (!Array.isArray(value)) {
    return [];
  }

  return value.filter((item): item is string => typeof item === "string" && item.length > 0);
}
