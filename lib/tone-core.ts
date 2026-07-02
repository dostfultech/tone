import { createHash } from "node:crypto";
import type { SupabaseClient } from "@supabase/supabase-js";
import { buildToneResult, type ToneRequest, type ToneType } from "@/lib/mock-data";
import type { ToneProfile } from "@/lib/tone-profiles";

type CoreToneResult = ReturnType<typeof buildToneResult>;

type CoreResolution = {
  result: CoreToneResult;
  source: "cache" | "rule";
  cacheKey: string;
  hitType: "exact" | "miss";
};

type ResolveCoreToneOptions = {
  admin?: SupabaseClient | null;
  userId?: string | null;
  requestId?: string | null;
};

type CacheRow = {
  id: string;
  result_json: CoreToneResult;
  confidence: number;
  expires_at: string | null;
  hit_count: number | null;
};

type EquipmentProfileType = "guitar" | "bass_guitar" | "amp" | "bass_amp" | "cabinet" | "pickup" | "multi_fx";

type GearRelation = {
  brand?: string | null;
  model?: string | null;
  item_type?: string | null;
  search_text?: string | null;
};

type EquipmentProfile = {
  id: string;
  gear_item_id: string;
  equipment_type: EquipmentProfileType;
  profile_version: number;
  transfer_class: string;
  search_text: string;
  behavior_profile: Record<string, unknown>;
  confidence: number;
  gear_items?: GearRelation | GearRelation[] | null;
};

type EquipmentResolution = {
  guitar: EquipmentProfile | null;
  amp: EquipmentProfile | null;
  missing: string[];
  signature: string;
};

const CORE_SCHEMA_VERSION = 2;
export const TONE_CORE_MODEL_NAME = `tone-core-v${CORE_SCHEMA_VERSION}`;
const DEFAULT_CACHE_TTL_DAYS = 180;
const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const KNOB_KEYS = ["gain", "bass", "mids", "treble", "presence", "reverb", "delay", "compression", "master"];

export function isToneCoreResolverEnabled() {
  return process.env.TONE_GENERATION_MODE === "hybrid_core" || process.env.TONE_CORE_RESOLVER === "true";
}

export async function resolveCoreTone(
  request: ToneRequest,
  toneProfile: ToneProfile | null,
  options: ResolveCoreToneOptions = {}
): Promise<CoreResolution | null> {
  if (!isToneCoreResolverEnabled()) {
    return null;
  }

  const startedAt = Date.now();
  const equipment = await resolveEquipmentProfiles(options.admin, request);
  const equipmentSummary = summarizeEquipmentResolution(equipment);
  const cacheKey = toneProfile ? buildToneCacheKey(request, toneProfile, equipment) : null;
  const sourceProfileId = toneProfile ? toDatabaseUuid(toneProfile.id) : null;

  if (!toneProfile || !cacheKey) {
    await recordTelemetry(options.admin, {
      userId: options.userId,
      requestId: options.requestId,
      sourceProfileId: null,
      mode: request.mode,
      hitType: "fallback",
      resultSource: "ai_fallback",
      latencyMs: Date.now() - startedAt,
      aiUsed: true,
      metadata: {
        reason: "missing_master_tone",
        requestSignature: buildToneRequestSignature(request),
        equipment: equipmentSummary
      }
    });
    return null;
  }

  const cached = await readCachedTone(options.admin, cacheKey);
  if (cached) {
    await touchCachedTone(options.admin, cached);
    await recordTelemetry(options.admin, {
      userId: options.userId,
      requestId: options.requestId,
      sourceProfileId,
      cacheId: cached.id,
      mode: request.mode,
      hitType: "exact",
      resultSource: "cache",
      latencyMs: Date.now() - startedAt,
      aiUsed: false,
      metadata: { cacheKey, equipment: equipmentSummary }
    });

    return {
      result: cached.result_json,
      source: "cache",
      cacheKey,
      hitType: "exact"
    };
  }

  const baseResult = buildToneResult(request, toneProfile);
  const result = applyEquipmentProfileAdjustments(baseResult, request, toneProfile, equipment);
  const cacheId = await writeCachedTone(options.admin, request, toneProfile, equipment, cacheKey, result);
  await recordTelemetry(options.admin, {
    userId: options.userId,
    requestId: options.requestId,
    sourceProfileId,
    cacheId,
    mode: request.mode,
    hitType: "miss",
    resultSource: "rule",
    latencyMs: Date.now() - startedAt,
    aiUsed: false,
    metadata: { cacheKey, equipment: equipmentSummary }
  });

  return {
    result,
    source: "rule",
    cacheKey,
    hitType: "miss"
  };
}

