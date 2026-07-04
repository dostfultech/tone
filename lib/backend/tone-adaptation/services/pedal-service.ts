import type { NormalizedSelection } from "../dtos";
import type { GearRepository } from "../repositories/gear-repository";

export class PedalService {
  constructor(private readonly repository: GearRepository) {}

  loadPedals(selections: NormalizedSelection[]) {
    return this.repository.findPedals(selections);
  }
}
