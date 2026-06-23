import { readFile } from "node:fs/promises";
import { basename, dirname, extname, isAbsolute, resolve } from "node:path";
import process from "node:process";
import { fileURLToPath } from "node:url";
import { createClient } from "@supabase/supabase-js";

const allowedModes = new Set(["guitar", "bass"]);
const allowedPartTypes = new Set(["main", "riff", "solo", "lead", "rhythm", "intro", "chorus", "bridge", "bassline"]);
const allowedToneTypes = new Set(["auto", "clean", "crunch", "distorted", "high_gain", "fuzz", "acoustic", "bass_clean", "bass_drive"]);
const allowedVerificationStatuses = new Set(["starter_estimate", "needs_review", "community_submitted", "admin_verified"]);
const allowedSourceTypes = new Set(["artist_interview", "rig_rundown", "community_forum", "video_tutorial", "tone_pack", "internal_seed", "user_submission"]);
const scriptDir = dirname(fileURLToPath(import.meta.url));
const projectRoot = resolve(scriptDir, "..");

const args = parseArgs(process.argv.slice(2));

if (args.help || !args.file) {
  printUsage(args.help ? 0 : 1);
}

await loadEnvFiles([resolve(projectRoot, ".env.local"), resolve(projectRoot, ".env"), resolve(process.cwd(), ".env.local"), resolve(process.cwd(), ".env")]);

const inputPath = isAbsolute(args.file) ? args.file : resolve(process.cwd(), args.file);
const rawInput = stripBom(await readFile(inputPath, "utf8"));
const format = resolveFormat(args.format, inputPath);
const importedProfiles = format === "json" ? parseJsonInput(rawInput) : parseCsvInput(rawInput);

if (!importedProfiles.length) {
  fail(`No profiles found in ${basename(inputPath)}.`);
}

const normalizedProfiles = importedProfiles.map((profile, index) => normalizeProfile(profile, index));

const artistCount = new Set(normalizedProfiles.map((profile) => profile.artist.slug)).size;
const songCount = new Set(normalizedProfiles.map((profile) => `${profile.artist.slug}::${profile.song.slug}`)).size;

console.log(`Validated ${normalizedProfiles.length} profiles from ${basename(inputPath)}.`);
console.log(`Artists: ${artistCount} | Songs: ${songCount} | Dry run: ${args.dryRun ? "yes" : "no"}`);

if (args.dryRun) {
  process.exit(0);
}

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !serviceRoleKey) {
  fail("Missing NEXT_PUBLIC_SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY in .env.local/.env.");
}

const supabase = createClient(supabaseUrl, serviceRoleKey, {
  auth: {
    persistSession: false,
    autoRefreshToken: false
  }
});

let processedCount = 0;

for (const profile of normalizedProfiles) {
  const artistId = await upsertArtist(supabase, profile.artist);
  const songId = await upsertSong(supabase, artistId, profile.song, profile.artist.name);
  const profileId = await upsertToneProfile(supabase, songId, profile);
  await replaceEffects(supabase, profileId, profile.effects);
  await replaceSources(supabase, profileId, profile.sources);
  processedCount += 1;
  console.log(`Imported ${processedCount}/${normalizedProfiles.length}: ${profile.song.title} - ${profile.partLabel}`);
}

console.log(`Import completed successfully. Profiles imported: ${processedCount}.`);

function parseArgs(values) {
  const parsed = {
    file: "",
    format: "auto",
    dryRun: false,
    help: false
  };

  for (let index = 0; index < values.length; index += 1) {
    const value = values[index];
    if (value === "--file" || value === "-f") {
      parsed.file = values[index + 1] || "";
      index += 1;
      continue;
    }
    if (value === "--format") {
      parsed.format = values[index + 1] || "auto";
      index += 1;
      continue;
    }
    if (value === "--dry-run") {
      parsed.dryRun = true;
      continue;
    }
    if (value === "--help" || value === "-h") {
      parsed.help = true;
      continue;
    }
  }

  return parsed;
}

function printUsage(exitCode) {
  console.log(`Usage: npm run import:tones -- --file <path> [--format json|csv] [--dry-run]\n\nSupported JSON:\n  - Array of profile objects\n  - Object with a profiles array\n\nSupported CSV:\n  One row per tone profile. Complex fields must be JSON strings.\n  Recommended columns: artist_name, artist_slug, song_title, song_slug, mode, part_type, part_label, tone_type, original_settings, original_effects, adaptation_notes, playing_notes, sources.`);
  process.exit(exitCode);
}

