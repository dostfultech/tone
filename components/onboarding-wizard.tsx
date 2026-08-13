"use client";

import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { ArrowRight, Check, Guitar, Loader2, Music2, SlidersHorizontal, Sparkles, Volume2, X } from "lucide-react";
import { SearchableGearDropdown } from "@/components/searchable-gear-dropdown";
import { createSupabaseBrowserClient } from "@/lib/supabase/browser";
import { brand } from "@/lib/brand";
import { trackEvent } from "@/lib/analytics";
import type { GearSearchItem } from "@/lib/my-gear";

type Step = "intro" | "guitar" | "amp" | "extras" | "summary" | "done";

export type OnboardingPresetEffects = {
  effectsMode: string;
  multiFx?: string;
  selectedFx: string;
  features: string[];
  customPickups: Record<string, string>;
};

export type OnboardingGearPreset = {
  id: string;
  name: string;
  instrument_type: "guitar";
  guitar_name: string | null;
  amp_name: string | null;
  pickup_name: null;
  effects: OnboardingPresetEffects;
};

export type OnboardingWizardProps = {
  /** "page" renders standalone (its own route); "modal" is embedded in an overlay and reports completion via callbacks. */
  variant?: "page" | "modal";
  /** Called when the user finishes and taps "Start Matching Tones" (modal variant). Hands back the created preset so the matcher can pre-fill. */
  onComplete?: (payload: { preset: OnboardingGearPreset }) => void;
  /** Called when the user skips/closes (modal variant). */
  onSkip?: () => void;
};

const REFERRALS = ["Instagram", "YouTube", "TikTok", "Reddit", "Facebook", "Google Search", "Friends", "Word of Mouth", "Other"];
const GUITAR_QUICK = ["Fender Stratocaster", "Squier Stratocaster", "Epiphone Les Paul", "Gibson Les Paul", "Fender Telecaster", "Squier Telecaster"];
const AMP_QUICK = ["Boss Katana", "Fender Mustang LT25", "Fender Champion 20", "Marshall CODE 25", "Positive Grid Spark", "Fender Mustang GTX 50"];
const PEDAL_QUICK = ["10-Band EQ", "Tube Screamer", "Boss DS-1", "MXR Carbon Copy", "Boss CE-2", "Big Muff"];
const MULTIFX_QUICK = ["Boss GT-1000", "Line 6 Helix", "HX Stomp", "POD Go", "Line 6 HX Effects", "Boss GX-100"];

const STEP_ORDER: Step[] = ["intro", "guitar", "amp", "extras", "summary", "done"];

