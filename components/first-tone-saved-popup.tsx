"use client";

import Link from "next/link";
import { Flame } from "lucide-react";

export function FirstToneSavedPopup({
  open,
  song,
  artist,
  onClose
}: {
  open: boolean;
  song?: string | null;
  artist?: string | null;
  onClose: () => void;
}) {
  if (!open) {
    return null;
  }

  return (
    <div className="fixed inset-0 z-[95] grid place-items-center bg-ink/45 p-4" role="dialog" aria-modal="true">
      <div className="theme-panel w-full max-w-sm overflow-hidden text-center">
        <div className="px-6 pt-8">
          <div className="mx-auto grid h-14 w-14 place-items-center rounded-full bg-amber-100 text-amber-500">
            <Flame className="h-7 w-7" />
          </div>
          <h2 className="mt-4 text-2xl font-bold">Tone Saved!</h2>
          {song ? (
            <p className="mt-2 text-sm text-slate-700">
              <span className="font-semibold text-ink">{song}</span>
              {artist ? <> by {artist}</> : null}
            </p>
          ) : null}
          <p className="mt-2 text-sm text-slate-500">
            We automatically saved your first tone to your library. Keep researching songs to build your collection!
          </p>
        </div>
        <div className="grid gap-3 px-6 py-6">
          <button type="button" className="button-primary min-h-12 justify-center" onClick={onClose}>
            Keep Going
          </button>
          <Link href="/library" className="button-secondary min-h-11 justify-center" onClick={onClose}>
            View My Library
          </Link>
        </div>
      </div>
    </div>
  );
}
