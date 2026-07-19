import type { SupabaseClient } from "@supabase/supabase-js";
import type { ToneType } from "../../../rule-engine";
import { isToneBackendError, repositoryError, notFoundError } from "../errors";
import { mapMasterToneRow } from "../mappers";
import type { NormalizedToneAdaptationRequest } from "../dtos";
import type { LoadedMasterToneContext } from "../types";
import { slugify } from "../validation";

type SupabaseQuery = any;
type SupabaseSingleResult = PromiseLike<{ data: unknown; error: { message: string } | null }>;

export interface SongRepository {
  findMasterTone(request: NormalizedToneAdaptationRequest): Promise<LoadedMasterToneContext>;
}

export class SupabaseSongRepository implements SongRepository {
  constructor(private readonly supabase: SupabaseClient) {}

  async findMasterTone(request: NormalizedToneAdaptationRequest): Promise<LoadedMasterToneContext> {
    if (request.masterToneId) {
      return this.findMasterToneById(request.masterToneId);
    }

    try {
      const artist = await this.findArtist(request.artist ?? "");
      const song = await this.findSong(idOf(artist), request.song ?? "");
      const part = await this.findSongPart(idOf(song), request.partType, request.part);
      const masterTone = await this.findMasterToneForPart(idOf(part), request.mode, request.toneType);
      const suggestedPedals = await this.findSuggestedPedals(idOf(masterTone));

      return mapMasterToneRow(masterTone, part, song, artist, suggestedPedals);
    } catch (error) {
      if (isToneBackendError(error) && error.code === "NOT_FOUND") {
        const legacyToneProfile = await this.findLegacyToneProfile(request);
        if (legacyToneProfile) {
          return legacyToneProfile;
        }
      }

      throw error;
    }
  }

  private async findMasterToneById(masterToneId: string) {
    const masterTone = await this.requireSingle("master_tones", "master tone", (query) =>
      query.select("*").eq("id", masterToneId).eq("is_active", true).maybeSingle()
    );
    const part = await this.requireSingle("song_parts", "song part", (query) =>
      query.select("*").eq("id", stringField(masterTone, "song_part_id")).eq("is_active", true).maybeSingle()
    );
    const song = await this.requireSingle("songs", "song", (query) =>
      query.select("*").eq("id", stringField(part, "song_id")).eq("is_active", true).maybeSingle()
    );
    const artist = await this.requireSingle("artists", "artist", (query) =>
      query.select("*").eq("id", stringField(song, "artist_id")).eq("is_active", true).maybeSingle()
    );
    const suggestedPedals = await this.findSuggestedPedals(idOf(masterTone));

    return mapMasterToneRow(masterTone, part, song, artist, suggestedPedals);
  }

  private async findArtist(artistName: string) {
    const slug = slugify(artistName);
    const bySlug = await this.optionalSingle("artists", (query) =>
      query.select("*").eq("slug", slug).eq("is_active", true).maybeSingle()
    );
    if (bySlug) {
      return bySlug;
    }

    return this.requireSingle("artists", "artist", (query) =>
      query.select("*").ilike("name", artistName).eq("is_active", true).limit(1).maybeSingle()
    );
  }

  private async findSong(artistId: string, songTitle: string) {
    const slug = slugify(songTitle);
    const bySlug = await this.optionalSingle("songs", (query) =>
      query.select("*").eq("artist_id", artistId).eq("slug", slug).eq("is_active", true).maybeSingle()
    );
    if (bySlug) {
      return bySlug;
    }

    return this.requireSingle("songs", "song", (query) =>
      query.select("*").eq("artist_id", artistId).ilike("title", songTitle).eq("is_active", true).limit(1).maybeSingle()
    );
  }

  private async findSongPart(songId: string, partType?: string, partLabel?: string) {
    if (partType) {
      const byType = await this.optionalSingle("song_parts", (query) =>
        query
          .select("*")
          .eq("song_id", songId)
          .eq("part_type_id", partType)
          .eq("is_active", true)
          .order("sort_order", { ascending: true })
          .limit(1)
          .maybeSingle()
      );
      if (byType) {
        return byType;
      }
    }

    if (partLabel) {
      const byLabel = await this.optionalSingle("song_parts", (query) =>
        query
          .select("*")
          .eq("song_id", songId)
          .ilike("label", partLabel)
          .eq("is_active", true)
          .order("sort_order", { ascending: true })
          .limit(1)
          .maybeSingle()
      );
      if (byLabel) {
        return byLabel;
      }
    }

    return this.requireSingle("song_parts", "song part", (query) =>
      query.select("*").eq("song_id", songId).eq("is_active", true).order("sort_order", { ascending: true }).limit(1).maybeSingle()
    );
  }

