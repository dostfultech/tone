"use client";

import { useState } from "react";
import { CheckCircle2, ChevronDown, ChevronUp, Loader2, Phone, Star } from "lucide-react";

type FeedbackSubmission = {
  id: string;
  user_id: string;
  email: string;
  full_name: string | null;
  overall_rating: number;
  tone_accuracy: string;
  what_worked: string | null;
  improvements: string | null;
  bugs: string | null;
  willing_to_call: boolean;
  preferred_contact_method: string | null;
  timezone: string | null;
  status: string;
  created_at: string;
};

const ACCURACY_LABELS: Record<string, string> = {
  excellent: "Excellent",
  good: "Good",
  average: "Average",
  needs_improvement: "Needs Improvement",
  poor: "Poor"
};

export function AdminFeedbackDashboard({ submissions }: { submissions: FeedbackSubmission[] }) {
  const [items, setItems] = useState(submissions);
  const [expandedId, setExpandedId] = useState<string | null>(null);
  const [upgrading, setUpgrading] = useState<string | null>(null);
  const [filter, setFilter] = useState<"all" | "pending" | "reviewed" | "upgraded">("all");

  const filtered = filter === "all" ? items : items.filter((s) => s.status === filter);

  async function upgradeUser(submission: FeedbackSubmission) {
    setUpgrading(submission.id);
    try {
      const response = await fetch("/api/admin/upgrade-early-tester", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ userId: submission.user_id, feedbackId: submission.id })
      });
      if (!response.ok) {
        const data = await response.json().catch(() => null);
        alert(data?.error || "Failed to upgrade user.");
        return;
      }
      setItems((prev) =>
        prev.map((s) => (s.id === submission.id ? { ...s, status: "upgraded" } : s))
      );
    } catch {
      alert("Network error. Please try again.");
    } finally {
      setUpgrading(null);
    }
  }

  return (
    <div>
      <div className="mb-4 flex gap-2">
        {(["all", "pending", "reviewed", "upgraded"] as const).map((f) => (
          <button
            key={f}
            onClick={() => setFilter(f)}
            className={`rounded-lg px-4 py-2 text-sm font-medium transition-colors ${
              filter === f
                ? "bg-ink text-white"
                : "bg-white text-slate-600 hover:bg-slate-100"
            }`}
          >
            {f.charAt(0).toUpperCase() + f.slice(1)}
          </button>
        ))}
      </div>

      {filtered.length === 0 ? (
        <div className="rounded-lg border border-dashed border-slate-300 bg-white p-12 text-center text-sm text-slate-500">
          No feedback submissions {filter !== "all" ? `with status "${filter}"` : "yet"}.
        </div>
      ) : (
        <div className="space-y-3">
          {filtered.map((submission) => {
            const expanded = expandedId === submission.id;
            return (
              <div key={submission.id} className="rounded-lg border border-slate-200 bg-white shadow-sm">
                <button
                  type="button"
                  onClick={() => setExpandedId(expanded ? null : submission.id)}
                  className="flex w-full items-center gap-4 px-5 py-4 text-left"
                >
                  <div className="flex items-center gap-1">
                    {Array.from({ length: 5 }, (_, i) => (
                      <Star
                        key={i}
                        className={`h-4 w-4 ${i < submission.overall_rating ? "fill-amber-400 text-amber-400" : "text-slate-200"}`}
                      />
                    ))}
                  </div>
                  <div className="min-w-0 flex-1">
                    <span className="font-semibold text-ink">{submission.full_name || submission.email}</span>
                    <span className="ml-2 text-sm text-slate-500">{submission.email}</span>
                  </div>
                  <span className="text-xs text-slate-400">
                    {new Date(submission.created_at).toLocaleDateString()}
                  </span>
                  <StatusBadge status={submission.status} />
                  {submission.willing_to_call && (
                    <span aria-label="Willing to do feedback call"><Phone className="h-4 w-4 text-emerald-500" /></span>
                  )}
                  {expanded ? <ChevronUp className="h-4 w-4 text-slate-400" /> : <ChevronDown className="h-4 w-4 text-slate-400" />}
                </button>

                {expanded && (
                  <div className="border-t border-slate-100 px-5 py-4">
                    <div className="grid gap-4 sm:grid-cols-2">
                      <Field label="Tone Accuracy" value={ACCURACY_LABELS[submission.tone_accuracy] || submission.tone_accuracy} />
                      <Field label="User ID" value={submission.user_id} mono />
                    </div>

                    {submission.what_worked && <Field label="What worked well" value={submission.what_worked} className="mt-4" />}
                    {submission.improvements && <Field label="What could improve" value={submission.improvements} className="mt-4" />}
                    {submission.bugs && <Field label="Bugs reported" value={submission.bugs} className="mt-4" />}

                    {submission.willing_to_call && (
                      <div className="mt-4 rounded-lg border border-emerald-200 bg-emerald-50 p-3">
                        <div className="text-xs font-bold uppercase tracking-[0.14em] text-emerald-700">Available for Feedback Call</div>
                        <div className="mt-1 text-sm text-emerald-800">
                          {submission.preferred_contact_method && `Via: ${submission.preferred_contact_method.replace("_", " ")}`}
                          {submission.timezone && ` · Timezone: ${submission.timezone}`}
                        </div>
                      </div>
                    )}

                    {submission.status === "pending" && (
                      <div className="mt-4 flex gap-3">
                        <button
                          onClick={() => upgradeUser(submission)}
                          disabled={upgrading === submission.id}
                          className="button-primary rounded-lg px-6 py-2.5 text-sm"
                        >
                          {upgrading === submission.id ? <Loader2 className="h-4 w-4 animate-spin" /> : <CheckCircle2 className="h-4 w-4" />}
                          <span className="ml-2">Upgrade to Expert Plan</span>
                        </button>
                      </div>
                    )}
                  </div>
                )}
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}

function StatusBadge({ status }: { status: string }) {
  const styles: Record<string, string> = {
    pending: "bg-amber-100 text-amber-700",
    reviewed: "bg-blue-100 text-blue-700",
    upgraded: "bg-emerald-100 text-emerald-700"
  };
  return (
    <span className={`rounded-full px-2.5 py-0.5 text-xs font-semibold ${styles[status] || "bg-slate-100 text-slate-600"}`}>
      {status}
    </span>
  );
}

function Field({ label, value, mono = false, className = "" }: { label: string; value: string; mono?: boolean; className?: string }) {
  return (
    <div className={className}>
      <div className="text-xs font-bold uppercase tracking-[0.14em] text-slate-500">{label}</div>
      <div className={`mt-1 text-sm text-ink ${mono ? "font-mono text-xs" : ""}`}>{value}</div>
    </div>
  );
}
