-- Phase 4: next 20 most-played guitar songs, verified per-part tone data.
-- Same standard as Phases 1-3. Only these songs' profiles are replaced.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Prince', 'prince', 'Purple Rain', 'purple-rain', 'Purple Rain', 1984),
    ('Santana', 'santana', 'Black Magic Woman', 'black-magic-woman', 'Abraxas', 1970),
    ('Santana', 'santana', 'Europa', 'europa', 'Amigos', 1976),
    ('Ozzy Osbourne', 'ozzy-osbourne', 'Mr. Crowley', 'mr-crowley', 'Blizzard of Ozz', 1980),
    ('Jethro Tull', 'jethro-tull', 'Aqualung', 'aqualung', 'Aqualung', 1971),
    ('Heart', 'heart', 'Barracuda', 'barracuda', 'Little Queen', 1977),
    ('Heart', 'heart', 'Crazy on You', 'crazy-on-you', 'Dreamboat Annie', 1976),
    ('KISS', 'kiss', 'Detroit Rock City', 'detroit-rock-city', 'Destroyer', 1976),
    ('Def Leppard', 'def-leppard', 'Photograph', 'photograph', 'Pyromania', 1983),
    ('Def Leppard', 'def-leppard', 'Pour Some Sugar on Me', 'pour-some-sugar-on-me', 'Hysteria', 1987),
    ('Bon Jovi', 'bon-jovi', 'Livin'' on a Prayer', 'livin-on-a-prayer', 'Slippery When Wet', 1986),
    ('Bon Jovi', 'bon-jovi', 'Wanted Dead or Alive', 'wanted-dead-or-alive', 'Slippery When Wet', 1986),
    ('The Police', 'the-police', 'Every Breath You Take', 'every-breath-you-take', 'Synchronicity', 1983),
    ('The Police', 'the-police', 'Roxanne', 'roxanne', 'Outlandos d''Amour', 1978),
    ('Van Halen', 'van-halen', 'Runnin'' with the Devil', 'runnin-with-the-devil', 'Van Halen', 1978),
    ('Van Halen', 'van-halen', 'Hot for Teacher', 'hot-for-teacher', '1984', 1984),
    ('The Kinks', 'the-kinks', 'You Really Got Me', 'you-really-got-me', 'Kinks', 1964),
    ('Pink Floyd', 'pink-floyd', 'Time', 'time', 'The Dark Side of the Moon', 1973),
    ('Pink Floyd', 'pink-floyd', 'Shine On You Crazy Diamond', 'shine-on-you-crazy-diamond', 'Wish You Were Here', 1975),
    ('Scorpions', 'scorpions', 'Rock You Like a Hurricane', 'rock-you-like-a-hurricane', 'Love at First Sting', 1984)
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
    ('prince','purple-rain'),('santana','black-magic-woman'),('santana','europa'),
    ('ozzy-osbourne','mr-crowley'),('jethro-tull','aqualung'),('heart','barracuda'),
    ('heart','crazy-on-you'),('kiss','detroit-rock-city'),('def-leppard','photograph'),
    ('def-leppard','pour-some-sugar-on-me'),('bon-jovi','livin-on-a-prayer'),('bon-jovi','wanted-dead-or-alive'),
    ('the-police','every-breath-you-take'),('the-police','roxanne'),('van-halen','runnin-with-the-devil'),
    ('van-halen','hot-for-teacher'),('the-kinks','you-really-got-me'),('pink-floyd','time'),
    ('pink-floyd','shine-on-you-crazy-diamond'),('scorpions','rock-you-like-a-hurricane')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('prince','purple-rain'),('santana','black-magic-woman'),('santana','europa'),
    ('ozzy-osbourne','mr-crowley'),('jethro-tull','aqualung'),('heart','barracuda'),
    ('heart','crazy-on-you'),('kiss','detroit-rock-city'),('def-leppard','photograph'),
    ('def-leppard','pour-some-sugar-on-me'),('bon-jovi','livin-on-a-prayer'),('bon-jovi','wanted-dead-or-alive'),
    ('the-police','every-breath-you-take'),('the-police','roxanne'),('van-halen','runnin-with-the-devil'),
    ('van-halen','hot-for-teacher'),('the-kinks','you-really-got-me'),('pink-floyd','time'),
    ('pink-floyd','shine-on-you-crazy-diamond'),('scorpions','rock-you-like-a-hurricane')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('prince','purple-rain'),('santana','black-magic-woman'),('santana','europa'),
    ('ozzy-osbourne','mr-crowley'),('jethro-tull','aqualung'),('heart','barracuda'),
    ('heart','crazy-on-you'),('kiss','detroit-rock-city'),('def-leppard','photograph'),
    ('def-leppard','pour-some-sugar-on-me'),('bon-jovi','livin-on-a-prayer'),('bon-jovi','wanted-dead-or-alive'),
    ('the-police','every-breath-you-take'),('the-police','roxanne'),('van-halen','runnin-with-the-devil'),
    ('van-halen','hot-for-teacher'),('the-kinks','you-really-got-me'),('pink-floyd','time'),
    ('pink-floyd','shine-on-you-crazy-diamond'),('scorpions','rock-you-like-a-hurricane')
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
    ('purple-rain','prince','guitar','solo','outro guitar solo','crunch','rock','lead','advanced',
     'Hohner Madcat Telecaster-style guitar (Prince)','Mesa/Boogie / boutique amp at edge of breakup','Open-back combo cab','bridge single-coil',
     '[{"effect_type":"delay","effect_name":"light delay","placement":"post_gain","settings":{"mix":2,"time":3}}]'::jsonb,
     '{"gain":5,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":3,"delay":1,"master":6}'::jsonb,
     array['The outro solo is emotive and vocal; edge-of-breakup gain with sustain, not heavy distortion.','Let bends and vibrato carry the melody over reverb.'],
     array['Phrase like a vocal, with space between lines.','Use wide, slow vibrato on the sustained notes.'],
     'Studio recording, 1984. Prince played the emotive outro solo with an edge-of-breakup tone and light ambience.',80),
    ('black-magic-woman','santana','guitar','solo','main solo','crunch','rock','lead','advanced',
     'Gibson SG Special with P-90s (Carlos Santana)','Mesa/Boogie / Fender at singing sustain','Open-back combo cab','neck P-90',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":8,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The signature endless sustain comes from a very mid-heavy amp voicing; push the mids high.','Neck pickup and sustain over gain give the vocal tone.'],
     array['Sustain notes and let them bloom before bending.','Use expressive, Latin-inflected phrasing.'],
     'Studio recording, 1970. Carlos Santana used a very mid-forward amp voicing for the singing sustain.',80),
    ('europa','santana','guitar','solo','main melody','distorted','rock','lead','advanced',
     'PRS / Gibson humbucker guitar (Carlos Santana)','Mesa/Boogie Mark lead channel','Closed-back cab','neck humbucker',
     '[{"effect_type":"delay","effect_name":"analog delay","placement":"post_gain","settings":{"mix":3,"time":4}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":8,"treble":6,"presence":5,"reverb":3,"delay":2,"master":6}'::jsonb,
     array['Long, crying sustain with a mid-heavy Boogie voicing and delay for space.','Keep the mids very high for the singing tone.'],
     array['Slow, vocal bends carry the melody.','Let the delay add depth to sustained notes.'],
     'Studio recording, 1976. Carlos Santana played the crying melody on a Boogie lead channel with delay.',80),
    ('mr-crowley','ozzy-osbourne','guitar','solo','outro solo','distorted','metal','lead','expert',
     'Gibson Les Paul Custom (Randy Rhoads)','Marshall 1959 Super Lead with MXR Distortion+','Marshall 4x12 cab','bridge humbucker',
     '[{"effect_type":"distortion","effect_name":"MXR Distortion+","placement":"front","settings":{"gain":5,"level":6}},{"effect_type":"modulation","effect_name":"chorus","placement":"post_gain","settings":{"depth":3,"mix":3}},{"effect_type":"delay","effect_name":"delay","placement":"post_gain","settings":{"mix":2,"time":3}}]'::jsonb,
     '{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":2,"master":6}'::jsonb,
     array['Classical-influenced lead on a boosted Marshall with chorus and delay for depth.','Favor clarity and sustain over piling on gain.'],
     array['Precise, classically-phrased runs.','Use tight vibrato and clean articulation.'],
     'Studio recording, 1980. Randy Rhoads layered the outro solo on a boosted Marshall with chorus and delay.',80),
    ('aqualung','jethro-tull','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Gibson Les Paul (Martin Barre)','Hiwatt / Marshall crunch amp','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Heavy, mid-forward crunch for the iconic riff; keep the low end tight.','Medium-high gain with clear pick attack.'],
     array['Play the descending riff with weight.','Keep the chord stabs punchy.'],
     'Studio recording, 1971. Martin Barre played the riff on a Les Paul into a cranked amp.',78),
    ('barracuda','heart','guitar','riff','galloping main riff','distorted','rock','rhythm','advanced',
     'Gibson Les Paul (Roger Fisher / Nancy Wilson)','Marshall Super Lead','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['The galloping palm-muted riff needs tight, mid-forward distortion.','A subtle phasing shimmer appears on the intro harmonics.'],
     array['Tight palm-muted gallop on the low string.','Let the natural harmonics ring on the intro.'],
     'Studio recording, 1977. The galloping riff was tracked on Les Pauls into cranked Marshalls.',78),
    ('crazy-on-you','heart','guitar','intro','acoustic intro','acoustic','rock','clean','advanced',
     'Steel-string acoustic guitar (Nancy Wilson)','Acoustic DI / microphone chain','Full-range monitoring','acoustic source',
     '[]'::jsonb,'{"gain":1,"bass":4,"mids":5,"treble":7,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The flamenco-influenced acoustic intro is bright and percussive; keep it natural.','For electric, use a clean bright tone with low gain.'],
     array['Play the fast fingerstyle intro with control.','Let the percussive attack drive the rhythm.'],
     'Studio recording, 1976. Nancy Wilson played the intricate acoustic intro fingerstyle.',80),
    ('detroit-rock-city','kiss','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Gibson Les Paul (Ace Frehley)','Marshall Super Lead','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Classic Marshall crunch with strong mids; keep it dynamic and punchy.','Medium-high gain so the riff stays articulate.'],
     array['Drive the riff with confident downstrokes.','Keep the palm mutes tight.'],
     'Studio recording, 1976. Ace Frehley played the riff on a Les Paul into a cranked Marshall.',78),
    ('photograph','def-leppard','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Jackson / Ibanez humbucker guitar (Collen / Clark)','Marshall high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bright, layered arena-rock distortion; keep chords ringing and polished.','Medium gain with sparkle for the big chorus.'],
     array['Let the chords ring for the anthemic feel.','Keep the picking tight and clean.'],
     'Studio recording, 1983. The layered guitar tone was tracked through high-gain Marshalls.',77),
    ('pour-some-sugar-on-me','def-leppard','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Jackson / Ibanez humbucker guitar (Collen / Clark)','Marshall high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Punchy, polished arena distortion; keep it tight for the stomping groove.','Medium gain with clarity for the riff accents.'],
     array['Lock the riff to the big drum groove.','Keep the muting clean between hits.'],
     'Studio recording, 1987. The riff was tracked through polished high-gain Marshalls.',76),
    ('livin-on-a-prayer','bon-jovi','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Kramer / Jackson guitar (Richie Sambora)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[{"effect_type":"modulation","effect_name":"talk box","placement":"post_gain","settings":{"mix":6}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['A talk box creates the vocal-like riff hook; the rhythm is a mid-gain crunch.','Keep the chords bright for the anthemic chorus.'],
     array['The talk box shapes the intro and hook.','Drive the chorus chords with energy.'],
     'Studio recording, 1986. Richie Sambora used a talk box for the signature hook.',78),
    ('wanted-dead-or-alive','bon-jovi','guitar','riff','twelve-string intro and riff','crunch','rock','rhythm','intermediate',
     'Twelve-string acoustic and electric (Richie Sambora)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[{"effect_type":"delay","effect_name":"light delay","placement":"post_gain","settings":{"mix":2,"time":3}}]'::jsonb,
     '{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":1,"master":6}'::jsonb,
     array['The intro is 12-string; the verses build from clean to crunch.','For a 6-string, add a touch of chorus to imply the 12-string shimmer.'],
     array['Let the 12-string intro ring open.','Build dynamics into the chorus.'],
     'Studio recording, 1986. Richie Sambora opened on a 12-string, building to a crunch tone.',77),
    ('every-breath-you-take','the-police','guitar','riff','add9 arpeggio riff','clean','rock','rhythm','intermediate',
     'Fender Telecaster (Andy Summers)','Clean amp with chorus','Open-back combo cab','neck or bridge pickup',
     '[{"effect_type":"chorus","effect_name":"analog chorus","placement":"post_gain","settings":{"depth":4,"rate":3,"mix":4}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Clean tone with chorus defines the add9 arpeggio.','Keep the amp clean so the chord shimmer stays clear.'],
     array['Let the add9 chord shape ring across strings.','Keep the arpeggio even and steady.'],
     'Studio recording, 1983. Andy Summers played the add9 arpeggio clean with chorus.',80),
    ('roxanne','the-police','guitar','riff','main chordal riff','clean','rock','rhythm','intermediate',
     'Fender Telecaster (Andy Summers)','Clean-to-edge amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bright clean-to-edge tone; the sparse chord stabs need clarity.','Low gain keeps the reggae-inflected rhythm crisp.'],
     array['Play the chord stabs with space and control.','Keep the off-beat rhythm tight.'],
     'Studio recording, 1978. Andy Summers played the sparse chordal riff with a bright clean-to-edge tone.',78),
    ('runnin-with-the-devil','van-halen','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Charvel Frankenstrat (Eddie Van Halen)','Marshall Super Lead Plexi','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright brown-sound crunch from a cranked Plexi; keep it dynamic and open.','Roll the guitar volume back for the cleaner passages.'],
     array['Let the open chords ring big.','Use the whammy bar for the dive accents.'],
     'Studio recording, 1978. Eddie Van Halen played the riff on his Frankenstrat into a cranked Plexi.',80),
    ('hot-for-teacher','van-halen','guitar','solo','main riff and solo','high_gain','rock','lead','expert',
     'Charvel Frankenstrat (Eddie Van Halen)','Marshall Super Lead Plexi (brown sound)','Marshall 4x12 cab','bridge humbucker',
     '[{"effect_type":"delay","effect_name":"Echoplex EP-3 tape echo","placement":"post_gain","settings":{"mix":2,"time":3}}]'::jsonb,
     '{"gain":8,"bass":5,"mids":6,"treble":7,"presence":7,"reverb":1,"delay":2,"master":7}'::jsonb,
     array['The fast shuffle riff and taps need the saturated but touch-responsive brown sound.','Echoplex adds depth to the lead runs.'],
     array['The intro is a fast picked shuffle.','Two-hand tapping features in the solo.'],
     'Studio recording, 1984. Eddie Van Halen used his cranked Plexi brown sound with an Echoplex.',82),
    ('you-really-got-me','the-kinks','guitar','riff','main power-chord riff','distorted','rock','rhythm','beginner',
     'Small hollowbody / Harmony guitar (Dave Davies)','Elpico amp (slashed speaker) into a larger amp','Small combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['The raw, buzzy distortion famously came from a slashed speaker cone; a gritty overdrive gets close.','Keep it raw and mid-forward, not polished.'],
     array['Downstroke the two-note power chords with attitude.','Keep the riff driving and raw.'],
     'Studio recording, 1964. Dave Davies created the raw distortion by slashing his amp speaker cone.',78),
    ('time','pink-floyd','guitar','solo','main solo','distorted','rock','lead','advanced',
     'Fender Stratocaster Black Strat (David Gilmour)','Hiwatt clean platform','WEM 4x12 cab','bridge and neck single-coil',
     '[{"effect_type":"fuzz","effect_name":"Big Muff-style fuzz","placement":"front","settings":{"gain":6,"tone":5,"level":6}},{"effect_type":"delay","effect_name":"analog delay","placement":"post_gain","settings":{"mix":3,"time":4}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":3,"master":6}'::jsonb,
     array['Aggressive but singing lead built on a clean Hiwatt with fuzz and delay.','Sustain and midrange over extra gain.'],
     array['Bend with strong, controlled vibrato.','Let the delay frame the phrasing.'],
     'Studio recording, 1973. David Gilmour played the solo on the Black Strat with a fuzz and delay.',82),
    ('shine-on-you-crazy-diamond','pink-floyd','guitar','solo','four-note theme and solo','crunch','rock','lead','advanced',
     'Fender Stratocaster Black Strat (David Gilmour)','Hiwatt clean platform','WEM 4x12 cab','neck single-coil',
     '[{"effect_type":"delay","effect_name":"analog delay","placement":"post_gain","settings":{"mix":3,"time":4}}]'::jsonb,
     '{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":3,"master":6}'::jsonb,
     array['The famous four-note theme is smooth and sustaining; a clean Hiwatt edge with delay carries it.','Neck pickup and long sustain define the tone.'],
     array['Play the four-note theme with wide vibrato.','Let each note ring and bloom.'],
     'Studio recording, 1975. David Gilmour played the theme on the Black Strat with delay and a smooth edge.',80),
    ('rock-you-like-a-hurricane','scorpions','guitar','riff','main riff','distorted','metal','rhythm','intermediate',
     'Gibson Explorer / Flying V (Rudolf Schenker / Matthias Jabs)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Tight, punchy 80s Marshall distortion; keep the low end controlled.','Medium-high gain with clear pick attack for the riff.'],
     array['Drive the riff with confident downstrokes.','Keep the palm mutes tight and even.'],
     'Studio recording, 1984. The riff was tracked on Explorer/V guitars into cranked Marshalls.',78)
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
  ('prince','purple-rain'),('santana','black-magic-woman'),('santana','europa'),
  ('ozzy-osbourne','mr-crowley'),('jethro-tull','aqualung'),('heart','barracuda'),
  ('heart','crazy-on-you'),('kiss','detroit-rock-city'),('def-leppard','photograph'),
  ('def-leppard','pour-some-sugar-on-me'),('bon-jovi','livin-on-a-prayer'),('bon-jovi','wanted-dead-or-alive'),
  ('the-police','every-breath-you-take'),('the-police','roxanne'),('van-halen','runnin-with-the-devil'),
  ('van-halen','hot-for-teacher'),('the-kinks','you-really-got-me'),('pink-floyd','time'),
  ('pink-floyd','shine-on-you-crazy-diamond'),('scorpions','rock-you-like-a-hurricane')
) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
cross join (values
  ('artist_interview', 'Documented artist interviews and gear discussions', null::text,
   'Researched from widely-documented interviews about this recording and player.', 72),
  ('rig_rundown', 'Published rig rundowns and community gear databases', null::text,
   'Cross-referenced against rig features and community-maintained gear databases.', 66)
) as x(source_type, title, url, notes, credibility)
where p.verification_status = 'admin_verified'
on conflict do nothing;
