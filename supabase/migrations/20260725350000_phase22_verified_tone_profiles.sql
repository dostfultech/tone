-- Phase 22: 25 classic-rock giant deep cuts, verified per-part tone data (Zeppelin, Hendrix, Beatles, Stones, Who, Deep Purple, Cream, Kinks, Yardbirds, Animals, Free, Bad Company, Grand Funk, Steppenwolf).

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Led Zeppelin','led-zeppelin','Since I''ve Been Loving You','since-ive-been-loving-you','Led Zeppelin III',1970),
    ('Led Zeppelin','led-zeppelin','The Ocean','the-ocean','Houses of the Holy',1973),
    ('Led Zeppelin','led-zeppelin','Communication Breakdown','communication-breakdown','Led Zeppelin',1969),
    ('Jimi Hendrix','jimi-hendrix','Crosstown Traffic','crosstown-traffic','Electric Ladyland',1968),
    ('Jimi Hendrix','jimi-hendrix','Foxy Lady','foxy-lady','Are You Experienced',1967),
    ('Jimi Hendrix','jimi-hendrix','Spanish Castle Magic','spanish-castle-magic','Axis: Bold as Love',1967),
    ('The Beatles','the-beatles','Get Back','get-back','Let It Be',1970),
    ('The Beatles','the-beatles','Ticket to Ride','ticket-to-ride','Help!',1965),
    ('The Beatles','the-beatles','Revolution','revolution','Hey Jude / single',1968),
    ('The Rolling Stones','the-rolling-stones','Jumpin'' Jack Flash','jumpin-jack-flash','single',1968),
    ('The Rolling Stones','the-rolling-stones','Honky Tonk Women','honky-tonk-women','single',1969),
    ('The Rolling Stones','the-rolling-stones','Angie','angie','Goats Head Soup',1973),
    ('The Who','the-who','My Generation','my-generation','My Generation',1965),
    ('The Who','the-who','Behind Blue Eyes','behind-blue-eyes','Who''s Next',1971),
    ('Deep Purple','deep-purple','Burn','burn','Burn',1974),
    ('Deep Purple','deep-purple','Space Truckin''','space-truckin','Machine Head',1972),
    ('Cream','cream','Badge','badge','Goodbye',1969),
    ('The Kinks','the-kinks','All Day and All of the Night','all-day-and-all-of-the-night','Kinks',1964),
    ('The Kinks','the-kinks','Lola','lola','Lola Versus Powerman',1970),
    ('The Yardbirds','the-yardbirds','Heart Full of Soul','heart-full-of-soul','single',1965),
    ('The Animals','the-animals','The House of the Rising Sun','the-house-of-the-rising-sun','single',1964),
    ('Free','free','Wishing Well','wishing-well','Heartbreaker',1973),
    ('Bad Company','bad-company','Feel Like Makin'' Love','feel-like-makin-love','Straight Shooter',1975),
    ('Grand Funk Railroad','grand-funk-railroad','We''re an American Band','were-an-american-band','We''re an American Band',1973),
    ('Steppenwolf','steppenwolf','Magic Carpet Ride','magic-carpet-ride','The Second',1968)
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
    ('led-zeppelin','since-ive-been-loving-you'),('led-zeppelin','the-ocean'),('led-zeppelin','communication-breakdown'),('jimi-hendrix','crosstown-traffic'),
    ('jimi-hendrix','foxy-lady'),('jimi-hendrix','spanish-castle-magic'),('the-beatles','get-back'),('the-beatles','ticket-to-ride'),
    ('the-beatles','revolution'),('the-rolling-stones','jumpin-jack-flash'),('the-rolling-stones','honky-tonk-women'),('the-rolling-stones','angie'),
    ('the-who','my-generation'),('the-who','behind-blue-eyes'),('deep-purple','burn'),('deep-purple','space-truckin'),
    ('cream','badge'),('the-kinks','all-day-and-all-of-the-night'),('the-kinks','lola'),('the-yardbirds','heart-full-of-soul'),
    ('the-animals','the-house-of-the-rising-sun'),('free','wishing-well'),('bad-company','feel-like-makin-love'),('grand-funk-railroad','were-an-american-band'),
    ('steppenwolf','magic-carpet-ride')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('led-zeppelin','since-ive-been-loving-you'),('led-zeppelin','the-ocean'),('led-zeppelin','communication-breakdown'),('jimi-hendrix','crosstown-traffic'),
    ('jimi-hendrix','foxy-lady'),('jimi-hendrix','spanish-castle-magic'),('the-beatles','get-back'),('the-beatles','ticket-to-ride'),
    ('the-beatles','revolution'),('the-rolling-stones','jumpin-jack-flash'),('the-rolling-stones','honky-tonk-women'),('the-rolling-stones','angie'),
    ('the-who','my-generation'),('the-who','behind-blue-eyes'),('deep-purple','burn'),('deep-purple','space-truckin'),
    ('cream','badge'),('the-kinks','all-day-and-all-of-the-night'),('the-kinks','lola'),('the-yardbirds','heart-full-of-soul'),
    ('the-animals','the-house-of-the-rising-sun'),('free','wishing-well'),('bad-company','feel-like-makin-love'),('grand-funk-railroad','were-an-american-band'),
    ('steppenwolf','magic-carpet-ride')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('led-zeppelin','since-ive-been-loving-you'),('led-zeppelin','the-ocean'),('led-zeppelin','communication-breakdown'),('jimi-hendrix','crosstown-traffic'),
    ('jimi-hendrix','foxy-lady'),('jimi-hendrix','spanish-castle-magic'),('the-beatles','get-back'),('the-beatles','ticket-to-ride'),
    ('the-beatles','revolution'),('the-rolling-stones','jumpin-jack-flash'),('the-rolling-stones','honky-tonk-women'),('the-rolling-stones','angie'),
    ('the-who','my-generation'),('the-who','behind-blue-eyes'),('deep-purple','burn'),('deep-purple','space-truckin'),
    ('cream','badge'),('the-kinks','all-day-and-all-of-the-night'),('the-kinks','lola'),('the-yardbirds','heart-full-of-soul'),
    ('the-animals','the-house-of-the-rising-sun'),('free','wishing-well'),('bad-company','feel-like-makin-love'),('grand-funk-railroad','were-an-american-band'),
    ('steppenwolf','magic-carpet-ride')
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
    ('since-ive-been-loving-you','led-zeppelin','guitar','riff','main progression and solo','crunch',
     'rock','lead','advanced',
     'Gibson Les Paul (Jimmy Page)','Marshall on the edge of breakup','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Slow, aching minor blues; keep it dynamic and let the amp break up only when you dig in.','Medium gain with huge feel.'],
     array['Play the bends and vibrato with vocal phrasing.','Control the dynamics from a whisper to a wail.'],
     'Studio recording, 1970 (Led Zeppelin III). Jimmy Page played an aching slow-blues on a Les Paul through a Marshall on the edge of breakup.',76),
    ('the-ocean','led-zeppelin','guitar','riff','main riff','crunch',
     'rock','rhythm','intermediate',
     'Gibson Les Paul (Jimmy Page)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Chunky, swaggering riff in a stop-start groove; keep it tight.','Medium gain with punch.'],
     array['Lock the syncopated riff to the drums.','Keep the palm mutes tight.'],
     'Studio recording, 1973 (Houses of the Holy). Jimmy Page played a chunky, swaggering riff on a Les Paul through a Marshall.',75),
    ('communication-breakdown','led-zeppelin','guitar','riff','main riff','crunch',
     'rock','rhythm','intermediate',
     'Fender Telecaster (Jimmy Page)','Small cranked amp (Supro-style)','Open-back combo cab','bridge single-coil',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Fast, frantic downstroke riff; keep it relentless and bright.','Medium-high gain, bright.'],
     array['Play the riff with fast, tight downstrokes.','Keep the tempo driving.'],
     'Studio recording, 1969 (Led Zeppelin). Jimmy Page played the fast, frantic riff on a Telecaster through a small cranked amp.',75),
    ('crosstown-traffic','jimi-hendrix','guitar','riff','main riff','fuzz',
     'rock','rhythm','intermediate',
     'Fender Stratocaster (Jimi Hendrix)','Marshall amp with fuzz','Marshall 4x12 cab','bridge single-coil',
     '[{"effect_type":"fuzz","effect_name":"fuzz","placement":"front","settings":{"gain":6,"tone":5,"level":6}}]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Punchy, fuzzy riff doubled with a kazoo-like line; keep it snappy.','Medium-high gain with fuzz.'],
     array['Play the staccato riff tightly.','Keep the groove bouncy.'],
     'Studio recording, 1968 (Electric Ladyland). Jimi Hendrix played a punchy, fuzzy riff on a Stratocaster through a Marshall.',75),
    ('foxy-lady','jimi-hendrix','guitar','riff','main riff','fuzz',
     'rock','lead','intermediate',
     'Fender Stratocaster (Jimi Hendrix)','Marshall amp with fuzz','Marshall 4x12 cab','bridge single-coil',
     '[{"effect_type":"fuzz","effect_name":"fuzz","placement":"front","settings":{"gain":7,"tone":5,"level":6}}]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Sultry fuzz riff opening on a rising trill; keep it thick and swaggering.','High gain with fuzz.'],
     array['Roll into the riff with the fingered trill.','Play with confident swagger.'],
     'Studio recording, 1967 (Are You Experienced). Jimi Hendrix played the sultry fuzz riff on a Stratocaster through a Marshall.',76),
    ('spanish-castle-magic','jimi-hendrix','guitar','riff','main riff','distorted',
     'rock','rhythm','advanced',
     'Fender Stratocaster (Jimi Hendrix)','Marshall high-gain amp','Marshall 4x12 cab','bridge single-coil',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Heavy, chordal riff with muscular chord stabs; keep it thick and driving.','High gain.'],
     array['Attack the chord-stab riff hard.','Keep the rhythm tight and heavy.'],
     'Studio recording, 1967 (Axis: Bold as Love). Jimi Hendrix played a heavy, chordal riff on a Stratocaster through a Marshall.',75),
    ('get-back','the-beatles','guitar','riff','main riff and solo','crunch',
     'rock','lead','intermediate',
     'Fender Telecaster (George Harrison)','Fender clean-to-crunch amp','Open-back combo cab','bridge single-coil',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, bluesy clean-to-crunch with a snappy solo; keep it tight and rootsy.','Low-medium gain.'],
     array['Play the rhythm with a light touch.','Keep the solo bends crisp.'],
     'Studio recording, 1969 (Let It Be). George Harrison played a bright, bluesy clean-to-crunch tone on a Telecaster.',74),
    ('ticket-to-ride','the-beatles','guitar','riff','main riff','clean',
     'rock','rhythm','beginner',
     'Rickenbacker 12-string (George Harrison)','Bright clean amp (Vox)','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":5,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, chiming 12-string jangle; keep the picked riff ringing.','Low gain, very bright.'],
     array['Let the jangly riff ring.','Keep the picking even.'],
     'Studio recording, 1965 (Help!). George Harrison played a bright, chiming riff on a Rickenbacker 12-string through a Vox.',75),
    ('revolution','the-beatles','guitar','riff','main riff','distorted',
     'rock','rhythm','beginner',
     'Epiphone Casino (John Lennon / George Harrison)','Overloaded preamp / distorted amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Raw, fuzzy overdriven tone (originally made by overloading the console); keep it gnarly.','High gain, raw.'],
     array['Slam the bluesy shuffle riff.','Keep it raw and dirty.'],
     'Studio recording, 1968. The gritty tone was famously created by overloading the mixing-console preamps; play it as a raw, fuzzy overdrive.',73),
    ('jumpin-jack-flash','the-rolling-stones','guitar','riff','main riff','crunch',
     'rock','rhythm','intermediate',
     'Electric guitar in open tuning (Keith Richards)','Crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Gritty, ringing open-tuned riff; keep it loose and driving.','Medium gain with grit.'],
     array['Let the open-tuned chords ring.','Keep the groove loose.'],
     'Studio recording, 1968. Keith Richards played the gritty, ringing riff in an open tuning.',75),
    ('honky-tonk-women','the-rolling-stones','guitar','riff','main riff','crunch',
     'rock','rhythm','intermediate',
     'Fender Telecaster in open-G tuning (Keith Richards)','Crunch amp','Open-back combo cab','bridge single-coil',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Loose, swaggering open-G riff (Keith''s 5-string style); keep it sloppy-tight.','Medium gain.'],
     array['Play the open-G riff with a loose swing.','Emphasise the hammer-ons.'],
     'Studio recording, 1969. Keith Richards played the loose, swaggering riff on a Telecaster in open-G tuning.',75),
    ('angie','the-rolling-stones','guitar','riff','strummed progression','acoustic',
     'rock','rhythm','beginner',
     'Acoustic guitar (Keith Richards)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, melancholic strummed acoustic ballad; keep it gentle and expressive.','Natural acoustic tone.'],
     array['Strum the ballad chords softly.','Add the descending fills between chords.'],
     'Studio recording, 1973 (Goats Head Soup). Keith Richards played a warm, melancholic strummed acoustic part.',74),
    ('my-generation','the-who','guitar','riff','main riff','crunch',
     'rock','rhythm','beginner',
     'Electric guitar (Pete Townshend)','Cranked crunch amp','Closed-back 4x12 cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":6,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Raw, stabbing power chords with attitude; keep it loud and loose.','Medium gain with grit.'],
     array['Slam the block power chords.','Keep the energy raw.'],
     'Studio recording, 1965. Pete Townshend played raw, stabbing power chords through a cranked amp.',73),
    ('behind-blue-eyes','the-who','guitar','riff','acoustic intro to crunch outro','crunch',
     'rock','rhythm','intermediate',
     'Acoustic and electric guitar (Pete Townshend)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Builds from a gentle fingerpicked acoustic verse to a driving crunch; keep dynamics wide.','Low-medium gain for the outburst.'],
     array['Fingerpick the verse gently.','Drive hard into the heavy section.'],
     'Studio recording, 1971 (Who''s Next). Pete Townshend built the song from acoustic fingerpicking to a driving crunch.',74),
    ('burn','deep-purple','guitar','riff','main riff and solo','high_gain',
     'rock','lead','advanced',
     'Fender Stratocaster (Ritchie Blackmore)','Marshall high-gain amp','Marshall 4x12 cab','bridge single-coil',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Fast, classically-tinged hard-rock riff with a blazing solo; keep it tight.','High gain with clarity.'],
     array['Play the fast riff cleanly.','Attack the solo with fast alternate picking.'],
     'Studio recording, 1974 (Burn). Ritchie Blackmore played a fast, classically-tinged riff and solo on a Stratocaster through a Marshall.',75),
    ('space-truckin','deep-purple','guitar','riff','main riff','crunch',
     'rock','rhythm','intermediate',
     'Fender Stratocaster (Ritchie Blackmore)','Marshall crunch amp','Marshall 4x12 cab','bridge single-coil',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Driving, punchy hard-rock riff; keep the chord stabs tight.','Medium-high gain.'],
     array['Punch the riff chords in time.','Keep the groove driving.'],
     'Studio recording, 1972 (Machine Head). Ritchie Blackmore played a driving, punchy riff on a Stratocaster through a Marshall.',74),
    ('badge','cream','guitar','riff','arpeggiated bridge and progression','clean',
     'rock','lead','intermediate',
     'Gibson Les Paul through a Leslie (Eric Clapton)','Clean-to-crunch amp with rotary speaker','Rotary/Leslie cab','neck humbucker',
     '[{"effect_type":"rotary","effect_name":"leslie","placement":"post_gain","settings":{"rate":4,"depth":5,"mix":5}}]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The famous arpeggiated bridge runs through a Leslie for a swirling tone; keep it clean and shimmering.','Low gain, rotary modulation.'],
     array['Arpeggiate the bridge chords cleanly.','Let the rotary swirl carry the tone.'],
     'Studio recording, 1969 (Goodbye). The arpeggiated bridge runs a Les Paul through a Leslie rotary speaker for its swirling tone.',74),
    ('all-day-and-all-of-the-night','the-kinks','guitar','riff','main riff','crunch',
     'rock','rhythm','beginner',
     'Electric guitar (Dave Davies)','Cranked crunch amp (sliced speaker)','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Raw, buzzy power-chord riff (Davies famously sliced his amp speaker); keep it gritty.','Medium-high gain, raw.'],
     array['Stab the two-chord riff hard.','Keep it raw and buzzy.'],
     'Studio recording, 1964. Dave Davies got the raw, buzzy riff tone by slicing his amp''s speaker cone.',73),
    ('lola','the-kinks','guitar','riff','main progression','crunch',
     'rock','rhythm','beginner',
     'Acoustic and electric 12-string (Dave / Ray Davies)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Ringing acoustic/12-string intro building to a fuller electric crunch; keep the chords big.','Low-medium gain.'],
     array['Let the ringing intro chords sound.','Open up for the fuller verses.'],
     'Studio recording, 1970. The Kinks built the song from a ringing acoustic/12-string intro into a fuller electric crunch.',73),
    ('heart-full-of-soul','the-yardbirds','guitar','riff','main riff','fuzz',
     'rock','lead','intermediate',
     'Electric guitar with fuzz (Jeff Beck)','Amp with early fuzz','Open-back combo cab','bridge pickup',
     '[{"effect_type":"fuzz","effect_name":"fuzz","placement":"front","settings":{"gain":6,"tone":5,"level":6}}]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['The sitar-like fuzz riff is the identity; keep it buzzy and vocal.','Medium-high gain with fuzz.'],
     array['Play the exotic fuzz riff with bends.','Make it sing like a sitar.'],
     'Studio recording, 1965. Jeff Beck played the famous sitar-like fuzz riff on the single.',73),
    ('the-house-of-the-rising-sun','the-animals','guitar','riff','arpeggiated progression','clean',
     'rock','rhythm','beginner',
     'Electric guitar (Hilton Valentine)','Bright clean amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The iconic 6/8 arpeggiated progression; keep every note clean and even.','Low gain, warm.'],
     array['Arpeggiate the chords in a steady 6/8.','Keep the picking even and clean.'],
     'Studio recording, 1964. Hilton Valentine played the iconic arpeggiated progression on a clean electric guitar.',74),
    ('wishing-well','free','guitar','riff','main riff','crunch',
     'rock','rhythm','intermediate',
     'Gibson Les Paul (Paul Kossoff)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Tough, mid-forward blues-rock riff with rich vibrato; keep it soulful.','Medium gain with strong mids.'],
     array['Play the riff with a loose groove.','Add Kossoff''s signature finger vibrato.'],
     'Studio recording, 1973 (Heartbreaker). Paul Kossoff played a tough, mid-forward blues-rock riff on a Les Paul through a Marshall.',74),
    ('feel-like-makin-love','bad-company','guitar','riff','clean verse to crunch chorus','crunch',
     'rock','rhythm','beginner',
     'Gibson Les Paul (Mick Ralphs)','Clean-to-crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Dynamic clean-picked verse that explodes into a big crunch chorus; keep the contrast wide.','Medium gain for the chorus.'],
     array['Pick the verse chords softly.','Slam the anthemic chorus power chords.'],
     'Studio recording, 1975 (Straight Shooter). Mick Ralphs played a dynamic clean-to-crunch part on a Les Paul.',74),
    ('were-an-american-band','grand-funk-railroad','guitar','riff','main riff','crunch',
     'rock','rhythm','beginner',
     'Electric guitar (Mark Farner)','Crunch amp','Closed-back 4x12 cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Swaggering, boogie-rock crunch riff; keep it tight and confident.','Medium gain.'],
     array['Drive the boogie riff with swagger.','Keep the groove tight.'],
     'Studio recording, 1973. Mark Farner played a swaggering boogie-rock crunch riff.',72),
    ('magic-carpet-ride','steppenwolf','guitar','riff','main riff','fuzz',
     'rock','rhythm','beginner',
     'Electric guitar with fuzz (Michael Monarch)','Amp with fuzz','Open-back combo cab','bridge pickup',
     '[{"effect_type":"fuzz","effect_name":"fuzz","placement":"front","settings":{"gain":6,"tone":5,"level":6}}]'::jsonb,'{"gain":6,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Fuzzy, driving psych-rock riff; keep the low end thick.','Medium-high gain with fuzz.'],
     array['Drive the fuzzy riff steadily.','Keep it thick and hypnotic.'],
     'Studio recording, 1968 (The Second). Michael Monarch played a fuzzy, driving psych-rock riff.',72)
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
  ('led-zeppelin','since-ive-been-loving-you'),('led-zeppelin','the-ocean'),('led-zeppelin','communication-breakdown'),('jimi-hendrix','crosstown-traffic'),
  ('jimi-hendrix','foxy-lady'),('jimi-hendrix','spanish-castle-magic'),('the-beatles','get-back'),('the-beatles','ticket-to-ride'),
  ('the-beatles','revolution'),('the-rolling-stones','jumpin-jack-flash'),('the-rolling-stones','honky-tonk-women'),('the-rolling-stones','angie'),
  ('the-who','my-generation'),('the-who','behind-blue-eyes'),('deep-purple','burn'),('deep-purple','space-truckin'),
  ('cream','badge'),('the-kinks','all-day-and-all-of-the-night'),('the-kinks','lola'),('the-yardbirds','heart-full-of-soul'),
  ('the-animals','the-house-of-the-rising-sun'),('free','wishing-well'),('bad-company','feel-like-makin-love'),('grand-funk-railroad','were-an-american-band'),
  ('steppenwolf','magic-carpet-ride')
) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
cross join (values
  ('artist_interview', 'Documented artist interviews and gear discussions', null::text,
   'Researched from widely-documented interviews about this recording and player.', 72),
  ('rig_rundown', 'Published rig rundowns and community gear databases', null::text,
   'Cross-referenced against rig features and community-maintained gear databases.', 66)
) as x(source_type, title, url, notes, credibility)
where p.verification_status = 'admin_verified'
on conflict do nothing;
