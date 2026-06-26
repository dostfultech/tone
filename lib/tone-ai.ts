import { buildToneResult, type ToneRequest } from "@/lib/mock-data";
import { createOpenAIClient } from "@/lib/provider-clients";
import type { ToneProfile } from "@/lib/tone-profiles";

export type GeneratedToneResult = ReturnType<typeof buildToneResult>;

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
  const fallback = buildToneResult(request, toneProfile);
  const client = createOpenAIClient();
  if (!client) {
    return fallback;
  }

  const model = process.env.OPENAI_MODEL || "gpt-4.1-nano";

  try {
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
      return fallback;
    }

    const parsed = JSON.parse(content) as Omit<GeneratedToneResult, "id" | "request">;
    return {
      ...fallback,
      ...parsed,
      request,
      id: fallback.id
    };
  } catch {
    return fallback;
  }
}
