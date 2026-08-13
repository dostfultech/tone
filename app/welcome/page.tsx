import type { Metadata } from "next";
import { redirect } from "next/navigation";
import { EARLY_TESTER_FREE_ADAPTATIONS, isEarlyTesterMode } from "@/lib/early-tester";
import { getEntitlement, getCurrentSession } from "@/lib/server-access";
import { buildPageMetadata } from "@/lib/seo";

export const metadata: Metadata = buildPageMetadata({
  title: "Welcome",
  description: "Finish setup and start adapting tones with your saved gear profile.",
  path: "/welcome",
  noIndex: true
});

// Analytics (2026-08): the old welcome interstitial (a re-pitch + "Get Started" button) bounced
// ~85% of new signups — they'd just signed up and hit ANOTHER marketing wall before reaching the
// app. So this now grants the free adaptations and drops the player straight into /app. The grant
// is idempotent (guarded on welcome_completed_at) so it only fires once.
export default async function WelcomePage() {
  const { supabase, user } = await getCurrentSession();

  if (!user) {
    redirect("/signup");
  }

  const entitlement = await getEntitlement(supabase, user);
  if (entitlement.hasAccess) {
    redirect("/app");
  }

  if (supabase) {
    const updates: Record<string, unknown> = { welcome_completed_at: new Date().toISOString() };
    if (isEarlyTesterMode()) {
      updates.free_adaptation_limit = EARLY_TESTER_FREE_ADAPTATIONS;
    }
    await supabase.from("profiles").update(updates).eq("id", user.id).is("welcome_completed_at", null);
  }

  redirect("/app?welcome=1");
}
