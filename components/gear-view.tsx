"use client";

import { FormEvent, useEffect, useState } from "react";
import { Cpu, Guitar, Loader2, Plus, SlidersHorizontal, Trash2, Volume2 } from "lucide-react";
import { brand } from "@/lib/brand";
import { amps, guitars, multiFxUnits, pedalPresets, pickups } from "@/lib/mock-data";
import { createSupabaseBrowserClient } from "@/lib/supabase/browser";

type Preset = {
  id: string;
  name: string;
  instrument_type?: "guitar" | "bass";
  guitar_name?: string;
  amp_name?: string;
  pickup_name?: string;
  guitar?: string;
  amp?: string;
  pickup?: string;
};

export function GearView() {
  const [presets, setPresets] = useState<Preset[]>([]);
  const [name, setName] = useState("Main rig");
  const [guitar, setGuitar] = useState(guitars[0].name);
  const [amp, setAmp] = useState(amps[0].name);
  const [pickup, setPickup] = useState(pickups[0].name);
  const [activeTab, setActiveTab] = useState<"presets" | "pedals" | "multi_fx">("presets");
  const [loading, setLoading] = useState(true);
  const [message, setMessage] = useState("");

  useEffect(() => {
    async function loadPresets() {
      const supabase = createSupabaseBrowserClient();
      if (!supabase) {
        setPresets(JSON.parse(localStorage.getItem(`${brand.storagePrefix}_saved_gear_presets`) || "[]"));
        setLoading(false);
        return;
      }

      const { data, error } = await supabase
        .from("gear_presets")
        .select("id, name, instrument_type, guitar_name, amp_name, pickup_name, created_at")
        .order("created_at", { ascending: false });
      setPresets(error ? [] : data || []);
      setLoading(false);
    }

    loadPresets();
  }, []);

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const supabase = createSupabaseBrowserClient();

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
          instrument_type: "guitar",
          guitar_name: guitar,
          amp_name: amp,
          pickup_name: pickup
        })
        .select("id, name, instrument_type, guitar_name, amp_name, pickup_name")
        .single();
      if (error) {
        setMessage(error.message);
        return;
      }
      setPresets([data, ...presets]);
      return;
    }

    const next = [{ id: crypto.randomUUID(), name, guitar, amp, pickup }, ...presets];
    setPresets(next);
    localStorage.setItem(`${brand.storagePrefix}_saved_gear_presets`, JSON.stringify(next));
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
    <div className="px-4 pb-16 pt-28 sm:px-6 lg:px-8">
      <div className="mx-auto max-w-[1840px]">
        <div className="mb-12">
          <h1 className="text-5xl font-bold tracking-normal">My Gear</h1>
          <p className="mt-4 text-2xl text-neutral-600">Manage your presets, pedals, and multi-effects</p>
        </div>

        {message ? <div className="mb-6 rounded-lg bg-ink px-5 py-4 text-sm font-bold text-white">{message}</div> : null}

        <div className="mb-12 grid gap-5 lg:grid-cols-3">
          {[
            ["presets", "Presets", SlidersHorizontal, presets.length],
            ["pedals", "Pedals", Guitar, pedalPresets.length],
            ["multi_fx", "Multi FX", Cpu, multiFxUnits.length]
          ].map(([value, label, Icon, count]) => {
            const ActiveIcon = Icon as typeof Guitar;
            const active = activeTab === value;
            return (
              <button
                key={value as string}
                type="button"
                className={`flex min-h-20 items-center justify-center gap-4 rounded-lg border text-xl font-bold shadow-sm transition ${
                  active ? "border-ink bg-ink text-white shadow-xl" : "border-white/80 bg-white/80 text-slate-700 hover:border-ocean/50"
                }`}
                onClick={() => setActiveTab(value as "presets" | "pedals" | "multi_fx")}
              >
                <ActiveIcon className="h-6 w-6" />
                {label as string}
                <span className={`rounded-full px-3 py-1 text-sm ${active ? "bg-white/20 text-white" : "bg-neutral-100 text-neutral-500"}`}>{count as number}</span>
              </button>
            );
          })}
        </div>

        {activeTab === "presets" ? (
          <div className="grid gap-10">
            <form onSubmit={submit} className="compact-card p-8">
              <div className="mb-7 flex items-center gap-5">
                <div className="grid h-16 w-16 place-items-center rounded-lg bg-moss text-ink">
                  <Plus className="h-8 w-8" />
                </div>
                <div>
                  <h2 className="text-2xl font-bold">Create New Preset</h2>
                  <p className="mt-1 text-lg text-neutral-600">Save a guitar and amp combination</p>
                </div>
              </div>
              <div className="grid gap-5 lg:grid-cols-4">
                <div>
                  <label className="label" htmlFor="preset-name">
                    Preset name
                  </label>
                  <input id="preset-name" className="field mt-2 h-12" value={name} onChange={(event) => setName(event.target.value)} required />
                </div>
                <Select label="Guitar" value={guitar} setValue={setGuitar} options={guitars.map((item) => item.name)} />
                <Select label="Amp" value={amp} setValue={setAmp} options={amps.map((item) => item.name)} />
                <Select label="Pickup" value={pickup} setValue={setPickup} options={pickups.map((item) => item.name)} />
              </div>
              <button className="button-primary mt-6 min-h-12 rounded-lg">
                <Plus className="h-4 w-4" />
                Save preset
              </button>
            </form>

            <div>
              <div className="mb-6 flex items-center justify-between">
                <h2 className="text-3xl font-bold">Your Presets</h2>
                <span className="text-lg text-neutral-500">{presets.length} saved</span>
              </div>
              {loading ? (
                <div className="compact-card flex min-h-[320px] items-center justify-center gap-3 p-8 text-neutral-600">
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
                          <p className="text-sm text-neutral-500">Gear preset</p>
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
                        <div className="rounded-lg bg-neutral-50 px-4 py-3">{preset.pickup_name || preset.pickup}</div>
                      </div>
                    </article>
                  ))}
                </div>
              ) : (
                <div className="grid min-h-[340px] place-items-center rounded-lg border border-dashed border-blue-100 bg-white/80 p-8 text-center">
                  <div>
                    <div className="mx-auto mb-5 grid h-24 w-24 place-items-center rounded-lg bg-blue-50 text-slate-400">
                      <SlidersHorizontal className="h-12 w-12" />
                    </div>
                    <h2 className="text-3xl font-bold">No presets yet</h2>
                    <p className="mt-3 text-lg text-neutral-600">Create your first gear preset above to get started.</p>
                  </div>
                </div>
              )}
            </div>
          </div>
        ) : null}

        {activeTab === "pedals" ? (
          <CatalogGrid
            title="Pedal presets"
            items={pedalPresets.map((preset) => ({
              id: preset.id,
              name: preset.name,
              meta: preset.category,
              details: preset.pedals
            }))}
          />
        ) : null}

        {activeTab === "multi_fx" ? (
          <CatalogGrid
            title="Multi FX units"
            items={multiFxUnits.map((unit) => ({
              id: unit.id,
              name: unit.name,
              meta: unit.brand,
              details: ["Preset output", "Effect routing", "Amp-model notes"]
            }))}
          />
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
        {options.map((option) => (
          <option key={option}>{option}</option>
        ))}
      </select>
    </div>
  );
}

function CatalogGrid({ title, items }: { title: string; items: Array<{ id: string; name: string; meta: string; details: string[] }> }) {
  return (
    <div>
      <h2 className="mb-6 text-3xl font-bold">{title}</h2>
      <div className="grid gap-5 md:grid-cols-2 xl:grid-cols-3">
        {items.map((item) => (
          <article key={item.id} className="compact-card p-6">
            <div className="mb-4 flex items-center gap-4">
              <div className="grid h-14 w-14 place-items-center rounded-lg bg-ink text-moss">
                <SlidersHorizontal className="h-6 w-6" />
              </div>
              <div>
                <h3 className="text-2xl font-bold">{item.name}</h3>
                <p className="text-sm font-semibold uppercase tracking-[0.12em] text-neutral-400">{item.meta}</p>
              </div>
            </div>
            <div className="flex flex-wrap gap-2">
              {item.details.map((detail) => (
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
