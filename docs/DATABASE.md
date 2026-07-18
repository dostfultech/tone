# Database

Supabase Postgres 15 migrations in `supabase/migrations/` are authoritative. This inventory describes every table created by those migrations. “Current” means used by executable code; “compatibility” means retained for older routes/data; “support” means reference, queue, telemetry, or future-facing infrastructure.

## Conventions

- UUID tables generally use `gen_random_uuid()` and `created_at`; mutable rows generally have `updated_at` plus `set_updated_at` triggers.
- Public-schema tables have RLS enabled by migrations. Catalog/reference rows are readable when active; user rows are owner-scoped; privileged cache, telemetry, rules, and ingestion writes are service-role paths.
- Search uses generated/trigger-maintained `search_text`, GIN full-text indexes, and `pg_trgm` indexes where added. Unique constraints are also indexes.
- Detailed SQL types, checks, policies, triggers, and index definitions must be read from the named migrations before a schema change.

## Accounts, billing, and product activity

| Table | Purpose and important columns | Relations/constraints/indexes | Runtime consumers |
|---|---|---|---|
| `profiles` | User profile: `email`, name/avatar, `role`, free-adaptation counters, first completion, `my_gear_profile` JSON. | PK/FK `id -> auth.users`; role check; owner RLS. | Auth bootstrap, account/My Gear, quotas, admin checks. |
| `plans` | Plan prices, limits, Dodo product IDs, feature JSON, active flag. | Text PK; active public-read policy. | Pricing/entitlement seed data. |
| `subscriptions` | Dodo customer/subscription/product IDs, plan, status, billing interval/period, cancellation, metadata. | FK user/plan; unique Dodo subscription; status checks; owner read. | Checkout portal, webhook, account, `getEntitlement`. |
| `usage_events` | Auditable product usage such as adaptation and checkout start. | FK user/job; event-type check; owner read. | Quota reconciliation and checkout/adaptation logging. |
| `monthly_usage` | Per-user/month adaptation/save/preset counters. | Composite PK `(user_id, usage_month)`; owner read. | Beginner quota enforcement. |
| `app_activity_events` | Bounded page/UI/custom events, path/referrer/element, metadata, IP, user agent, timestamps. | Category check; user/time/name indexes; service-role insert. | `POST /api/v1/events`, `AppEventTracker`. |
| `reviews` | Ratings and moderated public testimonials. | Rating/body/status checks; approved-or-owner read. | Home `Reviews`. |
| `feedback_messages` | Contact/feedback topic, email, message, workflow status. | Length/status checks; submitter insert/read. | `ContactForm` direct Supabase write. |
| `admin_audit_logs` | Privileged action trail. | Optional actor FK; action/time lookup; admin policy. | Account deletion and admin operations. |

## User tones and compatibility workflows

| Table | Purpose and important columns | Relations/constraints/indexes | Runtime consumers |
|---|---|---|---|
| `gear_presets` | Legacy user rig: instrument, gear IDs/names, effects, notes. | FK user and `gear_items`; owner CRUD. | Compatibility/history; normalized user rigs are the target. |
| `tone_jobs` | Per-user adaptation job inputs, model, status, errors and token/cost fields. | FK user; mode/status checks; owner read. | v1 and compatibility adaptation routes. |
| `tone_results` | Immutable JSON result and confidence for a job/user. | FK job/user; confidence check; owner read. | v1 tracking, usage confirmation, library saves. |
| `saved_tones` | User library entry with request/result JSON, labels, notes, public flag. | FK user/result; owner CRUD and public read; user/time indexes. | Library/detail and `/api/save-tone`. |
| `song_requests` | Missing-song research queue with requested gear, status, votes. | Optional user FK; status/time index; owner/admin visibility. | Compatibility research flow. |
| `community_submissions` | User-submitted gear/settings/effects/sources and moderation state. | Optional user FK; status/time index; approved-or-owner read. | Community submission compatibility path. |

## Song and tone knowledge

