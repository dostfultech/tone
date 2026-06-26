"use client";

import Image from "next/image";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useEffect, useState } from "react";
import {
  BarChart3,
  Database,
  Guitar,
  Library,
  LogIn,
  LogOut,
  Menu,
  MessageSquare,
  Music2,
  Settings,
  SlidersHorizontal,
  Sparkles,
  UserCircle,
  Wrench,
  X
} from "lucide-react";
import { brand } from "@/lib/brand";
import { createSupabaseBrowserClient } from "@/lib/supabase/browser";
import { cn } from "@/lib/utils";

const collectionNav = [
  { href: "/library", label: "Library", icon: Library },
  { href: "/gear", label: "My Gear", icon: SlidersHorizontal }
];

const discoveryNav = [
  { href: "/app", label: "Match Tones", icon: Music2 },
  { href: "/community", label: "Tone Database", icon: Database }
];

const accountNav = [
  { href: "/account", label: "Settings", icon: Settings },
  { href: "/plans", label: "Plans", icon: BarChart3 }
];

const feedbackNav = [
  { href: "/contact?kind=feedback", label: "Send Feedback", icon: MessageSquare },
  { href: "/contact?kind=gear", label: "Request Gear", icon: Wrench }
];

export function AppShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const [open, setOpen] = useState(false);
  const [email, setEmail] = useState("");
  const [name, setName] = useState("");

  useEffect(() => {
    const supabase = createSupabaseBrowserClient();
    if (!supabase) return;

    supabase.auth.getUser().then(({ data }) => {
      const user = data.user;
      setEmail(user?.email || "");
      setName(user?.user_metadata?.full_name || user?.email?.split("@")[0] || "");
    });
  }, []);

  async function logout() {
    const supabase = createSupabaseBrowserClient();
    await supabase?.auth.signOut();
    window.location.href = "/login";
  }

  return (
    <div className="app-gradient min-h-screen text-ink">
      <button
        type="button"
        aria-label={open ? "Close navigation" : "Open navigation"}
        className="fixed left-5 top-5 z-[70] grid h-14 w-14 place-items-center rounded-lg border border-white/80 bg-white/90 text-ink shadow-[0_18px_45px_rgba(95,141,247,0.22)] backdrop-blur transition hover:-translate-y-0.5 hover:border-ocean hover:shadow-2xl lg:hidden"
        onClick={() => setOpen((value) => !value)}
      >
        {open ? <X className="h-6 w-6" /> : <Menu className="h-6 w-6" />}
      </button>

      <div
        className={cn(
          "fixed inset-0 z-[60] bg-ink/35 backdrop-blur-[4px] transition-opacity lg:hidden",
          open ? "pointer-events-auto opacity-100" : "pointer-events-none opacity-0"
        )}
        onClick={() => setOpen(false)}
      />

      <aside
        className={cn(
          "theme-blue-panel fixed inset-y-0 left-0 z-[65] flex w-[322px] max-w-[88vw] flex-col border-r border-white/80 shadow-2xl transition-transform duration-300 lg:translate-x-0",
          open ? "translate-x-0" : "-translate-x-full"
        )}
      >
        <div className="flex h-24 items-center justify-between border-b border-white/70 px-8">
          <Link href="/app" className="flex items-center gap-4" onClick={() => setOpen(false)}>
            <Image src="/tonefex-logo.svg" alt={brand.appName} width={48} height={48} className="rounded-lg" />
            <div>
              <div className="text-xl font-bold text-ink">Tone<span className="lime-highlight ml-0.5">fex</span></div>
              <div className="text-xs font-semibold uppercase tracking-[0.16em] text-neutral-400">Tone workspace</div>
            </div>
          </Link>
          <button type="button" className="button-quiet px-2" aria-label="Close menu" onClick={() => setOpen(false)}>
            <X className="h-5 w-5" />
          </button>
        </div>

        <div className="custom-scrollbar flex-1 overflow-y-auto px-7 py-8">
          <div className="mb-8 flex items-center gap-4 border-b border-white/70 pb-7">
            <div className="grid h-14 w-14 shrink-0 place-items-center rounded-lg border border-white bg-ink text-xl font-bold text-white shadow-md">
              {(name || email || "G").slice(0, 1).toUpperCase()}
            </div>
            <div className="min-w-0">
              <div className="truncate text-lg font-bold">{name || "Account"}</div>
              <div className="truncate text-sm text-neutral-500">{email || "Sign in to sync your tones"}</div>
            </div>
          </div>

          <NavSection title="My Collection" items={collectionNav} pathname={pathname} close={() => setOpen(false)} />
          <NavSection title="Discover" items={discoveryNav} pathname={pathname} close={() => setOpen(false)} />
          <NavSection title="Account" items={accountNav} pathname={pathname} close={() => setOpen(false)} />
          <NavSection title="Feedback" items={feedbackNav} pathname={pathname} close={() => setOpen(false)} />
        </div>

        <div className="border-t border-white/70 p-7">
          {email ? (
            <button type="button" className="button-quiet w-full justify-start text-base" onClick={logout}>
              <LogOut className="h-5 w-5" />
              Logout
            </button>
          ) : (
            <Link href="/login" className="button-secondary w-full justify-start" onClick={() => setOpen(false)}>
              <LogIn className="h-5 w-5" />
              Login
            </Link>
          )}
          <div className="mt-5 rounded-lg border border-white/80 bg-white/75 p-4 shadow-sm">
            <div className="flex items-center gap-2 text-sm font-bold text-ink">
              <Sparkles className="h-4 w-4" />
              Subscription access
            </div>
            <p className="mt-2 text-xs leading-5 text-slate-600">Your active plan unlocks the tone features, saved tones, presets, and gated access available for that tier.</p>
          </div>
        </div>
      </aside>

      <main className="min-h-screen lg:pl-[322px]">
        {children}
        <AppFooter />
      </main>
    </div>
  );
}

