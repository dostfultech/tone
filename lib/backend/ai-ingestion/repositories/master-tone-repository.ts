import type { SupabaseClient } from "@supabase/supabase-js";
import type { NormalizedMasterToneDraft, StoredMasterTone } from "../dtos";
import { ingestionDatabaseError } from "../errors";
import { slugify } from "../validation";

type SupabaseQuery = any;

export interface MasterToneRepository {
  storeDraft(
    draft: NormalizedMasterToneDraft,
    options?: { regenerate?: boolean; embedding?: number[] | null; requestedBy?: string | null }
  ): Promise<StoredMasterTone>;
  updateMasterTone(masterToneId: string, patch: Partial<NormalizedMasterToneDraft>, reason?: string): Promise<StoredMasterTone>;
  softDeleteMasterTone(masterToneId: string, reason?: string): Promise<void>;
  approveMasterTone(masterToneId: string, reviewedBy: string | null, reason?: string, metadata?: Record<string, unknown>): Promise<void>;
  rejectMasterTone(masterToneId: string, reviewedBy: string | null, reason?: string, metadata?: Record<string, unknown>): Promise<void>;
  enrichMetadata(masterToneId: string, metadata: Record<string, unknown>): Promise<void>;
  findGearMatches(query: string): Promise<Record<string, unknown>>;
}

export class SupabaseMasterToneRepository implements MasterToneRepository {
  constructor(private readonly supabase: SupabaseClient) {}

  async storeDraft(
    draft: NormalizedMasterToneDraft,
    options: { regenerate?: boolean; embedding?: number[] | null; requestedBy?: string | null } = {}
  ) {
    const artist = await this.upsertArtist(draft.artist);
    const song = await this.upsertSong(artist.id, draft);
    const part = await this.upsertSongPart(song.id, draft);
    const existing = await this.findLatestMasterTone(part.id, draft.mode, draft.toneType);

    if (existing && !options.regenerate) {
      const legacyProfileId = await this.upsertLegacyToneProfileMirror(existing.id, song.id, draft);
      if (legacyProfileId) {
        await this.enrichMetadata(existing.id, {
          legacyProfileId,
          legacyMirrorSource: "song_tone_profiles",
          legacyMirroredAt: new Date().toISOString()
        });
      }
      return {
        artistId: artist.id,
        songId: song.id,
        songPartId: part.id,
        masterToneId: existing.id,
        version: existing.version
      };
    }

    const version = existing ? existing.version + 1 : 1;
    const metadata = {
      ...draft.metadata,
      generatedBy: "ai_ingestion",
      generatedAt: new Date().toISOString(),
      requestedBy: options.requestedBy ?? null,
      embedding: options.embedding ?? undefined
    };

    const { data, error } = await this.supabase
      .from("master_tones")
      .insert({
        song_part_id: part.id,
        instrument_type: draft.mode,
        tone_type_id: draft.toneType,
        gain: draft.gain,
        bass: draft.bass,
        middle: draft.middle,
        treble: draft.treble,
        presence: draft.presence,
        resonance: draft.resonance,
        depth: draft.depth,
        master_volume: draft.masterVolume,
        noise_gate: draft.noiseGate,
        compression: draft.compression,
        delay: draft.delay,
        reverb: draft.reverb,
        eq_profile: draft.eqProfile,
        modulation_profile: draft.modulationProfile,
        tempo_bpm: draft.tempoBpm ?? null,
        metadata,
        source_summary: draft.sourceSummary,
        confidence: draft.confidence,
        verification_status: "needs_review",
        version,
        is_active: true
      })
      .select("id, version")
      .single();

    if (error) {
      throw ingestionDatabaseError("Failed to store normalized master tone.", { error: error.message });
    }

    const masterToneId = String(data.id);
    await this.replaceSuggestedPedals(masterToneId, draft.suggestedPedals);
    const legacyProfileId = await this.upsertLegacyToneProfileMirror(masterToneId, song.id, draft);
    if (legacyProfileId) {
      await this.enrichMetadata(masterToneId, {
        legacyProfileId,
        legacyMirrorSource: "song_tone_profiles",
        legacyMirroredAt: new Date().toISOString()
      });
    }

    return {
      artistId: artist.id,
      songId: song.id,
      songPartId: part.id,
      masterToneId,
      version: Number(data.version ?? version)
    };
  }

