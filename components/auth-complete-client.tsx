"use client";

import { useEffect, useMemo, useState } from "react";
import { Loader2, ShieldCheck } from "lucide-react";
import { createSupabaseBrowserClient } from "@/lib/supabase/browser";

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
        window.location.replace(next);
      }
    });

    async function finishSignIn() {
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
          window.location.replace(next);
          return;
        }

        setStatus(attempt < 8 ? "Finalizing your workspace..." : "Still syncing your session...");
        await new Promise((resolve) => window.setTimeout(resolve, 250));
      }

      if (!cancelled) {
        window.location.replace(`/login?error=session_sync&message=${encodeURIComponent("We could not confirm your session. Please try again.")}`);
      }
    }

    void finishSignIn();

    return () => {
      cancelled = true;
      subscription.unsubscribe();
    };
  }, [next]);

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
