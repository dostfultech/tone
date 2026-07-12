import { createOpenAIClient } from "../../../provider-clients";
import type { GenerateSongRequestDto, NormalizedMasterToneDraft } from "../dtos";
import { ingestionConfigError } from "../errors";
import { validateAiDraft } from "../validation";

const normalizedMasterToneSchema = {
  type: "object",
  additionalProperties: false,
  required: [
    "song",
    "artist",
    "part",
    "partType",
    "toneType",
    "mode",
    "gain",
    "bass",
    "middle",
    "treble",
    "presence",
    "resonance",
    "depth",
    "masterVolume",
    "noiseGate",
    "compression",
    "delay",
    "reverb",
    "tempoBpm",
    "suggestedAmpArchetype",
    "suggestedCabinetArchetype",
    "suggestedPedals",
    "pickupPreference",
    "toneArchetype",
    "eqProfile",
    "modulationProfile",
    "metadata",
    "sourceSummary",
    "confidence"
  ],
  properties: {
    song: { type: "string" },
    artist: { type: "string" },
    part: { type: "string" },
    partType: {
      type: "string",
      enum: ["intro", "verse", "chorus", "bridge", "solo", "lead", "rhythm", "riff", "breakdown", "outro", "clean"]
    },
    toneType: {
      type: "string",
      enum: [
        "auto_detect",
        "clean",
        "crunch",
        "edge_of_breakup",
        "classic_rock",
        "heavy",
        "high_gain",
        "metal",
        "modern_metal",
        "distorted",
        "fuzz",
        "ambient",
        "acoustic",
        "bass_clean",
        "bass_drive"
      ]
    },
    mode: { type: "string", enum: ["guitar", "bass"] },
    gain: { type: "number", minimum: 0, maximum: 10 },
    bass: { type: "number", minimum: 0, maximum: 10 },
    middle: { type: "number", minimum: 0, maximum: 10 },
    treble: { type: "number", minimum: 0, maximum: 10 },
    presence: { type: "number", minimum: 0, maximum: 10 },
    resonance: { type: "number", minimum: 0, maximum: 10 },
    depth: { type: "number", minimum: 0, maximum: 10 },
    masterVolume: { type: "number", minimum: 0, maximum: 10 },
    noiseGate: { type: "number", minimum: 0, maximum: 10 },
    compression: { type: "number", minimum: 0, maximum: 10 },
    delay: { type: "number", minimum: 0, maximum: 10 },
    reverb: { type: "number", minimum: 0, maximum: 10 },
    tempoBpm: { type: ["number", "null"] },
    suggestedAmpArchetype: { type: ["string", "null"] },
    suggestedCabinetArchetype: { type: ["string", "null"] },
    suggestedPedals: {
      type: "array",
      items: { type: "string" },
      maxItems: 12
    },
    pickupPreference: { type: ["string", "null"] },
    toneArchetype: { type: ["string", "null"] },
    eqProfile: {
      type: "object",
      additionalProperties: false,
      properties: {}
    },
    modulationProfile: {
      type: "object",
      additionalProperties: false,
      properties: {}
    },
    metadata: {
      type: "object",
      additionalProperties: false,
      properties: {}
    },
    sourceSummary: { type: "string" },
    confidence: { type: "integer", minimum: 0, maximum: 100 }
  }
};

export interface AiToneResearchProvider {
  generateMasterTone(request: GenerateSongRequestDto): Promise<NormalizedMasterToneDraft>;
  enrichMasterTone(draft: NormalizedMasterToneDraft): Promise<NormalizedMasterToneDraft>;
}

export class OpenAiToneResearchProvider implements AiToneResearchProvider {
  async generateMasterTone(request: GenerateSongRequestDto): Promise<NormalizedMasterToneDraft> {
    const client = createOpenAIClient();
    if (!client) {
      throw ingestionConfigError("OPENAI_API_KEY is required for AI ingestion.");
    }

    const model = process.env.AI_INGESTION_MODEL || process.env.OPENAI_MODEL || "gpt-4.1-nano";
    const completion = await client.chat.completions.create({
      model,
      temperature: 0.2,
      messages: [
        {
          role: "system",
          content:
            "You are Tonefex's ingestion-only tone researcher. Create normalized master tones, never amplifier-specific adaptations. Use cautious language, avoid lyrics, and return JSON only."
        },
        {
          role: "user",
          content: JSON.stringify({
            task: "Generate one normalized master tone for permanent database storage.",
            request,
            constraints: {
              knobScale: "0-10",
              noUserGearAdaptation: true,
              noCopyrightedLyrics: true,
              includeOnlyReusableMasterToneKnowledge: true,
              doNotClaimOfficialRigCertainty: true
            }
          })
        }
      ],
      response_format: {
        type: "json_schema",
        json_schema: {
          name: "tonefex_normalized_master_tone",
          strict: true,
          schema: normalizedMasterToneSchema
        }
      }
    } as never);

    const content = completion.choices[0]?.message?.content;
    if (!content) {
      throw ingestionConfigError("OpenAI returned an empty ingestion response.", { model });
    }

    return validateAiDraft(JSON.parse(content));
  }

  async enrichMasterTone(draft: NormalizedMasterToneDraft): Promise<NormalizedMasterToneDraft> {
    const enriched = await this.generateMasterTone({
      song: draft.song,
      artist: draft.artist,
      part: draft.part,
      partType: draft.partType,
      toneType: draft.toneType,
      mode: draft.mode,
      runImmediately: true,
      metadata: {
        existingDraft: draft,
        enrichmentTask: true
      }
    });

    return {
      ...draft,
      ...enriched,
      metadata: {
        ...draft.metadata,
        ...enriched.metadata,
        enrichedAt: new Date().toISOString()
      }
    };
  }
}
