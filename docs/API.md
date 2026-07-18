# API

All handlers are Next.js App Router routes. JSON errors are not fully uniform: v1/admin routes use structured `{ error: { code, message, status } }`; compatibility and commerce routes often use `{ error: string }`.

## Primary routes

| Method and URL | Purpose / request | Response / auth / caller |
|---|---|---|
| `POST /api/v1/tones/adapt` | Validate and adapt a master tone. Body supports `requestSource`, song/artist/part/type/mode/masterToneId and gear IDs/names, ordered pickups/pedals, cabinet, direct mode, MultiFX and effects metadata. | `{requestId,result,source,masterTone,gear,tracking}`. Requires Supabase user and admin client; enforces free/Beginner/Expert quota. Used by tone adaptation UI. |
| `POST /api/v1/tones/confirm` | Idempotently confirm usage for `{toneResultId}`. Retained for clients that need explicit confirmation; current adapt route records usage before returning. | Confirmation and remaining quotas. Requires signed-in owner. |
| `POST /api/v1/events` | Accept one event, an array, or `{events}`; max 50. Normalizes text/metadata depth and timestamps. | `202 {accepted}`; works anonymously and skips safely if admin client is absent. Used by `AppEventTracker`/analytics helpers. |
| `GET /api/search/guitars?q=&limit=&instrumentType=` | Search active canonical `equipment` guitar rows. | `{results: GearSearchItem[]}`; SSR Supabase client/RLS; used by Gear selectors. |
| `GET /api/search/amps?q=&limit=&instrumentType=` | Search active canonical `equipment` amp rows. | Same shape; used by Gear selectors. |
| `GET /api/search/pedals?q=&limit=` | Search `pedal_models` joined to `pedal_brands`; limit capped at 200. | Same shape; used by Gear pedal selector. |
| `GET /api/search/multifx?q=&limit=` | Search `multifx_models` joined to `multifx_brands`; limit capped at 200. | Same shape; used by Gear MultiFX selector. |
| `GET /api/equipment/brands?type=guitar|amp&q=&limit=` | List distinct canonical equipment brands. | `{results}`; bad type returns 400/empty. Used by catalog search helpers. |
| `GET /api/equipment/models?type=guitar|amp&q=&brandId=&instrumentType=&limit=` | Search canonical equipment with optional filters. | `{results}`; bad type returns 400/empty. |
| `GET /api/equipment/search?type=guitar|amp|pedal|multifx...` | Shared searchable gear endpoint used by modern selectors. Guitar/amp read `equipment`; pedal/Multi-FX read normalized brand/model tables. | `{results: GearSearchItem[]}` with same auth/access behavior. |

`instrumentType` accepts `guitar`, `bass`, `acoustic`, or `both`, but the canonical equipment table currently contains only electric/bass guitar and guitar/bass amp types.

## Account and commerce

| Method and URL | Purpose / request | Response / auth / caller |
|---|---|---|
| `POST /api/account/delete` | Audit and delete the current Supabase Auth user. | `{deleted:true}`; authenticated; service role required. Used by Account view. |
| `POST /api/dodo/checkout` | Body `{planId: beginner|expert, billing: monthly|annual}`; create Dodo checkout and log `checkout_started`. | `{checkoutUrl}`; authenticated. Used by Pricing. |
| `GET /api/dodo/customer-portal` | Resolve the current user's Dodo customer and return app portal URL. | `{portalUrl}`; authenticated subscription owner. Used by Account view. |
| `POST /api/webhook/dodo-payments` | Verify Dodo signature and synchronize subscription/customer/status/period metadata. | Webhook acknowledgement/error. Auth is webhook signature, not user session. |
| `GET /customer-portal?customer_id=` | Server redirect into Dodo's hosted customer portal. | Redirect/error page; server payment API key required. |
| `GET /auth/callback?code=&next=` | Exchange Supabase OAuth/email code, then redirect safely. | Redirect; no JSON. Used by Supabase Auth links/providers. |

## Admin AI ingestion

Base URL: `/api/admin/ai-ingestion/[action]`. `POST`, `PATCH`, and `DELETE` all dispatch by action. Authentication is either an authenticated `profiles.role = 'admin'` user or `x-tonefex-worker-secret` matching `AI_INGESTION_WORKER_SECRET`.

| Action | Expected body | Result |
|---|---|---|
| `generate-song` | Song, artist, optional part/type/mode, runImmediately, priority, metadata. | Queued job or generated/stored master tone. |
| `regenerate-song` | Generate fields plus optional masterToneId/reason. | Regeneration job/result. |
| `update-master-tone` | `{masterToneId, patch, reason?}`. | Updated normalized master tone. |
| `approve-tone` / `reject-tone` | `{masterToneId, reason?, metadata?}`. | Review decision and tone state update. |
| `delete-tone` | `{masterToneId, reason?}`. | Soft/delete service result as implemented by repository. |
| `run-worker` | Worker ID, claim limit, optional job types. | Claimed/succeeded/failed counts. |

## Compatibility catch-all

`app/api/[...path]/route.ts` keeps older frontend contracts. Responses have `Cache-Control: no-store`.

### GET routes

| URL after `/api/` | Behavior |
|---|---|
| `amps/lookup`, `guitars/lookup` | Search canonical equipment and map to legacy catalog items. |
| `bass-amps/lookup`, `bass-guitars/lookup` | Same, filtered to bass. |
| `pedals/catalog`, `multi-fx/catalog` | Compatibility catalog reads backed by the normalized pedal and Multi-FX tables via the shared equipment service. |
| `pedals/user`, `pedals/presets`, `multi-fx/user` | Compatibility reads derived from `profiles.my_gear_profile` when a signed-in user exists; otherwise `{results:[]}`. |
| `acoustic-guitars/lookup`, `pickups/catalog`, `cabinets/catalog`, `effects/catalog` | Current compatibility stubs return `{results:[]}`. |
| `music/search?q=` | Search iTunes with a 10-minute bounded in-memory cache, merge with starter songs, and fall back locally. |
| `trending-tones` | Return starter `songs` data. |
| `community-tones/lookup` | Query community profiles with text/instrument/part/tone/sort/pagination filters. |
| `promo-credit/usage` | Static compatibility response `{credits:3,used:0}`. |
| `gear-onboarding/status` | Static compatibility onboarding status. |
| `songsterr` | Static tab-shaped compatibility response. |
| unknown path | `{ok:true,route,query}` compatibility response. |

### POST routes

| URL after `/api/` | Behavior and auth |
|---|---|
| `research-tone`, `research-bass-tone` | Find source profile or create a missing song request; return research payload. Optional user. |
| `adapt-tone`, `adapt-bass-tone`, `adapt-multi-fx-tone` | Legacy adaptation orchestration, entitlement/quota, tone job/result/cache/core resolution. Auth required when Supabase is configured. |
| `save-tone` | Save request/result to `saved_tones`; authenticated paid user when configured. |
| `ab-variant/view` | Static tracking acknowledgement. |
| `gear-onboarding/dismiss` | Static dismissal acknowledgement. |
| `grant-signup-credit` | Static compatibility credit response. |
| `account/delete` | Returns 410 and directs clients to `/api/account/delete`. |
| unknown path | `{ok:true,route,body}` compatibility response. |

## API change policy

Do not remove or repurpose endpoints without approval. Add explicit validation, preserve response contracts, document authentication and callers, and add tests for behavior changes. New product work should prefer focused versioned routes over adding more catch-all branches.
