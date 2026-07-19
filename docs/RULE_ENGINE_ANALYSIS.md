# Tone Adaptation Rule Engine — Complete Analysis

> Generated from direct code inspection on 2026-07-19. No assumptions — every claim below is traceable to a file/line in this repo.

## 1. Where the rule engine lives

| Layer | Files |
|---|---|
| **Core rule engine** (pure, deterministic) | `lib/rule-engine/pipeline.ts`, `rules.ts`, `evaluator.ts`, `conflict-resolution.ts`, `loader.ts`, `utils.ts`, `validation.ts`, `types.ts`, `service.ts` |
| **Backend orchestration** | `lib/backend/tone-adaptation/services/tone-service.ts` (orchestrator), `rule-engine-service.ts` (adapter), `song-service.ts`, `gear-service.ts`, `cache-service.ts` |
| **Data access** | `lib/backend/tone-adaptation/repositories/song-repository.ts`, `gear-repository.ts`, `cache-repository.ts` |
| **Translation** | `lib/backend/tone-adaptation/mappers.ts` (DB rows → rule inputs), `validation.ts` (request normalization), `cache-key.ts` |
| **AI fallback (data acquisition only)** | `lib/backend/ai-ingestion/*` — wired as `sourceHydrationService` in `lib/backend/tone-adaptation/index.ts` |
| **HTTP entry** | `app/api/v1/tones/adapt/route.ts` |
| **Frontend** | `components/tone-matcher.tsx` — `runAdaptation()` (~line 406), `buildToneAdaptationApiPayload()` (~2151), `mapToneAdaptationApiResponse()` (~2201) |

Note: `services/pickup-service.ts`, `amp-service.ts`, `cabinet-service.ts`, `pedal-service.ts`, `multifx-service.ts` are thin pass-through wrappers that are exported but **not used** in the live path — `GearService.loadGear()` calls the repository directly.

## 2. Execution flow from "Generate Tone"

```
USER CLICKS "Generate Tone"  (tone-matcher.tsx)
  │
  ├─ 1. runAdaptation() builds payload via buildToneAdaptationApiPayload():
  │      song, artist, part, partType, toneType (auto→auto_detect),
  │      mode, guitar (name), pickups[] (custom neck/mid/bridge or single
  │      primary), amp (name), cabinet (name), pedals[] (max 8, ordered),
  │      goingDirect, multiFx (only when goingDirect), effectsMode, selectedFx
  │
  ├─ 2. POST /api/v1/tones/adapt  (route.ts)
  │      ├─ Supabase admin client check (503 if missing)
  │      ├─ Auth session check (401 if anonymous)
  │      ├─ validateToneAdaptationRequest() — normalizes tokens, requires
  │      │    masterToneId OR (song AND artist)
  │      ├─ Entitlement + usage-limit check (402 when over limit)
  │      │
  │      ├─ 3. ToneService.adaptTone(dto)
  │      │      │
  │      │      ├─ 3a. LOAD CONTEXT (parallel)
  │      │      │     SongService.loadMasterTone()      GearService.loadGear()
  │      │      │        (see §4)                          (see §5)
  │      │      │     └─ on NOT_FOUND + song+artist → AI HYDRATION
  │      │      │        (OpenAI ingestion writes master_tones row, then retry)
  │      │      │
  │      │      ├─ 3b. CACHE KEY = sha256(stable-json of song/artist/part/
  │      │      │     toneType/mode/masterToneId+version/all gear ids+names+
  │      │      │     versions/goingDirect) — schema v3
  │      │      │
  │      │      ├─ 3c. CACHE READ (tone_adaptation_cache)
  │      │      │     HIT  → touch + return cached result
  │      │      │     MISS → continue
  │      │      │
  │      │      ├─ 3d. RULE ENGINE  TransformationPipeline.execute()
  │      │      │     10 stages in fixed order (see §3)
  │      │      │
  │      │      ├─ 3e. enrichResultForStorage() — attach requestSnapshot,
  │      │      │     originalSettings, targetSettings, sourceContext
  │      │      │
  │      │      └─ 3f. CACHE WRITE (throws on failure — request fails)
  │      │
  │      ├─ 4. createToneJob() → tone_jobs row
  │      ├─ 5. createToneResult() → tone_results row
  │      └─ 6. recordSuccessfulAdaptationUsage() → usage counters
  │
  └─ 7. mapToneAdaptationApiResponse() (client)
         settings → UI knobs (middle→mids, masterVolume→master),
         effectsChain → "Effects chain" list,
         notes+warnings (first 6) → "Playing tips",
         masterTone.confidence → "accuracy" badge,
         static pickupAdvice string
```

