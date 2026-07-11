import type { Metadata } from "next";
import Link from "next/link";
import { brand } from "@/lib/brand";
import { SiteShell } from "@/components/site-shell";
import { buildPageMetadata } from "@/lib/seo";

export const metadata: Metadata = buildPageMetadata({
  title: "Privacy Policy",
  description: "Read how Tonefex stores, processes, and protects account and tone adaptation data.",
  path: "/privacy"
});

export default function PrivacyPage() {
  return (
    <SiteShell>
      <LegalPage title="Privacy Policy" updated="Last updated June 11, 2026">
        <p>
          {brand.appName} stores account data, reviews, gear presets, saved tones, billing status, and tone-generation activity in the services configured for this application.
        </p>
        <h2>Information collected</h2>
        <p>
          The app may store interface preferences, profile details, song queries, selected gear, generated recommendations, and review text.
        </p>
        <h2>Provider integrations</h2>
        <p>
          {brand.appName} uses Supabase for authentication and data storage, Dodo Payments for billing, OpenAI for tone generation, and Vercel/PostHog-ready analytics hooks.
        </p>
        <h2>Cookies and storage</h2>
        <p>
          The cookie banner writes a consent value named <code>{brand.storagePrefix}_cookie_consent</code>. Additional localStorage keys track dismissed banners, generated tones, and saved gear.
        </p>
        <h2>Contact</h2>
        <p>
          For production use, replace this page with reviewed legal text for your own company, data flows, and jurisdiction.
        </p>
      </LegalPage>
    </SiteShell>
  );
}

function LegalPage({ title, updated, children }: { title: string; updated: string; children: React.ReactNode }) {
  return (
    <section className="section py-12">
      <Link href="/" className="text-sm font-semibold text-ocean">
        Back to Home
      </Link>
      <article className="mt-6 max-w-4xl space-y-4 rounded-lg border border-neutral-200 bg-white p-6 leading-7 text-neutral-700 shadow-sm [&_code]:rounded [&_code]:bg-neutral-100 [&_code]:px-1.5 [&_h1]:text-3xl [&_h1]:font-semibold [&_h2]:pt-4 [&_h2]:text-xl [&_h2]:font-semibold">
        <h1>{title}</h1>
        <p className="text-sm text-neutral-500">{updated}</p>
        {children}
      </article>
    </section>
  );
}