function buildToneCacheKey(request: ToneRequest, toneProfile: ToneProfile, equipment: EquipmentResolution) {
  const signature = buildToneRequestSignature(request);
  const source = [
    `schema:${CORE_SCHEMA_VERSION}`,
    `profile:${toneProfile.id}`,
    `equipment:${equipment.signature}`,
    `request:${signature}`
  ].join("|");

  return `tone-core:v${CORE_SCHEMA_VERSION}:${hash(source)}`;
}

function buildToneRequestSignature(request: ToneRequest) {
  return JSON.stringify({
    mode: request.mode,
    song: normalizeText(request.song),
    artist: normalizeText(request.artist),
    part: normalizeText(request.part),
    partType: request.partType || null,
    toneType: request.toneType || null,
    guitar: normalizeText(request.guitar),
    amp: normalizeText(request.amp),
    cabinet: normalizeText(request.cabinet || ""),
    pickup: normalizeText(request.pickup || ""),
    effectsMode: request.effectsMode || null
  });
}

async function resolveEquipmentProfiles(admin: SupabaseClient | null | undefined, request: ToneRequest): Promise<EquipmentResolution> {
  if (!admin) {
    return buildEquipmentResolution(null, null);
  }

  const guitarTypes: EquipmentProfileType[] = request.mode === "bass" ? ["bass_guitar"] : ["guitar"];
  const ampTypes: EquipmentProfileType[] = request.mode === "bass" ? ["bass_amp"] : ["amp", "multi_fx"];
  const [guitar, amp] = await Promise.all([
    findEquipmentProfile(admin, request.guitar, guitarTypes),
    findEquipmentProfile(admin, request.amp, ampTypes)
  ]);

  return buildEquipmentResolution(guitar, amp);
}

function buildEquipmentResolution(guitar: EquipmentProfile | null, amp: EquipmentProfile | null): EquipmentResolution {
  const missing = [
    guitar ? null : "instrument_profile",
    amp ? null : "amp_profile"
  ].filter(Boolean) as string[];

  return {
    guitar,
    amp,
    missing,
    signature: [
      `g:${guitar ? `${guitar.id}:${guitar.profile_version}` : "none"}`,
      `a:${amp ? `${amp.id}:${amp.profile_version}` : "none"}`
    ].join("|")
  };
}

async function findEquipmentProfile(
  admin: SupabaseClient,
  gearName: string,
  equipmentTypes: EquipmentProfileType[]
): Promise<EquipmentProfile | null> {
  const normalized = normalizeText(gearName);
  if (!normalized) return null;

  try {
    const searchQuery = buildEquipmentSearchQuery(normalized);
    let query = admin
      .from("tone_equipment_profiles")
      .select("id, gear_item_id, equipment_type, profile_version, transfer_class, search_text, behavior_profile, confidence, gear_items!inner(brand, model, item_type, search_text)")
      .eq("is_active", true)
      .in("equipment_type", equipmentTypes)
      .order("confidence", { ascending: false })
      .limit(160);

    if (searchQuery) {
      query = query.textSearch("search_text", searchQuery, { config: "simple", type: "websearch" });
    }

    const { data, error } = await query;
    const candidates = !error && data?.length
      ? data as EquipmentProfile[]
      : await findFallbackEquipmentCandidates(admin, equipmentTypes);

    const ranked = candidates
      .map((profile) => ({ profile, score: scoreEquipmentProfile(profile, normalized) }))
      .filter(({ score }) => score >= 42)
      .sort((left, right) => right.score - left.score);

    return ranked[0]?.profile || null;
  } catch {
    return null;
  }
}

