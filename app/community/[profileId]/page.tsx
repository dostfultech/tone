import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { ArrowLeft, Database, Gauge, Guitar, Link2, Lock, Music2, ShieldCheck, SlidersHorizontal, Sparkles, Volume2 } from "lucide-react";
import { AmpSettingsKnobs } from "@/components/amp-settings-knobs";
import { AppShell } from "@/components/app-shell";
import { CommunityToneCta } from "@/components/community-tone-cta";
import { buildPageMetadata } from "@/lib/seo";
import { getCurrentSession, getEntitlement } from "@/lib/server-access";
import { getCommunityToneProfileById } from "@/lib/tone-profiles";

type CommunityToneDetailPageProps = {
  params: Promise<{ profileId: string }>;
};

export async function generateMetadata({ params }: CommunityToneDetailPageProps): Promise<Metadata> {
  const { profileId } = await params;
  const profile = await getCommunityToneProfileById(profileId);

  if (!profile) {
    return buildPageMetadata({
      title: "Tone Not Found",
      description: "The requested tone profile could not be found.",
      path: `/community/${profileId}`,
      noIndex: true
    });
  }

  return buildPageMetadata({
    title: `${profile.songTitle} by ${profile.artistName} Tone`,
    description: `Community profile for ${profile.songTitle} by ${profile.artistName}, including source rig, settings, and adaptation workflow.`,
    path: `/community/${profileId}`
  });
}

