import type { Metadata } from "next";
import { Suspense } from "react";
import { AuthForm } from "@/components/auth-form";
import { SiteShell } from "@/components/site-shell";
import { buildPageMetadata } from "@/lib/seo";

export const metadata: Metadata = buildPageMetadata({
  title: "Reset Password",
  description: "Request a secure password reset link for your Tonefex account.",
  path: "/forgot-password",
  noIndex: true
});

export default function ForgotPasswordPage() {
  return (
    <SiteShell>
      <Suspense fallback={null}>
        <AuthForm mode="reset" />
      </Suspense>
    </SiteShell>
  );
}
