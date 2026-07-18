# Coding Standards

## TypeScript and React

- Keep `strict` TypeScript clean; avoid `any` and unsafe assertions unless a third-party boundary requires one.
- Use `@/*` imports for project modules and explicit `import type` where practical.
- App Router pages and route handlers live under `app`; reusable UI lives under `components`; domain code lives under `lib`.
- Default to server components. Add `"use client"` only for browser APIs, local interaction, or hooks.
- Keep state local unless multiple owners genuinely require shared persistence. Do not add a state library without a decision record.
- Represent loading, empty, error, unauthenticated, and quota states explicitly.

## Backend

- Route handlers parse HTTP/auth/access and delegate business behavior.
- Validate DTOs at boundaries. Services orchestrate; repositories own database access; mappers translate persistence to domain types.
- Use structured domain errors in v1/admin code and do not leak secrets/internal stack traces.
- Keep deterministic code free of network calls, current-time decisions, randomness, and provider imports.
- Include source/cache telemetry when changing adaptation behavior.

## SQL

- Use lowercase snake_case identifiers and explicit `public.` qualification in migrations.
- Prefer additive, idempotent migrations (`if not exists`, conflict-safe inserts) where compatible.
- Define foreign-key delete behavior, checks, uniqueness, indexes, RLS, and policies deliberately.
- Use arrays/JSONB for genuinely structured flexible values; use typed columns/enums for stable searchable constraints.
- Add/maintain search indexes when changing searchable fields.
- Never edit deployed history or drop/recreate `equipment` without explicit approval.

## Naming

- React components/types/classes: `PascalCase`.
- Functions/variables/files: existing `camelCase` and kebab-case conventions.
- Database/API JSON: preserve established snake_case at persistence boundaries and camelCase DTOs in TypeScript.
- Route paths: lowercase kebab-case; version stable public contracts under `/api/vN`.

## Tests and docs

- Add a regression test for bug fixes and deterministic rule/cache changes.
- Prefer focused Node tests that do not require live services; add integration smoke checks separately.
- Update permanent context documents under the maintenance policy in `docs/README.md`.