export function OnboardingWizard({ variant = "page", onComplete, onSkip }: OnboardingWizardProps = {}) {
  const router = useRouter();
  const [step, setStep] = useState<Step>("intro");
  const [referral, setReferral] = useState<string | null>(null);
  const [guitar, setGuitar] = useState("");
  const [amp, setAmp] = useState("");
  const [pedals, setPedals] = useState<string[]>([]);
  const [multifx, setMultifx] = useState("");
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");
  const [presetName, setPresetName] = useState("");
  const [createdPreset, setCreatedPreset] = useState<OnboardingGearPreset | null>(null);

  const progress = useMemo(() => {
    const idx = STEP_ORDER.indexOf(step);
    return Math.round((idx / (STEP_ORDER.length - 1)) * 100);
  }, [step]);

  function togglePedal(name: string) {
    setPedals((current) => (current.includes(name) ? current.filter((p) => p !== name) : [...current, name]));
  }

  function goToApp() {
    router.push("/app?onboarding=1");
  }

  // "Start Matching Tones" on the done step: modal reports the preset back so the matcher pre-fills; page navigates.
  function complete() {
    if (variant === "modal" && onComplete && createdPreset) {
      onComplete({ preset: createdPreset });
      return;
    }
    goToApp();
  }

  // Skip/exit the whole flow: modal closes in place; page falls back to the app.
  function skip() {
    if (variant === "modal" && onSkip) {
      onSkip();
      return;
    }
    goToApp();
  }

  async function finish() {
    setSaving(true);
    setError("");
    const name = [guitar, amp].filter(Boolean).join(" + ") || "My Rig";
    const usingMultiFx = Boolean(multifx);
    // A multi-FX unit run direct takes the amp slot (mirrors gear-view's save shape).
    const ampName = usingMultiFx ? multifx : amp;
    const hasGear = Boolean(guitar || amp || multifx);
    const effects: OnboardingPresetEffects = {
      effectsMode: usingMultiFx ? "multi_fx" : "manual",
      multiFx: multifx || undefined,
      selectedFx: pedals.join(", "),
      features: [],
      customPickups: {}
    };
    let presetId = `local-${Date.now()}`;

    const supabase = createSupabaseBrowserClient();
    try {
      if (supabase) {
        const {
          data: { user }
        } = await supabase.auth.getUser();
        if (user) {
          if (hasGear) {
            const { data } = await supabase
              .from("gear_presets")
              .insert({
                user_id: user.id,
                name,
                instrument_type: "guitar",
                guitar_name: guitar || null,
                amp_name: ampName || null,
                pickup_name: null,
                effects
              })
              .select("id")
              .single();
            if (data?.id) {
              presetId = data.id as string;
            }
          }
          await supabase
            .from("profiles")
            .update({
              welcome_completed_at: new Date().toISOString(),
              gear_onboarding_completed_at: new Date().toISOString()
            })
            .eq("id", user.id);
        }
      }

      const preset: OnboardingGearPreset = {
        id: presetId,
        name,
        instrument_type: "guitar",
        guitar_name: guitar || null,
        amp_name: ampName || null,
        pickup_name: null,
        effects
      };

      // Local cache so the preset shows immediately even before a round-trip.
      const localPresets = JSON.parse(localStorage.getItem(`${brand.storagePrefix}_saved_gear_presets`) || "[]");
      if (hasGear) {
        localStorage.setItem(
          `${brand.storagePrefix}_saved_gear_presets`,
          JSON.stringify([{ id: presetId, name, instrument_type: "guitar", guitar, amp: ampName, pickup: "", effects }, ...localPresets])
        );
      }
      trackEvent("onboarding_completed", { has_guitar: Boolean(guitar), has_amp: Boolean(amp), pedals: pedals.length, referral: referral || "unknown" });
      setCreatedPreset(preset);
      setPresetName(name);
      setStep("done");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Could not save your rig. You can set it up later.");
    } finally {
      setSaving(false);
    }
  }

  return (
    <div className={variant === "modal" ? "w-full" : "mx-auto max-w-2xl px-4 pb-16 pt-24 sm:px-6"}>
      {step !== "intro" && step !== "done" ? (
        <div className="mb-8">
          <div className="h-1.5 w-full overflow-hidden rounded-full bg-slate-200">
            <div className="h-full rounded-full bg-ocean transition-all duration-500" style={{ width: `${progress}%` }} />
          </div>
        </div>
      ) : null}

      {step === "intro" ? (
        <IntroStep referral={referral} onReferral={setReferral} onStart={() => setStep("guitar")} onSkip={skip} />
      ) : null}

      {step === "guitar" ? (
        <PickerStep
          icon={<Guitar className="h-5 w-5" />}
          title="Your guitar"
          subtitle="Search and tap to pick the guitar you play most."
          quick={GUITAR_QUICK}
          selected={guitar ? [guitar] : []}
          onQuick={(name) => setGuitar((cur) => (cur === name ? "" : name))}
          searchLabel="Search guitars"
          searchPlaceholder="Search guitars..."
          endpoint="/api/equipment/search?type=guitar&instrumentType=guitar"
          requestType="Guitar"
          onSearchSelect={(item) => setGuitar(item.name)}
          onClear={() => setGuitar("")}
          primaryLabel={guitar ? "Continue" : "Select a guitar to continue"}
          primaryDisabled={!guitar}
          onPrimary={() => setStep("amp")}
          skipLabel="I'll add my gear later"
          onSkip={skip}
        />
      ) : null}

      {step === "amp" ? (
        <PickerStep
          icon={<Volume2 className="h-5 w-5" />}
          title="Your amp"
          subtitle="Pick the amp (or modeler) you run your guitar through."
          quick={AMP_QUICK}
          selected={amp ? [amp] : []}
          onQuick={(name) => setAmp((cur) => (cur === name ? "" : name))}
          searchLabel="Search amps"
          searchPlaceholder="Search amps..."
          endpoint="/api/equipment/search?type=amp&instrumentType=guitar"
          requestType="Amp"
          onSearchSelect={(item) => setAmp(item.name)}
          onClear={() => setAmp("")}
          primaryLabel={amp ? "Continue" : "Select an amp to continue"}
          primaryDisabled={!amp}
          onPrimary={() => setStep("extras")}
          skipLabel="I'll add my amp later"
          onSkip={() => setStep("extras")}
          onBack={() => setStep("guitar")}
        />
      ) : null}

      {step === "extras" ? (
        <ExtrasStep
          pedals={pedals}
          multifx={multifx}
          onTogglePedal={togglePedal}
          onMultifx={(name) => setMultifx((cur) => (cur === name ? "" : name))}
          onContinue={() => setStep("summary")}
          onSkip={() => setStep("summary")}
          onBack={() => setStep("amp")}
        />
      ) : null}

      {step === "summary" ? (
        <SummaryStep
          guitar={guitar}
          amp={amp}
          pedals={pedals}
          multifx={multifx}
          saving={saving}
          error={error}
          onEdit={(s) => setStep(s)}
          onConfirm={finish}
          onBack={() => setStep("extras")}
        />
      ) : null}

      {step === "done" ? <DoneStep presetName={presetName} onStart={complete} /> : null}
    </div>
  );
}

