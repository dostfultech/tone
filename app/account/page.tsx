import type { Metadata } from "next";
import { AppShell } from "@/components/app-shell";
import { AccountView } from "@/components/account-view";
import { buildPageMetadata } from "@/lib/seo";

export const metadata: Metadata = buildPageMetadata({
  title: "Account",
  description: "Manage subscription, profile details, and tone workspace settings.",
  path: "/account",
  noIndex: true
});

export default function AccountPage() {
  return (
    <AppShell>
      <AccountView />
    </AppShell>
  );
}