async function loadEnvFiles(filePaths) {
  for (const filePath of new Set(filePaths)) {
    try {
      const content = stripBom(await readFile(filePath, "utf8"));
      applyEnvContent(content);
    } catch (error) {
      if (error && typeof error === "object" && "code" in error && error.code === "ENOENT") {
        continue;
      }

      fail(`Failed to load environment file ${filePath}: ${error instanceof Error ? error.message : "unknown error"}`);
    }
  }
}

function applyEnvContent(content) {
  for (const line of content.split(/\r?\n/)) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("#")) {
      continue;
    }

    const normalizedLine = trimmed.startsWith("export ") ? trimmed.slice(7).trim() : trimmed;
    const separatorIndex = normalizedLine.indexOf("=");
    if (separatorIndex < 0) {
      continue;
    }

    const key = normalizedLine.slice(0, separatorIndex).trim();
    if (!key || process.env[key] !== undefined) {
      continue;
    }

    let value = normalizedLine.slice(separatorIndex + 1).trim();
    if ((value.startsWith('"') && value.endsWith('"')) || (value.startsWith("'") && value.endsWith("'"))) {
      value = value.slice(1, -1);
    }
    process.env[key] = value;
  }
}

function stripBom(value) {
  return value.charCodeAt(0) === 0xfeff ? value.slice(1) : value;
}

function resolveFormat(value, filePath) {
  if (value === "json" || value === "csv") {
    return value;
  }

  const extension = extname(filePath).toLowerCase();
  if (extension === ".json") return "json";
  if (extension === ".csv") return "csv";
  fail(`Unable to infer format for ${basename(filePath)}. Use --format json or --format csv.`);
}

function parseJsonInput(content) {
  const parsed = JSON.parse(content);
  if (Array.isArray(parsed)) {
    return parsed;
  }
  if (Array.isArray(parsed?.profiles)) {
    return parsed.profiles;
  }
  fail("JSON input must be an array or an object with a profiles array.");
}

function parseCsvInput(content) {
  const rows = parseCsv(content);
  if (!rows.length) {
    return [];
  }

  const [header, ...dataRows] = rows;
  return dataRows
    .filter((row) => row.some((value) => value.trim() !== ""))
    .map((row) => mapCsvRow(header, row));
}

function parseCsv(content) {
  const rows = [];
  let currentCell = "";
  let currentRow = [];
  let inQuotes = false;

  for (let index = 0; index < content.length; index += 1) {
    const char = content[index];
    const next = content[index + 1];

    if (char === '"') {
      if (inQuotes && next === '"') {
        currentCell += '"';
        index += 1;
      } else {
        inQuotes = !inQuotes;
      }
      continue;
    }

    if (char === "," && !inQuotes) {
      currentRow.push(currentCell);
      currentCell = "";
      continue;
    }

    if ((char === "\n" || char === "\r") && !inQuotes) {
      if (char === "\r" && next === "\n") {
        index += 1;
      }
      currentRow.push(currentCell);
      rows.push(currentRow);
      currentCell = "";
      currentRow = [];
      continue;
    }

    currentCell += char;
  }

  if (currentCell.length || currentRow.length) {
    currentRow.push(currentCell);
    rows.push(currentRow);
  }

  return rows;
}

function mapCsvRow(header, row) {
  const record = {};
  for (let index = 0; index < header.length; index += 1) {
    const key = (header[index] || "").trim();
    if (!key) {
      continue;
    }
    record[key] = (row[index] || "").trim();
  }

  return {
    artistName: record.artist_name || record.artistName,
    artistSlug: record.artist_slug || record.artistSlug,
    artistCountry: record.artist_country || record.artistCountry,
    artistExternalIds: parseStructuredField(record.artist_external_ids || record.artistExternalIds, {}),
    songTitle: record.song_title || record.songTitle,
    songSlug: record.song_slug || record.songSlug,
    album: record.album,
    releaseYear: parseOptionalNumber(record.release_year || record.releaseYear),
    durationSeconds: parseOptionalNumber(record.duration_seconds || record.durationSeconds),
    songExternalIds: parseStructuredField(record.song_external_ids || record.songExternalIds, {}),
    mode: record.mode,
    partType: record.part_type || record.partType,
    partLabel: record.part_label || record.partLabel,
    toneType: record.tone_type || record.toneType,
    originalGuitar: record.original_guitar || record.originalGuitar,
    originalAmp: record.original_amp || record.originalAmp,
    originalCab: record.original_cab || record.originalCab,
    originalPickup: record.original_pickup || record.originalPickup,
    originalEffects: parseStructuredField(record.original_effects || record.originalEffects, []),
    originalSettings: parseStructuredField(record.original_settings || record.originalSettings, {}),
    adaptationNotes: parseStructuredField(record.adaptation_notes || record.adaptationNotes, []),
    playingNotes: parseStructuredField(record.playing_notes || record.playingNotes, []),
    confidence: parseOptionalNumber(record.confidence),
    verificationStatus: record.verification_status || record.verificationStatus,
    sourceSummary: record.source_summary || record.sourceSummary,
    searchText: record.search_text || record.searchText,
    isPublic: parseOptionalBoolean(record.is_public || record.isPublic),
    sources: parseStructuredField(record.sources, [])
  };
}

