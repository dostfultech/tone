import type { Metadata } from "next";
import Link from "next/link";
import { OnboardingWizard } from "@/components/onboarding-wizard";
import { buildPageMetadata } from "@/lib/seo";
import { brand } from "@/lib/brand";

export const metadata: Metadata = buildPageMetadata({
  title: `Set up your rig — ${brand.appName}`,
  description: "Tell us what gear you own and we'll tailor every tone to your exact setup.",
  path: "/onboarding"
});

export default function OnboardingPage() {
  return (
    <div className="app-gradient min-h-screen text-ink">
      <header className="mx-auto flex max-w-2xl items-center justify-between px-4 pt-6 sm:px-6">
        <Link href="/" className="flex items-center gap-2 text-lg font-bold">
          <span className="grid h-9 w-9 place-items-center overflow-hidden rounded-lg bg-ink">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/tonefex-logo.svg" alt="" className="h-6 w-6" />
          </span>
          {brand.appName}
        </Link>
        <Link href="/app" className="text-sm font-semibold text-slate-500 hover:text-ink">
          Skip
        </Link>
      </header>
      <OnboardingWizard />
    </div>
  );
}
