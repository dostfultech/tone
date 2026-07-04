import type { NormalizedSelection } from "../dtos";
import type { GearRepository } from "../repositories/gear-repository";

export class CabinetService {
  constructor(private readonly repository: GearRepository) {}

  loadCabinet(selection: NormalizedSelection | undefined) {
    return this.repository.findCabinet(selection);
  }
}
