import type { Metadata } from "next";
import { AppShell } from "@/components/app-shell";
import { ContactForm } from "@/components/contact-form";

export const metadata: Metadata = {
  title: "Contact"
};

export default function ContactPage() {
  return (
    <AppShell>
      <section className="px-4 pb-16 pt-28 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-[1840px]">
          <div className="mb-10 text-center">
            <div className="mx-auto mb-5 grid h-14 w-14 place-items-center rounded-lg bg-ink text-moss">
              <span className="text-2xl">?</span>
            </div>
            <h1 className="text-4xl font-bold tracking-normal">Send Feedback or Request Gear</h1>
            <p className="mx-auto mt-4 max-w-2xl text-lg leading-8 text-neutral-600">Tell us what to fix, improve, or add to the Tonefex gear database.</p>
          </div>
          <ContactForm />
        </div>
      </section>
    </AppShell>
  );
}
