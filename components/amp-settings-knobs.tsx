"use client";

import { type CSSProperties, useMemo } from "react";
import {
  extractToneControls,
  formatToneControlName,
  useAnimatedToneControls
} from "@/components/tone-control-animation";

type AmpSettingsKnobsProps = {
  settings: Record<string, number>;
  empty?: string;
  duration?: number;
  columns?: 2 | 3 | 4;
};

export function AmpSettingsKnobs({ settings, empty = "No settings available", duration = 900, columns = 3 }: AmpSettingsKnobsProps) {
  const hasSettings = Object.keys(settings).length > 0;
  const controls = useMemo(() => (hasSettings ? extractToneControls({ targetSettings: settings }) : {}), [hasSettings, settings]);
  const animatedValues = useAnimatedToneControls(controls, duration);
  const entries = Object.entries(controls);

  const gridClass = columns === 4
    ? "grid grid-cols-2 gap-3 sm:grid-cols-3 xl:grid-cols-4"
    : columns === 2
      ? "grid grid-cols-2 gap-3"
      : "grid grid-cols-2 gap-3 sm:grid-cols-3";

  if (!entries.length) {
    return <div className="rounded-lg border border-dashed border-blue-100 bg-white/80 p-4 text-sm text-slate-500">{empty}</div>;
  }

  return (
    <div className={gridClass}>
      {entries.map(([name]) => {
        const animatedValue = animatedValues[name] ?? 0;
        return (
          <div key={name} className="rounded-lg border border-white/80 bg-white/90 p-4 text-center shadow-sm transition-shadow hover:shadow-lg">
            <div className="knob-shell mx-auto mb-3 grid h-16 w-16 place-items-center rounded-full" style={knobStyle(animatedValue)} aria-label={`${formatToneControlName(name)} ${formatDisplayValue(animatedValue)}`}>
              <div className="knob h-12 w-12 rounded-full" />
            </div>
            <div className="text-xs text-slate-500">{formatToneControlName(name)}</div>
            <div className="text-lg font-semibold">{formatDisplayValue(animatedValue)}</div>
          </div>
        );
      })}
    </div>
  );
}

function knobStyle(value: number): CSSProperties {
  const boundedValue = Math.max(0, Math.min(10, Number(value) || 0));
  return { "--knob-angle": `${-135 + boundedValue * 27}deg` } as CSSProperties;
}

function formatDisplayValue(value: number) {
  return Number.isInteger(value) ? value : value.toFixed(1);
}
