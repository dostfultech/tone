import test from "node:test";
import assert from "node:assert/strict";
import {
  createMemoryRuleEngineLogger,
  transformMasterToneForGear,
  type RuleEngineInput
} from "../lib/rule-engine";

function baseInput(overrides: Partial<RuleEngineInput> = {}): RuleEngineInput {
  return {
    masterTone: {
      id: "master-1",
      instrumentType: "guitar",
      toneType: "clean",
      settings: {
        gain: 5,
        bass: 5,
        middle: 5,
        treble: 5,
        presence: 5,
        resonance: 5,
        depth: 5,
        masterVolume: 5,
        noiseGate: 0,
        compression: 2,
        delay: 0,
        reverb: 1
      },
      suggestedPedals: ["Spring Reverb"],
      eqProfile: { lowCut: 80 },
      modulationProfile: {}
    },
    toneType: "clean",
    guitar: {
      id: "guitar-bright",
      name: "Bright Strat",
      brightness: "bright",
      outputLevel: "medium"
    },
    pickups: [
      {
        id: "pickup-low",
        name: "Low Output Single Coil",
        position: "bridge",
        type: "single_coil",
        circuitType: "passive",
        outputLevel: "low"
      }
    ],
    amplifier: {
      id: "amp-vintage",
      name: "Vintage Combo",
      era: "vintage",
      brightness: "balanced",
      gainStructure: "vintage low gain"
    },
    cabinet: {
      id: "cab-open",
      name: "Open Back 1x12",
      format: "1x12",
      backType: "open_back"
    },
    pedals: [],
    goingDirect: false,
    ...overrides
  };
}

test("applies rules in the required deterministic stage order", () => {
  const result = transformMasterToneForGear(baseInput());
  const stages = result.auditTrail.map((entry) => entry.stage);

  assert.deepEqual(stages, [
    "load_master_tone",
    "tone_type",
    "guitar_profile",
    "pickup_profiles",
    "amplifier_profile",
    "cabinet_profile",
    "final_tone"
  ]);
  assert.equal(result.metadata.aiUsed, false);
});

test("does not mutate the master tone input", () => {
  const input = baseInput();
  const originalSettings = { ...input.masterTone.settings };

  const result = transformMasterToneForGear(input);

  assert.deepEqual(input.masterTone.settings, originalSettings);
  assert.notDeepEqual(result.settings, originalSettings);
});

test("low output pickup increases gain and compression before final clamping", () => {
  const result = transformMasterToneForGear(baseInput({
    guitar: null,
    amplifier: null,
    cabinet: null,
    toneType: "auto_detect"
  }));

  assert.equal(result.settings.gain, 6);
  assert.equal(result.settings.compression, 3);
});

test("high output pickup reduces gain and compression", () => {
  const result = transformMasterToneForGear(baseInput({
    guitar: null,
    amplifier: null,
    cabinet: null,
    toneType: "auto_detect",
    pickups: [
      {
        id: "pickup-high",
        name: "High Output Humbucker",
        position: "bridge",
        type: "humbucker",
        circuitType: "passive",
        outputLevel: "high"
      }
    ]
  }));

  assert.equal(result.settings.gain, 4);
  assert.equal(result.settings.compression, 2);
});

test("bright guitar reduces treble and presence", () => {
  const result = transformMasterToneForGear(baseInput({
    pickups: [],
    amplifier: null,
    cabinet: null,
    toneType: "auto_detect",
    guitar: {
      id: "bright-guitar",
      name: "Bright Guitar",
      brightness: "bright",
      outputLevel: "medium"
    }
  }));

  assert.equal(result.settings.treble, 4);
  assert.equal(result.settings.presence, 4);
});

test("dark guitar increases treble and presence", () => {
  const result = transformMasterToneForGear(baseInput({
    pickups: [],
    amplifier: null,
    cabinet: null,
    toneType: "auto_detect",
    guitar: {
      id: "dark-guitar",
      name: "Dark Guitar",
      brightness: "dark",
      outputLevel: "medium"
    }
  }));

  assert.equal(result.settings.treble, 6);
  assert.equal(result.settings.presence, 6);
});

