import { buildToneResult, type ToneRequest } from "@/lib/mock-data";
import { createOpenAIClient } from "@/lib/provider-clients";
import type { ToneProfile } from "@/lib/tone-profiles";

export type GeneratedToneResult = ReturnType<typeof buildToneResult>;
export type ToneAiGeneration = {
  result: GeneratedToneResult;
  source: "openai" | "local_fallback";
  model: string | null;
  reason?: "missing_openai_client" | "empty_openai_response" | "openai_error";
};

const toneResultSchema = {
  type: "object",
  additionalProperties: false,
  required: ["accuracy", "originalRig", "targetSettings", "pickupAdvice", "effects", "playingTips"],
  properties: {
    accuracy: { type: "integer", minimum: 0, maximum: 100 },
    originalRig: { type: "string" },
    targetSettings: {
      type: "object",
      additionalProperties: { type: "number" }
    },
    pickupAdvice: { type: "string" },
    effects: {
      type: "array",
      items: { type: "string" },
      minItems: 1,
      maxItems: 8
    },
    playingTips: {
      type: "array",
      items: { type: "string" },
      minItems: 1,
      maxItems: 8
    }
  }
};

export async function generateToneResult(request: ToneRequest, toneProfile?: ToneProfile | null): Promise<GeneratedToneResult> {
  return (await generateToneResultWithMetadata(request, toneProfile)).result;
}

export async function generateToneResultWithMetadata(request: ToneRequest, toneProfile?: ToneProfile | null): Promise<ToneAiGeneration> {
  const fallback = buildToneResult(request, toneProfile);
  const client = createOpenAIClient();
  const model = process.env.OPENAI_MODEL || "gpt-4.1-nano";
  if (!client) {
    console.info("[tonefex:ai]", {
      event: "skipped_openai_missing_client",
      source: "local_fallback",
      song: request.song,
      artist: request.artist,
      mode: request.mode
    });
    return { result: fallback, source: "local_fallback", model: null, reason: "missing_openai_client" };
  }

  try {
    console.info("[tonefex:ai]", {
      event: "calling_openai",
      source: "openai",
      model,
      song: request.song,
      artist: request.artist,
      mode: request.mode,
      profileId: toneProfile?.id || null
    });

    const completion = await client.chat.completions.create({
      model,
      temperature: 0.25,
      messages: [
        {
          role: "system",
          content:
            "You are a professional guitar and bass tone engineer. Return practical, safe amp/effects settings as JSON only. Do not claim certainty about proprietary rigs; phrase research assumptions cautiously."
        },
        {
          role: "user",
          content: JSON.stringify({
            task: "Adapt this song tone to the user's rig.",
            request,
            sourceToneProfile: toneProfile,
            constraints: {
              knobScale: "0-10",
              includeEffectsOrder: true,
              includeTechniqueNotes: true,
              useSourceToneProfileWhenPresent: true,
              doNotInventVerification: true,
              avoidCopyrightedText: true
            }
          })
        }
      ],
      response_format: {
        type: "json_schema",
        json_schema: {
          name: "tonefex_tone_result",
          strict: true,
          schema: toneResultSchema
        }
      }
    } as never);

    const content = completion.choices[0]?.message?.content;
    if (!content) {
      console.warn("[tonefex:ai]", {
        event: "empty_openai_response",
        source: "local_fallback",
        model,
        song: request.song,
        artist: request.artist,
        mode: request.mode
      });
      return { result: fallback, source: "local_fallback", model, reason: "empty_openai_response" };
    }

    const parsed = JSON.parse(content) as Omit<GeneratedToneResult, "id" | "request">;
    const result = {
      ...fallback,
      ...parsed,
      request,
      id: fallback.id
    };

    console.info("[tonefex:ai]", {
      event: "openai_response_used",
      source: "openai",
      model,
      song: request.song,
      artist: request.artist,
      mode: request.mode
    });

    return { result, source: "openai", model };
  } catch {
    console.warn("[tonefex:ai]", {
      event: "openai_error_fallback_used",
      source: "local_fallback",
      model,
      song: request.song,
      artist: request.artist,
      mode: request.mode
    });
    return { result: fallback, source: "local_fallback", model, reason: "openai_error" };
  }
}
