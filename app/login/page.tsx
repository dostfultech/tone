import type { Metadata } from "next";
import { Suspense } from "react";
import { AuthForm } from "@/components/auth-form";
import { SiteShell } from "@/components/site-shell";
import { buildPageMetadata } from "@/lib/seo";

export const metadata: Metadata = buildPageMetadata({
  title: "Log In",
  description: "Sign in to your account to continue tone matching and sync your saved presets.",
  path: "/login",
  noIndex: true
});

export default function LoginPage() {
  return (
    <SiteShell>
      <Suspense fallback={null}>
        <AuthForm mode="login" />
      </Suspense>
    </SiteShell>
  );
}
