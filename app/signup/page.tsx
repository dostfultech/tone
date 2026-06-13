import type { Metadata } from "next";
import { Suspense } from "react";
import { AuthForm } from "@/components/auth-form";
import { SiteShell } from "@/components/site-shell";

export const metadata: Metadata = {
  title: "Sign Up"
};

export default function SignupPage() {
  return (
    <SiteShell>
      <Suspense fallback={null}>
        <AuthForm mode="signup" />
      </Suspense>
    </SiteShell>
  );
}