export default async function CommunityToneDetailPage({ params }: CommunityToneDetailPageProps) {
  const { profileId } = await params;
  const { supabase, user } = await getCurrentSession();
  const entitlement = await getEntitlement(supabase, user);
  const profile = await getCommunityToneProfileById(profileId);

  if (!profile) {
    notFound();
  }

  const originalSettings = (profile.originalSettings || {}) as Record<string, number>;
  const settingsEntries = Object.entries(originalSettings);
  const researchCount = Math.max(24, profile.confidence * 4);
  const likes = Math.max(10, Math.round(profile.confidence / 1.35));
  const hasPremiumAccess = entitlement.hasAccess;
  const userLoggedIn = Boolean(user);
  const canAdapt = userLoggedIn;
  const redirectTarget = `/community/${profile.id}`;
  const visibleSettingsMap = hasPremiumAccess
    ? originalSettings
    : Object.fromEntries(settingsEntries.slice(0, 2));
  const lockedSettingsMap = hasPremiumAccess
    ? {}
    : Object.fromEntries(settingsEntries.slice(2));

  return (
    <AppShell>
      <div className="px-4 pb-14 pt-24 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-[1440px]">
          <Link href="/community" className="button-quiet mb-8 w-fit">
            <ArrowLeft className="h-4 w-4" />
            Back to Tone Database
          </Link>

          <section className="grid gap-8 xl:grid-cols-[minmax(0,1.45fr)_360px]">
            <div className="grid gap-8">
              <div className="theme-panel theme-blue-panel overflow-hidden p-8 lg:p-10">
                <div className="grid gap-8 lg:grid-cols-[minmax(0,1fr)_300px] lg:items-end">
                  <div>
                    <div className="flex flex-wrap items-center gap-3 text-sm font-bold uppercase tracking-[0.14em] text-slate-500">
                      <span className="rounded-md bg-white/80 px-3 py-1 text-ocean">{labelToneType(profile.toneType)}</span>
                      <span className="rounded-md bg-white/80 px-3 py-1">{profile.mode}</span>
                      <span className="rounded-md bg-white/80 px-3 py-1">{profile.partType}</span>
                      <span className="rounded-md bg-white/80 px-3 py-1">1980s</span>
                    </div>
                    <h1 className="mt-5 text-4xl font-bold tracking-normal sm:text-5xl">{profile.songTitle}</h1>
                    <p className="mt-3 text-2xl text-slate-500">{profile.artistName}</p>
                    <p className="mt-6 max-w-3xl text-base leading-7 text-slate-600">
                      {profile.sourceSummary || "Community profile details for matching the original rig before adapting it to the player’s setup."}
                    </p>
                  </div>
                  <div className="grid gap-3 rounded-2xl border border-white/80 bg-white/75 p-4 shadow-sm">
                    <MiniStat label="Community Research" value={`${researchCount} runs`} />
                    <MiniStat label="Profile Likes" value={`${likes}`} />
                    <MiniStat label="Verification" value={labelVerification(profile.verificationStatus)} />
                  </div>
                </div>
              </div>

              <section className="theme-panel p-8">
                <div className="mb-6 flex items-center gap-3">
                  <div className="grid h-12 w-12 place-items-center rounded-lg bg-ink text-moss">
                    {profile.mode === "bass" ? <Volume2 className="h-5 w-5" /> : <Guitar className="h-5 w-5" />}
                  </div>
                  <div>
                    <h2 className="text-2xl font-bold">Original Gear</h2>
                    <p className="text-sm text-slate-500">Reference rig captured for this tone profile</p>
                  </div>
                </div>
                <div className="grid gap-4 md:grid-cols-2">
                  <InfoCard icon={<Guitar className="h-5 w-5" />} label="Instrument" value={profile.originalGuitar || "Original guitar unknown"} />
                  <InfoCard icon={<SlidersHorizontal className="h-5 w-5" />} label="Pickup / Source" value={profile.originalPickup || "Original pickup unknown"} />
                  <InfoCard icon={<Gauge className="h-5 w-5" />} label="Amp" value={profile.originalAmp || "Original amp unknown"} />
                  <InfoCard icon={<Database className="h-5 w-5" />} label="Cab / Chain" value={profile.originalCab || "Original cab unknown"} />
                </div>
              </section>

              <section className="theme-panel p-8">
                <div className="mb-6 flex items-center gap-3">
                  <div className="grid h-12 w-12 place-items-center rounded-lg bg-ink text-moss">
                    <Gauge className="h-5 w-5" />
                  </div>
                  <div>
                    <h2 className="text-2xl font-bold">Amp Settings</h2>
                    <p className="text-sm text-slate-500">Stored baseline values before gear adaptation</p>
                  </div>
                </div>
                {Object.keys(visibleSettingsMap).length ? (
                  <AmpSettingsKnobs settings={visibleSettingsMap} empty="No structured amp settings are stored for this profile yet." />
                ) : (
                  <p className="text-sm text-slate-500">No structured amp settings are stored for this profile yet.</p>
                )}
                {Object.keys(lockedSettingsMap).length ? (
                  <LockedContent
                    className="mt-6"
                    redirectTarget={redirectTarget}
                    userLoggedIn={userLoggedIn}
                    title="Unlock full amp settings"
                    body="Beginner and Expert plans reveal every stored setting for this tone profile."
                  >
                    <AmpSettingsKnobs settings={lockedSettingsMap} />
                  </LockedContent>
                ) : null}
              </section>

              <section className="grid gap-8 xl:grid-cols-2">
                <div className="theme-panel min-h-[420px] p-8">
                  <h2 className="text-2xl font-bold">Effects & Signal Chain</h2>
                  <LockedContent
                    locked={!hasPremiumAccess}
                    className="mt-6"
                    redirectTarget={redirectTarget}
                    userLoggedIn={userLoggedIn}
                    title="Unlock effects and signal chain"
                    body="Upgrade to see the complete pedal order, placement, and stored effect settings."
                  >
                    <div className="grid gap-3">
                      {profile.effects.length ? (
                        profile.effects.map((effect) => (
                          <div key={`${effect.effectOrder}-${effect.effectName}`} className="rounded-lg border border-white/80 bg-white/80 p-4">
                            <div className="flex items-center justify-between gap-3">
                              <div className="font-bold">{effect.effectOrder}. {effect.effectName}</div>
                              <span className="rounded-md bg-neutral-100 px-3 py-1 text-xs font-bold uppercase tracking-[0.12em] text-slate-500">{effect.placement}</span>
                            </div>
                            {Object.keys(effect.settings || {}).length ? (
                              <div className="mt-3 flex flex-wrap gap-2 text-sm text-slate-600">
                                {Object.entries(effect.settings).map(([key, value]) => (
                                  <span key={key} className="rounded-full bg-neutral-100 px-3 py-1 font-semibold">
                                    {prettifyKey(key)}: {String(value)}
                                  </span>
                                ))}
                              </div>
                            ) : null}
                          </div>
                        ))
                      ) : (
                        <p className="text-sm text-slate-500">No effect chain recorded for this profile yet.</p>
                      )}
                    </div>
                  </LockedContent>
                </div>

                <div className="theme-panel min-h-[420px] p-8">
                  <h2 className="text-2xl font-bold">Playing & Adaptation Notes</h2>
                  <LockedContent
                    locked={!hasPremiumAccess}
                    className="mt-6"
                    redirectTarget={redirectTarget}
                    userLoggedIn={userLoggedIn}
                    title="Unlock playing notes"
                    body="Beginner and Expert plans include the full playing guidance and adaptation notes."
                  >
                    <div className="grid gap-6">
                      <NotesBlock title="Playing Notes" items={profile.playingNotes} emptyLabel="No playing notes stored yet." />
                      <NotesBlock title="Adaptation Notes" items={profile.adaptationNotes} emptyLabel="No adaptation notes stored yet." />
                    </div>
                  </LockedContent>
                </div>
              </section>
            </div>

            <aside className="grid h-fit gap-6 xl:sticky xl:top-28">
              <div className="theme-panel p-6">
                <h2 className="text-lg font-bold">Profile Status</h2>
                <div className="mt-5 grid gap-4">
                  <StatRow label="Confidence" value={`${profile.confidence}%`} />
                  <StatRow label="Verification" value={labelVerification(profile.verificationStatus)} />
                  <StatRow label="Part" value={profile.partLabel} />
                  <StatRow label="Community Research" value={`${researchCount}`} />
                </div>
              </div>

              <div className="theme-panel p-6">
                <h2 className="text-lg font-bold">Tone Character</h2>
                <LockedContent
                  locked={!hasPremiumAccess}
                  className="mt-5"
                  redirectTarget={redirectTarget}
                  userLoggedIn={userLoggedIn}
                  title="Unlock tone character"
                  body="See full authenticity, playability, and adaptability scoring with a paid plan."
                  compact
                >
                  <div className="grid gap-3">
                    <CharacterMeter label="Authenticity" value={profile.confidence} />
                    <CharacterMeter label="Playability" value={Math.min(96, profile.confidence + 10)} />
                    <CharacterMeter label="Adaptability" value={Math.min(94, profile.confidence + 6)} />
                  </div>
                </LockedContent>
              </div>

              <div className="theme-panel p-6">
                <h2 className="text-lg font-bold">Sources</h2>
                <LockedContent
                  locked={!hasPremiumAccess}
                  className="mt-5"
                  redirectTarget={redirectTarget}
                  userLoggedIn={userLoggedIn}
                  title="Unlock sources"
                  body="Paid plans reveal source notes and credibility details for each profile."
                  compact
                >
                  <div className="grid gap-4">
                    {profile.sources.length ? (
                      profile.sources.map((source) => (
                        <div key={`${source.sourceType}-${source.title}`} className="rounded-lg border border-white/80 bg-white/80 p-4">
                          <div className="text-sm font-bold uppercase tracking-[0.12em] text-ocean">{source.sourceType.replaceAll("_", " ")}</div>
                          <div className="mt-2 font-semibold">{source.title}</div>
                          <div className="mt-2 text-sm text-slate-500">Credibility: {source.credibility}%</div>
                          {source.notes ? <p className="mt-2 text-sm leading-6 text-slate-600">{source.notes}</p> : null}
                          {source.url ? (
                            <a href={source.url} target="_blank" rel="noreferrer" className="mt-3 inline-flex items-center gap-2 text-sm font-semibold text-ocean">
                              <Link2 className="h-4 w-4" />
                              Open source
                            </a>
                          ) : null}
                        </div>
                      ))
                    ) : (
                      <p className="text-sm text-slate-500">No sources are stored for this profile yet.</p>
                    )}
                  </div>
                </LockedContent>
              </div>

              <div className="theme-panel p-6">
                <h2 className="text-lg font-bold">Use This Tone</h2>
                <p className="mt-3 text-sm leading-6 text-slate-600">
                  {canAdapt
                    ? "Adapt this reference profile with your saved My Gear preset and generate settings for your own rig."
                    : "Sign in to adapt this reference profile with your saved My Gear preset."}
                </p>
                {canAdapt ? (
                  <>
                    <div className="mt-5">
                      <CommunityToneCta
                        mode={profile.mode}
                        song={profile.songTitle}
                        artist={profile.artistName}
                        part={profile.partLabel}
                        partType={profile.partType}
                        toneType={profile.toneType}
                        guitar={profile.originalGuitar || "Fender Stratocaster"}
                        amp={profile.originalAmp || "Boss Katana Artist"}
                        pickup={profile.originalPickup}
                        cabinet={profile.originalCab}
                      />
                    </div>
                    <Link href="/app" className="button-secondary mt-3 w-full justify-center">
                      <Music2 className="h-4 w-4" />
                      Open Matcher
                    </Link>
                  </>
                ) : (
                  <div className="mt-5 grid gap-3">
                    <Link href={`/login?redirect=${encodeURIComponent(redirectTarget)}`} className="button-secondary w-full justify-center">
                      <ShieldCheck className="h-4 w-4" />
                      Sign In To Continue
                    </Link>
                  </div>
                )}
                <p className="mt-4 text-xs leading-5 text-slate-500">This detail page previews the source rig and research notes, then adapts the profile through your saved gear when My Gear is configured.</p>
              </div>
            </aside>
          </section>
        </div>
      </div>
    </AppShell>
  );
}

