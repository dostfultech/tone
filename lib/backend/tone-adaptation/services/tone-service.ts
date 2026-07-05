import type { NormalizedToneAdaptationRequest, ToneAdaptationLogSummary, ToneAdaptationResponseDto } from "../dtos";
import { elapsedMs, nowMs, type ToneBackendLogger, consoleToneBackendLogger } from "../logging";
import type { GeneratedToneCacheKey } from "../cache-key";
import type { RuleEngineService } from "./rule-engine-service";
import type { LoadedGearContext, LoadedMasterToneContext, LoadedToneRequestContext, ToneCacheRecord, ToneCacheWriteInput } from "../types";
import { isToneBackendError } from "../errors";

export interface ToneServiceDependencies {
  songService: {
    loadMasterTone: (request: NormalizedToneAdaptationRequest) => Promise<LoadedMasterToneContext>;
  };
  gearService: {
    loadGear: (request: NormalizedToneAdaptationRequest) => Promise<LoadedGearContext>;
  };
  cacheService: {
    createKey: (context: LoadedToneRequestContext) => GeneratedToneCacheKey;
    read: (cacheKey: string) => Promise<ToneCacheRecord | null>;
    touch: (cacheRecord: ToneCacheRecord) => Promise<void>;
    write: (input: Omit<ToneCacheWriteInput, "schemaVersion">) => Promise<{ id?: string }>;
  };
  ruleEngineService: RuleEngineService;
  sourceHydrationService?: {
    hydrateSourceTone: (request: NormalizedToneAdaptationRequest) => Promise<{ masterToneId?: string } | null>;
  };
  logger?: ToneBackendLogger;
}

export class ToneService {
  private readonly logger: ToneBackendLogger;

  constructor(private readonly dependencies: ToneServiceDependencies) {
    this.logger = dependencies.logger ?? consoleToneBackendLogger;
  }