## 3. The pipeline stages and every rule

`RULE_STAGE_ORDER` (types.ts) — one rule per stage except pickups/pedals which emit one contribution per item:

| # | Stage | Rule id | Fires when | What it does |
|---|-------|---------|-----------|--------------|
| 1 | `load_master_tone` | `core.load_master_tone` | always | No deltas. Notes the baseline id. Baseline settings = master tone settings normalized: missing EQ keys default **5**, ambience keys (noiseGate, compression, delay, reverb) default **0**; clamp 0–10, round to 0.5. |
| 2 | `tone_type` | `core.apply_tone_type` | always | Fixed delta table by tone type. clean/acoustic: gain −1, comp −0.5, reverb +0.5 · crunch/classic_rock: gain +1, mid +0.5 · heavy/high_gain/metal/modern_metal: gain +1.5, bass +0.5, gate +1, comp +0.5 · distorted/fuzz: gain +1, comp +0.5 · ambient: delay +1, reverb +1, presence −0.5 · edge_of_breakup: gain +0.5, mid +0.5 · bass_drive: gain +0.75, comp +0.5 · bass_clean: gain −0.5, comp +0.5 · **auto_detect: no deltas**. |
| 3 | `guitar_profile` | `gear.apply_guitar_profile` | guitar loaded | Explicit `deltas` + `toneTypeDeltas[toneType]` from DB, then trait compensation: brightness ≥7 → treble −1, presence −1; ≤3.5 → +1/+1. output ≤3.5 → gain +0.5, comp +0.5; ≥7 → −0.5/−0.5. warmth ≥7 → bass −0.5, mid −0.5; ≤3.5 → +0.5/+0.5. compression ≥7 → comp −0.5; ≤3.5 → +0.5. Per-rule merge clamp ±4. |
| 4 | `pickup_profiles` | `gear.apply_pickup_profiles.<pos>.<id>` | ≥1 pickup | Per pickup: DB deltas + output ≤3.5 → gain +1, comp +0.5; ≥7 → gain −1, comp −0.5. active → gain −0.5, gate −0.5, comp −0.5; passive → comp +0.25. brightness ≥7 → treble −0.5, presence −0.5; ≤3.5 → +0.5/+0.5. neck → bass −0.5, treble +0.5; bridge → treble −0.25, presence −0.25. Per-pickup merge clamp **±2**. |
| 5 | `amplifier_profile` | `gear.apply_amplifier_profile` | amp loaded & not goingDirect | DB deltas + era: vintage (or gainStructure matches /vintage\|plexi\|tweed\|blackface/i) → gain +0.5, mid +0.5; modern (or /modern\|high\|rectifier\|5150/i) → gain −0.5, bass −0.25. brightness ≥7 → treble −0.5, presence −0.5; ≤3.5 → +0.5/+0.5. warmth ≥7 → bass −0.5. headroom ≤3.5 → gain −0.5, master −0.5. |
| 6 | `cabinet_profile` | `gear.apply_cabinet_profile` | cab loaded & not goingDirect | DB deltas + open_back → bass −0.75, depth −0.5, presence +0.25; closed_back → inverse. 1x12 → bass −0.5; 4x12 → bass +0.5, resonance +0.5. brightness ≥7 → treble −0.5, presence −0.5. lowEnd ≥7 → bass −0.5, depth −0.5. highEnd ≤3.5 → treble +0.5, presence +0.5. |
| 7 | `pedals` | `gear.apply_pedals.<order>.<id>` | ≥1 enabled pedal | Sorted by order. Per pedal: DB deltas + eqInfluence + gainChange + compression + noise→gate (min 1.5, noise/4) + type defaults (delay → delay +1; reverb → reverb +1; boost → gain +0.75; overdrive → gain +0.5, mid +0.5; distortion/fuzz → gain +1, comp +0.5; compressor → comp +1; noise_gate → gate +1). Pedal name appended to effects chain. Per-pedal clamp **±2.5**. |
| 8 | `going_direct` | `direct.apply_going_direct` | goingDirect | Fixed: bass −0.5, treble −0.5, presence −1, reverb +0.5, gate +0.5. Adds "Cab/IR block" + "Post amp EQ" to chain. Sets multifxParameters.goingDirect/cabSimulation/targetUnit. |
| 9 | `multifx_mapping` | `direct.apply_multifx_mapping` | goingDirect && multiFx | Maps final knob values to device parameter names (defaults amp.gain, amp.bass … gate.threshold, compressor.amount, overridable per device via `parameter_mapping`). Adds "MultiFX patch: <name>". |
| 10 | `final_tone` | `core.return_final_tone` | always | No deltas; closing note. |

