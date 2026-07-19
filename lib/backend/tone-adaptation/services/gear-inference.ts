import type {
  AmplifierProfileInput,
  CabinetProfileInput,
  GuitarProfileInput,
  PickupProfileInput,
  PickupPosition
} from "../../../rule-engine";
import { slugify } from "../validation";

// Deterministic keyword-based gear inference.
// When a user's gear name has no row in the catalog tables, these tables keep the
// guitar/amp stages running instead of silently skipping them. Same name in ⇒ same profile out.

type GuitarTraits = {
  brightness: number;
  outputLevel: number;
  warmth: number;
  compression: number;
  pickupType: "single_coil" | "humbucker" | "p90";
};

const GUITAR_KEYWORDS: Array<{ pattern: RegExp; traits: GuitarTraits }> = [
  { pattern: /strat|stratocaster/i, traits: { brightness: 7.5, outputLevel: 3.5, warmth: 4, compression: 3, pickupType: "single_coil" } },
  { pattern: /tele|telecaster/i, traits: { brightness: 8, outputLevel: 3.5, warmth: 3.5, compression: 3, pickupType: "single_coil" } },
  { pattern: /les ?paul|lp custom|lp standard/i, traits: { brightness: 4, outputLevel: 6.5, warmth: 7, compression: 6, pickupType: "humbucker" } },
  { pattern: /\bsg\b/i, traits: { brightness: 5, outputLevel: 6.5, warmth: 6, compression: 5.5, pickupType: "humbucker" } },
  { pattern: /335|339|casino|hollow/i, traits: { brightness: 4.5, outputLevel: 5, warmth: 7.5, compression: 5, pickupType: "humbucker" } },
  { pattern: /jazzmaster|jaguar|mustang|offset/i, traits: { brightness: 7, outputLevel: 3.5, warmth: 4.5, compression: 3.5, pickupType: "single_coil" } },
  { pattern: /jr\b|junior|special/i, traits: { brightness: 6, outputLevel: 5.5, warmth: 5.5, compression: 4.5, pickupType: "p90" } },
  { pattern: /rg\b|jem|ibanez|superstrat|soloist|dinky|charvel|kramer/i, traits: { brightness: 6, outputLevel: 7.5, warmth: 4.5, compression: 5, pickupType: "humbucker" } },
  { pattern: /explorer|flying v|firebird/i, traits: { brightness: 5, outputLevel: 7, warmth: 6, compression: 5.5, pickupType: "humbucker" } },
  { pattern: /prs|custom 24|mccarty/i, traits: { brightness: 5.5, outputLevel: 6, warmth: 6, compression: 5, pickupType: "humbucker" } },
  { pattern: /esp|ltd|schecter|jackson|dean\b|bc rich|solar/i, traits: { brightness: 5.5, outputLevel: 8, warmth: 4.5, compression: 5.5, pickupType: "humbucker" } },
  { pattern: /gretsch|duo jet|falcon/i, traits: { brightness: 7, outputLevel: 4.5, warmth: 5.5, compression: 4, pickupType: "single_coil" } },
  { pattern: /acoustic|dread|taylor|martin|j-45|hummingbird/i, traits: { brightness: 6.5, outputLevel: 3, warmth: 6, compression: 3, pickupType: "single_coil" } },
  { pattern: /precision|p bass|p-bass/i, traits: { brightness: 4.5, outputLevel: 5.5, warmth: 7, compression: 5, pickupType: "single_coil" } },
  { pattern: /jazz bass|j bass|j-bass/i, traits: { brightness: 6, outputLevel: 5, warmth: 5.5, compression: 4.5, pickupType: "single_coil" } },
  { pattern: /stingray|music ?man/i, traits: { brightness: 6.5, outputLevel: 7, warmth: 5, compression: 5, pickupType: "humbucker" } }
];

const DEFAULT_GUITAR_TRAITS: GuitarTraits = { brightness: 5.5, outputLevel: 5, warmth: 5, compression: 4.5, pickupType: "humbucker" };

type AmpTraits = {
  brightness: number;
  warmth: number;
  cleanHeadroom: number;
  gainStructure: string;
  era: "vintage" | "modern" | "neutral";
  technology: "tube" | "solid_state" | "digital_modeling";
};

