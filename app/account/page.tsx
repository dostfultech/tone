import type { Metadata } from "next";
import { AppShell } from "@/components/app-shell";
import { AccountView } from "@/components/account-view";

export const metadata: Metadata = {
  title: "Account"
};

export default function AccountPage() {
  return (
    <AppShell>
      <AccountView />
    </AppShell>
  );
}
