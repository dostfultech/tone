"use client";

import { useEffect, useMemo, useState } from "react";
import Link from "next/link";
import { Bookmark, Lock, Loader2, Search, Sparkles, Trash2 } from "lucide-react";
import { brand } from "@/lib/brand";
import { createSupabaseBrowserClient } from "@/lib/supabase/browser";

type SavedTone = {
  id: string;
  accuracy?: number;
  song: string;
  artist: string;
  part: string;
  mode: string;
  request: {
    guitar?: string;
    amp?: string;
  };
  result: {
    accuracy?: number;
    targetSettings?: Record<string, number>;
    request?: {
      guitar?: string;
      amp?: string;
    };
  };
};

export function LibraryView() {
  const [tones, setTones] = useState<SavedTone[]>([]);
  const [query, setQuery] = useState("");
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function loadTones() {
      const supabase = createSupabaseBrowserClient();
      if (!supabase) {
        setTones(JSON.parse(localStorage.getItem(`${brand.storagePrefix}_saved_tones`) || "[]"));
        setLoading(false);
        return;
      }

      const { data, error } = await supabase
        .from("saved_tones")
        .select("id, song, artist, part, mode, request, result, created_at")
        .order("created_at", { ascending: false });
      setTones(error ? [] : data || []);
      setLoading(false);
    }

    loadTones();
  }, []);

  const filtered = useMemo(() => {
    const normalized = query.toLowerCase();
    return tones.filter((tone) => `${tone.song} ${tone.artist} ${tone.request?.guitar || ""} ${tone.request?.amp || ""}`.toLowerCase().includes(normalized));
  }, [tones, query]);

  async function removeTone(id: string) {
    const supabase = createSupabaseBrowserClient();
    if (supabase) {
      await supabase.from("saved_tones").delete().eq("id", id);
    }
    const next = tones.filter((tone) => tone.id !== id);
    setTones(next);
    localStorage.setItem(`${brand.storagePrefix}_saved_tones`, JSON.stringify(next));
  }

  return (
    <div className="px-4 pb-16 pt-28 sm:px-6 lg:px-8">
      <div className="mx-auto max-w-[1840px]">
        <div className="mb-12">
          <h1 className="text-5xl font-bold tracking-normal">My Library</h1>
          <p className="mt-5 text-2xl text-neutral-600">Your saved tone research and adaptations</p>
        </div>

        <div className="theme-panel mb-8 p-8">
          <div className="flex flex-col gap-6 lg:flex-row lg:items-center lg:justify-between">
            <div className="flex items-center gap-5">
              <div className="grid h-16 w-16 place-items-center rounded-lg bg-ink text-moss">
                <Lock className="h-8 w-8" />
              </div>
              <div>
                <h2 className="text-2xl font-bold">You have {tones.length} saved {tones.length === 1 ? "tone" : "tones"}</h2>
                <p className="mt-2 text-lg text-neutral-600">Paid access controls saved settings, adaptations, and future exports.</p>
              </div>
            </div>
            <Link href="/plans" className="button-primary min-h-14 rounded-lg px-8 text-lg">
              <Sparkles className="h-5 w-5" />
              View plans
            </Link>
          </div>
        </div>

        <div className="mb-8 flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
          <h2 className="text-3xl font-bold">Saved tones</h2>
          <div className="relative w-full max-w-xl">
            <Search className="absolute left-5 top-1/2 h-5 w-5 -translate-y-1/2 text-neutral-400" />
            <input className="field h-14 rounded-lg pl-12 text-base" value={query} onChange={(event) => setQuery(event.target.value)} placeholder="Search songs, artists, guitars, or amps" />
          </div>
        </div>

        {loading ? (
          <div className="compact-card flex min-h-[360px] items-center justify-center gap-3 p-8 text-neutral-600">
            <Loader2 className="h-5 w-5 animate-spin" />
            Loading saved tones
          </div>
        ) : filtered.length ? (
          <div className="grid gap-6 lg:grid-cols-2">
            {filtered.map((tone) => {
              const request = tone.result?.request || tone.request || {};
              const settings = tone.result?.targetSettings || {};
              return (
                <article key={tone.id} className="compact-card overflow-hidden border-l-4 border-l-ocean p-7">
                  <div className="flex items-start justify-between gap-4">
                    <div className="min-w-0">
                      <div className="inline-flex rounded-md bg-moss px-3 py-1 text-sm font-bold text-ink">
                        {tone.result?.accuracy || tone.accuracy || 0}% match
                      </div>
                      <h3 className="mt-4 truncate text-3xl font-bold">{tone.song}</h3>
                      <p className="mt-1 text-lg text-neutral-600">
                        {tone.artist} - {tone.part}
                      </p>
                    </div>
                    <button type="button" className="button-secondary px-3" aria-label="Delete saved tone" onClick={() => removeTone(tone.id)}>
                      <Trash2 className="h-4 w-4" />
                    </button>
                  </div>
                  <div className="mt-6 grid gap-3 text-base text-neutral-600">
                    <span>{request.guitar || "Guitar not recorded"}</span>
                    <span>{request.amp || "Amp not recorded"}</span>
                  </div>
                  <div className="mt-6 grid grid-cols-2 gap-3 sm:grid-cols-4">
                    {Object.entries(settings)
                      .slice(0, 4)
                      .map(([key, value]) => (
                        <div key={key} className="rounded-lg bg-neutral-100 px-3 py-3 text-center">
                          <div className="text-xs font-semibold capitalize text-neutral-500">{key}</div>
                          <div className="text-xl font-bold">{value}</div>
                        </div>
                      ))}
                  </div>
                </article>
              );
            })}
          </div>
        ) : (
        <div className="grid min-h-[420px] place-items-center rounded-lg border border-dashed border-blue-100 bg-white/80 p-8 text-center">
            <div>
              <div className="mx-auto mb-5 grid h-24 w-24 place-items-center rounded-lg bg-blue-50 text-slate-400">
                <Bookmark className="h-12 w-12" />
              </div>
              <h2 className="text-3xl font-bold">No saved tones yet</h2>
              <p className="mt-3 text-lg text-neutral-600">Generate a tone match and save it to populate this library.</p>
              <Link href="/app" className="button-primary mt-7">
                Match a tone
              </Link>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
