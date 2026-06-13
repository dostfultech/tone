import { NextResponse } from "next/server";
import { getCurrentSession } from "@/lib/server-access";
import { createSupabaseAdminClient } from "@/lib/supabase/admin";

export async function POST() {
  const { user } = await getCurrentSession();
  if (!user) {
    return NextResponse.json({ error: "Authentication required" }, { status: 401 });
  }

  const admin = createSupabaseAdminClient();
  if (!admin) {
    return NextResponse.json({ error: "SUPABASE_SERVICE_ROLE_KEY is required for account deletion." }, { status: 503 });
  }

  await admin.from("admin_audit_logs").insert({
    actor_id: user.id,
    action: "account_delete_requested",
    target_table: "profiles",
    target_id: user.id
  });

  const { error } = await admin.auth.admin.deleteUser(user.id);
  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }

  return NextResponse.json({ deleted: true, message: "Account deleted." });
}