  private async findMasterToneForPart(songPartId: string, mode: string, toneType: string) {
    const exact = await this.optionalSingle("master_tones", (query) =>
      query
        .select("*")
        .eq("song_part_id", songPartId)
        .eq("instrument_type", mode)
        .eq("tone_type_id", toneType)
        .eq("is_active", true)
        .order("version", { ascending: false })
        .limit(1)
        .maybeSingle()
    );
    if (exact) {
      return exact;
    }

    return this.requireSingle("master_tones", "master tone", (query) =>
      query
        .select("*")
        .eq("song_part_id", songPartId)
        .eq("instrument_type", mode)
        .eq("is_active", true)
        .order("version", { ascending: false })
        .limit(1)
        .maybeSingle()
    );
  }

  private async findSuggestedPedals(masterToneId: string) {
    const { data, error } = await this.supabase
      .from("master_tone_suggested_pedals")
      .select("pedal_type_id")
      .eq("master_tone_id", masterToneId)
      .eq("is_active", true)
      .order("position_order", { ascending: true });

    if (error) {
      throw repositoryError("Failed to load suggested pedals.", { error: error.message });
    }

    return (data ?? []).map((row) => String(row.pedal_type_id));
  }

  private async findLegacyToneProfile(request: NormalizedToneAdaptationRequest) {
    const song = request.song ?? "";
    const artist = request.artist ?? "";
    if (!song || !artist) {
      return null;
    }

    const { data, error } = await this.supabase
      .from("song_tone_profiles")
      .select(
        "id, song_id, song_title, artist_name, mode, part_type, part_label, tone_type, genre, difficulty, original_guitar, original_amp, original_cab, original_pickup, original_settings, original_effects, playing_notes, adaptation_notes, source_summary, confidence, updated_at, tone_profile_effects(effect_order, effect_type, effect_name, placement, settings), tone_profile_sources(source_type, title, url)"
      )
      .eq("is_public", true)
      .eq("mode", request.mode)
      .ilike("song_title", `%${song}%`)
      .ilike("artist_name", `%${artist}%`)
      .limit(20);

    if (error) {
      throw repositoryError("Failed to query song_tone_profiles.", { error: error.message });
    }

    const ranked = ((data ?? []) as Array<Record<string, unknown>>)
      .map((row) => ({ row, score: this.scoreLegacyToneProfile(row, request) }))
      .filter(({ score }) => score > 25)
      .sort((left, right) => right.score - left.score);

    const legacy = ranked[0]?.row;
    return legacy ? mapLegacyToneProfileRow(legacy, request) : null;
  }

  private scoreLegacyToneProfile(row: Record<string, unknown>, request: NormalizedToneAdaptationRequest) {
    const title = normalizeText(stringField(row, "song_title"));
    const artist = normalizeText(stringField(row, "artist_name"));
    const requestedSong = normalizeText(request.song ?? "");
    const requestedArtist = normalizeText(request.artist ?? "");
    const partType = request.partType ?? "";
    const toneType = request.toneType ?? "auto";
    const legacyToneType = stringField(row, "tone_type");

    let score = 0;
    if (title === requestedSong) score += 100;
    else if (title.includes(requestedSong) || requestedSong.includes(title)) score += 55;
    if (artist === requestedArtist) score += 45;
    else if (artist.includes(requestedArtist) || requestedArtist.includes(artist)) score += 20;
    if (stringField(row, "part_type") === partType) score += 20;
    if (toneType === "auto" || legacyToneType === toneType || legacyToneType === "auto") {
      score += 15;
    }

    return score;
  }

  private async optionalSingle(
    tableName: string,
    execute: (query: SupabaseQuery) => SupabaseSingleResult
  ) {
    const { data, error } = await execute(this.supabase.from(tableName));
    if (error) {
      throw repositoryError(`Failed to query ${tableName}.`, { error: error.message });
    }
    return data as Record<string, unknown> | null;
  }