  async adaptTone(request: NormalizedToneAdaptationRequest): Promise<ToneAdaptationResponseDto> {
    const responseStart = nowMs();
    let databaseTimeMs = 0;
    let ruleEngineTimeMs = 0;
    let cacheWrite: ToneAdaptationLogSummary["cacheWrite"] = "not_attempted";
    let aiUsed = false;
    let sourceHydrationUsed = false;

    const { masterTone, gear } = await this.loadContextWithHydration(request, (timing) => {
      databaseTimeMs += timing.databaseTimeMs;
      aiUsed = aiUsed || timing.aiUsed;
      sourceHydrationUsed = sourceHydrationUsed || timing.sourceHydrationUsed;
    });

    const context: LoadedToneRequestContext = {
      masterTone,
      gear,
      ruleEngineInput: {
        masterTone: masterTone.masterTone,
        toneType: request.toneType,
        guitar: gear.guitar,
        pickups: gear.pickups,
        amplifier: gear.amplifier,
        cabinet: gear.cabinet,
        pedals: gear.pedals,
        goingDirect: gear.goingDirect,
        multiFx: gear.multiFx
      }
    };

    const generatedCacheKey = this.dependencies.cacheService.createKey(context);
    const cacheReadStart = nowMs();
    const cached = await this.dependencies.cacheService.read(generatedCacheKey.cacheKey);
    databaseTimeMs += elapsedMs(cacheReadStart);

    if (cached) {
      const cacheTouchStart = nowMs();
      await this.dependencies.cacheService.touch(cached);
      databaseTimeMs += elapsedMs(cacheTouchStart);

      const source = this.createLogSummary({
        requestId: request.requestId,
        finalSource: "DATABASE_CACHE",
        cacheStatus: "hit",
        cacheKey: generatedCacheKey.cacheKey,
        databaseTimeMs,
        ruleEngineTimeMs,
        responseTimeMs: elapsedMs(responseStart),
        cacheWrite: "not_attempted",
        aiUsed,
        openAiCalled: aiUsed,
        sourceHydrationUsed
      });
      this.logger.info("cache_hit", source);
      return this.createResponse(request.requestId, context, cached.result, source);
    }

    this.logger.info("cache_miss", {
      requestId: request.requestId,
      cacheKey: generatedCacheKey.cacheKey,
      song: masterTone.source.songTitle,
      artist: masterTone.source.artistName
    });

    const ruleEngineStart = nowMs();
    const result = this.dependencies.ruleEngineService.transform(context.ruleEngineInput);
    ruleEngineTimeMs = elapsedMs(ruleEngineStart);
    const persistedResult = this.enrichResultForStorage(request, context, result, generatedCacheKey);

    const cacheWriteStart = nowMs();
    try {
      await this.dependencies.cacheService.write({
        cacheKey: generatedCacheKey.cacheKey,
        requestSignature: generatedCacheKey.requestSignature,
        mode: masterTone.source.mode,
        songTitle: masterTone.source.songTitle,
        artistName: masterTone.source.artistName,
        partLabel: masterTone.source.partLabel,
        guitarName: gear.guitar?.name ?? request.guitar?.name ?? null,
        ampName: gear.amplifier?.name ?? request.amp?.name ?? null,
        cabinetName: gear.cabinet?.name ?? request.cabinet?.name ?? null,
        pickupName: joinNames(gear.pickups.map((pickup) => pickup.name)) ?? joinNames(request.pickups.map(selectionName)),
        pedalsName: joinNames(gear.pedals.map((pedal) => pedal.name)) ?? joinNames(request.pedals.map(selectionName)),
        multiFxName: gear.multiFx?.name ?? request.multiFx?.name ?? null,
        effectsMode: request.effectsMode ?? null,
        selectedFxName: request.selectedFx ?? null,
        goingDirect: gear.goingDirect,
        sourceProfileVersion: masterTone.source.version,
        sourceProfileId: masterTone.source.cacheSourceProfileId ?? null,
        result: persistedResult,
        confidence: masterTone.source.confidence,
        metadata: {
          cacheIdentity: generatedCacheKey.identity
        }
      });
      cacheWrite = "succeeded";
    } catch (error) {
      cacheWrite = "failed";
      this.logger.error("cache_write_failed", {
        requestId: request.requestId,
        cacheKey: generatedCacheKey.cacheKey,
        message: error instanceof Error ? error.message : "Unknown cache write error"
      });
      throw error;
    } finally {
      databaseTimeMs += elapsedMs(cacheWriteStart);
    }

    const source = this.createLogSummary({
      requestId: request.requestId,
      finalSource: "RULE_ENGINE",
      cacheStatus: "miss",
      cacheKey: generatedCacheKey.cacheKey,
      databaseTimeMs,
      ruleEngineTimeMs,
      responseTimeMs: elapsedMs(responseStart),
      cacheWrite,
      aiUsed,
      openAiCalled: aiUsed,
      sourceHydrationUsed
    });
    this.logger.info("rule_engine_complete", source);

    return this.createResponse(request.requestId, context, persistedResult, source);
  }

  private async loadContextWithHydration(
    request: NormalizedToneAdaptationRequest,
    record: (timing: { databaseTimeMs: number; aiUsed: boolean; sourceHydrationUsed: boolean }) => void
  ) {
    let dbLoadStart = nowMs();

    try {
      const [masterTone, gear] = await Promise.all([
        this.dependencies.songService.loadMasterTone(request),
        this.dependencies.gearService.loadGear(request)
      ]);
      record({ databaseTimeMs: elapsedMs(dbLoadStart), aiUsed: false, sourceHydrationUsed: false });
      return { masterTone, gear };
    } catch (error) {
      const hydrationService = this.dependencies.sourceHydrationService;
      const canHydrate =
        hydrationService &&
        isToneBackendError(error) &&
        error.code === "NOT_FOUND" &&
        Boolean(request.song && request.artist);

      if (!canHydrate) {
        record({ databaseTimeMs: elapsedMs(dbLoadStart), aiUsed: false, sourceHydrationUsed: false });
        throw error;
      }

      this.logger.warn("source_tone_missing_attempting_ai_hydration", {
        requestId: request.requestId,
        song: request.song,
        artist: request.artist,
        part: request.part,
        toneType: request.toneType,
        mode: request.mode
      });

      const hydrated = await hydrationService.hydrateSourceTone(request);
      record({ databaseTimeMs: elapsedMs(dbLoadStart), aiUsed: true, sourceHydrationUsed: true });

      dbLoadStart = nowMs();
      const retryRequest = hydrated?.masterToneId ? { ...request, masterToneId: hydrated.masterToneId } : request;
      const [masterTone, gear] = await Promise.all([
        this.dependencies.songService.loadMasterTone(retryRequest),
        this.dependencies.gearService.loadGear(retryRequest)
      ]);
      record({ databaseTimeMs: elapsedMs(dbLoadStart), aiUsed: false, sourceHydrationUsed: false });

      this.logger.info("source_tone_hydrated_and_loaded", {
        requestId: request.requestId,
        song: request.song,
        artist: request.artist,
        masterToneId: hydrated?.masterToneId || masterTone.source.id
      });

      return { masterTone, gear };
    }
  }

