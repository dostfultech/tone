import { getCurrentSession } from "@/lib/server-access";
import { ingestionAuthError, ingestionConfigError } from "./ai-ingestion/errors";

export interface AdminApiContext {
  userId: string | null;
  authType: "admin_user" | "worker_secret";
}

export async function requireAdminApiContext(request: Request): Promise<AdminApiContext> {
  const workerSecret = process.env.AI_INGESTION_WORKER_SECRET;
  const providedWorkerSecret = request.headers.get("x-tonefex-worker-secret");

  if (workerSecret && providedWorkerSecret && providedWorkerSecret === workerSecret) {
    return { userId: null, authType: "worker_secret" };
  }

  const { supabase, user } = await getCurrentSession();
  if (!supabase) {
    throw ingestionConfigError("Supabase auth is required for admin AI ingestion endpoints.");
  }
  if (!user) {
    throw ingestionAuthError("Authentication is required.");
  }

  const { data, error } = await supabase.from("profiles").select("role").eq("id", user.id).maybeSingle();
  if (error) {
    throw ingestionConfigError("Unable to verify admin role.", { error: error.message });
  }
  if (data?.role !== "admin") {
    throw ingestionAuthError();
  }

  return { userId: user.id, authType: "admin_user" };
}
