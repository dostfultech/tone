"use client";

import { FormEvent, useEffect, useMemo, useRef, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { Check, ChevronDown, ChevronUp, Cpu, Guitar, Loader2, Plus, SlidersHorizontal, Sparkles, Trash2, Volume2, Waves, X } from "lucide-react";
import { PedalSelectorModal } from "@/components/pedal-selector-modal";
import { SearchableGearDropdown } from "@/components/searchable-gear-dropdown";
import { OnboardingProgress } from "@/components/onboarding-progress";
import { useMyGearProfile, toSearchItem } from "@/hooks/use-my-gear-profile";
import { brand } from "@/lib/brand";
import { createSupabaseBrowserClient } from "@/lib/supabase/browser";
import type { GearSelectionMetadata } from "@/lib/my-gear";

type Preset = {
  id: string;
  name: string;
  instrument_type?: "guitar" | "bass";
  guitar_name?: string;
  amp_name?: string;
  pickup_name?: string;
  effects?: PresetEffects | PresetEffects[] | null;
  guitar?: string;
  amp?: string;
  pickup?: string;
  cabinet?: string;
  multiFx?: string;
  selectedFx?: string;
  effectsMode?: string;
};

type PresetEffects = {
  cabinetName?: string;
  effectsMode?: string;
  multiFx?: string;
  selectedFx?: string;
  features?: string[];
  customPickups?: {
    neck?: string;
    middle?: string;
    bridge?: string;
  };
};

type CatalogEntry = {
  id: string;
  name: string;
  description: string;
  category: string;
  details: string[];
};

const PRESET_FEATURES = ["Coil Split", "Presence", "Reverb", "FX Loop"] as const;

export function GearView() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const onboardingMode = searchParams.get("onboarding") === "1";

  const gearProfile = useMyGearProfile();

  const [presets, setPresets] = useState<Preset[]>([]);
  const [name, setName] = useState("Main rig");
  const [presetInstrument, setPresetInstrument] = useState<"guitar" | "bass">("guitar");
  const [guitar, setGuitar] = useState("");
  const [amp, setAmp] = useState("");
  const [pickup, setPickup] = useState("");
  const [neckPickup, setNeckPickup] = useState("Stock");
  const [middlePickup, setMiddlePickup] = useState("Stock");
  const [bridgePickup, setBridgePickup] = useState("Stock");
  const [cabinet, setCabinet] = useState("");
  const [effectsMode, setEffectsMode] = useState("manual");
  const [multiFx, setMultiFx] = useState("");
  const [selectedFx, setSelectedFx] = useState("");
  const [useMultiFxInPreset, setUseMultiFxInPreset] = useState(false);
  const [presetFeatures, setPresetFeatures] = useState<string[]>([]);
  const [activeTab, setActiveTab] = useState<"presets" | "pedals" | "multi_fx" | "catalog">(() => {
    const tab = searchParams.get("tab");
    if (tab === "pedals") return "pedals";
    if (tab === "multifx" || tab === "multi_fx") return "multi_fx";
    if (tab === "catalog") return "catalog";
    return "presets";
  });
  const [showAdvancedSetup, setShowAdvancedSetup] = useState(false);
  const [showCreatePreset, setShowCreatePreset] = useState(true);
  const [loading, setLoading] = useState(true);
  const [message, setMessage] = useState("");
  const [pedalModalOpen, setPedalModalOpen] = useState(false);
  const [multiFxSearchOpen, setMultiFxSearchOpen] = useState(false);

  const [electricGuitars, setElectricGuitars] = useState<CatalogEntry[]>([]);
  const [bassGuitars, setBassGuitars] = useState<CatalogEntry[]>([]);
  const [acousticGuitars, setAcousticGuitars] = useState<CatalogEntry[]>([]);
  const [guitarAmps, setGuitarAmps] = useState<CatalogEntry[]>([]);
  const [bassAmps, setBassAmps] = useState<CatalogEntry[]>([]);
  const [pickups, setPickups] = useState<CatalogEntry[]>([]);
  const [pedals, setPedals] = useState<CatalogEntry[]>([]);
  const [effects, setEffects] = useState<CatalogEntry[]>([]);
  const [cabinets, setCabinets] = useState<CatalogEntry[]>([]);
  const [multiFxUnits, setMultiFxUnits] = useState<CatalogEntry[]>([]);

  useEffect(() => {
    async function loadView() {
      const supabase = createSupabaseBrowserClient();

      const [electricResponse, bassResponse, acousticResponse, guitarAmpResponse, bassAmpResponse, pickupResponse, pedalResponse, effectResponse, cabinetResponse, multiFxResponse, presetResponse] = await Promise.all([
        fetchCatalog("/api/guitars/lookup"),
        fetchCatalog("/api/bass-guitars/lookup"),
        fetchCatalog("/api/acoustic-guitars/lookup"),
        fetchCatalog("/api/amps/lookup"),
        fetchCatalog("/api/bass-amps/lookup"),
        fetchCatalog("/api/pickups/catalog"),
        fetchCatalog("/api/pedals/catalog"),
        fetchCatalog("/api/effects/catalog"),
        fetchCatalog("/api/cabinets/catalog"),
        fetchCatalog("/api/multi-fx/catalog"),
        supabase
          ? supabase.from("gear_presets").select("id, name, instrument_type, guitar_name, amp_name, pickup_name, effects, created_at").order("created_at", { ascending: false })
          : Promise.resolve({ data: JSON.parse(localStorage.getItem(`${brand.storagePrefix}_saved_gear_presets`) || "[]"), error: null })
      ]);

      setElectricGuitars(electricResponse);
      setBassGuitars(bassResponse);
      setAcousticGuitars(acousticResponse);
      setGuitarAmps(guitarAmpResponse);
      setBassAmps(bassAmpResponse);
      setPickups(pickupResponse);
      setPedals(pedalResponse);
      setEffects(effectResponse);
      setCabinets(cabinetResponse);
      setMultiFxUnits(multiFxResponse);
      setPresets(presetResponse.error ? [] : presetResponse.data || []);

      setCabinet((current) => current || selectDefaultCabinet("guitar", cabinetResponse));
      setLoading(false);
    }

    void loadView();
  }, []);

  useEffect(() => {
    if (presetInstrument === "bass") {
      setGuitar((current) => {
        if (!current) return "";
        return bassGuitars.find((item) => item.name === current)?.name || "";
      });
      setAmp((current) => {
        if (!current) return "";
        return bassAmps.find((item) => item.name === current)?.name || "";
      });
      setCabinet((current) => selectDefaultCabinet("bass", cabinets, current));
      return;
    }

    setGuitar((current) => {
      if (!current) return "";
      return electricGuitars.find((item) => item.name === current)?.name || "";
    });
    setAmp((current) => {
      if (!current) return "";
      return guitarAmps.find((item) => item.name === current)?.name || "";
    });
    setCabinet((current) => selectDefaultCabinet("guitar", cabinets, current));
  }, [bassAmps, bassGuitars, cabinets, electricGuitars, guitarAmps, presetInstrument]);

  const currentGuitars = presetInstrument === "bass" ? bassGuitars : electricGuitars;
  const currentAmps = presetInstrument === "bass" ? bassAmps : guitarAmps;

  const groupedCatalog = useMemo(
    () => [
      { title: "Electric Guitars", items: electricGuitars },
      { title: "Bass Guitars", items: bassGuitars },
      { title: "Acoustic Guitars", items: acousticGuitars },
      { title: "Amplifiers", items: [...guitarAmps, ...bassAmps] },
      { title: "Cabinets", items: cabinets },
      { title: "Pickups", items: pickups },
      { title: "Pedals", items: pedals },
      { title: "Effects", items: effects },
      { title: "Multi FX", items: multiFxUnits }
    ].filter((group) => group.items.length),
    [acousticGuitars, bassAmps, bassGuitars, cabinets, effects, electricGuitars, guitarAmps, multiFxUnits, pedals, pickups]
  );

  function toggleFeature(feature: string) {
    setPresetFeatures((current) => (current.includes(feature) ? current.filter((f) => f !== feature) : [...current, feature]));
  }

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const supabase = createSupabaseBrowserClient();
    const presetEffects: PresetEffects = {
      cabinetName: cabinet,
      effectsMode: useMultiFxInPreset ? "multi_fx" : effectsMode,
      multiFx: useMultiFxInPreset ? multiFx : undefined,
      selectedFx,
      features: presetFeatures,
      customPickups: {
        neck: cleanPickupOverride(neckPickup),
        middle: cleanPickupOverride(middlePickup),
        bridge: cleanPickupOverride(bridgePickup)
      }
    };

    if (supabase) {
      const {
        data: { user }
      } = await supabase.auth.getUser();
      if (!user) {
        setMessage("Sign in before saving gear presets.");
        return;
      }

      const { data, error } = await supabase
        .from("gear_presets")
        .insert({
          user_id: user.id,
          name,
          instrument_type: presetInstrument,
          guitar_name: guitar,
          amp_name: useMultiFxInPreset ? multiFx : amp,
          pickup_name: pickup || null,
          effects: presetEffects
        })
        .select("id, name, instrument_type, guitar_name, amp_name, pickup_name, effects")
        .single();

      if (error) {
        setMessage(error.message);
        return;
      }

      setPresets([data, ...presets]);
      if (onboardingMode) {
        await supabase
          .from("profiles")
          .update({
            welcome_completed_at: new Date().toISOString(),
            gear_onboarding_completed_at: new Date().toISOString()
          })
          .eq("id", user.id);
        setMessage("Gear saved. Opening the tone database...");
        router.push("/community?onboarding=1");
        return;
      }

      setMessage("Preset saved.");
      return;
    }

    const next = [{ id: crypto.randomUUID(), name, instrument_type: presetInstrument, guitar, amp: useMultiFxInPreset ? multiFx : amp, pickup, cabinet, effects: presetEffects }, ...presets];
    setPresets(next);
    localStorage.setItem(`${brand.storagePrefix}_saved_gear_presets`, JSON.stringify(next));
    if (onboardingMode) {
      setMessage("Gear saved locally. Opening the tone database...");
      router.push("/community?onboarding=1");
      return;
    }

    setMessage("Preset saved locally.");
  }

  async function removePreset(id: string) {
    const supabase = createSupabaseBrowserClient();
    if (supabase) {
      await supabase.from("gear_presets").delete().eq("id", id);
    }
    const next = presets.filter((preset) => preset.id !== id);
    setPresets(next);
    localStorage.setItem(`${brand.storagePrefix}_saved_gear_presets`, JSON.stringify(next));
  }

  return (
    <div className="px-4 pb-14 pt-24 sm:px-6 lg:px-8">
      <div className="mx-auto max-w-[1440px]">
        {onboardingMode ? (
          <div className="mb-8">
            <OnboardingProgress currentStep={1} />
          </div>
        ) : null}

        <div className="mb-10">
          <h1 className="text-4xl font-bold tracking-normal sm:text-5xl">{onboardingMode ? "Let's build your guitar rig." : "My Gear"}</h1>
          <p className="mt-4 text-lg text-neutral-600 sm:text-xl">
            {onboardingMode
              ? "We'll save your gear so every supported song can be adapted automatically to your equipment."
              : "Manage your presets, pedals, and multi-effects"}
          </p>
        </div>

        {message ? <div className="mb-6 rounded-lg bg-ink px-5 py-4 text-sm font-bold text-white">{message}</div> : null}

        {!onboardingMode ? (
          <div className="mb-10 grid gap-4 sm:grid-cols-3">
            {[
              ["presets", "Presets", SlidersHorizontal, presets.length],
              ["pedals", "Pedals", Guitar, gearProfile.profile.pedals.length],
              ["multi_fx", "Multi FX", Cpu, gearProfile.profile.multifx ? 1 : 0]
            ].map(([value, label, Icon, count]) => {
              const ActiveIcon = Icon as typeof Guitar;
              const active = activeTab === value;
              return (
                <button
                  key={value as string}
                  type="button"
                  className={`flex min-h-16 items-center justify-center gap-4 rounded-lg border text-base font-bold shadow-sm transition ${
                    active ? "border-ink bg-ink text-white shadow-xl" : "border-white/80 bg-white/80 text-slate-700 hover:border-ocean/50"
                  }`}
                  onClick={() => setActiveTab(value as "presets" | "pedals" | "multi_fx" | "catalog")}
                >
                  <ActiveIcon className="h-5 w-5" />
                  {label as string}
                  {(count as number) > 0 ? (
                    <span className={`rounded-full px-3 py-1 text-sm ${active ? "bg-white/20 text-white" : "bg-neutral-100 text-neutral-500"}`}>{count as number}</span>
                  ) : null}
                </button>
              );
            })}
          </div>
        ) : null}

        {/* ─── PRESETS TAB ─── */}
        {activeTab === "presets" || onboardingMode ? (
          <div className="grid gap-10">
            <div className="compact-card overflow-hidden">
              <button
                type="button"
                className="flex w-full items-center gap-5 p-6 text-left sm:p-8"
                onClick={() => setShowCreatePreset((v) => !v)}
              >
                <div className="grid h-16 w-16 shrink-0 place-items-center rounded-lg bg-moss text-ink">
                  <Plus className="h-8 w-8" />
                </div>
                <div className="min-w-0 flex-1">
                  <h2 className="text-2xl font-bold">{onboardingMode ? "Save My Gear" : "Create New Preset"}</h2>
                  <p className="mt-1 text-base text-neutral-600">
                    {onboardingMode ? "Required: guitar and amplifier." : "Save a guitar and amp combination"}
                  </p>
                </div>
                {!onboardingMode ? (
                  showCreatePreset ? <ChevronUp className="h-6 w-6 shrink-0 text-slate-400" /> : <ChevronDown className="h-6 w-6 shrink-0 text-slate-400" />
                ) : null}
              </button>

              {showCreatePreset || onboardingMode ? (
                <form onSubmit={submit} className="border-t border-blue-100 p-6 sm:p-8">
                  <div className="mb-6 inline-flex rounded-lg border border-white/80 bg-white/80 p-1 shadow-sm">
                    {(["guitar", "bass"] as const).map((value) => (
                      <button
                        key={value}
                        type="button"
                        className={`min-h-10 rounded-md px-4 text-sm font-bold transition ${presetInstrument === value ? "bg-ink text-white" : "text-slate-700 hover:bg-blue-50"}`}
                        onClick={() => setPresetInstrument(value)}
                      >
                        {value === "guitar" ? "Guitar" : "Bass"}
                      </button>
                    ))}
                  </div>

                  <div className="grid gap-5 md:grid-cols-2 xl:grid-cols-3">
                    {!onboardingMode ? (
                      <div>
                        <label className="label" htmlFor="preset-name">Preset Name</label>
                        <input id="preset-name" className="field mt-2 h-12" value={name} onChange={(event) => setName(event.target.value)} required placeholder="e.g. My Main Rig" />
                      </div>
                    ) : null}
                    <SearchSelect
                      label={presetInstrument === "bass" ? "Bass" : "Guitar"}
                      placeholder={presetInstrument === "bass" ? "Select bass..." : "Select guitar..."}
                      value={guitar}
                      setValue={setGuitar}
                      options={currentGuitars}
                    />

                    {useMultiFxInPreset ? (
                      <div>
                        <div className="flex items-center justify-between">
                          <label className="label">Multi-FX</label>
                          <button type="button" className="text-xs font-semibold text-ocean hover:underline" onClick={() => setUseMultiFxInPreset(false)}>
                            Use Amp instead
                          </button>
                        </div>
                        <select className="field mt-2 h-12" value={multiFx} onChange={(e) => setMultiFx(e.target.value)}>
                          {multiFxUnits.length ? multiFxUnits.map((item) => <option key={item.name}>{item.name}</option>) : <option>{multiFx || "Loading..."}</option>}
                        </select>
                      </div>
                    ) : (
                      <div>
                        <div className="flex items-center justify-between">
                          <label className="label">Amp</label>
                          <button type="button" className="text-xs font-semibold text-ocean hover:underline" onClick={() => setUseMultiFxInPreset(true)}>
                            Use Multi-FX instead
                          </button>
                        </div>
                        <SearchSelect
                          placeholder="Select amp..."
                          value={amp}
                          setValue={setAmp}
                          options={currentAmps}
                          hideLabel
                        />
                      </div>
                    )}
                  </div>

                  <div className="mt-6">
                    <label className="label">Features</label>
                    <div className="mt-2 grid grid-cols-2 gap-3 sm:grid-cols-4">
                      {PRESET_FEATURES.map((feature) => {
                        const active = presetFeatures.includes(feature);
                        return (
                          <button
                            key={feature}
                            type="button"
                            className={`flex min-h-12 items-center gap-3 rounded-lg border px-4 text-sm font-semibold transition ${
                              active ? "border-ocean/30 bg-ocean/10 text-ink" : "border-white/80 bg-white text-slate-600 hover:border-ocean/20"
                            }`}
                            onClick={() => toggleFeature(feature)}
                          >
                            {active ? <Check className="h-4 w-4 text-ocean" /> : <div className="h-4 w-4 rounded border border-slate-300" />}
                            {feature}
                          </button>
                        );
                      })}
                    </div>
                  </div>

                  {guitar ? (
                    <div className="mt-5">
                      <button
                        type="button"
                        className="flex items-center gap-2 text-sm font-semibold text-slate-500 hover:text-ink"
                        onClick={() => setShowAdvancedSetup((v) => !v)}
                      >
                        {showAdvancedSetup ? <ChevronUp className="h-4 w-4" /> : <ChevronDown className="h-4 w-4" />}
                        Custom pickups?
                      </button>
                      {showAdvancedSetup ? (
                        <div className="mt-4 grid gap-5 rounded-lg border border-blue-100 bg-blue-50/50 p-5 md:grid-cols-2 xl:grid-cols-4">
                          <Select label="Primary pickup" value={pickup} setValue={setPickup} options={pickups.map((item) => item.name)} />
                          {presetInstrument === "guitar" ? (
                            <>
                              <Select label="Neck override" value={neckPickup} setValue={setNeckPickup} options={["Stock", ...pickups.map((item) => item.name)]} />
                              <Select label="Middle override" value={middlePickup} setValue={setMiddlePickup} options={["Stock", ...pickups.map((item) => item.name)]} />
                              <Select label="Bridge override" value={bridgePickup} setValue={setBridgePickup} options={["Stock", ...pickups.map((item) => item.name)]} />
                            </>
                          ) : null}
                        </div>
                      ) : null}
                    </div>
                  ) : null}

                  <button className="button-primary mt-6 min-h-12 rounded-lg">
                    <Plus className="h-4 w-4" />
                    {onboardingMode ? "Save My Gear and Continue" : "Save Preset"}
                  </button>
                  {onboardingMode ? <p className="mt-3 text-sm text-slate-500">You can update your saved gear anytime from My Gear.</p> : null}
                </form>
              ) : null}
            </div>

            {!onboardingMode ? (
              <div>
                <div className="mb-6 flex items-center justify-between">
                  <h2 className="text-2xl font-bold sm:text-3xl">Your Presets</h2>
                  <span className="text-base text-neutral-500">{presets.length} saved</span>
                </div>
                {loading ? (
                  <div className="compact-card flex min-h-[260px] items-center justify-center gap-3 p-8 text-neutral-600">
                    <Loader2 className="h-5 w-5 animate-spin" />
                    Loading presets
                  </div>
                ) : presets.length ? (
                  <div className="grid gap-5 md:grid-cols-2 xl:grid-cols-3">
                    {presets.map((preset) => (
                      <PresetCard key={preset.id} preset={preset} onRemove={removePreset} />
                    ))}
                  </div>
                ) : (
                  <EmptyState icon={<SlidersHorizontal className="h-12 w-12" />} title="No presets yet" body="Create your first gear preset above to get started." />
                )}
              </div>
            ) : null}
          </div>
        ) : null}

        {/* ─── PEDALS TAB ─── */}
        {activeTab === "pedals" ? (
          <div className="grid gap-8">
            <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
              <div>
                <h2 className="text-2xl font-bold sm:text-3xl">My Pedals</h2>
                <p className="mt-1 text-base text-neutral-600">Manage your pedal collection for tone matching</p>
              </div>
              <button
                type="button"
                className="button-primary inline-flex min-h-12 items-center gap-2 rounded-lg px-5 text-sm"
                onClick={() => setPedalModalOpen(true)}
              >
                <Plus className="h-4 w-4" />
                Add Pedal
              </button>
            </div>

            {gearProfile.profile.pedals.length > 0 ? (
              <>
                <SignalChain pedals={gearProfile.profile.pedals} />

                <div className="grid gap-4 md:grid-cols-2">
                  {gearProfile.profile.pedals.map((pedal) => (
                    <div key={pedal.model_id} className="compact-card flex items-start gap-4 p-5">
                      <div className="mt-1 grid h-10 w-10 shrink-0 place-items-center rounded-lg bg-green-100 text-green-700">
                        <Check className="h-5 w-5" />
                      </div>
                      <div className="min-w-0 flex-1">
                        <h3 className="text-lg font-bold">{pedal.model_name}</h3>
                        <p className="text-sm text-slate-500">{pedal.brand_name}</p>
                        {pedal.pedal_type ? (
                          <span className="mt-2 inline-block rounded-full bg-neutral-100 px-3 py-1 text-xs font-semibold capitalize text-neutral-600">
                            {pedal.pedal_type.replace(/_/g, " ")}
                          </span>
                        ) : null}
                      </div>
                      <button
                        type="button"
                        className="rounded-lg p-2 text-slate-400 transition hover:bg-red-50 hover:text-red-600"
                        onClick={() => gearProfile.removePedal(pedal.model_id)}
                        aria-label={`Remove ${pedal.model_name}`}
                      >
                        <Trash2 className="h-4 w-4" />
                      </button>
                    </div>
                  ))}
                </div>
              </>
            ) : (
              <EmptyState
                icon={<Guitar className="h-12 w-12" />}
                title="No pedals in your collection yet"
                body="Add pedals to build your signal chain and get better tone adaptations."
              />
            )}

            <PedalSelectorModal
              open={pedalModalOpen}
              onClose={() => setPedalModalOpen(false)}
              onSelect={gearProfile.addPedal}
              selectedPedals={gearProfile.profile.pedals.map(toSearchItem)}
            />
          </div>
        ) : null}

        {/* ─── MULTI FX TAB ─── */}
        {activeTab === "multi_fx" ? (
          <div className="grid gap-8">
            <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
              <div>
                <h2 className="text-2xl font-bold sm:text-3xl">My Multi FX Units</h2>
                <p className="mt-1 text-base text-neutral-600">Manage your multi FX processors for tone matching</p>
              </div>
              <button
                type="button"
                className="button-primary inline-flex min-h-12 items-center gap-2 rounded-lg px-5 text-sm"
                onClick={() => setMultiFxSearchOpen((v) => !v)}
              >
                <Plus className="h-4 w-4" />
                Add Multi FX
              </button>
            </div>

            {multiFxSearchOpen ? (
              <div className="compact-card p-5">
                <SearchableGearDropdown
                  label="Search for a Multi-FX unit"
                  placeholder="e.g. Boss Katana, Helix, Matribox..."
                  endpoint="/api/equipment/search?type=multifx"
                  selectedItems={gearProfile.profile.multifx ? [toSearchItem(gearProfile.profile.multifx)] : []}
                  onSelect={(item) => {
                    gearProfile.setSingleSelection("multifx", "multifx", item);
                    setMultiFxSearchOpen(false);
                  }}
                  requestType="Multi FX Unit"
                />
              </div>
            ) : null}

            {gearProfile.profile.multifx ? (
              <div className="compact-card flex items-start gap-5 p-6">
                <div className="grid h-14 w-14 shrink-0 place-items-center rounded-lg bg-purple-100 text-purple-700">
                  <Sparkles className="h-7 w-7" />
                </div>
                <div className="min-w-0 flex-1">
                  <h3 className="text-xl font-bold">{gearProfile.profile.multifx.model_name}</h3>
                  <p className="text-sm text-slate-500">{gearProfile.profile.multifx.brand_name}</p>
                  <div className="mt-3 flex flex-wrap gap-2">
                    {gearProfile.profile.multifx.model_category ? (
                      <span className="rounded-full bg-purple-100 px-3 py-1 text-xs font-semibold text-purple-700">
                        {gearProfile.profile.multifx.model_category === "multifx" ? "Amp Modeling" : gearProfile.profile.multifx.model_category}
                      </span>
                    ) : null}
                    <span className="rounded-full bg-neutral-100 px-3 py-1 text-xs font-semibold text-neutral-600">Amp Modeling</span>
                  </div>
                </div>
                <button
                  type="button"
                  className="rounded-lg p-2 text-slate-400 transition hover:bg-red-50 hover:text-red-600"
                  onClick={() => gearProfile.removeSingleSelection("multifx")}
                  aria-label="Remove Multi FX"
                >
                  <Trash2 className="h-5 w-5" />
                </button>
              </div>
            ) : (
              <EmptyState
                icon={<Cpu className="h-12 w-12" />}
                title="No Multi FX units yet"
                body="Add your multi-effects processor to get complete preset adaptations."
              />
            )}

            <div className="compact-card p-6">
              <h3 className="text-lg font-bold text-ink">How Multi FX Matching Works</h3>
              <div className="mt-4 grid gap-3 text-sm text-slate-600">
                <p>
                  <span className="font-bold text-ink">Effects-Only Units (Boss ME-80, GT-1):</span>{" "}
                  We&apos;ll show you the internal effects to use plus amp settings for your physical amp.
                </p>
                <p>
                  <span className="font-bold text-ink">Amp Modelers (Helix, Kemper, Axe-Fx):</span>{" "}
                  We&apos;ll provide a complete preset including amp model selection and all effect settings.
                </p>
              </div>
            </div>
          </div>
        ) : null}

        {/* ─── CATALOG TAB ─── */}
        {activeTab === "catalog" ? (
          <div className="grid gap-8">
            {groupedCatalog.map((group) => (
              <CatalogGrid key={group.title} title={group.title} items={group.items} />
            ))}
          </div>
        ) : null}
      </div>
    </div>
  );
}

