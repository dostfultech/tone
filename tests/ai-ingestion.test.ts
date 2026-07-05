import test from "node:test";
import assert from "node:assert/strict";
import { AiIngestionService } from "../lib/backend/ai-ingestion/services/ingestion-service";
import { AiIngestionWorkerService } from "../lib/backend/ai-ingestion/services/worker-service";
import { CachePrewarmService } from "../lib/backend/ai-ingestion/services/cache-prewarm-service";
import type { EmbeddingService } from "../lib/backend/ai-ingestion/services/embedding-service";
import type { AiToneResearchProvider } from "../lib/backend/ai-ingestion/services/openai-ingestion-provider";
import type { JobRepository } from "../lib/backend/ai-ingestion/repositories/job-repository";
import type { MasterToneRepository } from "../lib/backend/ai-ingestion/repositories/master-tone-repository";
import type { IngestionJob, NormalizedMasterToneDraft } from "../lib/backend/ai-ingestion/dtos";
import type { ToneAdaptationResponseDto } from "../lib/backend/tone-adaptation/dtos";

test("generate-song queues by default without calling AI", async () => {
  const harness = createHarness();

  const response = await harness.ingestionService.generateSong(
    {
      song: "Enter Sandman",
      artist: "Metallica",
      part: "Riff",
      partType: "riff",
      toneType: "metal",
      mode: "guitar"
    },
    "admin-1"
  );

  assert.equal(response.action, "generate-song");
  assert.equal(response.job?.jobType, "song_generation");
  assert.equal(harness.aiCalls, 0);
  assert.equal(harness.jobs.length, 1);
});

test("runImmediately generates AI knowledge once and stores a master tone", async () => {
  const harness = createHarness();

  const response = await harness.ingestionService.generateSong(
    {
      song: "Enter Sandman",
      artist: "Metallica",
      part: "Riff",
      partType: "riff",
      toneType: "metal",
      mode: "guitar",
      runImmediately: true
    },
    "admin-1"
  );

  assert.equal(response.masterTone?.masterToneId, "master-1");
  assert.equal(harness.aiCalls, 1);
  assert.equal(harness.storedDrafts.length, 1);
});

test("worker processes song generation as database ingestion only", async () => {
  const harness = createHarness({
    initialJobs: [
      {
        id: "job-1",
        jobType: "song_generation",
        status: "queued",
        payload: {
          song: "Paranoid",
          artist: "Black Sabbath",
          part: "Riff",
          partType: "riff",
          toneType: "classic_rock",
          mode: "guitar"
        },
        result: {},
        attempts: 0,
        maxAttempts: 3,
        requestedBy: "admin-1"
      }
    ]
  });

  const response = await harness.workerService.run({ workerId: "worker-1", limit: 1 });

  assert.equal(response.claimed, 1);
  assert.equal(harness.aiCalls, 1);
  assert.equal(harness.succeededJobs[0].result.aiScope, "database_ingestion_only");
});

test("cache prewarming uses deterministic tone service and reports no AI", async () => {
  let adaptCalls = 0;
  const prewarmer = new CachePrewarmService({
    async adaptTone(): Promise<ToneAdaptationResponseDto> {
      adaptCalls += 1;
      return {
        requestId: "request-1",
        result: {} as ToneAdaptationResponseDto["result"],
        source: {
          event: "tone_backend_adaptation_complete",
          endpoint: "/api/v1/tones/adapt",
          requestId: "request-1",
          finalSource: "DATABASE_CACHE",
          cacheStatus: "hit",
          cacheHit: true,
          cacheMiss: false,
          cacheWrite: "not_attempted",
          databaseTimeMs: 1,
          ruleEngineTimeMs: 0,
          responseTimeMs: 2,
          cacheKey: "cache-1",
          aiUsed: false,
          openAiCalled: false
        },
        masterTone: {
          id: "master-1",
          song: "Song",
          artist: "Artist",
          part: "Riff",
          partType: "riff",
          toneType: "metal",
          version: 1,
          confidence: 80,
          sourceType: "master_tones"
        },
        gear: {
          pickups: [],
          pedals: [],
          goingDirect: false
        }
      };
    }
  });

  const response = await prewarmer.prewarm({
    requests: [
      {
        song: "Song",
        artist: "Artist",
        part: "Riff",
        toneType: "metal",
        mode: "guitar",
        guitar: "Fender Stratocaster"
      }
    ]
  });

  assert.equal(response.aiUsed, false);
  assert.equal(response.prewarmed, 1);
  assert.equal(adaptCalls, 1);
});

