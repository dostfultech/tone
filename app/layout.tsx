import type { Metadata, Viewport } from "next";
import Script from "next/script";
import { Analytics } from "@vercel/analytics/react";
import { SpeedInsights } from "@vercel/speed-insights/next";
import { brand } from "@/lib/brand";
import { getMetadataBase } from "@/lib/seo";
import "./globals.css";

const defaultDescription =
  "AI-assisted guitar and bass tone matching for players who want practical rig settings fast.";
const GOOGLE_TAG_ID = "G-C8PQY1H9L8";

export const metadata: Metadata = {
  metadataBase: getMetadataBase(),
  applicationName: brand.appName,
  title: {
    default: `${brand.appName} - Guitar Tone Matching`,
    template: `%s | ${brand.appName}`
  },
  description: defaultDescription,
  alternates: {
    canonical: "/"
  },
  manifest: "/manifest.webmanifest",
  icons: {
    icon: [
      { url: "/icon.svg", type: "image/svg+xml" },
      { url: "/tonefex-logo.svg", type: "image/svg+xml" }
    ],
    apple: [{ url: "/apple-icon.svg", type: "image/svg+xml" }],
    shortcut: ["/icon.svg"]
  },
  openGraph: {
    title: `${brand.appName} - Guitar Tone Matching`,
    description: defaultDescription,
    url: "/",
    siteName: brand.appName,
    locale: "en_US",
    type: "website",
    images: [
      {
        url: "/og-image.svg",
        width: 1200,
        height: 630,
        alt: `${brand.appName} preview`
      }
    ]
  },
  twitter: {
    card: "summary_large_image",
    title: `${brand.appName} - Guitar Tone Matching`,
    description: defaultDescription,
    images: ["/og-image.svg"]
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      "max-image-preview": "large",
      "max-snippet": -1,
      "max-video-preview": -1
    }
  },
  verification: {
    google: process.env.GOOGLE_SITE_VERIFICATION || undefined
  }
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  maximumScale: 1,
  viewportFit: "cover"
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <head>
        <Script
          src={`https://www.googletagmanager.com/gtag/js?id=${GOOGLE_TAG_ID}`}
          strategy="afterInteractive"
        />
        <Script id="google-gtag" strategy="afterInteractive">
          {`
            window.dataLayer = window.dataLayer || [];
            function gtag(){dataLayer.push(arguments);}
            gtag('js', new Date());
            gtag('config', '${GOOGLE_TAG_ID}');
          `}
        </Script>
      </head>
      <body>
        {children}
        <Analytics />
        <SpeedInsights />
      </body>
    </html>
  );
}
