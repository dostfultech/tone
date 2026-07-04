import { NextRequest, NextResponse } from "next/server";
import { brand } from "@/lib/brand";
import {
  amps,
  bassAmps,
  bassGuitars,
  cabinets,
  effectsCatalog,
  type GearItem,
  guitars,
  lookupGear,
  multiFxUnits,
  pedalPresets,
  pickups,
  songs,
  type SongItem,
  type TonePartType,
  type ToneType,
  type ToneRequest
} from "@/lib/mock-data";
import { getEntitlement, getCurrentSession } from "@/lib/server-access";
import { lookupGearFromSupabase } from "@/lib/gear-catalog";
import { generateToneResultWithMetadata } from "@/lib/tone-ai";
import { isToneCoreResolverEnabled, resolveCoreTone, TONE_CORE_MODEL_NAME } from "@/lib/tone-core";
import { createSupabaseAdminClient } from "@/lib/supabase/admin";
import { assertCanCreateAdaptation, incrementAdaptationUsage } from "@/lib/usage";
import { buildResearchPayload, createMissingSongRequest, findToneProfile, listCommunityToneProfiles, saveGeneratedMasterTone, type CommunityToneQuery } from "@/lib/tone-profiles";

export const runtime = "nodejs";
export const maxDuration = 60;

const MUSIC_SEARCH_CACHE_TTL_MS = 10 * 60 * 1000;
const MUSIC_SEARCH_CACHE_MAX_ITEMS = 120;
const DEFAULT_MUSIC_SEARCH_LIMIT = 30;
const musicSearchCache = new Map<string, { expiresAt: number; results: SongItem[] }>();
const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

type RouteContext = {
  params: Promise<{ path: string[] }>;
};

export async function GET(request: NextRequest, context: RouteContext) {
  const route = (await context.params).path.join("/");
  const query = request.nextUrl.searchParams.get("q") || request.nextUrl.searchParams.get("name") || "";

  if (route === "amps/lookup") {
    const dbResults = await lookupGearFromSupabase(["amp"], query, { limit: 60 });
    return json({ results: mergeCatalogResults(dbResults, buildGearFallbackResults(lookupGear(amps, query), "amp")) });
  }

  if (route === "guitars/lookup") {
    const dbResults = await lookupGearFromSupabase(["guitar", "acoustic_guitar"], query, { limit: 80 });
    return json({
      results: mergeCatalogResults(dbResults, buildGearFallbackResults(lookupGear(guitars, query), "guitar")),
      pickups
    });
  }

  if (route === "bass-amps/lookup") {
    const dbResults = await lookupGearFromSupabase(["bass_amp"], query, { limit: 40 });
    return json({ results: mergeCatalogResults(dbResults, buildGearFallbackResults(lookupGear(bassAmps, query), "bass_amp")) });
  }

  if (route === "bass-guitars/lookup") {
    const dbResults = await lookupGearFromSupabase(["bass_guitar"], query, { limit: 40 });
    return json({ results: mergeCatalogResults(dbResults, buildGearFallbackResults(lookupGear(bassGuitars, query), "bass_guitar")) });
  }

  if (route === "acoustic-guitars/lookup") {
    const dbResults = await lookupGearFromSupabase(["acoustic_guitar"], query, { limit: 40 });
    return json({ results: mergeCatalogResults(dbResults, buildGearFallbackResults(lookupGear(guitars, query), "acoustic_guitar")) });
  }

  if (route === "pickups/catalog") {
    const dbResults = await lookupGearFromSupabase(["pickup"], query, { limit: 40 });
    return json({
      results: mergeCatalogResults(
        dbResults,
        pickups.map((item) => ({
          id: item.id,
          name: item.name,
          category: item.category,
          description: item.category,
          details: item.category ? [item.category] : []
        }))
      )
    });
  }

  if (route === "music/search") {
    const normalized = query.trim().toLowerCase();
    const resultLimit = getMusicSearchLimit();
    const liveResults = await searchExternalSongs(query);
    const localResults = searchLocalSongs(normalized, resultLimit);

    if (liveResults.length) {
      return json({ results: mergeSongResults(liveResults, localResults, resultLimit) });
    }

    return json({ results: localResults });
  }

  if (route === "trending-tones") {
    return json({ results: songs });
  }

  if (route === "pedals/user" || route === "pedals/presets" || route === "pedals/catalog") {
    const dbResults = await lookupGearFromSupabase(["pedal", "effect"], query, { limit: 80 });
    return json({
      results: mergeCatalogResults(
        dbResults,
        pedalPresets.map((preset) => ({
          id: preset.id,
          name: preset.name,
          category: preset.category,
          description: preset.pedals.join(" | "),
          details: preset.pedals
        }))
      )
    });
  }

  if (route === "multi-fx/user" || route === "multi-fx/catalog") {
    const dbResults = await lookupGearFromSupabase(["multi_fx"], query, { limit: 40 });
    return json({
      results: mergeCatalogResults(
        dbResults,
        multiFxUnits
          .filter((unit) => `${unit.brand} ${unit.name}`.toLowerCase().includes(query.toLowerCase()))
          .map((unit) => ({
            id: unit.id,
            name: unit.name,
            category: "multi_fx",
            description: unit.brand,
            details: [unit.brand]
          }))
      )
    });
  }

  if (route === "cabinets/catalog") {
    const dbResults = await lookupGearFromSupabase(["cabinet"], query, { limit: 60 });
    return json({ results: mergeCatalogResults(dbResults, buildGearFallbackResults(lookupGear(cabinets, query), "cabinet")) });
  }

  if (route === "effects/catalog") {
    const dbResults = await lookupGearFromSupabase(["effect"], query, { limit: 60 });
    return json({ results: mergeCatalogResults(dbResults, buildGearFallbackResults(lookupGear(effectsCatalog, query), "effect")) });
  }

  if (route === "community-tones/lookup") {
    return json(await listCommunityToneProfiles(parseCommunityToneQuery(request)));
  }

  if (route === "promo-credit/usage") {
    return json({ credits: 5, used: 0, source: "signup" });
  }

  if (route === "gear-onboarding/status") {
    return json({ dismissed: false, required: true });
  }

  if (route === "songsterr") {
    return json({ tabs: [{ title: query || "Requested song", tuning: "E standard", confidence: 82 }] });
  }

  return json({ ok: true, route, query });
}

