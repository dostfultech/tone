import type { Metadata } from "next";
import { Suspense } from "react";
import { AppShell } from "@/components/app-shell";
import { CommunityView } from "@/components/community-view";
import { buildPageMetadata } from "@/lib/seo";

export const metadata: Metadata = buildPageMetadata({
  title: "Tone Database",
  description: "Browse public tone profiles and adapt them to your own guitar or bass rig.",
  path: "/community"
});

export default function CommunityPage() {
  return (
    <AppShell>
      <Suspense fallback={null}>
        <CommunityView />
      </Suspense>
    </AppShell>
  );
}