function SignalChain({ pedals }: { pedals: GearSelectionMetadata[] }) {
  return (
    <div className="compact-card p-6">
      <h3 className="mb-2 text-base font-bold text-ink">Signal Chain</h3>
      <p className="mb-5 text-sm text-slate-500">Drag to reorder &bull; Click to toggle active/bypass</p>
      <div className="flex items-center gap-3 overflow-x-auto pb-2">
        <div className="flex shrink-0 items-center gap-2 text-sm font-semibold text-slate-500">
          <Guitar className="h-5 w-5" />
          Guitar
        </div>
        <span className="text-slate-300">—</span>
        {pedals.map((pedal, index) => (
          <div key={pedal.model_id} className="flex shrink-0 items-center gap-3">
            <div className="rounded-lg border border-ocean/20 bg-ocean/5 px-4 py-2 text-center">
              <div className="text-sm font-bold text-ink">{pedal.model_name}</div>
              <div className="text-xs text-slate-500">{pedal.brand_name}</div>
              {pedal.pedal_type ? (
                <div className="mt-1 text-xs capitalize text-ocean">{pedal.pedal_type.replace(/_/g, " ")}</div>
              ) : null}
              <div className="mx-auto mt-2 h-2 w-2 rounded-full bg-green-500" />
            </div>
            {index < pedals.length - 1 ? <span className="text-slate-300">—</span> : null}
          </div>
        ))}
        <span className="text-slate-300">—</span>
        <div className="flex shrink-0 items-center gap-2 text-sm font-semibold text-slate-500">
          <Volume2 className="h-5 w-5" />
          Amp
        </div>
      </div>
    </div>
  );
}

