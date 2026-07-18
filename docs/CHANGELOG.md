# Changelog

Repository history before this documentation pass is summarized from migrations and current code; it is not a substitute for Git history.

## 2026-07-18

- Added the permanent AI context documentation system and subsystem guides.
- Added Harley Benton WL-20BK Rock Series to the verified master equipment expansion seed.
- Connected Gear page pedal and MultiFX search handlers to their Supabase-backed catalogs.
- Added `20260718123000_replace_placeholder_pedal_multifx_catalog_real_world.sql` with 329 real pedal rows and 92 real Multi-FX rows for the normalized catalogs.
- Routed pedal and Multi-FX selectors through the shared equipment search service and updated Tone Matcher to sync saved pedals/Multi-FX from `profiles.my_gear_profile`.
- Expanded the verified master catalog migration; repository catalog validation reports 385 total seed rows.

## 2026-07-17

- Rebuilt `public.equipment` as the constrained single master catalog for four supported guitar/amp equipment types.
- Added feedback-driven gear backfill data.

## 2026-07-16

- Added searchable brand catalogs, selector compatibility fields, search-text triggers/indexes, `multifx_models`, and `profiles.my_gear_profile`.

## 2026-07-13

- Added bounded application activity event ingestion and storage.

## 2026-07-04 to 2026-07-06

- Added normalized tone/gear architecture, deterministic rule-engine blueprint, AI ingestion pipeline, and free adaptation onboarding/accounting.

## 2026-06-29 to 2026-06-30

- Added tone equipment profiles, adaptation cache, telemetry, production hardening, and seed profiles.

## 2026-06-12 to 2026-06-27

- Established accounts, plans, subscriptions, legacy gear/preset tables, tone jobs/results/saves/usage, song catalog, community submissions, tone profiles, and initial seed expansion.
