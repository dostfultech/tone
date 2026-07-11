import type { Metadata } from "next";
import { Suspense } from "react";
import { AuthForm } from "@/components/auth-form";
import { SiteShell } from "@/components/site-shell";
import { buildPageMetadata } from "@/lib/seo";

export const metadata: Metadata = buildPageMetadata({
  title: "Choose a New Password",
  description: "Set a new password securely for your Tonefex account.",
  path: "/reset-password",
  noIndex: true
});

export default function ResetPasswordPage() {
  return (
    <SiteShell>
      <Suspense fallback={null}>
        <AuthForm mode="update" />
      </Suspense>
    </SiteShell>
  );
}