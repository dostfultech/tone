import {
  generateToneCacheKey,
  type CacheGearIdentity,
  TONE_BACKEND_CACHE_SCHEMA_VERSION,
  type GeneratedToneCacheKey,
  type ToneCacheKeyIdentity
} from "../cache-key";
import type { CacheRepository } from "../repositories/cache-repository";
import type { LoadedToneRequestContext, ToneCacheWriteInput } from "../types";

export class CacheService {
  constructor(private readonly repository: CacheRepository) {}

  createKey(context: LoadedToneRequestContext): GeneratedToneCacheKey {
    return generateToneCacheKey(toCacheIdentity(context));
  }

  read(cacheKey: string) {
    return this.repository.read(cacheKey);
  }

  touch(cacheRecord: Awaited<ReturnType<CacheRepository["read"]>>) {
    return cacheRecord ? this.repository.touch(cacheRecord) : Promise.resolve();
  }

  write(input: Omit<ToneCacheWriteInput, "schemaVersion">) {
    return this.repository.write({
      ...input,
      schemaVersion: TONE_BACKEND_CACHE_SCHEMA_VERSION
    });
  }
}

export function toCacheIdentity(context: LoadedToneRequestContext): ToneCacheKeyIdentity {
  const source = context.masterTone.source;

  return {
    song: source.songTitle,
    artist: source.artistName,
    part: source.partLabel,
    toneType: source.toneType,
    mode: source.mode,
    masterToneId: source.id,
    masterToneVersion: source.version,
    guitar: gearIdentity(context.gear.guitar),
    pickups: context.gear.pickups.map(gearIdentity).filter(isCacheGearIdentity),
    amp: gearIdentity(context.gear.amplifier),
    cabinet: gearIdentity(context.gear.cabinet),
    pedals: context.gear.pedals.map(gearIdentity).filter(isCacheGearIdentity),
    goingDirect: context.gear.goingDirect,
    multiFx: gearIdentity(context.gear.multiFx)
  };
}

function gearIdentity(
  value?: { id: string; name: string; version?: number; position?: string; order?: number } | null
): CacheGearIdentity | undefined {
  if (!value) {
    return undefined;
  }
  return {
    id: value.id,
    name: value.name,
    version: value.version ?? 1,
    position: value.position,
    order: value.order
  };
}

function isCacheGearIdentity(value: CacheGearIdentity | undefined): value is CacheGearIdentity {
  return value !== undefined;
}
