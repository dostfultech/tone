"use client";

import { useEffect, useRef, useState } from "react";

/**
 * Avatar that shows a real photo when the file exists and falls back to a branded
 * initial circle if the src is missing or fails to load. Lets us ship the testimonial
 * / badge layout before the photo files are added to /public without broken images.
 * `className` controls size + shape (shared by photo and fallback).
 *
 * The useEffect covers the case where the image 404s BEFORE hydration (so React's
 * onError never fires) — a fresh <img> that is `complete` with zero natural width has
 * already failed, so we fall back immediately.
 */
export function PhotoAvatar({
  src,
  name,
  gradient = "from-ocean to-copper",
  className = "",
  fallbackTextClassName = "text-base"
}: {
  src?: string;
  name: string;
  gradient?: string;
  className?: string;
  fallbackTextClassName?: string;
}) {
  const [failed, setFailed] = useState(false);
  const ref = useRef<HTMLImageElement>(null);
  const initial = (name || "?").trim().slice(0, 1).toUpperCase();

  useEffect(() => {
    const img = ref.current;
    if (img && img.complete && img.naturalWidth === 0) {
      setFailed(true);
    }
  }, [src]);

  if (src && !failed) {
    return (
      // eslint-disable-next-line @next/next/no-img-element
      <img
        ref={ref}
        src={src}
        alt={name}
        loading="lazy"
        onError={() => setFailed(true)}
        onLoad={(event) => {
          if (event.currentTarget.naturalWidth === 0) setFailed(true);
        }}
        className={`object-cover ${className}`.trim()}
      />
    );
  }

  return (
    <div
      aria-label={name}
      className={`grid place-items-center bg-gradient-to-br ${gradient} font-bold text-white ${fallbackTextClassName} ${className}`.trim()}
    >
      {initial}
    </div>
  );
}
