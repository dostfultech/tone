-- Tester-validated (aamesss): the Pantera "Floods" SOLO adapted with treble too low (5.5);
-- he lands at ~8 by ear, which matches the real tone — Dimebag's whammy-drenched bridge-pickup
-- lead through a bright Randall solid-state + MXR 6-band EQ is very treble-forward. Raise the
-- verified solo profile's treble 6 -> 8. Mids left as-is (his lower-mids tweak was preference).
begin;

update public.song_tone_profiles
set original_settings = original_settings || '{"treble":8}'::jsonb,
    updated_at = now()
where id = 'e3b0c57d-80ce-4884-8f0a-b740f1cae7e3'
  and song_title = 'Floods' and artist_name = 'Pantera' and part_type = 'solo';

do $$
declare t int;
begin
  select (original_settings->>'treble')::int into t
  from public.song_tone_profiles where id = 'e3b0c57d-80ce-4884-8f0a-b740f1cae7e3';
  if t <> 8 then raise exception 'Floods solo treble not updated (treble=%)', t; end if;
end $$;

commit;
