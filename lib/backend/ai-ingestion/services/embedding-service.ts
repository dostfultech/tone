import { createOpenAIClient } from "@/lib/provider-clients";
import type { NormalizedMasterToneDraft } from "../dtos";
import { ingestionConfigError } from "../errors";

export interface EmbeddingService {
  embedMasterTone(draft: NormalizedMasterToneDraft): Promise<number[] | null>;
}

export class OpenAiEmbeddingService implements EmbeddingService {
  async embedMasterTone(draft: NormalizedMasterToneDraft) {
    if (process.env.AI_INGESTION_EMBEDDINGS_ENABLED !== "true") {
      return null;
    }

    const client = createOpenAIClient();
    if (!client) {
      throw ingestionConfigError("OPENAI_API_KEY is required when AI_INGESTION_EMBEDDINGS_ENABLED=true.");
    }

    const model = process.env.OPENAI_EMBEDDING_MODEL || "text-embedding-3-small";
    const response = await client.embeddings.create({
      model,
      input: [
        draft.song,
        draft.artist,
        draft.part,
        draft.toneType,
        draft.mode,
        draft.sourceSummary,
        draft.suggestedPedals.join(" ")
      ].join(" | ")
    });

    return response.data[0]?.embedding ?? null;
  }
}

export class NoopEmbeddingService implements EmbeddingService {
  async embedMasterTone() {
    return null;
  }
}
