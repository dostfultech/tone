import type { ToneType } from "../../rule-engine";

export type IngestionJobType = "song_generation" | "metadata_enrichment" | "gear_matching" | "cache_prewarming";
export type IngestionJobStatus = "queued" | "running" | "succeeded" | "failed" | "cancelled";
export type IngestionMode = "guitar" | "bass";
export type IngestionPartType =
  | "intro"
  | "verse"
  | "chorus"
  | "bridge"
  | "solo"
  | "lead"
  | "rhythm"
  | "riff"
  | "breakdown"
  | "outro"
  | "clean";

export interface GenerateSongRequestDto {
  song: string;
  artist: string;
  part?: string;
  partType?: string;
  toneType?: string;
  mode?: IngestionMode;
  runImmediately?: boolean;
  priority?: number;
  metadata?: Record<string, unknown>;
}

export interface RegenerateSongRequestDto extends GenerateSongRequestDto {
  masterToneId?: string;
  reason?: string;
}

export interface UpdateMasterToneRequestDto {
  masterToneId: string;
  patch: Partial<NormalizedMasterToneDraft>;
  reason?: string;
}

export interface ToneDecisionRequestDto {
  masterToneId: string;
  reason?: string;
  metadata?: Record<string, unknown>;
}

export interface DeleteToneRequestDto {
  masterToneId: string;
  reason?: string;
}

export interface WorkerRunRequestDto {
  workerId?: string;
  limit?: number;
  jobTypes?: IngestionJobType[];
}

export interface NormalizedMasterToneDraft {
  song: string;
  artist: string;
  part: string;
  partType: IngestionPartType;
  toneType: ToneType;
  mode: IngestionMode;
  gain: number;
  bass: number;
  middle: number;
  treble: number;
  presence: number;
  resonance: number;
  depth: number;
  masterVolume: number;
  noiseGate: number;
  compression: number;
  delay: number;
  reverb: number;
  tempoBpm?: number | null;
  suggestedAmpArchetype?: string | null;
  suggestedCabinetArchetype?: string | null;
  suggestedPedals: string[];
  pickupPreference?: string | null;
  toneArchetype?: string | null;
  eqProfile: Record<string, unknown>;
  modulationProfile: Record<string, unknown>;
  metadata: Record<string, unknown>;
  sourceSummary: string;
  confidence: number;
}

export interface StoredMasterTone {
  artistId: string;
  songId: string;
  songPartId: string;
  masterToneId: string;
  version: number;
}

export interface IngestionJob {
  id: string;
  jobType: IngestionJobType;
  status: IngestionJobStatus;
  payload: Record<string, unknown>;
  result: Record<string, unknown>;
  attempts: number;
  maxAttempts: number;
  requestedBy?: string | null;
}

export interface AdminIngestionResponse {
  ok: true;
  action: string;
  job?: IngestionJob;
  masterTone?: StoredMasterTone;
  result?: Record<string, unknown>;
}
