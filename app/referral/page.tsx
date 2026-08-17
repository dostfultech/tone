import type { Metadata } from "next";
import { redirect } from "next/navigation";
import { AppShell } from "@/components/app-shell";
import { ReferralPanel } from "@/components/referral-panel";
import { getSiteUrl } from "@/lib/env";
import { computeReferralCode } from "@/lib/referral";
import { buildPageMetadata } from "@/lib/seo";
import { getCurrentSession } from "@/lib/server-access";
import { createSupabaseAdminClient } from "@/lib/supabase/admin";

export const metadata: Metadata = buildPageMetadata({
  title: "Invite & Earn",
  description: "Invite guitarists to Tonefex and track who joins.",
  path: "/referral",
  noIndex: true
});

export default async function ReferralPage() {
  const { user } = await getCurrentSession();
  if (!user) {
    redirect("/login?redirect=/referral");
  }

  const admin = createSupabaseAdminClient();
  let code = computeReferralCode(user.id);
  let referredCount = 0;
  let subscribedCount = 0;

  if (admin) {
    const { data: me } = await admin.from("profiles").select("referral_code").eq("id", user.id).maybeSingle();
    if (me?.referral_code) {
      code = me.referral_code;
    } else {
      // Lazy-store a code for accounts created before the backfill / by an older path.
      await admin.from("profiles").update({ referral_code: code }).eq("id", user.id).is("referral_code", null);
    }

    const { data: referred } = await admin.from("profiles").select("id").eq("referred_by", user.id);
    const referredIds = (referred ?? []).map((row) => row.id as string);
    referredCount = referredIds.length;

    if (referredIds.length > 0) {
      const { data: subs } = await admin
        .from("subscriptions")
        .select("user_id, trial_end")
        .in("user_id", referredIds)
        .eq("status", "active")
        .in("plan_id", ["beginner", "expert"]);
      // Only count genuinely PAID subscribers: active AND past the trial (or no trial). A
      // trial-then-cancel never reaches a real payment, so it never counts here.
      const now = Date.now();
      const paid = (subs ?? []).filter((row) => !row.trial_end || new Date(row.trial_end as string).getTime() <= now);
      subscribedCount = new Set(paid.map((row) => row.user_id as string)).size;
    }
  }

  const link = `${getSiteUrl().replace(/\/$/, "")}/?ref=${code}`;

  return (
    <AppShell>
      <ReferralPanel link={link} code={code} referredCount={referredCount} subscribedCount={subscribedCount} />
    </AppShell>
  );
}