export async function POST(request: NextRequest, context: RouteContext) {
  const route = (await context.params).path.join("/");
  const body = await safeBody(request);

  if (route === "research-tone" || route === "research-bass-tone") {
    const requestBody = normalizeToneRequest(body);
    const { user } = await getCurrentSession();
    const toneProfile = await findToneProfile(requestBody);
    if (!toneProfile) {
      await createMissingSongRequest(requestBody, user?.id || null);
    }
    return json({ research: buildResearchPayload(requestBody, toneProfile) });
  }

  if (route === "adapt-tone" || route === "adapt-bass-tone" || route === "adapt-multi-fx-tone") {
    const requestBody = normalizeToneRequest(body);
    const { supabase, user } = await getCurrentSession();
    const admin = createSupabaseAdminClient();

    if (supabase && !user) {
      return NextResponse.json({ error: "Authentication required" }, { status: 401 });
    }

    let toneJobId: string | null = null;
    if (user) {
      const entitlement = await getEntitlement(supabase, user);
      const canCreate = await assertCanCreateAdaptation(admin, user, entitlement);
      if (!canCreate.ok) {
        return NextResponse.json({ error: canCreate.error }, { status: 402 });
      }

      if (admin) {
        const { data: job } = await admin.from("tone_jobs").insert({
          user_id: user.id,
          mode: requestBody.mode,
          song: requestBody.song,
          artist: requestBody.artist,
          part: requestBody.part,
          input_gear: requestBody,
          status: "running",
          model: isToneCoreResolverEnabled() ? TONE_CORE_MODEL_NAME : process.env.OPENAI_MODEL || "gpt-4.1-nano"
        }).select("id").single();
        toneJobId = job?.id || null;
      }
    }

    const toneProfile = await findToneProfile(requestBody);
    if (!toneProfile) {
      await createMissingSongRequest(requestBody, user?.id || null);
    }
    const coreResolution = await resolveCoreTone(requestBody, toneProfile, { admin, userId: user?.id || null, requestId: toneJobId });
    if (coreResolution.fallbackReason === "missing_admin_client") {
      return NextResponse.json(
        { error: "Tone core resolver requires SUPABASE_SERVICE_ROLE_KEY when hybrid core mode is enabled." },
        { status: 503 }
      );
    }
    let aiGeneration: Awaited<ReturnType<typeof generateToneResultWithMetadata>> | null = null;
    if (!coreResolution.result) {
      aiGeneration = await generateToneResultWithMetadata(requestBody, toneProfile);
      if (!toneProfile && aiGeneration.openAiSucceeded) {
        await saveGeneratedMasterTone(requestBody, aiGeneration.result, user?.id || null);
      }
    }
    const result = coreResolution.result || aiGeneration!.result;
    const usedCore = coreResolution.source === "cache" || coreResolution.source === "rule";
    const resolvedModel = usedCore ? TONE_CORE_MODEL_NAME : process.env.OPENAI_MODEL || "gpt-4.1-nano";
    const source = buildAdaptationSourceLog(route, requestBody, toneProfile, coreResolution, aiGeneration, toneJobId);
    console.info("[tonefex:adaptation]", source);

    if (user && admin && toneJobId) {
      await admin.from("tone_jobs").update({ model: resolvedModel, status: "succeeded" }).eq("id", toneJobId);
      const { data: savedResult } = await admin.from("tone_results").insert({
        job_id: toneJobId,
        user_id: user.id,
        result,
        confidence: result.accuracy
      }).select("id").single();
      await incrementAdaptationUsage(admin, user.id, toneJobId);
      return json({ result: { ...result, toneResultId: savedResult?.id || null }, source });
    }

    return json({ result, source });
  }

  if (route === "save-tone") {
    const { supabase, user } = await getCurrentSession();
    if (supabase && !user) {
      return NextResponse.json({ error: "Authentication required" }, { status: 401 });
    }

    if (supabase && user) {
      const entitlement = await getEntitlement(supabase, user);
      if (!entitlement.hasAccess) {
        return NextResponse.json({ error: "This feature requires a Beginner or Expert plan." }, { status: 402 });
      }

      const tone = body.result || body;
      const requestBody = tone.request || body.request || {};
      const { error } = await supabase.from("saved_tones").insert({
        user_id: user.id,
        tone_result_id: body.toneResultId || tone.toneResultId || null,
        song: requestBody.song || "Unknown Song",
        artist: requestBody.artist || "Unknown Artist",
        part: requestBody.part || "main part",
        mode: requestBody.mode === "bass" ? "bass" : "guitar",
        request: requestBody,
        result: tone,
        notes: body.notes || null
      });

      if (error) {
        return NextResponse.json({ error: error.message }, { status: 500 });
      }
    }

    return json({ saved: true, tone: body, message: "Tone saved." });
  }

  if (route === "ab-variant/view") {
    return json({ tracked: true, ...body });
  }

  if (route === "gear-onboarding/dismiss") {
    return json({ dismissed: true });
  }

  if (route === "grant-signup-credit") {
    return json({ granted: true, credits: 5 });
  }

  if (route === "account/delete") {
    return NextResponse.json({ error: "Use /api/account/delete" }, { status: 410 });
  }

  return json({ ok: true, route, body });
}