function normalizeProfile(input, index) {
  const artistName = requiredString(input.artistName || input.artist_name, `profiles[${index}].artistName`);
  const songTitle = requiredString(input.songTitle || input.song_title, `profiles[${index}].songTitle`);
  const mode = validateEnum((input.mode || "").toLowerCase(), allowedModes, `profiles[${index}].mode`);
  const partLabel = requiredString(input.partLabel || input.part_label, `profiles[${index}].partLabel`);
  const partType = validateEnum(normalizePartType(input.partType || input.part_type || partLabel), allowedPartTypes, `profiles[${index}].partType`);
  const toneType = validateEnum((input.toneType || input.tone_type || "auto").toLowerCase(), allowedToneTypes, `profiles[${index}].toneType`);
  const verificationStatus = validateEnum(
    (input.verificationStatus || input.verification_status || "needs_review").toLowerCase(),
    allowedVerificationStatuses,
    `profiles[${index}].verificationStatus`
  );

  const originalSettings = parseLooseObject(input.originalSettings || input.original_settings, `profiles[${index}].originalSettings`);
  const adaptationNotes = parseLooseStringArray(input.adaptationNotes || input.adaptation_notes, `profiles[${index}].adaptationNotes`);
  const playingNotes = parseLooseStringArray(input.playingNotes || input.playing_notes, `profiles[${index}].playingNotes`);
  const effects = parseLooseArray(input.originalEffects || input.original_effects, `profiles[${index}].originalEffects`).map((effect, effectIndex) =>
    normalizeEffect(effect, index, effectIndex)
  );
  const sources = parseLooseArray(input.sources, `profiles[${index}].sources`).map((source, sourceIndex) => normalizeSource(source, index, sourceIndex));

  return {
    artist: {
      name: artistName,
      slug: slugify(input.artistSlug || input.artist_slug || artistName),
      country: optionalString(input.artistCountry || input.artist_country),
      externalIds: parseLooseObject(input.artistExternalIds || input.artist_external_ids || {}, `profiles[${index}].artistExternalIds`)
    },
    song: {
      title: songTitle,
      slug: slugify(input.songSlug || input.song_slug || songTitle),
      album: optionalString(input.album),
      releaseYear: parseOptionalInteger(input.releaseYear || input.release_year),
      durationSeconds: parseOptionalInteger(input.durationSeconds || input.duration_seconds),
      externalIds: parseLooseObject(input.songExternalIds || input.song_external_ids || {}, `profiles[${index}].songExternalIds`)
    },
    mode,
    partType,
    partLabel,
    toneType,
    originalGuitar: optionalString(input.originalGuitar || input.original_guitar),
    originalAmp: optionalString(input.originalAmp || input.original_amp),
    originalCab: optionalString(input.originalCab || input.original_cab),
    originalPickup: optionalString(input.originalPickup || input.original_pickup),
    originalSettings,
    adaptationNotes,
    playingNotes,
    confidence: clampInteger(parseOptionalInteger(input.confidence) ?? 65, 0, 100),
    verificationStatus,
    sourceSummary: optionalString(input.sourceSummary || input.source_summary),
    searchText: optionalString(input.searchText || input.search_text) || buildProfileSearchText({
      artistName,
      songTitle,
      partLabel,
      toneType,
      mode,
      originalGuitar: input.originalGuitar || input.original_guitar,
      originalAmp: input.originalAmp || input.original_amp
    }),
    isPublic: typeof input.isPublic === "boolean" ? input.isPublic : typeof input.is_public === "boolean" ? input.is_public : true,
    effects,
    sources
  };
}

