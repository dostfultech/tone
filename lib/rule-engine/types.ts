export type RuleStage =
  | "load_master_tone"
  | "tone_type"
  | "guitar_profile"
  | "pickup_profiles"
  | "amplifier_profile"
  | "cabinet_profile"
  | "pedals"
  | "going_direct"
  | "multifx_mapping"
  | "final_tone";

export const RULE_STAGE_ORDER: RuleStage[] = [
  "load_master_tone",
  "tone_type",
  "guitar_profile",
  "pickup_profiles",
  "amplifier_profile",
  "cabinet_profile",
  "pedals",
  "going_direct",
  "multifx_mapping",
  "final_tone"
];

export type ToneType =
  | "auto_detect"
  | "auto"
  | "clean"
  | "crunch"
  | "edge_of_breakup"
  | "classic_rock"
  | "heavy"
  | "high_gain"
  | "metal"
  | "modern_metal"
  | "distorted"
  | "fuzz"
  | "ambient"
  | "acoustic"
  | "bass_clean"
  | "bass_drive";

export type PickupPosition = "neck" | "middle" | "bridge" | "primary";

export type ToneSettingKey =
  | "gain"
  | "bass"
  | "middle"
  | "treble"
  | "presence"
  | "resonance"
  | "depth"
  | "masterVolume"
  | "noiseGate"
  | "compression"
  | "delay"
  | "reverb";

export const TONE_SETTING_KEYS: ToneSettingKey[] = [
  "gain",
  "bass",
  "middle",
  "treble",
  "presence",
  "resonance",
  "depth",
  "masterVolume",
  "noiseGate",
  "compression",
  "delay",
  "reverb"
];

export type ToneSettingMap = Record<ToneSettingKey, number>;
export type ToneDeltas = Partial<Record<ToneSettingKey, number>>;
export type JsonRecord = Record<string, unknown>;

export type OutputLevel = "very_low" | "low" | "medium" | "high" | "very_high";
export type BrightnessProfile = "dark" | "balanced" | "bright";
export type AmpEra = "vintage" | "modern" | "neutral";
export type CabinetBackType = "open_back" | "closed_back" | "semi_open";

export interface MasterToneInput {
  id: string;
  songId?: string;
  songPartId?: string;
  instrumentType: "guitar" | "bass";
  toneType: ToneType;
  settings: Partial<ToneSettingMap>;
  eqProfile?: JsonRecord;
  modulationProfile?: JsonRecord;
  tempoBpm?: number | null;
  toneArchetype?: string | null;
  pickupPreference?: string | null;
  suggestedAmpArchetype?: string | null;
  suggestedCabinetArchetype?: string | null;
  suggestedPedals?: string[];
  metadata?: JsonRecord;
}

export interface ProfileWithDeltas {
  id: string;
  name: string;
  version?: number;
  deltas?: ToneDeltas;
  toneTypeDeltas?: Partial<Record<ToneType, ToneDeltas>>;
  metadata?: JsonRecord;
}

export interface GuitarProfileInput extends ProfileWithDeltas {
  bodyType?: string | null;
  scaleLengthInches?: number | null;
  bridgeType?: string | null;
  pickupLayout?: string | null;
  outputLevel?: OutputLevel | number | null;
  brightness?: BrightnessProfile | number | null;
  warmth?: number | null;
  compression?: number | null;
  frequencyCurve?: JsonRecord;
  noiseCharacteristics?: JsonRecord;
  toneArchetype?: string | null;
}

export interface PickupProfileInput extends ProfileWithDeltas {
  position: PickupPosition;
  type?: "single_coil" | "humbucker" | "p90" | "other" | null;
  circuitType?: "active" | "passive" | null;
  outputLevel?: OutputLevel | number | null;
  brightness?: BrightnessProfile | number | null;
  bass?: number | null;
  midrange?: number | null;
  compression?: number | null;
  noise?: number | null;
  frequencyResponse?: JsonRecord;
  toneArchetype?: string | null;
}

