export interface ToneBackendLogger {
  info: (event: string, payload?: unknown) => void;
  warn: (event: string, payload?: unknown) => void;
  error: (event: string, payload?: unknown) => void;
}

export const consoleToneBackendLogger: ToneBackendLogger = {
  info(event, payload) {
    console.info("[tonefex:tone-backend]", event, payload ?? {});
  },
  warn(event, payload) {
    console.warn("[tonefex:tone-backend]", event, payload ?? {});
  },
  error(event, payload) {
    console.error("[tonefex:tone-backend]", event, payload ?? {});
  }
};

export function nowMs() {
  return Math.round((globalThis.performance?.now?.() ?? Date.now()) * 100) / 100;
}

export function elapsedMs(startMs: number) {
  return Math.max(0, Math.round((nowMs() - startMs) * 100) / 100);
}
