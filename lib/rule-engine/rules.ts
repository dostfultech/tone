import type { PedalProfileInput, RuleContribution, RuleDefinition, RuleEvaluationContext, ToneDeltas, ToneType } from "./types";
import { brightnessToNumber, mergeDeltas, outputLevelToNumber, readNumericProfileValue } from "./utils";

export function createDefaultRules(): RuleDefinition[] {
  return [
    loadMasterToneRule(),
    toneTypeRule(),
    guitarProfileRule(),
    pickupProfileRule(),
    amplifierProfileRule(),
    cabinetProfileRule(),
    pedalProfileRule(),
    goingDirectRule(),
    multiFxMappingRule(),
    finalToneRule()
  ];
}

function loadMasterToneRule(): RuleDefinition {
  return {
    id: "core.load_master_tone",
    stage: "load_master_tone",
    priority: 10,
    description: "Load the normalized master tone as the immutable baseline.",
    when: () => true,
    apply: ({ input }) => ({
      ruleId: "core.load_master_tone",
      stage: "load_master_tone",
      priority: 10,
      description: "Loaded normalized master tone.",
      notes: [`Loaded master tone ${input.masterTone.id}.`],
      metadata: {
        masterToneId: input.masterTone.id,
        sourceToneType: input.masterTone.toneType
      }
    })
  };
}

function toneTypeRule(): RuleDefinition {
  return {
    id: "core.apply_tone_type",
    stage: "tone_type",
    priority: 20,
    description: "Apply deterministic tone-type compensation before gear-specific transforms.",
    when: () => true,
    apply: ({ input }) => {
      const toneType = normalizeToneType(input.toneType || input.masterTone.toneType);
      const deltas = toneTypeDeltas(toneType);
      return {
        ruleId: "core.apply_tone_type",
        stage: "tone_type",
        priority: 20,
        description: `Applied tone type ${toneType}.`,
        deltas,
        notes: [`Tone type set to ${toneType.replaceAll("_", " ")}.`]
      };
    }
  };
}

function guitarProfileRule(): RuleDefinition {
  return {
    id: "gear.apply_guitar_profile",
    stage: "guitar_profile",
    priority: 30,
    description: "Apply guitar-body, output, brightness, warmth, and explicit profile deltas.",
    when: ({ input }) => Boolean(input.guitar),
    apply: ({ input }) => {
      const guitar = input.guitar;
      if (!guitar) return null;

      const brightness = brightnessToNumber(guitar.brightness);
      const output = outputLevelToNumber(guitar.outputLevel);
      const warmth = readNumericProfileValue(guitar.warmth);
      const compression = readNumericProfileValue(guitar.compression);
      const deltas: ToneDeltas[] = [guitar.deltas || {}, readToneSpecificDeltas(guitar.toneTypeDeltas, input.toneType)];

      if (brightness != null && brightness >= 7) {
        deltas.push({ treble: -1, presence: -1 });
      } else if (brightness != null && brightness <= 3.5) {
        deltas.push({ treble: 1, presence: 1 });
      }

      if (output != null && output <= 3.5) {
        deltas.push({ gain: 0.5, compression: 0.5 });
      } else if (output != null && output >= 7) {
        deltas.push({ gain: -0.5, compression: -0.5 });
      }

      if (warmth != null && warmth >= 7) {
        deltas.push({ bass: -0.5, middle: -0.5 });
      } else if (warmth != null && warmth <= 3.5) {
        deltas.push({ bass: 0.5, middle: 0.5 });
      }

      if (compression != null && compression >= 7) {
        deltas.push({ compression: -0.5 });
      } else if (compression != null && compression <= 3.5) {
        deltas.push({ compression: 0.5 });
      }

      return {
        ruleId: "gear.apply_guitar_profile",
        stage: "guitar_profile",
        priority: 30,
        description: `Applied guitar profile ${guitar.name}.`,
        deltas: mergeDeltas(deltas),
        notes: [`Adjusted for guitar profile: ${guitar.name}.`]
      };
    }
  };
}

