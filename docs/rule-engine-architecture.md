# Tonefex Rule Engine Architecture

Status: deterministic backend/domain implementation only. This phase does not modify database schema, frontend UI, AI, or cache logic.

## Goal

Transform a normalized Master Tone into final tone settings for selected user gear. The engine never overwrites the master tone. Every profile contributes deterministic deltas that are applied to a copied working setting map.

## Public Entry Point

```ts
import { transformMasterToneForGear } from "@/lib/rule-engine";
```

The service accepts:

- Master Tone
- Selected Guitar
- Selected Pickups
- Selected Amplifier
- Selected Cabinet
- Selected Pedals
- Tone Type
- Going Direct Mode
- Selected MultiFX

It returns:

- Final tone settings
- Effects chain
- MultiFX parameter mapping
- Notes
- Warnings
- Audit trail
- Conflict-resolution records
- Metadata with `aiUsed: false`

## Fixed Rule Order

Rules always execute in this order:

1. Load Master Tone
2. Apply Tone Type
3. Apply Guitar Profile
4. Apply Pickup Profiles
5. Apply Amplifier Profile
6. Apply Cabinet Profile
7. Apply Pedals
8. Apply Going Direct Mode
9. Apply MultiFX Mapping
10. Return Final Tone

This order is defined in `RULE_STAGE_ORDER` inside `lib/rule-engine/types.ts`.

## Components

- `types.ts`: shared interfaces and stage contracts.
- `rules.ts`: default deterministic rule definitions.
- `loader.ts`: rule loading and priority ordering.
- `evaluator.ts`: per-stage rule evaluation.
- `conflict-resolution.ts`: additive conflict resolution for opposing deltas.
- `validation.ts`: input validation and non-blocking warnings.
- `logger.ts`: no-op, console, and memory loggers.
- `pipeline.ts`: full transformation pipeline.
- `service.ts`: public Rule Engine service wrapper.

## Priority System

Each rule has:

- `stage`
- `priority`
- `id`

Rules sort by:

1. Stage order
2. Priority ascending
3. Rule ID ascending

This makes execution deterministic even when additional rules are added later.

## Conflict Resolution

The engine is additive. If two rules affect the same setting in opposite directions, the engine:

1. Sums positive deltas.
2. Sums negative deltas.
3. Resolves to the combined delta.
4. Clamps the stage delta.
5. Records a conflict entry.

No rule overwrites another rule and no rule overwrites the master tone.

## Logging

The engine logs:

- Start event
- Completed stages
- Validation failures
- Final completion

By default, logging is no-op. Production code can inject a logger.

## Determinism Guarantees

- No OpenAI import.
- No network calls.
- No database calls.
- No randomness.
- No time-based decisions in rule behavior.
- The only timestamp-like value is elapsed execution metadata, which does not affect settings.

## Example Rule Behavior

- Low output pickup: increase gain and compression.
- High output pickup: reduce gain and compression.
- Bright guitar: reduce treble and presence.
- Dark guitar: increase treble and presence.
- Vintage amp: increase drive/mids.
- Modern amp: reduce drive.
- Open back cabinet: reduce low end.
- Closed back cabinet: increase low end.
- Going direct: reduce presence, add cab simulation and post-EQ mapping.
- MultiFX mapping: maps final tone knobs to device parameter names.
