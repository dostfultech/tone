# Tonefex Normalized Tone Database Architecture

Status: database architecture only. No UI, rule engine, AI, or cache implementation is included in this phase.

## Core Principle

Songs must never store amplifier-specific adapted settings.

A song stores one or more normalized `master_tones`. A `master_tone` describes the musical target: gain, EQ balance, ambience, compression, tempo, archetypes, pickup preference, and suggested pedal types. Later systems can combine that master tone with user gear, but the song database itself remains independent of any concrete guitar, amplifier, cabinet, pedal, or MultiFX device.

## Generated Artifacts

- Prisma schema: `prisma/schema.prisma`
- PostgreSQL schema/migration: `supabase/migrations/20260704193016_normalized_tone_database_architecture.sql`
- TypeScript interfaces: `lib/database/normalized-tone-models.ts`
- Architecture document: `docs/database/normalized-tone-architecture.md`

## Entity Relationships

### Song Domain

- `artists` has many `songs`.
- `songs` has many `song_parts`.
- `song_parts` belongs to `tone_part_types`.
- `song_parts` has many `master_tones`.
- `master_tones` belongs to `tone_types`.
- `master_tones` optionally belongs to:
  - `tone_archetypes`
  - `pickup_preferences`
  - `amp_archetypes`
  - `cabinet_archetypes`
- `master_tones` has many `master_tone_suggested_pedals`.
- `master_tone_suggested_pedals` belongs to `pedal_types`.

### Gear Domain

- `equipment_manufacturers` has many:
  - `guitar_models`
  - `pickup_models`
  - `amp_models`
  - `speaker_models`
  - `cabinet_models`
  - `pedal_models`
  - `multifx_devices`
- `guitar_models` optionally reference `frequency_curves` and `tone_archetypes`.
- `pickup_models` belongs to `pickup_types`, and optionally references `frequency_curves` and `tone_archetypes`.
- `guitar_model_pickups` links stock pickups to guitar models by `neck`, `middle`, or `bridge`.
- `amp_models` optionally references `tone_archetypes`.
- `amp_recommended_cabinets` links amp models to recommended cabinet models.
- `cabinet_models` belongs to `cabinet_formats` and optionally references `speaker_models` and `frequency_curves`.
- `pedal_models` belongs to `pedal_types`.
- `multifx_devices` has many:
  - `multifx_amp_models`
  - `multifx_cab_models`
  - `multifx_effects`

### User Gear Domain

- `profiles` has many `user_instruments`.
- `user_instruments` optionally references a normalized `guitar_model`.
- `user_instrument_pickups` lets users override stock pickups by position.
- `profiles` has many `user_rigs`.
- `user_rigs` optionally references:
  - `user_instruments`
  - `amp_models`
  - `cabinet_models`
  - `multifx_devices`
- `user_rig_pedals` links a user rig to ordered pedal models.

### Future Rule/Cache Placeholders

- `rule_sets` contains versioned rule-engine groups.
- `rule_profiles` belongs to `rule_sets`.
- `rule_profile_archetypes` links future rules to tone, amp, and cabinet archetypes.
- `cache_key_definitions` describes future cache-key contracts only. It does not store cache results.

## ER Diagram Text

