-- Phase 92: fulfill open song_requests with researched verified tones (2026-08-06).
-- Demand from song_requests: I Wanna Be Yours (Arctic Monkeys, 12 votes),
-- Beggin' (Måneskin), Bad (Michael Jackson), Rowdy Baby (Dhanush & Dhee).
-- Rigs researched 2026-08-06: Mixdown/Equipboard (AM sessions), Sound on Sound
-- Inside Track (Beggin' — Fender Pro Reverb confirmed), David Williams session
-- documentation (Bad), Rowdy Baby is an adaptation (original hook is nadaswaram/synth).
begin;

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Arctic Monkeys','arctic-monkeys','I Wanna Be Yours','i-wanna-be-yours','AM',2013),
    ('Måneskin','maneskin','Beggin''','beggin','Chosen',2017),
    ('Michael Jackson','michael-jackson','Bad','bad','Bad',1987),
    ('Dhanush & Dhee','dhanush-dhee','Rowdy Baby','rowdy-baby','Maari 2',2018)
),
ins_artists as (
  insert into public.artists (name, slug, search_text, is_active)
  select distinct artist_name, artist_slug, artist_name, true from target
  on conflict (slug) do update set name = excluded.name, is_active = true
  returning id, slug
)
insert into public.songs (artist_id, title, slug, album, release_year, search_text, is_active)
select a.id, t.song_title, t.song_slug, t.album, t.release_year,
       concat_ws(' ', t.song_title, t.artist_name, t.album), true
from target t join ins_artists a on a.slug = t.artist_slug
on conflict (artist_id, slug) do update set
  title = excluded.title, album = excluded.album, release_year = excluded.release_year,
  is_active = true, updated_at = now();

-- Replace any existing guitar profiles for these songs (starter estimates)
delete from public.tone_profile_effects e where e.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('arctic-monkeys','i-wanna-be-yours'),('maneskin','beggin'),
    ('michael-jackson','bad'),('dhanush-dhee','rowdy-baby')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
  where p.mode = 'guitar'
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('arctic-monkeys','i-wanna-be-yours'),('maneskin','beggin'),
    ('michael-jackson','bad'),('dhanush-dhee','rowdy-baby')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
  where p.mode = 'guitar'
);
delete from public.song_tone_profiles p where p.mode = 'guitar' and p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('arctic-monkeys','i-wanna-be-yours'),('maneskin','beggin'),
    ('michael-jackson','bad'),('dhanush-dhee','rowdy-baby')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);

insert into public.song_tone_profiles (
  song_id, song_title, artist_name, mode, part_type, part_label, tone_type,
  genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes,
  source_summary, confidence, verification_status, search_text, is_public
)
select
  s.id, s.title, a.name, c.mode, c.part_type, c.part_label, c.tone_type,
  c.genre, c.tone_category, c.difficulty,
  c.original_guitar, c.original_amp, c.original_cab, c.original_pickup,
  c.original_effects, c.original_settings, c.adaptation_notes, c.playing_notes,
  c.source_summary, c.confidence, 'admin_verified',
  concat_ws(' ', s.title, a.name, c.part_label, c.tone_type, c.original_guitar, c.original_amp, 'researched verified tone'),
  true
