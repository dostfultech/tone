-- Phase 79: iconic basslines vol. 2 — funk & session legends (bass-mode profiles).
-- Deletes restricted to mode='bass' so existing guitar profiles are preserved.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Sly & The Family Stone','sly-and-the-family-stone','Thank You (Falettinme Be Mice Elf Agin)','thank-you-falettinme','Greatest Hits',1969),
    ('Earth, Wind & Fire','earth-wind-and-fire','September','september','The Best of Earth, Wind & Fire Vol. 1',1978),
    ('Commodores','commodores','Brick House','brick-house','Commodores',1977),
    ('Stevie Wonder','stevie-wonder','I Was Made to Love Her','i-was-made-to-love-her','I Was Made to Love Her',1967),
    ('Bruno Mars','bruno-mars','Uptown Funk','uptown-funk','Uptown Special',2014),
    ('Weather Report','weather-report','Teen Town','teen-town','Heavy Weather',1977),
    ('Weather Report','weather-report','Birdland','birdland','Heavy Weather',1977),
    ('Stanley Clarke','stanley-clarke','School Days','school-days','School Days',1976),
    ('Patrice Rushen','patrice-rushen','Forget Me Nots','forget-me-nots','Straight from the Heart',1982),
    ('Tower of Power','tower-of-power','What Is Hip?','what-is-hip','Tower of Power',1973),
    ('Steely Dan','steely-dan','Peg','peg','Aja',1977),
    ('Aerosmith','aerosmith','Sweet Emotion','sweet-emotion','Toys in the Attic',1975),
    ('Motorhead','motorhead','Ace of Spades','ace-of-spades','Ace of Spades',1980),
    ('Iron Maiden','iron-maiden','The Trooper','the-trooper','Piece of Mind',1983),
    ('Metallica','metallica','Orion','orion','Master of Puppets',1986),
    ('Primus','primus','Tommy the Cat','tommy-the-cat','Sailing the Seas of Cheese',1991),
    ('Red Hot Chili Peppers','red-hot-chili-peppers','Aeroplane','aeroplane','One Hot Minute',1995),
    ('Red Hot Chili Peppers','red-hot-chili-peppers','Otherside','otherside','Californication',1999),
    ('Duran Duran','duran-duran','Rio','rio','Rio',1982),
    ('The Who','the-who','The Real Me','the-real-me','Quadrophenia',1973),
    ('Bill Withers','bill-withers','Lovely Day','lovely-day','Menagerie',1977),
    ('The Temptations','the-temptations','Papa Was a Rollin'' Stone','papa-was-a-rollin-stone','All Directions',1972),
    ('Herbie Hancock','herbie-hancock','Chameleon','chameleon','Head Hunters',1973),
    ('The Clash','the-clash','The Guns of Brixton','the-guns-of-brixton','London Calling',1979),
    ('Graham Central Station','graham-central-station','Hair','hair','Release Yourself',1974)
),
ins_artists as (
  insert into public.artists (name, slug, search_text, is_active)
  select distinct artist_name, artist_slug, artist_name, true from target
  on conflict (slug) do update set name = excluded.name, is_active = true
  returning id, slug
)
insert into public.songs (artist_id, title, slug, album, release_year, search_text, is_active)
select a.id, t.song_title, t.song_slug, t.album, t.release_year,
       concat_ws(' ', t.song_title, t.artist_name, t.album, 'bassline bass'), true
from target t join ins_artists a on a.slug = t.artist_slug
on conflict (artist_id, slug) do update set
  is_active = true, updated_at = now();

