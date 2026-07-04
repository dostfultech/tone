import { NextResponse } from "next/server";
import type { ToneAdaptationErrorResponseDto } from "../dtos";
import { configurationError, isToneBackendError } from "../errors";
import { consoleToneBackendLogger, type ToneBackendLogger } from "../logging";
import { validateToneAdaptationRequest } from "../validation";
import type { ToneService } from "../services/tone-service";

export class ToneController {
  private readonly logger: ToneBackendLogger;

  constructor(
    private readonly toneService: ToneService,
    logger: ToneBackendLogger = consoleToneBackendLogger
  ) {
    this.logger = logger;
  }

  async adapt(request: Request) {
    try {
      const payload = await request.json();
      const dto = validateToneAdaptationRequest(payload);
      const response = await this.toneService.adaptTone(dto);
      return NextResponse.json(response);
    } catch (error) {
      return this.handleError(error);
    }
  }

  private handleError(error: unknown) {
    const normalized = isToneBackendError(error)
      ? error
      : configurationError("Tone adaptation backend failed.", {
          message: error instanceof Error ? error.message : "Unknown error"
        });

    this.logger.error("request_failed", {
      code: normalized.code,
      status: normalized.status,
      message: normalized.message,
      details: normalized.details
    });

    const body: ToneAdaptationErrorResponseDto = {
      error: {
        code: normalized.code,
        message: normalized.message,
        status: normalized.status,
        details: normalized.details
      }
    };

    return NextResponse.json(body, { status: normalized.status });
  }
}
