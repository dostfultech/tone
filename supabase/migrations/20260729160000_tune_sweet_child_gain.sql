-- Accuracy tuning: Sweet Child O' Mine (Guns N' Roses) riff.
--
-- Option-3 baseline validation (app master tone vs independently documented settings) found the
-- riff's baseline gain (6) sat 1-2 points hotter than the documented consensus for Slash's rhythm
-- tone ("keep gain relatively low, ~4-5, for clarity" — Guitar Chalk / Rigtone / mylespaul forum).
-- Everything else (treble 6, present un-scooped mids, bass 5) matched. Nudge gain 6 -> 5.
--
-- Done as a forward UPDATE (not an edit of the historical phase1 seed) so it applies whether or not
-- the phase1 verified-profiles migration has already run. Guarded on the current value so re-running
-- is a no-op and it never clobbers a later hand-tuned value.

update public.song_tone_profiles
set original_settings = jsonb_set(original_settings, '{gain}', '5'::jsonb),
    updated_at = now()
where artist_name = 'Guns N'' Roses'
  and song_title = 'Sweet Child O'' Mine'
  and part_type = 'riff'
  and (original_settings->>'gain')::numeric = 6;