async function safeBody(request: NextRequest) {
  try {
    return await request.json();
  } catch {
    return {};
  }
}

function normalizeToneRequest(body: Partial<ToneRequest> & Record<string, unknown>): ToneRequest {
  const effectsMode = typeof body.effectsMode === "string" ? body.effectsMode : "manual";
  const goingDirect = body.goingDirect === true || effectsMode === "multi_fx";
  const customPickups = normalizeCustomPickups(body) as ToneRequest["customPickups"];

  return {
    mode: body.mode === "bass" ? "bass" : "guitar",
    song: body.song || "Unknown Song",
    artist: body.artist || "Unknown Artist",
    part: body.part || "main part",
    partType: normalizePartType(body.partType, body.part),
    toneType: normalizeToneType(body.toneType),
    guitar: body.guitar || (body.mode === "bass" ? "Fender Precision Bass" : "Fender Stratocaster"),
    amp: body.amp || (body.mode === "bass" ? "Ampeg SVT-CL" : "Fender Deluxe Reverb"),
    cabinet: body.cabinet || (body.mode === "bass" ? "Ampeg SVT-410HLF" : "Mesa/Boogie Rectifier 4x12"),
    pickup: body.pickup || "bridge pickup",
    effectsMode,
    multiFx: typeof body.multiFx === "string" ? body.multiFx : undefined,
    selectedFx: typeof body.selectedFx === "string" ? body.selectedFx : undefined,
    goingDirect,
    customPickups: customPickups && Object.keys(customPickups).length ? customPickups : undefined
  };
}

