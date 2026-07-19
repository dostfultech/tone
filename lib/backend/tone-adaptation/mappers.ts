import type {
  AmplifierProfileInput,
  CabinetBackType,
  CabinetProfileInput,
  GuitarProfileInput,
  JsonRecord,
  MasterToneInput,
  MultiFxProfileInput,
  PedalProfileInput,
  PickupPosition,
  PickupProfileInput,
  ToneSettingKey,
  ToneType
} from "../../rule-engine";
import type { ToneAdaptationMode } from "./dtos";
import type { LoadedMasterToneContext } from "./types";

const TONE_SETTING_KEY_BY_DB_COLUMN: Record<string, ToneSettingKey> = {
  gain: "gain",
  bass: "bass",
  middle: "middle",
  treble: "treble",
  presence: "presence",
  resonance: "resonance",
  depth: "depth",
  master_volume: "masterVolume",
  noise_gate: "noiseGate",
  compression: "compression",
  delay: "delay",
  reverb: "reverb"
};

export function mapMasterToneRow(
  row: Record<string, unknown>,
  songPart: Record<string, unknown>,
  song: Record<string, unknown>,
  artist: Record<string, unknown>,
  suggestedPedals: string[]
): LoadedMasterToneContext {
  const settings = Object.entries(TONE_SETTING_KEY_BY_DB_COLUMN).reduce<MasterToneInput["settings"]>(
    (accumulator, [dbColumn, settingKey]) => {
      const value = toNumber(row[dbColumn]);
      if (value !== null) {
        accumulator[settingKey] = value;
      }
      return accumulator;
    },
    {}
  );

  const toneType = toToneType(row.tone_type_id, "auto_detect");
  const mode = row.instrument_type === "bass" ? "bass" : "guitar";
  const version = Math.max(1, toNumber(row.version) ?? 1);
  const metadata = jsonRecord(row.metadata);
  const original = mapMasterToneOriginal(metadata, settings);

  return {
    original,
    masterTone: {
      id: stringValue(row.id, "unknown-master-tone"),
      songId: stringValue(song.id),
      songPartId: stringValue(songPart.id),
      instrumentType: mode,
      toneType,
      settings,
      eqProfile: jsonRecord(row.eq_profile),
      modulationProfile: jsonRecord(row.modulation_profile),
      tempoBpm: toNumber(row.tempo_bpm),
      toneArchetype: nullableString(row.tone_archetype_id),
      pickupPreference: nullableString(row.pickup_preference_id),
      suggestedAmpArchetype: nullableString(row.suggested_amp_archetype_id),
      suggestedCabinetArchetype: nullableString(row.suggested_cabinet_archetype_id),
      suggestedPedals,
      metadata: jsonRecord(row.metadata)
    },
    source: {
      id: stringValue(row.id, "unknown-master-tone"),
      sourceType: "master_tones",
      cacheSourceProfileId: nullableString(jsonRecord(row.metadata).legacyProfileId),
      songId: stringValue(song.id),
      songTitle: stringValue(song.title, "Unknown Song"),
      artistId: stringValue(artist.id),
      artistName: stringValue(artist.name, "Unknown Artist"),
      songPartId: stringValue(songPart.id),
      partLabel: stringValue(songPart.label, "Main"),
      partType: stringValue(songPart.part_type_id, "main"),
      toneType,
      mode,
      version,
      confidence: Math.round(toNumber(row.confidence) ?? 70)
    }
  };
}

function mapMasterToneOriginal(
  metadata: JsonRecord,
  settings: MasterToneInput["settings"]
): LoadedMasterToneContext["original"] {
  const guitar = nullableString(metadata.originalGuitar) ?? nullableString(metadata.original_guitar);
  const pickup = nullableString(metadata.originalPickup) ?? nullableString(metadata.original_pickup);
  const amp = nullableString(metadata.originalAmp) ?? nullableString(metadata.original_amp);
  const cab = nullableString(metadata.originalCab) ?? nullableString(metadata.original_cab);
  const notes = nullableString(metadata.sourceSummary) ?? nullableString(metadata.source_summary) ?? nullableString(metadata.notes);

  if (!guitar && !pickup && !amp && !cab && !notes) {
    return undefined;
  }

  const numericSettings = Object.entries(settings).reduce<Record<string, number>>((accumulator, [key, value]) => {
    if (typeof value === "number" && Number.isFinite(value)) {
      accumulator[key] = value;
    }
    return accumulator;
  }, {});

  return {
    guitar,
    pickup,
    amp,
    cab,
    notes,
    settings: numericSettings,
    effects: [],
    playingNotes: metadataStringArray(metadata.playingNotes ?? metadata.playing_notes),
    adaptationNotes: metadataStringArray(metadata.adaptationNotes ?? metadata.adaptation_notes),
    sources: [],
    difficulty: nullableString(metadata.difficulty),
    genre: nullableString(metadata.genre)
  };
}

