"use client";

import Link from "next/link";
import { useEffect, useMemo, useState } from "react";
import { useSearchParams } from "next/navigation";
import { Database, Guitar, Loader2, Search, Sparkles, ThumbsUp, Volume2 } from "lucide-react";
import { FreeAdaptationSummary } from "@/components/free-adaptation-summary";
import { OnboardingProgress } from "@/components/onboarding-progress";
import type { TonePartType } from "@/lib/mock-data";
import { getAdaptationSummaryProps, shouldShowFreeOnboardingJourney } from "@/lib/subscription-display";
import { addSubscriptionRefreshListener } from "@/lib/subscription-events";
import { loadClientSubscriptionSnapshot, type ClientSubscriptionSnapshot } from "@/lib/subscription-client";
import { createSupabaseBrowserClient } from "@/lib/supabase/browser";

type CommunityTone = {
  id: string;
  song: string;
  artist: string;
  genre: string;
  difficulty: string;
  part: string;
  mode: string;
  score: number;
  guitar: string;
  amp: string;
  pickupType: string;
  toneType?: string;
  toneCategory?: string;
  verificationStatus?: string;
};

const instrumentFilters = ["all", "guitar", "bass"] as const;
const partFilters = ["all", "riff", "solo"] as const;
const toneFilters = ["all", "clean", "distorted"] as const;
const sortFilters = ["top", "popular", "recent"] as const;

