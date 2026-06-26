"use client";

import { FormEvent, useEffect, useState } from "react";
import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { Chrome, Loader2, Music2 } from "lucide-react";
import { brand } from "@/lib/brand";
import { createSupabaseBrowserClient } from "@/lib/supabase/browser";

export function AuthForm({ mode }: { mode: "login" | "signup" | "reset" | "update" }) {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [loading, setLoading] = useState(false);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");
  const [updateComplete, setUpdateComplete] = useState(false);
  const [recoveryReady, setRecoveryReady] = useState(mode !== "update");
  const googleAuthEnabled = process.env.NEXT_PUBLIC_GOOGLE_AUTH_ENABLED !== "false";

  useEffect(() => {
    const authMessage = searchParams.get("message");
    const authError = searchParams.get("error");
    const passwordReset = searchParams.get("passwordReset");
    if (authError) {
      setError(authMessage || "Authentication could not be completed. Please try again.");
    } else if (passwordReset === "success") {
      setMessage("Your password has been updated. Sign in with your new password.");
    } else if (authMessage) {
      setMessage(authMessage);
    }
  }, [searchParams]);

  useEffect(() => {
    if (mode !== "update") {
      return;
    }

    const supabase = createSupabaseBrowserClient();
    if (!supabase) {
      setRecoveryReady(false);
      setError("Supabase is not configured. Request a new password reset link after configuring auth.");
      return;
    }

    supabase.auth.getSession().then(({ data, error: sessionError }) => {
      if (sessionError || !data.session) {
        setRecoveryReady(false);
        setError("This password reset link is invalid or has expired. Request a new reset link to continue.");
        return;
      }

      setRecoveryReady(true);
    });
  }, [mode]);

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setLoading(true);
    setMessage("");
    setError("");

    const formData = new FormData(event.currentTarget);
    const submittedEmail = String(formData.get("email") || email).trim();
    const submittedPassword = String(formData.get("password") || password);
    const submittedConfirmPassword = String(formData.get("confirm-password") || confirmPassword);

    const supabase = createSupabaseBrowserClient();
    if (!supabase) {
      setError("Supabase is not configured. Add NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_ANON_KEY to .env.local.");
      setLoading(false);
      return;
    }

    const origin = window.location.origin;
    const redirectTo = searchParams.get("redirect") || "/app";

    if (mode === "reset") {
      const { error: resetError } = await supabase.auth.resetPasswordForEmail(submittedEmail, {
        redirectTo: `${origin}/reset-password`
      });
      setLoading(false);
      if (resetError) {
        setError(resetError.message);
      } else {
        setMessage("Password reset link sent. Check your inbox.");
      }
      return;
    }

    if (mode === "update") {
      if (submittedPassword.length < 6) {
        setLoading(false);
        setError("Password must be at least 6 characters.");
        return;
      }

      if (submittedPassword !== submittedConfirmPassword) {
        setLoading(false);
        setError("Passwords do not match.");
        return;
      }

      const { error: updateError } = await supabase.auth.updateUser({ password: submittedPassword });
      setLoading(false);
      if (updateError) {
        setError(updateError.message);
      } else {
        setUpdateComplete(true);
        setMessage("Password updated successfully. You can sign in now.");
      }
      return;
    }

    if (mode === "signup") {
      const { error: signUpError } = await supabase.auth.signUp({
        email: submittedEmail,
        password: submittedPassword,
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

    const { data: signInData, error: signInError } = await supabase.auth.signInWithPassword({
      email: submittedEmail,
      password: submittedPassword
    });
    if (signInError) {
      setLoading(false);
      setError(signInError.message);
      return;
    }

    if (!signInData.session) {
      setLoading(false);
      setError("Sign-in could not be completed. Please try again.");
      return;
    }

    window.location.assign(redirectTo);
  }

  async function signInWithGoogle() {
    setError("");
    if (!googleAuthEnabled) {
      setError("Google sign-in is disabled for this deployment.");
      return;
    }

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

  const title = mode === "signup" ? "Create your account" : mode === "reset" ? "Reset your password" : mode === "update" ? "Choose a new password" : "Sign in";
  const description =
    mode === "signup"
      ? `Create your ${brand.appName} account to save tones, manage gear, and unlock paid access.`
      : mode === "reset"
      ? `Enter the email you use for ${brand.appName} and we will send a secure reset link.`
      : mode === "update"
        ? `Choose a new password for your ${brand.appName} account.`
        : "Sign in to access your tone workspace and saved gear settings.";

  return (
    <div className="section grid min-h-[calc(100vh-4rem)] items-center py-12">
      <div className="mx-auto w-full max-w-md">
        <div className="compact-card p-6 shadow-soft">
          <div className="mb-6 flex h-12 w-12 items-center justify-center rounded-lg bg-ink text-white">
            <Music2 className="h-6 w-6" />
          </div>
          <h1 className="text-2xl font-semibold">{title}</h1>
          <p className="mt-2 text-sm leading-6 text-neutral-600">{description}</p>

          {mode === "login" || mode === "signup" ? (
            <button className="button-secondary mt-6 w-full" type="button" onClick={signInWithGoogle}>
              <Chrome className="h-4 w-4" />
              Continue with Google
            </button>
          ) : null}

          {updateComplete ? (
            <div className="mt-6 grid gap-4">
              {message ? <div className="rounded-md bg-blue-50/80 px-3 py-2 text-sm font-semibold text-ink">{message}</div> : null}
              <Link href="/login?passwordReset=success" className="button-primary w-full justify-center">
                Return to sign in
              </Link>
            </div>
          ) : mode === "update" && !recoveryReady ? (
            <div className="mt-6 grid gap-4">
              {error ? <div className="rounded-md bg-red-50 px-3 py-2 text-sm text-red-800">{error}</div> : null}
              <Link href="/forgot-password" className="button-primary w-full justify-center">
                Request a new reset link
              </Link>
              <Link href="/login" className="button-secondary w-full justify-center">
                Back to sign in
              </Link>
            </div>
          ) : (
          <form onSubmit={submit} className="mt-6 grid gap-4">
            {mode !== "update" ? (
              <div>
                <label htmlFor="email" className="label">
                  Email
                </label>
                <input
                  id="email"
                  name="email"
                  className="field mt-1"
                  type="email"
                  value={email}
                  onChange={(event) => setEmail(event.target.value)}
                  required
                  placeholder="you@example.com"
                />
              </div>
            ) : null}
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
                  name="password"
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
            {mode === "update" ? (
              <div>
                <label htmlFor="confirm-password" className="label">
                  Confirm password
                </label>
                <input
                  id="confirm-password"
                  name="confirm-password"
                  className="field mt-1"
                  type="password"
                  value={confirmPassword}
                  onChange={(event) => setConfirmPassword(event.target.value)}
                  minLength={6}
                  required
                  placeholder="Repeat your new password"
                />
              </div>
            ) : null}
              {message ? <div className="rounded-md bg-blue-50/80 px-3 py-2 text-sm font-semibold text-ink">{message}</div> : null}
            {error ? <div className="rounded-md bg-red-50 px-3 py-2 text-sm text-red-800">{error}</div> : null}
            <button className="button-primary w-full" disabled={loading}>
              {loading ? <Loader2 className="h-4 w-4 animate-spin" /> : null}
              {mode === "signup" ? "Create account" : mode === "reset" ? "Send reset link" : mode === "update" ? "Update password" : "Sign in"}
            </button>
          </form>
            )}
          <div className="mt-6 text-center text-sm text-neutral-600">
            {mode === "update" ? (
              <>Open this page from the password reset email to choose a new password.</>
            ) : null}
            {mode === "login" ? (
              <>
                New here?{" "}
                <Link className="font-semibold text-ink" href="/signup">
                  Create an account
                </Link>
              </>
            ) : mode === "update" ? null : (
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
