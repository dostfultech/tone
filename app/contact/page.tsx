import type { Metadata } from "next";
import { AppShell } from "@/components/app-shell";
import { ContactForm } from "@/components/contact-form";
import { buildPageMetadata } from "@/lib/seo";

export const metadata: Metadata = buildPageMetadata({
  title: "Request Gear",
  description: "Request new guitars, amps, pedals, or tone workflow features for the platform.",
  path: "/contact"
});

export default function ContactPage() {
  return (
    <AppShell>
      <section className="px-4 pb-14 pt-24 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-[1440px]">
          <div className="mb-10 text-center">
            <div className="mx-auto mb-5 grid h-14 w-14 place-items-center rounded-lg bg-ink text-moss">
              <span className="text-2xl">?</span>
            </div>
            <h1 className="text-4xl font-bold tracking-normal">Request a Feature</h1>
            <p className="mx-auto mt-4 max-w-2xl text-lg leading-8 text-neutral-600">Help us improve Tonefex by requesting amps, guitars, or other gear you want added to the app.</p>
          </div>
          <ContactForm mode="gear" />
        </div>
      </section>
    </AppShell>
  );
}
