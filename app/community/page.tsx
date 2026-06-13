import type { Metadata } from "next";
import { AppShell } from "@/components/app-shell";
import { CommunityView } from "@/components/community-view";

export const metadata: Metadata = {
  title: "Tone Database"
};

export default function CommunityPage() {
  return (
    <AppShell>
      <CommunityView />
    </AppShell>
  );
}
