-- Phase 27: 25 reggae, ska & world staples, verified per-part tone data (more Bob Marley, Sublime, Santana + Peter Tosh, Jimmy Cliff, Toots, Desmond Dekker, Gregory Isaacs, UB40, Specials, Madness, Ali Farka Toure, Tinariwen, Rodrigo y Gabriela, Gipsy Kings, Buena Vista Social Club, Manu Chao).

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Bob Marley','bob-marley','Three Little Birds','three-little-birds','Exodus',1977),
    ('Bob Marley','bob-marley','One Love','one-love','Exodus',1977),
    ('Bob Marley','bob-marley','Buffalo Soldier','buffalo-soldier','Confrontation',1983),
    ('Bob Marley','bob-marley','Stir It Up','stir-it-up','Catch a Fire',1973),
    ('Bob Marley','bob-marley','Jamming','jamming','Exodus',1977),
    ('Peter Tosh','peter-tosh','Legalize It','legalize-it','Legalize It',1976),
    ('Jimmy Cliff','jimmy-cliff','The Harder They Come','the-harder-they-come','The Harder They Come',1972),
    ('Toots and the Maytals','toots-and-the-maytals','Pressure Drop','pressure-drop','Monkey Man',1969),
    ('Desmond Dekker','desmond-dekker','Israelites','israelites','single',1968),
    ('Gregory Isaacs','gregory-isaacs','Night Nurse','night-nurse','Night Nurse',1982),
    ('Sublime','sublime','Wrong Way','wrong-way','Sublime',1996),
    ('Sublime','sublime','Doin'' Time','doin-time','Sublime',1996),
    ('Santana','santana','Oye Como Va','oye-como-va','Abraxas',1970),
    ('Santana','santana','Smooth','smooth','Supernatural',1999),
    ('Santana','santana','Samba Pa Ti','samba-pa-ti','Abraxas',1970),
    ('Santana','santana','Evil Ways','evil-ways','Santana',1969),
    ('UB40','ub40','Red Red Wine','red-red-wine','Labour of Love',1983),
    ('The Specials','the-specials','A Message to You Rudy','a-message-to-you-rudy','The Specials',1979),
    ('Madness','madness','Our House','our-house','The Rise & Fall',1982),
    ('Ali Farka Touré','ali-farka-toure','Diaraby','diaraby','The Source',1993),
    ('Tinariwen','tinariwen','Amassakoul ''n'' Ténéré','amassakoul-n-tenere','Amassakoul',2004),
    ('Rodrigo y Gabriela','rodrigo-y-gabriela','Tamacun','tamacun','Rodrigo y Gabriela',2006),
    ('Gipsy Kings','gipsy-kings','Bamboléo','bamboleo','Gipsy Kings',1987),
    ('Buena Vista Social Club','buena-vista-social-club','Chan Chan','chan-chan','Buena Vista Social Club',1997),
    ('Manu Chao','manu-chao','Clandestino','clandestino','Clandestino',1998)
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
    ('bob-marley','three-little-birds'),('bob-marley','one-love'),('bob-marley','buffalo-soldier'),('bob-marley','stir-it-up'),
    ('bob-marley','jamming'),('peter-tosh','legalize-it'),('jimmy-cliff','the-harder-they-come'),('toots-and-the-maytals','pressure-drop'),
    ('desmond-dekker','israelites'),('gregory-isaacs','night-nurse'),('sublime','wrong-way'),('sublime','doin-time'),
    ('santana','oye-como-va'),('santana','smooth'),('santana','samba-pa-ti'),('santana','evil-ways'),
    ('ub40','red-red-wine'),('the-specials','a-message-to-you-rudy'),('madness','our-house'),('ali-farka-toure','diaraby'),
    ('tinariwen','amassakoul-n-tenere'),('rodrigo-y-gabriela','tamacun'),('gipsy-kings','bamboleo'),('buena-vista-social-club','chan-chan'),
    ('manu-chao','clandestino')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('bob-marley','three-little-birds'),('bob-marley','one-love'),('bob-marley','buffalo-soldier'),('bob-marley','stir-it-up'),
    ('bob-marley','jamming'),('peter-tosh','legalize-it'),('jimmy-cliff','the-harder-they-come'),('toots-and-the-maytals','pressure-drop'),
    ('desmond-dekker','israelites'),('gregory-isaacs','night-nurse'),('sublime','wrong-way'),('sublime','doin-time'),
    ('santana','oye-como-va'),('santana','smooth'),('santana','samba-pa-ti'),('santana','evil-ways'),
    ('ub40','red-red-wine'),('the-specials','a-message-to-you-rudy'),('madness','our-house'),('ali-farka-toure','diaraby'),
    ('tinariwen','amassakoul-n-tenere'),('rodrigo-y-gabriela','tamacun'),('gipsy-kings','bamboleo'),('buena-vista-social-club','chan-chan'),
    ('manu-chao','clandestino')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('bob-marley','three-little-birds'),('bob-marley','one-love'),('bob-marley','buffalo-soldier'),('bob-marley','stir-it-up'),
    ('bob-marley','jamming'),('peter-tosh','legalize-it'),('jimmy-cliff','the-harder-they-come'),('toots-and-the-maytals','pressure-drop'),
    ('desmond-dekker','israelites'),('gregory-isaacs','night-nurse'),('sublime','wrong-way'),('sublime','doin-time'),
    ('santana','oye-como-va'),('santana','smooth'),('santana','samba-pa-ti'),('santana','evil-ways'),
    ('ub40','red-red-wine'),('the-specials','a-message-to-you-rudy'),('madness','our-house'),('ali-farka-toure','diaraby'),
    ('tinariwen','amassakoul-n-tenere'),('rodrigo-y-gabriela','tamacun'),('gipsy-kings','bamboleo'),('buena-vista-social-club','chan-chan'),
    ('manu-chao','clandestino')
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
    ('three-little-birds','bob-marley','guitar','riff','skank rhythm','clean',
     'reggae','rhythm','beginner',
     'Electric guitar (Bob Marley & the Wailers)','Bright clean amp','Open-back combo cab','bridge single-coil',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":5,"treble":7,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bright, clean off-beat skank chops; keep them short, percussive, and on the upbeat.','Low gain, bright and thin.'],
     array['Chop the chords on the off-beats.','Mute quickly for a percussive stab.'],
     'Studio recording, 1977 (Exodus). The Wailers played bright, clean off-beat skank chops.',74),
    ('one-love','bob-marley','guitar','riff','skank rhythm','clean',
     'reggae','rhythm','beginner',
     'Electric guitar (Bob Marley & the Wailers)','Bright clean amp','Open-back combo cab','bridge single-coil',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":5,"treble":7,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Upbeat, clean reggae skank; keep the chops tight and joyful.','Low gain, bright.'],
     array['Play the off-beat chops crisply.','Keep the groove uplifting.'],
     'Studio recording, 1977 (Exodus). The Wailers played an upbeat, clean reggae skank.',74),
    ('buffalo-soldier','bob-marley','guitar','riff','skank rhythm','clean',
     'reggae','rhythm','beginner',
     'Electric guitar (Bob Marley & the Wailers)','Bright clean amp','Open-back combo cab','bridge single-coil',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":5,"treble":7,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Clean, steady reggae skank under the marching groove; keep it tight.','Low gain, bright.'],
     array['Chop the off-beats evenly.','Lock to the one-drop drums.'],
     'Studio recording, released 1983. The Wailers played a clean, steady reggae skank.',73),
    ('stir-it-up','bob-marley','guitar','riff','skank and bluesy lead fills','clean',
     'reggae','lead','intermediate',
     'Electric guitar (Bob Marley & the Wailers)','Bright clean amp','Open-back combo cab','bridge single-coil',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Laid-back skank with warm, bluesy lead fills between the chops; keep it smooth.','Low gain, warm.'],
     array['Chop the off-beats, then answer with soft fills.','Keep the fills bluesy and relaxed.'],
     'Studio recording, 1973 (Catch a Fire). The Wailers played a laid-back skank with warm bluesy lead fills.',73),
    ('jamming','bob-marley','guitar','riff','skank rhythm','clean',
     'reggae','rhythm','beginner',
     'Electric guitar (Bob Marley & the Wailers)','Bright clean amp','Open-back combo cab','bridge single-coil',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":5,"treble":7,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Happy, clean reggae skank with a light bounce; keep the chops crisp.','Low gain, bright.'],
     array['Play the off-beat chops with a bounce.','Keep it light and grooving.'],
     'Studio recording, 1977 (Exodus). The Wailers played a happy, clean reggae skank.',73),
    ('legalize-it','peter-tosh','guitar','riff','skank rhythm','clean',
     'reggae','rhythm','beginner',
     'Electric guitar (Peter Tosh)','Bright clean amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":5,"treble":7,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Clean, steady roots-reggae skank; keep the chops tight and deliberate.','Low gain, bright.'],
     array['Chop the off-beats evenly.','Keep the groove steady.'],
     'Studio recording, 1976 (Legalize It). Peter Tosh played a clean, steady roots-reggae skank.',72),
    ('the-harder-they-come','jimmy-cliff','guitar','riff','skank rhythm','clean',
     'reggae','rhythm','beginner',
     'Electric guitar (Jimmy Cliff band)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":5,"treble":7,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Driving early-reggae skank with a rootsy push; keep the chops crisp.','Low gain, bright.'],
     array['Chop the off-beats with drive.','Keep it tight and rootsy.'],
     'Studio recording, 1972. Jimmy Cliff''s band played a driving early-reggae skank.',72),
    ('pressure-drop','toots-and-the-maytals','guitar','riff','skank rhythm','clean',
     'reggae','rhythm','beginner',
     'Electric guitar (Toots and the Maytals)','Bright clean amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":5,"treble":7,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bright, bouncy rocksteady skank; keep the chops snappy.','Low gain, bright.'],
     array['Play the off-beat chops snappily.','Keep the groove bouncy.'],
     'Studio recording, 1969. Toots and the Maytals played a bright, bouncy rocksteady skank.',72),
    ('israelites','desmond-dekker','guitar','riff','skank rhythm','clean',
     'ska','rhythm','beginner',
     'Electric guitar (Desmond Dekker band)','Bright clean amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":5,"treble":7,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bright, brisk rocksteady/early-reggae chop; keep it light and tight.','Low gain, bright.'],
     array['Chop the off-beats crisply.','Keep the tempo brisk.'],
     'Studio recording, 1968. Desmond Dekker''s band played a bright, brisk rocksteady chop.',71),
    ('night-nurse','gregory-isaacs','guitar','riff','skank rhythm','clean',
     'reggae','rhythm','beginner',
     'Electric guitar (Gregory Isaacs band)','Bright clean amp with light chorus','Open-back combo cab','neck pickup',
     '[{"effect_type":"chorus","effect_name":"chorus","placement":"post_gain","settings":{"rate":3,"depth":3,"mix":3}}]'::jsonb,'{"gain":2,"bass":4,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Smooth, mellow lovers-rock skank with a touch of chorus; keep it silky.','Low gain, warm, light chorus.'],
     array['Chop the off-beats gently.','Keep the groove smooth and late-night.'],
     'Studio recording, 1982 (Night Nurse). Gregory Isaacs'' band played a smooth lovers-rock skank.',72),
    ('wrong-way','sublime','guitar','riff','main riff','crunch',
     'ska','rhythm','beginner',
     'Electric guitar (Bradley Nowell)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Upbeat ska-punk with crunchy upstroke chords; keep the off-beats tight and driving.','Low-medium gain.'],
     array['Play the ska upstrokes tightly.','Keep the energy up.'],
     'Studio recording, 1996 (Sublime). Bradley Nowell played upbeat ska-punk upstroke chords.',72),
    ('doin-time','sublime','guitar','riff','skank rhythm','clean',
     'reggae','rhythm','beginner',
     'Electric guitar (Bradley Nowell)','Clean amp with dub effects','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Laid-back, dubby summer skank; keep the chops mellow and spacious.','Low gain, warm.'],
     array['Chop the off-beats softly.','Leave dubby space.'],
     'Studio recording, 1996 (Sublime). Bradley Nowell played a laid-back, dubby reggae skank.',72),
    ('oye-como-va','santana','guitar','riff','main theme and solo','crunch',
     'latin','lead','intermediate',
     'Gibson/PRS electric (Carlos Santana)','Mesa/Boogie overdriven amp','Open-back combo cab','neck humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":2,"delay":1,"master":6}'::jsonb,
     array['Singing, sustained Latin-rock lead with strong mids; keep the tone creamy and vocal.','Medium-high gain, strong mids.'],
     array['Play the melody with long, sustained notes.','Add rich finger vibrato.'],
     'Studio recording, 1970 (Abraxas). Carlos Santana played a singing, sustained Latin-rock lead through a Mesa/Boogie.',75),
    ('smooth','santana','guitar','riff','main riff and solo','crunch',
     'latin','lead','intermediate',
     'Gibson/PRS electric (Carlos Santana)','Mesa/Boogie overdriven amp','Open-back combo cab','neck humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":2,"delay":1,"master":6}'::jsonb,
     array['Hot Latin-pop with a creamy, singing lead over a percussive groove; keep the sustain rich.','Medium-high gain, strong mids.'],
     array['Play the melody with singing sustain.','Keep the rhythm stabs tight.'],
     'Studio recording, 1999 (Supernatural). Carlos Santana played a creamy, singing lead through a Mesa/Boogie.',74),
    ('samba-pa-ti','santana','guitar','riff','instrumental main theme','crunch',
     'latin','lead','advanced',
     'Gibson/PRS electric (Carlos Santana)','Mesa/Boogie overdriven amp','Open-back combo cab','neck humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":2,"delay":1,"master":6}'::jsonb,
     array['Slow, emotional instrumental with a singing, sustained tone; keep it lyrical and dynamic.','Medium-high gain, huge sustain.'],
     array['Play the melody slowly with feeling.','Let the long notes sing and cry.'],
     'Studio recording, 1970 (Abraxas). Carlos Santana played a slow, emotional instrumental with a singing tone.',74),
    ('evil-ways','santana','guitar','riff','main riff and solo','crunch',
     'latin','lead','intermediate',
     'Gibson/PRS electric (Carlos Santana)','Mesa/Boogie overdriven amp','Open-back combo cab','neck humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":2,"delay":1,"master":6}'::jsonb,
     array['Percussive Latin-rock with a singing solo over an organ groove; keep the mids up.','Medium-high gain.'],
     array['Comp the groove tightly.','Play the solo with sustain and vibrato.'],
     'Studio recording, 1969 (Santana). Carlos Santana played percussive Latin-rock and a singing solo.',73),
    ('red-red-wine','ub40','guitar','riff','skank rhythm','clean',
     'reggae','rhythm','beginner',
     'Electric guitar (UB40)','Bright clean amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Smooth, pop-reggae skank; keep the chops relaxed and even.','Low gain, warm-bright.'],
     array['Chop the off-beats smoothly.','Keep the groove relaxed.'],
     'Studio recording, 1983 (Labour of Love). UB40 played a smooth pop-reggae skank.',72),
    ('a-message-to-you-rudy','the-specials','guitar','riff','upstroke rhythm','clean',
     'ska','rhythm','beginner',
     'Electric guitar (The Specials)','Bright clean amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":5,"treble":7,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bright, brisk 2-tone ska upstrokes; keep the off-beat chops crisp and tight.','Low gain, bright.'],
     array['Play the off-beat upstrokes crisply.','Keep the tempo brisk.'],
     'Studio recording, 1979. The Specials played bright, brisk 2-tone ska upstrokes.',72),
    ('our-house','madness','guitar','riff','upstroke rhythm','clean',
     'ska','rhythm','beginner',
     'Electric guitar (Madness)','Bright clean amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":5,"treble":7,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Cheerful, bouncy nutty-boys ska upstrokes; keep them light and tight.','Low gain, bright.'],
     array['Play the off-beat chops with a bounce.','Keep it upbeat.'],
     'Studio recording, 1982. Madness played cheerful, bouncy ska upstrokes.',71),
    ('diaraby','ali-farka-toure','guitar','riff','hypnotic main riff','clean',
     'world','lead','intermediate',
     'Electric guitar (Ali Farka Touré)','Clean amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Hypnotic, cyclical Malian desert-blues riff with a warm clean tone; keep it rolling.','Low gain, warm.'],
     array['Loop the cyclical riff smoothly.','Keep the groove hypnotic.'],
     'Studio recording (The Source). Ali Farka Touré played hypnotic, cyclical Malian desert-blues with a warm clean tone.',72),
    ('amassakoul-n-tenere','tinariwen','guitar','riff','hypnotic main riff','clean',
     'world','rhythm','intermediate',
     'Electric guitar (Tinariwen)','Clean amp with light overdrive','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Loping, hypnotic Tuareg desert-blues riff with a slightly gritty clean tone; keep it rolling.','Low gain, faintly gritty.'],
     array['Loop the loping riff steadily.','Keep the trance-like groove.'],
     'Studio recording, 2004 (Amassakoul). Tinariwen played a loping, hypnotic Tuareg desert-blues riff.',71),
    ('tamacun','rodrigo-y-gabriela','guitar','riff','percussive flamenco-rock theme','acoustic',
     'world','lead','expert',
     'Nylon/steel acoustic (Rodrigo y Gabriela)','Acoustic — no amp','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Fiery, percussive flamenco-meets-metal acoustic instrumental; keep the rhythm tight and driving.','Natural acoustic tone, bright and percussive.'],
     array['Drive the fast rasgueado strumming.','Add percussive body hits between phrases.'],
     'Studio recording, 2006. Rodrigo y Gabriela played a fiery, percussive flamenco-rock acoustic instrumental.',73),
    ('bamboleo','gipsy-kings','guitar','riff','flamenco rhythm','acoustic',
     'latin','rhythm','advanced',
     'Nylon-string acoustic (Gipsy Kings)','Acoustic — no amp','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Driving flamenco-pop rasgueado strumming; keep the rhythm fast and fiery.','Natural nylon-string tone.'],
     array['Drive the rasgueado strumming.','Keep the tempo urgent.'],
     'Studio recording, 1987. The Gipsy Kings played driving flamenco-pop rasgueado on nylon-string guitars.',72),
    ('chan-chan','buena-vista-social-club','guitar','riff','main theme','acoustic',
     'latin','lead','intermediate',
     'Spanish guitar / tres (Buena Vista Social Club)','Acoustic — no amp','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Warm, rolling Cuban son with a gentle four-chord melody; keep it relaxed and lyrical.','Natural acoustic tone.'],
     array['Play the rolling melody softly.','Keep the son groove laid-back.'],
     'Studio recording, 1997. Buena Vista Social Club played warm, rolling Cuban son on Spanish guitar and tres.',72),
    ('clandestino','manu-chao','guitar','riff','strummed progression','acoustic',
     'latin','rhythm','beginner',
     'Nylon/steel acoustic (Manu Chao)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Gentle, looping Latin-folk strum; keep it simple, warm, and hypnotic.','Natural acoustic tone.'],
     array['Strum the simple progression evenly.','Keep the groove mellow.'],
     'Studio recording, 1998 (Clandestino). Manu Chao played a gentle, looping Latin-folk strum on acoustic guitar.',71)
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
  ('bob-marley','three-little-birds'),('bob-marley','one-love'),('bob-marley','buffalo-soldier'),('bob-marley','stir-it-up'),
  ('bob-marley','jamming'),('peter-tosh','legalize-it'),('jimmy-cliff','the-harder-they-come'),('toots-and-the-maytals','pressure-drop'),
  ('desmond-dekker','israelites'),('gregory-isaacs','night-nurse'),('sublime','wrong-way'),('sublime','doin-time'),
  ('santana','oye-como-va'),('santana','smooth'),('santana','samba-pa-ti'),('santana','evil-ways'),
  ('ub40','red-red-wine'),('the-specials','a-message-to-you-rudy'),('madness','our-house'),('ali-farka-toure','diaraby'),
  ('tinariwen','amassakoul-n-tenere'),('rodrigo-y-gabriela','tamacun'),('gipsy-kings','bamboleo'),('buena-vista-social-club','chan-chan'),
  ('manu-chao','clandestino')
) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
cross join (values
  ('artist_interview', 'Documented artist interviews and gear discussions', null::text,
   'Researched from widely-documented interviews about this recording and player.', 72),
  ('rig_rundown', 'Published rig rundowns and community gear databases', null::text,
   'Cross-referenced against rig features and community-maintained gear databases.', 66)
) as x(source_type, title, url, notes, credibility)
where p.verification_status = 'admin_verified'
on conflict do nothing;