const AMP_KEYWORDS: Array<{ pattern: RegExp; traits: AmpTraits }> = [
  { pattern: /twin reverb|deluxe reverb|blackface|vibrolux|princeton|super reverb/i, traits: { brightness: 7.5, warmth: 5.5, cleanHeadroom: 8.5, gainStructure: "vintage_blackface_clean", era: "vintage", technology: "tube" } },
  { pattern: /tweed|bassman|champ\b/i, traits: { brightness: 6, warmth: 7, cleanHeadroom: 5, gainStructure: "vintage_tweed_breakup", era: "vintage", technology: "tube" } },
  { pattern: /plexi|super lead|1959|jtm/i, traits: { brightness: 6.5, warmth: 6, cleanHeadroom: 4.5, gainStructure: "vintage_plexi_crunch", era: "vintage", technology: "tube" } },
  { pattern: /jcm ?800|jcm ?900|dsl|jvm|marshall/i, traits: { brightness: 6.5, warmth: 5, cleanHeadroom: 4, gainStructure: "british_high_gain", era: "neutral", technology: "tube" } },
  { pattern: /ac30|ac15|vox/i, traits: { brightness: 8, warmth: 5.5, cleanHeadroom: 5.5, gainStructure: "vintage_class_a_chime", era: "vintage", technology: "tube" } },
  { pattern: /rectifier|recto|mesa|mark v|triple crown/i, traits: { brightness: 5.5, warmth: 4.5, cleanHeadroom: 6, gainStructure: "modern_high_gain_rectifier", era: "modern", technology: "tube" } },
  { pattern: /5150|6505|evh|invective/i, traits: { brightness: 5.5, warmth: 4, cleanHeadroom: 4, gainStructure: "modern_high_gain_5150", era: "modern", technology: "tube" } },
  { pattern: /jc-?120|jazz chorus/i, traits: { brightness: 7.5, warmth: 4.5, cleanHeadroom: 9.5, gainStructure: "solid_state_clean", era: "neutral", technology: "solid_state" } },
  { pattern: /hiwatt/i, traits: { brightness: 7, warmth: 5, cleanHeadroom: 9, gainStructure: "vintage_hiwatt_clean", era: "vintage", technology: "tube" } },
  { pattern: /orange|rockerverb|or\d+/i, traits: { brightness: 5, warmth: 6.5, cleanHeadroom: 4.5, gainStructure: "british_mid_gain", era: "neutral", technology: "tube" } },
  { pattern: /friedman|bogner|diezel|soldano|uberschall/i, traits: { brightness: 6, warmth: 5, cleanHeadroom: 4, gainStructure: "boutique_high_gain", era: "modern", technology: "tube" } },
  { pattern: /dumble|overdrive special/i, traits: { brightness: 5.5, warmth: 6.5, cleanHeadroom: 6, gainStructure: "boutique_overdrive", era: "vintage", technology: "tube" } },
  { pattern: /katana|champion|mustang gt|mustang lt|spark|thr|code\b|nextone/i, traits: { brightness: 6, warmth: 5, cleanHeadroom: 7, gainStructure: "digital_modeling", era: "neutral", technology: "digital_modeling" } },
  { pattern: /helix|kemper|axe-?fx|quad cortex|pod\b|headrush|amplifi|gt-?1000|gt-?100/i, traits: { brightness: 6, warmth: 5, cleanHeadroom: 8, gainStructure: "digital_modeling", era: "neutral", technology: "digital_modeling" } },
  { pattern: /ampeg|svt/i, traits: { brightness: 5, warmth: 7, cleanHeadroom: 7, gainStructure: "bass_tube_classic", era: "vintage", technology: "tube" } },
  { pattern: /markbass|hartke|gallien|trace elliot/i, traits: { brightness: 6, warmth: 5.5, cleanHeadroom: 8, gainStructure: "bass_solid_state", era: "neutral", technology: "solid_state" } }
];

const DEFAULT_AMP_TRAITS: AmpTraits = { brightness: 6, warmth: 5.5, cleanHeadroom: 6, gainStructure: "general_purpose", era: "neutral", technology: "tube" };