  private createResponse(
    requestId: string,
    context: LoadedToneRequestContext,
    result: ToneAdaptationResponseDto["result"],
    source: ToneAdaptationLogSummary
  ): ToneAdaptationResponseDto {
    const requestSnapshot = recordValue((result as unknown as Record<string, unknown>).request);
    const pickupSnapshot = Array.isArray(requestSnapshot.pickups)
      ? requestSnapshot.pickups
          .map((entry) => (entry && typeof entry === "object" && !Array.isArray(entry) ? stringValue((entry as Record<string, unknown>).name) : null))
          .filter((entry): entry is string => typeof entry === "string" && entry.length > 0)
      : [];
    const pedalSnapshot = Array.isArray(requestSnapshot.pedals)
      ? requestSnapshot.pedals
          .map((entry) => (entry && typeof entry === "object" && !Array.isArray(entry) ? stringValue((entry as Record<string, unknown>).name) : null))
          .filter((entry): entry is string => typeof entry === "string" && entry.length > 0)
      : [];

    return {
      requestId,
      result,
      source,
      masterTone: {
        id: context.masterTone.source.id,
        song: context.masterTone.source.songTitle,
        artist: context.masterTone.source.artistName,
        part: context.masterTone.source.partLabel,
        partType: context.masterTone.source.partType,
        toneType: context.masterTone.source.toneType,
        version: context.masterTone.source.version,
        confidence: context.masterTone.source.confidence,
        sourceType: context.masterTone.source.sourceType
      },
      gear: {
        guitar: context.gear.guitar?.name ?? stringValue(requestSnapshot.guitar),
        pickups: context.gear.pickups.map((pickup) => pickup.name).length ? context.gear.pickups.map((pickup) => pickup.name) : pickupSnapshot,
        amp: context.gear.amplifier?.name ?? stringValue(requestSnapshot.amp),
        cabinet: context.gear.cabinet?.name ?? stringValue(requestSnapshot.cabinet),
        pedals: context.gear.pedals.map((pedal) => pedal.name).length ? context.gear.pedals.map((pedal) => pedal.name) : pedalSnapshot,
        goingDirect: context.gear.goingDirect,
        multiFx: context.gear.multiFx?.name ?? stringValue(requestSnapshot.multiFx)
      }
    };
  }

  private createLogSummary(input: {
    requestId: string;
    finalSource: ToneAdaptationLogSummary["finalSource"];
    cacheStatus: ToneAdaptationLogSummary["cacheStatus"];
    cacheKey: string;
    databaseTimeMs: number;
    ruleEngineTimeMs: number;
    responseTimeMs: number;
    cacheWrite: ToneAdaptationLogSummary["cacheWrite"];
    aiUsed: boolean;
    openAiCalled: boolean;
    sourceHydrationUsed: boolean;
  }): ToneAdaptationLogSummary {
    return {
      event: "tone_backend_adaptation_complete",
      endpoint: "/api/v1/tones/adapt",
      requestId: input.requestId,
      finalSource: input.finalSource,
      cacheStatus: input.cacheStatus,
      cacheHit: input.cacheStatus === "hit",
      cacheMiss: input.cacheStatus === "miss",
      cacheWrite: input.cacheWrite,
      databaseTimeMs: input.databaseTimeMs,
      ruleEngineTimeMs: input.ruleEngineTimeMs,
      responseTimeMs: input.responseTimeMs,
      cacheKey: input.cacheKey,
      aiUsed: input.aiUsed,
      openAiCalled: input.openAiCalled,
      sourceHydrationUsed: input.sourceHydrationUsed
    };
  }

