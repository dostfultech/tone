import type { Metadata } from "next";
import Link from "next/link";
import { redirect } from "next/navigation";
import { ArrowRight, BadgeCheck, Guitar, Library, MessageSquare, Music2, Star, Users, Volume2, Zap } from "lucide-react";
import { brand } from "@/lib/brand";
import { buildPageMetadata, toAbsoluteUrl } from "@/lib/seo";
import { SiteShell } from "@/components/site-shell";
import { Reviews } from "@/components/reviews";

const differentiators = [
  {
    icon: BadgeCheck,
    title: "A hand-verified tone library",
    body: "Tones researched song by song — real rigs, real interviews, real settings. No auto-generated guesses wearing a lab coat."
  },
  {
    icon: Volume2,
    title: "Bass players get a real seat",
    body: "Full bass mode with its own researched basslines — from Motown fingerstyle to slap funk. Not a guitar app with the gain turned down."
  },
  {
    icon: Zap,
    title: "Settings translated, not copied",
    body: "A Plexi's 6 is not your practice amp's 6. We remap every value onto the channels, knobs, and pedals your rig actually has."
  },
  {
    icon: MessageSquare,
    title: "Tuned by player feedback",
    body: "Every adaptation can be rated and corrected by real players, and those corrections feed back into the engine. The tones get sharper every week."
  }
];

const trendingSongs = [
  { title: "Master of Puppets", artist: "Metallica", genre: "Metal", part: "Riff" },
  { title: "Sweet Child O' Mine", artist: "Guns N' Roses", genre: "Rock", part: "Riff" },
  { title: "Comfortably Numb", artist: "Pink Floyd", genre: "Rock", part: "Solo" },
  { title: "Smells Like Teen Spirit", artist: "Nirvana", genre: "Rock", part: "Riff" },
  { title: "Hotel California", artist: "Eagles", genre: "Rock", part: "Solo" },
  { title: "Enter Sandman", artist: "Metallica", genre: "Metal", part: "Riff" },
  { title: "Eruption", artist: "Van Halen", genre: "Rock", part: "Solo" },
  { title: "Back in Black", artist: "AC/DC", genre: "Rock", part: "Riff" }
];

const testimonials = [
  {
    name: "JamSession_92",
    role: "Bedroom player",
    gradient: "from-ocean to-copper",
    text: "Found accurate tones for all my favorite songs — adapted to my gear, it sounds so close to the original."
  },
  {
    name: "ToneChaser",
    role: "Gigging guitarist",
    gradient: "from-moss to-ocean",
    text: "I could never nail that Smells Like Teen Spirit sound. The moment I used this, my tones completely changed."
  },
  {
    name: "RiffMaster",
    role: "Home studio",
    gradient: "from-ember to-copper",
    text: "I was about to give up trying to dial in my amp. This changed everything — real settings, real results."
  }
];

export const metadata: Metadata = buildPageMetadata({
  title: "Tonefex — Sound Like Any Song on Your Own Amp",
  description: "Search a song, get the settings for your exact guitar, amp, and pedals. Researched guitar and bass tones, translated to the gear you own.",
  path: "/",
  keywords: [
    "guitar tone finder",
    "bass tone settings",
    "amp settings by song",
    "guitar effects chain",
    "tonefex"
  ]
});

type HomePageProps = {
  searchParams?: Promise<Record<string, string | string[] | undefined>>;
};

