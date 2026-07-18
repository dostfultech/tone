# Testing

## Automated strategy

The project uses Node's built-in test runner. Each script compiles only the relevant TypeScript graph into an OS temporary directory, then runs the emitted test file.

| Command | Coverage |
|---|---|
| `npm run test:rule-engine` | Stage order, immutability, guitar/pickup/amp/cab/pedal/direct/MultiFX deltas, conflicts, logging, no-AI metadata. |
| `npm run test:backend` | Cache hits/misses/keys/writes, source timing, optional source hydration, unresolved gear labels/effect metadata. |
| `npm run test:ai-ingestion` | Queue behavior, immediate generation, worker storage, database-only ingestion scope, cache prewarming. |
| `node scripts/validate-equipment-catalog.mjs` | Seed parse/counts, supported types, duplicates and required catalog metadata. |
| `npx tsc -p tsconfig.json --noEmit` | Whole-repository typecheck. |
| `npm run build` | Next.js production compilation and route rendering checks. |

## Current caveat

The full typecheck has known test fixture drift around required `requestSource`; see `KNOWN_ISSUES.md`. Do not suppress it globally. Update fixtures or contract defaults deliberately.

## Manual smoke tests

1. Sign up, login, OAuth callback, reset password, logout, and protected-route redirect.
2. Search guitar, bass guitar, guitar amp, bass amp, pedal, and MultiFX selectors; verify empty/query/results/autosave/reload behavior.
3. Run free manual generation, paid adapt-to-my-gear, and saved-tone re-adaptation; verify quota changes exactly once.
4. Repeat an identical adaptation and verify cache-hit source; change pickup position/pedal order/MultiFX and verify a miss/new key.
5. Save and reopen a tone; inspect library and community flows.
6. Test Beginner/Expert checkout, success return, webhook subscription update, portal, and cancellation state.
7. Verify non-admin denial and admin/worker access for every ingestion action.
8. Submit contact feedback and activity events; confirm bounds and ownership.
9. Test desktop/mobile layouts and accessibility basics.

## Production checklist

- All focused tests, full typecheck, build, and catalog validation pass.
- Migrations apply cleanly to staging; no unexpected drops/data loss.
- RLS/advisors and service-role boundaries are reviewed.
- Search relevance and duplicate queries are spot-checked with real models.
- Secrets, callback URLs, Dodo webhook signature, and canonical host are verified.
- Cache/source telemetry and ingestion failures are observable.
- `CURRENT_STATE.md` and `CHANGELOG.md` record the release.
