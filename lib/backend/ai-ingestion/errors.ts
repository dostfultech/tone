export class AiIngestionError extends Error {
  readonly code: string;
  readonly status: number;
  readonly details?: Record<string, unknown>;

  constructor(code: string, message: string, status = 400, details?: Record<string, unknown>) {
    super(message);
    this.name = "AiIngestionError";
    this.code = code;
    this.status = status;
    this.details = details;
  }
}

export function isAiIngestionError(error: unknown): error is AiIngestionError {
  return error instanceof AiIngestionError;
}

export function ingestionValidationError(message: string, details?: Record<string, unknown>) {
  return new AiIngestionError("AI_INGESTION_VALIDATION_ERROR", message, 400, details);
}

export function ingestionAuthError(message = "Admin access is required.") {
  return new AiIngestionError("AI_INGESTION_ADMIN_REQUIRED", message, 403);
}

export function ingestionConfigError(message: string, details?: Record<string, unknown>) {
  return new AiIngestionError("AI_INGESTION_CONFIG_ERROR", message, 503, details);
}

export function ingestionDatabaseError(message: string, details?: Record<string, unknown>) {
  return new AiIngestionError("AI_INGESTION_DATABASE_ERROR", message, 500, details);
}