export default async function HomePage({ searchParams }: HomePageProps) {
  const params = await searchParams;
  const code = stringParam(params?.code);
  const error = stringParam(params?.error);
  const errorDescription = stringParam(params?.error_description);
  const structuredData = [
    {
      "@context": "https://schema.org",
      "@type": "Organization",
      name: brand.appName,
      url: toAbsoluteUrl("/"),
      logo: toAbsoluteUrl("/tonefex-logo.svg"),
      sameAs: []
    },
    {
      "@context": "https://schema.org",
      "@type": "WebSite",
      name: `${brand.appName} Guitar Tone Matching`,
      url: toAbsoluteUrl("/"),
      potentialAction: {
        "@type": "SearchAction",
        target: `${toAbsoluteUrl("/songs")}?q={search_term_string}`,
        "query-input": "required name=search_term_string"
      }
    },
    {
      "@context": "https://schema.org",
      "@type": "SoftwareApplication",
      name: brand.appName,
      applicationCategory: "MusicApplication",
      operatingSystem: "Web",
      offers: {
        "@type": "Offer",
        priceCurrency: "USD",
        price: "0",
        availability: "https://schema.org/InStock"
      },
      description: "Researched tone matching and gear adaptation for guitar and bass players.",
      url: toAbsoluteUrl("/")
    }
  ];

  if (code) {
    const callbackParams = new URLSearchParams({ code, next: "/app" });
    redirect(`/auth/callback?${callbackParams.toString()}`);
  }

  if (error) {
    const loginParams = new URLSearchParams({
      error,
      message: errorDescription || "Authentication could not be completed."
    });
    redirect(`/login?${loginParams.toString()}`);
  }

  return (
    <SiteShell>
      {structuredData.map((item) => (
        <script
          key={item["@type"]}
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(item) }}
        />
      ))}

      {/* Hero — dark stage */}
      <section className="stage-dark stage-grid-lines relative overflow-hidden">
        <div className="section relative py-20 text-center sm:py-24 lg:py-28">
          <div className="stage-chip">
            <Star className="h-4 w-4 shrink-0 fill-amber-400 text-amber-400" />
            <span className="leading-none normal-case tracking-normal">Trusted by 125,000+ guitarists worldwide</span>
          </div>

          <h1 className="mx-auto mt-8 max-w-4xl text-5xl font-bold leading-[1.04] tracking-tight text-white sm:text-6xl lg:text-7xl">
            Sound like any song,
            <span className="block text-moss">on your own amp.</span>
          </h1>

          <p className="mx-auto mt-6 max-w-2xl text-lg leading-8 text-white/65 sm:text-xl">
            Search a song — get the exact knob settings for your guitar, amp, and pedals in seconds.
          </p>

          <div className="mt-9 flex flex-col items-center justify-center gap-3 sm:flex-row">
            <Link href="/app" className="inline-flex min-h-14 items-center justify-center gap-2 rounded-lg bg-moss px-8 text-base font-bold text-ink shadow-[0_0_50px_rgba(167,255,63,0.35)] transition hover:bg-moss/90">
              Dial In a Song
              <ArrowRight className="h-4 w-4" />
            </Link>
            <Link href="/plans" className="inline-flex min-h-14 items-center justify-center gap-2 rounded-lg border border-white/20 px-8 text-base font-semibold text-white transition hover:bg-white/10">
              View Plans
            </Link>
          </div>

          {/* Rig-card mock — one card, song-first flow */}
          <div className="mx-auto mt-14 max-w-3xl text-left">
            <div className="stage-card overflow-hidden">
              <div className="flex items-center justify-between border-b border-white/10 px-6 py-4">
                <div className="flex items-center gap-3">
                  <div className="grid h-10 w-10 place-items-center rounded-lg bg-moss/15 text-moss">
                    <Music2 className="h-5 w-5" />
                  </div>
                  <div>
                    <div className="text-sm font-bold text-white">Sweet Child O&apos; Mine</div>
                    <div className="text-xs text-white/50">Guns N&apos; Roses &middot; Riff</div>
                  </div>
                </div>
                <span className="inline-flex items-center gap-1 rounded-full bg-moss/15 px-3 py-1 text-xs font-bold text-moss">
                  <BadgeCheck className="h-3.5 w-3.5" />
                  Verified
                </span>
              </div>
              <div className="grid gap-px bg-white/10 sm:grid-cols-2">
                <div className="bg-[#0d0c1d] p-5">
                  <div className="text-xs font-bold uppercase tracking-widest text-white/40">On your rig</div>
                  <div className="mt-3 grid grid-cols-4 gap-2 text-center">
                    {[["Gain", 7], ["Treble", 6], ["Mids", 5], ["Bass", 5]].map(([label, value]) => (
                      <div key={String(label)} className="rounded-lg bg-white/5 py-3">
                        <AmpKnob value={Number(value)} />
                        <div className="mt-1.5 text-sm font-bold text-moss">{value}</div>
                        <div className="text-[11px] text-white/50">{label}</div>
                      </div>
                    ))}
                  </div>
                  <div className="mt-3 rounded-lg bg-white/5 px-4 py-2.5 text-sm text-white/80">
                    Bridge humbucker &middot; OD channel &middot; volume at 8
                  </div>
                </div>
                <div className="bg-[#0d0c1d] p-5">
                  <div className="text-xs font-bold uppercase tracking-widest text-white/40">The original rig</div>
                  <div className="mt-3 space-y-2 text-sm text-white/80">
                    <div className="rounded-lg bg-white/5 px-4 py-2.5">Les Paul &rarr; Marshall Super Lead 1959</div>
                    <div className="rounded-lg bg-white/5 px-4 py-2.5">Wah &rarr; Overdrive &rarr; Delay</div>
                    <div className="rounded-lg bg-white/5 px-4 py-2.5">Researched from rig rundowns</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Differentiators */}
      <section id="why-tonefex" className="scroll-mt-20 border-b border-white/80">
        <div className="section py-16 lg:py-20">
          <div className="mx-auto mb-12 max-w-3xl text-center">
            <p className="text-sm font-bold uppercase tracking-[0.18em] text-ocean">Why players switch</p>
            <h2 className="mt-3 text-3xl font-bold tracking-normal text-ink sm:text-4xl">
              Built different where it counts
            </h2>
          </div>
          <div className="grid gap-6 md:grid-cols-2">
            {differentiators.map((feature) => {
              const Icon = feature.icon;
              return (
                <article key={feature.title} className="compact-card p-7">
                  <div className="mb-5 grid h-12 w-12 place-items-center rounded-lg bg-ink text-moss shadow-lg">
                    <Icon className="h-5 w-5" />
                  </div>
                  <h3 className="text-lg font-bold">{feature.title}</h3>
                  <p className="mt-2 text-sm leading-6 text-slate-600">{feature.body}</p>
                </article>
              );
            })}
          </div>
        </div>
      </section>

      {/* How it works — video + 3 beats */}
      <section id="how-it-works" className="scroll-mt-20 border-b border-white/80 bg-slate-50">
        <div className="section py-16 lg:py-20">
          <div className="mx-auto mb-12 max-w-3xl text-center">
            <h2 className="text-3xl font-bold tracking-normal text-ink sm:text-4xl">From song to sound in three moves</h2>
            <p className="mt-3 text-base text-slate-600">Watch a real tone get dialed in, start to finish.</p>
          </div>
          <div className="mx-auto mb-12 max-w-4xl">
            <div className="overflow-hidden rounded-xl border border-white/10 bg-ink shadow-[0_30px_90px_rgba(8,7,26,0.35)]">
              <video
                className="block w-full"
                src="/how-it-works.mp4"
                controls
                playsInline
                preload="metadata"
              />
            </div>
          </div>
          <div className="grid gap-6 md:grid-cols-3">
            {[
              {
                icon: Music2,
                title: "Name the song",
                body: "Type it once. We pull the researched original rig — amp, guitar, pickups, and the full effects chain behind the recording."
              },
              {
                icon: Guitar,
                title: "Tell us your rig once",
                body: "Save your guitar, amp, and pedalboard a single time. Every tone you look up from then on speaks your gear's language."
              },
              {
                icon: Zap,
                title: "Copy the knobs",
                body: "You get numbers for your controls — gain, EQ, pickup choice, pedal order — plus playing notes on how to make it breathe."
              }
            ].map((step, i) => {
              const Icon = step.icon;
              return (
                <article key={step.title} className="rounded-xl border border-white/80 bg-white p-7 shadow-sm">
                  <div className="mb-4 flex items-center gap-3">
                    <div className="grid h-10 w-10 place-items-center rounded-lg bg-ink text-sm font-bold text-moss">{i + 1}</div>
                    <Icon className="h-5 w-5 text-ocean" />
                  </div>
                  <h3 className="text-lg font-bold text-ink">{step.title}</h3>
                  <p className="mt-2 text-sm leading-6 text-slate-600">{step.body}</p>
                </article>
              );
            })}
          </div>
        </div>
      </section>

      {/* What players are chasing */}
      <section id="trending" className="scroll-mt-20">
        <div className="section py-16 lg:py-20">
          <div className="mx-auto mb-10 max-w-3xl text-center">
            <p className="text-sm font-bold uppercase tracking-[0.18em] text-ocean">On the boards right now</p>
            <h2 className="mt-3 text-3xl font-bold tracking-normal text-ink sm:text-4xl">What players are chasing</h2>
            <p className="mt-3 text-base text-slate-600">The most-dialed tones this week</p>
          </div>
          <div className="mx-auto grid max-w-4xl gap-3">
            {trendingSongs.map((song, i) => (
              <Link
                key={`${song.title}-${song.artist}`}
                href="/app"
                className="group flex items-center gap-4 rounded-xl border border-white/80 bg-white px-5 py-4 shadow-sm transition-shadow hover:shadow-md"
              >
                <div className="grid h-10 w-10 flex-shrink-0 place-items-center rounded-lg bg-ink text-sm font-bold text-moss">
                  {i + 1}
                </div>
                <div className="min-w-0 flex-1">
                  <div className="truncate text-sm font-semibold text-ink">{song.title}</div>
                  <div className="truncate text-xs text-slate-500">{song.artist}</div>
                </div>
                <div className="hidden items-center gap-2 sm:flex">
                  <span className="rounded-md bg-slate-100 px-2.5 py-1 text-xs font-medium text-slate-600">{song.genre}</span>
                  <span className="rounded-md bg-slate-100 px-2.5 py-1 text-xs font-medium text-slate-600">{song.part}</span>
                </div>
                <ArrowRight className="h-4 w-4 flex-shrink-0 text-slate-400 transition-transform group-hover:translate-x-0.5" />
              </Link>
            ))}
          </div>
        </div>
      </section>

      {/* Library depth */}
      <section className="stage-dark border-y border-white/10">
        <div className="section py-16 lg:py-20">
          <div className="mx-auto grid max-w-5xl gap-8 text-center sm:grid-cols-3">
            {[
              { icon: Library, stat: "15,000+", label: "Guitar & bass tones for the songs you want to play" },
              { icon: Users, stat: "125,000+", label: "Guitarists worldwide trust the settings" },
              { icon: Volume2, stat: "2", label: "Full instruments — dedicated guitar and bass engines" }
            ].map((item) => {
              const Icon = item.icon;
              return (
                <div key={item.label} className="stage-card px-6 py-8">
                  <Icon className="mx-auto h-6 w-6 text-moss" />
                  <div className="mt-3 text-4xl font-bold text-white">{item.stat}</div>
                  <p className="mt-2 text-sm leading-6 text-white/60">{item.label}</p>
                </div>
              );
            })}
          </div>
        </div>
      </section>

      {/* Testimonials */}
      <section className="border-b border-white/80 bg-slate-50">
        <div className="section py-16 lg:py-20">
          <h2 className="text-center text-3xl font-bold tracking-normal text-ink sm:text-4xl">
            Players on {brand.appName}
          </h2>
          <div className="mx-auto mt-10 grid max-w-5xl gap-6 md:grid-cols-3">
            {testimonials.map((t) => (
              <article key={t.name} className="rounded-xl border border-white/80 bg-white p-6 shadow-sm">
                <div className="mb-4 flex items-center gap-3">
                  <div className={`grid h-11 w-11 shrink-0 place-items-center rounded-full bg-gradient-to-br ${t.gradient} text-base font-bold text-white shadow-md`}>
                    {t.name.slice(0, 1).toUpperCase()}
                  </div>
                  <div>
                    <div className="text-sm font-semibold text-ink">{t.name}</div>
                    <div className="text-xs text-slate-500">{t.role}</div>
                  </div>
                </div>
                <div className="mb-3 flex gap-0.5">
                  {Array.from({ length: 5 }).map((_, i) => (
                    <Star key={i} className="h-4 w-4 fill-amber-400 text-amber-400" />
                  ))}
                </div>
                <p className="text-sm leading-6 text-slate-700">&ldquo;{t.text}&rdquo;</p>
              </article>
            ))}
          </div>
        </div>
      </section>

      {/* CTA Banner */}
      <section className="section py-16">
        <div className="stage-dark rounded-xl border border-white/10 p-8 text-center shadow-lg lg:p-12">
          <h2 className="text-3xl font-bold text-white sm:text-4xl">Tonight&apos;s song is waiting.</h2>
          <p className="mx-auto mt-3 max-w-xl text-base text-white/60">
            Search it, dial the numbers onto your amp, and hear your rig do something it&apos;s never done.
          </p>
          <div className="mt-8 flex flex-col items-center justify-center gap-3 sm:flex-row">
            <Link href="/app" className="inline-flex min-h-14 items-center gap-2 rounded-lg bg-moss px-8 text-base font-bold text-ink shadow transition-colors hover:bg-moss/90">
              Dial In a Song
              <ArrowRight className="h-4 w-4" />
            </Link>
            <Link href="/plans" className="inline-flex min-h-14 items-center gap-2 rounded-lg border border-white/20 px-8 text-base font-semibold text-white transition-colors hover:bg-white/10">
              View Plans
            </Link>
          </div>
        </div>
      </section>

      {/* Reviews */}
      <Reviews />
    </SiteShell>
  );
}

