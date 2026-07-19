import type { FinalToneOutput, ToneType } from "../../../rule-engine";
import type { NormalizedToneAdaptationRequest } from "../dtos";
import type { LoadedToneRequestContext, OriginalToneEffect } from "../types";
import { inferPedalType } from "./gear-inference";

// Deterministic presentation builder: turns the loaded context + rule-engine output
// into the split Original / Adapted result the UI renders. No AI, no randomness —
// same inputs always produce the same presentation.

export interface TonePresentationEffectEntry {
  name: string;
  type: string;
  importance: "important" | "recommended" | "nice-to-have";
  role: string;
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
  };
  adapted: {
    gearSummary: string;
    pickupChoice: { recommendation: string; reason: string } | null;
    ampConfiguration: { recommendedPreset: string; reason: string } | null;
    settings: Record<string, number>;
    guitarControls: { volume: number; tone: number };
    signalChain: string[];
    ampEffectsSettings: Array<{ effect: string; level: number | null; note: string }>;
    missingEffects: Array<{ name: string; type: string; importance: string; description: string; substitution: string | null }>;
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
  const ampEffectsSettings = buildAmpEffectsSettings(originalEffects, originalSettings, adaptedSettings, userPedalCoverage, userAmpIsModeler);

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
      sources: (original?.sources ?? []).map((entry) => ({ type: entry.type, title: entry.title, url: entry.url ?? null }))
    },
    adapted: {
      gearSummary: buildGearSummary(request, context),
      pickupChoice: buildPickupChoice(original?.pickup ?? null, context),
      ampConfiguration: buildAmpConfiguration(original?.amp ?? null, source.toneType, userAmpIsModeler, context),
      settings: adaptedSettings,
      guitarControls: guitarControlsFor(request.toneType, source.partType),
      signalChain: buildAdaptedChain(request, context),
      ampEffectsSettings,
      missingEffects,
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
      substitution: substitutable ? `Use your amp's ${CATEGORY_LABELS[category] ?? category} if it has one.` : null
    });
  }

  const importanceRank = { important: 0, recommended: 1, "nice-to-have": 2 } as const;
  return missing.sort((left, right) => importanceRank[left.importance as keyof typeof importanceRank] - importanceRank[right.importance as keyof typeof importanceRank]);
}

function buildAmpEffectsSettings(
  originalEffects: OriginalToneEffect[],
  originalSettings: Record<string, number>,
  adaptedSettings: Record<string, number>,
  userCoverage: Set<string>,
  userAmpIsModeler: boolean
) {
  const entries: TonePresentation["adapted"]["ampEffectsSettings"] = [];

  if (typeof adaptedSettings.reverb === "number" && adaptedSettings.reverb > 0) {
    entries.push({
      effect: "Reverb",
      level: adaptedSettings.reverb,
      note:
        typeof originalSettings.reverb === "number" && originalSettings.reverb > 0
          ? "Match the original reverb character."
          : "Light ambience to glue the tone together."
    });
  }

  const originalDelay = originalEffects.find((effect) => effectCategory(effect.type) === "delay");
  if (originalDelay && !userCoverage.has("delay")) {
    entries.push({
      effect: "Delay",
      level: typeof adaptedSettings.delay === "number" && adaptedSettings.delay > 0 ? adaptedSettings.delay : null,
      note: `Use your amp's delay instead of the ${originalDelay.name}.`
    });
  }

  if (userAmpIsModeler) {
    const originalModulation = originalEffects.find((effect) => effectCategory(effect.type) === "modulation");
    if (originalModulation && !userCoverage.has("modulation")) {
      entries.push({
        effect: "Modulation",
        level: null,
        note: `Enable your amp's modulation block to stand in for the ${originalModulation.name}.`
      });
    }
  }

  return entries;
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

const PRESET_KEYWORDS: Array<{ pattern: RegExp; preset: string }> = [
  { pattern: /tweed|bassman|champ/i, preset: "Tweed" },
  { pattern: /deluxe reverb|twin|blackface|princeton|vibrolux|vibroverb/i, preset: "Blackface Clean" },
  { pattern: /ac30|ac15|vox/i, preset: "Class A Chime" },
  { pattern: /plexi|super lead|1959|jtm/i, preset: "Plexi Crunch" },
  { pattern: /jcm|marshall/i, preset: "British Crunch" },
  { pattern: /rectifier|recto|mesa|5150|6505|uberschall|high.?gain/i, preset: "Modern High Gain" },
  { pattern: /hiwatt/i, preset: "Loud Clean" },
  { pattern: /jazz chorus|jc-?120/i, preset: "FX Clean" },
  { pattern: /dumble/i, preset: "Boutique Overdrive" }
];

function buildAmpConfiguration(
  originalAmp: string | null,
  toneType: ToneType | string,
  userAmpIsModeler: boolean,
  context: LoadedToneRequestContext
): { recommendedPreset: string; reason: string } | null {
  if (!userAmpIsModeler) {
    return null;
  }

  const fromOriginal = originalAmp ? PRESET_KEYWORDS.find((entry) => entry.pattern.test(originalAmp))?.preset : undefined;
  const fallback =
    toneType === "clean" || toneType === "acoustic" || toneType === "bass_clean"
      ? "Clean"
      : toneType === "crunch" || toneType === "edge_of_breakup" || toneType === "classic_rock"
        ? "Crunch"
        : toneType === "high_gain" || toneType === "metal" || toneType === "modern_metal" || toneType === "heavy"
          ? "High Gain"
          : "Drive";

  const preset = fromOriginal ?? fallback;
  const ampName = context.gear.amplifier?.name ?? context.gear.multiFx?.name ?? "your modeler";

  return {
    recommendedPreset: preset,
    reason: fromOriginal
      ? `Closest preset family on ${ampName} to the original ${originalAmp}.`
      : `Best-fit preset family on ${ampName} for a ${String(toneType).replace(/_/g, " ")} tone.`
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
