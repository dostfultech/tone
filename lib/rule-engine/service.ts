import { TransformationPipeline, type TransformationPipelineOptions } from "./pipeline";
import type { FinalToneOutput, RuleEngineInput } from "./types";

export interface ToneRuleEngine {
  transform: (input: RuleEngineInput) => FinalToneOutput;
}

export class ToneRuleEngineService implements ToneRuleEngine {
  private readonly pipeline: TransformationPipeline;

  constructor(options: TransformationPipelineOptions = {}) {
    this.pipeline = new TransformationPipeline(options);
  }

  transform(input: RuleEngineInput) {
    return this.pipeline.execute(input);
  }
}

export function createToneRuleEngine(options: TransformationPipelineOptions = {}) {
  return new ToneRuleEngineService(options);
}

export function transformMasterToneForGear(input: RuleEngineInput, options: TransformationPipelineOptions = {}) {
  return createToneRuleEngine(options).transform(input);
}
