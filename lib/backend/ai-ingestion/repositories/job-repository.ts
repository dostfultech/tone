import type { SupabaseClient } from "@supabase/supabase-js";
import type { IngestionJob, IngestionJobType } from "../dtos";
import { ingestionDatabaseError } from "../errors";

export interface JobRepository {
  enqueue(input: {
    jobType: IngestionJobType;
    payload: Record<string, unknown>;
    priority?: number;
    requestedBy?: string | null;
  }): Promise<IngestionJob>;
  claimQueuedJobs(input: { workerId: string; limit: number; jobTypes?: IngestionJobType[] }): Promise<IngestionJob[]>;
  markSucceeded(jobId: string, result: Record<string, unknown>): Promise<void>;
  markFailed(jobId: string, errorMessage: string, retry: boolean): Promise<void>;
  addEvent(jobId: string, eventType: string, message?: string, metadata?: Record<string, unknown>): Promise<void>;
}

export class SupabaseJobRepository implements JobRepository {
  constructor(private readonly supabase: SupabaseClient) {}

  async enqueue(input: {
    jobType: IngestionJobType;
    payload: Record<string, unknown>;
    priority?: number;
    requestedBy?: string | null;
  }) {
    const { data, error } = await this.supabase
      .from("ai_ingestion_jobs")
      .insert({
        job_type: input.jobType,
        payload: input.payload,
        priority: input.priority ?? 100,
        requested_by: input.requestedBy ?? null,
        status: "queued"
      })
      .select("*")
      .single();

    if (error) {
      throw ingestionDatabaseError("Failed to enqueue AI ingestion job.", { error: error.message });
    }

    const job = mapJob(data);
    await this.addEvent(job.id, "queued", "Job queued.", { jobType: input.jobType });
    return job;
  }

  async claimQueuedJobs(input: { workerId: string; limit: number; jobTypes?: IngestionJobType[] }) {
    let query = this.supabase
      .from("ai_ingestion_jobs")
      .select("*")
      .eq("status", "queued")
      .order("priority", { ascending: true })
      .order("created_at", { ascending: true })
      .limit(input.limit);

    if (input.jobTypes?.length) {
      query = query.in("job_type", input.jobTypes);
    }

    const { data, error } = await query;
    if (error) {
      throw ingestionDatabaseError("Failed to claim queued AI ingestion jobs.", { error: error.message });
    }

    const claimed: IngestionJob[] = [];
    for (const row of data ?? []) {
      const job = mapJob(row);
      const { data: updated, error: updateError } = await this.supabase
        .from("ai_ingestion_jobs")
        .update({
          status: "running",
          attempts: job.attempts + 1,
          locked_by: input.workerId,
          locked_at: new Date().toISOString(),
          started_at: new Date().toISOString(),
          error_message: null
        })
        .eq("id", job.id)
        .eq("status", "queued")
        .select("*")
        .maybeSingle();

      if (updateError) {
        throw ingestionDatabaseError("Failed to lock AI ingestion job.", { error: updateError.message, jobId: job.id });
      }

      if (updated) {
        const locked = mapJob(updated);
        claimed.push(locked);
        await this.addEvent(locked.id, "running", "Job claimed by worker.", { workerId: input.workerId });
      }
    }

    return claimed;
  }

  async markSucceeded(jobId: string, result: Record<string, unknown>) {
    const { error } = await this.supabase
      .from("ai_ingestion_jobs")
      .update({
        status: "succeeded",
        result,
        error_message: null,
        finished_at: new Date().toISOString()
      })
      .eq("id", jobId);

    if (error) {
      throw ingestionDatabaseError("Failed to mark AI ingestion job succeeded.", { error: error.message, jobId });
    }

    await this.addEvent(jobId, "succeeded", "Job completed.", result);
  }

  async markFailed(jobId: string, errorMessage: string, retry: boolean) {
    const { error } = await this.supabase
      .from("ai_ingestion_jobs")
      .update({
        status: retry ? "queued" : "failed",
        error_message: errorMessage,
        locked_by: null,
        locked_at: null,
        finished_at: retry ? null : new Date().toISOString()
      })
      .eq("id", jobId);

    if (error) {
      throw ingestionDatabaseError("Failed to mark AI ingestion job failed.", { error: error.message, jobId });
    }

    await this.addEvent(jobId, retry ? "retry_queued" : "failed", errorMessage, { retry });
  }

  async addEvent(jobId: string, eventType: string, message?: string, metadata: Record<string, unknown> = {}) {
    const { error } = await this.supabase.from("ai_ingestion_job_events").insert({
      job_id: jobId,
      event_type: eventType,
      message: message ?? null,
      metadata
    });

    if (error) {
      throw ingestionDatabaseError("Failed to write AI ingestion job event.", { error: error.message, jobId, eventType });
    }
  }
}

function mapJob(row: Record<string, unknown>): IngestionJob {
  return {
    id: stringField(row, "id"),
    jobType: stringField(row, "job_type") as IngestionJobType,
    status: stringField(row, "status") as IngestionJob["status"],
    payload: recordField(row.payload),
    result: recordField(row.result),
    attempts: numberField(row.attempts),
    maxAttempts: numberField(row.max_attempts, 3),
    requestedBy: typeof row.requested_by === "string" ? row.requested_by : null
  };
}

function recordField(value: unknown) {
  return typeof value === "object" && value !== null && !Array.isArray(value) ? (value as Record<string, unknown>) : {};
}

function stringField(row: Record<string, unknown>, key: string) {
  return typeof row[key] === "string" ? row[key] : "";
}

function numberField(value: unknown, fallback = 0) {
  if (typeof value === "number" && Number.isFinite(value)) {
    return value;
  }
  return fallback;
}
