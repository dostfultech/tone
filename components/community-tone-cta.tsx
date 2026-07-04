"use client";

import { useEffect, useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { brand } from "@/lib/brand";
import { createSupabaseBrowserClient } from "@/lib/supabase/browser";

const AUTO_ADAPT_KEY = `${brand.storagePrefix}_auto_adapt_from_community`;
const AUTO_ADAPT_PAYLOAD_KEY = `${brand.storagePrefix}_auto_adapt_payload`;
const SAVED_GEAR_KEY = `${brand.storagePrefix}_saved_gear_presets`;

type PresetEffects = {
  cabinetName?: string;
  effectsMode?: string;
  multiFx?: string;
  selectedFx?: string;
  customPickups?: {
    neck?: string;
    middle?: string;
    bridge?: string;
  };
};

type GearPreset = {
  id: string;
  name?: string;
  instrument_type?: "guitar" | "bass";
  guitar_name?: string;
  amp_name?: string;
  pickup_name?: string | null;
  effects?: PresetEffects | PresetEffects[] | null;
  guitar?: string;
  amp?: string;
  pickup?: string;
  cabinet?: string;
  multiFx?: string;
  selectedFx?: string;
  effectsMode?: string;
};

type CommunityToneCtaProps = {
  mode: "guitar" | "bass";
  song: string;
  artist: string;
  part: string;
  partType: string;
  toneType: string;
  guitar: string;
  amp: string;
  pickup?: string | null;
  cabinet?: string | null;
};

export function CommunityToneCta({ mode, song, artist, part, partType, toneType, guitar, amp, pickup, cabinet }: CommunityToneCtaProps) {
  const router = useRouter();
  const [presets, setPresets] = useState<GearPreset[]>([]);
  const [loading, setLoading] = useState(true);
  const [message, setMessage] = useState("");

  useEffect(() => {
    let mounted = true;

    async function loadPresets() {
      const supabase = createSupabaseBrowserClient();
      let nextPresets: GearPreset[] = [];

      if (supabase) {
        const {
          data: { user }
        } = await supabase.auth.getUser();

        if (user) {
          const { data, error } = await supabase
            .from("gear_presets")
            .select("id, name, instrument_type, guitar_name, amp_name, pickup_name, effects, created_at")
            .order("created_at", { ascending: false })
            .limit(12);

          if (!error && data?.length) {
            nextPresets = data as GearPreset[];
          }
        }
      }

      if (!nextPresets.length) {
        nextPresets = readLocalPresets();
      }

      if (mounted) {
        setPresets(nextPresets);
        setLoading(false);
      }
    }

    void loadPresets();

    return () => {
      mounted = false;
    };
  }, []);

  const preset = useMemo(() => selectCompatiblePreset(presets, mode), [mode, presets]);
  const readyForGearAdaptation = Boolean(preset && getPresetGuitar(preset) && getPresetAmp(preset));

  function adaptTone() {
    if (loading) {
      return;
    }

    if (!preset || !readyForGearAdaptation) {
      console.warn("[tonefex:adapt-to-my-gear]", {
        event: "missing_my_gear_preset",
        mode,
        song,
        artist
      });
      setMessage("Complete My Gear first, then this tone can be adapted directly to your saved rig.");
      return;
    }

    const presetEffects = readPresetEffects(preset);
    console.info("[tonefex:adapt-to-my-gear]", {
      event: "adapt_to_my_gear_clicked",
      mode,
      song,
      artist,
      preset: preset.name || preset.id,
      targetGear: {
        guitar: getPresetGuitar(preset),
        amp: getPresetAmp(preset),
        cabinet: presetEffects.cabinetName || preset.cabinet || cabinet || null,
        pickup: getPresetPickup(preset) || pickup || null,
        effectsMode: presetEffects.effectsMode || preset.effectsMode || "manual",
        selectedFx: presetEffects.selectedFx || preset.selectedFx || null,
        multiFx: presetEffects.multiFx || preset.multiFx || null,
        customPickups: presetEffects.customPickups || null
      }
    });
    sessionStorage.setItem(
      AUTO_ADAPT_PAYLOAD_KEY,
      JSON.stringify({
        mode,
        song,
        artist,
        part,
        partType,
        toneType: toneType || "auto",
        guitar: getPresetGuitar(preset) || guitar,
        amp: getPresetAmp(preset) || amp,
        pickup: getPresetPickup(preset) || pickup || undefined,
        cabinet: presetEffects.cabinetName || preset.cabinet || cabinet || undefined,
        effectsMode: presetEffects.effectsMode || preset.effectsMode || "manual",
        goingDirect: (presetEffects.effectsMode || preset.effectsMode) === "multi_fx",
        multiFx: presetEffects.multiFx || preset.multiFx,
        selectedFx: presetEffects.selectedFx || preset.selectedFx,
        customPickups: presetEffects.customPickups
      })
    );
    sessionStorage.setItem(AUTO_ADAPT_KEY, "1");
    router.push("/app");
  }

  return (
    <div className="grid gap-3">
      <button type="button" className="button-primary w-full justify-center" onClick={adaptTone} disabled={loading}>
        {loading ? "Checking My Gear..." : readyForGearAdaptation ? "Adapt to My Gear" : "Adapt This Tone"}
      </button>
      {readyForGearAdaptation ? (
        <p className="rounded-lg border border-emerald-200 bg-emerald-50 px-4 py-3 text-xs font-bold text-emerald-800">
          Using {preset?.name || "your saved rig"}: {getPresetGuitar(preset)} into {getPresetAmp(preset)}.
        </p>
      ) : message ? (
        <div className="grid gap-3 rounded-lg border border-amber-200 bg-amber-50 px-4 py-3">
          <p className="text-sm font-semibold text-amber-900">{message}</p>
          <button type="button" className="button-secondary min-h-10 justify-center rounded-lg text-sm" onClick={() => router.push("/gear")}>
            Open My Gear
          </button>
        </div>
      ) : null}
    </div>
  );
}

function readLocalPresets() {
  try {
    const parsed = JSON.parse(localStorage.getItem(SAVED_GEAR_KEY) || "[]");
    return Array.isArray(parsed) ? parsed as GearPreset[] : [];
  } catch {
    return [];
  }
}

function selectCompatiblePreset(presets: GearPreset[], mode: "guitar" | "bass") {
  return presets.find((preset) => preset.instrument_type === mode) || presets.find((preset) => !preset.instrument_type) || null;
}

function readPresetEffects(preset: GearPreset | null): PresetEffects {
  if (!preset) {
    return {};
  }

  if (Array.isArray(preset.effects)) {
    return preset.effects[0] || {};
  }

  return preset.effects && typeof preset.effects === "object" ? preset.effects : {};
}

function getPresetGuitar(preset: GearPreset | null) {
  return preset?.guitar_name || preset?.guitar || "";
}

function getPresetAmp(preset: GearPreset | null) {
  return preset?.amp_name || preset?.amp || "";
}

function getPresetPickup(preset: GearPreset | null) {
  return preset?.pickup_name || preset?.pickup || "";
}
