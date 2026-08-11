import type { FinalToneOutput, ToneType } from "../../../rule-engine";
import type { NormalizedToneAdaptationRequest } from "../dtos";
import type { LoadedToneRequestContext, OriginalToneEffect } from "../types";
import { inferPedalType } from "./gear-inference";
import { buildAmpPanelControls, type AmpPanelControls } from "./amp-panel-controls";

// Deterministic presentation builder: turns the loaded context + rule-engine output
// into the split Original / Adapted result the UI renders. No AI, no randomness —
// same inputs always produce the same presentation.

export interface TonePresentationEffectEntry {
  name: string;
  type: string;
  importance: "important" | "recommended" | "nice-to-have";
  role: string;
}

export interface AmpConfigurationPresentation {
  recommendedPreset: string;
  frontPanelChannel: string;
  toneStudioPreset: string | null;
  reason: string;
  howToAccess: string;
}

export interface AmpEffectSettingEntry {
  effect: string;
  level: number | null;
  effectType: string | null;
  note: string;
}

export interface TonePresentation {
  original: {
    song: string;
    artist: string;
    partLabel: string;
    toneType: string;
    genre: string | null;
    difficulty: { level: string; description: string } | null;
    gear: { guitar: string | null; pickups: string | null; amp: string | null; cab: string | null };
    notes: string | null;
    settings: Record<string, number>;
    guitarControls: { volume: number; tone: number };
    signalChainText: string | null;
    pedalsUsed: TonePresentationEffectEntry[];
    ampEffects: Array<{ effect: string; level: number }>;
    sources: Array<{ type: string; title: string; url: string | null }>;
    researchLinks: Array<{ label: string; url: string }>;
  };
  adapted: {
    gearSummary: string;
    pickupChoice: { recommendation: string; reason: string } | null;
    ampConfiguration: AmpConfigurationPresentation | null;
    cabinet: { recommendation: string; reason: string } | null;
    ampControls: AmpPanelControls | null;
    settings: Record<string, number>;
    guitarControls: { volume: number; tone: number };
    signalChain: string[];
    ampEffectsSettings: AmpEffectSettingEntry[];
    missingEffects: Array<{
      name: string;
      type: string;
      importance: string;
      description: string;
      substitution: string | null;
      alternatives: Array<{ name: string; price: string; tier: "budget" | "mid" | "premium" }>;
    }>;
    keepOff: Array<{ name: string; reason: string }>;
    pedalSettings: Array<{ name: string; setting: string; role: string }>;
    playingNotes: string[];
  };
  confidence: { score: number; factors: string[] };
}

export function buildTonePresentation(
  request: NormalizedToneAdaptationRequest,
  context: LoadedToneRequestContext,
  result: FinalToneOutput
): TonePresentation {
  const original = context.masterTone.original;
  const source = context.masterTone.source;
  const gear = context.gear;

  const originalSettings = mapSettingsForUi(
    original && Object.keys(original.settings).length ? original.settings : numericOnly(context.masterTone.masterTone.settings)
  );
  const adaptedSettings = mapSettingsForUi(numericOnly(result.settings));

  const originalEffects = original?.effects ?? [];
  const partLabel = source.partLabel || "main part";
  const userPedalCoverage = collectUserPedalCategories(request, context);
  const userAmpIsModeler = isModelingAmp(context);

  const missingEffects = buildMissingEffects(originalEffects, userPedalCoverage, partLabel, gear.goingDirect, Boolean(gear.multiFx), userAmpIsModeler);
  const keepOff = buildKeepOff(request, context, originalEffects, source.toneType, partLabel);
  const pedalSettings = buildPedalSettings(
    request,
    context,
    originalEffects,
    source.toneType,
    source.partType,
    new Set(keepOff.map((entry) => entry.name)),
    typeof adaptedSettings.gain === "number" ? adaptedSettings.gain : 0
  );
  const adaptedCabinet = buildAdaptedCabinet(original?.cab ?? null, original?.amp ?? null, context);
  const ampControls = buildAmpPanelControls({
    ampName: context.gear.amplifier?.name ?? context.gear.multiFx?.name ?? request.amp?.name ?? "",
    originalAmp: original?.amp ?? null,
    toneType: String(source.toneType),
    partType: source.partType,
    goingDirect: gear.goingDirect
  });
  const ampEffectsSettings = buildAmpEffectsSettings(originalEffects, originalSettings, adaptedSettings, userPedalCoverage, userAmpIsModeler, original?.amp ?? null, source.toneType);

  return {
    original: {
      song: source.songTitle,
      artist: source.artistName,
      partLabel,
      toneType: source.toneType,
      genre: original?.genre ?? null,
      difficulty: buildDifficulty(original?.difficulty ?? null, source.partType, partLabel),
      gear: {
        guitar: original?.guitar ?? null,
        pickups: original?.pickup ?? null,
        amp: original?.amp ?? null,
        cab: original?.cab ?? null
      },
      notes: original?.notes ?? null,
      settings: originalSettings,
      guitarControls: guitarControlsFor(source.toneType, source.partType),
      signalChainText: buildOriginalChainText(original?.guitar ?? null, originalEffects, original?.amp ?? null),
      pedalsUsed: originalEffects.map((effect) => ({
        name: effect.name,
        type: effectCategory(effect.type),
        importance: effectImportance(effectCategory(effect.type), source.partType),
        role: effectRole(effect, partLabel)
      })),
      ampEffects: buildOriginalAmpEffects(originalSettings),
      sources: (original?.sources ?? [])
        .filter((entry) => Boolean(entry.url))
        .map((entry) => ({ type: entry.type, title: entry.title, url: entry.url ?? null })),
      researchLinks: buildResearchLinks(source.songTitle, source.artistName)
    },
    adapted: {
      gearSummary: buildGearSummary(request, context),
      pickupChoice: buildPickupChoice(original?.pickup ?? null, context),
      ampConfiguration: buildAmpConfiguration(original?.amp ?? null, source.toneType, userAmpIsModeler, context),
      cabinet: adaptedCabinet,
      ampControls,
      settings: adaptedSettings,
      guitarControls: guitarControlsFor(request.toneType, source.partType),
      signalChain: buildAdaptedChain(request, context),
      ampEffectsSettings,
      missingEffects,
      keepOff,
      pedalSettings,
      playingNotes: buildPlayingNotes(original?.playingNotes ?? [], original?.adaptationNotes ?? [], missingEffects)
    },
    confidence: computeConfidence(source.confidence, context)
  };
}

