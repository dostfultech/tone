import { randomUUID } from "node:crypto";
import type {
  DeleteToneRequestDto,
  GenerateSongRequestDto,
  IngestionJobType,
  IngestionMode,
  IngestionPartType,
  NormalizedMasterToneDraft,
  RegenerateSongRequestDto,
  ToneDecisionRequestDto,
  UpdateMasterToneRequestDto,
  WorkerRunRequestDto
} from "./dtos";
import { ingestionValidationError } from "./errors";
import type { ToneType } from "../../rule-engine";

export const INGESTION_PART_TYPES: IngestionPartType[] = [
  "intro",
  "verse",
  "chorus",
  "bridge",
  "solo",
  "lead",
  "rhythm",
  "riff",
  "breakdown",
  "outro",
  "clean"
];

export const INGESTION_TONE_TYPES: ToneType[] = [
  "auto_detect",
  "clean",
  "crunch",
  "edge_of_breakup",
  "classic_rock",
  "heavy",
  "high_gain",
  "metal",
  "modern_metal",
  "distorted",
  "ambient",
  "acoustic",
  "bass_clean",
  "bass_drive"
];

const JOB_TYPES: IngestionJobType[] = ["song_generation", "metadata_enrichment", "gear_matching", "cache_prewarming"];

export function validateGenerateSongRequest(payload: unknown): GenerateSongRequestDto {
  const record = requireRecord(payload);
  const song = requiredString(record.song, "song");
  const artist = requiredString(record.artist, "artist");
  return {
    song,
    artist,
    part: optionalString(record.part) ?? "Main",
    partType: normalizePartType(record.partType, record.part),
    toneType: normalizeToneType(record.toneType),
    mode: normalizeMode(record.mode),
    runImmediately: record.runImmediately === true,
    priority: optionalInteger(record.priority, 100),
    metadata: optionalRecord(record.metadata)
  };
}

export function validateRegenerateSongRequest(payload: unknown): RegenerateSongRequestDto {
  const base = validateGenerateSongRequest(payload);
  const record = requireRecord(payload);
  return {
    ...base,
    masterToneId: optionalString(record.masterToneId),
    reason: optionalString(record.reason)
  };
}

export function validateUpdateMasterToneRequest(payload: unknown): UpdateMasterToneRequestDto {
  const record = requireRecord(payload);
  const patch = optionalRecord(record.patch);
  if (!patch || Object.keys(patch).length === 0) {
    throw ingestionValidationError("patch is required.");
  }

  return {
    masterToneId: requiredString(record.masterToneId, "masterToneId"),
    patch: validateDraftPatch(patch),
    reason: optionalString(record.reason)
  };
}

export function validateToneDecisionRequest(payload: unknown): ToneDecisionRequestDto {
  const record = requireRecord(payload);
  return {
    masterToneId: requiredString(record.masterToneId, "masterToneId"),
    reason: optionalString(record.reason),
    metadata: optionalRecord(record.metadata)
  };
}

export function validateDeleteToneRequest(payload: unknown): DeleteToneRequestDto {
  const record = requireRecord(payload);
  return {
    masterToneId: requiredString(record.masterToneId, "masterToneId"),
    reason: optionalString(record.reason)
  };
}

export function validateWorkerRunRequest(payload: unknown): WorkerRunRequestDto {
  const record = isRecord(payload) ? payload : {};
  const jobTypes = Array.isArray(record.jobTypes)
    ? record.jobTypes.filter((jobType): jobType is IngestionJobType => JOB_TYPES.includes(jobType as IngestionJobType))
    : undefined;

  return {
    workerId: optionalString(record.workerId) ?? `worker-${randomUUID()}`,
    limit: Math.min(Math.max(optionalInteger(record.limit, 5), 1), 25),
    jobTypes
  };
}

