import type { Metadata } from "next";
import { Suspense } from "react";
import { AuthForm } from "@/components/auth-form";
import { SiteShell } from "@/components/site-shell";

export const metadata: Metadata = {
  title: "Choose a New Password"
};

export default function ResetPasswordPage() {
  return (
    <SiteShell>
      <Suspense fallback={null}>
        <AuthForm mode="update" />
      </Suspense>
    </SiteShell>
  );
}