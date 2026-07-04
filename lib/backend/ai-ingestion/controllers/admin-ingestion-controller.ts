import { NextResponse } from "next/server";
import { requireAdminApiContext } from "../../admin-access";
import type { AiIngestionService } from "../services/ingestion-service";
import type { AiIngestionWorkerService } from "../services/worker-service";
import {
  validateDeleteToneRequest,
  validateGenerateSongRequest,
  validateRegenerateSongRequest,
  validateToneDecisionRequest,
  validateUpdateMasterToneRequest,
  validateWorkerRunRequest
} from "../validation";
import { isAiIngestionError } from "../errors";
import type { AiIngestionLogger } from "../logging";
import { consoleAiIngestionLogger } from "../logging";

export class AdminIngestionController {
  private readonly logger: AiIngestionLogger;

  constructor(
    private readonly ingestionService: AiIngestionService,
    private readonly workerService: AiIngestionWorkerService,
    logger: AiIngestionLogger = consoleAiIngestionLogger
  ) {
    this.logger = logger;
  }

  async handle(action: string, request: Request) {
    try {
      const context = await requireAdminApiContext(request);
      const body = await safeJson(request);

      if (action === "generate-song") {
        const dto = validateGenerateSongRequest(body);
        const response = await this.ingestionService.generateSong(dto, context.userId);
        return json(response);
      }

      if (action === "regenerate-song") {
        const dto = validateRegenerateSongRequest(body);
        const response = await this.ingestionService.regenerateSong(dto, context.userId);
        return json(response);
      }

      if (action === "update-master-tone") {
        const dto = validateUpdateMasterToneRequest(body);
        const response = await this.ingestionService.updateMasterTone(dto);
        return json(response);
      }

      if (action === "delete-tone") {
        const dto = validateDeleteToneRequest(body);
        const response = await this.ingestionService.deleteTone(dto.masterToneId, dto.reason);
        return json(response);
      }

      if (action === "approve-tone") {
        const dto = validateToneDecisionRequest(body);
        const response = await this.ingestionService.approveTone(dto.masterToneId, context.userId, dto.reason, dto.metadata);
        return json(response);
      }

      if (action === "reject-tone") {
        const dto = validateToneDecisionRequest(body);
        const response = await this.ingestionService.rejectTone(dto.masterToneId, context.userId, dto.reason, dto.metadata);
        return json(response);
      }

      if (action === "run-worker") {
        const dto = validateWorkerRunRequest(body);
        const response = await this.workerService.run(dto);
        return json({ ok: true, action, ...response });
      }

      return NextResponse.json(
        {
          error: {
            code: "AI_INGESTION_UNKNOWN_ACTION",
            message: `Unknown AI ingestion action: ${action}`,
            status: 404
          }
        },
        { status: 404 }
      );
    } catch (error) {
      return this.handleError(error);
    }
  }

  private handleError(error: unknown) {
    const normalized = isAiIngestionError(error)
      ? error
      : {
          code: "AI_INGESTION_ERROR",
          message: error instanceof Error ? error.message : "Unknown AI ingestion error",
          status: 500,
          details: undefined
        };

    this.logger.error("admin_request_failed", normalized);
    return NextResponse.json(
      {
        error: {
          code: normalized.code,
          message: normalized.message,
          status: normalized.status,
          details: normalized.details
        }
      },
      { status: normalized.status }
    );
  }
}

async function safeJson(request: Request) {
  try {
    return await request.json();
  } catch {
    return {};
  }
}

function json(data: unknown) {
  return NextResponse.json(data, {
    headers: {
      "Cache-Control": "no-store"
    }
  });
}
