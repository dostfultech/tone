"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { Database, Gift, Guitar, Loader2, Search } from "lucide-react";
import { createSupabaseBrowserClient } from "@/lib/supabase/browser";

export function WelcomeView() {
  const router = useRouter();
  const [loading, setLoading] = useState(false);

  async function startOnboarding() {
    setLoading(true);

    const supabase = createSupabaseBrowserClient();
    if (supabase) {
      const {
        data: { user }
      } = await supabase.auth.getUser();

      if (user) {
        await supabase
          .from("profiles")
          .update({ welcome_completed_at: new Date().toISOString() })
          .eq("id", user.id)
          .is("welcome_completed_at", null);
      }
    }

    router.push("/gear?onboarding=1");
  }

  return (
    <div className="px-4 pb-14 pt-24 sm:px-6 lg:px-8">
      <div className="mx-auto max-w-5xl">
        <section className="theme-panel theme-blue-panel overflow-hidden p-8 lg:p-10">
          <div className="grid gap-8 lg:grid-cols-[minmax(0,1fr)_320px] lg:items-center">
            <div>
              <div className="inline-flex items-center gap-2 rounded-md bg-white/80 px-4 py-2 text-xs font-bold uppercase tracking-[0.14em] text-slate-600">
                <Gift className="h-4 w-4 text-ocean" />
                Welcome to Tonefex
              </div>
              <h1 className="mt-6 text-4xl font-bold tracking-normal sm:text-5xl">
                Get your first 3 songs adapted to <span className="lime-highlight">your gear</span> for free.
              </h1>
              <p className="mt-5 max-w-3xl text-lg leading-8 text-slate-600">
                Save your guitar rig once, search the tone database, and turn any supported song into settings that fit the gear you actually play.
              </p>
              <div className="mt-8 grid gap-3 sm:grid-cols-3">
                <WelcomeFeature icon={<Search className="h-5 w-5" />} label="Search thousands of songs" />
                <WelcomeFeature icon={<Guitar className="h-5 w-5" />} label="Save your own guitar rig" />
                <WelcomeFeature icon={<Database className="h-5 w-5" />} label="Adapt songs to your own equipment" />
              </div>
              <button type="button" className="button-primary mt-8 min-h-14 rounded-lg px-8 text-base" onClick={startOnboarding} disabled={loading}>
                {loading ? <Loader2 className="h-5 w-5 animate-spin" /> : null}
                Get Started
              </button>
            </div>

            <div className="rounded-2xl border border-white/80 bg-white/80 p-6 shadow-lg">
              <div className="text-xs font-bold uppercase tracking-[0.14em] text-slate-500">Your account starts with</div>
              <div className="mt-4 flex items-end gap-3">
                <div className="text-5xl font-bold text-ink">3</div>
                <div className="pb-1 text-lg font-semibold text-slate-600">Free Adaptations</div>
              </div>
              <div className="mt-6 rounded-lg border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm font-semibold text-emerald-800">
                Only successful adaptations use a credit.
              </div>
              <div className="mt-6 grid gap-3 text-sm text-slate-600">
                <div className="rounded-lg bg-slate-50 px-4 py-3">Unlimited song search and browsing</div>
                <div className="rounded-lg bg-slate-50 px-4 py-3">My Gear setup and editing included</div>
                <div className="rounded-lg bg-slate-50 px-4 py-3">Expert unlocks unlimited adaptations</div>
              </div>
            </div>
          </div>
        </section>
      </div>
    </div>
  );
}

function WelcomeFeature({ icon, label }: { icon: React.ReactNode; label: string }) {
  return (
    <div className="rounded-lg border border-white/80 bg-white/80 px-4 py-4 text-sm font-semibold text-ink shadow-sm">
      <div className="flex items-center gap-3">
        <div className="grid h-10 w-10 place-items-center rounded-md bg-ink text-moss">{icon}</div>
        <span>{label}</span>
      </div>
    </div>
  );
}
