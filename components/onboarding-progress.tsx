"use client";

import { CheckCircle2, Search, SlidersHorizontal, Sparkles } from "lucide-react";

const steps = [
  { id: 1, label: "Setup Your Gear", icon: SlidersHorizontal },
  { id: 2, label: "Find a Song", icon: Search },
  { id: 3, label: "Adapt Your First Tone", icon: Sparkles }
] as const;

export function OnboardingProgress({
  currentStep,
  completed
}: {
  currentStep: 1 | 2 | 3;
  completed?: boolean;
}) {
  const activeStep = completed ? 3 : currentStep;

  return (
    <div className="theme-blue-panel rounded-lg border border-white/80 px-5 py-4 shadow-sm">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <div className="text-xs font-bold uppercase tracking-[0.14em] text-slate-500">
            {completed ? "Onboarding Complete" : `Step ${activeStep} of 3`}
          </div>
          <div className="mt-1 text-sm text-slate-600">
            {completed ? "Your saved gear is ready for unlimited song discovery and personalized tone adaptation." : "Follow the next step to get to your first personalized tone fast."}
          </div>
        </div>
        {completed ? (
          <div className="inline-flex items-center gap-2 rounded-md bg-emerald-100 px-3 py-2 text-sm font-bold text-emerald-800">
            <CheckCircle2 className="h-4 w-4" />
            Ready to Go
          </div>
        ) : null}
      </div>
      <div className="mt-4 grid gap-3 md:grid-cols-3">
        {steps.map((step) => {
          const Icon = step.icon;
          const isComplete = completed || step.id < activeStep;
          const isActive = !completed && step.id === activeStep;

          return (
            <div
              key={step.id}
              className={`rounded-lg border px-4 py-3 ${
                isComplete
                  ? "border-emerald-200 bg-emerald-50"
                  : isActive
                    ? "border-ink bg-white shadow-sm"
                    : "border-white/80 bg-white/70"
              }`}
            >
              <div className="flex items-center gap-3">
                <div
                  className={`grid h-10 w-10 place-items-center rounded-md ${
                    isComplete ? "bg-emerald-600 text-white" : isActive ? "bg-ink text-white" : "bg-blue-50 text-slate-500"
                  }`}
                >
                  {isComplete ? <CheckCircle2 className="h-5 w-5" /> : <Icon className="h-5 w-5" />}
                </div>
                <div className="min-w-0">
                  <div className="text-sm font-bold text-ink">{step.label}</div>
                  <div className="text-xs text-slate-500">{isComplete ? "Done" : isActive ? "Current step" : "Coming up"}</div>
                </div>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
