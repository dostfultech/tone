import type { Metadata } from "next";
import { Suspense } from "react";
import { AppShell } from "@/components/app-shell";
import { CheckoutSuccessTracker } from "@/components/checkout-success-tracker";
import { ToneMatcher } from "@/components/tone-matcher";
import { buildPageMetadata } from "@/lib/seo";

export const metadata: Metadata = buildPageMetadata({
  title: "Guitar Tone Matcher",
  description: "Generate AI-assisted, gear-matched tone settings for guitar and bass.",
  path: "/app",
  noIndex: true
});

export default function MatcherPage() {
  return (
    <AppShell>
      <Suspense fallback={null}>
        <CheckoutSuccessTracker />
        <ToneMatcher />
      </Suspense>
    </AppShell>
  );
}
