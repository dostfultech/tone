"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { type CSSProperties, FormEvent, useCallback, useEffect, useRef, useState } from "react";
import { AnimatePresence, motion } from "framer-motion";
import {
  BadgeCheck,
  Bookmark,
  ChevronRight,
  ExternalLink,
  Flame,
  Gauge,
  Guitar,
  Info,
  Loader2,
  Music2,
  Search,
  SlidersHorizontal,
  Sparkles,
  Volume2,
  X
} from "lucide-react";
import {
  partOptions,
  toneTypeOptions,
  type SongItem,
  type TonePartType,
  type ToneRequest,
  type ToneType
} from "@/lib/mock-data";
import { brand } from "@/lib/brand";
import { loadClientSubscriptionSnapshot, type ClientSubscriptionSnapshot } from "@/lib/subscription-client";
import { createSupabaseBrowserClient } from "@/lib/supabase/browser";

type ToneResult = {
  id: string;
  request: ToneRequest;
  accuracy: number;
  originalRig: string;
  originalSettings?: Record<string, number>;
  targetSettings: Record<string, number>;
  pickupAdvice: string;
  effects: string[];
  playingTips: string[];
  sourceProfile?: {
    id: string;
    partType: TonePartType;
    toneType: ToneType;
    partLabel: string;
    confidence: number;
    verificationStatus: string;
  } | null;
};

type SongSuggestion = SongItem;

type CatalogEntry = {
  id: string;
  name: string;
  description?: string;
  category?: string;
  details?: string[];
};

const progressSteps = [
  "Searching for this song...",
  "Finding original gear used...",
  "Analyzing amp settings...",
  "Identifying effects chain...",
  "Extracting tone characteristics...",
  "Calibrating settings for your gear...",
  "Finalizing your custom tone..."
];

const trendingTones = [
  { rank: 1, song: "Master of Puppets", artist: "Metallica", count: "25 searches" },
  { rank: 2, song: "Beat It", artist: "Michael Jackson", count: "19 searches" },
  { rank: 3, song: "Sweet Child O' Mine", artist: "Guns N' Roses", count: "14 searches" },
  { rank: 4, song: "Seek & Destroy", artist: "Metallica", count: "13 searches" },
  { rank: 5, song: "Be Quiet and Drive", artist: "Deftones", count: "12 searches" }
];

const AUTO_ADAPT_KEY = `${brand.storagePrefix}_auto_adapt_from_community`;

