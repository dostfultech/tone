import test from "node:test";
import assert from "node:assert/strict";
import { generateToneCacheKey } from "../lib/backend/tone-adaptation/cache-key";
import { toCacheIdentity } from "../lib/backend/tone-adaptation/services/cache-service";
import { ToneService } from "../lib/backend/tone-adaptation/services/tone-service";
import { notFoundError } from "../lib/backend/tone-adaptation/errors";
import type {
  FinalToneOutput,
  RuleEngineInput,
  ToneSettingMap
} from "../lib/rule-engine";
import type {
  LoadedGearContext,
  LoadedMasterToneContext,
  LoadedToneRequestContext,
  ToneCacheRecord,
  ToneCacheWriteInput
} from "../lib/backend/tone-adaptation/types";

const baseSettings: ToneSettingMap = {
  gain: 5,
  bass: 5,
  middle: 5,
  treble: 5,
  presence: 5,
  resonance: 5,
  depth: 5,
  masterVolume: 5,
  noiseGate: 1,
  compression: 2,
  delay: 1,
  reverb: 2
};

test("cache hit returns cached result without running the rule engine", async () => {
  const cachedResult = finalTone({ gain: 7 });
  const harness = createHarness({
    cacheRecord: {
      id: "cache-1",
      cacheKey: "cache-key",
      result: cachedResult,
      hitCount: 4
    }
  });

  const response = await harness.service.adaptTone(harness.request);

  assert.equal(response.source.finalSource, "DATABASE_CACHE");
  assert.equal(response.source.cacheHit, true);
  assert.equal(response.source.cacheWrite, "not_attempted");
  assert.equal(harness.ruleEngineCalls, 0);
  assert.equal(harness.cacheTouches, 1);
  assert.deepEqual(response.result, cachedResult);
});

test("cache miss runs the deterministic rule engine once and writes cache", async () => {
  const generatedResult = finalTone({ treble: 6 });
  const harness = createHarness({ generatedResult });

  const response = await harness.service.adaptTone(harness.request);

  assert.equal(response.source.finalSource, "RULE_ENGINE");
  assert.equal(response.source.cacheMiss, true);
  assert.equal(response.source.cacheWrite, "succeeded");
  assert.equal(harness.ruleEngineCalls, 1);
  assert.equal(harness.cacheWrites.length, 1);
  assert.equal(response.result.settings.treble, 6);
  assert.equal(response.result.metadata.aiUsed, false);
  assert.equal((response.result.metadata as Record<string, unknown>).storageFormatVersion, "tone-cache-v3");
  assert.equal(harness.cacheWrites[0].result.metadata.aiUsed, false);
});

test("cache key changes when pickup position, pedal order, or direct device changes", () => {
  const context = loadedContext();
  const baseKey = generateToneCacheKey(toCacheIdentity(context)).cacheKey;

  const pickupPositionKey = generateToneCacheKey(
    toCacheIdentity({
      ...context,
      gear: {
        ...context.gear,
        pickups: [{ ...context.gear.pickups[0], position: "neck" }]
      }
    })
  ).cacheKey;

  const pedalOrderKey = generateToneCacheKey(
    toCacheIdentity({
      ...context,
      gear: {
        ...context.gear,
        pedals: [{ ...context.gear.pedals[0], order: 3 }]
      }
    })
  ).cacheKey;

  const multiFxKey = generateToneCacheKey(
    toCacheIdentity({
      ...context,
      gear: {
        ...context.gear,
        goingDirect: true,
        multiFx: {
          id: "multifx-2",
          deviceId: "multifx-2",
          name: "Different Modeler",
          version: 1
        }
      }
    })
  ).cacheKey;

  assert.notEqual(baseKey, pickupPositionKey);
  assert.notEqual(baseKey, pedalOrderKey);
  assert.notEqual(baseKey, multiFxKey);
});

test("cache request signature is stable valid JSON", () => {
  const parsed = JSON.parse(generateToneCacheKey(toCacheIdentity(loadedContext())).requestSignature) as Record<string, unknown>;

  assert.equal(parsed.schemaVersion, 4);
  assert.equal(parsed.song, "Example Song");
});