function pickupProfileRule(): RuleDefinition {
  return {
    id: "gear.apply_pickup_profiles",
    stage: "pickup_profiles",
    priority: 40,
    description: "Apply selected pickup output, active/passive behavior, position, and explicit deltas.",
    when: ({ input }) => Boolean(input.pickups?.length),
    apply: ({ input }) => {
      const pickups = input.pickups || [];
      const contributions: RuleContribution[] = [];

      for (const pickup of pickups) {
        const output = outputLevelToNumber(pickup.outputLevel);
        const brightness = brightnessToNumber(pickup.brightness);
        const deltas: ToneDeltas[] = [pickup.deltas || {}, readToneSpecificDeltas(pickup.toneTypeDeltas, input.toneType)];

        if (output != null && output <= 3.5) {
          deltas.push({ gain: 1, compression: 0.5 });
        } else if (output != null && output >= 7) {
          deltas.push({ gain: -1, compression: -0.5 });
        }

        if (pickup.circuitType === "active") {
          deltas.push({ gain: -0.5, noiseGate: -0.5, compression: -0.5 });
        } else if (pickup.circuitType === "passive") {
          deltas.push({ compression: 0.25 });
        }

        if (brightness != null && brightness >= 7) {
          deltas.push({ treble: -0.5, presence: -0.5 });
        } else if (brightness != null && brightness <= 3.5) {
          deltas.push({ treble: 0.5, presence: 0.5 });
        }

        if (pickup.position === "neck") {
          deltas.push({ bass: -0.5, treble: 0.5 });
        } else if (pickup.position === "bridge") {
          deltas.push({ treble: -0.25, presence: -0.25 });
        }

        contributions.push({
          ruleId: `gear.apply_pickup_profiles.${pickup.position}.${pickup.id}`,
          stage: "pickup_profiles",
          priority: 40,
          description: `Applied ${pickup.position} pickup profile ${pickup.name}.`,
          deltas: mergeDeltas(deltas, 2),
          notes: [`Adjusted for ${pickup.position} pickup: ${pickup.name}.`]
        });
      }

      return contributions;
    }
  };
}

function amplifierProfileRule(): RuleDefinition {
  return {
    id: "gear.apply_amplifier_profile",
    stage: "amplifier_profile",
    priority: 50,
    description: "Apply amplifier gain structure, era, headroom, EQ behavior, and explicit deltas.",
    when: ({ input }) => Boolean(input.amplifier),
    apply: ({ input }) => {
      const amplifier = input.amplifier;
      if (!amplifier) return null;

      const deltas: ToneDeltas[] = [amplifier.deltas || {}, readToneSpecificDeltas(amplifier.toneTypeDeltas, input.toneType)];
      const brightness = brightnessToNumber(amplifier.brightness);
      const warmth = readNumericProfileValue(amplifier.warmth);
      const headroom = readNumericProfileValue(amplifier.cleanHeadroom);

      if (amplifier.era === "vintage" || /vintage|plexi|tweed|blackface/i.test(amplifier.gainStructure || "")) {
        deltas.push({ gain: 0.5, middle: 0.5 });
      }

      if (amplifier.era === "modern" || /modern|high|rectifier|5150/i.test(amplifier.gainStructure || "")) {
        deltas.push({ gain: -0.5, bass: -0.25 });
      }

      if (brightness != null && brightness >= 7) {
        deltas.push({ treble: -0.5, presence: -0.5 });
      } else if (brightness != null && brightness <= 3.5) {
        deltas.push({ treble: 0.5, presence: 0.5 });
      }

      if (warmth != null && warmth >= 7) {
        deltas.push({ bass: -0.5 });
      }

      if (headroom != null && headroom <= 3.5) {
        deltas.push({ gain: -0.5, masterVolume: -0.5 });
      }

      return {
        ruleId: "gear.apply_amplifier_profile",
        stage: "amplifier_profile",
        priority: 50,
        description: `Applied amplifier profile ${amplifier.name}.`,
        deltas: mergeDeltas(deltas),
        notes: [`Adjusted for amplifier profile: ${amplifier.name}.`]
      };
    }
  };
}