export function ToneMatcher() {
  const router = useRouter();
  const autoAdaptTriggeredRef = useRef(false);
  const hasLoadedPreferencesRef = useRef(false);
  const resultRef = useRef<HTMLDivElement | null>(null);
  const [mode, setMode] = useState<"guitar" | "bass">("guitar");
  const [song, setSong] = useState("Comfortably Numb");
  const [songDraft, setSongDraft] = useState("Comfortably Numb");
  const [artist, setArtist] = useState("Pink Floyd");
  const [part, setPart] = useState("second solo");
  const [partType, setPartType] = useState<TonePartType>("solo");
  const [toneType, setToneType] = useState<ToneType>("auto");
  const [guitar, setGuitar] = useState("Fender Stratocaster");
  const [amp, setAmp] = useState("Boss Katana Artist");
  const [pickup, setPickup] = useState("Vintage Single Coil");
  const [effectsMode, setEffectsMode] = useState("manual");
  const [goingDirect, setGoingDirect] = useState(false);
  const [selectedFx, setSelectedFx] = useState("ambient-lead");
  const [multiFx, setMultiFx] = useState("Line 6 Helix Floor");
  const [result, setResult] = useState<ToneResult | null>(null);
  const [loading, setLoading] = useState(false);
  const [progress, setProgress] = useState(0);
  const [message, setMessage] = useState("");
  const [songSuggestions, setSongSuggestions] = useState<SongSuggestion[]>([]);
  const [songSearchOpen, setSongSearchOpen] = useState(false);
  const [songSearchLoading, setSongSearchLoading] = useState(false);
  const [highlightedSongIndex, setHighlightedSongIndex] = useState(0);
  const [songSearchTouched, setSongSearchTouched] = useState(false);
  const [subscriptionSnapshot, setSubscriptionSnapshot] = useState<ClientSubscriptionSnapshot | null>(null);
  const [guitarCatalog, setGuitarCatalog] = useState<CatalogEntry[]>([]);
  const [bassGuitarCatalog, setBassGuitarCatalog] = useState<CatalogEntry[]>([]);
  const [ampCatalog, setAmpCatalog] = useState<CatalogEntry[]>([]);
  const [bassAmpCatalog, setBassAmpCatalog] = useState<CatalogEntry[]>([]);
  const [pickupCatalog, setPickupCatalog] = useState<CatalogEntry[]>([]);
  const [pedalCatalog, setPedalCatalog] = useState<CatalogEntry[]>([]);
  const [multiFxCatalog, setMultiFxCatalog] = useState<CatalogEntry[]>([]);

  const runAdaptation = useCallback(
    async (
      payload: ToneRequest,
      options?: {
        multiFx?: string;
        selectedFx?: string;
      }
    ) => {
      setLoading(true);
      setMessage("");
      setProgress(0);
      setResult(null);

      const progressTimer = window.setInterval(() => {
        setProgress((value) => Math.min(progressSteps.length - 1, value + 1));
      }, 350);

      try {
        await fetch(payload.mode === "bass" ? "/api/research-bass-tone" : "/api/research-tone", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify(payload)
        });
        const endpoint =
          payload.mode === "bass"
            ? "/api/adapt-bass-tone"
            : payload.effectsMode === "multi_fx"
              ? "/api/adapt-multi-fx-tone"
              : "/api/adapt-tone";
        const response = await fetch(endpoint, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ ...payload, multiFx: options?.multiFx || multiFx, selectedFx: options?.selectedFx || selectedFx })
        });
        const data = await response.json();
        if (response.status === 401) {
          router.push(`/login?redirect=${encodeURIComponent("/app")}`);
          return;
        }
        if (response.status === 402) {
          const params = new URLSearchParams({
            required: "subscription",
            redirect: "/app",
            source: "generate-tone"
          });
          router.push(`/plans?${params.toString()}`);
          return;
        }
        if (!response.ok) {
          throw new Error(data.error || "Tone adaptation failed.");
        }
        setResult(data.result);
        trackUsage(data.result);
      } catch (error) {
        setMessage(error instanceof Error ? error.message : "The adaptation endpoint did not respond.");
      } finally {
        window.clearInterval(progressTimer);
        setProgress(progressSteps.length - 1);
        window.setTimeout(() => setLoading(false), 350);
      }
    },
    [multiFx, router, selectedFx]
  );

  useEffect(() => {
    const fields = [
      [
        "toneMatch_song",
        (value: string) => {
          setSong(value);
          setSongDraft(value);
        }
      ],
      ["toneMatch_artist", setArtist],
      ["toneMatch_part", setPart],
      ["toneMatch_partType", (value: string) => setPartType(normalizePartType(value))],
      ["toneMatch_toneType", (value: string) => setToneType(normalizeToneType(value))],
      ["toneMatch_guitar", setGuitar],
      ["toneMatch_amp", setAmp],
      ["toneMatch_pickup", setPickup],
      ["toneMatch_multiFx", setMultiFx],
      ["toneMatch_effectsMode", setEffectsMode],
      ["toneMatch_selectedEffects", setSelectedFx]
    ] as const;

    fields.forEach(([key, setter]) => {
      const value = localStorage.getItem(key);
      if (value) {
        setter(value);
      }
    });

    const shouldAutoAdapt = sessionStorage.getItem(AUTO_ADAPT_KEY) === "1";
    if (shouldAutoAdapt && !autoAdaptTriggeredRef.current) {
      autoAdaptTriggeredRef.current = true;
      sessionStorage.removeItem(AUTO_ADAPT_KEY);

      const storedPart = localStorage.getItem("toneMatch_part") || "main part";
      const storedPartType = localStorage.getItem("toneMatch_partType") || "main";
      const storedToneType = localStorage.getItem("toneMatch_toneType") || "auto";
      const storedMode = inferStoredMode(storedPartType, storedToneType);
      const payload: ToneRequest = {
        mode: storedMode,
        song: localStorage.getItem("toneMatch_song") || "Unknown Song",
        artist: localStorage.getItem("toneMatch_artist") || "Unknown Artist",
        part: storedPart,
        partType: normalizePartType(storedPartType, storedPart),
        toneType: normalizeToneType(storedToneType),
        guitar: localStorage.getItem("toneMatch_guitar") || (storedMode === "bass" ? "Fender Precision Bass" : "Fender Stratocaster"),
        amp: localStorage.getItem("toneMatch_amp") || (storedMode === "bass" ? "Ampeg SVT-CL" : "Boss Katana Artist"),
        pickup: localStorage.getItem("toneMatch_pickup") || "Vintage Single Coil",
        effectsMode: localStorage.getItem("toneMatch_effectsMode") || "manual"
      };

      void runAdaptation(payload, {
        multiFx: localStorage.getItem("toneMatch_multiFx") || "Line 6 Helix Floor",
        selectedFx: localStorage.getItem("toneMatch_selectedEffects") || "ambient-lead"
      });
    }

    hasLoadedPreferencesRef.current = true;
  }, [runAdaptation]);

  useEffect(() => {
    if (!hasLoadedPreferencesRef.current) {
      return;
    }

    const persistTimeout = window.setTimeout(() => {
      localStorage.setItem("toneMatch_song", songDraft);
      localStorage.setItem("toneMatch_artist", artist);
      localStorage.setItem("toneMatch_part", part);
      localStorage.setItem("toneMatch_partType", partType);
      localStorage.setItem("toneMatch_toneType", toneType);
      localStorage.setItem("toneMatch_guitar", guitar);
      localStorage.setItem("toneMatch_amp", amp);
      localStorage.setItem("toneMatch_pickup", pickup);
      localStorage.setItem("toneMatch_multiFx", multiFx);
      localStorage.setItem("toneMatch_effectsMode", effectsMode);
      localStorage.setItem("toneMatch_selectedEffects", selectedFx);
    }, 220);

    return () => window.clearTimeout(persistTimeout);
  }, [songDraft, artist, part, partType, toneType, guitar, amp, pickup, multiFx, effectsMode, selectedFx]);

  useEffect(() => {
    const query = songDraft.trim();
    if (!songSearchTouched || query.length < 3) {
      setSongSuggestions([]);
      setSongSearchLoading(false);
      setHighlightedSongIndex(0);
      return;
    }

    const controller = new AbortController();
    setSongSearchLoading(true);

    const timeout = window.setTimeout(async () => {
      try {
        const response = await fetch(`/api/music/search?q=${encodeURIComponent(query)}`, {
          signal: controller.signal
        });
        const data = await response.json();
        const normalizedQuery = query.toLowerCase();
        const results = ((data.results || []) as SongSuggestion[]).filter((item) =>
          `${item.song} ${item.artist} ${item.album || ""}`.toLowerCase().includes(normalizedQuery)
        );
        setSongSuggestions(results);
        setHighlightedSongIndex(0);
      } catch (error) {
        if (!(error instanceof DOMException && error.name === "AbortError")) {
          setSongSuggestions([]);
        }
      } finally {
        setSongSearchLoading(false);
      }
    }, 300);

    return () => {
      window.clearTimeout(timeout);
      controller.abort();
    };
  }, [songDraft, songSearchTouched]);

  useEffect(() => {
    const supabase = createSupabaseBrowserClient();
    if (!supabase) {
      return;
    }
    const client = supabase;

    async function refreshSubscription() {
      setSubscriptionSnapshot(await loadClientSubscriptionSnapshot(client));
    }

    void refreshSubscription();

    const {
      data: { subscription }
    } = client.auth.onAuthStateChange(() => {
      refreshSubscription().catch(() => undefined);
    });

    return () => subscription.unsubscribe();
  }, []);

  useEffect(() => {
    let cancelled = false;

    async function loadCatalog() {
      const [guitarsResponse, bassGuitarsResponse, ampsResponse, bassAmpsResponse, pickupsResponse, pedalsResponse, multiFxResponse] = await Promise.all([
        fetchCatalog("/api/guitars/lookup"),
        fetchCatalog("/api/bass-guitars/lookup"),
        fetchCatalog("/api/amps/lookup"),
        fetchCatalog("/api/bass-amps/lookup"),
        fetchCatalog("/api/pickups/catalog"),
        fetchCatalog("/api/pedals/catalog"),
        fetchCatalog("/api/multi-fx/catalog")
      ]);

      if (cancelled) {
        return;
      }

      const storedGuitar = localStorage.getItem("toneMatch_guitar") || "Fender Stratocaster";
      const storedAmp = localStorage.getItem("toneMatch_amp") || "Boss Katana Artist";
      const storedPickup = localStorage.getItem("toneMatch_pickup") || "Vintage Single Coil";
      const storedSelectedFx = localStorage.getItem("toneMatch_selectedEffects") || "ambient-lead";
      const storedMultiFx = localStorage.getItem("toneMatch_multiFx") || "Line 6 Helix Floor";
      const storedMode = inferStoredMode(localStorage.getItem("toneMatch_partType"), localStorage.getItem("toneMatch_toneType"));

      setGuitarCatalog(guitarsResponse);
      setBassGuitarCatalog(bassGuitarsResponse);
      setAmpCatalog(ampsResponse);
      setBassAmpCatalog(bassAmpsResponse);
      setPickupCatalog(pickupsResponse);
      setPedalCatalog(pedalsResponse);
      setMultiFxCatalog(multiFxResponse);

      if (guitarsResponse.length && storedMode !== "bass" && !guitarsResponse.some((item) => item.name === storedGuitar)) {
        setGuitar(guitarsResponse[0].name);
      }

      if (bassGuitarsResponse.length && storedMode === "bass" && !bassGuitarsResponse.some((item) => item.name === storedGuitar)) {
        setGuitar(bassGuitarsResponse[0].name);
      }

      if (ampsResponse.length && storedMode !== "bass" && !ampsResponse.some((item) => item.name === storedAmp)) {
        setAmp(ampsResponse[0].name);
      }

      if (bassAmpsResponse.length && storedMode === "bass" && !bassAmpsResponse.some((item) => item.name === storedAmp)) {
        setAmp(bassAmpsResponse[0].name);
      }

      if (pickupsResponse.length && !pickupsResponse.some((item) => item.name === storedPickup)) {
        setPickup(pickupsResponse[0].name);
      }

      if (pedalsResponse.length && !pedalsResponse.some((item) => item.name === storedSelectedFx)) {
        setSelectedFx(pedalsResponse[0].name);
      }

      if (multiFxResponse.length && !multiFxResponse.some((item) => item.name === storedMultiFx)) {
        setMultiFx(multiFxResponse[0].name);
      }
    }

    void loadCatalog();

    return () => {
      cancelled = true;
    };
  }, []);

  useEffect(() => {
    if (!result) {
      return;
    }

    window.requestAnimationFrame(() => {
      resultRef.current?.scrollIntoView({ behavior: "smooth", block: "start" });
    });
  }, [result]);

  const currentGuitars = mode === "bass" ? bassGuitarCatalog : guitarCatalog;
  const currentAmps = mode === "bass" ? bassAmpCatalog : ampCatalog;

  useEffect(() => {
    if (currentGuitars.length && !currentGuitars.some((item) => item.name === guitar)) {
      setGuitar(currentGuitars[0].name);
    }

    if (currentAmps.length && !currentAmps.some((item) => item.name === amp)) {
      setAmp(currentAmps[0].name);
    }

    if (pickupCatalog.length && !pickupCatalog.some((item) => item.name === pickup)) {
      setPickup(pickupCatalog[0].name);
    }

    if (pedalCatalog.length && !pedalCatalog.some((item) => item.name === selectedFx)) {
      setSelectedFx(pedalCatalog[0].name);
    }

    if (multiFxCatalog.length && !multiFxCatalog.some((item) => item.name === multiFx)) {
      setMultiFx(multiFxCatalog[0].name);
    }
  }, [amp, currentAmps, currentGuitars, guitar, multiFx, multiFxCatalog, pedalCatalog, pickup, pickupCatalog, selectedFx]);

  function applySongPreset(preset: SongSuggestion) {
    setMode(preset.mode);
    setSong(preset.song);
    setSongDraft(preset.song);
    setArtist(preset.artist);
    setPart(preset.part);
    setPartType(normalizePartType(preset.part, preset.mode === "bass" ? "bassline" : undefined));
    setToneType(preset.mode === "bass" ? "bass_clean" : "auto");
    if (preset.mode === "bass") {
      setGuitar(bassGuitarCatalog[0]?.name || "Fender Precision Bass");
      setAmp(bassAmpCatalog[0]?.name || "Ampeg SVT-CL");
    } else if (mode === "bass") {
      setGuitar(guitarCatalog[0]?.name || "Fender Stratocaster");
      setAmp(ampCatalog[0]?.name || "Boss Katana Artist");
    }
    setSongSearchTouched(false);
    setSongSearchOpen(false);
  }

  function handleSongKeyDown(event: React.KeyboardEvent<HTMLInputElement>) {
    const canOpenSuggestions = songSearchTouched && songDraft.trim().length >= 3;
    if (!songSearchOpen && (event.key === "ArrowDown" || event.key === "Enter")) {
      if (canOpenSuggestions) {
        setSongSearchOpen(true);
      }
      return;
    }

    if (event.key === "ArrowDown") {
      event.preventDefault();
      setHighlightedSongIndex((index) => Math.min(index + 1, Math.max(songSuggestions.length - 1, 0)));
    }

    if (event.key === "ArrowUp") {
      event.preventDefault();
      setHighlightedSongIndex((index) => Math.max(index - 1, 0));
    }

    if (event.key === "Enter" && songSearchOpen && songSuggestions[highlightedSongIndex]) {
      event.preventDefault();
      applySongPreset(songSuggestions[highlightedSongIndex]);
    }

    if (event.key === "Escape") {
      setSongSearchOpen(false);
    }
  }

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const normalizedSong = songDraft.trim() || song.trim() || "Unknown Song";
    setSong(normalizedSong);
    const payload: ToneRequest = { mode, song: normalizedSong, artist, part, partType, toneType, guitar, amp, pickup, effectsMode };
    await runAdaptation(payload);
  }

  function trackUsage(nextResult: ToneResult) {
    const activity = JSON.parse(localStorage.getItem(`${brand.storagePrefix}_recent_activity`) || "[]");
    localStorage.setItem(
      `${brand.storagePrefix}_recent_activity`,
      JSON.stringify([
        { id: nextResult.id, song: nextResult.request.song, artist: nextResult.request.artist, createdAt: new Date().toISOString() },
        ...activity
      ].slice(0, 8))
    );
    const usage = Number(localStorage.getItem(`${brand.storagePrefix}_daily_usage`) || "0");
    localStorage.setItem(`${brand.storagePrefix}_daily_usage`, String(usage + 1));
  }

  async function saveTone() {
    if (!result) {
      return;
    }
    const saved = JSON.parse(localStorage.getItem(`${brand.storagePrefix}_saved_tones`) || "[]");
    localStorage.setItem(`${brand.storagePrefix}_saved_tones`, JSON.stringify([result, ...saved.filter((tone: ToneResult) => tone.id !== result.id)]));
    const response = await fetch("/api/save-tone", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(result)
    }).catch(() => null);
    if (response && !response.ok) {
      const data = await response.json().catch(() => ({}));
      setMessage(data.error || "Tone saved locally, but database save failed.");
      return;
    }
    setMessage("Tone saved to your library.");
  }

  const selectedGuitar = currentGuitars.find((item) => item.name === guitar);
  const selectedAmp = currentAmps.find((item) => item.name === amp);
  const selectedPickup = pickupCatalog.find((item) => item.name === pickup);
  const selectedPreset = pedalCatalog.find((item) => item.name === selectedFx);
  const partChoices = partOptions.filter((option) => mode === "bass" || option.value !== "bassline");
  const toneChoices = toneTypeOptions.filter((option) => {
    if (mode === "bass") return option.value === "auto" || option.value === "bass_clean" || option.value === "bass_drive" || option.value === "clean" || option.value === "distorted";
    return option.value !== "bass_clean" && option.value !== "bass_drive";
  });
  const songsterrUrl = `https://www.songsterr.com/a/wa/search?pattern=${encodeURIComponent(`${songDraft || song} ${artist}`)}`;
  const backingTrackUrl = `https://www.youtube.com/results?search_query=${encodeURIComponent(`${songDraft || song} ${artist} backing track`)}`;
  const selectedSongLabel = songDraft.trim() || song.trim() || "selected song";
  const selectedArtistLabel = artist.trim();
  const songLinkLabel = song.trim() ? `"${song.trim()}"` : "this song";

  return (
    <div className="px-4 pb-14 pt-24 sm:px-6 lg:px-8">
      <div className="mx-auto max-w-[1440px]">
        <section className="theme-panel theme-blue-panel mx-auto max-w-5xl px-6 py-12 text-center lg:py-14">
          <div className="inline-flex items-center gap-2 rounded-md border border-white/80 bg-white/80 px-4 py-2 text-xs font-bold uppercase tracking-[0.14em] text-slate-600 shadow-sm">
            <Sparkles className="h-4 w-4" />
            Gear-matched tone settings
          </div>
          <h1 className="mx-auto mt-7 max-w-4xl text-4xl font-bold leading-tight tracking-normal text-ink sm:text-5xl">
            <span className="block">Shape iconic tones with</span>
            <span className="mt-2 inline-block max-w-full break-words rounded-md bg-moss px-3 py-1 leading-tight text-ink">AI-matched gear</span>
          </h1>
          <p className="mx-auto mt-5 max-w-3xl text-lg leading-8 text-slate-600">{brand.appName} turns song research into clean, playable settings for the guitar, amp, pedals, and modelers you own.</p>
          <div className="mx-auto mt-9 grid w-full max-w-md grid-cols-2 rounded-lg border border-white/80 bg-white/80 p-2 shadow-xl">
            {[
              { value: "guitar", label: "Guitar", icon: Guitar },
              { value: "bass", label: "Bass", icon: Volume2 }
            ].map((item) => {
              const Icon = item.icon;
              const active = mode === item.value;
              return (
                <button
                  key={item.value}
                  type="button"
                  className={`flex min-h-14 items-center justify-center gap-3 rounded-md text-base font-bold transition ${
                    active ? "bg-ink text-white shadow-lg" : "text-slate-700 hover:bg-blue-50"
                  }`}
                  onClick={() => {
                    setMode(item.value as "guitar" | "bass");
                    if (item.value === "bass") {
                      setGuitar(bassGuitarCatalog[0]?.name || "Fender Precision Bass");
                      setAmp(bassAmpCatalog[0]?.name || "Ampeg SVT-CL");
                      setToneType("bass_clean");
                    } else {
                      setGuitar(guitarCatalog[0]?.name || "Fender Stratocaster");
                      setAmp(ampCatalog[0]?.name || "Boss Katana Artist");
                      setToneType("auto");
                    }
                  }}
                >
                  <Icon className="h-5 w-5" />
                  {item.label}
                </button>
              );
            })}
          </div>
        </section>

        <section className="mt-14">
          <div className="mb-6 text-center">
            <div className="inline-flex h-12 w-12 items-center justify-center rounded-lg bg-ink text-moss shadow-lg">
              <Flame className="h-6 w-6" />
            </div>
            <h2 className="mt-3 text-3xl font-bold">Trending This Week</h2>
            <p className="mt-2 text-slate-500">Fast-start ideas from popular tone searches</p>
          </div>
          <div className="grid gap-5 md:grid-cols-2 xl:grid-cols-5">
            {trendingTones.map((item) => (
              <button
                key={item.rank}
                type="button"
                className="compact-card min-h-36 p-6 text-left transition hover:-translate-y-1 hover:border-ocean/40 hover:shadow-xl"
                onClick={() => {
                  setSong(item.song);
                  setArtist(item.artist);
                  setSongSearchTouched(false);
                  setSongSearchOpen(false);
                }}
              >
                <div className="flex items-center gap-4">
                  <span className={`grid h-14 w-14 place-items-center rounded-lg text-2xl font-bold ${item.rank === 1 ? "bg-moss text-ink" : item.rank === 3 ? "bg-ocean text-white" : "bg-ink text-white"}`}>
                    {item.rank}
                  </span>
                  <span className="min-w-0">
                    <span className="block truncate text-xl font-bold">{item.song}</span>
                    <span className="block truncate text-slate-600">{item.artist}</span>
                  </span>
                </div>
                <div className="mt-4 flex items-center gap-2 text-sm font-medium text-slate-500">
                  <Music2 className="h-4 w-4" />
                  {item.count} this week
                </div>
              </button>
            ))}
          </div>
        </section>

        <StepProgress />

        <form onSubmit={submit} className="mt-12 grid gap-10">
          <WorkflowCard step="1" title="Your Gear">
            <div className="grid gap-8">
              <div>
                <label className="label flex items-center gap-2 uppercase tracking-[0.16em]">
                  <Sparkles className="h-4 w-4 text-ocean" />
                  Saved preset
                </label>
                <select className="field mt-3 h-16 text-lg" defaultValue="">
                  <option value="">Select preset or choose manually...</option>
                </select>
              </div>

              <div className="flex items-center gap-4">
                <div className="h-px flex-1 bg-blue-100" />
                <span className="text-sm font-bold uppercase tracking-[0.14em] text-slate-500">or select manually</span>
                <div className="h-px flex-1 bg-blue-100" />
              </div>

              <div className="grid gap-8 lg:grid-cols-2">
                <SelectField label={mode === "bass" ? "Bass archetype" : "Guitar archetype"} value={guitar} onChange={setGuitar} options={currentGuitars.map((item) => item.name)} />
                <div>
                  <div className="mb-2 flex items-center justify-between gap-4">
                    <label className="label">Amplifier</label>
                    <button
                      type="button"
                      aria-pressed={goingDirect}
                      className="flex items-center gap-3 text-sm font-semibold text-slate-600"
                      onClick={() => setGoingDirect((value) => !value)}
                    >
                      Going direct
                      <span className={`flex h-7 w-12 items-center rounded-full p-1 transition ${goingDirect ? "bg-ink" : "bg-slate-300"}`}>
                        <span className={`h-5 w-5 rounded-full bg-white shadow transition ${goingDirect ? "translate-x-5" : ""}`} />
                      </span>
                    </button>
                  </div>
                  <select className="field h-12" value={amp} onChange={(event) => setAmp(event.target.value)}>
                    {currentAmps.map((option) => (
                      <option key={option.id} value={option.name}>
                        {option.name}
                      </option>
                    ))}
                  </select>
                </div>
              </div>

              {mode === "guitar" ? (
                <div>
                  <label className="label" htmlFor="pickup">
                    Pickup
                  </label>
                  <select id="pickup" className="field mt-2 h-12" value={pickup} onChange={(event) => setPickup(event.target.value)}>
                    {pickupCatalog.length ? (
                      pickupCatalog.map((item) => (
                        <option key={item.id} value={item.name}>
                          {item.name} {item.category ? `- ${item.category}` : ""}
                        </option>
                      ))
                    ) : (
                      <option value={pickup}>{pickup || "Loading pickups..."}</option>
                    )}
                  </select>
                </div>
              ) : null}

              <div>
                <label className="label flex items-center gap-2 uppercase tracking-[0.16em]">
                  <BadgeCheck className="h-4 w-4 text-moss" />
                  Selected gear
                </label>
                <div className="mt-4 grid gap-5 lg:grid-cols-2">
                  <GearSummaryCard icon={<Guitar className="h-8 w-8" />} title={guitar} description={selectedGuitar?.description || "Custom instrument selected for this adaptation."} tags={mode === "bass" ? ["bass", "touch-sensitive"] : [selectedPickup?.category || "pickup", "adaptable"]} />
                  <GearSummaryCard icon={<Volume2 className="h-8 w-8" />} title={amp} description={selectedAmp?.description || "Selected amp or modeler for the adapted settings."} tags={goingDirect ? ["direct", "modeler-ready"] : ["amp", "speaker chain"]} />
                </div>
              </div>

              <div className="border-t border-blue-100 pt-8">
                <h3 className="mb-5 text-xl font-bold">Select Your Effects (Optional)</h3>
                <div className="grid rounded-lg border border-white/80 bg-blue-50/80 p-2 shadow-inner md:grid-cols-3">
                  {[
                    ["manual", "Pedals", SlidersHorizontal],
                    ["amp_with_effects", "Amp Effects", Volume2],
                    ["multi_fx", "Multi FX", Sparkles]
                  ].map(([value, label, Icon]) => {
                    const ActiveIcon = Icon as typeof SlidersHorizontal;
                    return (
                      <button
                        key={value as string}
                        type="button"
                        className={`flex min-h-16 items-center justify-center gap-3 rounded-md text-base font-bold transition ${
                          effectsMode === value ? "bg-white text-ink shadow-lg" : "text-slate-700 hover:bg-white/70"
                        }`}
                        onClick={() => setEffectsMode(value as string)}
                      >
                        <ActiveIcon className="h-5 w-5" />
                        {label as string}
                      </button>
                    );
                  })}
                </div>

                {effectsMode === "multi_fx" ? (
                  <div className="theme-blue-panel mt-6 rounded-lg border border-white/80 p-6 shadow-sm">
                    <h4 className="flex items-center gap-3 text-xl font-bold text-ink">
                      <Sparkles className="h-5 w-5" />
                      Multi FX Mode
                    </h4>
                    <p className="mt-2 text-slate-600">{brand.appName} will shape a complete preset for your unit from the tone research.</p>
                    <SelectField label="Select your unit" value={multiFx} onChange={setMultiFx} options={multiFxCatalog.map((unit) => unit.name)} />
                    <div className="mt-4 rounded-lg bg-white/80 p-4 text-sm text-slate-600">Using effects, modulation, delay, and reverb around your selected amp choice.</div>
                  </div>
                ) : (
                  <div className="mt-6 grid gap-4 lg:grid-cols-[minmax(0,1fr)_minmax(260px,0.55fr)]">
                    <SelectField label="Effect preset" value={selectedFx} onChange={setSelectedFx} options={pedalCatalog.map((preset) => preset.name)} />
                    <div className="rounded-lg border border-white/80 bg-blue-50/70 p-4">
                      <div className="text-sm font-bold">{selectedPreset?.name || "Custom chain"}</div>
                      <div className="mt-2 flex flex-wrap gap-2">
                        {(selectedPreset?.details || selectedPreset?.description?.split(" | ") || ["Amp effects"]).map((pedal) => (
                          <span key={pedal} className="rounded-md bg-white px-3 py-1 text-xs font-semibold text-slate-600">
                            {pedal}
                          </span>
                        ))}
                      </div>
                    </div>
                  </div>
                )}
              </div>
            </div>
          </WorkflowCard>

          <WorkflowCard step="2" title="Song & Part">
            <div className="grid gap-8">
              <div>
                <label className="label flex items-center gap-2 uppercase tracking-[0.16em]" htmlFor="song-search">
                  <Music2 className="h-5 w-5 text-ocean" />
                  Search for a song
                </label>
                <div className="relative mt-4">
                  <input
                    id="song-search"
                    className="field h-16 rounded-lg px-5 pr-14 text-xl"
                    value={songDraft}
                    onChange={(event) => {
                      const nextSong = event.target.value;
                      setSongDraft(nextSong);
                      setSongSearchTouched(true);
                      setSongSearchOpen(nextSong.trim().length >= 3);
                    }}
                    onFocus={() => setSongSearchOpen(songSearchTouched && songDraft.trim().length >= 3)}
                    onKeyDown={handleSongKeyDown}
                    onBlur={() => window.setTimeout(() => setSongSearchOpen(false), 140)}
                    placeholder="Search any song..."
                    autoComplete="off"
                    required
                  />
                  {songDraft ? (
                    <button
                      type="button"
                      aria-label="Clear song search"
                      className="absolute right-4 top-1/2 z-10 -translate-y-1/2 rounded-md p-2 text-neutral-400 hover:bg-neutral-100 hover:text-neutral-700"
                      onMouseDown={(event) => event.preventDefault()}
                      onClick={() => {
                        setSongDraft("");
                        setSong("");
                        setArtist("");
                        setPart("");
                        setSongSuggestions([]);
                        setSongSearchTouched(true);
                        setSongSearchOpen(false);
                      }}
                    >
                      <X className="h-5 w-5" />
                    </button>
                  ) : null}

                  {songSearchOpen ? (
                    <div className="absolute left-0 right-0 top-[calc(100%+8px)] z-30 overflow-hidden rounded-lg border border-white/80 bg-white shadow-2xl">
                      <div className="max-h-[420px] overflow-y-auto">
                        {songSearchLoading ? (
                          <div className="flex items-center gap-3 px-5 py-5 text-neutral-500">
                            <Loader2 className="h-5 w-5 animate-spin" />
                            Searching songs
                          </div>
                        ) : songSuggestions.length ? (
                          songSuggestions.map((suggestion, index) => (
                            <button
                              key={suggestion.id}
                              type="button"
                              className={`grid w-full grid-cols-[56px_1fr_auto] items-center gap-4 border-b border-neutral-100 px-5 py-4 text-left transition last:border-b-0 ${
                                highlightedSongIndex === index ? "bg-blue-50" : "bg-white hover:bg-neutral-50"
                              }`}
                              onMouseDown={(event) => event.preventDefault()}
                              onMouseEnter={() => setHighlightedSongIndex(index)}
                              onClick={() => applySongPreset(suggestion)}
                            >
                              <span
                                className="grid h-14 w-14 place-items-center rounded-lg bg-cover bg-center text-lg font-bold text-white shadow-sm"
                                style={{
                                  backgroundColor: suggestion.artworkColor,
                                  backgroundImage: suggestion.artworkUrl ? `url(${suggestion.artworkUrl})` : undefined
                                }}
                              >
                                {suggestion.artworkUrl ? null : suggestion.song.slice(0, 1)}
                              </span>
                              <span className="min-w-0">
                                <span className="block truncate text-lg font-bold text-neutral-950">{suggestion.song}</span>
                                <span className="block truncate text-base text-neutral-700">{suggestion.artist}</span>
                                <span className="block truncate text-sm text-neutral-500">{suggestion.album}</span>
                              </span>
                              <span className="text-sm text-neutral-500">{suggestion.duration}</span>
                            </button>
                          ))
                        ) : (
                          <div className="px-5 py-5 text-sm text-neutral-500">No songs found. You can still type the song and artist manually.</div>
                        )}
                      </div>
                    </div>
                  ) : null}
                </div>
              </div>

              <div className="grid gap-6 lg:grid-cols-2">
                <TextField label="Artist" value={artist} onChange={setArtist} />
                <TextField label="Part to match" value={part} onChange={setPart} placeholder="solo, rhythm, intro, chorus..." />
              </div>

              <SegmentedControl
                label="Part type"
                value={partType}
                options={partChoices}
                onChange={(value) => {
                  setPartType(value as TonePartType);
                  if (!part.trim() || part === "main part" || part === "second solo") {
                    setPart(partLabelFromType(value as TonePartType));
                  }
                }}
              />

              <div className="theme-blue-panel rounded-lg border border-white/80 p-6 shadow-sm">
                <div className="flex flex-wrap items-center gap-3">
                  <Sparkles className="h-5 w-5 text-ink" />
                  <h3 className="text-lg font-bold uppercase tracking-[0.12em]">Tone Type</h3>
                  <span className="rounded-md bg-moss px-4 py-1 text-xs font-bold uppercase text-ink">Recommended</span>
                </div>
                <p className="mt-4 text-lg leading-8 text-slate-700">Specify clean, driven, or auto-detected tone behavior for more accurate gain and effects decisions.</p>
                <div className="mt-6 grid gap-4 md:grid-cols-3">
                  {toneChoices.slice(0, 3).map((option) => (
                    <button
                      key={option.value}
                      type="button"
                      className={`min-h-28 rounded-lg border px-5 py-4 text-lg font-bold transition ${
                        toneType === option.value ? "border-ink bg-white text-ink shadow-lg" : "border-white/80 bg-white/70 text-slate-700 hover:border-ocean/40"
                      }`}
                      onClick={() => setToneType(option.value)}
                    >
                      {option.label}
                    </button>
                  ))}
                </div>
                <div className="mt-4 grid gap-3 sm:grid-cols-2 lg:grid-cols-4">
                  {toneChoices.slice(3).map((option) => (
                    <button
                      key={option.value}
                      type="button"
                      className={`min-h-11 rounded-lg border px-3 py-2 text-sm font-bold transition ${
                        toneType === option.value ? "border-ink bg-ink text-white" : "border-white bg-white/80 text-slate-700 hover:border-ocean/50"
                      }`}
                      onClick={() => setToneType(option.value)}
                    >
                      {option.label}
                    </button>
                  ))}
                </div>
                <div className="mt-5 flex items-center gap-2 rounded-lg border border-white/80 bg-white/80 px-4 py-3 text-sm text-slate-700">
                  <Info className="h-4 w-4 text-ink" />
                  Selecting Clean or Distorted improves accuracy for songs with mixed tones.
                </div>
              </div>

              {!subscriptionSnapshot?.hasAccess ? (
                <div className="theme-blue-panel rounded-lg border border-white/80 p-8 text-center shadow-xl">
                  <p className="text-lg text-slate-700">Need access?</p>
                  <h3 className="mt-2 text-3xl font-bold">Unlock full Tonefex access</h3>
                  <p className="mt-2 text-lg font-semibold text-emerald-700">Choose a plan to unlock full adaptations, tone saving, and presets.</p>
                  <div className="mt-6 flex flex-col items-center justify-center gap-4 sm:flex-row">
                    <Link className="button-primary min-h-14 rounded-lg px-8 text-lg" href="/plans">
                      View Plans
                    </Link>
                    <span className="text-sm font-medium text-slate-600">Manage billing anytime from the customer portal.</span>
                  </div>
                </div>
              ) : null}

              <div className="grid justify-items-center gap-5 text-center">
                <button type="submit" className="button-primary min-h-16 w-full max-w-xl rounded-lg px-8 text-lg shadow-xl" disabled={loading}>
                  {loading ? <Loader2 className="h-5 w-5 animate-spin" /> : <Search className="h-5 w-5" />}
                  Generate My Tone
                </button>
                <p className="max-w-2xl text-sm font-medium text-slate-600">
                  Generate a gear-matched version of {selectedArtistLabel ? `"${selectedSongLabel}" by ${selectedArtistLabel}` : `"${selectedSongLabel}"`} for your setup.
                </p>
                <div className="grid w-full max-w-4xl gap-4 sm:grid-cols-2">
                  <a className="button-secondary min-h-14 rounded-lg text-base" href={songsterrUrl} target="_blank" rel="noreferrer">
                    <ExternalLink className="h-5 w-5" />
                    Open Songsterr Tab for {songLinkLabel}
                  </a>
                  <a className="button-secondary min-h-14 rounded-lg text-base" href={backingTrackUrl} target="_blank" rel="noreferrer">
                    <ExternalLink className="h-5 w-5" />
                    Find Backing Track for {songLinkLabel}
                  </a>
                </div>
              </div>
              {message ? <div className="rounded-lg bg-ink px-4 py-3 text-sm font-bold text-white">{message}</div> : null}
            </div>
          </WorkflowCard>

          <div ref={resultRef}>
            <WorkflowCard step="3" title="Results">
              {result ? <ResultPanel result={result} onSave={saveTone} /> : <EmptySplitResult song={songDraft || song} artist={artist} guitar={guitar} amp={amp} />}
            </WorkflowCard>
          </div>
        </form>
      </div>

      <AnimatePresence>
        {loading ? (
          <motion.div className="fixed inset-0 z-[80] grid place-items-center bg-ink/35 p-4 backdrop-blur-sm" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}>
            <motion.div className="theme-panel w-full max-w-md p-7" initial={{ y: 20, scale: 0.98 }} animate={{ y: 0, scale: 1 }} exit={{ y: 20, scale: 0.98 }}>
              <div className="mx-auto mb-5 grid h-20 w-20 place-items-center rounded-full border border-white/80 bg-white shadow-sm">
                <Loader2 className="h-9 w-9 animate-spin text-ink" />
              </div>
              <div className="text-center text-2xl font-bold">Generating your adapted tone...</div>
              <div className="mt-2 text-center text-sm font-medium text-slate-600">{progressSteps[progress]}</div>
              <div className="mt-5 h-2 overflow-hidden rounded-full bg-blue-100">
                <motion.div className="h-full rounded-full bg-moss" initial={{ width: "8%" }} animate={{ width: `${((progress + 1) / progressSteps.length) * 100}%` }} />
              </div>
            </motion.div>
          </motion.div>
        ) : null}
      </AnimatePresence>
    </div>
  );
}

