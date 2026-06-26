import { NextResponse, type NextRequest } from "next/server";
import { getSiteUrl } from "@/lib/env";
import { createSupabaseServerClient } from "@/lib/supabase/server";

export async function GET(request: NextRequest) {
  const requestUrl = new URL(request.url);
  const origin = resolveAuthOrigin(requestUrl);
  const code = requestUrl.searchParams.get("code");
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

  if (code) {
    const supabase = await createSupabaseServerClient();
    const { error } = (await supabase?.auth.exchangeCodeForSession(code)) || {};
    if (error) {
      const loginUrl = new URL("/login", origin);
      loginUrl.searchParams.set("error", "callback_failed");
      loginUrl.searchParams.set("message", error.message);
      return NextResponse.redirect(loginUrl);
    }
  }

  return NextResponse.redirect(new URL(next, origin));
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
