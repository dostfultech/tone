"use client";

import Link from "next/link";
import { useEffect, useMemo, useState } from "react";
import { Database, Guitar, Search, Sparkles, ThumbsUp, Volume2 } from "lucide-react";
import type { TonePartType } from "@/lib/mock-data";

type CommunityTone = {
  id: string;
  song: string;
  artist: string;
  part: string;
  mode: string;
  score: number;
  guitar: string;
  amp: string;
  toneType?: string;
  verificationStatus?: string;
};

const instrumentFilters = ["all", "guitar", "bass"] as const;
const partFilters = ["all", "riff", "solo"] as const;
const toneFilters = ["all", "clean", "distorted"] as const;
const sortFilters = ["top", "popular", "recent"] as const;

export function CommunityView() {
  const [query, setQuery] = useState("");
  const [tones, setTones] = useState<CommunityTone[]>([]);
  const [instrument, setInstrument] = useState<(typeof instrumentFilters)[number]>("all");
  const [part, setPart] = useState<(typeof partFilters)[number]>("all");
  const [tone, setTone] = useState<(typeof toneFilters)[number]>("all");
  const [sort, setSort] = useState<(typeof sortFilters)[number]>("top");

  useEffect(() => {
    fetch(`/api/community-tones/lookup?q=${encodeURIComponent(query)}`)
      .then((response) => response.json())
      .then((data) => setTones(data.results || []))
      .catch(() => setTones([]));
  }, [query]);

  const filtered = useMemo(() => {
    const next = tones.filter((item) => {
      const itemPart = normalizePart(item.part);
      const itemTone = (item.toneType || "").toLowerCase();
      if (instrument !== "all" && item.mode !== instrument) return false;
      if (part !== "all" && itemPart !== part) return false;
      if (tone !== "all" && !itemTone.includes(tone)) return false;
      return true;
    });

    return [...next].sort((a, b) => {
      if (sort === "recent") return a.song.localeCompare(b.song);
      if (sort === "popular") return b.score - a.score + b.artist.localeCompare(a.artist);
      return b.score - a.score;
    });
  }, [instrument, part, sort, tone, tones]);

  return (
    <div className="px-4 pb-16 pt-28 sm:px-6 lg:px-8">
      <div className="mx-auto max-w-[1840px]">
        <section className="theme-panel theme-blue-panel px-6 py-14 text-center lg:px-8 lg:py-16">
          <h1 className="text-4xl font-bold tracking-normal sm:text-5xl lg:text-6xl">
            Tone <span className="lime-highlight">Database</span>
          </h1>
          <p className="mx-auto mt-5 max-w-3xl text-base leading-7 text-neutral-600 sm:text-lg">Browse community tone research, compare gear assumptions, and preview source rigs before adapting them to your setup.</p>
          <div className="relative mx-auto mt-10 max-w-3xl">
            <Search className="absolute left-5 top-1/2 h-5 w-5 -translate-y-1/2 text-neutral-400" />
            <input
              className="field h-14 rounded-lg border-white/80 pl-12 text-base shadow-lg"
              value={query}
              onChange={(event) => setQuery(event.target.value)}
              placeholder="Search songs, artists, or gear..."
            />
          </div>
        </section>

        <div className="mt-8 flex flex-col gap-4 xl:flex-row xl:items-center xl:justify-between">
          <div className="flex flex-wrap gap-3">
            <FilterGroup value={instrument} setValue={setInstrument} options={instrumentFilters} labels={{ all: "All", guitar: "Guitar", bass: "Bass" }} />
            <FilterGroup value={part} setValue={setPart} options={partFilters} labels={{ all: "All Parts", riff: "Riff", solo: "Solo" }} />
            <FilterGroup value={tone} setValue={setTone} options={toneFilters} labels={{ all: "All Tones", clean: "Clean", distorted: "Distorted" }} />
          </div>
          <FilterGroup value={sort} setValue={setSort} options={sortFilters} labels={{ top: "Top", popular: "Popular", recent: "Recent" }} />
        </div>

        <div className="mt-8 grid gap-6 lg:grid-cols-2 2xl:grid-cols-3">
          {filtered.map((item) => (
            <article key={item.id} className="compact-card overflow-hidden border border-white/90 bg-white/85 p-5 shadow-lg transition hover:-translate-y-1 hover:shadow-xl">
              <div className="flex items-start justify-between gap-4">
                <div className="min-w-0">
                  <h2 className="line-clamp-1 text-2xl font-bold leading-tight">{item.song}</h2>
                  <p className="mt-1.5 text-base font-semibold text-neutral-400">{item.artist}</p>
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
                {item.verificationStatus ? <Pill icon={<Sparkles className="h-4 w-4" />}>{item.verificationStatus.replace("_", " ")}</Pill> : null}
              </div>
              <div className="mt-5 rounded-xl border border-blue-50 bg-gradient-to-br from-white to-slate-50 px-4 py-3.5">
                <div className="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-400">Original Rig Snapshot</div>
                <div className="mt-2.5 line-clamp-1 text-sm font-semibold text-neutral-600">
                  {item.guitar} <span className="mx-2 text-neutral-300">+</span> {item.amp}
                </div>
                <div className="mt-3 flex flex-wrap gap-2">
                  <span className="rounded-md bg-moss px-2.5 py-1 text-xs font-bold uppercase text-ink">{normalizePart(item.part)}</span>
                  <span className="rounded-md bg-neutral-50 px-2.5 py-1 text-xs font-bold uppercase text-neutral-500">{(item.toneType || "auto").replace("_", " ")}</span>
                  <span className="rounded-md bg-white px-2.5 py-1 text-xs font-bold uppercase text-ocean">{item.mode}</span>
                </div>
              </div>
              <div className="mt-5 grid grid-cols-[82px_1fr] gap-3 border-t border-neutral-100 pt-4">
                <button type="button" className="button-secondary min-h-10 rounded-lg px-3 text-sm">
                  <ThumbsUp className="h-5 w-5" />
                  {Math.max(10, Math.round(item.score / 1.4))}
                </button>
                <Link href={`/community/${item.id}`} className="button-primary min-h-10 rounded-lg text-sm">
                  <Database className="h-5 w-5" />
                  View Tone
                </Link>
              </div>
            </article>
          ))}
        </div>
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
