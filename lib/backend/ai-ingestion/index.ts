import type { SupabaseClient } from "@supabase/supabase-js";
import { createToneAdaptationService } from "../tone-adaptation";
import { AdminIngestionController } from "./controllers/admin-ingestion-controller";
import { SupabaseJobRepository } from "./repositories/job-repository";
import { SupabaseMasterToneRepository } from "./repositories/master-tone-repository";
import { CachePrewarmService } from "./services/cache-prewarm-service";
import { OpenAiEmbeddingService } from "./services/embedding-service";
import { AiIngestionService } from "./services/ingestion-service";
import { OpenAiToneResearchProvider } from "./services/openai-ingestion-provider";
import { AiIngestionWorkerService } from "./services/worker-service";
import type { AiIngestionLogger } from "./logging";

export function createAdminIngestionController(supabase: SupabaseClient, logger?: AiIngestionLogger) {
  const jobRepository = new SupabaseJobRepository(supabase);
  const masterToneRepository = new SupabaseMasterToneRepository(supabase);
  const ingestionService = new AiIngestionService({
    jobRepository,
    masterToneRepository,
    aiProvider: new OpenAiToneResearchProvider(),
    embeddingService: new OpenAiEmbeddingService(),
    logger
  });
  const workerService = new AiIngestionWorkerService({
    jobRepository,
    masterToneRepository,
    ingestionService,
    cachePrewarmService: new CachePrewarmService(createToneAdaptationService(supabase)),
    logger
  });

  return new AdminIngestionController(ingestionService, workerService, logger);
}

export * from "./dtos";
export * from "./errors";
export * from "./logging";
export * from "./repositories/job-repository";
export * from "./repositories/master-tone-repository";
export * from "./services/cache-prewarm-service";
export * from "./services/embedding-service";
export * from "./services/ingestion-service";
export * from "./services/openai-ingestion-provider";
export * from "./services/worker-service";
export * from "./validation";
