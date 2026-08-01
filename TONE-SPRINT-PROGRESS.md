# Verified Tone Sprint — Progress Tracker

Deadline: Aug 1, 6 PM. Resume point for usage-limit interruptions — if the session stops, say "continue" and work resumes from the first unchecked item.

## Status

- [x] Batch 1 (Phase 42) — user requests + Weezer catalog + midwest emo (25 songs) — `20260731120000_phase42_verified_tone_profiles.sql`
- [x] Batch 2 (Phase 43) — pop-punk / emo deep cuts (25 songs) — `20260731130000_phase43_verified_tone_profiles.sql`
- [x] Batch 3 (Phase 44) — grunge / 90s alt deep cuts (25 songs) — `20260731140000_phase44_verified_tone_profiles.sql`
- [x] Batch 4 (Phase 45) — indie rock deep cuts (AM, Strokes, White Stripes, Interpol, Killers, Bloc Party, Vampire Weekend, YYYs — 25 songs) — `20260731150000_phase45_verified_tone_profiles.sql`
- [x] Batch 5 (Phase 46) — classic metal deep cuts (Metallica, Megadeth, Maiden, Priest, Pantera, Ozzy/Rhoads, Dio-era Sabbath, Slayer, Motorhead — 25 songs) — `20260731160000_phase46_verified_tone_profiles.sql`
- [x] Batch 6 (Phase 47) — viral/TikTok-era songs (Polyphia, bedroom pop, dream pop, jazz pop — 25 songs) — `20260731170000_phase47_verified_tone_profiles.sql`
- [x] Guard migration re-run — `20260731180000_guard_verified_profiles_phase42_47.sql`
- [x] Final audit — static integrity audit passed: 150 songs, 158 profiles, no duplicates, all JSON valid, settings in range
- [x] Commit + push
- [ ] Run migrations on Supabase
- [ ] Message .mr.toaster. (Go Away + Oakwood re-test) and aamesss

## Notes

- "Flutter" (tester said "by Claire") — artist unconfirmed, ASK TESTER which band before researching. Not in Batch 1.
- Quality bar: per-song researched or honestly-generic gear (never invented models), per-part settings, empty effects [] when recording used none, song-specific notes, honest confidence (68-85).
- Format: follow `20260725240000_phase12_verified_tone_profiles.sql` exactly (target CTE → delete effects/sources/profiles → insert admin_verified).