function metadataStringArray(value: unknown): string[] {
  if (!Array.isArray(value)) {
    return [];
  }
  return value.filter((entry): entry is string => typeof entry === "string" && entry.trim().length > 0);
}

export function mapGuitarRow(row: Record<string, unknown>): GuitarProfileInput {
  return {
    id: stringValue(row.id),
    name: displayName(row),
    bodyType: nullableString(row.body_type),
    scaleLengthInches: toNumber(row.scale_length_inches),
    bridgeType: nullableString(row.bridge_type),
    pickupLayout: nullableString(row.pickup_layout),
    outputLevel: toNumber(row.output_level),
    brightness: numericBrightnessOrProfile(row.brightness),
    warmth: toNumber(row.warmth),
    compression: toNumber(row.compression),
    frequencyCurve: jsonRecord(row.frequency_curve),
    noiseCharacteristics: jsonRecord(row.noise_characteristics),
    toneArchetype: nullableString(row.tone_archetype_id),
    metadata: jsonRecord(row.metadata),
    version: metadataVersion(row.metadata)
  };
}

export function mapPickupRow(row: Record<string, unknown>, position?: PickupPosition): PickupProfileInput {
  return {
    id: stringValue(row.id),
    name: displayName(row),
    position: position ?? "primary",
    type: pickupType(row.pickup_type_id),
    circuitType: row.circuit_type === "active" ? "active" : "passive",
    outputLevel: toNumber(row.output_level),
    brightness: numericBrightnessOrProfile(row.brightness),
    bass: toNumber(row.bass),
    midrange: toNumber(row.midrange),
    compression: toNumber(row.compression),
    noise: toNumber(row.noise),
    frequencyResponse: jsonRecord(row.frequency_curve),
    toneArchetype: nullableString(row.tone_archetype_id),
    metadata: jsonRecord(row.metadata),
    version: metadataVersion(row.metadata)
  };
}

export function mapAmpRow(row: Record<string, unknown>): AmplifierProfileInput {
  return {
    id: stringValue(row.id),
    name: displayName(row),
    technology: ampTechnology(row.amp_technology),
    gainStructure: nullableString(row.gain_structure),
    era: ampEra(row.gain_structure),
    eqBehaviour: jsonRecord(row.eq_behaviour),
    presenceBehaviour: jsonRecord(row.presence_behaviour),
    compression: toNumber(row.compression),
    brightness: numericBrightnessOrProfile(row.brightness),
    warmth: toNumber(row.warmth),
    cleanHeadroom: toNumber(row.clean_headroom),
    toneArchetype: nullableString(row.tone_archetype_id),
    metadata: jsonRecord(row.metadata),
    version: metadataVersion(row.metadata)
  };
}

export function mapCabinetRow(row: Record<string, unknown>): CabinetProfileInput {
  return {
    id: stringValue(row.id),
    name: displayName(row),
    format: nullableString(row.cabinet_format_id),
    backType: cabinetBackType(row.back_type),
    speakerModel: nullableString(row.speaker_model_name),
    frequencyCurve: jsonRecord(row.frequency_curve),
    lowEnd: toNumber(row.low_end),
    highEnd: toNumber(row.high_end),
    brightness: numericBrightnessOrProfile(row.brightness),
    warmth: toNumber(row.warmth),
    metadata: jsonRecord(row.metadata),
    version: metadataVersion(row.metadata)
  };
}

export function mapPedalRow(row: Record<string, unknown>, order: number): PedalProfileInput {
  return {
    id: stringValue(row.id),
    name: displayName(row),
    type: stringValue(row.pedal_type_id, "unknown"),
    order,
    enabled: true,
    gainChange: toNumber(row.gain_change),
    eqInfluence: toneDeltas(row.eq_influence),
    compression: toNumber(row.compression),
    noise: toNumber(row.noise),
    toneColor: jsonRecord(row.tone_color),
    metadata: jsonRecord(row.metadata),
    version: metadataVersion(row.metadata)
  };
}

