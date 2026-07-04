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

    await this.replaceSuggestedPedals(String(data.id), draft.suggestedPedals);

    return {
      artistId: artist.id,
      songId: song.id,
      songPartId: part.id,
      masterToneId: String(data.id),
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

function record(value: unknown) {
  return typeof value === "object" && value !== null && !Array.isArray(value) ? (value as Record<string, unknown>) : {};
}

function stringField(row: Record<string, unknown>, key: string) {
  return typeof row[key] === "string" ? row[key] : "";
}

function numberField(value: unknown, fallback = 0) {
  return typeof value === "number" && Number.isFinite(value) ? value : fallback;
}