const UI_SETTING_ALIASES: Array<[string, string[]]> = [
  ["gain", ["gain"]],
  ["bass", ["bass"]],
  ["mids", ["mids", "middle", "mid"]],
  ["treble", ["treble"]],
  ["presence", ["presence"]],
  ["reverb", ["reverb"]],
  ["delay", ["delay"]],
  ["compression", ["compression"]],
  ["master", ["master", "masterVolume", "master_volume"]]
];

function mapSettingsForUi(settings: Record<string, number>): Record<string, number> {
  const output: Record<string, number> = {};
  for (const [uiKey, aliases] of UI_SETTING_ALIASES) {
    for (const alias of aliases) {
      if (typeof settings[alias] === "number") {
        output[uiKey] = settings[alias];
        break;
      }
    }
  }
  return output;
}

function numericOnly(settings: Record<string, unknown>): Record<string, number> {
  return Object.entries(settings).reduce<Record<string, number>>((accumulator, [key, value]) => {
    if (typeof value === "number" && Number.isFinite(value)) {
      accumulator[key] = value;
    }
    return accumulator;
  }, {});
}

function effectCategory(type: string): string {
  const normalized = type.toLowerCase();
  if (/overdrive|distortion|fuzz|boost|drive/.test(normalized)) return "drive";
  if (/delay|echo/.test(normalized)) return "delay";
  if (/reverb/.test(normalized)) return "reverb";
  if (/chorus|flanger|phaser|tremolo|vibrato|modulation/.test(normalized)) return "modulation";
  if (/compress/.test(normalized)) return "compressor";
  if (/\beq\b|equal/.test(normalized)) return "eq";
  if (/gate/.test(normalized)) return "gate";
  if (/wah/.test(normalized)) return "wah";
  if (/pitch|octav/.test(normalized)) return "pitch";
  return "effect";
}

function effectImportance(category: string, partType: string): "important" | "recommended" | "nice-to-have" {
  if (category === "drive") return "important";
  if (category === "delay") return partType === "solo" || partType === "lead" ? "important" : "recommended";
  if (category === "reverb" || category === "compressor") return "recommended";
  return "nice-to-have";
}

const CATEGORY_LABELS: Record<string, string> = {
  drive: "drive pedal",
  delay: "delay",
  reverb: "reverb",
  modulation: "modulation effect",
  compressor: "compressor",
  eq: "EQ",
  gate: "noise gate",
  wah: "wah pedal",
  pitch: "pitch effect",
  effect: "similar effect"
};

// Curated real-world buy recommendations per effect category (budget / mid / premium).
// Prices are approximate USD street prices — refreshed periodically; treated as guidance, not live pricing.
type PedalAlternative = { name: string; price: string; tier: "budget" | "mid" | "premium" };
const PEDAL_ALTERNATIVES: Record<string, PedalAlternative[]> = {
  drive: [
    { name: "Boss SD-1 Super Overdrive", price: "$59", tier: "budget" },
    { name: "Ibanez TS9 Tube Screamer", price: "$109", tier: "mid" },
    { name: "Fulltone OCD", price: "$129", tier: "premium" }
  ],
  delay: [
    { name: "TC Electronic Flashback 2", price: "$139", tier: "budget" },
    { name: "MXR Carbon Copy", price: "$149", tier: "mid" },
    { name: "Strymon Timeline", price: "$449", tier: "premium" }
  ],
  reverb: [
    { name: "TC Electronic Hall of Fame 2", price: "$149", tier: "budget" },
    { name: "Boss RV-6", price: "$169", tier: "mid" },
    { name: "Strymon BigSky", price: "$479", tier: "premium" }
  ],
  modulation: [
    { name: "MXR Phase 90", price: "$99", tier: "budget" },
    { name: "Boss CE-5 Chorus", price: "$119", tier: "mid" },
    { name: "EHX Small Clone", price: "$99", tier: "premium" }
  ],
  compressor: [
    { name: "Donner Ultimate Comp", price: "$45", tier: "budget" },
    { name: "Boss CS-3", price: "$109", tier: "mid" },
    { name: "Keeley Compressor Plus", price: "$179", tier: "premium" }
  ],
  eq: [
    { name: "Caline 10-Band EQ", price: "$45", tier: "budget" },
    { name: "Boss GE-7", price: "$109", tier: "mid" },
    { name: "MXR 10-Band M108S", price: "$149", tier: "premium" }
  ],
  wah: [
    { name: "Donner Wah", price: "$45", tier: "budget" },
    { name: "Dunlop Cry Baby GCB95", price: "$99", tier: "mid" },
    { name: "Vox V847-A", price: "$119", tier: "premium" }
  ],
  pitch: [
    { name: "Mooer Pitch Box", price: "$79", tier: "budget" },
    { name: "EHX Pitch Fork", price: "$153", tier: "mid" },
    { name: "DigiTech Whammy 5", price: "$199", tier: "premium" }
  ],
  gate: [
    { name: "Donner Noise Killer", price: "$39", tier: "budget" },
    { name: "Boss NS-2", price: "$119", tier: "mid" },
    { name: "ISP Decimator II", price: "$199", tier: "premium" }
  ]
};