export function validateAiDraft(value: unknown): NormalizedMasterToneDraft {
  const record = requireRecord(value);
  const draft: NormalizedMasterToneDraft = {
    song: requiredString(record.song, "song"),
    artist: requiredString(record.artist, "artist"),
    part: optionalString(record.part) ?? "Main",
    partType: normalizePartType(record.partType, record.part),
    toneType: normalizeToneType(record.toneType),
    mode: normalizeMode(record.mode),
    gain: knob(record.gain, "gain"),
    bass: knob(record.bass, "bass"),
    middle: knob(record.middle, "middle"),
    treble: knob(record.treble, "treble"),
    presence: knob(record.presence, "presence"),
    resonance: knob(record.resonance, "resonance"),
    depth: knob(record.depth, "depth"),
    masterVolume: knob(record.masterVolume, "masterVolume"),
    noiseGate: knob(record.noiseGate, "noiseGate"),
    compression: knob(record.compression, "compression"),
    delay: knob(record.delay, "delay"),
    reverb: knob(record.reverb, "reverb"),
    tempoBpm: optionalNumber(record.tempoBpm),
    suggestedAmpArchetype: optionalString(record.suggestedAmpArchetype) ?? null,
    suggestedCabinetArchetype: optionalString(record.suggestedCabinetArchetype) ?? null,
    suggestedPedals: stringArray(record.suggestedPedals).slice(0, 12),
    pickupPreference: optionalString(record.pickupPreference) ?? null,
    toneArchetype: optionalString(record.toneArchetype) ?? null,
    eqProfile: optionalRecord(record.eqProfile) ?? {},
    modulationProfile: optionalRecord(record.modulationProfile) ?? {},
    metadata: optionalRecord(record.metadata) ?? {},
    sourceSummary: requiredString(record.sourceSummary, "sourceSummary"),
    confidence: Math.round(Math.min(Math.max(optionalNumber(record.confidence) ?? 65, 0), 100))
  };

  return draft;
}

export function slugify(value: string) {
  return value
    .trim()
    .toLowerCase()
    .replace(/&/g, " and ")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

function validateDraftPatch(patch: Record<string, unknown>): Partial<NormalizedMasterToneDraft> {
  const allowed = new Set([
    "part",
    "partType",
    "toneType",
    "mode",
    "gain",
    "bass",
    "middle",
    "treble",
    "presence",
    "resonance",
    "depth",
    "masterVolume",
    "noiseGate",
    "compression",
    "delay",
    "reverb",
    "tempoBpm",
    "suggestedAmpArchetype",
    "suggestedCabinetArchetype",
    "suggestedPedals",
    "pickupPreference",
    "toneArchetype",
    "eqProfile",
    "modulationProfile",
    "metadata",
    "sourceSummary",
    "confidence"
  ]);

  return Object.fromEntries(Object.entries(patch).filter(([key]) => allowed.has(key))) as Partial<NormalizedMasterToneDraft>;
}

function normalizeMode(value: unknown): IngestionMode {
  return value === "bass" ? "bass" : "guitar";
}

function normalizeToneType(value: unknown): ToneType {
  const normalized = optionalString(value)?.toLowerCase().replace(/[^a-z0-9]+/g, "_") ?? "auto_detect";
  const toneType = normalized === "auto" ? "auto_detect" : normalized;
  if (!INGESTION_TONE_TYPES.includes(toneType as ToneType)) {
    throw ingestionValidationError("Unsupported toneType.", { toneType: value });
  }
  return toneType as ToneType;
}

function normalizePartType(value: unknown, partValue: unknown): IngestionPartType {
  const normalized = optionalString(value)?.toLowerCase().replace(/[^a-z0-9]+/g, "_");
  if (normalized && INGESTION_PART_TYPES.includes(normalized as IngestionPartType)) {
    return normalized as IngestionPartType;
  }

  const part = optionalString(partValue)?.toLowerCase() ?? "";
  const inferred = INGESTION_PART_TYPES.find((partType) => part.includes(partType));
  return inferred ?? "riff";
}

function knob(value: unknown, name: string) {
  const numeric = optionalNumber(value);
  if (numeric === null) {
    throw ingestionValidationError(`${name} must be a number between 0 and 10.`);
  }
  if (numeric < 0 || numeric > 10) {
    throw ingestionValidationError(`${name} must be between 0 and 10.`, { value: numeric });
  }
  return Math.round(numeric * 100) / 100;
}

function requiredString(value: unknown, key: string) {
  const text = optionalString(value);
  if (!text) {
    throw ingestionValidationError(`${key} is required.`);
  }
  return text;
}

function optionalString(value: unknown) {
  return typeof value === "string" && value.trim().length > 0 ? value.trim() : undefined;
}

function optionalInteger(value: unknown, fallback: number) {
  const numeric = optionalNumber(value);
  return numeric === null ? fallback : Math.round(numeric);
}

function optionalNumber(value: unknown) {
  if (typeof value === "number" && Number.isFinite(value)) {
    return value;
  }
  if (typeof value === "string" && value.trim().length > 0) {
    const parsed = Number(value);
    return Number.isFinite(parsed) ? parsed : null;
  }
  return null;
}

function stringArray(value: unknown) {
  return Array.isArray(value) ? value.filter((item): item is string => typeof item === "string" && item.trim().length > 0) : [];
}

function optionalRecord(value: unknown) {
  return isRecord(value) ? value : undefined;
}

function requireRecord(value: unknown) {
  if (!isRecord(value)) {
    throw ingestionValidationError("Request body must be a JSON object.");
  }
  return value;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
