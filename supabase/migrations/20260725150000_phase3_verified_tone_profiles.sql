-- Phase 3: next 20 most-played guitar songs, verified per-part tone data.
-- Same standard as Phases 1-2. Only these songs' profiles are replaced.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Led Zeppelin', 'led-zeppelin', 'Kashmir', 'kashmir', 'Physical Graffiti', 1975),
    ('AC/DC', 'ac-dc', 'Thunderstruck', 'thunderstruck', 'The Razors Edge', 1990),
    ('Aerosmith', 'aerosmith', 'Sweet Emotion', 'sweet-emotion', 'Toys in the Attic', 1975),
    ('Boston', 'boston', 'More Than a Feeling', 'more-than-a-feeling', 'Boston', 1976),
    ('Kansas', 'kansas', 'Carry On Wayward Son', 'carry-on-wayward-son', 'Leftoverture', 1976),
    ('Blue Oyster Cult', 'blue-oyster-cult', '(Don''t Fear) The Reaper', 'don-t-fear-the-reaper', 'Agents of Fortune', 1976),
    ('Jimi Hendrix', 'jimi-hendrix', 'Hey Joe', 'hey-joe', 'Are You Experienced', 1966),
    ('Jimi Hendrix', 'jimi-hendrix', 'All Along the Watchtower', 'all-along-the-watchtower', 'Electric Ladyland', 1968),
    ('Jimi Hendrix', 'jimi-hendrix', 'Little Wing', 'little-wing', 'Axis: Bold as Love', 1967),
    ('U2', 'u2', 'Where the Streets Have No Name', 'where-the-streets-have-no-name', 'The Joshua Tree', 1987),
    ('U2', 'u2', 'With or Without You', 'with-or-without-you', 'The Joshua Tree', 1987),
    ('The Cranberries', 'the-cranberries', 'Zombie', 'zombie', 'No Need to Argue', 1994),
    ('Pink Floyd', 'pink-floyd', 'Wish You Were Here', 'wish-you-were-here', 'Wish You Were Here', 1975),
    ('Pink Floyd', 'pink-floyd', 'Another Brick in the Wall (Part 2)', 'another-brick-in-the-wall-part-2', 'The Wall', 1979),
    ('Guns N'' Roses', 'guns-n-roses', 'Paradise City', 'paradise-city', 'Appetite for Destruction', 1987),
    ('System of a Down', 'system-of-a-down', 'Chop Suey!', 'chop-suey', 'Toxicity', 2001),
    ('System of a Down', 'system-of-a-down', 'Toxicity', 'toxicity', 'Toxicity', 2001),
    ('Linkin Park', 'linkin-park', 'Numb', 'numb', 'Meteora', 2003),
    ('Guns N'' Roses', 'guns-n-roses', 'Welcome to the Jungle', 'welcome-to-the-jungle', 'Appetite for Destruction', 1987),
    ('Red Hot Chili Peppers', 'red-hot-chili-peppers', 'Californication', 'californication', 'Californication', 1999)
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
    ('led-zeppelin','kashmir'),('ac-dc','thunderstruck'),('aerosmith','sweet-emotion'),
    ('boston','more-than-a-feeling'),('kansas','carry-on-wayward-son'),('blue-oyster-cult','don-t-fear-the-reaper'),
    ('jimi-hendrix','hey-joe'),('jimi-hendrix','all-along-the-watchtower'),('jimi-hendrix','little-wing'),
    ('u2','where-the-streets-have-no-name'),('u2','with-or-without-you'),('the-cranberries','zombie'),
    ('pink-floyd','wish-you-were-here'),('pink-floyd','another-brick-in-the-wall-part-2'),('guns-n-roses','paradise-city'),
    ('system-of-a-down','chop-suey'),('system-of-a-down','toxicity'),('linkin-park','numb'),
    ('guns-n-roses','welcome-to-the-jungle'),('red-hot-chili-peppers','californication')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('led-zeppelin','kashmir'),('ac-dc','thunderstruck'),('aerosmith','sweet-emotion'),
    ('boston','more-than-a-feeling'),('kansas','carry-on-wayward-son'),('blue-oyster-cult','don-t-fear-the-reaper'),
    ('jimi-hendrix','hey-joe'),('jimi-hendrix','all-along-the-watchtower'),('jimi-hendrix','little-wing'),
    ('u2','where-the-streets-have-no-name'),('u2','with-or-without-you'),('the-cranberries','zombie'),
    ('pink-floyd','wish-you-were-here'),('pink-floyd','another-brick-in-the-wall-part-2'),('guns-n-roses','paradise-city'),
    ('system-of-a-down','chop-suey'),('system-of-a-down','toxicity'),('linkin-park','numb'),
    ('guns-n-roses','welcome-to-the-jungle'),('red-hot-chili-peppers','californication')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('led-zeppelin','kashmir'),('ac-dc','thunderstruck'),('aerosmith','sweet-emotion'),
    ('boston','more-than-a-feeling'),('kansas','carry-on-wayward-son'),('blue-oyster-cult','don-t-fear-the-reaper'),
    ('jimi-hendrix','hey-joe'),('jimi-hendrix','all-along-the-watchtower'),('jimi-hendrix','little-wing'),
    ('u2','where-the-streets-have-no-name'),('u2','with-or-without-you'),('the-cranberries','zombie'),
    ('pink-floyd','wish-you-were-here'),('pink-floyd','another-brick-in-the-wall-part-2'),('guns-n-roses','paradise-city'),
    ('system-of-a-down','chop-suey'),('system-of-a-down','toxicity'),('linkin-park','numb'),
    ('guns-n-roses','welcome-to-the-jungle'),('red-hot-chili-peppers','californication')
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
    ('kashmir','led-zeppelin','guitar','riff','main riff','crunch','rock','rhythm','intermediate',
     'Danelectro / Les Paul in DADGAD-style tuning (Jimmy Page)','Marshall Super Lead','Marshall 4x12 cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":6,"mids":7,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The hypnotic riff uses an alternate tuning; keep gain moderate so the drone strings ring clearly.','Strong mids give the riff its orchestral weight.'],
     array['Let the open drone strings ring under the melody.','Keep the rhythm steady and deliberate.'],
     'Studio recording, 1975. Jimmy Page played the riff in an alternate tuning into a cranked Marshall.',80),
    ('thunderstruck','ac-dc','guitar','riff','main picking riff','crunch','rock','rhythm','advanced',
     'Gibson SG (Angus Young)','Marshall Super Lead','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":7,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Clear, mid-forward crunch so the fast single-note picking stays articulate.','Keep gain moderate; clarity beats saturation here.'],
     array['The intro is finger-tapped/pulled on the open string.','Keep the picking hand relaxed and even.'],
     'Studio recording, 1990. Angus Young played the picking riff on an SG into a cranked Marshall.',80),
    ('sweet-emotion','aerosmith','guitar','riff','main riff','crunch','rock','rhythm','intermediate',
     'Gibson Les Paul (Joe Perry)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[{"effect_type":"modulation","effect_name":"talk box (intro)","placement":"post_gain","settings":{"mix":6}}]'::jsonb,
     '{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['A talk box shapes the intro vowel sounds; the main riff is a mid-gain crunch.','Keep the groove loose and funky.'],
     array['Lock the riff into the bass groove.','Use light dynamics for the verse builds.'],
     'Studio recording, 1975. Joe Perry used a talk box on the intro and a mid-gain crunch for the riff.',77),
    ('more-than-a-feeling','boston','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Gibson Les Paul (Tom Scholz)','Marshall with power attenuation','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Layered, singing distortion with lots of sustain; Scholz used power attenuation for a saturated but controlled tone.','Keep the chords ringing and bright.'],
     array['Let the open-position chords ring fully.','The dynamics between soft verse and big chorus define it.'],
     'Studio recording, 1976. Tom Scholz crafted the layered guitar tone with a power-attenuated cranked amp.',78),
    ('carry-on-wayward-son','kansas','guitar','riff','main riff','distorted','rock','rhythm','advanced',
     'Gibson Les Paul (Kerry Livgren / Rich Williams)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Tight, mid-rich distortion for the harmonized riff; keep the low end controlled.','Clarity matters for the fast unison lines.'],
     array['Play the harmonized riff cleanly and in time.','Palm mute where needed for tightness.'],
     'Studio recording, 1976. The harmonized riff was tracked on Les Pauls into cranked Marshalls.',78),
    ('don-t-fear-the-reaper','blue-oyster-cult','guitar','riff','main riff','clean','rock','rhythm','beginner',
     'Gibson SG (Buck Dharma)','Clean-to-edge tube amp','Open-back combo cab','neck or bridge pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Clean-to-edge tone with a little sparkle; the riff should stay clear and jangly.','Low gain keeps the arpeggiated chords defined.'],
     array['Let the picked chord pattern ring evenly.','Keep a steady, relaxed tempo.'],
     'Studio recording, 1976. Buck Dharma played the riff with a clean-to-edge tone.',76),
    ('hey-joe','jimi-hendrix','guitar','riff','main progression','crunch','rock','lead','intermediate',
     'Fender Stratocaster (Jimi Hendrix)','Marshall crunch amp','Marshall 4x12 cab','neck and middle single-coil',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Warm, lightly-driven tone; roll the guitar volume for the cleaner chord work.','Let the amp break up gently on the fills.'],
     array['Blend rhythm chords with lead fills fluidly.','Use thumb-over chording for the bass notes.'],
     'Studio recording, 1966. Jimi Hendrix played the progression with a warm, lightly-driven Strat tone.',78),
    ('all-along-the-watchtower','jimi-hendrix','guitar','solo','main solo sections','distorted','rock','lead','advanced',
     'Fender Stratocaster (Jimi Hendrix)','Marshall Super Lead','Marshall 4x12 cab','bridge single-coil',
     '[{"effect_type":"wah","effect_name":"wah (for slide and lead accents)","placement":"front","settings":{"position":5}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Expressive lead tone with wah accents and slide; the amp carries the sustain.','Use dynamics and the wah for the multiple solo sections.'],
     array['Slide and wah phrasing shape the solos.','Vary attack across the four distinct solo sections.'],
     'Studio recording, 1968. Jimi Hendrix layered the solos with wah and slide over a driven Marshall.',80),
    ('little-wing','jimi-hendrix','guitar','riff','clean chordal theme','clean','rock','lead','advanced',
     'Fender Stratocaster (Jimi Hendrix)','Fender clean amp with rotary/vibe','Open-back combo cab','neck single-coil',
     '[{"effect_type":"modulation","effect_name":"Leslie / Uni-Vibe (glassy shimmer)","placement":"post_gain","settings":{"depth":4,"rate":3,"mix":5}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm clean tone with a glassy rotary shimmer; the thumb-over chord embellishments are the identity.','Keep gain very low so the chord melody rings clearly.'],
     array['Use thumb-over chording with hammer-on and slide embellishments.','Let the chord fragments ring into each other.'],
     'Studio recording, 1967. Jimi Hendrix played the clean chordal theme with a rotary/vibe shimmer.',80),
    ('where-the-streets-have-no-name','u2','guitar','riff','delay-driven main riff','clean','rock','rhythm','advanced',
     'Fender Stratocaster / Gibson Explorer (The Edge)','Vox AC30','Open-back combo cab','neck or bridge pickup',
     '[{"effect_type":"delay","effect_name":"dotted-eighth delay","placement":"post_gain","settings":{"mix":6,"time":5,"feedback":4}}]'::jsonb,
     '{"gain":3,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":6,"master":6}'::jsonb,
     array['The dotted-eighth delay IS the riff; set the delay time to the tempo so the repeats form the arpeggio.','Keep the amp bright and mostly clean so the repeats stay distinct.'],
     array['Play simple picked notes and let the delay build the pattern.','Lock the delay timing to the song tempo.'],
     'Studio recording, 1987. The Edge built the riff around a tempo-synced dotted-eighth delay into a Vox AC30.',82),
    ('with-or-without-you','u2','guitar','riff','sustained clean melody','clean','rock','lead','intermediate',
     'Infinite-sustain guitar / ebow (The Edge)','Vox AC30','Open-back combo cab','neck pickup',
     '[{"effect_type":"delay","effect_name":"clean delay","placement":"post_gain","settings":{"mix":4,"time":4}},{"effect_type":"reverb","effect_name":"ambient reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":4,"master":6}'::jsonb,
     array['The soaring melody uses infinite sustain (ebow) with delay and reverb; keep the amp clean.','An ebow or long sustain plus ambience recreates the floating line.'],
     array['Sustain single notes and let them bloom.','Swell in with volume for the smoothest attack.'],
     'Studio recording, 1987. The Edge used an infinite-sustain guitar with delay and reverb into a clean Vox.',80),
    ('zombie','the-cranberries','guitar','riff','chorus riff','distorted','rock','rhythm','intermediate',
     'Fender / Gibson guitar (Noel Hogan)','Clean amp pushed by distortion','Closed-back guitar cab','bridge pickup',
     '[{"effect_type":"distortion","effect_name":"distortion pedal","placement":"front","settings":{"gain":6,"tone":5,"level":6}},{"effect_type":"modulation","effect_name":"chorus (clean verse)","placement":"post_gain","settings":{"depth":3,"mix":3}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Big dynamic jump from clean chorus-laden verse to distorted chorus.','Keep the chorus distortion thick but not too tight.'],
     array['Hit the chorus power chords with weight.','Keep the verse arpeggios clean and even.'],
     'Studio recording, 1994. Noel Hogan contrasted a clean chorused verse with a distorted chorus riff.',78),
    ('wish-you-were-here','pink-floyd','guitar','intro','acoustic intro and theme','acoustic','rock','clean','intermediate',
     'Steel-string acoustic guitar (David Gilmour)','Acoustic DI / microphone chain','Full-range monitoring','acoustic source',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The main theme is acoustic; keep it natural and dynamic.','For electric, use a clean bright tone with low gain.'],
     array['Let the picked intro figure ring clearly.','Use light, expressive dynamics.'],
     'Studio recording, 1975. David Gilmour played the intro and theme on a steel-string acoustic.',80),
    ('another-brick-in-the-wall-part-2','pink-floyd','guitar','solo','guitar solo','distorted','rock','lead','advanced',
     'Fender Stratocaster Black Strat (David Gilmour)','Hiwatt clean platform','WEM 4x12 cab','bridge and neck single-coil',
     '[{"effect_type":"fuzz","effect_name":"Big Muff-style fuzz","placement":"front","settings":{"gain":6,"tone":5,"level":6}},{"effect_type":"delay","effect_name":"analog delay","placement":"post_gain","settings":{"mix":2,"time":4}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":3,"master":6}'::jsonb,
     array['Smooth, sustaining lead built on a clean Hiwatt with a Big Muff-style fuzz.','Midrange sustain and controlled bends over extra gain.'],
     array['Bend and sustain with slow vibrato.','Let the disco-groove backing frame the phrasing.'],
     'Studio recording, 1979. David Gilmour played the solo on the Black Strat with a Big Muff-style fuzz and delay.',82),
    ('paradise-city','guns-n-roses','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Gibson Les Paul-style guitar (Slash)','Marshall modified 1959','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Amp-driven crunch with strong mids; keep it dynamic for the verse-to-chorus lift.','Roll guitar volume back for the cleaner verse.'],
     array['Let the open chords ring on the chorus.','Keep the palm mutes tight on the verse.'],
     'Studio recording, 1987. Slash tracked the riff on a Les Paul into a modified Marshall.',80),
    ('chop-suey','system-of-a-down','guitar','riff','main riff','distorted','metal','rhythm','advanced',
     'Ibanez humbucker guitar in Drop C# (Daron Malakian)','Marshall / Mesa high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Tight drop-tuned high gain; keep the low end controlled for the fast riffing.','Do not over-scoop or the palm mutes lose definition.'],
     array['Precise alternate picking on the fast riff.','Tight palm muting drives the verse.'],
     'Studio recording, 2001. Daron Malakian tracked the riff in a dropped tuning through a high-gain amp.',78),
    ('toxicity','system-of-a-down','guitar','riff','main riff','distorted','metal','rhythm','intermediate',
     'Ibanez humbucker guitar in Drop C (Daron Malakian)','Marshall / Mesa high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Tight drop-C high gain; keep the riff percussive and controlled.','Balance low-end weight with pick clarity.'],
     array['Lock the syncopated riff to the drums.','Use firm palm muting on the low string.'],
     'Studio recording, 2001. Daron Malakian played the riff in Drop C through a high-gain amp.',78),
    ('numb','linkin-park','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'PRS humbucker guitar (Brad Delson)','Mesa/Boogie high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Modern mid-gain rock rhythm; keep it tight behind the vocal and piano.','Clean-to-heavy dynamics between verse and chorus.'],
     array['Palm mute the driving power chords.','Keep the chorus chords big and ringing.'],
     'Studio recording, 2003. Brad Delson tracked the riff through a high-gain Mesa amp.',77),
    ('welcome-to-the-jungle','guns-n-roses','guitar','riff','main riff','distorted','rock','rhythm','advanced',
     'Gibson Les Paul-style guitar (Slash)','Marshall Super Lead 1959','Marshall 4x12 cab','bridge humbucker',
     '[{"effect_type":"delay","effect_name":"delay (intro layering)","placement":"post_gain","settings":{"mix":3,"time":4}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":2,"master":6}'::jsonb,
     array['A layered delay creates the shimmering intro; the main riff is amp-driven crunch.','Strong mids keep the riff cutting.'],
     array['Let the intro chords ring with the delay.','Dig into the main riff with confident attack.'],
     'Studio recording, 1987. Slash layered the intro with delay and drove the riff through a cranked Marshall.',80),
    ('californication','red-hot-chili-peppers','guitar','lead','main lead melody','clean','rock','lead','intermediate',
     'Fender Stratocaster (John Frusciante)','Clean Fender / Marshall-style amp','Open-back combo cab','neck single-coil',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm neck single-coil clean tone; keep the amp mostly clean for the melodic hook.','Avoid harsh bright tones; roll back the tone if needed.'],
     array['Play with relaxed attack and clean slides.','Let the melody notes decay naturally.'],
     'Studio recording, 1999. John Frusciante played the clean melodic lead on a Stratocaster into a clean amp.',80)
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
  ('led-zeppelin','kashmir'),('ac-dc','thunderstruck'),('aerosmith','sweet-emotion'),
  ('boston','more-than-a-feeling'),('kansas','carry-on-wayward-son'),('blue-oyster-cult','don-t-fear-the-reaper'),
  ('jimi-hendrix','hey-joe'),('jimi-hendrix','all-along-the-watchtower'),('jimi-hendrix','little-wing'),
  ('u2','where-the-streets-have-no-name'),('u2','with-or-without-you'),('the-cranberries','zombie'),
  ('pink-floyd','wish-you-were-here'),('pink-floyd','another-brick-in-the-wall-part-2'),('guns-n-roses','paradise-city'),
  ('system-of-a-down','chop-suey'),('system-of-a-down','toxicity'),('linkin-park','numb'),
  ('guns-n-roses','welcome-to-the-jungle'),('red-hot-chili-peppers','californication')
) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
cross join (values
  ('artist_interview', 'Documented artist interviews and gear discussions', null::text,
   'Researched from widely-documented interviews about this recording and player.', 72),
  ('rig_rundown', 'Published rig rundowns and community gear databases', null::text,
   'Cross-referenced against rig features and community-maintained gear databases.', 66)
) as x(source_type, title, url, notes, credibility)
where p.verification_status = 'admin_verified'
on conflict do nothing;
