import type { Metadata } from "next";
import { redirect } from "next/navigation";
import { AppShell } from "@/components/app-shell";
import { WelcomeView } from "@/components/welcome-view";
import { getEntitlement, getCurrentSession } from "@/lib/server-access";

export const metadata: Metadata = {
  title: "Welcome"
};

export default async function WelcomePage() {
  const { supabase, user } = await getCurrentSession();

  if (!user) {
    redirect("/signup");
  }

  const entitlement = await getEntitlement(supabase, user);
  if (entitlement.hasAccess) {
    redirect("/app");
  }

  return (
    <AppShell>
      <WelcomeView />
    </AppShell>
  );
}