| Table | Purpose and important columns | Relations/constraints/indexes | Runtime consumers |
|---|---|---|---|
| `artists` | Canonical artist identity, slug, country, external IDs, search text. | Unique slug; GIN search; active public read. | Song/community pages, importer, repositories. |
| `songs` | Song metadata, artist, slug, album/year/duration, external IDs/search. | FK artist; unique `(artist_id, slug)`; artist/search indexes. | Catalog pages, tone lookup, ingestion. |
| `song_tone_profiles` | Legacy denormalized source profile with concrete research gear/settings/effects and verification. | FK song; unique song/mode/part/tone/label; browse/trigram indexes. | Compatibility route and bridge fallback. |
| `tone_profile_effects` | Ordered effects belonging to a legacy profile. | FK profile; unique `(profile_id, effect_order)`. | Importer/legacy profile reads. |
| `tone_profile_sources` | Provenance records for a legacy profile. | FK profile; source type/credibility checks. | Importer/research display support. |
| `tone_part_types` | Reference IDs/labels for song sections. | Text PK, sort/active fields. | Normalized song parts and ingestion. |
| `tone_types` | Reference IDs/labels for tone classes. | Text PK, sort/active fields. | Master tones and ingestion. |
| `tone_archetypes` | Reusable tone character archetypes. | Unique slug; optional instrument check. | Master/gear profile relations. |
| `amp_archetypes` | Abstract gain/EQ amp targets. | Unique slug; active reference row. | Suggested amp relation in master tones. |
| `cabinet_archetypes` | Abstract format/back-type cabinet targets. | Unique slug; back-type check. | Suggested cabinet relation in master tones. |
| `pickup_preferences` | Preferred position/type descriptions. | Unique slug; FK pickup type; position check. | Master tone pickup target. |
| `song_parts` | Normalized section per song with type, label, order/timing and search. | FK song/type; unique `(song_id, part_type_id, label)`; lookup indexes. | Master-tone repository and ingestion. |
| `master_tones` | Gear-independent knob targets, profiles, archetype links, confidence, verification and version. | FK song part/type/archetypes; 0-10 checks; unique part/instrument/tone/version; lookup index. | v1 adaptation and AI ingestion. |
| `master_tone_suggested_pedals` | Ordered abstract pedal-type suggestions for a master tone. | FK master tone/pedal type; unique tone/type/order. | Master-tone repository/rule input. |
| `master_tone_review_decisions` | Approve/reject audit for generated master tones. | FK master tone/reviewer; status check; tone/time index. | Admin ingestion actions. |

## Canonical master equipment catalog

| Table | Purpose and important columns | Relations/constraints/indexes | Runtime consumers |
|---|---|---|---|
| `equipment` | Canonical electric/bass guitar and guitar/bass amp rows. Shared: type, brand/slugs, model, series, display, description, popularity, search terms/text, status/order, genres/tones. Guitar: body, frets, scale, bridge, pickup config/types/output. Amp: amp type, technology, watts, channels, gain range. | Unique `(equipment_type, brand, model)`; enum and required-metadata checks; brand/type/popularity, display, GIN search-term/full-text and trigram indexes; active public read. | `equipment-service`, `/api/equipment/*`, guitar/amp Gear dropdowns and compatibility lookups. |

Only the four enum values `electric_guitar`, `bass_guitar`, `guitar_amp`, and `bass_amp` belong in `equipment`. Its current migration intentionally creates complete rows from seed CTEs and later expansion uses conflict-safe inserts. Do not add pedals, MultiFX, acoustics, cabinets, or accessories.

## Gear catalogs and tone profiles

| Table | Purpose and important columns | Relations/constraints/indexes | Runtime consumers |
|---|---|---|---|
| `gear_items` | Legacy broad catalog with brand/model/type, instrument/pickup/amp fields and tags. | Unique brand/model/type; GIN/trigram/lookup indexes; active public read. | Tone equipment profile relation and compatibility data. |
| `tone_equipment_profiles` | Versioned transfer/control/behavior JSON for a legacy gear item. | FK gear item; unique item/type; active/type/search indexes. | Legacy `tone-core` resolver. |
| `equipment_manufacturers` | Normalized manufacturer identity and metadata. | Unique name and slug. | Normalized gear repositories and ingestion seeds. |
| `frequency_curves` | 0-10 frequency bands plus arbitrary curve JSON. | Unique slug; range checks. | Guitar/pickup/speaker/cabinet profiles. |
| `pickup_types` | Coil-type reference (`single_coil`, `humbucker`, `p90`, `other`). | Text PK and coil check. | Pickup models/preferences. |
| `pedal_types` | Pedal category reference. | Text PK, sort/active. | Pedal models, suggestions, MultiFX effects. |
| `guitar_models` | Normalized model profile plus selector compatibility fields `brand_id`, `name`, `slug`, `category`, pickup config, tags. | FK normalized manufacturer and guitar brand; unique manufacturer/model/instrument and partial brand/slug; search/brand indexes. | Tone `GearRepository`; compatibility selector data, though guitar UI search now uses `equipment`. |
| `pickup_models` | Pickup behavior: type/circuit/output/EQ/noise/archetype plus metadata/search. | FK manufacturer/type/curve/archetype; unique manufacturer/model/type. | Tone pickup service/repository. |
| `guitar_model_pickups` | Stock pickup by guitar position. | FK guitar/pickup; position check; unique guitar/position/stock. | Automatic stock pickup resolution. |
| `amp_models` | Normalized amp behavior plus selector compatibility brand/name/slug/category/type/tags. | FK manufacturer/archetype/amp brand; unique manufacturer/model/instrument and partial brand/slug; search indexes. | Tone amp service/repository; guitar/amp UI uses `equipment`. |
| `cabinet_formats` | Speaker count/size reference such as 1x12/2x12/4x12. | Text PK; positive checks. | Cabinet models. |
| `speaker_models` | Speaker curve, brightness/warmth and metadata. | FK manufacturer/curve; unique manufacturer/model. | Cabinet model composition. |
| `cabinet_models` | Cabinet format/back/speaker/curve and tonal values. | FK manufacturer/format/speaker/curve; unique manufacturer/model/format. | Tone cabinet service/repository. |
| `amp_recommended_cabinets` | Ranked amp-to-cabinet relation. | FK amp/cabinet; unique pair. | Reference data; no direct current API. |
| `pedal_models` | Pedal behavior plus selector fields `brand_id`, `name`, `slug`, `category`, `pedal_type`, tags/search. | FK normalized manufacturer/type and pedal brand; unique normalized identity and partial brand/slug; search indexes. | `/api/search/pedals`, tone pedal repository. |
| `multifx_devices` | Normalized device behavior: DSP, routing, patch structure and parameter mapping. | FK normalized manufacturer; unique manufacturer/model. | Tone MultiFX repository fallback. |
| `multifx_amp_models` | Device amp model and optional normalized amp mapping. | FK device/amp; unique device/model. | Tone MultiFX expansion. |
| `multifx_cab_models` | Device cab model and optional normalized cabinet mapping. | FK device/cabinet; unique device/model. | Tone MultiFX expansion. |
| `multifx_effects` | Device effect and optional pedal-type mapping. | FK device/type; unique device/effect. | Tone MultiFX expansion. |
| `guitar_brands` | Search brand identity for compatibility guitar models. | Unique slug; search trigger/index; active public read. | Selector compatibility/backfill. |
| `amp_brands` | Search brand identity for compatibility amp models. | Unique slug; search trigger/index; active public read. | Selector compatibility/backfill. |
| `pedal_brands` | Search brand identity for pedals. | Unique slug; search trigger/index; active public read. | `/api/search/pedals`. |
| `multifx_brands` | Search brand identity for MultiFX. | Unique slug; search trigger/index; active public read. | `/api/search/multifx`. |
| `multifx_models` | Canonical searchable selector rows: brand, name/slug, category, tags/search. | FK MultiFX brand; unique brand/name and brand/slug; GIN/trigram indexes. | `/api/search/multifx`, preferred tone repository lookup. |

