-- Upgrade Modern Baseball - "Your Graduation" (You're Gonna Miss It All, 2014)
-- from templated starter_estimate rows to researched admin_verified per-part tone data.
-- Emo/pop-punk revival: bright, jangly, overdriven twin-guitar sound (Fender
-- Starcaster/offset guitars into a Fender '68 Custom Twin Reverb with a JHS Morning
-- Glory transparent overdrive) over a driving punk bass. Gear per Equipboard band
-- research + the official audio (https://youtu.be/oEKFo5W9y3I).

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Modern Baseball','modern-baseball','Your Graduation','your-graduation','You''re Gonna Miss It All',2014)
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

-- Remove the existing starter_estimate profiles (and their child rows) for this song.
delete from public.tone_profile_effects e where e.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  where a.slug = 'modern-baseball' and s.slug = 'your-graduation'
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  where a.slug = 'modern-baseball' and s.slug = 'your-graduation'
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  where a.slug = 'modern-baseball' and s.slug = 'your-graduation'
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
    ('guitar','intro','clean intro jangle','clean',
     'emo/pop-punk','clean','beginner',
     'Fender Starcaster / offset electric guitar (Modern Baseball)','Fender 68 Custom Twin Reverb (clean)','Fender 2x12 combo','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":3,"delay":0,"master":5}'::jsonb,
     array['Bright, jangly clean intro with chiming open chords; let the notes ring and keep it lively.','Low gain, bright and chimey.'],
     array['Let the open chords ring out.','Keep the picking bright and even.'],
     'Studio recording, 2014 (You''re Gonna Miss It All). Modern Baseball open with a bright, jangly clean guitar figure through a Fender Twin Reverb.',72),
    ('guitar','rhythm','driving overdriven rhythm','crunch',
     'emo/pop-punk','rhythm','intermediate',
     'Fender Starcaster / offset electric guitar (Modern Baseball)','Fender 68 Custom Twin Reverb with JHS Morning Glory overdrive','Fender 2x12 combo','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Fast, driving emo-punk power chords with a bright, mid-forward overdrive; keep the strumming urgent and tight.','Medium gain from a transparent overdrive, not high gain.'],
     array['Strum the chords fast and driving.','Keep the right hand tight and energetic.'],
     'Studio recording, 2014. The verses and choruses drive on bright, overdriven emo-revival power chords (a transparent overdrive into a Fender Twin Reverb).',72),
    ('guitar','lead','jangly twin-guitar lead','crunch',
     'emo/pop-punk','lead','intermediate',
     'Fender Starcaster / offset electric guitar (Modern Baseball)','Fender 68 Custom Twin Reverb with light overdrive','Fender 2x12 combo','neck pickup',
     '[]'::jsonb,'{"gain":4,"bass":4,"mids":7,"treble":7,"presence":6,"reverb":3,"delay":1,"master":6}'::jsonb,
     array['Bright, jangly lead lines weaving over the rhythm guitar; keep them cutting and melodic.','Medium gain, mid-forward and bright for note clarity.'],
     array['Let the lead lines sing over the chords.','Pick cleanly so the melody cuts through.'],
     'Studio recording, 2014. Interlocking twin-guitar lead lines sit just above the driving rhythm, bright and jangly.',71),
    ('bass','bassline','driving punk bassline','bass_clean',
     'emo/pop-punk','rhythm','beginner',
     'Fender Precision-style bass (Modern Baseball)','Clean bass amp with a touch of grit','Bass cab (4x10 or 1x15)','passive split-coil',
     '[]'::jsonb,'{"gain":3,"bass":6,"mids":6,"treble":5,"presence":4,"reverb":0,"delay":0,"master":6}'::jsonb,
     array['Punchy, driving punk bassline that follows the guitars; keep it steady and propulsive with a little grit.','Mostly clean with a slight edge.'],
     array['Lock in with the drums and keep it driving.','Use a firm, even attack.'],
     'Studio recording, 2014. The bass drives the song with a punchy, propulsive punk feel underneath the guitars.',70)
) as c(mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
       original_guitar, original_amp, original_cab, original_pickup,
       original_effects, original_settings, adaptation_notes, playing_notes,
       source_summary, confidence)
join public.songs s on s.slug = 'your-graduation'
join public.artists a on a.id = s.artist_id and a.slug = 'modern-baseball';
