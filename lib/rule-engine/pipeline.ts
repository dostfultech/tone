import { resolveContributionConflicts } from "./conflict-resolution";
import { RuleEvaluator } from "./evaluator";
import { DefaultRuleLoader, type RuleLoader } from "./loader";
import { noopRuleEngineLogger } from "./logger";
import {
  RULE_STAGE_ORDER,
  type FinalToneOutput,
  type JsonRecord,
  type RuleContribution,
  type RuleEngineAuditEntry,
  type RuleEngineInput,
  type RuleEngineLogger,
  type RuleEngineOptions,
  type RuleStage,
  type ToneSettingMap
} from "./types";
import { addDeltas, formatDelta, normalizeMasterSettings } from "./utils";
import { validateRuleEngineInput, type RuleValidationResult } from "./validation";

export const RULE_ENGINE_VERSION = "rule-engine-v1";

export class RuleEngineValidationError extends Error {
  readonly validation: RuleValidationResult;

  constructor(validation: RuleValidationResult) {
    super(validation.errors.join(" "));
    this.name = "RuleEngineValidationError";
    this.validation = validation;
  }
}

export interface TransformationPipelineOptions extends RuleEngineOptions {
  loader?: RuleLoader;
}

export class TransformationPipeline {
  private readonly loader: RuleLoader;
  private readonly evaluator: RuleEvaluator;
  private readonly logger: RuleEngineLogger;
  private readonly maxAbsoluteDeltaPerSetting: number;

  constructor(options: TransformationPipelineOptions = {}) {
    this.loader = options.loader || new DefaultRuleLoader();
    this.evaluator = new RuleEvaluator();
    this.logger = options.logger || noopRuleEngineLogger;
    this.maxAbsoluteDeltaPerSetting = options.maxAbsoluteDeltaPerSetting ?? 4;
  }

  execute(input: RuleEngineInput): FinalToneOutput {
    const validation = validateRuleEngineInput(input);
    if (!validation.valid) {
      this.logger.error("validation_failed", { errors: validation.errors });
      throw new RuleEngineValidationError(validation);
    }

    const startedAt = Date.now();
    const initialSettings = normalizeMasterSettings(input.masterTone.settings);
    let currentSettings: ToneSettingMap = { ...initialSettings };
    const allContributions: RuleContribution[] = [];
    const auditTrail: RuleEngineAuditEntry[] = [];
    const notes: string[] = [...validation.warnings];
    const warnings: string[] = [...validation.warnings];
    const effectsChain: string[] = [...(input.masterTone.suggestedPedals || [])];
    const multifxParameters: Record<string, number | string | boolean> = {};
    const conflicts: FinalToneOutput["conflicts"] = [];

    this.logger.info("started", {
      masterToneId: input.masterTone.id,
      toneType: input.toneType,
      stageOrder: RULE_STAGE_ORDER
    });

    for (const stage of RULE_STAGE_ORDER) {
      const stageResult = this.executeStage(stage, input, currentSettings, allContributions);
      allContributions.push(...stageResult.contributions);

      currentSettings = stageResult.nextSettings;
      auditTrail.push(...stageResult.auditEntries);
      conflicts.push(...stageResult.conflicts);

      for (const contribution of stageResult.contributions) {
        notes.push(...(contribution.notes || []));
        warnings.push(...(contribution.warnings || []));
        effectsChain.push(...(contribution.effects || []));
        Object.assign(multifxParameters, contribution.multifxParameters || {});
      }
    }

    const output: FinalToneOutput = {
      masterToneId: input.masterTone.id,
      toneType: input.toneType || input.masterTone.toneType,
      settings: currentSettings,
      eqProfile: { ...(input.masterTone.eqProfile || {}) },
      modulationProfile: { ...(input.masterTone.modulationProfile || {}) },
      effectsChain: uniqueStrings(effectsChain),
      multifxParameters,
      notes: uniqueStrings(notes).slice(0, 16),
      warnings: uniqueStrings(warnings),
      auditTrail,
      conflicts,
      metadata: {
        ruleEngineVersion: RULE_ENGINE_VERSION,
        deterministic: true,
        aiUsed: false,
        stageOrder: RULE_STAGE_ORDER,
        elapsedMs: Date.now() - startedAt,
        initialSettings,
        profileVersions: collectProfileVersions(input)
      }
    };

    this.logger.info("completed", {
      masterToneId: output.masterToneId,
      aiUsed: false,
      settings: output.settings,
      conflicts: output.conflicts.length
    });

    return output;
  }

  private executeStage(
    stage: RuleStage,
    input: RuleEngineInput,
    currentSettings: ToneSettingMap,
    previousContributions: RuleContribution[]
  ) {
    const rules = this.loader.loadRulesForStage(stage);
    const contributions = this.evaluator.evaluateStage(stage, rules, {
      input,
      currentSettings,
      contributions: previousContributions
    });
    const resolution = resolveContributionConflicts(contributions, this.maxAbsoluteDeltaPerSetting);
    const nextSettings = addDeltas(currentSettings, resolution.deltas);

    const auditEntries = contributions.map((contribution): RuleEngineAuditEntry => ({
      stage,
      ruleId: contribution.ruleId,
      priority: contribution.priority,
      description: contribution.description,
      deltas: contribution.deltas || {},
      settingsAfterRule: nextSettings,
      notes: contribution.notes || [],
      warnings: [
        ...(contribution.warnings || []),
        ...resolution.conflicts
          .filter((conflict) => conflict.ruleIds.includes(contribution.ruleId))
          .map((conflict) => `Conflict on ${conflict.setting}; resolved to ${formatDelta(conflict.setting, conflict.resolvedDelta)}.`)
      ]
    }));

    if (contributions.length) {
      this.logger.debug("stage_completed", {
        stage,
        ruleIds: contributions.map((contribution) => contribution.ruleId),
        resolvedDeltas: resolution.deltas,
        settings: nextSettings
      } satisfies JsonRecord);
    }

    return {
      contributions,
      nextSettings,
      auditEntries,
      conflicts: resolution.conflicts
    };
  }
}

function uniqueStrings(values: string[]) {
  const seen = new Set<string>();
  const output: string[] = [];

  for (const value of values) {
    const normalized = value.trim().toLowerCase();
    if (!normalized || seen.has(normalized)) continue;
    seen.add(normalized);
    output.push(value);
  }

  return output;
}

function collectProfileVersions(input: RuleEngineInput) {
  return {
    guitar: input.guitar ? `${input.guitar.id}:${input.guitar.version || 1}` : null,
    pickups: (input.pickups || []).map((pickup) => `${pickup.position}:${pickup.id}:${pickup.version || 1}`),
    amplifier: input.amplifier ? `${input.amplifier.id}:${input.amplifier.version || 1}` : null,
    cabinet: input.cabinet ? `${input.cabinet.id}:${input.cabinet.version || 1}` : null,
    pedals: (input.pedals || []).map((pedal) => `${pedal.order}:${pedal.id}:${pedal.version || 1}`),
    multiFx: input.multiFx ? `${input.multiFx.deviceId}:${input.multiFx.version || 1}` : null
  };
}