// check where this cabinet is present in UI
function cabinetProfileRule(): RuleDefinition {
  return {
    id: "gear.apply_cabinet_profile",
    stage: "cabinet_profile",
    priority: 60,
    description: "Apply cabinet format, back type, speaker curve, and explicit deltas.",
    when: ({ input }) => Boolean(input.cabinet),
    apply: ({ input }) => {
      const cabinet = input.cabinet;
      if (!cabinet) return null;

      const deltas: ToneDeltas[] = [cabinet.deltas || {}, readToneSpecificDeltas(cabinet.toneTypeDeltas, input.toneType)];
      const brightness = brightnessToNumber(cabinet.brightness);
      const lowEnd = readNumericProfileValue(cabinet.lowEnd);
      const highEnd = readNumericProfileValue(cabinet.highEnd);

      if (cabinet.backType === "open_back") {
        deltas.push({ bass: -0.75, depth: -0.5, presence: 0.25 });
      } else if (cabinet.backType === "closed_back") {
        deltas.push({ bass: 0.75, depth: 0.5, presence: -0.25 });
      }

      if (cabinet.format === "1x12") {
        deltas.push({ bass: -0.5 });
      } else if (cabinet.format === "4x12") {
        deltas.push({ bass: 0.5, resonance: 0.5 });
      }

      if (brightness != null && brightness >= 7) {
        deltas.push({ treble: -0.5, presence: -0.5 });
      }

      if (lowEnd != null && lowEnd >= 7) {
        deltas.push({ bass: -0.5, depth: -0.5 });
      }

      if (highEnd != null && highEnd <= 3.5) {
        deltas.push({ treble: 0.5, presence: 0.5 });
      }

      return {
        ruleId: "gear.apply_cabinet_profile",
        stage: "cabinet_profile",
        priority: 60,
        description: `Applied cabinet profile ${cabinet.name}.`,
        deltas: mergeDeltas(deltas),
        notes: [`Adjusted for cabinet profile: ${cabinet.name}.`]
      };
    }
  };
}

function pedalProfileRule(): RuleDefinition {
  return {
    id: "gear.apply_pedals",
    stage: "pedals",
    priority: 70,
    description: "Apply ordered enabled pedal gain, EQ, ambience, compression, and noise contributions.",
    when: ({ input }) => Boolean(input.pedals?.some((pedal) => pedal.enabled !== false)),
    apply: ({ input }) => {
      const pedals = [...(input.pedals || [])].filter((pedal) => pedal.enabled !== false).sort((left, right) => left.order - right.order);
      return pedals.map((pedal) => pedalContribution(pedal));
    }
  };
}

function goingDirectRule(): RuleDefinition {
  return {
    id: "direct.apply_going_direct",
    stage: "going_direct",
    priority: 80,
    description: "Convert amp-room settings toward a direct modeler-friendly baseline.",
    when: ({ input }) => Boolean(input.goingDirect),
    apply: ({ input }) => ({
      ruleId: "direct.apply_going_direct",
      stage: "going_direct",
      priority: 80,
      description: "Applied going-direct compensation.",
      deltas: {
        bass: -0.5,
        treble: -0.5,
        presence: -1,
        reverb: 0.5,
        noiseGate: 0.5
      },
      notes: ["Converted amp-room settings into a direct-friendly modeler baseline."],
      effects: ["Cab/IR block", "Post amp EQ"],
      multifxParameters: {
        goingDirect: true,
        cabSimulation: true,
        targetUnit: input.multiFx?.name || "generic direct unit"
      }
    })
  };
}

function multiFxMappingRule(): RuleDefinition {
  return {
    id: "direct.apply_multifx_mapping",
    stage: "multifx_mapping",
    priority: 90,
    description: "Map final knobs to selected MultiFX parameter names.",
    when: ({ input }) => Boolean(input.goingDirect && input.multiFx),
    apply: ({ input, currentSettings }) => {
      const multiFx = input.multiFx;
      if (!multiFx) return null;

      const mappedParameters: Record<string, number | string | boolean> = {};
      const mapping = multiFx.parameterMapping || {};
      const defaultMapping: Record<string, string> = {
        gain: "amp.gain",
        bass: "amp.bass",
        middle: "amp.mid",
        treble: "amp.treble",
        presence: "amp.presence",
        masterVolume: "amp.master",
        delay: "delay.mix",
        reverb: "reverb.mix",
        noiseGate: "gate.threshold",
        compression: "compressor.amount"
      };

      for (const [setting, target] of Object.entries({ ...defaultMapping, ...mapping })) {
        const value = currentSettings[setting as keyof typeof currentSettings];
        if (typeof value === "number") {
          mappedParameters[target] = value;
        }
      }

      return {
        ruleId: "direct.apply_multifx_mapping",
        stage: "multifx_mapping",
        priority: 90,
        description: `Mapped settings to ${multiFx.name}.`,
        notes: [`Mapped final tone controls to ${multiFx.name} parameters.`],
        effects: [`MultiFX patch: ${multiFx.name}`],
        multifxParameters: mappedParameters
      };
    }
  };
}