  async updateMasterTone(masterToneId: string, patch: Partial<NormalizedMasterToneDraft>, reason?: string) {
    const current = await this.requireSingle("master_tones", "master tone", (query) =>
      query.select("*").eq("id", masterToneId).eq("is_active", true).maybeSingle()
    );

    const update: Record<string, unknown> = {
      metadata: {
        ...record(current.metadata),
        ...record(patch.metadata),
        adminUpdateReason: reason ?? null,
        adminUpdatedAt: new Date().toISOString()
      }
    };

    mapPatch(patch, update);

    const { error } = await this.supabase.from("master_tones").update(update).eq("id", masterToneId);
    if (error) {
      throw ingestionDatabaseError("Failed to update master tone.", { error: error.message, masterToneId });
    }

    if (patch.suggestedPedals) {
      await this.replaceSuggestedPedals(masterToneId, patch.suggestedPedals);
    }

    return this.lookupStoredMasterTone(masterToneId);
  }

  async softDeleteMasterTone(masterToneId: string, reason?: string) {
    const current = await this.requireSingle("master_tones", "master tone", (query) =>
      query.select("metadata").eq("id", masterToneId).maybeSingle()
    );
    const { error } = await this.supabase
      .from("master_tones")
      .update({
        is_active: false,
        metadata: {
          ...record(current.metadata),
          deletedByAdminAt: new Date().toISOString(),
          deleteReason: reason ?? null
        }
      })
      .eq("id", masterToneId);

    if (error) {
      throw ingestionDatabaseError("Failed to delete master tone.", { error: error.message, masterToneId });
    }
  }

  async approveMasterTone(masterToneId: string, reviewedBy: string | null, reason?: string, metadata: Record<string, unknown> = {}) {
    await this.setReviewDecision(masterToneId, "approved", "admin_verified", reviewedBy, reason, metadata);
  }

  async rejectMasterTone(masterToneId: string, reviewedBy: string | null, reason?: string, metadata: Record<string, unknown> = {}) {
    await this.setReviewDecision(masterToneId, "rejected", "needs_review", reviewedBy, reason, metadata);
  }

  async enrichMetadata(masterToneId: string, metadata: Record<string, unknown>) {
    const current = await this.requireSingle("master_tones", "master tone", (query) =>
      query.select("metadata").eq("id", masterToneId).eq("is_active", true).maybeSingle()
    );
    const { error } = await this.supabase
      .from("master_tones")
      .update({
        metadata: {
          ...record(current.metadata),
          ...metadata,
          enrichedAt: new Date().toISOString()
        }
      })
      .eq("id", masterToneId);

    if (error) {
      throw ingestionDatabaseError("Failed to enrich master tone metadata.", { error: error.message, masterToneId });
    }
  }

  async findGearMatches(query: string) {
    const [guitars, amps, cabinets, pedals, multiFx] = await Promise.all([
      this.searchTable("guitar_models", query),
      this.searchTable("amp_models", query),
      this.searchTable("cabinet_models", query),
      this.searchTable("pedal_models", query),
      this.searchTable("multifx_devices", query)
    ]);

    return { guitars, amps, cabinets, pedals, multiFx };
  }

  private async upsertArtist(artistName: string) {
    const slug = slugify(artistName);
    const { data, error } = await this.supabase
      .from("artists")
      .upsert(
        {
          name: artistName,
          slug,
          search_text: `${artistName} ${slug}`.toLowerCase(),
          is_active: true
        },
        { onConflict: "slug" }
      )
      .select("id, name")
      .single();

    if (error) {
      throw ingestionDatabaseError("Failed to upsert artist.", { error: error.message, artistName });
    }

    return { id: String(data.id), name: String(data.name) };
  }

  private async upsertSong(artistId: string, draft: NormalizedMasterToneDraft) {
    const slug = slugify(draft.song);
    const { data, error } = await this.supabase
      .from("songs")
      .upsert(
        {
          artist_id: artistId,
          title: draft.song,
          slug,
          search_text: `${draft.song} ${draft.artist} ${slug}`.toLowerCase(),
          is_active: true
        },
        { onConflict: "artist_id,slug" }
      )
      .select("id, title")
      .single();

    if (error) {
      throw ingestionDatabaseError("Failed to upsert song.", { error: error.message, song: draft.song });
    }

    return { id: String(data.id), title: String(data.title) };
  }