function stringParam(value: string | string[] | undefined) {
  return Array.isArray(value) ? value[0] || "" : value || "";
}

/**
 * Custom amp-knob dial (0-10). Pointer sweeps 270deg from 7 o'clock to 5 o'clock,
 * like a real amp face — our own illustration style, no stock art.
 */
function AmpKnob({ value }: { value: number }) {
  const angle = -135 + (Math.min(10, Math.max(0, value)) / 10) * 270;
  return (
    <svg viewBox="0 0 48 48" className="mx-auto h-11 w-11" role="img" aria-label={`set to ${value}`}>
      <circle cx="24" cy="24" r="21" fill="#16152b" stroke="rgba(255,255,255,0.16)" strokeWidth="1.5" />
      <circle cx="24" cy="24" r="15" fill="#1e1d38" stroke="rgba(167,255,63,0.35)" strokeWidth="1" />
      {Array.from({ length: 11 }).map((_, i) => {
        const tickAngle = ((-135 + i * 27) * Math.PI) / 180;
        const x1 = 24 + Math.sin(tickAngle) * 18.5;
        const y1 = 24 - Math.cos(tickAngle) * 18.5;
        const x2 = 24 + Math.sin(tickAngle) * 20.5;
        const y2 = 24 - Math.cos(tickAngle) * 20.5;
        return <line key={i} x1={x1} y1={y1} x2={x2} y2={y2} stroke="rgba(255,255,255,0.3)" strokeWidth="1" />;
      })}
      <line
        x1="24"
        y1="24"
        x2={24 + Math.sin((angle * Math.PI) / 180) * 12}
        y2={24 - Math.cos((angle * Math.PI) / 180) * 12}
        stroke="#a7ff3f"
        strokeWidth="2.5"
        strokeLinecap="round"
      />
      <circle cx="24" cy="24" r="3" fill="#a7ff3f" />
    </svg>
  );
}