from (
  values
    ('i-wanna-be-yours','arctic-monkeys','guitar','chorus','dreamy reverb + tremolo swells','clean','indie rock','clean','beginner',
     'Gibson Les Paul Custom (Alex Turner, AM sessions)','Selmer Zodiac Twin 30 (built-in tremolo + reverb)','Selmer 2x12 combo','neck humbucker, tone rolled back',
     '[]'::jsonb,'{"gain":2.5,"bass":6,"mids":5,"treble":4,"presence":3,"reverb":8,"delay":4,"master":6}'::jsonb,
     array['Verses are drum machine, bass and keys — guitar enters with sustained clean-edge swells drenched in reverb and slow tremolo.','Set amp tremolo slow and deep; neck humbucker with tone rolled back gets the dark round AM voice.'],
     array['Let chords swell in — volume knob or light attack.','Slow tremolo pulse should breathe with the drum machine.'],
     'AM sessions gear documented via Mixdown gear rundown + Equipboard; Selmer Zodiac Twin 30 is the AM signature amp.',72),
    ('i-wanna-be-yours','arctic-monkeys','guitar','lead','emotive outro bends','clean','indie rock','lead','intermediate',
     'Gibson Les Paul Custom (Alex Turner, AM sessions)','Selmer Zodiac Twin 30 (built-in tremolo + reverb)','Selmer 2x12 combo','neck humbucker',
     '[]'::jsonb,'{"gain":3,"bass":6,"mids":5,"treble":4,"presence":3,"reverb":8,"delay":4,"master":6}'::jsonb,
     array['The outro lead answers the vocal — full-step bends with wide vibrato, still clean with huge reverb.','Slightly more input gain than the chorus swells so bends bloom into light breakup.'],
     array['Bends must land in tune — slow full-step bends with vibrato on top.','Leave space; the line is a conversation with the vocal.'],
     'AM sessions gear documented via Mixdown gear rundown + Equipboard.',70),
    ('beggin','maneskin','guitar','rhythm','funk clean 16th-note stabs','clean','funk rock','clean','intermediate',
     'Squier/Fender Stratocaster (Thomas Raggi, early era)','Fender Pro Reverb (mic''d SM57 + Royer R-122)','Fender 2x12 combo','bridge + middle single coils',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Tracked live with no pedals — pure Strat into Fender Pro Reverb (confirmed by the Sound on Sound Inside Track feature).','Percussive 16th-note funk scratch: muting discipline is the whole tone.'],
     array['Keep the fretting hand muting between stabs.','Lock to the hi-hat 16ths; ghost strums stay silent.'],
     'Sound on Sound Inside Track: Måneskin ''Beggin'''' — amp and live tracking confirmed by engineer Alessandro Marcantoni.',78),
    ('beggin','maneskin','guitar','chorus','pushed-amp crunch stabs','crunch','funk rock','crunch','intermediate',
     'Squier/Fender Stratocaster (Thomas Raggi, early era)','Fender Pro Reverb, pushed','Fender 2x12 combo','bridge single coil',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":3,"delay":0,"master":7}'::jsonb,
     array['Chorus grit is the same amp pushed harder — light crunch that stays articulate, never high-gain.','Dig in with the pick for the extra hair instead of adding pedals.'],
     array['Accent beats with full chord stabs, then choke.','Dynamics carry the lift from verse to chorus.'],
     'Sound on Sound Inside Track: Måneskin ''Beggin'''' — same live rig, pushed harder.',74),
    ('bad','michael-jackson','guitar','riff','tight funk scratch riff','clean','funk','clean','advanced',
     'Strat-style (David Williams, MJ session guitarist)','Roland JC-120 clean','JC-120 2x12 combo','bridge + middle single coils',
     '[]'::jsonb,'{"gain":1.5,"bass":3.5,"mids":5,"treble":7,"presence":6,"reverb":1.5,"delay":0,"master":6}'::jsonb,
     array['David Williams'' ultra-clean percussive scratch layer sits over Synclavier synth bass — thin, tight and bone dry.','Add a compressor if available; the studio sound is heavily compressed and gated.'],
     array['The notes are simple; the pocket is everything.','Consistent 16th-note wrist motion with most strums muted.'],
     'David Williams credited on Bad (album liner notes); JC-120 clean rig documented from his MJ session work.',72),
    ('rowdy-baby','dhanush-dhee','guitar','riff','nadaswaram hook adaptation (clean lead)','clean','kuthu folk-pop','clean','intermediate',
     'Any clean electric — adaptation (original hook is nadaswaram/synth, no guitar on the record)','Clean combo with mid-forward voicing','Combo speaker','neck single coil',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":6.5,"treble":5.5,"presence":4,"reverb":4,"delay":2,"master":6}'::jsonb,
     array['ADAPTATION: the original Maari 2 track has no guitar — the hook is a nadaswaram-flavored lead over kuthu percussion.','Mid-forward clean with short slap delay imitates the reedy lead; slides and grace-note ornaments imitate gamakam.'],
     array['Learn the hook vocally first, then phrase it with slides between notes.','Verse chops: muted clean chords locked to the kuthu beat.'],
     'No guitar on the original recording (Yuvan Shankar Raja production) — profile is a researched guitar adaptation, labeled as such.',55)
) as c(song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
       original_guitar, original_amp, original_cab, original_pickup,
       original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;

-- Mark the matching open requests fulfilled
update public.song_requests
set status = 'fulfilled', updated_at = now()
where status = 'open'
  and (
    (song_title ilike 'I Wanna Be Yours' and artist_name ilike '%Arctic Monkeys%') or
    (song_title ilike 'Beggin%' and artist_name ilike '%neskin%') or
    (song_title ilike 'Bad' and artist_name ilike '%Michael Jackson%') or
    (song_title ilike 'Rowdy Baby')
  );

-- Post-conditions
do $$
declare
  n int;
begin
  select count(*) into n
  from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id
  join public.artists a on a.id = s.artist_id
  where p.verification_status = 'admin_verified'
    and (a.slug, s.slug) in (('arctic-monkeys','i-wanna-be-yours'),('maneskin','beggin'),
                             ('michael-jackson','bad'),('dhanush-dhee','rowdy-baby'));
  if n <> 6 then
    raise exception 'POST-CONDITION FAILED: expected 6 verified profiles for requested songs, got %', n;
  end if;

  select count(*) into n from public.song_requests
  where status = 'open'
    and (song_title ilike 'I Wanna Be Yours' or song_title ilike 'Beggin%'
         or (song_title ilike 'Bad' and artist_name ilike '%Jackson%') or song_title ilike 'Rowdy Baby');
  if n > 0 then
    raise exception 'POST-CONDITION FAILED: % matching song_requests still open', n;
  end if;
end $$;

commit;
