"use client";

import { useRouter } from "next/navigation";
import { useMemo } from "react";
import {
  extractToneControls,
  formatToneControlName,
  useAnimatedToneControls
} from "@/components/tone-control-animation";
import { brand } from "@/lib/brand";

type SavedToneDetailProps = {
  song: string;
  artist: string;
  part: string;
  mode: string;
  notes: string | null;
  result: Record<string, unknown>;
};

export function SavedToneDetail({ song, artist, part, mode, notes, result }: SavedToneDetailProps) {
  const router = useRouter();
  const controls = useMemo(() => extractToneControls(result), [result]);
  const animatedValues = useAnimatedToneControls(controls, 800);
  const request = useMemo(() => parseSavedToneRequest(result), [result]);

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
              <div className="flex flex-col gap-3 border-b border-neutral-200 pb-6">
            <div className="text-sm font-semibold uppercase tracking-[0.16em] text-slate-500">Saved Tone</div>
            <h1 className="text-4xl font-semibold text-ink">{song}</h1>
            <p className="text-base text-neutral-600">{artist} - {part} - {mode}</p>
            {notes ? <p className="max-w-3xl text-sm leading-6 text-neutral-600">{notes}</p> : null}
            <button type="button" className="button-primary mt-3 w-full max-w-sm" onClick={reAdaptTone}>
              Re-adapt this tone with your current gear
            </button>
          </div>

          <div className="mt-8">
            <div className="mb-5 text-sm font-semibold uppercase tracking-[0.16em] text-slate-500">Your Adapted Tone</div>
            <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
              {Object.entries(controls).map(([name]) => (
                <div key={name} className="rounded-2xl border border-neutral-200 bg-neutral-50 p-5">
                  <div className="flex items-center justify-between">
                    <div className="text-sm font-semibold text-ink">{formatToneControlName(name)}</div>
                    <div className="text-sm font-bold text-ocean">{formatDisplayValue(animatedValues[name] ?? 0)}</div>
                  </div>
                  <div className="mt-4 flex justify-center">
                    <div
                      className="relative h-24 w-24 rounded-full border border-neutral-200 bg-white shadow-inner"
                      style={{
                        background: `conic-gradient(from 225deg, #111827 0deg, #84cc16 ${((animatedValues[name] ?? 0) / 10) * 270}deg, #e5e7eb 0deg)`
                      }}
                    >
                      <div className="absolute inset-3 rounded-full bg-white" />
                      <div
                        className="absolute left-1/2 top-1/2 h-8 w-1.5 -translate-x-1/2 -translate-y-[85%] rounded-full bg-ink"
                        style={{ transform: `translate(-50%, -85%) rotate(${((animatedValues[name] ?? 0) / 10) * 270 - 135}deg)`, transformOrigin: "50% 120%" }}
                      />
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </section>
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
