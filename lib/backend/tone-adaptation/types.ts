import type {
  AmplifierProfileInput,
  CabinetProfileInput,
  FinalToneOutput,
  GuitarProfileInput,
  JsonRecord,
  MasterToneInput,
  MultiFxProfileInput,
  PedalProfileInput,
  PickupProfileInput,
  RuleEngineInput,
  ToneType
} from "../../rule-engine";
import type { ToneAdaptationMode } from "./dtos";

export interface OriginalToneEffect {
  type: string;
  name: string;
  placement?: string | null;
  settings?: Record<string, number>;
}

export interface OriginalToneSource {
  type: string;
  title: string;
  url?: string | null;
}

export interface OriginalToneContext {
  guitar?: string | null;
  pickup?: string | null;
  amp?: string | null;
  cab?: string | null;
  notes?: string | null;
  settings: Record<string, number>;
  effects: OriginalToneEffect[];
  playingNotes: string[];
  adaptationNotes: string[];
  sources: OriginalToneSource[];
  difficulty?: string | null;
  genre?: string | null;
}

export interface LoadedMasterToneContext {
  masterTone: MasterToneInput;
  original?: OriginalToneContext;
  source: {
    id: string;
    sourceType: "master_tones" | "song_tone_profiles_bridge";
    cacheSourceProfileId?: string | null;
    songId: string;
    songTitle: string;
    artistId: string;
    artistName: string;
    songPartId: string;
    partLabel: string;
    partType: string;
    toneType: ToneType;
    mode: ToneAdaptationMode;
    version: number;
    confidence: number;
  };
}

export type GearMatchQuality = "catalog" | "inferred" | "none";

export interface GearResolution {
  guitar: GearMatchQuality;
  amp: GearMatchQuality;
  cabinet: GearMatchQuality;
  pickupsMatched: number;
  pickupsRequested: number;
  pedalsMatched: number;
  pedalsRequested: number;
}

export interface LoadedGearContext {
  guitar?: GuitarProfileInput | null;
  pickups: PickupProfileInput[];
  amplifier?: AmplifierProfileInput | null;
  cabinet?: CabinetProfileInput | null;
  pedals: PedalProfileInput[];
  goingDirect: boolean;
  multiFx?: MultiFxProfileInput | null;
  resolution?: GearResolution;
}

export interface LoadedToneRequestContext {
  masterTone: LoadedMasterToneContext;
  gear: LoadedGearContext;
  ruleEngineInput: RuleEngineInput;
}

export interface ToneCacheRecord {
  id: string;
  cacheKey: string;
  result: FinalToneOutput;
  hitCount: number;
  expiresAt?: string | null;
}

export interface ToneCacheWriteInput {
  cacheKey: string;
  requestSignature: string;
  mode: ToneAdaptationMode;
  songTitle: string;
  artistName: string;
  partLabel: string;
  guitarName?: string | null;
  ampName?: string | null;
  cabinetName?: string | null;
  pickupName?: string | null;
  pedalsName?: string | null;
  multiFxName?: string | null;
  effectsMode?: string | null;
  selectedFxName?: string | null;
  goingDirect: boolean;
  schemaVersion: number;
  sourceProfileVersion: number;
  sourceProfileId?: string | null;
  result: FinalToneOutput;
  confidence: number;
  metadata?: JsonRecord;
}
