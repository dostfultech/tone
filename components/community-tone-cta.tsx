"use client";

import { useEffect, useMemo, useState } from "react";
import { usePathname, useRouter } from "next/navigation";
import { ExpertUpgradeModal } from "@/components/expert-upgrade-modal";
import { FreeAdaptationSummary } from "@/components/free-adaptation-summary";
import { brand } from "@/lib/brand";
import { getAdaptationSummaryProps, shouldShowFreeOnboardingJourney } from "@/lib/subscription-display";
import { addSubscriptionRefreshListener } from "@/lib/subscription-events";
import { loadClientSubscriptionSnapshot, type ClientSubscriptionSnapshot } from "@/lib/subscription-client";
import { createSupabaseBrowserClient } from "@/lib/supabase/browser";

const AUTO_ADAPT_KEY = `${brand.storagePrefix}_auto_adapt_from_community`;
const AUTO_ADAPT_PAYLOAD_KEY = `${brand.storagePrefix}_auto_adapt_payload`;
const AUTO_ADAPT_PERSISTED_KEY = `${brand.storagePrefix}_auto_adapt_payload_persisted`;
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
  const pathname = usePathname();
  const [presets, setPresets] = useState<GearPreset[]>([]);
  const [snapshot, setSnapshot] = useState<ClientSubscriptionSnapshot | null>(null);
  const [loading, setLoading] = useState(true);
  const [message, setMessage] = useState("");
  const [upgradeModalOpen, setUpgradeModalOpen] = useState(false);

  useEffect(() => {
    let mounted = true;

    async function loadPresets() {
      const supabase = createSupabaseBrowserClient();
      let nextPresets: GearPreset[] = [];
      let nextSnapshot: ClientSubscriptionSnapshot | null = null;

      if (supabase) {
        const {
          data: { user }
        } = await supabase.auth.getUser();

        if (user) {
          nextSnapshot = await loadClientSubscriptionSnapshot(supabase);
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
        setSnapshot(nextSnapshot);
        setLoading(false);
      }
    }

    void loadPresets();

    const removeRefreshListener = addSubscriptionRefreshListener(() => {
      loadPresets().catch(() => undefined);
    });

    return () => {
      mounted = false;
      removeRefreshListener();
    };
  }, []);

  const preset = useMemo(() => selectCompatiblePreset(presets, mode), [mode, presets]);
  const readyForGearAdaptation = Boolean(preset && getPresetGuitar(preset) && getPresetAmp(preset));
  const onboardingActive = shouldShowFreeOnboardingJourney(snapshot, true);

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

    if (snapshot?.user && !snapshot.hasAccess) {
      setUpgradeModalOpen(true);
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
    const handoffPayload = {
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
      customPickups: presetEffects.customPickups,
      createdAt: new Date().toISOString()
    };
    sessionStorage.setItem(AUTO_ADAPT_PAYLOAD_KEY, JSON.stringify(handoffPayload));
    localStorage.setItem(AUTO_ADAPT_PERSISTED_KEY, JSON.stringify(handoffPayload));
    sessionStorage.setItem(AUTO_ADAPT_KEY, "1");
    localStorage.setItem(AUTO_ADAPT_KEY, "1");
    router.push(onboardingActive ? "/app?onboarding=1&autoadapt=1" : "/app?autoadapt=1");
  }

  return (
    <>
      <div className="grid gap-3">
        <button type="button" className="button-primary w-full justify-center" onClick={adaptTone} disabled={loading}>
          {loading ? "Checking My Gear..." : readyForGearAdaptation ? "Adapt to My Gear" : "Adapt This Tone"}
        </button>
        {snapshot?.user && snapshot.hasAccess ? <FreeAdaptationSummary {...getAdaptationSummaryProps(snapshot)} /> : null}
        {snapshot?.user && !snapshot.hasAccess ? (
          <p className="rounded-lg border border-amber-200 bg-amber-50 px-4 py-3 text-xs font-bold text-amber-900">
            Tone Database browsing is free. Adapt to My Gear requires a paid plan.
          </p>
        ) : null}
        {readyForGearAdaptation ? (
          <p className="rounded-lg border border-emerald-200 bg-emerald-50 px-4 py-3 text-xs font-bold text-emerald-800">
            Using {preset?.name || "your saved rig"}: {getPresetGuitar(preset)} into {getPresetAmp(preset)}.
          </p>
        ) : message ? (
          <div className="grid gap-3 rounded-lg border border-amber-200 bg-amber-50 px-4 py-3">
            <p className="text-sm font-semibold text-amber-900">{message}</p>
            <button type="button" className="button-secondary min-h-10 justify-center rounded-lg text-sm" onClick={() => router.push("/gear?onboarding=1")}>
              Open My Gear
            </button>
          </div>
        ) : null}
      </div>

      <ExpertUpgradeModal
        open={upgradeModalOpen}
        onClose={() => setUpgradeModalOpen(false)}
        redirect={pathname || "/community"}
        title="Adapt to My Gear is a premium feature."
        body="Tone Database browsing is free. Upgrade to adapt database tones to your saved rig."
      />
    </>
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
