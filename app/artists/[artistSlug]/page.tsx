import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { SiteShell } from "@/components/site-shell";
import { buildPageMetadata, toAbsoluteUrl } from "@/lib/seo";
import { getSeoArtistBySlug, seoArtists } from "@/lib/seo-content";

type ArtistDetailPageProps = {
  params: Promise<{ artistSlug: string }>;
};

export function generateStaticParams() {
  return seoArtists.map((artist) => ({ artistSlug: artist.slug }));
}

export async function generateMetadata({ params }: ArtistDetailPageProps): Promise<Metadata> {
  const { artistSlug } = await params;
  const artist = getSeoArtistBySlug(artistSlug);

  if (!artist) {
    return buildPageMetadata({
      title: "Artist Not Found",
      description: "The requested artist profile was not found.",
      path: `/artists/${artistSlug}`,
      noIndex: true
    });
  }

  return buildPageMetadata({
    title: `${artist.name} Tone Profiles`,
    description: `Public tone references inspired by ${artist.name}, with part-focused song profile links.`,
    path: `/artists/${artist.slug}`
  });
}

export default async function ArtistDetailPage({ params }: ArtistDetailPageProps) {
  const { artistSlug } = await params;
  const artist = getSeoArtistBySlug(artistSlug);

  if (!artist) {
    notFound();
  }

  const structuredData = {
    "@context": "https://schema.org",
    "@type": "MusicGroup",
    name: artist.name,
    url: toAbsoluteUrl(`/artists/${artist.slug}`)
  };

  return (
    <SiteShell>
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(structuredData) }} />

      <section className="section py-14">
        <Link href="/artists" className="text-sm font-semibold text-ocean">Back to artists</Link>

        <div className="theme-panel mt-5 p-8">
          <p className="text-xs font-bold uppercase tracking-[0.16em] text-slate-400">artist tone profile</p>
          <h1 className="mt-3 text-4xl font-bold tracking-normal text-ink sm:text-5xl">{artist.name}</h1>
          <p className="mt-3 text-lg leading-8 text-slate-600">
            {artist.songs.length} song profile{artist.songs.length === 1 ? "" : "s"} currently mapped for this artist.
          </p>
        </div>

        <div className="mx-auto mt-8 grid max-w-6xl gap-4 md:grid-cols-2 lg:grid-cols-3">
          {artist.songs.map((song) => (
            <article key={song.slug} className="compact-card p-5">
              <p className="text-xs font-bold uppercase tracking-[0.14em] text-slate-400">{song.mode}</p>
              <h2 className="mt-2 text-xl font-bold text-ink">{song.song}</h2>
              <p className="mt-2 text-sm text-slate-600">Part: {song.part}</p>
              <p className="mt-1 text-sm text-slate-600">Album: {song.album}</p>
              <Link href={`/songs/${song.slug}`} className="button-secondary mt-5 min-h-10 justify-center">
                Open Song Profile
              </Link>
            </article>
          ))}
        </div>
      </section>
    </SiteShell>
  );
}
