import type { Metadata } from "next";
import { brand } from "@/lib/brand";
import { getSiteUrl } from "@/lib/env";

type BuildPageMetadataOptions = {
  title: string;
  description?: string;
  path?: string;
  keywords?: string[];
  noIndex?: boolean;
};

const defaultDescription =
  "AI-assisted guitar and bass tone matching with practical, gear-aware settings for real rigs.";

export function getMetadataBase() {
  return new URL(getSiteUrl());
}

export function toAbsoluteUrl(path = "/") {
  const normalizedPath = normalizePath(path);
  return new URL(normalizedPath, getSiteUrl()).toString();
}

export function buildPageMetadata({
  title,
  description = defaultDescription,
  path = "/",
  keywords,
  noIndex = false
}: BuildPageMetadataOptions): Metadata {
  const normalizedPath = normalizePath(path);
  const ogImage = "/og-image.svg";

  return {
    title,
    description,
    keywords,
    alternates: {
      canonical: normalizedPath
    },
    openGraph: {
      title: `${title} | ${brand.appName}`,
      description,
      url: normalizedPath,
      siteName: brand.appName,
      type: "website",
      images: [
        {
          url: ogImage,
          width: 1200,
          height: 630,
          alt: `${brand.appName} preview`
        }
      ]
    },
    twitter: {
      card: "summary_large_image",
      title: `${title} | ${brand.appName}`,
      description,
      images: [ogImage]
    },
    robots: noIndex
      ? {
          index: false,
          follow: false,
          nocache: true,
          googleBot: {
            index: false,
            follow: false,
            noimageindex: true
          }
        }
      : undefined
  };
}

function normalizePath(path: string) {
  if (!path || path === "/") {
    return "/";
  }

  return `/${path.replace(/^\/+/, "").replace(/\/+$/, "")}`;
}
