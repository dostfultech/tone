import type { GenerateSongRequestDto, IngestionJob, WorkerRunRequestDto } from "../dtos";
import type { AiIngestionLogger } from "../logging";
import { consoleAiIngestionLogger } from "../logging";
import type { JobRepository } from "../repositories/job-repository";
import type { MasterToneRepository } from "../repositories/master-tone-repository";
import { validateAiDraft, validateGenerateSongRequest } from "../validation";
import type { AiIngestionService } from "./ingestion-service";
import type { CachePrewarmService } from "./cache-prewarm-service";

export interface WorkerServiceDependencies {
  jobRepository: JobRepository;
  masterToneRepository: MasterToneRepository;
  ingestionService: AiIngestionService;
  cachePrewarmService: CachePrewarmService;
  logger?: AiIngestionLogger;
}

export class AiIngestionWorkerService {
  private readonly logger: AiIngestionLogger;

  constructor(private readonly dependencies: WorkerServiceDependencies) {
    this.logger = dependencies.logger ?? consoleAiIngestionLogger;
  }

  async run(request: WorkerRunRequestDto) {
    const jobs = await this.dependencies.jobRepository.claimQueuedJobs({
      workerId: request.workerId ?? "worker",
      limit: request.limit ?? 5,
      jobTypes: request.jobTypes
    });

    const results = [];
    for (const job of jobs) {
      results.push(await this.processJob(job));
    }

    return {
      claimed: jobs.length,
      results
    };
  }

  private async processJob(job: IngestionJob) {
    try {
      await this.dependencies.jobRepository.addEvent(job.id, "processing", `Processing ${job.jobType}.`);
      const result = await this.executeJob(job);
      await this.dependencies.jobRepository.markSucceeded(job.id, result);
      return { jobId: job.id, status: "succeeded", result };
    } catch (error) {
      const message = error instanceof Error ? error.message : "Unknown ingestion worker error";
      const retry = job.attempts < job.maxAttempts;
      await this.dependencies.jobRepository.markFailed(job.id, message, retry);
      this.logger.error("job_failed", { jobId: job.id, jobType: job.jobType, retry, message });
      return { jobId: job.id, status: retry ? "retry_queued" : "failed", error: message };
    }
  }

  private async executeJob(job: IngestionJob): Promise<Record<string, unknown>> {
    if (job.jobType === "song_generation") {
      const request = validateGenerateSongRequest({
        ...job.payload,
        runImmediately: true
      }) as GenerateSongRequestDto;
      const stored = await this.dependencies.ingestionService.generateAndStore(request, {
        requestedBy: job.requestedBy,
        regenerate: job.payload.regenerate === true
      });
      return { stored, aiUsed: true, aiScope: "database_ingestion_only" };
    }

    if (job.jobType === "metadata_enrichment") {
      const draft = validateAiDraft(job.payload.draft);
      const masterToneId = typeof job.payload.masterToneId === "string" ? job.payload.masterToneId : "";
      const enriched = await this.dependencies.ingestionService.enrichMasterTone(draft, masterToneId);
      return { enriched, aiUsed: true, aiScope: "database_ingestion_only" };
    }

    if (job.jobType === "gear_matching") {
      const query = typeof job.payload.query === "string" ? job.payload.query : "";
      const matches = await this.dependencies.masterToneRepository.findGearMatches(query);
      return { matches, aiUsed: false };
    }

    if (job.jobType === "cache_prewarming") {
      return this.dependencies.cachePrewarmService.prewarm(job.payload);
    }

    return { skipped: true };
  }
}
