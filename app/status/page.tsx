import type { Metadata } from "next";
import { Activity, CheckCircle2, Clock, Database, Server, Zap } from "lucide-react";
import { SiteShell } from "@/components/site-shell";

export const metadata: Metadata = {
  title: "System Status"
};

const systems = [
  { name: "Web app", detail: "Next.js route handlers and UI", icon: Server },
  { name: "Tone generation", detail: "OpenAI structured adaptation pipeline", icon: Zap },
  { name: "Database", detail: "Local/Supabase-compatible data model", icon: Database },
  { name: "Billing", detail: "Dodo Payments checkout and webhook sync", icon: Activity }
];

export default function StatusPage() {
  return (
    <SiteShell>
      <section className="section grid min-h-[calc(100vh-4rem)] items-center py-16">
        <div className="mx-auto max-w-4xl text-center">
        <div className="mx-auto mb-6 flex h-16 w-16 items-center justify-center rounded-lg bg-ink text-moss">
            <CheckCircle2 className="h-9 w-9" />
          </div>
          <h1 className="text-4xl font-semibold tracking-normal sm:text-5xl">System Status</h1>
          <p className="mt-4 text-lg text-neutral-600">All local systems are operational and ready to match tones.</p>
          <div className="mt-10 grid gap-4 md:grid-cols-2">
            {systems.map((system) => {
              const Icon = system.icon;
              return (
                <div key={system.name} className="compact-card flex items-center gap-4 p-5 text-left">
                  <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-md bg-neutral-100 text-ocean">
                    <Icon className="h-5 w-5" />
                  </div>
                  <div>
                    <h2 className="font-semibold">{system.name}</h2>
                    <p className="mt-1 text-sm text-neutral-600">{system.detail}</p>
                  </div>
            <span className="ml-auto rounded-md bg-moss px-2 py-1 text-xs font-semibold text-ink">
                    Online
                  </span>
                </div>
              );
            })}
          </div>
          <div className="mt-8 inline-flex items-center gap-2 rounded-md bg-white px-4 py-2 text-sm text-neutral-600 shadow-sm">
            <Clock className="h-4 w-4" />
            Last checked locally in your browser session
          </div>
        </div>
      </section>
    </SiteShell>
  );
}