// Effect categories the app will flag on the user's board to turn OFF when the tone doesn't use them.
// Drive is only flagged for genuinely clean tones (a distorted tone may legitimately want the user's drive).
const KEEP_OFF_CATEGORIES = new Set(["modulation", "delay", "reverb", "pitch", "wah"]);
const CLEAN_TONE_TYPES = new Set(["clean", "acoustic", "bass_clean"]);
const HEAVY_TONE_TYPES = new Set(["high_gain", "metal", "modern_metal", "heavy", "djent"]);
const CRUNCH_TONE_TYPES = new Set(["crunch", "edge_of_breakup", "classic_rock"]);

function effectRole(effect: OriginalToneEffect, partLabel: string): string {
  const placement = effect.placement === "front" ? "in front of the amp" : effect.placement === "loop" ? "in the FX loop" : "after the gain stage";
  return `Used ${placement} on the ${partLabel}.`;
}

function collectUserPedalCategories(request: NormalizedToneAdaptationRequest, context: LoadedToneRequestContext): Set<string> {
  const categories = new Set<string>();
  for (const pedal of context.gear.pedals) {
    categories.add(effectCategory(pedal.type));
  }
  for (const pedal of request.pedals) {
    if (pedal.name) {
      categories.add(effectCategory(inferPedalType(pedal.name)));
    }
  }
  return categories;
}

function isModelingAmp(context: LoadedToneRequestContext): boolean {
  if (context.gear.goingDirect && context.gear.multiFx) {
    return true;
  }
  return context.gear.amplifier?.technology === "digital_modeling";
}

function buildMissingEffects(
  originalEffects: OriginalToneEffect[],
  userCoverage: Set<string>,
  partLabel: string,
  goingDirect: boolean,
  hasMultiFx: boolean,
  userAmpIsModeler: boolean
) {
  if (goingDirect && hasMultiFx) {
    return [];
  }

  const seenCategories = new Set<string>();
  const missing: TonePresentation["adapted"]["missingEffects"] = [];

  for (const effect of originalEffects) {
    const category = effectCategory(effect.type);
    if (category === "effect" || userCoverage.has(category) || seenCategories.has(category)) {
      continue;
    }
    seenCategories.add(category);

    const substitutable = category === "reverb" || category === "delay" || (userAmpIsModeler && category === "modulation");
    missing.push({
      name: effect.name,
      type: category,
      importance: effectImportance(category, partLabel),
      description: `${effect.name} was used on the original ${partLabel}. Your ${partLabel} may lose some of its character without a ${CATEGORY_LABELS[category] ?? category}.`,
      substitution: substitutable ? `Use your amp's ${CATEGORY_LABELS[category] ?? category} if it has one.` : null,
      alternatives: PEDAL_ALTERNATIVES[category] ?? []
    });
  }

  const importanceRank = { important: 0, recommended: 1, "nice-to-have": 2 } as const;
  return missing.sort((left, right) => importanceRank[left.importance as keyof typeof importanceRank] - importanceRank[right.importance as keyof typeof importanceRank]);
}

// "Keep these off" — the user's own pedals whose effect the original tone did NOT use.
// Two gear names refer to the SAME physical unit when one is a substring of the other
// (after stripping punctuation/spacing) or they share an alphanumeric model token like
// "ds1" / "dd7" / "ts9". This collapses a raw request name ("Boss DS-1 Distortion") and
// its catalog-resolved twin ("Keeley Andy Timmons Mod Boss DS-1") into one entry so the
// user never sees the same pedal listed twice. Pure-number tokens (e.g. "90") are ignored
// to avoid false merges between unrelated pedals.
function sameGear(a: string, b: string): boolean {
  const norm = (s: string) => s.toLowerCase().replace(/[^a-z0-9]+/g, "");
  const na = norm(a);
  const nb = norm(b);
  if (!na || !nb) return false;
  if (na.includes(nb) || nb.includes(na)) return true;
  // Model designators like "DS-1", "DD-7", "TS9", "GCB95", "M108S" — a short letter run
  // immediately followed by digits (an optional single separator between them). The
  // separator is stripped so "DS-1" and "DS1" compare equal. A space breaks the run, so
  // "Phase 90" yields no model token and never false-merges with another "…90" pedal.
  const modelTokens = (s: string) =>
    (s.toLowerCase().match(/[a-z]{1,4}-?\d{1,4}[a-z]?/g) ?? []).map((token) => token.replace(/-/g, ""));
  const ma = modelTokens(a);
  const mb = modelTokens(b);
  return ma.length > 0 && ma.some((token) => mb.includes(token));
}

