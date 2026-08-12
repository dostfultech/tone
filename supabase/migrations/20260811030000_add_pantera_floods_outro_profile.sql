-- Add a verified OUTRO profile for Pantera "Floods" (tester aamesss asked for the outro but
-- only the solo existed, so he got a too-hot, no-modulation solo tone). The outro is the
-- neck-pickup, arpeggiated/orchestrated melodic section: moderate gain (let-ring must stay
-- defined) with chorus + delay central to it. Sources: Guitar World (Dimebag Darrell, Floods
-- outro) — neck pickup, Randall RG100ES, MXR 6-band EQ, chorus + reverb + delay, doubled theme.
begin;

-- The part_type CHECK constraint didn't allow 'outro' (a legitimate song section). Widen it
-- (also add 'verse' for future profiles) so the outro can be stored as its own part.
alter table public.song_tone_profiles drop constraint if exists song_tone_profiles_part_type_check;
alter table public.song_tone_profiles add constraint song_tone_profiles_part_type_check
  check (part_type in ('main','riff','solo','lead','rhythm','intro','chorus','bridge','bassline','outro','verse'));

insert into public.song_tone_profiles (
  id, song_id, song_title, artist_name, mode, part_type, part_label, tone_type,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes,
  source_summary, confidence, verification_status, is_public
)
select
  gen_random_uuid(), 'be9bbb9f-8e4b-4d1e-b103-23516a91e9f8', 'Floods', 'Pantera', 'guitar', 'outro',
  'Outro solo (neck pickup, arpeggiated)', 'high_gain',
  'Washburn Dime 333 (Dimebag Darrell)', 'Randall RG100ES', 'Randall 4x12',
  'Neck humbucker (roll to the neck pickup for the outro theme)',
  '[{"effect_type":"modulation","effect_name":"chorus","placement":"post_gain","settings":{"mix":4,"depth":3,"rate":3}},{"effect_type":"delay","effect_name":"delay","placement":"post_gain","settings":{"mix":4,"feedback":3,"time":5}}]'::jsonb,
  '{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"master":6,"reverb":3,"delay":0}'::jsonb,
  array[
    'Neck pickup, moderate gain so the arpeggiated outro theme stays defined, not saturated',
    'Chorus and delay carry the ambient, orchestrated outro; keep them audible',
    'Double the arpeggiated theme (Randy Rhoads style) for width'
  ],
  array[
    'Roll to the neck pickup for the arpeggiated outro theme',
    'Keep gain moderate so the let-ring chords stay clear; they get dirty fast if pushed',
    'Delay and chorus are central to the outro; set delay to a dotted-eighth or quarter feel'
  ],
  'Web-sourced: Guitar World (Dimebag Darrell, Floods outro): neck pickup, Randall RG100ES, MXR 6-band EQ, chorus + reverb + delay, doubled arpeggiated theme. Moderate gain; the existing solo profile (gain 7) ran too hot for the outro let-ring.',
  82, 'admin_verified', true
where not exists (
  select 1 from public.song_tone_profiles
  where song_title = 'Floods' and artist_name = 'Pantera' and part_type = 'outro'
);

do $$
declare n int;
begin
  select count(*) into n from public.song_tone_profiles
   where song_title = 'Floods' and artist_name = 'Pantera' and part_type = 'outro' and verification_status = 'admin_verified';
  if n < 1 then raise exception 'Floods outro profile not created'; end if;
end $$;

commit;
