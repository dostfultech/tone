"use client";

import { useEffect, useMemo, useState } from "react";
import { Database, Guitar, Search, ThumbsUp, Volume2 } from "lucide-react";
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

  function viewTone(item: CommunityTone) {
    localStorage.setItem("toneMatch_song", item.song);
    localStorage.setItem("toneMatch_artist", item.artist);
    localStorage.setItem("toneMatch_part", item.part);
    localStorage.setItem("toneMatch_partType", normalizePart(item.part));
    localStorage.setItem("toneMatch_toneType", item.toneType || "auto");
    localStorage.setItem("toneMatch_guitar", item.guitar);
    localStorage.setItem("toneMatch_amp", item.amp);
    window.location.href = "/app";
  }

  return (
    <div className="px-4 pb-16 pt-28 sm:px-6 lg:px-8">
      <div className="mx-auto max-w-[1840px]">
        <section className="theme-panel theme-blue-panel px-6 py-20 text-center">
          <h1 className="text-6xl font-bold tracking-normal">
            Tone <span className="lime-highlight">Database</span>
          </h1>
          <p className="mx-auto mt-7 max-w-4xl text-2xl leading-10 text-neutral-600">Browse community tone research, compare gear assumptions, and send any result into your matcher.</p>
          <div className="relative mx-auto mt-14 max-w-5xl">
            <Search className="absolute left-7 top-1/2 h-7 w-7 -translate-y-1/2 text-neutral-400" />
            <input
              className="field h-20 rounded-lg border-white/80 pl-20 text-2xl shadow-lg"
              value={query}
              onChange={(event) => setQuery(event.target.value)}
              placeholder="Search songs, artists, or gear..."
            />
          </div>
        </section>

        <div className="mt-10 flex flex-col gap-5 xl:flex-row xl:items-center xl:justify-between">
          <div className="flex flex-wrap gap-4">
            <FilterGroup value={instrument} setValue={setInstrument} options={instrumentFilters} labels={{ all: "All", guitar: "Guitar", bass: "Bass" }} />
            <FilterGroup value={part} setValue={setPart} options={partFilters} labels={{ all: "All Parts", riff: "Riff", solo: "Solo" }} />
            <FilterGroup value={tone} setValue={setTone} options={toneFilters} labels={{ all: "All Tones", clean: "Clean", distorted: "Distorted" }} />
          </div>
          <FilterGroup value={sort} setValue={setSort} options={sortFilters} labels={{ top: "Top", popular: "Popular", recent: "Recent" }} />
        </div>

        <div className="mt-10 grid gap-8 lg:grid-cols-2 2xl:grid-cols-3">
          {filtered.map((item) => (
            <article key={item.id} className="compact-card p-8 shadow-lg transition hover:-translate-y-1 hover:shadow-xl">
              <h2 className="line-clamp-1 text-4xl font-bold">{item.song}</h2>
              <p className="mt-3 text-2xl font-semibold text-neutral-400">{item.artist}</p>
              <div className="mt-7 flex flex-wrap gap-3">
                <Pill icon={item.mode === "bass" ? <Volume2 className="h-4 w-4" /> : <Guitar className="h-4 w-4" />}>{item.mode}</Pill>
                <Pill>{normalizePart(item.part)}</Pill>
                <Pill tone>{(item.toneType || "auto").replace("_", " ")}</Pill>
                <Pill>{Math.max(18, item.score * 4)} versions</Pill>
              </div>
              <div className="mt-7 grid gap-3 text-lg font-semibold text-neutral-400">
                <div className="line-clamp-1">
                  {item.guitar} <span className="mx-2 text-neutral-300">+</span> {item.amp}
                </div>
                <div className="flex gap-3">
                  <span className="rounded-md bg-moss px-3 py-1 text-sm font-bold uppercase text-ink">Rock</span>
                  <span className="rounded-md bg-neutral-50 px-3 py-1 text-sm font-bold uppercase text-neutral-400">1980s</span>
                  {item.verificationStatus ? <span className="rounded-md bg-white px-3 py-1 text-sm font-bold uppercase text-ocean">{item.verificationStatus.replace("_", " ")}</span> : null}
                </div>
              </div>
              <div className="mt-8 grid grid-cols-[92px_1fr] gap-4 border-t border-neutral-100 pt-6">
                <button type="button" className="button-secondary rounded-lg">
                  <ThumbsUp className="h-5 w-5" />
                  {Math.max(10, Math.round(item.score / 1.4))}
                </button>
                <button type="button" className="button-primary rounded-lg text-lg" onClick={() => viewTone(item)}>
                  <Database className="h-5 w-5" />
                  View Tone
                </button>
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
          className={`min-h-12 rounded-md px-5 text-base font-bold transition ${value === option ? "bg-ink text-white shadow-md" : "text-slate-600 hover:bg-blue-50 hover:text-ink"}`}
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
    <span className={`inline-flex items-center gap-2 rounded-md border px-3 py-1 text-sm font-bold capitalize ${tone ? "border-moss bg-moss text-ink" : "border-white/80 bg-white/80 text-slate-600"}`}>
      {icon}
      {children}
    </span>
  );
}