  private async requireSingle(
    tableName: string,
    entityName: string,
    execute: (query: SupabaseQuery) => SupabaseSingleResult
  ) {
    const data = await this.optionalSingle(tableName, execute);
    if (!data) {
      throw notFoundError(`Required ${entityName} was not found.`, { tableName });
    }
    return data;
  }
}

function idOf(row: Record<string, unknown>) {
  return stringField(row, "id");
}

function stringField(row: Record<string, unknown>, key: string) {
  return typeof row[key] === "string" ? row[key] : "";
}

function mapLegacyToneProfileRow(
  row: Record<string, unknown>,
  request: NormalizedToneAdaptationRequest
): LoadedMasterToneContext {
  const originalSettings = recordField(row, "original_settings");
  const updatedAt = stringField(row, "updated_at");
  const suggestedPedals = relationValues(row.tone_profile_effects, "effect_name");
  const partType = stringField(row, "part_type") || request.partType || "main";
  const toneType = normalizeLegacyToneType(stringField(row, "tone_type"));

  const originalEffects = mapOriginalEffects(row.original_effects, row.tone_profile_effects);
  const original: NonNullable<LoadedMasterToneContext["original"]> = {
    guitar: stringField(row, "original_guitar") || null,
    pickup: stringField(row, "original_pickup") || null,
    amp: stringField(row, "original_amp") || null,
    cab: stringField(row, "original_cab") || null,
    notes: stringField(row, "source_summary") || null,
    settings: numericRecord(originalSettings),
    effects: originalEffects,
    playingNotes: stringArray(row.playing_notes),
    adaptationNotes: stringArray(row.adaptation_notes),
    sources: mapProfileSources(row.tone_profile_sources),
    difficulty: stringField(row, "difficulty") || null,
    genre: stringField(row, "genre") || null
  };

  return {
    original,
    masterTone: {
      id: stringField(row, "id"),
      songId: stringField(row, "song_id") || stringField(row, "id"),
      songPartId: stringField(row, "id"),
      instrumentType: request.mode,
      toneType,
      settings: mapLegacySettings(originalSettings),
      eqProfile: {},
      modulationProfile: {},
      tempoBpm: null,
      toneArchetype: null,
      pickupPreference: stringField(row, "original_pickup") || null,
      suggestedAmpArchetype: null,
      suggestedCabinetArchetype: null,
      suggestedPedals,
      metadata: {
        sourceType: "song_tone_profiles_bridge",
        originalGuitar: stringField(row, "original_guitar") || null,
        originalAmp: stringField(row, "original_amp") || null,
        originalCab: stringField(row, "original_cab") || null,
        originalPickup: stringField(row, "original_pickup") || null
      }
    },
    source: {
      id: stringField(row, "id"),
      sourceType: "song_tone_profiles_bridge",
      cacheSourceProfileId: stringField(row, "id"),
      songId: stringField(row, "song_id") || stringField(row, "id"),
      songTitle: stringField(row, "song_title") || request.song || "Unknown Song",
      artistId: `legacy-artist:${slugify(stringField(row, "artist_name") || request.artist || "unknown-artist")}`,
      artistName: stringField(row, "artist_name") || request.artist || "Unknown Artist",
      songPartId: stringField(row, "id"),
      partLabel: stringField(row, "part_label") || request.part || "Main",
      partType,
      toneType,
      mode: request.mode,
      version: deriveLegacyVersion(updatedAt, originalSettings),
      confidence: Math.round(numberField(row, "confidence") ?? 70)
    }
  };
}

function mapLegacySettings(originalSettings: Record<string, unknown>): LoadedMasterToneContext["masterTone"]["settings"] {
  return {
    gain: numberValue(originalSettings.gain),
    bass: numberValue(originalSettings.bass),
    middle: numberValue(originalSettings.middle) ?? numberValue(originalSettings.mids) ?? undefined,
    treble: numberValue(originalSettings.treble),
    presence: numberValue(originalSettings.presence),
    resonance: numberValue(originalSettings.resonance),
    depth: numberValue(originalSettings.depth),
    masterVolume: numberValue(originalSettings.master_volume) ?? numberValue(originalSettings.master) ?? undefined,
    noiseGate: numberValue(originalSettings.noise_gate) ?? numberValue(originalSettings.noiseGate) ?? undefined,
    compression: numberValue(originalSettings.compression),
    delay: numberValue(originalSettings.delay),
    reverb: numberValue(originalSettings.reverb)
  };
}

