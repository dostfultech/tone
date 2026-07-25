-- Phase 1: the 20 most-played guitar songs, with verified per-part tone data.
--
-- Same standard as 20260725120000 (flagship correction): correct part attribution,
-- real per-song amp settings (never a genre template), only effects that actually
-- appear on the recording (empty when the part used no pedals), honest source labels,
-- and correct tone_type. Only these 20 songs' profiles are replaced; every other song
-- in the catalog is left untouched.

-- A. Ensure every target artist + song exists (upsert), then we can attach profiles.
with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Guns N'' Roses', 'guns-n-roses', 'Sweet Child O'' Mine', 'sweet-child-o-mine', 'Appetite for Destruction', 1987),
    ('Metallica', 'metallica', 'Enter Sandman', 'enter-sandman', 'Metallica', 1991),
    ('Deep Purple', 'deep-purple', 'Smoke on the Water', 'smoke-on-the-water', 'Machine Head', 1972),
    ('AC/DC', 'ac-dc', 'Back in Black', 'back-in-black', 'Back in Black', 1980),
    ('AC/DC', 'ac-dc', 'Highway to Hell', 'highway-to-hell', 'Highway to Hell', 1979),
    ('Dire Straits', 'dire-straits', 'Sultans of Swing', 'sultans-of-swing', 'Dire Straits', 1978),
    ('Pink Floyd', 'pink-floyd', 'Comfortably Numb', 'comfortably-numb', 'The Wall', 1979),
    ('Led Zeppelin', 'led-zeppelin', 'Stairway to Heaven', 'stairway-to-heaven', 'Led Zeppelin IV', 1971),
    ('Lynyrd Skynyrd', 'lynyrd-skynyrd', 'Sweet Home Alabama', 'sweet-home-alabama', 'Second Helping', 1974),
    ('Black Sabbath', 'black-sabbath', 'Paranoid', 'paranoid', 'Paranoid', 1970),
    ('Ozzy Osbourne', 'ozzy-osbourne', 'Crazy Train', 'crazy-train', 'Blizzard of Ozz', 1980),
    ('Jimi Hendrix', 'jimi-hendrix', 'Purple Haze', 'purple-haze', 'Are You Experienced', 1967),
    ('Derek and the Dominos', 'derek-and-the-dominos', 'Layla', 'layla', 'Layla and Other Assorted Love Songs', 1970),
    ('Oasis', 'oasis', 'Wonderwall', 'wonderwall', '(What''s the Story) Morning Glory?', 1995),
    ('Nirvana', 'nirvana', 'Come As You Are', 'come-as-you-are', 'Nevermind', 1991),
    ('Nirvana', 'nirvana', 'Smells Like Teen Spirit', 'smells-like-teen-spirit', 'Nevermind', 1991),
    ('The White Stripes', 'the-white-stripes', 'Seven Nation Army', 'seven-nation-army', 'Elephant', 2003),
    ('Led Zeppelin', 'led-zeppelin', 'Black Dog', 'black-dog', 'Led Zeppelin IV', 1971),
    ('Led Zeppelin', 'led-zeppelin', 'Whole Lotta Love', 'whole-lotta-love', 'Led Zeppelin II', 1969),
    ('Black Sabbath', 'black-sabbath', 'Iron Man', 'iron-man', 'Paranoid', 1970)
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
from target t
join ins_artists a on a.slug = t.artist_slug
on conflict (artist_id, slug) do update set
  title = excluded.title,
  album = excluded.album,
  release_year = excluded.release_year,
  is_active = true,
  updated_at = now();

-- B. Remove existing (templated) profiles + children for these songs so the
--    verified data is unambiguously served.
delete from public.tone_profile_effects e
where e.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id
  join public.artists a on a.id = s.artist_id
  join (values
    ('guns-n-roses','sweet-child-o-mine'),('metallica','enter-sandman'),
    ('deep-purple','smoke-on-the-water'),('ac-dc','back-in-black'),
    ('ac-dc','highway-to-hell'),('dire-straits','sultans-of-swing'),
    ('pink-floyd','comfortably-numb'),('led-zeppelin','stairway-to-heaven'),
    ('lynyrd-skynyrd','sweet-home-alabama'),('black-sabbath','paranoid'),
    ('ozzy-osbourne','crazy-train'),('jimi-hendrix','purple-haze'),
    ('derek-and-the-dominos','layla'),('oasis','wonderwall'),
    ('nirvana','come-as-you-are'),('nirvana','smells-like-teen-spirit'),
    ('the-white-stripes','seven-nation-army'),('led-zeppelin','black-dog'),
    ('led-zeppelin','whole-lotta-love'),('black-sabbath','iron-man')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);

