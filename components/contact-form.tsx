"use client";

import { FormEvent, useEffect, useState } from "react";
import { Bug, Heart, Lightbulb, MessageSquare, Sparkles, Wrench } from "lucide-react";
import { createSupabaseBrowserClient } from "@/lib/supabase/browser";

const feedbackKinds = [
  { value: "Bug report", label: "Bug Report", caption: "Something is not working", icon: Bug },
  { value: "Feature request", label: "Feature Request", caption: "I wish Tonefex could...", icon: Lightbulb },
  { value: "Improvement", label: "Improvement", caption: "This could be better", icon: Sparkles },
  { value: "Praise", label: "Praise", caption: "Something I love", icon: Heart },
  { value: "Other", label: "Other", caption: "Anything else", icon: MessageSquare }
];

type ContactFormMode = "combined" | "feedback" | "gear";

export function ContactForm({ mode = "combined" }: { mode?: ContactFormMode }) {
  const [topic, setTopic] = useState("Feature request");
  const [requestType, setRequestType] = useState("Guitar Amp");
  const [requestName, setRequestName] = useState("");
  const [email, setEmail] = useState("");
  const [message, setMessage] = useState("");
  const [status, setStatus] = useState("");
  const [viewMode, setViewMode] = useState<ContactFormMode>(mode);

  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    const kind = params.get("kind");

    let nextMode: ContactFormMode = mode;
    if (mode === "combined") {
      if (kind === "gear") {
        nextMode = "gear";
      } else if (kind === "feedback") {
        nextMode = "feedback";
      }
    }

    setViewMode(nextMode);

    if (nextMode === "gear") {
      setTopic("Request guitar or amp");
      setRequestType("Guitar Amp");
      return;
    }

    if (nextMode === "feedback") {
      setTopic((current) => (current === "Request guitar or amp" ? "Feature request" : current));
    }
  }, [mode]);

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const supabase = createSupabaseBrowserClient();
    if (!supabase) {
      setStatus("Supabase is not configured. Message was not sent.");
      return;
    }
    const {
      data: { user }
    } = await supabase.auth.getUser();
    const composedMessage = [requestName ? `Request: ${requestType} - ${requestName}` : "", message].filter(Boolean).join("\n\n");
    const { error } = await supabase.from("feedback_messages").insert({
      user_id: user?.id || null,
      topic,
      email,
      message: composedMessage
    });
    setStatus(error ? error.message : "Request received. Thank you.");
    if (!error) {
      setMessage("");
      setRequestName("");
    }
  }

  const isGearForm = viewMode === "gear" || (viewMode === "combined" && topic === "Request guitar or amp");
  const showFeedbackKinds = viewMode !== "gear";
  const showRequestTypePicker = viewMode === "combined";

  return (
    <form className="mx-auto grid w-full max-w-3xl gap-6" onSubmit={submit}>
      <section className="compact-card p-7">
        {showFeedbackKinds ? (
          <>
            <h2 className="mb-5 text-lg font-bold">What kind of feedback?</h2>
            <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
              {feedbackKinds.map((kind) => {
                const Icon = kind.icon;
                const active = topic === kind.value || (topic === "Request guitar or amp" && kind.value === "Feature request");
                return (
                  <button
                    key={kind.value}
                    type="button"
                    className={`min-h-24 rounded-lg border p-4 text-center transition ${
                      active ? "border-ink bg-ink text-white shadow-lg" : "border-white/80 bg-white/80 text-slate-700 hover:border-ocean/50"
                    }`}
                    onClick={() => setTopic(kind.value)}
                  >
                    <Icon className="mx-auto h-5 w-5" />
                    <span className="mt-2 block text-sm font-bold">{kind.label}</span>
                    <span className="mt-1 block text-xs text-neutral-500">{kind.caption}</span>
                  </button>
                );
              })}
            </div>
          </>
        ) : (
          <>
            <h2 className="mb-3 text-lg font-bold">Feature Request Form</h2>
            <p className="text-sm text-neutral-600">Tell us what gear you want to see in Tonefex. We review all requests and prioritize based on demand.</p>
          </>
        )}
      </section>

      <section className="compact-card grid gap-5 p-7">
        {showRequestTypePicker ? (
          <div>
            <label className="label" htmlFor="topic">
              Request type
            </label>
            <select className="field mt-2 h-12" id="topic" value={topic} onChange={(event) => setTopic(event.target.value)}>
              <option>Feature request</option>
              <option>Request guitar or amp</option>
              <option>General feedback</option>
              <option>Billing question</option>
              <option>Bug report</option>
            </select>
          </div>
        ) : null}

        {isGearForm ? (
          <>
            <div className="theme-blue-panel rounded-lg border border-white/80 px-4 py-3 text-sm text-slate-700">We review requested gear regularly and prioritize repeated requests.</div>
            <div>
              <label className="label" htmlFor="request-type">
                What would you like to request?
              </label>
              <select className="field mt-2 h-12" id="request-type" value={requestType} onChange={(event) => setRequestType(event.target.value)}>
                <option>Guitar Amp</option>
                <option>Guitar</option>
                <option>Pickup</option>
                <option>Pedal</option>
                <option>Multi FX Unit</option>
                <option>Bass Guitar</option>
                <option>Bass Amp</option>
                <option>Bass Gear</option>
                <option>Effect</option>
                <option>Other Feature</option>
              </select>
            </div>
            <div>
              <label className="label" htmlFor="request-name">
                {requestType} name
              </label>
              <input className="field mt-2 h-12" id="request-name" placeholder="e.g., Fender Twin Reverb" value={requestName} onChange={(event) => setRequestName(event.target.value)} />
            </div>
          </>
        ) : null}

        <div>
          <label className="label" htmlFor="message">
            {isGearForm ? "Additional information" : "Your feedback"}
          </label>
          <textarea
            className="field mt-2 min-h-44 rounded-lg"
            id="message"
            placeholder={isGearForm ? "Any details, links, or context that can help us understand your request..." : "Tell us what's on your mind..."}
            value={message}
            onChange={(event) => setMessage(event.target.value)}
            required
            minLength={10}
            maxLength={5000}
          />
          <div className="mt-2 flex justify-between text-xs text-neutral-400">
            <span>{message.length < 10 ? `${10 - message.length} more characters needed` : "Ready to submit"}</span>
            <span>{message.length}/5,000</span>
          </div>
        </div>

        <div>
          <label className="label" htmlFor="email">
            Your email
          </label>
          <input className="field mt-2 h-12" id="email" type="email" placeholder="your.email@example.com" value={email} onChange={(event) => setEmail(event.target.value)} />
        </div>

        {status ? <div className="rounded-lg bg-blue-50/80 px-4 py-3 text-sm font-bold text-ink">{status}</div> : null}
        <button className="button-primary min-h-14 rounded-lg text-base">
          {isGearForm ? <Wrench className="h-5 w-5" /> : <MessageSquare className="h-5 w-5" />}
          {isGearForm ? "Submit Feature Request" : "Submit Feedback"}
        </button>
      </section>

      <section className="compact-card p-7">
        <h2 className="text-lg font-bold">What happens next?</h2>
        <div className="mt-4 grid gap-3 text-sm text-neutral-600">
          <div>We review feedback and gear requests regularly.</div>
          <div>Popular gear requests are prioritized for the database.</div>
          <div>Bugs that affect tone matching or paid access go first.</div>
        </div>
      </section>
    </form>
  );
}