```text
artists
  1 -> many songs

songs
  1 -> many song_parts

tone_part_types
  1 -> many song_parts

song_parts
  1 -> many master_tones

tone_types
  1 -> many master_tones

tone_archetypes
  1 -> many master_tones
  1 -> many guitar_models
  1 -> many pickup_models
  1 -> many amp_models

pickup_preferences
  1 -> many master_tones

amp_archetypes
  1 -> many master_tones

cabinet_archetypes
  1 -> many master_tones

master_tones
  1 -> many master_tone_suggested_pedals

pedal_types
  1 -> many master_tone_suggested_pedals
  1 -> many pedal_models
  1 -> many multifx_effects

equipment_manufacturers
  1 -> many guitar_models
  1 -> many pickup_models
  1 -> many amp_models
  1 -> many speaker_models
  1 -> many cabinet_models
  1 -> many pedal_models
  1 -> many multifx_devices

frequency_curves
  1 -> many guitar_models
  1 -> many pickup_models
  1 -> many speaker_models
  1 -> many cabinet_models

pickup_types
  1 -> many pickup_models
  1 -> many pickup_preferences

guitar_models
  1 -> many guitar_model_pickups
  1 -> many user_instruments

pickup_models
  1 -> many guitar_model_pickups
  1 -> many user_instrument_pickups

amp_models
  1 -> many amp_recommended_cabinets
  1 -> many user_rigs
  1 -> many multifx_amp_models

cabinet_formats
  1 -> many cabinet_models

speaker_models
  1 -> many cabinet_models

cabinet_models
  1 -> many amp_recommended_cabinets
  1 -> many user_rigs
  1 -> many multifx_cab_models

pedal_models
  1 -> many user_rig_pedals

multifx_devices
  1 -> many multifx_amp_models
  1 -> many multifx_cab_models
  1 -> many multifx_effects
  1 -> many user_rigs

profiles
  1 -> many user_instruments
  1 -> many user_rigs

user_instruments
  1 -> many user_instrument_pickups
  1 -> many user_rigs

user_rigs
  1 -> many user_rig_pedals

rule_sets
  1 -> many rule_profiles

rule_profiles
  1 -> many rule_profile_archetypes
```

## Supported Reference Values

### Song Part Types

- Intro
- Verse
- Chorus
- Bridge
- Solo
- Lead
- Rhythm
- Riff
- Breakdown
- Outro
- Clean

### Tone Types

- Auto Detect
- Clean
- Crunch
- Edge of Breakup
- Classic Rock
- Heavy
- High Gain
- Metal
- Modern Metal
- Distorted
- Ambient
- Acoustic

### Pedal Types

- Overdrive
- Boost
- Distortion
- Compressor
- EQ
- Delay
- Reverb
- Noise Gate
- Chorus
- Flanger
- Phaser
- Pitch
- Octaver
- Fuzz

### Pickup Types

- Single Coil
- Humbucker
- P90
- Active and passive are stored on `pickup_models.circuit_type`.

### Cabinet Formats

- 1x12
- 2x12
- 4x12
- Open back, closed back, and semi-open are stored on `cabinet_models.back_type`.

### MultiFX Starter Devices

- Boss GT-1000
- HX Stomp
- Helix
- FM3
- FM9
- Quad Cortex
- Headrush
- Kemper
- Neural DSP

## Master Tone Rules

`master_tones` may store:

- Gain
- Bass
- Middle
- Treble
- Presence
- Resonance
- Depth
- Master volume
- Noise gate
- Compression
- Delay
- Reverb
- EQ profile
- Modulation profile
- Tempo
- Suggested amp archetype
- Suggested cabinet archetype
- Suggested pedal types
- Tone archetype
- Pickup preference
- Metadata

`master_tones` must not store:

- A concrete amplifier model selected by a user.
- A concrete cabinet selected by a user.
- A user's guitar model.
- A user's pickup replacement.
- A final adapted amp-specific result.
- AI prompt or completion data.
- Adaptation cache output.

## Migration Plan From Existing Database

### Phase 1: Add Normalized Schema

Apply `20260704193016_normalized_tone_database_architecture.sql`.

This creates the target normalized schema without removing current production tables.

### Phase 2: Backfill Reference Data

Map current values into normalized reference rows:

- Existing `artists` and `songs` remain canonical.
- `song_tone_profiles.part_type` maps to `tone_part_types`.
- `song_tone_profiles.tone_type` maps to `tone_types`.
- Gear text fields such as `original_guitar`, `original_amp`, `original_cab`, and `original_pickup` should not become master-tone settings. They may be used only as research metadata or to infer archetypes.

