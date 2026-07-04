import type { NormalizedToneAdaptationRequest } from "../dtos";
import type { SongRepository } from "../repositories/song-repository";

export class SongService {
  constructor(private readonly repository: SongRepository) {}

  loadMasterTone(request: NormalizedToneAdaptationRequest) {
    return this.repository.findMasterTone(request);
  }
}
