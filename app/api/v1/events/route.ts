import { NextResponse, type NextRequest } from "next/server";
import { getCurrentSession } from "@/lib/server-access";
import { createSupabaseAdminClient } from "@/lib/supabase/admin";

export const runtime = "nodejs";

const MAX_EVENTS_PER_REQUEST = 50;
const MAX_TEXT_LENGTH = 2048;
const MAX_METADATA_DEPTH = 3;
const MAX_METADATA_KEYS = 30;
const MAX_METADATA_ARRAY_ITEMS = 20;

type EventCategory = "page_view" | "ui_action" | "custom_event";
type JsonValue = string | number | boolean | null | JsonValue[] | { [key: string]: JsonValue };

type IncomingEvent = {
  category?: unknown;
  name?: unknown;
  path?: unknown;
  referrer?: unknown;
  element?: unknown;
  metadata?: unknown;
  occurredAt?: unknown;
  sessionId?: unknown;
};

export async function POST(request: NextRequest) {
  const body = await request.json().catch(() => ({}));
  const incomingEvents = normalizeIncomingEvents(body);

  if (incomingEvents.length === 0) {
    return NextResponse.json({ accepted: 0 }, { status: 202 });
  }

  const admin = createSupabaseAdminClient();
  if (!admin) {
    return NextResponse.json({ accepted: 0, skipped: true }, { status: 202 });
  }

  const { user } = await getCurrentSession();
  const userId = user?.id || null;
  const clientIp = resolveClientIp(request);
  const userAgent = normalizeText(request.headers.get("user-agent"), 512);

  const rows = incomingEvents
    .map((event) => normalizeEvent(event))
    .filter((event): event is ReturnType<typeof normalizeEvent> & { name: string } => Boolean(event?.name))
    .map((event) => ({
      user_id: userId,
      session_id: event.sessionId,
      event_category: event.category,
      event_name: event.name,
      path: event.path,
      referrer: event.referrer,
      element: event.element,
      metadata: event.metadata,
      client_ip: clientIp,
      user_agent: userAgent,
      occurred_at: event.occurredAt
    }));

  if (rows.length === 0) {
    return NextResponse.json({ accepted: 0 }, { status: 202 });
  }

  const { error } = await admin.from("app_activity_events").insert(rows);

  if (error) {
    console.error("[tonefex:events] ingestion_failed", { message: error.message });
    return NextResponse.json({ accepted: 0, error: "ingestion_failed" }, { status: 202 });
  }

  return NextResponse.json({ accepted: rows.length }, { status: 202 });
}

function normalizeIncomingEvents(body: unknown): IncomingEvent[] {
  if (Array.isArray(body)) {
    return body.slice(0, MAX_EVENTS_PER_REQUEST);
  }

  if (isRecord(body) && Array.isArray(body.events)) {
    return body.events.slice(0, MAX_EVENTS_PER_REQUEST);
  }

  if (isRecord(body)) {
    return [body];
  }

  return [];
}

function normalizeEvent(event: IncomingEvent) {
  const category = normalizeCategory(event.category);
  const name = normalizeText(event.name, 120);

  return {
    category,
    name,
    path: normalizePath(event.path),
    referrer: normalizeText(event.referrer, MAX_TEXT_LENGTH),
    element: normalizeText(event.element, 220),
    metadata: normalizeMetadata(event.metadata),
    sessionId: normalizeText(event.sessionId, 100),
    occurredAt: normalizeTimestamp(event.occurredAt)
  };
}

function normalizeCategory(value: unknown): EventCategory {
  if (value === "page_view" || value === "ui_action" || value === "custom_event") {
    return value;
  }

  return "custom_event";
}

function normalizePath(value: unknown) {
  if (typeof value !== "string") {
    return null;
  }

  const trimmed = value.trim();
  if (!trimmed) {
    return null;
  }

  if (trimmed.startsWith("/")) {
    return trimmed.slice(0, MAX_TEXT_LENGTH);
  }

  try {
    const url = new URL(trimmed);
    return `${url.pathname}${url.search}`.slice(0, MAX_TEXT_LENGTH);
  } catch {
    return trimmed.slice(0, MAX_TEXT_LENGTH);
  }
}

function normalizeTimestamp(value: unknown) {
  if (typeof value !== "string") {
    return new Date().toISOString();
  }

  const parsed = new Date(value);
  if (Number.isNaN(parsed.getTime())) {
    return new Date().toISOString();
  }

  return parsed.toISOString();
}

function normalizeText(value: unknown, maxLength: number) {
  if (typeof value !== "string") {
    return null;
  }

  const trimmed = value.trim();
  if (!trimmed) {
    return null;
  }

  return trimmed.slice(0, maxLength);
}

function normalizeMetadata(value: unknown): Record<string, JsonValue> {
  if (!isRecord(value)) {
    return {};
  }

  const output: Record<string, JsonValue> = {};
  for (const [rawKey, rawValue] of Object.entries(value).slice(0, MAX_METADATA_KEYS)) {
    const key = rawKey.slice(0, 80);
    const normalized = normalizeJsonValue(rawValue, 0);
    if (normalized !== undefined) {
      output[key] = normalized;
    }
  }

  return output;
}

function normalizeJsonValue(value: unknown, depth: number): JsonValue | undefined {
  if (depth > MAX_METADATA_DEPTH) {
    return "[max_depth]";
  }

  if (value === null) {
    return null;
  }

  if (typeof value === "string") {
    return value.slice(0, 400);
  }

  if (typeof value === "number") {
    return Number.isFinite(value) ? value : undefined;
  }

  if (typeof value === "boolean") {
    return value;
  }

  if (Array.isArray(value)) {
    const items = value
      .slice(0, MAX_METADATA_ARRAY_ITEMS)
      .map((item) => normalizeJsonValue(item, depth + 1))
      .filter((item): item is JsonValue => item !== undefined);
    return items;
  }

  if (isRecord(value)) {
    const nested: { [key: string]: JsonValue } = {};
    for (const [rawKey, rawValue] of Object.entries(value).slice(0, MAX_METADATA_KEYS)) {
      const key = rawKey.slice(0, 80);
      const normalized = normalizeJsonValue(rawValue, depth + 1);
      if (normalized !== undefined) {
        nested[key] = normalized;
      }
    }
    return nested;
  }

  return undefined;
}

function resolveClientIp(request: NextRequest) {
  const forwarded = request.headers.get("x-forwarded-for");
  if (forwarded) {
    const first = forwarded.split(",")[0]?.trim();
    return first ? first.slice(0, 120) : null;
  }

  const realIp = request.headers.get("x-real-ip")?.trim();
  return realIp ? realIp.slice(0, 120) : null;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