function normalizeCustomPickups(body: Record<string, unknown>) {
  const source = body.customPickups && typeof body.customPickups === "object" && !Array.isArray(body.customPickups)
    ? body.customPickups as Record<string, unknown>
    : body;
  const pickups = {
    neck: typeof source.neck === "string" ? source.neck : typeof source.neckPickup === "string" ? source.neckPickup : "",
    middle: typeof source.middle === "string" ? source.middle : typeof source.middlePickup === "string" ? source.middlePickup : "",
    bridge: typeof source.bridge === "string" ? source.bridge : typeof source.bridgePickup === "string" ? source.bridgePickup : ""
  };

  return Object.fromEntries(Object.entries(pickups).filter(([, value]) => value.trim().length > 0));
}

function normalizePartType(value?: string, part?: string): TonePartType {
  const allowed: TonePartType[] = ["main", "riff", "solo", "lead", "rhythm", "intro", "chorus", "bridge", "bassline"];
  if (allowed.includes(value as TonePartType)) {
    return value as TonePartType;
  }

  const normalized = (part || "").toLowerCase();
  if (normalized.includes("solo")) return "solo";
  if (normalized.includes("lead")) return "lead";
  if (normalized.includes("riff")) return "riff";
  if (normalized.includes("intro")) return "intro";
  if (normalized.includes("chorus")) return "chorus";
  if (normalized.includes("bass")) return "bassline";
  if (normalized.includes("rhythm")) return "rhythm";
  return "main";
}

function normalizeToneType(value?: string): ToneType {
  const allowed: ToneType[] = ["auto", "clean", "crunch", "distorted", "high_gain", "fuzz", "acoustic", "bass_clean", "bass_drive"];
  return allowed.includes(value as ToneType) ? (value as ToneType) : "auto";
}

function json(data: unknown) {
  return NextResponse.json(data, {
    headers: {
      "Cache-Control": "no-store"
    }
  });
}

function buildAdaptationSourceLog(
  route: string,
  request: ToneRequest,
  toneProfile: { id: string } | null,
  coreResolution: Awaited<ReturnType<typeof resolveCoreTone>>,
  aiGeneration: Awaited<ReturnType<typeof generateToneResultWithMetadata>> | null,
  requestId: string | null
) {
  const masterToneSource = classifyToneProfileSource(toneProfile);
  const resultPath =
    coreResolution.source === "cache"
      ? "database_cache"
      : coreResolution.source === "rule"
        ? "tone_core_rule_engine"
        : aiGeneration?.source === "openai"
          ? "openai"
          : "local_fallback";
  const cacheStatus = getCacheStatus(coreResolution);
  const sourceLabel = getSourceLabel(resultPath, cacheStatus, coreResolution.fallbackReason, aiGeneration?.reason);
  const openAiCalled = Boolean(aiGeneration?.openAiCalled);
  const openAiSucceeded = Boolean(aiGeneration?.openAiSucceeded);
  const aiResultUsed = resultPath === "openai";
  const ruleEngineUsed = coreResolution.source === "rule";
  const databaseCacheUsed = coreResolution.source === "cache";
  const cacheWrite = coreResolution.cacheWriteStatus || (ruleEngineUsed ? "unknown" : "not_applicable");

  return {
    event: "tone_adaptation_complete",
    route,
    requestId,
    finalSource: sourceLabel,
    resultPath,
    sourceLabel,
    masterToneSource,
    aiFallbackTriggered: coreResolution.source === "ai_fallback",
    aiUsed: aiResultUsed,
    aiResultUsed,
    openAiCalled,
    openAiSucceeded,
    ruleEngineUsed,
    databaseCacheUsed,
    databaseUsed: coreResolution.source === "cache" || coreResolution.source === "rule" || masterToneSource === "database",
    cacheStatus,
    cacheHit: databaseCacheUsed,
    cacheMiss: ruleEngineUsed,
    cacheWrite,
    cacheId: coreResolution.cacheId || null,
    coreSource: coreResolution.source,
    hitType: coreResolution.hitType,
    fallbackReason: coreResolution.fallbackReason || aiGeneration?.reason || null,
    model: coreResolution.source === "cache" || coreResolution.source === "rule" ? TONE_CORE_MODEL_NAME : aiGeneration?.model,
    song: request.song,
    artist: request.artist,
    mode: request.mode,
    targetGear: {
      guitar: request.guitar,
      amp: request.amp,
      cabinet: request.cabinet || null,
      pickup: request.pickup || null,
      customPickups: request.customPickups || null,
      effectsMode: request.effectsMode || null,
      multiFx: request.multiFx || null,
      selectedFx: request.selectedFx || null,
      goingDirect: Boolean(request.goingDirect)
    }
  };
}

