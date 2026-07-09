import type { Metadata } from "next";
import { AppShell } from "@/components/app-shell";
import { ContactForm } from "@/components/contact-form";

export const metadata: Metadata = {
  title: "Feedback"
};

export default function FeedbackPage() {
  return (
    <AppShell>
      <section className="px-4 pb-14 pt-24 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-[1440px]">
          <div className="mb-10 text-center">
            <div className="mx-auto mb-5 grid h-14 w-14 place-items-center rounded-lg bg-ink text-moss">
              <span className="text-2xl">?</span>
            </div>
            <h1 className="text-4xl font-bold tracking-normal">Send Feedback</h1>
            <p className="mx-auto mt-4 max-w-2xl text-lg leading-8 text-neutral-600">Help us make Tonefex better. Every piece of feedback is read.</p>
          </div>
          <ContactForm mode="feedback" />
        </div>
      </section>
    </AppShell>
  );
}