test("source logs explicitly state cache, rule-engine, database, response, and AI status", async () => {
  const harness = createHarness();
  const response = await harness.service.adaptTone(harness.request);

  assert.equal(response.source.endpoint, "/api/v1/tones/adapt");
  assert.equal(response.source.aiUsed, false);
  assert.equal(response.source.openAiCalled, false);
  assert.equal(typeof response.source.databaseTimeMs, "number");
  assert.equal(typeof response.source.ruleEngineTimeMs, "number");
  assert.equal(typeof response.source.responseTimeMs, "number");
  assert.ok(response.source.cacheKey.length > 10);
});

test("cache write failure prevents returning an uncached rule-engine result", async () => {
  const harness = createHarness({ failCacheWrite: true });

  await assert.rejects(() => harness.service.adaptTone(harness.request), /cache write failed/i);
  assert.equal(harness.ruleEngineCalls, 1);
  assert.equal(harness.cacheWrites.length, 0);
});

test("missing source tone hydrates once with AI-backed ingestion and then completes adaptation", async () => {
  const harness = createHarness({ failFirstMasterToneLoad: true, hydratedMasterToneId: "master-hydrated-1" });

  const response = await harness.service.adaptTone(harness.request);

  assert.equal(response.source.finalSource, "RULE_ENGINE");
  assert.equal(response.source.aiUsed, true);
  assert.equal(response.source.openAiCalled, true);
  assert.equal(response.source.sourceHydrationUsed, true);
  assert.equal(harness.sourceHydrationCalls, 1);
  assert.equal(harness.ruleEngineCalls, 1);
});

test("cache write preserves requested gear labels and effect metadata when profiles are unresolved", async () => {
  const harness = createHarness({
    loadedContext: {
      ...loadedContext(),
      gear: {
        guitar: null,
        pickups: [],
        amplifier: null,
        cabinet: null,
        pedals: [],
        goingDirect: false,
        multiFx: null
      }
    }
  });

  await harness.service.adaptTone({
    ...harness.request,
    guitar: { name: "Martin D-28" },
    amp: { name: "Fender Mustang LT25" },
    cabinet: { name: "Fender Deluxe Reverb 1x12" },
    pickups: [{ name: "EMG 89", position: "bridge" }],
    pedals: [{ name: "Delay", order: 1 }],
    effectsMode: "manual",
    selectedFx: "Delay"
  });

  assert.equal(harness.cacheWrites[0].guitarName, "Martin D-28");
  assert.equal(harness.cacheWrites[0].ampName, "Fender Mustang LT25");
  assert.equal(harness.cacheWrites[0].cabinetName, "Fender Deluxe Reverb 1x12");
  assert.equal(harness.cacheWrites[0].pickupName, "EMG 89");
  assert.equal(harness.cacheWrites[0].pedalsName, "Delay");
  assert.equal(harness.cacheWrites[0].effectsMode, "manual");
  assert.equal(harness.cacheWrites[0].selectedFxName, "Delay");
});

