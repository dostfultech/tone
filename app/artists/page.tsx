import type { Metadata } from "next";
import Link from "next/link";
import { SiteShell } from "@/components/site-shell";
import { buildPageMetadata, toAbsoluteUrl } from "@/lib/seo";
import { seoArtists } from "@/lib/seo-content";

export const metadata: Metadata = buildPageMetadata({
  title: "Artist Tone Profiles",
  description: "Browse artist-focused guitar and bass tone profiles and discover song-specific settings.",
  path: "/artists",
  keywords: ["artist guitar tones", "artist bass tones", "tone library"]
});

export default function ArtistsPage() {
  const structuredData = {
    "@context": "https://schema.org",
    "@type": "ItemList",
    name: "Artist Tone Profiles",
    itemListElement: seoArtists.map((artist, index) => ({
      "@type": "ListItem",
      position: index + 1,
      name: artist.name,
      url: toAbsoluteUrl(`/artists/${artist.slug}`)
    }))
  };

  return (
    <SiteShell>
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(structuredData) }} />

      <section className="section py-14">
        <div className="mx-auto max-w-5xl text-center">
          <h1 className="text-4xl font-bold tracking-normal text-ink sm:text-5xl">Artist Tone Profiles</h1>
          <p className="mx-auto mt-4 max-w-3xl text-lg leading-8 text-slate-600">
            Explore artist-driven tone references and jump into song-level profiles built for practical adaptation.
          </p>
        </div>

        <div className="mx-auto mt-10 grid max-w-6xl gap-4 md:grid-cols-2 lg:grid-cols-3">
          {seoArtists.map((artist) => (
            <article key={artist.slug} className="compact-card p-5">
              <p className="text-xs font-bold uppercase tracking-[0.14em] text-slate-400">{artist.mode}</p>
              <h2 className="mt-2 text-2xl font-bold text-ink">{artist.name}</h2>
              <p className="mt-3 text-sm text-slate-600">{artist.songs.length} public tone profile{artist.songs.length === 1 ? "" : "s"}</p>
              <p className="mt-2 text-sm text-slate-600">Featured: {artist.songs[0]?.song || "-"}</p>
              <Link href={`/artists/${artist.slug}`} className="button-secondary mt-5 min-h-10 justify-center">
                View Artist Profile
              </Link>
            </article>
          ))}
        </div>
      </section>
    </SiteShell>
  );
}