  private enrichResultForStorage(
    request: NormalizedToneAdaptationRequest,
    context: LoadedToneRequestContext,
    result: ToneAdaptationResponseDto["result"],
    generatedCacheKey: GeneratedToneCacheKey
  ): ToneAdaptationResponseDto["result"] {
    const requestSnapshot = {
      song: request.song ?? context.masterTone.source.songTitle,
      artist: request.artist ?? context.masterTone.source.artistName,
      part: request.part ?? context.masterTone.source.partLabel,
      partType: request.partType ?? context.masterTone.source.partType,
      toneType: request.toneType,
      mode: request.mode,
      guitar: context.gear.guitar?.name ?? request.guitar?.name ?? null,
      pickups: request.pickups.map((pickup) => ({
        id: pickup.id ?? null,
        name: pickup.name ?? null,
        position: pickup.position ?? null
      })),
      amp: context.gear.amplifier?.name ?? request.amp?.name ?? null,
      cabinet: context.gear.cabinet?.name ?? request.cabinet?.name ?? null,
      pedals: request.pedals.map((pedal) => ({
        id: pedal.id ?? null,
        name: pedal.name ?? null,
        order: pedal.order ?? null
      })),
      goingDirect: request.goingDirect,
      multiFx: context.gear.multiFx?.name ?? request.multiFx?.name ?? null,
      effectsMode: request.effectsMode ?? null,
      selectedFx: request.selectedFx ?? null
    };

    const originalSettings =
      recordValue(result.metadata?.initialSettings) && Object.keys(recordValue(result.metadata?.initialSettings)).length > 0
        ? recordValue(result.metadata?.initialSettings)
        : context.masterTone.masterTone.settings;

    return {
      ...result,
      metadata: {
        ...(result.metadata ?? {}),
        storageFormatVersion: "tone-cache-v3",
        cacheIdentity: generatedCacheKey.identity,
        requestSnapshot,
        sourceContext: {
          masterToneId: context.masterTone.masterTone.id,
          sourceId: context.masterTone.source.id,
          sourceType: context.masterTone.source.sourceType,
          sourceProfileId: context.masterTone.source.cacheSourceProfileId ?? null,
          confidence: context.masterTone.source.confidence,
          version: context.masterTone.source.version
        },
        originalSettings,
        targetSettings: result.settings
      },
      request: requestSnapshot,
      accuracy: context.masterTone.source.confidence,
      sourceProfile: {
        id: context.masterTone.source.cacheSourceProfileId ?? context.masterTone.source.id,
        masterToneId: context.masterTone.masterTone.id,
        sourceType: context.masterTone.source.sourceType,
        partType: context.masterTone.source.partType,
        toneType: context.masterTone.source.toneType,
        partLabel: context.masterTone.source.partLabel,
        confidence: context.masterTone.source.confidence,
        version: context.masterTone.source.version
      },
      originalSettings,
      targetSettings: result.settings,
      storageFormatVersion: "tone-cache-v3"
    } as ToneAdaptationResponseDto["result"];
  }
}

function joinNames(values: Array<string | null | undefined>) {
  const cleaned = values.map((value) => (typeof value === "string" ? value.trim() : "")).filter(Boolean);
  return cleaned.length ? cleaned.join(", ") : null;
}

function selectionName(
  selection: { name?: string | null } | undefined
) {
  return selection?.name ?? null;
}

function recordValue(value: unknown) {
  return value && typeof value === "object" && !Array.isArray(value) ? (value as Record<string, unknown>) : {};
}

function stringValue(value: unknown) {
  return typeof value === "string" ? value : undefined;
}
