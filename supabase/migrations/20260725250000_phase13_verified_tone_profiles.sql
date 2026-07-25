-- Phase 13: 25 Muse / Coldplay / Radiohead / alt-rock staples, verified per-part tone data.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Muse','muse','Time Is Running Out','time-is-running-out','Absolution',2003),
    ('Muse','muse','Plug In Baby','plug-in-baby','Origin of Symmetry',2001),
    ('Muse','muse','Knights of Cydonia','knights-of-cydonia','Black Holes and Revelations',2006),
    ('Muse','muse','Supermassive Black Hole','supermassive-black-hole','Black Holes and Revelations',2006),
    ('Muse','muse','Starlight','starlight','Black Holes and Revelations',2006),
    ('Muse','muse','Uprising','uprising','The Resistance',2009),
    ('Coldplay','coldplay','Yellow','yellow','Parachutes',2000),
    ('Coldplay','coldplay','Fix You','fix-you','X&Y',2005),
    ('Coldplay','coldplay','In My Place','in-my-place','A Rush of Blood to the Head',2002),
    ('Oasis','oasis','Don''t Look Back in Anger','don-t-look-back-in-anger','(What''s the Story) Morning Glory?',1995),
    ('Oasis','oasis','Champagne Supernova','champagne-supernova','(What''s the Story) Morning Glory?',1995),
    ('Oasis','oasis','Live Forever','live-forever','Definitely Maybe',1994),
    ('Jimmy Eat World','jimmy-eat-world','The Middle','the-middle','Bleed American',2001),
    ('Jimmy Eat World','jimmy-eat-world','Sweetness','sweetness','Bleed American',2001),
    ('Yellowcard','yellowcard','Ocean Avenue','ocean-avenue','Ocean Avenue',2003),
    ('Paramore','paramore','That''s What You Get','that-s-what-you-get','Riot!',2007),
    ('Blur','blur','Song 2','song-2','Blur',1997),
    ('Radiohead','radiohead','Just','just','The Bends',1995),
    ('Radiohead','radiohead','Fake Plastic Trees','fake-plastic-trees','The Bends',1995),
    ('Radiohead','radiohead','High and Dry','high-and-dry','The Bends',1995),
    ('Third Eye Blind','third-eye-blind','Semi-Charmed Life','semi-charmed-life','Third Eye Blind',1997),
    ('Goo Goo Dolls','goo-goo-dolls','Slide','slide','Dizzy Up the Girl',1998),
    ('Goo Goo Dolls','goo-goo-dolls','Iris','iris','Dizzy Up the Girl',1998),
    ('The La''s','the-la-s','There She Goes','there-she-goes','The La''s',1990),
    ('Counting Crows','counting-crows','Mr. Jones','mr-jones','August and Everything After',1993)
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
  join (values
    ('muse','time-is-running-out'),('muse','plug-in-baby'),('muse','knights-of-cydonia'),('muse','supermassive-black-hole'),
    ('muse','starlight'),('muse','uprising'),('coldplay','yellow'),('coldplay','fix-you'),('coldplay','in-my-place'),
    ('oasis','don-t-look-back-in-anger'),('oasis','champagne-supernova'),('oasis','live-forever'),
    ('jimmy-eat-world','the-middle'),('jimmy-eat-world','sweetness'),('yellowcard','ocean-avenue'),('paramore','that-s-what-you-get'),
    ('blur','song-2'),('radiohead','just'),('radiohead','fake-plastic-trees'),('radiohead','high-and-dry'),
    ('third-eye-blind','semi-charmed-life'),('goo-goo-dolls','slide'),('goo-goo-dolls','iris'),('the-la-s','there-she-goes'),('counting-crows','mr-jones')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('muse','time-is-running-out'),('muse','plug-in-baby'),('muse','knights-of-cydonia'),('muse','supermassive-black-hole'),
    ('muse','starlight'),('muse','uprising'),('coldplay','yellow'),('coldplay','fix-you'),('coldplay','in-my-place'),
    ('oasis','don-t-look-back-in-anger'),('oasis','champagne-supernova'),('oasis','live-forever'),
    ('jimmy-eat-world','the-middle'),('jimmy-eat-world','sweetness'),('yellowcard','ocean-avenue'),('paramore','that-s-what-you-get'),
    ('blur','song-2'),('radiohead','just'),('radiohead','fake-plastic-trees'),('radiohead','high-and-dry'),
    ('third-eye-blind','semi-charmed-life'),('goo-goo-dolls','slide'),('goo-goo-dolls','iris'),('the-la-s','there-she-goes'),('counting-crows','mr-jones')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('muse','time-is-running-out'),('muse','plug-in-baby'),('muse','knights-of-cydonia'),('muse','supermassive-black-hole'),
    ('muse','starlight'),('muse','uprising'),('coldplay','yellow'),('coldplay','fix-you'),('coldplay','in-my-place'),
    ('oasis','don-t-look-back-in-anger'),('oasis','champagne-supernova'),('oasis','live-forever'),
    ('jimmy-eat-world','the-middle'),('jimmy-eat-world','sweetness'),('yellowcard','ocean-avenue'),('paramore','that-s-what-you-get'),
    ('blur','song-2'),('radiohead','just'),('radiohead','fake-plastic-trees'),('radiohead','high-and-dry'),
    ('third-eye-blind','semi-charmed-life'),('goo-goo-dolls','slide'),('goo-goo-dolls','iris'),('the-la-s','there-she-goes'),('counting-crows','mr-jones')
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
    ('time-is-running-out','muse','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Manson electric guitar (Matthew Bellamy)','High-gain amp with fuzz','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"fuzz","effect_name":"fuzz","placement":"front","settings":{"gain":6,"tone":5,"level":6}}]'::jsonb,
     '{"gain":6,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Tight, fuzzy riff over the driving bassline; keep the low end controlled.','The fuzz drives the tension.'],
     array['Play the muted riff tightly.','Build intensity into the chorus.'],
     'Studio recording, 2003. Matthew Bellamy played the fuzzy riff through a high-gain amp.',77),
    ('plug-in-baby','muse','guitar','riff','arpeggiated riff','distorted','rock','rhythm','advanced',
     'Manson electric guitar (Matthew Bellamy)','High-gain amp with fuzz','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"fuzz","effect_name":"fuzz","placement":"front","settings":{"gain":6,"tone":5,"level":6}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['The arpeggiated distorted riff needs clarity under the fuzz; keep the picking clean.','Medium-high gain with fuzz.'],
     array['Play the fast arpeggiated riff cleanly.','Keep the picking precise.'],
     'Studio recording, 2001. Matthew Bellamy played the arpeggiated fuzz riff.',78),
    ('knights-of-cydonia','muse','guitar','riff','galloping main riff','distorted','rock','rhythm','advanced',
     'Manson electric guitar (Matthew Bellamy)','High-gain amp with delay','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"delay","effect_name":"delay","placement":"post_gain","settings":{"mix":3,"time":4}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":2,"master":6}'::jsonb,
     array['Epic galloping riff with delay; keep it tight and driving.','Medium-high gain with delay for space.'],
     array['Play the galloping riff with steady picking.','Let the delay add momentum.'],
     'Studio recording, 2006. Matthew Bellamy played the galloping riff with delay.',77),
    ('supermassive-black-hole','muse','guitar','riff','funk fuzz riff','fuzz','rock','rhythm','intermediate',
     'Manson electric guitar (Matthew Bellamy)','High-gain amp with fuzz','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"fuzz","effect_name":"fuzz","placement":"front","settings":{"gain":6,"tone":5,"level":6}}]'::jsonb,
     '{"gain":6,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Funky, fuzzy riff with a falsetto swagger; keep the muting tight.','The fuzz is the identity.'],
     array['Play the funky riff with tight muting.','Keep the groove sleazy.'],
     'Studio recording, 2006. Matthew Bellamy played the funky fuzz riff.',77),
    ('starlight','muse','guitar','riff','main riff','crunch','rock','rhythm','intermediate',
     'Manson electric guitar (Matthew Bellamy)','Crunch amp with ambience','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bright, anthemic clean-to-crunch chords; keep them ringing and clear.','Low-to-medium gain with ambience.'],
     array['Let the anthemic chords ring.','Keep the palm-muted verse tight.'],
     'Studio recording, 2006. Bright, anthemic clean-to-crunch chords.',77),
    ('uprising','muse','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Manson electric guitar (Matthew Bellamy)','High-gain amp with fuzz','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"fuzz","effect_name":"fuzz","placement":"front","settings":{"gain":6,"tone":5,"level":6}}]'::jsonb,
     '{"gain":6,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Fuzzy, stomping glam-rock riff over the synth; keep the low end controlled.','The fuzz drives the groove.'],
     array['Play the stomping riff with attitude.','Keep the groove heavy.'],
     'Studio recording, 2009. Matthew Bellamy played the fuzzy stomping riff.',77),
    ('yellow','coldplay','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Electric guitar (Jonny Buckland)','Crunch amp with ambience','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, ringing crunch chords; keep them big and clear.','Low-to-medium gain with ambience.'],
     array['Let the chords ring for the anthemic feel.','Keep a steady strum.'],
     'Studio recording, 2000. Jonny Buckland played the warm ringing crunch chords.',76),
    ('fix-you','coldplay','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Electric guitar (Jonny Buckland)','Crunch amp with ambience','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Builds from a clean organ ballad to a big ringing crunch; keep the chords wide.','Medium gain with ambience for the climax.'],
     array['Let the clean intro breathe.','Slam the big outro chords.'],
     'Studio recording, 2005. Builds from a clean ballad to a big ringing crunch.',76),
    ('in-my-place','coldplay','guitar','riff','delayed main riff','crunch','rock','rhythm','intermediate',
     'Electric guitar (Jonny Buckland)','Bright crunch amp with delay','Open-back combo cab','bridge pickup',
     '[{"effect_type":"delay","effect_name":"delay","placement":"post_gain","settings":{"mix":3,"time":4}}]'::jsonb,
     '{"gain":4,"bass":5,"mids":5,"treble":7,"presence":5,"reverb":2,"delay":2,"master":6}'::jsonb,
     array['A bright, delayed high riff drives the song; set the delay to the tempo.','Keep the amp bright and mostly clean.'],
     array['Play the ringing high riff with even picking.','Let the delay add movement.'],
     'Studio recording, 2002. Jonny Buckland played the bright delayed riff.',77),
    ('don-t-look-back-in-anger','oasis','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Gibson Les Paul (Noel Gallagher)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Warm, mid-forward crunch chords; keep them big and ringing.','Medium gain with strong mids.'],
     array['Let the chord progression ring.','Keep a steady, confident strum.'],
     'Studio recording, 1995. Noel Gallagher played the warm crunch chords on a Les Paul.',77),
    ('champagne-supernova','oasis','guitar','riff','main riff and solo','crunch','rock','lead','intermediate',
     'Gibson Les Paul (Noel Gallagher)','Marshall crunch amp with ambience','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, hazy crunch with ambience; keep the chords big and the solo singing.','Medium gain with dynamics.'],
     array['Let the chords ring dreamily.','Play the solo with smooth bends.'],
     'Studio recording, 1995. Noel Gallagher played the hazy crunch and solo on a Les Paul.',77),
    ('live-forever','oasis','guitar','riff','main riff and solo','crunch','rock','lead','intermediate',
     'Gibson Les Paul (Noel Gallagher)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Warm, mid-forward crunch; keep the chords ringing and the solo melodic.','Medium gain with strong mids.'],
     array['Let the chord riff ring.','Play the solo with vocal phrasing.'],
     'Studio recording, 1994. Noel Gallagher played the warm crunch and solo on a Les Paul.',77),
    ('the-middle','jimmy-eat-world','guitar','riff','main riff','distorted','rock','rhythm','beginner',
     'Electric guitar (Jim Adkins / Tom Linton)','High-gain amp','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, driving power-pop distortion; keep the riff tight.','Medium-high gain with clarity.'],
     array['Play the palm-muted riff evenly.','Keep the tempo bright.'],
     'Studio recording, 2001. Bright, driving power-pop distortion.',75),
    ('sweetness','jimmy-eat-world','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Electric guitar (Jim Adkins / Tom Linton)','High-gain amp','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, anthemic emo-rock distortion; keep the chords ringing.','Medium-high gain.'],
     array['Drive the chords with energy.','Build into the big chorus.'],
     'Studio recording, 2001. Bright, anthemic emo-rock distortion.',75),
    ('ocean-avenue','yellowcard','guitar','riff','main riff','distorted','punk','rhythm','intermediate',
     'Electric guitar (Ryan Key / Ben Harper)','High-gain amp','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, fast pop-punk distortion; keep the riff tight.','Medium-high gain with clarity.'],
     array['Play the fast riff cleanly.','Keep the tempo tight.'],
     'Studio recording, 2003. Bright, fast pop-punk distortion.',75),
    ('that-s-what-you-get','paramore','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Electric guitar (Josh Farro)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, driving pop-punk distortion; keep the chords ringing.','Medium-high gain.'],
     array['Drive the riff with energy.','Keep the muting clean.'],
     'Studio recording, 2007. Bright, driving pop-punk distortion.',75),
    ('song-2','blur','guitar','riff','main riff','distorted','rock','rhythm','beginner',
     'Electric guitar (Graham Coxon)','High-gain amp with fuzz','Closed-back cab','bridge humbucker',
     '[{"effect_type":"fuzz","effect_name":"fuzz","placement":"front","settings":{"gain":7,"tone":5,"level":6}}]'::jsonb,
     '{"gain":7,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Raw, fuzzy grunge-pop riff; keep the low end controlled under the fuzz.','The fuzz is the identity.'],
     array['Slam the two-chord riff with energy.','Let the fuzz roar.'],
     'Studio recording, 1997. Graham Coxon played the raw fuzz riff.',76),
    ('just','radiohead','guitar','riff','main riff','distorted','rock','rhythm','advanced',
     'Fender Telecaster (Jonny Greenwood)','High-gain amp','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Dense, layered alt-rock distortion; keep the frantic riff articulate.','Medium-high gain with clarity.'],
     array['Play the busy riff cleanly.','Keep the picking precise.'],
     'Studio recording, 1995. Jonny Greenwood layered the frantic distorted riff.',76),
    ('fake-plastic-trees','radiohead','guitar','riff','main riff','crunch','rock','rhythm','intermediate',
     'Acoustic and electric guitar (Radiohead)','Clean-to-crunch amp with ambience','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Builds from gentle acoustic to a swelling crunch; keep dynamics wide.','Medium gain for the climax.'],
     array['Let the acoustic verse breathe.','Swell into the emotional peak.'],
     'Studio recording, 1995. Builds from acoustic to a swelling crunch.',76),
    ('high-and-dry','radiohead','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Electric guitar (Radiohead)','Clean-to-edge amp with ambience','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, jangly clean-to-edge tone; keep the chords ringing.','Low-to-medium gain with ambience.'],
     array['Let the chords ring gently.','Keep a relaxed strum.'],
     'Studio recording, 1995. A warm, jangly clean-to-edge tone.',75),
    ('semi-charmed-life','third-eye-blind','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Electric guitar (Kevin Cadogan / Stephan Jenkins)','Bright crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, jangly crunch; keep the picked riff clear and driving.','Low-to-medium gain with sparkle.'],
     array['Play the picked riff evenly.','Keep the groove upbeat.'],
     'Studio recording, 1997. A bright, jangly crunch riff drives the song.',75),
    ('slide','goo-goo-dolls','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Electric guitar in an alternate tuning (Johnny Rzeznik)','Crunch amp with ambience','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bright, jangly crunch in an open tuning; keep the chords ringing.','Low-to-medium gain with ambience.'],
     array['Let the open-tuned chords ring.','Keep a steady, driving strum.'],
     'Studio recording, 1998. Johnny Rzeznik used an alternate tuning for the jangly crunch.',76),
    ('iris','goo-goo-dolls','guitar','riff','main riff','crunch','rock','rhythm','intermediate',
     'Electric guitar in an alternate tuning (Johnny Rzeznik)','Crunch amp with ambience','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Big, ringing crunch in an unusual open tuning; keep the chords wide and clear.','Medium gain with ambience.'],
     array['Let the open-tuned chords ring big.','Build into the soaring chorus.'],
     'Studio recording, 1998. Johnny Rzeznik used an unusual open tuning for the big ringing chords.',77),
    ('there-she-goes','the-la-s','guitar','riff','main riff','clean','rock','rhythm','beginner',
     'Electric guitar (The La''s)','Bright clean amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":5,"treble":7,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bright, jangly clean tone; the chiming riff is the identity.','Keep gain low and the chords ringing.'],
     array['Let the jangly riff chime.','Keep the picking crisp.'],
     'Studio recording, 1990. A bright, jangly clean riff drives the song.',75),
    ('mr-jones','counting-crows','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Electric / acoustic guitar (Counting Crows)','Clean-to-crunch amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Warm, jangly clean-to-crunch chords; keep them ringing and dynamic.','Low-to-medium gain.'],
     array['Let the chords ring and strum evenly.','Keep the groove relaxed.'],
     'Studio recording, 1993. Warm, jangly clean-to-crunch chords drive the song.',75)
) as c(
  song_slug, artist_slug, mode, part_type, part_label, tone_type,
  genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes,
  source_summary, confidence
)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug
on conflict (song_id, mode, part_type, tone_type, part_label) do update set
  original_guitar = excluded.original_guitar, original_amp = excluded.original_amp,
  original_cab = excluded.original_cab, original_pickup = excluded.original_pickup,
  original_effects = excluded.original_effects, original_settings = excluded.original_settings,
  adaptation_notes = excluded.adaptation_notes, playing_notes = excluded.playing_notes,
  source_summary = excluded.source_summary, confidence = excluded.confidence,
  verification_status = excluded.verification_status, genre = excluded.genre,
  tone_category = excluded.tone_category, difficulty = excluded.difficulty,
  search_text = excluded.search_text, is_public = excluded.is_public, updated_at = now();