function buildKeepOff(
  request: NormalizedToneAdaptationRequest,
  context: LoadedToneRequestContext,
  originalEffects: OriginalToneEffect[],
  toneType: string,
  partLabel: string
): Array<{ name: string; reason: string }> {
  const originalCategories = new Set(originalEffects.map((effect) => effectCategory(effect.type)));
  const toneIsClean = CLEAN_TONE_TYPES.has(String(toneType));

  // Resolved gear first (the units the rule engine reasoned about), then any raw request
  // pedals that failed to resolve — deduped by fuzzy identity so a name-drift twin of an
  // already-listed pedal is not added a second time.
  const userPedals: Array<{ name: string; category: string }> = [];
  const addPedal = (name: string | null | undefined, category: string) => {
    if (!name) return;
    if (userPedals.some((entry) => sameGear(entry.name, name))) return;
    userPedals.push({ name, category });
  };
  for (const pedal of context.gear.pedals) {
    addPedal(pedal.name, effectCategory(pedal.type));
  }
  for (const pedal of request.pedals) {
    addPedal(pedal.name, effectCategory(inferPedalType(pedal.name ?? "")));
  }

  const keepOff: Array<{ name: string; reason: string }> = [];
  for (const pedal of userPedals) {
    const shouldFlag = KEEP_OFF_CATEGORIES.has(pedal.category) || (pedal.category === "drive" && toneIsClean);
    if (!shouldFlag || originalCategories.has(pedal.category)) continue;
    keepOff.push({
      name: pedal.name,
      reason: `The original ${partLabel} didn't use ${CATEGORY_LABELS[pedal.category] ?? pedal.category} — keep it off for an accurate match.`
    });
  }
  return keepOff;
}

// Per-pedal "how to dial it" for the pedals the user selected and should keep ON. Pedals the
// tone doesn't use are handled by buildKeepOff (the OFF list); every other selected pedal gets
// a concrete setting + role here — so a user's pedal is never silently ignored (tester feedback).
function buildPedalSettings(
  request: NormalizedToneAdaptationRequest,
  context: LoadedToneRequestContext,
  originalEffects: OriginalToneEffect[],
  toneType: string,
  partType: string,
  keepOffNames: Set<string>,
  adaptedGain: number
): Array<{ name: string; setting: string; role: string }> {
  const originalCategories = new Set(originalEffects.map((effect) => effectCategory(effect.type)));
  const flags = {
    heavy: HEAVY_TONE_TYPES.has(String(toneType)),
    crunch: CRUNCH_TONE_TYPES.has(String(toneType)),
    clean: CLEAN_TONE_TYPES.has(String(toneType)),
    lead: partType === "solo" || partType === "lead",
    ampGainHigh: adaptedGain >= 8
  };

  // Same fuzzy dedup as buildKeepOff so a name-drift twin isn't listed twice.
  const pedals: Array<{ name: string; category: string }> = [];
  const addPedal = (name: string | null | undefined, category: string) => {
    if (!name) return;
    if (pedals.some((entry) => sameGear(entry.name, name))) return;
    pedals.push({ name, category });
  };
  for (const pedal of context.gear.pedals) addPedal(pedal.name, effectCategory(pedal.type));
  for (const pedal of request.pedals) addPedal(pedal.name, effectCategory(inferPedalType(pedal.name ?? "")));

  const out: Array<{ name: string; setting: string; role: string }> = [];
  for (const pedal of pedals) {
    if (keepOffNames.has(pedal.name)) continue; // already on the OFF list
    const guidance = pedalGuidanceFor(pedal.category, { ...flags, originalUses: originalCategories.has(pedal.category) });
    if (guidance) out.push({ name: pedal.name, setting: guidance.setting, role: guidance.role });
  }
  return out;
}

