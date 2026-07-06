import type { Metadata } from "next";
import { Suspense } from "react";
import { AppShell } from "@/components/app-shell";
import { CommunityView } from "@/components/community-view";

export const metadata: Metadata = {
  title: "Tone Database"
};

export default function CommunityPage() {
  return (
    <AppShell>
      <Suspense fallback={null}>
        <CommunityView />
      </Suspense>
    </AppShell>
  );
}
