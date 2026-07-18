# AI Context

## Project

Tonefex is a web application that helps guitarists and bassists find song tones, adapt a normalized source tone to their own gear, and save the result. It combines a public song/tone catalog, a user gear profile, deterministic tone rules, a database cache, subscriptions, and an admin-only AI ingestion pipeline.

## Current stack

- Next.js 15 App Router, React 19, strict TypeScript, Node 24.
- Tailwind CSS 3, Framer Motion, Lucide icons.
- Supabase Postgres/Auth via `@supabase/ssr` and `@supabase/supabase-js`.
- Dodo Payments subscriptions and webhooks.
- OpenAI only for admin ingestion/source hydration paths; the rule engine itself has no AI or network dependency.
- Vercel deployment, analytics through Vercel and PostHog.

## Repository map

```text
app/                 pages, route handlers, auth callbacks, metadata
components/          client/server UI components
lib/                 domain helpers, Supabase clients, catalog and access logic
lib/backend/         tone-adaptation and admin AI-ingestion layers
lib/rule-engine/     pure deterministic tone transformation
supabase/migrations/ ordered production schema and seed history
prisma/              descriptive normalized schema; runtime uses Supabase client
scripts/             importers and isolated test runners
tests/               Node test suites
docs/                permanent project context
```

## Runtime architecture

The App Router renders public and authenticated pages. UI components call Next.js route handlers. Route handlers authenticate and enforce entitlements, then call services. Services use repository interfaces backed by Supabase. Tone adaptation loads a master tone and gear profiles, checks `tone_adaptation_cache`, runs the deterministic rule engine on a miss, writes the result, records the job/result/usage, and returns source telemetry.

See [ARCHITECTURE.md](ARCHITECTURE.md).

## Major systems

- **Gear catalog:** `public.equipment` is the canonical single master table for electric guitars, bass guitars, guitar amps, and bass amps. Pedals and MultiFX remain in their existing dedicated catalogs because they are outside the four-type equipment table contract. See [ai/GEAR_CATALOG.md](ai/GEAR_CATALOG.md).
- **Tone database:** songs are normalized as `artists -> songs -> song_parts -> master_tones`. Legacy `song_tone_profiles` remains a compatibility bridge. See [ai/TONE_DATABASE.md](ai/TONE_DATABASE.md).
- **Tone engine:** `lib/rule-engine` applies ordered additive deltas without mutating the master tone. See [ai/TONE_ENGINE.md](ai/TONE_ENGINE.md).
- **Backend adaptation:** `lib/backend/tone-adaptation` validates DTOs, loads database models, resolves cache, executes rules, and returns explicit source timing.
- **AI ingestion:** admin/worker-only OpenAI pipeline creates or updates master-tone knowledge; normal rule execution does not call OpenAI.
- **Subscriptions:** Dodo checkout/webhook plus `subscriptions`, `monthly_usage`, and free adaptation counters.
- **Auth:** Supabase Auth with SSR cookies, middleware session refresh/protection, and RLS.

## Database overview

Migrations are authoritative. The database contains account/billing tables, song and tone tables, normalized gear and rule reference tables, catalog compatibility tables, cache/telemetry tables, and ingestion queues. Do not assume every additive historical table is the preferred write path; [DATABASE.md](DATABASE.md) labels ownership and compatibility status.

## API overview

The primary deterministic adaptation endpoint is `POST /api/v1/tones/adapt`. Search endpoints are `/api/search/{guitars,amps,pedals,multifx}`. A catch-all compatibility route still serves older lookup, research, adaptation, save, community, and music-search contracts. See [API.md](API.md).

## Conventions and philosophy

- Preserve API and stored-data compatibility unless change is explicitly approved.
- Prefer deterministic, auditable tone transformation; AI enriches source knowledge, not ordinary rule evaluation.
- Keep source tones gear-independent and adapt them at request time.
- Keep server secrets server-only; browser code uses the Supabase anon key and RLS.
- Migrations are append-only after deployment. Seed additions must be idempotent.
- Use `@/*` imports, strict types, small route handlers, service/repository boundaries, and explicit validation.

## Durable decisions and constraints

- `equipment` remains the single master catalog for the four supported guitar/amp equipment types. Do not split, drop, rename, or recreate it without explicit approval.
- Brand + model + equipment type must remain unique; seed expansion preserves existing rows.
- Normal users must not trigger generative AI for deterministic tone adaptation.
- Cache keys include source/version and all tone-affecting gear selections.
- RLS remains enabled on exposed public-schema tables; service-role usage stays server-side.

## Current milestone

The project is consolidating production catalog/search quality and hardening the deterministic v1 adaptation path. The master catalog has 385 seed rows after the verified expansion migration; the long-term commercial target remains 4,000+ verified guitar/amp records. See [CURRENT_STATE.md](CURRENT_STATE.md).

## Roadmap summary

Expand and verify the catalog, reconcile compatibility schemas/read paths, complete end-to-end production validation, improve search ranking and typo tolerance, and operationalize ingestion/review/cache observability. See [ROADMAP.md](ROADMAP.md).
