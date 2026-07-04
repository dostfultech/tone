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

export interface LoadedMasterToneContext {
  masterTone: MasterToneInput;
  source: {
    id: string;
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

export interface LoadedGearContext {
  guitar?: GuitarProfileInput | null;
  pickups: PickupProfileInput[];
  amplifier?: AmplifierProfileInput | null;
  cabinet?: CabinetProfileInput | null;
  pedals: PedalProfileInput[];
  goingDirect: boolean;
  multiFx?: MultiFxProfileInput | null;
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
  goingDirect: boolean;
  schemaVersion: number;
  sourceProfileVersion: number;
  result: FinalToneOutput;
  confidence: number;
  metadata?: JsonRecord;
}