  private async upsertSongPart(songId: string, draft: NormalizedMasterToneDraft) {
    const { data, error } = await this.supabase
      .from("song_parts")
      .upsert(
        {
          song_id: songId,
          part_type_id: draft.partType,
          label: draft.part,
          sort_order: 0,
          metadata: {
            generatedBy: "ai_ingestion"
          },
          search_text: `${draft.song} ${draft.artist} ${draft.part} ${draft.partType}`.toLowerCase(),
          is_active: true
        },
        { onConflict: "song_id,part_type_id,label" }
      )
      .select("id, label")
      .single();

    if (error) {
      throw ingestionDatabaseError("Failed to upsert song part.", { error: error.message, part: draft.part });
    }

    return { id: String(data.id), label: String(data.label) };
  }

  private async findLatestMasterTone(songPartId: string, mode: string, toneType: string) {
    const { data, error } = await this.supabase
      .from("master_tones")
      .select("id, version")
      .eq("song_part_id", songPartId)
      .eq("instrument_type", mode)
      .eq("tone_type_id", toneType)
      .eq("is_active", true)
      .order("version", { ascending: false })
      .limit(1)
      .maybeSingle();

    if (error) {
      throw ingestionDatabaseError("Failed to find existing master tone.", { error: error.message, songPartId });
    }

    return data ? { id: String(data.id), version: Number(data.version ?? 1) } : null;
  }

  private async replaceSuggestedPedals(masterToneId: string, pedals: string[]) {
    await this.supabase.from("master_tone_suggested_pedals").delete().eq("master_tone_id", masterToneId);

    if (!pedals.length) {
      return;
    }

    const { error } = await this.supabase.from("master_tone_suggested_pedals").insert(
      pedals.map((pedal, index) => ({
        master_tone_id: masterToneId,
        pedal_type_id: normalizePedalType(pedal),
        position_order: index + 1,
        purpose: pedal,
        metadata: {
          sourceLabel: pedal
        },
        is_active: true
      }))
    );

    if (error) {
      throw ingestionDatabaseError("Failed to store suggested pedals.", { error: error.message, masterToneId });
    }
  }

  private async upsertLegacyToneProfileMirror(masterToneId: string, songId: string, draft: NormalizedMasterToneDraft) {
    const legacyPartType = toLegacyPartType(draft.partType, draft.mode);
    const legacyToneType = toLegacyToneType(draft.toneType);
    const originalSettings = {
      gain: draft.gain,
      bass: draft.bass,
      middle: draft.middle,
      treble: draft.treble,
      presence: draft.presence,
      resonance: draft.resonance,
      depth: draft.depth,
      master_volume: draft.masterVolume,
      noise_gate: draft.noiseGate,
      compression: draft.compression,
      delay: draft.delay,
      reverb: draft.reverb
    };
    const sourceMetadata = record(draft.metadata);
    const originalEffects = draft.suggestedPedals.map((effectName, index) => ({
      order: index + 1,
      type: normalizePedalType(effectName),
      name: effectName
    }));
    const searchText = `${draft.song} ${draft.artist} ${draft.part} ${legacyPartType} ${legacyToneType}`.toLowerCase();

    const { data, error } = await this.supabase
      .from("song_tone_profiles")
      .upsert(
        {
          song_id: songId,
          song_title: draft.song,
          artist_name: draft.artist,
          mode: draft.mode,
          part_type: legacyPartType,
          part_label: draft.part,
          tone_type: legacyToneType,
          original_guitar: stringOrNull(sourceMetadata.originalGuitar),
          original_amp: stringOrNull(sourceMetadata.originalAmp) ?? draft.suggestedAmpArchetype ?? null,
          original_cab: stringOrNull(sourceMetadata.originalCab) ?? draft.suggestedCabinetArchetype ?? null,
          original_pickup: stringOrNull(sourceMetadata.originalPickup) ?? draft.pickupPreference ?? null,
          original_effects: originalEffects,
          original_settings: originalSettings,
          adaptation_notes: ["Mirrored from normalized master_tones for deterministic tone-core compatibility."],
          playing_notes: readTextList(sourceMetadata.playingNotes),
          source_summary: draft.sourceSummary,
          confidence: draft.confidence,
          verification_status: "needs_review",
          search_text: searchText,
          is_public: true
        },
        { onConflict: "song_id,mode,part_type,tone_type,part_label" }
      )
      .select("id")
      .single();

    if (error) {
      throw ingestionDatabaseError("Failed to mirror master tone into song_tone_profiles.", {
        error: error.message,
        masterToneId
      });
    }

    const legacyProfileId = String(data.id);
    await this.replaceLegacyToneProfileEffects(legacyProfileId, draft.suggestedPedals);
    await this.replaceLegacyToneProfileSources(legacyProfileId, draft, masterToneId);
    return legacyProfileId;
  }

