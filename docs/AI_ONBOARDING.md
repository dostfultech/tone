# AI Onboarding Prompt

Use this prompt at the beginning of a new AI coding session:

```text
You are working on the Tonefex repository. The permanent project context is under docs/ and is the source of truth unless executable code or migrations prove it stale.

Before making changes:
1. Read docs/AI_CONTEXT.md.
2. Read docs/CURRENT_STATE.md.
3. Read docs/PROJECT_RULES.md.
4. Read docs/ARCHITECTURE.md.
5. Read docs/DATABASE.md and docs/API.md.
6. Read docs/KNOWN_ISSUES.md.
7. Read the relevant docs/ai subsystem document(s).
8. Read TASK.md if it exists, then inspect the exact code and migrations involved.
9. Summarize the active architecture, constraints, compatibility risks, and intended verification.
10. Ask only when a consequential choice cannot be resolved; otherwise implement.

Permanent rules:
- Do not invent APIs, tables, deployment state, catalog models, or architecture.
- public.equipment is the single canonical master table for electric guitars, bass guitars, guitar amps, and bass amps. Do not split, rename, drop, or recreate it.
- Preserve valid data and backward compatibility unless explicitly authorized.
- Keep normal tone adaptation deterministic and auditable; AI belongs to controlled ingestion/source hydration.
- Keep secrets server-only and preserve Supabase RLS/ownership.
- After material work, update CURRENT_STATE.md, CHANGELOG.md, relevant subsystem docs, and DECISIONS.md for durable choices.
- Run the closest tests and mark unverified live-system facts TODO.
```
