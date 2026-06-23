import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { ArrowLeft, Database, Gauge, Guitar, Link2, Lock, Music2, ShieldCheck, SlidersHorizontal, Sparkles, Volume2 } from "lucide-react";
import { AppShell } from "@/components/app-shell";
import { CommunityToneCta } from "@/components/community-tone-cta";
import { getCurrentSession, getEntitlement } from "@/lib/server-access";
import { getCommunityToneProfileById } from "@/lib/tone-profiles";

type CommunityToneDetailPageProps = {
  params: Promise<{ profileId: string }>;
};

export async function generateMetadata({ params }: CommunityToneDetailPageProps): Promise<Metadata> {
  const { profileId } = await params;
  const profile = await getCommunityToneProfileById(profileId);

  if (!profile) {
    return { title: "Tone Not Found" };
  }

  return {
    title: `${profile.songTitle} Tone Database`
  };
}

export default async function CommunityToneDetailPage({ params }: CommunityToneDetailPageProps) {
  const { profileId } = await params;
  const { supabase, user } = await getCurrentSession();
  const entitlement = await getEntitlement(supabase, user);
  const profile = await getCommunityToneProfileById(profileId);

  if (!profile) {
    notFound();
  }

  const settings = Object.entries(profile.originalSettings || {});
  const visibleSettings = settings.slice(0, 3);
  const lockedSettings = settings.slice(3);
  const researchCount = Math.max(24, profile.confidence * 4);
  const likes = Math.max(10, Math.round(profile.confidence / 1.35));
  const isUnlocked = entitlement.hasAccess;
  const redirectTarget = `/community/${profile.id}`;

  return (
    <AppShell>
      <div className="px-4 pb-16 pt-28 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-[1840px]">
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
                {visibleSettings.length ? (
                  <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
                    {visibleSettings.map(([key, value]) => (
                      <div key={key} className="compact-card p-5 text-center">
                        <div className="text-xs font-bold uppercase tracking-[0.14em] text-slate-400">{prettifyKey(key)}</div>
                        <div className="mt-3 text-4xl font-bold text-ink">{value}</div>
                      </div>
                    ))}
                  </div>
                ) : (
                  <p className="text-sm text-slate-500">No structured amp settings are stored for this profile yet.</p>
                )}
                {!isUnlocked && lockedSettings.length ? (
                  <div className="preview-lock mt-6 rounded-2xl border border-white/80 bg-white/75 p-5">
                    <div className="preview-lock-inner grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
                      {lockedSettings.map(([key, value]) => (
                        <div key={key} className="compact-card p-5 text-center">
                          <div className="text-xs font-bold uppercase tracking-[0.14em] text-slate-400">{prettifyKey(key)}</div>
                          <div className="mt-3 text-4xl font-bold text-ink">{value}</div>
                        </div>
                      ))}
                    </div>
                    <div className="preview-lock-cta">
                      <LockedCta label="Unlock the remaining amp settings and full tone recipe" redirectTarget={redirectTarget} userLoggedIn={Boolean(user)} />
                    </div>
                  </div>
                ) : null}
                {isUnlocked && lockedSettings.length ? (
                  <div className="mt-6 grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
                    {lockedSettings.map(([key, value]) => (
                      <div key={key} className="compact-card p-5 text-center">
                        <div className="text-xs font-bold uppercase tracking-[0.14em] text-slate-400">{prettifyKey(key)}</div>
                        <div className="mt-3 text-4xl font-bold text-ink">{value}</div>
                      </div>
                    ))}
                  </div>
                ) : null}
              </section>

              <section className="grid gap-8 xl:grid-cols-2">
                <div className={`theme-panel p-8 min-h-[420px] ${isUnlocked ? "" : "preview-lock"}`}>
                  <h2 className="text-2xl font-bold">Effects & Signal Chain</h2>
                  <div className={`${isUnlocked ? "" : "preview-lock-inner"} mt-6 grid gap-3`}>
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
                  {!isUnlocked ? (
                    <div className="preview-lock-cta">
                      <LockedCta label="Preview effects and routing, then adapt it to your own rig" redirectTarget={redirectTarget} userLoggedIn={Boolean(user)} />
                    </div>
                  ) : null}
                </div>

                <div className={`theme-panel p-8 min-h-[420px] ${isUnlocked ? "" : "preview-lock"}`}>
                  <h2 className="text-2xl font-bold">Playing & Adaptation Notes</h2>
                  <div className={`${isUnlocked ? "" : "preview-lock-inner"} mt-6 grid gap-6`}>
                    <NotesBlock title="Playing Notes" items={profile.playingNotes} emptyLabel="No playing notes stored yet." />
                    <NotesBlock title="Adaptation Notes" items={profile.adaptationNotes} emptyLabel="No adaptation notes stored yet." />
                  </div>
                  {!isUnlocked ? (
                    <div className="preview-lock-cta">
                      <LockedCta label="Open the matcher to carry these notes into your tone adaptation" redirectTarget={redirectTarget} userLoggedIn={Boolean(user)} />
                    </div>
                  ) : null}
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
                <div className="mt-5 grid gap-3">
                  <CharacterMeter label="Authenticity" value={profile.confidence} />
                  <CharacterMeter label="Playability" value={Math.min(96, profile.confidence + 10)} />
                  <CharacterMeter label="Adaptability" value={Math.min(94, profile.confidence + 6)} />
                </div>
              </div>

              <div className="theme-panel p-6">
                <h2 className="text-lg font-bold">Sources</h2>
                <div className="mt-5 grid gap-4">
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
              </div>

              <div className="theme-panel p-6">
                <h2 className="text-lg font-bold">Use This Tone</h2>
                <p className="mt-3 text-sm leading-6 text-slate-600">{isUnlocked ? "Send this reference profile into the matcher with its song, artist, part, and original rig prefilled." : "Subscribers can unlock the full recipe, all notes, and direct profile-to-matcher handoff."}</p>
                {isUnlocked ? (
                  <>
                    <div className="mt-5">
                      <CommunityToneCta
                        song={profile.songTitle}
                        artist={profile.artistName}
                        part={profile.partLabel}
                        partType={profile.partType}
                        toneType={profile.toneType}
                        guitar={profile.originalGuitar || "Fender Stratocaster"}
                        amp={profile.originalAmp || "Boss Katana Artist"}
                      />
                    </div>
                    <Link href="/app" className="button-secondary mt-3 w-full justify-center">
                      <Music2 className="h-4 w-4" />
                      Open Matcher
                    </Link>
                  </>
                ) : (
                  <div className="mt-5 grid gap-3">
                    <Link href={`/plans?required=subscription&redirect=${encodeURIComponent(redirectTarget)}`} className="button-primary w-full justify-center">
                      <Sparkles className="h-4 w-4" />
                      Unlock Full Tone
                    </Link>
                    <Link href={`/login?redirect=${encodeURIComponent(redirectTarget)}`} className="button-secondary w-full justify-center">
                      <ShieldCheck className="h-4 w-4" />
                      Sign In To Continue
                    </Link>
                  </div>
                )}
                <p className="mt-4 text-xs leading-5 text-slate-500">This detail page previews the source rig and research notes, then hands the profile off to the matcher for full adaptation.</p>
              </div>
            </aside>
          </section>
        </div>
      </div>
    </AppShell>
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

function LockedCta({ label, redirectTarget, userLoggedIn }: { label: string; redirectTarget: string; userLoggedIn: boolean }) {
  return (
    <div className="rounded-2xl border border-white/80 bg-white/90 p-4 shadow-[0_18px_45px_rgba(8,7,26,0.14)] backdrop-blur">
      <div className="flex items-start gap-3">
        <div className="grid h-10 w-10 shrink-0 place-items-center rounded-lg bg-ink text-moss">
          <Lock className="h-4 w-4" />
        </div>
        <div className="min-w-0">
          <div className="text-sm font-bold text-ink">{label}</div>
          <div className="mt-1 text-xs leading-5 text-slate-500">Use the full profile as the source reference, then adapt it to your guitar, pickups, and amp.</div>
          <div className="mt-3 flex flex-wrap gap-2">
            <Link href={`/plans?required=subscription&redirect=${encodeURIComponent(redirectTarget)}`} className="button-primary min-h-9 px-3 text-xs">
              Unlock
            </Link>
            <Link href={userLoggedIn ? `/plans?required=subscription&redirect=${encodeURIComponent(redirectTarget)}` : `/login?redirect=${encodeURIComponent(redirectTarget)}`} className="button-secondary min-h-9 px-3 text-xs">
              {userLoggedIn ? "View Plans" : "Sign In"}
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}