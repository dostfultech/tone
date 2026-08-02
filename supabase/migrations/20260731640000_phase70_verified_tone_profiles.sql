-- Phase 70: US jam/roots canon (Grateful Dead, Phish, DMB, Dire Straits deep cuts, Steely Dan), verified per-part tone data.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Grateful Dead','grateful-dead','Ripple','ripple','American Beauty',1970),
    ('Grateful Dead','grateful-dead','Friend of the Devil','friend-of-the-devil','American Beauty',1970),
    ('Grateful Dead','grateful-dead','Casey Jones','casey-jones','Workingman''s Dead',1970),
    ('Grateful Dead','grateful-dead','Touch of Grey','touch-of-grey','In the Dark',1987),
    ('Grateful Dead','grateful-dead','Fire on the Mountain','fire-on-the-mountain','Shakedown Street',1978),
    ('Phish','phish','You Enjoy Myself','you-enjoy-myself','Junta',1989),
    ('Phish','phish','Farmhouse','farmhouse','Farmhouse',2000),
    ('Billy Strings','billy-strings','Dust in a Baggie','dust-in-a-baggie','Rock of Ages',2013),
    ('John Butler Trio','john-butler-trio','Ocean','ocean','John Butler',1998),
    ('John Butler Trio','john-butler-trio','Zebra','zebra','Sunrise Over Sea',2003),
    ('Dave Matthews Band','dave-matthews-band','Ants Marching','ants-marching','Under the Table and Dreaming',1994),
    ('Dave Matthews Band','dave-matthews-band','Satellite','satellite','Under the Table and Dreaming',1994),
    ('Dire Straits','dire-straits','Romeo and Juliet','romeo-and-juliet','Making Movies',1980),
    ('Dire Straits','dire-straits','Brothers in Arms','brothers-in-arms','Brothers in Arms',1985),
    ('Dire Straits','dire-straits','Walk of Life','walk-of-life','Brothers in Arms',1985),
    ('Eric Clapton','eric-clapton','Change the World','change-the-world','Phenomenon',1996),
    ('Jimi Hendrix','jimi-hendrix','Castles Made of Sand','castles-made-of-sand','Axis: Bold as Love',1967),
    ('Jimi Hendrix','jimi-hendrix','Angel','angel','The Cry of Love',1971),
    ('Blues Traveler','blues-traveler','Run-Around','run-around','Four',1994),
    ('Mason Williams','mason-williams','Classical Gas','classical-gas','The Mason Williams Phonograph Record',1968),
    ('The Band','the-band','The Weight','the-weight','Music from Big Pink',1968),
    ('Crosby, Stills, Nash & Young','crosby-stills-nash-and-young','Ohio','ohio','Ohio',1970),
    ('Steely Dan','steely-dan','Reelin'' in the Years','reelin-in-the-years','Can''t Buy a Thrill',1972),
    ('Steely Dan','steely-dan','Do It Again','do-it-again','Can''t Buy a Thrill',1972),
    ('The Doobie Brothers','the-doobie-brothers','Long Train Runnin''','long-train-runnin','The Captain and Me',1973)
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
    ('grateful-dead','ripple'),('grateful-dead','friend-of-the-devil'),('grateful-dead','casey-jones'),
    ('grateful-dead','touch-of-grey'),('grateful-dead','fire-on-the-mountain'),('phish','you-enjoy-myself'),
    ('phish','farmhouse'),('billy-strings','dust-in-a-baggie'),('john-butler-trio','ocean'),('john-butler-trio','zebra'),
    ('dave-matthews-band','ants-marching'),('dave-matthews-band','satellite'),('dire-straits','romeo-and-juliet'),
    ('dire-straits','brothers-in-arms'),('dire-straits','walk-of-life'),('eric-clapton','change-the-world'),
    ('jimi-hendrix','castles-made-of-sand'),('jimi-hendrix','angel'),('blues-traveler','run-around'),
    ('mason-williams','classical-gas'),('the-band','the-weight'),('crosby-stills-nash-and-young','ohio'),
    ('steely-dan','reelin-in-the-years'),('steely-dan','do-it-again'),('the-doobie-brothers','long-train-runnin')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('grateful-dead','ripple'),('grateful-dead','friend-of-the-devil'),('grateful-dead','casey-jones'),
    ('grateful-dead','touch-of-grey'),('grateful-dead','fire-on-the-mountain'),('phish','you-enjoy-myself'),
    ('phish','farmhouse'),('billy-strings','dust-in-a-baggie'),('john-butler-trio','ocean'),('john-butler-trio','zebra'),
    ('dave-matthews-band','ants-marching'),('dave-matthews-band','satellite'),('dire-straits','romeo-and-juliet'),
    ('dire-straits','brothers-in-arms'),('dire-straits','walk-of-life'),('eric-clapton','change-the-world'),
    ('jimi-hendrix','castles-made-of-sand'),('jimi-hendrix','angel'),('blues-traveler','run-around'),
    ('mason-williams','classical-gas'),('the-band','the-weight'),('crosby-stills-nash-and-young','ohio'),
    ('steely-dan','reelin-in-the-years'),('steely-dan','do-it-again'),('the-doobie-brothers','long-train-runnin')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('grateful-dead','ripple'),('grateful-dead','friend-of-the-devil'),('grateful-dead','casey-jones'),
    ('grateful-dead','touch-of-grey'),('grateful-dead','fire-on-the-mountain'),('phish','you-enjoy-myself'),
    ('phish','farmhouse'),('billy-strings','dust-in-a-baggie'),('john-butler-trio','ocean'),('john-butler-trio','zebra'),
    ('dave-matthews-band','ants-marching'),('dave-matthews-band','satellite'),('dire-straits','romeo-and-juliet'),
    ('dire-straits','brothers-in-arms'),('dire-straits','walk-of-life'),('eric-clapton','change-the-world'),
    ('jimi-hendrix','castles-made-of-sand'),('jimi-hendrix','angel'),('blues-traveler','run-around'),
    ('mason-williams','classical-gas'),('the-band','the-weight'),('crosby-stills-nash-and-young','ohio'),
    ('steely-dan','reelin-in-the-years'),('steely-dan','do-it-again'),('the-doobie-brothers','long-train-runnin')
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
    -- ============ GRATEFUL DEAD ============
    ('ripple','grateful-dead','guitar','main','fingerpicked pattern','acoustic','jam rock','rhythm','beginner',
     'Acoustic guitar (Jerry Garcia)','Acoustic — mic''d with mandolin','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The Dead''s gentlest gift — warm acoustic picking with Grisman''s mandolin.','Soft rolling acoustic; a psalm around a campfire.'],
     array['The picking pattern rolls like water.','Let it be known: there is a fountain.'],
     'Studio recording, 1970. The campfire psalm from American Beauty.',79),
    ('friend-of-the-devil','grateful-dead','guitar','main','fingerpicked runs','acoustic','jam rock','rhythm','intermediate',
     'Acoustic guitar (Jerry Garcia / Bob Weir)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The outlaw sprint — galloping acoustic runs with that descending bass line.','Bright driving acoustic; bluegrass bones under folk skin.'],
     array['The descending G-run intro is the calling card.','Keep the gallop light — he''s running, not fleeing.'],
     'Studio recording, 1970. The outlaw acoustic sprint.',79),
    ('casey-jones','grateful-dead','guitar','riff','main riff','clean','jam rock','rhythm','beginner',
     'Fender Stratocaster (Jerry Garcia)','Fender Twin-style, bright clean','Fender 2x12 cab','bridge pickup',
     '[]'::jsonb,'{"gain":3,"bass":4,"mids":5,"treble":8,"presence":7,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The locomotive boogie — Garcia''s glassy trebly clean chug.','Bright snappy Fender clean; the train drives itself.'],
     array['The chug pattern rides the rails.','Garcia''s fills sparkle — light touch, banjo roots.'],
     'Studio recording, 1970. The locomotive clean boogie.',79),
    ('touch-of-grey','grateful-dead','guitar','riff','main riff','clean','jam rock','lead','intermediate',
     'Custom "Tiger" guitar (Jerry Garcia)','McIntosh power, ultra-clean and enveloped','Hard Truckers cab','middle pickup with envelope filter color',
     '[{"effect_type":"filter","effect_name":"envelope filter color","placement":"front","settings":{"sensitivity":5,"mix":4}}]'::jsonb,
     '{"gain":2,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The comeback hit — Garcia''s hi-fi clean with his signature quacky envelope color.','Ultra-clean articulate rig; every note round and separate.'],
     array['The intro melody-riff is pure Garcia phrasing.','We will get by. We will survive.'],
     'Studio recording, 1987. Garcia''s hi-fi comeback lead.',79),
    ('fire-on-the-mountain','grateful-dead','guitar','riff','groove + lead','clean','jam rock','lead','intermediate',
     'Custom "Wolf" guitar (Jerry Garcia)','McIntosh power, clean with envelope filter','Hard Truckers cab','single-coil with filter',
     '[{"effect_type":"filter","effect_name":"Mu-Tron envelope filter","placement":"front","settings":{"sensitivity":6,"mix":6}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The two-chord eternal jam — Garcia''s Mu-Tron quack over the lope.','Clean with envelope filter; the quack IS the voice.'],
     array['Two chords forever; the story is in the phrasing.','Let the filter open with your pick attack.'],
     'Studio recording, 1978. Garcia''s Mu-Tron two-chord eternal.',78),

    -- ============ PHISH / BILLY STRINGS / JBT ============
    ('you-enjoy-myself','phish','guitar','riff','composed section + jam','clean','jam rock','lead','expert',
     'Languedoc custom (Trey Anastasio)','Fender Deluxe Reverbs with Tube Screamer push','Fender 2x12 cabs','humbucker',
     '[{"effect_type":"overdrive","effect_name":"stacked Tube Screamers","placement":"front","settings":{"gain":4,"level":6}},{"effect_type":"delay","effect_name":"digital delay","placement":"post_gain","settings":{"time":3,"mix":2,"feedback":2}}]'::jsonb,
     '{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":2,"master":6}'::jsonb,
     array['The Phish rite of passage — through-composed fugue into funk jam, on Trey''s singing Languedoc-into-Deluxes rig.','Warm compressed clean pushed by stacked Tube Screamers for leads.'],
     array['The composed section takes months — learn it in chunks.','Then forget everything and listen: that''s the jam.'],
     'Studio recording, 1989. The through-composed rite of passage.',78),
    ('farmhouse','phish','guitar','main','main progression','clean','jam rock','rhythm','beginner',
     'Languedoc custom (Trey Anastasio)','Fender Deluxe Reverb, warm clean','Fender 2x12 cab','humbucker',
     '[{"effect_type":"reverb","effect_name":"amp reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The gateway Phish song — warm relaxed clean strums and a singing solo (gain 4 with a Tube Screamer).','Round friendly clean; flies and barnyard optional.'],
     array['Easy strums under the verses.','The solo glides — Trey sings through the guitar.'],
     'Studio recording, 2000. The gateway farmhouse warmth.',77),
    ('dust-in-a-baggie','billy-strings','guitar','main','flatpicked bluegrass','acoustic','bluegrass','lead','expert',
     'Martin dreadnought (Billy Strings)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['The song that launched the flatpicking revival — methamphetamine ballad at bluegrass warp speed.','Dry powerful dreadnought; crosspicking fire.'],
     array['Flatpick the runs with strict alternate picking.','Speed comes months after accuracy.'],
     'Live/studio, 2013. The flatpicking-revival launcher.',77),
    ('ocean','john-butler-trio','guitar','main','fingerstyle epic','acoustic','fingerstyle','lead','expert',
     '12-string guitar, 11 strings (John Butler)','Acoustic — pickup + mic','No cab (acoustic)','piezo pickup',
     '[]'::jsonb,'{"gain":0,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":7}'::jsonb,
     array['One of YouTube''s most-watched guitar pieces — the 11-string open-C fingerstyle ocean.','Huge shimmering 12-string (minus one) in open tuning; fingerpicks and thumb slaps.'],
     array['Open C tuning; the piece breathes in movements.','Learn the waves one at a time — it''s a journey, not a lick.'],
     'Studio recording, 1998 (2012 version viral). The 11-string fingerstyle ocean.',78),
    ('zebra','john-butler-trio','guitar','riff','slide groove','crunch','roots rock','rhythm','intermediate',
     '12-string guitar (John Butler)','Tube amp, gritty roots drive','Open-back cab','piezo/mag blend',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The roots-rock strut — gritty 12-string groove with slide accents.','Warm driven jangle; busker energy at full band scale.'],
     array['The groove riff struts; slide fills answer.','Loose wrist, big smile.'],
     'Studio recording, 2003. The 12-string roots strut.',76),

    -- ============ DMB / DIRE STRAITS ============
    ('ants-marching','dave-matthews-band','guitar','riff','acoustic groove engine','acoustic','jam rock','rhythm','intermediate',
     'Taylor/Martin acoustic (Dave Matthews)','Acoustic — pickup, percussive','No cab (acoustic)','piezo pickup',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['The DMB engine — percussive acoustic riffing driving violin and sax.','Bright percussive piezo acoustic; Dave''s right hand is the drummer''s cousin.'],
     array['The riff is rhythm first — ghost notes everywhere.','Lock with the snare, not the melody.'],
     'Studio recording, 1994. The percussive acoustic engine.',78),
    ('satellite','dave-matthews-band','guitar','riff','fingerpicked figure','acoustic','jam rock','rhythm','advanced',
     'Taylor/Martin acoustic (Dave Matthews)','Acoustic — pickup','No cab (acoustic)','piezo pickup',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":7,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The orbiting figure — Dave''s crossing fingerpicked pattern that started as a finger exercise.','Clear bright acoustic; the pattern loops like its title.'],
     array['The stretchy pattern crosses strings — slow practice.','Once it loops, it flies itself.'],
     'Studio recording, 1994. The orbiting finger-exercise figure.',78),
    ('romeo-and-juliet','dire-straits','guitar','main','resonator fingerpicking','acoustic','rock','rhythm','intermediate',
     'National Style O resonator (Mark Knopfler)','Acoustic resonator — mic''d','No cab (acoustic)','n/a (resonator)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Knopfler''s streetlight serenade — open-G fingerpicking on the shimmering National resonator.','Metallic warm resonator voice; fingertips only, no pick.'],
     array['Open G tuning; thumb and fingers weave the intro.','Phrase it like dialogue — he''s talking to her.'],
     'Studio recording, 1980. Knopfler''s National resonator serenade.',80),
    ('brothers-in-arms','dire-straits','guitar','solo','ambient lead','clean','rock','lead','intermediate',
     'Gibson Les Paul (Mark Knopfler)','Clean amp with ambient wash','Closed-back cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"large hall reverb","placement":"post_gain","settings":{"mix":5,"decay":7}},{"effect_type":"delay","effect_name":"ambient delay","placement":"post_gain","settings":{"time":4,"mix":3,"feedback":3}}]'::jsonb,
     '{"gain":3,"bass":5,"mids":6,"treble":5,"presence":4,"reverb":5,"delay":3,"master":6}'::jsonb,
     array['The battlefield elegy — Knopfler''s fingerpicked Les Paul crying in fog.','Warm neck-pickup near-clean in deep ambience; every note weighed.'],
     array['Fingerpick the lead lines — the flesh tone is the sound.','Say more with fewer notes than feels possible.'],
     'Studio recording, 1985. The battlefield elegy lead.',80),
    ('walk-of-life','dire-straits','guitar','riff','main riff','clean','rock','rhythm','beginner',
     'Fender Stratocaster/Schecter (Mark Knopfler)','Clean amp, bouncing rockabilly clean','Fender combo cab','in-between pickup position',
     '[{"effect_type":"compressor","effect_name":"light compression","placement":"front","settings":{"sustain":4,"level":5}}]'::jsonb,
     '{"gain":2,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The organ-hook companion — Knopfler''s bouncing fingerpicked clean.','Quacky in-between Strat clean; joy in every double-stop.'],
     array['Fingerpick the rockabilly figure — no pick.','Bounce it like a busker in the underground.'],
     'Studio recording, 1985. The bouncing busker''s companion.',79),

    -- ============ LEGENDS' SECOND TIER ============
    ('change-the-world','eric-clapton','guitar','main','fingerpicked pop-blues','acoustic','pop rock','rhythm','intermediate',
     'Acoustic guitar (Eric Clapton)','Acoustic — mic''d, Babyface production','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The Phenomenon hit — silky acoustic fingerpicking with pop-soul polish.','Warm smooth acoustic; the turnarounds are pure EC.'],
     array['Fingerpick the riff with blues grace notes.','Understate everything.'],
     'Studio recording, 1996. The silky pop-blues hit.',78),
    ('castles-made-of-sand','jimi-hendrix','guitar','riff','clean R&B figures','clean','rock','rhythm','advanced',
     'Fender Stratocaster (Jimi Hendrix)','Fender/Marshall clean, warm','Marshall 4x12 cab','neck pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Jimi''s Curtis Mayfield side — sliding double-stop clean figures, thumb-over chording.','Warm neck-pickup clean; melody and rhythm in one hand.'],
     array['Thumb frets the bass while fingers slide the doubles.','The backwards solo you can''t copy — improvise your own dream.'],
     'Studio recording, 1967. Jimi''s sliding R&B masterclass.',80),
    ('angel','jimi-hendrix','guitar','riff','clean ballad figures','clean','rock','rhythm','intermediate',
     'Fender Stratocaster (Jimi Hendrix)','Fender/Marshall clean, warm','Marshall 4x12 cab','neck pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":5,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The posthumous lullaby — warm chordal embellishments around the melody.','Soft neck-pickup clean; hymn-like patience.'],
     array['Every chord gets a small melodic gift.','Play it like a promise kept late.'],
     'Studio recording, 1971. The posthumous lullaby.',79),
    ('run-around','blues-traveler','guitar','riff','jangle engine','clean','roots rock','rhythm','beginner',
     'Fender Telecaster (Chan Kinchla)','Clean amp, bright jangle','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":3,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The harmonica-hit engine — driving bright jangle under Popper''s runs.','Crisp clean strums at busking-sprint pace.'],
     array['G-C-Am-D forever at speed.','You''re the road; the harmonica is the car.'],
     'Studio recording, 1994. The harmonica-hit jangle engine.',76),
    ('classical-gas','mason-williams','guitar','lead','classical fingerstyle','acoustic','instrumental','lead','advanced',
     'Nylon-string classical (Mason Williams)','Acoustic — mic''d with orchestra','No cab (acoustic)','n/a (classical)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":0,"master":7}'::jsonb,
     array['The most-broadcast instrumental ever — galloping classical fingerstyle with orchestra hits.','Clear nylon articulation; the accelerating gallop is the thrill.'],
     array['Learn the arpeggio engine slow; the gallop comes later.','The orchestra stabs live in your accents now.'],
     'Studio recording, 1968. The most-broadcast guitar instrumental.',79),
    ('the-weight','the-band','guitar','main','main progression','acoustic','roots rock','rhythm','beginner',
     'Acoustic + Telecaster (Robbie Robertson)','Acoustic + small tube amp','Small combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The Americana cornerstone — acoustic strums with Telecaster curls between lines.','Warm woody acoustic; take a load off.'],
     array['The intro figure descends into the first verse.','Every voice in the room joins the chorus — leave space.'],
     'Studio recording, 1968. The Americana cornerstone.',79),
    ('ohio','crosby-stills-nash-and-young','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Gibson Les Paul (Neil Young / Stephen Stills)','Tube amp, raw protest crunch','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":5,"presence":4,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The four-dead-in-Ohio dirge — raw Dm-F-C riff cut days after Kent State.','Warm angry crunch; grief at full volume.'],
     array['The riff tolls — heavy and even.','Recorded in one furious session; play it that way.'],
     'Studio recording, 1970. The Kent State protest dirge.',79),
    ('reelin-in-the-years','steely-dan','guitar','solo','twin leads + rhythm','crunch','rock','lead','advanced',
     'Gibson SG (Elliott Randall, session)','Tube amp, singing crunch','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":4,"mids":7,"treble":7,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['Elliott Randall''s legendary session solo (reportedly Jimmy Page''s favorite) — singing sustained crunch.','Bright mid-rich drive; the solo flows like it''s laughing.'],
     array['The solo phrases fall over the barline — learn the swing.','One take, they say. Aim for that spirit.'],
     'Studio recording, 1972. Randall''s legendary one-take solo.',79),
    ('do-it-again','steely-dan','guitar','riff','groove comping + solo','clean','rock','rhythm','intermediate',
     'Fender/Gibson electric (Denny Dias / Jeff Baxter)','Clean amp, jazzy groove','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The wheel-turning groove — jazzy clean comping (the famous solo is electric sitar; adapt with a bright neck-pickup tone).','Round clean groove; precision with a shrug.'],
     array['Comp the minor vamp hypnotically.','The sitar solo translates to guitar with legato slides.'],
     'Studio recording, 1972. The wheel-turning jazz-rock groove.',78),
    ('long-train-runnin','the-doobie-brothers','guitar','riff','funk strum engine','clean','rock','rhythm','intermediate',
     'Gibson/Fender electric (Tom Johnston)','Clean amp, percussive funk strums','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The muted-strum masterclass — Johnston''s sixteenth-note funk engine.','Bright percussive clean; the mute-strum groove IS the song.'],
     array['Sixteenth-note strums with constant left-hand muting.','Without love, where would you be now? Practicing this groove.'],
     'Studio recording, 1973. The muted funk-strum masterclass.',79)
) as c(
  song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence
)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;
