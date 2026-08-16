"use client";

import { useState } from "react";
import { CheckCircle2, Loader2, ThumbsDown, ThumbsUp } from "lucide-react";
import { trackEvent } from "@/lib/analytics";

export type ToneAccuracyFeedbackPayload = {
  songTitle: string;
  artistName: string;
  partLabel?: string | null;
  toneType?: string | null;
  guitarName?: string | null;
  ampName?: string | null;
  goingDirect?: boolean;
  multiFxName?: string | null;
  pedalNames?: string[];
  adaptedSettings?: Record<string, number>;
  confidenceShown?: number | null;
  verificationStatus?: string | null;
};

const DIRECTIONS: Array<{ value: string; label: string }> = [
  { value: "too_bright", label: "Too bright" },
  { value: "too_dark", label: "Too dark / muddy" },
  { value: "too_much_gain", label: "Too much gain" },
  { value: "too_little_gain", label: "Not enough gain" },
  { value: "other", label: "Something else" }
];

type Phase = "ask" | "directions" | "sending" | "done" | "error";

// One-tap accuracy capture on the result screen. Every answer is tied to the
// exact song + gear pair, which is what lets us tune the adaptation engine.
export function ToneAccuracyFeedback({ payload }: { payload: ToneAccuracyFeedbackPayload }) {
  const [phase, setPhase] = useState<Phase>("ask");
  const [selected, setSelected] = useState<string[]>([]);

  async function submit(verdict: "close" | "off", directions: string[]) {
    setPhase("sending");
    try {
      const response = await fetch("/api/tone-feedback", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ ...payload, verdict, directions })
      });
      if (!response.ok) {
        throw new Error(`status ${response.status}`);
      }
      trackEvent("tone_accuracy_feedback", { verdict, directions: directions.join(",") || "none" });
      setPhase("done");
    } catch {
      setPhase("error");
    }
  }

  if (phase === "done") {
    return (
      <div className="mt-6 flex items-center justify-center gap-2 rounded-xl border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm font-semibold text-emerald-800">
        <CheckCircle2 className="h-4 w-4" />
        Thanks — this directly helps tune the engine for your gear.
      </div>
    );
  }

  return (
    <div className="mt-6 rounded-xl border border-white/80 bg-white/80 p-4 shadow-sm">
      {phase === "ask" || phase === "sending" || phase === "error" ? (
        <div className="flex flex-col items-center gap-3 sm:flex-row sm:justify-between">
          <div>
            <div className="text-sm font-bold text-ink">Did this sound close?</div>
            <div className="text-xs text-slate-500">One tap — it tunes future matches for your rig.</div>
            {phase === "error" ? <div className="mt-1 text-xs font-semibold text-red-600">Could not save — try again.</div> : null}
          </div>
          <div className="flex items-center gap-2">
            <button
              type="button"
              disabled={phase === "sending"}
              onClick={() => void submit("close", [])}
              className="button-secondary inline-flex min-h-10 items-center gap-2 rounded-lg px-4 text-sm"
            >
              {phase === "sending" ? <Loader2 className="h-4 w-4 animate-spin" /> : <ThumbsUp className="h-4 w-4" />}
              Yes, close
            </button>
            <button
              type="button"
              disabled={phase === "sending"}
              onClick={() => setPhase("directions")}
              className="button-quiet inline-flex min-h-10 items-center gap-2 rounded-lg px-4 text-sm"
            >
              <ThumbsDown className="h-4 w-4" />
              Not quite
            </button>
          </div>
        </div>
      ) : null}

      {phase === "directions" ? (
        <div>
          <div className="text-sm font-bold text-ink">What was off?</div>
          <div className="mt-3 flex flex-wrap gap-2">
            {DIRECTIONS.map((direction) => {
              const active = selected.includes(direction.value);
              return (
                <button
                  key={direction.value}
                  type="button"
                  onClick={() =>
                    setSelected((current) =>
                      current.includes(direction.value)
                        ? current.filter((value) => value !== direction.value)
                        : [...current, direction.value]
                    )
                  }
                  className={`rounded-full border px-3 py-1.5 text-xs font-semibold transition ${
                    active ? "border-ocean bg-ocean/10 text-ocean" : "border-slate-200 bg-white text-slate-600 hover:border-ocean/50"
                  }`}
                >
                  {direction.label}
                </button>
              );
            })}
          </div>
          <div className="mt-3 flex items-center gap-3">
            <button
              type="button"
              disabled={!selected.length}
              onClick={() => void submit("off", selected)}
              className={selected.length ? "button-primary min-h-10 rounded-lg px-4 text-sm" : "inline-flex min-h-10 items-center rounded-lg bg-slate-200 px-4 text-sm font-semibold text-slate-400"}
            >
              Send
            </button>
            <button type="button" className="text-xs font-semibold text-slate-500 hover:text-ink" onClick={() => setPhase("ask")}>
              Back
            </button>
          </div>
        </div>
      ) : null}
    </div>
  );
}
