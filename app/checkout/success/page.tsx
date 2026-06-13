import Link from "next/link";
import { CheckCircle2 } from "lucide-react";
import { SiteShell } from "@/components/site-shell";

export default function CheckoutSuccessPage() {
  return (
    <SiteShell>
      <section className="section grid min-h-[calc(100vh-4rem)] place-items-center py-16 text-center">
        <div className="max-w-xl">
          <CheckCircle2 className="mx-auto mb-5 h-16 w-16 text-moss" />
          <h1 className="text-4xl font-semibold tracking-normal">Checkout received</h1>
          <p className="mt-4 leading-7 text-neutral-600">
            Your payment provider will confirm the subscription through a webhook. If your app access does not unlock immediately in local testing, use TEST_ACCESS_EMAILS while you finish Dodo setup.
          </p>
          <div className="mt-8 flex flex-col justify-center gap-3 sm:flex-row">
            <Link href="/app" className="button-primary">
              Open app
            </Link>
            <Link href="/account" className="button-secondary">
              Account
            </Link>
          </div>
        </div>
      </section>
    </SiteShell>
  );
}
