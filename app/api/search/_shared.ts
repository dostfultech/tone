import { NextResponse } from "next/server";
import type { GearSearchItem } from "@/lib/my-gear";

const MAX_QUERY_LENGTH = 80;

export function normalizeQuery(value: string | null) {
  return (value || "").trim().slice(0, MAX_QUERY_LENGTH);
}

export function escapeLike(value: string) {
  return value.replaceAll("%", "\\%").replaceAll("_", "\\_");
}

export function resultsResponse(results: GearSearchItem[]) {
  return NextResponse.json({ results });
}

export function extractJoinedBrandName(value: unknown) {
  if (Array.isArray(value)) {
    const first = value[0] as { name?: unknown } | undefined;
    return typeof first?.name === "string" && first.name.trim() ? first.name : "Unknown";
  }

  if (value && typeof value === "object") {
    const name = (value as { name?: unknown }).name;
    return typeof name === "string" && name.trim() ? name : "Unknown";
  }

  return "Unknown";
}