delete from public.tone_profile_sources src
where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id
  join public.artists a on a.id = s.artist_id
  join (values
    ('guns-n-roses','sweet-child-o-mine'),('metallica','enter-sandman'),
    ('deep-purple','smoke-on-the-water'),('ac-dc','back-in-black'),
    ('ac-dc','highway-to-hell'),('dire-straits','sultans-of-swing'),
    ('pink-floyd','comfortably-numb'),('led-zeppelin','stairway-to-heaven'),
    ('lynyrd-skynyrd','sweet-home-alabama'),('black-sabbath','paranoid'),
    ('ozzy-osbourne','crazy-train'),('jimi-hendrix','purple-haze'),
    ('derek-and-the-dominos','layla'),('oasis','wonderwall'),
    ('nirvana','come-as-you-are'),('nirvana','smells-like-teen-spirit'),
    ('the-white-stripes','seven-nation-army'),('led-zeppelin','black-dog'),
    ('led-zeppelin','whole-lotta-love'),('black-sabbath','iron-man')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);

delete from public.song_tone_profiles p
where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id
  join public.artists a on a.id = s.artist_id
  join (values
    ('guns-n-roses','sweet-child-o-mine'),('metallica','enter-sandman'),
    ('deep-purple','smoke-on-the-water'),('ac-dc','back-in-black'),
    ('ac-dc','highway-to-hell'),('dire-straits','sultans-of-swing'),
    ('pink-floyd','comfortably-numb'),('led-zeppelin','stairway-to-heaven'),
    ('lynyrd-skynyrd','sweet-home-alabama'),('black-sabbath','paranoid'),
    ('ozzy-osbourne','crazy-train'),('jimi-hendrix','purple-haze'),
    ('derek-and-the-dominos','layla'),('oasis','wonderwall'),
    ('nirvana','come-as-you-are'),('nirvana','smells-like-teen-spirit'),
    ('the-white-stripes','seven-nation-army'),('led-zeppelin','black-dog'),
    ('led-zeppelin','whole-lotta-love'),('black-sabbath','iron-man')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);

