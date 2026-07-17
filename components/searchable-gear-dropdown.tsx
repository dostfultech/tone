"use client";

import { type KeyboardEvent, useEffect, useMemo, useRef, useState } from "react";
import { Check, ChevronDown, Loader2, Search } from "lucide-react";
import type { GearSearchItem, GearSearchResponse } from "@/lib/my-gear";

type SearchableGearDropdownProps = {
  label: string;
  placeholder: string;
  endpoint: string;
  selectedItems: GearSearchItem[];
  onSelect: (item: GearSearchItem) => void;
  requestType: string;
  limit?: number;
  hideLabel?: boolean;
};

export function SearchableGearDropdown({
  label,
  placeholder,
  endpoint,
  selectedItems,
  onSelect,
  requestType,
  limit = 200,
  hideLabel = false
}: SearchableGearDropdownProps) {
  const [open, setOpen] = useState(false);
  const [query, setQuery] = useState("");
  const [debouncedQuery, setDebouncedQuery] = useState("");
  const [results, setResults] = useState<GearSearchItem[]>([]);
  const [loading, setLoading] = useState(false);
  const [activeIndex, setActiveIndex] = useState(0);
  const rootRef = useRef<HTMLDivElement | null>(null);
  const searchInputRef = useRef<HTMLInputElement | null>(null);

  const selectedSummary = useMemo(() => {
    if (!selectedItems.length) {
      return placeholder;
    }

    if (selectedItems.length === 1) {
      return selectedItems[0].name;
    }

    return `${selectedItems.length} selected`;
  }, [placeholder, selectedItems]);

  const groupedResults = useMemo(() => {
    const map = new Map<string, GearSearchItem[]>();

    for (const item of results) {
      const existing = map.get(item.brandName) || [];
      existing.push(item);
      map.set(item.brandName, existing);
    }

    return Array.from(map.entries());
  }, [results]);

  useEffect(() => {
    const timeout = window.setTimeout(() => {
      setDebouncedQuery(query.trim());
    }, 250);

    return () => window.clearTimeout(timeout);
  }, [query]);

  useEffect(() => {
    if (!open) {
      return;
    }

    const controller = new AbortController();

    async function loadResults() {
      setLoading(true);
      try {
        const response = await fetch(buildEndpointUrl(endpoint, debouncedQuery, limit), {
          cache: "no-store",
          signal: controller.signal
        });
        const payload = (await response.json()) as GearSearchResponse;
        const nextResults = Array.isArray(payload.results) ? payload.results : [];
        setResults(nextResults);
        setActiveIndex(0);
      } catch {
        if (!controller.signal.aborted) {
          setResults([]);
        }
      } finally {
        if (!controller.signal.aborted) {
          setLoading(false);
        }
      }
    }

    void loadResults();

    return () => {
      controller.abort();
    };
  }, [debouncedQuery, endpoint, limit, open]);

  useEffect(() => {
    function handleOutsideClick(event: MouseEvent) {
      if (!rootRef.current) {
        return;
      }

      if (event.target instanceof Node && !rootRef.current.contains(event.target)) {
        setOpen(false);
      }
    }

    document.addEventListener("mousedown", handleOutsideClick);
    return () => document.removeEventListener("mousedown", handleOutsideClick);
  }, []);

  function openPanel() {
    setOpen(true);
    window.setTimeout(() => {
      searchInputRef.current?.focus();
    }, 0);
  }

  function selectResult(item: GearSearchItem) {
    onSelect(item);
    setOpen(false);
    setQuery("");
  }

  function requestGear() {
    const term = query.trim();
    const params = new URLSearchParams({
      kind: "gear",
      requestType,
      requestName: term,
      message: term ? `Please add ${term}.` : "Please add this gear."
    });

    window.location.href = `/contact?${params.toString()}`;
  }

  function handleSearchKeyDown(event: KeyboardEvent<HTMLInputElement>) {
    if (!results.length) {
      if (event.key === "Escape") {
        setOpen(false);
      }
      return;
    }

    if (event.key === "ArrowDown") {
      event.preventDefault();
      setActiveIndex((current) => Math.min(current + 1, results.length - 1));
      return;
    }

    if (event.key === "ArrowUp") {
      event.preventDefault();
      setActiveIndex((current) => Math.max(current - 1, 0));
      return;
    }

    if (event.key === "Enter") {
      event.preventDefault();
      const activeItem = results[activeIndex];
      if (activeItem) {
        selectResult(activeItem);
      }
      return;
    }

    if (event.key === "Escape") {
      setOpen(false);
    }
  }

  return (
    <div ref={rootRef} className="relative w-full">
      {hideLabel ? null : <label className="label">{label}</label>}
      <button
        type="button"
        className={`${hideLabel ? "" : "mt-2 "}flex min-h-12 w-full items-center justify-between rounded-xl border border-slate-200 bg-white px-4 text-left text-sm font-semibold text-slate-700 shadow-sm transition hover:border-ocean/50 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-100`}
        onClick={() => (open ? setOpen(false) : openPanel())}
      >
        <span className={selectedItems.length ? "text-slate-900 dark:text-white" : "text-slate-500 dark:text-slate-400"}>{selectedSummary}</span>
        <ChevronDown className={`h-4 w-4 text-slate-500 transition ${open ? "rotate-180" : ""}`} />
      </button>

      {open ? (
        <div className="absolute left-0 right-0 z-40 mt-2 overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-2xl dark:border-slate-700 dark:bg-slate-900">
          <div className="sticky top-0 z-10 border-b border-slate-200 bg-white p-3 dark:border-slate-700 dark:bg-slate-900">
            <div className="relative">
              <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />
              <input
                ref={searchInputRef}
                value={query}
                onChange={(event) => setQuery(event.target.value)}
                onKeyDown={handleSearchKeyDown}
                placeholder={placeholder}
                className="h-11 w-full rounded-xl border border-slate-200 bg-slate-50 pl-10 pr-4 text-sm text-slate-800 outline-none transition focus:border-ocean dark:border-slate-700 dark:bg-slate-800 dark:text-slate-100"
              />
            </div>
          </div>

          <div className="max-h-80 overflow-y-auto p-2">
            {loading ? (
              <div className="flex items-center gap-2 px-3 py-8 text-sm text-slate-500">
                <Loader2 className="h-4 w-4 animate-spin" />
                Searching gear...
              </div>
            ) : results.length ? (
              groupedResults.map(([brand, items]) => (
                <div key={brand} className="pb-2">
                  <div className="sticky top-0 px-3 py-2 text-xs font-bold uppercase tracking-[0.12em] text-slate-400 dark:text-slate-500">
                    {brand}
                  </div>
                  {items.map((item) => {
                    const itemIndex = results.findIndex((candidate) => candidate.modelId === item.modelId);
                    const isActive = itemIndex === activeIndex;
                    const isSelected = selectedItems.some((selected) => selected.modelId === item.modelId);

                    return (
                      <button
                        key={item.modelId}
                        type="button"
                        onMouseEnter={() => setActiveIndex(itemIndex)}
                        onClick={() => selectResult(item)}
                        className={`flex w-full items-center justify-between rounded-xl px-3 py-2 text-left text-sm transition ${
                          isActive
                            ? "bg-blue-50 text-ink dark:bg-slate-800 dark:text-white"
                            : "text-slate-700 hover:bg-slate-50 dark:text-slate-200 dark:hover:bg-slate-800"
                        }`}
                      >
                        <div>
                          <div className="font-semibold">{item.modelName}</div>
                          <div className="text-xs text-slate-500 dark:text-slate-400">
                            {item.category}
                            {item.tags.length ? ` | ${item.tags.slice(0, 2).join(" | ")}` : ""}
                          </div>
                        </div>
                        {isSelected ? <Check className="h-4 w-4 text-ocean" /> : null}
                      </button>
                    );
                  })}
                </div>
              ))
            ) : (
              <div className="grid gap-3 px-3 py-6 text-sm">
                <p className="font-semibold text-slate-700 dark:text-slate-100">No matching gear found</p>
                <button type="button" className="button-secondary min-h-10 rounded-lg justify-center" onClick={requestGear}>
                  Request this gear
                </button>
              </div>
            )}
          </div>
        </div>
      ) : null}
    </div>
  );
}

function buildEndpointUrl(endpoint: string, query: string, limit: number) {
  const [path, existingQuery = ""] = endpoint.split("?");
  const params = new URLSearchParams(existingQuery);
  params.set("q", query);
  params.set("limit", String(limit));
  return `${path}?${params.toString()}`;
}
