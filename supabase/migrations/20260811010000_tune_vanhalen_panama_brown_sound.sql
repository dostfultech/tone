-- Tester-validated tune (aamesss, Van Halen "Panama" control test): the adapted result ran
-- too crunchy + too bassy for the "brown sound". Van Halen's Plexi tone is power-amp driven,
-- mid-forward and TIGHT — not high-preamp-gain or bass-heavy. Nudge the verified profile to
-- the truer values (gain 7 -> 6, bass 5 -> 4); other bands already fit (mids 6, treble 7,
-- presence 6). Merge-update so the rest of original_settings is untouched.
begin;

update public.song_tone_profiles
set original_settings = original_settings || '{"gain":6,"bass":4}'::jsonb,
    updated_at = now()
where id = '5ca637f2-7167-42be-baa0-6a13127c37d1'
  and song_title = 'Panama' and artist_name = 'Van Halen';

do $$
declare g int; b int;
begin
  select (original_settings->>'gain')::int, (original_settings->>'bass')::int into g, b
  from public.song_tone_profiles where id = '5ca637f2-7167-42be-baa0-6a13127c37d1';
  if g <> 6 or b <> 4 then raise exception 'Panama tune did not apply (gain=%, bass=%)', g, b; end if;
end $$;

commit;
