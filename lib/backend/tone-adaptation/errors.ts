export class ToneBackendError extends Error {
  readonly code: string;
  readonly status: number;
  readonly details?: Record<string, unknown>;

  constructor(code: string, message: string, status = 400, details?: Record<string, unknown>) {
    super(message);
    this.name = "ToneBackendError";
    this.code = code;
    this.status = status;
    this.details = details;
  }
}

export function isToneBackendError(error: unknown): error is ToneBackendError {
  return error instanceof ToneBackendError;
}

export function validationError(message: string, details?: Record<string, unknown>) {
  return new ToneBackendError("VALIDATION_ERROR", message, 400, details);
}

export function notFoundError(message: string, details?: Record<string, unknown>) {
  return new ToneBackendError("NOT_FOUND", message, 404, details);
}

export function repositoryError(message: string, details?: Record<string, unknown>) {
  return new ToneBackendError("DATABASE_ERROR", message, 500, details);
}

export function configurationError(message: string, details?: Record<string, unknown>) {
  return new ToneBackendError("CONFIGURATION_ERROR", message, 503, details);
}