function normalizeEffect(effect, profileIndex, effectIndex) {
  const value = typeof effect === "string" ? { name: effect } : effect || {};
  const effectName = requiredString(value.name || value.effect_name, `profiles[${profileIndex}].originalEffects[${effectIndex}].name`);
  return {
    effectOrder: effectIndex + 1,
    effectType: optionalString(value.type || value.effect_type) || slugify(effectName).split("-")[0] || "effect",
    effectName,
    placement: optionalString(value.placement) || "post_gain",
    settings: parseLooseObject(value.settings || {}, `profiles[${profileIndex}].originalEffects[${effectIndex}].settings`)
  };
}

function normalizeSource(source, profileIndex, sourceIndex) {
  const value = source || {};
  const sourceType = validateEnum(
    (value.sourceType || value.source_type || "community_forum").toLowerCase(),
    allowedSourceTypes,
    `profiles[${profileIndex}].sources[${sourceIndex}].sourceType`
  );
  return {
    sourceType,
    title: requiredString(value.title, `profiles[${profileIndex}].sources[${sourceIndex}].title`),
    url: optionalString(value.url),
    notes: optionalString(value.notes),
    credibility: clampInteger(parseOptionalInteger(value.credibility) ?? 50, 0, 100)
  };
}

async function upsertArtist(supabase, artist) {
  const payload = {
    name: artist.name,
    slug: artist.slug,
    country: artist.country,
    external_ids: artist.externalIds,
    search_text: [artist.name, artist.slug.replaceAll("-", " ")].join(" "),
    is_active: true
  };

  const { data, error } = await supabase.from("artists").upsert(payload, { onConflict: "slug" }).select("id").single();
  if (error || !data?.id) {
    fail(`Artist upsert failed for ${artist.name}: ${error?.message || "unknown error"}`);
  }
  return data.id;
}

async function upsertSong(supabase, artistId, song, artistName) {
  const payload = {
    artist_id: artistId,
    title: song.title,
    slug: song.slug,
    album: song.album,
    release_year: song.releaseYear,
    duration_seconds: song.durationSeconds,
    external_ids: song.externalIds,
    search_text: [song.title, artistName, song.album].filter(Boolean).join(" "),
    is_active: true
  };

  const { data, error } = await supabase.from("songs").upsert(payload, { onConflict: "artist_id,slug" }).select("id").single();
  if (error || !data?.id) {
    fail(`Song upsert failed for ${song.title}: ${error?.message || "unknown error"}`);
  }
  return data.id;
}

async function upsertToneProfile(supabase, songId, profile) {
  const payload = {
    song_id: songId,
    song_title: profile.song.title,
    artist_name: profile.artist.name,
    mode: profile.mode,
    part_type: profile.partType,
    part_label: profile.partLabel,
    tone_type: profile.toneType,
    original_guitar: profile.originalGuitar,
    original_amp: profile.originalAmp,
    original_cab: profile.originalCab,
    original_pickup: profile.originalPickup,
    original_effects: profile.effects.map((effect) => ({
      type: effect.effectType,
      name: effect.effectName,
      placement: effect.placement,
      settings: effect.settings
    })),
    original_settings: profile.originalSettings,
    adaptation_notes: profile.adaptationNotes,
    playing_notes: profile.playingNotes,
    source_summary: profile.sourceSummary,
    confidence: profile.confidence,
    verification_status: profile.verificationStatus,
    search_text: profile.searchText,
    is_public: profile.isPublic
  };

  const { data, error } = await supabase
    .from("song_tone_profiles")
    .upsert(payload, { onConflict: "song_id,mode,part_type,tone_type,part_label" })
    .select("id")
    .single();

  if (error || !data?.id) {
    fail(`Tone profile upsert failed for ${profile.song.title} (${profile.partLabel}): ${error?.message || "unknown error"}`);
  }
  return data.id;
}

async function replaceEffects(supabase, profileId, effects) {
  const { error: deleteError } = await supabase.from("tone_profile_effects").delete().eq("profile_id", profileId);
  if (deleteError) {
    fail(`Failed clearing effects for profile ${profileId}: ${deleteError.message}`);
  }

  if (!effects.length) {
    return;
  }

  const { error } = await supabase.from("tone_profile_effects").insert(
    effects.map((effect) => ({
      profile_id: profileId,
      effect_order: effect.effectOrder,
      effect_type: effect.effectType,
      effect_name: effect.effectName,
      placement: effect.placement,
      settings: effect.settings
    }))
  );

  if (error) {
    fail(`Failed inserting effects for profile ${profileId}: ${error.message}`);
  }
}

