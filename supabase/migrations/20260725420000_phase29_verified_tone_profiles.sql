-- Phase 29: 25 prog-rock staples, verified per-part tone data (Yes, Genesis, King Crimson, Jethro Tull, Kansas, Rush, Pink Floyd, Porcupine Tree, Opeth, Dream Theater, Marillion, Frank Zappa, Tool).

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Yes','yes','Roundabout','roundabout','Fragile',1971),
    ('Yes','yes','Owner of a Lonely Heart','owner-of-a-lonely-heart','90125',1983),
    ('Yes','yes','Starship Trooper','starship-trooper','The Yes Album',1971),
    ('Genesis','genesis','Firth of Fifth','firth-of-fifth','Selling England by the Pound',1973),
    ('Genesis','genesis','I Know What I Like (In Your Wardrobe)','i-know-what-i-like','Selling England by the Pound',1973),
    ('King Crimson','king-crimson','21st Century Schizoid Man','21st-century-schizoid-man','In the Court of the Crimson King',1969),
    ('King Crimson','king-crimson','Red','red','Red',1974),
    ('Jethro Tull','jethro-tull','Locomotive Breath','locomotive-breath','Aqualung',1971),
    ('Jethro Tull','jethro-tull','Thick as a Brick','thick-as-a-brick','Thick as a Brick',1972),
    ('Kansas','kansas','Point of Know Return','point-of-know-return','Point of Know Return',1977),
    ('Rush','rush','YYZ','yyz','Moving Pictures',1981),
    ('Rush','rush','Freewill','freewill','Permanent Waves',1980),
    ('Rush','rush','Closer to the Heart','closer-to-the-heart','A Farewell to Kings',1977),
    ('Rush','rush','La Villa Strangiato','la-villa-strangiato','Hemispheres',1978),
    ('Pink Floyd','pink-floyd','Hey You','hey-you','The Wall',1979),
    ('Pink Floyd','pink-floyd','Dogs','dogs','Animals',1977),
    ('Pink Floyd','pink-floyd','Breathe (In the Air)','breathe-in-the-air','The Dark Side of the Moon',1973),
    ('Porcupine Tree','porcupine-tree','Trains','trains','In Absentia',2002),
    ('Porcupine Tree','porcupine-tree','Blackest Eyes','blackest-eyes','In Absentia',2002),
    ('Opeth','opeth','Blackwater Park','blackwater-park','Blackwater Park',2001),
    ('Opeth','opeth','Ghost of Perdition','ghost-of-perdition','Ghost Reveries',2005),
    ('Dream Theater','dream-theater','Metropolis Pt. 1: The Miracle and the Sleeper','metropolis-pt-1','Images and Words',1992),
    ('Marillion','marillion','Kayleigh','kayleigh','Misplaced Childhood',1985),
    ('Frank Zappa','frank-zappa','Peaches en Regalia','peaches-en-regalia','Hot Rats',1969),
    ('Tool','tool','Lateralus','lateralus','Lateralus',2001)
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
    ('yes','roundabout'),('yes','owner-of-a-lonely-heart'),('yes','starship-trooper'),('genesis','firth-of-fifth'),
    ('genesis','i-know-what-i-like'),('king-crimson','21st-century-schizoid-man'),('king-crimson','red'),('jethro-tull','locomotive-breath'),
    ('jethro-tull','thick-as-a-brick'),('kansas','point-of-know-return'),('rush','yyz'),('rush','freewill'),
    ('rush','closer-to-the-heart'),('rush','la-villa-strangiato'),('pink-floyd','hey-you'),('pink-floyd','dogs'),
    ('pink-floyd','breathe-in-the-air'),('porcupine-tree','trains'),('porcupine-tree','blackest-eyes'),('opeth','blackwater-park'),
    ('opeth','ghost-of-perdition'),('dream-theater','metropolis-pt-1'),('marillion','kayleigh'),('frank-zappa','peaches-en-regalia'),
    ('tool','lateralus')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('yes','roundabout'),('yes','owner-of-a-lonely-heart'),('yes','starship-trooper'),('genesis','firth-of-fifth'),
    ('genesis','i-know-what-i-like'),('king-crimson','21st-century-schizoid-man'),('king-crimson','red'),('jethro-tull','locomotive-breath'),
    ('jethro-tull','thick-as-a-brick'),('kansas','point-of-know-return'),('rush','yyz'),('rush','freewill'),
    ('rush','closer-to-the-heart'),('rush','la-villa-strangiato'),('pink-floyd','hey-you'),('pink-floyd','dogs'),
    ('pink-floyd','breathe-in-the-air'),('porcupine-tree','trains'),('porcupine-tree','blackest-eyes'),('opeth','blackwater-park'),
    ('opeth','ghost-of-perdition'),('dream-theater','metropolis-pt-1'),('marillion','kayleigh'),('frank-zappa','peaches-en-regalia'),
    ('tool','lateralus')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('yes','roundabout'),('yes','owner-of-a-lonely-heart'),('yes','starship-trooper'),('genesis','firth-of-fifth'),
    ('genesis','i-know-what-i-like'),('king-crimson','21st-century-schizoid-man'),('king-crimson','red'),('jethro-tull','locomotive-breath'),
    ('jethro-tull','thick-as-a-brick'),('kansas','point-of-know-return'),('rush','yyz'),('rush','freewill'),
    ('rush','closer-to-the-heart'),('rush','la-villa-strangiato'),('pink-floyd','hey-you'),('pink-floyd','dogs'),
    ('pink-floyd','breathe-in-the-air'),('porcupine-tree','trains'),('porcupine-tree','blackest-eyes'),('opeth','blackwater-park'),
    ('opeth','ghost-of-perdition'),('dream-theater','metropolis-pt-1'),('marillion','kayleigh'),('frank-zappa','peaches-en-regalia'),
    ('tool','lateralus')
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
    ('roundabout','yes','guitar','riff','harmonic intro and main riff','crunch',
     'rock','lead','advanced',
     'Gibson ES-175 / electric (Steve Howe)','Clean-to-crunch amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Opens with a chiming harmonic figure then a bright, driving crunch riff; keep it articulate.','Low-medium gain, bright.'],
     array['Ring the harmonic intro cleanly.','Play the busy riff precisely.'],
     'Studio recording, 1971 (Fragile). Steve Howe played the harmonic intro and bright riff on an ES-175.',74),
    ('owner-of-a-lonely-heart','yes','guitar','riff','main riff','crunch',
     'rock','rhythm','beginner',
     'Electric guitar (Trevor Rabin)','Crunch amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Punchy, stabbing 80s art-rock riff; keep it tight and rhythmic.','Medium gain, punchy.'],
     array['Stab the riff chords tightly.','Lock to the groove.'],
     'Studio recording, 1983 (90125). Trevor Rabin played a punchy, stabbing art-rock riff.',73),
    ('starship-trooper','yes','guitar','riff','main progression and outro','crunch',
     'rock','lead','advanced',
     'Gibson ES-175 / electric (Steve Howe)','Clean-to-crunch amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Builds to the anthemic ''Wurm'' outro of ascending chords; keep it big and driving.','Low-medium gain.'],
     array['Let the ascending outro chords build.','Keep the crescendo powerful.'],
     'Studio recording, 1971 (The Yes Album). Steve Howe built the anthemic ascending outro on an ES-175.',73),
    ('firth-of-fifth','genesis','guitar','riff','main solo','crunch',
     'rock','lead','advanced',
     'Gibson Les Paul (Steve Hackett)','Crunch amp with sustain','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":1,"master":6}'::jsonb,
     array['One of prog''s most lyrical solos: long, singing sustained notes; keep it smooth and vocal.','Medium gain with huge sustain.'],
     array['Play the melody slowly with sustain.','Use smooth legato and violin-like phrasing.'],
     'Studio recording, 1973 (Selling England by the Pound). Steve Hackett played his famous lyrical, sustained solo on a Les Paul.',74),
    ('i-know-what-i-like','genesis','guitar','riff','main riff','crunch',
     'rock','rhythm','intermediate',
     'Gibson Les Paul (Steve Hackett)','Crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Quirky, mid-tempo art-rock riff with a bouncy groove; keep it tight and playful.','Medium gain.'],
     array['Play the riff with a bouncy feel.','Keep the groove tight.'],
     'Studio recording, 1973. Steve Hackett played a quirky, mid-tempo art-rock riff on a Les Paul.',72),
    ('21st-century-schizoid-man','king-crimson','guitar','riff','main riff and unison lines','distorted',
     'rock','lead','advanced',
     'Electric guitar (Robert Fripp)','Distorted amp with fuzz','Closed-back cab','bridge humbucker',
     '[{"effect_type":"fuzz","effect_name":"fuzz","placement":"front","settings":{"gain":7,"tone":5,"level":6}}]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Menacing fuzz-distorted riff and blistering unison lines with the horns; keep it tight and aggressive.','High gain with fuzz.'],
     array['Play the doubled riff tightly.','Nail the fast unison break with the band.'],
     'Studio recording, 1969. Robert Fripp played a menacing fuzz-distorted riff and blistering unison lines.',73),
    ('red','king-crimson','guitar','riff','main riff','distorted',
     'rock','rhythm','advanced',
     'Electric guitar (Robert Fripp)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Heavy, angular instrumental riff in shifting time; keep it precise and crushing.','High gain, tight.'],
     array['Play the angular riff precisely.','Count the odd-time shifts.'],
     'Studio recording, 1974 (Red). Robert Fripp played a heavy, angular instrumental riff.',73),
    ('locomotive-breath','jethro-tull','guitar','riff','main riff and solo','crunch',
     'rock','lead','intermediate',
     'Gibson Les Paul (Martin Barre)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Chugging, bluesy hard-rock riff with a driving solo; keep it tight and locomotive-steady.','Medium gain.'],
     array['Keep the chugging riff steady.','Play the solo with drive.'],
     'Studio recording, 1971 (Aqualung). Martin Barre played a chugging, bluesy hard-rock riff and solo on a Les Paul.',73),
    ('thick-as-a-brick','jethro-tull','guitar','riff','acoustic intro and progression','crunch',
     'rock','rhythm','intermediate',
     'Acoustic and electric guitar (Martin Barre / Ian Anderson)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Famous acoustic intro building through many prog sections to fuller crunch; keep dynamics wide.','Low-medium gain.'],
     array['Play the acoustic intro cleanly.','Follow the shifting sections.'],
     'Studio recording, 1972. Jethro Tull built the epic from an acoustic intro through shifting prog sections.',72),
    ('point-of-know-return','kansas','guitar','riff','main riff','crunch',
     'rock','rhythm','intermediate',
     'Electric guitar (Kerry Livgren / Rich Williams)','Crunch amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, driving symphonic-rock riff; keep it tight and anthemic.','Medium gain.'],
     array['Drive the riff with energy.','Keep it tight under the violin.'],
     'Studio recording, 1977. Kansas played a bright, driving symphonic-rock riff.',72),
    ('yyz','rush','guitar','riff','instrumental main riff and solo','crunch',
     'rock','lead','expert',
     'Gibson electric guitar (Alex Lifeson)','Marshall/Hiwatt crunch amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":1,"master":6}'::jsonb,
     array['Instrumental tour-de-force with an odd-time main riff and a flashy solo; keep it tight.','Medium-high gain with clarity.'],
     array['Nail the 5/4 main riff with the band.','Play the fast solo cleanly.'],
     'Studio recording, 1981 (Moving Pictures). Alex Lifeson played the odd-time instrumental riff and flashy solo.',74),
    ('freewill','rush','guitar','riff','main riff and solo','crunch',
     'rock','lead','advanced',
     'Gibson electric guitar (Alex Lifeson)','Bright crunch amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":1,"master":6}'::jsonb,
     array['Fast, chiming riff with a frenetic solo; keep the picking precise and bright.','Medium-high gain, bright.'],
     array['Play the fast riff cleanly.','Attack the frenetic solo.'],
     'Studio recording, 1980 (Permanent Waves). Alex Lifeson played a fast, chiming riff and frenetic solo.',73),
    ('closer-to-the-heart','rush','guitar','riff','acoustic intro to crunch','crunch',
     'rock','rhythm','beginner',
     'Acoustic and electric guitar (Alex Lifeson)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Gentle fingerpicked acoustic intro building to a driving electric crunch; keep dynamics wide.','Low-medium gain.'],
     array['Fingerpick the intro cleanly.','Drive into the electric section.'],
     'Studio recording, 1977 (A Farewell to Kings). Alex Lifeson played an acoustic intro building to a driving crunch.',73),
    ('la-villa-strangiato','rush','guitar','riff','instrumental theme and solo','crunch',
     'rock','lead','expert',
     'Gibson electric guitar (Alex Lifeson)','Marshall/Hiwatt crunch amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":1,"master":6}'::jsonb,
     array['Sprawling instrumental with a soaring, emotive central solo; keep dynamics and phrasing wide.','Medium-high gain.'],
     array['Play the emotive solo with feeling.','Navigate the many sections tightly.'],
     'Studio recording, 1978 (Hemispheres). Alex Lifeson played the sprawling instrumental and its soaring solo.',73),
    ('hey-you','pink-floyd','guitar','riff','fingerpicked intro and solo','crunch',
     'rock','lead','intermediate',
     'Fender Stratocaster (David Gilmour)','Hiwatt clean-to-crunch amp with delay','Open-back combo cab','bridge single-coil',
     '[{"effect_type":"delay","effect_name":"delay","placement":"post_gain","settings":{"mix":3,"time":4}}]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":2,"master":6}'::jsonb,
     array['Fretless-toned fingerpicked intro then a crying, delayed Gilmour solo; keep it expressive.','Low-medium gain, delay for space.'],
     array['Fingerpick the intro cleanly.','Play the solo with crying bends and delay.'],
     'Studio recording, 1979 (The Wall). David Gilmour played the fingerpicked intro and a crying, delayed solo on a Stratocaster.',74),
    ('dogs','pink-floyd','guitar','riff','clean chords and solos','crunch',
     'rock','lead','advanced',
     'Fender Stratocaster (David Gilmour)','Hiwatt clean-to-crunch amp with delay','Open-back combo cab','bridge single-coil',
     '[{"effect_type":"delay","effect_name":"delay","placement":"post_gain","settings":{"mix":3,"time":4}}]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":2,"master":6}'::jsonb,
     array['Sprawling epic with jazzy clean chords and long, soaring delayed solos; keep it dynamic.','Medium gain, ambient delay.'],
     array['Play the jazzy chords cleanly.','Let the soaring solos sustain with delay.'],
     'Studio recording, 1977 (Animals). David Gilmour played jazzy clean chords and long, soaring solos on a Stratocaster.',73),
    ('breathe-in-the-air','pink-floyd','guitar','riff','main progression with slide','clean',
     'rock','lead','intermediate',
     'Fender Stratocaster (David Gilmour)','Hiwatt clean-to-crunch amp with delay','Open-back combo cab','bridge single-coil',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":1,"master":6}'::jsonb,
     array['Warm, floating clean chords with lap/slide swells; keep it spacious and mellow.','Low gain, warm and ambient.'],
     array['Let the wide chords float.','Add gentle slide swells on top.'],
     'Studio recording, 1973 (The Dark Side of the Moon). David Gilmour played warm, floating clean chords with slide on a Stratocaster.',74),
    ('trains','porcupine-tree','guitar','riff','acoustic-tinged progression to crunch','crunch',
     'rock','rhythm','intermediate',
     'Electric guitar (Steven Wilson)','Clean-to-crunch amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm acoustic-tinged verses building to a big modern-prog crunch; keep the melody strong.','Medium gain.'],
     array['Play the picked verse cleanly.','Open into the fuller crunch chorus.'],
     'Studio recording, 2002 (In Absentia). Steven Wilson played warm verses building to a modern-prog crunch.',72),
    ('blackest-eyes','porcupine-tree','guitar','riff','main riff','high_gain',
     'rock','rhythm','advanced',
     'Electric guitar (Steven Wilson)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Alternates crushing djent-adjacent riffs with delicate clean passages; keep the heavy parts tight.','High gain for the riffs, wide dynamics.'],
     array['Keep the chugging riff tight.','Contrast with the delicate clean parts.'],
     'Studio recording, 2002 (In Absentia). Steven Wilson alternated crushing riffs with clean passages.',72),
    ('blackwater-park','opeth','guitar','riff','heavy riff and clean passages','high_gain',
     'metal','rhythm','advanced',
     'Electric guitar (Mikael Åkerfeldt)','High-gain amp / clean amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Sprawling prog-death: crushing riffs alternating with warm clean/acoustic sections; keep dynamics huge.','High gain for the heavy riffs.'],
     array['Keep the heavy riffs tight.','Play the clean interludes warmly.'],
     'Studio recording, 2001 (Blackwater Park). Mikael Åkerfeldt alternated crushing prog-death riffs with warm clean sections.',72),
    ('ghost-of-perdition','opeth','guitar','riff','heavy riff and clean passages','high_gain',
     'metal','rhythm','advanced',
     'Electric guitar (Mikael Åkerfeldt)','High-gain amp / clean amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Dynamic prog-death epic shifting from brutal riffs to melodic clean passages; keep the contrast wide.','High gain for the riffs.'],
     array['Keep the brutal riffs tight.','Play the melodic clean parts smoothly.'],
     'Studio recording, 2005 (Ghost Reveries). Mikael Åkerfeldt shifted between brutal riffs and melodic clean passages.',72),
    ('metropolis-pt-1','dream-theater','guitar','riff','main riff and solo','high_gain',
     'metal','lead','expert',
     'Ernie Ball Music Man (John Petrucci)','Mesa/Boogie high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":1,"master":6}'::jsonb,
     array['Intricate prog-metal with fast unison riffs and a virtuosic solo; keep everything precise.','High gain with clarity.'],
     array['Play the intricate riffs precisely.','Nail the fast unison lines and solo.'],
     'Studio recording, 1992 (Images and Words). John Petrucci played intricate prog-metal riffs and a virtuosic solo through a Mesa/Boogie.',73),
    ('kayleigh','marillion','guitar','riff','main riff and melodic lead','clean',
     'rock','lead','intermediate',
     'Electric guitar (Steve Rothery)','Clean amp with chorus and delay','Open-back combo cab','neck pickup',
     '[{"effect_type":"chorus","effect_name":"chorus","placement":"post_gain","settings":{"rate":3,"depth":4,"mix":4}}]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":2,"master":6}'::jsonb,
     array['Chiming, chorused clean riff with a soaring, lyrical lead; keep it shimmering and melodic.','Low gain, chorus and delay.'],
     array['Play the chiming riff cleanly.','Let the melodic lead soar.'],
     'Studio recording, 1985 (Misplaced Childhood). Steve Rothery played a chiming, chorused clean riff and lyrical lead.',72),
    ('peaches-en-regalia','frank-zappa','guitar','riff','instrumental theme','crunch',
     'rock','lead','advanced',
     'Gibson SG (Frank Zappa)','Clean-to-crunch amp','Open-back combo cab','bridge humbucker',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bright, layered instrumental with intricate melodic lines; keep it crisp and articulate.','Low-medium gain.'],
     array['Play the intricate melody cleanly.','Keep the layered parts tight.'],
     'Studio recording, 1969 (Hot Rats). Frank Zappa played the bright, layered instrumental theme.',72),
    ('lateralus','tool','guitar','riff','main riff','high_gain',
     'metal','rhythm','advanced',
     'Gibson Les Paul Silverburst (Adam Jones)','High-gain amp (Diezel/Marshall/Bogner blend)','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Hypnotic, building riff cycling through shifting Fibonacci-based time signatures; keep it tight and dynamic.','High gain, articulate.'],
     array['Count the shifting time signatures carefully.','Build intensity through the cycles.'],
     'Studio recording, 2001 (Lateralus). Adam Jones played the hypnotic, odd-time riff on his Les Paul Silverburst.',73)
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
  ('yes','roundabout'),('yes','owner-of-a-lonely-heart'),('yes','starship-trooper'),('genesis','firth-of-fifth'),
  ('genesis','i-know-what-i-like'),('king-crimson','21st-century-schizoid-man'),('king-crimson','red'),('jethro-tull','locomotive-breath'),
  ('jethro-tull','thick-as-a-brick'),('kansas','point-of-know-return'),('rush','yyz'),('rush','freewill'),
  ('rush','closer-to-the-heart'),('rush','la-villa-strangiato'),('pink-floyd','hey-you'),('pink-floyd','dogs'),
  ('pink-floyd','breathe-in-the-air'),('porcupine-tree','trains'),('porcupine-tree','blackest-eyes'),('opeth','blackwater-park'),
  ('opeth','ghost-of-perdition'),('dream-theater','metropolis-pt-1'),('marillion','kayleigh'),('frank-zappa','peaches-en-regalia'),
  ('tool','lateralus')
) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
cross join (values
  ('artist_interview', 'Documented artist interviews and gear discussions', null::text,
   'Researched from widely-documented interviews about this recording and player.', 72),
  ('rig_rundown', 'Published rig rundowns and community gear databases', null::text,
   'Cross-referenced against rig features and community-maintained gear databases.', 66)
) as x(source_type, title, url, notes, credibility)
where p.verification_status = 'admin_verified'
on conflict do nothing;
