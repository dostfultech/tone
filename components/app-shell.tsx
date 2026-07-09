"use client";

import Image from "next/image";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useEffect, useState } from "react";
import {
  CreditCard,
  Database,
  Library,
  LogIn,
  LogOut,
  Menu,
  MessageSquare,
  Music2,
  Settings,
  SlidersHorizontal,
  Wrench,
  X
} from "lucide-react";
import { brand } from "@/lib/brand";
import { FreeAdaptationSummary } from "@/components/free-adaptation-summary";
import {
  loadClientSubscriptionSnapshot,
  type ClientSubscriptionSnapshot
} from "@/lib/subscription-client";
import { getAdaptationSummaryProps } from "@/lib/subscription-display";
import { addSubscriptionRefreshListener } from "@/lib/subscription-events";
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
  { href: "/plans", label: "Plans", icon: CreditCard }
];

const feedbackNav = [
  { href: "/feedback", label: "Send Feedback", icon: MessageSquare },
  { href: "/contact?kind=gear", label: "Request Gear", icon: Wrench }
];

export function AppShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const [open, setOpen] = useState(true);
  const [snapshot, setSnapshot] = useState<ClientSubscriptionSnapshot | null>(null);
  const closeForNavigation = () => {
    if (typeof window !== "undefined" && window.innerWidth < 1024) {
      setOpen(false);
    }
  };

  useEffect(() => {
    if (pathname === "/app") {
      setOpen(false);
      localStorage.setItem(`${brand.storagePrefix}_sidebar_open`, "0");
      return;
    }

    const saved = localStorage.getItem(`${brand.storagePrefix}_sidebar_open`);
    if (saved === "0") {
      setOpen(false);
      return;
    }

    if (saved === "1") {
      setOpen(true);
      return;
    }

    setOpen(window.innerWidth >= 1024);
  }, [pathname]);

  useEffect(() => {
    localStorage.setItem(`${brand.storagePrefix}_sidebar_open`, open ? "1" : "0");
  }, [open]);

  useEffect(() => {
    const supabase = createSupabaseBrowserClient();
    if (!supabase) {
      return;
    }
    const client = supabase;

    async function refreshShell() {
      setSnapshot(await loadClientSubscriptionSnapshot(client));
    }

    void refreshShell();

    const {
      data: { subscription }
    } = client.auth.onAuthStateChange(() => {
      refreshShell().catch(() => undefined);
    });

    const removeRefreshListener = addSubscriptionRefreshListener(() => {
      refreshShell().catch(() => undefined);
    });

    return () => {
      subscription.unsubscribe();
      removeRefreshListener();
    };
  }, []);

  async function logout() {
    const supabase = createSupabaseBrowserClient();
    await supabase?.auth.signOut();
    window.location.href = "/login";
  }

  function navigate() {
    closeForNavigation();
  }

  const email = snapshot?.user?.email || "";
  const name = snapshot?.user?.user_metadata?.full_name || snapshot?.user?.email?.split("@")[0] || "";

  return (
    <div className="app-gradient min-h-screen text-ink">
      <button
        type="button"
        aria-label={open ? "Close navigation" : "Open navigation"}
        className={cn(
          "fixed left-5 top-5 z-[70] grid h-14 w-14 place-items-center rounded-lg border border-white/80 bg-white/95 text-ink shadow-[0_18px_45px_rgba(95,141,247,0.22)] transition-colors hover:border-ocean hover:shadow-2xl",
          open ? "pointer-events-none opacity-0" : "pointer-events-auto opacity-100"
        )}
        onClick={() => setOpen((value) => !value)}
      >
        {open ? <X className="h-6 w-6" /> : <Menu className="h-6 w-6" />}
      </button>

      <div
        className={cn(
          "fixed inset-0 z-[60] bg-ink/35 transition-opacity lg:hidden",
          open ? "pointer-events-auto opacity-100" : "pointer-events-none opacity-0"
        )}
        onClick={() => setOpen(false)}
      />

      <aside
        className={cn(
          "theme-blue-panel fixed inset-y-0 left-0 z-[65] flex w-[322px] max-w-[88vw] flex-col border-r border-white/80 shadow-2xl transition-transform duration-200 will-change-transform",
          open ? "pointer-events-auto translate-x-0" : "pointer-events-none -translate-x-full"
        )}
      >
        <div className="flex h-24 items-center justify-between border-b border-white/70 px-8">
          <Link href="/app" className="flex items-center gap-4" onClick={closeForNavigation}>
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

        <div className="custom-scrollbar relative z-10 flex-1 overflow-y-auto px-7 py-8">
          <div className="mb-8 flex items-center gap-4 border-b border-white/70 pb-7">
            <div className="grid h-14 w-14 shrink-0 place-items-center rounded-lg border border-white bg-ink text-xl font-bold text-white shadow-md">
              {(name || email || "G").slice(0, 1).toUpperCase()}
            </div>
            <div className="min-w-0">
              <div className="truncate text-lg font-bold">{name || "Account"}</div>
              <div className="truncate text-sm text-neutral-500">{email || "Sign in to sync your tones"}</div>
            </div>
          </div>

          {snapshot?.user ? <FreeAdaptationSummary {...getAdaptationSummaryProps(snapshot)} className="mb-8" /> : null}

          <NavSection title="My Collection" items={collectionNav} pathname={pathname} onNavigate={navigate} />
          <NavSection title="Discover" items={discoveryNav} pathname={pathname} onNavigate={navigate} />
          <NavSection title="Account" items={accountNav} pathname={pathname} onNavigate={navigate} />
          <NavSection title="Feedback" items={feedbackNav} pathname={pathname} onNavigate={navigate} />
        </div>

        <div className="relative z-10 border-t border-white/70 p-7">
          {email ? (
            <button type="button" className="button-quiet w-full justify-start text-base" onClick={logout}>
              <LogOut className="h-5 w-5" />
              Logout
            </button>
          ) : (
            <Link href="/login" className="button-secondary w-full justify-start" onClick={closeForNavigation}>
              <LogIn className="h-5 w-5" />
              Login
            </Link>
          )}

        </div>
      </aside>

      <main className={cn("min-h-screen", open ? "lg:pl-[322px]" : "lg:pl-0")}>
        {children}
      </main>
    </div>
  );
}

function NavSection({
  title,
  items,
  pathname,
  onNavigate
}: {
  title: string;
  items: Array<{ href: string; label: string; icon: React.ComponentType<{ className?: string }> }>;
  pathname: string;
  onNavigate: () => void;
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
            <a
              key={item.href}
              href={item.href}
              className={cn(
                "relative z-20 flex min-h-12 w-full items-center gap-4 rounded-lg px-3 text-left text-base font-semibold transition-colors",
                active ? "bg-ink text-white shadow-lg shadow-slate-900/10" : "text-slate-700 hover:bg-white/70 hover:text-ink"
              )}
              onClick={() => onNavigate()}
            >
              <Icon className="h-5 w-5" />
              {item.label}
            </a>
          );
        })}
      </nav>
    </div>
  );
}
