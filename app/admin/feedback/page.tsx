import type { Metadata } from "next";
import { redirect } from "next/navigation";
import { getCurrentSession } from "@/lib/server-access";
import { createSupabaseAdminClient } from "@/lib/supabase/admin";
import { AdminFeedbackDashboard } from "@/components/admin-feedback-dashboard";

export const metadata: Metadata = {
  title: "Admin — Early Tester Feedback",
  robots: { index: false, follow: false }
};

export default async function AdminFeedbackPage() {
  const { supabase, user } = await getCurrentSession();
  if (!user || !supabase) {
    redirect("/login?redirect=/admin/feedback");
  }

  const { data: profile } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .maybeSingle();

  if (profile?.role !== "admin") {
    redirect("/app");
  }

  const admin = createSupabaseAdminClient();
  if (!admin) {
    return <div className="p-8 text-center text-red-600">Admin client not configured.</div>;
  }

  const { data: submissions } = await admin
    .from("feedback_submissions")
    .select("*")
    .order("created_at", { ascending: false });

  const { data: stats } = await admin
    .from("feedback_submissions")
    .select("overall_rating, tone_accuracy, status", { count: "exact" });

  const totalCount = stats?.length || 0;
  const avgRating = totalCount > 0
    ? (stats!.reduce((sum, r) => sum + (r.overall_rating || 0), 0) / totalCount).toFixed(1)
    : "—";
  const pendingCount = stats?.filter((r) => r.status === "pending").length || 0;
  const upgradedCount = stats?.filter((r) => r.status === "upgraded").length || 0;
  const willingToCallCount = submissions?.filter((s) => s.willing_to_call).length || 0;

  return (
    <div className="min-h-screen bg-slate-50">
      <div className="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8">
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-ink">Early Tester Feedback</h1>
          <p className="mt-2 text-sm text-slate-600">Review feedback submissions and upgrade users to Expert plan.</p>
        </div>

        <div className="mb-8 grid gap-4 sm:grid-cols-2 lg:grid-cols-5">
          <StatCard label="Total Submissions" value={String(totalCount)} />
          <StatCard label="Average Rating" value={`${avgRating}/5`} />
          <StatCard label="Pending Review" value={String(pendingCount)} highlight={pendingCount > 0} />
          <StatCard label="Upgraded" value={String(upgradedCount)} />
          <StatCard label="Willing to Call" value={String(willingToCallCount)} />
        </div>

        <AdminFeedbackDashboard submissions={submissions || []} />
      </div>
    </div>
  );
}

function StatCard({ label, value, highlight = false }: { label: string; value: string; highlight?: boolean }) {
  return (
    <div className={`rounded-lg border p-4 shadow-sm ${highlight ? "border-amber-300 bg-amber-50" : "border-slate-200 bg-white"}`}>
      <div className="text-xs font-bold uppercase tracking-[0.14em] text-slate-500">{label}</div>
      <div className="mt-2 text-2xl font-bold text-ink">{value}</div>
    </div>
  );
}
