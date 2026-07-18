# Known Issues

## Active

1. Full TypeScript checking reports missing required `requestSource` values in several `tests/backend-tone-service.test.ts` fixtures. Runtime code and focused route files are separate from this fixture drift, but the repository should not be called type-clean until fixed.
2. The catch-all compatibility route still returns empty arrays for legacy pedal, MultiFX, pickup, cabinet, effect, and acoustic catalog URLs. The Gear page uses working `/api/search/pedals` and `/api/search/multifx` routes, but older callers may still see empty data.
3. Several historical catalog representations coexist: `equipment`, `gear_items`, normalized model tables, and selector brand/model compatibility fields. `equipment` is authoritative for guitar/amp search, but retirement boundaries are incomplete.
4. `profiles.my_gear_profile` is the current UI persistence path while normalized `user_instruments`/`user_rigs` tables are not yet primary.
5. Repository catalog size is 385 seed rows, below the long-term 4,000+ verified target.
6. Live Supabase migration parity, row counts, RLS advisors, and last Vercel deployment are unverified from repository-only context.
7. Pedal/MultiFX search routes non-null assert the SSR Supabase client and do not return a tailored configuration error if Supabase is absent.
8. `docs/vercel-deployment.md` contains older Node/version statements; this context system and `package.json` (`node 24.x`) are current.

## Technical debt

- The broad catch-all route mixes legacy lookup, external music search, adaptation, saving, and static compatibility responses.
- API error shapes differ between v1/admin and legacy/commerce routes.
- Rule metadata tables exist, but the current deterministic rules remain TypeScript-defined.
- Automated tests are strong for rule/cache/ingestion logic but sparse for route handlers, RLS, search relevance, commerce webhooks, and browser flows.

## Workaround policy

Document temporary behavior here, add a removal condition, and never let a workaround silently become a permanent architecture decision. Remove resolved items in the same change and log the resolution in `CHANGELOG.md`.