async function replaceSources(supabase, profileId, sources) {
  const { error: deleteError } = await supabase.from("tone_profile_sources").delete().eq("profile_id", profileId);
  if (deleteError) {
    fail(`Failed clearing sources for profile ${profileId}: ${deleteError.message}`);
  }

  if (!sources.length) {
    return;
  }

  const { error } = await supabase.from("tone_profile_sources").insert(
    sources.map((source) => ({
      profile_id: profileId,
      source_type: source.sourceType,
      title: source.title,
      url: source.url,
      notes: source.notes,
      credibility: source.credibility
    }))
  );

  if (error) {
    fail(`Failed inserting sources for profile ${profileId}: ${error.message}`);
  }
}

function parseStructuredField(value, fallback) {
  if (value == null || value === "") {
    return fallback;
  }

  if (typeof value !== "string") {
    return value;
  }

  try {
    return JSON.parse(value);
  } catch {
    return fallback;
  }
}

function parseLooseArray(value, fieldName) {
  const parsed = typeof value === "string" ? parseJsonString(value, fieldName) : value;
  if (parsed == null || parsed === "") {
    return [];
  }
  if (!Array.isArray(parsed)) {
    fail(`${fieldName} must be an array.`);
  }
  return parsed;
}

function parseLooseObject(value, fieldName) {
  const parsed = typeof value === "string" ? parseJsonString(value, fieldName) : value;
  if (parsed == null || parsed === "") {
    return {};
  }
  if (typeof parsed !== "object" || Array.isArray(parsed)) {
    fail(`${fieldName} must be an object.`);
  }
  return parsed;
}

function parseLooseStringArray(value, fieldName) {
  const parsed = typeof value === "string" ? parseJsonString(value, fieldName) : value;
  if (parsed == null || parsed === "") {
    return [];
  }
  if (Array.isArray(parsed)) {
    return parsed.map((item) => String(item).trim()).filter(Boolean);
  }
  fail(`${fieldName} must be an array of strings.`);
}

function parseJsonString(value, fieldName) {
  const trimmed = value.trim();
  if (!trimmed) {
    return undefined;
  }
  try {
    return JSON.parse(trimmed);
  } catch {
    fail(`${fieldName} contains invalid JSON.`);
  }
}

function parseOptionalInteger(value) {
  if (value == null || value === "") {
    return null;
  }
  const numberValue = Number(value);
  if (!Number.isFinite(numberValue)) {
    return null;
  }
  return Math.trunc(numberValue);
}

function parseOptionalNumber(value) {
  if (value == null || value === "") {
    return null;
  }
  const numberValue = Number(value);
  return Number.isFinite(numberValue) ? numberValue : null;
}

function parseOptionalBoolean(value) {
  if (value == null || value === "") {
    return undefined;
  }
  if (typeof value === "boolean") {
    return value;
  }
  const normalized = String(value).trim().toLowerCase();
  if (["true", "1", "yes"].includes(normalized)) return true;
  if (["false", "0", "no"].includes(normalized)) return false;
  return undefined;
}

function requiredString(value, fieldName) {
  const normalized = optionalString(value);
  if (!normalized) {
    fail(`${fieldName} is required.`);
  }
  return normalized;
}

function optionalString(value) {
  if (value == null) {
    return null;
  }
  const normalized = String(value).trim();
  return normalized || null;
}

function validateEnum(value, allowedValues, fieldName) {
  if (!allowedValues.has(value)) {
    fail(`${fieldName} must be one of: ${Array.from(allowedValues).join(", ")}. Received: ${value || "<empty>"}`);
  }
  return value;
}

function normalizePartType(value) {
  const normalized = String(value || "").trim().toLowerCase();
  if (allowedPartTypes.has(normalized)) {
    return normalized;
  }
  if (normalized.includes("solo")) return "solo";
  if (normalized.includes("lead")) return "lead";
  if (normalized.includes("riff")) return "riff";
  if (normalized.includes("rhythm")) return "rhythm";
  if (normalized.includes("intro")) return "intro";
  if (normalized.includes("chorus")) return "chorus";
  if (normalized.includes("bridge")) return "bridge";
  if (normalized.includes("bass")) return "bassline";
  return "main";
}

function buildProfileSearchText(profile) {
  return [profile.songTitle, profile.artistName, profile.partLabel, profile.toneType, profile.mode, profile.originalGuitar, profile.originalAmp]
    .filter(Boolean)
    .join(" ");
}

function slugify(value) {
  return String(value || "")
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/(^-|-$)+/g, "") || "unknown";
}

function clampInteger(value, min, max) {
  return Math.max(min, Math.min(max, Math.trunc(value)));
}

function fail(message) {
  console.error(`Import failed: ${message}`);
  process.exit(1);
}