function PresetCard({ preset, onRemove }: { preset: Preset; onRemove: (id: string) => void }) {
  const effects = readPresetEffects(preset);
  const features = effects.features || [];
  const isMultiFx = effects.effectsMode === "multi_fx";

  return (
    <article className="compact-card p-6">
      <div className="mb-4 flex items-start justify-between">
        <div>
          <h3 className="text-xl font-bold">{preset.name}</h3>
          <p className="text-sm capitalize text-neutral-500">{preset.instrument_type || "gear"} preset</p>
        </div>
        <button type="button" className="button-secondary px-3" onClick={() => onRemove(preset.id)} aria-label="Delete preset">
          <Trash2 className="h-4 w-4" />
        </button>
      </div>
      <div className="grid gap-3 text-base">
        <div className="flex items-center gap-3 rounded-lg bg-neutral-50 px-4 py-3">
          <Guitar className="h-5 w-5 text-ink" />
          {preset.guitar_name || preset.guitar || "Guitar not set"}
        </div>
        <div className="flex items-center gap-3 rounded-lg bg-neutral-50 px-4 py-3">
          {isMultiFx ? <Sparkles className="h-5 w-5 text-ink" /> : <Volume2 className="h-5 w-5 text-ink" />}
          {preset.amp_name || preset.amp || "Amp not set"}
        </div>
      </div>
      {features.length > 0 ? (
        <div className="mt-3 flex flex-wrap gap-2">
          {features.map((feature) => (
            <span key={feature} className="rounded-full bg-ocean/10 px-3 py-1 text-xs font-semibold text-ocean">
              {feature}
            </span>
          ))}
        </div>
      ) : null}
    </article>
  );
}