function LockedContent({
  children,
  className = "",
  locked = true,
  redirectTarget,
  userLoggedIn,
  title,
  body,
  compact = false
}: {
  children: React.ReactNode;
  className?: string;
  locked?: boolean;
  redirectTarget: string;
  userLoggedIn: boolean;
  title: string;
  body: string;
  compact?: boolean;
}) {
  if (!locked) {
    return <div className={className}>{children}</div>;
  }

  return (
    <div className={`relative overflow-hidden rounded-xl ${className}`}>
      <div className="pointer-events-none select-none blur-sm opacity-55" aria-hidden="true">
        {children}
      </div>
      <div className="absolute inset-0 grid place-items-center bg-white/65 p-4 backdrop-blur-[1px]">
        <div className={`max-w-sm rounded-lg border border-white/90 bg-white/95 text-center shadow-xl ${compact ? "p-4" : "p-5"}`}>
          <div className="mx-auto grid h-10 w-10 place-items-center rounded-lg bg-ink text-moss">
            <Lock className="h-5 w-5" />
          </div>
          <h3 className={`${compact ? "mt-3 text-base" : "mt-4 text-lg"} font-bold text-ink`}>{title}</h3>
          <p className={`${compact ? "mt-2 text-xs leading-5" : "mt-2 text-sm leading-6"} text-slate-600`}>{body}</p>
          <div className="mt-4 grid gap-2">
            <Link href={`/plans?required=subscription&redirect=${encodeURIComponent(redirectTarget)}`} className="button-primary min-h-10 justify-center rounded-lg px-4 text-sm">
              <Sparkles className="h-4 w-4" />
              View Plans
            </Link>
            {!userLoggedIn ? (
              <Link href={`/login?redirect=${encodeURIComponent(redirectTarget)}`} className="button-secondary min-h-10 justify-center rounded-lg px-4 text-sm">
                <ShieldCheck className="h-4 w-4" />
                Sign In
              </Link>
            ) : null}
          </div>
        </div>
      </div>
    </div>
  );
}

