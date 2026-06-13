"use client";

import { FormEvent, useState } from "react";
import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { Chrome, Loader2, Music2 } from "lucide-react";
import { createSupabaseBrowserClient } from "@/lib/supabase/browser";

export function AuthForm({ mode }: { mode: "login" | "signup" | "reset" }) {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [loading, setLoading] = useState(false);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setLoading(true);
    setMessage("");
    setError("");

    const supabase = createSupabaseBrowserClient();
    if (!supabase) {
      setError("Supabase is not configured. Add NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_ANON_KEY to .env.local.");
      setLoading(false);
      return;
    }

    const origin = window.location.origin;
    const redirectTo = searchParams.get("redirect") || "/app";

    if (mode === "reset") {
      const { error: resetError } = await supabase.auth.resetPasswordForEmail(email, {
        redirectTo: `${origin}/login?passwordReset=success`
      });
      setLoading(false);
      if (resetError) {
        setError(resetError.message);
      } else {
        setMessage("Password reset link sent. Check your inbox.");
      }
      return;
    }

    if (mode === "signup") {
      const { error: signUpError } = await supabase.auth.signUp({
        email,
        password,
        options: {
          emailRedirectTo: `${origin}/auth/callback?next=/plans`
        }
      });
      setLoading(false);
      if (signUpError) {
        setError(signUpError.message);
      } else {
        setMessage("Account created. Check your email if confirmation is enabled, then choose a plan.");
        router.refresh();
      }
      return;
    }

    const { error: signInError } = await supabase.auth.signInWithPassword({ email, password });
    setLoading(false);
    if (signInError) {
      setError(signInError.message);
    } else {
      router.push(redirectTo);
      router.refresh();
    }
  }

  async function signInWithGoogle() {
    setError("");
    const supabase = createSupabaseBrowserClient();
    if (!supabase) {
      setError("Supabase is not configured.");
      return;
    }

    const next = searchParams.get("redirect") || "/app";
    const { error: oauthError } = await supabase.auth.signInWithOAuth({
      provider: "google",
      options: {
        redirectTo: `${window.location.origin}/auth/callback?next=${encodeURIComponent(next)}`
      }
    });
    if (oauthError) {
      setError(oauthError.message);
    }
  }

  const title = mode === "signup" ? "Create your account" : mode === "reset" ? "Reset your password" : "Sign in";

  return (
    <div className="section grid min-h-[calc(100vh-4rem)] items-center py-12">
      <div className="mx-auto w-full max-w-md">
        <div className="compact-card p-6 shadow-soft">
          <div className="mb-6 flex h-12 w-12 items-center justify-center rounded-lg bg-ink text-white">
            <Music2 className="h-6 w-6" />
          </div>
          <h1 className="text-2xl font-semibold">{title}</h1>
          <p className="mt-2 text-sm leading-6 text-neutral-600">
            Sign in to access paid tone matching. Add your email to TEST_ACCESS_EMAILS for local testing without payment.
          </p>

          {mode !== "reset" ? (
            <button className="button-secondary mt-6 w-full" type="button" onClick={signInWithGoogle}>
              <Chrome className="h-4 w-4" />
              Continue with Google
            </button>
          ) : null}

          <form onSubmit={submit} className="mt-6 grid gap-4">
            <div>
              <label htmlFor="email" className="label">
                Email
              </label>
              <input
                id="email"
                className="field mt-1"
                type="email"
                value={email}
                onChange={(event) => setEmail(event.target.value)}
                required
                placeholder="you@example.com"
              />
            </div>
            {mode !== "reset" ? (
              <div>
                <div className="flex items-center justify-between">
                  <label htmlFor="password" className="label">
                    Password
                  </label>
                  {mode === "login" ? (
                    <Link href="/forgot-password" className="text-xs font-semibold text-ocean">
                      Forgot password?
                    </Link>
                  ) : null}
                </div>
                <input
                  id="password"
                  className="field mt-1"
                  type="password"
                  value={password}
                  onChange={(event) => setPassword(event.target.value)}
                  minLength={6}
                  required
                  placeholder="Minimum 6 characters"
                />
              </div>
            ) : null}
      {message ? <div className="rounded-md bg-blue-50/80 px-3 py-2 text-sm font-semibold text-ink">{message}</div> : null}
            {error ? <div className="rounded-md bg-red-50 px-3 py-2 text-sm text-red-800">{error}</div> : null}
            <button className="button-primary w-full" disabled={loading}>
              {loading ? <Loader2 className="h-4 w-4 animate-spin" /> : null}
              {mode === "signup" ? "Create account" : mode === "reset" ? "Send reset link" : "Sign in"}
            </button>
          </form>
          <div className="mt-6 text-center text-sm text-neutral-600">
            {mode === "login" ? (
              <>
                New here?{" "}
                <Link className="font-semibold text-ink" href="/signup">
                  Create an account
                </Link>
              </>
            ) : (
              <>
                Already have an account?{" "}
                <Link className="font-semibold text-ink" href="/login">
                  Sign in
                </Link>
              </>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
