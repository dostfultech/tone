import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function slugify(value: string) {
  return value
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/(^-|-$)+/g, "");
}

export function clamp(value: number, min = 0, max = 10) {
  return Math.min(max, Math.max(min, value));
}

export function stableScore(seed: string, min = 72, max = 96) {
  const total = seed.split("").reduce((acc, char) => acc + char.charCodeAt(0), 0);
  return min + (total % (max - min + 1));
}