export interface AmplifierProfileInput extends ProfileWithDeltas {
  technology?: "tube" | "solid_state" | "hybrid" | "digital_modeling" | "plugin" | null;
  gainStructure?: "low_gain" | "medium_gain" | "high_gain" | "modern_high_gain" | string | null;
  era?: AmpEra | null;
  eqBehaviour?: JsonRecord;
  presenceBehaviour?: JsonRecord;
  compression?: number | null;
  brightness?: BrightnessProfile | number | null;
  warmth?: number | null;
  cleanHeadroom?: number | null;
  toneArchetype?: string | null;
}

export interface CabinetProfileInput extends ProfileWithDeltas {
  format?: "1x12" | "2x12" | "4x12" | string | null;
  backType?: CabinetBackType | null;
  speakerModel?: string | null;
  frequencyCurve?: JsonRecord;
  lowEnd?: number | null;
  highEnd?: number | null;
  brightness?: BrightnessProfile | number | null;
  warmth?: number | null;
}

export interface PedalProfileInput extends ProfileWithDeltas {
  type:
    | "overdrive"
    | "boost"
    | "distortion"
    | "compressor"
    | "eq"
    | "delay"
    | "reverb"
    | "noise_gate"
    | "chorus"
    | "flanger"
    | "phaser"
    | "pitch"
    | "octaver"
    | "fuzz"
    | string;
  order: number;
  enabled?: boolean;
  gainChange?: number | null;
  eqInfluence?: ToneDeltas | null;
  compression?: number | null;
  noise?: number | null;
  toneColor?: JsonRecord;
}

export interface MultiFxProfileInput extends ProfileWithDeltas {
  deviceId: string;
  name: string;
  availableAmpModels?: string[];
  cabModels?: string[];
  effects?: string[];
  dspLimits?: JsonRecord;
  routing?: JsonRecord;
  patchStructure?: JsonRecord;
  parameterMapping?: Record<string, string>;
}

export interface RuleEngineInput {
  masterTone: MasterToneInput;
  toneType: ToneType;
  guitar?: GuitarProfileInput | null;
  pickups?: PickupProfileInput[];
  amplifier?: AmplifierProfileInput | null;
  cabinet?: CabinetProfileInput | null;
  pedals?: PedalProfileInput[];
  goingDirect?: boolean;
  multiFx?: MultiFxProfileInput | null;
}

export interface RuleContribution {
  ruleId: string;
  stage: RuleStage;
  priority: number;
  description: string;
  deltas?: ToneDeltas;
  notes?: string[];
  effects?: string[];
  warnings?: string[];
  multifxParameters?: Record<string, number | string | boolean>;
  metadata?: JsonRecord;
}

export interface RuleDefinition {
  id: string;
  stage: RuleStage;
  priority: number;
  description: string;
  when: (context: RuleEvaluationContext) => boolean;
  apply: (context: RuleEvaluationContext) => RuleContribution | RuleContribution[] | null;
}

export interface RuleEvaluationContext {
  input: RuleEngineInput;
  currentSettings: ToneSettingMap;
  contributions: RuleContribution[];
}

export interface RuleEngineAuditEntry {
  stage: RuleStage;
  ruleId: string;
  priority: number;
  description: string;
  deltas: ToneDeltas;
  settingsAfterRule: ToneSettingMap;
  notes: string[];
  warnings: string[];
}

export interface ConflictResolutionEntry {
  setting: ToneSettingKey;
  positiveDelta: number;
  negativeDelta: number;
  resolvedDelta: number;
  ruleIds: string[];
}

export interface FinalToneOutput {
  masterToneId: string;
  toneType: ToneType;
  settings: ToneSettingMap;
  eqProfile: JsonRecord;
  modulationProfile: JsonRecord;
  effectsChain: string[];
  multifxParameters: Record<string, number | string | boolean>;
  notes: string[];
  warnings: string[];
  auditTrail: RuleEngineAuditEntry[];
  conflicts: ConflictResolutionEntry[];
  metadata: JsonRecord;
}

export interface RuleEngineLogger {
  debug: (event: string, payload?: JsonRecord) => void;
  info: (event: string, payload?: JsonRecord) => void;
  warn: (event: string, payload?: JsonRecord) => void;
  error: (event: string, payload?: JsonRecord) => void;
}

export interface RuleEngineOptions {
  logger?: RuleEngineLogger;
  maxAbsoluteDeltaPerSetting?: number;
}
