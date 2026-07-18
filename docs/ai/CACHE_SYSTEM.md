# Cache System

`tone_adaptation_cache` stores a unique key/signature, schema/source/gear versions, selected gear/effect/direct labels, result JSON, source/confidence, hit count, last hit, and optional expiry.

`cache-key.ts` serializes normalized source and gear inputs deterministically. Tests require keys to differ for pickup position, pedal order, and MultiFX. Add every new tone-affecting input to the key and tests.

- Hit: return stored output and touch hit metadata.
- Expired: miss.
- Miss: run deterministic rules and upsert.
- Write failure: fail rather than return an unpersisted result.

Use versioned invalidation when semantics change. The separate iTunes `Map` cache is process-local, capped, and unrelated to tone results.
