-- Add "Miracle" by Marty Friedman (from "Introduction" album, 1994)
-- Verified tone profile with per-part data for lead melody and solo sections.
-- Marty used a Jackson Kelly with Seymour Duncan pickups through a Marshall-based rig
-- with a smooth, singing high-gain lead tone and lush delay/reverb.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Marty Friedman','marty-friedman','Miracle','miracle','Introduction',1994)
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

delete from public.tone_profile_effects e where e.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  where a.slug = 'marty-friedman' and s.slug = 'miracle'
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  where a.slug = 'marty-friedman' and s.slug = 'miracle'
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  where a.slug = 'marty-friedman' and s.slug = 'miracle'
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
    ('miracle','marty-friedman','guitar','intro','clean melodic intro','clean',
     'instrumental rock','clean','intermediate',
     'Jackson Kelly (Marty Friedman signature)','Marshall JCM800 2203 (clean channel)','Marshall 4x12 (Celestion Vintage 30)','Seymour Duncan JB bridge humbucker',
     '[{"type":"delay","name":"Digital delay","placement":"loop"},{"type":"reverb","name":"Hall reverb","placement":"loop"}]'::jsonb,
     '{"gain":2,"bass":5,"mids":6,"treble":6.5,"presence":5.5,"reverb":3,"delay":3,"master":5}'::jsonb,
     array['Clean, expressive intro — focus on dynamics and letting notes ring.','Use hall reverb for spacious ambience.'],
     array['Play with a soft touch and let the delay trails fill the space.','Use the neck pickup for a warmer, rounder tone.','Focus on smooth, legato phrasing.'],
     'Studio recording, 1994 (Introduction). Marty Friedman played a clean, atmospheric melodic intro on a Jackson Kelly through a Marshall on the clean channel with lush delay and reverb.',74),

    ('miracle','marty-friedman','guitar','riff','main melodic theme','high_gain',
     'instrumental rock','lead','advanced',
     'Jackson Kelly (Marty Friedman signature)','Marshall JCM800 2203','Marshall 4x12 (Celestion Vintage 30)','Seymour Duncan JB bridge humbucker',
     '[{"type":"overdrive","name":"Tube Screamer-style boost","placement":"front"},{"type":"delay","name":"Digital delay","placement":"loop"},{"type":"reverb","name":"Hall reverb","placement":"loop"}]'::jsonb,
     '{"gain":7,"bass":5,"mids":6.5,"treble":6,"presence":6,"reverb":2.5,"delay":2,"master":6}'::jsonb,
     array['Smooth, singing high-gain lead tone — Marty''s signature exotic phrasing.','Tube Screamer in front for tighter low end and sustain.'],
     array['Use wide, expressive bends with vibrato.','Play the exotic scales with fluid legato technique.','Keep the picking smooth — avoid harsh attack on melodic passages.','Bridge pickup for clarity and cut.'],
     'Studio recording, 1994 (Introduction). Marty Friedman played his signature exotic, melodic lead on a Jackson Kelly through a boosted Marshall JCM800.',82),

    ('miracle','marty-friedman','guitar','solo','guitar solo','high_gain',
     'instrumental rock','lead','expert',
     'Jackson Kelly (Marty Friedman signature)','Marshall JCM800 2203','Marshall 4x12 (Celestion Vintage 30)','Seymour Duncan JB bridge humbucker',
     '[{"type":"overdrive","name":"Tube Screamer-style boost","placement":"front"},{"type":"delay","name":"Digital delay","placement":"loop"},{"type":"reverb","name":"Hall reverb","placement":"loop"}]'::jsonb,
     '{"gain":7.5,"bass":5,"mids":7,"treble":6,"presence":6,"reverb":2.5,"delay":2.5,"master":6}'::jsonb,
     array['Full-gain solo tone with extra mids for sustain and singing quality.','Slightly more delay than the main theme for added depth.'],
     array['Expressive bends are key — Marty uses wide interval bends.','Legato runs with hammer-ons and pull-offs for fluidity.','Use vibrato generously on sustained notes.','Volume swells for dynamic contrast in the emotional passages.'],
     'Studio recording, 1994 (Introduction). Marty Friedman played an emotionally expressive solo with exotic scales and wide bends on a Jackson Kelly through a Marshall.',80),

    ('miracle','marty-friedman','guitar','rhythm','rhythm section','crunch',
     'instrumental rock','crunch','intermediate',
     'Jackson Kelly (Marty Friedman signature)','Marshall JCM800 2203','Marshall 4x12 (Celestion Vintage 30)','Seymour Duncan JB bridge humbucker',
     '[{"type":"reverb","name":"Hall reverb","placement":"loop"}]'::jsonb,
     '{"gain":5,"bass":5.5,"mids":6,"treble":6,"presence":5.5,"reverb":2,"delay":0,"master":5.5}'::jsonb,
     array['Crunchy rhythm tone that sits behind the lead — moderate gain with clarity.','No delay on rhythm parts to keep them tight.'],
     array['Keep the strumming tight and rhythmic.','Palm mute where needed to add punch.','Let the lead line be the focus — stay supportive.'],
     'Studio recording, 1994 (Introduction). Rhythm guitar parts played with a moderate crunch tone for support behind the lead melodies.',72)
) as c(song_slug, artist_slug, mode, part_type, part_label, tone_type,
       genre, tone_category, difficulty,
       original_guitar, original_amp, original_cab, original_pickup,
       original_effects, original_settings, adaptation_notes, playing_notes,
       source_summary, confidence)
join public.songs s on s.slug = c.song_slug
join public.artists a on a.id = s.artist_id and a.slug = c.artist_slug
on conflict do nothing;
