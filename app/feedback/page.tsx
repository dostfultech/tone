import type { Metadata } from "next";
import { redirect } from "next/navigation";
import { AppShell } from "@/components/app-shell";
import { ContactForm } from "@/components/contact-form";
import { FeedbackForm } from "@/components/feedback-form";
import { isEarlyTesterMode } from "@/lib/early-tester";
import { buildPageMetadata } from "@/lib/seo";
import { getCurrentSession } from "@/lib/server-access";

export const metadata: Metadata = buildPageMetadata({
  title: "Feedback",
  description: "Share product feedback and feature requests to improve tone matching quality.",
  path: "/feedback"
});

export default async function FeedbackPage() {
  if (!isEarlyTesterMode()) {
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

  const { user } = await getCurrentSession();
  if (!user) {
    redirect("/login?redirect=/feedback");
  }

  const userEmail = user.email || "";
  const userName = user.user_metadata?.full_name || user.user_metadata?.name || "";

  return (
    <AppShell>
      <FeedbackForm userEmail={userEmail} userName={userName} />
    </AppShell>
  );
}
