import Image from "next/image";
import Link from "next/link";
import { brand } from "@/lib/brand";

/**
 * Shared marketing footer. Used by the public SiteShell and also rendered at the
 * bottom of the in-app shell (Match Tone, Library, etc.) so every page carries it.
 */
export function SiteFooter({ isAuthenticated = false }: { isAuthenticated?: boolean }) {
  return (
    <footer className="border-t border-white/10 bg-[#08071a] text-white">
      <div className="section grid gap-8 py-10 md:grid-cols-[1.4fr_1fr_1fr]">
        <div>
          <div className="mb-3 flex items-center gap-3 font-semibold">
            <Image src="/tonefex-logo.svg" alt={brand.appName} width={34} height={34} />
            {brand.appName}
          </div>
          <p className="max-w-md text-sm leading-6 text-white/55">
            Search a song, get the settings for your rig. Hand-verified guitar and bass tones, translated to the gear you own.
          </p>
        </div>
        <div>
          <h3 className="mb-3 text-sm font-semibold">Explore</h3>
          <div className="grid gap-2 text-sm text-white/55">
            <Link className="transition hover:text-white" href="/app">Dial In</Link>
            <Link className="transition hover:text-white" href="/songs">Songs</Link>
            <Link className="transition hover:text-white" href="/artists">Artists</Link>
            <Link className="transition hover:text-white" href="/plans">Plans</Link>
            {isAuthenticated ? <Link className="transition hover:text-white" href="/account">Account</Link> : <Link className="transition hover:text-white" href="/login">Login</Link>}
          </div>
        </div>
        <div>
          <h3 className="mb-3 text-sm font-semibold">Support</h3>
          <div className="grid gap-2 text-sm text-white/55">
            <Link className="transition hover:text-white" href="/contact">Contact</Link>
            <Link className="transition hover:text-white" href="/privacy">Privacy Policy</Link>
            <Link className="transition hover:text-white" href="/terms">Terms of Use</Link>
            <span>{brand.supportEmail}</span>
          </div>
        </div>
      </div>
      <div className="border-t border-white/10 px-4 py-4 text-center text-xs text-white/40">
        Sound like any song, on your own amp. &copy; {new Date().getFullYear()} {brand.appName}.
      </div>
    </footer>
  );
}
