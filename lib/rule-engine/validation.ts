import { TONE_SETTING_KEYS, type RuleEngineInput, type ToneSettingKey } from "./types";

export type RuleValidationResult = {
  valid: boolean;
  errors: string[];
  warnings: string[];
};

export function validateRuleEngineInput(input: RuleEngineInput): RuleValidationResult {
  const errors: string[] = [];
  const warnings: string[] = [];

  if (!input.masterTone) {
    errors.push("masterTone is required.");
    return { valid: false, errors, warnings };
  }

  if (!input.masterTone.id) {
    errors.push("masterTone.id is required.");
  }

  if (!input.masterTone.instrumentType) {
    errors.push("masterTone.instrumentType is required.");
  }

  for (const key of TONE_SETTING_KEYS) {
    const value = input.masterTone.settings[key as ToneSettingKey];
    if (value == null) continue;
    if (typeof value !== "number" || !Number.isFinite(value)) {
      errors.push(`masterTone.settings.${key} must be a finite number.`);
    } else if (value < 0 || value > 10) {
      warnings.push(`masterTone.settings.${key} is outside 0-10 and will be clamped.`);
    }
  }

  if (!input.toneType) {
    warnings.push("toneType was not supplied; masterTone.toneType will be used.");
  }

  if (!input.guitar) {
    warnings.push("No guitar profile supplied; guitar profile stage will be skipped.");
  }

  if (!input.amplifier && !input.goingDirect) {
    warnings.push("No amplifier profile supplied; amplifier profile stage will be skipped.");
  }

  if (input.goingDirect && !input.multiFx) {
    warnings.push("Going direct is enabled without a MultiFX profile; generic direct mapping will be used.");
  }

  return { valid: errors.length === 0, errors, warnings };
}
