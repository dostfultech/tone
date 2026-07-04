import type { GearItem } from "@/lib/mock-data";

type CatalogLike = Partial<GearItem> & {
  details?: string[];
};

export type GearMetadata = {
  description: string;
  pickupConfig?: string;
  outputLevel?: string;
  toneCharacteristics: string[];
  tags: string[];
  features: string[];
};

const KNOWN_GUITAR_META: Record<string, Partial<GearMetadata>> = {
  stratocaster: { pickupConfig: "SSS", outputLevel: "vintage output", toneCharacteristics: ["glassy", "bell-like", "articulate"] },
  telecaster: { pickupConfig: "SS", outputLevel: "low output", toneCharacteristics: ["twangy", "bright", "cutting"] },
  "les paul": { pickupConfig: "HH", outputLevel: "high output", toneCharacteristics: ["thick", "sustain", "warm mids"] },
  sg: { pickupConfig: "HH", outputLevel: "high output", toneCharacteristics: ["upper-mid bite", "lightweight", "rock"] },
  casino: { pickupConfig: "P90/P90", outputLevel: "medium output", toneCharacteristics: ["airy", "hollow", "raw"] },
  jazzmaster: { pickupConfig: "SS", outputLevel: "medium output", toneCharacteristics: ["wide single-coil", "airy", "offset"] },
  jaguar: { pickupConfig: "SS", outputLevel: "low output", toneCharacteristics: ["short-scale", "bright", "percussive"] },
  rg: { pickupConfig: "HSH", outputLevel: "high output", toneCharacteristics: ["tight", "fast attack", "modern"] },
  pacifica: { pickupConfig: "HSS", outputLevel: "medium output", toneCharacteristics: ["balanced", "versatile", "clear"] },
  schecter: { pickupConfig: "HH", outputLevel: "high output", toneCharacteristics: ["aggressive", "tight", "modern"] },
  jackson: { pickupConfig: "HH", outputLevel: "high output", toneCharacteristics: ["sharp attack", "modern", "focused"] },
  rickenbacker: { pickupConfig: "SS", outputLevel: "medium output", toneCharacteristics: ["jangly", "chime", "clear"] },
  wolfgang: { pickupConfig: "HH", outputLevel: "high output", toneCharacteristics: ["hot bridge", "rock", "sustain"] }
};

const KNOWN_BASS_META: Record<string, Partial<GearMetadata>> = {
  precision: { pickupConfig: "Split coil", outputLevel: "medium output", toneCharacteristics: ["punchy", "focused", "classic"] },
  jazz: { pickupConfig: "JJ", outputLevel: "medium output", toneCharacteristics: ["scooped", "clear", "flexible"] },
  stingray: { pickupConfig: "Active H", outputLevel: "high output", toneCharacteristics: ["bright", "tight lows", "modern"] },
  rickenbacker: { pickupConfig: "SS", outputLevel: "medium output", toneCharacteristics: ["grindy", "piano attack", "present"] },
  jaguar: { pickupConfig: "PJ", outputLevel: "medium output", toneCharacteristics: ["versatile", "punchy", "offset"] },
  aerodyne: { pickupConfig: "PJ", outputLevel: "medium output", toneCharacteristics: ["sleek", "punchy", "modern"] },
  surveyor: { pickupConfig: "PJ", outputLevel: "high output", toneCharacteristics: ["active", "modern", "tight"] }
};

export function getInstrumentMetadata(name: string, mode: "guitar" | "bass", catalog?: CatalogLike | null): GearMetadata {
  const haystack = normalize(`${name} ${catalog?.description || ""} ${catalog?.category || ""} ${(catalog?.details || []).join(" ")}`);
  const known = findKnownMetadata(haystack, mode === "bass" ? KNOWN_BASS_META : KNOWN_GUITAR_META);
  const pickupConfig = known.pickupConfig || inferPickupConfig(haystack, mode);
  const outputLevel = known.outputLevel || inferOutputLevel(haystack);
  const toneCharacteristics = known.toneCharacteristics || inferToneCharacteristics(haystack, mode);

  return {
    description: catalog?.description || buildInstrumentDescription(name, mode, toneCharacteristics),
    pickupConfig,
    outputLevel,
    toneCharacteristics,
    tags: [pickupConfig, outputLevel, ...toneCharacteristics].filter(Boolean).slice(0, 5),
    features: toneCharacteristics
  };
}

export function getAmpMetadata(name: string, catalog?: CatalogLike | null, goingDirect = false): GearMetadata {
  const haystack = normalize(`${name} ${catalog?.description || ""} ${catalog?.category || ""} ${(catalog?.details || []).join(" ")}`);
  const features = inferAmpFeatures(haystack, goingDirect);
  const toneCharacteristics = inferAmpTone(haystack, goingDirect);

  return {
    description: catalog?.description || buildAmpDescription(name, toneCharacteristics, goingDirect),
    toneCharacteristics,
    tags: features.slice(0, 6),
    features
  };
}