  private async replaceLegacyToneProfileEffects(profileId: string, pedals: string[]) {
    const { error: deleteError } = await this.supabase.from("tone_profile_effects").delete().eq("profile_id", profileId);
    if (deleteError) {
      throw ingestionDatabaseError("Failed to clear legacy tone profile effects.", {
        error: deleteError.message,
        profileId
      });
    }

    if (!pedals.length) {
      return;
    }

    const { error } = await this.supabase.from("tone_profile_effects").insert(
      pedals.map((pedal, index) => ({
        profile_id: profileId,
        effect_order: index + 1,
        effect_type: normalizePedalType(pedal),
        effect_name: pedal,
        placement: "post_gain",
        settings: {}
      }))
    );

    if (error) {
      throw ingestionDatabaseError("Failed to store legacy tone profile effects.", { error: error.message, profileId });
    }
  }

  private async replaceLegacyToneProfileSources(profileId: string, draft: NormalizedMasterToneDraft, masterToneId: string) {
    const { error: deleteError } = await this.supabase.from("tone_profile_sources").delete().eq("profile_id", profileId);
    if (deleteError) {
      throw ingestionDatabaseError("Failed to clear legacy tone profile sources.", {
        error: deleteError.message,
        profileId
      });
    }

    const { error } = await this.supabase.from("tone_profile_sources").insert({
      profile_id: profileId,
      source_type: "internal_seed",
      title: `Normalized master tone mirror for ${draft.song}`,
      notes: `Mirrored from master_tones ${masterToneId}. ${draft.sourceSummary}`.trim(),
      credibility: draft.confidence
    });

    if (error) {
      throw ingestionDatabaseError("Failed to store legacy tone profile source metadata.", {
        error: error.message,
        profileId
      });
    }
  }

  private async setReviewDecision(
    masterToneId: string,
    decision: "approved" | "rejected",
    verificationStatus: "admin_verified" | "needs_review",
    reviewedBy: string | null,
    reason?: string,
    metadata: Record<string, unknown> = {}
  ) {
    const current = await this.requireSingle("master_tones", "master tone", (query) =>
      query.select("metadata").eq("id", masterToneId).maybeSingle()
    );
    const { error: toneError } = await this.supabase
      .from("master_tones")
      .update({
        verification_status: verificationStatus,
        metadata: {
          ...record(current.metadata),
          reviewDecision: decision,
          reviewReason: reason ?? null,
          reviewedAt: new Date().toISOString()
        }
      })
      .eq("id", masterToneId);

    if (toneError) {
      throw ingestionDatabaseError("Failed to update master tone review status.", { error: toneError.message, masterToneId });
    }

    const { error: reviewError } = await this.supabase.from("master_tone_review_decisions").insert({
      master_tone_id: masterToneId,
      status: decision,
      reviewed_by: reviewedBy,
      reason: reason ?? null,
      metadata
    });

    if (reviewError) {
      throw ingestionDatabaseError("Failed to store master tone review decision.", { error: reviewError.message, masterToneId });
    }
  }

  private async lookupStoredMasterTone(masterToneId: string): Promise<StoredMasterTone> {
    const masterTone = await this.requireSingle("master_tones", "master tone", (query) =>
      query.select("id, song_part_id, version").eq("id", masterToneId).maybeSingle()
    );
    const part = await this.requireSingle("song_parts", "song part", (query) =>
      query.select("id, song_id").eq("id", stringField(masterTone, "song_part_id")).maybeSingle()
    );
    const song = await this.requireSingle("songs", "song", (query) =>
      query.select("id, artist_id").eq("id", stringField(part, "song_id")).maybeSingle()
    );

    return {
      artistId: stringField(song, "artist_id"),
      songId: stringField(song, "id"),
      songPartId: stringField(part, "id"),
      masterToneId: stringField(masterTone, "id"),
      version: numberField(masterTone.version, 1)
    };
  }