export function mapMultiFxRow(
  row: Record<string, unknown>,
  ampModels: string[],
  cabModels: string[],
  effects: string[]
): MultiFxProfileInput {
  return {
    id: stringValue(row.id),
    deviceId: stringValue(row.id),
    name: displayName(row),
    availableAmpModels: ampModels,
    cabModels,
    effects,
    dspLimits: jsonRecord(row.dsp_limits),
    routing: jsonRecord(row.routing),
    patchStructure: jsonRecord(row.patch_structure),
    parameterMapping: stringMapping(row.parameter_mapping),
    metadata: jsonRecord(row.metadata),
    version: metadataVersion(row.metadata)
  };
}

export function normalizeRequestedMode(value: unknown): ToneAdaptationMode {
  return value === "bass" ? "bass" : "guitar";
}

export function toNumber(value: unknown): number | null {
  if (typeof value === "number" && Number.isFinite(value)) {
    return value;
  }
  if (typeof value === "string" && value.trim() !== "") {
    const parsed = Number(value);
    return Number.isFinite(parsed) ? parsed : null;
  }
  return null;
}

function numericBrightnessOrProfile(value: unknown) {
  const numeric = toNumber(value);
  if (numeric === null) {
    return null;
  }
  if (numeric <= 3.5) {
    return "dark";
  }
  if (numeric >= 6.5) {
    return "bright";
  }
  return "balanced";
}

function displayName(row: Record<string, unknown>) {
  const manufacturer = manufacturerName(row.equipment_manufacturers) || manufacturerName(row.brand) || manufacturerName(row.manufacturer);
  const modelName = stringValue(row.model_name, stringValue(row.name, "Unknown Model"));
  return manufacturer ? `${manufacturer} ${modelName}` : modelName;
}

function manufacturerName(value: unknown) {
  if (Array.isArray(value)) {
    return nullableString(value[0]?.name);
  }
  if (isRecord(value)) {
    return nullableString(value.name);
  }
  return null;
}

function pickupType(value: unknown) {
  if (value === "single_coil" || value === "humbucker" || value === "p90") {
    return value;
  }
  return "other";
}

function ampTechnology(value: unknown) {
  if (
    value === "tube" ||
    value === "solid_state" ||
    value === "hybrid" ||
    value === "digital_modeling" ||
    value === "plugin"
  ) {
    return value;
  }
  return null;
}

function cabinetBackType(value: unknown): CabinetBackType | null {
  if (value === "open_back" || value === "closed_back" || value === "semi_open") {
    return value;
  }
  return null;
}

function ampEra(value: unknown) {
  const text = nullableString(value)?.toLowerCase() ?? "";
  if (text.includes("vintage") || text.includes("classic")) {
    return "vintage";
  }
  if (text.includes("modern")) {
    return "modern";
  }
  return "neutral";
}

function toToneType(value: unknown, fallback: ToneType): ToneType {
  return typeof value === "string" && value.length > 0 ? (value as ToneType) : fallback;
}

function stringValue(value: unknown, fallback = "") {
  return typeof value === "string" && value.length > 0 ? value : fallback;
}

function nullableString(value: unknown) {
  return typeof value === "string" && value.length > 0 ? value : null;
}

function jsonRecord(value: unknown): JsonRecord {
  return isRecord(value) ? value : {};
}

function toneDeltas(value: unknown) {
  if (!isRecord(value)) {
    return null;
  }

  return Object.entries(value).reduce<Record<string, number>>((accumulator, [key, delta]) => {
    const numeric = toNumber(delta);
    if (numeric !== null) {
      accumulator[key] = numeric;
    }
    return accumulator;
  }, {});
}

function stringMapping(value: unknown) {
  if (!isRecord(value)) {
    return {};
  }

  return Object.entries(value).reduce<Record<string, string>>((accumulator, [key, mapped]) => {
    if (typeof mapped === "string") {
      accumulator[key] = mapped;
    }
    return accumulator;
  }, {});
}

function metadataVersion(value: unknown) {
  const metadata = jsonRecord(value);
  const version = toNumber(metadata.profileVersion) ?? toNumber(metadata.version);
  return version ?? 1;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
