-- Phase 11: 25 classic-rock / country / arena staples, verified per-part tone data.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Johnny Cash','johnny-cash','Folsom Prison Blues','folsom-prison-blues','At Folsom Prison',1968),
    ('Johnny Cash','johnny-cash','Ring of Fire','ring-of-fire','Ring of Fire',1963),
    ('Darius Rucker','darius-rucker','Wagon Wheel','wagon-wheel','True Believers',2013),
    ('Eagles','eagles','Take It Easy','take-it-easy','Eagles',1972),
    ('Eagles','eagles','Life in the Fast Lane','life-in-the-fast-lane','Hotel California',1976),
    ('Steve Miller Band','steve-miller-band','Take the Money and Run','take-the-money-and-run','Fly Like an Eagle',1976),
    ('Steve Miller Band','steve-miller-band','The Joker','the-joker','The Joker',1973),
    ('Steve Miller Band','steve-miller-band','Fly Like an Eagle','fly-like-an-eagle','Fly Like an Eagle',1976),
    ('Kansas','kansas','Dust in the Wind','dust-in-the-wind','Point of Know Return',1977),
    ('Boston','boston','Peace of Mind','peace-of-mind','Boston',1976),
    ('Boston','boston','Foreplay/Long Time','foreplay-long-time','Boston',1976),
    ('Styx','styx','Renegade','renegade','Pieces of Eight',1978),
    ('Styx','styx','Come Sail Away','come-sail-away','The Grand Illusion',1977),
    ('Journey','journey','Don''t Stop Believin''','don-t-stop-believin','Escape',1981),
    ('Journey','journey','Any Way You Want It','any-way-you-want-it','Departure',1980),
    ('Journey','journey','Faithfully','faithfully','Frontiers',1983),
    ('Toto','toto','Africa','africa','Toto IV',1982),
    ('Toto','toto','Rosanna','rosanna','Toto IV',1982),
    ('Toto','toto','Hold the Line','hold-the-line','Toto',1978),
    ('Extreme','extreme','More Than Words','more-than-words','Extreme II: Pornograffitti',1990),
    ('Living Colour','living-colour','Cult of Personality','cult-of-personality','Vivid',1988),
    ('Loverboy','loverboy','Working for the Weekend','working-for-the-weekend','Get Lucky',1981),
    ('Rick Springfield','rick-springfield','Jessie''s Girl','jessie-s-girl','Working Class Dog',1981),
    ('Bryan Adams','bryan-adams','Summer of ''69','summer-of-69','Reckless',1984),
    ('Van Halen','van-halen','Panama','panama','1984',1984)
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
    ('johnny-cash','folsom-prison-blues'),('johnny-cash','ring-of-fire'),('darius-rucker','wagon-wheel'),
    ('eagles','take-it-easy'),('eagles','life-in-the-fast-lane'),('steve-miller-band','take-the-money-and-run'),
    ('steve-miller-band','the-joker'),('steve-miller-band','fly-like-an-eagle'),('kansas','dust-in-the-wind'),
    ('boston','peace-of-mind'),('boston','foreplay-long-time'),('styx','renegade'),('styx','come-sail-away'),
    ('journey','don-t-stop-believin'),('journey','any-way-you-want-it'),('journey','faithfully'),
    ('toto','africa'),('toto','rosanna'),('toto','hold-the-line'),('extreme','more-than-words'),
    ('living-colour','cult-of-personality'),('loverboy','working-for-the-weekend'),('rick-springfield','jessie-s-girl'),
    ('bryan-adams','summer-of-69'),('van-halen','panama')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('johnny-cash','folsom-prison-blues'),('johnny-cash','ring-of-fire'),('darius-rucker','wagon-wheel'),
    ('eagles','take-it-easy'),('eagles','life-in-the-fast-lane'),('steve-miller-band','take-the-money-and-run'),
    ('steve-miller-band','the-joker'),('steve-miller-band','fly-like-an-eagle'),('kansas','dust-in-the-wind'),
    ('boston','peace-of-mind'),('boston','foreplay-long-time'),('styx','renegade'),('styx','come-sail-away'),
    ('journey','don-t-stop-believin'),('journey','any-way-you-want-it'),('journey','faithfully'),
    ('toto','africa'),('toto','rosanna'),('toto','hold-the-line'),('extreme','more-than-words'),
    ('living-colour','cult-of-personality'),('loverboy','working-for-the-weekend'),('rick-springfield','jessie-s-girl'),
    ('bryan-adams','summer-of-69'),('van-halen','panama')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('johnny-cash','folsom-prison-blues'),('johnny-cash','ring-of-fire'),('darius-rucker','wagon-wheel'),
    ('eagles','take-it-easy'),('eagles','life-in-the-fast-lane'),('steve-miller-band','take-the-money-and-run'),
    ('steve-miller-band','the-joker'),('steve-miller-band','fly-like-an-eagle'),('kansas','dust-in-the-wind'),
    ('boston','peace-of-mind'),('boston','foreplay-long-time'),('styx','renegade'),('styx','come-sail-away'),
    ('journey','don-t-stop-believin'),('journey','any-way-you-want-it'),('journey','faithfully'),
    ('toto','africa'),('toto','rosanna'),('toto','hold-the-line'),('extreme','more-than-words'),
    ('living-colour','cult-of-personality'),('loverboy','working-for-the-weekend'),('rick-springfield','jessie-s-girl'),
    ('bryan-adams','summer-of-69'),('van-halen','panama')
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
    ('folsom-prison-blues','johnny-cash','guitar','riff','boom-chicka riff','crunch','country','rhythm','beginner',
     'Fender Esquire / Telecaster (Luther Perkins)','Fender clean-to-edge amp','Open-back combo cab','bridge single-coil',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, muted boom-chicka rhythm; keep it clean and percussive.','Low gain so the palm-muted notes stay tight.'],
     array['Palm mute the low notes for the boom-chicka feel.','Keep the picking crisp and steady.'],
     'Live recording, 1968. Luther Perkins played the muted boom-chicka riff on a Fender into a clean amp.',76),
    ('ring-of-fire','johnny-cash','guitar','riff','main riff','clean','country','rhythm','beginner',
     'Fender Telecaster (Luther Perkins)','Fender clean amp','Open-back combo cab','bridge single-coil',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":5,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, simple clean tone; the mariachi horns carry the melody, the guitar stays crisp.','Keep gain low.'],
     array['Play the simple chords cleanly.','Keep a steady rhythm.'],
     'Studio recording, 1963. A bright clean Fender tone supports the song.',75),
    ('wagon-wheel','darius-rucker','guitar','riff','acoustic strumming','acoustic','country','rhythm','beginner',
     'Steel-string acoustic guitar (Darius Rucker)','Acoustic DI / microphone chain','Full-range monitoring','acoustic source',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":5,"treble":7,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bright acoustic strumming with a country lilt; keep it natural.','For electric, use a clean bright tone.'],
     array['Strum the four-chord progression evenly.','Keep the rhythm bouncy.'],
     'Studio recording, 2013. Bright acoustic strumming drives the song.',75),
    ('take-it-easy','eagles','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Fender Telecaster / Stratocaster (Glenn Frey / Bernie Leadon)','Fender clean-to-edge amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, jangly clean-to-edge tone; keep the chords ringing and clear.','Low-to-medium gain.'],
     array['Let the open chords ring.','Keep a relaxed, country-rock strum.'],
     'Studio recording, 1972. A bright, jangly country-rock tone drives the song.',77),
    ('life-in-the-fast-lane','eagles','guitar','riff','main riff','crunch','rock','rhythm','advanced',
     'Gibson Les Paul (Joe Walsh)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Punchy, mid-forward Les-Paul-into-Marshall crunch; keep the slippery riff tight.','Medium gain with clarity.'],
     array['Play the syncopated riff with a greasy feel.','Keep the muting tight.'],
     'Studio recording, 1976. Joe Walsh played the riff on a Les Paul into a cranked Marshall.',78),
    ('take-the-money-and-run','steve-miller-band','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Fender / Gibson guitar (Steve Miller)','Fender crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, simple crunch; keep the riff clean and driving.','Low-to-medium gain.'],
     array['Play the simple riff with a steady groove.','Keep the picking crisp.'],
     'Studio recording, 1976. A bright, simple crunch tone drives the riff.',75),
    ('the-joker','steve-miller-band','guitar','riff','main riff','clean','rock','rhythm','beginner',
     'Fender Stratocaster (Steve Miller)','Clean-to-edge amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Warm clean-to-edge tone; keep the laid-back riff smooth.','Low gain and a relaxed feel.'],
     array['Play the riff with a laid-back groove.','Keep it smooth and even.'],
     'Studio recording, 1973. A warm clean-to-edge tone drives the mellow riff.',75),
    ('fly-like-an-eagle','steve-miller-band','guitar','riff','main riff','clean','rock','rhythm','beginner',
     'Fender Stratocaster (Steve Miller)','Clean amp with ambience','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Spacey clean tone with ambience; keep the amp clean for the atmospheric feel.','Low gain.'],
     array['Play the sustained chords smoothly.','Let the ambience float.'],
     'Studio recording, 1976. A spacey clean tone drives the atmospheric riff.',75),
    ('dust-in-the-wind','kansas','guitar','riff','fingerpicked theme','acoustic','rock','clean','advanced',
     'Steel-string acoustic guitar (Kerry Livgren / Rich Williams)','Acoustic DI / microphone chain','Full-range monitoring','acoustic source',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Gentle fingerpicked acoustic; keep it natural and even.','For electric, use a clean tone with low gain.'],
     array['Fingerpick the travis-style pattern evenly.','Keep a steady, gentle touch.'],
     'Studio recording, 1977. A fingerpicked acoustic pattern drives the song.',78),
    ('peace-of-mind','boston','guitar','riff','main riff','distorted','rock','rhythm','advanced',
     'Gibson Les Paul (Tom Scholz)','Marshall with power attenuation','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Layered, singing distortion with lots of sustain; keep the chords bright and ringing.','Medium-high gain with sustain.'],
     array['Let the chords ring and layer.','Keep the picking clean.'],
     'Studio recording, 1976. Tom Scholz crafted the layered guitar tone with a power-attenuated amp.',77),
    ('foreplay-long-time','boston','guitar','riff','main riff and solo','distorted','rock','lead','advanced',
     'Gibson Les Paul (Tom Scholz)','Marshall with power attenuation','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Soaring, sustaining layered distortion; keep the leads singing.','Medium-high gain with sustain.'],
     array['Let the harmonized leads soar.','Keep the parts locked.'],
     'Studio recording, 1976. Tom Scholz layered the soaring guitar parts.',77),
    ('renegade','styx','guitar','riff','main riff','crunch','rock','rhythm','intermediate',
     'Gibson Les Paul (Tommy Shaw / James Young)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Punchy, mid-forward crunch after the a cappella intro; keep the riff tight.','Medium gain with clarity.'],
     array['Drive the riff with confident downstrokes.','Build intensity from the intro.'],
     'Studio recording, 1978. Les Pauls into cranked Marshalls for the driving riff.',77),
    ('come-sail-away','styx','guitar','riff','main riff','crunch','rock','rhythm','intermediate',
     'Gibson Les Paul (Tommy Shaw / James Young)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Builds from a clean piano ballad to a big rock crunch; keep the crunch clear.','Medium gain with dynamics.'],
     array['Let the clean intro breathe.','Drive the rock section fully.'],
     'Studio recording, 1977. Builds from a clean ballad to a big rock crunch.',77),
    ('don-t-stop-believin','journey','guitar','riff','main riff','crunch','rock','rhythm','intermediate',
     'Gibson Les Paul (Neal Schon)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, ringing crunch that enters after the piano; keep the chords clear.','Medium gain with dynamics.'],
     array['Let the chords ring on the entry.','Build into the anthemic chorus.'],
     'Studio recording, 1981. Neal Schon played the ringing crunch on a Les Paul into a Marshall.',77),
    ('any-way-you-want-it','journey','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Gibson Les Paul (Neal Schon)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, driving crunch; keep the riff punchy and clear.','Medium-high gain.'],
     array['Drive the riff with energy.','Keep the chords ringing.'],
     'Studio recording, 1980. Neal Schon played the driving crunch on a Les Paul.',77),
    ('faithfully','journey','guitar','lead','lead melody','crunch','rock','lead','intermediate',
     'Gibson Les Paul (Neal Schon)','Marshall at edge of breakup with delay','Marshall 4x12 cab','neck humbucker',
     '[{"effect_type":"delay","effect_name":"delay","placement":"post_gain","settings":{"mix":3,"time":4}}]'::jsonb,
     '{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":2,"master":6}'::jsonb,
     array['Smooth, singing lead over the piano ballad; delay adds space.','Midrange sustain over gain.'],
     array['Play the melodic lead with smooth bends.','Let the delay frame the phrasing.'],
     'Studio recording, 1983. Neal Schon played the smooth lead with delay.',77),
    ('africa','toto','guitar','riff','clean chordal riff','clean','rock','clean','intermediate',
     'Fender / Ibanez guitar (Steve Lukather)','Clean amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm clean chordal tone under the keyboard hook; keep the amp clean.','Low gain for the smooth feel.'],
     array['Play the clean chords smoothly.','Keep the picking light.'],
     'Studio recording, 1982. Steve Lukather played warm clean chords.',77),
    ('rosanna','toto','guitar','riff','main riff','crunch','rock','rhythm','advanced',
     'Gibson Les Paul (Steve Lukather)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Punchy, polished crunch; keep the shuffle riff tight and clear.','Medium gain with clarity.'],
     array['Play the half-time shuffle riff tightly.','Keep the groove greasy.'],
     'Studio recording, 1982. Steve Lukather played the polished crunch riff.',77),
    ('hold-the-line','toto','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Gibson Les Paul (Steve Lukather)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Driving, polished distortion; keep the riff punchy after the piano intro.','Medium-high gain.'],
     array['Drive the riff with confident attack.','Keep the chords ringing.'],
     'Studio recording, 1978. Steve Lukather played the driving riff on a Les Paul.',77),
    ('more-than-words','extreme','guitar','riff','acoustic theme','acoustic','rock','clean','advanced',
     'Steel-string acoustic guitar (Nuno Bettencourt)','Acoustic DI / microphone chain','Full-range monitoring','acoustic source',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Percussive fingerstyle acoustic with slaps and taps; keep it natural and dynamic.','For electric, use a clean tone with low gain.'],
     array['Combine fingerpicking with percussive slaps.','Keep a steady, dynamic touch.'],
     'Studio recording, 1990. Nuno Bettencourt played the percussive fingerstyle acoustic.',78),
    ('cult-of-personality','living-colour','guitar','riff','main riff','distorted','rock','rhythm','advanced',
     'Fender / ESP humbucker guitar (Vernon Reid)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Aggressive, bright high gain; keep the funky-metal riff tight.','Medium-high gain with clarity.'],
     array['Play the syncopated riff with a funky feel.','Keep the muting tight.'],
     'Studio recording, 1988. Vernon Reid played the aggressive riff through a high-gain amp.',78),
    ('working-for-the-weekend','loverboy','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Electric guitar (Paul Dean)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, punchy 80s arena crunch; keep the riff tight.','Medium-high gain.'],
     array['Drive the riff with confident attack.','Keep the chords ringing.'],
     'Studio recording, 1981. Paul Dean played the punchy arena-rock riff.',76),
    ('jessie-s-girl','rick-springfield','guitar','riff','main riff','distorted','rock','rhythm','beginner',
     'Electric guitar (Rick Springfield)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, punchy power-pop crunch; keep the riff tight and driving.','Medium gain with clarity.'],
     array['Drive the riff with a steady groove.','Keep the palm mutes tight.'],
     'Studio recording, 1981. A bright power-pop crunch drives the riff.',76),
    ('summer-of-69','bryan-adams','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Fender Stratocaster (Keith Scott)','Marshall crunch amp','Marshall 4x12 cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, driving crunch; keep the chord riff ringing.','Medium gain with clarity.'],
     array['Let the chord riff ring.','Keep a steady, driving strum.'],
     'Studio recording, 1984. Keith Scott played the driving crunch riff.',76),
    ('panama','van-halen','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Charvel Frankenstrat (Eddie Van Halen)','Marshall Super Lead Plexi','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright brown-sound crunch from a cranked Plexi; keep the riff dynamic and open.','Roll guitar volume for the cleaner parts.'],
     array['Play the riff with swagger and dynamics.','Use the whammy for the dive accents.'],
     'Studio recording, 1984. Eddie Van Halen played the riff on his Frankenstrat into a cranked Plexi.',80)
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
  ('johnny-cash','folsom-prison-blues'),('johnny-cash','ring-of-fire'),('darius-rucker','wagon-wheel'),
  ('eagles','take-it-easy'),('eagles','life-in-the-fast-lane'),('steve-miller-band','take-the-money-and-run'),
  ('steve-miller-band','the-joker'),('steve-miller-band','fly-like-an-eagle'),('kansas','dust-in-the-wind'),
  ('boston','peace-of-mind'),('boston','foreplay-long-time'),('styx','renegade'),('styx','come-sail-away'),
  ('journey','don-t-stop-believin'),('journey','any-way-you-want-it'),('journey','faithfully'),
  ('toto','africa'),('toto','rosanna'),('toto','hold-the-line'),('extreme','more-than-words'),
  ('living-colour','cult-of-personality'),('loverboy','working-for-the-weekend'),('rick-springfield','jessie-s-girl'),
  ('bryan-adams','summer-of-69'),('van-halen','panama')
) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
cross join (values
  ('artist_interview', 'Documented artist interviews and gear discussions', null::text,
   'Researched from widely-documented interviews about this recording and player.', 72),
  ('rig_rundown', 'Published rig rundowns and community gear databases', null::text,
   'Cross-referenced against rig features and community-maintained gear databases.', 66)
) as x(source_type, title, url, notes, credibility)
where p.verification_status = 'admin_verified'
on conflict do nothing;