function finalToneRule(): RuleDefinition {
  return {
    id: "core.return_final_tone",
    stage: "final_tone",
    priority: 100,
    description: "Finalize deterministic tone output after all deltas have been applied.",
    when: () => true,
    apply: () => ({
      ruleId: "core.return_final_tone",
      stage: "final_tone",
      priority: 100,
      description: "Final tone returned.",
      notes: ["Final deterministic tone settings returned without AI."]
    })
  };
}

function pedalContribution(pedal: PedalProfileInput): RuleContribution {
  const deltas: ToneDeltas[] = [pedal.deltas || {}, pedal.eqInfluence || {}];

  if (typeof pedal.gainChange === "number") {
    deltas.push({ gain: pedal.gainChange });
  }

  if (typeof pedal.compression === "number") {
    deltas.push({ compression: pedal.compression });
  }

  if (typeof pedal.noise === "number" && pedal.noise > 0) {
    deltas.push({ noiseGate: Math.min(1.5, pedal.noise / 4) });
  }

  if (pedal.type === "delay") {
    deltas.push({ delay: 1 });
  } else if (pedal.type === "reverb") {
    deltas.push({ reverb: 1 });
  } else if (pedal.type === "boost") {
    deltas.push({ gain: 0.75 });
  } else if (pedal.type === "overdrive") {
    deltas.push({ gain: 0.5, middle: 0.5 });
  } else if (pedal.type === "distortion" || pedal.type === "fuzz") {
    deltas.push({ gain: 1, compression: 0.5 });
  } else if (pedal.type === "compressor") {
    deltas.push({ compression: 1 });
  } else if (pedal.type === "noise_gate") {
    deltas.push({ noiseGate: 1 });
  }

  return {
    ruleId: `gear.apply_pedals.${String(pedal.order).padStart(3, "0")}.${pedal.id}`,
    stage: "pedals",
    priority: 70 + pedal.order / 1000,
    description: `Applied pedal ${pedal.name}.`,
    deltas: mergeDeltas(deltas, 2.5),
    notes: [`Applied pedal: ${pedal.name}.`],
    effects: [pedal.name]
  };
}

function toneTypeDeltas(toneType: ToneType): ToneDeltas {
  switch (normalizeToneType(toneType)) {
    case "clean":
    case "acoustic":
      return { gain: -1, compression: -0.5, reverb: 0.5 };
    case "edge_of_breakup":
      return { gain: 0.5, middle: 0.5 };
    case "crunch":
    case "classic_rock":
      return { gain: 1, middle: 0.5 };
    case "heavy":
    case "high_gain":
    case "metal":
    case "modern_metal":
      return { gain: 1.5, bass: 0.5, noiseGate: 1, compression: 0.5 };
    case "distorted":
      return { gain: 1, compression: 0.5 };
    case "ambient":
      return { delay: 1, reverb: 1, presence: -0.5 };
    case "bass_drive":
      return { gain: 0.75, compression: 0.5 };
    case "bass_clean":
      return { gain: -0.5, compression: 0.5 };
    default:
      return {};
  }
}

function normalizeToneType(toneType: ToneType): ToneType {
  if (toneType === "auto") return "auto_detect";
  return toneType;
}

function readToneSpecificDeltas(source: Partial<Record<ToneType, ToneDeltas>> | undefined, toneType: ToneType) {
  return source?.[toneType] || source?.[normalizeToneType(toneType)] || {};
}