function IntroStep({
  referral,
  onReferral,
  onStart,
  onSkip
}: {
  referral: string | null;
  onReferral: (value: string) => void;
  onStart: () => void;
  onSkip: () => void;
}) {
  return (
    <section className="theme-panel p-8 text-center sm:p-10">
      <div className="mx-auto grid h-16 w-16 place-items-center rounded-2xl bg-ocean/10 text-ocean">
        <Guitar className="h-8 w-8" />
      </div>
      <h1 className="mt-6 text-3xl font-bold tracking-normal sm:text-4xl">Let&apos;s set up your rig</h1>
      <p className="mx-auto mt-3 max-w-md text-base leading-7 text-slate-600">
        Tell us what you play and we&apos;ll tailor every tone to your exact gear.
      </p>

      <div className="mx-auto mt-8 grid max-w-md gap-3 text-left">
        {[
          { icon: <Guitar className="h-5 w-5" />, title: "Your guitar & amp", body: "Pick from thousands of real models." },
          { icon: <SlidersHorizontal className="h-5 w-5" />, title: "Pedals & effects", body: "Add the pedals and multi-FX you own." },
          { icon: <Sparkles className="h-5 w-5" />, title: "Better matches", body: "Every tone dialed in for your setup." }
        ].map((item) => (
          <div key={item.title} className="flex items-center gap-3 rounded-xl border border-white/80 bg-white/80 px-4 py-3">
            <div className="grid h-10 w-10 shrink-0 place-items-center rounded-lg bg-ink text-moss">{item.icon}</div>
            <div>
              <div className="text-sm font-bold text-ink">{item.title}</div>
              <div className="text-xs text-slate-500">{item.body}</div>
            </div>
          </div>
        ))}
      </div>

      <div className="mt-8">
        <p className="text-sm font-bold uppercase tracking-[0.14em] text-slate-500">How did you hear about us?</p>
        <div className="mt-3 flex flex-wrap justify-center gap-2">
          {REFERRALS.map((option) => (
            <button
              key={option}
              type="button"
              onClick={() => onReferral(option)}
              className={`rounded-full border px-4 py-2 text-sm font-semibold transition ${
                referral === option ? "border-ocean bg-ocean text-white" : "border-slate-200 bg-white text-slate-600 hover:border-ocean/50"
              }`}
            >
              {option}
            </button>
          ))}
        </div>
      </div>

      <button type="button" className="button-primary mt-9 min-h-14 w-full justify-center text-base" onClick={onStart}>
        Get Started
        <ArrowRight className="h-4 w-4" />
      </button>
      <button type="button" className="mt-3 text-sm font-semibold text-slate-500 hover:text-ink" onClick={onSkip}>
        Skip for now
      </button>
    </section>
  );
}

