import { transformMasterToneForGear, type FinalToneOutput, type RuleEngineInput } from "../../../rule-engine";

export interface RuleEngineService {
  transform(input: RuleEngineInput): FinalToneOutput;
}

export class DeterministicRuleEngineService implements RuleEngineService {
  transform(input: RuleEngineInput) {
    return transformMasterToneForGear(input);
  }
}
