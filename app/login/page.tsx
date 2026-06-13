import type { Metadata } from "next";
import { Suspense } from "react";
import { AuthForm } from "@/components/auth-form";
import { SiteShell } from "@/components/site-shell";

export const metadata: Metadata = {
  title: "Log In"
};

export default function LoginPage() {
  return (
    <SiteShell>
      <Suspense fallback={null}>
        <AuthForm mode="login" />
      </Suspense>
    </SiteShell>
  );
}
