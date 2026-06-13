import type { Metadata } from "next";
import { AppShell } from "@/components/app-shell";
import { GearView } from "@/components/gear-view";

export const metadata: Metadata = {
  title: "My Gear"
};

export default function GearPage() {
  return (
    <AppShell>
      <GearView />
    </AppShell>
  );
}
