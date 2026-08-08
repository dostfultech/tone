import type { SupabaseClient, User } from "@supabase/supabase-js";
import type { NormalizedToneAdaptationRequest, ToneAdaptationResponseDto } from "./dtos";

export type ToneAdaptationStatus = "success" | "failed";

export interface RecordToneAdaptationInput {
  user: Pick<User, "id" | "email">;
  dto: NormalizedToneAdaptationRequest;
  response?: ToneAdaptationResponseDto | null;
  status: ToneAdaptationStatus;
  toneResultId?: string | null;
  errorMessage?: string | null;
}

/**
 * Persist exactly one permanent analytics/history row per adaptation attempt into
 * `tone_adaptations`. Snapshots the real song, artist, tone, gear and settings used
 * so records stay accurate as the catalog/gear/tones change later.
 *
 * Best-effort by design: any failure here is logged and swallowed so recording
 * analytics can never break or slow the user's adaptation response.
 */
export async function recordToneAdaptation(admin: SupabaseClient, input: RecordToneAdaptationInput): Promise<void> {
  try {
    const { user, dto, response, status } = input;
    // `result` is enriched at runtime (originalSettings / targetSettings / request /
    // storageFormatVersion) beyond the FinalToneOutput type — read it defensively.
    const result = asRecord(response?.result);
    const master = response?.masterTone ?? null;
    const source = response?.source ?? null;

    const originalSettings = asRecord(result.originalSettings);
    const adaptedSettings = Object.keys(asRecord(result.settings)).length ? asRecord(result.settings) : asRecord(result.targetSettings);
    const gearSnapshot = Object.keys(asRecord(result.request)).length ? asRecord(result.request) : buildGearSnapshotFromDto(dto);

    const engine = source ? (source.finalSource === "DATABASE_CACHE" ? "database_cache" : "rule_engine") : "rule_engine";
    const version = typeof result.storageFormatVersion === "string" ? result.storageFormatVersion : "tone-core";

    await admin.from("tone_adaptations").insert({
      user_id: user.id,
      user_email: user.email ?? null,
      song_id: null, // no reliable songs.id in the adaptation response; snapshots below are authoritative
      song_name: master?.song ?? dto.song ?? null,
      artist_name: master?.artist ?? dto.artist ?? null,
      tone_id: master?.id ?? dto.masterToneId ?? null,
      tone_name: master ? `${master.song} — ${master.part}` : dto.song ?? null,
      guitar_id: dto.guitar?.id ?? null,
      pickup_id: dto.pickups[0]?.id ?? null,
      amp_id: dto.amp?.id ?? null,
      cabinet_id: dto.cabinet?.id ?? null,
      pedals: dto.pedals.map((pedal) => ({ id: pedal.id ?? null, name: pedal.name ?? null, order: pedal.order ?? null })),
      selected_gear: gearSnapshot,
      original_tone_settings: status === "success" ? originalSettings : {},
      adapted_tone_settings: status === "success" ? adaptedSettings : {},
      adaptation_engine: engine,
      adaptation_version: version,
      mode: dto.mode,
      request_source: dto.requestSource,
      confidence: typeof master?.confidence === "number" ? master.confidence : null,
      source_summary: source ?? {},
      tone_result_id: input.toneResultId ?? null,
      status,
      error_message: input.errorMessage ?? null,
      generation_time_ms: source && Number.isFinite(source.responseTimeMs) ? Math.round(source.responseTimeMs) : null
    });
  } catch (error) {
    console.error("[tone-adaptations] failed to record adaptation history", error instanceof Error ? error.message : error);
  }
}

function buildGearSnapshotFromDto(dto: NormalizedToneAdaptationRequest): Record<string, unknown> {
  return {
    guitar: dto.guitar?.name ?? null,
    pickups: dto.pickups.map((pickup) => ({ id: pickup.id ?? null, name: pickup.name ?? null, position: pickup.position ?? null })),
    amp: dto.amp?.name ?? null,
    cabinet: dto.cabinet?.name ?? null,
    pedals: dto.pedals.map((pedal) => ({ id: pedal.id ?? null, name: pedal.name ?? null })),
    goingDirect: dto.goingDirect,
    multiFx: dto.multiFx?.name ?? null,
    effectsMode: dto.effectsMode ?? null,
    selectedFx: dto.selectedFx ?? null,
    mode: dto.mode
  };
}

function asRecord(value: unknown): Record<string, unknown> {
  return value && typeof value === "object" && !Array.isArray(value) ? (value as Record<string, unknown>) : {};
}
