import type { Metadata } from "next";
import Link from "next/link";
import { redirect } from "next/navigation";
import { ArrowRight, Guitar, Headphones, Music2, Search, SlidersHorizontal, Sparkles, Star, Zap } from "lucide-react";
import { brand } from "@/lib/brand";
import { buildPageMetadata, toAbsoluteUrl } from "@/lib/seo";
import { SiteShell } from "@/components/site-shell";
import { Reviews } from "@/components/reviews";

const insideFeatures = [
  {
    icon: Search,
    title: "The song's original gear & settings",
    body: "We research the exact rig behind the recording — the artist's amp, guitar, and full pedal/effects setup."
  },
  {
    icon: SlidersHorizontal,
    title: "Dialed into your amp & guitar",
    body: "Not the artist's settings — yours. We translate the tone onto the real channels and controls your specific amp and guitar actually have."
  },
  {
    icon: Headphones,
    title: "Your pedals & effects signal chain",
    body: "We map the song's effects onto the pedals and effects units you own, with exact settings for each one in your chain."
  },
  {
    icon: Music2,
    title: "Works with any song",
    body: "If it has a guitar tone, we research the original rig and dial it into yours."
  }
];

const whyFeatures = [
  {
    title: "Stop guessing settings",
    body: "Real amp, pedal and EQ values researched from rig rundowns and interviews — no more trial and error."
  },
  {
    title: "Built for your gear, not the artist's",
    body: "Most tabs assume a Les Paul into a cranked Marshall. Tonefex works with whatever you actually have."
  },
  {
    title: "Dial in in seconds",
    body: "Pick a song, see your settings, and start playing. No menus, no manuals, no rabbit holes."
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
    text: "Found accurate tones for all my favorite songs — adapted to my gear, it sounds so close to the original."
  },
  {
    name: "ToneChaser",
    text: "I could never nail that Smells Like Teen Spirit sound. The moment I used this, my tones completely changed."
  },
  {
    name: "RiffMaster",
    text: "I was about to give up trying to dial in my amp. This changed everything — real settings, real results."
  }
];

