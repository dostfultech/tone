import type {
  AdminIngestionResponse,
  GenerateSongRequestDto,
  IngestionJob,
  NormalizedMasterToneDraft,
  RegenerateSongRequestDto,
  StoredMasterTone,
  UpdateMasterToneRequestDto
} from "../dtos";
import type { AiIngestionLogger } from "../logging";
import { consoleAiIngestionLogger } from "../logging";
import type { JobRepository } from "../repositories/job-repository";
import type { MasterToneRepository } from "../repositories/master-tone-repository";
import type { AiToneResearchProvider } from "./openai-ingestion-provider";
import type { EmbeddingService } from "./embedding-service";

export interface AiIngestionServiceDependencies {
  jobRepository: JobRepository;
  masterToneRepository: MasterToneRepository;
  aiProvider: AiToneResearchProvider;
  embeddingService: EmbeddingService;
  logger?: AiIngestionLogger;
}

export class AiIngestionService {
  private readonly logger: AiIngestionLogger;

  constructor(private readonly dependencies: AiIngestionServiceDependencies) {
    this.logger = dependencies.logger ?? consoleAiIngestionLogger;
  }

  async generateSong(request: GenerateSongRequestDto, requestedBy: string | null): Promise<AdminIngestionResponse> {
    if (!request.runImmediately) {
      const job = await this.dependencies.jobRepository.enqueue({
        jobType: "song_generation",
        payload: request as unknown as Record<string, unknown>,
        priority: request.priority,
        requestedBy
      });
      return { ok: true, action: "generate-song", job };
    }

    const masterTone = await this.generateAndStore(request, { requestedBy, regenerate: false });
    return { ok: true, action: "generate-song", masterTone };
  }

  async regenerateSong(request: RegenerateSongRequestDto, requestedBy: string | null): Promise<AdminIngestionResponse> {
    if (!request.runImmediately) {
      const job = await this.dependencies.jobRepository.enqueue({
        jobType: "song_generation",
        payload: {
          ...request,
          regenerate: true
        },
        priority: request.priority,
        requestedBy
      });
      return { ok: true, action: "regenerate-song", job };
    }

    const masterTone = await this.generateAndStore(request, { requestedBy, regenerate: true });
    return { ok: true, action: "regenerate-song", masterTone };
  }

  async updateMasterTone(request: UpdateMasterToneRequestDto): Promise<AdminIngestionResponse> {
    const masterTone = await this.dependencies.masterToneRepository.updateMasterTone(
      request.masterToneId,
      request.patch,
      request.reason
    );
    return { ok: true, action: "update-master-tone", masterTone };
  }

  async deleteTone(masterToneId: string, reason?: string): Promise<AdminIngestionResponse> {
    await this.dependencies.masterToneRepository.softDeleteMasterTone(masterToneId, reason);
    return { ok: true, action: "delete-tone", result: { masterToneId, deleted: true } };
  }

  async approveTone(masterToneId: string, reviewedBy: string | null, reason?: string, metadata: Record<string, unknown> = {}) {
    await this.dependencies.masterToneRepository.approveMasterTone(masterToneId, reviewedBy, reason, metadata);
    return { ok: true, action: "approve-tone", result: { masterToneId, approved: true } };
  }

  async rejectTone(masterToneId: string, reviewedBy: string | null, reason?: string, metadata: Record<string, unknown> = {}) {
    await this.dependencies.masterToneRepository.rejectMasterTone(masterToneId, reviewedBy, reason, metadata);
    return { ok: true, action: "reject-tone", result: { masterToneId, rejected: true } };
  }

  async generateAndStore(
    request: GenerateSongRequestDto,
    options: { requestedBy?: string | null; regenerate?: boolean } = {}
  ): Promise<StoredMasterTone> {
    this.logger.info("ai_generation_started", {
      song: request.song,
      artist: request.artist,
      part: request.part,
      runContext: "admin_ingestion_only"
    });

    const draft = await this.dependencies.aiProvider.generateMasterTone(request);
    const embedding = await this.dependencies.embeddingService.embedMasterTone(draft);
    const stored = await this.dependencies.masterToneRepository.storeDraft(draft, {
      regenerate: options.regenerate,
      embedding,
      requestedBy: options.requestedBy
    });

    this.logger.info("ai_generation_stored", {
      masterToneId: stored.masterToneId,
      version: stored.version,
      aiUsedForUserRequest: false
    });

    return stored;
  }

  async enrichMasterTone(draft: NormalizedMasterToneDraft, masterToneId: string) {
    const enriched = await this.dependencies.aiProvider.enrichMasterTone(draft);
    const embedding = await this.dependencies.embeddingService.embedMasterTone(enriched);
    await this.dependencies.masterToneRepository.enrichMetadata(masterToneId, {
      aiEnrichment: enriched.metadata,
      embedding: embedding ?? undefined
    });
    return enriched;
  }
}
