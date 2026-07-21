"use client";

import { useRouter } from "next/navigation";
import { useMemo } from "react";
import {
  BadgeCheck,
  ChevronRight,
  Gauge,
  Guitar,
  Info,
  Music2,
  SlidersHorizontal
} from "lucide-react";
import { AmpSettingsKnobs } from "@/components/amp-settings-knobs";
import { brand } from "@/lib/brand";

type SavedToneDetailProps = {
  song: string;
  artist: string;
  part: string;
  mode: string;
  notes: string | null;
  result: Record<string, unknown>;
};

type Presentation = {
  original: {
    song: string;
    artist: string;
    partLabel: string;
    toneType: string;
    genre: string | null;
    difficulty: { level: string; description: string } | null;
    gear: { guitar: string | null; pickups: string | null; amp: string | null; cab: string | null };
    notes: string | null;
    settings: Record<string, number>;
    guitarControls: { volume: number; tone: number };
    signalChainText: string | null;
    pedalsUsed: Array<{ name: string; type: string; importance: string; role: string }>;
    ampEffects: Array<{ effect: string; level: number }>;
    sources: Array<{ type: string; title: string; url: string | null }>;
  };
  adapted: {
    gearSummary: string;
    pickupChoice: { recommendation: string; reason: string } | null;
    ampConfiguration: { recommendedPreset: string; reason: string } | null;
    settings: Record<string, number>;
    guitarControls: { volume: number; tone: number };
    signalChain: string[];
    ampEffectsSettings: Array<{ effect: string; level: number | null; note: string }>;
    missingEffects: Array<{ name: string; type: string; importance: string; description: string; substitution: string | null }>;
    playingNotes: string[];
  };
  confidence: { score: number; factors: string[] };
};

const IMPORTANCE_BADGE_CLASSES: Record<string, string> = {
  important: "border-amber-200 bg-amber-50 text-amber-800",
  recommended: "border-ocean/30 bg-ocean/10 text-ocean",
  "nice-to-have": "border-slate-200 bg-slate-50 text-slate-600"
};

export function SavedToneDetail({ song, artist, part, mode, notes, result }: SavedToneDetailProps) {
  const router = useRouter();
  const request = useMemo(() => parseSavedToneRequest(result), [result]);
  const presentation = (result.presentation || null) as Presentation | null;
  const accuracy = typeof result.accuracy === "number" ? result.accuracy : 0;
  const targetSettings = (result.targetSettings || {}) as Record<string, number>;
  const originalSettings = (result.originalSettings || {}) as Record<string, number>;
  const pickupAdvice = typeof result.pickupAdvice === "string" ? result.pickupAdvice : "";
  const effects = Array.isArray(result.effects) ? (result.effects as string[]) : [];
  const playingTips = Array.isArray(result.playingTips) ? (result.playingTips as string[]) : [];

  function reAdaptTone() {
    if (!request.song || !request.artist) {
      return;
    }

    const inferredPartType =
      request.partType || ((request.part || part).toLowerCase().includes("bass") ? "bassline" : "main");

    const payload = {
      song: request.song,
      artist: request.artist,
      part: request.part || part,
      partType: inferredPartType,
      toneType: request.toneType || "auto",
      guitar: request.guitar,
      amp: request.amp,
      cabinet: request.cabinet,
      pickup: request.pickup,
      effectsMode: request.effectsMode || "manual",
      mode: mode === "bass" ? "bass" : "guitar",
      multiFx: request.multiFx,
      selectedFx: request.selectedFx,
      goingDirect: request.goingDirect,
      customPickups: request.customPickups
    };

    sessionStorage.setItem(`${brand.storagePrefix}_auto_adapt_payload`, JSON.stringify(payload));
    sessionStorage.setItem(`${brand.storagePrefix}_auto_adapt_from_community`, "1");
    router.push("/app");
  }

  return (
    <section className="section py-10">
      <div className="mx-auto max-w-6xl">
        <div className="rounded-3xl border border-neutral-200 bg-white p-8 shadow-soft">
          {/* Header */}
          <div className="flex flex-col gap-3 border-b border-neutral-200 pb-6">
            <div className="flex flex-wrap items-center gap-3">
              <div className="text-sm font-semibold uppercase tracking-[0.16em] text-slate-500">Saved Tone</div>
              {accuracy > 0 ? (
                <span className="inline-flex items-center gap-1.5 rounded-md bg-moss px-3 py-1 text-xs font-bold text-ink">
                  <BadgeCheck className="h-3.5 w-3.5" />
                  {Math.round(accuracy)}% tone match
                </span>
              ) : null}
            </div>
            <h1 className="text-4xl font-semibold text-ink">{song}</h1>
            <p className="text-base text-neutral-600">{artist} - {part} - {mode}</p>
            {notes ? <p className="max-w-3xl text-sm leading-6 text-neutral-600">{notes}</p> : null}
            <button type="button" className="button-primary mt-3 w-full max-w-sm" onClick={reAdaptTone}>
              Re-adapt this tone with your current gear
            </button>
          </div>

          {/* Full presentation view */}
          {presentation ? (
            <FullPresentationView
              presentation={presentation}
              targetSettings={targetSettings}
              originalSettings={originalSettings}
            />
          ) : (
            <SimpleToneView
              targetSettings={targetSettings}
              pickupAdvice={pickupAdvice}
              effects={effects}
              playingTips={playingTips}
            />
          )}
        </div>
      </div>
    </section>
  );
}

