import type { Metadata } from "next";
import { AppShell } from "@/components/app-shell";
import { LibraryView } from "@/components/library-view";

export const metadata: Metadata = {
  title: "Library"
};

export default function LibraryPage() {
  return (
    <AppShell>
      <LibraryView />
    </AppShell>
  );
}
