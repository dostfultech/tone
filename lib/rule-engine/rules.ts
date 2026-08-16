import type { AmplifierProfileInput, PedalProfileInput, RuleContribution, RuleDefinition, RuleEvaluationContext, ToneDeltas, ToneType } from "./types";
import { brightnessToNumber, clampDelta, mergeDeltas, outputLevelToNumber, readNumericProfileValue } from "./utils";

// Continuous compensation: distance from the neutral midpoint (5) scaled per point,
// clamped so a single characteristic can't dominate the tone. Replaces the old
// 3-bucket thresholds (<=3.5 / >=7) that made a 6.9 and a 3.6 behave identically.
function fromNeutral(value: number | null, perPoint: number, cap = 1.5): number {
  if (value == null) return 0;
  // No rounding here — mergeDeltas quantizes the accumulated result to knob
  // resolution (0.5); rounding twice would re-bucket the continuous values.
  return Math.max(-cap, Math.min(cap, (value - 5) * perPoint));
}

function pushIfNonZero(deltas: ToneDeltas[], entry: ToneDeltas) {
  const cleaned = Object.fromEntries(Object.entries(entry).filter(([, v]) => typeof v === "number" && v !== 0));
  if (Object.keys(cleaned).length) {
    deltas.push(cleaned as ToneDeltas);
  }
}

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

      // Continuous compensation: the farther a characteristic sits from neutral,
      // the larger the counter-adjustment — a slightly bright guitar gets a slight
      // treble cut, a very bright one a strong cut.
      pushIfNonZero(deltas, {
        treble: -fromNeutral(brightness, 0.4),
        presence: -fromNeutral(brightness, 0.4)
      });
      pushIfNonZero(deltas, {
        gain: -fromNeutral(output, 0.25, 1),
        compression: -fromNeutral(output, 0.25, 1)
      });
      pushIfNonZero(deltas, {
        bass: -fromNeutral(warmth, 0.25, 1),
        middle: -fromNeutral(warmth, 0.25, 1)
      });
      pushIfNonZero(deltas, { compression: -fromNeutral(compression, 0.25, 1) });

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

        // Continuous: pickup output distance from neutral drives a proportional
        // gain trade — hotter pickups hit the amp harder, so the knob comes down.
        pushIfNonZero(deltas, {
          gain: -fromNeutral(output, 0.5),
          compression: -fromNeutral(output, 0.25, 1)
        });

        if (pickup.circuitType === "active") {
          deltas.push({ gain: -0.5, noiseGate: -0.5, compression: -0.5 });
        } else if (pickup.circuitType === "passive") {
          deltas.push({ compression: 0.25 });
        }

        pushIfNonZero(deltas, {
          treble: -fromNeutral(brightness, 0.25, 1),
          presence: -fromNeutral(brightness, 0.25, 1)
        });

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
      const notes = [`Adjusted for amplifier profile: ${amplifier.name}.`];

      const gainStructure = (amplifier.gainStructure || "").toLowerCase();

      // Voicing residuals: EQ character only. The gain axis is handled by the
      // proportional headroom compensation below — keeping fixed gain nudges here
      // too would double-count the same physical effect.
      if (amplifier.era === "vintage" || /vintage|plexi|tweed|blackface/.test(gainStructure)) {
        deltas.push({ middle: 0.5 });
      } else if (/boutique_high_gain/.test(gainStructure)) {
        deltas.push({ bass: -0.25 });
      } else if (/modern_high_gain_5150/.test(gainStructure)) {
        deltas.push({ bass: -0.5 });
      } else if (/modern|high|rectifier/.test(gainStructure)) {
        deltas.push({ bass: -0.25 });
      }

      // Proportional gain compensation. How far the amp's knob must move depends on
      // BOTH how far the target drive sits from neutral AND how much clean headroom
      // this amp has: high-headroom amps must be pushed to reach a drive target,
      // early-breakup amps reach it sooner and must be backed off — proportionally,
      // not by a fixed nudge.
      const masterGain = typeof input.masterTone.settings.gain === "number" ? input.masterTone.settings.gain : 5;
      const headroom = readNumericProfileValue(amplifier.cleanHeadroom) ?? inferCleanHeadroom(amplifier, gainStructure);
      const driveDemand = (masterGain - 5) / 5;
      const headroomOffset = (headroom - 5) / 5;
      let gainCompensation = 0;
      if (driveDemand > 0 && headroomOffset !== 0) {
        gainCompensation = 2 * driveDemand * headroomOffset;
      } else if (driveDemand < 0 && headroomOffset < 0) {
        // Clean target on an early-breakup amp: back the gain off to stay clean.
        gainCompensation = 2 * driveDemand * -headroomOffset;
      }
      if (gainCompensation !== 0) {
        deltas.push({ gain: clampDelta(gainCompensation, 2) });
        notes.push(
          gainCompensation > 0
            ? `Pushed gain to reach the target drive on this high-headroom amp.`
            : `Reduced gain — this amp reaches the target drive earlier than the original.`
        );
      }

      pushIfNonZero(deltas, {
        treble: -fromNeutral(brightness, 0.25, 1),
        presence: -fromNeutral(brightness, 0.25, 1)
      });
      pushIfNonZero(deltas, { bass: -Math.max(0, fromNeutral(warmth, 0.25, 1)) });
      pushIfNonZero(deltas, { masterVolume: Math.min(0, fromNeutral(headroom, 0.25, 1)) });

      return {
        ruleId: "gear.apply_amplifier_profile",
        stage: "amplifier_profile",
        priority: 50,
        description: `Applied amplifier profile ${amplifier.name}.`,
        deltas: mergeDeltas(deltas),
        notes
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

      // Continuous: only counter excesses (bright/boomy cabs get cut, dull cabs
      // get lifted) — proportional to how far the cab sits from neutral.
      pushIfNonZero(deltas, {
        treble: -Math.max(0, fromNeutral(brightness, 0.25, 1)),
        presence: -Math.max(0, fromNeutral(brightness, 0.25, 1))
      });
      pushIfNonZero(deltas, {
        bass: -Math.max(0, fromNeutral(lowEnd, 0.25, 1)),
        depth: -Math.max(0, fromNeutral(lowEnd, 0.25, 1))
      });
      pushIfNonZero(deltas, {
        treble: Math.max(0, -fromNeutral(highEnd, 0.33, 1)),
        presence: Math.max(0, -fromNeutral(highEnd, 0.33, 1))
      });

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

  // Seeded per-model behavior replaces the generic type defaults below;
  // without this guard the two would stack and overshoot.
  const hasSeededBehavior =
    Object.keys(pedal.deltas || {}).length > 0 ||
    Object.keys(pedal.eqInfluence || {}).length > 0 ||
    (typeof pedal.gainChange === "number" && pedal.gainChange !== 0) ||
    (typeof pedal.compression === "number" && pedal.compression !== 0);

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
  } else if (!hasSeededBehavior) {
    if (pedal.type === "boost") {
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

// When the catalog has no clean_headroom value, estimate one from the amp's
// voicing so proportional gain compensation still has a physical anchor.
// Neutral (5) means "no compensation", matching the old behavior for unknowns.
function inferCleanHeadroom(amplifier: AmplifierProfileInput, gainStructure: string): number {
  if (/5150|rectifier|metal|high_gain/.test(gainStructure)) return 2.5;
  if (/modern|high/.test(gainStructure)) return 3.5;
  if (amplifier.era === "vintage" || /plexi|tweed/.test(gainStructure)) return 4;
  if (/blackface|clean|jazz/.test(gainStructure)) return 7.5;
  if (amplifier.era === "modern") return 3.5;
  return 5;
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
    case "fuzz":
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