function inferStoredMode(partType: string | null, toneType: string | null): "guitar" | "bass" {
  if (partType === "bassline") {
    return "bass";
  }

  if (toneType === "bass_clean" || toneType === "bass_drive") {
    return "bass";
  }

  return "guitar";
}

function StepProgress() {
  const steps = [
    ["1", "Your Gear"],
    ["2", "Song & Artist"],
    ["3", "Results"]
  ];

  return (
    <div className="mx-auto mt-16 grid max-w-4xl grid-cols-[1fr_auto_1fr_auto_1fr] items-center gap-5">
      {steps.map(([number, label], index) => (
        <div key={number} className="contents">
          <div className="text-center">
            <div className={`mx-auto grid h-20 w-20 place-items-center rounded-lg border text-3xl font-bold shadow-lg ${index < 2 ? "border-white bg-ink text-white" : "border-white bg-white/70 text-slate-500"}`}>
              {number}
            </div>
            <div className="mt-3 text-lg font-bold text-slate-800">{label}</div>
          </div>
          {index < steps.length - 1 ? (
            <div className="hidden h-1 w-32 rounded-full bg-blue-100 sm:block">
              <div className={`h-full rounded-full ${index === 0 ? "w-full bg-moss" : "w-1/2 bg-blue-200"}`} />
            </div>
          ) : null}
        </div>
      ))}
    </div>
  );
}

