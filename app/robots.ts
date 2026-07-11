import type { MetadataRoute } from "next";
import { getSiteUrl } from "@/lib/env";

export default function robots(): MetadataRoute.Robots {
  const siteUrl = getSiteUrl();

  return {
    rules: [
      {
        userAgent: "*",
        allow: "/",
        disallow: ["/app", "/account", "/library", "/checkout", "/api", "/auth"]
      }
    ],
    sitemap: `${siteUrl}/sitemap.xml`,
    host: siteUrl
  };
}
