-- Accuracy tuning: Iron Man (Black Sabbath) riff.
--
-- Option-3 baseline validation (15-song batch) flagged the riff's baseline treble (5) as ~1.5-2
-- below documented consensus (6-7) for Tony Iommi's Iron Man rig — a Rangemaster treble booster
-- into a Laney with presence/middle/treble pushed and bass near zero; Iommi is repeatedly described
-- as "always searching for more treble." It was also internally inconsistent with the app's own
-- Paranoid baseline (treble 6) for the SAME Laney + treble-booster rig. Nudge treble 5 -> 6.
-- (Gain 6 was noted as slightly under the ~7-8 consensus but kept — defensible on a master scale.)
--
-- Forward UPDATE (not an edit of the historical seed) so it applies whether or not the phase1
-- verified-profiles migration has run; guarded on the current value so re-running is a no-op.
--
-- Sources: Guitar World "Tonal Recall" (Iron Man); Guitar Space Black Sabbath settings;
-- MusicStrive Tony Iommi settings.

update public.song_tone_profiles
set original_settings = jsonb_set(original_settings, '{treble}', '6'::jsonb),
    updated_at = now()
where artist_name = 'Black Sabbath'
  and song_title = 'Iron Man'
  and part_type = 'riff'
  and (original_settings->>'treble')::numeric = 5;