function FullPresentationView({
  presentation,
  targetSettings,
  originalSettings
}: {
  presentation: Presentation;
  targetSettings: Record<string, number>;
  originalSettings: Record<string, number>;
}) {
  const original = presentation.original;
  const adapted = presentation.adapted;
  const hasOriginalGear = Boolean(original.gear.guitar || original.gear.pickups || original.gear.amp || original.gear.cab || original.notes);
  const origSettings = Object.keys(original.settings).length ? original.settings : originalSettings;
  const adaptSettings = Object.keys(adapted.settings || {}).length ? adapted.settings : targetSettings;

  return (
    <div className="mt-8 grid gap-8 lg:grid-cols-2">
      {/* ORIGINAL TONE — left column */}
      <div className="grid content-start gap-5">
        <div className="flex items-center gap-3">
          <div className="grid h-9 w-9 place-items-center rounded-lg bg-ink text-moss">
            <Music2 className="h-4 w-4" />
          </div>
          <div>
            <h3 className="text-lg font-bold text-ink">Original Tone</h3>
            <p className="text-sm text-slate-600">{original.song} by {original.artist}</p>
          </div>
        </div>

        {hasOriginalGear ? (
          <ResultCard title="Original Gear" icon={<Guitar className="h-3.5 w-3.5" />}>
            <div className="grid gap-2">
              {original.gear.guitar ? <GearSpecRow label="Guitar" value={original.gear.guitar} /> : null}
              {original.gear.pickups ? <GearSpecRow label="Pickups" value={original.gear.pickups} /> : null}
              {original.gear.amp ? <GearSpecRow label="Amp" value={original.gear.amp} /> : null}
              {original.gear.cab ? <GearSpecRow label="Cab" value={original.gear.cab} /> : null}
              {original.notes ? (
                <div className="mt-2 rounded-md border border-slate-200 bg-slate-50/80 px-3 py-2 text-sm leading-6 text-slate-600">{original.notes}</div>
              ) : null}
            </div>
          </ResultCard>
        ) : null}

        {original.difficulty ? (
          <ResultCard title="Difficulty" icon={<Gauge className="h-3.5 w-3.5" />}>
            <div className="flex items-center gap-2">
              <span className="rounded-md bg-ink px-2 py-1 text-xs font-bold capitalize text-moss">{original.difficulty.level}</span>
              <span className="rounded-md bg-blue-50 px-2 py-1 text-xs font-semibold capitalize text-slate-700">{original.partLabel}</span>
            </div>
            <p className="mt-2 text-sm leading-6 text-slate-600">{original.difficulty.description}</p>
          </ResultCard>
        ) : null}

        {Object.keys(origSettings).length ? (
          <div>
            <h3 className="mb-3 flex items-center gap-2 font-semibold">
              <Gauge className="h-4 w-4 text-ocean" />
              Amp settings — original
            </h3>
            <AmpSettingsKnobs settings={origSettings} empty="No original settings available" />
          </div>
        ) : null}

        <ResultCard title="Guitar Controls" icon={<SlidersHorizontal className="h-3.5 w-3.5" />}>
          <GuitarControlsRow controls={original.guitarControls} />
        </ResultCard>

        {original.signalChainText || original.pedalsUsed.length || original.ampEffects.length ? (
          <ResultCard title="Effects & Pedals — original" icon={<SlidersHorizontal className="h-3.5 w-3.5" />}>
            {original.signalChainText ? (
              <p className="rounded-md border border-slate-200 bg-slate-50/80 px-3 py-2 text-sm font-semibold leading-6 text-slate-700">{original.signalChainText}</p>
            ) : null}
            {original.pedalsUsed.length ? (
              <div className="mt-3 grid gap-2">
                {original.pedalsUsed.map((pedal) => (
                  <div key={pedal.name} className="rounded-md border border-slate-200 bg-white px-3 py-2">
                    <div className="flex items-center justify-between gap-2">
                      <span className="text-sm font-bold text-ink">{pedal.name}</span>
                      <ImportanceBadge importance={pedal.importance} />
                    </div>
                    <p className="mt-1 text-xs text-slate-500">{pedal.role}</p>
                  </div>
                ))}
              </div>
            ) : null}
            {original.ampEffects.length ? (
              <div className="mt-3 flex flex-wrap gap-2">
                {original.ampEffects.map((entry) => (
                  <span key={entry.effect} className="rounded-md border border-ocean/30 bg-ocean/10 px-2 py-1 text-xs font-semibold text-ocean">
                    {entry.effect} level {formatDisplayValue(entry.level)}
                  </span>
                ))}
              </div>
            ) : null}
          </ResultCard>
        ) : null}

        {original.sources.length ? (
          <ResultCard title="Sources" icon={<Info className="h-3.5 w-3.5" />}>
            <div className="grid gap-2">
              {original.sources.map((source) => (
                <div key={source.title} className="rounded-md border border-slate-200 bg-slate-50/80 px-3 py-2 text-sm">
                  {source.url ? (
                    <a href={source.url} target="_blank" rel="noreferrer" className="font-semibold text-ocean hover:underline">
                      {source.title}
                    </a>
                  ) : (
                    <span className="text-slate-700">{source.title}</span>
                  )}
                  <span className="ml-2 text-xs capitalize text-slate-400">{source.type.replace(/_/g, " ")}</span>
                </div>
              ))}
            </div>
          </ResultCard>
        ) : null}
      </div>

      {/* YOUR ADAPTED TONE — right column */}
      <div className="grid content-start gap-5">
        <div className="flex items-center gap-3">
          <div className="grid h-9 w-9 place-items-center rounded-lg bg-ocean text-white">
            <Gauge className="h-4 w-4" />
          </div>
          <div>
            <h3 className="text-lg font-bold text-ink">Your Adapted Tone</h3>
            <p className="text-sm text-slate-600">{adapted.gearSummary}</p>
          </div>
        </div>

        {adapted.pickupChoice ? (
          <ResultCard title="Pickup Choice" icon={<Guitar className="h-3.5 w-3.5" />}>
            <p className="text-sm font-bold text-ink">{adapted.pickupChoice.recommendation}</p>
            <p className="mt-1 text-sm text-slate-600">{adapted.pickupChoice.reason}</p>
          </ResultCard>
        ) : null}

        {adapted.ampConfiguration ? (
          <ResultCard title="Amp Configuration" icon={<SlidersHorizontal className="h-3.5 w-3.5" />}>
            <p className="text-xs font-bold uppercase tracking-wide text-slate-500">Recommended preset</p>
            <p className="mt-1 text-sm font-bold text-ocean">{adapted.ampConfiguration.recommendedPreset}</p>
            <p className="mt-1 text-sm text-slate-600">{adapted.ampConfiguration.reason}</p>
          </ResultCard>
        ) : null}

        <div>
          <h3 className="mb-3 flex items-center gap-2 font-semibold">
            <Gauge className="h-4 w-4 text-ocean" />
            Amp settings — adapted
          </h3>
          <AmpSettingsKnobs settings={adaptSettings} empty="No adapted settings returned" />
        </div>

        <ResultCard title="Guitar Controls" icon={<SlidersHorizontal className="h-3.5 w-3.5" />}>
          <GuitarControlsRow controls={adapted.guitarControls} />
        </ResultCard>

        {adapted.signalChain.length ? (
          <ResultCard title="Signal Chain" icon={<ChevronRight className="h-3.5 w-3.5" />}>
            <div className="flex flex-wrap items-center gap-1.5">
              {adapted.signalChain.map((node, index) => (
                <span key={`${node}-${index}`} className="inline-flex items-center gap-1.5">
                  {index > 0 ? <ChevronRight className="h-3.5 w-3.5 text-copper" /> : null}
                  <span className={`rounded-md px-2 py-1 text-xs font-bold ${index === 0 ? "bg-ink text-white" : "border border-slate-200 bg-slate-50 text-slate-700"}`}>
                    {node}
                  </span>
                </span>
              ))}
            </div>
          </ResultCard>
        ) : null}

        {adapted.ampEffectsSettings.length ? (
          <ResultCard title="Amp Effects Settings" icon={<SlidersHorizontal className="h-3.5 w-3.5" />}>
            <div className="grid gap-2 sm:grid-cols-2">
              {adapted.ampEffectsSettings.map((entry) => (
                <div key={entry.effect} className="rounded-md border border-slate-200 bg-white px-3 py-2">
                  <div className="flex items-center justify-between gap-2">
                    <span className="text-sm font-bold text-ink">{entry.effect}</span>
                    {entry.level != null ? <span className="text-sm font-bold text-ocean">{formatDisplayValue(entry.level)}/10</span> : null}
                  </div>
                  <p className="mt-1 text-xs leading-5 text-slate-500">{entry.note}</p>
                </div>
              ))}
            </div>
          </ResultCard>
        ) : null}

        {adapted.missingEffects.length ? (
          <ResultCard title="Missing Effects" icon={<Info className="h-3.5 w-3.5" />}>
            <div className="grid gap-2">
              {adapted.missingEffects.map((effect) => (
                <div key={effect.name} className="rounded-md border border-amber-100 bg-amber-50/60 px-3 py-2">
                  <div className="flex items-center justify-between gap-2">
                    <span className="text-sm font-bold text-ink">{effect.name}</span>
                    <ImportanceBadge importance={effect.importance} />
                  </div>
                  <p className="mt-1 text-sm leading-6 text-slate-600">{effect.description}</p>
                  {effect.substitution ? <p className="mt-1 text-xs font-semibold text-ocean">{effect.substitution}</p> : null}
                </div>
              ))}
            </div>
          </ResultCard>
        ) : null}

        {adapted.playingNotes.length ? (
          <ResultCard title="Playing Notes" icon={<Music2 className="h-3.5 w-3.5" />}>
            <div className="grid gap-2">
              {adapted.playingNotes.map((note) => (
                <div key={note} className="rounded-md border border-white/80 bg-blue-50/70 px-3 py-2 text-sm leading-6 text-slate-700">
                  {note}
                </div>
              ))}
            </div>
          </ResultCard>
        ) : null}

        {presentation.confidence.factors.length ? (
          <ResultCard title="Confidence Notes" icon={<Info className="h-3.5 w-3.5" />}>
            <div className="mb-2 flex items-center gap-2">
              <span className="text-sm font-bold text-ink">{Math.round(presentation.confidence.score)}%</span>
              <span className="text-xs text-slate-500">confidence score</span>
            </div>
            <div className="grid gap-1.5">
              {presentation.confidence.factors.map((factor) => (
                <p key={factor} className="text-xs leading-5 text-slate-500">{factor}</p>
              ))}
            </div>
          </ResultCard>
        ) : null}
      </div>
    </div>
  );
}

