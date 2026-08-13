import { NextResponse, type NextRequest } from "next/server";
import type { ToneAdaptationErrorResponseDto, ToneAdaptationResponseDto } from "@/lib/backend/tone-adaptation";
import { createToneAdaptationService } from "@/lib/backend/tone-adaptation";
import { configurationError, isToneBackendError } from "@/lib/backend/tone-adaptation/errors";
import { recordToneAdaptation } from "@/lib/backend/tone-adaptation/history";
import { validateToneAdaptationRequest } from "@/lib/backend/tone-adaptation/validation";
import { getEntitlement, getCurrentSession } from "@/lib/server-access";
import { createSupabaseAdminClient } from "@/lib/supabase/admin";
import { assertCanCreateAdaptation, recordSuccessfulAdaptationUsage } from "@/lib/usage";

export const runtime = "nodejs";

export async function POST(request: NextRequest) {
  const admin = createSupabaseAdminClient();

  if (!admin) {
    return NextResponse.json(
      {
        error: {
          code: "SUPABASE_ADMIN_UNAVAILABLE",
          message: "Tone adaptation backend is not configured with a Supabase service role key.",
          status: 503
        }
      },
      { status: 503 }
    );
  }

  const { supabase, user } = await getCurrentSession();
  if (!user) {
    return NextResponse.json(
      {
        error: {
          code: "AUTHENTICATION_REQUIRED",
          message: "Sign in to adapt tones to your saved gear.",
          status: 401
        }
      },
      { status: 401 }
    );
  }

  try {
    const rawPayload = await request.json();
    const dto = validateToneAdaptationRequest(rawPayload);
    const entitlement = await getEntitlement(supabase, user);
    const eligibility = await assertCanCreateAdaptation(admin, user, entitlement, dto.requestSource);

    // A signed-in user WITHOUT access (no active/trial subscription) gets a LOCKED PREVIEW
    // instead of a hard 402: we compute the tone and return the Original side, but the
    // client gates the adapted settings behind the "Start your 7-day free trial" CTA. This
    // is the conversion demo. Users who DO have access but hit a cap (trial/paid exhausted)
    // still get the normal 402 upgrade prompt.
    const previewOnly = !eligibility.ok && !entitlement.hasAccess;

    if (!eligibility.ok && !previewOnly) {
      return NextResponse.json(
        {
          error: {
            code: "ADAPTATION_LIMIT_REACHED",
            message: eligibility.error || "Adaptation access is unavailable.",
            status: 402
          },
          usage: {
            freeAdaptationsRemaining: eligibility.freeAdaptationsRemaining ?? 0,
            monthlyAdaptationsRemaining: eligibility.monthlyAdaptationsRemaining ?? null,
            path: eligibility.path ?? "free"
          }
        } satisfies ToneAdaptationErrorResponseDto & {
          usage: {
            freeAdaptationsRemaining: number;
            monthlyAdaptationsRemaining: number | null;
            path: string;
          };
        },
        { status: 402 }
      );
    }

    const toneService = createToneAdaptationService(admin);

    let response: ToneAdaptationResponseDto;
    try {
      response = await toneService.adaptTone(dto);
    } catch (adaptError) {
      // The adaptation attempt itself failed — record a failed history row (never a
      // misleading success). Validation/auth/limit rejections above are NOT recorded,
      // because they are not adaptation attempts.
      await recordToneAdaptation(admin, {
        user,
        dto,
        status: "failed",
        errorMessage: adaptError instanceof Error ? adaptError.message : "Tone adaptation failed."
      });
      throw adaptError;
    }

    if (previewOnly) {
      // Locked preview: no credit consumed, nothing persisted. The client shows the
      // Original tone and gates the adapted settings behind the free-trial CTA.
      return NextResponse.json({
        ...response,
        preview: true,
        tracking: {
          toneResultId: null,
          usageConfirmationRequired: false,
          freeAdaptationsRemaining: 0,
          freeAdaptationsUsed: null,
          freeAdaptationLimit: 0,
          monthlyAdaptationsRemaining: null,
          accessPath: "preview",
          locked: true
        }
      });
    }

    const toneJobId = await createToneJob(admin, user.id, dto);
    const toneResultId = await createToneResult(admin, {
      toneJobId,
      userId: user.id,
      response
    });

    // Exactly one permanent analytics row per successful adaptation. Best-effort:
    // recordToneAdaptation never throws, so it can't break the adaptation response.
    await recordToneAdaptation(admin, { user, dto, response, status: "success", toneResultId });

    const usage = await recordSuccessfulAdaptationUsage(admin, user, toneResultId, entitlement);

    if (!usage.ok) {
      throw configurationError("Tone adaptation usage could not be recorded.", {
        message: usage.error || "Usage recording failed."
      });
    }

    return NextResponse.json({
      ...response,
      tracking: {
        toneResultId,
        usageConfirmationRequired: false,
        freeAdaptationsRemaining: usage.freeAdaptationsRemaining,
        freeAdaptationsUsed: usage.freeAdaptationsUsed,
        freeAdaptationLimit: usage.freeAdaptationLimit,
        monthlyAdaptationsRemaining: usage.monthlyAdaptationsRemaining,
        accessPath: eligibility.path ?? "free"
      }
    });
  } catch (error) {
    const normalized = isToneBackendError(error)
      ? error
      : configurationError("Tone adaptation backend failed.", {
          message: error instanceof Error ? error.message : "Unknown error"
        });

    const body: ToneAdaptationErrorResponseDto = {
      error: {
        code: normalized.code,
        message: normalized.message,
        status: normalized.status,
        details: normalized.details
      }
    };

    return NextResponse.json(body, { status: normalized.status });
  }
}

