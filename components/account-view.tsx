"use client";

import Link from "next/link";
import { useEffect, useState } from "react";
import { Activity, Check, CreditCard, Guitar, Loader2, Music2, ShieldCheck, Trash2, UserCircle } from "lucide-react";
import { brand } from "@/lib/brand";
import {
  formatSubscriptionDate,
  formatSubscriptionStatus,
  loadClientSubscriptionSnapshot,
  type ClientSubscriptionSnapshot
} from "@/lib/subscription-client";
import { createSupabaseBrowserClient } from "@/lib/supabase/browser";

export function AccountView() {
  const [email, setEmail] = useState("");
  const [fullName, setFullName] = useState("");
  const [snapshot, setSnapshot] = useState<ClientSubscriptionSnapshot | null>(null);
  const [activeTab, setActiveTab] = useState<"settings" | "activity">("settings");
  const [stats, setStats] = useState({ presets: 0, savedTones: 0, activities: 0, adaptations: 0 });
  const [message, setMessage] = useState("");
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const supabase = createSupabaseBrowserClient();
    if (!supabase) {
      setMessage("Supabase is not configured.");
      setLoading(false);
      return;
    }
    const client = supabase;

    async function loadAccount() {
      const subscriptionSnapshot = await loadClientSubscriptionSnapshot(client);
      setSnapshot(subscriptionSnapshot);

      if (!subscriptionSnapshot.user) {
        setMessage("Sign in to manage your account.");
        setLoading(false);
        return;
      }

      setEmail(subscriptionSnapshot.user.email || "");

      const { data: profile } = await client
        .from("profiles")
        .select("full_name")
        .eq("id", subscriptionSnapshot.user.id)
        .maybeSingle();

      setFullName(profile?.full_name || subscriptionSnapshot.user.user_metadata?.full_name || "");

      setStats({
        presets: subscriptionSnapshot.totals.gearPresets,
        savedTones: subscriptionSnapshot.totals.savedTones,
        activities: JSON.parse(localStorage.getItem(`${brand.storagePrefix}_recent_activity`) || "[]").length,
        adaptations: subscriptionSnapshot.usage.adaptationsUsed
      });

      setLoading(false);
    }

    void loadAccount();

    const {
      data: { subscription }
    } = client.auth.onAuthStateChange(() => {
      loadAccount().catch(() => undefined);
    });

    return () => subscription.unsubscribe();
  }, []);

  async function saveProfile() {
    const supabase = createSupabaseBrowserClient();
    if (!supabase) {
      return;
    }
    const client = supabase;

    const {
      data: { user }
    } = await client.auth.getUser();

    if (!user) {
      return;
    }

    const { error } = await client.from("profiles").update({ full_name: fullName, email }).eq("id", user.id);
    setMessage(error ? error.message : "Profile saved.");
  }

  async function openBillingPortal() {
    const response = await fetch("/api/dodo/customer-portal");
    const data = await response.json();
    if (!response.ok) {
      setMessage(data.error || "Customer portal is unavailable.");
      return;
    }
    window.location.href = data.portalUrl;
  }

  async function deleteAccount() {
    const response = await fetch("/api/account/delete", { method: "POST" });
    const data = await response.json().catch(() => ({}));
    setMessage(data.message || data.error || "Account deletion request processed.");
  }

  const planLabel = snapshot?.hasAccess ? snapshot.planName || "Active plan" : "No active plan";
  const statusLabel = snapshot?.hasAccess ? formatSubscriptionStatus(snapshot.status) : "Inactive";

  return (
    <div className="px-4 pb-14 pt-24 sm:px-6 lg:px-8">
      <div className="mx-auto max-w-[1440px]">
        <section className="theme-panel theme-blue-panel p-8">
          <div className="flex flex-col gap-8 lg:flex-row lg:items-center lg:justify-between">
            <div className="flex items-center gap-6">
              <div className="grid h-24 w-24 place-items-center rounded-lg border border-white/80 bg-ink text-5xl font-bold text-white">
                {(fullName || email || "F").slice(0, 1).toUpperCase()}
              </div>
              <div>
                <h1 className="text-3xl font-bold">{fullName || email?.split("@")[0] || "Account"}</h1>
                <p className="mt-2 text-slate-600">{email || "Sign in to manage your profile"}</p>
                <span className={`mt-4 inline-flex rounded-md px-4 py-1 text-xs font-bold uppercase tracking-[0.12em] ${snapshot?.hasAccess ? "bg-moss text-ink" : "bg-white text-slate-700"}`}>
                  {planLabel}
                </span>
              </div>
            </div>
            <Link href="/app" className="button-primary">
              <Guitar className="h-4 w-4" />
              Adapt Tone
            </Link>
          </div>
        </section>

        {message ? <div className="mt-6 rounded-lg bg-blue-50/80 px-4 py-3 text-sm font-bold text-ink">{message}</div> : null}

        <div className="mt-8 inline-flex rounded-lg border border-white/80 bg-white/80 p-1 shadow-sm">
          {[
            ["settings", "Settings", UserCircle],
            ["activity", "Activity", Activity]
          ].map(([value, label, Icon]) => {
            const ActiveIcon = Icon as typeof UserCircle;
            const active = activeTab === value;
            return (
              <button
                key={value as string}
                type="button"
                className={`flex min-h-12 items-center gap-3 rounded-md px-5 text-sm font-bold transition ${active ? "bg-ink text-white" : "text-slate-700 hover:bg-blue-50"}`}
                onClick={() => setActiveTab(value as "settings" | "activity")}
              >
                <ActiveIcon className="h-4 w-4" />
                {label as string}
                {value === "activity" ? <span className="rounded-full bg-neutral-100 px-2 py-0.5 text-xs text-neutral-500">{stats.activities}</span> : null}
              </button>
            );
          })}
        </div>

        <div className="mt-8 grid gap-5 md:grid-cols-4">
          <StatCard value={stats.presets} label="Presets" />
          <StatCard value={stats.savedTones} label="Saved Tones" />
          <StatCard value={stats.activities} label="Activities" />
          <StatCard value={stats.adaptations} label="Adaptations" />
        </div>

        {loading ? (
          <div className="compact-card mt-8 flex min-h-64 items-center justify-center gap-3 p-8 text-neutral-600">
            <Loader2 className="h-5 w-5 animate-spin" />
            Loading account
          </div>
        ) : activeTab === "settings" ? (
          <div className="mt-8 grid gap-6">
            <section className="compact-card overflow-hidden">
              <div className="flex items-center gap-4 border-b border-neutral-200 p-6">
                <div className="grid h-12 w-12 place-items-center rounded-lg bg-ink text-moss">
                  <CreditCard className="h-6 w-6" />
                </div>
                <div>
                  <h2 className="text-xl font-bold">Subscription</h2>
                  <p className="text-sm text-neutral-500">Plan, renewal, limits, and feature access</p>
                </div>
              </div>

              <div className="grid gap-5 p-6 xl:grid-cols-[1.1fr_0.9fr]">
                <div className="grid gap-4 sm:grid-cols-2">
                  <MetricCard label="Current plan" value={planLabel} />
                  <MetricCard label="Plan status" value={statusLabel} />
                  <MetricCard label="Renewal date" value={snapshot?.hasAccess ? formatSubscriptionDate(snapshot.renewalDate) : "Not scheduled"} />
                  <MetricCard label="Billing" value={snapshot?.billingInterval === "annual" ? "Annual" : snapshot?.billingInterval === "monthly" ? "Monthly" : "None"} />
                  <MetricCard label="Adaptations" value={snapshot ? formatRemaining(snapshot.usage.adaptationsUsed, snapshot.usage.adaptationsRemaining) : "0 used"} />
                  <MetricCard label="Saved tones" value={snapshot ? formatRemaining(snapshot.usage.savedTonesUsed, snapshot.usage.savedTonesRemaining) : "0 used"} />
                  <MetricCard label="Starter adaptations left" value={snapshot?.usage.starterAdaptationsRemaining === null ? "Unlimited" : String(snapshot?.usage.starterAdaptationsRemaining ?? 0)} />
                  <MetricCard label="Gear presets" value={snapshot ? formatRemaining(snapshot.usage.gearPresetsUsed, snapshot.usage.gearPresetsRemaining) : "0 used"} />
                </div>

                <div className="rounded-lg border border-neutral-200 bg-neutral-50 p-5">
                  <div className="text-xs font-bold uppercase tracking-[0.14em] text-neutral-400">Unlocked features</div>
                  <div className="mt-4 grid gap-3 text-sm text-neutral-700">
                    {(snapshot?.features.length ? snapshot.features : ["Community Tone Database", "Saved tones", "Tone matching"]).map((feature) => (
                      <div key={feature} className="flex items-center gap-2">
                        <Check className="h-4 w-4 text-moss" />
                        <span>{feature}</span>
                      </div>
                    ))}
                  </div>
                  <div className="mt-5 flex flex-wrap gap-3">
                    {snapshot?.hasAccess ? (
                      <button className="button-primary" onClick={openBillingPortal}>
                        Manage Subscription
                      </button>
                    ) : (
                      <Link className="button-primary" href="/plans">
                        View Plans
                      </Link>
                    )}
                    {snapshot?.planId === "beginner" ? (
                      <Link className="button-secondary" href="/plans">
                        Upgrade to Expert
                      </Link>
                    ) : null}
                  </div>
                </div>
              </div>
            </section>

            <section className="compact-card overflow-hidden">
              <div className="flex items-center gap-4 border-b border-neutral-200 p-6">
                <div className="grid h-12 w-12 place-items-center rounded-lg bg-ink text-moss">
                  <UserCircle className="h-6 w-6" />
                </div>
                <div>
                  <h2 className="text-xl font-bold">Profile</h2>
                  <p className="text-sm text-neutral-500">Picture and username</p>
                </div>
              </div>
              <div className="grid gap-5 p-6">
                <div className="flex items-center gap-4">
                  <div className="grid h-20 w-20 place-items-center rounded-lg bg-ink text-3xl font-bold text-white">{(fullName || email || "F").slice(0, 1).toUpperCase()}</div>
                  <button className="button-secondary" type="button">
                    Choose File
                  </button>
                  <span className="text-sm text-neutral-500">Max 5MB - JPG, PNG, GIF</span>
                </div>
                <div>
                  <label className="label" htmlFor="full-name">
                    Username
                  </label>
                  <input id="full-name" className="field mt-2 h-12" placeholder="Enter username" value={fullName} onChange={(event) => setFullName(event.target.value)} />
                </div>
                <div>
                  <label className="label" htmlFor="email">
                    Email
                  </label>
                  <input id="email" className="field mt-2 h-12" type="email" value={email} onChange={(event) => setEmail(event.target.value)} />
                </div>
                <button className="button-primary w-fit" onClick={saveProfile}>
                  Save
                </button>
              </div>
            </section>

            <section className="compact-card overflow-hidden">
              <div className="flex items-center gap-4 border-b border-neutral-200 p-6">
                <div className="grid h-12 w-12 place-items-center rounded-lg bg-ink text-moss">
                  <ShieldCheck className="h-6 w-6" />
                </div>
                <div>
                  <h2 className="text-xl font-bold">Security</h2>
                  <p className="text-sm text-neutral-500">Password and sign out</p>
                </div>
              </div>
              <div className="p-6 text-neutral-600">Password resets are handled through Supabase Auth email flows.</div>
            </section>

            <section className="rounded-lg border border-red-200 bg-red-50 p-6">
              <h2 className="text-xl font-bold text-red-900">Danger zone</h2>
              <p className="mt-2 text-sm leading-6 text-red-800">Request account deletion and clear profile-linked application data.</p>
              <button className="mt-4 inline-flex min-h-11 items-center justify-center gap-2 rounded-md bg-red-700 px-4 py-2 text-sm font-semibold text-white hover:bg-red-800" onClick={deleteAccount}>
                <Trash2 className="h-4 w-4" />
                Delete account data
              </button>
            </section>
          </div>
        ) : (
          <section className="compact-card mt-8 grid min-h-[360px] place-items-center p-8 text-center">
            <div>
              <Music2 className="mx-auto mb-5 h-14 w-14 text-ink" />
              <h2 className="text-3xl font-bold">Recent activity</h2>
              <p className="mt-3 text-lg text-neutral-600">Tone matching activity is tracked locally during testing and in Supabase when configured.</p>
            </div>
          </section>
        )}
      </div>
    </div>
  );
}

function StatCard({ value, label }: { value: number; label: string }) {
  return (
    <div className="compact-card p-5 text-center">
      <div className="text-3xl font-bold text-ink">{value}</div>
      <div className="mt-1 text-sm text-neutral-500">{label}</div>
    </div>
  );
}

function MetricCard({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-lg bg-neutral-50 p-5">
      <div className="text-xs font-bold uppercase tracking-[0.14em] text-neutral-400">{label}</div>
      <div className="mt-2 text-lg font-bold">{value}</div>
    </div>
  );
}

function formatRemaining(used: number, remaining: number | null) {
  if (remaining === null) {
    return `${used} used · Unlimited remaining`;
  }

  return `${used} used · ${remaining} remaining`;
}
