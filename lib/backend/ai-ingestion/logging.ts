export interface AiIngestionLogger {
  info: (event: string, payload?: unknown) => void;
  warn: (event: string, payload?: unknown) => void;
  error: (event: string, payload?: unknown) => void;
}

export const consoleAiIngestionLogger: AiIngestionLogger = {
  info(event, payload) {
    console.info("[tonefex:ai-ingestion]", event, payload ?? {});
  },
  warn(event, payload) {
    console.warn("[tonefex:ai-ingestion]", event, payload ?? {});
  },
  error(event, payload) {
    console.error("[tonefex:ai-ingestion]", event, payload ?? {});
  }
};
