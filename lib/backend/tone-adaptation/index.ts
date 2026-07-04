import type { SupabaseClient } from "@supabase/supabase-js";
import { ToneController } from "./controllers/tone-controller";
import { SupabaseCacheRepository } from "./repositories/cache-repository";
import { SupabaseGearRepository } from "./repositories/gear-repository";
import { SupabaseSongRepository } from "./repositories/song-repository";
import { CacheService } from "./services/cache-service";
import { DeterministicRuleEngineService } from "./services/rule-engine-service";
import { GearService } from "./services/gear-service";
import { SongService } from "./services/song-service";
import { ToneService } from "./services/tone-service";
import type { ToneBackendLogger } from "./logging";

export function createToneAdaptationController(supabase: SupabaseClient, logger?: ToneBackendLogger) {
  return new ToneController(createToneAdaptationService(supabase, logger), logger);
}

export function createToneAdaptationService(supabase: SupabaseClient, logger?: ToneBackendLogger) {
  const songRepository = new SupabaseSongRepository(supabase);
  const gearRepository = new SupabaseGearRepository(supabase);
  const cacheRepository = new SupabaseCacheRepository(supabase);

  return new ToneService({
    songService: new SongService(songRepository),
    gearService: new GearService(gearRepository),
    cacheService: new CacheService(cacheRepository),
    ruleEngineService: new DeterministicRuleEngineService(),
    logger
  });
}

export * from "./cache-key";
export * from "./dtos";
export * from "./errors";
export * from "./logging";
export * from "./mappers";
export * from "./repositories/cache-repository";
export * from "./repositories/gear-repository";
export * from "./repositories/song-repository";
export * from "./services/amp-service";
export * from "./services/cache-service";
export * from "./services/cabinet-service";
export * from "./services/gear-service";
export * from "./services/multifx-service";
export * from "./services/pedal-service";
export * from "./services/pickup-service";
export * from "./services/rule-engine-service";
export * from "./services/song-service";
export * from "./services/tone-service";
export * from "./types";
export * from "./validation";