function getCacheStatus(coreResolution: Awaited<ReturnType<typeof resolveCoreTone>>) {
  if (coreResolution.source === "cache") {
    return "hit";
  }

  if (coreResolution.source === "rule") {
    if (coreResolution.cacheWriteStatus === "succeeded") {
      return "miss_rule_engine_cache_write_succeeded";
    }

    if (coreResolution.cacheWriteStatus === "failed") {
      return "miss_rule_engine_cache_write_failed";
    }

    return "miss_rule_engine_cache_write_unknown";
  }

  if (coreResolution.fallbackReason === "resolver_disabled") {
    return "bypassed_resolver_disabled";
  }

  if (coreResolution.fallbackReason === "missing_master_tone") {
    return "not_checked_missing_master_tone";
  }

  if (coreResolution.fallbackReason === "internal_error") {
    return "not_checked_resolver_error";
  }

  return "not_checked";
}

function getSourceLabel(
  resultPath: string,
  cacheStatus: string,
  coreFallbackReason?: string,
  aiReason?: string
) {
  if (resultPath === "database_cache") {
    return "CACHE_HIT_FROM_TONE_ADAPTATION_CACHE";
  }

  if (resultPath === "tone_core_rule_engine") {
    if (cacheStatus === "miss_rule_engine_cache_write_succeeded") {
      return "CACHE_MISS_RULE_ENGINE_WRITTEN_TO_CACHE";
    }

    if (cacheStatus === "miss_rule_engine_cache_write_failed") {
      return "CACHE_MISS_RULE_ENGINE_CACHE_WRITE_FAILED";
    }

    return "CACHE_MISS_RULE_ENGINE_GENERATED";
  }

  if (resultPath === "openai") {
    return "OPENAI_RESULT_USED";
  }

  if (coreFallbackReason === "missing_master_tone") {
    return `LOCAL_FALLBACK_NO_MASTER_TONE_${aiReason || "NO_OPENAI_RESULT"}`.toUpperCase();
  }

  if (cacheStatus.startsWith("bypassed")) {
    return `LOCAL_FALLBACK_${cacheStatus}`.toUpperCase();
  }

  return `LOCAL_FALLBACK_${aiReason || coreFallbackReason || "UNKNOWN_REASON"}`.toUpperCase();
}

function classifyToneProfileSource(toneProfile: { id: string } | null) {
  if (!toneProfile) {
    return "missing";
  }

  return UUID_PATTERN.test(toneProfile.id) ? "database" : "starter_catalog";
}

function parseCommunityToneQuery(request: NextRequest): CommunityToneQuery {
  const params = request.nextUrl.searchParams;
  const instrument = params.get("instrument");
  const part = params.get("part");
  const tone = params.get("tone");
  const sort = params.get("sort");
  const page = Number(params.get("page") || "1");
  const pageSize = Number(params.get("pageSize") || "24");

  return {
    query: params.get("q") || "",
    instrument: instrument === "guitar" || instrument === "bass" || instrument === "all" ? instrument : "all",
    part: part === "riff" || part === "solo" || part === "all" ? part : "all",
    tone: tone === "clean" || tone === "distorted" || tone === "all" ? tone : "all",
    sort: sort === "popular" || sort === "recent" || sort === "top" ? sort : "top",
    page: Number.isFinite(page) && page > 0 ? page : 1,
    pageSize: Number.isFinite(pageSize) && pageSize > 0 ? pageSize : 24
  };
}