function PickerStep({
  icon,
  title,
  subtitle,
  quick,
  selected,
  onQuick,
  searchLabel,
  searchPlaceholder,
  endpoint,
  requestType,
  onSearchSelect,
  onClear,
  primaryLabel,
  primaryDisabled,
  onPrimary,
  skipLabel,
  onSkip,
  onBack
}: {
  icon: React.ReactNode;
  title: string;
  subtitle: string;
  quick: string[];
  selected: string[];
  onQuick: (name: string) => void;
  searchLabel: string;
  searchPlaceholder: string;
  endpoint: string;
  requestType: string;
  onSearchSelect: (item: GearSearchItem) => void;
  onClear: () => void;
  primaryLabel: string;
  primaryDisabled: boolean;
  onPrimary: () => void;
  skipLabel: string;
  onSkip: () => void;
  onBack?: () => void;
}) {
  return (
    <section className="theme-panel p-6 sm:p-8">
      <div className="flex items-center gap-3">
        <div className="grid h-11 w-11 place-items-center rounded-xl bg-ocean/10 text-ocean">{icon}</div>
        <div>
          <h2 className="text-xl font-bold text-ink">{title}</h2>
          <p className="text-sm text-slate-600">{subtitle}</p>
        </div>
      </div>

      {selected.length ? (
        <div className="mt-5 flex flex-wrap gap-2">
          {selected.map((name) => (
            <span key={name} className="inline-flex items-center gap-1.5 rounded-full bg-ocean px-3 py-1.5 text-sm font-semibold text-white">
              <Check className="h-3.5 w-3.5" />
              {name}
              <button type="button" onClick={onClear} aria-label={`Remove ${name}`} className="ml-0.5 rounded-full p-0.5 hover:bg-white/20">
                <X className="h-3.5 w-3.5" />
              </button>
            </span>
          ))}
        </div>
      ) : null}

      <div className="mt-5">
        <SearchableGearDropdown
          label={searchLabel}
          hideLabel
          placeholder={searchPlaceholder}
          endpoint={endpoint}
          selectedItems={[]}
          onSelect={onSearchSelect}
          requestType={requestType}
        />
      </div>

      <p className="mt-6 text-xs font-bold uppercase tracking-[0.14em] text-slate-400">Quick select</p>
      <div className="mt-3 flex flex-wrap gap-2">
        {quick.map((name) => {
          const active = selected.includes(name);
          return (
            <button
              key={name}
              type="button"
              onClick={() => onQuick(name)}
              className={`rounded-full border px-4 py-2 text-sm font-semibold transition ${
                active ? "border-ocean bg-ocean/10 text-ocean" : "border-slate-200 bg-white text-slate-600 hover:border-ocean/50"
              }`}
            >
              {name}
            </button>
          );
        })}
      </div>

      <button
        type="button"
        className={`mt-8 min-h-14 w-full justify-center text-base ${primaryDisabled ? "inline-flex items-center gap-2 rounded-md bg-slate-200 px-4 py-2 font-semibold text-slate-400" : "button-primary"}`}
        disabled={primaryDisabled}
        onClick={onPrimary}
      >
        {primaryLabel}
        {!primaryDisabled ? <ArrowRight className="h-4 w-4" /> : null}
      </button>
      <div className="mt-3 flex items-center justify-between">
        {onBack ? (
          <button type="button" className="text-sm font-semibold text-slate-500 hover:text-ink" onClick={onBack}>
            Back
          </button>
        ) : (
          <span />
        )}
        <button type="button" className="text-sm font-semibold text-slate-500 hover:text-ink" onClick={onSkip}>
          {skipLabel}
        </button>
      </div>
    </section>
  );
}