function pedalGuidanceFor(
  category: string,
  ctx: { heavy: boolean; crunch: boolean; clean: boolean; lead: boolean; originalUses: boolean; ampGainHigh: boolean }
): { setting: string; role: string } | null {
  switch (category) {
    case "drive":
      // Amp already dimed (heavy tone, or the adapted gain is already high): an overdrive
      // must NOT stack more gain — that's just piling drive on drive. Run it as a clean
      // boost / tone-shaper instead, and tell the player they can leave it off.
      if (ctx.heavy || ctx.ampGainHigh) {
        return {
          setting: "Drive 0–1 · Level 7–8 · Tone ~6",
          role: "Your amp is already high-gain, so run this as a clean boost (Drive near 0) — it tightens the low end and pushes mids without adding more dirt. If the tone's already there, leave it off."
        };
      }
      if (ctx.crunch) {
        return ctx.originalUses
          ? { setting: "Drive 5–6 · Level ~6 · Tone 5–6", role: "This is the main dirt — dial the grit here and keep the amp itself cleaner." }
          : { setting: "Drive 2–3 · Level 7 · Tone 6", role: "Light boost to push the amp into breakup and add mids." };
      }
      return { setting: "Drive 3–4 · Level 6–7 · Tone 5–6", role: "Adds gain and mids in front of the amp." };
    case "delay":
      return {
        setting: ctx.lead ? "¼-note time · 3–4 repeats · Mix 25–30%" : "Dotted-⅛ or ¼ time · 2–3 repeats · Mix 15–20%",
        role: "Matches the original's delay — set the time to the song's tempo."
      };
    case "reverb":
      return {
        setting: ctx.clean ? "Spring/Room · Mix 20–30%" : "Room · Mix 10–20%",
        role: "Adds the original's ambience — keep it subtle so riffs stay defined."
      };
    case "modulation":
      return { setting: "Rate & Depth low (subtle)", role: "Matches the original's modulation movement." };
    case "compressor":
      return ctx.clean
        ? { setting: "Ratio low · light squish · Level unity", role: "Evens out clean picking and adds a little sustain." }
        : { setting: "Light · Level unity", role: "Optional — a touch of compression for consistency." };
    case "wah":
      return { setting: "Sweep by ear", role: "For the wah passages — or park it for a fixed cocked-wah tone." };
    case "gate":
      return {
        setting: ctx.heavy ? "Threshold just enough to kill hum · fast release" : "Light / off",
        role: "Tightens string and amp noise on high-gain patches."
      };
    default:
      return null;
  }
}

// Adapted cabinet recommendation — the original result never surfaced a cab on the user's side.
function buildAdaptedCabinet(
  originalCab: string | null,
  originalAmp: string | null,
  context: LoadedToneRequestContext
): { recommendation: string; reason: string } | null {
  const character = describeCabCharacter(originalCab, originalAmp);
  if (!character && !originalCab) {
    return null;
  }

  const recommendation = character ?? (originalCab ? humanize(originalCab) : "Matched cab voicing");
  const originalRef = originalCab ? ` The original used ${originalCab}.` : "";
  const technology = context.gear.amplifier?.technology ?? null;

  // A generic descriptor ("Closed-back 4×12") reads naturally lowercased; a proper cab
  // name ("Ampeg SVT 8×10") must keep its casing. Pick the article from the first sound so
  // we never emit "a ampeg…".
  const phrase = character ? recommendation.toLowerCase() : recommendation;
  const article = /^[aeiou]/i.test(phrase) ? "an" : "a";

  if (context.gear.goingDirect || technology === "digital_modeling" || technology === "plugin") {
    const unit = context.gear.multiFx?.name ?? context.gear.amplifier?.name ?? "your modeler";
    return {
      recommendation,
      reason: `Load ${article} ${phrase} cab IR in ${unit}.${originalRef}`
    };
  }

  const userCab = context.gear.cabinet?.name ?? null;
  if (userCab) {
    return {
      recommendation: userCab,
      reason: `Run your ${userCab} and aim for ${article} ${phrase} voicing.${originalRef}`
    };
  }

  const amp = context.gear.amplifier?.name ?? "your amp";
  return {
    recommendation,
    reason: `Pair ${amp} with ${article} ${phrase}.${originalRef}`
  };
}

function describeCabCharacter(originalCab: string | null, originalAmp: string | null): string | null {
  const text = `${originalCab ?? ""} ${originalAmp ?? ""}`.toLowerCase();
  if (!text.trim()) return null;

  const size = /8\s*x\s*10/.test(text)
    ? "8×10"
    : /6\s*x\s*10/.test(text)
      ? "6×10"
      : /4\s*x\s*10/.test(text)
        ? "4×10"
        : /2\s*x\s*10/.test(text)
          ? "2×10"
          : /1\s*x\s*15/.test(text)
            ? "1×15"
            : /1\s*x\s*18/.test(text)
              ? "1×18"
              : /4\s*x\s*12/.test(text)
                ? "4×12"
                : /2\s*x\s*12/.test(text)
                  ? "2×12"
                  : /1\s*x\s*12/.test(text)
                    ? "1×12"
                    : /1\s*x\s*10/.test(text)
                      ? "1×10"
                      : null;

  let speaker: string | null = null;
  if (/v30|vintage\s*30/.test(text)) speaker = "V30-style";
  else if (/greenback|g12m/.test(text)) speaker = "Greenback-style";
  else if (/creamback|g12h/.test(text)) speaker = "Creamback-style";
  else if (/celestion\s*blue|alnico\s*blue/.test(text)) speaker = "Celestion Blue-style";
  else if (/jensen/.test(text)) speaker = "Jensen-style";
  else if (/eminence/.test(text)) speaker = "Eminence-style";

  const sealedBassCab = size === "8×10" || size === "6×10";
  const back = sealedBassCab || /\bsealed\b/.test(text)
    ? "sealed"
    : /closed[\s-]*back/.test(text) || (size === "4×12" && !/open/.test(text))
      ? "closed-back"
      : /open[\s-]*back|combo|deluxe|twin|princeton|vibro|champ|ac30|ac15|tweed/.test(text)
        ? "open-back"
        : null;

  const parts = [back, size, speaker ? `with ${speaker} speakers` : null].filter(Boolean);
  if (!parts.length) return null;
  const label = parts.join(" ");
  return label.charAt(0).toUpperCase() + label.slice(1);
}