function scoreSongResult(song: { song: string; artist: string; album: string; part: string }, query: string) {
  if (!query) return 1;
  const title = song.song.toLowerCase();
  const artist = song.artist.toLowerCase();
  const album = song.album.toLowerCase();
  const part = song.part.toLowerCase();
  let score = 0;
  if (title === query) score += 100;
  if (title.startsWith(query)) score += 70;
  if (title.includes(query)) score += 45;
  if (artist.startsWith(query)) score += 30;
  if (artist.includes(query)) score += 20;
  if (album.includes(query)) score += 10;
  if (part.includes(query)) score += 5;
  return score;
}

function searchLocalSongs(query: string, limit: number) {
  return songs
    .filter((song) => {
      const haystack = `${song.song} ${song.artist} ${song.album} ${song.part}`.toLowerCase();
      return !query || haystack.includes(query);
    })
    .sort((a, b) => scoreSongResult(b, query) - scoreSongResult(a, query))
    .slice(0, limit);
}

function mergeSongResults(primary: SongItem[], fallback: SongItem[], limit: number) {
  const seen = new Set<string>();
  const merged: SongItem[] = [];

  for (const song of [...primary, ...fallback]) {
    const key = `${song.song}|${song.artist}|${song.album}`.toLowerCase();
    if (seen.has(key)) continue;
    seen.add(key);
    merged.push(song);
    if (merged.length >= limit) break;
  }

  return merged;
}

function getMusicSearchLimit() {
  const configured = Number(process.env.MUSIC_SEARCH_RESULT_LIMIT);
  if (!Number.isFinite(configured) || configured <= 0) {
    return DEFAULT_MUSIC_SEARCH_LIMIT;
  }
  return Math.min(Math.max(Math.round(configured), 10), 50);
}

type ItunesTrack = {
  trackId?: number;
  trackName?: string;
  artistName?: string;
  collectionName?: string;
  artworkUrl100?: string;
  trackTimeMillis?: number;
  primaryGenreName?: string;
  kind?: string;
};

async function searchExternalSongs(query: string) {
  const term = query.trim();
  if (term.length < 2) {
    return [];
  }

  const country = (process.env.MUSIC_SEARCH_COUNTRY || "IN").toUpperCase();
  const limit = getMusicSearchLimit();
  const cacheKey = `${country}:${limit}:${term.toLowerCase()}`;
  const cached = musicSearchCache.get(cacheKey);
  if (cached && cached.expiresAt > Date.now()) {
    return cached.results;
  }

  const params = new URLSearchParams({
    term,
    country,
    media: "music",
    entity: "song",
    limit: String(Math.min(limit + 20, 50))
  });

  try {
    const payload = await fetchItunesJson(`https://itunes.apple.com/search?${params.toString()}`);
    const seen = new Set<string>();
    const results: SongItem[] = [];

    for (const track of payload.results || []) {
      if (track.kind !== "song" || !track.trackName || !track.artistName) continue;

      const dedupeKey = `${track.trackName}|${track.artistName}|${track.collectionName}`.toLowerCase();
      if (seen.has(dedupeKey)) continue;
      seen.add(dedupeKey);

      const song: SongItem = {
        id: `itunes-${track.trackId || `${track.artistName}-${track.trackName}`}`,
        song: track.trackName,
        artist: track.artistName,
        part: inferDefaultPart(track.primaryGenreName),
        mode: inferMode(track.primaryGenreName),
        album: track.collectionName || "Single",
        duration: formatDuration(track.trackTimeMillis),
        artworkColor: colorFromText(`${track.artistName}-${track.trackName}`),
        source: "itunes"
      };

      if (track.artworkUrl100) {
        song.artworkUrl = track.artworkUrl100.replace("100x100bb", "160x160bb");
      }

      results.push(song);
      if (results.length >= limit) break;
    }

    cacheSongResults(cacheKey, results);
    return results;
  } catch {
    return [];
  }
}

function cacheSongResults(cacheKey: string, results: SongItem[]) {
  if (!results.length) return;

  if (musicSearchCache.size >= MUSIC_SEARCH_CACHE_MAX_ITEMS) {
    const now = Date.now();
    for (const [key, cached] of musicSearchCache) {
      if (cached.expiresAt <= now || musicSearchCache.size >= MUSIC_SEARCH_CACHE_MAX_ITEMS) {
        musicSearchCache.delete(key);
      }
      if (musicSearchCache.size < MUSIC_SEARCH_CACHE_MAX_ITEMS) break;
    }
  }

  musicSearchCache.set(cacheKey, {
    expiresAt: Date.now() + MUSIC_SEARCH_CACHE_TTL_MS,
    results
  });
}

