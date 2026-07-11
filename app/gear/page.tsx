import type { Metadata } from "next";
import Link from "next/link";
import { Suspense } from "react";
import { AppShell } from "@/components/app-shell";
import { GearView } from "@/components/gear-view";
import { SiteShell } from "@/components/site-shell";
import { amps, bassAmps, bassGuitars, cabinets, effectsCatalog, guitars } from "@/lib/mock-data";
import { buildPageMetadata } from "@/lib/seo";
import { getCurrentSession } from "@/lib/server-access";

export const metadata: Metadata = buildPageMetadata({
  title: "Guitar and Bass Gear Library",
  description: "Browse supported guitars, basses, amps, cabinets, and effect chains available for tone adaptation.",
  path: "/gear",
  keywords: ["guitar gear", "bass gear", "amp list", "effects catalog", "tonefex gear"]
});

export default async function GearPage() {
  const { user } = await getCurrentSession();

  if (user) {
    return (
      <AppShell>
        <Suspense fallback={null}>
          <GearView />
        </Suspense>
      </AppShell>
    );
  }

  const sections = [
    { title: "Guitars", items: guitars.slice(0, 12).map((item) => item.name) },
    { title: "Bass Guitars", items: bassGuitars.slice(0, 10).map((item) => item.name) },
    { title: "Guitar Amps", items: amps.slice(0, 12).map((item) => item.name) },
    { title: "Bass Amps", items: bassAmps.slice(0, 10).map((item) => item.name) },
    { title: "Cabinets", items: cabinets.slice(0, 8).map((item) => item.name) },
    { title: "Effects", items: effectsCatalog.slice(0, 12).map((item) => item.name) }
  ];

  return (
    <SiteShell>
      <section className="section py-14">
        <div className="mx-auto max-w-5xl text-center">
          <h1 className="text-4xl font-bold tracking-normal text-ink sm:text-5xl">Public Gear Library</h1>
          <p className="mx-auto mt-4 max-w-3xl text-lg leading-8 text-slate-600">
            Explore the supported gear ecosystem used by the tone matching engine, then sign in to adapt those tones to your own rig.
          </p>
          <div className="mt-8 flex flex-wrap items-center justify-center gap-3">
            <Link href="/songs" className="button-secondary min-h-11 px-5">Browse Songs</Link>
            <Link href="/artists" className="button-secondary min-h-11 px-5">Browse Artists</Link>
            <Link href="/signup" className="button-primary min-h-11 px-5">Create Free Account</Link>
          </div>
        </div>

        <div className="mx-auto mt-10 grid max-w-6xl gap-5 md:grid-cols-2">
          {sections.map((section) => (
            <article key={section.title} className="compact-card p-6">
              <h2 className="text-2xl font-bold text-ink">{section.title}</h2>
              <ul className="mt-4 grid gap-2 text-sm leading-6 text-slate-600">
                {section.items.map((item) => (
                  <li key={item} className="rounded-md border border-neutral-100 bg-white px-3 py-2">
                    {item}
                  </li>
                ))}
              </ul>
            </article>
          ))}
        </div>
      </section>
    </SiteShell>
  );
}
