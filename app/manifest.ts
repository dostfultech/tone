import type { MetadataRoute } from "next";
import { brand } from "@/lib/brand";

export default function manifest(): MetadataRoute.Manifest {
  return {
    name: `${brand.appName} Guitar Tone Matching`,
    short_name: brand.appName,
    description: "AI-assisted guitar and bass tone matching with gear-aware settings.",
    start_url: "/",
    display: "standalone",
    background_color: "#f8fafc",
    theme_color: "#0f172a",
    orientation: "portrait",
    icons: [
      {
        src: "/favicon-192.png",
        sizes: "192x192",
        type: "image/png"
      },
      {
        src: "/favicon-512.png",
        sizes: "512x512",
        type: "image/png",
        purpose: "any"
      }
    ]
  };
}
