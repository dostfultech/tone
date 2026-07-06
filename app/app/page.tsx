import type { Metadata } from "next";
import { Suspense } from "react";
import { AppShell } from "@/components/app-shell";
import { ToneMatcher } from "@/components/tone-matcher";

export const metadata: Metadata = {
  title: "Guitar Tone Matcher"
};

export default function MatcherPage() {
  return (
    <AppShell>
      <Suspense fallback={null}>
        <ToneMatcher />
      </Suspense>
    </AppShell>
  );
}
