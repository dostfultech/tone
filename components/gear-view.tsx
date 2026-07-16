"use client";

import { FormEvent, useEffect, useMemo, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { Cpu, Guitar, Loader2, Plus, SlidersHorizontal, Trash2, Volume2, Waves } from "lucide-react";
import { MyGearSelectors } from "@/components/my-gear-selectors";
import { OnboardingProgress } from "@/components/onboarding-progress";
import { brand } from "@/lib/brand";
import { createSupabaseBrowserClient } from "@/lib/supabase/browser";

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

export function GearView() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const onboardingMode = searchParams.get("onboarding") === "1";
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
  const [activeTab, setActiveTab] = useState<"presets" | "pedals" | "multi_fx" | "catalog">("presets");
  const [showAdvancedSetup, setShowAdvancedSetup] = useState(false);
  const [loading, setLoading] = useState(true);
  const [message, setMessage] = useState("");
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

      setGuitar((current) => current || electricResponse[0]?.name || bassResponse[0]?.name || "");
      setAmp((current) => current || guitarAmpResponse[0]?.name || bassAmpResponse[0]?.name || "");
      setPickup((current) => current || pickupResponse[0]?.name || "");
      setCabinet((current) => current || selectDefaultCabinet("guitar", cabinetResponse));
      setMultiFx((current) => current || multiFxResponse[0]?.name || "");
      setSelectedFx((current) => current || pedalResponse[0]?.name || effectResponse[0]?.name || "");
      setLoading(false);
    }

    void loadView();
  }, []);

  useEffect(() => {
    if (presetInstrument === "bass") {
      setGuitar((current) => bassGuitars.find((item) => item.name === current)?.name || bassGuitars[0]?.name || current);
      setAmp((current) => bassAmps.find((item) => item.name === current)?.name || bassAmps[0]?.name || current);
      setCabinet((current) => selectDefaultCabinet("bass", cabinets, current));
      return;
    }

    setGuitar((current) => electricGuitars.find((item) => item.name === current)?.name || electricGuitars[0]?.name || current);
    setAmp((current) => guitarAmps.find((item) => item.name === current)?.name || guitarAmps[0]?.name || current);
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

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const supabase = createSupabaseBrowserClient();
    const presetEffects: PresetEffects = {
      cabinetName: cabinet,
      effectsMode,
      multiFx,
      selectedFx,
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
          amp_name: amp,
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

    const next = [{ id: crypto.randomUUID(), name, instrument_type: presetInstrument, guitar, amp, pickup, cabinet, effects: presetEffects }, ...presets];
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
              : "Manage presets and browse the full equipment catalog"}
          </p>
        </div>

        {message ? <div className="mb-6 rounded-lg bg-ink px-5 py-4 text-sm font-bold text-white">{message}</div> : null}

        {!onboardingMode ? (
          <div className="mb-10 grid gap-4 lg:grid-cols-4">
            {[
              ["presets", "Presets", SlidersHorizontal, presets.length],
              ["pedals", "Pedals", Guitar, pedals.length],
              ["multi_fx", "Multi FX", Cpu, multiFxUnits.length],
              ["catalog", "Catalog", Waves, groupedCatalog.reduce((total, group) => total + group.items.length, 0)]
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
                  <span className={`rounded-full px-3 py-1 text-sm ${active ? "bg-white/20 text-white" : "bg-neutral-100 text-neutral-500"}`}>{count as number}</span>
                </button>
              );
            })}
          </div>
        ) : null}

        {activeTab === "presets" || onboardingMode ? (
          <div className="grid gap-10">
            <MyGearSelectors />

            <form onSubmit={submit} className="compact-card p-6 sm:p-8">
              <div className="mb-7 flex items-center gap-5">
                <div className="grid h-16 w-16 place-items-center rounded-lg bg-moss text-ink">
                  <Plus className="h-8 w-8" />
                </div>
                <div>
                  <h2 className="text-2xl font-bold">{onboardingMode ? "Save My Gear" : "Create New Preset"}</h2>
                  <p className="mt-1 text-base text-neutral-600 sm:text-lg">
                    {onboardingMode ? "Required: guitar and amplifier. Optional: cabinet, pedals, Multi FX, custom pickups, and going direct." : "Save a rig using the shared equipment catalog"}
                  </p>
                </div>
              </div>

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
                    <label className="label" htmlFor="preset-name">
                      Preset name
                    </label>
                    <input id="preset-name" className="field mt-2 h-12" value={name} onChange={(event) => setName(event.target.value)} required />
                  </div>
                ) : null}
                <Select label={`${presetInstrument === "bass" ? "Bass" : "Guitar"}${onboardingMode ? " *" : ""}`} value={guitar} setValue={setGuitar} options={currentGuitars.map((item) => item.name)} />
                <Select label={`Amplifier${onboardingMode ? " *" : ""}`} value={amp} setValue={setAmp} options={currentAmps.map((item) => item.name)} />
              </div>
              {onboardingMode ? (
                <div className="mt-6 rounded-lg border border-white/80 bg-blue-50/70 p-5">
                  <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
                    <div>
                      <h3 className="text-lg font-bold">Optional gear details</h3>
                      <p className="mt-1 text-sm text-slate-600">Cabinet, pickups, pedals, and direct mode can make your future adaptations more accurate.</p>
                    </div>
                    <button
                      type="button"
                      className="button-secondary min-h-10 rounded-lg px-4 text-sm"
                      onClick={() => setShowAdvancedSetup((value) => !value)}
                    >
                      {showAdvancedSetup ? "Hide details" : "Add optional details"}
                    </button>
                  </div>
                  {showAdvancedSetup ? (
                    <div className="mt-5 grid gap-5 md:grid-cols-2 xl:grid-cols-3">
                      <Select label="Cabinet / Speaker" value={cabinet} setValue={setCabinet} options={cabinets.map((item) => item.name)} />
                      <Select label="Primary pickup" value={pickup} setValue={setPickup} options={pickups.map((item) => item.name)} />
                      <div>
                        <label className="label">Going direct</label>
                        <button
                          type="button"
                          className={`mt-2 flex h-12 w-full items-center justify-between rounded-lg border px-4 text-sm font-semibold transition ${
                            effectsMode === "multi_fx" ? "border-ink bg-ink text-white" : "border-white/80 bg-white text-slate-700"
                          }`}
                          onClick={() => setEffectsMode((current) => (current === "multi_fx" ? "manual" : "multi_fx"))}
                        >
                          <span>{effectsMode === "multi_fx" ? "Enabled" : "Disabled"}</span>
                          <span className={`flex h-6 w-11 items-center rounded-full p-1 ${effectsMode === "multi_fx" ? "bg-white/20" : "bg-slate-200"}`}>
                            <span className={`h-4 w-4 rounded-full bg-white shadow transition ${effectsMode === "multi_fx" ? "translate-x-5" : ""}`} />
                          </span>
                        </button>
                      </div>
                      <Select label="Available effects" value={selectedFx} setValue={setSelectedFx} options={[...pedals, ...effects].map((item) => item.name)} />
                      <Select label="Multi-FX unit" value={multiFx} setValue={setMultiFx} options={multiFxUnits.map((item) => item.name)} />
                      {presetInstrument === "guitar" ? (
                        <>
                          <Select label="Neck pickup override" value={neckPickup} setValue={setNeckPickup} options={["Stock", ...pickups.map((item) => item.name)]} />
                          <Select label="Middle pickup override" value={middlePickup} setValue={setMiddlePickup} options={["Stock", ...pickups.map((item) => item.name)]} />
                          <Select label="Bridge pickup override" value={bridgePickup} setValue={setBridgePickup} options={["Stock", ...pickups.map((item) => item.name)]} />
                        </>
                      ) : null}
                    </div>
                  ) : null}
                </div>
              ) : (
                <div className="grid gap-5 md:grid-cols-2 xl:grid-cols-4">
                  <Select label="Pickup" value={pickup} setValue={setPickup} options={pickups.map((item) => item.name)} />
                  {presetInstrument === "guitar" ? (
                    <>
                      <Select label="Neck pickup override" value={neckPickup} setValue={setNeckPickup} options={["Stock", ...pickups.map((item) => item.name)]} />
                      <Select label="Middle pickup override" value={middlePickup} setValue={setMiddlePickup} options={["Stock", ...pickups.map((item) => item.name)]} />
                      <Select label="Bridge pickup override" value={bridgePickup} setValue={setBridgePickup} options={["Stock", ...pickups.map((item) => item.name)]} />
                    </>
                  ) : null}
                  <Select label="Cabinet / Speaker" value={cabinet} setValue={setCabinet} options={cabinets.map((item) => item.name)} />
                  <Select label="Effects mode" value={effectsMode} setValue={setEffectsMode} options={["manual", "amp_with_effects", "multi_fx"]} />
                  <Select label="Available effects" value={selectedFx} setValue={setSelectedFx} options={[...pedals, ...effects].map((item) => item.name)} />
                  <Select label="Multi-FX unit" value={multiFx} setValue={setMultiFx} options={multiFxUnits.map((item) => item.name)} />
                </div>
              )}
              <button className="button-primary mt-6 min-h-12 rounded-lg">
                <Plus className="h-4 w-4" />
                {onboardingMode ? "Save My Gear and Continue" : "Save preset"}
              </button>
              {onboardingMode ? <p className="mt-3 text-sm text-slate-500">You can update your saved gear anytime from My Gear.</p> : null}
            </form>

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
                    <article key={preset.id} className="compact-card p-6">
                      <div className="mb-5 flex items-start justify-between">
                        <div>
                          <h3 className="text-2xl font-bold">{preset.name}</h3>
                          <p className="text-sm capitalize text-neutral-500">{preset.instrument_type || "gear"} preset</p>
                        </div>
                        <button type="button" className="button-secondary px-3" onClick={() => removePreset(preset.id)} aria-label="Delete preset">
                          <Trash2 className="h-4 w-4" />
                        </button>
                      </div>
                      <div className="grid gap-3 text-base">
                        <div className="flex items-center gap-3 rounded-lg bg-neutral-50 px-4 py-3">
                          <Guitar className="h-5 w-5 text-ink" />
                          {preset.guitar_name || preset.guitar}
                        </div>
                        <div className="flex items-center gap-3 rounded-lg bg-neutral-50 px-4 py-3">
                          <Volume2 className="h-5 w-5 text-ink" />
                          {preset.amp_name || preset.amp}
                        </div>
                        <div className="rounded-lg bg-neutral-50 px-4 py-3">{preset.pickup_name || preset.pickup || "Pickup not set"}</div>
                        <div className="rounded-lg bg-neutral-50 px-4 py-3">{formatPresetCustomPickups(preset) || "Stock pickup positions"}</div>
                        <div className="rounded-lg bg-neutral-50 px-4 py-3">{getPresetCabinet(preset) || "Cabinet not set"}</div>
                        <div className="rounded-lg bg-neutral-50 px-4 py-3">{getPresetEffectsMode(preset).replaceAll("_", " ")}</div>
                        <div className="rounded-lg bg-neutral-50 px-4 py-3">{getPresetSelectedEffect(preset) || "Effects not set"}</div>
                      </div>
                    </article>
                  ))}
                </div>
              ) : (
                <EmptyState icon={<SlidersHorizontal className="h-12 w-12" />} title="No presets yet" body="Create your first gear preset above to get started." />
              )}
              </div>
            ) : null}
          </div>
        ) : null}

        {activeTab === "pedals" ? <CatalogGrid title="Pedals and Drive Chains" items={[...pedals, ...effects]} /> : null}

        {activeTab === "multi_fx" ? <CatalogGrid title="Multi FX Units" items={multiFxUnits} /> : null}

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

