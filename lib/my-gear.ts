import { brand } from "@/lib/brand";

export type GearSelectionCategory = "guitar" | "amp" | "pedal" | "multifx";

export type GearSelectionMetadata = {
  model_id: string;
  brand_name: string;
  model_name: string;
  category: GearSelectionCategory;
  model_category: string;
  pickup_configuration: string | null;
  amp_type: string | null;
  pedal_type: string | null;
};

export type MyGearProfile = {
  schema_version: 1;
  guitar: GearSelectionMetadata | null;
  amp: GearSelectionMetadata | null;
  pedals: GearSelectionMetadata[];
  multifx: GearSelectionMetadata | null;
  updated_at: string | null;
};

export type GearSearchItem = {
  modelId: string;
  brandName: string;
  modelName: string;
  name: string;
  category: string;
  tags: string[];
  pickupConfiguration: string | null;
  ampType: string | null;
  pedalType: string | null;
};

export type GearSearchResponse = {
  results: GearSearchItem[];
};

export const MY_GEAR_PROFILE_STORAGE_KEY = `${brand.storagePrefix}_my_gear_profile`;
export const MY_GEAR_PROFILE_UPDATED_EVENT = `${brand.storagePrefix}:my-gear-profile-updated`;

const EMPTY_PROFILE: MyGearProfile = {
  schema_version: 1,
  guitar: null,
  amp: null,
  pedals: [],
  multifx: null,
  updated_at: null
};

export function createEmptyMyGearProfile(): MyGearProfile {
  return {
    ...EMPTY_PROFILE,
    pedals: []
  };
}

export function readCachedMyGearProfile() {
  if (typeof window === "undefined") {
    return createEmptyMyGearProfile();
  }

  try {
    return normalizeMyGearProfile(JSON.parse(window.localStorage.getItem(MY_GEAR_PROFILE_STORAGE_KEY) || "null"));
  } catch {
    return createEmptyMyGearProfile();
  }
}

export function cacheMyGearProfile(profile: MyGearProfile) {
  if (typeof window === "undefined") {
    return;
  }

  const normalized = normalizeMyGearProfile(profile);
  const serialized = JSON.stringify(normalized);
  const previous = window.localStorage.getItem(MY_GEAR_PROFILE_STORAGE_KEY);

  window.localStorage.setItem(MY_GEAR_PROFILE_STORAGE_KEY, serialized);

  if (previous !== serialized) {
    window.dispatchEvent(
      new CustomEvent(MY_GEAR_PROFILE_UPDATED_EVENT, {
        detail: normalized
      })
    );
  }
}

export function normalizeMyGearProfile(value: unknown): MyGearProfile {
  if (!value || typeof value !== "object") {
    return createEmptyMyGearProfile();
  }

  const source = value as Record<string, unknown>;

  return {
    schema_version: 1,
    guitar: normalizeSelection(source.guitar, "guitar"),
    amp: normalizeSelection(source.amp, "amp"),
    pedals: normalizePedals(source.pedals),
    multifx: normalizeSelection(source.multifx, "multifx"),
    updated_at: typeof source.updated_at === "string" ? source.updated_at : typeof source.updatedAt === "string" ? source.updatedAt : null
  };
}

function normalizePedals(value: unknown): GearSelectionMetadata[] {
  if (!Array.isArray(value)) {
    return [];
  }

  return value
    .map((item) => normalizeSelection(item, "pedal"))
    .filter((item): item is GearSelectionMetadata => item !== null);
}

function normalizeSelection(value: unknown, category: GearSelectionCategory): GearSelectionMetadata | null {
  if (!value || typeof value !== "object") {
    return null;
  }

  const source = value as Record<string, unknown>;
  const modelId = asString(source.model_id) || asString(source.modelId);
  const brandName = asString(source.brand_name) || asString(source.brandName);
  const modelName = asString(source.model_name) || asString(source.modelName);

  if (!modelId || !brandName || !modelName) {
    return null;
  }

  return {
    model_id: modelId,
    brand_name: brandName,
    model_name: modelName,
    category,
    model_category: asString(source.model_category) || asString(source.modelCategory) || category,
    pickup_configuration: asNullableString(source.pickup_configuration) || asNullableString(source.pickupConfiguration),
    amp_type: asNullableString(source.amp_type) || asNullableString(source.ampType),
    pedal_type: asNullableString(source.pedal_type) || asNullableString(source.pedalType)
  };
}

function asString(value: unknown) {
  return typeof value === "string" ? value : "";
}

function asNullableString(value: unknown) {
  return typeof value === "string" && value.length > 0 ? value : null;
}
