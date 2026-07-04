import type { NormalizedToneAdaptationRequest, ToneAdaptationLogSummary, ToneAdaptationResponseDto } from "../dtos";
import { elapsedMs, nowMs, type ToneBackendLogger, consoleToneBackendLogger } from "../logging";
import type { GeneratedToneCacheKey } from "../cache-key";
import type { RuleEngineService } from "./rule-engine-service";
import type { LoadedGearContext, LoadedMasterToneContext, LoadedToneRequestContext, ToneCacheRecord, ToneCacheWriteInput } from "../types";

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

    const dbLoadStart = nowMs();
    const [masterTone, gear] = await Promise.all([
      this.dependencies.songService.loadMasterTone(request),
      this.dependencies.gearService.loadGear(request)
    ]);
    databaseTimeMs += elapsedMs(dbLoadStart);

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
        cacheWrite: "not_attempted"
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

    const cacheWriteStart = nowMs();
    try {
      await this.dependencies.cacheService.write({
        cacheKey: generatedCacheKey.cacheKey,
        requestSignature: generatedCacheKey.requestSignature,
        mode: masterTone.source.mode,
        songTitle: masterTone.source.songTitle,
        artistName: masterTone.source.artistName,
        partLabel: masterTone.source.partLabel,
        guitarName: gear.guitar?.name,
        ampName: gear.amplifier?.name,
        cabinetName: gear.cabinet?.name,
        pickupName: gear.pickups.map((pickup) => pickup.name).join(", ") || null,
        pedalsName: gear.pedals.map((pedal) => pedal.name).join(", ") || null,
        multiFxName: gear.multiFx?.name,
        goingDirect: gear.goingDirect,
        sourceProfileVersion: masterTone.source.version,
        result,
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
      cacheWrite
    });
    this.logger.info("rule_engine_complete", source);

    return this.createResponse(request.requestId, context, result, source);
  }

  private createResponse(
    requestId: string,
    context: LoadedToneRequestContext,
    result: ToneAdaptationResponseDto["result"],
    source: ToneAdaptationLogSummary
  ): ToneAdaptationResponseDto {
    return {
      requestId,
      result,
      source,
      masterTone: {
        id: context.masterTone.source.id,
        song: context.masterTone.source.songTitle,
        artist: context.masterTone.source.artistName,
        part: context.masterTone.source.partLabel,
        toneType: context.masterTone.source.toneType,
        version: context.masterTone.source.version
      },
      gear: {
        guitar: context.gear.guitar?.name,
        pickups: context.gear.pickups.map((pickup) => pickup.name),
        amp: context.gear.amplifier?.name,
        cabinet: context.gear.cabinet?.name,
        pedals: context.gear.pedals.map((pedal) => pedal.name),
        goingDirect: context.gear.goingDirect,
        multiFx: context.gear.multiFx?.name
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
      aiUsed: false,
      openAiCalled: false
    };
  }
}
