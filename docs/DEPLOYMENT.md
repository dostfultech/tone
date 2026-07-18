# Deployment

## Local setup

1. Install Node 24 and run `npm ci`.
2. Create `.env.local` with the required variables below.
3. Link/start a Supabase project and apply migrations in filename order.
4. Run `npm run dev`; default Next.js URL is `http://localhost:3000`.
5. Use `TEST_ACCESS_EMAILS` only in development; production code intentionally disables this bypass.

## Environment variables

| Variable | Required for | Exposure |
|---|---|---|
| `NEXT_PUBLIC_SITE_URL` | Canonical URLs/redirects | Public |
| `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Browser and SSR Supabase | Public by design |
| `SUPABASE_URL`, `SUPABASE_ANON_KEY` | Optional server aliases | Server |
| `SUPABASE_SERVICE_ROLE_KEY` | Privileged adaptation, usage, ingestion, account deletion | Secret |
| `SUPABASE_PROJECT_REF`, `TONEFEX_EXPECTED_SUPABASE_PROJECT_REF` | Project-key mismatch checks | Server |
| `TEST_ACCESS_EMAILS` | Development-only Expert bypass | Server |
| `DODO_PAYMENTS_API_KEY`, `DODO_PAYMENTS_WEBHOOK_KEY` | Checkout/portal/webhook | Secret |
| `DODO_PAYMENTS_ENVIRONMENT` | `test_mode` or `live_mode` | Server |
| `DODO_*_PRODUCT_ID` | Four plan/billing products | Server |
| `DODO_PAYMENTS_RETURN_URL` | Checkout return override | Server |
| `OPENAI_API_KEY`, `OPENAI_MODEL` | Approved AI provider paths | Secret |
| `AI_INGESTION_MODEL`, `OPENAI_EMBEDDING_MODEL` | Ingestion model overrides | Server |
| `AI_INGESTION_EMBEDDINGS_ENABLED` | Optional embeddings | Server |
| `AI_INGESTION_WORKER_SECRET` | Worker endpoint auth | Secret |
| `TONE_CORE_RESOLVER`, `TONE_GENERATION_MODE` | Legacy resolver behavior | Server |
| `MUSIC_SEARCH_COUNTRY`, `MUSIC_SEARCH_RESULT_LIMIT`, `MUSIC_SEARCH_ALLOW_INSECURE_TLS` | iTunes search behavior | Server |
| `NEXT_PUBLIC_POSTHOG_KEY`, `NEXT_PUBLIC_POSTHOG_HOST` | PostHog client analytics | Public |
| `GOOGLE_SITE_VERIFICATION` | Search verification metadata | Server-rendered/public value |

Never add secret variables to a `NEXT_PUBLIC_` name.

## Supabase

- `supabase/config.toml` targets Postgres 15 and exposes `public` through the Data API.
- Apply ordered migrations; verify with the Supabase CLI migration list and database advisors supported by the installed CLI.
- Configure Auth site URL and redirect URLs for `/auth/callback` and `/reset-password` on local, preview, and production hosts.
- Keep RLS enabled and verify grants separately from policies.
- Run `node scripts/validate-equipment-catalog.mjs` before catalog migration deployment.

## Vercel

`vercel.json` uses Next.js, `npm ci`, and `npm run build`. Add environment variables separately for Preview and Production, connect the canonical domain, and configure the Dodo webhook as `/api/webhook/dodo-payments`.

## Release checklist

1. Run typecheck/build and all three test suites.
2. Validate equipment seeds and review migration SQL for destructive statements.
3. Apply migrations to a staging/preview project first.
4. Verify auth, all Gear searches, adaptation/cache, save/library, quotas, checkout, portal, webhook, account deletion, and admin ingestion authorization.
5. Deploy to Vercel and repeat smoke tests against the production domain.
6. Record deployment date/identifier in `CURRENT_STATE.md` and `CHANGELOG.md`.

## Rollback

Application rollback is a Vercel deployment rollback. Database rollback should normally be a new forward migration that restores compatible behavior/data. Never run a destructive down migration against production without backup, impact review, and explicit approval. Seed expansions are conflict-safe and should be corrected with targeted forward SQL, not table recreation.

Live project/deployment identifiers are intentionally `TODO` until verified from the connected services.
