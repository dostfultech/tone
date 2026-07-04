import type { NormalizedSelection, ToneAdaptationMode } from "../dtos";
import type { GearRepository } from "../repositories/gear-repository";

export class AmpService {
  constructor(private readonly repository: GearRepository) {}

  loadAmplifier(selection: NormalizedSelection | undefined, mode: ToneAdaptationMode) {
    return this.repository.findAmplifier(selection, mode);
  }
}
