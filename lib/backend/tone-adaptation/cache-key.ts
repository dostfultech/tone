import { createHash } from "node:crypto";
import type { ToneType } from "../../rule-engine";

export const TONE_BACKEND_CACHE_SCHEMA_VERSION = 3;
export const TONE_BACKEND_RULE_ENGINE_VERSION = "deterministic-rule-engine-v1";

export interface ToneCacheKeyIdentity {
  song: string;
  artist: string;
  part: string;
  toneType: ToneType;
  mode: "guitar" | "bass";
  masterToneId: string;
  masterToneVersion: number;
  guitar?: CacheGearIdentity;
  pickups: CacheGearIdentity[];
  amp?: CacheGearIdentity;
  cabinet?: CacheGearIdentity;
  pedals: CacheGearIdentity[];
  goingDirect: boolean;
  multiFx?: CacheGearIdentity;
}

export interface CacheGearIdentity {
  id?: string;
  name?: string;
  version?: number;
  position?: string;
  order?: number;
}

export interface GeneratedToneCacheKey {
  cacheKey: string;
  requestSignature: string;
  identity: ToneCacheKeyIdentity;
}

export function generateToneCacheKey(identity: ToneCacheKeyIdentity): GeneratedToneCacheKey {
  const canonicalIdentity = {
    schemaVersion: TONE_BACKEND_CACHE_SCHEMA_VERSION,
    ruleEngineVersion: TONE_BACKEND_RULE_ENGINE_VERSION,
    ...identity,
    pickups: identity.pickups
      .map(canonicalGearIdentity)
      .sort(compareGearIdentity),
    pedals: identity.pedals
      .map(canonicalGearIdentity)
      .sort(compareGearIdentity),
    guitar: canonicalGearIdentity(identity.guitar),
    amp: canonicalGearIdentity(identity.amp),
    cabinet: canonicalGearIdentity(identity.cabinet),
    multiFx: canonicalGearIdentity(identity.multiFx)
  };

  const requestSignature = stableStringify(canonicalIdentity);
  const cacheKey = createHash("sha256").update(requestSignature).digest("hex");

  return { cacheKey, requestSignature, identity };
}

export function stableStringify(value: unknown): string {
  if (value === undefined) {
    return "null";
  }

  if (value === null || typeof value !== "object") {
    return JSON.stringify(value);
  }

  if (Array.isArray(value)) {
    return `[${value.map(stableStringify).join(",")}]`;
  }

  const record = value as Record<string, unknown>;
  return `{${Object.keys(record)
    .sort()
    .filter((key) => record[key] !== undefined)
    .map((key) => `${JSON.stringify(key)}:${stableStringify(record[key])}`)
    .join(",")}}`;
}

function canonicalGearIdentity(value?: CacheGearIdentity): CacheGearIdentity | undefined {
  if (!value) {
    return undefined;
  }

  return {
    id: value.id,
    name: value.name?.trim().toLowerCase(),
    version: value.version ?? 1,
    position: value.position,
    order: value.order
  };
}

function compareGearIdentity(left?: CacheGearIdentity, right?: CacheGearIdentity) {
  const leftKey = `${left?.order ?? 0}:${left?.position ?? ""}:${left?.id ?? left?.name ?? ""}`;
  const rightKey = `${right?.order ?? 0}:${right?.position ?? ""}:${right?.id ?? right?.name ?? ""}`;
  return leftKey.localeCompare(rightKey);
}
