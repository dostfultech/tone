"use client";

import { useEffect, useMemo, useState } from "react";

const toneControlOrder = [
  "gain",
  "bass",
  "mids",
  "mid",
  "treble",
  "presence",
  "reverb",
  "delay",
  "master",
  "volume",
  "tone",
  "compression"
] as const;

type ToneControlKey = (typeof toneControlOrder)[number];

export type ToneControls = Record<string, number>;

const fallbackControls: Array<readonly [string, number]> = [
  ["gain", 0],
  ["bass", 0],
  ["mids", 0],
  ["treble", 0],
  ["presence", 0],
  ["reverb", 0]
];

export function formatToneControlName(name: string) {
  const normalized = name.toLowerCase();

  if (normalized === "mid" || normalized === "mids") {
    return "Mids";
  }

  return normalized
    .replace(/[_-]+/g, " ")
    .replace(/\b\w/g, (character) => character.toUpperCase());
}

export function clampToneControlValue(value: number) {
  const numeric = Number(value);

  if (!Number.isFinite(numeric)) {
    return 0;
  }

  return Math.max(0, Math.min(10, numeric));
}

export function extractToneControls(result: Record<string, unknown>) {
  const discovered = new Map<string, number>();

  const visit = (value: unknown) => {
    if (!value) {
      return;
    }

    if (Array.isArray(value)) {
      value.forEach(visit);
      return;
    }

    if (typeof value !== "object") {
      return;
    }

    for (const [key, nestedValue] of Object.entries(value)) {
      const normalizedKey = key.toLowerCase();

      if (
        typeof nestedValue === "number" &&
        toneControlOrder.includes(normalizedKey as ToneControlKey) &&
        !discovered.has(normalizedKey)
      ) {
        discovered.set(normalizedKey, clampToneControlValue(nestedValue));
      } else {
        visit(nestedValue);
      }
    }
  };

  visit(result);

  const entries: Array<readonly [string, number]> = toneControlOrder
    .filter((key) => discovered.has(key))
    .map((key) => [key, discovered.get(key) || 0] as const);

  return Object.fromEntries(entries.length ? entries : fallbackControls) as ToneControls;
}

export function useAnimatedToneControls(controls: ToneControls, durationMs = 800) {
  const signature = useMemo(
    () =>
      Object.entries(controls)
        .map(([key, value]) => `${key}:${clampToneControlValue(value)}`)
        .join("|"),
    [controls]
  );

  const finalEntries = useMemo(() => {
    if (!signature) {
      return [] as Array<readonly [string, number]>;
    }

    return signature.split("|").map((item) => {
      const dividerIndex = item.lastIndexOf(":");

      return [item.slice(0, dividerIndex), Number(item.slice(dividerIndex + 1))] as const;
    });
  }, [signature]);

  const [animatedValues, setAnimatedValues] = useState<ToneControls>({});

  useEffect(() => {
    if (!finalEntries.length) {
      setAnimatedValues({});
      return;
    }

    let frame = 0;
    const startedAt = performance.now();

    const renderValue = (finalValue: number, eased: number, done: boolean) => {
      if (done) {
        return finalValue;
      }

      const currentValue = finalValue * eased;

      return Math.abs(finalValue - Math.round(finalValue)) > 0.001
        ? Number(currentValue.toFixed(1))
        : Math.round(currentValue);
    };

    const animate = (now: number) => {
      const progress = Math.min((now - startedAt) / durationMs, 1);
      const eased = 1 - Math.pow(1 - progress, 3);
      const done = progress >= 1;

      setAnimatedValues(
        Object.fromEntries(finalEntries.map(([key, value]) => [key, renderValue(value, eased, done)]))
      );

      if (!done) {
        frame = requestAnimationFrame(animate);
      }
    };

    setAnimatedValues(Object.fromEntries(finalEntries.map(([key]) => [key, 0])));
    frame = requestAnimationFrame(animate);

    return () => cancelAnimationFrame(frame);
  }, [durationMs, finalEntries]);

  return animatedValues;
}
