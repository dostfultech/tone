"use client";

import { useEffect, useMemo, useRef, useState } from "react";
import { Check, Loader2, Plus, Search, X } from "lucide-react";
import type { GearSearchItem, GearSearchResponse } from "@/lib/my-gear";

type PedalSelectorModalProps = {
  open: boolean;
  onClose: () => void;
  onSelect: (item: GearSearchItem) => void;
  selectedPedals: GearSearchItem[];
};

const CATEGORY_FILTERS = [
  { key: "all", label: "All" },
  { key: "overdrive", label: "Overdrive" },
  { key: "distortion", label: "Distortion" },
  { key: "fuzz", label: "Fuzz" },
  { key: "boost", label: "Boost" },
  { key: "delay", label: "Delay" },
  { key: "reverb", label: "Reverb" },
  { key: "modulation", label: "Modulation" },
  { key: "wah", label: "Wah" },
  { key: "compression", label: "Compression" },
  { key: "eq", label: "EQ" },
  { key: "noise_gate", label: "Noise Gate" },
  { key: "other", label: "Other" },
] as const;

const CATEGORY_COLORS: Record<string, string> = {
  overdrive: "bg-amber-100 text-amber-800 dark:bg-amber-900/40 dark:text-amber-300",
  distortion: "bg-red-100 text-red-800 dark:bg-red-900/40 dark:text-red-300",
  fuzz: "bg-purple-100 text-purple-800 dark:bg-purple-900/40 dark:text-purple-300",
  boost: "bg-emerald-100 text-emerald-800 dark:bg-emerald-900/40 dark:text-emerald-300",
  delay: "bg-blue-100 text-blue-800 dark:bg-blue-900/40 dark:text-blue-300",
  reverb: "bg-sky-100 text-sky-800 dark:bg-sky-900/40 dark:text-sky-300",
  chorus: "bg-teal-100 text-teal-800 dark:bg-teal-900/40 dark:text-teal-300",
  flanger: "bg-teal-100 text-teal-800 dark:bg-teal-900/40 dark:text-teal-300",
  phaser: "bg-teal-100 text-teal-800 dark:bg-teal-900/40 dark:text-teal-300",
  modulation: "bg-teal-100 text-teal-800 dark:bg-teal-900/40 dark:text-teal-300",
  tremolo: "bg-teal-100 text-teal-800 dark:bg-teal-900/40 dark:text-teal-300",
  compressor: "bg-yellow-100 text-yellow-800 dark:bg-yellow-900/40 dark:text-yellow-300",
  eq: "bg-indigo-100 text-indigo-800 dark:bg-indigo-900/40 dark:text-indigo-300",
  wah: "bg-pink-100 text-pink-800 dark:bg-pink-900/40 dark:text-pink-300",
  noise_gate: "bg-slate-200 text-slate-700 dark:bg-slate-700 dark:text-slate-300",
  pitch: "bg-violet-100 text-violet-800 dark:bg-violet-900/40 dark:text-violet-300",
  octaver: "bg-violet-100 text-violet-800 dark:bg-violet-900/40 dark:text-violet-300",
  volume: "bg-gray-100 text-gray-700 dark:bg-gray-800 dark:text-gray-300",
  looper: "bg-lime-100 text-lime-800 dark:bg-lime-900/40 dark:text-lime-300",
  utility: "bg-gray-100 text-gray-700 dark:bg-gray-800 dark:text-gray-300",
  preamp: "bg-orange-100 text-orange-800 dark:bg-orange-900/40 dark:text-orange-300",
  amp_cab_sim: "bg-orange-100 text-orange-800 dark:bg-orange-900/40 dark:text-orange-300",
  acoustic: "bg-amber-50 text-amber-700 dark:bg-amber-900/30 dark:text-amber-300",
};

function categoryBadgeClass(category: string) {
  return CATEGORY_COLORS[category] || "bg-slate-100 text-slate-600 dark:bg-slate-700 dark:text-slate-300";
}

