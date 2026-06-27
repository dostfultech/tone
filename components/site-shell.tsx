"use client";

import Link from "next/link";
import Image from "next/image";
import { useEffect, useState } from "react";
import { Menu, Music2, ShieldCheck, X } from "lucide-react";
import { brand } from "@/lib/brand";
import { createSupabaseBrowserClient } from "@/lib/supabase/browser";

export function SiteShell({ children }: { children: React.ReactNode }) {
  const [menuOpen, setMenuOpen] = useState(false);
  const [cookie, setCookie] = useState<string | null>(null);
  const [privacyBanner, setPrivacyBanner] = useState(false);
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  const nav = [
    { href: "/", label: "Home" },
    { href: "/app", label: isAuthenticated ? "Workspace" : "App" },
    { href: "/plans", label: "Plans" },
    ...(isAuthenticated ? [{ href: "/account", label: "Account" }] : [{ href: "/login", label: "Login" }])
  ];

  useEffect(() => {
    const storedCookie = localStorage.getItem(`${brand.storagePrefix}_cookie_consent`);
    setCookie(storedCookie);
    setPrivacyBanner(localStorage.getItem(`${brand.storagePrefix}_privacy_banner_2026_05_01`) !== "true");

    const supabase = createSupabaseBrowserClient();
    if (!supabase) {
      return;
    }

    supabase.auth.getUser().then(({ data }) => {
      setIsAuthenticated(Boolean(data.user));
    });

    const {
      data: { subscription }
    } = supabase.auth.onAuthStateChange((_event, session) => {
      setIsAuthenticated(Boolean(session?.user));
    });

    return () => subscription.unsubscribe();
  }, []);

  function decideCookie(value: "accepted" | "declined") {
    localStorage.setItem(`${brand.storagePrefix}_cookie_consent`, value);
    document.cookie = `${brand.storagePrefix}_cookie_consent=${value}; path=/; max-age=31536000; SameSite=Lax`;
    setCookie(value);
  }

  function dismissPrivacy() {
    localStorage.setItem(`${brand.storagePrefix}_privacy_banner_2026_05_01`, "true");
    setPrivacyBanner(false);
  }
  return (
    <div className="min-h-screen">
      {privacyBanner ? (
          <div className="relative z-40 bg-ink px-4 py-2 text-center text-sm font-medium text-white">
          <span className="inline-flex items-center gap-2">
            <ShieldCheck className="h-4 w-4" />
            Privacy policy updated for analytics, mobile attribution, and provider details.
            <Link href="/privacy" className="underline underline-offset-4">
              Review
            </Link>
          </span>
          <button
            aria-label="Dismiss privacy update banner"
            className="absolute right-3 top-1/2 -translate-y-1/2 rounded p-1 hover:bg-white/20"
            onClick={dismissPrivacy}
          >
            <X className="h-4 w-4" />
          </button>
        </div>
      ) : null}

      <header className="sticky top-0 z-30 border-b border-neutral-200 bg-white/90 backdrop-blur">
        <div className="section flex h-16 items-center justify-between">
          <Link href="/" className="flex items-center gap-3 font-semibold">
            <Image src="/tonefex-logo.svg" alt={brand.appName} width={34} height={34} priority />
            <span>{brand.appName}</span>
          </Link>

          <nav className="hidden items-center gap-1 md:flex">
            {nav.map((item) => (
              <Link key={item.href} href={item.href} className="button-quiet">
                {item.label}
              </Link>
            ))}
          </nav>

          <div className="hidden items-center gap-2 md:flex">
            <Link href="/plans" className="button-secondary">
              Plans
            </Link>
            <Link href={isAuthenticated ? "/app" : "/login?redirect=%2Fapp"} className="button-primary">
              <Music2 className="h-4 w-4" />
              Match Tone
            </Link>
          </div>

          <button
            aria-label="Open menu"
            className="button-secondary px-3 md:hidden"
            onClick={() => setMenuOpen(true)}
          >
            <Menu className="h-5 w-5" />
          </button>
        </div>
      </header>

      {menuOpen ? (
        <div className="fixed inset-0 z-50 md:hidden">
          <button aria-label="Close menu backdrop" className="absolute inset-0 bg-black/30" onClick={() => setMenuOpen(false)} />
          <div className="absolute right-0 top-0 h-full w-80 max-w-[88vw] border-l border-neutral-200 bg-white p-4 shadow-soft">
            <div className="mb-6 flex items-center justify-between">
              <span className="font-semibold">Menu</span>
              <button aria-label="Close menu" className="button-quiet px-2" onClick={() => setMenuOpen(false)}>
                <X className="h-5 w-5" />
              </button>
            </div>
            <div className="grid gap-2">
              {nav.map((item) => (
                <Link key={item.href} href={item.href} className="button-secondary justify-start" onClick={() => setMenuOpen(false)}>
                  {item.label}
                </Link>
              ))}
              <Link href="/app" className="button-primary mt-2" onClick={() => setMenuOpen(false)}>
                Start Matching
              </Link>
            </div>
          </div>
        </div>
      ) : null}

      <main>{children}</main>

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
          AI-assisted tone matching for guitar and bass players.
        </div>
      </footer>

      {cookie === null ? (
        <div className="fixed bottom-4 left-1/2 z-40 w-[calc(100%-2rem)] max-w-3xl -translate-x-1/2 rounded-lg border border-neutral-200 bg-white p-4 shadow-soft" role="region" aria-labelledby="cookie-consent-title">
          <div className="grid gap-3 md:grid-cols-[1fr_auto] md:items-center">
            <div>
              <h2 id="cookie-consent-title" className="text-sm font-semibold">
                Cookie preferences
              </h2>
              <p className="mt-1 text-sm text-neutral-600">
                {brand.appName} stores interface choices locally and uses consent-aware analytics hooks.
              </p>
            </div>
            <div className="flex gap-2">
              <button className="button-secondary" onClick={() => decideCookie("declined")}>
                Decline
              </button>
              <button className="button-primary" onClick={() => decideCookie("accepted")}>
                Accept
              </button>
            </div>
          </div>
        </div>
      ) : null}

    </div>
  );
}