function createHarness(options: { initialJobs?: IngestionJob[] } = {}) {
  let aiCalls = 0;
  const jobs = [...(options.initialJobs ?? [])];
  const storedDrafts: NormalizedMasterToneDraft[] = [];
  const succeededJobs: Array<{ jobId: string; result: Record<string, unknown> }> = [];

  const jobRepository: JobRepository = {
    async enqueue(input) {
      const job: IngestionJob = {
        id: `job-${jobs.length + 1}`,
        jobType: input.jobType,
        status: "queued",
        payload: input.payload,
        result: {},
        attempts: 0,
        maxAttempts: 3,
        requestedBy: input.requestedBy
      };
      jobs.push(job);
      return job;
    },
    async claimQueuedJobs(input) {
      return jobs
        .filter((job) => job.status === "queued" && (!input.jobTypes?.length || input.jobTypes.includes(job.jobType)))
        .slice(0, input.limit)
        .map((job) => {
          job.status = "running";
          job.attempts += 1;
          return job;
        });
    },
    async markSucceeded(jobId, result) {
      succeededJobs.push({ jobId, result });
    },
    async markFailed() {},
    async addEvent() {}
  };

  const masterToneRepository: MasterToneRepository = {
    async storeDraft(draft) {
      storedDrafts.push(draft);
      return {
        artistId: "artist-1",
        songId: "song-1",
        songPartId: "part-1",
        masterToneId: "master-1",
        version: 1
      };
    },
    async updateMasterTone() {
      return {
        artistId: "artist-1",
        songId: "song-1",
        songPartId: "part-1",
        masterToneId: "master-1",
        version: 1
      };
    },
    async softDeleteMasterTone() {},
    async approveMasterTone() {},
    async rejectMasterTone() {},
    async enrichMetadata() {},
    async findGearMatches() {
      return { guitars: [], amps: [], cabinets: [], pedals: [], multiFx: [] };
    }
  };

  const aiProvider: AiToneResearchProvider = {
    async generateMasterTone(request) {
      aiCalls += 1;
      return draft({
        song: request.song,
        artist: request.artist,
        part: request.part ?? "Riff",
        toneType: (request.toneType ?? "metal") as NormalizedMasterToneDraft["toneType"]
      });
    },
    async enrichMasterTone(value) {
      aiCalls += 1;
      return value;
    }
  };

  const embeddingService: EmbeddingService = {
    async embedMasterTone() {
      return null;
    }
  };

  const ingestionService = new AiIngestionService({
    jobRepository,
    masterToneRepository,
    aiProvider,
    embeddingService,
    logger: silentLogger
  });
  const workerService = new AiIngestionWorkerService({
    jobRepository,
    masterToneRepository,
    ingestionService,
    cachePrewarmService: new CachePrewarmService({
      async adaptTone() {
        throw new Error("not used");
      }
    }),
    logger: silentLogger
  });

  return {
    ingestionService,
    workerService,
    jobs,
    storedDrafts,
    succeededJobs,
    get aiCalls() {
      return aiCalls;
    }
  };
}

function draft(overrides: Partial<NormalizedMasterToneDraft> = {}): NormalizedMasterToneDraft {
  return {
    song: "Song",
    artist: "Artist",
    part: "Riff",
    partType: "riff",
    toneType: "metal",
    mode: "guitar",
    gain: 7,
    bass: 6,
    middle: 5,
    treble: 6,
    presence: 5,
    resonance: 4,
    depth: 4,
    masterVolume: 5,
    noiseGate: 3,
    compression: 2,
    delay: 1,
    reverb: 2,
    tempoBpm: 120,
    suggestedAmpArchetype: "british_high_gain",
    suggestedCabinetArchetype: "closed_back_4x12",
    suggestedPedals: ["noise_gate", "overdrive"],
    pickupPreference: "bridge humbucker",
    toneArchetype: "tight high gain",
    eqProfile: {},
    modulationProfile: {},
    metadata: {},
    sourceSummary: "Test source summary.",
    confidence: 80,
    ...overrides
  };
}

const silentLogger = {
  info() {},
  warn() {},
  error() {}
};
