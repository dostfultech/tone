import { NextRequest, NextResponse } from "next/server";
import {
  amps,
  bassAmps,
  bassGuitars,
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
import { generateToneResult } from "@/lib/tone-ai";
import { createSupabaseAdminClient } from "@/lib/supabase/admin";
import { assertCanCreateAdaptation, incrementAdaptationUsage } from "@/lib/usage";
import { buildResearchPayload, createMissingSongRequest, findToneProfile, listCommunityToneProfiles } from "@/lib/tone-profiles";

export const runtime = "nodejs";
export const maxDuration = 60;

const MUSIC_SEARCH_CACHE_TTL_MS = 10 * 60 * 1000;
const MUSIC_SEARCH_CACHE_MAX_ITEMS = 120;
const DEFAULT_MUSIC_SEARCH_LIMIT = 30;
const musicSearchCache = new Map<string, { expiresAt: number; results: SongItem[] }>();

type RouteContext = {
  params: Promise<{ path: string[] }>;
};

export async function GET(request: NextRequest, context: RouteContext) {
  const route = (await context.params).path.join("/");
  const query = request.nextUrl.searchParams.get("q") || request.nextUrl.searchParams.get("name") || "";

  if (route === "amps/lookup") {
    const dbResults = await lookupGearFromSupabase(["amp"], query);
    if (dbResults) return json({ results: dbResults });
    return json({ results: lookupGear(amps, query) });
  }

  if (route === "guitars/lookup") {
    const dbResults = await lookupGearFromSupabase(["guitar"], query);
    if (dbResults) return json({ results: dbResults, pickups });
    return json({ results: lookupGear(guitars, query), pickups });
  }

  if (route === "bass-amps/lookup") {
    const dbResults = await lookupGearFromSupabase(["bass_amp"], query);
    if (dbResults) return json({ results: dbResults });
    return json({ results: lookupGear(bassAmps, query) });
  }

  if (route === "bass-guitars/lookup") {
    const dbResults = await lookupGearFromSupabase(["bass_guitar"], query);
    if (dbResults) return json({ results: dbResults });
    return json({ results: lookupGear(bassGuitars, query) });
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

  if (route === "pedals/user" || route === "pedals/presets") {
    return json({ results: pedalPresets });
  }

  if (route === "multi-fx/user" || route === "multi-fx/catalog") {
    const dbResults = await lookupGearFromSupabase(["multi_fx"], query);
    if (dbResults) return json({ results: dbResults });
    return json({ results: multiFxUnits.filter((unit) => `${unit.brand} ${unit.name}`.toLowerCase().includes(query.toLowerCase())) });
  }

  if (route === "community-tones/lookup") {
    return json({ results: await listCommunityToneProfiles(query) });
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
          model: process.env.OPENAI_MODEL || "gpt-4.1-nano"
        }).select("id").single();
        toneJobId = job?.id || null;
      }
    }

    const toneProfile = await findToneProfile(requestBody);
    if (!toneProfile) {
      await createMissingSongRequest(requestBody, user?.id || null);
    }
    const result = await generateToneResult(requestBody, toneProfile);

    if (user && admin && toneJobId) {
      await admin.from("tone_jobs").update({ status: "succeeded" }).eq("id", toneJobId);
      const { data: savedResult } = await admin.from("tone_results").insert({
        job_id: toneJobId,
        user_id: user.id,
        result,
        confidence: result.accuracy
      }).select("id").single();
      await incrementAdaptationUsage(admin, user.id, toneJobId);
      return json({ result: { ...result, toneResultId: savedResult?.id || null } });
    }

    return json({ result });
  }

  if (route === "save-tone") {
    const { supabase, user } = await getCurrentSession();
    if (supabase && !user) {
      return NextResponse.json({ error: "Authentication required" }, { status: 401 });
    }

    if (supabase && user) {
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

function normalizeToneRequest(body: Partial<ToneRequest>): ToneRequest {
  return {
    mode: body.mode === "bass" ? "bass" : "guitar",
    song: body.song || "Unknown Song",
    artist: body.artist || "Unknown Artist",
    part: body.part || "main part",
    partType: normalizePartType(body.partType, body.part),
    toneType: normalizeToneType(body.toneType),
    guitar: body.guitar || (body.mode === "bass" ? "Fender Precision Bass" : "Fender Stratocaster"),
    amp: body.amp || (body.mode === "bass" ? "Ampeg SVT-CL" : "Fender Deluxe Reverb"),
    pickup: body.pickup || "bridge pickup",
    effectsMode: body.effectsMode || "manual"
  };
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
        "User-Agent": "FretPilot/1.0"
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
          "User-Agent": "FretPilot/1.0"
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