function scoreEquipmentProfile(profile: EquipmentProfile, normalizedQuery: string) {
  const gear = getGearRelation(profile);
  const label = normalizeText(`${gear?.brand || ""} ${gear?.model || ""}`);
  const searchText = normalizeText(`${profile.search_text || ""} ${gear?.search_text || ""}`);
  if (!label) return 0;
  if (label === normalizedQuery) return 100;
  if (label.includes(normalizedQuery) || normalizedQuery.includes(label)) return 82;

  const haystack = `${label} ${searchText}`.trim();
  const queryTokens = normalizedQuery.split(" ").filter((token) => token.length > 1);
  const matchedTokens = queryTokens.filter((token) => haystack.includes(token)).length;
  const tokenScore = queryTokens.length ? (matchedTokens / queryTokens.length) * 72 : 0;
  const modelBonus = gear?.model && normalizedQuery.includes(normalizeText(gear.model)) ? 18 : 0;

  return tokenScore + modelBonus;
}

async function findFallbackEquipmentCandidates(admin: SupabaseClient, equipmentTypes: EquipmentProfileType[]) {
  const { data, error } = await admin
    .from("tone_equipment_profiles")
    .select("id, gear_item_id, equipment_type, profile_version, transfer_class, search_text, behavior_profile, confidence, gear_items!inner(brand, model, item_type, search_text)")
    .eq("is_active", true)
    .in("equipment_type", equipmentTypes)
    .order("confidence", { ascending: false })
    .limit(160);

  if (error || !data?.length) return [];
  return data as EquipmentProfile[];
}

function buildEquipmentSearchQuery(normalizedGearName: string) {
  const tokens = normalizedGearName
    .split(" ")
    .map((token) => token.replace(/[^a-z0-9]/g, ""))
    .filter((token) => token.length > 1 || /^\d+$/.test(token));

  const uniqueTokens = Array.from(new Set(tokens)).slice(0, 6);
  if (!uniqueTokens.length) return null;
  return uniqueTokens.join(" OR ");
}

function applyEquipmentProfileAdjustments(
  result: CoreToneResult,
  request: ToneRequest,
  toneProfile: ToneProfile,
  equipment: EquipmentResolution
): CoreToneResult {
  const toneType = request.toneType && request.toneType !== "auto" ? request.toneType : toneProfile.toneType;
  const deltas = mergeKnobDeltas([
    equipment.guitar ? getProfileKnobDeltas(equipment.guitar, toneType) : {},
    equipment.amp ? getProfileKnobDeltas(equipment.amp, toneType) : {}
  ]);

  if (!Object.keys(deltas).length && !equipment.guitar && !equipment.amp) {
    return result;
  }

  const targetSettings = { ...result.targetSettings };
  for (const key of KNOB_KEYS) {
    if (typeof deltas[key] !== "number") continue;
    targetSettings[key] = clampKnob(Number(targetSettings[key] ?? 5) + deltas[key]);
  }

  const equipmentTips = buildEquipmentTips(equipment);
  const pickupAdvice = equipment.guitar
    ? `${result.pickupAdvice} ${summarizeProfileAdvice(equipment.guitar)}`
    : result.pickupAdvice;

  return {
    ...result,
    accuracy: equipment.guitar && equipment.amp ? Math.min(96, result.accuracy + 2) : result.accuracy,
    targetSettings,
    pickupAdvice,
    playingTips: [...equipmentTips, ...result.playingTips].slice(0, 6)
  };
}

