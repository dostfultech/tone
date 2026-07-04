import type { NormalizedSelection } from "../dtos";
import type { GearRepository } from "../repositories/gear-repository";

export class MultiFxService {
  constructor(private readonly repository: GearRepository) {}

  loadMultiFx(selection: NormalizedSelection | undefined) {
    return this.repository.findMultiFx(selection);
  }
}
