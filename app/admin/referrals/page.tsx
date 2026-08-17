import type { Metadata } from "next";
import { redirect } from "next/navigation";
import { commissionFor } from "@/lib/referral";
import { getCurrentSession } from "@/lib/server-access";
import { createSupabaseAdminClient } from "@/lib/supabase/admin";

export const metadata: Metadata = {
  title: "Admin — Referrals",
  robots: { index: false, follow: false }
};

export default async function AdminReferralsPage() {
  const { supabase, user } = await getCurrentSession();
  if (!user || !supabase) {
    redirect("/login?redirect=/admin/referrals");
  }

  const { data: profile } = await supabase.from("profiles").select("role").eq("id", user.id).maybeSingle();
  if (profile?.role !== "admin") {
    redirect("/app");
  }

  const admin = createSupabaseAdminClient();
  if (!admin) {
    return <div className="p-8 text-center text-red-600">Admin client not configured.</div>;
  }

  const { data: referredRows } = await admin
    .from("profiles")
    .select("id, referred_by, email, created_at")
    .not("referred_by", "is", null);
  const rows = referredRows ?? [];
  const refereeIds = rows.map((r) => r.id as string);

  let subscribedSet = new Set<string>();
  const commissionByReferee = new Map<string, number>();
  if (refereeIds.length) {
    const { data: subs } = await admin
      .from("subscriptions")
      .select("user_id, plan_id, billing_interval, trial_end")
      .in("user_id", refereeIds)
      .eq("status", "active")
      .in("plan_id", ["beginner", "expert"]);
    // Paid only: active AND past-trial (or no trial). Trial-then-cancel never counts.
    const now = Date.now();
    for (const s of subs ?? []) {
      if (s.trial_end && new Date(s.trial_end as string).getTime() > now) continue;
      const uid = s.user_id as string;
      if (commissionByReferee.has(uid)) continue;
      commissionByReferee.set(uid, commissionFor(String(s.plan_id), String(s.billing_interval || "monthly")));
    }
    subscribedSet = new Set(commissionByReferee.keys());
  }

  const agg = new Map<string, { signups: number; subscribed: number; commission: number }>();
  for (const r of rows) {
    const ref = r.referred_by as string;
    const a = agg.get(ref) ?? { signups: 0, subscribed: 0, commission: 0 };
    a.signups += 1;
    if (subscribedSet.has(r.id as string)) {
      a.subscribed += 1;
      a.commission += commissionByReferee.get(r.id as string) ?? 0;
    }
    agg.set(ref, a);
  }

  const referrerIds = [...agg.keys()];
  const referrerInfo = new Map<string, { email: string; code: string }>();
  if (referrerIds.length) {
    const { data: refs } = await admin.from("profiles").select("id, email, referral_code").in("id", referrerIds);
    (refs ?? []).forEach((p) =>
      referrerInfo.set(p.id as string, {
        email: (p.email as string) || "(no email)",
        code: (p.referral_code as string) || ""
      })
    );
  }

  const leaderboard = referrerIds
    .map((id) => ({ id, ...agg.get(id)!, ...(referrerInfo.get(id) ?? { email: id, code: "" }) }))
    .sort((a, b) => b.subscribed - a.subscribed || b.signups - a.signups);

  const totalSignups = rows.length;
  const totalSubscribed = subscribedSet.size;
  const totalCommission = [...commissionByReferee.values()].reduce((sum, value) => sum + value, 0);

  return (
    <div className="min-h-screen bg-slate-50">
      <div className="mx-auto max-w-5xl px-4 py-8 sm:px-6 lg:px-8">
        <h1 className="text-3xl font-bold text-ink">Referrals</h1>
        <p className="mt-2 text-sm text-slate-600">Who has brought players in, and how many converted to paid.</p>

        <div className="mb-8 mt-6 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
          <StatCard label="Active referrers" value={String(leaderboard.length)} />
          <StatCard label="Referred signups" value={String(totalSignups)} />
          <StatCard label="Referred subscribers" value={String(totalSubscribed)} />
          <StatCard label="Commission owed" value={`$${totalCommission.toFixed(2)}`} highlight={totalCommission > 0} />
        </div>

        <div className="overflow-x-auto rounded-lg border border-slate-200 bg-white shadow-sm">
          <table className="w-full min-w-[560px] text-left text-sm">
            <thead className="border-b border-slate-200 bg-slate-50 text-xs font-bold uppercase tracking-wide text-slate-500">
              <tr>
                <th className="px-4 py-3">Referrer</th>
                <th className="px-4 py-3">Code</th>
                <th className="px-4 py-3 text-right">Signed up</th>
                <th className="px-4 py-3 text-right">Subscribed</th>
                <th className="px-4 py-3 text-right">Commission</th>
              </tr>
            </thead>
            <tbody>
              {leaderboard.length === 0 ? (
                <tr>
                  <td colSpan={5} className="px-4 py-8 text-center text-slate-500">
                    No referrals yet.
                  </td>
                </tr>
              ) : (
                leaderboard.map((row) => (
                  <tr key={row.id} className="border-b border-slate-100 last:border-0">
                    <td className="px-4 py-3 font-medium text-ink">{row.email}</td>
                    <td className="px-4 py-3 font-mono text-slate-500">{row.code}</td>
                    <td className="px-4 py-3 text-right font-bold text-ink">{row.signups}</td>
                    <td className="px-4 py-3 text-right font-bold text-ink">{row.subscribed}</td>
                    <td className="px-4 py-3 text-right font-bold text-emerald-600">${row.commission.toFixed(2)}</td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}

function StatCard({ label, value, highlight = false }: { label: string; value: string; highlight?: boolean }) {
  return (
    <div className={`rounded-lg border p-4 shadow-sm ${highlight ? "border-emerald-300 bg-emerald-50" : "border-slate-200 bg-white"}`}>
      <div className="text-xs font-bold uppercase tracking-[0.14em] text-slate-500">{label}</div>
      <div className="mt-2 text-2xl font-bold text-ink">{value}</div>
    </div>
  );
}
