import type { SupabaseClient } from "@supabase/supabase-js";
import type { FinalToneOutput } from "../../../rule-engine";
import { repositoryError } from "../errors";
import type { ToneCacheRecord, ToneCacheWriteInput } from "../types";

export interface CacheRepository {
  read(cacheKey: string): Promise<ToneCacheRecord | null>;
  touch(cacheRecord: ToneCacheRecord): Promise<void>;
  write(input: ToneCacheWriteInput): Promise<{ id?: string }>;
}

export class SupabaseCacheRepository implements CacheRepository {
  constructor(private readonly supabase: SupabaseClient) {}

  async read(cacheKey: string): Promise<ToneCacheRecord | null> {
    const { data, error } = await this.supabase
      .from("tone_adaptation_cache")
      .select("id, cache_key, result_json, hit_count, expires_at")
      .eq("cache_key", cacheKey)
      .maybeSingle();

    if (error) {
      throw repositoryError("Failed to read tone adaptation cache.", { error: error.message });
    }

    if (!data) {
      return null;
    }

    const expiresAt = typeof data.expires_at === "string" ? data.expires_at : null;
    if (expiresAt && new Date(expiresAt).getTime() <= Date.now()) {
      return null;
    }

    return {
      id: String(data.id),
      cacheKey: String(data.cache_key),
      result: data.result_json as FinalToneOutput,
      hitCount: Number(data.hit_count ?? 0),
      expiresAt
    };
  }

  async touch(cacheRecord: ToneCacheRecord) {
    const { error } = await this.supabase
      .from("tone_adaptation_cache")
      .update({
        hit_count: cacheRecord.hitCount + 1,
        last_hit_at: new Date().toISOString()
      })
      .eq("id", cacheRecord.id);

    if (error) {
      throw repositoryError("Failed to update cache hit counter.", { error: error.message, cacheId: cacheRecord.id });
    }
  }

  async write(input: ToneCacheWriteInput) {
    const { data, error } = await this.supabase
      .from("tone_adaptation_cache")
      .upsert(
        {
          source_profile_id: input.sourceProfileId ?? null,
          request_signature: input.requestSignature,
          cache_key: input.cacheKey,
          mode: input.mode,
          song_title: input.songTitle,
          artist_name: input.artistName,
          part_label: input.partLabel,
          guitar_name: input.guitarName ?? null,
          amp_name: input.ampName ?? null,
          cabinet_name: input.cabinetName ?? null,
          pickup_name: input.pickupName ?? null,
          effects_mode: input.effectsMode ?? null,
          multi_fx_name: input.multiFxName ?? null,
          selected_fx_name: input.selectedFxName ?? null,
          going_direct: input.goingDirect,
          schema_version: input.schemaVersion,
          source_profile_version: input.sourceProfileVersion,
          guitar_profile_id: null,
          amp_profile_id: null,
          pickup_profile_id: null,
          cabinet_profile_id: null,
          multi_fx_profile_id: null,
          guitar_profile_version: 0,
          amp_profile_version: 0,
          pickup_profile_version: 0,
          cabinet_profile_version: 0,
          multi_fx_profile_version: 0,
          result_json: input.result,
          result_source: "rule",
          confidence: input.confidence,
          expires_at: null
        },
        { onConflict: "cache_key" }
      )
      .select("id")
      .maybeSingle();

    if (error) {
      throw repositoryError("Failed to write tone adaptation cache.", { error: error.message, cacheKey: input.cacheKey });
    }

    return { id: data?.id ? String(data.id) : undefined };
  }
}