function createHarness(options: {
  cacheRecord?: ToneCacheRecord | null;
  generatedResult?: FinalToneOutput;
  failCacheWrite?: boolean;
  failFirstMasterToneLoad?: boolean;
  hydratedMasterToneId?: string;
  loadedContext?: LoadedToneRequestContext;
} = {}) {
  let ruleEngineCalls = 0;
  let cacheTouches = 0;
  let masterToneLoadCalls = 0;
  let sourceHydrationCalls = 0;
  const cacheWrites: Array<Omit<ToneCacheWriteInput, "schemaVersion">> = [];
  const context = options.loadedContext ?? loadedContext();

  const service = new ToneService({
    songService: {
      async loadMasterTone() {
        masterToneLoadCalls += 1;
        if (options.failFirstMasterToneLoad && masterToneLoadCalls === 1) {
          throw notFoundError("Required master tone was not found.", { tableName: "master_tones" });
        }

        return context.masterTone;
      }
    },
    gearService: {
      async loadGear() {
        return context.gear;
      }
    },
    cacheService: {
      createKey(value: LoadedToneRequestContext) {
        return generateToneCacheKey(toCacheIdentity(value));
      },
      async read() {
        return options.cacheRecord ?? null;
      },
      async touch() {
        cacheTouches += 1;
      },
      async write(input: Omit<ToneCacheWriteInput, "schemaVersion">) {
        if (options.failCacheWrite) {
          throw new Error("cache write failed");
        }
        cacheWrites.push(input);
        return { id: "cache-write-1" };
      }
    },
    ruleEngineService: {
      transform(_input: RuleEngineInput) {
        ruleEngineCalls += 1;
        return options.generatedResult ?? finalTone({ gain: 6 });
      }
    },
    sourceHydrationService: {
      async hydrateSourceTone() {
        sourceHydrationCalls += 1;
        return { masterToneId: options.hydratedMasterToneId ?? "master-1" };
      }
    },
    logger: {
      info() {},
      warn() {},
      error() {}
    }
  });

  return {
    service,
    request: {
      requestId: "request-1",
      requestSource: "manual_generate" as const,
      song: "Example Song",
      artist: "Example Artist",
      part: "Riff",
      toneType: "clean" as const,
      mode: "guitar" as const,
      pickups: [],
      pedals: [],
      goingDirect: false,
      effectsMode: "manual",
      selectedFx: "Analog Delay"
    },
    get ruleEngineCalls() {
      return ruleEngineCalls;
    },
    get cacheTouches() {
      return cacheTouches;
    },
    get sourceHydrationCalls() {
      return sourceHydrationCalls;
    },
    cacheWrites
  };
}

function loadedContext(): LoadedToneRequestContext {
  const masterTone: LoadedMasterToneContext = {
    masterTone: {
      id: "master-1",
      songId: "song-1",
      songPartId: "part-1",
      instrumentType: "guitar",
      toneType: "clean",
      settings: baseSettings,
      suggestedPedals: ["delay"],
      eqProfile: {},
      modulationProfile: {}
    },
    source: {
      id: "master-1",
      sourceType: "master_tones",
      songId: "song-1",
      songTitle: "Example Song",
      artistId: "artist-1",
      artistName: "Example Artist",
      songPartId: "part-1",
      partLabel: "Riff",
      partType: "riff",
      toneType: "clean",
      mode: "guitar",
      version: 2,
      confidence: 82
    }
  };

  const gear: LoadedGearContext = {
    guitar: {
      id: "guitar-1",
      name: "Fender Stratocaster",
      brightness: "bright",
      outputLevel: "medium",
      version: 1
    },
    pickups: [
      {
        id: "pickup-1",
        name: "Bridge Single Coil",
        position: "bridge",
        type: "single_coil",
        outputLevel: "low",
        version: 1
      }
    ],
    amplifier: {
      id: "amp-1",
      name: "Fender Twin",
      era: "vintage",
      version: 1
    },
    cabinet: {
      id: "cab-1",
      name: "Open Back 2x12",
      backType: "open_back",
      version: 1
    },
    pedals: [
      {
        id: "pedal-1",
        name: "Analog Delay",
        type: "delay",
        order: 2,
        version: 1
      }
    ],
    goingDirect: false,
    multiFx: null
  };

  return {
    masterTone,
    gear,
    ruleEngineInput: {
      masterTone: masterTone.masterTone,
      toneType: "clean",
      guitar: gear.guitar,
      pickups: gear.pickups,
      amplifier: gear.amplifier,
      cabinet: gear.cabinet,
      pedals: gear.pedals,
      goingDirect: gear.goingDirect,
      multiFx: gear.multiFx
    }
  };
}

function finalTone(overrides: Partial<ToneSettingMap>): FinalToneOutput {
  return {
    masterToneId: "master-1",
    toneType: "clean",
    settings: {
      ...baseSettings,
      ...overrides
    },
    eqProfile: {},
    modulationProfile: {},
    effectsChain: ["delay"],
    multifxParameters: {},
    notes: ["deterministic test tone"],
    warnings: [],
    auditTrail: [],
    conflicts: [],
    metadata: {
      aiUsed: false
    }
  };
}