function getProfileKnobDeltas(profile: EquipmentProfile, toneType: ToneType) {
  const behavior = safeObject(profile.behavior_profile);
  const eqBias = readKnobMap(behavior.eqBias || behavior.eq_bias);
  const toneTypeAdjustments = safeObject(behavior.toneTypeAdjustments || behavior.tone_type_adjustments);
  const toneSpecific = readKnobMap(toneTypeAdjustments[toneType]);
  return mergeKnobDeltas([eqBias, toneSpecific]);
}

function mergeKnobDeltas(deltaSets: Array<Record<string, number>>) {
  const merged: Record<string, number> = {};

  for (const deltas of deltaSets) {
    for (const [key, value] of Object.entries(deltas)) {
      if (!KNOB_KEYS.includes(key) || !Number.isFinite(value)) continue;
      merged[key] = clampDelta((merged[key] || 0) + value);
    }
  }

  return Object.fromEntries(Object.entries(merged).filter(([, value]) => value !== 0));
}

function buildEquipmentTips(equipment: EquipmentResolution) {
  const tips: string[] = [];

  for (const profile of [equipment.guitar, equipment.amp]) {
    if (!profile) continue;
    const behavior = safeObject(profile.behavior_profile);
    const advice = Array.isArray(behavior.advice) ? behavior.advice.filter((item): item is string => typeof item === "string") : [];
    tips.push(...advice.slice(0, 1));
  }

  if (equipment.missing.length) {
    tips.push("Some gear is not profiled yet, so treat these settings as a practical starting point and refine by ear.");
  }

  return tips.slice(0, 2);
}

function summarizeProfileAdvice(profile: EquipmentProfile) {
  const behavior = safeObject(profile.behavior_profile);
  const outputLevel = typeof behavior.outputLevel === "string" ? behavior.outputLevel.replace("_", " ") : null;
  const gear = getGearRelation(profile);
  const name = [gear?.brand, gear?.model].filter(Boolean).join(" ");

  if (!outputLevel || !name) {
    return "Use your instrument volume as the first fine-tune control.";
  }

  return `${name} is profiled as ${outputLevel} output, so fine-tune gain before changing EQ.`;
}

function summarizeEquipmentResolution(equipment: EquipmentResolution) {
  return {
    signature: equipment.signature,
    missing: equipment.missing,
    guitar: equipment.guitar ? summarizeEquipmentProfile(equipment.guitar) : null,
    amp: equipment.amp ? summarizeEquipmentProfile(equipment.amp) : null
  };
}

function summarizeEquipmentProfile(profile: EquipmentProfile) {
  const gear = getGearRelation(profile);
  return {
    id: profile.id,
    version: profile.profile_version,
    type: profile.equipment_type,
    transferClass: profile.transfer_class,
    name: [gear?.brand, gear?.model].filter(Boolean).join(" ") || null,
    confidence: profile.confidence
  };
}

async function readCachedTone(admin: SupabaseClient | null | undefined, cacheKey: string) {
  if (!admin) return null;

  try {
    const { data, error } = await admin
      .from("tone_adaptation_cache")
      .select("id, result_json, confidence, expires_at, hit_count")
      .eq("cache_key", cacheKey)
      .maybeSingle();

    const cached = data as CacheRow | null;
    if (error || !cached) return null;
    if (cached.expires_at && new Date(cached.expires_at).getTime() <= Date.now()) return null;
    return cached;
  } catch {
    return null;
  }
}

async function touchCachedTone(admin: SupabaseClient | null | undefined, cached: CacheRow) {
  if (!admin) return;

  try {
    await admin
      .from("tone_adaptation_cache")
      .update({
        hit_count: Number(cached.hit_count || 0) + 1,
        last_hit_at: new Date().toISOString()
      })
      .eq("id", cached.id);
  } catch {
    // Cache statistics should never block a tone response.
  }
}