### Phase 3: Create Song Parts

For each existing `song_tone_profiles` row:

1. Find the linked `songs.id`.
2. Create or reuse a `song_parts` row by `(song_id, part_type_id, part_label)`.
3. Store section timing only when known.

### Phase 4: Create Master Tones

For each existing `song_tone_profiles` row:

1. Create a `master_tones` row linked to the normalized `song_parts.id`.
2. Copy normalized knob values from `original_settings` only when they describe the musical source tone.
3. Convert `mids` to `middle`.
4. Do not copy concrete amp names into `master_tones`.
5. Convert `original_effects` into `master_tone_suggested_pedals` by pedal type where possible.
6. Store uncertain research notes in `master_tones.metadata`.

### Phase 5: Normalize Gear Catalog

Migrate `gear_items` into normalized equipment tables:

- `gear_items.item_type = guitar` or `bass_guitar` -> `equipment_manufacturers` + `guitar_models`.
- `gear_items.item_type = pickup` -> `equipment_manufacturers` + `pickup_models`.
- `gear_items.item_type = amp` or `bass_amp` -> `equipment_manufacturers` + `amp_models`.
- Cabinet-like gear -> `cabinet_models`.
- `gear_items.item_type = pedal` -> `pedal_models`.
- `gear_items.item_type = multi_fx` -> `multifx_devices`.

Existing `gear_items` can remain as a compatibility table until the application stops reading it.

### Phase 6: Normalize User Gear

Migrate `gear_presets` into:

- `user_instruments`
- `user_instrument_pickups`
- `user_rigs`
- `user_rig_pedals`

Free-text fallback fields should be phased out after all catalog matching is complete.

### Phase 7: Switch Read Paths

After data quality is verified:

1. Tone Database reads from `songs -> song_parts -> master_tones`.
2. My Gear reads from `user_rigs`.
3. Equipment dropdowns read from normalized equipment tables.
4. Old `song_tone_profiles` becomes read-only compatibility data.

### Phase 8: Retire Old Schema

Only after the application has no runtime references to old tables:

- Deprecate `song_tone_profiles`.
- Deprecate `tone_profile_effects`.
- Deprecate concrete gear text columns in saved outputs.
- Keep `tone_results` and `saved_tones` for user history unless a separate normalized result-history model is approved.

## Folder Structure For Models

Recommended future folder structure:

```text
lib/database/
  normalized-tone-models.ts
  repositories/
    artists.repository.ts
    songs.repository.ts
    master-tones.repository.ts
    equipment-manufacturers.repository.ts
    guitar-models.repository.ts
    pickup-models.repository.ts
    amp-models.repository.ts
    cabinet-models.repository.ts
    pedal-models.repository.ts
    multifx-devices.repository.ts
    user-rigs.repository.ts
  mappers/
    song-tone-profile-to-master-tone.mapper.ts
    gear-item-to-normalized-equipment.mapper.ts
    gear-preset-to-user-rig.mapper.ts
  validators/
    master-tone.validator.ts
    equipment-profile.validator.ts

prisma/
  schema.prisma

supabase/migrations/
  20260704193016_normalized_tone_database_architecture.sql

docs/database/
  normalized-tone-architecture.md
```

Repository and mapper files are not implemented in this phase. The structure is a target for later phases.

## Security Model

- Public catalog/reference tables use RLS with active-row read policies.
- User gear tables are scoped by `auth.uid()` and ownership checks.
- Rule and cache placeholder tables are service-role only.
- No policy uses `auth.role()`.
- Update policies include both `USING` and `WITH CHECK`.

## Important Tradeoffs

- This migration is additive, so production behavior does not change until the application read paths are migrated.
- `jsonb` is intentionally retained for flexible frequency curves, EQ curves, routing, and MultiFX parameter mapping.
- Concrete AI, rule-engine, and cache output tables are not introduced here because those systems were explicitly excluded from this phase.
