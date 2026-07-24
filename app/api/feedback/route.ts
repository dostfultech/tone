import { NextResponse, type NextRequest } from "next/server";
import { getCurrentSession } from "@/lib/server-access";
import { createSupabaseAdminClient } from "@/lib/supabase/admin";
import { isEarlyTesterMode } from "@/lib/early-tester";

export async function POST(request: NextRequest) {
  if (!isEarlyTesterMode()) {
    return NextResponse.json({ error: "Feedback submissions are not enabled." }, { status: 403 });
  }

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

  const overallRating = Number(body.overallRating);
  if (!Number.isInteger(overallRating) || overallRating < 1 || overallRating > 5) {
    return NextResponse.json({ error: "Overall rating must be 1-5." }, { status: 400 });
  }

  const validAccuracy = ["excellent", "good", "average", "needs_improvement", "poor"];
  if (!validAccuracy.includes(body.toneAccuracy as string)) {
    return NextResponse.json({ error: "Invalid tone accuracy value." }, { status: 400 });
  }

  const validContact = ["email", "discord", "google_meet"];
  if (body.preferredContactMethod && !validContact.includes(body.preferredContactMethod as string)) {
    return NextResponse.json({ error: "Invalid contact method." }, { status: 400 });
  }

  const { data: existing } = await admin
    .from("feedback_submissions")
    .select("id")
    .eq("user_id", user.id)
    .limit(1)
    .maybeSingle();

  if (existing) {
    return NextResponse.json({ error: "You have already submitted feedback. Thank you!" }, { status: 409 });
  }

  const { error: insertError } = await admin.from("feedback_submissions").insert({
    user_id: user.id,
    email: user.email || "",
    full_name: typeof body.fullName === "string" ? body.fullName.slice(0, 200) : null,
    overall_rating: overallRating,
    tone_accuracy: body.toneAccuracy,
    what_worked: typeof body.whatWorked === "string" ? body.whatWorked.slice(0, 5000) : null,
    improvements: typeof body.improvements === "string" ? body.improvements.slice(0, 5000) : null,
    bugs: typeof body.bugs === "string" ? body.bugs.slice(0, 5000) : null,
    willing_to_call: Boolean(body.willingToCall),
    preferred_contact_method: body.preferredContactMethod || null,
    timezone: typeof body.timezone === "string" ? body.timezone.slice(0, 100) : null
  });

  if (insertError) {
    console.error("[tonefex:feedback] Insert failed:", insertError.message);
    return NextResponse.json({ error: "Failed to save feedback." }, { status: 500 });
  }

  await admin.from("admin_audit_logs").insert({
    actor_id: user.id,
    action: "early_tester_feedback_submitted",
    target_table: "feedback_submissions",
    target_id: user.id,
    metadata: {
      email: user.email,
      overall_rating: overallRating,
      tone_accuracy: body.toneAccuracy,
      willing_to_call: Boolean(body.willingToCall)
    }
  });

  sendAdminNotification(user.email || "unknown", overallRating, body.toneAccuracy as string, Boolean(body.willingToCall));

  return NextResponse.json({ ok: true });
}

function sendAdminNotification(email: string, rating: number, accuracy: string, willingToCall: boolean) {
  const adminEmail = process.env.ADMIN_NOTIFICATION_EMAIL;
  if (!adminEmail) return;

  const subject = `[Tonefex] New Early Tester Feedback from ${email}`;
  const text = [
    `New feedback submission from: ${email}`,
    `Overall Rating: ${rating}/5`,
    `Tone Accuracy: ${accuracy}`,
    `Willing to Call: ${willingToCall ? "Yes" : "No"}`,
    "",
    `Review at: ${process.env.NEXT_PUBLIC_SITE_URL || "https://tonefex.com"}/admin/feedback`
  ].join("\n");

  console.info(`[tonefex:feedback:notification] ${subject}\n${text}`);
}
