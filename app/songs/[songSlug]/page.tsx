import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { SiteShell } from "@/components/site-shell";
import { buildPageMetadata, toAbsoluteUrl } from "@/lib/seo";
import { getSeoSongBySlug, seoSongs } from "@/lib/seo-content";

type SongDetailPageProps = {
  params: Promise<{ songSlug: string }>;
};

export function generateStaticParams() {
  return seoSongs.map((song) => ({ songSlug: song.slug }));
}

export async function generateMetadata({ params }: SongDetailPageProps): Promise<Metadata> {
  const { songSlug } = await params;
  const song = getSeoSongBySlug(songSlug);

  if (!song) {
    return buildPageMetadata({
      title: "Song Not Found",
      description: "The requested song tone profile could not be found.",
      path: `/songs/${songSlug}`,
      noIndex: true
    });
  }

  return buildPageMetadata({
    title: `${song.song} Tone Profile`,
    description: `Reference tone profile for ${song.song} by ${song.artist}, including part-specific adaptation context.`,
    path: `/songs/${song.slug}`
  });
}

export default async function SongDetailPage({ params }: SongDetailPageProps) {
  const { songSlug } = await params;
  const song = getSeoSongBySlug(songSlug);

  if (!song) {
    notFound();
  }

  const related = seoSongs.filter((item) => item.artistSlug === song.artistSlug && item.slug !== song.slug).slice(0, 6);
  const structuredData = {
    "@context": "https://schema.org",
    "@type": "MusicComposition",
    name: song.song,
    composer: {
      "@type": "Person",
      name: song.artist
    },
    url: toAbsoluteUrl(`/songs/${song.slug}`),
    inAlbum: song.album
  };

  return (
    <SiteShell>
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(structuredData) }} />

      <section className="section py-14">
        <Link href="/songs" className="text-sm font-semibold text-ocean">Back to songs</Link>

        <div className="theme-panel mt-5 p-8">
          <p className="text-xs font-bold uppercase tracking-[0.16em] text-slate-400">{song.mode} tone reference</p>
          <h1 className="mt-3 text-4xl font-bold tracking-normal text-ink sm:text-5xl">{song.song}</h1>
          <p className="mt-2 text-xl text-slate-500">{song.artist}</p>

          <div className="mt-7 grid gap-4 md:grid-cols-3">
            <InfoCard label="Target Part" value={song.part} />
            <InfoCard label="Album" value={song.album} />
            <InfoCard label="Duration" value={song.duration} />
          </div>

          <div className="mt-8 flex flex-wrap gap-3">
            <Link href={`/artists/${song.artistSlug}`} className="button-secondary min-h-10 px-4">View Artist Page</Link>
            <Link href="/app" className="button-primary min-h-10 px-4">Adapt This Tone In App</Link>
          </div>
        </div>

        {related.length ? (
          <div className="mt-10">
            <h2 className="text-2xl font-bold text-ink">More from {song.artist}</h2>
            <div className="mt-4 grid gap-3 md:grid-cols-2">
              {related.map((item) => (
                <Link key={item.slug} href={`/songs/${item.slug}`} className="compact-card p-4 transition hover:border-ocean/30">
                  <div className="text-lg font-bold text-ink">{item.song}</div>
                  <div className="mt-1 text-sm text-slate-600">Part: {item.part}</div>
                </Link>
              ))}
            </div>
          </div>
        ) : null}
      </section>
    </SiteShell>
  );
}

function InfoCard({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-lg border border-neutral-200 bg-white p-4">
      <p className="text-xs font-bold uppercase tracking-[0.14em] text-slate-400">{label}</p>
      <p className="mt-2 text-base font-semibold text-ink">{value}</p>
    </div>
  );
}
