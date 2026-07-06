"use client";

import { useEffect, useMemo, useState } from "react";
import { Loader2, ShieldCheck } from "lucide-react";
import { createSupabaseBrowserClient } from "@/lib/supabase/browser";

const OAUTH_PROGRESS_KEY = "tonefex_oauth_in_progress";

type AuthCompleteClientProps = {
  searchParams: Record<string, string | string[] | undefined>;
};

export function AuthCompleteClient({ searchParams }: AuthCompleteClientProps) {
  const [status, setStatus] = useState("Completing your sign-in...");
  const [error, setError] = useState("");

  const next = useMemo(() => {
    const value = searchParams.next;
    const candidate = Array.isArray(value) ? value[0] || "" : value || "";
    if (!candidate || !candidate.startsWith("/") || candidate.startsWith("//")) {
      return "/app";
    }
    return candidate;
  }, [searchParams]);

  const code = useMemo(() => getSearchParam(searchParams, "code"), [searchParams]);
  const tokenHash = useMemo(() => getSearchParam(searchParams, "token_hash"), [searchParams]);
  const otpType = useMemo(() => getSearchParam(searchParams, "type"), [searchParams]);

  useEffect(() => {
    const supabase = createSupabaseBrowserClient();
    if (!supabase) {
      return;
    }
    const client = supabase;

    let cancelled = false;

    const {
      data: { subscription }
    } = client.auth.onAuthStateChange((_event, session) => {
      if (session?.user) {
        clearOauthInProgress();
        window.location.replace(next);
      }
    });

    async function finishSignIn() {
      const {
        data: { session: initialSession }
      } = await client.auth.getSession();

      if (!initialSession) {
        const authActionError = await completeBrowserAuth(client, { code, tokenHash, otpType });
        if (authActionError) {
          clearOauthInProgress();
          setError(authActionError);
          window.setTimeout(() => {
            window.location.replace(`/login?error=callback_failed&message=${encodeURIComponent(authActionError)}`);
          }, 900);
          return;
        }
      }

      for (let attempt = 0; attempt < 20 && !cancelled; attempt += 1) {
        const {
          data: { session },
          error: sessionError
        } = await client.auth.getSession();

        if (sessionError) {
          setError(sessionError.message);
          return;
        }

        if (session?.user) {
          clearOauthInProgress();
          window.location.replace(next);
          return;
        }

        setStatus(attempt < 8 ? "Finalizing your workspace..." : "Still syncing your session...");
        await new Promise((resolve) => window.setTimeout(resolve, 250));
      }

      if (!cancelled) {
        clearOauthInProgress();
        window.location.replace(`/login?error=session_sync&message=${encodeURIComponent("We could not confirm your session. Please try again.")}`);
      }
    }

    void finishSignIn();

    return () => {
      cancelled = true;
      subscription.unsubscribe();
    };
  }, [code, next, otpType, tokenHash]);

  return (
    <div className="section grid min-h-[calc(100vh-4rem)] place-items-center py-12">
      <div className="compact-card w-full max-w-md p-8 text-center shadow-soft">
        <div className="mx-auto grid h-16 w-16 place-items-center rounded-2xl bg-ink text-moss">
          <ShieldCheck className="h-8 w-8" />
        </div>
        <h1 className="mt-6 text-2xl font-semibold">Signing you in</h1>
        <p className="mt-3 text-sm leading-6 text-neutral-600">{error || status}</p>
        <div className="mt-6 inline-flex items-center gap-3 rounded-lg border border-neutral-200 bg-neutral-50 px-4 py-3 text-sm font-medium text-slate-600">
          <Loader2 className="h-4 w-4 animate-spin" />
          Generating your workspace session...
        </div>
      </div>
    </div>
  );
}

async function completeBrowserAuth(
  client: NonNullable<ReturnType<typeof createSupabaseBrowserClient>>,
  params: { code: string; tokenHash: string; otpType: string }
) {
  const { code, tokenHash, otpType } = params;

  if (tokenHash && isSupportedOtpType(otpType)) {
    const { error } = await client.auth.verifyOtp({
      token_hash: tokenHash,
      type: otpType
    });
    return error?.message || "";
  }

  if (code) {
    const { error } = await client.auth.exchangeCodeForSession(code);
    return error?.message || "";
  }

  return "";
}

function getSearchParam(searchParams: Record<string, string | string[] | undefined>, key: string) {
  const value = searchParams[key];
  return Array.isArray(value) ? value[0] || "" : value || "";
}

function isSupportedOtpType(value: string): value is "signup" | "invite" | "magiclink" | "recovery" | "email_change" | "email" {
  return ["signup", "invite", "magiclink", "recovery", "email_change", "email"].includes(value);
}

function clearOauthInProgress() {
  if (typeof window === "undefined") {
    return;
  }

  window.sessionStorage.removeItem(OAUTH_PROGRESS_KEY);
}
