import type { CSSProperties } from "react";
import type { Metadata } from "next";
import Link from "next/link";
import { redirect } from "next/navigation";
import { ArrowRight, BadgeCheck, Guitar, Library, MessageSquare, Music2, Star, Users, Volume2, Zap } from "lucide-react";
import { brand } from "@/lib/brand";
import { buildPageMetadata, toAbsoluteUrl } from "@/lib/seo";
import { SiteShell } from "@/components/site-shell";
import { Reviews } from "@/components/reviews";
import { ScrollReveal } from "@/components/scroll-reveal";
import { PhotoAvatar } from "@/components/photo-avatar";
import { SongCover } from "@/components/song-cover";

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

// Cover art served from Apple's iTunes artwork CDN (via the public iTunes Search API).
const trendingSongs = [
  { title: "Master of Puppets", artist: "Metallica", genre: "Metal", part: "Riff", cover: "https://is1-ssl.mzstatic.com/image/thumb/Music114/v4/b8/5a/82/b85a8259-60d9-bfaa-770a-2baac8380e87/858978005196.png/300x300bb.jpg" },
  { title: "Sweet Child O' Mine", artist: "Guns N' Roses", genre: "Rock", part: "Riff", cover: "https://is1-ssl.mzstatic.com/image/thumb/Music125/v4/a0/4d/c4/a04dc484-03cc-02aa-fa82-5334fcb4bc16/18UMGIM24878.rgb.jpg/300x300bb.jpg" },
  { title: "Comfortably Numb", artist: "Pink Floyd", genre: "Rock", part: "Solo", cover: "https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/3e/17/ec/3e17ec6d-f980-c64f-19e0-a6fd8bbf0c10/886445635850.jpg/300x300bb.jpg" },
  { title: "Smells Like Teen Spirit", artist: "Nirvana", genre: "Rock", part: "Riff", cover: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/95/fd/b9/95fdb9b2-6d2b-92a6-97f2-51c1a6d77f1a/00602527874609.rgb.jpg/300x300bb.jpg" },
  { title: "Hotel California", artist: "Eagles", genre: "Rock", part: "Solo", cover: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/88/16/2c/88162c3d-46db-8321-61f3-3a47404cfe76/075596050920.jpg/300x300bb.jpg" },
  { title: "Enter Sandman", artist: "Metallica", genre: "Metal", part: "Riff", cover: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/2e/94/95/2e9495d7-dfe3-ddc8-87ef-6ef797a60218/850007452056.png/300x300bb.jpg" },
  { title: "Eruption", artist: "Van Halen", genre: "Rock", part: "Solo", cover: "https://is1-ssl.mzstatic.com/image/thumb/Music125/v4/7a/ef/88/7aef88ad-25aa-be91-eb78-8917c3f114f7/603497894130.jpg/300x300bb.jpg" },
  { title: "Back in Black", artist: "AC/DC", genre: "Rock", part: "Riff", cover: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/1e/14/58/1e145814-281a-58e0-3ab1-145f5d1af421/886443673441.jpg/300x300bb.jpg" }
];

const testimonials = [
  {
    name: "Alex",
    role: "Guitar player",
    gradient: "from-ocean to-copper",
    photo: "/testimonials/alex.jpg",
    text: "I used to spend hours tweaking my amp just to get close to the sound I wanted. This makes it ridiculously easy to dial in a tone that actually fits my setup. Huge time saver."
  },
  {
    name: "Marcus T.",
    role: "Guitar player",
    gradient: "from-moss to-ocean",
    photo: "/testimonials/marcus.jpg",
    text: "The best part is that I don't need the exact gear used in the recording. I can choose what I own and still get a really convincing version of the tone. Definitely one of the most useful guitar tools I've tried."
  },
  {
    name: "Ryan",
    role: "Guitar player",
    gradient: "from-ember to-copper",
    photo: "/testimonials/ryan.jpg",
    text: "I finally stopped guessing what settings to use. I picked a song, entered my rig, and got settings I could actually use right away. It feels like having someone build the tone for you."
  }
];

// Hero trust-badge faces — separate photos from the testimonials.
// Files: public/testimonials/badge-1.jpg, badge-2.jpg, badge-3.jpg
const badgeAvatars = [
  { name: "Guitar player", photo: "/testimonials/badge-1.jpg", gradient: "from-ocean to-copper" },
  { name: "Guitar player", photo: "/testimonials/badge-2.jpg", gradient: "from-moss to-ocean" },
  { name: "Guitar player", photo: "/testimonials/badge-3.jpg", gradient: "from-ember to-copper" }
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
          <div className="mx-auto inline-flex items-center gap-3 rounded-full border border-white/15 bg-white/10 px-3 py-2 pr-4 backdrop-blur-sm sm:gap-4">
            <div className="flex -space-x-2.5">
              {badgeAvatars.map((a, i) => (
                <PhotoAvatar
                  key={i}
                  src={a.photo}
                  name={a.name}
                  gradient={a.gradient}
                  className="h-8 w-8 rounded-full ring-2 ring-[#0d0c1d]"
                  fallbackTextClassName="text-xs"
                />
              ))}
            </div>
            <div className="flex items-center gap-1">
              {Array.from({ length: 5 }).map((_, i) => (
                <Star key={i} className="h-3.5 w-3.5 shrink-0 fill-amber-400 text-amber-400" />
              ))}
            </div>
            <span className="text-sm font-semibold leading-none text-white/85">
              Loved by <span className="text-white">125,000+</span> guitarists
            </span>
          </div>

          <h1 className="mx-auto mt-8 max-w-4xl text-5xl font-bold leading-[1.04] tracking-tight text-white sm:text-6xl lg:text-7xl">
            Sound like any song,
            <span className="block text-moss">on your own amp.</span>
          </h1>

          <p className="mx-auto mt-6 max-w-2xl text-lg leading-8 text-white/65 sm:text-xl">
            Search a song — get the exact knob settings for your guitar, amp, and pedals in seconds.
          </p>

          <div className="mt-9 flex flex-col items-center justify-center gap-3 sm:flex-row">
            <Link href="/app" className="inline-flex min-h-14 items-center justify-center gap-2 rounded-lg bg-moss px-8 text-base font-bold text-ink shadow-[0_0_50px_rgba(167,255,63,0.35)] transition-all duration-200 ease-out hover:-translate-y-0.5 hover:bg-moss/90 hover:shadow-[0_0_70px_rgba(167,255,63,0.5)] active:translate-y-0 active:scale-[0.98]">
              Dial In a Song
              <ArrowRight className="h-4 w-4" />
            </Link>
            <Link href="/plans" className="inline-flex min-h-14 items-center justify-center gap-2 rounded-lg border border-white/20 px-8 text-base font-semibold text-white transition-all duration-200 ease-out hover:-translate-y-0.5 hover:bg-white/10 active:translate-y-0 active:scale-[0.98]">
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
          <div className="reveal mx-auto mb-12 max-w-3xl text-center">
            <p className="text-sm font-bold uppercase tracking-[0.18em] text-ocean">Why players switch</p>
            <h2 className="mt-3 text-3xl font-bold tracking-normal text-ink sm:text-4xl">
              Built different where it counts
            </h2>
          </div>
          <div className="grid gap-6 md:grid-cols-2">
            {differentiators.map((feature, i) => {
              const Icon = feature.icon;
              return (
                <article
                  key={feature.title}
                  className="reveal hover-lift compact-card p-7"
                  style={{ "--reveal-delay": `${i * 70}ms` } as CSSProperties}
                >
                  <div className="mb-5 grid h-12 w-12 place-items-center rounded-xl bg-gradient-to-br from-ink to-[#1b1a44] text-moss shadow-[0_12px_26px_rgba(8,7,26,0.24)] ring-1 ring-moss/25">
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
          <div className="reveal mx-auto mb-12 max-w-3xl text-center">
            <h2 className="text-3xl font-bold tracking-normal text-ink sm:text-4xl">From song to sound in three moves</h2>
            <p className="mt-3 text-base text-slate-600">Watch a real tone get dialed in, start to finish.</p>
          </div>
          <div className="reveal mx-auto mb-12 max-w-4xl">
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
                <article
                  key={step.title}
                  className="reveal hover-lift rounded-xl border border-white/80 bg-white p-7 shadow-sm"
                  style={{ "--reveal-delay": `${i * 70}ms` } as CSSProperties}
                >
                  <div className="mb-4 flex items-center gap-3">
                    <div className="grid h-10 w-10 place-items-center rounded-xl bg-gradient-to-br from-ink to-[#1b1a44] text-sm font-bold text-moss shadow-[0_10px_22px_rgba(8,7,26,0.22)] ring-1 ring-moss/25">{i + 1}</div>
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
          <div className="reveal mx-auto mb-10 max-w-3xl text-center">
            <p className="text-sm font-bold uppercase tracking-[0.18em] text-ocean">On the boards right now</p>
            <h2 className="mt-3 text-3xl font-bold tracking-normal text-ink sm:text-4xl">What players are chasing</h2>
            <p className="mt-3 text-base text-slate-600">The most-dialed tones this week</p>
          </div>
          <div className="reveal mx-auto grid max-w-4xl gap-3">
            {trendingSongs.map((song, i) => (
              <Link
                key={`${song.title}-${song.artist}`}
                href="/app"
                className="group flex items-center gap-4 rounded-xl border border-white/80 bg-white px-5 py-4 shadow-sm transition-all duration-200 ease-out hover:-translate-y-0.5 hover:shadow-md"
              >
                <SongCover cover={song.cover} rank={i + 1} title={song.title} />
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
            ].map((item, i) => {
              const Icon = item.icon;
              return (
                <div
                  key={item.label}
                  className="reveal stage-card px-6 py-8"
                  style={{ "--reveal-delay": `${i * 70}ms` } as CSSProperties}
                >
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
          <h2 className="reveal text-center text-3xl font-bold tracking-normal text-ink sm:text-4xl">
            Players on {brand.appName}
          </h2>
          <div className="mx-auto mt-10 grid max-w-5xl gap-6 md:grid-cols-3">
            {testimonials.map((t, i) => (
              <article
                key={t.name}
                className="reveal hover-lift rounded-xl border border-white/80 bg-white p-6 shadow-sm"
                style={{ "--reveal-delay": `${i * 70}ms` } as CSSProperties}
              >
                <div className="mb-4 flex items-center gap-3">
                  <PhotoAvatar
                    src={t.photo}
                    name={t.name}
                    gradient={t.gradient}
                    className="h-11 w-11 shrink-0 rounded-full shadow-md"
                  />
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
        <div className="reveal stage-dark rounded-xl border border-white/10 p-8 text-center shadow-lg lg:p-12">
          <h2 className="text-3xl font-bold text-white sm:text-4xl">Tonight&apos;s song is waiting.</h2>
          <p className="mx-auto mt-3 max-w-xl text-base text-white/60">
            Search it, dial the numbers onto your amp, and hear your rig do something it&apos;s never done.
          </p>
          <div className="mt-8 flex flex-col items-center justify-center gap-3 sm:flex-row">
            <Link href="/app" className="inline-flex min-h-14 items-center gap-2 rounded-lg bg-moss px-8 text-base font-bold text-ink shadow transition-all duration-200 ease-out hover:-translate-y-0.5 hover:bg-moss/90 hover:shadow-[0_0_60px_rgba(167,255,63,0.4)] active:translate-y-0 active:scale-[0.98]">
              Dial In a Song
              <ArrowRight className="h-4 w-4" />
            </Link>
            <Link href="/plans" className="inline-flex min-h-14 items-center gap-2 rounded-lg border border-white/20 px-8 text-base font-semibold text-white transition-all duration-200 ease-out hover:-translate-y-0.5 hover:bg-white/10 active:translate-y-0 active:scale-[0.98]">
              View Plans
            </Link>
          </div>
        </div>
      </section>

      {/* Reviews */}
      <Reviews />

      <ScrollReveal />
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
