import type { SupabaseClient } from "@supabase/supabase-js";
import { repositoryError, notFoundError } from "../errors";
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

    const artist = await this.findArtist(request.artist ?? "");
    const song = await this.findSong(idOf(artist), request.song ?? "");
    const part = await this.findSongPart(idOf(song), request.partType, request.part);
    const masterTone = await this.findMasterToneForPart(idOf(part), request.mode, request.toneType);
    const suggestedPedals = await this.findSuggestedPedals(idOf(masterTone));

    return mapMasterToneRow(masterTone, part, song, artist, suggestedPedals);
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