export const metadata: Metadata = buildPageMetadata({
  title: "Guitar Tone Matching",
  description: "Match iconic guitar and bass tones to the gear you own with AI-assisted settings and adaptation guidance.",
  path: "/",
  keywords: [
    "guitar tone matcher",
    "bass tone matching",
    "amp settings",
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
      description: "AI-assisted tone matching and gear adaptation for guitar and bass players.",
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

      {/* Hero */}
      <section className="app-gradient border-b border-white/80">
        <div className="section py-20 text-center sm:py-24 lg:py-28">
          <div className="inline-flex items-center gap-3 rounded-full border border-white/80 bg-white/85 px-5 py-2.5 text-sm font-semibold text-slate-700 shadow-sm">
            <span className="inline-flex items-center gap-1.5">
              <Sparkles className="h-4 w-4 text-ocean" />
              Trusted by guitarists worldwide
            </span>
            <span className="h-4 w-px bg-slate-300" />
            <span className="inline-flex items-center gap-1">
              <Star className="h-3.5 w-3.5 fill-amber-400 text-amber-400" />
              4.9 rating
            </span>
          </div>

          <p className="mt-6 text-sm font-bold uppercase tracking-[0.18em] text-ocean">Meet {brand.appName}</p>

          <h1 className="mx-auto mt-4 max-w-4xl text-5xl font-bold leading-[1.05] tracking-tight text-ink sm:text-6xl lg:text-7xl">
            Nail any guitar tone, on the gear you own.
          </h1>

          <p className="mx-auto mt-6 max-w-2xl text-lg leading-8 text-slate-600 sm:text-xl">
            Pick any song and get researched amp, pickup, and pedal settings — then adapted to your exact guitar and amp.
          </p>

          <div className="mt-9 flex flex-col items-center justify-center gap-3 sm:flex-row">
            <Link href="/app" className="button-primary min-h-14 px-8 text-base">
              Start Matching
              <ArrowRight className="h-4 w-4" />
            </Link>
            <Link href="/plans" className="button-secondary min-h-14 px-8 text-base">
              View Plans
            </Link>
          </div>

          {/* Product mockups */}
          <div className="mx-auto mt-14 grid max-w-4xl gap-6 md:grid-cols-2">
            <div className="overflow-hidden rounded-xl border border-white/80 bg-white/90 p-5 shadow-lg">
              <div className="mb-3 flex items-center gap-2 text-xs font-bold uppercase tracking-widest text-slate-400">
                <Guitar className="h-4 w-4" />
                Song Research
              </div>
              <div className="space-y-3">
                <div className="rounded-lg bg-slate-50 px-4 py-3">
                  <div className="text-sm font-semibold text-ink">Sweet Child O&apos; Mine</div>
                  <div className="text-xs text-slate-500">Guns N&apos; Roses &middot; Appetite for Destruction</div>
                </div>
                <div className="rounded-lg bg-slate-50 px-4 py-3">
                  <div className="text-xs font-semibold text-slate-500">Original Rig</div>
                  <div className="mt-1 text-sm text-ink">Les Paul &rarr; Marshall Super Lead 1959</div>
                </div>
                <div className="rounded-lg bg-ocean/10 px-4 py-3">
                  <div className="text-xs font-semibold text-ocean">Pickup</div>
                  <div className="mt-1 text-sm text-ink">Bridge humbucker, Tone 8/10</div>
                </div>
              </div>
            </div>
            <div className="overflow-hidden rounded-xl border border-white/80 bg-white/90 p-5 shadow-lg">
              <div className="mb-3 flex items-center gap-2 text-xs font-bold uppercase tracking-widest text-slate-400">
                <SlidersHorizontal className="h-4 w-4" />
                Your Adapted Tone
              </div>
              <div className="space-y-3">
                <div className="rounded-lg bg-moss/15 px-4 py-3">
                  <div className="text-xs font-semibold text-emerald-700">Your Amp Settings</div>
                  <div className="mt-2 grid grid-cols-3 gap-2 text-center text-xs">
                    <div><div className="text-lg font-bold text-ink">7</div>Gain</div>
                    <div><div className="text-lg font-bold text-ink">6</div>Treble</div>
                    <div><div className="text-lg font-bold text-ink">5</div>Bass</div>
                  </div>
                </div>
                <div className="rounded-lg bg-slate-50 px-4 py-3">
                  <div className="text-xs font-semibold text-slate-500">Effects Chain</div>
                  <div className="mt-1 text-sm text-ink">Wah &rarr; Overdrive &rarr; Delay</div>
                </div>
                <div className="rounded-lg bg-slate-50 px-4 py-3">
                  <div className="text-xs font-semibold text-slate-500">Playing Notes</div>
                  <div className="mt-1 text-sm text-ink">Bridge pickup, volume rolled to 8</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Social proof / Testimonials */}
      <section className="border-b border-white/80 bg-slate-50">
        <div className="section py-16 lg:py-20">
          <h2 className="text-center text-3xl font-bold tracking-normal text-ink sm:text-4xl">
            Loved by guitarists everywhere
          </h2>
          <div className="mx-auto mt-10 grid max-w-5xl gap-6 md:grid-cols-3">
            {testimonials.map((t) => (
              <article key={t.name} className="rounded-xl border border-white/80 bg-white p-6 shadow-sm">
                <div className="mb-4 flex gap-0.5">
                  {Array.from({ length: 5 }).map((_, i) => (
                    <Star key={i} className="h-4 w-4 fill-amber-400 text-amber-400" />
                  ))}
                </div>
                <p className="text-sm leading-6 text-slate-700">&ldquo;{t.text}&rdquo;</p>
                <div className="mt-4 text-sm font-semibold text-ink">{t.name}</div>
              </article>
            ))}
          </div>
        </div>
      </section>

      {/* How it works */}
      <section id="how-it-works" className="scroll-mt-20">
        <div className="section py-16 lg:py-20">
          <div className="mx-auto mb-12 max-w-3xl text-center">
            <p className="text-sm font-bold uppercase tracking-[0.18em] text-ocean">Features</p>
            <h2 className="mt-3 text-3xl font-bold tracking-normal text-ink sm:text-4xl">
              What&apos;s inside {brand.appName}?
            </h2>
          </div>
          <div className="grid gap-6 md:grid-cols-2">
            {insideFeatures.map((feature) => {
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

      {/* Trending */}
      <section id="trending" className="scroll-mt-20 border-y border-white/80 bg-slate-50">
        <div className="section py-16 lg:py-20">
          <div className="mx-auto mb-10 max-w-3xl text-center">
            <p className="text-sm font-bold uppercase tracking-[0.18em] text-ocean">Popular right now</p>
            <h2 className="mt-3 text-3xl font-bold tracking-normal text-ink sm:text-4xl">Trending This Week</h2>
            <p className="mt-3 text-base text-slate-600">Most researched tones by our community</p>
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

      {/* Why Tonefex */}
      <section className="app-gradient">
        <div className="section py-16 lg:py-20">
          <div className="mx-auto mb-12 max-w-3xl text-center">
            <h2 className="text-3xl font-bold tracking-normal text-ink sm:text-4xl">Why {brand.appName}?</h2>
            <p className="mt-3 text-base text-slate-600">
              The fastest way from &ldquo;what are the settings?&rdquo; to actually playing.
            </p>
          </div>
          <div className="grid gap-6 md:grid-cols-3">
            {whyFeatures.map((f) => (
              <article key={f.title} className="rounded-xl border border-white/80 bg-white/90 p-7 shadow-sm">
                <h3 className="text-lg font-bold text-ink">{f.title}</h3>
                <p className="mt-3 text-sm leading-6 text-slate-600">{f.body}</p>
              </article>
            ))}
          </div>
        </div>
      </section>

      {/* CTA Banner */}
      <section className="section py-16">
        <div className="rounded-xl border border-white/80 bg-ink p-8 text-center shadow-lg lg:p-12">
          <h2 className="text-3xl font-bold text-white sm:text-4xl">Ready to find your tone?</h2>
          <p className="mx-auto mt-3 max-w-xl text-base text-white/70">
            Pick a song, select your gear, and start playing with settings adapted to your rig.
          </p>
          <div className="mt-8 flex flex-col items-center justify-center gap-3 sm:flex-row">
            <Link href="/app" className="inline-flex min-h-14 items-center gap-2 rounded-lg bg-moss px-8 text-base font-semibold text-ink shadow transition-colors hover:bg-moss/90">
              Start Matching
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
