import type { JsonRecord, RuleEngineLogger } from "./types";

export const noopRuleEngineLogger: RuleEngineLogger = {
  debug: () => undefined,
  info: () => undefined,
  warn: () => undefined,
  error: () => undefined
};

export function createConsoleRuleEngineLogger(prefix = "[tonefex:rule-engine]"): RuleEngineLogger {
  return {
    debug: (event, payload) => console.debug(prefix, event, payload || {}),
    info: (event, payload) => console.info(prefix, event, payload || {}),
    warn: (event, payload) => console.warn(prefix, event, payload || {}),
    error: (event, payload) => console.error(prefix, event, payload || {})
  };
}

export function createMemoryRuleEngineLogger() {
  const entries: Array<{ level: keyof RuleEngineLogger; event: string; payload: JsonRecord }> = [];
  const logger: RuleEngineLogger = {
    debug: (event, payload = {}) => entries.push({ level: "debug", event, payload }),
    info: (event, payload = {}) => entries.push({ level: "info", event, payload }),
    warn: (event, payload = {}) => entries.push({ level: "warn", event, payload }),
    error: (event, payload = {}) => entries.push({ level: "error", event, payload })
  };

  return { logger, entries };
}
