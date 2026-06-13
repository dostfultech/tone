import type { Metadata } from "next";
import { AppShell } from "@/components/app-shell";
import { ToneMatcher } from "@/components/tone-matcher";

export const metadata: Metadata = {
  title: "Guitar Tone Matcher"
};

export default function MatcherPage() {
  return (
    <AppShell>
      <ToneMatcher />
    </AppShell>
  );
}
