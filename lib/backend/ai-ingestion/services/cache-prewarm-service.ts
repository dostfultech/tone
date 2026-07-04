import type { NormalizedToneAdaptationRequest, ToneAdaptationRequestDto, ToneAdaptationResponseDto } from "../../tone-adaptation/dtos";
import { validateToneAdaptationRequest } from "../../tone-adaptation/validation";

export interface CachePrewarmToneService {
  adaptTone(request: NormalizedToneAdaptationRequest): Promise<ToneAdaptationResponseDto>;
}

export class CachePrewarmService {
  constructor(private readonly toneService: CachePrewarmToneService) {}

  async prewarm(payload: Record<string, unknown>) {
    const requests = Array.isArray(payload.requests) ? payload.requests : [];
    const results: Array<{ requestId: string; cacheStatus: string; cacheKey: string }> = [];

    for (const request of requests) {
      const normalized = validateToneAdaptationRequest(request as ToneAdaptationRequestDto);
      const response = await this.toneService.adaptTone(normalized);
      results.push({
        requestId: response.requestId,
        cacheStatus: response.source.cacheStatus,
        cacheKey: response.source.cacheKey
      });
    }

    return {
      prewarmed: results.length,
      results,
      aiUsed: false
    };
  }
}
