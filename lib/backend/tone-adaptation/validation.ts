import { randomUUID } from "node:crypto";
import type {
  NamedSelectionDto,
  NormalizedSelection,
  NormalizedToneAdaptationRequest,
  ToneAdaptationGearDto,
  ToneAdaptationMode,
  ToneAdaptationRequestDto
} from "./dtos";
import { validationError } from "./errors";
import type { ToneType } from "../../rule-engine";

const SUPPORTED_TONE_TYPES = new Set<ToneType>([
  "auto_detect",
  "auto",
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
]);

export function validateToneAdaptationRequest(payload: unknown): NormalizedToneAdaptationRequest {
  if (!isRecord(payload)) {
    throw validationError("Request body must be a JSON object.");
  }

  const dto = payload as ToneAdaptationRequestDto;
  const gear = isRecord(dto.gear) ? (dto.gear as ToneAdaptationGearDto) : {};
  const mode = normalizeMode(dto.mode);
  const toneType = normalizeToneType(dto.toneType);
  const requestId = cleanString(dto.requestId) ?? randomUUID();
  const masterToneId = cleanString(dto.masterToneId);
  const song = cleanString(dto.song);
  const artist = cleanString(dto.artist);

  if (!masterToneId && (!song || !artist)) {
    throw validationError("Provide either masterToneId or both song and artist.");
  }

  return {
    requestId,
    song,
    artist,
    part: cleanString(dto.part),
    partType: normalizePart(dto.partType),
    toneType,
    mode,
    masterToneId,
    guitar: normalizeSelection(dto.guitarId ?? gear.guitarId, dto.guitar ?? gear.guitar),
    pickups: normalizeSelections(dto.pickupIds ?? gear.pickupIds, dto.pickups ?? gear.pickups),
    amp: normalizeSelection(dto.ampId ?? gear.ampId, dto.amp ?? gear.amp),
    cabinet: normalizeSelection(dto.cabinetId ?? gear.cabinetId, dto.cabinet ?? gear.cabinet),
    pedals: normalizeSelections(dto.pedalIds ?? gear.pedalIds, dto.pedals ?? gear.pedals),
    goingDirect: Boolean(dto.goingDirect ?? gear.goingDirect ?? false),
    multiFx: normalizeSelection(dto.multiFxId ?? gear.multiFxId, dto.multiFx ?? gear.multiFx)
  };
}

export function slugify(value: string) {
  return value
    .trim()
    .toLowerCase()
    .replace(/&/g, " and ")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

function normalizeMode(value: unknown): ToneAdaptationMode {
  return value === "bass" ? "bass" : "guitar";
}

function normalizeToneType(value: unknown): ToneType {
  const normalized = normalizeToken(value, "auto_detect");
  const toneType = normalized === "auto" ? "auto_detect" : normalized;

  if (!SUPPORTED_TONE_TYPES.has(toneType as ToneType)) {
    throw validationError("Unsupported toneType.", { toneType: value });
  }

  return toneType as ToneType;
}

function normalizePart(value: unknown) {
  return normalizeToken(value, undefined);
}

function normalizeToken(value: unknown, fallback?: string) {
  const cleaned = cleanString(value);
  if (!cleaned) {
    return fallback;
  }
  return cleaned.toLowerCase().replace(/[^a-z0-9]+/g, "_").replace(/^_+|_+$/g, "");
}

function normalizeSelection(id: unknown, name: unknown): NormalizedSelection | undefined {
  const normalizedId = cleanString(id);
  const normalizedName = cleanString(name);
  if (!normalizedId && !normalizedName) {
    return undefined;
  }
  return {
    id: normalizedId,
    name: normalizedName
  };
}

function normalizeSelections(ids: unknown, values: unknown): NormalizedSelection[] {
  const idSelections = Array.isArray(ids)
    ? ids.map((id) => normalizeSelection(id, undefined)).filter(Boolean)
    : [];
  const valueSelections = Array.isArray(values) ? values.map(normalizeNamedSelection).filter(Boolean) : [];

  return [...idSelections, ...valueSelections] as NormalizedSelection[];
}

function normalizeNamedSelection(value: unknown): NormalizedSelection | undefined {
  if (typeof value === "string") {
    return normalizeSelection(undefined, value);
  }

  if (!isRecord(value)) {
    return undefined;
  }

  const dto = value as NamedSelectionDto;
  const selection = normalizeSelection(dto.id, dto.name);
  if (!selection) {
    return undefined;
  }

  return {
    ...selection,
    position: dto.position,
    order: typeof dto.order === "number" ? dto.order : undefined
  };
}

function cleanString(value: unknown) {
  return typeof value === "string" && value.trim().length > 0 ? value.trim() : undefined;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