function WorkflowCard({ step, title, children }: { step: string; title: string; children: React.ReactNode }) {
  return (
    <section className="theme-panel overflow-hidden">
      <header className="theme-blue-panel flex min-h-32 items-center gap-5 border-b border-white/80 px-9 py-7">
        <div className="grid h-16 w-16 shrink-0 place-items-center rounded-lg bg-ink text-2xl font-bold text-white shadow-lg">{step}</div>
        <h2 className="text-4xl font-bold tracking-normal">{title}</h2>
      </header>
      <div className="p-8 lg:p-12">{children}</div>
    </section>
  );
}

function GearSummaryCard({ icon, title, description, tags }: { icon: React.ReactNode; title: string; description: string; tags: string[] }) {
  return (
    <div className="theme-blue-panel rounded-lg border border-white/80 p-6 shadow-sm">
      <div className="flex gap-5">
        <div className="grid h-16 w-16 shrink-0 place-items-center rounded-lg bg-ink text-moss shadow-lg">{icon}</div>
        <div className="min-w-0">
          <h3 className="truncate text-2xl font-bold">{title}</h3>
          <p className="mt-3 text-base leading-7 text-slate-600">{description}</p>
          <div className="mt-4 flex flex-wrap gap-2">
            {tags.map((tag) => (
              <span key={tag} className="rounded-md border border-white/80 bg-white/80 px-3 py-1 text-sm font-semibold capitalize text-slate-700">
                {tag}
              </span>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

function TextField({ label, value, onChange, placeholder }: { label: string; value: string; onChange: (value: string) => void; placeholder?: string }) {
  return (
    <div>
      <label className="label">{label}</label>
      <input className="field mt-2 h-12" value={value} onChange={(event) => onChange(event.target.value)} placeholder={placeholder} required />
    </div>
  );
}

function SelectField({ label, value, onChange, options }: { label: string; value: string; onChange: (value: string) => void; options: string[] }) {
  return (
    <div>
      <label className="label">{label}</label>
      <select className="field mt-1" value={value} onChange={(event) => onChange(event.target.value)}>
        {options.length ? (
          options.map((option) => (
            <option key={option} value={option}>
              {option}
            </option>
          ))
        ) : (
          <option value={value || ""}>{value || "Loading options..."}</option>
        )}
      </select>
    </div>
  );
}

function SegmentedControl<T extends string>({
  label,
  value,
  options,
  onChange
}: {
  label: string;
  value: T;
  options: Array<{ value: T | string; label: string }>;
  onChange: (value: T | string) => void;
}) {
  return (
    <div>
      <label className="label">{label}</label>
      <div className="mt-2 grid gap-2 sm:grid-cols-4">
        {options.map((option) => {
          const active = value === option.value;
          return (
            <button
              key={option.value}
              type="button"
              className={`min-h-10 rounded-md border px-3 py-2 text-sm font-semibold transition ${
                active ? "border-ink bg-ink text-white" : "border-neutral-200 bg-white text-neutral-700 hover:border-neutral-400"
              }`}
              onClick={() => onChange(option.value)}
            >
              {option.label}
            </button>
          );
        })}
      </div>
    </div>
  );
}

function normalizePartType(value: string, fallback?: string): TonePartType {
  const allowed = partOptions.map((option) => option.value);
  if (allowed.includes(value as TonePartType)) return value as TonePartType;
  const normalized = `${value} ${fallback || ""}`.toLowerCase();
  if (normalized.includes("solo")) return "solo";
  if (normalized.includes("lead")) return "lead";
  if (normalized.includes("riff")) return "riff";
  if (normalized.includes("intro")) return "intro";
  if (normalized.includes("chorus")) return "chorus";
  if (normalized.includes("bass")) return "bassline";
  if (normalized.includes("rhythm")) return "rhythm";
  return "main";
}

function normalizeToneType(value: string): ToneType {
  const allowed = toneTypeOptions.map((option) => option.value);
  return allowed.includes(value as ToneType) ? (value as ToneType) : "auto";
}

async function fetchCatalog(url: string): Promise<CatalogEntry[]> {
  try {
    const response = await fetch(url, { cache: "no-store" });
    const payload = await response.json();
    const results = Array.isArray(payload.results) ? payload.results : [];
    return results.map((item: Record<string, unknown>) => ({
      id: String(item.id || item.name),
      name: String(item.name || ""),
      description: String(item.description || item.category || item.meta || ""),
      category: String(item.category || item.itemType || item.meta || ""),
      details: Array.isArray(item.details)
        ? item.details.map((detail) => String(detail))
        : typeof item.description === "string"
          ? item.description.split(" | ").filter(Boolean)
          : []
    }));
  } catch {
    return [];
  }
}

function partLabelFromType(value: TonePartType) {
  const labels: Record<TonePartType, string> = {
    main: "main part",
    riff: "main riff",
    solo: "solo",
    lead: "lead line",
    rhythm: "rhythm guitar",
    intro: "intro",
    chorus: "chorus",
    bridge: "bridge",
    bassline: "bassline"
  };
  return labels[value];
}

function EmptySplitResult({ song, artist, guitar, amp }: { song: string; artist: string; guitar: string; amp: string }) {
  return (
    <div className="theme-blue-panel grid min-h-[520px] place-items-center rounded-lg border border-white/80 p-8 text-center">
      <div>
        <div className="mx-auto mb-5 grid h-16 w-16 place-items-center rounded-lg bg-ink text-moss shadow-lg">
          <Gauge className="h-8 w-8" />
        </div>
        <h3 className="text-3xl font-bold">Your Adapted Tone</h3>
        <p className="mt-2 text-xl text-slate-600">
          {song || "Choose a song"} {artist ? `by ${artist}` : ""}
        </p>
        <p className="mt-1 text-base text-slate-500">
          {guitar} + {amp}
        </p>
        <div className="mt-20 text-blue-200">
          <Guitar className="mx-auto h-20 w-20" />
        </div>
        <h4 className="mt-8 text-2xl font-bold text-slate-700">Ready to Generate</h4>
        <p className="mx-auto mt-4 max-w-md text-lg leading-8 text-slate-500">Select your gear, choose the song details, and generate the adapted tone when you are ready.</p>
      </div>
    </div>
  );
}

function ResultPanel({ result, onSave }: { result: ToneResult; onSave: () => void }) {
  const targetSettings = Object.entries(result.targetSettings);
  const profile = result.sourceProfile;

  return (
    <motion.article className="overflow-hidden" initial={{ opacity: 0, y: 18 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.35, ease: "easeOut" }}>
      <div className="border-b border-white/80 bg-white/70 p-5">
        <div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
          <div>
            <div className="inline-flex items-center gap-2 rounded-md bg-moss px-3 py-1 text-xs font-bold text-ink">
              <BadgeCheck className="h-4 w-4" />
              {result.accuracy}% tone match
            </div>
            <h2 className="mt-3 text-2xl font-semibold">{result.request.song}</h2>
            <p className="text-sm text-slate-600">
              {result.request.artist} - {result.request.part}
            </p>
            <div className="mt-2 flex flex-wrap gap-2 text-xs font-semibold">
              <span className="rounded-md bg-blue-50 px-2 py-1 capitalize text-slate-700">{profile?.partType || result.request.partType || "main"}</span>
              <span className="rounded-md bg-blue-50 px-2 py-1 capitalize text-slate-700">{(profile?.toneType || result.request.toneType || "auto").replace("_", " ")}</span>
              {profile ? <span className="rounded-md bg-white px-2 py-1 text-ocean">{profile.verificationStatus.replace("_", " ")}</span> : null}
            </div>
            {profile ? <p className="mt-3 text-xs font-semibold text-slate-500">Matched source confidence: {profile.confidence}%</p> : null}
          </div>
          <button
            type="button"
            className="button-primary pointer-events-auto relative z-10"
            onClick={(event) => {
              event.preventDefault();
              event.stopPropagation();
              onSave();
            }}
          >
            <Bookmark className="h-4 w-4" />
            Save tone
          </button>
        </div>
      </div>

      <div className="grid gap-5 p-5">
        <motion.section initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.3, delay: 0.05 }}>
          <SettingsBlock title="Your adapted tone" icon={<Gauge className="h-4 w-4 text-ocean" />} settings={targetSettings} empty="No target settings returned" />
        </motion.section>

        <motion.section className="grid gap-4 lg:grid-cols-2" initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.3, delay: 0.12 }}>
          <InfoBlock icon={<Guitar className="h-4 w-4" />} title="Pickup and touch">
            {result.pickupAdvice}
          </InfoBlock>
          <InfoBlock icon={<SlidersHorizontal className="h-4 w-4" />} title="Effects chain">
            <div className="grid gap-2">
              {result.effects.map((effect) => (
                <div key={effect} className="flex items-center gap-2 text-sm">
                  <ChevronRight className="h-4 w-4 text-copper" />
                  {effect}
                </div>
              ))}
            </div>
          </InfoBlock>
        </motion.section>

        <motion.section initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.3, delay: 0.18 }}>
          <h3 className="mb-3 font-semibold">Playing tips</h3>
          <div className="grid gap-2">
            {result.playingTips.map((tip) => (
              <div key={tip} className="rounded-md border border-white/80 bg-blue-50/70 px-3 py-2 text-sm text-slate-700">
                {tip}
              </div>
            ))}
          </div>
        </motion.section>
      </div>
    </motion.article>
  );
}

