import { createDefaultRules } from "./rules";
import { RULE_STAGE_ORDER, type RuleDefinition, type RuleStage } from "./types";
import { stableRuleSort } from "./utils";

export interface RuleLoader {
  loadRules: () => RuleDefinition[];
  loadRulesForStage: (stage: RuleStage) => RuleDefinition[];
}

export class DefaultRuleLoader implements RuleLoader {
  private readonly rules: RuleDefinition[];

  constructor(extraRules: RuleDefinition[] = []) {
    this.rules = sortRulesByStageAndPriority([...createDefaultRules(), ...extraRules]);
  }

  loadRules() {
    return [...this.rules];
  }

  loadRulesForStage(stage: RuleStage) {
    return this.rules.filter((rule) => rule.stage === stage);
  }
}

export function sortRulesByStageAndPriority(rules: RuleDefinition[]) {
  return [...rules].sort((left, right) => {
    const stageDifference = RULE_STAGE_ORDER.indexOf(left.stage) - RULE_STAGE_ORDER.indexOf(right.stage);
    if (stageDifference !== 0) return stageDifference;
    return stableRuleSort([left, right])[0] === left ? -1 : 1;
  });
}
