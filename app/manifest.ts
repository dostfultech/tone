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
        src: "/icon.svg",
        sizes: "any",
        type: "image/svg+xml"
      },
      {
        src: "/apple-icon.svg",
        sizes: "180x180",
        type: "image/svg+xml",
        purpose: "any"
      }
    ]
  };
}