function Select({ label, value, setValue, options }: { label: string; value: string; setValue: (value: string) => void; options: string[] }) {
  return (
    <div>
      <label className="label">{label}</label>
      <select className="field mt-2 h-12" value={value} onChange={(event) => setValue(event.target.value)}>
        {options.length ? (
          options.map((option) => (
            <option key={option}>{option}</option>
          ))
        ) : (
          <option value={value || ""}>{value || "Loading options..."}</option>
        )}
      </select>
    </div>
  );
}

function SearchSelect({ label, placeholder, value, setValue, options, hideLabel }: { label?: string; placeholder: string; value: string; setValue: (value: string) => void; options: CatalogEntry[]; hideLabel?: boolean }) {
  const [open, setOpen] = useState(false);
  const [filter, setFilter] = useState("");
  const rootRef = useRef<HTMLDivElement | null>(null);
  const inputRef = useRef<HTMLInputElement | null>(null);

  useEffect(() => {
    function handleOutsideClick(event: MouseEvent) {
      if (rootRef.current && event.target instanceof Node && !rootRef.current.contains(event.target)) {
        setOpen(false);
      }
    }
    document.addEventListener("mousedown", handleOutsideClick);
    return () => document.removeEventListener("mousedown", handleOutsideClick);
  }, []);

  const filtered = filter
    ? options.filter((item) => item.name.toLowerCase().includes(filter.toLowerCase()))
    : options;

  return (
    <div ref={rootRef} className="relative">
      {label && !hideLabel ? <label className="label">{label}</label> : null}
      <button
        type="button"
        className={`${label && !hideLabel ? "mt-2 " : ""}flex min-h-12 w-full items-center justify-between rounded-xl border border-slate-200 bg-white px-4 text-left text-sm font-semibold shadow-sm transition hover:border-ocean/50`}
        onClick={() => { setOpen((v) => !v); setFilter(""); window.setTimeout(() => inputRef.current?.focus(), 0); }}
      >
        <span className={value ? "text-slate-900" : "text-slate-400"}>{value || placeholder}</span>
        <ChevronDown className={`h-4 w-4 text-slate-400 transition ${open ? "rotate-180" : ""}`} />
      </button>
      {open ? (
        <div className="absolute left-0 right-0 z-40 mt-1 overflow-hidden rounded-xl border border-slate-200 bg-white shadow-xl">
          <div className="border-b border-slate-100 p-2">
            <input
              ref={inputRef}
              value={filter}
              onChange={(e) => setFilter(e.target.value)}
              placeholder={placeholder}
              className="h-10 w-full rounded-lg border border-slate-200 bg-slate-50 px-3 text-sm outline-none focus:border-ocean"
            />
          </div>
          <div className="max-h-60 overflow-y-auto p-1">
            {filtered.length ? filtered.map((item) => (
              <button
                key={item.id}
                type="button"
                className={`flex w-full items-center justify-between rounded-lg px-3 py-2 text-left text-sm transition ${
                  item.name === value ? "bg-ocean/10 font-bold text-ink" : "text-slate-700 hover:bg-slate-50"
                }`}
                onClick={() => { setValue(item.name); setOpen(false); setFilter(""); }}
              >
                <span>{item.name}</span>
                {item.name === value ? <Check className="h-4 w-4 text-ocean" /> : null}
              </button>
            )) : (
              <div className="px-3 py-4 text-sm text-slate-400">No results found</div>
            )}
          </div>
        </div>
      ) : null}
    </div>
  );
}

