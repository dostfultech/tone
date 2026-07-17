"use client";

import { useEffect, useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { Loader2, Search } from "lucide-react";

type EquipmentResult = {
  id: string;
  displayName: string;
};

export function HomeGearQuickSearch() {
  const router = useRouter();
  const [guitarQuery, setGuitarQuery] = useState("");
  const [ampQuery, setAmpQuery] = useState("");
  const [guitarResults, setGuitarResults] = useState<EquipmentResult[]>([]);
  const [ampResults, setAmpResults] = useState<EquipmentResult[]>([]);
  const [loading, setLoading] = useState<{ guitar: boolean; amp: boolean }>({ guitar: false, amp: false });

  const selectedGuitar = useMemo(() => guitarQuery.trim(), [guitarQuery]);
  const selectedAmp = useMemo(() => ampQuery.trim(), [ampQuery]);

  useEffect(() => {
    const controller = new AbortController();
    const timeout = window.setTimeout(async () => {
      await loadResults("guitar", guitarQuery, setGuitarResults, setLoading, controller.signal);
    }, 220);

    return () => {
      controller.abort();
      window.clearTimeout(timeout);
    };
  }, [guitarQuery]);

  useEffect(() => {
    const controller = new AbortController();
    const timeout = window.setTimeout(async () => {
      await loadResults("amp", ampQuery, setAmpResults, setLoading, controller.signal);
    }, 220);

    return () => {
      controller.abort();
      window.clearTimeout(timeout);
    };
  }, [ampQuery]);

  function startMatchTones() {
    const params = new URLSearchParams();
    if (selectedGuitar) {
      params.set("guitar", selectedGuitar);
    }
    if (selectedAmp) {
      params.set("amp", selectedAmp);
    }

    const target = params.toString() ? `/app?${params.toString()}` : "/app";
    router.push(target);
  }

  return (
    <div className="mx-auto mt-10 grid w-full max-w-4xl gap-4 rounded-lg border border-white/80 bg-white/80 p-5 text-left shadow-lg sm:grid-cols-2">
      <SearchField
        label="Search Guitar"
        value={guitarQuery}
        onChange={setGuitarQuery}
        results={guitarResults}
        loading={loading.guitar}
        onSelect={setGuitarQuery}
        placeholder="e.g. Fender Stratocaster"
      />
      <SearchField
        label="Search Amplifier"
        value={ampQuery}
        onChange={setAmpQuery}
        results={ampResults}
        loading={loading.amp}
        onSelect={setAmpQuery}
        placeholder="e.g. Marshall JCM800"
      />
      <div className="sm:col-span-2 flex justify-end">
        <button type="button" className="button-primary min-h-12 px-6" onClick={startMatchTones}>
          <Search className="h-4 w-4" />
          Match Tones
        </button>
      </div>
    </div>
  );
}

function SearchField({
  label,
  value,
  onChange,
  results,
  loading,
  onSelect,
  placeholder
}: {
  label: string;
  value: string;
  onChange: (value: string) => void;
  results: EquipmentResult[];
  loading: boolean;
  onSelect: (value: string) => void;
  placeholder: string;
}) {
  return (
    <div className="relative">
      <label className="label">{label}</label>
      <input
        className="field mt-2 h-12"
        value={value}
        onChange={(event) => onChange(event.target.value)}
        placeholder={placeholder}
      />
      {loading ? <Loader2 className="pointer-events-none absolute right-3 top-[2.55rem] h-4 w-4 animate-spin text-slate-400" /> : null}
      {results.length ? (
        <div className="absolute left-0 right-0 z-30 mt-1 max-h-56 overflow-y-auto rounded-md border border-slate-200 bg-white shadow-xl">
          {results.map((item) => (
            <button
              key={item.id}
              type="button"
              className="block w-full border-b border-slate-100 px-3 py-2 text-left text-sm text-slate-700 transition last:border-b-0 hover:bg-slate-50"
              onClick={() => onSelect(item.displayName)}
            >
              {item.displayName}
            </button>
          ))}
        </div>
      ) : null}
    </div>
  );
}

async function loadResults(
  type: "guitar" | "amp",
  query: string,
  setResults: (items: EquipmentResult[]) => void,
  setLoading: (update: (value: { guitar: boolean; amp: boolean }) => { guitar: boolean; amp: boolean }) => void,
  signal: AbortSignal
) {
  const term = query.trim();
  if (!term) {
    setResults([]);
    return;
  }

  setLoading((current) => ({ ...current, [type]: true }));

  try {
    const response = await fetch(`/api/equipment/search?type=${type}&q=${encodeURIComponent(term)}&limit=20`, {
      cache: "no-store",
      signal
    });

    const payload = (await response.json()) as { results?: Array<Record<string, unknown>> };
    const results = Array.isArray(payload.results)
      ? payload.results.map((item) => ({
          id: typeof item.id === "string" ? item.id : `${type}-${typeof item.displayName === "string" ? item.displayName : "unknown"}`,
          displayName: typeof item.displayName === "string" ? item.displayName : ""
        }))
      : [];

    setResults(results.filter((item) => item.displayName));
  } catch {
    if (!signal.aborted) {
      setResults([]);
    }
  } finally {
    if (!signal.aborted) {
      setLoading((current) => ({ ...current, [type]: false }));
    }
  }
}
