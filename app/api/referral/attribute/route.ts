import { NextResponse, type NextRequest } from "next/server";
import { REF_COOKIE, normalizeRefCode } from "@/lib/referral";
import { createSupabaseAdminClient } from "@/lib/supabase/admin";
import { createSupabaseServerClient } from "@/lib/supabase/server";

// Called by the client after an email-link sign-in completes (the Google path is handled in the
// auth callback). Reads the captured ?ref cookie and links the new account to its referrer.
// Idempotent + best-effort — only sets referred_by when it's still empty, and clears the cookie.
export async function POST(request: NextRequest) {
  const clearCookie = (res: NextResponse) => {
    res.cookies.set(REF_COOKIE, "", { maxAge: 0, path: "/" });
    return res;
  };

  try {
    const code = normalizeRefCode(request.cookies.get(REF_COOKIE)?.value);
    const supabase = await createSupabaseServerClient();
    const {
      data: { user }
    } = (await supabase?.auth.getUser()) ?? { data: { user: null } };

    if (!code || !user) {
      return clearCookie(NextResponse.json({ ok: true, attributed: false }));
    }

    const admin = createSupabaseAdminClient();
    if (!admin) {
      return clearCookie(NextResponse.json({ ok: true, attributed: false }));
    }

    const { data: me } = await admin.from("profiles").select("referred_by").eq("id", user.id).maybeSingle();
    if (!me || me.referred_by) {
      return clearCookie(NextResponse.json({ ok: true, attributed: false }));
    }

    const { data: referrer } = await admin.from("profiles").select("id").eq("referral_code", code).maybeSingle();
    if (!referrer || referrer.id === user.id) {
      return clearCookie(NextResponse.json({ ok: true, attributed: false }));
    }

    await admin.from("profiles").update({ referred_by: referrer.id }).eq("id", user.id).is("referred_by", null);
    return clearCookie(NextResponse.json({ ok: true, attributed: true }));
  } catch {
    return NextResponse.json({ ok: false });
  }
}