function SimpleToneView({
  targetSettings,
  pickupAdvice,
  effects,
  playingTips
}: {
  targetSettings: Record<string, number>;
  pickupAdvice: string;
  effects: string[];
  playingTips: string[];
}) {
  return (
    <div className="mt-8 grid gap-5">
      <div>
        <h3 className="mb-3 flex items-center gap-2 font-semibold">
          <Gauge className="h-4 w-4 text-ocean" />
          Your Adapted Tone
        </h3>
        <AmpSettingsKnobs settings={targetSettings} empty="No target settings returned" />
      </div>

      {pickupAdvice ? (
        <ResultCard title="Pickup and touch" icon={<Guitar className="h-3.5 w-3.5" />}>
          <p className="text-sm leading-6 text-slate-700">{pickupAdvice}</p>
        </ResultCard>
      ) : null}

      {effects.length ? (
        <ResultCard title="Effects chain" icon={<SlidersHorizontal className="h-3.5 w-3.5" />}>
          <div className="grid gap-2">
            {effects.map((effect) => (
              <div key={effect} className="flex items-center gap-2 text-sm">
                <ChevronRight className="h-4 w-4 text-copper" />
                {effect}
              </div>
            ))}
          </div>
        </ResultCard>
      ) : null}

      {playingTips.length ? (
        <div>
          <h3 className="mb-3 font-semibold">Playing tips</h3>
          <div className="grid gap-2">
            {playingTips.map((tip) => (
              <div key={tip} className="rounded-md border border-white/80 bg-blue-50/70 px-3 py-2 text-sm text-slate-700">
                {tip}
              </div>
            ))}
          </div>
        </div>
      ) : null}
    </div>
  );
}