function AppFooter() {
  const year = new Date().getFullYear();

  return (
    <footer className="mx-auto max-w-[1840px] px-4 pb-12 sm:px-6 lg:px-8">
      <div className="theme-panel border-t border-white/80 bg-white/75 p-8 md:p-10">
        <div className="grid gap-10 md:grid-cols-[1.15fr_0.75fr_1fr]">
          <div>
            <Link href="/app" className="inline-flex items-center gap-4">
              <Image src="/tonefex-logo.svg" alt={brand.appName} width={44} height={44} className="rounded-lg" />
              <span className="text-xl font-bold">
                Tone<span className="lime-highlight ml-0.5">fex</span>
              </span>
            </Link>
            <p className="mt-5 max-w-sm text-base leading-7 text-slate-600">Gear-matched guitar and bass tone settings for musicians worldwide.</p>
          </div>

          <div>
            <h2 className="text-lg font-bold">Quick Links</h2>
            <nav className="mt-5 grid gap-3 text-base text-slate-600">
              <Link href="/">Home</Link>
              <Link href="/app">App</Link>
              <Link href="/plans">Plans</Link>
              <Link href="/account">Account</Link>
            </nav>
          </div>

          <div>
            <h2 className="text-lg font-bold">Support</h2>
            <div className="mt-5 grid gap-3 text-base text-slate-600">
              <p>Need help or have questions?</p>
              <a className="font-semibold text-ocean" href={`mailto:${brand.supportEmail}`}>
                {brand.supportEmail}
              </a>
              <Link href="/privacy">Privacy Policy</Link>
              <Link href="/terms">Terms of Use</Link>
            </div>
          </div>
        </div>
        <div className="mt-10 border-t border-blue-100 pt-6 text-center text-sm text-slate-500">
          © {year} {brand.appName}. All rights reserved.
        </div>
      </div>
    </footer>
  );
}

function NavSection({
  title,
  items,
  pathname,
  close
}: {
  title: string;
  items: Array<{ href: string; label: string; icon: React.ComponentType<{ className?: string }> }>;
  pathname: string;
  close: () => void;
}) {
  return (
    <div className="mb-8">
      <div className="mb-3 px-3 text-xs font-bold uppercase tracking-[0.16em] text-slate-400">{title}</div>
      <nav className="grid gap-1">
        {items.map((item) => {
          const Icon = item.icon;
          const baseHref = item.href.split("?")[0];
          const active = pathname === baseHref;
          return (
            <Link
              key={item.href}
              href={item.href}
              className={cn(
                "flex min-h-12 items-center gap-4 rounded-lg px-3 text-base font-semibold transition",
                active ? "bg-ink text-white shadow-lg shadow-slate-900/10" : "text-slate-700 hover:bg-white/70 hover:text-ink"
              )}
              onClick={close}
            >
              <Icon className="h-5 w-5" />
              {item.label}
            </Link>
          );
        })}
      </nav>
    </div>
  );
}