async function createToneJob(
  admin: NonNullable<ReturnType<typeof createSupabaseAdminClient>>,
  userId: string,
  request: ReturnType<typeof validateToneAdaptationRequest>
) {
  const { data, error } = await admin
    .from("tone_jobs")
    .insert({
      user_id: userId,
      mode: request.mode,
      song: request.song || "Unknown Song",
      artist: request.artist || "Unknown Artist",
      part: request.part || "main part",
      input_gear: {
        requestSource: request.requestSource,
        guitar: request.guitar?.name || null,
        pickups: request.pickups.map((pickup) => pickup.name).filter(Boolean),
        amp: request.amp?.name || null,
        cabinet: request.cabinet?.name || null,
        pedals: request.pedals.map((pedal) => pedal.name).filter(Boolean),
        goingDirect: request.goingDirect,
        multiFx: request.multiFx?.name || null,
        effectsMode: request.effectsMode || null,
        selectedFx: request.selectedFx || null
      },
      status: "succeeded",
      model: "tone-core-onboarding"
    })
    .select("id")
    .single();

  if (error || !data?.id) {
    throw configurationError("Tone adaptation job could not be recorded.", {
      message: error?.message || "Missing tone job id"
    });
  }

  return String(data.id);
}

async function createToneResult(
  admin: NonNullable<ReturnType<typeof createSupabaseAdminClient>>,
  input: {
    toneJobId: string;
    userId: string;
    response: ToneAdaptationResponseDto;
  }
) {
  const { data, error } = await admin
    .from("tone_results")
    .insert({
      job_id: input.toneJobId,
      user_id: input.userId,
      result: {
        ...input.response.result,
        requestId: input.response.requestId,
        source: input.response.source,
        masterTone: input.response.masterTone,
        gear: input.response.gear
      },
      confidence: input.response.masterTone.confidence
    })
    .select("id")
    .single();

  if (error || !data?.id) {
    throw configurationError("Tone adaptation result could not be recorded.", {
      message: error?.message || "Missing tone result id"
    });
  }

  return String(data.id);
}