function knobStyle(value: number): CSSProperties {
  const boundedValue = Math.max(0, Math.min(10, Number(value) || 0));
  return { "--knob-angle": `${-135 + boundedValue * 27}deg` } as CSSProperties;
}

function SettingsBlock({ title, icon, settings, empty }: { title: string; icon: React.ReactNode; settings: Array<[string, number]>; empty: string }) {
  const [animatedValues, setAnimatedValues] = useState<Record<string, number>>({});

  useEffect(() => {
    let frame = 0;
    const startedAt = performance.now();
    const durationMs = 900;

    const animate = (now: number) => {
      const progress = Math.min((now - startedAt) / durationMs, 1);
      const eased = 1 - Math.pow(1 - progress, 3);
      const nextValues = Object.fromEntries(
        settings.map(([name, value]) => [name, Number((value * eased).toFixed(1))])
      );

      setAnimatedValues(nextValues);

      if (progress < 1) {
        frame = requestAnimationFrame(animate);
      }
    };

    setAnimatedValues({});
    frame = requestAnimationFrame(animate);

    return () => cancelAnimationFrame(frame);
  }, [settings]);

  return (
    <div>
      <h3 className="mb-3 flex items-center gap-2 font-semibold">
        {icon}
        {title}
      </h3>
      {settings.length ? (
        <div className="grid grid-cols-2 gap-3 sm:grid-cols-3">
          {settings.map(([name, value]) => (
            <div key={name} className="rounded-lg border border-white/80 bg-white/90 p-4 text-center shadow-sm transition hover:-translate-y-0.5 hover:shadow-lg">
              <div className="knob-shell mx-auto mb-3 grid h-16 w-16 place-items-center rounded-full" style={knobStyle(animatedValues[name] ?? 0)} aria-label={`${name} ${value}`}>
                <div className="knob h-12 w-12 rounded-full" />
              </div>
              <div className="text-xs capitalize text-slate-500">{name.replace("_", " ")}</div>
              <div className="text-lg font-semibold">{animatedValues[name] ?? 0}</div>
            </div>
          ))}
        </div>
      ) : (
        <div className="rounded-lg border border-dashed border-blue-100 bg-white/80 p-4 text-sm text-slate-500">{empty}</div>
      )}
    </div>
  );
}

function InfoBlock({ icon, title, children }: { icon: React.ReactNode; title: string; children: React.ReactNode }) {
  return (
    <div className="rounded-lg border border-white/80 bg-white/85 p-4 shadow-sm">
      <h3 className="mb-2 flex items-center gap-2 font-semibold text-ink">
        <span className="text-ink">{icon}</span>
        {title}
      </h3>
      <div className="text-sm leading-6 text-slate-700">{children}</div>
    </div>
  );
}