  private async searchTable(tableName: string, queryText: string) {
    const { data, error } = await this.supabase
      .from(tableName)
      .select("id, model_name, search_text")
      .ilike("search_text", `%${queryText}%`)
      .eq("is_active", true)
      .limit(10);

    if (error) {
      throw ingestionDatabaseError(`Failed to search ${tableName}.`, { error: error.message });
    }

    return data ?? [];
  }

  private async requireSingle(
    tableName: string,
    entityName: string,
    execute: (query: SupabaseQuery) => PromiseLike<{ data: unknown; error: { message: string } | null }>
  ) {
    const { data, error } = await execute(this.supabase.from(tableName));
    if (error) {
      throw ingestionDatabaseError(`Failed to load ${entityName}.`, { error: error.message, tableName });
    }
    if (!data || typeof data !== "object") {
      throw ingestionDatabaseError(`Missing ${entityName}.`, { tableName });
    }
    return data as Record<string, unknown>;
  }
}

function mapPatch(patch: Partial<NormalizedMasterToneDraft>, update: Record<string, unknown>) {
  const columnMap: Record<string, string> = {
    toneType: "tone_type_id",
    mode: "instrument_type",
    gain: "gain",
    bass: "bass",
    middle: "middle",
    treble: "treble",
    presence: "presence",
    resonance: "resonance",
    depth: "depth",
    masterVolume: "master_volume",
    noiseGate: "noise_gate",
    compression: "compression",
    delay: "delay",
    reverb: "reverb",
    tempoBpm: "tempo_bpm",
    eqProfile: "eq_profile",
    modulationProfile: "modulation_profile",
    sourceSummary: "source_summary",
    confidence: "confidence"
  };

  for (const [key, column] of Object.entries(columnMap)) {
    const value = patch[key as keyof NormalizedMasterToneDraft];
    if (value !== undefined) {
      update[column] = value;
    }
  }
}

function normalizePedalType(value: string) {
  const normalized = value.toLowerCase().replace(/[^a-z0-9]+/g, "_").replace(/^_+|_+$/g, "");
  const supported = new Set([
    "overdrive",
    "boost",
    "distortion",
    "compressor",
    "eq",
    "delay",
    "reverb",
    "noise_gate",
    "chorus",
    "flanger",
    "phaser",
    "pitch",
    "octaver",
    "fuzz"
  ]);
  return supported.has(normalized) ? normalized : "eq";
}

function toLegacyPartType(value: string, mode: NormalizedMasterToneDraft["mode"]) {
  const normalized = value.toLowerCase();
  if (normalized === "verse" || normalized === "outro" || normalized === "clean") {
    return "main";
  }
  if (normalized === "breakdown") {
    return mode === "bass" ? "bassline" : "riff";
  }
  if (normalized === "lead") {
    return "lead";
  }
  if (normalized === "solo") {
    return "solo";
  }
  if (normalized === "rhythm") {
    return "rhythm";
  }
  if (normalized === "intro") {
    return "intro";
  }
  if (normalized === "chorus") {
    return "chorus";
  }
  if (normalized === "bridge") {
    return "bridge";
  }
  if (mode === "bass" && normalized === "riff") {
    return "bassline";
  }
  if (normalized === "riff") {
    return "riff";
  }
  return "main";
}

function toLegacyToneType(value: string) {
  switch (value) {
    case "auto_detect":
      return "auto";
    case "edge_of_breakup":
    case "classic_rock":
      return "crunch";
    case "heavy":
    case "metal":
    case "modern_metal":
      return "high_gain";
    case "ambient":
      return "clean";
    default:
      return value;
  }
}

function record(value: unknown) {
  return typeof value === "object" && value !== null && !Array.isArray(value) ? (value as Record<string, unknown>) : {};
}

function stringOrNull(value: unknown) {
  return typeof value === "string" && value.trim().length > 0 ? value.trim() : null;
}

function readTextList(value: unknown) {
  return Array.isArray(value) ? value.filter((entry): entry is string => typeof entry === "string" && entry.trim().length > 0) : [];
}

function stringField(row: Record<string, unknown>, key: string) {
  return typeof row[key] === "string" ? row[key] : "";
}

function numberField(value: unknown, fallback = 0) {
  return typeof value === "number" && Number.isFinite(value) ? value : fallback;
}
