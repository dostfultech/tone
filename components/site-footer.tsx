import Image from "next/image";
import Link from "next/link";
import { brand } from "@/lib/brand";

/**
 * Shared marketing footer. Used by the public SiteShell and also rendered at the
 * bottom of the in-app shell (Match Tone, Library, etc.) so every page carries it.
 */
export function SiteFooter({ isAuthenticated = false }: { isAuthenticated?: boolean }) {
  return (
    <footer className="border-t border-neutral-200 bg-white">
      <div className="section grid gap-8 py-10 md:grid-cols-[1.4fr_1fr_1fr]">
        <div>
          <div className="mb-3 flex items-center gap-3 font-semibold">
            <Image src="/tonefex-logo.svg" alt={brand.appName} width={34} height={34} />
            {brand.appName}
          </div>
          <p className="max-w-md text-sm leading-6 text-neutral-600">
            Gear-matched guitar and bass settings for players who want a practical starting point fast.
          </p>
        </div>
        <div>
          <h3 className="mb-3 text-sm font-semibold">Quick Links</h3>
          <div className="grid gap-2 text-sm text-neutral-600">
            <Link href="/app">App</Link>
            <Link href="/songs">Songs</Link>
            <Link href="/artists">Artists</Link>
            <Link href="/plans">Plans</Link>
            {isAuthenticated ? <Link href="/account">Account</Link> : <Link href="/login">Login</Link>}
          </div>
        </div>
        <div>
          <h3 className="mb-3 text-sm font-semibold">Support</h3>
          <div className="grid gap-2 text-sm text-neutral-600">
            <Link href="/contact">Contact</Link>
            <Link href="/privacy">Privacy Policy</Link>
            <Link href="/terms">Terms of Use</Link>
            <span>{brand.supportEmail}</span>
          </div>
        </div>
      </div>
      <div className="border-t border-neutral-200 px-4 py-4 text-center text-xs text-neutral-500">
        Gear-matched tone settings for guitar and bass players.
      </div>
    </footer>
  );
}