export function inferGuitarProfile(name: string): GuitarProfileInput {
  const match = GUITAR_KEYWORDS.find((entry) => entry.pattern.test(name));
  const traits = match?.traits ?? DEFAULT_GUITAR_TRAITS;

  return {
    id: `inferred-guitar:${slugify(name)}`,
    name,
    brightness: traits.brightness,
    outputLevel: traits.outputLevel,
    warmth: traits.warmth,
    compression: traits.compression,
    pickupLayout: traits.pickupType,
    metadata: { inferred: true },
    version: 1
  };
}

export function inferAmpProfile(name: string): AmplifierProfileInput {
  const match = AMP_KEYWORDS.find((entry) => entry.pattern.test(name));
  const traits = match?.traits ?? DEFAULT_AMP_TRAITS;

  return {
    id: `inferred-amp:${slugify(name)}`,
    name,
    technology: traits.technology,
    gainStructure: traits.gainStructure,
    era: traits.era,
    brightness: traits.brightness,
    warmth: traits.warmth,
    cleanHeadroom: traits.cleanHeadroom,
    metadata: { inferred: true },
    version: 1
  };
}

export function inferCabinetProfile(name: string): CabinetProfileInput {
  const lower = name.toLowerCase();
  const format = /4x12/.test(lower) ? "4x12" : /2x12/.test(lower) ? "2x12" : /1x12/.test(lower) ? "1x12" : null;
  const backType = /closed/.test(lower) || format === "4x12" ? "closed_back" : /open/.test(lower) || /combo/.test(lower) ? "open_back" : null;

  return {
    id: `inferred-cab:${slugify(name)}`,
    name,
    format,
    backType,
    metadata: { inferred: true },
    version: 1
  };
}

export function inferPickupProfile(name: string, position: PickupPosition): PickupProfileInput {
  const lower = name.toLowerCase();
  const type = /humbucker|bucker|paf|490|498|57|jb\b|distortion|invader|emg|fluence|blackout/.test(lower)
    ? "humbucker"
    : /p-?90|soap ?bar/.test(lower)
      ? "p90"
      : "single_coil";
  const active = /emg|fluence|blackout|active/.test(lower);
  const output = /invader|distortion|emg 81|blackout|x2n|high output|hot/.test(lower) ? 8 : type === "humbucker" ? 6 : 4;

  return {
    id: `inferred-pickup:${slugify(name)}`,
    name,
    position,
    type,
    circuitType: active ? "active" : "passive",
    outputLevel: output,
    brightness: type === "single_coil" ? 7 : 4.5,
    metadata: { inferred: true },
    version: 1
  };
}

const PEDAL_TYPE_KEYWORDS: Array<{ pattern: RegExp; type: string }> = [
  { pattern: /overdrive|od-?\d|ts-?\d|tube screamer|blues driver|bd-?2|klon|centaur|morning glory|drive/i, type: "overdrive" },
  { pattern: /distortion|ds-?\d|rat\b|metal zone|mt-?2/i, type: "distortion" },
  { pattern: /fuzz|big muff|face|octavia/i, type: "fuzz" },
  { pattern: /boost|booster|ep booster/i, type: "boost" },
  { pattern: /delay|echo|dd-?\d|carbon copy|timeline|echoplex|memory man/i, type: "delay" },
  { pattern: /reverb|verb|hall of fame|bigsky|rv-?\d/i, type: "reverb" },
  { pattern: /chorus|ce-?\d|julia/i, type: "chorus" },
  { pattern: /flanger|electric mistress/i, type: "flanger" },
  { pattern: /phaser|phase ?90|small stone/i, type: "phaser" },
  { pattern: /tremolo|vibrato/i, type: "tremolo" },
  { pattern: /compressor|compression|dyna ?comp|cs-?\d/i, type: "compressor" },
  { pattern: /wah|cry ?baby/i, type: "wah" },
  { pattern: /octave|octaver|oc-?\d|pog/i, type: "octaver" },
  { pattern: /noise gate|gate|suppressor|ns-?\d|decimator/i, type: "noise_gate" },
  { pattern: /eq\b|equalizer|ge-?\d/i, type: "eq" }
];

export function inferPedalType(name: string): string {
  const match = PEDAL_TYPE_KEYWORDS.find((entry) => entry.pattern.test(name));
  return match?.type ?? "effect";
}
