"use client";

import { useEffect, useState } from "react";
import { Activity, CreditCard, Guitar, Loader2, Music2, ShieldCheck, Trash2, UserCircle } from "lucide-react";
import { createSupabaseBrowserClient } from "@/lib/supabase/browser";

type SubscriptionSnapshot = {
  status: string;
  plan_id: string | null;
  billing_interval: string | null;
  current_period_end: string | null;
};

export function AccountView() {
  const [email, setEmail] = useState("");
  const [fullName, setFullName] = useState("");
  const [subscription, setSubscription] = useState<SubscriptionSnapshot | null>(null);
  const [activeTab, setActiveTab] = useState<"settings" | "activity">("settings");
  const [stats, setStats] = useState({ presets: 0, savedTones: 0, activities: 0, adaptations: 0 });
  const [message, setMessage] = useState("");
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function loadAccount() {
      const supabase = createSupabaseBrowserClient();
      if (!supabase) {
        setMessage("Supabase is not configured.");
        setLoading(false);
        return;
      }

      const {
        data: { user }
      } = await supabase.auth.getUser();
      if (!user) {
        setMessage("Sign in to manage your account.");
        setLoading(false);
        return;
      }

      setEmail(user.email || "");
      const { data: profile } = await supabase.from("profiles").select("full_name").eq("id", user.id).maybeSingle();
      setFullName(profile?.full_name || user.user_metadata?.full_name || "");

      const { data: sub } = await supabase
        .from("subscriptions")
        .select("status, plan_id, billing_interval, current_period_end")
        .eq("user_id", user.id)
        .order("updated_at", { ascending: false })
        .limit(1)
        .maybeSingle();
      setSubscription(sub);
      setLoading(false);
    }

    loadAccount();

    setStats({
      presets: JSON.parse(localStorage.getItem("fretpilot_saved_gear_presets") || "[]").length,
      savedTones: JSON.parse(localStorage.getItem("fretpilot_saved_tones") || "[]").length,
      activities: JSON.parse(localStorage.getItem("fretpilot_recent_activity") || "[]").length,
      adaptations: Number(localStorage.getItem("fretpilot_daily_usage") || "0")
    });
  }, []);

  async function saveProfile() {
    const supabase = createSupabaseBrowserClient();
    if (!supabase) {
      return;
    }
    const {
      data: { user }
    } = await supabase.auth.getUser();
    if (!user) {
      return;
    }
    const { error } = await supabase.from("profiles").update({ full_name: fullName, email }).eq("id", user.id);
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

  return (
    <div className="px-4 pb-16 pt-28 sm:px-6 lg:px-8">
      <div className="mx-auto max-w-[1840px]">
        <section className="theme-panel theme-blue-panel p-8">
          <div className="flex flex-col gap-8 lg:flex-row lg:items-center lg:justify-between">
            <div className="flex items-center gap-6">
              <div className="grid h-24 w-24 place-items-center rounded-lg border border-white/80 bg-ink text-5xl font-bold text-white">
                {(fullName || email || "F").slice(0, 1).toUpperCase()}
              </div>
              <div>
                <h1 className="text-3xl font-bold">{fullName || email?.split("@")[0] || "Account"}</h1>
                <p className="mt-2 text-slate-600">{email || "Sign in to manage your profile"}</p>
                <span className="mt-4 inline-flex rounded-md bg-moss px-4 py-1 text-xs font-bold uppercase tracking-[0.12em] text-ink">Free Account</span>
              </div>
            </div>
            <a href="/app" className="button-primary">
              <Guitar className="h-4 w-4" />
              Adapt Tone
            </a>
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
                  <p className="text-sm text-neutral-500">Plan and payment status</p>
                </div>
              </div>
              <div className="grid gap-5 p-6 lg:grid-cols-2">
                <div className="rounded-lg bg-neutral-50 p-5">
                  <div className="text-xs font-bold uppercase tracking-[0.14em] text-neutral-400">Plan</div>
                  <div className="mt-2 text-lg font-bold">{subscription?.plan_id || "No Plan"}</div>
                </div>
                <div className="rounded-lg bg-neutral-50 p-5">
                  <div className="text-xs font-bold uppercase tracking-[0.14em] text-neutral-400">Status</div>
                  <div className="mt-2 text-lg font-bold capitalize">{subscription?.status || "Inactive"}</div>
                </div>
              </div>
              <div className="px-6 pb-6">
                <button className="button-primary" onClick={openBillingPortal}>
                  Manage Subscription
                </button>
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