function readPresetEffects(preset: Preset): PresetEffects {
  if (Array.isArray(preset.effects)) {
    return preset.effects[0] || {};
  }

  return preset.effects && typeof preset.effects === "object" ? preset.effects : {};
}

function getPresetCabinet(preset: Preset) {
  return readPresetEffects(preset).cabinetName || preset.cabinet || "";
}

function getPresetEffectsMode(preset: Preset) {
  return readPresetEffects(preset).effectsMode || preset.effectsMode || "manual";
}

function getPresetSelectedEffect(preset: Preset) {
  return readPresetEffects(preset).selectedFx || preset.selectedFx || "";
}

function cleanPickupOverride(value: string) {
  return value && value !== "Stock" ? value : undefined;
}

function formatPresetCustomPickups(preset: Preset) {
  const custom = readPresetEffects(preset).customPickups;
  if (!custom) return "";
  return [
    custom.neck ? `Neck: ${custom.neck}` : null,
    custom.middle ? `Middle: ${custom.middle}` : null,
    custom.bridge ? `Bridge: ${custom.bridge}` : null
  ].filter(Boolean).join(" | ");
}

function selectDefaultCabinet(mode: "guitar" | "bass", cabinets: CatalogEntry[], current?: string) {
  const currentCabinet = cabinets.find((item) => item.name === current);
  if (currentCabinet) {
    return currentCabinet.name;
  }

  const bassCabinet = cabinets.find((item) => /ampeg|darkglass|bass/i.test(`${item.name} ${item.description}`));
  if (mode === "bass") {
    return bassCabinet?.name || cabinets[0]?.name || current || "";
  }

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