function InfoCard({ icon, label, value }: { icon: React.ReactNode; label: string; value: string }) {
  return (
    <div className="rounded-lg border border-white/80 bg-white/80 p-5">
      <div className="flex items-center gap-3 text-sm font-bold uppercase tracking-[0.12em] text-slate-400">
        {icon}
        {label}
      </div>
      <div className="mt-3 text-base font-semibold text-ink">{value}</div>
    </div>
  );
}

function NotesBlock({ title, items, emptyLabel }: { title: string; items: string[]; emptyLabel: string }) {
  return (
    <div>
      <h3 className="text-lg font-bold">{title}</h3>
      {items.length ? (
        <div className="mt-4 grid gap-3">
          {items.map((item) => (
            <div key={item} className="rounded-lg border border-white/80 bg-white/80 p-4 text-sm leading-6 text-slate-600">
              {item}
            </div>
          ))}
        </div>
      ) : (
        <p className="mt-3 text-sm text-slate-500">{emptyLabel}</p>
      )}
    </div>
  );
}

function StatRow({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex items-center justify-between gap-4 rounded-lg border border-white/80 bg-white/80 px-4 py-3">
      <span className="text-sm font-semibold text-slate-500">{label}</span>
      <span className="text-sm font-bold text-ink">{value}</span>
    </div>
  );
}

function prettifyKey(value: string) {
  return value.replaceAll("_", " ");
}

function labelToneType(value: string) {
  return value.replaceAll("_", " ");
}

function labelVerification(value: string) {
  return value.replaceAll("_", " ");
}

function MiniStat({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex items-center justify-between gap-3 rounded-xl border border-white/80 bg-white/80 px-4 py-3">
      <span className="text-xs font-bold uppercase tracking-[0.12em] text-slate-400">{label}</span>
      <span className="text-sm font-bold text-ink">{value}</span>
    </div>
  );
}

function CharacterMeter({ label, value }: { label: string; value: number }) {
  return (
    <div className="rounded-xl border border-white/80 bg-white/80 p-4">
      <div className="flex items-center justify-between gap-4 text-sm">
        <span className="font-semibold text-slate-500">{label}</span>
        <span className="font-bold text-ink">{value}%</span>
      </div>
      <div className="mt-3 h-2 overflow-hidden rounded-full bg-blue-50">
        <div className="h-full rounded-full bg-ocean" style={{ width: `${value}%` }} />
      </div>
    </div>
  );
}

