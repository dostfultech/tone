# Roadmap

## Completed foundations

- Product shell, authentication, subscriptions, usage limits, and core user flows.
- Song/tone catalog and normalized master-tone schema.
- Deterministic rule engine, Supabase repositories, adaptation cache, and telemetry.
- Admin AI ingestion pipeline.
- Canonical four-type master equipment table and database-backed Gear dropdowns.

## In progress

- Verified production equipment catalog expansion.
- Search completeness and ranking quality.
- Production validation of RLS, migrations, API behavior, and deployment configuration.
- Documentation and compatibility-path consolidation.

## Near term

- Reach broad commercial catalog coverage with source provenance and duplicate checks.
- Add API/search integration tests and migration smoke tests.
- Resolve backend test fixture/type drift.
- Decide and document retirement criteria for `gear_items`, `song_tone_profiles`, duplicate brand/model compatibility fields, and catch-all stubs.
- Add operational dashboards for ingestion jobs, cache hit rate, failures, quota writes, and webhook processing.

## Future

- Better tokenized/fuzzy ranking and measurable search relevance.
- Admin catalog verification workflow and source audit trail.
- Richer gear profiles, pickup/cabinet/MultiFX mappings, and versioned rule data.
- Community moderation and verified tone provenance workflows.
- Formal API versioning/deprecation process.

## Long-term goal

Tonefex should cover most commonly owned musician gear and produce reproducible, explainable adaptations from verified source tones while remaining fast, scalable, and maintainable.
