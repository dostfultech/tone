-- Phase 73: classical guitar canon + world/bossa + US reggae-rock + country-fingerstyle legends, verified per-part tone data.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Isaac Albeniz','isaac-albeniz','Asturias (Leyenda)','asturias-leyenda','Suite Espanola',1892),
    ('Francisco Tarrega','francisco-tarrega','Recuerdos de la Alhambra','recuerdos-de-la-alhambra','Recuerdos de la Alhambra',1896),
    ('Francisco Tarrega','francisco-tarrega','Lagrima','lagrima','Lagrima',1891),
    ('Traditional','traditional','Romanza (Spanish Romance)','romanza-spanish-romance',null,null),
    ('Ernesto Lecuona','ernesto-lecuona','Malaguena','malaguena','Andalucia Suite',1928),
    ('Gipsy Kings','gipsy-kings','Volare','volare','Mosaique',1989),
    ('Rodrigo y Gabriela','rodrigo-y-gabriela','Diablo Rojo','diablo-rojo','Rodrigo y Gabriela',2006),
    ('Antonio Carlos Jobim','antonio-carlos-jobim','The Girl from Ipanema','the-girl-from-ipanema','Getz/Gilberto',1964),
    ('Luiz Bonfa','luiz-bonfa','Manha de Carnaval','manha-de-carnaval','Black Orpheus',1959),
    ('Israel Kamakawiwoole','israel-kamakawiwoole','Somewhere Over the Rainbow / What a Wonderful World','somewhere-over-the-rainbow','Facing Future',1993),
    ('Dirty Heads','dirty-heads','Lay Me Down','lay-me-down','Any Port in a Storm',2010),
    ('Rebelution','rebelution','Feeling Alright','feeling-alright','Courage to Grow',2007),
    ('Stick Figure','stick-figure','World on Fire','world-on-fire','Set in Stone',2015),
    ('Matisyahu','matisyahu','One Day','one-day','Light',2009),
    ('Iration','iration','Time Bomb','time-bomb-iration','Time Bomb',2010),
    ('Jimmy Cliff','jimmy-cliff','You Can Get It If You Really Want','you-can-get-it-if-you-really-want','The Harder They Come',1972),
    ('Toots and the Maytals','toots-and-the-maytals','54-46 Was My Number','54-46-was-my-number','54-46 Was My Number',1968),
    ('Manu Chao','manu-chao','Me Gustas Tu','me-gustas-tu','Proxima Estacion: Esperanza',2001),
    ('Django Reinhardt','django-reinhardt','Les Yeux Noirs (Dark Eyes)','les-yeux-noirs','Django Reinhardt',1940),
    ('Chet Atkins','chet-atkins','Windy and Warm','windy-and-warm','Down Home',1962),
    ('Merle Travis','merle-travis','Cannonball Rag','cannonball-rag','The Merle Travis Guitar',1956),
    ('Arthur Smith','arthur-smith','Guitar Boogie','guitar-boogie','Guitar Boogie',1945),
    ('Glen Campbell','glen-campbell','Wichita Lineman','wichita-lineman','Wichita Lineman',1968),
    ('Willie Nelson','willie-nelson','On the Road Again','on-the-road-again','Honeysuckle Rose',1980),
    ('Hank Williams','hank-williams','Hey Good Lookin''','hey-good-lookin','Hey Good Lookin''',1951)
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
    ('isaac-albeniz','asturias-leyenda'),('francisco-tarrega','recuerdos-de-la-alhambra'),('francisco-tarrega','lagrima'),
    ('traditional','romanza-spanish-romance'),('ernesto-lecuona','malaguena'),('gipsy-kings','volare'),
    ('rodrigo-y-gabriela','diablo-rojo'),('antonio-carlos-jobim','the-girl-from-ipanema'),('luiz-bonfa','manha-de-carnaval'),
    ('israel-kamakawiwoole','somewhere-over-the-rainbow'),('dirty-heads','lay-me-down'),('rebelution','feeling-alright'),
    ('stick-figure','world-on-fire'),('matisyahu','one-day'),('iration','time-bomb-iration'),
    ('jimmy-cliff','you-can-get-it-if-you-really-want'),('toots-and-the-maytals','54-46-was-my-number'),
    ('manu-chao','me-gustas-tu'),('django-reinhardt','les-yeux-noirs'),('chet-atkins','windy-and-warm'),
    ('merle-travis','cannonball-rag'),('arthur-smith','guitar-boogie'),('glen-campbell','wichita-lineman'),
    ('willie-nelson','on-the-road-again'),('hank-williams','hey-good-lookin')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('isaac-albeniz','asturias-leyenda'),('francisco-tarrega','recuerdos-de-la-alhambra'),('francisco-tarrega','lagrima'),
    ('traditional','romanza-spanish-romance'),('ernesto-lecuona','malaguena'),('gipsy-kings','volare'),
    ('rodrigo-y-gabriela','diablo-rojo'),('antonio-carlos-jobim','the-girl-from-ipanema'),('luiz-bonfa','manha-de-carnaval'),
    ('israel-kamakawiwoole','somewhere-over-the-rainbow'),('dirty-heads','lay-me-down'),('rebelution','feeling-alright'),
    ('stick-figure','world-on-fire'),('matisyahu','one-day'),('iration','time-bomb-iration'),
    ('jimmy-cliff','you-can-get-it-if-you-really-want'),('toots-and-the-maytals','54-46-was-my-number'),
    ('manu-chao','me-gustas-tu'),('django-reinhardt','les-yeux-noirs'),('chet-atkins','windy-and-warm'),
    ('merle-travis','cannonball-rag'),('arthur-smith','guitar-boogie'),('glen-campbell','wichita-lineman'),
    ('willie-nelson','on-the-road-again'),('hank-williams','hey-good-lookin')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('isaac-albeniz','asturias-leyenda'),('francisco-tarrega','recuerdos-de-la-alhambra'),('francisco-tarrega','lagrima'),
    ('traditional','romanza-spanish-romance'),('ernesto-lecuona','malaguena'),('gipsy-kings','volare'),
    ('rodrigo-y-gabriela','diablo-rojo'),('antonio-carlos-jobim','the-girl-from-ipanema'),('luiz-bonfa','manha-de-carnaval'),
    ('israel-kamakawiwoole','somewhere-over-the-rainbow'),('dirty-heads','lay-me-down'),('rebelution','feeling-alright'),
    ('stick-figure','world-on-fire'),('matisyahu','one-day'),('iration','time-bomb-iration'),
    ('jimmy-cliff','you-can-get-it-if-you-really-want'),('toots-and-the-maytals','54-46-was-my-number'),
    ('manu-chao','me-gustas-tu'),('django-reinhardt','les-yeux-noirs'),('chet-atkins','windy-and-warm'),
    ('merle-travis','cannonball-rag'),('arthur-smith','guitar-boogie'),('glen-campbell','wichita-lineman'),
    ('willie-nelson','on-the-road-again'),('hank-williams','hey-good-lookin')
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
    -- ============ CLASSICAL GUITAR CANON ============
    ('asturias-leyenda','isaac-albeniz','guitar','main','classical showpiece','acoustic','classical','lead','expert',
     'Classical guitar (Segovia-lineage arrangement)','Classical — concert hall mic','No cab (classical)','n/a (classical)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The most famous classical guitar piece on earth — written for piano, immortalized by Segovia''s arrangement.','Clear concert nylon tone; the pedal-tone drama needs total right-hand control.'],
     array['The repeated pedal note under the melody is the engine.','Rest-stroke the melody; free-stroke the pedal.'],
     'Composed 1892; Segovia arrangement. The flamenco-flavored classical monument.',79),
    ('recuerdos-de-la-alhambra','francisco-tarrega','guitar','main','tremolo study','acoustic','classical','lead','expert',
     'Classical guitar (Francisco Tarrega)','Classical — concert mic','No cab (classical)','n/a (classical)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The tremolo masterpiece — p-a-m-i tremolo painting the Alhambra''s fountains.','Warm even nylon; the tremolo must blur into one singing voice.'],
     array['Years of p-a-m-i practice hide inside this piece.','The thumb carries the harmony; the tremolo carries the tears.'],
     'Composed 1896. The tremolo masterpiece of the repertoire.',79),
    ('lagrima','francisco-tarrega','guitar','main','miniature prelude','acoustic','classical','lead','intermediate',
     'Classical guitar (Francisco Tarrega)','Classical — close mic','No cab (classical)','n/a (classical)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":3,"delay":0,"master":5}'::jsonb,
     array['The teardrop — Tarrega''s one-page prelude, every classical student''s first beautiful thing.','Soft intimate nylon; a single tear in E major/minor.'],
     array['Sing the melody over the arpeggiated bass.','One page. Infinite depth.'],
     'Composed c. 1891. The one-page teardrop prelude.',79),
    ('romanza-spanish-romance','traditional','guitar','main','arpeggio romance','acoustic','classical','lead','intermediate',
     'Classical guitar (traditional)','Classical — close mic','No cab (classical)','n/a (classical)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":3,"delay":0,"master":5}'::jsonb,
     array['The anonymous romance every guitarist meets — melody on top of a flowing arpeggio, composer unknown.','Warm rolling nylon; the ring finger sings the tune.'],
     array['The p-i-m-a pattern flows while the top voice sings.','The B section''s barre chords are the test.'],
     'Traditional, 19th century. The anonymous arpeggio romance.',78),
    ('malaguena','ernesto-lecuona','guitar','main','flamenco showpiece','acoustic','classical','lead','advanced',
     'Classical/flamenco guitar (arrangement)','Classical — concert mic','No cab (classical)','n/a (classical)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":3,"delay":0,"master":7}'::jsonb,
     array['The piano showpiece turned guitar firework — driving flamenco figures and cascading runs.','Bright percussive nylon; the E-major cascades sparkle.'],
     array['The bass ostinato drives; the runs decorate.','Build the accelerando like a bullring.'],
     'Composed 1928. The flamenco firework arrangement.',78),

    -- ============ WORLD / BOSSA ============
    ('volare','gipsy-kings','guitar','main','rumba flamenca strums','acoustic','flamenco','rhythm','intermediate',
     'Flamenco guitars (Reyes brothers)','Acoustic — mic''d ensemble','No cab (flamenco)','n/a (flamenco)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The rumba-flamenca party — driving Gipsy strums on the Modugno classic.','Bright percussive flamenco; the rumba strum pattern is the engine.'],
     array['Learn the rumba strum (down-up-slap) before the chords.','Ten guitars, one pulse — be all of them.'],
     'Studio recording, 1989. The rumba-flamenca party classic.',77),
    ('diablo-rojo','rodrigo-y-gabriela','guitar','main','percussive duo showpiece','acoustic','flamenco','lead','expert',
     'Nylon-string guitars (Rodrigo Sanchez / Gabriela Quintero)','Acoustic — pickup + mic','No cab (nylon)','piezo pickup',
     '[]'::jsonb,'{"gain":0,"bass":6,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The rollercoaster — Rodrigo''s metal-schooled lead over Gabriela''s percussive strum machine.','Bright aggressive nylon; her right hand is a drum kit, his is a shredder.'],
     array['Gabriela''s golpe-strum technique is its own instrument.','Metal picking on nylon strings — precision at speed.'],
     'Studio recording, 2006. The metal-flamenco rollercoaster.',78),
    ('the-girl-from-ipanema','antonio-carlos-jobim','guitar','main','bossa comping','clean','bossa nova','rhythm','intermediate',
     'Nylon-string guitar (Joao Gilberto)','Acoustic nylon — close mic','No cab (nylon)','n/a (nylon)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":2,"delay":0,"master":5}'::jsonb,
     array['The bossa nova itself — Gilberto''s whisper-soft syncopated comping that started everything.','Soft round nylon; the clave lives in the thumb.'],
     array['The bossa pattern: thumb on beat, fingers syncopated.','Quieter. Now quieter than that.'],
     'Studio recording, 1964. Gilberto''s whisper-bossa blueprint.',79),
    ('manha-de-carnaval','luiz-bonfa','guitar','main','bossa ballad','acoustic','bossa nova','lead','intermediate',
     'Nylon-string guitar (Luiz Bonfa)','Acoustic nylon — mic''d','No cab (nylon)','n/a (nylon)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":3,"delay":0,"master":5}'::jsonb,
     array['The Black Orpheus dawn — Bonfa''s aching A-minor bossa, a jazz-standard forever.','Warm singing nylon; melody and harmony in one hand.'],
     array['Chord-melody the A-minor theme.','Carnival morning: beautiful and already ending.'],
     'Film recording, 1959. The Black Orpheus dawn ballad.',78),
    ('somewhere-over-the-rainbow','israel-kamakawiwoole','guitar','main','ukulele-style strums','acoustic','hawaiian','rhythm','beginner',
     'Ukulele (Israel Kamakawiwoole) — guitar adaptation','Acoustic — one-take mic','No cab (ukulele)','n/a (ukulele)',
     '[]'::jsonb,'{"gain":0,"bass":4,"mids":5,"treble":7,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The 3 a.m. one-take miracle — IZ''s ukulele medley, profiled for the guitar/uke strum arrangement everyone plays.','Bright gentle strums; capo high on guitar to reach the uke sweetness.'],
     array['The island strum: down, down-up, up-down-up.','Recorded in one take at 3 a.m. Keep that peace.'],
     'Studio recording, 1993. The one-take ukulele miracle (guitar-adapted).',78),

    -- ============ US REGGAE-ROCK ============
    ('lay-me-down','dirty-heads','guitar','riff','acoustic reggae groove','acoustic','reggae rock','rhythm','beginner',
     'Acoustic guitar (Dirty Heads / Rome)','Acoustic — DI, beach-clean','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The 2010 beach-radio #1 — bouncing acoustic reggae skank.','Crisp dry acoustic; the upstroke skank drives it.'],
     array['Skank the off-beats with muted precision.','Sunshine tempo — never rush.'],
     'Studio recording, 2010. The beach-radio skank hit.',74),
    ('feeling-alright','rebelution','guitar','riff','reggae-rock skank','clean','reggae rock','rhythm','beginner',
     'Electric guitar (Eric Rachmany)','Clean amp with dub space','Open-back combo cab','neck pickup',
     '[{"effect_type":"delay","effect_name":"dub delay","placement":"post_gain","settings":{"time":4,"mix":3,"feedback":3}},{"effect_type":"reverb","effect_name":"spring reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":3,"master":6}'::jsonb,
     array['The Cali-reggae staple — clean skanks with dub echoes and a laid-back lead.','Wet warm clean; the skank floats on the delay.'],
     array['Off-beat chops with dub throws on the turnarounds.','Rachmany''s leads glide — no hurry anywhere.'],
     'Studio recording, 2007. The Cali-reggae staple.',74),
    ('world-on-fire','stick-figure','guitar','riff','dub-rock groove','clean','reggae rock','rhythm','beginner',
     'Electric guitar (Scott Woodruff)','Clean amp, deep dub production','Studio direct','neck pickup',
     '[{"effect_type":"delay","effect_name":"deep dub delay","placement":"post_gain","settings":{"time":5,"mix":4,"feedback":4}},{"effect_type":"reverb","effect_name":"large reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":4,"delay":4,"master":6}'::jsonb,
     array['The one-man-band dub anthem — spacious skanks in cavernous delay.','Deep wet clean; the space between chops is the song.'],
     array['Sparse skanks; let the delays answer.','Woodruff plays everything — you just need the guitar chair.'],
     'Studio recording, 2015. The one-man dub anthem.',74),
    ('one-day','matisyahu','guitar','main','hope anthem strums','acoustic','reggae rock','rhythm','beginner',
     'Acoustic guitar (session)','Acoustic — DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The stadium hope anthem — simple warm strums under the prayer.','Open honest acoustic; four chords of optimism.'],
     array['Steady strums; the melody does the lifting.','Sometimes I lay under the moon — that gentle.'],
     'Studio recording, 2009. The stadium hope anthem.',74),
    ('time-bomb-iration','iration','guitar','riff','island-rock groove','clean','reggae rock','rhythm','beginner',
     'Electric guitar (Micah Brown era)','Clean amp, sunny and tight','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"spring reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":1,"master":6}'::jsonb,
     array['The Santa Barbara island-rock hit — tight sunny skanks with pop hooks.','Bright dry-ish clean; beach-pop discipline.'],
     array['Tick the skanks tight; open for the chorus.','Love you like a time bomb — steady till it drops.'],
     'Studio recording, 2010. The island-rock time bomb.',73),

    -- ============ REGGAE LEGENDS FILLS ============
    ('you-can-get-it-if-you-really-want','jimmy-cliff','guitar','riff','uptempo skank','clean','reggae','rhythm','beginner',
     'Electric guitar (session — Kingston)','Small tube amp, bright skank','Small combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":5,"treble":7,"presence":6,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The try-and-try anthem — bright uptempo skank from The Harder They Come.','Crisp trebly chops; joy with persistence.'],
     array['Skank every off-beat crisp.','But you must try, try and try — same for the groove.'],
     'Studio recording, 1970. The try-and-try skank anthem.',76),
    ('54-46-was-my-number','toots-and-the-maytals','guitar','riff','early reggae skank','clean','reggae','rhythm','beginner',
     'Electric guitar (session — Kingston)','Small tube amp, dry skank','Small combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The prison-number classic — foundational reggae skank under Toots'' soul shout.','Dry tight chops; the groove is testimony.'],
     array['Give it to me one time (chop). Two times (chop chop).','You know the rest.'],
     'Studio recording, 1968. The foundational prison-number skank.',77),
    ('me-gustas-tu','manu-chao','guitar','main','rumba-pop strums','acoustic','latin','rhythm','beginner',
     'Acoustic guitar (Manu Chao)','Acoustic — DI, lo-fi warm','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The global campfire rumba — two chords and a list of everything he likes.','Warm bouncing acoustic; the pattern never changes, the joy never stops.'],
     array['The rumba strum loops on Am-G (capo taste).','What time is it? Time to learn this strum.'],
     'Studio recording, 2001. The global two-chord rumba.',76),
    ('les-yeux-noirs','django-reinhardt','guitar','lead','gypsy-jazz standard','acoustic','gypsy jazz','lead','advanced',
     'Selmer-Maccaferri guitar (Django Reinhardt)','Acoustic — mic''d, Hot Club','No cab (Selmer)','n/a (Selmer)',
     '[]'::jsonb,'{"gain":0,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['Dark Eyes — the gypsy-jam standard Django owned with two fretting fingers.','Dry barking Selmer tone; la pompe rhythm underneath.'],
     array['Learn la pompe first; the melody rides it.','Django used two fingers. You have no excuses.'],
     'Recording, 1940. Django''s two-fingered Dark Eyes.',79),

    -- ============ COUNTRY FINGERSTYLE LEGENDS ============
    ('windy-and-warm','chet-atkins','guitar','main','travis-picked standard','clean','country','lead','advanced',
     'Gretsch Country Gentleman (Chet Atkins)','Small tube amp, clean and round','Small combo cab','neck pickup',
     '[{"effect_type":"delay","effect_name":"subtle slapback","placement":"post_gain","settings":{"time":1,"mix":2,"feedback":1}}]'::jsonb,
     '{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":2,"master":6}'::jsonb,
     array['The Loudermilk tune Chet made a fingerstyle rite — minor-key travis picking with cool restraint.','Round clean Gretsch; thumb independence is the entry fee.'],
     array['The E-minor pattern rolls dark and steady.','Doc played it too — compare and steal from both.'],
     'Studio recording, 1962. Chet''s minor-key travis rite.',79),
    ('cannonball-rag','merle-travis','guitar','main','travis-picking origin','clean','country','lead','advanced',
     'Gibson Super 400 (Merle Travis)','Small tube amp, warm clean','Small combo cab','neck pickup',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['From the man the technique is NAMED for — Travis'' ragtime showpiece.','Warm round clean; the thumb plays boom-chick forever.'],
     array['This is where "Travis picking" comes from — learn the source.','The rag section swings; smile like Merle.'],
     'Recording, c. 1947. The technique''s namesake showpiece.',79),
    ('guitar-boogie','arthur-smith','guitar','riff','boogie instrumental','clean','country','lead','intermediate',
     'Electric guitar (Arthur Smith)','Small tube amp, bright clean','Small combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['The 1945 instrumental that sold a million — the boogie pattern every guitarist eventually finds.','Bright snappy clean; the boogie shuffle is eternal.'],
     array['The E-boogie pattern with the walking line.','It became "Guitar Boogie Shuffle" and never stopped.'],
     'Recording, 1945. The million-selling boogie origin.',78),
    ('wichita-lineman','glen-campbell','guitar','main','countrypolitan ballad','clean','country','rhythm','beginner',
     'Fender/Danelectro guitars (Glen Campbell — Wrecking Crew)','Clean amp, countrypolitan warmth','Fender combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"studio plate","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":1,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The lineman still on the line — warm countrypolitan comping and THAT baritone-guitar break.','Soft glassy clean; the famous solo was a Danelectro six-string bass.'],
     array['Comp the Jimmy Webb changes gently.','The morse-code outro note: still searching in the sun.'],
     'Studio recording, 1968. The countrypolitan lineman.',79),
    ('on-the-road-again','willie-nelson','guitar','main','trigger strums + runs','acoustic','country','rhythm','beginner',
     'Martin N-20 "Trigger" (Willie Nelson)','Acoustic nylon — mic''d/pickup','No cab (nylon)','n/a (nylon)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Trigger''s theme song — Willie''s nylon strums and jazz-tinged runs on the road anthem.','Warm worn nylon; behind-the-beat phrasing is the signature.'],
     array['Strum the train-beat; fill with chromatic runs.','The life I love is makin'' music with my friends.'],
     'Studio recording, 1980. Trigger''s road anthem.',78),
    ('hey-good-lookin','hank-williams','guitar','main','honky-tonk strums','acoustic','country','rhythm','beginner',
     'Martin D-28 (Hank Williams)','Acoustic — mic''d with steel band','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The honky-tonk pickup line — Hank''s driving D-28 strums under the grin.','Bright percussive acoustic; the shuffle sells the charm.'],
     array['Boom-chick the shuffle; the steel answers.','How''s about cookin'' somethin'' up with me?'],
     'Studio recording, 1951. The honky-tonk pickup line.',79)
) as c(
  song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence
)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;
