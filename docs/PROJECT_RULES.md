# Permanent Project Rules

These rules are binding context. An AI assistant must not reverse them without explicit user approval.

## Architecture

1. `public.equipment` is the single canonical master table for `electric_guitar`, `bass_guitar`, `guitar_amp`, and `bass_amp`.
2. Do not create replacement or duplicate equipment tables, rename the master table, drop it, or recreate it.
3. Pedals and MultiFX use their existing catalogs; do not add them to the four-type master equipment contract without approval.
4. Preserve service/repository boundaries and the existing API surface unless a task explicitly authorizes architecture or API changes.
5. Source/master tones remain independent of a user's concrete gear. Adapted settings belong in results/cache, not master tones.
6. The rule engine stays deterministic, ordered, auditable, and independent of network/database/OpenAI calls.

## Data

1. Never delete valid catalog records during expansion.
2. Equipment seeds must be real production models and must be idempotent.
3. Never insert duplicate `(equipment_type, brand, model)` combinations.
4. Use normalized arrays/enums/JSON objects where the schema supports them; do not encode structured metadata into prose.
5. Do not invent brands, models, series, source claims, deployment facts, or database counts.
6. Migrations are the schema source of truth. Do not edit an already deployed migration; add a new migration when a live schema change is approved.

## Compatibility and security

1. Preserve backward compatibility for public routes and persisted payloads unless removal is approved and documented.
2. Never expose `SUPABASE_SERVICE_ROLE_KEY`, payment secrets, webhook secrets, worker secrets, or OpenAI keys to client code.
3. Keep RLS enabled on exposed tables and scope user rows by `auth.uid()`.
4. Admin ingestion requires either an authenticated `profiles.role = 'admin'` user or the configured worker secret.
5. Validate untrusted request data at the boundary and return structured errors.

## Delivery

1. Inspect relevant code and migrations before changing behavior.
2. Run the closest available automated tests and report failures honestly.
3. Update `CURRENT_STATE.md`, `CHANGELOG.md`, and affected subsystem docs after material changes.
4. Record durable architectural changes in `DECISIONS.md` before treating them as established policy.
5. Mark repository-unverifiable facts as `TODO`; do not guess live deployment or database state.