function ExtrasStep({
  pedals,
  multifx,
  onTogglePedal,
  onMultifx,
  onContinue,
  onSkip,
  onBack
}: {
  pedals: string[];
  multifx: string;
  onTogglePedal: (name: string) => void;
  onMultifx: (name: string) => void;
  onContinue: () => void;
  onSkip: () => void;
  onBack: () => void;
}) {
  const [tab, setTab] = useState<"pedals" | "multifx">("pedals");
  const count = pedals.length + (multifx ? 1 : 0);
  return (
    <section className="theme-panel p-6 sm:p-8">
      <div className="flex items-center gap-3">
        <div className="grid h-11 w-11 place-items-center rounded-xl bg-ocean/10 text-ocean">
          <SlidersHorizontal className="h-5 w-5" />
        </div>
        <div>
          <h2 className="text-xl font-bold text-ink">Extras</h2>
          <p className="text-sm text-slate-600">Add pedals or a multi-FX unit — totally optional.</p>
        </div>
      </div>

      <div className="mt-5 inline-flex rounded-lg border border-slate-200 bg-white p-1">
        {(["pedals", "multifx"] as const).map((value) => (
          <button
            key={value}
            type="button"
            onClick={() => setTab(value)}
            className={`rounded-md px-4 py-2 text-sm font-bold capitalize transition ${tab === value ? "bg-ink text-white" : "text-slate-600 hover:bg-slate-50"}`}
          >
            {value === "multifx" ? "Multi-FX" : "Pedals"}
          </button>
        ))}
      </div>

      <p className="mt-5 text-xs font-bold uppercase tracking-[0.14em] text-slate-400">Quick select</p>
      <div className="mt-3 flex flex-wrap gap-2">
        {(tab === "pedals" ? PEDAL_QUICK : MULTIFX_QUICK).map((name) => {
          const active = tab === "pedals" ? pedals.includes(name) : multifx === name;
          return (
            <button
              key={name}
              type="button"
              onClick={() => (tab === "pedals" ? onTogglePedal(name) : onMultifx(name))}
              className={`rounded-full border px-4 py-2 text-sm font-semibold transition ${
                active ? "border-ocean bg-ocean/10 text-ocean" : "border-slate-200 bg-white text-slate-600 hover:border-ocean/50"
              }`}
            >
              {name}
            </button>
          );
        })}
      </div>

      <button type="button" className="button-primary mt-8 min-h-14 w-full justify-center text-base" onClick={onContinue}>
        {count ? `Continue with ${count} extra${count === 1 ? "" : "s"}` : "Continue"}
        <ArrowRight className="h-4 w-4" />
      </button>
      <div className="mt-3 flex items-center justify-between">
        <button type="button" className="text-sm font-semibold text-slate-500 hover:text-ink" onClick={onBack}>
          Back
        </button>
        <button type="button" className="text-sm font-semibold text-slate-500 hover:text-ink" onClick={onSkip}>
          Skip for now
        </button>
      </div>
    </section>
  );
}

