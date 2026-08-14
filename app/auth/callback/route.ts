import { NextResponse, type NextRequest } from "next/server";
import { getSiteUrl } from "@/lib/env";
import { REF_COOKIE, normalizeRefCode } from "@/lib/referral";
import { createSupabaseAdminClient } from "@/lib/supabase/admin";
import { createSupabaseServerClient } from "@/lib/supabase/server";

export async function GET(request: NextRequest) {
  const requestUrl = new URL(request.url);
  const origin = resolveAuthOrigin(requestUrl);
  const code = requestUrl.searchParams.get("code");
  const tokenHash = requestUrl.searchParams.get("token_hash");
  const otpType = requestUrl.searchParams.get("type");
  const authError = requestUrl.searchParams.get("error");
  const errorDescription = requestUrl.searchParams.get("error_description");
  const next = safeNextPath(requestUrl.searchParams.get("next"));

  if (authError) {
    const loginUrl = new URL("/login", origin);
    loginUrl.searchParams.set("error", authError);
    if (errorDescription) {
      loginUrl.searchParams.set("message", errorDescription);
    }
    return NextResponse.redirect(loginUrl);
  }

  if (tokenHash && otpType) {
    const authCompleteUrl = new URL("/auth/complete", origin);
    authCompleteUrl.searchParams.set("next", next);
    authCompleteUrl.searchParams.set("token_hash", tokenHash);
    authCompleteUrl.searchParams.set("type", otpType);
    return NextResponse.redirect(authCompleteUrl);
  }

  if (code) {
    const supabase = await createSupabaseServerClient();
    const { error } = (await supabase?.auth.exchangeCodeForSession(code)) || {};
    if (error) {
      if (canRetryInBrowser(error.message)) {
        const authCompleteUrl = new URL("/auth/complete", origin);
        authCompleteUrl.searchParams.set("next", next);
        authCompleteUrl.searchParams.set("code", code);
        return NextResponse.redirect(authCompleteUrl);
      }

      const loginUrl = new URL("/login", origin);
      loginUrl.searchParams.set("error", "callback_failed");
      loginUrl.searchParams.set("message", error.message);
      return NextResponse.redirect(loginUrl);
    }

    await attributeReferral(request, supabase);
    const response = NextResponse.redirect(new URL(next, origin));
    response.cookies.set(REF_COOKIE, "", { maxAge: 0, path: "/" });
    return response;
  }

  const authCompleteUrl = new URL("/auth/complete", origin);
  authCompleteUrl.searchParams.set("next", next);
  return NextResponse.redirect(authCompleteUrl);
}

// Best-effort referral attribution: if the visitor arrived via ?ref=CODE (captured to a cookie)
// and this is a brand-new account, link them to the referrer. Never blocks or breaks auth.
async function attributeReferral(
  request: NextRequest,
  supabase: Awaited<ReturnType<typeof createSupabaseServerClient>>
) {
  try {
    const code = normalizeRefCode(request.cookies.get(REF_COOKIE)?.value);
    if (!code || !supabase) {
      return;
    }
    const {
      data: { user }
    } = await supabase.auth.getUser();
    if (!user) {
      return;
    }
    const admin = createSupabaseAdminClient();
    if (!admin) {
      return;
    }
    const { data: me } = await admin.from("profiles").select("referred_by").eq("id", user.id).maybeSingle();
    if (!me || me.referred_by) {
      return; // no profile yet, or already attributed
    }
    const { data: referrer } = await admin.from("profiles").select("id").eq("referral_code", code).maybeSingle();
    if (!referrer || referrer.id === user.id) {
      return; // unknown code or self-referral
    }
    await admin.from("profiles").update({ referred_by: referrer.id }).eq("id", user.id).is("referred_by", null);
  } catch {
    // swallow — referral attribution must never break sign-in
  }
}

function resolveAuthOrigin(requestUrl: URL) {
  if (process.env.NODE_ENV !== "production") {
    return requestUrl.origin;
  }

  const configuredSiteUrl = getSiteUrl();
  const configuredHost = new URL(configuredSiteUrl).hostname.toLowerCase();
  const currentHost = requestUrl.hostname.toLowerCase();
  if (currentHost === configuredHost || currentHost === "localhost" || currentHost === "127.0.0.1") {
    return requestUrl.origin;
  }

  return configuredSiteUrl;
}

function safeNextPath(value: string | null) {
  if (!value || !value.startsWith("/") || value.startsWith("//")) {
    return "/app";
  }

  return value;
}

function canRetryInBrowser(message: string) {
  const normalized = message.toLowerCase();
  return (
    normalized.includes("pkce code verifier") ||
    normalized.includes("fetch failed") ||
    normalized.includes("certificate") ||
    normalized.includes("unable to verify")
  );
}
