"use client";

import { useEffect, useRef, useState } from "react";
import { Disc3 } from "lucide-react";

const COVER_GRADIENTS = [
  "from-indigo-500 to-fuchsia-600",
  "from-sky-500 to-blue-700",
  "from-emerald-500 to-teal-700",
  "from-rose-500 to-orange-600",
  "from-violet-600 to-indigo-800",
  "from-amber-500 to-red-600",
  "from-cyan-500 to-blue-700",
  "from-slate-600 to-slate-900"
];

/**
 * Real album cover for the trending list. Shows the licensed artwork (served from
 * Apple's iTunes artwork CDN) when it loads, and falls back to a branded vinyl tile
 * if the image is missing or blocked — so a row is never empty. The chart rank sits
 * in the corner either way. The useEffect covers an image that 404s before hydration.
 */
export function SongCover({ cover, rank, title }: { cover?: string; rank: number; title: string }) {
  const [failed, setFailed] = useState(false);
  const ref = useRef<HTMLImageElement>(null);

  useEffect(() => {
    const img = ref.current;
    if (img && img.complete && img.naturalWidth === 0) {
      setFailed(true);
    }
  }, [cover]);

  const hash = Array.from(title).reduce((sum, ch) => sum + ch.charCodeAt(0), 0);
  const gradient = COVER_GRADIENTS[hash % COVER_GRADIENTS.length];
  const showCover = cover && !failed;

  return (
    <div className="relative h-12 w-12 flex-shrink-0 sm:h-14 sm:w-14">
      {showCover ? (
        // eslint-disable-next-line @next/next/no-img-element
        <img
          ref={ref}
          src={cover}
          alt={`${title} album cover`}
          loading="lazy"
          onError={() => setFailed(true)}
          onLoad={(event) => {
            if (event.currentTarget.naturalWidth === 0) setFailed(true);
          }}
          className="h-full w-full rounded-lg object-cover shadow-md"
        />
      ) : (
        <div className={`relative grid h-full w-full place-items-center overflow-hidden rounded-lg bg-gradient-to-br ${gradient} shadow-md`}>
          <div className="absolute inset-0 bg-gradient-to-tr from-transparent via-white/5 to-white/25" />
          <Disc3 className="relative h-6 w-6 text-white/85 sm:h-7 sm:w-7" />
        </div>
      )}
      <div className="absolute -bottom-1.5 -left-1.5 grid h-5 w-5 place-items-center rounded-full bg-ink text-[10px] font-bold text-moss ring-2 ring-white">
        {rank}
      </div>
    </div>
  );
}
