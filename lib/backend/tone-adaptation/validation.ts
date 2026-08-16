import { randomUUID } from "node:crypto";
import type {
  NamedSelectionDto,
  NormalizedSelection,
  NormalizedToneAdaptationRequest,
  ToneAdaptationRequestSource,
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
  "fuzz",
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
  const song = tidyTitleInput(cleanString(dto.song));
  const artist = tidyTitleInput(cleanString(dto.artist));

  if (!masterToneId && (!song || !artist)) {
    throw validationError("Provide either masterToneId or both song and artist.");
  }

  return {
    requestId,
    requestSource: normalizeRequestSource(dto.requestSource),
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
    multiFx: normalizeSelection(dto.multiFxId ?? gear.multiFxId, dto.multiFx ?? gear.multiFx),
    effectsMode: cleanString(dto.effectsMode ?? gear.effectsMode),
    selectedFx: cleanString(dto.selectedFx ?? gear.selectedFx)
  };
}

function normalizeRequestSource(value: unknown): ToneAdaptationRequestSource {
  return value === "tone_database_adapt_to_my_gear" || value === "saved_tone_readapt" ? value : "manual_generate";
}

export function slugify(value: string) {
  return value
    .trim()
    .toLowerCase()
    .replace(/&/g, " and ")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

// Streaming/iTunes catalogs list songs with trailing qualifiers like "(Remastered)",
// "(Live)", "(2011 Remaster)", "- Deluxe Edition". Those are the SAME song for tone
// purposes, so strip a trailing qualifier group when it names a variant. Real
// parentheticals that are part of the title (e.g. "Voodoo Child (Slight Return)") are
// preserved because they do not contain a variant keyword.
const SONG_VARIANT_QUALIFIER =
  /\b(?:re-?master(?:ed)?|digital remaster|live|deluxe|mono|stereo|anniversary|edition|version|remix|mix|edit|radio edit|single version|album version|bonus(?: track)?|demo|take\s*\d+|session|expanded|reissue|remastered|feat\.?|ft\.?|featuring|acoustic|instrumental|unplugged|extended|explicit)\b/i;

export function normalizeSongTitle(title: string): string {
  // Streaming metadata sometimes carries stray wrapping quotes or doubled spaces
  // ("' Sweet Child O' Mine"). Strip junk only when followed/preceded by a space so
  // legitimate leading apostrophes ("'39") survive.
  let result = title
    .trim()
    .replace(/^['"‘’“”]\s+/, "")
    .replace(/\s+['"‘’“”]$/, "")
    .replace(/\s{2,}/g, " ");

  // Strip up to a few stacked trailing "(...)" / "[...]" qualifier groups, e.g.
  // "Song (feat. X) (2011 Remaster)" or "Song (2009 Remastered Version) [feat. Y]" -> "Song".
  for (let i = 0; i < 4; i += 1) {
    const stripped = result.replace(/[([][^()[\]]*[)\]]\s*$/, (match) =>
      SONG_VARIANT_QUALIFIER.test(match) ? "" : match
    );
    if (stripped === result) {
      break;
    }
    result = stripped.trim();
  }

  // Strip a trailing "- Remastered 2011" / "- Live at ..." / "- feat. X" dash suffix.
  result = result.replace(/\s[-–—]\s.*$/, (match) => (SONG_VARIANT_QUALIFIER.test(match) ? "" : match));

  return result.trim() || title.trim();
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

// Tidy stray input so the same song isn't split in search + analytics (e.g. a user's
// "' Sweet Child O' Mine" vs "Sweet Child O' Mine"). Strips a leading quote/apostrophe that is
// followed by whitespace (junk) but preserves real leading-apostrophe titles like "'39" or
// "'Til You Can't" (apostrophe immediately followed by a character), and collapses double spaces.
function tidyTitleInput(value?: string) {
  if (!value) {
    return value;
  }
  const tidied = value
    .replace(/^['‘’"“”]\s+/, "")
    .replace(/\s{2,}/g, " ")
    .trim();
  return tidied || value;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
