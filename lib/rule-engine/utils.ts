import { TONE_SETTING_KEYS, type ToneDeltas, type ToneSettingKey, type ToneSettingMap } from "./types";

export const DEFAULT_TONE_SETTINGS: ToneSettingMap = {
  gain: 5,
  bass: 5,
  middle: 5,
  treble: 5,
  presence: 5,
  resonance: 5,
  depth: 5,
  masterVolume: 5,
  noiseGate: 0,
  compression: 0,
  delay: 0,
  reverb: 0
};

export function normalizeMasterSettings(settings: Partial<ToneSettingMap>): ToneSettingMap {
  const normalized = { ...DEFAULT_TONE_SETTINGS };
  for (const key of TONE_SETTING_KEYS) {
    const value = settings[key];
    if (typeof value === "number" && Number.isFinite(value)) {
      normalized[key] = clampToneSetting(value);
    }
  }
  return normalized;
}

export function clampToneSetting(value: number) {
  return roundHalf(Math.max(0, Math.min(10, value)));
}

export function clampDelta(value: number, maxAbsoluteDelta = 4) {
  return roundHalf(Math.max(-maxAbsoluteDelta, Math.min(maxAbsoluteDelta, value)));
}

export function roundHalf(value: number) {
  return Math.round(value * 2) / 2;
}

export function addDeltas(settings: ToneSettingMap, deltas: ToneDeltas): ToneSettingMap {
  const next = { ...settings };
  for (const key of TONE_SETTING_KEYS) {
    const delta = deltas[key];
    if (typeof delta === "number" && Number.isFinite(delta)) {
      next[key] = clampToneSetting(next[key] + delta);
    }
  }
  return next;
}

export function mergeDeltas(deltaSets: ToneDeltas[], maxAbsoluteDelta = 4): ToneDeltas {
  const merged: ToneDeltas = {};
  for (const deltas of deltaSets) {
    for (const key of TONE_SETTING_KEYS) {
      const value = deltas[key];
      if (typeof value === "number" && Number.isFinite(value)) {
        merged[key] = clampDelta((merged[key] || 0) + value, maxAbsoluteDelta);
      }
    }
  }
  return removeZeroDeltas(merged);
}

export function removeZeroDeltas(deltas: ToneDeltas): ToneDeltas {
  const cleaned: ToneDeltas = {};
  for (const key of TONE_SETTING_KEYS) {
    const value = deltas[key];
    if (typeof value === "number" && Number.isFinite(value) && value !== 0) {
      cleaned[key] = value;
    }
  }
  return cleaned;
}

export function invertDeltas(deltas: ToneDeltas): ToneDeltas {
  const inverted: ToneDeltas = {};
  for (const key of TONE_SETTING_KEYS) {
    const value = deltas[key];
    if (typeof value === "number" && Number.isFinite(value)) {
      inverted[key] = -value;
    }
  }
  return removeZeroDeltas(inverted);
}

export function readNumericProfileValue(value: unknown): number | null {
  return typeof value === "number" && Number.isFinite(value) ? value : null;
}

export function outputLevelToNumber(value: unknown): number | null {
  if (typeof value === "number" && Number.isFinite(value)) return value;
  if (value === "very_low") return 2;
  if (value === "low") return 3.5;
  if (value === "medium") return 5;
  if (value === "high") return 7;
  if (value === "very_high") return 8.5;
  return null;
}

export function brightnessToNumber(value: unknown): number | null {
  if (typeof value === "number" && Number.isFinite(value)) return value;
  if (value === "dark") return 3;
  if (value === "balanced") return 5;
  if (value === "bright") return 7.5;
  return null;
}

export function stableRuleSort<T extends { id: string; priority: number }>(items: T[]) {
  return [...items].sort((left, right) => {
    if (left.priority !== right.priority) return left.priority - right.priority;
    return left.id.localeCompare(right.id);
  });
}

export function formatDelta(key: ToneSettingKey, value: number) {
  const sign = value > 0 ? "+" : "";
  return `${key} ${sign}${value}`;
}
