# Architecture Decisions

## ADR-001: Single master equipment table for guitar and amp catalog

- **Decision:** `public.equipment` is canonical for electric guitars, bass guitars, guitar amps, and bass amps.
- **Reason:** one searchable, consistently constrained source avoids type-specific duplication and keeps API compatibility stable.
- **Alternatives:** separate type tables; reuse only legacy `gear_items`; use normalized model tables directly.
- **Status:** Accepted. Do not reverse without explicit approval.

## ADR-002: Gear-independent master tones

- **Decision:** songs store normalized musical targets in `master_tones`, not user-amp-specific outputs.
- **Reason:** one source tone can be adapted deterministically to many rigs.
- **Alternatives:** precompute concrete settings per amp; embed gear names in source tones.
- **Status:** Accepted.

## ADR-003: Deterministic adaptation first

- **Decision:** the rule engine is pure, ordered, additive, clamped, and auditable; normal transformation does not call AI.
- **Reason:** reproducibility, testability, cost control, and explainability.
- **Alternatives:** generate every result with an LLM; mutable overwrite rules.
- **Status:** Accepted.

## ADR-004: AI belongs to controlled ingestion

- **Decision:** OpenAI creates/enriches source knowledge through an admin/worker pipeline. Any missing-source hydration must be explicit and observable.
- **Reason:** separate uncertain research from deterministic user-facing adaptation.
- **Alternatives:** synchronous unrestricted AI generation from every user request.
- **Status:** Accepted.

## ADR-005: Database-backed adaptation cache

- **Decision:** stable, versioned signatures key `tone_adaptation_cache`; successful miss handling writes before returning.
- **Reason:** identical inputs produce reusable results while version fields prevent stale cross-version reuse.
- **Alternatives:** process memory cache; no cache; CDN-only cache.
- **Status:** Accepted.

## ADR-006: Additive schema migration and compatibility

- **Decision:** normalized schema additions coexist with legacy tables and routes until consumers migrate.
- **Reason:** reduce production cutover risk and preserve saved payload/API compatibility.
- **Alternatives:** destructive one-step replacement.
- **Status:** Accepted; compatibility debt is tracked in `KNOWN_ISSUES.md`.

## ADR-007: Supabase trust separation

- **Decision:** browser/SSR clients use anon credentials and RLS; privileged operations use a server-only service-role client.
- **Reason:** enforce least privilege at the data boundary.
- **Alternatives:** service-role access from general application code or clients.
- **Status:** Accepted.
