import type { RuleContribution, RuleDefinition, RuleEvaluationContext, RuleStage } from "./types";

export class RuleEvaluator {
  evaluateStage(stage: RuleStage, rules: RuleDefinition[], context: RuleEvaluationContext): RuleContribution[] {
    const contributions: RuleContribution[] = [];

    for (const rule of rules) {
      if (rule.stage !== stage || !rule.when(context)) {
        continue;
      }

      const result = rule.apply({
        ...context,
        contributions: [...context.contributions, ...contributions]
      });

      if (!result) {
        continue;
      }

      const nextContributions = Array.isArray(result) ? result : [result];
      contributions.push(...nextContributions.map((contribution) => normalizeContribution(rule, contribution)));
    }

    return contributions;
  }
}

function normalizeContribution(rule: RuleDefinition, contribution: RuleContribution): RuleContribution {
  return {
    ruleId: contribution.ruleId || rule.id,
    stage: contribution.stage || rule.stage,
    priority: contribution.priority ?? rule.priority,
    description: contribution.description || rule.description,
    deltas: contribution.deltas || {},
    notes: contribution.notes || [],
    warnings: contribution.warnings || [],
    effects: contribution.effects || [],
    multifxParameters: contribution.multifxParameters || {},
    metadata: contribution.metadata || {}
  };
}
