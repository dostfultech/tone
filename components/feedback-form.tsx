"use client";

import { useState } from "react";
import { CheckCircle2, Loader2, MessageSquareHeart, Star } from "lucide-react";

type ToneAccuracy = "excellent" | "good" | "average" | "needs_improvement" | "poor";
type ContactMethod = "email" | "discord" | "google_meet";

const TONE_ACCURACY_OPTIONS: { value: ToneAccuracy; label: string }[] = [
  { value: "excellent", label: "Excellent" },
  { value: "good", label: "Good" },
  { value: "average", label: "Average" },
  { value: "needs_improvement", label: "Needs Improvement" },
  { value: "poor", label: "Poor" }
];

const CONTACT_OPTIONS: { value: ContactMethod; label: string }[] = [
  { value: "email", label: "Email" },
  { value: "discord", label: "Discord" },
  { value: "google_meet", label: "Google Meet" }
];

export function FeedbackForm({ userEmail, userName }: { userEmail: string; userName?: string }) {
  const [submitted, setSubmitted] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const [fullName, setFullName] = useState(userName || "");
  const [overallRating, setOverallRating] = useState(0);
  const [hoverRating, setHoverRating] = useState(0);
  const [toneAccuracy, setToneAccuracy] = useState<ToneAccuracy | "">("");
  const [whatWorked, setWhatWorked] = useState("");
  const [improvements, setImprovements] = useState("");
  const [bugs, setBugs] = useState("");
  const [willingToCall, setWillingToCall] = useState(false);
  const [contactMethod, setContactMethod] = useState<ContactMethod | "">("");
  const [timezone, setTimezone] = useState("");

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (overallRating === 0) {
      setError("Please select an overall rating.");
      return;
    }
    if (!toneAccuracy) {
      setError("Please select a tone accuracy rating.");
      return;
    }

    setSubmitting(true);
    setError(null);

    try {
      const response = await fetch("/api/feedback", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          fullName: fullName.trim() || null,
          overallRating,
          toneAccuracy,
          whatWorked: whatWorked.trim() || null,
          improvements: improvements.trim() || null,
          bugs: bugs.trim() || null,
          willingToCall,
          preferredContactMethod: willingToCall && contactMethod ? contactMethod : null,
          timezone: willingToCall && timezone.trim() ? timezone.trim() : null
        })
      });

      if (!response.ok) {
        const data = await response.json().catch(() => null);
        throw new Error(data?.error || "Failed to submit feedback.");
      }

      setSubmitted(true);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Something went wrong. Please try again.");
    } finally {
      setSubmitting(false);
    }
  }

  if (submitted) {
    return (
      <div className="mx-auto max-w-2xl px-4 pb-14 pt-16 text-center sm:px-6">
        <div className="theme-panel theme-blue-panel p-8 lg:p-12">
          <div className="mx-auto grid h-16 w-16 place-items-center rounded-full bg-emerald-100">
            <CheckCircle2 className="h-8 w-8 text-emerald-600" />
          </div>
          <h1 className="mt-6 text-3xl font-bold sm:text-4xl">Thank You for Your Feedback!</h1>
          <p className="mx-auto mt-4 max-w-lg text-lg text-slate-600">
            Your feedback has been received and will directly help us improve tone adaptation for guitarists everywhere.
          </p>
          <div className="mx-auto mt-8 max-w-md rounded-lg border border-amber-200 bg-amber-50 px-6 py-4 text-sm text-amber-800">
            <p className="font-semibold">Your account will be upgraded to the complimentary Expert Plan shortly.</p>
            <p className="mt-2">We&apos;ll notify you at <span className="font-medium">{userEmail}</span> once your unlimited access is activated.</p>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-3xl px-4 pb-14 pt-16 sm:px-6">
      <div className="theme-panel theme-blue-panel overflow-hidden p-8 lg:p-10">
        <div className="mb-8 text-center">
          <div className="mx-auto inline-flex items-center gap-2 rounded-md bg-white/80 px-4 py-2 text-xs font-bold uppercase tracking-[0.14em] text-slate-600">
            <MessageSquareHeart className="h-4 w-4 text-amber-500" />
            Early Tester Program
          </div>
          <h1 className="mt-6 text-3xl font-bold sm:text-4xl">Help Shape Tonefex</h1>
          <p className="mx-auto mt-4 max-w-xl text-base text-slate-600">
            We&apos;re currently working with early users to improve tone adaptation accuracy. Your feedback will directly help make Tonefex better for guitarists worldwide.
          </p>
          <div className="mx-auto mt-6 max-w-md rounded-lg border border-amber-200 bg-amber-50 px-5 py-3 text-sm font-medium text-amber-800">
            After submitting honest feedback, you&apos;ll receive a complimentary Expert Plan with unlimited access.
          </div>
        </div>

        <form onSubmit={handleSubmit} className="space-y-6">
          <div className="grid gap-6 sm:grid-cols-2">
            <div>
              <label htmlFor="fb-name" className="mb-1.5 block text-sm font-semibold text-ink">Name</label>
              <input
                id="fb-name"
                type="text"
                value={fullName}
                onChange={(e) => setFullName(e.target.value)}
                className="w-full rounded-lg border border-slate-200 bg-white px-4 py-2.5 text-sm text-ink shadow-sm focus:border-ocean focus:outline-none focus:ring-2 focus:ring-ocean/20"
                placeholder="Your name"
              />
            </div>
            <div>
              <label htmlFor="fb-email" className="mb-1.5 block text-sm font-semibold text-ink">Email</label>
              <input
                id="fb-email"
                type="email"
                value={userEmail}
                readOnly
                className="w-full rounded-lg border border-slate-200 bg-slate-50 px-4 py-2.5 text-sm text-slate-500 shadow-sm"
              />
            </div>
          </div>

          <div>
            <label className="mb-2 block text-sm font-semibold text-ink">Overall Rating</label>
            <div className="flex gap-1">
              {[1, 2, 3, 4, 5].map((star) => (
                <button
                  key={star}
                  type="button"
                  onClick={() => setOverallRating(star)}
                  onMouseEnter={() => setHoverRating(star)}
                  onMouseLeave={() => setHoverRating(0)}
                  className="rounded p-1 transition-transform hover:scale-110 focus:outline-none focus:ring-2 focus:ring-ocean/30"
                  aria-label={`Rate ${star} star${star > 1 ? "s" : ""}`}
                >
                  <Star
                    className={`h-8 w-8 transition-colors ${
                      star <= (hoverRating || overallRating)
                        ? "fill-amber-400 text-amber-400"
                        : "text-slate-300"
                    }`}
                  />
                </button>
              ))}
            </div>
          </div>

          <div>
            <label htmlFor="fb-accuracy" className="mb-1.5 block text-sm font-semibold text-ink">How accurate was the adapted tone?</label>
            <select
              id="fb-accuracy"
              value={toneAccuracy}
              onChange={(e) => setToneAccuracy(e.target.value as ToneAccuracy)}
              className="w-full rounded-lg border border-slate-200 bg-white px-4 py-2.5 text-sm text-ink shadow-sm focus:border-ocean focus:outline-none focus:ring-2 focus:ring-ocean/20"
            >
              <option value="">Select accuracy...</option>
              {TONE_ACCURACY_OPTIONS.map((opt) => (
                <option key={opt.value} value={opt.value}>{opt.label}</option>
              ))}
            </select>
          </div>

          <div>
            <label htmlFor="fb-worked" className="mb-1.5 block text-sm font-semibold text-ink">What worked well?</label>
            <textarea
              id="fb-worked"
              value={whatWorked}
              onChange={(e) => setWhatWorked(e.target.value)}
              rows={3}
              className="w-full rounded-lg border border-slate-200 bg-white px-4 py-2.5 text-sm text-ink shadow-sm focus:border-ocean focus:outline-none focus:ring-2 focus:ring-ocean/20"
              placeholder="Tell us what impressed you about the tone adaptations..."
            />
          </div>

          <div>
            <label htmlFor="fb-improve" className="mb-1.5 block text-sm font-semibold text-ink">What could we improve?</label>
            <textarea
              id="fb-improve"
              value={improvements}
              onChange={(e) => setImprovements(e.target.value)}
              rows={3}
              className="w-full rounded-lg border border-slate-200 bg-white px-4 py-2.5 text-sm text-ink shadow-sm focus:border-ocean focus:outline-none focus:ring-2 focus:ring-ocean/20"
              placeholder="Any suggestions for making the adapted tones more accurate or useful?"
            />
          </div>

          <div>
            <label htmlFor="fb-bugs" className="mb-1.5 block text-sm font-semibold text-ink">Did you encounter any bugs?</label>
            <textarea
              id="fb-bugs"
              value={bugs}
              onChange={(e) => setBugs(e.target.value)}
              rows={2}
              className="w-full rounded-lg border border-slate-200 bg-white px-4 py-2.5 text-sm text-ink shadow-sm focus:border-ocean focus:outline-none focus:ring-2 focus:ring-ocean/20"
              placeholder="Describe any issues or unexpected behavior you experienced..."
            />
          </div>

          <div className="rounded-lg border border-slate-200 bg-white/80 p-5">
            <label className="flex cursor-pointer items-start gap-3">
              <input
                type="checkbox"
                checked={willingToCall}
                onChange={(e) => setWillingToCall(e.target.checked)}
                className="mt-0.5 h-5 w-5 rounded border-slate-300 text-ocean focus:ring-ocean/30"
              />
              <div>
                <span className="text-sm font-semibold text-ink">I&apos;m willing to participate in a 15–20 minute feedback call</span>
                <span className="mt-1 block text-xs text-slate-500">Help us understand your experience in more detail</span>
              </div>
            </label>

            {willingToCall && (
              <div className="mt-4 grid gap-4 border-t border-slate-100 pt-4 sm:grid-cols-2">
                <div>
                  <label htmlFor="fb-contact" className="mb-1.5 block text-sm font-semibold text-ink">Preferred contact method</label>
                  <select
                    id="fb-contact"
                    value={contactMethod}
                    onChange={(e) => setContactMethod(e.target.value as ContactMethod)}
                    className="w-full rounded-lg border border-slate-200 bg-white px-4 py-2.5 text-sm text-ink shadow-sm focus:border-ocean focus:outline-none focus:ring-2 focus:ring-ocean/20"
                  >
                    <option value="">Select...</option>
                    {CONTACT_OPTIONS.map((opt) => (
                      <option key={opt.value} value={opt.value}>{opt.label}</option>
                    ))}
                  </select>
                </div>
                <div>
                  <label htmlFor="fb-timezone" className="mb-1.5 block text-sm font-semibold text-ink">Your timezone</label>
                  <input
                    id="fb-timezone"
                    type="text"
                    value={timezone}
                    onChange={(e) => setTimezone(e.target.value)}
                    className="w-full rounded-lg border border-slate-200 bg-white px-4 py-2.5 text-sm text-ink shadow-sm focus:border-ocean focus:outline-none focus:ring-2 focus:ring-ocean/20"
                    placeholder="e.g. IST, EST, PST, GMT+5:30"
                  />
                </div>
              </div>
            )}
          </div>

          {error && (
            <div className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
              {error}
            </div>
          )}

          <button
            type="submit"
            disabled={submitting}
            className="button-primary w-full min-h-14 rounded-lg text-base"
          >
            {submitting ? <Loader2 className="h-5 w-5 animate-spin" /> : null}
            Submit Feedback
          </button>
        </form>
      </div>
    </div>
  );
}