**Per-stage conflict resolution** (`conflict-resolution.ts`): within a stage, per setting, positive deltas summed, negative summed, net clamped **±4**, flagged as conflict if both signs present. Then `addDeltas` clamps each setting 0–10, rounds to 0.5. **`eqProfile` and `modulationProfile` are passed through untouched from the master tone — no rule modifies them.**

## 4. How the song profile (master tone) is loaded

`SupabaseSongRepository.findMasterTone` — strict → fuzzy → legacy → AI:

1. `masterToneId` provided → direct load (master_tones → song_parts → songs → artists).
2. Else: artist by slug, fallback `ilike name`; song by slug within artist, fallback `ilike title`; part by `part_type_id`, fallback `ilike label`, fallback first active part by sort_order; master tone by exact `tone_type_id` + `instrument_type`, fallback any tone type for the part (highest version). Suggested pedals from `master_tone_suggested_pedals`.
3. On NOT_FOUND → **legacy bridge**: `song_tone_profiles` fuzzy query (`ilike %song%`, `%artist%`, mode filter, limit 20), scored: exact title 100 / partial 55, exact artist 45 / partial 20, part_type match +20, tone_type match +15. **Threshold: score > 25.** Winner mapped into master-tone shape (`mids`→`middle`, `master`→`masterVolume`), confidence default 70, original gear strings stored in metadata (**not used by rules**). ⚠️ `adaptation_notes`/`playing_notes` from song_tone_profiles are **not** carried across.
4. Still nothing and song+artist present → **AI hydration** (OpenAI ingestion writes a master_tones row) → retry step 1/2. This is the only non-deterministic element, and it only *acquires data*; the transform stays deterministic.

## 5. How user gear is loaded and "compared"

`SupabaseGearRepository` matches each selection by: id if given, else `ilike %name%` on `search_text`, fallback `ilike %name%` on `model_name` — first row ordered by model_name. Guitars filter `instrument_type = mode`; amps `in (mode, 'both')`.

- **Pickups**: explicit selections (position from payload or index order neck/middle/bridge) → else guitar's stock pickups from `guitar_model_pickups`.
- **Amp/cab**: skipped entirely when goingDirect.
- **MultiFX**: canonical `multifx_models` first, fallback `multifx_devices` (+ amp/cab/effect model lists — loaded but never used by rules).

**Key architectural fact:** the engine never compares user gear against the *original song gear*. Master-tone settings are the baseline; user-gear traits apply absolute compensation deltas. Original gear (in legacy metadata / master-tone archetype fields `pickupPreference`, `suggestedAmpArchetype`, `suggestedCabinetArchetype`) is declared in types but **never read by any rule** (verified by grep).

## 6. Confidence, notes, chain, output

- **Confidence** = stored value on the master-tone / legacy row (legacy default 70), rounded. Surfaced as `accuracy`. **No computation** — gear-match quality, fuzzy-match distance, and hydration provenance do not affect it.
- **Playing tips** = rule notes ("Adjusted for guitar profile: X…") + validation warnings, deduped, engine caps 16, UI shows 6. Generic, not performance advice.
- **Effects chain** = master tone `suggestedPedals` + user pedal names + direct-mode blocks, deduped strings. No structure, no original-vs-user diff, **no missing-effects detection**.
- **Cache** result stores full audit trail, request snapshot, original + target settings (`tone-cache-v3`).

## 7. Deterministic vs heuristic

| Deterministic (same input + same DB ⇒ same output) | Heuristic / fuzzy |
|---|---|
| All 10 stages, delta tables, clamps, conflict resolution | `ilike %name%` gear matching (first row wins) |
| Cache key (stable stringify + sha256) | Legacy profile scoring (threshold 25) |
| Settings normalization and rounding | Era inference regex on `gain_structure` text |
| MultiFX parameter mapping | AI hydration for missing songs (OpenAI — nondeterministic data creation) |

## 8. Gaps vs ToneAdapt (from reference screenshots)

