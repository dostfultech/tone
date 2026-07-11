import type { Metadata } from "next";
import Link from "next/link";
import { SiteShell } from "@/components/site-shell";
import { buildPageMetadata, toAbsoluteUrl } from "@/lib/seo";
import { seoSongs } from "@/lib/seo-content";

type SongsPageProps = {
  searchParams?: Promise<Record<string, string | string[] | undefined>>;
};

export const metadata: Metadata = buildPageMetadata({
  title: "Song Tone Profiles",
  description: "Explore song-specific guitar and bass tone references and adapt them to your own rig.",
  path: "/songs",
  keywords: ["song guitar tone", "tone profiles", "guitar song settings", "bass tone songs"]
});

export default async function SongsPage({ searchParams }: SongsPageProps) {
  const params = await searchParams;
  const query = stringParam(params?.q).trim().toLowerCase();
  const songList = query
    ? seoSongs.filter((song) => `${song.song} ${song.artist} ${song.part}`.toLowerCase().includes(query))
    : seoSongs;
  const structuredData = {
    "@context": "https://schema.org",
    "@type": "ItemList",
    name: "Song Tone Profiles",
    itemListElement: songList.slice(0, 30).map((song, index) => ({
      "@type": "ListItem",
      position: index + 1,
      name: `${song.song} by ${song.artist}`,
      url: toAbsoluteUrl(`/songs/${song.slug}`)
    }))
  };

  return (
    <SiteShell>
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(structuredData) }} />

      <section className="section py-14">
        <div className="mx-auto max-w-5xl text-center">
          <h1 className="text-4xl font-bold tracking-normal text-ink sm:text-5xl">Song Tone Profiles</h1>
          <p className="mx-auto mt-4 max-w-3xl text-lg leading-8 text-slate-600">
            Browse public song profiles and use them as starting points for your own guitar and bass setup.
          </p>
        </div>

        <div className="mx-auto mt-8 max-w-4xl">
          <form method="get" className="compact-card flex flex-col gap-3 p-4 sm:flex-row sm:items-center">
            <label htmlFor="song-search" className="text-sm font-semibold text-slate-600">Search songs or artists</label>
            <input
              id="song-search"
              name="q"
              defaultValue={stringParam(params?.q)}
              placeholder="Try Metallica, Pink Floyd, solo, riff..."
              className="field flex-1"
            />
            <button type="submit" className="button-primary min-h-11 px-4">Search</button>
          </form>
        </div>

        <div className="mx-auto mt-8 grid max-w-6xl gap-4 md:grid-cols-2 lg:grid-cols-3">
          {songList.map((song) => (
            <article key={song.id} className="compact-card p-5">
              <p className="text-xs font-bold uppercase tracking-[0.14em] text-slate-400">{song.mode}</p>
              <h2 className="mt-2 text-xl font-bold text-ink">{song.song}</h2>
              <p className="mt-1 text-sm font-semibold text-slate-500">{song.artist}</p>
              <p className="mt-3 text-sm text-slate-600">Part: {song.part}</p>
              <p className="mt-1 text-sm text-slate-600">Album: {song.album}</p>
              <Link href={`/songs/${song.slug}`} className="button-secondary mt-5 min-h-10 justify-center">
                View Tone Profile
              </Link>
            </article>
          ))}
        </div>

        {!songList.length ? (
          <div className="mx-auto mt-8 max-w-3xl rounded-lg border border-neutral-200 bg-white p-6 text-center text-sm text-slate-600">
            No songs matched your search yet. Try a broader artist name or visit the artists page.
            <div className="mt-4">
              <Link href="/artists" className="button-primary min-h-10 px-4">Browse Artists</Link>
            </div>
          </div>
        ) : null}
      </section>
    </SiteShell>
  );
}

function stringParam(value: string | string[] | undefined) {
  return Array.isArray(value) ? value[0] || "" : value || "";
}
