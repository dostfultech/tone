import type { Metadata } from "next";
import { Suspense } from "react";
import { AuthForm } from "@/components/auth-form";
import { SiteShell } from "@/components/site-shell";
import { buildPageMetadata } from "@/lib/seo";

export const metadata: Metadata = buildPageMetadata({
  title: "Sign Up",
  description: "Create your account to save tones, track adaptations, and manage your rig settings.",
  path: "/signup",
  noIndex: true
});

export default function SignupPage() {
  return (
    <SiteShell>
      <Suspense fallback={null}>
        <AuthForm mode="signup" />
      </Suspense>
    </SiteShell>
  );
}
