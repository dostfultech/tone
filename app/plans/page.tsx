import type { Metadata } from "next";
import { AppShell } from "@/components/app-shell";
import { Pricing } from "@/components/pricing";
import { buildPageMetadata } from "@/lib/seo";

export const metadata: Metadata = buildPageMetadata({
  title: "Pricing & Plans",
  description: "Compare Tonefex plans and start a subscription for unlimited tone adaptations.",
  path: "/plans",
  keywords: ["tonefex pricing", "guitar tone subscription", "music app plans"]
});

export default function PlansPage() {
  return (
    <AppShell>
      <Pricing />
    </AppShell>
  );
}
