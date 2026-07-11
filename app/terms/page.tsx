import type { Metadata } from "next";
import Link from "next/link";
import { brand } from "@/lib/brand";
import { SiteShell } from "@/components/site-shell";
import { buildPageMetadata } from "@/lib/seo";

export const metadata: Metadata = buildPageMetadata({
  title: "Terms of Use",
  description: "Review usage terms, subscription policies, and account responsibilities for Tonefex.",
  path: "/terms"
});

export default function TermsPage() {
  return (
    <SiteShell>
      <section className="section py-12">
        <Link href="/" className="text-sm font-semibold text-ocean">
          Back to Home
        </Link>
        <article className="mt-6 max-w-4xl space-y-4 rounded-lg border border-neutral-200 bg-white p-6 leading-7 text-neutral-700 shadow-sm [&_h1]:text-3xl [&_h1]:font-semibold [&_h2]:pt-4 [&_h2]:text-xl [&_h2]:font-semibold">
          <h1>Terms of Use</h1>
          <p className="text-sm text-neutral-500">Last updated June 11, 2026</p>
          <h2>Use of this service</h2>
          <p>
            {brand.appName} is a paid tone-matching service for guitar and bass players. You are responsible for using generated settings safely and lawfully.
          </p>
          <h2>Subscriptions</h2>
          <p>
            Billing is handled through Dodo Payments. A subscription is active only after payment provider confirmation or approved local test access.
          </p>
          <h2>Tone recommendations</h2>
          <p>
            Generated settings are educational starting points. Always use your ears, keep stage volume safe, and adjust to the instrument, room, and band mix.
          </p>
          <h2>Production readiness</h2>
          <p>
            Before production deployment, replace placeholder legal copy, connect real authentication and billing, secure database policies, and audit generated AI output.
          </p>
        </article>
      </section>
    </SiteShell>
  );
}