function readPresetEffects(preset: Preset): PresetEffects {
  if (Array.isArray(preset.effects)) {
    return preset.effects[0] || {};
  }
  return preset.effects && typeof preset.effects === "object" ? preset.effects : {};
}

function cleanPickupOverride(value: string) {
  return value && value !== "Stock" ? value : undefined;
}

function selectDefaultCabinet(mode: "guitar" | "bass", cabinets: CatalogEntry[], current?: string) {
  const currentCabinet = cabinets.find((item) => item.name === current);
  if (currentCabinet) return currentCabinet.name;

  const bassCabinet = cabinets.find((item) => /ampeg|darkglass|bass/i.test(`${item.name} ${item.description}`));
  if (mode === "bass") return bassCabinet?.name || cabinets[0]?.name || current || "";
  return cabinets.find((item) => item.id !== bassCabinet?.id)?.name || cabinets[0]?.name || current || "";
}

function CatalogGrid({ title, items }: { title: string; items: CatalogEntry[] }) {
  return (
    <div>
      <h2 className="mb-5 text-2xl font-bold sm:text-3xl">{title}</h2>
      <div className="grid gap-5 md:grid-cols-2 xl:grid-cols-3">
        {items.map((item) => (
          <article key={item.id} className="compact-card p-6">
            <div className="mb-4 flex items-center gap-4">
              <div className="grid h-14 w-14 place-items-center rounded-lg bg-ink text-moss">
                <SlidersHorizontal className="h-6 w-6" />
              </div>
              <div className="min-w-0">
                <h3 className="truncate text-xl font-bold sm:text-2xl">{item.name}</h3>
                <p className="text-xs font-semibold uppercase tracking-[0.12em] text-neutral-400">{item.category}</p>
              </div>
            </div>
            <p className="text-sm leading-6 text-slate-600">{item.description || "Catalog item available in the shared equipment database."}</p>
            <div className="mt-4 flex flex-wrap gap-2">
              {(item.details.length ? item.details : [item.category]).slice(0, 5).map((detail) => (
                <span key={detail} className="rounded-full bg-neutral-100 px-3 py-1 text-sm font-semibold text-neutral-600">
                  {detail}
                </span>
              ))}
            </div>
          </article>
        ))}
      </div>
    </div>
  );
}