const REVERB_TYPE_FROM_AMP: Array<{ pattern: RegExp; reverbType: string }> = [
  { pattern: /twin|deluxe|princeton|vibrolux|vibroverb|fender|blackface|silverface|bassman/i, reverbType: "Spring" },
  { pattern: /vox|ac30|ac15/i, reverbType: "Spring" },
  { pattern: /marshall|jcm|plexi|super lead|1959|jtm/i, reverbType: "Spring" },
  { pattern: /mesa|rectifier|recto|5150|6505/i, reverbType: "Hall" },
  { pattern: /soldano|slo/i, reverbType: "Hall" },
  { pattern: /jazz chorus|jc-?120|roland/i, reverbType: "Hall" },
  { pattern: /hiwatt/i, reverbType: "Plate" },
  { pattern: /dumble/i, reverbType: "Spring" }
];

const REVERB_TYPE_FROM_EFFECT_NAME: Array<{ pattern: RegExp; reverbType: string }> = [
  { pattern: /spring/i, reverbType: "Spring" },
  { pattern: /plate/i, reverbType: "Plate" },
  { pattern: /hall/i, reverbType: "Hall" },
  { pattern: /room|chamber/i, reverbType: "Room" },
  { pattern: /shimmer/i, reverbType: "Shimmer" }
];

function inferReverbType(
  originalAmp: string | null,
  originalEffects: OriginalToneEffect[],
  toneType: string
): string {
  const reverbEffect = originalEffects.find((e) => effectCategory(e.type) === "reverb");
  if (reverbEffect) {
    const fromName = REVERB_TYPE_FROM_EFFECT_NAME.find((entry) => entry.pattern.test(reverbEffect.name));
    if (fromName) return fromName.reverbType;
  }

  if (originalAmp) {
    const fromAmp = REVERB_TYPE_FROM_AMP.find((entry) => entry.pattern.test(originalAmp));
    if (fromAmp) return fromAmp.reverbType;
  }

  if (toneType === "ambient" || toneType === "post_rock") return "Hall";
  if (toneType === "clean" || toneType === "classic_rock" || toneType === "crunch") return "Spring";

  return "Spring";
}

function buildAmpEffectsSettings(
  originalEffects: OriginalToneEffect[],
  originalSettings: Record<string, number>,
  adaptedSettings: Record<string, number>,
  userCoverage: Set<string>,
  userAmpIsModeler: boolean,
  originalAmp: string | null,
  toneType: string
): AmpEffectSettingEntry[] {
  const entries: AmpEffectSettingEntry[] = [];

  if (typeof adaptedSettings.reverb === "number" && adaptedSettings.reverb > 0) {
    const reverbType = inferReverbType(originalAmp, originalEffects, toneType);
    entries.push({
      effect: "Reverb",
      level: adaptedSettings.reverb,
      effectType: reverbType,
      note:
        typeof originalSettings.reverb === "number" && originalSettings.reverb > 0
          ? `Use ${reverbType} reverb to match the original character.`
          : `Light ${reverbType.toLowerCase()} ambience to glue the tone together.`
    });
  }

  const originalDelay = originalEffects.find((effect) => effectCategory(effect.type) === "delay");
  if (originalDelay && !userCoverage.has("delay")) {
    entries.push({
      effect: "Delay",
      level: typeof adaptedSettings.delay === "number" && adaptedSettings.delay > 0 ? adaptedSettings.delay : null,
      effectType: null,
      note: `Use your amp's delay instead of the ${originalDelay.name}.`
    });
  }

  if (userAmpIsModeler) {
    const originalModulation = originalEffects.find((effect) => effectCategory(effect.type) === "modulation");
    if (originalModulation && !userCoverage.has("modulation")) {
      entries.push({
        effect: "Modulation",
        level: null,
        effectType: null,
        note: `Enable your amp's modulation block to stand in for the ${originalModulation.name}.`
      });
    }
  }

  return entries;
}

// Deterministic, always-valid outbound research destinations for the original tone.
// These are real working search/reference endpoints — NOT fabricated "sources we analyzed".
function buildResearchLinks(song: string, artist: string): Array<{ label: string; url: string }> {
  const songArtist = `${song} ${artist}`.trim();
  if (!songArtist) {
    return [];
  }
  const q = (value: string) => encodeURIComponent(value);
  const links: Array<{ label: string; url: string }> = [];

  if (artist) {
    links.push({ label: `${artist}'s gear on Equipboard`, url: `https://equipboard.com/search?q=${q(artist)}` });
  }
  links.push({ label: "Amp settings & tone breakdown", url: `https://www.google.com/search?q=${q(`${songArtist} guitar tone amp settings`)}` });
  links.push({ label: "Tab on Ultimate Guitar", url: `https://www.ultimate-guitar.com/search.php?search_type=title&value=${q(songArtist)}` });
  links.push({ label: "Rig rundown on YouTube", url: `https://www.youtube.com/results?search_query=${q(`${artist || song} guitar rig rundown gear`)}` });

  return links;
}