## User normalized gear

| Table | Purpose and important columns | Relations/constraints/indexes | Runtime consumers |
|---|---|---|---|
| `user_instruments` | User-owned normalized guitar with nickname/metadata. | FK user/guitar model; owner RLS. | Future normalized My Gear path. |
| `user_instrument_pickups` | Per-position pickup override. | FK instrument/pickup; unique instrument/position. | Future normalized My Gear path. |
| `user_rigs` | Named instrument/amp/cab/MultiFX/direct rig. | FK user and normalized gear; instrument check. | Future normalized My Gear path. |
| `user_rig_pedals` | Ordered pedals in a rig. | FK rig/pedal; unique rig/order. | Future normalized My Gear path. |

The current Gear page persists the compact selector payload in `profiles.my_gear_profile`; the normalized user tables are additive architecture and are not yet the primary UI persistence path.

## Rules, cache, telemetry, and ingestion

| Table | Purpose and important columns | Relations/constraints/indexes | Runtime consumers |
|---|---|---|---|
| `rule_sets` | Versioned named rule groups and lifecycle status. | Unique slug; status check. | Database placeholder; current rules are TypeScript. |
| `rule_profiles` | Prioritized equipment-scoped rule metadata. | FK rule set; unique set/name/scope. | Future data-driven rules. |
| `rule_profile_archetypes` | Rule-to-tone/amp/cab archetype mapping. | FK rule profile/archetypes. | Future data-driven rules. |
| `cache_key_definitions` | Versioned documentation of cache input shapes. | Unique namespace/name/version. | Future cache contract registry. |
| `tone_adaptation_cache` | Stable request signature/key, source and gear labels/profile versions, result JSON, source/confidence, hits/expiry. Later migrations add pickup/cab/MultiFX/effects/direct fields and relax source-profile requirements. | Unique cache key and versioned source signature; exact/fresh/equipment/direct indexes; service-role path. | `SupabaseCacheRepository`, legacy tone core. |
| `tone_generation_telemetry` | Source/cache/result/latency/AI/cost metadata. | FK user/source/cache; created-time index; service writes. | Tone core telemetry. |
| `ai_ingestion_jobs` | Queued job type/status/priority, payload/result/error, attempts and locks. | Job/status checks; claim/status indexes; service role. | Admin ingestion worker. |
| `ai_ingestion_job_events` | Job event log. | FK job; job/time index. | Ingestion observability. |

## Functions and extensions

The schema uses `pgcrypto` and `pg_trgm`; `set_updated_at`, profile bootstrap, slug/search synchronization, quota helpers, cache cleanup, and ingestion claim helpers are defined in migrations. Security-definer functions must keep fixed `search_path`, explicit authorization, and restricted execute grants.

## Future database work

- Verify live migration parity and RLS with Supabase advisors.
- Define retirement criteria for compatibility tables only after all runtime references are gone.
- Add catalog source provenance if approved; do not overload descriptions as proof.
- Keep `equipment` stable while expanding verified rows through idempotent migrations.