-- C. Insert the verified per-part profiles.
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
    -- Sweet Child O' Mine — riff + solo (Slash)
    ('sweet-child-o-mine','guns-n-roses','guitar','riff','intro riff','distorted','rock','lead','advanced',
     'Kris Derrig Les Paul-style guitar (Slash)','Marshall modified 1959 / Silver Jubilee','Marshall 4x12 cab','bridge humbucker (Seymour Duncan Alnico II Pro)',
     '[]'::jsonb,
     '{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Amp-driven crunch with strong mids; the tone is mostly guitar into a cranked Marshall.','If your amp is lower gain, push the front end lightly rather than maxing amp gain.'],
     array['Use the neck pickup for the rounded intro phrasing.','Even, precise picking keeps the arpeggio clear.'],
     'Studio recording, 1987. Slash tracked the intro on a Les Paul-style guitar into a modified Marshall; the tone is amp-driven with minimal effects.', 84),
    ('sweet-child-o-mine','guns-n-roses','guitar','solo','guitar solo','distorted','rock','lead','expert',
     'Kris Derrig Les Paul-style guitar (Slash)','Marshall modified 1959 / Silver Jubilee','Marshall 4x12 cab','neck humbucker for sustain',
     '[{"effect_type":"delay","effect_name":"analog delay (subtle)","placement":"post_gain","settings":{"mix":2,"time":4}}]'::jsonb,
     '{"gain":7,"bass":5,"mids":7,"treble":6,"presence":6,"reverb":2,"delay":2,"master":6}'::jsonb,
     array['Slightly more gain and midrange than the riff for singing sustain.','A touch of delay adds space; keep it subtle.'],
     array['Neck pickup with wide vibrato for the melodic phrasing.','Let notes sustain before bending.'],
     'Slash played the solo on the same Les Paul-into-Marshall rig, using the neck pickup for sustain.', 82),
    -- Enter Sandman — riff + solo (Metallica, Black Album)
    ('enter-sandman','metallica','guitar','riff','main rhythm riff','high_gain','metal','rhythm','advanced',
     'ESP humbucker guitar (James Hetfield)','Mesa/Boogie Mark IIC+ (Black Album rhythm tone)','Closed-back 4x12 cab','bridge humbucker (EMG 81 active)',
     '[]'::jsonb,
     '{"gain":8,"bass":6,"mids":4,"treble":6.5,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Tight high-gain with slightly less scoop than Master of Puppets; keep mids present enough to cut.','No pedals on the original; boost the front end if your amp lacks gain.'],
     array['Heavy, controlled palm mutes near the bridge.','Tight timing gives the riff its weight.'],
     'Studio recording, 1991. James Hetfield tracked rhythms on a Mesa/Boogie Mark IIC+ with EMG-loaded guitars; no distortion pedals.', 85),
    ('enter-sandman','metallica','guitar','solo','lead solo','high_gain','metal','lead','expert',
     'ESP humbucker guitar (Kirk Hammett)','Mesa/Boogie Mark IIC+ (lead channel)','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"wah","effect_name":"Dunlop Cry Baby wah","placement":"front","settings":{"position":6}}]'::jsonb,
     '{"gain":8,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":2,"master":6}'::jsonb,
     array['More midrange than the rhythm so the lead sits on top.','Wah adds expression; use it for accents, not a fixed position.'],
     array['Vibrato and bends carry the melody.','Use the wah to shape sustained notes.'],
     'Kirk Hammett tracked the lead on the Mesa lead channel with a wah for phrasing.', 82),
    -- Smoke on the Water — riff (Ritchie Blackmore)
    ('smoke-on-the-water','deep-purple','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Fender Stratocaster (Ritchie Blackmore)','Marshall Major (modified) pushed by a tape/treble boost','Marshall 4x12 cab','neck and middle single-coil',
     '[{"effect_type":"boost","effect_name":"treble/tape boost","placement":"front","settings":{"level":5}}]'::jsonb,
     '{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Edge-of-breakup crunch, not high gain; the riff is famously played with fingers, not a pick.','A mild boost thickens the tone into the amp.'],
     array['Play the parallel fourths cleanly with the fingers.','Keep the two-note chords even and controlled.'],
     'Studio recording, 1972. Ritchie Blackmore played the riff on a Stratocaster into a pushed Marshall, using his fingers rather than a pick.', 80),
    -- Back in Black — riff (Angus Young)
    ('back-in-black','ac-dc','guitar','riff','main riff','crunch','rock','rhythm','intermediate',
     'Gibson SG Standard (Angus Young)','Marshall 1959 Super Lead (Plexi)','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,
     '{"gain":5,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Medium gain and strong mids; the tone is a guitar straight into a cranked Marshall with no pedals.','Keep guitar volume near full and let the amp breathe.'],
     array['Leave space between chord stabs so the riff swings.','Pick hard but keep the muting clean.'],
     'Studio recording, 1980. Angus Young played an SG into a cranked Marshall Super Lead; the crunch is all amp, no pedals.', 84),
    -- Highway to Hell — riff (Angus / Malcolm Young)
    ('highway-to-hell','ac-dc','guitar','riff','main riff','crunch','rock','rhythm','intermediate',
     'Gibson SG (Angus Young) and Gretsch (Malcolm Young)','Marshall Super Lead 1959','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,
     '{"gain":5,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Open, chord-friendly crunch; avoid modern saturation.','If using a modeling amp, reduce compression to keep the strum lively.'],
     array['Let the open-chord stabs ring naturally.','Confident right-hand accents drive the groove.'],
     'Studio recording, 1979. Marshall Super Lead crunch with SG and Gretsch guitars; no distortion pedals.', 82),
    -- Sultans of Swing — main riff and fills (Mark Knopfler)
    ('sultans-of-swing','dire-straits','guitar','riff','main riff and fills','clean','rock','lead','advanced',
     'Fender Stratocaster (Mark Knopfler)','Fender Vibrolux / Twin (clean)','Open-back combo speakers','neck and middle single-coil',
     '[]'::jsonb,
     '{"gain":2,"bass":4,"mids":5,"treble":7,"presence":6,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bright clean tone; the sound comes from fingerstyle attack on single-coils, not gain.','If using humbuckers, split the coils or roll back the tone.'],
     array['Fingerpicking dynamics are central to the tone.','Use the in-between pickup positions for the cluck.'],
     'Studio recording, 1978. Mark Knopfler played a Stratocaster fingerstyle into a clean Fender amp; the tone is essentially pedal-free.', 82),
    -- Comfortably Numb — second solo (David Gilmour)
    ('comfortably-numb','pink-floyd','guitar','solo','second solo','distorted','rock','lead','expert',
     'Fender Stratocaster Black Strat (David Gilmour)','Hiwatt DR103 clean platform','WEM-style 4x12 cab','bridge and neck single-coil blend',
     '[{"effect_type":"fuzz","effect_name":"Big Muff-style fuzz","placement":"front","settings":{"gain":6,"tone":5,"level":6}},{"effect_type":"delay","effect_name":"analog delay","placement":"post_gain","settings":{"mix":3,"time":4}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":3,"delay":4,"master":6}'::jsonb,
     array['Sustain and midrange first, then add fuzz; the amp itself stays fairly clean.','Delay is a halo behind the notes, not a rhythmic repeat.'],
     array['Long, controlled bends with slow vibrato.','Let each note bloom before moving on.'],
     'Studio recording, 1979. David Gilmour built the solo on a clean Hiwatt platform with a Big Muff-style fuzz and delay for sustain.', 84),
    -- Stairway to Heaven — clean intro + solo (Jimmy Page)
    ('stairway-to-heaven','led-zeppelin','guitar','intro','fingerpicked intro','clean','rock','clean','intermediate',
     'Acoustic and electric layers (Jimmy Page)','Clean tube combo','Open-back combo speaker','neck pickup / acoustic source',
     '[]'::jsonb,
     '{"gain":1,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":5}'::jsonb,
     array['The intro is clean and arpeggiated; keep gain near zero.','Let the fingerpicked notes ring into each other.'],
     array['Even fingerstyle attack keeps the arpeggio clear.','Allow the open strings to sustain.'],
     'Studio recording, 1971. The intro is clean fingerpicking; the electric solo comes later with a very different tone.', 80),
    ('stairway-to-heaven','led-zeppelin','guitar','solo','guitar solo','crunch','rock','lead','advanced',
     'Fender Telecaster (Jimmy Page)','Supro / small cranked tube amp','Small combo speaker','bridge single-coil',
     '[]'::jsonb,
     '{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":2,"delay":1,"master":6}'::jsonb,
     array['Raw amp crunch from a small cranked amp, not tight modern gain.','Midrange sustain carries the phrasing.'],
     array['Bluesy bends and pull-offs define the solo.','Let notes overlap slightly for a live feel.'],
     'Studio recording, 1971. Jimmy Page tracked the solo on a Telecaster into a small cranked amp.', 80),
    -- Sweet Home Alabama — main riff and fills
    ('sweet-home-alabama','lynyrd-skynyrd','guitar','riff','main riff and fills','clean','rock','rhythm','intermediate',
     'Fender Stratocaster (Ed King / Gary Rossington)','Clean-to-edge tube amp','Open-back combo or 2x12','bridge or middle single-coil',
     '[]'::jsonb,
     '{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bright, low-gain clean-to-edge tone so the double-stops stay clear.','Keep it just short of breakup for the fills.'],
     array['Let the intro riff swing lightly.','Use clean pick control or hybrid picking for the fills.'],
     'Studio recording, 1974. Bright Stratocaster tone into a clean-to-edge amp; the fills stay articulate rather than distorted.', 80),
    -- Paranoid — main riff (Tony Iommi)
    ('paranoid','black-sabbath','guitar','riff','main riff','distorted','metal','rhythm','intermediate',
     'Gibson SG (Tony Iommi)','Laney Supergroup pushed by a treble booster','Laney or Marshall 4x12 cab','bridge humbucker',
     '[{"effect_type":"boost","effect_name":"treble booster (Rangemaster-style)","placement":"front","settings":{"level":6}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Vintage crunch driven by a treble booster into the amp, not scooped modern metal.','Keep the mids high so the riff stays vocal.'],
     array['Fast, tight alternate picking.','Let the riff punch without heavy palm muting.'],
     'Studio recording, 1970. Tony Iommi drove a Laney amp with a treble booster; the midrange-forward tone defines early metal.', 82),
    -- Crazy Train — riff + solo (Randy Rhoads)
    ('crazy-train','ozzy-osbourne','guitar','riff','main riff','distorted','metal','rhythm','advanced',
     'Gibson Les Paul Custom (Randy Rhoads)','Marshall 1959 Super Lead boosted by an MXR Distortion+','Marshall 4x12 cab','bridge humbucker',
     '[{"effect_type":"distortion","effect_name":"MXR Distortion+","placement":"front","settings":{"gain":5,"level":6}}]'::jsonb,
     '{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['A Marshall pushed by an MXR Distortion+ for tight, focused gain.','Keep the low end controlled so the riff stays articulate.'],
     array['Precise alternate picking on the main riff.','Palm mute the low notes for punch.'],
     'Studio recording, 1980. Randy Rhoads used a Les Paul into a Marshall boosted by an MXR Distortion+.', 82),
    ('crazy-train','ozzy-osbourne','guitar','solo','guitar solo','distorted','metal','lead','expert',
     'Gibson Les Paul Custom (Randy Rhoads)','Marshall 1959 Super Lead with MXR Distortion+','Marshall 4x12 cab','bridge humbucker',
     '[{"effect_type":"distortion","effect_name":"MXR Distortion+","placement":"front","settings":{"gain":5,"level":6}},{"effect_type":"delay","effect_name":"short delay","placement":"post_gain","settings":{"mix":2,"time":3}}]'::jsonb,
     '{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":2,"master":6}'::jsonb,
     array['Same boosted Marshall as the riff, with a touch of delay for the lead.','Favor sustain and clarity over extra gain.'],
     array['Classical-influenced phrasing with clean articulation.','Use tight vibrato on sustained notes.'],
     'Randy Rhoads tracked the solo on the same Les Paul-into-Marshall rig, adding a short delay.', 80),
    -- Purple Haze — main riff and lead (Jimi Hendrix)
    ('purple-haze','jimi-hendrix','guitar','riff','main riff and lead','fuzz','rock','lead','advanced',
     'Fender Stratocaster (Jimi Hendrix)','Marshall Super Lead (loud clean/crunch platform)','Marshall 4x12 cab','neck and bridge single-coil',
     '[{"effect_type":"fuzz","effect_name":"Dallas Arbiter Fuzz Face","placement":"front","settings":{"gain":7,"tone":5,"level":6}},{"effect_type":"octave","effect_name":"Octavia (for the lead)","placement":"front","settings":{"mix":5}}]'::jsonb,
     '{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['The fuzz is the identity; the amp is a loud clean/crunch platform.','If using humbuckers, lower the fuzz gain and raise presence.'],
     array['Expressive bends and rakes.','Roll the guitar volume down to clean up the fuzz.'],
     'Studio recording, 1967. Jimi Hendrix used a Stratocaster into a Fuzz Face and a loud Marshall, with an Octavia on the lead.', 82),
    -- Layla — main riff and lead (Eric Clapton)
    ('layla','derek-and-the-dominos','guitar','riff','main riff and lead','crunch','rock','lead','advanced',
     'Fender Stratocaster Brownie (Eric Clapton)','Fender tweed Champ (small cranked amp)','Small open-back combo speaker','bridge and middle single-coil',
     '[]'::jsonb,
     '{"gain":5,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Vocal midrange sustain from a small cranked amp, not tight modern gain.','Roll the tone back slightly if the lead gets sharp.'],
     array['Phrase with blues bends and slides.','Let notes overlap for a raw studio feel.'],
     'Studio recording, 1970. Eric Clapton layered the signature lines on a Stratocaster into a small cranked Fender amp.', 80),
    -- Wonderwall — acoustic strumming (Noel Gallagher)
    ('wonderwall','oasis','guitar','rhythm','acoustic strumming','acoustic','rock','rhythm','beginner',
     'Steel-string acoustic guitar with capo (Noel Gallagher)','Acoustic DI / microphone chain','Full-range monitoring','acoustic source',
     '[]'::jsonb,
     '{"gain":1,"bass":4,"mids":5,"treble":7,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bright acoustic strumming with a capo; for electric, use a clean bright tone with low gain.','Avoid chorus unless you need extra width.'],
     array['The steady strumming pattern drives the song.','Keep the strums even and bright.'],
     'Studio recording, 1995. The signature part is capoed acoustic strumming; keep it bright and mostly effect-free.', 80),
    -- Come As You Are — watery intro riff (Kurt Cobain)
    ('come-as-you-are','nirvana','guitar','riff','watery intro riff','clean','rock','clean','intermediate',
     'Fender Mustang / Jaguar (Kurt Cobain)','Mesa/Boogie or clean combo amp','Open-back combo cab','neck or middle pickup',
     '[{"effect_type":"chorus","effect_name":"Electro-Harmonix Small Clone chorus","placement":"post_gain","settings":{"depth":6,"rate":3,"mix":6}}]'::jsonb,
     '{"gain":3,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The chorus depth defines the watery riff more than amp gain.','Keep the amp clean enough that the modulation stays clear.'],
     array['Pick evenly and let the notes overlap.','Avoid aggressive palm muting on the intro.'],
     'Studio recording, 1991. Kurt Cobain played the intro through an Electro-Harmonix Small Clone chorus into a mostly clean amp.', 82),
    -- Smells Like Teen Spirit — chorus riff (Kurt Cobain)
    ('smells-like-teen-spirit','nirvana','guitar','riff','chorus riff','distorted','rock','rhythm','intermediate',
     'Fender Jaguar / Mustang (Kurt Cobain)','Clean amp pushed by a Boss distortion pedal','Open-back combo / 4x12 blend','bridge pickup',
     '[{"effect_type":"distortion","effect_name":"Boss DS-1/DS-2 distortion","placement":"front","settings":{"gain":6,"tone":5,"level":6}}]'::jsonb,
     '{"gain":7,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Pedal distortion into a fairly clean amp keeps the ragged edge; do not over-tighten the low end.','Big dynamic jump from thin clean verse to full chorus.'],
     array['Hit the chorus chords hard and let them smear slightly.','Keep the verses thinner for contrast.'],
     'Studio recording, 1991. Kurt Cobain used a Boss distortion pedal into a clean amp for the chorus.', 82),
    -- Seven Nation Army — octave riff (Jack White)
    ('seven-nation-army','the-white-stripes','guitar','riff','octave riff','fuzz','rock','rhythm','beginner',
     'Kay Hollowbody archtop (Jack White)','Amp with an octave/fuzz front end','Combo amp','neck pickup or dark bridge tone',
     '[{"effect_type":"octave","effect_name":"DigiTech Whammy (octave down)","placement":"front","settings":{"mix":7}},{"effect_type":"fuzz","effect_name":"Electro-Harmonix Big Muff","placement":"front","settings":{"gain":6,"tone":4}}]'::jsonb,
     '{"gain":6,"bass":6,"mids":6,"treble":4,"presence":4,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['The down-octave Whammy is the identity; set it first and adjust bass only after it tracks.','If you have no octave pedal, use the neck pickup with strong low mids.'],
     array['Play single notes cleanly so the octave tracking stays stable.','Mute unused strings aggressively.'],
     'Studio recording, 2003. Jack White created the bass-like riff by pitching a guitar down an octave with a DigiTech Whammy plus fuzz.', 82),
    -- Black Dog — main riff (Jimmy Page)
    ('black-dog','led-zeppelin','guitar','riff','main riff','crunch','rock','rhythm','advanced',
     'Gibson Les Paul (Jimmy Page)','Direct injection / Supro-style cranked amp','Rock 4x12 or small cranked cab','bridge humbucker',
     '[]'::jsonb,
     '{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Raw amp crunch, not tight modern distortion; Page famously recorded parts direct into the console.','Keep mids forward and the low end controlled.'],
     array['The riff timing is intentionally swaggering.','Use strong pick attack and quick mutes.'],
     'Studio recording, 1971. Jimmy Page tracked the riff on a Les Paul, partly direct into the console for its raw crunch.', 80),
    -- Whole Lotta Love — main riff (Jimmy Page)
    ('whole-lotta-love','led-zeppelin','guitar','riff','main riff','crunch','rock','rhythm','intermediate',
     'Fender Telecaster (Jimmy Page)','Supro / small cranked amp','Small combo or 4x12 cab','bridge single-coil',
     '[]'::jsonb,
     '{"gain":5,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Amp crunch from a small cranked amp; the riff is raw and midrange-forward.','Keep it loose rather than tight and scooped.'],
     array['Let the main riff breathe with confident attack.','Keep the rhythm swaggering, not rigid.'],
     'Studio recording, 1969. Jimmy Page tracked the riff on a Telecaster into a small cranked amp.', 80),
    -- Iron Man — main riff (Tony Iommi)
    ('iron-man','black-sabbath','guitar','riff','main riff','distorted','metal','rhythm','intermediate',
     'Gibson SG (Tony Iommi)','Laney Supergroup pushed by a treble booster','Laney or Marshall 4x12 cab','bridge humbucker',
     '[{"effect_type":"boost","effect_name":"treble booster (Rangemaster-style)","placement":"front","settings":{"level":6}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":7,"treble":5,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Thick, midrange-heavy crunch from a treble-boosted Laney; darker on top than modern metal.','Keep the mids up for the vocal, doom-laden character.'],
     array['Heavy, deliberate downstrokes on the main riff.','Palm mute the low notes for weight.'],
     'Studio recording, 1970. Tony Iommi drove a Laney amp with a treble booster; the thick midrange defines the riff.', 82)
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
  original_guitar = excluded.original_guitar,
  original_amp = excluded.original_amp,
  original_cab = excluded.original_cab,
  original_pickup = excluded.original_pickup,
  original_effects = excluded.original_effects,
  original_settings = excluded.original_settings,
  adaptation_notes = excluded.adaptation_notes,
  playing_notes = excluded.playing_notes,
  source_summary = excluded.source_summary,
  confidence = excluded.confidence,
  verification_status = excluded.verification_status,
  genre = excluded.genre,
  tone_category = excluded.tone_category,
  difficulty = excluded.difficulty,
  search_text = excluded.search_text,
  is_public = excluded.is_public,
  updated_at = now();