function ResultCard({ title, icon, children }: { title: string; icon?: React.ReactNode; children: React.ReactNode }) {
  return (
    <div className="rounded-lg border border-white/80 bg-white/80 p-4 shadow-sm">
      <h4 className="flex items-center gap-2 text-xs font-bold uppercase tracking-[0.12em] text-slate-500">
        {icon}
        {title}
      </h4>
      <div className="mt-3">{children}</div>
    </div>
  );
}

function GearSpecRow({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex gap-3 text-sm">
      <span className="w-16 shrink-0 font-semibold text-slate-500">{label}</span>
      <span className="text-slate-700">{value}</span>
    </div>
  );
}

function GuitarControlsRow({ controls }: { controls: { volume: number; tone: number } }) {
  return (
    <div className="grid grid-cols-2 gap-3">
      <div className="rounded-md border border-slate-200 bg-slate-50 px-3 py-2">
        <p className="text-[11px] font-bold uppercase tracking-wide text-slate-500">Volume</p>
        <p className="text-lg font-bold text-ink">{formatDisplayValue(controls.volume)}</p>
      </div>
      <div className="rounded-md border border-slate-200 bg-slate-50 px-3 py-2">
        <p className="text-[11px] font-bold uppercase tracking-wide text-slate-500">Tone</p>
        <p className="text-lg font-bold text-ink">{formatDisplayValue(controls.tone)}</p>
      </div>
    </div>
  );
}