function normalizeLegacyToneType(value: string): ToneType {
  if (value === "auto" || value === "auto_detect" || !value) {
    return "auto_detect";
  }

  return value as ToneType;
}

function deriveLegacyVersion(updatedAt: string, settings: Record<string, unknown>) {
  const signature = updatedAt || JSON.stringify(settings);
  let hash = 0;
  for (let index = 0; index < signature.length; index += 1) {
    hash = ((hash << 5) - hash + signature.charCodeAt(index)) | 0;
  }
  return Math.max(1, Math.abs(hash));
}

function normalizeText(value: string) {
  return value.trim().toLowerCase().replace(/[^a-z0-9]+/g, " ");
}

function numberValue(value: unknown) {
  if (typeof value === "number" && Number.isFinite(value)) {
    return value;
  }

  if (typeof value === "string" && value.trim().length > 0) {
    const parsed = Number(value);
    return Number.isFinite(parsed) ? parsed : undefined;
  }

  return undefined;
}

function numberField(row: Record<string, unknown>, key: string) {
  return numberValue(row[key]);
}

function recordField(row: Record<string, unknown>, key: string) {
  const value = row[key];
  return value && typeof value === "object" && !Array.isArray(value) ? (value as Record<string, unknown>) : {};
}

function relationValues(value: unknown, key: string) {
  const list = Array.isArray(value) ? value : [];
  return list
    .map((entry) => (entry && typeof entry === "object" && !Array.isArray(entry) ? (entry as Record<string, unknown>)[key] : null))
    .filter((entry): entry is string => typeof entry === "string" && entry.length > 0);
}

function stringArray(value: unknown): string[] {
  if (!Array.isArray(value)) {
    return [];
  }
  return value.filter((entry): entry is string => typeof entry === "string" && entry.trim().length > 0);
}

function numericRecord(value: Record<string, unknown>): Record<string, number> {
  return Object.entries(value).reduce<Record<string, number>>((accumulator, [key, entry]) => {
    const numeric = numberValue(entry);
    if (typeof numeric === "number") {
      accumulator[key] = numeric;
    }
    return accumulator;
  }, {});
}

function mapOriginalEffects(originalEffects: unknown, relationEffects: unknown) {
  const fromColumn = Array.isArray(originalEffects) ? originalEffects : [];
  const mappedColumn = fromColumn
    .map((entry) => {
      if (!entry || typeof entry !== "object" || Array.isArray(entry)) {
        return null;
      }
      const record = entry as Record<string, unknown>;
      const type = stringField(record, "effect_type") || stringField(record, "type");
      const name = stringField(record, "effect_name") || stringField(record, "name");
      if (!type && !name) {
        return null;
      }
      return {
        type: type || "effect",
        name: name || type || "effect",
        placement: stringField(record, "placement") || null,
        settings: numericRecord(recordField(record, "settings"))
      };
    })
    .filter((entry): entry is NonNullable<typeof entry> => entry !== null);

  if (mappedColumn.length) {
    return mappedColumn;
  }

  const fromRelation = Array.isArray(relationEffects) ? relationEffects : [];
  return fromRelation
    .map((entry) => {
      if (!entry || typeof entry !== "object" || Array.isArray(entry)) {
        return null;
      }
      const record = entry as Record<string, unknown>;
      const name = stringField(record, "effect_name");
      if (!name) {
        return null;
      }
      return {
        type: stringField(record, "effect_type") || "effect",
        name,
        placement: stringField(record, "placement") || null,
        settings: numericRecord(recordField(record, "settings"))
      };
    })
    .filter((entry): entry is NonNullable<typeof entry> => entry !== null);
}

function mapProfileSources(value: unknown) {
  const list = Array.isArray(value) ? value : [];
  return list
    .map((entry) => {
      if (!entry || typeof entry !== "object" || Array.isArray(entry)) {
        return null;
      }
      const record = entry as Record<string, unknown>;
      const title = stringField(record, "title");
      if (!title) {
        return null;
      }
      return {
        type: stringField(record, "source_type") || "internal_seed",
        title,
        url: stringField(record, "url") || null
      };
    })
    .filter((entry): entry is NonNullable<typeof entry> => entry !== null);
}