function EmptyState({ icon, title, body }: { icon: React.ReactNode; title: string; body: string }) {
  return (
    <div className="grid min-h-[320px] place-items-center rounded-lg border border-dashed border-blue-100 bg-white/80 p-8 text-center">
      <div>
        <div className="mx-auto mb-5 grid h-24 w-24 place-items-center rounded-lg bg-blue-50 text-slate-400">{icon}</div>
        <h2 className="text-3xl font-bold">{title}</h2>
        <p className="mt-3 text-lg text-neutral-600">{body}</p>
      </div>
    </div>
  );
}

async function fetchCatalog(url: string): Promise<CatalogEntry[]> {
  try {
    const response = await fetch(url, { cache: "no-store" });
    const payload = await response.json();
    const results = Array.isArray(payload.results) ? payload.results : [];
    return results.map((item: Record<string, unknown>) => ({
      id: String(item.id || item.name),
      name: String(item.name || ""),
      description: String(item.description || item.category || item.meta || ""),
      category: String(item.category || item.itemType || item.meta || "catalog"),
      details: Array.isArray(item.details)
        ? item.details.map((detail) => String(detail))
        : typeof item.description === "string"
          ? item.description.split(" | ").filter(Boolean)
          : []
    }));
  } catch {
    return [];
  }
}
