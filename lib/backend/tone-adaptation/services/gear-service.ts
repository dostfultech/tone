import type { NormalizedToneAdaptationRequest } from "../dtos";
import type { GearRepository } from "../repositories/gear-repository";
import type { LoadedGearContext } from "../types";

export class GearService {
  constructor(private readonly repository: GearRepository) {}

  async loadGear(request: NormalizedToneAdaptationRequest): Promise<LoadedGearContext> {
    const guitar = await this.repository.findGuitar(request.guitar, request.mode);
    const [pickups, amplifier, cabinet, pedals, multiFx] = await Promise.all([
      this.repository.findPickups(request.pickups, guitar?.id),
      request.goingDirect ? Promise.resolve(null) : this.repository.findAmplifier(request.amp, request.mode),
      request.goingDirect ? Promise.resolve(null) : this.repository.findCabinet(request.cabinet),
      this.repository.findPedals(request.pedals),
      this.repository.findMultiFx(request.multiFx)
    ]);

    return {
      guitar,
      pickups,
      amplifier,
      cabinet,
      pedals,
      goingDirect: request.goingDirect,
      multiFx
    };
  }
}