-- BASS-ONLY deletes: existing guitar profiles on these songs are preserved.
delete from public.tone_profile_effects e where e.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('sly-and-the-family-stone','thank-you-falettinme'),('earth-wind-and-fire','september'),('commodores','brick-house'),
    ('stevie-wonder','i-was-made-to-love-her'),('bruno-mars','uptown-funk'),('weather-report','teen-town'),
    ('weather-report','birdland'),('stanley-clarke','school-days'),('patrice-rushen','forget-me-nots'),
    ('tower-of-power','what-is-hip'),('steely-dan','peg'),('aerosmith','sweet-emotion'),('motorhead','ace-of-spades'),
    ('iron-maiden','the-trooper'),('metallica','orion'),('primus','tommy-the-cat'),('red-hot-chili-peppers','aeroplane'),
    ('red-hot-chili-peppers','otherside'),('duran-duran','rio'),('the-who','the-real-me'),('bill-withers','lovely-day'),
    ('the-temptations','papa-was-a-rollin-stone'),('herbie-hancock','chameleon'),('the-clash','the-guns-of-brixton'),
    ('graham-central-station','hair')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
  where p.mode = 'bass'
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('sly-and-the-family-stone','thank-you-falettinme'),('earth-wind-and-fire','september'),('commodores','brick-house'),
    ('stevie-wonder','i-was-made-to-love-her'),('bruno-mars','uptown-funk'),('weather-report','teen-town'),
    ('weather-report','birdland'),('stanley-clarke','school-days'),('patrice-rushen','forget-me-nots'),
    ('tower-of-power','what-is-hip'),('steely-dan','peg'),('aerosmith','sweet-emotion'),('motorhead','ace-of-spades'),
    ('iron-maiden','the-trooper'),('metallica','orion'),('primus','tommy-the-cat'),('red-hot-chili-peppers','aeroplane'),
    ('red-hot-chili-peppers','otherside'),('duran-duran','rio'),('the-who','the-real-me'),('bill-withers','lovely-day'),
    ('the-temptations','papa-was-a-rollin-stone'),('herbie-hancock','chameleon'),('the-clash','the-guns-of-brixton'),
    ('graham-central-station','hair')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
  where p.mode = 'bass'
);
delete from public.song_tone_profiles p where p.mode = 'bass' and p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('sly-and-the-family-stone','thank-you-falettinme'),('earth-wind-and-fire','september'),('commodores','brick-house'),
    ('stevie-wonder','i-was-made-to-love-her'),('bruno-mars','uptown-funk'),('weather-report','teen-town'),
    ('weather-report','birdland'),('stanley-clarke','school-days'),('patrice-rushen','forget-me-nots'),
    ('tower-of-power','what-is-hip'),('steely-dan','peg'),('aerosmith','sweet-emotion'),('motorhead','ace-of-spades'),
    ('iron-maiden','the-trooper'),('metallica','orion'),('primus','tommy-the-cat'),('red-hot-chili-peppers','aeroplane'),
    ('red-hot-chili-peppers','otherside'),('duran-duran','rio'),('the-who','the-real-me'),('bill-withers','lovely-day'),
    ('the-temptations','papa-was-a-rollin-stone'),('herbie-hancock','chameleon'),('the-clash','the-guns-of-brixton'),
    ('graham-central-station','hair')
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
  concat_ws(' ', s.title, a.name, c.part_label, c.tone_type, c.original_guitar, c.original_amp, 'bassline researched verified tone'),
  true
