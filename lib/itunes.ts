import { brand } from "@/lib/brand";

const CACHE_TTL_MS = 10 * 60 * 1000;

type ItunesTrack = {
  trackId?: number;
  trackName?: string;
  artistName?: string;
  collectionName?: string;
  artworkUrl100?: string;
};

const artworkCache = new Map<string, { expiresAt: number; url: string | null }>();

export async function lookupSongArtwork(song: string, artist: string): Promise<string | null> {
  const key = `${song}|${artist}`.toLowerCase();
  const cached = artworkCache.get(key);
  if (cached && cached.expiresAt > Date.now()) {
    return cached.url;
  }

  const term = `${song} ${artist}`.trim();
  const params = new URLSearchParams({ term, media: "music", entity: "song", limit: "10" });
  const payload = await fetchItunesJson(`https://itunes.apple.com/search?${params.toString()}`);
  const normalizedArtist = artist.toLowerCase();
  const track = (payload.results || []).find(
    (item) => item.artworkUrl100 && (item.artistName || "").toLowerCase().includes(normalizedArtist)
  );
  const url = track?.artworkUrl100 ? track.artworkUrl100.replace("100x100bb", "600x600bb") : null;

  artworkCache.set(key, { url, expiresAt: Date.now() + CACHE_TTL_MS });
  return url;
}

export async function lookupBatchArtwork(items: { song: string; artist: string }[]): Promise<Record<string, string | null>> {
  const results: Record<string, string | null> = {};
  const unique = new Map<string, { song: string; artist: string }>();

  for (const item of items) {
    const key = `${item.song}|${item.artist}`.toLowerCase();
    if (!unique.has(key)) {
      unique.set(key, item);
    }
  }

  await Promise.all(
    Array.from(unique.entries()).map(async ([key, item]) => {
      results[key] = await lookupSongArtwork(item.song, item.artist);
    })
  );

  return results;
}

async function fetchItunesJson(url: string): Promise<{ results?: ItunesTrack[] }> {
  try {
    const response = await fetch(url, {
      cache: "no-store",
      headers: { "User-Agent": `${brand.appName}/1.0` }
    });
    if (!response.ok) return {};
    return (await response.json()) as { results?: ItunesTrack[] };
  } catch (error) {
    const cause = error instanceof Error ? (error as Error & { cause?: { code?: string } }).cause : undefined;
    const canUseInsecureFallback =
      cause?.code === "UNABLE_TO_VERIFY_LEAF_SIGNATURE" &&
      (process.env.NODE_ENV !== "production" || process.env.MUSIC_SEARCH_ALLOW_INSECURE_TLS === "true");

    if (!canUseInsecureFallback) return {};

    return fetchItunesJsonWithHttps(url);
  }
}

async function fetchItunesJsonWithHttps(url: string): Promise<{ results?: ItunesTrack[] }> {
  const https = await import("node:https");
  return new Promise((resolve) => {
    const request = https.get(
      url,
      { rejectUnauthorized: false, headers: { "User-Agent": `${brand.appName}/1.0` } },
      (response) => {
        if ((response.statusCode || 500) >= 400) {
          response.resume();
          resolve({});
          return;
        }
        const chunks: Buffer[] = [];
        response.on("data", (chunk: Buffer) => chunks.push(Buffer.from(chunk)));
        response.on("end", () => {
          try {
            resolve(JSON.parse(Buffer.concat(chunks).toString("utf8")) as { results?: ItunesTrack[] });
          } catch {
            resolve({});
          }
        });
      }
    );
    request.on("error", () => resolve({}));
  });
}
