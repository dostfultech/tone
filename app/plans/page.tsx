import type { Metadata } from "next";
import { AppShell } from "@/components/app-shell";
import { Pricing } from "@/components/pricing";

export const metadata: Metadata = {
  title: "Pricing & Plans"
};

export default function PlansPage() {
  return (
    <AppShell>
      <Pricing />
    </AppShell>
  );
}
