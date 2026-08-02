-- Phase 78: iconic basslines (bass-mode profiles). Deletes are restricted to mode='bass'
-- so existing verified GUITAR profiles on the same songs are untouched.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Queen','queen','Another One Bites the Dust','another-one-bites-the-dust','The Game',1980),
    ('Queen','queen','Under Pressure','under-pressure','Hot Space',1981),
    ('Michael Jackson','michael-jackson','Billie Jean','billie-jean','Thriller',1982),
    ('The Jackson 5','the-jackson-5','I Want You Back','i-want-you-back','Diana Ross Presents The Jackson 5',1969),
    ('Chic','chic','Good Times','good-times','Risque',1979),
    ('Stevie Wonder','stevie-wonder','I Wish','i-wish','Songs in the Key of Life',1976),
    ('Jaco Pastorius','jaco-pastorius','Portrait of Tracy','portrait-of-tracy','Jaco Pastorius',1976),
    ('Primus','primus','My Name Is Mud','my-name-is-mud','Pork Soda',1993),
    ('Four Tops','four-tops','Bernadette','bernadette','Reach Out',1967),
    ('The Beatles','the-beatles','Taxman','taxman','Revolver',1966),
    ('Gorillaz','gorillaz','Feel Good Inc.','feel-good-inc','Demon Days',2005),
    ('Yes','yes','Roundabout','roundabout','Fragile',1971),
    ('Rush','rush','YYZ','yyz','Moving Pictures',1981),
    ('Tool','tool','Schism','schism','Lateralus',2001),
    ('Green Day','green-day','Longview','longview','Dookie',1994),
    ('Red Hot Chili Peppers','red-hot-chili-peppers','Around the World','around-the-world','Californication',1999),
    ('Red Hot Chili Peppers','red-hot-chili-peppers','Higher Ground','higher-ground','Mother''s Milk',1989),
    ('Pink Floyd','pink-floyd','Money','money','The Dark Side of the Moon',1973),
    ('The Who','the-who','My Generation','my-generation','My Generation',1965),
    ('The Beatles','the-beatles','Come Together','come-together','Abbey Road',1969),
    ('Fleetwood Mac','fleetwood-mac','The Chain','the-chain','Rumours',1977),
    ('Black Sabbath','black-sabbath','N.I.B.','n-i-b','Black Sabbath',1970),
    ('Metallica','metallica','For Whom the Bell Tolls','for-whom-the-bell-tolls','Ride the Lightning',1984),
    ('Marvin Gaye','marvin-gaye','What''s Going On','whats-going-on','What''s Going On',1971),
    ('Led Zeppelin','led-zeppelin','Ramble On','ramble-on','Led Zeppelin II',1969)
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
    ('queen','another-one-bites-the-dust'),('queen','under-pressure'),('michael-jackson','billie-jean'),
    ('the-jackson-5','i-want-you-back'),('chic','good-times'),('stevie-wonder','i-wish'),
    ('jaco-pastorius','portrait-of-tracy'),('primus','my-name-is-mud'),('four-tops','bernadette'),
    ('the-beatles','taxman'),('gorillaz','feel-good-inc'),('yes','roundabout'),('rush','yyz'),('tool','schism'),
    ('green-day','longview'),('red-hot-chili-peppers','around-the-world'),('red-hot-chili-peppers','higher-ground'),
    ('pink-floyd','money'),('the-who','my-generation'),('the-beatles','come-together'),('fleetwood-mac','the-chain'),
    ('black-sabbath','n-i-b'),('metallica','for-whom-the-bell-tolls'),('marvin-gaye','whats-going-on'),
    ('led-zeppelin','ramble-on')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
  where p.mode = 'bass'
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('queen','another-one-bites-the-dust'),('queen','under-pressure'),('michael-jackson','billie-jean'),
    ('the-jackson-5','i-want-you-back'),('chic','good-times'),('stevie-wonder','i-wish'),
    ('jaco-pastorius','portrait-of-tracy'),('primus','my-name-is-mud'),('four-tops','bernadette'),
    ('the-beatles','taxman'),('gorillaz','feel-good-inc'),('yes','roundabout'),('rush','yyz'),('tool','schism'),
    ('green-day','longview'),('red-hot-chili-peppers','around-the-world'),('red-hot-chili-peppers','higher-ground'),
    ('pink-floyd','money'),('the-who','my-generation'),('the-beatles','come-together'),('fleetwood-mac','the-chain'),
    ('black-sabbath','n-i-b'),('metallica','for-whom-the-bell-tolls'),('marvin-gaye','whats-going-on'),
    ('led-zeppelin','ramble-on')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
  where p.mode = 'bass'
);
delete from public.song_tone_profiles p where p.mode = 'bass' and p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('queen','another-one-bites-the-dust'),('queen','under-pressure'),('michael-jackson','billie-jean'),
    ('the-jackson-5','i-want-you-back'),('chic','good-times'),('stevie-wonder','i-wish'),
    ('jaco-pastorius','portrait-of-tracy'),('primus','my-name-is-mud'),('four-tops','bernadette'),
    ('the-beatles','taxman'),('gorillaz','feel-good-inc'),('yes','roundabout'),('rush','yyz'),('tool','schism'),
    ('green-day','longview'),('red-hot-chili-peppers','around-the-world'),('red-hot-chili-peppers','higher-ground'),
    ('pink-floyd','money'),('the-who','my-generation'),('the-beatles','come-together'),('fleetwood-mac','the-chain'),
    ('black-sabbath','n-i-b'),('metallica','for-whom-the-bell-tolls'),('marvin-gaye','whats-going-on'),
    ('led-zeppelin','ramble-on')
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
    ('another-one-bites-the-dust','queen','bass','bassline','main bassline','bass_clean','rock','rhythm','beginner',
     'Fender Precision Bass (John Deacon)','Direct + small amp, dry and tight','Studio DI','split-coil pickup',
     '[]'::jsonb,'{"gain":2,"bass":6,"mids":7,"treble":5,"presence":4,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['The most recognizable bassline in rock — Deacon''s dry, muted P-Bass groove.','Bone-dry mid-forward P-Bass; palm-mute the pulse.'],
     array['The riff IS the song — machine-steady eighths.','Lock the ghost notes; no swing.'],
     'Studio recording, 1980. Deacon''s dry disco-rock monument.',80),
    ('under-pressure','queen','bass','bassline','main bassline','bass_clean','rock','rhythm','beginner',
     'Fender Precision Bass (John Deacon)','Direct + amp, warm and round','Studio DI','split-coil pickup',
     '[]'::jsonb,'{"gain":2,"bass":6,"mids":6,"treble":5,"presence":4,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Ding-ding-ding-diki-ding-ding — the two-note line everyone on earth knows.','Warm round P-Bass; the space between notes is sacred.'],
     array['Two notes; total feel.','Whoever plays it, the room sings it.'],
     'Studio recording, 1981. The two-note monument.',80),
    ('billie-jean','michael-jackson','bass','bassline','main bassline','bass_clean','pop','rhythm','intermediate',
     'Yamaha BB-series bass (Louis Johnson)','Direct, tight and funky','Studio DI','P/J pickups',
     '[]'::jsonb,'{"gain":2,"bass":6,"mids":6,"treble":5,"presence":4,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['Louis "Thunder Thumbs" Johnson''s ostinato — the dancefloor heartbeat of Thriller.','Dry punchy fingerstyle; every note identical, forever.'],
     array['The ostinato never varies — discipline is the groove.','Fingerstyle, perfectly even, 117 BPM.'],
     'Studio recording, 1982. Thunder Thumbs'' immortal ostinato.',80),
    ('i-want-you-back','the-jackson-5','bass','bassline','main bassline','bass_clean','soul','rhythm','advanced',
     'Fender Precision Bass (Wilton Felder)','Direct + tube amp, Motown warmth','Studio DI','split-coil pickup',
     '[]'::jsonb,'{"gain":2,"bass":6,"mids":6,"treble":5,"presence":4,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['One of the greatest basslines ever written — Felder''s runs dance around little Michael.','Warm round P-Bass; the fills are melodies.'],
     array['The runs connect every chord — learn them as lines, not licks.','Joy in sixteenth notes.'],
     'Studio recording, 1969. The dancing Motown masterpiece.',80),
    ('good-times','chic','bass','bassline','main bassline','bass_clean','funk','rhythm','intermediate',
     'Music Man StingRay (Bernard Edwards)','Direct, bright disco snap','Studio DI','humbucker pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['The line that birthed hip-hop (Rapper''s Delight borrowed it) — Edwards'' immaculate disco walk.','Bright snapping StingRay; clean articulation at all costs.'],
     array['The famous descending walk anchors the loop.','These are the good times — play them precisely.'],
     'Studio recording, 1979. The line that launched hip-hop.',80),
    ('i-wish','stevie-wonder','bass','bassline','main bassline','bass_clean','funk','rhythm','advanced',
     'Fender Precision Bass (Nathan Watts)','Direct, punchy funk','Studio DI','split-coil pickup',
     '[]'::jsonb,'{"gain":2,"bass":6,"mids":7,"treble":5,"presence":4,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['Nathan Watts'' career-making chase — the slippery funk line under Stevie''s nostalgia.','Punchy mid-forward fingerstyle; the syncopation never rests.'],
     array['The line chases the clav — learn both rhythms.','Looking back on when I was a little nappy-headed boy — at full sprint.'],
     'Studio recording, 1976. Watts'' slippery funk chase.',79),
    ('portrait-of-tracy','jaco-pastorius','bass','bassline','harmonic solo piece','bass_clean','jazz fusion','lead','expert',
     'Fender Jazz Bass, fretless (Jaco Pastorius)','Direct, pristine','Studio DI','J pickups',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The harmonics bible — Jaco''s solo portrait painted entirely in natural and false harmonics.','Pristine clean Jazz Bass; bridge-pickup focus, feather touch.'],
     array['Map every harmonic node before attempting the piece.','This is why they call him the greatest.'],
     'Studio recording, 1976. Jaco''s harmonics bible.',80),
    ('my-name-is-mud','primus','bass','bassline','slap riff','bass_drive','alternative metal','rhythm','expert',
     'Carl Thompson 6-string (Les Claypool)','Amp with grind, weirdo funk-metal','Bass 4x10 cab','custom pickups',
     '[]'::jsonb,'{"gain":5,"bass":6,"mids":6,"treble":6,"presence":5,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['Claypool''s slap-strum mutant — percussive strumming-flamenco-slap hybrid on a 6-string.','Gritty clanking tone; the technique is the song.'],
     array['The strum-slap pattern is its own instrument — slow-motion practice.','My name is Mud — play it swampy.'],
     'Studio recording, 1993. Claypool''s slap-strum mutant.',78),
    ('bernadette','four-tops','bass','bassline','main bassline','bass_clean','soul','rhythm','advanced',
     'Fender Precision Bass (James Jamerson)','Direct to console, Motown','Studio DI','split-coil, flatwounds',
     '[]'::jsonb,'{"gain":2,"bass":6,"mids":6,"treble":4,"presence":3,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Jamerson''s masterpiece — the one-finger genius improvising a symphony under the Tops.','Warm flatwound P-Bass thump; the fills never repeat.'],
     array['Study the fills — each pass is different, all are perfect.','The Hook: one finger, infinite swing.'],
     'Studio recording, 1967. Jamerson''s one-finger symphony.',80),
    ('taxman','the-beatles','bass','bassline','main bassline','bass_clean','rock','rhythm','intermediate',
     'Rickenbacker 4001 (Paul McCartney)','Vox amp, biting and melodic','Vox cab','toaster pickups',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['McCartney''s funk awakening — the snaking Rickenbacker line that drives Revolver''s opener.','Bright growling Rick tone; the line stalks.'],
     array['The riff coils around D7 — mind the chromatic passing tones.','One for you, nineteen for me — count it.'],
     'Studio recording, 1966. McCartney''s stalking Rickenbacker line.',80),
    ('feel-good-inc','gorillaz','bass','bassline','main bassline','bass_clean','alternative rock','rhythm','beginner',
     'Electric bass (Morgan Nicholls / Murdoc)','Direct, dry indie-hop','Studio DI','P-style pickup',
     '[]'::jsonb,'{"gain":2,"bass":6,"mids":6,"treble":5,"presence":4,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['The windmill-island earworm — dry rubbery line every beginner learns second.','Dead-dry fingerstyle; the hook is four bars of cool.'],
     array['The line loops — keep the muting consistent.','Feel good — exactly that.'],
     'Studio recording, 2005. The windmill-island earworm.',78),
    ('roundabout','yes','bass','bassline','main bassline','bass_drive','progressive rock','rhythm','advanced',
     'Rickenbacker 4001 (Chris Squire)','Driven amp + DI blend, trebly growl','Bass stack','toaster pickups',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['Squire''s galloping growl — the trebly pick-attack Rickenbacker that defined prog bass.','Bright driven Rick with pick; piano-string clank on purpose.'],
     array['Pick the gallop hard; the treble is the identity.','The meme intro is acoustic guitar; the bass owns the rest.'],
     'Studio recording, 1971. Squire''s galloping Rickenbacker growl.',80),
    ('yyz','rush','bass','bassline','instrumental workout','bass_drive','progressive rock','lead','expert',
     'Rickenbacker/Fender Jazz (Geddy Lee)','Driven amp + DI, snarling','Bass stack','J pickups',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":7,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The Morse-code monster — Geddy''s snarling lead-bass through the 5/4 airport code.','Aggressive mid-snarl; the bass is the lead singer here.'],
     array['Y-Y-Z in Morse opens it — 5/4 then everything.','The bass solo section took everyone''s lunch money.'],
     'Studio recording, 1981. Geddy''s Morse-code monster.',80),
    ('schism','tool','bass','bassline','main bassline','bass_drive','progressive metal','rhythm','advanced',
     'Wal Mk2 bass (Justin Chancellor)','Driven amp, growling mid-honk','Bass 4x10 stack','Wal pickups',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":7,"treble":6,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['The 5/8+7/8 riddle — Chancellor''s honking Wal growl carrying the whole song.','Picked mid-honk with grind; the Wal quack is the sound.'],
     array['Count the shifting meter until it breathes.','I know the pieces fit — assemble them slowly.'],
     'Studio recording, 2001. Chancellor''s odd-meter Wal riddle.',80),
    ('longview','green-day','bass','bassline','main bassline','bass_clean','pop punk','rhythm','intermediate',
     'Fender Precision Bass (Mike Dirnt)','Amp + DI, bouncing punk clean','Bass 4x10 cab','split-coil pickup',
     '[]'::jsonb,'{"gain":2,"bass":6,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['The couch-boredom walk — Dirnt''s swinging line written (legend says) on acid.','Round bouncing P-Bass; the verse belongs to you alone.'],
     array['Swing the line loose; it saunters.','When the guitars crash in, hold your ground.'],
     'Studio recording, 1994. Dirnt''s couch-boredom walk.',79),
    ('around-the-world','red-hot-chili-peppers','bass','bassline','main bassline','bass_drive','funk rock','rhythm','expert',
     'Modulus Flea Bass (Flea)','Driven amp, aggressive funk','Bass 4x10 stack','humbucker pickup',
     '[]'::jsonb,'{"gain":4,"bass":6,"mids":6,"treble":6,"presence":6,"reverb":0,"delay":0,"master":8}'::jsonb,
     array['Flea''s opening statement on Californication — distorted slap-and-fingers fury.','Gritty aggressive attack; the intro is a gauntlet.'],
     array['The intro run is finger-twisting — isolate it.','All around the world — at Flea velocity.'],
     'Studio recording, 1999. Flea''s opening gauntlet.',79),
    ('higher-ground','red-hot-chili-peppers','bass','bassline','slap riff','bass_drive','funk rock','rhythm','advanced',
     'Music Man StingRay (Flea)','Amp + DI, slap machine','Bass 4x10 stack','humbucker pickup',
     '[]'::jsonb,'{"gain":3,"bass":6,"mids":6,"treble":7,"presence":6,"reverb":0,"delay":0,"master":8}'::jsonb,
     array['The Stevie cover that made slap mainstream — Flea''s octave thumb machine.','Bright snapping StingRay; thumb-pop octaves forever.'],
     array['Slap the octave pattern until it''s automatic.','Gonna keep on trying — your thumb will.'],
     'Studio recording, 1989. Flea''s octave slap machine.',79),
    ('money','pink-floyd','bass','bassline','main bassline','bass_clean','rock','rhythm','intermediate',
     'Fender Precision Bass (Roger Waters)','Amp, round and deliberate','Bass cab','split-coil pickup',
     '[]'::jsonb,'{"gain":2,"bass":6,"mids":6,"treble":4,"presence":3,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['The 7/4 cash register — Waters'' deliberate walking figure everyone learns for the time signature.','Warm round P-Bass; seven beats, no hurry.'],
     array['Count 7/4 until it stops being weird.','The line IS the song''s skeleton.'],
     'Studio recording, 1973. The 7/4 cash-register walk.',80),
    ('my-generation','the-who','bass','bassline','verse + bass breaks','bass_drive','rock','lead','advanced',
     'Fender Jazz Bass (John Entwistle)','Amp cranked, trebly lead-bass','Bass stack','J pickups',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The first bass solo on a hit record — Entwistle''s stuttering Jazz Bass breaks.','Bright snarling attack; the Ox answers the stutter.'],
     array['The solo breaks trade with the vocal — crisp and loud.','Hope I die before I get old — the bass never did.'],
     'Studio recording, 1965. Entwistle''s history-making breaks.',80),
    ('come-together','the-beatles','bass','bassline','main bassline','bass_clean','rock','rhythm','beginner',
     'Fender Jazz Bass (Paul McCartney)','Amp, dark and swampy','Bass cab','J pickups',
     '[]'::jsonb,'{"gain":2,"bass":7,"mids":5,"treble":4,"presence":3,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['The swamp-walk — McCartney''s dark descending slide figure.','Deep dark tone; the slide into each phrase is the signature.'],
     array['Slide into the figure; let it ooze.','Shoot me — then the bass answers.'],
     'Studio recording, 1969. The swamp-walk figure.',80),
    ('the-chain','fleetwood-mac','bass','bassline','outro bass break','bass_clean','rock','rhythm','beginner',
     'Fender Precision Bass (John McVie)','Amp, round and building','Bass cab','split-coil pickup',
     '[]'::jsonb,'{"gain":2,"bass":6,"mids":6,"treble":5,"presence":4,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['The Formula 1 theme — McVie''s ominous outro run, the most famous 8 bars in bass.','Round driving P-Bass; the build is a green light.'],
     array['The descending outro figure — everyone waits for it.','Lights out, and away we go.'],
     'Studio recording, 1977. The F1-theme outro run.',80),
    ('n-i-b','black-sabbath','bass','bassline','intro solo + riff','bass_drive','metal','lead','intermediate',
     'Fender Precision Bass (Geezer Butler)','Amp cranked with wah intro','Bass stack','split-coil pickup',
     '[{"effect_type":"wah","effect_name":"bass wah (intro solo)","placement":"front","settings":{"position":5}}]'::jsonb,
     '{"gain":4,"bass":6,"mids":6,"treble":5,"presence":4,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['"Bassically" — Geezer''s wah-drenched intro solo into the doom riff doubling.','Driven P-Bass growl; the wah intro is its own track.'],
     array['The intro solo bends and swells through the wah.','Then double Iommi''s riff like a shadow.'],
     'Studio recording, 1970. Geezer''s wah-intro landmark.',79),
    ('for-whom-the-bell-tolls','metallica','bass','bassline','intro lead','bass_drive','metal','lead','intermediate',
     'Rickenbacker 4001 with distortion (Cliff Burton)','Driven amp with wah color','Bass stack','toaster pickups',
     '[{"effect_type":"distortion","effect_name":"bass distortion","placement":"front","settings":{"gain":6,"level":6}},{"effect_type":"wah","effect_name":"bass wah color","placement":"front","settings":{"position":6}}]'::jsonb,
     '{"gain":6,"bass":6,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['That famous intro "guitar"? It''s Cliff Burton''s distorted bass with wah.','Snarling driven Rick; the chromatic intro is all bass.'],
     array['The intro lead bends through the wah — it''s yours, not the guitarist''s.','Play it loud enough to correct thirty years of misattribution.'],
     'Studio recording, 1984. Cliff''s misattributed intro lead.',80),
    ('whats-going-on','marvin-gaye','bass','bassline','main bassline','bass_clean','soul','rhythm','advanced',
     'Fender Precision Bass (James Jamerson)','Direct, Motown warmth','Studio DI','split-coil, flatwounds',
     '[]'::jsonb,'{"gain":2,"bass":6,"mids":6,"treble":4,"presence":3,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Recorded flat on his back (legend says) — Jamerson''s flowing line under Marvin''s question.','Warm flatwound thump; the fills float like the strings.'],
     array['The line breathes with the vocal — rubato feel over the groove.','Mercy mercy me — every fill a sigh.'],
     'Studio recording, 1971. Jamerson''s flat-on-his-back masterpiece.',80),
    ('ramble-on','led-zeppelin','bass','bassline','main bassline','bass_clean','rock','rhythm','intermediate',
     'Fender Jazz Bass (John Paul Jones)','Amp, warm melodic drive','Bass cab','J pickups',
     '[]'::jsonb,'{"gain":2,"bass":6,"mids":6,"treble":5,"presence":4,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['JPJ''s melodic chase — the verse bassline outruns the vocal melody.','Warm singing Jazz Bass; a countermelody, not a root-note job.'],
     array['Learn the verse line as a melody in itself.','Leaf and Gollum jokes optional; the line is mandatory.'],
     'Studio recording, 1969. JPJ''s melodic verse chase.',80)
) as c(
  song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence
)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;