test("vintage amp increases drive while modern amp reduces drive", () => {
  const vintage = transformMasterToneForGear(baseInput({
    guitar: null,
    pickups: [],
    cabinet: null,
    toneType: "auto_detect",
    amplifier: { id: "vintage", name: "Vintage Amp", era: "vintage" }
  }));
  const modern = transformMasterToneForGear(baseInput({
    guitar: null,
    pickups: [],
    cabinet: null,
    toneType: "auto_detect",
    amplifier: { id: "modern", name: "Modern Amp", era: "modern" }
  }));

  assert.equal(vintage.settings.gain, 5.5);
  assert.equal(modern.settings.gain, 4.5);
});

test("open back cabinet reduces low end and closed back cabinet increases low end", () => {
  const openBack = transformMasterToneForGear(baseInput({
    guitar: null,
    pickups: [],
    amplifier: null,
    toneType: "auto_detect",
    cabinet: { id: "open", name: "Open Back", backType: "open_back", format: "2x12" }
  }));
  const closedBack = transformMasterToneForGear(baseInput({
    guitar: null,
    pickups: [],
    amplifier: null,
    toneType: "auto_detect",
    cabinet: { id: "closed", name: "Closed Back", backType: "closed_back", format: "2x12" }
  }));

  assert.equal(openBack.settings.bass, 4.5);
  assert.equal(closedBack.settings.bass, 6);
});

test("pedals contribute ordered deterministic deltas and effects", () => {
  const result = transformMasterToneForGear(baseInput({
    guitar: null,
    pickups: [],
    amplifier: null,
    cabinet: null,
    toneType: "auto_detect",
    pedals: [
      { id: "delay", name: "Analog Delay", type: "delay", order: 2 },
      { id: "boost", name: "Clean Boost", type: "boost", order: 1 }
    ]
  }));

  assert.equal(result.settings.gain, 6);
  assert.equal(result.settings.delay, 1);
  assert.deepEqual(result.effectsChain, ["Spring Reverb", "Clean Boost", "Analog Delay"]);
});

test("going direct and MultiFX mapping produce direct parameters without AI", () => {
  const result = transformMasterToneForGear(baseInput({
    goingDirect: true,
    toneType: "auto_detect",
    pedals: [],
    multiFx: {
      id: "helix",
      deviceId: "helix",
      name: "Line 6 Helix",
      parameterMapping: {
        gain: "amp.drive",
        middle: "amp.mids"
      }
    }
  }));

  assert.equal(result.metadata.aiUsed, false);
  assert.equal(result.multifxParameters.goingDirect, true);
  assert.equal(result.multifxParameters.cabSimulation, true);
  assert.equal(result.multifxParameters["amp.drive"], result.settings.gain);
  assert.equal(result.multifxParameters["amp.mids"], result.settings.middle);
  assert.ok(result.effectsChain.includes("Cab/IR block"));
  assert.ok(result.effectsChain.includes("MultiFX patch: Line 6 Helix"));
});

test("opposing deltas are resolved and recorded as conflicts", () => {
  const result = transformMasterToneForGear(baseInput({
    toneType: "auto_detect",
    guitar: {
      id: "guitar-explicit",
      name: "Explicit Guitar",
      deltas: { treble: 1 }
    },
    pickups: [],
    amplifier: null,
    cabinet: null,
    pedals: []
  }), { maxAbsoluteDeltaPerSetting: 4 });

  assert.equal(result.settings.treble, 6);
  assert.equal(result.conflicts.length, 0);

  const conflicting = transformMasterToneForGear(baseInput({
    toneType: "auto_detect",
    guitar: null,
    pickups: [
      {
        id: "pickup-add",
        name: "Treble Add Pickup",
        position: "primary",
        deltas: { treble: 0.5 }
      },
      {
        id: "pickup-subtract",
        name: "Bright Bridge Pickup",
        position: "primary",
        brightness: "bright"
      }
    ],
    amplifier: null,
    cabinet: null,
    pedals: []
  }));

  assert.equal(conflicting.settings.treble, 5);
  assert.equal(conflicting.conflicts.length, 1);
  assert.equal(conflicting.conflicts[0].setting, "treble");
});

test("logger receives deterministic start and completion events", () => {
  const memory = createMemoryRuleEngineLogger();
  transformMasterToneForGear(baseInput({ pedals: [] }), { logger: memory.logger });

  assert.equal(memory.entries[0].event, "started");
  assert.equal(memory.entries.at(-1)?.event, "completed");
  assert.equal(memory.entries.at(-1)?.payload.aiUsed, false);
});