from (
  values
    ('thank-you-falettinme','sly-and-the-family-stone','bass','bassline','slap origin line','bass_drive','funk','rhythm','advanced',
     'Fender Precision Bass (Larry Graham)','Amp, thumping and plucking','Bass cab','split-coil pickup',
     '[]'::jsonb,'{"gain":3,"bass":6,"mids":6,"treble":6,"presence":5,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['Where slap bass WAS INVENTED — Graham''s thumpin'' and pluckin'' on the Sly classic.','Percussive thumb-and-pop attack; this line is the technique''s birth certificate.'],
     array['Thumb the low notes, pop the octaves.','Every slap player owes this line rent.'],
     'Studio recording, 1969. Larry Graham invents slap bass.',80),
    ('september','earth-wind-and-fire','bass','bassline','main bassline','bass_clean','funk','rhythm','intermediate',
     'Fender Jazz/P Bass (Verdine White)','Direct, bouncing disco-funk','Studio DI','split-coil pickup',
     '[]'::jsonb,'{"gain":2,"bass":6,"mids":6,"treble":5,"presence":4,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['The 21st-night eternal — Verdine''s bouncing line under the horns.','Round bouncing fingerstyle; joy in constant motion.'],
     array['The line skips and lands with the kick.','Ba-dee-ya — never miss the pickup notes.'],
     'Studio recording, 1978. Verdine''s 21st-night bounce.',79),
    ('brick-house','commodores','bass','bassline','main bassline','bass_clean','funk','rhythm','intermediate',
     'Fender Precision Bass (Ronald LaPread)','Amp + DI, thick funk','Bass cab','split-coil pickup',
     '[]'::jsonb,'{"gain":2,"bass":7,"mids":6,"treble":5,"presence":4,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['The mighty-mighty groove — LaPread''s strutting funk line.','Thick round thump; the strut is non-negotiable.'],
     array['The main figure struts on the E.','She''s a brick... house — let the rest ring.'],
     'Studio recording, 1977. The mighty-mighty strut.',79),
    ('i-was-made-to-love-her','stevie-wonder','bass','bassline','main bassline','bass_clean','soul','rhythm','expert',
     'Fender Precision Bass (James Jamerson)','Direct to console, Motown','Studio DI','split-coil, flatwounds',
     '[]'::jsonb,'{"gain":2,"bass":6,"mids":6,"treble":4,"presence":3,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Jamerson unchained — arguably his busiest, most joyful line ever recorded.','Warm flatwound thump; sixteenth-note syncopation that never repeats.'],
     array['Transcriptions exist; the feel doesn''t transcribe.','One finger. Somehow. One finger.'],
     'Studio recording, 1967. Jamerson at maximum joy.',80),
    ('uptown-funk','bruno-mars','bass','bassline','main bassline','bass_clean','funk','rhythm','intermediate',
     'Fender Jazz Bass (Jamareo Artis)','Direct, tight retro-funk','Studio DI','J pickups',
     '[]'::jsonb,'{"gain":2,"bass":6,"mids":6,"treble":5,"presence":4,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['The modern funk monument — Artis'' Minneapolis-schooled line under the horns.','Dry punchy fingerstyle; don''t believe me, just watch.'],
     array['The verse line walks; the hook stabs.','Too hot — hot damn — exactly on the grid.'],
     'Studio recording, 2014. The modern funk monument.',78),
    ('teen-town','weather-report','bass','bassline','lead bass melody','bass_clean','jazz fusion','lead','expert',
     'Fender Jazz Bass, fretless (Jaco Pastorius)','Direct, singing fretless','Studio DI','J pickups (bridge focus)',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['The bass-as-lead-instrument thesis — Jaco''s sixteenth-note melody at impossible tempo.','Singing bridge-pickup fretless; the bass IS the horn section.'],
     array['Learn it at half speed for months.','Jaco also played drums on the track. Show-off.'],
     'Studio recording, 1977. Jaco''s lead-bass thesis.',80),
    ('birdland','weather-report','bass','bassline','harmonic intro + groove','bass_clean','jazz fusion','rhythm','advanced',
     'Fender Jazz Bass, fretless (Jaco Pastorius)','Direct, warm and vocal','Studio DI','J pickups',
     '[]'::jsonb,'{"gain":2,"bass":6,"mids":6,"treble":5,"presence":4,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['The fusion hit — Jaco''s false-harmonic "guitar" intro and strutting groove.','Warm vocal fretless; the intro harmonics fooled everyone.'],
     array['The intro is false harmonics up high — thumb-and-touch technique.','Then swing the theme like the big band it honors.'],
     'Studio recording, 1977. Jaco''s harmonic-intro fusion hit.',80),
    ('school-days','stanley-clarke','bass','bassline','lead bass anthem','bass_drive','jazz fusion','lead','expert',
     'Alembic bass (Stanley Clarke)','Amp, bright piccolo-adjacent attack','Bass stack','Alembic pickups',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The lead-bass anthem — Clarke''s ringing Alembic riff that made bassists frontmen.','Bright piano-string attack; the riff is scripture.'],
     array['The main riff rings open strings against fretted stabs.','They said the bass was a background instrument. They were wrong.'],
     'Studio recording, 1976. Clarke''s lead-bass anthem.',80),
    ('forget-me-nots','patrice-rushen','bass','bassline','main bassline','bass_clean','funk','rhythm','advanced',
     'Fender Precision Bass (Freddie Washington)','Direct, snapping funk','Studio DI','split-coil pickup',
     '[]'::jsonb,'{"gain":2,"bass":6,"mids":6,"treble":6,"presence":5,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['The line so good it became Men in Black — Washington''s slap-and-finger hybrid.','Bright snapping P-Bass; the hook is the whole song.'],
     array['Slap the signature figure exactly.','Sending you forget-me-nots — funky ones.'],
     'Studio recording, 1982. Washington''s twice-famous hook.',79),
    ('what-is-hip','tower-of-power','bass','bassline','fingerstyle sixteenths','bass_clean','funk','rhythm','expert',
     'Fender Precision Bass (Francis "Rocco" Prestia)','Amp + DI, muted machine-gun','Bass cab','split-coil pickup',
     '[]'::jsonb,'{"gain":2,"bass":6,"mids":7,"treble":5,"presence":4,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['The fingerstyle-funk bible — Rocco''s relentless muted sixteenths.','Muted percolating P-Bass; every note short, none skipped.'],
     array['Left-hand muting is the entire technique.','Hipness is — what it is. Sixteenths forever.'],
     'Studio recording, 1973. Rocco''s sixteenth-note bible.',80),
    ('peg','steely-dan','bass','bassline','main bassline','bass_clean','rock','rhythm','advanced',
     'Fender Precision Bass (Chuck Rainey)','Direct, silk-funk session tone','Studio DI','split-coil pickup',
     '[]'::jsonb,'{"gain":2,"bass":6,"mids":6,"treble":5,"presence":4,"reverb":0,"delay":0,"master":6}'::jsonb,
     array['Rainey''s contraband slap — he hid the slapping from Becker & Fagen behind a baffle, and it made the record.','Silky punchy session tone; grace notes everywhere.'],
     array['The verse line dances around the kick.','Slap it quietly — historically accurate.'],
     'Studio recording, 1977. Rainey''s hidden-slap classic.',79),
    ('sweet-emotion','aerosmith','bass','bassline','intro bassline','bass_clean','rock','rhythm','beginner',
     'Fender Precision Bass (Tom Hamilton)','Amp, round and hypnotic','Bass cab','split-coil pickup',
     '[]'::jsonb,'{"gain":2,"bass":7,"mids":5,"treble":4,"presence":3,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['The talk-box song opens with BASS — Hamilton''s hypnotic two-bar intro everyone air-plays.','Deep round pulse; patience is the hook.'],
     array['The intro line loops as the tension builds.','You own the first thirty seconds. Enjoy them.'],
     'Studio recording, 1975. Hamilton''s hypnotic intro.',80),
    ('ace-of-spades','motorhead','bass','bassline','main riff (bass-as-rhythm-guitar)','bass_drive','metal','rhythm','intermediate',
     'Rickenbacker 4001 (Lemmy Kilmister)','Marshall stacks, distorted chords','Marshall bass stack','toaster pickups',
     '[{"effect_type":"distortion","effect_name":"overdriven Marshall grind","placement":"front","settings":{"gain":7,"level":7}}]'::jsonb,
     '{"gain":7,"bass":5,"mids":7,"treble":7,"presence":6,"reverb":0,"delay":0,"master":8}'::jsonb,
     array['Lemmy didn''t play bass; he played rhythm guitar on a Rickenbacker through screaming Marshalls.','Distorted chordal roar; treble up, subtlety off.'],
     array['Play CHORDS, downstrokes, at full violence.','The intro run announces the apocalypse.'],
     'Studio recording, 1980. Lemmy''s rhythm-guitar bass roar.',80),
    ('the-trooper','iron-maiden','bass','bassline','gallop engine','bass_clean','metal','rhythm','advanced',
     'Fender Precision Bass (Steve Harris)','Amp, clanking trebly gallop','Bass 4x12 stack','split-coil, flatwounds',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":8,"presence":7,"reverb":0,"delay":0,"master":8}'::jsonb,
     array['The Maiden gallop itself — Harris'' three-finger clank driving the cavalry.','Trebly piano-string clank; flatwounds hit HARD.'],
     array['The gallop: two sixteenths and an eighth, forever.','Your fingers are the horses.'],
     'Studio recording, 1983. Harris'' cavalry gallop.',80),
    ('orion','metallica','bass','bassline','melodic bass interlude','bass_drive','metal','lead','advanced',
     'Rickenbacker/Aria (Cliff Burton)','Driven amp, singing lead bass','Bass stack','humbucker pickups',
     '[{"effect_type":"distortion","effect_name":"bass overdrive","placement":"front","settings":{"gain":5,"level":6}}]'::jsonb,
     '{"gain":5,"bass":6,"mids":7,"treble":5,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['Cliff''s cathedral — the middle-section bass melodies that sound like guitars praying.','Warm driven lead-bass voice; the swells are volume-knob work.'],
     array['The melodic interlude is Cliff''s heart on tape.','They buried him to this song. Play it like that matters.'],
     'Studio recording, 1986. Cliff''s cathedral interlude.',80),
    ('tommy-the-cat','primus','bass','bassline','slap-flurry showcase','bass_drive','alternative metal','lead','expert',
     'Carl Thompson 4-string (Les Claypool)','Amp, clanking weirdo-funk','Bass 4x10 cab','custom pickups',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":7,"treble":7,"presence":6,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['The audition-destroyer — Claypool''s strumming slap flurry at conversation speed.','Clanking percussive chaos; precision hiding inside madness.'],
     array['Break the flurry into its slap/pluck/strum atoms.','Say baby — then blackout technique.'],
     'Studio recording, 1991. Claypool''s audition-destroyer.',79),
    ('aeroplane','red-hot-chili-peppers','bass','bassline','funk verse + slap outro','bass_clean','funk rock','rhythm','advanced',
     'Alembic/Modulus (Flea)','Amp + DI, springy funk','Bass 4x10 cab','humbucker pickup',
     '[]'::jsonb,'{"gain":3,"bass":6,"mids":6,"treble":6,"presence":5,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['Pleasure-spiked-with-pain funk — Flea''s springy verse line and the children''s-choir slap outro.','Bright springy fingerstyle into full slap celebration.'],
     array['The verse line bounces off the vocal.','The outro slap solo is pure Flea joy — with his daughter''s choir.'],
     'Studio recording, 1995. Flea''s pleasure-and-pain funk.',79),
    ('otherside','red-hot-chili-peppers','bass','bassline','main bassline','bass_clean','funk rock','rhythm','beginner',
     'Modulus Flea Bass (Flea)','Amp + DI, melodic restraint','Bass 4x10 cab','humbucker pickup',
     '[]'::jsonb,'{"gain":2,"bass":6,"mids":6,"treble":5,"presence":4,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Restrained Flea — the melodic Am line every beginner bassist learns first.','Warm round fingerstyle; melody over flash.'],
     array['The verse line IS the song''s harmony.','How long, how long — steady as grief.'],
     'Studio recording, 1999. Flea''s restrained Am classic.',79),
    ('rio','duran-duran','bass','bassline','main bassline','bass_clean','new wave','rhythm','advanced',
     'Aria Pro II (John Taylor)','Amp + DI, bright disco-funk chorus','Bass cab','J-style pickups',
     '[{"effect_type":"chorus","effect_name":"80s bass chorus","placement":"post_gain","settings":{"rate":3,"depth":4,"mix":4}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['Her name is Rio and the bass never stops dancing — Taylor''s chorused disco-funk sprint.','Bright chorused attack; Chic filtered through MTV.'],
     array['The verse sixteenths sparkle — right-hand stamina.','She dances on the sand. You dance on the E string.'],
     'Studio recording, 1982. Taylor''s dancing sprint.',79),
    ('the-real-me','the-who','bass','bassline','lead bass rampage','bass_drive','rock','lead','expert',
     'Fender Precision Bass (John Entwistle)','Amp cranked, roaring treble','Bass stack','split-coil pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":8,"presence":7,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The Ox off the leash — reportedly one take, laughing, while the band gaped.','Roaring trebly attack; the bass solos through the entire song.'],
     array['There is no "part" — it''s continuous invention.','Can you see the real me? The bass can.'],
     'Studio recording, 1973. The Ox''s one-take rampage.',80),
    ('lovely-day','bill-withers','bass','bassline','main bassline','bass_clean','soul','rhythm','intermediate',
     'Fender Precision Bass (Jerry Knight)','Direct, gliding soul','Studio DI','split-coil pickup',
     '[]'::jsonb,'{"gain":2,"bass":6,"mids":6,"treble":5,"presence":4,"reverb":0,"delay":0,"master":6}'::jsonb,
     array['The sunrise glide — the walking line that carries the 18-second note.','Smooth round fingerstyle; optimism in stepwise motion.'],
     array['The line climbs with the sun.','A lovely daaaaaay — you hold the ground under it.'],
     'Studio recording, 1977. The sunrise glide.',78),
    ('papa-was-a-rollin-stone','the-temptations','bass','bassline','one-note groove','bass_clean','soul','rhythm','beginner',
     'Fender Precision Bass (Bob Babbitt)','Direct, deep cinematic funk','Studio DI','split-coil pickup',
     '[]'::jsonb,'{"gain":2,"bass":7,"mids":5,"treble":4,"presence":3,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Twelve minutes on (almost) one note — the deepest groove Motown ever cut.','Deep dark pulse; the restraint is the drama.'],
     array['One note, placed perfectly, forever.','It was the third of September — and the bass never blinked.'],
     'Studio recording, 1972. The one-note cinema groove.',79),
    ('chameleon','herbie-hancock','bass','bassline','main groove (synth-bass line)','bass_clean','jazz fusion','rhythm','intermediate',
     'Bass adaptation of the ARP synth line (Paul Jackson on later sections)','Amp, fat and funky','Bass cab','split-coil pickup',
     '[]'::jsonb,'{"gain":2,"bass":7,"mids":6,"treble":4,"presence":3,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['The famous line is an ARP synth — but it''s bass-audition scripture, and Paul Jackson''s live grooves own the back half.','Fat round tone; the funkiest four bars in fusion.'],
     array['The Bb-minor line loops — pocket it deep.','Every jam night starts here. Be ready.'],
     'Studio recording, 1973. The audition-scripture groove (synth original, honestly noted).',78),
    ('the-guns-of-brixton','the-clash','bass','bassline','main bassline','bass_clean','punk','rhythm','beginner',
     'Fender Precision Bass (Paul Simonon)','Amp, dubby menace','Bass cab','split-coil pickup',
     '[]'::jsonb,'{"gain":2,"bass":7,"mids":5,"treble":4,"presence":3,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['Simonon finally sings — and his dub-heavy line stalks the whole song.','Deep dubby pulse; London menace in a minor key.'],
     array['The line prowls — behind the beat, low and heavy.','When they kick at your front door, how you gonna come?'],
     'Studio recording, 1979. Simonon''s dub-menace stalk.',79),
    ('hair','graham-central-station','bass','bassline','slap showcase','bass_drive','funk','lead','expert',
     'Fender Jazz Bass (Larry Graham)','Amp with grind, full slap arsenal','Bass stack','J pickups',
     '[{"effect_type":"distortion","effect_name":"light bass grind","placement":"front","settings":{"gain":4,"level":6}}]'::jsonb,
     '{"gain":4,"bass":6,"mids":6,"treble":7,"presence":6,"reverb":0,"delay":0,"master":8}'::jsonb,
     array['The inventor showing off — Graham''s full thumpin''-and-pluckin'' arsenal with grind.','Aggressive snapping attack; the technique''s victory lap.'],
     array['Thumb, pluck, hammer, repeat.','Dere ain''t nothin'' but a party.'],
     'Studio recording, 1974. Graham''s slap victory lap.',79)
) as c(
  song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence
)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;
