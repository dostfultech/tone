import type { NormalizedSelection } from "../dtos";
import type { GearRepository } from "../repositories/gear-repository";

export class PickupService {
  constructor(private readonly repository: GearRepository) {}

  loadPickups(selections: NormalizedSelection[], guitarId?: string) {
    return this.repository.findPickups(selections, guitarId);
  }
}
