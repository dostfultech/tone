// Tonefex normalized database model contracts.
// Type-only architecture layer. No UI, rule-engine, AI, or caching logic lives here.

export type JsonValue = string | number | boolean | null | JsonValue[] | { [key: string]: JsonValue };
export type JsonRecord = Record<string, JsonValue>;

export type InstrumentType = "guitar" | "bass";
export type SharedInstrumentType = InstrumentType | "both";
export type PickupPosition = "neck" | "middle" | "bridge";
export type PickupCircuitType = "active" | "passive";
export type PickupCoilType = "single_coil" | "humbucker" | "p90" | "other";
export type AmpTechnology = "tube" | "solid_state" | "hybrid" | "digital_modeling" | "plugin";
export type CabinetBackType = "open_back" | "closed_back" | "semi_open";
export type RuleStatus = "draft" | "active" | "archived";
export type VerificationStatus = "needs_review" | "starter_estimate" | "research_verified" | "admin_verified";

export const supportedTonePartTypes = [
  "intro",
  "verse",
  "chorus",
  "bridge",
  "solo",
  "lead",
  "rhythm",
  "riff",
  "breakdown",
  "outro",
  "clean"
] as const;

export type SupportedTonePartType = (typeof supportedTonePartTypes)[number];

export const supportedToneTypes = [
  "auto_detect",
  "clean",
  "crunch",
  "edge_of_breakup",
  "classic_rock",
  "heavy",
  "high_gain",
  "metal",
  "modern_metal",
  "distorted",
  "ambient",
  "acoustic"
] as const;

export type SupportedToneType = (typeof supportedToneTypes)[number];

export const supportedPedalTypes = [
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
] as const;

export type SupportedPedalType = (typeof supportedPedalTypes)[number];

export interface TimestampedEntity {
  id: string;
  createdAt: string;
  updatedAt?: string;
}

export interface TonePartType extends TimestampedEntity {
  id: SupportedTonePartType;
  label: string;
  description?: string | null;
  sortOrder: number;
  isActive: boolean;
}

export interface ToneType extends TimestampedEntity {
  id: SupportedToneType;
  label: string;
  description?: string | null;
  sortOrder: number;
  isActive: boolean;
}

export interface ToneArchetype extends TimestampedEntity {
  slug: string;
  name: string;
  instrumentType?: SharedInstrumentType | null;
  description?: string | null;
  metadata: JsonRecord;
  isActive: boolean;
}

export interface Artist extends TimestampedEntity {
  name: string;
  slug: string;
  country?: string | null;
  externalIds: JsonRecord;
  searchText: string;
  isActive: boolean;
}

export interface Song extends TimestampedEntity {
  artistId: string;
  title: string;
  slug: string;
  album?: string | null;
  releaseYear?: number | null;
  durationSeconds?: number | null;
  externalIds: JsonRecord;
  searchText: string;
  isActive: boolean;
}

export interface SongPart extends TimestampedEntity {
  songId: string;
  partTypeId: SupportedTonePartType;
  label: string;
  sortOrder: number;
  startSeconds?: number | null;
  endSeconds?: number | null;
  metadata: JsonRecord;
  searchText: string;
  isActive: boolean;
}

export interface MasterTone extends TimestampedEntity {
  songPartId: string;
  instrumentType: InstrumentType;
  toneTypeId: SupportedToneType;
  toneArchetypeId?: string | null;
  pickupPreferenceId?: string | null;
  suggestedAmpArchetypeId?: string | null;
  suggestedCabinetArchetypeId?: string | null;
  gain?: number | null;
  bass?: number | null;
  middle?: number | null;
  treble?: number | null;
  presence?: number | null;
  resonance?: number | null;
  depth?: number | null;
  masterVolume?: number | null;
  noiseGate?: number | null;
  compression?: number | null;
  delay?: number | null;
  reverb?: number | null;
  eqProfile: JsonRecord;
  modulationProfile: JsonRecord;
  tempoBpm?: number | null;
  metadata: JsonRecord;
  sourceSummary?: string | null;
  confidence: number;
  verificationStatus: VerificationStatus;
  version: number;
  isActive: boolean;
}

export interface MasterToneSuggestedPedal extends TimestampedEntity {
  masterToneId: string;
  pedalTypeId: SupportedPedalType;
  positionOrder: number;
  purpose?: string | null;
  intensity?: number | null;
  metadata: JsonRecord;
  isActive: boolean;
}

export interface EquipmentManufacturer extends TimestampedEntity {
  name: string;
  slug: string;
  country?: string | null;
  websiteUrl?: string | null;
  metadata: JsonRecord;
  isActive: boolean;
}

export interface FrequencyCurve extends TimestampedEntity {
  slug: string;
  name: string;
  lowEnd: number;
  lowMid: number;
  midrange: number;
  highMid: number;
  highEnd: number;
  curve: JsonRecord;
  metadata: JsonRecord;
  isActive: boolean;
}

export interface GuitarModel extends TimestampedEntity {
  manufacturerId: string;
  modelName: string;
  instrumentType: InstrumentType;
  bodyType?: string | null;
  scaleLengthInches?: number | null;
  bridgeType?: string | null;
  pickupLayout?: string | null;
  outputLevel: number;
  brightness: number;
  warmth: number;
  compression: number;
  frequencyCurveId?: string | null;
  noiseCharacteristics: JsonRecord;
  toneArchetypeId?: string | null;
  metadata: JsonRecord;
  searchText: string;
  isActive: boolean;
}

export interface PickupType extends TimestampedEntity {
  id: SupportedPickupType;
  label: string;
  coilType: PickupCoilType;
  description?: string | null;
  isActive: boolean;
}