function SummaryStep({
  guitar,
  amp,
  pedals,
  multifx,
  saving,
  error,
  onEdit,
  onConfirm,
  onBack
}: {
  guitar: string;
  amp: string;
  pedals: string[];
  multifx: string;
  saving: boolean;
  error: string;
  onEdit: (step: Step) => void;
  onConfirm: () => void;
  onBack: () => void;
}) {
  const rows = (
    [
      { label: "Guitar", icon: <Guitar className="h-4 w-4" />, values: guitar ? [guitar] : [], step: "guitar" as Step },
      { label: "Amp", icon: <Volume2 className="h-4 w-4" />, values: amp ? [amp] : [], step: "amp" as Step },
      { label: "Pedals", icon: <SlidersHorizontal className="h-4 w-4" />, values: pedals, step: "extras" as Step },
      { label: "Multi-FX", icon: <SlidersHorizontal className="h-4 w-4" />, values: multifx ? [multifx] : [], step: "extras" as Step }
    ] as { label: string; icon: React.ReactNode; values: string[]; step: Step }[]
  ).filter((row) => row.values.length);

  return (
    <section className="theme-panel p-6 sm:p-8">
      <div className="text-center">
        <div className="mx-auto grid h-12 w-12 place-items-center rounded-full bg-emerald-100 text-emerald-600">
          <Check className="h-6 w-6" />
        </div>
        <h2 className="mt-3 text-2xl font-bold text-ink">Your rig summary</h2>
        <p className="mt-1 text-sm text-slate-600">Review your setup, then we&apos;ll create a preset for you.</p>
      </div>

      <div className="mt-6 grid gap-3">
        {rows.length ? (
          rows.map((row) => (
            <div key={row.label} className="rounded-xl border border-white/80 bg-white/80 p-4">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2 text-sm font-bold text-ink">
                  <span className="text-ocean">{row.icon}</span>
                  {row.label} <span className="text-slate-400">({row.values.length})</span>
                </div>
                <button type="button" className="text-xs font-bold text-ocean hover:underline" onClick={() => onEdit(row.step)}>
                  Edit
                </button>
              </div>
              <div className="mt-2 flex flex-wrap gap-2">
                {row.values.map((v) => (
                  <span key={v} className="rounded-md bg-slate-100 px-2.5 py-1 text-xs font-semibold text-slate-700">
                    {v}
                  </span>
                ))}
              </div>
            </div>
          ))
        ) : (
          <div className="rounded-xl border border-amber-200 bg-amber-50 px-4 py-3 text-sm font-medium text-amber-900">
            You haven&apos;t added any gear yet. You can still continue and set it up later.
          </div>
        )}
      </div>

      {error ? <p className="mt-4 text-sm font-semibold text-red-600">{error}</p> : null}

      <button type="button" className="button-primary mt-7 min-h-14 w-full justify-center text-base" disabled={saving} onClick={onConfirm}>
        {saving ? <Loader2 className="h-4 w-4 animate-spin" /> : null}
        Looks good! Let&apos;s go
      </button>
      <button type="button" className="mt-3 w-full text-center text-sm font-semibold text-slate-500 hover:text-ink" onClick={onBack}>
        Back
      </button>
    </section>
  );
}

function DoneStep({ presetName, onStart }: { presetName: string; onStart: () => void }) {
  return (
    <section className="theme-panel p-8 text-center sm:p-10">
      <div className="mx-auto grid h-16 w-16 place-items-center rounded-full bg-emerald-100 text-emerald-600">
        <Check className="h-8 w-8" />
      </div>
      <h1 className="mt-6 text-3xl font-bold tracking-normal">You&apos;re all set!</h1>
      {presetName ? (
        <>
          <p className="mt-3 text-base text-slate-600">We created a gear preset for you:</p>
          <div className="mx-auto mt-4 inline-flex items-center gap-2 rounded-xl border border-white/80 bg-white/90 px-5 py-3 text-base font-bold text-ink shadow-sm">
            <Music2 className="h-5 w-5 text-ocean" />
            {presetName}
          </div>
          <p className="mx-auto mt-4 max-w-sm text-sm text-slate-500">
            It&apos;s loaded into the matcher — just pick a song and start matching tones.
          </p>
        </>
      ) : (
        <p className="mx-auto mt-3 max-w-sm text-base text-slate-600">Head to the app and pick a song to match your first tone.</p>
      )}
      <button type="button" className="button-primary mt-8 min-h-14 w-full justify-center text-base" onClick={onStart}>
        Start Matching Tones
        <ArrowRight className="h-4 w-4" />
      </button>
    </section>
  );
}