function categoryLabel(category: string) {
  const labels: Record<string, string> = {
    overdrive: "Overdrive",
    distortion: "Distortion",
    fuzz: "Fuzz",
    boost: "Boost",
    delay: "Delay",
    reverb: "Reverb",
    chorus: "Chorus",
    flanger: "Flanger",
    phaser: "Phaser",
    modulation: "Modulation",
    tremolo: "Tremolo",
    compressor: "Compression",
    eq: "EQ",
    wah: "Wah",
    noise_gate: "Noise Gate",
    pitch: "Pitch",
    octaver: "Octaver",
    volume: "Volume",
    looper: "Looper",
    utility: "Utility",
    preamp: "Preamp",
    amp_cab_sim: "Amp/Cab Sim",
    acoustic: "Acoustic",
  };
  return labels[category] || category;
}

function formatPrice(low: number | null, high: number | null) {
  if (low === null && high === null) return null;
  if (low !== null && high !== null && low !== high) return `~$${low}–$${high}`;
  return `~$${low ?? high}`;
}

export function PedalSelectorModal({ open, onClose, onSelect, selectedPedals }: PedalSelectorModalProps) {
  const [query, setQuery] = useState("");
  const [debouncedQuery, setDebouncedQuery] = useState("");
  const [activeCategory, setActiveCategory] = useState("all");
  const [results, setResults] = useState<GearSearchItem[]>([]);
  const [loading, setLoading] = useState(false);
  const searchInputRef = useRef<HTMLInputElement | null>(null);
  const backdropRef = useRef<HTMLDivElement | null>(null);

  const selectedIds = useMemo(
    () => new Set(selectedPedals.map((p) => p.modelId)),
    [selectedPedals]
  );

  useEffect(() => {
    const timeout = window.setTimeout(() => {
      setDebouncedQuery(query.trim());
    }, 250);
    return () => window.clearTimeout(timeout);
  }, [query]);

  useEffect(() => {
    if (!open) return;

    const controller = new AbortController();

    async function loadResults() {
      setLoading(true);
      try {
        const params = new URLSearchParams({ type: "pedal", limit: "500" });
        if (debouncedQuery) params.set("q", debouncedQuery);
        if (activeCategory !== "all") params.set("category", activeCategory);

        const response = await fetch(`/api/equipment/search?${params.toString()}`, {
          cache: "no-store",
          signal: controller.signal,
        });
        const payload = (await response.json()) as GearSearchResponse;
        setResults(Array.isArray(payload.results) ? payload.results : []);
      } catch {
        if (!controller.signal.aborted) setResults([]);
      } finally {
        if (!controller.signal.aborted) setLoading(false);
      }
    }

    void loadResults();
    return () => controller.abort();
  }, [open, debouncedQuery, activeCategory]);

  useEffect(() => {
    if (open) {
      document.body.style.overflow = "hidden";
      window.setTimeout(() => searchInputRef.current?.focus(), 50);
    } else {
      document.body.style.overflow = "";
    }
    return () => { document.body.style.overflow = ""; };
  }, [open]);

  useEffect(() => {
    if (!open) return;
    function handleEsc(e: KeyboardEvent) {
      if (e.key === "Escape") onClose();
    }
    document.addEventListener("keydown", handleEsc);
    return () => document.removeEventListener("keydown", handleEsc);
  }, [open, onClose]);

  function handleBackdropClick(e: React.MouseEvent) {
    if (e.target === backdropRef.current) onClose();
  }

  function handleCategoryChange(key: string) {
    setActiveCategory(key);
  }

  if (!open) return null;

  return (
    <div
      ref={backdropRef}
      onClick={handleBackdropClick}
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4 backdrop-blur-sm"
    >
      <div className="flex max-h-[90vh] w-full max-w-3xl flex-col overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-2xl dark:border-slate-700 dark:bg-slate-900">
        {/* Header */}
        <div className="flex items-center justify-between border-b border-slate-200 px-6 py-4 dark:border-slate-700">
          <h2 className="text-lg font-bold text-ink dark:text-white">Add Pedal to Collection</h2>
          <button
            type="button"
            onClick={onClose}
            className="rounded-lg p-1.5 text-slate-400 transition hover:bg-slate-100 hover:text-slate-600 dark:hover:bg-slate-800 dark:hover:text-white"
            aria-label="Close"
          >
            <X className="h-5 w-5" />
          </button>
        </div>

        {/* Search */}
        <div className="border-b border-slate-200 px-6 py-3 dark:border-slate-700">
          <div className="relative">
            <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />
            <input
              ref={searchInputRef}
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder="Search pedals..."
              className="h-11 w-full rounded-xl border border-slate-200 bg-slate-50 pl-10 pr-4 text-sm text-slate-800 outline-none transition focus:border-ocean dark:border-slate-700 dark:bg-slate-800 dark:text-slate-100"
            />
          </div>
        </div>

        {/* Category filters */}
        <div className="flex flex-wrap gap-2 border-b border-slate-200 px-6 py-3 dark:border-slate-700">
          {CATEGORY_FILTERS.map((filter) => (
            <button
              key={filter.key}
              type="button"
              onClick={() => handleCategoryChange(filter.key)}
              className={`rounded-full px-3 py-1 text-xs font-semibold transition ${
                activeCategory === filter.key
                  ? "bg-ocean text-white shadow-sm"
                  : "bg-slate-100 text-slate-600 hover:bg-slate-200 dark:bg-slate-800 dark:text-slate-300 dark:hover:bg-slate-700"
              }`}
            >
              {filter.label}
            </button>
          ))}
        </div>

        {/* Results grid */}
        <div className="flex-1 overflow-y-auto px-6 py-4">
          {loading ? (
            <div className="flex items-center justify-center gap-2 py-16 text-sm text-slate-500">
              <Loader2 className="h-5 w-5 animate-spin" />
              Searching pedals...
            </div>
          ) : results.length ? (
            <div className="grid grid-cols-1 gap-3 sm:grid-cols-2">
              {results.map((item) => {
                const isSelected = selectedIds.has(item.modelId);
                const price = formatPrice(item.priceLow, item.priceHigh);

                return (
                  <div
                    key={item.modelId}
                    className={`relative flex items-start justify-between rounded-xl border p-4 transition ${
                      isSelected
                        ? "border-ocean/40 bg-ocean/5 dark:border-ocean/30 dark:bg-ocean/10"
                        : "border-slate-200 bg-white hover:border-slate-300 hover:shadow-sm dark:border-slate-700 dark:bg-slate-800/50 dark:hover:border-slate-600"
                    }`}
                  >
                    <div className="min-w-0 flex-1 pr-3">
                      <div className="font-semibold text-sm text-ink dark:text-white leading-tight">
                        {item.modelName}
                      </div>
                      <div className="mt-0.5 text-xs text-slate-500 dark:text-slate-400">
                        {item.brandName}
                      </div>
                      <div className="mt-2 flex flex-wrap items-center gap-1.5">
                        <span className={`inline-block rounded-md px-2 py-0.5 text-[10px] font-bold uppercase tracking-wide ${categoryBadgeClass(item.category)}`}>
                          {categoryLabel(item.category)}
                        </span>
                        {price ? (
                          <span className="text-[11px] font-medium text-slate-500 dark:text-slate-400">
                            {price}
                          </span>
                        ) : null}
                      </div>
                      {item.usedByArtists.length > 0 ? (
                        <div className="mt-1.5 text-[11px] text-slate-400 dark:text-slate-500 leading-snug">
                          Used by: {item.usedByArtists.slice(0, 3).join(", ")}
                          {item.usedByArtists.length > 3 ? ` +${item.usedByArtists.length - 3} more` : ""}
                        </div>
                      ) : null}
                    </div>
                    <button
                      type="button"
                      onClick={() => { if (!isSelected) onSelect(item); }}
                      disabled={isSelected}
                      className={`mt-1 flex h-7 w-7 flex-shrink-0 items-center justify-center rounded-full transition ${
                        isSelected
                          ? "bg-ocean text-white"
                          : "border border-slate-300 bg-white text-slate-500 hover:border-ocean hover:text-ocean dark:border-slate-600 dark:bg-slate-700 dark:text-slate-300 dark:hover:border-ocean dark:hover:text-ocean"
                      }`}
                      aria-label={isSelected ? `${item.modelName} already added` : `Add ${item.modelName}`}
                    >
                      {isSelected ? <Check className="h-3.5 w-3.5" /> : <Plus className="h-3.5 w-3.5" />}
                    </button>
                  </div>
                );
              })}
            </div>
          ) : (
            <div className="py-16 text-center text-sm text-slate-500 dark:text-slate-400">
              <p className="font-semibold text-slate-700 dark:text-slate-200">No pedals found</p>
              <p className="mt-1">Try a different search term or category.</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