1. **Original-rig relative adaptation** — ToneAdapt reasons "original = Telecaster into Fender Deluxe; you have Squier Strat + Champion 20 ⇒ specific compensation." Tonefex compensates on user-gear traits alone; owning the *same* gear as the record still shifts the EQ.
2. **Original gear panel with provenance** — original guitar/pickups/amp/notes + source links ("Joe Walsh | Equipboard", forum threads). Data partially exists (`song_tone_profiles.original_*`, `tone_profile_sources`) but is dropped by the bridge and absent from master-tone results.
3. **Missing-effects detection with severity** — "MXR Phase 90 (nice-to-have): used for solo sections…" i.e. diff(original effects, user pedals+amp effects) with per-effect role/importance. Tonefex has `suggestedPedals` and user pedals in the same function but never diffs them.
4. **Amp-effects substitution** — "Use your amp's delay instead of the Maestro Echoplex" + amp reverb level (5.5/10). Requires amp built-in-effects data + substitution rule.
5. **Recommended amp preset/model** — "RECOMMENDED PRESET: Tweed Deluxe" on modeling amps. `availableAmpModels` is loaded and discarded.
6. **Pickup-position recommendation** — ToneAdapt: "Pickup Choice: Bridge pickup." `pickup_preference_id` exists on master_tones, never surfaced.
7. **Guitar volume/tone knob values** — ToneAdapt outputs Volume 10 / Tone 10. Not modeled at all.
8. **Structured signal chain** — "Guitar → Fender Champion 20 Input" and full original chain "Tele → Echoplex → Phase 90 → Deluxe". Tonefex: flat string list.
9. **Per-pedal usage/match %** and per-song difficulty stars with rationale (data exists: `difficulty` column — unused in adaptation output).
10. **Cached badge** is shown by ToneAdapt; Tonefex has the data (`finalSource`) but doesn't render it.

## 9. Accuracy weaknesses (ranked)

1. **Absolute (not relative) compensation** — biggest correctness gap; see §8.1.
2. **Master-tone baseline defaults**: missing EQ keys silently become 5 and ambience 0 — a sparse DB row yields a generic tone with full confidence displayed.
3. **Fuzzy `ilike` first-match gear resolution** — "Fender Deluxe" can resolve to the wrong model deterministically-but-wrongly; no match-quality signal returned.
4. **Legacy-bridge data loss** — original gear strings, playing_notes, adaptation_notes (10k+ seeded rows!) never reach the result.
5. **auto_detect applies zero tone-type shaping** while UI default is "Auto".
6. **Confidence is static** — doesn't degrade on fuzzy match, part fallback, tone-type fallback, or hydrated data.
7. **Pedal-type generic deltas double-count** with DB `gain_change`/`eq_influence` when both present.
8. **Cache write failure fails the whole request** (`throw` after successful rule-engine run).
9. **suggestedPedals conflated with user pedals** in one chain list — user can't tell what they own vs what's recommended.

## 10. Deterministic improvement plan

1. **Relative gear compensation**: store original-rig trait vectors (brightness, output, warmth…) per master tone; rule deltas become `f(userTrait − originalTrait)` instead of `f(userTrait)`. Same-gear ⇒ zero delta. Pure lookup + arithmetic; fully deterministic.
2. **Effect-diff stage**: new stage after `pedals` that set-diffs original effects (typed: delay/phaser/…, with role metadata solo/rhythm/always + importance) against user pedals + amp built-in effects → emits `missingEffects[]` with severity and substitution advice ("amp delay replaces tape echo") from a static substitution table.
3. **Amp-model recommendation stage**: when the user's amp is a modeler (or goingDirect with multiFx), match `suggestedAmpArchetype` against `availableAmpModels`/amp preset list via deterministic token scoring → "Recommended preset".
4. **Surface pickup preference**: pass `masterTone.pickupPreference` through to output; add a guitar-controls block (volume/tone) driven by tone-type table (clean → guitar vol 8–10, high_gain rhythm → 10, etc.).
5. **Computed confidence**: `final = clamp(sourceConfidence − fuzzyMatchPenalty − partFallbackPenalty − toneTypeFallbackPenalty − hydrationPenalty − missingGearPenalty)`; expose sub-scores for UI.
6. **Bridge completeness**: map `original_*`, `playing_notes`, `adaptation_notes`, `tone_profile_sources` into the result (original-rig panel + real playing tips + sources list).
7. **Structured signal chain**: emit `{ position, kind: guitar|pedal|amp|cab|block, name, source: user|suggested }[]` instead of strings; render original chain vs adapted chain.
8. **Exact-match gear resolution first**: try exact normalized-name equality before `ilike`; return `matchQuality: exact|fuzzy|none` per item and feed it into confidence.
9. **Don't fail on cache-write errors** — log and return the computed result.
10. **auto_detect resolution rule**: resolve to the master tone's stored tone type before stage 2 so tone-type shaping always applies.

All ten are table-lookups, set operations, and arithmetic — no generative AI required at request time.
