export const EARLY_TESTER_FREE_ADAPTATIONS = 3;

export function isEarlyTesterMode(): boolean {
  return process.env.NEXT_PUBLIC_EARLY_TESTER_MODE === "true";
}

export function isEarlyTesterModeClient(): boolean {
  return typeof window !== "undefined"
    ? process.env.NEXT_PUBLIC_EARLY_TESTER_MODE === "true"
    : false;
}