export type SupportedPickupType = "single_coil" | "humbucker" | "p90";

export interface PickupModel extends TimestampedEntity {
  manufacturerId: string;
  modelName: string;
  pickupTypeId: SupportedPickupType;
  circuitType: PickupCircuitType;
  outputLevel: number;
  brightness: number;
  bass: number;
  midrange: number;
  compression: number;
  frequencyCurveId?: string | null;
  noise: number;
  toneArchetypeId?: string | null;
  metadata: JsonRecord;
  searchText: string;
  isActive: boolean;
}

export interface GuitarModelPickup extends TimestampedEntity {
  guitarModelId: string;
  pickupModelId?: string | null;
  pickupPosition: PickupPosition;
  isStock: boolean;
  metadata: JsonRecord;
  isActive: boolean;
}

export interface AmpModel extends TimestampedEntity {
  manufacturerId: string;
  modelName: string;
  instrumentType: SharedInstrumentType;
  ampTechnology: AmpTechnology;
  gainStructure?: string | null;
  eqBehaviour: JsonRecord;
  presenceBehaviour: JsonRecord;
  compression: number;
  brightness: number;
  warmth: number;
  cleanHeadroom: number;
  toneArchetypeId?: string | null;
  metadata: JsonRecord;
  searchText: string;
  isActive: boolean;
}

export interface CabinetFormat extends TimestampedEntity {
  id: "1x12" | "2x12" | "4x12";
  label: string;
  speakerCount: number;
  speakerSizeInches: number;
  isActive: boolean;
}

export interface SpeakerModel extends TimestampedEntity {
  manufacturerId?: string | null;
  modelName: string;
  frequencyCurveId?: string | null;
  brightness: number;
  warmth: number;
  metadata: JsonRecord;
  searchText: string;
  isActive: boolean;
}

export interface CabinetModel extends TimestampedEntity {
  manufacturerId?: string | null;
  modelName: string;
  cabinetFormatId: CabinetFormat["id"];
  backType: CabinetBackType;
  speakerModelId?: string | null;
  frequencyCurveId?: string | null;
  lowEnd: number;
  highEnd: number;
  brightness: number;
  warmth: number;
  metadata: JsonRecord;
  searchText: string;
  isActive: boolean;
}

export interface PedalType extends TimestampedEntity {
  id: SupportedPedalType;
  label: string;
  description?: string | null;
  sortOrder: number;
  isActive: boolean;
}

export interface PedalModel extends TimestampedEntity {
  manufacturerId: string;
  modelName: string;
  pedalTypeId: SupportedPedalType;
  gainChange: number;
  eqInfluence: JsonRecord;
  compression: number;
  noise: number;
  toneColor: JsonRecord;
  metadata: JsonRecord;
  searchText: string;
  isActive: boolean;
}

export interface MultifxDevice extends TimestampedEntity {
  manufacturerId: string;
  modelName: string;
  dspLimits: JsonRecord;
  routing: JsonRecord;
  patchStructure: JsonRecord;
  parameterMapping: JsonRecord;
  metadata: JsonRecord;
  searchText: string;
  isActive: boolean;
}

export interface MultifxAmpModel extends TimestampedEntity {
  multifxDeviceId: string;
  modelName: string;
  ampModelId?: string | null;
  parameterMapping: JsonRecord;
  metadata: JsonRecord;
  isActive: boolean;
}

export interface MultifxCabModel extends TimestampedEntity {
  multifxDeviceId: string;
  modelName: string;
  cabinetModelId?: string | null;
  parameterMapping: JsonRecord;
  metadata: JsonRecord;
  isActive: boolean;
}

export interface MultifxEffect extends TimestampedEntity {
  multifxDeviceId: string;
  effectName: string;
  pedalTypeId?: SupportedPedalType | null;
  parameterMapping: JsonRecord;
  metadata: JsonRecord;
  isActive: boolean;
}

export interface UserInstrument extends TimestampedEntity {
  userId: string;
  guitarModelId?: string | null;
  nickname?: string | null;
  metadata: JsonRecord;
}

export interface UserInstrumentPickup extends TimestampedEntity {
  userInstrumentId: string;
  pickupModelId?: string | null;
  pickupPosition: PickupPosition;
  isStock: boolean;
  metadata: JsonRecord;
}

export interface UserRig extends TimestampedEntity {
  userId: string;
  name: string;
  instrumentType: InstrumentType;
  userInstrumentId?: string | null;
  ampModelId?: string | null;
  cabinetModelId?: string | null;
  multifxDeviceId?: string | null;
  goingDirect: boolean;
  metadata: JsonRecord;
}

export interface UserRigPedal extends TimestampedEntity {
  userRigId: string;
  pedalModelId?: string | null;
  positionOrder: number;
  metadata: JsonRecord;
}

export interface RuleSet extends TimestampedEntity {
  slug: string;
  name: string;
  description?: string | null;
  version: number;
  status: RuleStatus;
  metadata: JsonRecord;
  isActive: boolean;
}

export interface RuleProfile extends TimestampedEntity {
  ruleSetId: string;
  name: string;
  equipmentScope: "global" | "guitar" | "pickup" | "amp" | "cabinet" | "pedal" | "multifx";
  priority: number;
  metadata: JsonRecord;
  isActive: boolean;
}

export interface CacheKeyDefinition extends TimestampedEntity {
  namespace: string;
  keyName: string;
  keyVersion: number;
  inputShape: JsonRecord;
  description?: string | null;
  isActive: boolean;
}
