import Link from "next/link";
import { ArrowRight, BrainCircuit, CheckCircle2, Gauge, Guitar, Music2, SlidersHorizontal, Sparkles, Zap } from "lucide-react";
import { SiteShell } from "@/components/site-shell";
import { Reviews } from "@/components/reviews";

const features = [
  {
    icon: BrainCircuit,
    title: "Research-aware matching",
    body: "Start with the song, artist, and part, then translate source-tone clues into a useful starting point."
  },
  {
    icon: SlidersHorizontal,
    title: "Gear adaptation",
    body: "Adjust for your guitar, pickup output, amp voicing, EQ range, pedals, and modeler workflow."
  },
  {
    icon: Zap,
    title: "Fast playable results",
    body: "Get knob values, pickup guidance, effect order, and playing notes in one focused result."
  }
];

const flow = [
  { icon: Music2, title: "Choose a song", body: "Search a real catalog and pick the exact artist or version." },
  { icon: Guitar, title: "Select your gear", body: "Use your own guitar, bass, amp, pedals, or multi-FX unit." },
  { icon: Gauge, title: "Dial it in", body: "Save settings that are adapted for your rig." }
];

export default function HomePage() {
  return (
    <SiteShell>
      <section className="app-gradient border-b border-white/80">
        <div className="section py-20 text-center sm:py-24 lg:py-28">
          <div className="inline-flex items-center gap-2 rounded-md border border-white/80 bg-white/85 px-4 py-2 text-sm font-bold text-slate-700 shadow-sm">
            <Sparkles className="h-4 w-4" />
            Gear-matched guitar and bass tones
          </div>

          <h1 className="mx-auto mt-7 max-w-5xl text-5xl font-bold leading-[1.03] tracking-normal text-ink sm:text-6xl lg:text-7xl">
            Match any <span className="text-ocean">guitar tone</span> to the gear you own.
          </h1>

          <p className="mx-auto mt-6 max-w-3xl text-lg leading-8 text-slate-600 sm:text-xl">
            FretPilot turns song research into practical amp, pickup, pedal, and modeler settings you can dial in fast.
          </p>

          <div className="mt-9 flex flex-col items-center justify-center gap-3 sm:flex-row">
            <Link href="/app" className="button-primary min-h-14 px-7 text-base">
              Start Matching
              <ArrowRight className="h-4 w-4" />
            </Link>
            <Link href="#features" className="button-secondary min-h-14 px-7 text-base">
              Learn More
            </Link>
            <Link href="/plans" className="button-secondary min-h-14 px-7 text-base">
              View Plans
            </Link>
          </div>

          <div className="mx-auto mt-10 flex max-w-3xl flex-col items-center justify-center gap-4 text-sm font-semibold text-slate-700 sm:flex-row">
            <span className="inline-flex items-center gap-2 rounded-md border border-white/80 bg-white/80 px-4 py-2">
              <CheckCircle2 className="h-4 w-4 text-moss" />
              2,000+ guitars
            </span>
            <span className="hidden h-5 w-px bg-blue-100 sm:block" />
            <span className="inline-flex items-center gap-2 rounded-md border border-white/80 bg-white/80 px-4 py-2">
              <CheckCircle2 className="h-4 w-4 text-moss" />
              1,500+ amps
            </span>
            <span className="hidden h-5 w-px bg-blue-100 sm:block" />
            <span className="inline-flex items-center gap-2 rounded-md border border-white/80 bg-white/80 px-4 py-2">
              <CheckCircle2 className="h-4 w-4 text-moss" />
              Guitar and bass modes
            </span>
          </div>

          <div className="mx-auto mt-14 grid max-w-5xl gap-4 md:grid-cols-3">
            {flow.map((item) => {
              const Icon = item.icon;
              return (
                <article key={item.title} className="theme-panel p-6 text-left">
                  <div className="mb-5 grid h-12 w-12 place-items-center rounded-lg bg-ink text-moss shadow-lg">
                    <Icon className="h-5 w-5" />
                  </div>
                  <h2 className="text-lg font-bold">{item.title}</h2>
                  <p className="mt-2 text-sm leading-6 text-slate-600">{item.body}</p>
                </article>
              );
            })}
          </div>
        </div>
      </section>

      <section id="features" className="section py-16 lg:py-20">
        <div className="mx-auto mb-10 max-w-3xl text-center">
          <p className="text-sm font-bold uppercase tracking-[0.18em] text-ocean">Powerful features</p>
          <h2 className="mt-3 text-3xl font-bold tracking-normal text-ink sm:text-4xl">Everything a practical tone-matching flow needs</h2>
          <p className="mt-3 text-base leading-7 text-slate-600">Clean inputs, realistic gear context, and results designed for players who want to start dialing now.</p>
        </div>

        <div className="grid gap-5 md:grid-cols-3">
          {features.map((feature) => {
            const Icon = feature.icon;
            return (
              <article key={feature.title} className="compact-card p-7">
                <div className="mb-6 grid h-12 w-12 place-items-center rounded-lg bg-ocean text-white shadow-lg shadow-blue-500/20">
                  <Icon className="h-5 w-5" />
                </div>
                <h3 className="text-xl font-bold">{feature.title}</h3>
                <p className="mt-3 text-sm leading-6 text-slate-600">{feature.body}</p>
              </article>
            );
          })}
        </div>
      </section>

      <section className="section pb-16">
        <div className="theme-blue-panel grid gap-6 rounded-lg border border-white/80 p-8 shadow-[0_30px_90px_rgba(95,141,247,0.16)] md:grid-cols-[1fr_auto] md:items-center lg:p-10">
          <div>
            <p className="text-sm font-bold uppercase tracking-[0.18em] text-ocean">Ready when you are</p>
            <h2 className="mt-3 text-3xl font-bold tracking-normal text-ink">Stop guessing your settings.</h2>
            <p className="mt-3 max-w-2xl text-base leading-7 text-slate-600">Try the matcher, save tones, build gear presets, and upgrade when you are ready for full production access.</p>
          </div>
          <div className="flex flex-col gap-3 sm:flex-row">
            <Link href="/app" className="button-primary min-h-12 px-6">
              Start Journey
            </Link>
            <Link href="/plans" className="button-secondary min-h-12 px-6">
              View Plans
            </Link>
          </div>
        </div>
      </section>

      <Reviews />
    </SiteShell>
  );
}
