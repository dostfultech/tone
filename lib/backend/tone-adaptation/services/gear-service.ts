import type { NormalizedToneAdaptationRequest } from "../dtos";
import type { GearRepository } from "../repositories/gear-repository";
import type { GearMatchQuality, LoadedGearContext } from "../types";
import { inferAmpProfile, inferCabinetProfile, inferGuitarProfile, inferPickupProfile } from "./gear-inference";

export class GearService {
  constructor(private readonly repository: GearRepository) {}

  async loadGear(request: NormalizedToneAdaptationRequest): Promise<LoadedGearContext> {
    const guitarFromCatalog = await this.repository.findGuitar(request.guitar, request.mode);
    const [pickupsFromCatalog, ampFromCatalog, cabinetFromCatalog, pedals, multiFx] = await Promise.all([
      this.repository.findPickups(request.pickups, guitarFromCatalog?.id),
      request.goingDirect ? Promise.resolve(null) : this.repository.findAmplifier(request.amp, request.mode),
      request.goingDirect ? Promise.resolve(null) : this.repository.findCabinet(request.cabinet),
      this.repository.findPedals(request.pedals),
      this.repository.findMultiFx(request.multiFx)
    ]);

    // Catalog miss + a name to work with → deterministic inference so the stage still runs.
    const guitar = guitarFromCatalog ?? (request.guitar?.name ? inferGuitarProfile(request.guitar.name) : null);
    const amplifier =
      request.goingDirect ? null : ampFromCatalog ?? (request.amp?.name ? inferAmpProfile(request.amp.name) : null);
    const cabinet =
      request.goingDirect ? null : cabinetFromCatalog ?? (request.cabinet?.name ? inferCabinetProfile(request.cabinet.name) : null);

    let pickups = pickupsFromCatalog;
    if (!pickups.length && request.pickups.length) {
      pickups = request.pickups
        .filter((selection) => selection.name)
        .map((selection, index) =>
          inferPickupProfile(selection.name as string, selection.position ?? (index === 0 ? "neck" : index === 1 ? "middle" : index === 2 ? "bridge" : "primary"))
        );
    }

    return {
      guitar,
      pickups,
      amplifier,
      cabinet,
      pedals,
      goingDirect: request.goingDirect,
      multiFx,
      resolution: {
        guitar: matchQuality(Boolean(guitarFromCatalog), Boolean(guitar)),
        amp: request.goingDirect ? "catalog" : matchQuality(Boolean(ampFromCatalog), Boolean(amplifier)),
        cabinet: request.goingDirect ? "catalog" : matchQuality(Boolean(cabinetFromCatalog), Boolean(cabinet)),
        pickupsMatched: pickups.length,
        pickupsRequested: request.pickups.length,
        pedalsMatched: pedals.length,
        pedalsRequested: request.pedals.length
      }
    };
  }
}

function matchQuality(catalog: boolean, resolved: boolean): GearMatchQuality {
  if (catalog) {
    return "catalog";
  }
  return resolved ? "inferred" : "none";
}
