with artist_rows(name, slug) as (
  values
    ('Ed Sheeran', 'ed-sheeran'),
    ('Pink Floyd', 'pink-floyd'),
    ('Metallica', 'metallica'),
    ('Dire Straits', 'dire-straits'),
    ('Nirvana', 'nirvana'),
    ('Guns N'' Roses', 'guns-n-roses'),
    ('AC/DC', 'ac-dc'),
    ('Oasis', 'oasis'),
    ('Eagles', 'eagles'),
    ('Led Zeppelin', 'led-zeppelin'),
    ('Jimi Hendrix', 'jimi-hendrix'),
    ('Radiohead', 'radiohead'),
    ('The White Stripes', 'the-white-stripes'),
    ('Red Hot Chili Peppers', 'red-hot-chili-peppers'),
    ('Muse', 'muse'),
    ('Derek and the Dominos', 'derek-and-the-dominos'),
    ('Lynyrd Skynyrd', 'lynyrd-skynyrd'),
    ('Black Sabbath', 'black-sabbath'),
    ('Pixies', 'pixies')
),
upserted_artists as (
  insert into public.artists (name, slug, search_text)
  select name, slug, name
  from artist_rows
  on conflict (slug) do update set
    name = excluded.name,
    search_text = excluded.search_text
  returning id, slug
),
song_rows(title, slug, artist_slug, album, release_year, duration_seconds) as (
  values
    ('Perfect', 'perfect', 'ed-sheeran', 'Divide', 2017, 263),
    ('Comfortably Numb', 'comfortably-numb', 'pink-floyd', 'The Wall', 1979, 382),
    ('Money', 'money', 'pink-floyd', 'The Dark Side of the Moon', 1973, 382),
    ('Enter Sandman', 'enter-sandman', 'metallica', 'Metallica', 1991, 331),
    ('Master of Puppets', 'master-of-puppets', 'metallica', 'Master of Puppets', 1986, 516),
    ('Nothing Else Matters', 'nothing-else-matters', 'metallica', 'Metallica', 1991, 388),
    ('Sultans of Swing', 'sultans-of-swing', 'dire-straits', 'Dire Straits', 1978, 348),
    ('Smells Like Teen Spirit', 'smells-like-teen-spirit', 'nirvana', 'Nevermind', 1991, 301),
    ('Come As You Are', 'come-as-you-are', 'nirvana', 'Nevermind', 1991, 219),
    ('Sweet Child O'' Mine', 'sweet-child-o-mine', 'guns-n-roses', 'Appetite for Destruction', 1987, 356),
    ('Back in Black', 'back-in-black', 'ac-dc', 'Back in Black', 1980, 255),
    ('Highway to Hell', 'highway-to-hell', 'ac-dc', 'Highway to Hell', 1979, 208),
    ('Wonderwall', 'wonderwall', 'oasis', '(What''s the Story) Morning Glory?', 1995, 259),
    ('Hotel California', 'hotel-california', 'eagles', 'Hotel California', 1976, 391),
    ('Black Dog', 'black-dog', 'led-zeppelin', 'Led Zeppelin IV', 1971, 295),
    ('Purple Haze', 'purple-haze', 'jimi-hendrix', 'Are You Experienced', 1967, 171),
    ('Creep', 'creep', 'radiohead', 'Pablo Honey', 1992, 239),
    ('Seven Nation Army', 'seven-nation-army', 'the-white-stripes', 'Elephant', 2003, 232),
    ('Californication', 'californication', 'red-hot-chili-peppers', 'Californication', 1999, 329),
    ('Under the Bridge', 'under-the-bridge', 'red-hot-chili-peppers', 'Blood Sugar Sex Magik', 1991, 264),
    ('Hysteria', 'hysteria', 'muse', 'Absolution', 2003, 227),
    ('Layla', 'layla', 'derek-and-the-dominos', 'Layla and Other Assorted Love Songs', 1970, 424),
    ('Sweet Home Alabama', 'sweet-home-alabama', 'lynyrd-skynyrd', 'Second Helping', 1974, 283),
    ('Paranoid', 'paranoid', 'black-sabbath', 'Paranoid', 1970, 168),
    ('Where Is My Mind?', 'where-is-my-mind', 'pixies', 'Surfer Rosa', 1988, 231)
),
upserted_songs as (
  insert into public.songs (artist_id, title, slug, album, release_year, duration_seconds, search_text)
  select a.id, s.title, s.slug, s.album, s.release_year, s.duration_seconds, concat_ws(' ', s.title, ar.name, s.album)
  from song_rows s
  join artist_rows ar on ar.slug = s.artist_slug
  join upserted_artists a on a.slug = s.artist_slug
  on conflict (artist_id, slug) do update set
    title = excluded.title,
    album = excluded.album,
    release_year = excluded.release_year,
    duration_seconds = excluded.duration_seconds,
    search_text = excluded.search_text
  returning id, slug, title
),
profile_rows(
  song_slug, artist_slug, mode, part_type, part_label, tone_type,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes, confidence, source_summary
) as (
  values
    ('perfect', 'ed-sheeran', 'guitar', 'rhythm', 'main acoustic progression', 'acoustic', 'Steel-string acoustic with piezo or mic blend', 'Studio acoustic preamp / DI', 'Full-range acoustic monitoring', 'acoustic pickup or mic', '[{"type":"compression","name":"light compressor","placement":"front","settings":{"sustain":3,"level":5}},{"type":"reverb","name":"small room reverb","placement":"post","settings":{"mix":3,"decay":4}}]'::jsonb, '{"gain":2,"bass":4,"mids":5,"treble":7,"presence":6,"compression":3,"reverb":3,"delay":0}'::jsonb, array['Keep electric amp gain low and use compression before ambience.', 'If using humbuckers, lower bass and add presence to keep the acoustic strum open.'], array['Use light pick attack and let open chords ring.', 'Keep reverb subtle so the vocal pocket stays clear.'], 72, 'Starter estimate based on common acoustic-pop production conventions; verify against dedicated rig sources before labeling exact.'),
    ('comfortably-numb', 'pink-floyd', 'guitar', 'solo', 'second solo', 'distorted', 'Strat-style single-coil guitar', 'Hiwatt-style clean platform with sustain pedals', 'Open-back or full-range stage cab', 'bridge or bridge/neck single coil', '[{"type":"fuzz","name":"sustain/fuzz drive","placement":"front","settings":{"gain":6,"tone":5,"level":6}},{"type":"delay","name":"tape-style delay","placement":"post","settings":{"mix":3,"time":4}},{"type":"reverb","name":"plate reverb","placement":"post","settings":{"mix":3,"decay":5}}]'::jsonb, '{"gain":6,"bass":4,"mids":6,"treble":6,"presence":6,"reverb":3,"delay":4}'::jsonb, array['Prioritize sustain and midrange before adding gain.', 'Use delay as a halo, not a rhythmic repeat.'], array['Long bends need controlled vibrato.', 'Pick softer after the note blooms.'], 78, 'Starter estimate reflecting widely discussed Gilmour-style sustain, delay, and clean-amp foundation.'),
    ('money', 'pink-floyd', 'bass', 'bassline', 'main bassline', 'bass_clean', 'Precision-style bass', 'Tube bass amp / DI blend', 'Large bass cab or studio DI', 'split-coil bass pickup', '[{"type":"compression","name":"studio bass compression","placement":"front","settings":{"ratio":4,"level":5}}]'::jsonb, '{"gain":3,"bass":6,"mids":6,"treble":4,"presence":3,"compression":5,"reverb":0,"delay":0}'::jsonb, array['Keep lows firm but avoid modern sub-heavy EQ.', 'Use enough mids for the line to speak.'], array['Play with even finger attack.', 'Mute between notes to keep the groove dry.'], 74, 'Starter estimate for classic dry studio bass tone.'),
    ('enter-sandman', 'metallica', 'guitar', 'rhythm', 'main rhythm riff', 'high_gain', 'Humbucker guitar', 'Mesa/Boogie-style high-gain amp', 'Closed-back 4x12 cab', 'bridge humbucker', '[{"type":"noise_gate","name":"tight gate","placement":"front","settings":{"threshold":5}},{"type":"eq","name":"post amp graphic EQ","placement":"post","settings":{"low":6,"mid":3,"high":6}}]'::jsonb, '{"gain":8,"bass":7,"mids":3,"treble":6,"presence":6,"reverb":1,"delay":0}'::jsonb, array['Use less gain than expected if palm mutes get blurry.', 'Scoop mids carefully; keep enough upper mids for pick attack.'], array['Palm mute close to the bridge.', 'Double-track feel comes from tight timing more than gain.'], 76, 'Starter estimate for early-90s tight high-gain metal rhythm.'),
    ('master-of-puppets', 'metallica', 'guitar', 'rhythm', 'downpicked rhythm', 'high_gain', 'Humbucker guitar', 'Mesa/Boogie Mark-style amp', 'Closed-back 4x12 cab', 'bridge humbucker', '[{"type":"noise_gate","name":"fast gate","placement":"front","settings":{"threshold":6}},{"type":"eq","name":"tight metal EQ","placement":"post","settings":{"low":6,"mid":4,"high":6}}]'::jsonb, '{"gain":8,"bass":6,"mids":4,"treble":6,"presence":5,"reverb":0,"delay":0}'::jsonb, array['Keep bass tighter than modern metal defaults.', 'If the amp sags, reduce gain and increase pick attack.'], array['Downpick steadily and keep mutes short.', 'Tightness matters more than saturation.'], 77, 'Starter estimate for classic thrash rhythm guitar.'),
    ('nothing-else-matters', 'metallica', 'guitar', 'intro', 'clean intro', 'clean', 'Clean electric or acoustic guitar', 'Clean amp / studio DI', 'Open clean cab or studio chain', 'neck pickup or acoustic source', '[{"type":"chorus","name":"subtle chorus","placement":"post","settings":{"depth":2,"mix":2}},{"type":"reverb","name":"room reverb","placement":"post","settings":{"mix":3,"decay":4}}]'::jsonb, '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":1}'::jsonb, array['Use neck pickup and low gain for roundness.', 'Add chorus only if the clean tone feels too narrow.'], array['Let arpeggios ring evenly.', 'Avoid heavy compression that flattens dynamics.'], 71, 'Starter estimate for clean ballad intro tone.'),
    ('sultans-of-swing', 'dire-straits', 'guitar', 'lead', 'lead and fills', 'clean', 'Strat-style single-coil guitar', 'Clean Fender/Vibrolux-style amp', 'Open-back combo cab', 'bridge/middle single coils', '[{"type":"compression","name":"light clean compression","placement":"front","settings":{"sustain":3}},{"type":"reverb","name":"spring reverb","placement":"post","settings":{"mix":2,"decay":3}}]'::jsonb, '{"gain":3,"bass":4,"mids":5,"treble":7,"presence":6,"reverb":2,"delay":0}'::jsonb, array['If using humbuckers, split coils or lower the guitar volume.', 'Keep gain barely breaking up.'], array['Fingerstyle attack is central to the tone.', 'Use bright pickup positions without harsh pick scrape.'], 76, 'Starter estimate for clean Strat-style fingerpicked lead tone.'),
    ('smells-like-teen-spirit', 'nirvana', 'guitar', 'rhythm', 'chorus rhythm', 'distorted', 'Offset-style guitar with humbucker or hot single coil', 'Clean amp pushed by distortion pedal', 'Open-back combo / 4x12 blend', 'bridge pickup', '[{"type":"distortion","name":"classic orange distortion","placement":"front","settings":{"gain":6,"tone":5,"level":6}},{"type":"chorus","name":"subtle chorus for clean sections","placement":"post","settings":{"depth":2,"mix":2}}]'::jsonb, '{"gain":7,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0}'::jsonb, array['Use pedal distortion into a fairly clean amp if your amp gain sounds too polished.', 'Do not over-tighten the low end.'], array['Hit the chorus hard and let the chords smear slightly.', 'Keep clean sections thinner for contrast.'], 75, 'Starter estimate for grunge pedal-distortion rhythm.'),
    ('come-as-you-are', 'nirvana', 'guitar', 'riff', 'watery intro riff', 'clean', 'Offset-style guitar', 'Clean combo amp', 'Open-back combo cab', 'neck or middle pickup', '[{"type":"chorus","name":"watery chorus","placement":"post","settings":{"depth":6,"rate":3,"mix":6}},{"type":"reverb","name":"small room","placement":"post","settings":{"mix":2}}]'::jsonb, '{"gain":3,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":2,"delay":0}'::jsonb, array['Chorus depth is more important than amp gain.', 'Keep the amp clean enough that modulation stays clear.'], array['Pick evenly and let notes overlap.', 'Avoid aggressive palm muting.'], 76, 'Starter estimate for chorus-heavy clean grunge riff.'),
    ('sweet-child-o-mine', 'guns-n-roses', 'guitar', 'lead', 'intro lead', 'distorted', 'Les Paul-style humbucker guitar', 'Marshall-style high-gain head', 'Closed-back 4x12 cab', 'neck humbucker for intro, bridge for bite', '[{"type":"drive","name":"amp gain","placement":"amp","settings":{"gain":6}},{"type":"delay","name":"short lead delay","placement":"post","settings":{"mix":2,"time":3}},{"type":"reverb","name":"plate ambience","placement":"post","settings":{"mix":2}}]'::jsonb, '{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":2,"delay":2}'::jsonb, array['Use upper mids and sustain instead of fizzy treble.', 'For single coils, add gain and reduce presence.'], array['Use neck pickup for round intro phrasing.', 'Control bends with wide, slow vibrato.'], 76, 'Starter estimate for late-80s Les Paul into Marshall lead tone.'),
    ('back-in-black', 'ac-dc', 'guitar', 'rhythm', 'main rhythm', 'crunch', 'SG-style humbucker guitar', 'Marshall Plexi/JMP-style amp', 'Closed-back rock cab', 'bridge humbucker', '[{"type":"drive","name":"amp crunch","placement":"amp","settings":{"gain":5}}]'::jsonb, '{"gain":5,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0}'::jsonb, array['Use medium gain and strong mids; avoid modern saturation.', 'Let the amp breathe with guitar volume near full.'], array['Open chords need space between hits.', 'Pick hard but keep muting clean.'], 78, 'Starter estimate for classic AC/DC Marshall crunch.'),
    ('highway-to-hell', 'ac-dc', 'guitar', 'rhythm', 'main rhythm', 'crunch', 'SG-style humbucker guitar', 'Marshall-style crunch amp', 'Closed-back rock cab', 'bridge humbucker', '[{"type":"drive","name":"amp crunch","placement":"amp","settings":{"gain":5}}]'::jsonb, '{"gain":5,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0}'::jsonb, array['Keep distortion open and chord-friendly.', 'If using a modeling amp, reduce compression.'], array['Let chord stabs ring naturally.', 'Use confident right-hand accents.'], 76, 'Starter estimate for late-70s rock crunch.'),
    ('wonderwall', 'oasis', 'guitar', 'rhythm', 'acoustic strumming', 'acoustic', 'Steel-string acoustic guitar', 'Acoustic DI / microphone chain', 'Full-range monitoring', 'acoustic source', '[{"type":"compression","name":"light acoustic leveling","placement":"front","settings":{"sustain":2}},{"type":"reverb","name":"small room","placement":"post","settings":{"mix":2,"decay":3}}]'::jsonb, '{"gain":2,"bass":4,"mids":5,"treble":7,"presence":5,"reverb":2,"delay":0}'::jsonb, array['For electric guitar, use clean amp and bright pickup with low gain.', 'Avoid chorus unless you need width.'], array['The rhythm pattern drives the sound.', 'Keep strums even and bright.'], 72, 'Starter estimate for bright acoustic pop-rock strumming.'),
    ('hotel-california', 'eagles', 'guitar', 'solo', 'dual-guitar solo', 'crunch', 'Les Paul / Tele-style lead guitars', 'Fender or small-tube amp edge of breakup', 'Open-back combo cab', 'bridge pickup with tone rolled slightly', '[{"type":"drive","name":"edge-of-breakup amp drive","placement":"amp","settings":{"gain":4}},{"type":"reverb","name":"plate reverb","placement":"post","settings":{"mix":2,"decay":4}}]'::jsonb, '{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":1}'::jsonb, array['Keep gain moderate so harmonized lines stay articulate.', 'Use midrange sustain rather than fuzz.'], array['Match bends carefully; harmony intonation matters.', 'Pick with controlled attack.'], 74, 'Starter estimate for melodic 70s classic-rock lead tone.'),
    ('black-dog', 'led-zeppelin', 'guitar', 'riff', 'main riff', 'crunch', 'Les Paul-style humbucker guitar', 'Marshall/Supro-style driven amp', 'Rock 4x12 or small cranked cab', 'bridge humbucker', '[{"type":"drive","name":"cranked amp drive","placement":"amp","settings":{"gain":6}}]'::jsonb, '{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0}'::jsonb, array['Use raw amp crunch, not tight modern distortion.', 'Keep mids forward and lows controlled.'], array['Riff timing is intentionally swaggering.', 'Use strong pick attack and quick mutes.'], 75, 'Starter estimate for early-70s British rock riff tone.'),
    ('purple-haze', 'jimi-hendrix', 'guitar', 'riff', 'main riff and lead', 'fuzz', 'Strat-style single-coil guitar', 'Marshall-style loud clean/crunch amp', '4x12 cab', 'neck/bridge single coils', '[{"type":"fuzz","name":"vintage fuzz face-style fuzz","placement":"front","settings":{"gain":7,"tone":5,"level":6}},{"type":"wah","name":"wah accents","placement":"front","settings":{"range":5}}]'::jsonb, '{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0}'::jsonb, array['If using humbuckers, lower gain and raise presence.', 'Roll guitar volume down for cleaner fuzzy dynamics.'], array['Use expressive bends and rakes.', 'Let fuzz clean up from the guitar controls.'], 76, 'Starter estimate for vintage fuzz into loud British amp.'),
    ('creep', 'radiohead', 'guitar', 'chorus', 'heavy chorus hits', 'distorted', 'Telecaster-style guitar', 'Clean amp with aggressive distortion for chorus', 'Combo or 4x12 stage cab', 'bridge pickup', '[{"type":"distortion","name":"hard clipping distortion","placement":"front","settings":{"gain":7,"tone":6,"level":6}},{"type":"reverb","name":"room ambience","placement":"post","settings":{"mix":2}}]'::jsonb, '{"gain":7,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0}'::jsonb, array['Use a big dynamic jump from clean verse to distorted chorus.', 'Keep distortion ragged rather than polished.'], array['Chorus strums should feel abrupt and wide.', 'Let muted scratches exaggerate the transition.'], 73, 'Starter estimate for quiet-loud alternative rhythm tone.'),
    ('seven-nation-army', 'the-white-stripes', 'guitar', 'riff', 'octave riff', 'fuzz', 'Semi-hollow or electric guitar', 'Amp with octave/fuzz front end', 'Combo amp', 'neck pickup or dark bridge tone', '[{"type":"octave","name":"down-octave effect","placement":"front","settings":{"mix":7}},{"type":"fuzz","name":"raw fuzz","placement":"front","settings":{"gain":6,"tone":4}}]'::jsonb, '{"gain":6,"bass":6,"mids":6,"treble":4,"presence":4,"reverb":1,"delay":0}'::jsonb, array['The octave effect is the identity; use bass EQ only after it tracks well.', 'If no octave pedal is available, use neck pickup and strong low mids.'], array['Play single notes cleanly so octave tracking stays stable.', 'Mute unused strings aggressively.'], 74, 'Starter estimate for guitar-through-octave riff sound.'),
    ('californication', 'red-hot-chili-peppers', 'guitar', 'lead', 'main lead melody', 'clean', 'Strat-style single-coil guitar', 'Clean Fender/Marshall-style amp', 'Open-back clean cab', 'neck single coil', '[{"type":"compression","name":"light leveling","placement":"front","settings":{"sustain":2}},{"type":"reverb","name":"small room","placement":"post","settings":{"mix":2}}]'::jsonb, '{"gain":3,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0}'::jsonb, array['Use a warm neck single-coil sound and keep the amp mostly clean.', 'Avoid bright bridge tones unless compensating with tone rolled back.'], array['Play with relaxed attack and clean slides.', 'Let notes decay naturally.'], 73, 'Starter estimate for warm clean Strat-style lead.'),
    ('under-the-bridge', 'red-hot-chili-peppers', 'guitar', 'intro', 'clean intro', 'clean', 'Strat-style single-coil guitar', 'Clean tube amp', 'Open-back combo cab', 'neck single coil', '[{"type":"compression","name":"subtle compression","placement":"front","settings":{"sustain":2}},{"type":"reverb","name":"room reverb","placement":"post","settings":{"mix":2}}]'::jsonb, '{"gain":3,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0}'::jsonb, array['Keep the clean tone touch-sensitive.', 'If using humbuckers, split coil or lower guitar volume.'], array['Use thumb/finger dynamics for the intro.', 'Keep chord fragments clear and even.'], 74, 'Starter estimate for clean funk-rock Strat intro.'),
    ('hysteria', 'muse', 'bass', 'bassline', 'main fuzz bass riff', 'bass_drive', 'Bass guitar with hot pickups', 'Bass amp / DI with fuzz and synth-like drive', 'Bass cab or full-range DI', 'bridge-heavy bass pickup blend', '[{"type":"fuzz","name":"compressed bass fuzz","placement":"front","settings":{"gain":7,"tone":5}},{"type":"compression","name":"heavy compression","placement":"front","settings":{"ratio":6}},{"type":"eq","name":"mid-forward bass EQ","placement":"post","settings":{"low":6,"mid":7,"high":5}}]'::jsonb, '{"gain":7,"bass":6,"mids":7,"treble":5,"presence":5,"compression":6,"reverb":0,"delay":0}'::jsonb, array['Blend clean low end if fuzz removes the fundamental.', 'Use compression to keep rapid notes even.'], array['Pick or pluck consistently for every note.', 'Mute tightly between fast riff notes.'], 76, 'Starter estimate for aggressive fuzz-bass rock tone.'),
    ('layla', 'derek-and-the-dominos', 'guitar', 'lead', 'main lead motif', 'crunch', 'Humbucker or Strat-style electric guitar', 'Small cranked tube amp / classic rock amp', 'Open-back or small cab', 'bridge pickup', '[{"type":"drive","name":"cranked amp drive","placement":"amp","settings":{"gain":6}},{"type":"reverb","name":"room ambience","placement":"post","settings":{"mix":2}}]'::jsonb, '{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":2,"delay":0}'::jsonb, array['Use vocal midrange sustain and avoid modern tight gain.', 'Roll tone back slightly if the lead is too sharp.'], array['Phrase with blues bends and slides.', 'Let notes overlap for a raw studio feel.'], 72, 'Starter estimate for classic blues-rock lead.'),
    ('sweet-home-alabama', 'lynyrd-skynyrd', 'guitar', 'rhythm', 'main rhythm and fills', 'clean', 'Strat/Les Paul-style southern rock guitar', 'Clean-to-edge tube amp', 'Open-back combo or 2x12', 'bridge or middle pickup', '[{"type":"drive","name":"edge-of-breakup amp","placement":"amp","settings":{"gain":4}},{"type":"reverb","name":"spring reverb","placement":"post","settings":{"mix":2}}]'::jsonb, '{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0}'::jsonb, array['Keep the rhythm bright but not spiky.', 'Use low gain so double-stops stay clear.'], array['Let the groove swing lightly.', 'Use hybrid picking or clean pick control for fills.'], 72, 'Starter estimate for bright southern-rock clean/crunch tone.'),
    ('paranoid', 'black-sabbath', 'guitar', 'riff', 'main riff', 'crunch', 'SG-style humbucker guitar', 'Laney/Marshall-style driven amp', 'Closed-back rock cab', 'bridge humbucker', '[{"type":"drive","name":"vintage amp drive","placement":"amp","settings":{"gain":6}},{"type":"eq","name":"mid-forward EQ","placement":"post","settings":{"mid":7}}]'::jsonb, '{"gain":6,"bass":5,"mids":7,"treble":5,"presence":5,"reverb":1,"delay":0}'::jsonb, array['Use vintage crunch, not scooped modern metal.', 'Keep mids high so the riff stays vocal.'], array['Use fast, tight alternate picking.', 'Let the riff punch without excess palm mute.'], 74, 'Starter estimate for early heavy-rock riff tone.'),
    ('where-is-my-mind', 'pixies', 'guitar', 'lead', 'clean lead hook', 'clean', 'Single-coil or bright humbucker guitar', 'Clean combo amp', 'Open-back combo cab', 'neck or middle pickup', '[{"type":"reverb","name":"room reverb","placement":"post","settings":{"mix":3}},{"type":"delay","name":"short ambience","placement":"post","settings":{"mix":1}}]'::jsonb, '{"gain":3,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":1}'::jsonb, array['Keep the lead clean and slightly distant.', 'Use modest reverb instead of chorus-heavy modulation.'], array['Let the hook breathe between phrases.', 'Use light touch and consistent note length.'], 70, 'Starter estimate for clean alternative lead hook.')
),
inserted_profiles as (
  insert into public.song_tone_profiles (
    song_id, song_title, artist_name, mode, part_type, part_label, tone_type,
    original_guitar, original_amp, original_cab, original_pickup,
    original_effects, original_settings, adaptation_notes, playing_notes,
    confidence, verification_status, source_summary, search_text
  )
  select
    s.id,
    s.title,
    ar.name,
    p.mode,
    p.part_type,
    p.part_label,
    p.tone_type,
    p.original_guitar,
    p.original_amp,
    p.original_cab,
    p.original_pickup,
    p.original_effects,
    p.original_settings,
    p.adaptation_notes,
    p.playing_notes,
    p.confidence,
    'starter_estimate',
    p.source_summary,
    concat_ws(' ', s.title, ar.name, p.part_label, p.tone_type, p.original_guitar, p.original_amp)
  from profile_rows p
  join song_rows sr on sr.slug = p.song_slug and sr.artist_slug = p.artist_slug
  join public.songs s on s.slug = sr.slug
  join public.artists ar on ar.slug = sr.artist_slug and ar.id = s.artist_id
  on conflict (song_id, mode, part_type, tone_type, part_label) do update set
    original_guitar = excluded.original_guitar,
    original_amp = excluded.original_amp,
    original_cab = excluded.original_cab,
    original_pickup = excluded.original_pickup,
    original_effects = excluded.original_effects,
    original_settings = excluded.original_settings,
    adaptation_notes = excluded.adaptation_notes,
    playing_notes = excluded.playing_notes,
    confidence = excluded.confidence,
    verification_status = excluded.verification_status,
    source_summary = excluded.source_summary,
    search_text = excluded.search_text
  returning id, original_effects
)
insert into public.tone_profile_sources (profile_id, source_type, title, url, notes, credibility)
select
  id,
  'internal_seed',
  'FretPilot starter tone estimate',
  null,
  'Starter profile for MVP adaptation. Treat as a useful baseline until reviewed against dedicated rig rundowns, interviews, or community submissions.',
  55
from inserted_profiles
on conflict do nothing;

insert into public.tone_profile_effects (profile_id, effect_order, effect_type, effect_name, placement, settings)
select
  p.id,
  effect.ordinality::integer,
  coalesce(effect.value ->> 'type', 'effect'),
  coalesce(effect.value ->> 'name', 'Effect'),
  coalesce(effect.value ->> 'placement', 'post_gain'),
  coalesce(effect.value -> 'settings', '{}'::jsonb)
from public.song_tone_profiles p
cross join jsonb_array_elements(p.original_effects) with ordinality as effect(value, ordinality)
where p.verification_status = 'starter_estimate'
on conflict (profile_id, effect_order) do update set
  effect_type = excluded.effect_type,
  effect_name = excluded.effect_name,
  placement = excluded.placement,
  settings = excluded.settings;
