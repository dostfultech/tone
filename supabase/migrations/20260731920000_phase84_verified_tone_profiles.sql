-- Phase 84: global canon (Russian post-punk, Latin, OPM, Indonesian) + viral 2024-25 + 2000s one-hit alt.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Kino','kino','Gruppa Krovi','gruppa-krovi','Gruppa Krovi',1988),
    ('Kino','kino','Zvezda po imeni Solntse','zvezda-po-imeni-solntse','Zvezda po imeni Solntse',1989),
    ('Molchat Doma','molchat-doma','Sudno','sudno','Etazhi',2018),
    ('Lola Young','lola-young','Messy','messy','This Wasn''t Meant for You Anyway',2024),
    ('Rose & Bruno Mars','rose-and-bruno-mars','APT.','apt','Rosie',2024),
    ('Twenty One Pilots','twenty-one-pilots','Ride','ride-top','Blurryface',2015),
    ('Jarabe de Palo','jarabe-de-palo','La Flaca','la-flaca','La Flaca',1996),
    ('Caifanes','caifanes','Afuera','afuera','El Nervio del Volcan',1994),
    ('Heroes del Silencio','heroes-del-silencio','Maldito Duende','maldito-duende','Senderos de Traicion',1990),
    ('Juanes','juanes','Me Enamora','me-enamora','La Vida... Es Un Ratico',2007),
    ('Rivermaya','rivermaya','214','214','Rivermaya',1996),
    ('Juan Karlos','juan-karlos','Buwan','buwan','Buwan',2018),
    ('Juan Karlos','juan-karlos','Ere','ere','Sad Songs and Bullshit Part 1',2023),
    ('Sheila on 7','sheila-on-7','Dan','dan','Sheila on 7',1999),
    ('Noah','noah-band','Separuh Aku','separuh-aku','Seperti Seharusnya',2012),
    ('Bright Eyes','bright-eyes','First Day of My Life','first-day-of-my-life','I''m Wide Awake, It''s Morning',2005),
    ('Neutral Milk Hotel','neutral-milk-hotel','In the Aeroplane Over the Sea','in-the-aeroplane-over-the-sea','In the Aeroplane Over the Sea',1998),
    ('The Front Bottoms','the-front-bottoms','Twin Size Mattress','twin-size-mattress','Talon of the Hawk',2013),
    ('The Mountain Goats','the-mountain-goats','No Children','no-children','Tallahassee',2002),
    ('Wheatus','wheatus','Teenage Dirtbag','teenage-dirtbag','Wheatus',2000),
    ('The Calling','the-calling','Wherever You Will Go','wherever-you-will-go','Camino Palmero',2001),
    ('Lit','lit','My Own Worst Enemy','my-own-worst-enemy','A Place in the Sun',1999),
    ('American Hi-Fi','american-hi-fi','Flavor of the Weak','flavor-of-the-weak','American Hi-Fi',2001),
    ('Bowling for Soup','bowling-for-soup','1985','1985','A Hangover You Don''t Deserve',2004),
    ('Fountains of Wayne','fountains-of-wayne','Stacy''s Mom','stacys-mom','Welcome Interstate Managers',2003)
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
    ('kino','gruppa-krovi'),('kino','zvezda-po-imeni-solntse'),('molchat-doma','sudno'),('lola-young','messy'),
    ('rose-and-bruno-mars','apt'),('twenty-one-pilots','ride-top'),('jarabe-de-palo','la-flaca'),('caifanes','afuera'),
    ('heroes-del-silencio','maldito-duende'),('juanes','me-enamora'),('rivermaya','214'),('juan-karlos','buwan'),
    ('juan-karlos','ere'),('sheila-on-7','dan'),('noah-band','separuh-aku'),('bright-eyes','first-day-of-my-life'),
    ('neutral-milk-hotel','in-the-aeroplane-over-the-sea'),('the-front-bottoms','twin-size-mattress'),
    ('the-mountain-goats','no-children'),('wheatus','teenage-dirtbag'),('the-calling','wherever-you-will-go'),
    ('lit','my-own-worst-enemy'),('american-hi-fi','flavor-of-the-weak'),('bowling-for-soup','1985'),
    ('fountains-of-wayne','stacys-mom')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
  where p.mode = 'guitar'
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('kino','gruppa-krovi'),('kino','zvezda-po-imeni-solntse'),('molchat-doma','sudno'),('lola-young','messy'),
    ('rose-and-bruno-mars','apt'),('twenty-one-pilots','ride-top'),('jarabe-de-palo','la-flaca'),('caifanes','afuera'),
    ('heroes-del-silencio','maldito-duende'),('juanes','me-enamora'),('rivermaya','214'),('juan-karlos','buwan'),
    ('juan-karlos','ere'),('sheila-on-7','dan'),('noah-band','separuh-aku'),('bright-eyes','first-day-of-my-life'),
    ('neutral-milk-hotel','in-the-aeroplane-over-the-sea'),('the-front-bottoms','twin-size-mattress'),
    ('the-mountain-goats','no-children'),('wheatus','teenage-dirtbag'),('the-calling','wherever-you-will-go'),
    ('lit','my-own-worst-enemy'),('american-hi-fi','flavor-of-the-weak'),('bowling-for-soup','1985'),
    ('fountains-of-wayne','stacys-mom')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
  where p.mode = 'guitar'
);
delete from public.song_tone_profiles p where p.mode = 'guitar' and p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('kino','gruppa-krovi'),('kino','zvezda-po-imeni-solntse'),('molchat-doma','sudno'),('lola-young','messy'),
    ('rose-and-bruno-mars','apt'),('twenty-one-pilots','ride-top'),('jarabe-de-palo','la-flaca'),('caifanes','afuera'),
    ('heroes-del-silencio','maldito-duende'),('juanes','me-enamora'),('rivermaya','214'),('juan-karlos','buwan'),
    ('juan-karlos','ere'),('sheila-on-7','dan'),('noah-band','separuh-aku'),('bright-eyes','first-day-of-my-life'),
    ('neutral-milk-hotel','in-the-aeroplane-over-the-sea'),('the-front-bottoms','twin-size-mattress'),
    ('the-mountain-goats','no-children'),('wheatus','teenage-dirtbag'),('the-calling','wherever-you-will-go'),
    ('lit','my-own-worst-enemy'),('american-hi-fi','flavor-of-the-weak'),('bowling-for-soup','1985'),
    ('fountains-of-wayne','stacys-mom')
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
    ('gruppa-krovi','kino','guitar','riff','main riff','clean','post-punk','rhythm','beginner',
     'Fender/Soviet electric (Viktor Tsoi / Yuri Kasparyan)','Clean amp with chorus, Soviet post-punk','Small combo cab','bridge pickup',
     '[{"effect_type":"chorus","effect_name":"cold chorus","placement":"post_gain","settings":{"rate":3,"depth":4,"mix":4}},{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":3,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":1,"master":6}'::jsonb,
     array['Blood Type — the Soviet rock monument; Tsoi''s chorused minor riff that a whole bloc grew up on.','Cold chorused clean-crunch; the USSR''s most-learned riff.'],
     array['The Am riff cycles under the marching beat.','Gruppa krovi na rukave — steady as a vow.'],
     'Studio recording, 1988. The Soviet rock monument.',75),
    ('zvezda-po-imeni-solntse','kino','guitar','riff','main riff','clean','post-punk','rhythm','beginner',
     'Electric guitar (Yuri Kasparyan)','Clean amp with chorus','Small combo cab','bridge pickup',
     '[{"effect_type":"chorus","effect_name":"cold chorus","placement":"post_gain","settings":{"rate":3,"depth":4,"mix":4}}]'::jsonb,
     '{"gain":3,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":1,"master":6}'::jsonb,
     array['A Star Called Sun — Tsoi''s last great anthem, chorused and mournful.','Cold minor jangle; the war goes on without a reason.'],
     array['The riff walks the minor changes evenly.','Every Russian-speaking guitarist''s second song.'],
     'Studio recording, 1989. Tsoi''s star-called-sun anthem.',75),
    ('sudno','molchat-doma','guitar','riff','post-punk pulse','clean','post-punk','rhythm','beginner',
     'Electric guitar (Roman Komogortsev)','Clean amp, icy Belarusian pulse','Studio direct','bridge pickup',
     '[{"effect_type":"chorus","effect_name":"icy chorus","placement":"post_gain","settings":{"rate":4,"depth":4,"mix":5}},{"effect_type":"reverb","effect_name":"cold reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":7,"presence":5,"reverb":4,"delay":1,"master":6}'::jsonb,
     array['The TikTok doomer anthem — icy chorused jangle from Minsk over the drum machine.','Frozen chorused clean; enamel bathtub poetry.'],
     array['The jangle figure loops with machine precision.','Zhit tyazhelo i neuyutno — but the riff is easy.'],
     'Studio recording, 2018. The doomer-wave anthem.',74),
    ('messy','lola-young','guitar','main','main progression','clean','pop','rhythm','beginner',
     'Electric guitar (session)','Clean amp, raw and close','Studio direct','neck pickup',
     '[{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The 2024-25 rant-anthem — loose warm clean strums under the stream-of-consciousness.','Raw honest clean; a thousand times messier than the chords.'],
     array['Strum the loop casually.','''Cause I''m too messy — the feel should be too.'],
     'Studio recording, 2024. The rant-anthem strummer.',72),
    ('apt','rose-and-bruno-mars','guitar','riff','main riff','crunch','pop rock','rhythm','beginner',
     'Electric guitar (session — Bruno Mars)','Tube amp, bright party crunch','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The apateu-apateu smash — bright new-wave-revival crunch built on the Korean drinking game.','Snappy trebly drive; Toni Basil bones, 2024 body.'],
     array['The riff pumps eighth-notes.','Apateu, apateu — don''t stop.'],
     'Studio recording, 2024. The drinking-game smash.',73),
    ('ride-top','twenty-one-pilots','guitar','riff','reggae-pop groove','clean','alternative rock','rhythm','beginner',
     'Electric guitar (session/live arrangement)','Clean amp, reggae-pop skank','Studio direct','neck pickup',
     '[{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":1,"master":6}'::jsonb,
     array['The Blurryface skanker — synth-led on record; the guitar arrangement rides the off-beat skank everyone plays.','Warm clean chops; I''ve been thinking too much.'],
     array['Skank the off-beats under the melody.','Help me — the groove already does.'],
     'Studio recording, 2015. The Blurryface skanker (arrangement noted).',72),
    ('la-flaca','jarabe-de-palo','guitar','riff','latin groove riff','clean','latin rock','rhythm','beginner',
     'Electric + nylon guitar (Pau Dones)','Clean amp, warm habanera groove','Small combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The Spanish summer eternal — Pau''s warm habanera groove for the skinny girl from Havana.','Round warm clean; por un beso de la flaca.'],
     array['The groove sways on the habanera rhythm.','Daria lo que fuera — play it that devoted.'],
     'Studio recording, 1996. The Spanish summer eternal.',74),
    ('afuera','caifanes','guitar','riff','main riff','crunch','latin rock','rhythm','intermediate',
     'Fender/Gibson electric (Alejandro Marcovich)','Tube amp, Latin-alternative drive','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":1,"master":7}'::jsonb,
     array['The Mexican alt-rock peak — Marcovich''s snaking drive on the beloved kiss-off.','Warm biting drive; me quedo afuera.'],
     array['The riff coils around the vocal.','Marcovich''s fills sting — place them exactly.'],
     'Studio recording, 1994. The Mexican alt-rock kiss-off.',74),
    ('maldito-duende','heroes-del-silencio','guitar','riff','main riff','crunch','latin rock','rhythm','intermediate',
     'Gibson Les Paul (Juan Valdivia)','Tube amp, Spanish arena drive','Closed-back cab','bridge humbucker',
     '[{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":1,"master":7}'::jsonb,
     array['The cursed-goblin anthem — Valdivia''s arpeggiated drive under Bunbury''s howl.','Warm arena drive; Spain''s most-learned rock intro.'],
     array['The arpeggiated intro rings — learn it exact.','Y es que el duende — commit to the drama.'],
     'Studio recording, 1990. The cursed-goblin anthem.',74),
    ('me-enamora','juanes','guitar','riff','main riff','clean','latin rock','rhythm','beginner',
     'Fender Stratocaster (Juanes)','Clean amp, bright Colombian pop-rock','Small combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":3,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The Colombian earworm — bright chiming riff that owned Latin radio.','Crisp just-clean sparkle; me enamora que me hables.'],
     array['The intro riff hooks in two bars.','Pero sobre todo — keep it bouncing.'],
     'Studio recording, 2007. The Colombian earworm riff.',74),
    ('214','rivermaya','guitar','riff','main arpeggio','clean','opm rock','rhythm','beginner',
     'Electric guitar (Rico Blanco / Perf de Castro era)','Clean amp with big reverb','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"large hall reverb","placement":"post_gain","settings":{"mix":5,"decay":6}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":5,"delay":1,"master":6}'::jsonb,
     array['The OPM love-letter — wet arpeggios every Filipino guitarist learns for someone.','Drenched clean picking; am I real?'],
     array['The arpeggio pattern carries the confession.','Save it for a dedication.'],
     'Studio recording, 1996. The OPM love-letter arpeggios.',74),
    ('buwan','juan-karlos','guitar','main','main progression','acoustic','opm rock','rhythm','beginner',
     'Acoustic guitar (Juan Karlos Labajo)','Acoustic — mic''d with band swell','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The moon serenade — warm 6/8 acoustic that broke Philippine streaming records.','Open warm acoustic; sa ilalim ng puting ilaw ng buwan.'],
     array['Sway the 6/8 strums.','Serenade tempo — the moon is listening.'],
     'Studio recording, 2018. The record-breaking moon serenade.',74),
    ('ere','juan-karlos','guitar','main','main progression','clean','opm rock','rhythm','beginner',
     'Clean electric (Juan Karlos band)','Clean amp, moody OPM','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":4,"delay":1,"master":6}'::jsonb,
     array['The 2023 OPM giant — moody clean build to a full-band confession.','Wet warm clean; sana ere lang.'],
     array['Arpeggiate soft; explode late.','The bridge scream earns itself — wait for it.'],
     'Studio recording, 2023. The 2023 OPM giant.',73),
    ('dan','sheila-on-7','guitar','riff','main riff','clean','indonesian pop','rhythm','beginner',
     'Fender electric (Eross Candra)','Clean amp, jangly Indo-pop','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The Indonesian evergreen — Eross'' jangling riff every warung guitarist knows.','Bright warm jangle; dan bila esok datang.'],
     array['The intro riff is national furniture.','Keep the strum relaxed and singable.'],
     'Studio recording, 1999. The Indonesian evergreen riff.',74),
    ('separuh-aku','noah-band','guitar','riff','ballad riff','clean','indonesian pop','rhythm','beginner',
     'Electric guitar (Lukman / Uki)','Clean amp with ballad gloss','Closed-back cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":3,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":4,"delay":1,"master":6}'::jsonb,
     array['The comeback ballad — glossy clean riffing on Indonesia''s biggest 2012 song.','Wet polished clean; dengarlah sayang.'],
     array['The lead riff answers the vocal.','Build to the chorus lift patiently.'],
     'Studio recording, 2012. The comeback ballad.',73),
    ('first-day-of-my-life','bright-eyes','guitar','main','fingerpicked love song','acoustic','indie folk','rhythm','beginner',
     'Acoustic guitar (Conor Oberst)','Acoustic — close-mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The wedding-indie standard — Oberst''s warm picked confession, door-opening and all.','Close intimate acoustic; yours is the first face that I saw.'],
     array['The travis-lite pattern rolls gently.','I''m glad I didn''t die before I met you — play it that grateful.'],
     'Studio recording, 2005. The wedding-indie standard.',76),
    ('in-the-aeroplane-over-the-sea','neutral-milk-hotel','guitar','main','strummed hymn','acoustic','indie folk','rhythm','beginner',
     'Acoustic guitar (Jeff Mangum)','Acoustic — hot-mic''d, blown out','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The lo-fi hymn — Mangum''s over-driven acoustic strums pushing the mic into the red.','Loud blown-out acoustic; how strange it is to be anything at all.'],
     array['Strum the G-Em-C-D wheel hard.','Sing until the tape distorts.'],
     'Studio recording, 1998. The blown-out strummed hymn.',76),
    ('twin-size-mattress','the-front-bottoms','guitar','main','folk-punk strums','acoustic','folk punk','rhythm','beginner',
     'Acoustic guitar (Brian Sella)','Acoustic — DI, punk energy','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['The shouted lullaby — driving acoustic strums under conversational screaming.','Dry bright acoustic hit hard; make sure to laugh.'],
     array['Drive the strums like drums.','This is for the snakes and the people they bite.'],
     'Studio recording, 2013. The shouted folk-punk lullaby.',74),
    ('no-children','the-mountain-goats','guitar','main','spite strums','acoustic','indie folk','rhythm','beginner',
     'Acoustic guitar (John Darnielle)','Acoustic — hot-mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['The divorce singalong TikTok resurrected — Darnielle''s galloping spite strums.','Bright hammered acoustic; I hope you die, I hope we both die — joyfully.'],
     array['Gallop the strums with a grin.','The whole room screams the bridge. Let them.'],
     'Studio recording, 2002. The joyful divorce singalong.',75),
    ('teenage-dirtbag','wheatus','guitar','riff','main riff','clean','pop rock','rhythm','beginner',
     'Acoustic + electric (Brendan Brown)','Clean amp, nasal-era jangle','Studio direct','bridge pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The dirtbag anthem — acoustic-electric jangle that never stopped charting somewhere.','Bright hybrid jangle; her name is Noelle.'],
     array['The verse chug is muted and tight.','Listen to Iron Maiden baby, with me — ooooh.'],
     'Studio recording, 2000. The eternal dirtbag anthem.',75),
    ('wherever-you-will-go','the-calling','guitar','riff','ballad riff','clean','pop rock','rhythm','beginner',
     'Electric + acoustic (Aaron Kamin)','Clean-to-warm amp','Closed-back cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The 2001 devotion ballad — warm arpeggiated build to the soaring hook.','Polished warm clean-crunch; so lately, been wondering.'],
     array['Arpeggiate the verses; strum the lift.','If I could, then I would — full chest.'],
     'Studio recording, 2001. The devotion ballad.',74),
    ('my-own-worst-enemy','lit','guitar','riff','main riff','distorted','pop punk','rhythm','beginner',
     'Gretsch/Gibson electric (Jeremy Popoff)','Tube amp, bright party crunch','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The car-on-the-lawn anthem — bright buzzing riff of every 1999 mistake.','Snappy saturated crunch; please tell me why.'],
     array['The riff bounces E-B-A.','It''s no surprise to me — play it hungover-proud.'],
     'Studio recording, 1999. The car-on-the-lawn anthem.',75),
    ('flavor-of-the-weak','american-hi-fi','guitar','riff','main riff','distorted','pop punk','rhythm','beginner',
     'Gibson Les Paul (Stacy Jones / Jamie Arentzen)','Tube amp, radio pop-punk','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The she''s-with-him lament — chunky radio pop-punk wall.','Thick bright drive; and he don''t even know.'],
     array['Drive the chords; punch the stops.','It''s such a shame — loudly.'],
     'Studio recording, 2001. The she''s-with-him wall.',73),
    ('1985','bowling-for-soup','guitar','riff','main riff','distorted','pop punk','rhythm','beginner',
     'Gibson/Fender electric (Chris Burney / Jaret Reddick)','Tube amp, grinning pop-punk','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The nostalgia machine — bouncing pop-punk drive about when Debbie was cool.','Bright fun saturation; Springsteen, Madonna, way before Nirvana.'],
     array['Bounce the progression with a grin.','There was U2 and Blondie — you''ve verified both today.'],
     'Studio recording, 2004. The nostalgia machine.',74),
    ('stacys-mom','fountains-of-wayne','guitar','riff','main riff','crunch','power pop','rhythm','beginner',
     'Fender/Gibson electric (Adam Schlesinger / Jody Porter)','Tube amp, Cars-worship crunch','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['The Cars-homage forever-meme — clipped bright stabs straight from 1978 by way of 2003.','Trebly tight crunch; Stacy''s mom has got it goin'' on.'],
     array['Clip the stabs Cars-tight.','Schlesinger built it as a love letter — deliver it.'],
     'Studio recording, 2003. The Cars-homage forever-meme.',75)
) as c(
  song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence
)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;
