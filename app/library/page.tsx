import type { Metadata } from "next";
import { AppShell } from "@/components/app-shell";
import { LibraryView } from "@/components/library-view";
import { buildPageMetadata } from "@/lib/seo";

export const metadata: Metadata = buildPageMetadata({
  title: "Library",
  description: "View and manage your saved tones and adaptation history.",
  path: "/library",
  noIndex: true
});

export default function LibraryPage() {
  return (
    <AppShell>
      <LibraryView />
    </AppShell>
  );
}
