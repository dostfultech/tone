"use client";

import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { type CSSProperties, FormEvent, useCallback, useEffect, useMemo, useRef, useState } from "react";
import { AnimatePresence, motion } from "framer-motion";
import {
  BadgeCheck,
  Bookmark,
  CheckCircle2,
  ChevronRight,
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
import { getAmpMetadata, getEffectCategories, getInstrumentMetadata } from "@/lib/equipment-metadata";
import { brand } from "@/lib/brand";
import { loadClientSubscriptionSnapshot, type ClientSubscriptionSnapshot } from "@/lib/subscription-client";
import { createSupabaseBrowserClient } from "@/lib/supabase/browser";
import {
  extractToneControls,
  formatToneControlName,
  useAnimatedToneControls
} from "@/components/tone-control-animation";
import { ExpertUpgradeModal } from "@/components/expert-upgrade-modal";
import { FreeAdaptationSummary } from "@/components/free-adaptation-summary";
import { OnboardingProgress } from "@/components/onboarding-progress";

type ToneResult = {
  id: string;
  toneResultId?: string | null;
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

type ToneBackendApiResponse = {
  requestId: string;
  result: {
    masterToneId: string;
    toneType: string;
    settings: Record<string, number>;
    effectsChain: string[];
    multifxParameters: Record<string, number | string | boolean>;
    notes: string[];
    warnings: string[];
    metadata?: Record<string, unknown>;
  };
  source: {
    finalSource: "DATABASE_CACHE" | "RULE_ENGINE";
    cacheStatus: "hit" | "miss";
    cacheHit: boolean;
    cacheMiss: boolean;
    cacheWrite: "not_attempted" | "succeeded" | "failed";
    databaseTimeMs: number;
    ruleEngineTimeMs: number;
    responseTimeMs: number;
    cacheKey: string;
    aiUsed: false;
    openAiCalled: false;
  };
  masterTone: {
    id: string;
    song: string;
    artist: string;
    part: string;
    partType: string;
    toneType: string;
    version: number;
    confidence: number;
    sourceType: "master_tones" | "song_tone_profiles_bridge";
  };
  gear: {
    guitar?: string;
    pickups: string[];
    amp?: string;
    cabinet?: string;
    pedals: string[];
    goingDirect: boolean;
    multiFx?: string;
  };
  tracking?: {
    toneResultId: string | null;
    usageConfirmationRequired: boolean;
    freeAdaptationsRemaining: number | null;
    monthlyAdaptationsRemaining: number | null;
    accessPath: string;
  };
};

type SongSuggestion = SongItem;
type SaveToneOutcome = "synced" | "local" | "redirected";

type SavedToneRecord = {
  id: string;
  accuracy: number;
  song: string;
  artist: string;
  part: string;
  mode: ToneRequest["mode"];
  request: ToneRequest;
  result: ToneResult;
  created_at: string;
};

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
const AUTO_ADAPT_PAYLOAD_KEY = `${brand.storagePrefix}_auto_adapt_payload`;
const LEGACY_DEFAULT_SONG = "Comfortably Numb";
const LEGACY_DEFAULT_ARTIST = "Pink Floyd";
const LEGACY_DEFAULT_PART = "second solo";

export function ToneMatcher() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const onboardingMode = searchParams.get("onboarding") === "1";
  const matcherRedirectTarget = onboardingMode ? "/app?onboarding=1" : "/app";
  const autoAdaptTriggeredRef = useRef(false);
  const hasLoadedPreferencesRef = useRef(false);
  const resultRef = useRef<HTMLDivElement | null>(null);
  const [mode, setMode] = useState<"guitar" | "bass">("guitar");
  const [song, setSong] = useState("");
  const [songDraft, setSongDraft] = useState("");
  const [artist, setArtist] = useState("");
  const [part, setPart] = useState("");
  const [partType, setPartType] = useState<TonePartType>("riff");
  const [toneType, setToneType] = useState<ToneType>("auto");
  const [guitar, setGuitar] = useState("Fender Stratocaster");
  const [amp, setAmp] = useState("Boss Katana Artist");
  const [cabinet, setCabinet] = useState("Mesa/Boogie Rectifier 4x12");
  const [pickup, setPickup] = useState("Vintage Single Coil");
  const [neckPickup, setNeckPickup] = useState("");
  const [middlePickup, setMiddlePickup] = useState("");
  const [bridgePickup, setBridgePickup] = useState("");
  const [effectsMode, setEffectsMode] = useState("manual");
  const [goingDirect, setGoingDirect] = useState(false);
  const [selectedFx, setSelectedFx] = useState("Ambient Lead");
  const [selectedEffects, setSelectedEffects] = useState<string[]>(["10-Band EQ", "TS9 Tube Screamer"]);
  const [multiFx, setMultiFx] = useState("Line 6 Helix Floor");
  const [result, setResult] = useState<ToneResult | null>(null);
  const [loading, setLoading] = useState(false);
  const [progress, setProgress] = useState(0);
  const [message, setMessage] = useState("");
  const [celebrationMessage, setCelebrationMessage] = useState("");
  const [songSuggestions, setSongSuggestions] = useState<SongSuggestion[]>([]);
  const [songSearchOpen, setSongSearchOpen] = useState(false);
  const [songSearchLoading, setSongSearchLoading] = useState(false);
  const [highlightedSongIndex, setHighlightedSongIndex] = useState(0);
  const [songSearchTouched, setSongSearchTouched] = useState(false);
  const [subscriptionSnapshot, setSubscriptionSnapshot] = useState<ClientSubscriptionSnapshot | null>(null);
  const [upgradeModalOpen, setUpgradeModalOpen] = useState(false);
  const [guitarCatalog, setGuitarCatalog] = useState<CatalogEntry[]>([]);
  const [bassGuitarCatalog, setBassGuitarCatalog] = useState<CatalogEntry[]>([]);
  const [ampCatalog, setAmpCatalog] = useState<CatalogEntry[]>([]);
  const [bassAmpCatalog, setBassAmpCatalog] = useState<CatalogEntry[]>([]);
  const [cabinetCatalog, setCabinetCatalog] = useState<CatalogEntry[]>([]);
  const [pickupCatalog, setPickupCatalog] = useState<CatalogEntry[]>([]);
  const [pedalCatalog, setPedalCatalog] = useState<CatalogEntry[]>([]);
  const [multiFxCatalog, setMultiFxCatalog] = useState<CatalogEntry[]>([]);

  const refreshSubscriptionSnapshot = useCallback(async () => {
    const supabase = createSupabaseBrowserClient();
    if (!supabase) {
      return null;
    }

    const nextSnapshot = await loadClientSubscriptionSnapshot(supabase);
    setSubscriptionSnapshot(nextSnapshot);
    return nextSnapshot;
  }, []);

  const confirmSuccessfulAdaptation = useCallback(
    async (toneResultId: string) => {
      const response = await fetch("/api/v1/tones/confirm", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ toneResultId })
      });

      if (!response.ok) {
        return null;
      }

      const data = await response.json();
      const nextSnapshot = await refreshSubscriptionSnapshot();
      const beforeFirstAdaptation = !subscriptionSnapshot?.onboarding.firstAdaptationCompleted;

      if (beforeFirstAdaptation && data.firstAdaptationCompleted) {
        const remaining = typeof data.freeAdaptationsRemaining === "number" ? data.freeAdaptationsRemaining : nextSnapshot?.usage.freeAdaptationsRemaining ?? 0;
        setCelebrationMessage(`Congratulations! Your first tone has been adapted to your gear. You have ${remaining} free adaptations remaining.`);
      }

      return data as {
        freeAdaptationsRemaining: number;
        firstAdaptationCompleted: boolean;
      };
    },
    [refreshSubscriptionSnapshot, subscriptionSnapshot?.onboarding.firstAdaptationCompleted]
  );

  const runAdaptation = useCallback(
    async (
      payload: ToneRequest,
      options?: {
        multiFx?: string;
        selectedFx?: string;
        trigger?: "manual_generate" | "tone_database_adapt_to_my_gear" | "saved_tone_readapt";
      }
    ) => {
      setLoading(true);
      setMessage("");
      setProgress(0);
      setResult(null);
      const trigger = options?.trigger || "manual_generate";

      console.info("[tonefex:adaptation:request]", {
        event: "tone_adaptation_request",
        trigger,
        mode: payload.mode,
        song: payload.song,
        artist: payload.artist,
        targetGear: {
          guitar: payload.guitar,
          amp: payload.amp,
          cabinet: payload.cabinet || null,
          pickup: payload.pickup || null
        },
        customPickups: payload.customPickups || null,
        effectsMode: payload.effectsMode || null,
        goingDirect: Boolean(payload.goingDirect),
        multiFx: payload.multiFx || options?.multiFx || multiFx || null,
        selectedFx: payload.selectedFx || options?.selectedFx || selectedFx || null
      });

      const progressTimer = window.setInterval(() => {
        setProgress((value) => Math.min(progressSteps.length - 1, value + 1));
      }, 350);

      try {
        const endpoint = "/api/v1/tones/adapt";
        const response = await fetch(endpoint, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify(
            buildToneAdaptationApiPayload(payload, {
              goingDirect: payload.goingDirect ?? goingDirect,
              multiFx: payload.multiFx || options?.multiFx || multiFx,
              selectedFx: payload.selectedFx || options?.selectedFx || selectedFx,
              selectedEffects
            })
          )
        });
        const data = await response.json();
        if (response.status === 401) {
          router.push(`/login?redirect=${encodeURIComponent(matcherRedirectTarget)}`);
          return;
        }
        if (response.status === 402) {
          setMessage(data.error?.message || "Upgrade to Expert to continue adapting tones.");
          setUpgradeModalOpen(true);
          return;
        }
        if (!response.ok) {
          throw new Error(data.error?.message || data.error || "Tone adaptation failed.");
        }
        const adapted = mapToneAdaptationApiResponse(payload, data as ToneBackendApiResponse);
        const source = (data as ToneBackendApiResponse).source || {};
        console.info("[tonefex:adaptation:response]", {
          event: "tone_adaptation_response",
          trigger,
          endpoint,
          finalSource: source.finalSource || "UNKNOWN",
          resultPath: source.finalSource === "DATABASE_CACHE" ? "database_cache" : "tone_core_rule_engine",
          cacheStatus: source.cacheStatus || "unknown",
          cacheHit: Boolean(source.cacheHit),
          cacheMiss: Boolean(source.cacheMiss),
          cacheWrite: source.cacheWrite || "unknown",
          databaseCacheUsed: source.finalSource === "DATABASE_CACHE",
          ruleEngineUsed: source.finalSource === "RULE_ENGINE",
          aiFallbackTriggered: false,
          openAiCalled: false,
          openAiSucceeded: false,
          aiResultUsed: false,
          masterToneSource: (data as ToneBackendApiResponse).masterTone?.sourceType || "unknown",
          fallbackReason: null,
          source,
          masterTone: (data as ToneBackendApiResponse).masterTone || null
        });
        setResult(adapted);
        if ((data as ToneBackendApiResponse).tracking?.toneResultId) {
          await confirmSuccessfulAdaptation((data as ToneBackendApiResponse).tracking?.toneResultId as string);
        }
        trackUsage(adapted);
      } catch (error) {
        setMessage(error instanceof Error ? error.message : "The adaptation endpoint did not respond.");
      } finally {
        window.clearInterval(progressTimer);
        setProgress(progressSteps.length - 1);
        window.setTimeout(() => setLoading(false), 350);
      }
    },
    [confirmSuccessfulAdaptation, goingDirect, matcherRedirectTarget, multiFx, router, selectedEffects, selectedFx]
  );

  const runAdaptationRef = useRef(runAdaptation);

  useEffect(() => {
    runAdaptationRef.current = runAdaptation;
  }, [runAdaptation]);

  useEffect(() => {
    if (hasLoadedPreferencesRef.current) {
      return;
    }

    const fields = [
      [
        "toneMatch_partType",
        (value: string) =>
          setPartType((current) => {
            const next = normalizePartType(value);
            return current === next ? current : next;
          })
      ],
      [
        "toneMatch_toneType",
        (value: string) =>
          setToneType((current) => {
            const next = normalizeToneType(value);
            return current === next ? current : next;
          })
      ],
      ["toneMatch_guitar", (value: string) => setGuitar((current) => (current === value ? current : value))],
      ["toneMatch_amp", (value: string) => setAmp((current) => (current === value ? current : value))],
      ["toneMatch_cabinet", (value: string) => setCabinet((current) => (current === value ? current : value))],
      ["toneMatch_pickup", (value: string) => setPickup((current) => (current === value ? current : value))],
      ["toneMatch_neckPickup", (value: string) => setNeckPickup((current) => (current === value ? current : value))],
      ["toneMatch_middlePickup", (value: string) => setMiddlePickup((current) => (current === value ? current : value))],
      ["toneMatch_bridgePickup", (value: string) => setBridgePickup((current) => (current === value ? current : value))],
      ["toneMatch_multiFx", (value: string) => setMultiFx((current) => (current === value ? current : value))],
      ["toneMatch_effectsMode", (value: string) => setEffectsMode((current) => (current === value ? current : value))],
      ["toneMatch_selectedEffects", (value: string) => setSelectedFx((current) => (current === value ? current : value))]
    ] as const;

    fields.forEach(([key, setter]) => {
      const value = localStorage.getItem(key);
      if (value) {
        setter(value);
      }
    });
    setSelectedEffects(readStoredEffectList());

    const storedSong = localStorage.getItem("toneMatch_song") || "";
    const storedArtist = localStorage.getItem("toneMatch_artist") || "";
    const storedPart = localStorage.getItem("toneMatch_part") || "";
    const hasLegacySeed =
      storedSong === LEGACY_DEFAULT_SONG &&
      storedArtist === LEGACY_DEFAULT_ARTIST &&
      storedPart === LEGACY_DEFAULT_PART;

    if (hasLegacySeed) {
      localStorage.removeItem("toneMatch_song");
      localStorage.removeItem("toneMatch_artist");
      localStorage.removeItem("toneMatch_part");
    }

    const shouldAutoAdapt = sessionStorage.getItem(AUTO_ADAPT_KEY) === "1";
    setGoingDirect(localStorage.getItem("toneMatch_goingDirect") === "true" || localStorage.getItem("toneMatch_effectsMode") === "multi_fx");
    if (shouldAutoAdapt && !autoAdaptTriggeredRef.current) {
      autoAdaptTriggeredRef.current = true;
      sessionStorage.removeItem(AUTO_ADAPT_KEY);
      const payloadFromSession = readAutoAdaptPayload();

      const storedPart = payloadFromSession?.part || localStorage.getItem("toneMatch_part") || "main part";
      const storedPartType = payloadFromSession?.partType || localStorage.getItem("toneMatch_partType") || "main";
      const storedToneType = payloadFromSession?.toneType || localStorage.getItem("toneMatch_toneType") || "auto";
      const storedMode =
        payloadFromSession?.mode === "bass" || payloadFromSession?.mode === "guitar"
          ? payloadFromSession.mode
          : inferStoredMode(storedPartType, storedToneType);
      const payload: ToneRequest = {
        mode: storedMode,
        song: payloadFromSession?.song || localStorage.getItem("toneMatch_song") || "Unknown Song",
        artist: payloadFromSession?.artist || localStorage.getItem("toneMatch_artist") || "Unknown Artist",
        part: storedPart,
        partType: normalizePartType(storedPartType, storedPart),
        toneType: normalizeToneType(storedToneType),
        guitar: payloadFromSession?.guitar || localStorage.getItem("toneMatch_guitar") || (storedMode === "bass" ? "Fender Precision Bass" : "Fender Stratocaster"),
        amp: payloadFromSession?.amp || localStorage.getItem("toneMatch_amp") || (storedMode === "bass" ? "Ampeg SVT-CL" : "Boss Katana Artist"),
        cabinet: payloadFromSession?.cabinet || localStorage.getItem("toneMatch_cabinet") || (storedMode === "bass" ? "Ampeg SVT-410HLF" : "Mesa/Boogie Rectifier 4x12"),
        pickup: payloadFromSession?.pickup || localStorage.getItem("toneMatch_pickup") || "Vintage Single Coil",
        effectsMode: payloadFromSession?.effectsMode || localStorage.getItem("toneMatch_effectsMode") || "manual",
        goingDirect: Boolean(payloadFromSession?.goingDirect),
        customPickups: payloadFromSession?.customPickups
      };
      const nextMultiFx = payloadFromSession?.multiFx || localStorage.getItem("toneMatch_multiFx") || "Line 6 Helix Floor";
      const nextSelectedFx = payloadFromSession?.selectedFx || localStorage.getItem("toneMatch_selectedEffects") || "Ambient Lead";

      setMode(payload.mode);
      setSong(payload.song);
      setSongDraft(payload.song);
      setArtist(payload.artist);
      setPart(payload.part);
      setPartType(payload.partType || "main");
      setToneType(payload.toneType || "auto");
      setGuitar(payload.guitar);
      setAmp(payload.amp);
      setCabinet(payload.cabinet || "");
      setPickup(payload.pickup || "");
      setNeckPickup(payload.customPickups?.neck || localStorage.getItem("toneMatch_neckPickup") || "");
      setMiddlePickup(payload.customPickups?.middle || localStorage.getItem("toneMatch_middlePickup") || "");
      setBridgePickup(payload.customPickups?.bridge || localStorage.getItem("toneMatch_bridgePickup") || "");
      setEffectsMode(payload.effectsMode || "manual");
      setGoingDirect(Boolean(payload.goingDirect || payload.effectsMode === "multi_fx"));
      setMultiFx(nextMultiFx);
      setSelectedFx(nextSelectedFx);

      void runAdaptationRef.current(payload, {
        multiFx: nextMultiFx,
        selectedFx: nextSelectedFx,
        trigger: "tone_database_adapt_to_my_gear"
      });
    }

    hasLoadedPreferencesRef.current = true;
  }, []);

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
      localStorage.setItem("toneMatch_cabinet", cabinet);
      localStorage.setItem("toneMatch_pickup", pickup);
      localStorage.setItem("toneMatch_neckPickup", neckPickup);
      localStorage.setItem("toneMatch_middlePickup", middlePickup);
      localStorage.setItem("toneMatch_bridgePickup", bridgePickup);
      localStorage.setItem("toneMatch_multiFx", multiFx);
      localStorage.setItem("toneMatch_effectsMode", effectsMode);
      localStorage.setItem("toneMatch_selectedEffects", selectedFx);
      localStorage.setItem("toneMatch_selectedEffectList", JSON.stringify(selectedEffects));
      localStorage.setItem("toneMatch_goingDirect", goingDirect ? "true" : "false");
    }, 220);

    return () => window.clearTimeout(persistTimeout);
  }, [songDraft, artist, part, partType, toneType, guitar, amp, cabinet, pickup, neckPickup, middlePickup, bridgePickup, multiFx, effectsMode, selectedFx, selectedEffects, goingDirect]);

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

    void refreshSubscriptionSnapshot();

    const {
      data: { subscription }
    } = client.auth.onAuthStateChange(() => {
      refreshSubscriptionSnapshot().catch(() => undefined);
    });

    return () => subscription.unsubscribe();
  }, [refreshSubscriptionSnapshot]);

  useEffect(() => {
    let cancelled = false;

    async function loadCatalog() {
      const [guitarsResponse, bassGuitarsResponse, ampsResponse, bassAmpsResponse, cabinetsResponse, pickupsResponse, pedalsResponse, multiFxResponse] = await Promise.all([
        fetchCatalog("/api/guitars/lookup"),
        fetchCatalog("/api/bass-guitars/lookup"),
        fetchCatalog("/api/amps/lookup"),
        fetchCatalog("/api/bass-amps/lookup"),
        fetchCatalog("/api/cabinets/catalog"),
        fetchCatalog("/api/pickups/catalog"),
        fetchCatalog("/api/pedals/catalog"),
        fetchCatalog("/api/multi-fx/catalog")
      ]);

      if (cancelled) {
        return;
      }

      const storedGuitar = localStorage.getItem("toneMatch_guitar") || "Fender Stratocaster";
      const storedAmp = localStorage.getItem("toneMatch_amp") || "Boss Katana Artist";
      const storedCabinet = localStorage.getItem("toneMatch_cabinet") || "Mesa/Boogie Rectifier 4x12";
      const storedPickup = localStorage.getItem("toneMatch_pickup") || "Vintage Single Coil";
      const storedSelectedFx = localStorage.getItem("toneMatch_selectedEffects") || "Ambient Lead";
      const storedMultiFx = localStorage.getItem("toneMatch_multiFx") || "Line 6 Helix Floor";
      const storedMode = inferStoredMode(localStorage.getItem("toneMatch_partType"), localStorage.getItem("toneMatch_toneType"));

      setGuitarCatalog(guitarsResponse);
      setBassGuitarCatalog(bassGuitarsResponse);
      setAmpCatalog(ampsResponse);
      setBassAmpCatalog(bassAmpsResponse);
      setCabinetCatalog(cabinetsResponse);
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

      if (cabinetsResponse.length && !cabinetsResponse.some((item) => item.name === storedCabinet)) {
        setCabinet(cabinetsResponse[0].name);
      }

      if (pickupsResponse.length && !pickupsResponse.some((item) => item.name === storedPickup)) {
        setPickup(pickupsResponse[0].name);
      }

      if (pedalsResponse.length) {
        const nextSelectedFx = resolveCatalogSelection(storedSelectedFx, pedalsResponse, pedalsResponse[0].name);
        if (nextSelectedFx !== storedSelectedFx || !pedalsResponse.some((item) => item.name === storedSelectedFx)) {
          setSelectedFx(nextSelectedFx);
        }
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

    if (cabinetCatalog.length && !cabinetCatalog.some((item) => item.name === cabinet)) {
      setCabinet(cabinetCatalog[0].name);
    }

    if (pickupCatalog.length && !pickupCatalog.some((item) => item.name === pickup)) {
      setPickup(pickupCatalog[0].name);
    }

    if (pedalCatalog.length && !pedalCatalog.some((item) => item.name === selectedFx)) {
      const nextSelectedFx = resolveCatalogSelection(selectedFx, pedalCatalog, pedalCatalog[0].name);
      setSelectedFx((current) => (current === nextSelectedFx ? current : nextSelectedFx));
    }

    if (multiFxCatalog.length && !multiFxCatalog.some((item) => item.name === multiFx)) {
      setMultiFx(multiFxCatalog[0].name);
    }
  }, [amp, cabinet, cabinetCatalog, currentAmps, currentGuitars, guitar, multiFx, multiFxCatalog, pedalCatalog, pickup, pickupCatalog, selectedFx]);

  useEffect(() => {
    if (mode === "bass") {
      if (partType !== "bassline") {
        setPartType("bassline");
      }
      if (toneType !== "bass_clean" && toneType !== "bass_drive") {
        setToneType("bass_clean");
      }
      return;
    }

    if (partType !== "riff" && partType !== "solo") {
      setPartType("riff");
    }
    if (toneType !== "auto" && toneType !== "clean" && toneType !== "distorted") {
      setToneType("auto");
    }
  }, [mode, partType, toneType]);

  function applySongPreset(preset: SongSuggestion) {
    const nextPartType = normalizePartType(preset.part, preset.mode === "bass" ? "bassline" : undefined);
    setMode(preset.mode);
    setSong(preset.song);
    setSongDraft(preset.song);
    setArtist(preset.artist);
    setPart(preset.part);
    setPartType(preset.mode === "bass" ? "bassline" : nextPartType === "solo" ? "solo" : "riff");
    setToneType(preset.mode === "bass" ? "bass_clean" : "auto");
    if (preset.mode === "bass") {
      setGuitar(bassGuitarCatalog[0]?.name || "Fender Precision Bass");
      setAmp(bassAmpCatalog[0]?.name || "Ampeg SVT-CL");
      setCabinet(cabinetCatalog.find((item) => item.name.includes("Ampeg"))?.name || "Ampeg SVT-410HLF");
    } else if (mode === "bass") {
      setGuitar(guitarCatalog[0]?.name || "Fender Stratocaster");
      setAmp(ampCatalog[0]?.name || "Boss Katana Artist");
      setCabinet(cabinetCatalog.find((item) => !item.name.includes("Ampeg") && !item.name.includes("Darkglass"))?.name || "Mesa/Boogie Rectifier 4x12");
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
    const customPickups = {
      neck: neckPickup || undefined,
      middle: middlePickup || undefined,
      bridge: bridgePickup || undefined
    };
    const payload: ToneRequest = {
      mode,
      song: normalizedSong,
      artist,
      part,
      partType,
      toneType,
      guitar,
      amp,
      cabinet,
      pickup,
      effectsMode,
      multiFx,
      selectedFx: selectedEffects.length ? selectedEffects.join(", ") : selectedFx,
      goingDirect: goingDirect || effectsMode === "multi_fx",
      customPickups: Object.values(customPickups).some(Boolean) ? customPickups : undefined
    };
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

  async function saveTone(): Promise<SaveToneOutcome> {
    if (!result) {
      return "local";
    }
    const saved = JSON.parse(localStorage.getItem(`${brand.storagePrefix}_saved_tones`) || "[]") as Array<SavedToneRecord | ToneResult>;
    const localRecord = toSavedToneRecord(result);
    localStorage.setItem(
      `${brand.storagePrefix}_saved_tones`,
      JSON.stringify([localRecord, ...saved.filter((tone) => getSavedToneId(tone) !== result.id)])
    );
    const response = await fetch("/api/save-tone", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(result)
    }).catch(() => null);
    if (response?.status === 402) {
      router.push(`/plans?required=subscription&redirect=${encodeURIComponent("/app")}`);
      return "redirected";
    }
    if (response && !response.ok) {
      const data = await response.json().catch(() => ({}));
      setMessage(data.error || "Tone saved locally, but database save failed.");
      return "local";
    }
    setMessage("Tone saved to your library.");
    return "synced";
  }

  const selectedGuitar = currentGuitars.find((item) => item.name === guitar);
  const selectedAmp = currentAmps.find((item) => item.name === amp);
  const instrumentMeta = getInstrumentMetadata(guitar, mode, selectedGuitar);
  const ampMeta = getAmpMetadata(goingDirect ? multiFx : amp, goingDirect ? multiFxCatalog.find((item) => item.name === multiFx) || selectedAmp : selectedAmp, goingDirect);
  const effectCategories = getEffectCategories();
  const builtInAmpEffects = ampMeta.features.filter((feature) => ["Reverb", "Delay", "Chorus", "Flanger", "Presets", "Noise Gate"].includes(feature));
  const partChoices = mode === "bass"
    ? partOptions.filter((option) => option.value === "bassline")
    : partOptions.filter((option) => option.value === "riff" || option.value === "solo");
  const toneChoices = mode === "bass"
    ? [
        { value: "bass_clean" as ToneType, label: "Clean" },
        { value: "bass_drive" as ToneType, label: "Distorted" }
      ]
    : toneTypeOptions.filter((option) => option.value === "auto" || option.value === "clean" || option.value === "distorted");
  const selectedSongLabel = songDraft.trim() || song.trim() || "selected song";
  const selectedArtistLabel = artist.trim();

  function addSelectedEffect(effectName: string) {
    if (pedalCatalog.some((item) => item.name === effectName)) {
      setSelectedFx(effectName);
    }
    setSelectedEffects((current) => current.includes(effectName) ? current : [...current, effectName].slice(0, 8));
  }

  function removeSelectedEffect(effectName: string) {
    setSelectedEffects((current) => current.filter((item) => item !== effectName));
  }

  function selectAllActiveEffects() {
    const active = [...builtInAmpEffects, "10-Band EQ", "TS9 Tube Screamer"].filter(Boolean);
    setSelectedEffects(Array.from(new Set(active)).slice(0, 8));
  }

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
                      setCabinet(cabinetCatalog.find((item) => item.name.includes("Ampeg"))?.name || "Ampeg SVT-410HLF");
                      setPartType("bassline");
                      setToneType("bass_clean");
                    } else {
                      setGuitar(guitarCatalog[0]?.name || "Fender Stratocaster");
                      setAmp(ampCatalog[0]?.name || "Boss Katana Artist");
                      setCabinet(cabinetCatalog.find((item) => !item.name.includes("Ampeg") && !item.name.includes("Darkglass"))?.name || "Mesa/Boogie Rectifier 4x12");
                      setPartType((current) => current === "solo" ? "solo" : "riff");
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
                className="compact-card min-h-36 p-6 text-left transition-colors hover:border-ocean/40 hover:shadow-xl"
                onClick={() => {
                  setSong(item.song);
                  setSongDraft(item.song);
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

        {onboardingMode && subscriptionSnapshot?.user && !subscriptionSnapshot.onboarding.firstAdaptationCompleted ? (
          <div className="mt-10">
            <OnboardingProgress currentStep={3} />
          </div>
        ) : null}

        {subscriptionSnapshot?.user ? (
          <div className="mt-10">
            <FreeAdaptationSummary
              remaining={
                subscriptionSnapshot.hasAccess && !subscriptionSnapshot.adaptationAccess.isUnlimited
                  ? subscriptionSnapshot.usage.adaptationsRemaining ?? 0
                  : subscriptionSnapshot.usage.freeAdaptationsRemaining
              }
              limit={
                subscriptionSnapshot.hasAccess && !subscriptionSnapshot.adaptationAccess.isUnlimited
                  ? subscriptionSnapshot.usage.adaptationsUsed + (subscriptionSnapshot.usage.adaptationsRemaining ?? 0)
                  : subscriptionSnapshot.usage.freeAdaptationLimit
              }
              unlimited={subscriptionSnapshot.adaptationAccess.isUnlimited}
              label={subscriptionSnapshot.hasAccess ? "Adaptations Remaining" : undefined}
              helpText={subscriptionSnapshot.hasAccess ? "Your paid usage refreshes each billing cycle." : undefined}
            />
          </div>
        ) : null}

        {celebrationMessage ? (
          <div className="mt-8 rounded-lg border border-emerald-200 bg-emerald-50 px-5 py-4 text-sm font-semibold text-emerald-900">
            {celebrationMessage}
          </div>
        ) : null}

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
                <div>
                  <SelectField label={mode === "bass" ? "Bass archetype" : "Guitar archetype"} value={guitar} onChange={setGuitar} options={currentGuitars.map((item) => item.name)} />
                  <Link href="/contact?kind=gear" className="mt-2 inline-block text-xs font-semibold text-slate-500 hover:text-ink">
                    Can&apos;t find your {mode === "bass" ? "bass" : "guitar"}?
                  </Link>
                </div>
                <div>
                  <div className="mb-2 flex items-center justify-between gap-4">
                    <label className="label">{goingDirect ? "Direct unit" : "Amplifier"}</label>
                    <button
                      type="button"
                      aria-pressed={goingDirect}
                      className="flex items-center gap-3 text-sm font-semibold text-slate-600"
                      onClick={() => {
                        setGoingDirect((value) => {
                          const next = !value;
                          setEffectsMode(next ? "multi_fx" : "manual");
                          return next;
                        });
                      }}
                    >
                      Going direct
                      <span className={`flex h-7 w-12 items-center rounded-full p-1 transition ${goingDirect ? "bg-ink" : "bg-slate-300"}`}>
                        <span className={`h-5 w-5 rounded-full bg-white shadow transition ${goingDirect ? "translate-x-5" : ""}`} />
                      </span>
                    </button>
                  </div>
                  {goingDirect ? (
                    <select className="field h-12" value={multiFx} onChange={(event) => setMultiFx(event.target.value)}>
                      {multiFxCatalog.length ? (
                        multiFxCatalog.map((option) => (
                          <option key={option.id} value={option.name}>
                            {option.name}
                          </option>
                        ))
                      ) : (
                        <option value={multiFx}>{multiFx || "Loading units..."}</option>
                      )}
                    </select>
                  ) : (
                    <select className="field h-12" value={amp} onChange={(event) => setAmp(event.target.value)}>
                      {currentAmps.map((option) => (
                        <option key={option.id} value={option.name}>
                          {option.name}
                        </option>
                      ))}
                    </select>
                  )}
                  <Link href="/contact?kind=gear" className="mt-2 inline-block text-xs font-semibold text-slate-500 hover:text-ink">
                    Can&apos;t find your {goingDirect ? "unit" : "amp"}?
                  </Link>
                </div>
              </div>

              {mode === "guitar" ? (
                <div className="rounded-lg border border-white/80 bg-blue-50/70 p-5">
                  <div className="mb-4 flex items-center justify-between gap-4">
                    <div>
                      <h3 className="text-lg font-bold">Custom Pickups</h3>
                      <p className="mt-1 text-sm text-slate-600">Leave stock positions blank, or override each pickup position independently.</p>
                    </div>
                    <button
                      type="button"
                      className="text-xs font-bold text-slate-500 hover:text-ink"
                      onClick={() => {
                        setNeckPickup("");
                        setMiddlePickup("");
                        setBridgePickup("");
                      }}
                    >
                      Clear
                    </button>
                  </div>
                  <div className="grid gap-4 md:grid-cols-3">
                    <PickupOverrideSelect label="Neck" value={neckPickup} onChange={setNeckPickup} options={pickupCatalog} />
                    <PickupOverrideSelect label="Middle" value={middlePickup} onChange={setMiddlePickup} options={pickupCatalog} />
                    <PickupOverrideSelect label="Bridge" value={bridgePickup} onChange={setBridgePickup} options={pickupCatalog} />
                  </div>
                </div>
              ) : null}

              <div>
                <label className="label flex items-center gap-2 uppercase tracking-[0.16em]">
                  <BadgeCheck className="h-4 w-4 text-moss" />
                  Selected gear
                </label>
                <div className="mt-4 grid gap-5 lg:grid-cols-2">
                  <GearSummaryCard icon={<Guitar className="h-8 w-8" />} title={guitar} description={instrumentMeta.description} tags={instrumentMeta.tags} />
                  <GearSummaryCard icon={<Volume2 className="h-8 w-8" />} title={goingDirect ? multiFx : amp} description={ampMeta.description} tags={ampMeta.tags} />
                </div>
              </div>

              <div className="border-t border-blue-100 pt-8">
                <h3 className="mb-5 text-xl font-bold">Select Your Effects (Optional)</h3>
                <div className="grid rounded-lg border border-white/80 bg-blue-50/80 p-2 shadow-inner md:grid-cols-2">
                  {[
                    ["manual", "Pedals", SlidersHorizontal],
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
                        onClick={() => {
                          const nextMode = value as string;
                          setEffectsMode((current) => (current === nextMode ? current : nextMode));
                          if (nextMode === "multi_fx") {
                            setGoingDirect(true);
                          } else {
                            setGoingDirect(false);
                          }
                        }}
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
                    <div className="mt-4 rounded-lg bg-white/80 p-4 text-sm text-slate-600">Using amp modeling, cab simulation, modulation, delay, and reverb around your selected direct unit.</div>
                  </div>
                ) : (
                  <div className="mt-6 grid gap-4">
                    <div className="rounded-lg border border-moss/50 bg-moss/10 px-4 py-3 text-sm font-semibold text-ink">
                      Tip: switch to Multi FX mode for complete amp models, cab simulation, and preset translation.
                    </div>
                    <div className="theme-blue-panel rounded-lg border border-white/80 p-4">
                      <div className="mb-3 flex items-center justify-between gap-4">
                        <h4 className="text-sm font-bold uppercase tracking-[0.12em] text-slate-500">Built-in amp effects</h4>
                        <button type="button" className="text-xs font-bold text-ocean hover:text-ink" onClick={selectAllActiveEffects}>
                          Select all active
                        </button>
                      </div>
                      <div className="flex flex-wrap gap-2">
                        {(builtInAmpEffects.length ? builtInAmpEffects : ["Reverb", "Delay", "Chorus"]).map((effect) => (
                          <button
                            key={effect}
                            type="button"
                            className={`rounded-md border px-3 py-1 text-xs font-bold transition ${
                              selectedEffects.includes(effect) ? "border-ocean bg-white text-ink shadow-sm" : "border-white/80 bg-white/70 text-slate-600 hover:border-ocean/40"
                            }`}
                            onClick={() => addSelectedEffect(effect)}
                          >
                            {effect}
                          </button>
                        ))}
                      </div>
                    </div>
                    <SelectField
                      label="Effect preset"
                      value={selectedFx}
                      onChange={addSelectedEffect}
                      options={pedalCatalog.map((preset) => preset.name)}
                    />
                    <div className="flex min-h-[112px] flex-col rounded-lg border border-white/80 bg-blue-50/70 p-4">
                      <div className="flex items-center justify-between gap-4">
                        <div className="text-sm font-bold">Your Pedals</div>
                        <div className="text-xs font-semibold text-slate-500">{selectedEffects.length} active</div>
                      </div>
                      <div className="mt-3 flex flex-1 flex-wrap content-start gap-2 overflow-hidden">
                        {selectedEffects.length ? (
                          selectedEffects.map((effect) => (
                            <button
                              key={effect}
                              type="button"
                              className="rounded-md border border-ocean/30 bg-white px-3 py-1 text-xs font-semibold text-slate-700 shadow-sm hover:border-ink"
                              onClick={() => removeSelectedEffect(effect)}
                            >
                              {effect} x
                            </button>
                          ))
                        ) : (
                          <span className="text-sm text-slate-500">No pedals selected.</span>
                        )}
                      </div>
                      <div className="mt-4 flex flex-wrap gap-2 border-t border-white/80 pt-3">
                        {effectCategories.slice(0, 12).map((category) => (
                          <span key={category} className="rounded-md bg-white/80 px-2 py-1 text-[11px] font-bold text-slate-500">
                            {category}
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
                        setPartType("main");
                        setToneType(mode === "bass" ? "bass_clean" : "auto");
                        setSongSuggestions([]);
                        setSongSearchTouched(true);
                        setSongSearchOpen(false);
                        localStorage.removeItem("toneMatch_song");
                        localStorage.removeItem("toneMatch_artist");
                        localStorage.removeItem("toneMatch_part");
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
                <div className={`mt-6 grid gap-4 ${mode === "bass" ? "md:grid-cols-2" : "md:grid-cols-3"}`}>
                  {toneChoices.map((option) => (
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
                <div className="mt-5 flex items-center gap-2 rounded-lg border border-white/80 bg-white/80 px-4 py-3 text-sm text-slate-700">
                  <Info className="h-4 w-4 text-ink" />
                  Selecting Clean or Distorted improves accuracy for songs with mixed tones.
                </div>
              </div>

              <div className="grid justify-items-center gap-5 text-center">
                <button type="submit" className="button-primary min-h-16 w-full max-w-xl rounded-lg px-8 text-lg shadow-xl" disabled={loading}>
                  {loading ? <Loader2 className="h-5 w-5 animate-spin" /> : <Search className="h-5 w-5" />}
                  Generate My Tone
                </button>
                <p className="max-w-2xl text-sm font-medium text-slate-600">
                  Generate a gear-matched version of {selectedArtistLabel ? `"${selectedSongLabel}" by ${selectedArtistLabel}` : `"${selectedSongLabel}"`} for your setup.
                </p>
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

      <ExpertUpgradeModal open={upgradeModalOpen} onClose={() => setUpgradeModalOpen(false)} redirect={matcherRedirectTarget} />

      <AnimatePresence>
        {loading ? (
          <motion.div className="fixed inset-0 z-[80] grid place-items-center bg-ink/35 p-4" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}>
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

function readAutoAdaptPayload() {
  try {
    const raw = sessionStorage.getItem(AUTO_ADAPT_PAYLOAD_KEY);
    if (!raw) {
      return null;
    }

    sessionStorage.removeItem(AUTO_ADAPT_PAYLOAD_KEY);
    return JSON.parse(raw) as Partial<ToneRequest> & {
      song?: string;
      artist?: string;
      part?: string;
      partType?: string;
      toneType?: string;
      guitar?: string;
      amp?: string;
      cabinet?: string;
      pickup?: string;
      effectsMode?: string;
      multiFx?: string;
      selectedFx?: string;
      goingDirect?: boolean;
      customPickups?: ToneRequest["customPickups"];
    };
  } catch {
    sessionStorage.removeItem(AUTO_ADAPT_PAYLOAD_KEY);
    return null;
  }
}

function readStoredEffectList() {
  try {
    const parsed = JSON.parse(localStorage.getItem("toneMatch_selectedEffectList") || "[]");
    if (Array.isArray(parsed)) {
      const effects = parsed.filter((item): item is string => typeof item === "string" && item.trim().length > 0);
      if (effects.length) return effects.slice(0, 8);
    }
  } catch {
    // Ignore corrupt local preference data.
  }

  return ["10-Band EQ", "TS9 Tube Screamer"];
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
      <select
        className="field mt-1"
        value={value}
        onChange={(event) => {
          const nextValue = event.target.value;
          if (nextValue !== value) {
            onChange(nextValue);
          }
        }}
      >
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

function PickupOverrideSelect({ label, value, onChange, options }: { label: string; value: string; onChange: (value: string) => void; options: CatalogEntry[] }) {
  return (
    <div>
      <label className="label">{label}</label>
      <select className="field mt-2 h-12" value={value} onChange={(event) => onChange(event.target.value)}>
        <option value="">Stock</option>
        {options.map((item) => (
          <option key={item.id} value={item.name}>
            {item.name}
          </option>
        ))}
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

function resolveCatalogSelection(value: string, catalog: CatalogEntry[], fallback: string) {
  return catalog.find((item) => item.name === value || item.id === value)?.name || fallback;
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

function buildToneAdaptationApiPayload(
  payload: ToneRequest,
  options: {
    goingDirect: boolean;
    multiFx: string;
    selectedFx: string;
    selectedEffects: string[];
  }
) {
  const pickups = payload.customPickups
    ? [
        payload.customPickups.neck ? { name: payload.customPickups.neck, position: "neck" as const } : null,
        payload.customPickups.middle ? { name: payload.customPickups.middle, position: "middle" as const } : null,
        payload.customPickups.bridge ? { name: payload.customPickups.bridge, position: "bridge" as const } : null
      ].filter(Boolean)
    : payload.pickup
      ? [{ name: payload.pickup, position: "primary" as const }]
      : [];

  const pedalNames = Array.from(
    new Set(
      [
        ...options.selectedEffects,
        ...(options.selectedEffects.length ? [] : payload.selectedFx ? payload.selectedFx.split(",").map((value) => value.trim()) : []),
        ...(options.selectedFx ? [options.selectedFx] : [])
      ].filter((value) => value && value.trim().length > 0)
    )
  ).slice(0, 8);

  return {
    song: payload.song,
    artist: payload.artist,
    part: payload.part,
    partType: payload.partType,
    toneType: normalizeBackendToneType(payload.toneType),
    mode: payload.mode,
    guitar: payload.guitar,
    pickups,
    amp: payload.amp,
    cabinet: payload.cabinet,
    pedals: pedalNames.map((name, index) => ({ name, order: index + 1 })),
    goingDirect: options.goingDirect,
    multiFx: options.goingDirect ? options.multiFx : undefined,
    effectsMode: payload.effectsMode,
    selectedFx: options.selectedFx
  };
}

function mapToneAdaptationApiResponse(payload: ToneRequest, response: ToneBackendApiResponse): ToneResult {
  const originalSettings = toUiToneSettings(recordValue(response.result.metadata?.initialSettings));
  const targetSettings = toUiToneSettings(response.result.settings || {});
  const pickupNames = payload.customPickups
    ? [payload.customPickups.neck, payload.customPickups.middle, payload.customPickups.bridge].filter(Boolean)
    : payload.pickup
      ? [payload.pickup]
      : [];
  const pickupAdvice =
    pickupNames.length > 0
      ? `Adapted around ${pickupNames.join(", ")}. Start there, then fine-tune gain and presence by ear on your rig.`
      : "Use your selected pickup position first, then fine-tune gain and treble by ear on your rig.";

  return {
    id: response.requestId,
    toneResultId: response.tracking?.toneResultId || null,
    request: payload,
    accuracy: response.masterTone.confidence,
    originalRig: `${response.masterTone.song} by ${response.masterTone.artist}`,
    originalSettings,
    targetSettings,
    pickupAdvice,
    effects: response.result.effectsChain || [],
    playingTips: [...(response.result.notes || []), ...(response.result.warnings || [])].slice(0, 6),
    sourceProfile: {
      id: response.masterTone.id,
      partType: normalizePartType(response.masterTone.partType, response.masterTone.part),
      toneType: normalizeUiToneType(response.masterTone.toneType),
      partLabel: response.masterTone.part,
      confidence: response.masterTone.confidence,
      verificationStatus:
        response.masterTone.sourceType === "master_tones" ? "normalized_master_tone" : "legacy_song_tone_profile"
    }
  };
}

function toUiToneSettings(settings: Record<string, unknown>) {
  return Object.fromEntries(
    [
      ["gain", numberValue(settings.gain)],
      ["bass", numberValue(settings.bass)],
      ["mids", numberValue(settings.middle) ?? numberValue(settings.mids)],
      ["treble", numberValue(settings.treble)],
      ["presence", numberValue(settings.presence)],
      ["reverb", numberValue(settings.reverb)],
      ["delay", numberValue(settings.delay)],
      ["compression", numberValue(settings.compression)],
      ["master", numberValue(settings.masterVolume) ?? numberValue(settings.master)]
    ].filter((entry): entry is [string, number] => typeof entry[1] === "number")
  );
}

function normalizeBackendToneType(value?: string) {
  if (value === "auto" || !value) {
    return "auto_detect";
  }

  return value;
}

function normalizeUiToneType(value: string): ToneType {
  switch (value) {
    case "auto_detect":
      return "auto";
    case "edge_of_breakup":
    case "classic_rock":
      return "crunch";
    case "heavy":
    case "metal":
    case "modern_metal":
      return "high_gain";
    default:
      return normalizeToneType(value);
  }
}

function recordValue(value: unknown) {
  return value && typeof value === "object" && !Array.isArray(value) ? (value as Record<string, unknown>) : {};
}

function numberValue(value: unknown) {
  if (typeof value === "number" && Number.isFinite(value)) {
    return value;
  }

  if (typeof value === "string" && value.trim().length > 0) {
    const parsed = Number(value);
    return Number.isFinite(parsed) ? parsed : undefined;
  }

  return undefined;
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

function toSavedToneRecord(result: ToneResult): SavedToneRecord {
  return {
    id: result.id,
    accuracy: result.accuracy,
    song: result.request.song || "Unknown Song",
    artist: result.request.artist || "Unknown Artist",
    part: result.request.part || "main part",
    mode: result.request.mode,
    request: result.request,
    result,
    created_at: new Date().toISOString()
  };
}

function getSavedToneId(tone: SavedToneRecord | ToneResult) {
  return tone.id || ("result" in tone ? tone.result?.id : undefined);
}

function ResultPanel({ result, onSave }: { result: ToneResult; onSave: () => Promise<SaveToneOutcome> }) {
  const profile = result.sourceProfile;
  const [saveState, setSaveState] = useState<"idle" | "saving" | "saved" | "local">("idle");
  const [saveBurstKey, setSaveBurstKey] = useState(0);
  const isSaving = saveState === "saving";
  const isSaved = saveState === "saved" || saveState === "local";
  const saveLabel = saveState === "saving" ? "Saving..." : saveState === "local" ? "Saved locally" : saveState === "saved" ? "Saved in Library" : "Save tone";

  useEffect(() => {
    setSaveState("idle");
    setSaveBurstKey(0);
  }, [result.id]);

  async function handleSave() {
    if (isSaving) {
      return;
    }

    setSaveState("saving");
    const outcome = await onSave();
    if (outcome === "redirected") {
      return;
    }

    setSaveState(outcome === "local" ? "local" : "saved");
    setSaveBurstKey((key) => key + 1);
    window.setTimeout(() => {
      setSaveState((current) => (current === "saving" ? current : "idle"));
    }, 2600);
  }

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
          <div className="flex flex-col items-start gap-2 sm:items-end">
            <motion.button
              type="button"
              className={`pointer-events-auto relative z-10 inline-flex min-h-12 min-w-36 items-center justify-center gap-2 overflow-hidden rounded-md px-5 py-2 text-sm font-bold shadow-[0_16px_34px_rgba(8,7,26,0.22)] transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ocean focus-visible:ring-offset-2 ${
                isSaved ? "bg-emerald-600 text-white hover:bg-emerald-700" : "bg-ink text-white hover:bg-black"
              } ${isSaving ? "cursor-wait opacity-95" : ""}`}
              disabled={isSaving}
              whileHover={{ y: isSaving ? 0 : -1 }}
              whileTap={{ scale: isSaving ? 1 : 0.94, y: isSaving ? 0 : 2 }}
              onClick={(event) => {
                event.preventDefault();
                event.stopPropagation();
                void handleSave();
              }}
            >
              <AnimatePresence>
                {isSaved ? (
                  <motion.span
                    key={`save-burst-${saveBurstKey}`}
                    className="absolute inset-0 bg-white/20"
                    initial={{ scale: 0, opacity: 0.6 }}
                    animate={{ scale: 1.8, opacity: 0 }}
                    exit={{ opacity: 0 }}
                    transition={{ duration: 0.55, ease: "easeOut" }}
                  />
                ) : null}
              </AnimatePresence>
              {saveState === "saving" ? <Loader2 className="h-4 w-4 animate-spin" /> : isSaved ? <CheckCircle2 className="h-4 w-4" /> : <Bookmark className="h-4 w-4" />}
              <span className="relative">{saveLabel}</span>
            </motion.button>
            <AnimatePresence>
              {isSaved ? (
                <motion.div
                  className="inline-flex items-center gap-1.5 rounded-md border border-emerald-200 bg-emerald-50 px-3 py-1 text-xs font-bold text-emerald-700 shadow-sm"
                  initial={{ opacity: 0, y: -4, scale: 0.96 }}
                  animate={{ opacity: 1, y: 0, scale: 1 }}
                  exit={{ opacity: 0, y: -4, scale: 0.96 }}
                  transition={{ duration: 0.18 }}
                  aria-live="polite"
                >
                  <CheckCircle2 className="h-3.5 w-3.5" />
                  {saveState === "local" ? "Saved on this device" : "Added to your library"}
                </motion.div>
              ) : null}
            </AnimatePresence>
          </div>
        </div>
      </div>

      <div className="grid gap-5 p-5">
        <motion.section initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.3, delay: 0.05 }}>
          <SettingsBlock title="Your adapted tone" icon={<Gauge className="h-4 w-4 text-ocean" />} settings={result.targetSettings} empty="No target settings returned" />
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

function SettingsBlock({ title, icon, settings, empty }: { title: string; icon: React.ReactNode; settings: Record<string, number>; empty: string }) {
  const hasSettings = Object.keys(settings).length > 0;
  const controls = useMemo(() => (hasSettings ? extractToneControls({ targetSettings: settings }) : {}), [hasSettings, settings]);
  const animatedValues = useAnimatedToneControls(controls, 900);
  const entries = Object.entries(controls);

  return (
    <div>
      <h3 className="mb-3 flex items-center gap-2 font-semibold">
        {icon}
        {title}
      </h3>
      {entries.length ? (
        <div className="grid grid-cols-2 gap-3 sm:grid-cols-3">
          {entries.map(([name, value]) => {
            const animatedValue = animatedValues[name] ?? 0;

            return (
              <div key={name} className="rounded-lg border border-white/80 bg-white/90 p-4 text-center shadow-sm transition-shadow hover:shadow-lg">
                <div className="knob-shell mx-auto mb-3 grid h-16 w-16 place-items-center rounded-full" style={knobStyle(animatedValue)} aria-label={`${formatToneControlName(name)} ${value}`}>
                  <div className="knob h-12 w-12 rounded-full" />
                </div>
                <div className="text-xs text-slate-500">{formatToneControlName(name)}</div>
                <div className="text-lg font-semibold">{formatDisplayValue(animatedValue)}</div>
              </div>
            );
          })}
        </div>
      ) : (
        <div className="rounded-lg border border-dashed border-blue-100 bg-white/80 p-4 text-sm text-slate-500">{empty}</div>
      )}
    </div>
  );
}

function formatDisplayValue(value: number) {
  return Number.isInteger(value) ? value : value.toFixed(1);
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