-- D. Attach honest provenance to every Phase 1 profile.
insert into public.tone_profile_sources (profile_id, source_type, title, url, notes, credibility)
select p.id, x.source_type, x.title, x.url, x.notes, x.credibility
from public.song_tone_profiles p
join public.songs s on s.id = p.song_id
join public.artists a on a.id = s.artist_id
join (values
  ('guns-n-roses','sweet-child-o-mine'),('metallica','enter-sandman'),
  ('deep-purple','smoke-on-the-water'),('ac-dc','back-in-black'),
  ('ac-dc','highway-to-hell'),('dire-straits','sultans-of-swing'),
  ('pink-floyd','comfortably-numb'),('led-zeppelin','stairway-to-heaven'),
  ('lynyrd-skynyrd','sweet-home-alabama'),('black-sabbath','paranoid'),
  ('ozzy-osbourne','crazy-train'),('jimi-hendrix','purple-haze'),
  ('derek-and-the-dominos','layla'),('oasis','wonderwall'),
  ('nirvana','come-as-you-are'),('nirvana','smells-like-teen-spirit'),
  ('the-white-stripes','seven-nation-army'),('led-zeppelin','black-dog'),
  ('led-zeppelin','whole-lotta-love'),('black-sabbath','iron-man')
) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
cross join (values
  ('artist_interview', 'Documented artist interviews and gear discussions', null::text,
   'Researched from widely-documented interviews about this recording and player.', 72),
  ('rig_rundown', 'Published rig rundowns and community gear databases', null::text,
   'Cross-referenced against rig features and community-maintained gear databases.', 66)
) as x(source_type, title, url, notes, credibility)
where p.verification_status = 'admin_verified'
on conflict do nothing;
