"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useEffect, useMemo, useState } from "react";
import { Bookmark, Loader2, Search, Sparkles, Trash2 } from "lucide-react";
import { brand } from "@/lib/brand";
import {
  loadClientSubscriptionSnapshot,
  type ClientSubscriptionSnapshot
} from "@/lib/subscription-client";
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
  const router = useRouter();
  const [tones, setTones] = useState<SavedTone[]>([]);
  const [snapshot, setSnapshot] = useState<ClientSubscriptionSnapshot | null>(null);
  const [query, setQuery] = useState("");
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function loadView() {
      const supabase = createSupabaseBrowserClient();
      if (!supabase) {
        setTones(JSON.parse(localStorage.getItem(`${brand.storagePrefix}_saved_tones`) || "[]"));
        setLoading(false);
        return;
      }

      const [subscriptionSnapshot, toneResult] = await Promise.all([
        loadClientSubscriptionSnapshot(supabase),
        supabase.from("saved_tones").select("id, song, artist, part, mode, request, result, created_at").order("created_at", { ascending: false })
      ]);

      setSnapshot(subscriptionSnapshot);
      setTones(toneResult.error ? [] : toneResult.data || []);
      setLoading(false);
    }

    void loadView();
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

  function openTone(id: string) {
    router.push(`/library/${id}`);
  }

  return (
    <div className="px-4 pb-14 pt-24 sm:px-6 lg:px-8">
      <div className="mx-auto max-w-[1440px]">
        <div className="mb-10">
          <h1 className="text-4xl font-bold tracking-normal sm:text-5xl">My Library</h1>
          <p className="mt-4 text-lg text-neutral-600 sm:text-xl">Your saved tone research and adaptations</p>
        </div>

        <div className="theme-panel mb-8 p-6 sm:p-8">
          <div className="flex flex-col gap-6 lg:flex-row lg:items-center lg:justify-between">
            <div className="flex items-center gap-5">
              <div className="grid h-16 w-16 place-items-center rounded-lg bg-ink text-moss">
                <Bookmark className="h-8 w-8" />
              </div>
              <div>
                <h2 className="text-2xl font-bold">You have {tones.length} saved {tones.length === 1 ? "tone" : "tones"}</h2>
                <p className="mt-2 text-base text-neutral-600 sm:text-lg">
                  {snapshot?.hasAccess
                    ? `${snapshot.planName} plan - ${snapshot.usage.savedTonesRemaining === null ? "Unlimited saves remaining" : `${snapshot.usage.savedTonesRemaining} saves remaining this cycle`}`
                    : "Upgrade to keep your tone library synced across sessions."}
                </p>
              </div>
            </div>
            {snapshot?.hasAccess ? (
              <div className="rounded-lg border border-neutral-200 bg-neutral-50 px-5 py-4 text-sm text-neutral-700">
                <div className="font-semibold text-ink">Current plan: {snapshot.planName}</div>
                <div className="mt-1">
                  Adaptations: {snapshot.usage.adaptationsRemaining === null ? "Unlimited remaining" : `${snapshot.usage.adaptationsRemaining} remaining`}
                </div>
              </div>
            ) : (
              <Link href="/plans" className="button-primary min-h-12 rounded-lg px-6 text-base">
                <Sparkles className="h-5 w-5" />
                View plans
              </Link>
            )}
          </div>
        </div>

        <div className="mb-8 flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
          <h2 className="text-2xl font-bold sm:text-3xl">Saved tones</h2>
          <div className="relative w-full max-w-xl">
            <Search className="absolute left-5 top-1/2 h-5 w-5 -translate-y-1/2 text-neutral-400" />
            <input className="field h-12 rounded-lg pl-12 text-base" value={query} onChange={(event) => setQuery(event.target.value)} placeholder="Search songs, artists, guitars, or amps" />
          </div>
        </div>

        {loading ? (
          <div className="compact-card flex min-h-[320px] items-center justify-center gap-3 p-8 text-neutral-600">
            <Loader2 className="h-5 w-5 animate-spin" />
            Loading saved tones
          </div>
        ) : filtered.length ? (
          <div className="grid gap-6 lg:grid-cols-2">
            {filtered.map((tone) => {
              const request = tone.result?.request || tone.request || {};
              const settings = tone.result?.targetSettings || {};

              return (
                <article key={tone.id} className="compact-card overflow-hidden border-l-4 border-l-ocean p-6">
                  <div className="flex items-start justify-between gap-4">
                    <button type="button" className="min-w-0 flex-1 text-left" onClick={() => openTone(tone.id)}>
                      <div className="inline-flex rounded-md bg-moss px-3 py-1 text-sm font-bold text-ink">
                        {tone.result?.accuracy || tone.accuracy || 0}% match
                      </div>
                      <h3 className="mt-4 truncate text-2xl font-bold sm:text-3xl">{tone.song}</h3>
                      <p className="mt-1 text-base text-neutral-600 sm:text-lg">
                        {tone.artist} - {tone.part}
                      </p>
                    </button>
                    <button type="button" className="button-secondary px-3" aria-label="Delete saved tone" onClick={() => removeTone(tone.id)}>
                      <Trash2 className="h-4 w-4" />
                    </button>
                  </div>

                  <button type="button" className="mt-6 block w-full text-left" onClick={() => openTone(tone.id)}>
                    <div className="grid gap-3 text-base text-neutral-600">
                      <span>{request.guitar || "Guitar not recorded"}</span>
                      <span>{request.amp || "Amp not recorded"}</span>
                    </div>
                    <div className="mt-6 grid grid-cols-2 gap-3 sm:grid-cols-4">
                      {Object.entries(settings)
                        .slice(0, 4)
                        .map(([key, value]) => (
                          <div key={key} className="rounded-lg bg-neutral-100 px-3 py-3 text-center transition hover:bg-neutral-200">
                            <div className="text-xs font-semibold capitalize text-neutral-500">{key}</div>
                            <div className="text-xl font-bold">{value}</div>
                          </div>
                        ))}
                    </div>
                    <div className="mt-5 text-sm font-semibold text-ocean">Open tone details</div>
                  </button>
                </article>
              );
            })}
          </div>
        ) : (
          <div className="grid min-h-[360px] place-items-center rounded-lg border border-dashed border-blue-100 bg-white/80 p-8 text-center">
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
