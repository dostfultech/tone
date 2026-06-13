import type { Metadata } from "next";
import { Suspense } from "react";
import { AuthForm } from "@/components/auth-form";
import { SiteShell } from "@/components/site-shell";

export const metadata: Metadata = {
  title: "Reset Password"
};

export default function ForgotPasswordPage() {
  return (
    <SiteShell>
      <Suspense fallback={null}>
        <AuthForm mode="reset" />
      </Suspense>
    </SiteShell>
  );
}
