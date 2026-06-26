import type { Metadata, Viewport } from "next";
import { Analytics } from "@vercel/analytics/react";
import { brand } from "@/lib/brand";
import "./globals.css";

export const metadata: Metadata = {
  title: {
    default: `${brand.appName} - Guitar Tone Matching`,
    template: `%s | ${brand.appName}`
  },
  description:
    "AI-assisted guitar and bass tone matching for players who want practical rig settings fast.",
  openGraph: {
    title: brand.appName,
    description: "Gear-aware tone matching flows built with Next.js App Router.",
    type: "website"
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
      <body>
        {children}
        <Analytics />
      </body>
    </html>
  );
}