function ImportanceBadge({ importance }: { importance: string }) {
  return (
    <span className={`rounded-md border px-2 py-0.5 text-[11px] font-bold ${IMPORTANCE_BADGE_CLASSES[importance] ?? IMPORTANCE_BADGE_CLASSES["nice-to-have"]}`}>
      {importance.replace(/-/g, " ")}
    </span>
  );
}

function parseSavedToneRequest(value: Record<string, unknown>) {
  const request = (value.request || {}) as Record<string, unknown>;
  const toText = (input: unknown, fallback: string) => (typeof input === "string" && input.trim().length > 0 ? input.trim() : fallback);
  const toOptionalText = (input: unknown) => (typeof input === "string" && input.trim().length > 0 ? input.trim() : undefined);

  return {
    song: toText(request.song, ""),
    artist: toText(request.artist, ""),
    part: toText(request.part, ""),
    partType: toOptionalText(request.partType),
    toneType: toOptionalText(request.toneType),
    guitar: toText(request.guitar, "Fender Stratocaster"),
    amp: toText(request.amp, "Boss Katana Artist"),
    cabinet: toOptionalText(request.cabinet),
    pickup: toOptionalText(request.pickup),
    effectsMode: toOptionalText(request.effectsMode),
    multiFx: toOptionalText(request.multiFx),
    selectedFx: toOptionalText(request.selectedFx),
    goingDirect: request.goingDirect === true,
    customPickups: request.customPickups && typeof request.customPickups === "object" && !Array.isArray(request.customPickups)
      ? request.customPickups as { neck?: string; middle?: string; bridge?: string }
      : undefined
  };
}

function formatDisplayValue(value: number) {
  return Number.isInteger(value) ? value : value.toFixed(1);
}
