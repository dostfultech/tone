import type { SupabaseClient } from "@supabase/supabase-js";
import type {
  AmplifierProfileInput,
  CabinetProfileInput,
  GuitarProfileInput,
  MultiFxProfileInput,
  PedalProfileInput,
  PickupPosition,
  PickupProfileInput
} from "../../../rule-engine";
import type { NormalizedSelection, ToneAdaptationMode } from "../dtos";
import { repositoryError } from "../errors";
import { mapAmpRow, mapCabinetRow, mapGuitarRow, mapMultiFxRow, mapPedalRow, mapPickupRow } from "../mappers";

type SupabaseQuery = any;

// Behavior tables whose match phrases live in a `tags` text[] column (folded into
// search_text by a trigger). For these, an exact tag-array match is preferred over
// a search_text substring so a base model doesn't lose to a longer variant's tag.
const TAG_MATCH_TABLES = new Set(["guitar_models", "amp_models"]);

export interface GearRepository {
  findGuitar(selection: NormalizedSelection | undefined, mode: ToneAdaptationMode): Promise<GuitarProfileInput | null>;
  findPickups(selections: NormalizedSelection[], guitarId?: string): Promise<PickupProfileInput[]>;
  findAmplifier(selection: NormalizedSelection | undefined, mode: ToneAdaptationMode): Promise<AmplifierProfileInput | null>;
  findCabinet(selection: NormalizedSelection | undefined): Promise<CabinetProfileInput | null>;
  findPedals(selections: NormalizedSelection[]): Promise<PedalProfileInput[]>;
  findMultiFx(selection: NormalizedSelection | undefined): Promise<MultiFxProfileInput | null>;
}

export class SupabaseGearRepository implements GearRepository {
  constructor(private readonly supabase: SupabaseClient) {}

  async findGuitar(selection: NormalizedSelection | undefined, mode: ToneAdaptationMode) {
    const row = await this.findEquipmentRow("guitar_models", selection, (query) =>
      query
        .select("*, equipment_manufacturers(name)")
        .eq("instrument_type", mode)
        .eq("is_active", true)
    );
    return row ? mapGuitarRow(row) : null;
  }

  async findPickups(selections: NormalizedSelection[], guitarId?: string) {
    if (selections.length > 0) {
      const pickups = await Promise.all(
        selections.map(async (selection, index) => {
          const row = await this.findEquipmentRow("pickup_models", selection, (query) =>
            query.select("*, equipment_manufacturers(name)").eq("is_active", true)
          );
          return row ? mapPickupRow(row, selection.position ?? positionByIndex(index)) : null;
        })
      );
      return pickups.filter((pickup): pickup is PickupProfileInput => pickup !== null);
    }

    if (!guitarId) {
      return [];
    }

    const { data, error } = await this.supabase
      .from("guitar_model_pickups")
      .select("pickup_position, pickup_models(*, equipment_manufacturers(name))")
      .eq("guitar_model_id", guitarId)
      .eq("is_active", true);

    if (error) {
      throw repositoryError("Failed to load stock pickups for guitar.", { error: error.message });
    }

    return (data ?? [])
      .map((row) => {
        const pickupRow = nestedRecord(row.pickup_models);
        return pickupRow ? mapPickupRow(pickupRow, pickupPosition(row.pickup_position)) : null;
      })
      .filter((pickup): pickup is PickupProfileInput => pickup !== null);
  }

  async findAmplifier(selection: NormalizedSelection | undefined, mode: ToneAdaptationMode) {
    const row = await this.findEquipmentRow("amp_models", selection, (query) =>
      query
        .select("*, equipment_manufacturers(name)")
        .in("instrument_type", [mode, "both"])
        .eq("is_active", true)
    );
    return row ? mapAmpRow(row) : null;
  }

  async findCabinet(selection: NormalizedSelection | undefined) {
    const row = await this.findEquipmentRow("cabinet_models", selection, (query) =>
      query.select("*, equipment_manufacturers(name)").eq("is_active", true)
    );
    return row ? mapCabinetRow(row) : null;
  }

  async findPedals(selections: NormalizedSelection[]) {
    const pedals = await Promise.all(
      selections.map(async (selection, index) => {
        const row = await this.findEquipmentRow("pedal_models", selection, (query) =>
          query.select("*, equipment_manufacturers(name)").eq("is_active", true)
        );
        return row ? mapPedalRow(row, selection.order ?? index + 1) : null;
      })
    );
    return pedals.filter((pedal): pedal is PedalProfileInput => pedal !== null);
  }

  async findMultiFx(selection: NormalizedSelection | undefined) {
    const canonicalRow = await this.findCanonicalMultiFxRow(selection);
    if (canonicalRow) {
      return mapMultiFxRow(canonicalRow, [], [], []);
    }

    const row = await this.findEquipmentRow("multifx_devices", selection, (query) =>
      query.select("*, equipment_manufacturers(name)").eq("is_active", true)
    );

    if (!row) {
      return null;
    }

    const [ampModels, cabModels, effects] = await Promise.all([
      this.findMultiFxNames("multifx_amp_models", "model_name", row.id),
      this.findMultiFxNames("multifx_cab_models", "model_name", row.id),
      this.findMultiFxNames("multifx_effects", "effect_name", row.id)
    ]);

    return mapMultiFxRow(row, ampModels, cabModels, effects);
  }