export function getEffectCategories() {
  return [
    "Drive",
    "Distortion",
    "Overdrive",
    "Fuzz",
    "Boost",
    "Compressor",
    "EQ",
    "Chorus",
    "Phaser",
    "Flanger",
    "Delay",
    "Reverb",
    "Noise Gate",
    "Wah",
    "Pitch",
    "Utility",
    "Cab Sim",
    "IR Loader"
  ];
}

function findKnownMetadata(haystack: string, source: Record<string, Partial<GearMetadata>>) {
  return Object.entries(source).find(([key]) => haystack.includes(key))?.[1] || {};
}

function inferPickupConfig(haystack: string, mode: "guitar" | "bass") {
  if (mode === "bass") {
    if (haystack.includes("pj") || haystack.includes("jaguar")) return "PJ";
    if (haystack.includes("jazz")) return "JJ";
    if (haystack.includes("precision") || haystack.includes("split")) return "Split coil";
    if (haystack.includes("active")) return "Active";
    return "Bass pickup";
  }

  if (haystack.includes("hsh")) return "HSH";
  if (haystack.includes("hss")) return "HSS";
  if (haystack.includes("humbucker") || haystack.includes("hh")) return "HH";
  if (haystack.includes("p-90") || haystack.includes("p90")) return "P90";
  if (haystack.includes("single") || haystack.includes("strat")) return "SSS";
  return "Stock";
}

function inferOutputLevel(haystack: string) {
  if (haystack.includes("active") || haystack.includes("high-output") || haystack.includes("hot")) return "high output";
  if (haystack.includes("vintage") || haystack.includes("single") || haystack.includes("tele")) return "low output";
  return "medium output";
}

function inferToneCharacteristics(haystack: string, mode: "guitar" | "bass") {
  const tags = [
    haystack.includes("bright") || haystack.includes("tele") ? "bright" : null,
    haystack.includes("warm") || haystack.includes("les paul") ? "warm" : null,
    haystack.includes("active") || haystack.includes("modern") ? "modern" : null,
    haystack.includes("hollow") || haystack.includes("casino") ? "airy" : null,
    haystack.includes("metal") || haystack.includes("schecter") ? "aggressive" : null,
    haystack.includes("bass") || mode === "bass" ? "low-end focus" : null
  ].filter(Boolean) as string[];

  return tags.length ? tags.slice(0, 3) : mode === "bass" ? ["punchy", "supportive"] : ["balanced", "adaptable"];
}

function inferAmpFeatures(haystack: string, goingDirect: boolean) {
  const features = [
    haystack.includes("reverb") || haystack.includes("champion") || haystack.includes("spider") ? "Reverb" : null,
    haystack.includes("delay") || haystack.includes("modeling") || haystack.includes("spider") ? "Delay" : null,
    haystack.includes("chorus") || haystack.includes("code") || haystack.includes("spider") ? "Chorus" : null,
    haystack.includes("loop") || haystack.includes("dsl") ? "FX Loop" : null,
    haystack.includes("preset") || haystack.includes("modeling") || haystack.includes("katana") || haystack.includes("boss") ? "Presets" : null,
    haystack.includes("gate") || haystack.includes("high-gain") || haystack.includes("boss") ? "Noise Gate" : null,
    haystack.includes("bluetooth") || haystack.includes("spark") ? "Bluetooth" : null,
    haystack.includes("usb") || haystack.includes("mustang") || haystack.includes("gt-1000") ? "USB" : null,
    goingDirect || haystack.includes("cab") || haystack.includes("direct") || haystack.includes("modeling") ? "Cab Simulation" : null,
    goingDirect ? "IR Loader" : null
  ].filter(Boolean) as string[];

  return Array.from(new Set(features.length ? features : ["Reverb", "EQ"]));
}

function inferAmpTone(haystack: string, goingDirect: boolean) {
  if (goingDirect) return ["direct", "cab sim", "patch-ready"];
  if (haystack.includes("marshall") || haystack.includes("orange")) return ["british", "mid-forward", "crunch"];
  if (haystack.includes("fender")) return ["clean", "bright", "spring"];
  if (haystack.includes("mesa") || haystack.includes("rectifier")) return ["modern", "high-gain", "tight"];
  if (haystack.includes("bass") || haystack.includes("ampeg")) return ["bass", "round", "punchy"];
  return ["flexible", "stage-ready"];
}

function buildInstrumentDescription(name: string, mode: "guitar" | "bass", characteristics: string[]) {
  return `${name} profile with ${characteristics.join(", ")} response for ${mode === "bass" ? "bass" : "guitar"} tone adaptation.`;
}

function buildAmpDescription(name: string, characteristics: string[], goingDirect: boolean) {
  return goingDirect
    ? `${name} direct workflow for modeler-ready patches and cab simulation.`
    : `${name} profile with ${characteristics.join(", ")} behavior for amp setting adaptation.`;
}

function normalize(value: string) {
  return value.toLowerCase().replace(/[^a-z0-9]+/g, " ").trim();
}