async function fetchItunesJson(url: string): Promise<{ results?: ItunesTrack[] }> {
  try {
    const response = await fetch(url, {
      cache: "no-store",
      headers: {
        "User-Agent": `${brand.appName}/1.0`
      }
    });
    if (!response.ok) return {};
    return (await response.json()) as { results?: ItunesTrack[] };
  } catch (error) {
    const cause = error instanceof Error ? (error as Error & { cause?: { code?: string } }).cause : undefined;
    const canUseInsecureFallback =
      cause?.code === "UNABLE_TO_VERIFY_LEAF_SIGNATURE" &&
      (process.env.NODE_ENV !== "production" || process.env.MUSIC_SEARCH_ALLOW_INSECURE_TLS === "true");

    if (!canUseInsecureFallback) {
      return {};
    }

    return fetchItunesJsonWithHttps(url);
  }
}

async function fetchItunesJsonWithHttps(url: string): Promise<{ results?: ItunesTrack[] }> {
  const https = await import("node:https");
  return new Promise((resolve) => {
    const request = https.get(
      url,
      {
        rejectUnauthorized: false,
        headers: {
          "User-Agent": `${brand.appName}/1.0`
        }
      },
      (response) => {
        if ((response.statusCode || 500) >= 400) {
          response.resume();
          resolve({});
          return;
        }
        const chunks: Buffer[] = [];
        response.on("data", (chunk) => chunks.push(Buffer.from(chunk)));
        response.on("end", () => {
          try {
            resolve(JSON.parse(Buffer.concat(chunks).toString("utf8")) as { results?: ItunesTrack[] });
          } catch {
            resolve({});
          }
        });
      }
    );
    request.setTimeout(6000, () => {
      request.destroy();
      resolve({});
    });
    request.on("error", () => resolve({}));
  });
}

function formatDuration(milliseconds?: number) {
  if (!milliseconds || milliseconds <= 0) {
    return "--:--";
  }
  const totalSeconds = Math.round(milliseconds / 1000);
  const minutes = Math.floor(totalSeconds / 60);
  const seconds = String(totalSeconds % 60).padStart(2, "0");
  return `${minutes}:${seconds}`;
}

function inferMode(genre?: string): "guitar" | "bass" {
  const normalized = (genre || "").toLowerCase();
  if (normalized.includes("funk") || normalized.includes("r&b") || normalized.includes("dance")) {
    return "bass";
  }
  return "guitar";
}

function inferDefaultPart(genre?: string) {
  const normalized = (genre || "").toLowerCase();
  if (normalized.includes("dance") || normalized.includes("electronic") || normalized.includes("funk") || normalized.includes("r&b")) {
    return "main groove";
  }
  return "main part";
}

function colorFromText(value: string) {
  const palette = ["#42a5c8", "#b64a33", "#8a5a44", "#62656a", "#e75f70", "#536b3d", "#155e75", "#d7482f"];
  const score = value.split("").reduce((total, char) => total + char.charCodeAt(0), 0);
  return palette[score % palette.length];
}

function buildGearFallbackResults(items: GearItem[], itemType: string) {
  return items.map((item) => ({
    id: item.id,
    name: item.name,
    description: item.description,
    category: item.category || itemType,
    itemType,
    details: item.description
      .split(".")
      .map((detail) => detail.trim())
      .filter(Boolean)
  }));
}

function mergeCatalogResults(
  primary: Array<{
    id: string;
    name: string;
    description?: string;
    category?: string;
    itemType?: string;
    details?: string[];
  }> | null,
  fallback: Array<{
    id: string;
    name: string;
    description?: string;
    category?: string;
    itemType?: string;
    details?: string[];
  }>
) {
  const merged: typeof fallback = [];
  const seen = new Set<string>();

  for (const item of [...(primary || []), ...fallback]) {
    const normalizedName = item.name.trim().toLowerCase();
    if (!normalizedName || seen.has(normalizedName)) {
      continue;
    }
    seen.add(normalizedName);
    merged.push({
      ...item,
      details: Array.isArray(item.details) ? item.details.filter(Boolean) : []
    });
  }

  return merged;
}
