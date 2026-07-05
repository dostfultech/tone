import type { FinalToneOutput, ToneType } from "../../rule-engine";

export type ToneAdaptationMode = "guitar" | "bass";

export interface NamedSelectionDto {
  id?: string;
  name?: string;
  position?: "neck" | "middle" | "bridge" | "primary";
  order?: number;
}

export interface ToneAdaptationGearDto {
  guitarId?: string;
  guitar?: string;
  pickupIds?: string[];
  pickups?: Array<string | NamedSelectionDto>;
  ampId?: string;
  amp?: string;
  cabinetId?: string;
  cabinet?: string;
  pedalIds?: string[];
  pedals?: Array<string | NamedSelectionDto>;
  goingDirect?: boolean;
  multiFxId?: string;
  multiFx?: string;
}

export interface ToneAdaptationRequestDto extends ToneAdaptationGearDto {
  requestId?: string;
  song?: string;
  artist?: string;
  part?: string;
  partType?: string;
  toneType?: string;
  mode?: ToneAdaptationMode;
  masterToneId?: string;
  gear?: ToneAdaptationGearDto;
}

export interface NormalizedSelection {
  id?: string;
  name?: string;
  position?: "neck" | "middle" | "bridge" | "primary";
  order?: number;
}

export interface NormalizedToneAdaptationRequest {
  requestId: string;
  song?: string;
  artist?: string;
  part?: string;
  partType?: string;
  toneType: ToneType;
  mode: ToneAdaptationMode;
  masterToneId?: string;
  guitar?: NormalizedSelection;
  pickups: NormalizedSelection[];
  amp?: NormalizedSelection;
  cabinet?: NormalizedSelection;
  pedals: NormalizedSelection[];
  goingDirect: boolean;
  multiFx?: NormalizedSelection;
}

export interface ToneAdaptationLogSummary {
  event: "tone_backend_adaptation_complete";
  endpoint: "/api/v1/tones/adapt";
  requestId: string;
  finalSource: "DATABASE_CACHE" | "RULE_ENGINE";
  cacheStatus: "hit" | "miss";
  cacheHit: boolean;
  cacheMiss: boolean;
  cacheWrite: "not_attempted" | "succeeded" | "failed";
  databaseTimeMs: number;
  ruleEngineTimeMs: number;
  responseTimeMs: number;
  cacheKey: string;
  aiUsed: boolean;
  openAiCalled: boolean;
  sourceHydrationUsed: boolean;
}

export interface ToneAdaptationResponseDto {
  requestId: string;
  result: FinalToneOutput;
  source: ToneAdaptationLogSummary;
  masterTone: {
    id: string;
    song: string;
    artist: string;
    part: string;
    partType: string;
    toneType: ToneType;
    version: number;
    confidence: number;
    sourceType: "master_tones" | "song_tone_profiles_bridge";
  };
  gear: {
    guitar?: string;
    pickups: string[];
    amp?: string;
    cabinet?: string;
    pedals: string[];
    goingDirect: boolean;
    multiFx?: string;
  };
}

export interface ToneAdaptationErrorResponseDto {
  error: {
    code: string;
    message: string;
    status: number;
    details?: Record<string, unknown>;
  };
}