function buildOriginalAmpEffects(originalSettings: Record<string, number>) {
  const entries: Array<{ effect: string; level: number }> = [];
  if (typeof originalSettings.reverb === "number" && originalSettings.reverb > 0) {
    entries.push({ effect: "Reverb", level: originalSettings.reverb });
  }
  if (typeof originalSettings.delay === "number" && originalSettings.delay > 0) {
    entries.push({ effect: "Delay", level: originalSettings.delay });
  }
  return entries;
}

function guitarControlsFor(toneType: ToneType | string, partType: string): { volume: number; tone: number } {
  if (partType === "solo" || partType === "lead") {
    return { volume: 10, tone: 10 };
  }
  switch (toneType) {
    case "clean":
    case "acoustic":
    case "bass_clean":
      return { volume: 8, tone: 6.5 };
    case "crunch":
    case "edge_of_breakup":
    case "classic_rock":
      return { volume: 9, tone: 7.5 };
    default:
      return { volume: 10, tone: 8.5 };
  }
}

function buildOriginalChainText(guitar: string | null, effects: OriginalToneEffect[], amp: string | null): string | null {
  const nodes = [guitar, ...effects.map((effect) => effect.name), amp].filter(
    (node): node is string => typeof node === "string" && node.length > 0
  );
  return nodes.length >= 2 ? nodes.join(" → ") : null;
}

function buildAdaptedChain(request: NormalizedToneAdaptationRequest, context: LoadedToneRequestContext): string[] {
  const chain: string[] = [context.gear.guitar?.name ?? request.guitar?.name ?? "Guitar"];

  const pedalNames = context.gear.pedals.length
    ? context.gear.pedals.map((pedal) => pedal.name)
    : request.pedals.map((pedal) => pedal.name).filter((name): name is string => Boolean(name));
  chain.push(...pedalNames);

  if (context.gear.goingDirect) {
    chain.push(context.gear.multiFx ? `${context.gear.multiFx.name} (direct)` : "Direct interface");
  } else {
    const amp = context.gear.amplifier?.name ?? request.amp?.name;
    chain.push(amp ? `${amp} input` : "Amp input");
  }

  return chain;
}

function buildGearSummary(request: NormalizedToneAdaptationRequest, context: LoadedToneRequestContext): string {
  const guitar = context.gear.guitar?.name ?? request.guitar?.name;
  if (context.gear.goingDirect) {
    const unit = context.gear.multiFx?.name ?? request.multiFx?.name;
    return [guitar, unit ? `${unit} (direct)` : "Direct"].filter(Boolean).join(" + ");
  }
  const amp = context.gear.amplifier?.name ?? request.amp?.name;
  return [guitar, amp].filter(Boolean).join(" + ") || "Your rig";
}

function buildPickupChoice(originalPickup: string | null, context: LoadedToneRequestContext): { recommendation: string; reason: string } | null {
  const preference = originalPickup ?? context.masterTone.masterTone.pickupPreference ?? null;
  if (!preference) {
    return null;
  }

  const lower = preference.toLowerCase();
  const position = /bridge/.test(lower) ? "Bridge" : /neck/.test(lower) ? "Neck" : /middle/.test(lower) ? "Middle" : null;
  const recommendation = position ? `${position} pickup` : humanize(preference);

  return {
    recommendation,
    reason: `The original tone used ${preference.replace(/_/g, " ")}.`
  };
}

const PRESET_KEYWORDS: Array<{ pattern: RegExp; preset: string; channel: string }> = [
  { pattern: /tweed|bassman|champ/i, preset: "Tweed", channel: "Crunch" },
  { pattern: /deluxe reverb|twin|blackface|princeton|vibrolux|vibroverb/i, preset: "Blackface Clean", channel: "Clean" },
  { pattern: /ac30|ac15|vox/i, preset: "Class A Chime", channel: "Crunch" },
  { pattern: /plexi|super lead|1959|jtm/i, preset: "Plexi Crunch", channel: "Lead" },
  { pattern: /jcm|marshall/i, preset: "British Crunch", channel: "Crunch" },
  { pattern: /rectifier|recto|mesa|5150|6505|uberschall|high.?gain/i, preset: "Modern High Gain", channel: "Brown" },
  { pattern: /soldano|slo.?100/i, preset: "Boutique High Gain", channel: "Lead" },
  { pattern: /hiwatt/i, preset: "Loud Clean", channel: "Clean" },
  { pattern: /jazz chorus|jc-?120/i, preset: "FX Clean", channel: "Clean" },
  { pattern: /dumble/i, preset: "Boutique Overdrive", channel: "Crunch" }
];

const TONE_TYPE_CHANNELS: Record<string, string> = {
  clean: "Clean",
  acoustic: "Clean",
  bass_clean: "Clean",
  crunch: "Crunch",
  edge_of_breakup: "Crunch",
  classic_rock: "Crunch",
  high_gain: "Lead",
  metal: "Brown",
  modern_metal: "Brown",
  heavy: "Brown"
};

