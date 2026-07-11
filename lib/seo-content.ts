import { songs, type SongItem } from "@/lib/mock-data";
import { slugify } from "@/lib/utils";

export type SeoSong = SongItem & {
  slug: string;
  artistSlug: string;
};

export type SeoArtist = {
  name: string;
  slug: string;
  songs: SeoSong[];
  mode: "guitar" | "bass" | "mixed";
};

export const seoSongs: SeoSong[] = songs.map((song) => ({
  ...song,
  slug: slugify(`${song.song}-${song.artist}`),
  artistSlug: slugify(song.artist)
}));

export const seoArtists: SeoArtist[] = buildSeoArtists(seoSongs);

export function getSeoSongBySlug(slug: string) {
  return seoSongs.find((song) => song.slug === slug) || null;
}

export function getSeoArtistBySlug(slug: string) {
  return seoArtists.find((artist) => artist.slug === slug) || null;
}

function buildSeoArtists(songList: SeoSong[]): SeoArtist[] {
  const artistMap = new Map<string, SeoArtist>();

  songList.forEach((song) => {
    const existing = artistMap.get(song.artistSlug);

    if (existing) {
      existing.songs.push(song);
      if (existing.mode !== song.mode) {
        existing.mode = "mixed";
      }
      return;
    }

    artistMap.set(song.artistSlug, {
      name: song.artist,
      slug: song.artistSlug,
      songs: [song],
      mode: song.mode
    });
  });

  return Array.from(artistMap.values()).sort((left, right) => left.name.localeCompare(right.name));
}
