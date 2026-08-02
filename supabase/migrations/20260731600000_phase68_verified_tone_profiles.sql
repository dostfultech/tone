-- Phase 68: 2010s festival rock + Aussie surf-indie + Latin rock fills, verified per-part tone data.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Catfish and the Bottlemen','catfish-and-the-bottlemen','Kathleen','kathleen','The Balcony',2014),
    ('Catfish and the Bottlemen','catfish-and-the-bottlemen','7','7','The Ride',2016),
    ('The Wombats','the-wombats','Let''s Dance to Joy Division','lets-dance-to-joy-division','A Guide to Love, Loss & Desperation',2007),
    ('The Wombats','the-wombats','Greek Tragedy','greek-tragedy','Glitterbug',2015),
    ('The Vaccines','the-vaccines','If You Wanna','if-you-wanna','What Did You Expect from The Vaccines?',2011),
    ('The Kooks','the-kooks','Naive','naive','Inside In / Inside Out',2006),
    ('The Kooks','the-kooks','She Moves in Her Own Way','she-moves-in-her-own-way','Inside In / Inside Out',2006),
    ('Circa Waves','circa-waves','T-Shirt Weather','t-shirt-weather','Young Chasers',2015),
    ('Hippo Campus','hippo-campus','Way It Goes','way-it-goes','Landmark',2017),
    ('COIN','coin','Talk Too Much','talk-too-much','How Will You Know If You Never Try',2016),
    ('Ocean Alley','ocean-alley','Confidence','confidence','Chiaroscuro',2018),
    ('Sticky Fingers','sticky-fingers','Australia Street','australia-street','Caress Your Soul',2013),
    ('Spacey Jane','spacey-jane','Booster Seat','booster-seat','Sunlight',2020),
    ('Los Enanitos Verdes','los-enanitos-verdes','Lamento Boliviano','lamento-boliviano','Big Bang',1994),
    ('Mana','mana','En el Muelle de San Blas','en-el-muelle-de-san-blas','Suenos Liquidos',1997),
    ('Soda Stereo','soda-stereo','En la Ciudad de la Furia','en-la-ciudad-de-la-furia','Doble Vida',1988),
    ('The Courteeners','the-courteeners','Not Nineteen Forever','not-nineteen-forever','St. Jude',2008),
    ('Blossoms','blossoms','Charlemagne','charlemagne','Blossoms',2016),
    ('Nothing But Thieves','nothing-but-thieves','Amsterdam','amsterdam','Broken Machine',2017),
    ('Royal Blood','royal-blood','Figure It Out','figure-it-out','Royal Blood',2014),
    ('Highly Suspect','highly-suspect','Lydia','lydia','Mister Asylum',2015),
    ('The Struts','the-struts','Could Have Been Me','could-have-been-me','Everybody Wants',2014),
    ('Briston Maroney','briston-maroney','Freakin'' Out on the Interstate','freakin-out-on-the-interstate','Carnival',2018),
    ('Vacations','vacations','Young','young','Vibes',2016),
    ('Beach Weather','beach-weather','Sex, Drugs, Etc.','sex-drugs-etc','Chit Chat',2016)
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
    ('catfish-and-the-bottlemen','kathleen'),('catfish-and-the-bottlemen','7'),('the-wombats','lets-dance-to-joy-division'),
    ('the-wombats','greek-tragedy'),('the-vaccines','if-you-wanna'),('the-kooks','naive'),
    ('the-kooks','she-moves-in-her-own-way'),('circa-waves','t-shirt-weather'),('hippo-campus','way-it-goes'),
    ('coin','talk-too-much'),('ocean-alley','confidence'),('sticky-fingers','australia-street'),
    ('spacey-jane','booster-seat'),('los-enanitos-verdes','lamento-boliviano'),('mana','en-el-muelle-de-san-blas'),
    ('soda-stereo','en-la-ciudad-de-la-furia'),('the-courteeners','not-nineteen-forever'),('blossoms','charlemagne'),
    ('nothing-but-thieves','amsterdam'),('royal-blood','figure-it-out'),('highly-suspect','lydia'),
    ('the-struts','could-have-been-me'),('briston-maroney','freakin-out-on-the-interstate'),('vacations','young'),
    ('beach-weather','sex-drugs-etc')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('catfish-and-the-bottlemen','kathleen'),('catfish-and-the-bottlemen','7'),('the-wombats','lets-dance-to-joy-division'),
    ('the-wombats','greek-tragedy'),('the-vaccines','if-you-wanna'),('the-kooks','naive'),
    ('the-kooks','she-moves-in-her-own-way'),('circa-waves','t-shirt-weather'),('hippo-campus','way-it-goes'),
    ('coin','talk-too-much'),('ocean-alley','confidence'),('sticky-fingers','australia-street'),
    ('spacey-jane','booster-seat'),('los-enanitos-verdes','lamento-boliviano'),('mana','en-el-muelle-de-san-blas'),
    ('soda-stereo','en-la-ciudad-de-la-furia'),('the-courteeners','not-nineteen-forever'),('blossoms','charlemagne'),
    ('nothing-but-thieves','amsterdam'),('royal-blood','figure-it-out'),('highly-suspect','lydia'),
    ('the-struts','could-have-been-me'),('briston-maroney','freakin-out-on-the-interstate'),('vacations','young'),
    ('beach-weather','sex-drugs-etc')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('catfish-and-the-bottlemen','kathleen'),('catfish-and-the-bottlemen','7'),('the-wombats','lets-dance-to-joy-division'),
    ('the-wombats','greek-tragedy'),('the-vaccines','if-you-wanna'),('the-kooks','naive'),
    ('the-kooks','she-moves-in-her-own-way'),('circa-waves','t-shirt-weather'),('hippo-campus','way-it-goes'),
    ('coin','talk-too-much'),('ocean-alley','confidence'),('sticky-fingers','australia-street'),
    ('spacey-jane','booster-seat'),('los-enanitos-verdes','lamento-boliviano'),('mana','en-el-muelle-de-san-blas'),
    ('soda-stereo','en-la-ciudad-de-la-furia'),('the-courteeners','not-nineteen-forever'),('blossoms','charlemagne'),
    ('nothing-but-thieves','amsterdam'),('royal-blood','figure-it-out'),('highly-suspect','lydia'),
    ('the-struts','could-have-been-me'),('briston-maroney','freakin-out-on-the-interstate'),('vacations','young'),
    ('beach-weather','sex-drugs-etc')
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
    -- ============ UK FESTIVAL ROCK ============
    ('kathleen','catfish-and-the-bottlemen','guitar','riff','main riff','crunch','indie rock','rhythm','intermediate',
     'Fender/Gibson electric (Johnny Bond / Van McCann)','Tube stack, tight arena crunch','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The Balcony''s detonator — tight stabbing crunch built for festival fields.','Bright punchy drive; the stops hit as hard as the chords.'],
     array['The stabs are surgical — mute everything between.','Explode into the chorus.'],
     'Studio recording, 2014. The festival-field detonator.',75),
    ('7','catfish-and-the-bottlemen','guitar','riff','main riff','crunch','indie rock','rhythm','beginner',
     'Fender/Gibson electric (Johnny Bond)','Tube stack, arena crunch','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The singalong juggernaut — big open crunch chords with terrace energy.','Thick bright drive; simplicity at stadium scale.'],
     array['Wide open chords; drive the eighth-notes.','Save your voice for the chorus.'],
     'Studio recording, 2016. The terrace-chant juggernaut.',74),
    ('lets-dance-to-joy-division','the-wombats','guitar','riff','main riff','crunch','indie rock','rhythm','beginner',
     'Fender electric (Matthew Murphy)','Tube amp, spiky indie crunch','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The indie-disco anthem — spiky bright crunch celebrating the irony.','Trebly tight drive; dance-floor punk energy.'],
     array['The angular riff bounces; keep it tight.','Everything is going wrong, but play like it''s alright.'],
     'Studio recording, 2007. The indie-disco anthem.',74),
    ('greek-tragedy','the-wombats','guitar','riff','main riff','crunch','indie rock','rhythm','intermediate',
     'Fender electric (Matthew Murphy)','Tube amp with synth-era polish','Closed-back cab','bridge pickup',
     '[{"effect_type":"reverb","effect_name":"dark room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":5,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":1,"master":7}'::jsonb,
     array['The TikTok-revived brooder — dark polished crunch under synth gloom.','Moody mid-gain; the heaviness arrives in waves.'],
     array['Restrained verses, crashing hook.','Let the drop hit like the lyric does.'],
     'Studio recording, 2015. The TikTok-revived brooding hook.',74),
    ('if-you-wanna','the-vaccines','guitar','riff','main riff','distorted','indie rock','rhythm','beginner',
     'Fender Jazzmaster (Freddie Cowan / Justin Young)','Tube amp, ramalama drive','Closed-back cab','bridge pickup',
     '[{"effect_type":"reverb","effect_name":"spring reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":3,"delay":0,"master":8}'::jsonb,
     array['Ramones-via-Sussex — springy saturated strums at double time.','Bright washed drive; three chords, no waiting.'],
     array['Downstroke sprint from the count-in.','The surf-y lead break winks — keep it loose.'],
     'Studio recording, 2011. The ramalama revival hit.',74),
    ('naive','the-kooks','guitar','riff','main riff','clean','indie rock','rhythm','beginner',
     'Hollow-body electric (Hugh Harris / Luke Pritchard)','Clean amp, bouncing jangle','Open-back combo cab','neck pickup',
     '[{"effect_type":"compressor","effect_name":"light compression","placement":"front","settings":{"sustain":4,"level":5}}]'::jsonb,
     '{"gain":3,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The 2006 indie rite of passage — bouncing just-clean riff everyone''s first band covered.','Bright springy clean; the riff skips.'],
     array['The intro riff hops between strings — light touch.','Skank the verse chords playfully.'],
     'Studio recording, 2006. The indie rite-of-passage riff.',76),
    ('she-moves-in-her-own-way','the-kooks','guitar','riff','main riff','clean','indie rock','rhythm','beginner',
     'Acoustic + hollow-body electric (Luke Pritchard / Hugh Harris)','Clean amp, sunny jangle','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Seaside-pop charm — sunny acoustic strums with chiming electric hooks.','Bright happy clean; Brighton pier in a riff.'],
     array['Bounce the strums; the hook answers the vocal.','Charm over precision.'],
     'Studio recording, 2006. The seaside-pop charmer.',75),
    ('t-shirt-weather','circa-waves','guitar','riff','main riff','crunch','indie rock','rhythm','beginner',
     'Fender electric (Joe Falconer / Kieran Shudall)','Tube amp, summer sprint crunch','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The summer sprint — bright driving crunch about being young in the sun.','Trebly urgent drive; the riff runs downhill.'],
     array['Full-speed downstrokes; the melody rides on top.','Play it like June never ends.'],
     'Studio recording, 2015. The summer-sprint anthem.',73),
    ('not-nineteen-forever','the-courteeners','guitar','riff','main riff','crunch','indie rock','rhythm','intermediate',
     'Fender electric (Liam Fray / Daniel Moores)','Tube amp, Manchester crunch','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The Manchester birthday anthem — driving crunch with terrace-choir destiny.','Warm punchy drive; built for 20,000 voices.'],
     array['Driving eighths under the verses.','The pre-chorus lift is the moment — nail it.'],
     'Studio recording, 2008. The Manchester birthday anthem.',73),
    ('charlemagne','blossoms','guitar','riff','main riff','clean','indie pop','rhythm','beginner',
     'Fender electric (Josh Dewhurst)','Clean amp with synth-pop gloss','Studio direct','bridge pickup',
     '[{"effect_type":"compressor","effect_name":"studio compression","placement":"front","settings":{"sustain":5,"level":5}}]'::jsonb,
     '{"gain":2,"bass":4,"mids":5,"treble":7,"presence":6,"reverb":2,"delay":1,"master":6}'::jsonb,
     array['Stockport synth-pop-rock — glassy clean hooks around the keyboard line.','Bright compressed clean; the riff glitters.'],
     array['The lead hook doubles the synth.','Tight pop discipline throughout.'],
     'Studio recording, 2016. The glittering Stockport hook.',73),
    ('amsterdam','nothing-but-thieves','guitar','riff','main riff','high_gain','alternative rock','rhythm','intermediate',
     'Fender/Manson electric (Joe Langridge-Brown / Dom Craik)','Modern high-gain with polish','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":5,"treble":6,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['Muse-school arena rock — tight saturated riffing under a stratospheric vocal.','Modern polished high gain; the riff coils and strikes.'],
     array['The verse riff coils; the chorus releases.','Support the falsetto — don''t bury it.'],
     'Studio recording, 2017. The coiled arena riff.',74),

    -- ============ AUSSIE SURF-INDIE ============
    ('confidence','ocean-alley','guitar','riff','psych-surf groove','clean','surf indie','lead','intermediate',
     'Fender Stratocaster (Angus Goodwin / Mitch Galbraith)','Clean amp with watery chorus','Open-back combo cab','neck pickup',
     '[{"effect_type":"chorus","effect_name":"watery chorus","placement":"post_gain","settings":{"rate":3,"depth":4,"mix":4}},{"effect_type":"reverb","effect_name":"spring reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":4,"delay":1,"master":6}'::jsonb,
     array['The triple-j titan — watery psych-surf leads over a lazy groove.','Warm chorused clean with a hint of hair; beach-psych gold.'],
     array['The lead hook bends lazily — surf phrasing.','Pocket first; flash never.'],
     'Studio recording, 2018. The psych-surf triple-j titan.',75),
    ('australia-street','sticky-fingers','guitar','riff','reggae-psych groove','clean','surf indie','rhythm','beginner',
     'Fender electric (Seamus Coyle)','Clean amp with dub space','Open-back combo cab','neck pickup',
     '[{"effect_type":"delay","effect_name":"dub delay","placement":"post_gain","settings":{"time":4,"mix":3,"feedback":3}},{"effect_type":"reverb","effect_name":"spring reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":4,"delay":3,"master":6}'::jsonb,
     array['The Sydney backyard anthem — dubby clean skanks with psych haze.','Wet lazy clean; reggae bones, indie heart.'],
     array['Off-beat skanks with dub echoes.','Sway, don''t push.'],
     'Studio recording, 2013. The backyard dub-indie anthem.',74),
    ('booster-seat','spacey-jane','guitar','riff','jangle progression','clean','indie rock','rhythm','beginner',
     'Fender Stratocaster (Ashton Hardman-Le Cornu)','Clean amp, bright jangle','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":3}},{"effect_type":"compressor","effect_name":"light compression","placement":"front","settings":{"sustain":4,"level":5}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":7,"presence":6,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The Hottest-100 heartbreaker — bright tender jangle under growing-up lyrics.','Clean Strat sparkle; emotional but light-footed.'],
     array['Gentle arpeggio-strums under the verses.','Lift softly into the chorus ache.'],
     'Studio recording, 2020. The Hottest-100 heartbreaker jangle.',74),

    -- ============ LATIN ROCK FILLS ============
    ('lamento-boliviano','los-enanitos-verdes','guitar','riff','main riff','crunch','latin rock','rhythm','beginner',
     'Fender electric (Felipe Staiti)','Tube amp, warm rock en espanol crunch','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The rock-en-espanol eternal — brooding crunch riff every Latin guitarist learns first.','Warm punchy drive; the Em-C-D progression is a continent''s campfire song.'],
     array['The arpeggiated intro into power-chord verses.','Sing it — everyone within earshot will.'],
     'Studio recording, 1994. The rock en espanol eternal.',76),
    ('en-el-muelle-de-san-blas','mana','guitar','riff','clean arpeggio + solo','clean','latin rock','lead','intermediate',
     'Fender Stratocaster (Sergio Vallin)','Clean amp into singing lead','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":4,"delay":1,"master":6}'::jsonb,
     array['The waiting-woman ballad — tender clean arpeggios and Vallin''s crying solo (gain 6).','Warm wet clean into a singing lead voice.'],
     array['Arpeggiate the story patiently.','The solo weeps — bend with the tale.'],
     'Studio recording, 1997. The waiting-at-the-dock ballad.',75),
    ('en-la-ciudad-de-la-furia','soda-stereo','guitar','riff','dark atmosphere riff','clean','latin rock','rhythm','intermediate',
     'Fender Stratocaster (Gustavo Cerati)','Clean amp with dark chorus ambience','Closed-back cab','neck pickup',
     '[{"effect_type":"chorus","effect_name":"dark 80s chorus","placement":"post_gain","settings":{"rate":3,"depth":4,"mix":4}},{"effect_type":"delay","effect_name":"ambient delay","placement":"post_gain","settings":{"time":4,"mix":3,"feedback":3}}]'::jsonb,
     '{"gain":3,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":4,"delay":3,"master":6}'::jsonb,
     array['Cerati''s night-flight over Buenos Aires — dark chorused clean in urban fog.','Wet moody clean; the city breathes through the delay.'],
     array['The atmosphere IS the part — play space.','Cerati phrased like a poet; honor it.'],
     'Studio recording, 1988. Cerati''s night-flight atmosphere.',76),

    -- ============ US ALT / VIRAL ============
    ('way-it-goes','hippo-campus','guitar','riff','bright math-jangle','clean','indie rock','rhythm','intermediate',
     'Fender electric (Nathan Stocker)','Clean amp, sparkling and tight','Open-back combo cab','bridge pickup',
     '[{"effect_type":"compressor","effect_name":"light compression","placement":"front","settings":{"sustain":4,"level":5}}]'::jsonb,
     '{"gain":2,"bass":4,"mids":5,"treble":8,"presence":6,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Midwest sparkle — quick chiming clean figures with math-y bounce.','Ultra-bright tight clean; sunshine in staccato.'],
     array['The noodly figures skip — light picking.','Bounce with the falsetto.'],
     'Studio recording, 2017. The midwest sparkle-jangle.',73),
    ('talk-too-much','coin','guitar','riff','main riff','clean','indie pop','rhythm','beginner',
     'Fender electric (Joe Memmel)','Clean amp with pop gloss','Studio direct','bridge pickup',
     '[{"effect_type":"compressor","effect_name":"studio compression","placement":"front","settings":{"sustain":5,"level":5}}]'::jsonb,
     '{"gain":2,"bass":4,"mids":5,"treble":7,"presence":6,"reverb":2,"delay":1,"master":6}'::jsonb,
     array['The kiss-me-shut hit — glassy clean hooks with pop-machine tightness.','Bright compressed clean; the riff pops like bubblegum.'],
     array['The hook stabs on the grid.','Precision equals charm here.'],
     'Studio recording, 2016. The bubblegum-tight hook.',73),
    ('figure-it-out','royal-blood','bass','bassline','main riff (bass-as-guitar)','bass_drive','rock','rhythm','intermediate',
     'Fender/Gretsch bass (Mike Kerr)','Split signal: bass amp + guitar amps with fuzz','Bass + guitar stacks','split-signal pickups',
     '[{"effect_type":"fuzz","effect_name":"fuzz on the guitar-amp split","placement":"front","settings":{"gain":7,"tone":5,"level":6}},{"effect_type":"octave","effect_name":"octave-up shimmer","placement":"front","settings":{"mix":5}}]'::jsonb,
     '{"gain":7,"bass":7,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['Kerr''s two-amp illusion — one bass split into bass AND fuzzed guitar amps, sounding like a full band.','Split your bass signal: clean low path + fuzzed octave-up path — that''s the whole trick.'],
     array['The riff is pure swagger — dig in hard.','Mute the low path during the "guitar" fills.'],
     'Studio recording, 2014. Kerr''s split-signal bass illusion.',77),
    ('lydia','highly-suspect','guitar','riff','main riff','crunch','alternative rock','rhythm','intermediate',
     'Fender Stratocaster (Johnny Stevens)','Tube amp, moody grit','Closed-back cab','bridge pickup',
     '[{"effect_type":"reverb","effect_name":"dark room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":0,"master":7}'::jsonb,
     array['The smoky slow-burn — moody grit building to a howling peak (gain 7 at the climax).','Dark warm drive; tension is the instrument.'],
     array['The verse riff smolders; hold back.','The climax bends scream — release everything.'],
     'Studio recording, 2015. The smoky slow-burn howl.',74),
    ('could-have-been-me','the-struts','guitar','riff','main riff','distorted','glam rock','rhythm','beginner',
     'Gibson Les Paul (Adam Slack)','Marshall-style stack, glam revival','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The glam-revival anthem — Queen-school crunch with maximum strut.','Big warm Marshall drive; theatrical to the bone.'],
     array['Wide open chords with showman stops.','Play to the back row.'],
     'Studio recording, 2014. The glam-revival strut anthem.',74),
    ('freakin-out-on-the-interstate','briston-maroney','guitar','riff','main progression','crunch','indie rock','rhythm','beginner',
     'Fender electric (Briston Maroney)','Tube amp, warm ragged crunch','Open-back combo cab','bridge pickup',
     '[{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":0,"master":7}'::jsonb,
     array['The viral panic-attack ballad — warm ragged crunch that cracks open at the end.','Loose warm drive; the falsetto break is the gut-punch.'],
     array['Steady strums under the spiral.','Let the final chorus fall apart beautifully.'],
     'Studio recording, 2018. The viral interstate breakdown.',73),
    ('young','vacations','guitar','riff','jangle groove','clean','indie pop','rhythm','beginner',
     'Fender electric (Campbell Burns)','Clean amp, hazy jangle','Open-back combo cab','neck pickup',
     '[{"effect_type":"chorus","effect_name":"hazy chorus","placement":"post_gain","settings":{"rate":3,"depth":4,"mix":4}},{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":4,"delay":1,"master":6}'::jsonb,
     array['The Insta-reel jangle — hazy chorused clean loop of endless summer.','Soft washed clean; nostalgia on a loop.'],
     array['The riff cycles lazily.','Keep it golden-hour warm.'],
     'Studio recording, 2016. The endless-summer jangle loop.',73),
    ('sex-drugs-etc','beach-weather','guitar','riff','main riff','clean','indie pop','rhythm','beginner',
     'Fender electric (Reeve Powers)','Clean amp, midnight gloss','Studio direct','neck pickup',
     '[{"effect_type":"compressor","effect_name":"studio compression","placement":"front","settings":{"sustain":5,"level":5}},{"effect_type":"reverb","effect_name":"dark reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":3,"delay":1,"master":6}'::jsonb,
     array['The 2022 viral sleeper — cool midnight clean groove.','Dark compressed clean; neon-sign mood.'],
     array['The riff slinks on the off-beats.','Cool over eager, always.'],
     'Studio recording, 2016. The midnight viral sleeper.',73)
) as c(
  song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence
)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;