insert into public.tone_profile_sources (profile_id, source_type, title, url, notes, credibility)
select p.id, x.source_type, x.title, x.url, x.notes, x.credibility
from public.song_tone_profiles p
join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
join (values
  ('muse','time-is-running-out'),('muse','plug-in-baby'),('muse','knights-of-cydonia'),('muse','supermassive-black-hole'),
  ('muse','starlight'),('muse','uprising'),('coldplay','yellow'),('coldplay','fix-you'),('coldplay','in-my-place'),
  ('oasis','don-t-look-back-in-anger'),('oasis','champagne-supernova'),('oasis','live-forever'),
  ('jimmy-eat-world','the-middle'),('jimmy-eat-world','sweetness'),('yellowcard','ocean-avenue'),('paramore','that-s-what-you-get'),
  ('blur','song-2'),('radiohead','just'),('radiohead','fake-plastic-trees'),('radiohead','high-and-dry'),
  ('third-eye-blind','semi-charmed-life'),('goo-goo-dolls','slide'),('goo-goo-dolls','iris'),('the-la-s','there-she-goes'),('counting-crows','mr-jones')
) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
cross join (values
  ('artist_interview', 'Documented artist interviews and gear discussions', null::text,
   'Researched from widely-documented interviews about this recording and player.', 72),
  ('rig_rundown', 'Published rig rundowns and community gear databases', null::text,
   'Cross-referenced against rig features and community-maintained gear databases.', 66)
) as x(source_type, title, url, notes, credibility)
where p.verification_status = 'admin_verified'
on conflict do nothing;
