import { TONE_SETTING_KEYS, type ConflictResolutionEntry, type RuleContribution, type ToneDeltas } from "./types";
import { clampDelta, removeZeroDeltas } from "./utils";

export function resolveContributionConflicts(
  contributions: RuleContribution[],
  maxAbsoluteDeltaPerSetting = 4
): { deltas: ToneDeltas; conflicts: ConflictResolutionEntry[] } {
  const resolved: ToneDeltas = {};
  const conflicts: ConflictResolutionEntry[] = [];

  for (const key of TONE_SETTING_KEYS) {
    const values = contributions
      .map((contribution) => ({
        ruleId: contribution.ruleId,
        value: contribution.deltas?.[key]
      }))
      .filter((item): item is { ruleId: string; value: number } => typeof item.value === "number" && Number.isFinite(item.value));

    if (!values.length) continue;

    const positiveDelta = values.filter((item) => item.value > 0).reduce((sum, item) => sum + item.value, 0);
    const negativeDelta = values.filter((item) => item.value < 0).reduce((sum, item) => sum + item.value, 0);
    const resolvedDelta = clampDelta(positiveDelta + negativeDelta, maxAbsoluteDeltaPerSetting);

    if (resolvedDelta !== 0) {
      resolved[key] = resolvedDelta;
    }

    if (positiveDelta > 0 && negativeDelta < 0) {
      conflicts.push({
        setting: key,
        positiveDelta,
        negativeDelta,
        resolvedDelta,
        ruleIds: values.map((item) => item.ruleId)
      });
    }
  }

  return { deltas: removeZeroDeltas(resolved), conflicts };
}
