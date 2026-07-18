# Current State

Last reviewed: 2026-07-18 from repository state. Live Supabase and Vercel state were not queried.

## Completed

- Next.js product, auth pages, song/community browsing, tone matcher, My Gear, library, plans, account, contact, and legal/status pages exist.
- Supabase Auth SSR clients, middleware protection, profile bootstrap, RLS migrations, and account deletion exist.
- Deterministic rule engine and layered tone-adaptation backend exist with cache/source telemetry tests.
- Admin AI ingestion queue, worker, review decisions, embeddings option, and cache prewarming exist.
- Dodo checkout, customer portal, webhook subscription synchronization, entitlements, and usage accounting exist.
- Canonical `equipment` table supports four guitar/amp types with complete metadata constraints and search indexes.
- Verified expansion migration includes Harley Benton WL-20BK Rock Series and yields 385 seed rows in repository validation.
- Gear selectors now use a shared equipment-search path for guitars, amps, pedals, and Multi-FX, while legacy catalog URLs proxy to the same normalized pedal/MultiFX tables.
- Added a real-world pedal and Multi-FX seed migration for `pedal_brands`, `pedal_models`, `multifx_brands`, and `multifx_models`; repository seed file currently contains 329 pedals and 92 Multi-FX units.
- Permanent AI context system exists under `docs/`.

## Current work

- Commercial-grade catalog expansion and source verification for the canonical `equipment` table.
- Production hardening and convergence of historical compatibility paths onto canonical read models and `profiles.my_gear_profile`.

## Next

- Grow the verified master catalog toward 4,000+ records without duplicates or invented models.
- Add endpoint-level tests for all four Gear dropdown searches and null-configuration handling.
- Validate the new pedal/MultiFX migration against the live Supabase project and remove any remaining synthetic rows already deployed there.
- Validate migrations, RLS, indexes, and row counts against the linked production Supabase project.
- Run full production smoke tests after deployment.

## Blocked or unknown

- Last production deployment: `TODO` (not represented in the repository).
- Live migration version and live row counts: `TODO` (requires Supabase project access).
- Full TypeScript check currently has test fixture errors involving required `requestSource` fields in `tests/backend-tone-service.test.ts`; verify and repair before declaring a clean build.

## Repository state

- Active branch at review: `main` tracking `origin/main`.
- Latest migration file: `20260718123000_replace_placeholder_pedal_multifx_catalog_real_world.sql`.
- Deployment target: Vercel; live deployment identifier/date is `TODO`.
