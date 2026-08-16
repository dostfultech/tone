import { NextResponse, type NextRequest } from "next/server";
import { getCurrentSession } from "@/lib/server-access";
import { createSupabaseAdminClient } from "@/lib/supabase/admin";
import { TONE_BACKEND_RULE_ENGINE_VERSION } from "@/lib/backend/tone-adaptation/cache-key";

const VALID_DIRECTIONS = new Set(["too_bright", "too_dark", "too_much_gain", "too_little_gain", "other"]);
const MAX_PER_DAY = 60;

export async function POST(request: NextRequest) {
  const { user } = await getCurrentSession();
  if (!user) {
    return NextResponse.json({ error: "Authentication required." }, { status: 401 });
  }

  const admin = createSupabaseAdminClient();
  if (!admin) {
    return NextResponse.json({ error: "Service unavailable." }, { status: 503 });
  }

  let body: Record<string, unknown>;
  try {
    body = await request.json();
  } catch {
    return NextResponse.json({ error: "Invalid request body." }, { status: 400 });
  }

  const verdict = body.verdict === "close" || body.verdict === "off" ? body.verdict : null;
  const songTitle = clean(body.songTitle, 300);
  const artistName = clean(body.artistName, 300);
  if (!verdict || !songTitle || !artistName) {
    return NextResponse.json({ error: "verdict, songTitle, and artistName are required." }, { status: 400 });
  }

  const directions =
    verdict === "off" && Array.isArray(body.directions)
      ? body.directions.filter((d): d is string => typeof d === "string" && VALID_DIRECTIONS.has(d)).slice(0, 5)
      : [];

  // Light abuse guard: one user can't flood the tuning signal.
  const dayAgo = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString();
  const { count } = await admin
    .from("tone_accuracy_feedback")
    .select("id", { count: "exact", head: true })
    .eq("user_id", user.id)
    .gte("created_at", dayAgo);
  if ((count ?? 0) >= MAX_PER_DAY) {
    return NextResponse.json({ error: "Feedback limit reached for today." }, { status: 429 });
  }

  const confidence = Number(body.confidenceShown);
  const { error } = await admin.from("tone_accuracy_feedback").insert({
    user_id: user.id,
    song_title: songTitle,
    artist_name: artistName,
    part_label: clean(body.partLabel, 200),
    tone_type: clean(body.toneType, 60),
    verdict,
    directions,
    guitar_name: clean(body.guitarName, 200),
    amp_name: clean(body.ampName, 200),
    going_direct: Boolean(body.goingDirect),
    multi_fx_name: clean(body.multiFxName, 200),
    pedal_names: Array.isArray(body.pedalNames)
      ? body.pedalNames.filter((p): p is string => typeof p === "string").slice(0, 12).map((p) => p.slice(0, 200))
      : [],
    adapted_settings: isRecord(body.adaptedSettings) ? body.adaptedSettings : {},
    confidence_shown: Number.isFinite(confidence) ? Math.round(confidence) : null,
    verification_status: clean(body.verificationStatus, 60),
    rule_engine_version: TONE_BACKEND_RULE_ENGINE_VERSION,
    notes: clean(body.notes, 1000)
  });

  if (error) {
    console.error("[tonefex:tone-feedback] Insert failed:", error.message);
    return NextResponse.json({ error: "Failed to save feedback." }, { status: 500 });
  }

  return NextResponse.json({ ok: true });
}

function clean(value: unknown, maxLength: number): string | null {
  return typeof value === "string" && value.trim().length > 0 ? value.trim().slice(0, maxLength) : null;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