async function writeCachedTone(
  admin: SupabaseClient | null | undefined,
  request: ToneRequest,
  toneProfile: ToneProfile,
  equipment: EquipmentResolution,
  cacheKey: string,
  result: CoreToneResult
) {
  if (!admin) return null;

  const expiresAt = new Date(Date.now() + DEFAULT_CACHE_TTL_DAYS * 24 * 60 * 60 * 1000).toISOString();

  try {
    const { data } = await admin
      .from("tone_adaptation_cache")
      .upsert(
        {
          source_profile_id: toDatabaseUuid(toneProfile.id),
          request_signature: buildToneRequestSignature(request),
          cache_key: cacheKey,
          mode: request.mode,
          song_title: request.song,
          artist_name: request.artist,
          part_label: request.part,
          guitar_name: request.guitar,
          amp_name: request.amp,
          cabinet_name: request.cabinet || null,
          pickup_name: request.pickup || null,
          schema_version: CORE_SCHEMA_VERSION,
          source_profile_version: 1,
          guitar_profile_id: equipment.guitar?.id || null,
          amp_profile_id: equipment.amp?.id || null,
          guitar_profile_version: equipment.guitar?.profile_version || 0,
          amp_profile_version: equipment.amp?.profile_version || 0,
          result_json: result,
          result_source: "rule",
          confidence: result.accuracy,
          expires_at: expiresAt
        },
        { onConflict: "cache_key" }
      )
      .select("id")
      .maybeSingle();

    return (data as { id?: string } | null)?.id || null;
  } catch {
    return null;
  }
}

async function recordTelemetry(
  admin: SupabaseClient | null | undefined,
  event: {
    userId?: string | null;
    requestId?: string | null;
    sourceProfileId?: string | null;
    cacheId?: string | null;
    mode: "guitar" | "bass";
    hitType: "exact" | "miss" | "bypass" | "fallback";
    resultSource: "cache" | "rule" | "ai_fallback" | "legacy_ai" | "manual";
    latencyMs: number;
    aiUsed: boolean;
    metadata?: Record<string, unknown>;
  }
) {
  if (!admin) return;

  try {
    await admin.from("tone_generation_telemetry").insert({
      user_id: event.userId || null,
      request_id: event.requestId || null,
      source_profile_id: event.sourceProfileId || null,
      cache_id: event.cacheId || null,
      mode: event.mode,
      hit_type: event.hitType,
      result_source: event.resultSource,
      latency_ms: Math.max(0, Math.round(event.latencyMs)),
      ai_used: event.aiUsed,
      metadata: event.metadata || {}
    });
  } catch {
    // Telemetry should never block tone generation.
  }
}

function getGearRelation(profile: EquipmentProfile) {
  const relation = profile.gear_items;
  return Array.isArray(relation) ? relation[0] : relation;
}

function readKnobMap(value: unknown) {
  const source = safeObject(value);
  const output: Record<string, number> = {};

  for (const key of KNOB_KEYS) {
    const raw = source[key];
    if (typeof raw === "number" && Number.isFinite(raw)) {
      output[key] = clampDelta(raw);
    }
  }

  return output;
}

function safeObject(value: unknown): Record<string, unknown> {
  return value && typeof value === "object" && !Array.isArray(value) ? value as Record<string, unknown> : {};
}

function normalizeText(value: string) {
  return value.toLowerCase().replace(/[^a-z0-9]+/g, " ").trim();
}

function toDatabaseUuid(value: string | null | undefined) {
  return value && UUID_PATTERN.test(value) ? value : null;
}

function hash(value: string) {
  return createHash("sha256").update(value).digest("hex").slice(0, 32);
}

function clampDelta(value: number) {
  return Math.max(-2, Math.min(2, Math.round(value)));
}

function clampKnob(value: number) {
  return Math.max(0, Math.min(10, Math.round(value)));
}