export function CommunityView() {
  const searchParams = useSearchParams();
  const onboardingMode = searchParams.get("onboarding") === "1";
  const [query, setQuery] = useState("");
  const [tones, setTones] = useState<CommunityTone[]>([]);
  const [snapshot, setSnapshot] = useState<ClientSubscriptionSnapshot | null>(null);
  const [instrument, setInstrument] = useState<(typeof instrumentFilters)[number]>("all");
  const [part, setPart] = useState<(typeof partFilters)[number]>("all");
  const [tone, setTone] = useState<(typeof toneFilters)[number]>("all");
  const [sort, setSort] = useState<(typeof sortFilters)[number]>("top");
  const [page, setPage] = useState(1);
  const [pageSize] = useState(18);
  const [total, setTotal] = useState(0);
  const [hasMore, setHasMore] = useState(false);
  const [loading, setLoading] = useState(false);
  const showFreeOnboardingJourney = shouldShowFreeOnboardingJourney(snapshot, onboardingMode);

  useEffect(() => {
    const supabase = createSupabaseBrowserClient();
    if (!supabase) {
      return;
    }
    const client = supabase;

    async function loadSnapshot() {
      const nextSnapshot = await loadClientSubscriptionSnapshot(client);
      setSnapshot(nextSnapshot);

      if (nextSnapshot.user && !nextSnapshot.hasAccess && onboardingMode && !nextSnapshot.onboarding.toneDatabaseVisited) {
        await client
          .from("profiles")
          .update({ tone_database_seen_at: new Date().toISOString() })
          .eq("id", nextSnapshot.user.id)
          .is("tone_database_seen_at", null);

        setSnapshot(await loadClientSubscriptionSnapshot(client));
      }
    }

    void loadSnapshot();

    const removeRefreshListener = addSubscriptionRefreshListener(() => {
      loadSnapshot().catch(() => undefined);
    });

    return () => {
      removeRefreshListener();
    };
  }, [onboardingMode]);

  useEffect(() => {
    setPage(1);
  }, [query, instrument, part, tone, sort]);

  useEffect(() => {
    const controller = new AbortController();
    const timeout = window.setTimeout(async () => {
      setLoading(true);
      try {
        const params = new URLSearchParams({
          q: query,
          instrument,
          part,
          tone,
          sort,
          page: String(page),
          pageSize: String(pageSize)
        });
        const response = await fetch(`/api/community-tones/lookup?${params.toString()}`, {
          signal: controller.signal
        });
        const data = await response.json();
        const results = (data.results || []) as CommunityTone[];
        setTotal(data.total || 0);
        setHasMore(Boolean(data.hasMore));
        setTones((current) => {
          if (page === 1) {
            return results;
          }

          const seen = new Set(current.map((item) => item.id));
          return [...current, ...results.filter((item) => !seen.has(item.id))];
        });
      } catch (error) {
        if (!(error instanceof DOMException && error.name === "AbortError")) {
          if (page === 1) {
            setTones([]);
            setTotal(0);
          }
          setHasMore(false);
        }
      } finally {
        setLoading(false);
      }
    }, 180);

    return () => {
      window.clearTimeout(timeout);
      controller.abort();
    };
  }, [instrument, page, pageSize, part, query, sort, tone]);

  const resultsLabel = useMemo(() => {
    if (!total) return "No tones yet";
    return `${total.toLocaleString()} tones`;
  }, [total]);
  const exampleSongs = ["Enter Sandman", "Master of Puppets", "Sweet Child O Mine", "Levitating", "Nothing Else Matters"];
  const popularArtists = Array.from(new Set(tones.map((item) => item.artist))).slice(0, 6);
  const recentlyAdded = tones.slice(0, 4);
  const detailHrefSuffix = showFreeOnboardingJourney ? "?onboarding=1" : "";

  return (
    <div className="px-4 pb-14 pt-24 sm:px-6 lg:px-8">
      <div className="mx-auto max-w-[1440px]">
        {showFreeOnboardingJourney ? (
          <div className="mb-8">
            <OnboardingProgress currentStep={2} />
          </div>
        ) : null}

        <section className="theme-panel theme-blue-panel px-6 py-12 text-center lg:px-8 lg:py-14">
          <h1 className="text-4xl font-bold tracking-normal sm:text-5xl">
            Tone <span className="lime-highlight">Database</span>
          </h1>
          <p className="mx-auto mt-5 max-w-3xl text-base leading-7 text-neutral-600 sm:text-lg">
            {showFreeOnboardingJourney
              ? "Search for the first song you want adapted to your saved gear. You can browse as much as you like before using a free adaptation."
              : "Browse community tone research, compare gear assumptions, and preview source rigs before adapting them to your setup."}
          </p>
          <div className="relative mx-auto mt-10 max-w-3xl">
            <Search className="absolute left-5 top-1/2 h-5 w-5 -translate-y-1/2 text-neutral-400" />
            <input
              className="field h-14 rounded-lg border-white/80 pl-12 text-base shadow-lg"
              value={query}
              onChange={(event) => setQuery(event.target.value)}
              placeholder="Search songs..."
            />
          </div>
          <div className="mx-auto mt-6 flex max-w-4xl flex-wrap justify-center gap-2">
            {exampleSongs.map((songName) => (
              <button
                key={songName}
                type="button"
                className="rounded-md border border-white/80 bg-white/80 px-3 py-2 text-sm font-semibold text-slate-700 transition hover:border-ocean/40 hover:text-ink"
                onClick={() => setQuery(songName)}
              >
                {songName}
              </button>
            ))}
          </div>
        </section>

        {showFreeOnboardingJourney ? (
          <div className="mt-8 rounded-lg border border-moss/50 bg-moss/10 px-5 py-4 text-sm text-ink">
            <div className="font-bold">Step 2: find a song you know.</div>
            <div className="mt-1 text-slate-700">
              Open any song page, then use <span className="font-semibold">Adapt to My Gear</span>. Searching and browsing do not use a free adaptation.
            </div>
          </div>
        ) : null}

        {snapshot?.user && snapshot.hasAccess ? <div className="mt-8"><FreeAdaptationSummary {...getAdaptationSummaryProps(snapshot)} /></div> : null}

        {!query.trim() ? (
          <div className="mt-8 grid gap-6 xl:grid-cols-3">
            <DiscoveryCard
              title="Trending Songs"
              items={recentlyAdded.map((item) => `${item.song} - ${item.artist}`)}
              onSelect={(value) => setQuery(value.split(" - ")[0] || value)}
            />
            <DiscoveryCard title="Popular Artists" items={popularArtists} onSelect={setQuery} />
            <DiscoveryCard
              title="Recently Added"
              items={recentlyAdded.map((item) => item.song)}
              onSelect={setQuery}
            />
          </div>
        ) : null}

        <div className="mt-8 flex flex-col gap-4 xl:flex-row xl:items-center xl:justify-between">
          <div className="flex flex-wrap gap-3">
            <FilterGroup value={instrument} setValue={setInstrument} options={instrumentFilters} labels={{ all: "All", guitar: "Guitar", bass: "Bass" }} />
            <FilterGroup value={part} setValue={setPart} options={partFilters} labels={{ all: "All Parts", riff: "Riff", solo: "Solo" }} />
            <FilterGroup value={tone} setValue={setTone} options={toneFilters} labels={{ all: "All Tones", clean: "Clean", distorted: "Distorted" }} />
          </div>
          <div className="flex flex-wrap items-center gap-3">
            <span className="text-sm font-semibold text-slate-500">{resultsLabel}</span>
            <FilterGroup value={sort} setValue={setSort} options={sortFilters} labels={{ top: "Top", popular: "Popular", recent: "Recent" }} />
          </div>
        </div>

        {loading && page === 1 ? (
          <div className="compact-card mt-8 flex min-h-[280px] items-center justify-center gap-3 p-8 text-neutral-600">
            <Loader2 className="h-5 w-5 animate-spin" />
            Loading tone database
          </div>
        ) : tones.length ? (
          <>
            <div className="mt-8 grid gap-6 lg:grid-cols-2 2xl:grid-cols-3">
              {tones.map((item) => (
            <article key={item.id} className="compact-card overflow-hidden border border-white/90 bg-white/90 p-5 shadow-lg transition-shadow hover:shadow-xl">
              <div className="flex items-start justify-between gap-4">
                <div className="min-w-0">
                  <h2 className="line-clamp-1 text-2xl font-bold leading-tight">{item.song}</h2>
                  <p className="mt-1.5 text-base font-semibold text-neutral-500">{item.artist}</p>
                </div>
                <div className="rounded-md bg-blue-50 px-3 py-2 text-right">
                  <div className="text-xs font-bold uppercase tracking-[0.12em] text-slate-400">Research</div>
                  <div className="mt-1 text-sm font-bold text-ocean">{Math.max(18, item.score * 4)} entries</div>
                </div>
              </div>
              <div className="mt-5 flex flex-wrap gap-2">
                <Pill icon={item.mode === "bass" ? <Volume2 className="h-4 w-4" /> : <Guitar className="h-4 w-4" />}>{item.mode}</Pill>
                <Pill>{normalizePart(item.part)}</Pill>
                <Pill tone>{(item.toneType || "auto").replace("_", " ")}</Pill>
                {item.toneCategory ? <Pill>{item.toneCategory}</Pill> : null}
                {item.verificationStatus ? <Pill icon={<Sparkles className="h-4 w-4" />}>{item.verificationStatus.replace("_", " ")}</Pill> : null}
              </div>
              <div className="mt-5 rounded-xl border border-blue-50 bg-gradient-to-br from-white to-slate-50 px-4 py-3.5">
                <div className="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-400">Original Rig Snapshot</div>
                <div className="mt-2.5 line-clamp-1 text-sm font-semibold text-neutral-600">
                  {item.guitar} <span className="mx-2 text-neutral-300">+</span> {item.amp}
                </div>
                <div className="mt-3 grid gap-2 text-xs font-semibold text-slate-500 sm:grid-cols-2">
                  <span>{item.genre}</span>
                  <span className="sm:text-right">{item.difficulty}</span>
                  <span className="sm:col-span-2">{item.pickupType}</span>
                </div>
              </div>
              <div className="mt-5 grid grid-cols-[82px_1fr] gap-3 border-t border-neutral-100 pt-4">
                <button type="button" className="button-secondary min-h-10 rounded-lg px-3 text-sm">
                  <ThumbsUp className="h-5 w-5" />
                  {Math.max(10, Math.round(item.score / 1.4))}
                </button>
                <Link href={`/community/${item.id}${detailHrefSuffix}`} className="button-primary min-h-10 rounded-lg text-sm">
                  <Database className="h-5 w-5" />
                  View Tone
                </Link>
              </div>
            </article>
              ))}
            </div>

            {hasMore ? (
              <div className="mt-8 flex justify-center">
                <button type="button" className="button-secondary min-h-12 rounded-lg px-6" onClick={() => setPage((current) => current + 1)} disabled={loading}>
                  {loading ? <Loader2 className="h-4 w-4 animate-spin" /> : null}
                  Load More Tones
                </button>
              </div>
            ) : null}
          </>
        ) : (
          <div className="compact-card mt-8 grid min-h-[280px] place-items-center p-8 text-center">
            <div>
              <Database className="mx-auto h-10 w-10 text-slate-400" />
              <h2 className="mt-4 text-2xl font-bold">No tones matched this search</h2>
              <p className="mt-2 text-sm text-slate-500">Try a different song, artist, part, or tone filter.</p>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

function DiscoveryCard({ title, items, onSelect }: { title: string; items: string[]; onSelect: (value: string) => void }) {
  if (!items.length) {
    return null;
  }

  return (
    <div className="compact-card p-5">
      <h2 className="text-lg font-bold">{title}</h2>
      <div className="mt-4 grid gap-2">
        {items.map((item) => (
          <button
            key={`${title}-${item}`}
            type="button"
            className="rounded-lg border border-white/80 bg-white/80 px-4 py-3 text-left text-sm font-semibold text-slate-700 transition hover:border-ocean/40 hover:text-ink"
            onClick={() => onSelect(item)}
          >
            {item}
          </button>
        ))}
      </div>
    </div>
  );
}

function normalizePart(value: string): TonePartType {
  const normalized = value.toLowerCase();
  if (normalized.includes("solo")) return "solo";
  if (normalized.includes("riff")) return "riff";
  if (normalized.includes("lead")) return "lead";
  if (normalized.includes("rhythm")) return "rhythm";
  if (normalized.includes("bass")) return "bassline";
  return "main";
}

function FilterGroup<T extends string>({ value, setValue, options, labels }: { value: T; setValue: (value: T) => void; options: readonly T[]; labels: Record<T, string> }) {
  return (
    <div className="inline-flex rounded-lg border border-white/80 bg-white/70 p-1 shadow-sm">
      {options.map((option) => (
        <button
          key={option}
          type="button"
          className={`min-h-9 rounded-md px-3.5 text-sm font-bold transition ${value === option ? "bg-ink text-white shadow-md" : "text-slate-600 hover:bg-blue-50 hover:text-ink"}`}
          onClick={() => setValue(option)}
        >
          {labels[option]}
        </button>
      ))}
    </div>
  );
}

function Pill({ children, icon, tone }: { children: React.ReactNode; icon?: React.ReactNode; tone?: boolean }) {
  return (
    <span className={`inline-flex items-center gap-1.5 rounded-md border px-2.5 py-1 text-xs font-bold capitalize ${tone ? "border-moss bg-moss text-ink" : "border-white/80 bg-white/80 text-slate-600"}`}>
      {icon}
      {children}
    </span>
  );
}