function buildAmpConfiguration(
  originalAmp: string | null,
  toneType: ToneType | string,
  userAmpIsModeler: boolean,
  context: LoadedToneRequestContext
): AmpConfigurationPresentation | null {
  if (!userAmpIsModeler) {
    return null;
  }

  // The "set the amp type + Boss Tone Studio variation" workflow is specific to Boss
  // Katana / Nextone. Other modelers (AmpliTube, Helix, Neural, Fractal…) get their
  // amp-model guidance from buildAmpPanelControls instead — never show them Boss-only
  // instructions like "connect to Boss Tone Studio".
  const ampName = context.gear.amplifier?.name ?? context.gear.multiFx?.name ?? "your modeler";
  if (!/katana|nextone/i.test(ampName)) {
    return null;
  }

  const matched = originalAmp ? PRESET_KEYWORDS.find((entry) => entry.pattern.test(originalAmp)) : undefined;
  const fallbackPreset =
    toneType === "clean" || toneType === "acoustic" || toneType === "bass_clean"
      ? "Clean"
      : toneType === "crunch" || toneType === "edge_of_breakup" || toneType === "classic_rock"
        ? "Crunch"
        : toneType === "high_gain" || toneType === "metal" || toneType === "modern_metal" || toneType === "heavy"
          ? "High Gain"
          : "Drive";

  const preset = matched?.preset ?? fallbackPreset;
  const frontPanelChannel = matched?.channel ?? TONE_TYPE_CHANNELS[String(toneType)] ?? "Clean";
  const hasToneStudioVariation = matched != null && matched.preset !== frontPanelChannel;

  return {
    recommendedPreset: preset,
    frontPanelChannel,
    toneStudioPreset: hasToneStudioVariation ? preset : null,
    reason: matched
      ? `Matches the original ${originalAmp}.`
      : `Best-fit for a ${String(toneType).replace(/_/g, " ")} tone.`,
    howToAccess: hasToneStudioVariation
      ? `On your ${ampName}, set the amp type to ${frontPanelChannel}. For a closer match, connect to Boss Tone Studio and select the ${preset} variation.`
      : `On your ${ampName}, set the amp type to ${frontPanelChannel}.`
  };
}

function buildPlayingNotes(
  playingNotes: string[],
  adaptationNotes: string[],
  missingEffects: TonePresentation["adapted"]["missingEffects"]
): string[] {
  const substitutionNotes = missingEffects
    .filter((effect) => effect.substitution)
    .map((effect) => `${effect.substitution} It stands in for the ${effect.name}.`);

  const combined = [...playingNotes, ...substitutionNotes, ...adaptationNotes];
  const seen = new Set<string>();
  const output: string[] = [];
  for (const note of combined) {
    const key = note.trim().toLowerCase();
    if (!key || seen.has(key)) continue;
    seen.add(key);
    output.push(note);
    if (output.length >= 6) break;
  }
  return output;
}

const DIFFICULTY_DESCRIPTIONS: Record<string, string> = {
  beginner: "Straightforward part — focus on clean fretting and steady timing.",
  intermediate: "Moderate challenge — watch the picking accuracy and dynamics.",
  advanced: "Demanding part — requires controlled bending, vibrato, and precise timing.",
  expert: "Very demanding — advanced technique, speed, and dynamic control throughout."
};

function buildDifficulty(difficulty: string | null, partType: string, partLabel: string): { level: string; description: string } | null {
  if (!difficulty) {
    return null;
  }
  const description = DIFFICULTY_DESCRIPTIONS[difficulty.toLowerCase()] ?? `Difficulty rated ${difficulty} for the ${partLabel}.`;
  return { level: difficulty, description };
}

function computeConfidence(sourceConfidence: number, context: LoadedToneRequestContext): { score: number; factors: string[] } {
  let score = sourceConfidence;
  const factors: string[] = [];
  const resolution = context.gear.resolution;

  if (resolution) {
    if (resolution.guitar === "none") {
      score -= 15;
      factors.push("Guitar could not be matched — guitar-specific compensation was skipped.");
    } else if (resolution.guitar === "inferred") {
      score -= 6;
      factors.push("Guitar matched by name inference rather than the gear catalog.");
    }

    if (!context.gear.goingDirect) {
      if (resolution.amp === "none") {
        score -= 15;
        factors.push("Amp could not be matched — amp-specific compensation was skipped.");
      } else if (resolution.amp === "inferred") {
        score -= 6;
        factors.push("Amp matched by name inference rather than the gear catalog.");
      }
    }

    if (resolution.pickupsRequested > 0 && resolution.pickupsMatched === 0) {
      score -= 4;
      factors.push("Selected pickups could not be matched to pickup profiles.");
    }

    if (resolution.pedalsRequested > resolution.pedalsMatched) {
      score -= 2;
      factors.push("Some pedals could not be matched to pedal profiles.");
    }
  }

  return {
    score: Math.max(35, Math.min(98, Math.round(score))),
    factors
  };
}

function humanize(value: string): string {
  const cleaned = value.replace(/[_-]+/g, " ").trim();
  return cleaned.charAt(0).toUpperCase() + cleaned.slice(1);
}
