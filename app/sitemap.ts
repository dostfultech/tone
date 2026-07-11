import type { MetadataRoute } from "next";
import { seoArtists, seoSongs } from "@/lib/seo-content";
import { toAbsoluteUrl } from "@/lib/seo";

export default function sitemap(): MetadataRoute.Sitemap {
  const now = new Date();

  const staticEntries: MetadataRoute.Sitemap = [
    { url: toAbsoluteUrl("/"), lastModified: now, changeFrequency: "daily", priority: 1 },
    { url: toAbsoluteUrl("/plans"), lastModified: now, changeFrequency: "weekly", priority: 0.9 },
    { url: toAbsoluteUrl("/songs"), lastModified: now, changeFrequency: "daily", priority: 0.9 },
    { url: toAbsoluteUrl("/artists"), lastModified: now, changeFrequency: "daily", priority: 0.9 },
    { url: toAbsoluteUrl("/gear"), lastModified: now, changeFrequency: "weekly", priority: 0.85 },
    { url: toAbsoluteUrl("/community"), lastModified: now, changeFrequency: "daily", priority: 0.85 },
    { url: toAbsoluteUrl("/status"), lastModified: now, changeFrequency: "weekly", priority: 0.5 },
    { url: toAbsoluteUrl("/privacy"), lastModified: now, changeFrequency: "yearly", priority: 0.3 },
    { url: toAbsoluteUrl("/terms"), lastModified: now, changeFrequency: "yearly", priority: 0.3 }
  ];

  const songEntries: MetadataRoute.Sitemap = seoSongs.map((song) => ({
    url: toAbsoluteUrl(`/songs/${song.slug}`),
    lastModified: now,
    changeFrequency: "weekly",
    priority: 0.8
  }));

  const artistEntries: MetadataRoute.Sitemap = seoArtists.map((artist) => ({
    url: toAbsoluteUrl(`/artists/${artist.slug}`),
    lastModified: now,
    changeFrequency: "weekly",
    priority: 0.75
  }));

  return [...staticEntries, ...songEntries, ...artistEntries];
}
