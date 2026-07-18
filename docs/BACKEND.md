# Backend

## Tone adaptation

`lib/backend/tone-adaptation` is the structured backend behind `POST /api/v1/tones/adapt`.

- `dtos.ts`: public request/response shapes.
- `validation.ts`: normalizes request source, IDs/names, mode, tone type, ordering, and booleans.
- `services/tone-service.ts`: orchestration, timing, source hydration, cache read/write, and rule execution.
- Focused services: song, gear, guitar/amp/pickup/cabinet/pedal/MultiFX, rule engine, and cache.
- Repositories: Supabase song, gear, and cache access.
- `cache-key.ts`: stable JSON signature/hash contract.
- `mappers.ts`: database records to rule-engine inputs.
- `errors.ts`, `logging.ts`, controller: structured failures and observability.

The service returns only `DATABASE_CACHE` or `RULE_ENGINE` as the final result source. Source metadata records cache status, timings, cache key, AI/source-hydration flags, and OpenAI-call state.

## Rule engine

`lib/rule-engine` is synchronous and pure. Rules are ordered by stage, priority, then ID. Each stage contributes deltas; values are combined/clamped rather than overwriting the source. See [ai/TONE_ENGINE.md](ai/TONE_ENGINE.md).

## AI ingestion

`lib/backend/ai-ingestion` queues and processes `song_generation`, `metadata_enrichment`, `gear_matching`, and `cache_prewarming` jobs. It validates admin DTOs, calls the OpenAI research/embedding providers where configured, stores normalized master tones and review decisions, and can prewarm through the deterministic adaptation service.

## Other backend modules

- `equipment-service.ts`: canonical `equipment` brand/model search and UI mapping.
- `tone-profiles.ts`: song profile/community lookup and missing-song request support.
- `tone-core.ts`: older hybrid cache/rule resolver used by compatibility adaptation routes.
- `usage.ts`, `adaptation-access.ts`, `entitlements.ts`: free and subscription access accounting.
- `dodo.ts`, `dodo-webhooks.ts`: payment client/config and webhook mapping.
- `server-access.ts`: current session, entitlement, and paid-user guards.
- `supabase/*`: configuration validation and browser/SSR/admin client factories.
- `analytics.ts`: client event helpers.
- `provider-clients.ts`, `tone-ai.ts`: OpenAI provider support for approved server paths.

## Validation and error policy

Validate untrusted payloads before service calls. v1 and ingestion backends use typed domain errors with status/code/details. Configuration absence should fail explicitly for required privileged operations; optional analytics may degrade safely. Do not catch database errors and silently return invented data.

## Search and caching

Canonical guitar/amp search is centralized in `equipment-service.ts`. Pedal/MultiFX search handlers directly query their selector catalogs and normalize the same UI result shape. Tone result caching is a backend repository concern, not HTTP caching; adaptation JSON is user/gear-specific and source responses use explicit no-store behavior where appropriate.

## Business rules

- Authenticated users are required for v1 adaptation.
- Free access is limited to manual generation and three adaptations.
- Beginner has a monthly limit; Expert and development test access are unlimited.
- Usage is linked to a persisted tone result and deduplicated through event metadata.
- Missing master-tone knowledge is handled through controlled ingestion/hydration, never hidden as an arbitrary fabricated result.