  private async findCanonicalMultiFxRow(selection: NormalizedSelection | undefined) {
    if (!selection?.id && !selection?.name) {
      return null;
    }

    if (selection.id) {
      const { data, error } = await this.supabase
        .from("multifx_models")
        .select("id, name, category, tags, brand:multifx_brands!brand_id(name)")
        .eq("id", selection.id)
        .eq("is_active", true)
        .limit(1)
        .maybeSingle();

      if (error) {
        throw repositoryError("Failed to query multifx_models.", { error: error.message });
      }

      if (data) {
        return data as Record<string, unknown>;
      }
    }

    const name = selection.name || "";
    if (!name) {
      return null;
    }

    const bySearchText = await this.queryCanonicalMultiFxByName(name, "search_text");
    if (bySearchText) {
      return bySearchText;
    }

    return this.queryCanonicalMultiFxByName(name, "name");
  }

  private async queryCanonicalMultiFxByName(name: string, columnName: "search_text" | "name") {
    const { data, error } = await this.supabase
      .from("multifx_models")
      .select("id, name, category, tags, brand:multifx_brands!brand_id(name)")
      .ilike(columnName, `%${name}%`)
      .eq("is_active", true)
      .order("name", { ascending: true })
      .limit(1)
      .maybeSingle();

    if (error) {
      throw repositoryError("Failed to query multifx_models.", { error: error.message, columnName });
    }

    return (data ?? null) as Record<string, unknown> | null;
  }

  private async findEquipmentRow(
    tableName: string,
    selection: NormalizedSelection | undefined,
    baseQuery: (query: SupabaseQuery) => SupabaseQuery
  ) {
    if (!selection?.id && !selection?.name) {
      return null;
    }

    if (selection.id) {
      const query = baseQuery(this.supabase.from(tableName));
      const { data, error } = await query.eq("id", selection.id).order("model_name", { ascending: true }).limit(1).maybeSingle();

      if (error) {
        throw repositoryError(`Failed to query ${tableName}.`, { error: error.message });
      }

      return (data ?? null) as Record<string, unknown> | null;
    }

    // Prefer an exact tag match on the tags-based behavior tables (guitar_models,
    // amp_models): a family whose `tags` array contains the picker display name as
    // a whole element is a precise hit, so a base model ("Harley Benton ST-20")
    // no longer loses a substring race to a longer variant's tag in another family
    // ("...st-20 hss"). Falls through to the substring search when no exact tag.
    if (TAG_MATCH_TABLES.has(tableName)) {
      const byExactTag = await this.queryEquipmentExactTag(tableName, selection.name ?? "", baseQuery);
      if (byExactTag) {
        return byExactTag;
      }
    }

    const bySearchText = await this.queryEquipmentName(tableName, selection.name ?? "", "search_text", baseQuery);
    if (bySearchText) {
      return bySearchText;
    }

    const byModelName = await this.queryEquipmentName(tableName, selection.name ?? "", "model_name", baseQuery);
    if (byModelName) {
      return byModelName;
    }

    // Display names like "Seymour Duncan JB (SH-4)" carry parentheses that
    // search_text does not; retry with punctuation stripped.
    const normalized = (selection.name ?? "").replace(/[()]/g, "").replace(/\s+/g, " ").trim();
    if (!normalized || normalized === selection.name) {
      return null;
    }

    return this.queryEquipmentName(tableName, normalized, "search_text", baseQuery);
  }

  private async queryEquipmentExactTag(
    tableName: string,
    name: string,
    baseQuery: (query: SupabaseQuery) => SupabaseQuery
  ) {
    const phrase = name.trim().toLowerCase();
    if (!phrase) {
      return null;
    }

    // `tags` holds each match phrase as a discrete array element, so containment
    // (`tags @> {phrase}`) is a true whole-phrase match — unlike a search_text
    // substring, which also fires on a longer tag that merely starts with `phrase`.
    const query = baseQuery(this.supabase.from(tableName));
    const { data, error } = await query.contains("tags", [phrase]).order("model_name", { ascending: true }).limit(1).maybeSingle();

    if (error) {
      // A table without a `tags` column (or any query issue) must not break gear
      // resolution — fall through to the substring lookup.
      return null;
    }

    return (data ?? null) as Record<string, unknown> | null;
  }

  private async queryEquipmentName(
    tableName: string,
    name: string,
    columnName: "search_text" | "model_name",
    baseQuery: (query: SupabaseQuery) => SupabaseQuery
  ) {
    const query = baseQuery(this.supabase.from(tableName));
    const { data, error } = await query.ilike(columnName, `%${name}%`).order("model_name", { ascending: true }).limit(1).maybeSingle();

    if (error) {
      throw repositoryError(`Failed to query ${tableName}.`, { error: error.message, columnName });
    }

    return (data ?? null) as Record<string, unknown> | null;
  }

  private async findMultiFxNames(tableName: string, columnName: string, deviceId: unknown) {
    const { data, error } = await this.supabase
      .from(tableName)
      .select(columnName)
      .eq("multifx_device_id", String(deviceId))
      .eq("is_active", true);

    if (error) {
      throw repositoryError(`Failed to query ${tableName}.`, { error: error.message });
    }

    return ((data ?? []) as unknown as Array<Record<string, unknown>>).map((row) => String(row[columnName]));
  }
}

function positionByIndex(index: number): PickupPosition {
  if (index === 0) {
    return "neck";
  }
  if (index === 1) {
    return "middle";
  }
  if (index === 2) {
    return "bridge";
  }
  return "primary";
}

function pickupPosition(value: unknown): PickupPosition {
  if (value === "neck" || value === "middle" || value === "bridge") {
    return value;
  }
  return "primary";
}

function nestedRecord(value: unknown): Record<string, unknown> | null {
  if (Array.isArray(value)) {
    return isRecord(value[0]) ? value[0] : null;
  }
  return isRecord(value) ? value : null;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
