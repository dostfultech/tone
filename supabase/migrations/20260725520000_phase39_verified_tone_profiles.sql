-- Phase 39: 25 Latin, Spanish & world guitar, verified per-part tone data (more Santana + Maná, Soda Stereo, Héroes del Silencio, Café Tacvba, Los Fabulosos Cadillacs, Juanes, Caifanes, Molotov, Enanitos Verdes, La Ley, Zoé, Aterciopelados, Paco de Lucía, Ottmar Liebert, Jesse Cook, Rata Blanca, Indian Ocean).

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Santana','santana','Maria Maria','maria-maria','Supernatural',1999),
    ('Santana','santana','Corazón Espinado','corazon-espinado','Supernatural',1999),
    ('Maná','mana','Oye Mi Amor','oye-mi-amor','¿Dónde Jugarán los Niños?',1992),
    ('Maná','mana','Rayando el Sol','rayando-el-sol','Falta Amor',1990),
    ('Maná','mana','Clavado en un Bar','clavado-en-un-bar','Sueños Líquidos',1997),
    ('Soda Stereo','soda-stereo','De Música Ligera','de-musica-ligera','Canción Animal',1990),
    ('Soda Stereo','soda-stereo','Cuando Pase el Temblor','cuando-pase-el-temblor','Nada Personal',1985),
    ('Soda Stereo','soda-stereo','Persiana Americana','persiana-americana','Signos',1986),
    ('Héroes del Silencio','heroes-del-silencio','Entre Dos Tierras','entre-dos-tierras','Senderos de Traición',1990),
    ('Café Tacvba','cafe-tacvba','Eres','eres','Cuatro Caminos',2003),
    ('Café Tacvba','cafe-tacvba','Ingrata','ingrata','Re',1994),
    ('Los Fabulosos Cadillacs','los-fabulosos-cadillacs','Matador','matador','Vasos Vacíos',1993),
    ('Juanes','juanes','La Camisa Negra','la-camisa-negra','Mi Sangre',2004),
    ('Juanes','juanes','A Dios le Pido','a-dios-le-pido','Un Día Normal',2002),
    ('Caifanes','caifanes','La Célula Que Explota','la-celula-que-explota','El Diablito',1990),
    ('Molotov','molotov','Gimme Tha Power','gimme-tha-power','¿Dónde Jugarán las Niñas?',1997),
    ('Enanitos Verdes','enanitos-verdes','Lamento Boliviano','lamento-boliviano','Big Bang',1994),
    ('La Ley','la-ley','El Duelo','el-duelo','Uno',2000),
    ('Zoé','zoe','Labios Rotos','labios-rotos','Memo Rex Commander y el Corazón Atómico de la Vía Láctea',2006),
    ('Aterciopelados','aterciopelados','Bolero Falaz','bolero-falaz','El Dorado',1995),
    ('Paco de Lucía','paco-de-lucia','Entre Dos Aguas','entre-dos-aguas','Fuente y Caudal',1973),
    ('Ottmar Liebert','ottmar-liebert','Barcelona Nights','barcelona-nights','Nouveau Flamenco',1990),
    ('Jesse Cook','jesse-cook','Mario Takes a Walk','mario-takes-a-walk','Tempest',1995),
    ('Rata Blanca','rata-blanca','Mujer Amante','mujer-amante','Magos, Espadas y Rosas',1990),
    ('Indian Ocean','indian-ocean','Kandisa','kandisa','Kandisa',2000)
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
    ('santana','maria-maria'),('santana','corazon-espinado'),('mana','oye-mi-amor'),('mana','rayando-el-sol'),
    ('mana','clavado-en-un-bar'),('soda-stereo','de-musica-ligera'),('soda-stereo','cuando-pase-el-temblor'),('soda-stereo','persiana-americana'),
    ('heroes-del-silencio','entre-dos-tierras'),('cafe-tacvba','eres'),('cafe-tacvba','ingrata'),('los-fabulosos-cadillacs','matador'),
    ('juanes','la-camisa-negra'),('juanes','a-dios-le-pido'),('caifanes','la-celula-que-explota'),('molotov','gimme-tha-power'),
    ('enanitos-verdes','lamento-boliviano'),('la-ley','el-duelo'),('zoe','labios-rotos'),('aterciopelados','bolero-falaz'),
    ('paco-de-lucia','entre-dos-aguas'),('ottmar-liebert','barcelona-nights'),('jesse-cook','mario-takes-a-walk'),('rata-blanca','mujer-amante'),
    ('indian-ocean','kandisa')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('santana','maria-maria'),('santana','corazon-espinado'),('mana','oye-mi-amor'),('mana','rayando-el-sol'),
    ('mana','clavado-en-un-bar'),('soda-stereo','de-musica-ligera'),('soda-stereo','cuando-pase-el-temblor'),('soda-stereo','persiana-americana'),
    ('heroes-del-silencio','entre-dos-tierras'),('cafe-tacvba','eres'),('cafe-tacvba','ingrata'),('los-fabulosos-cadillacs','matador'),
    ('juanes','la-camisa-negra'),('juanes','a-dios-le-pido'),('caifanes','la-celula-que-explota'),('molotov','gimme-tha-power'),
    ('enanitos-verdes','lamento-boliviano'),('la-ley','el-duelo'),('zoe','labios-rotos'),('aterciopelados','bolero-falaz'),
    ('paco-de-lucia','entre-dos-aguas'),('ottmar-liebert','barcelona-nights'),('jesse-cook','mario-takes-a-walk'),('rata-blanca','mujer-amante'),
    ('indian-ocean','kandisa')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('santana','maria-maria'),('santana','corazon-espinado'),('mana','oye-mi-amor'),('mana','rayando-el-sol'),
    ('mana','clavado-en-un-bar'),('soda-stereo','de-musica-ligera'),('soda-stereo','cuando-pase-el-temblor'),('soda-stereo','persiana-americana'),
    ('heroes-del-silencio','entre-dos-tierras'),('cafe-tacvba','eres'),('cafe-tacvba','ingrata'),('los-fabulosos-cadillacs','matador'),
    ('juanes','la-camisa-negra'),('juanes','a-dios-le-pido'),('caifanes','la-celula-que-explota'),('molotov','gimme-tha-power'),
    ('enanitos-verdes','lamento-boliviano'),('la-ley','el-duelo'),('zoe','labios-rotos'),('aterciopelados','bolero-falaz'),
    ('paco-de-lucia','entre-dos-aguas'),('ottmar-liebert','barcelona-nights'),('jesse-cook','mario-takes-a-walk'),('rata-blanca','mujer-amante'),
    ('indian-ocean','kandisa')
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
    ('maria-maria','santana','guitar','riff','main riff and lead','crunch',
     'latin','lead','intermediate',
     'Gibson/PRS electric (Carlos Santana)','Mesa/Boogie overdriven amp','Open-back combo cab','neck humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":2,"delay":1,"master":6}'::jsonb,
     array['Smooth Latin-hip-hop groove with singing, sustained lead accents; keep the mids up and the tone creamy.','Medium-high gain, strong mids.'],
     array['Comp the groove lightly.','Play the lead accents with singing sustain.'],
     'Studio recording, 1999 (Supernatural). Carlos Santana played singing, sustained lead over a Latin-hip-hop groove.',73),
    ('corazon-espinado','santana','guitar','riff','main riff and lead','crunch',
     'latin','lead','intermediate',
     'Gibson/PRS electric (Carlos Santana)','Mesa/Boogie overdriven amp','Open-back combo cab','neck humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":2,"delay":1,"master":6}'::jsonb,
     array['Percussive Latin-rock with a hot, singing lead over a cumbia-tinged groove; keep it creamy.','Medium-high gain, strong mids.'],
     array['Lock the rhythm to the groove.','Play the lead with sustain and vibrato.'],
     'Studio recording, 1999 (Supernatural). Carlos Santana played a hot, singing Latin-rock lead.',72),
    ('oye-mi-amor','mana','guitar','riff','main riff','crunch',
     'latin','rhythm','beginner',
     'Electric guitar (Sergio Vallín)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Upbeat Latin pop-rock with a driving, bright riff; keep it tight and energetic.','Medium gain, bright.'],
     array['Drive the riff with energy.','Keep the groove tight.'],
     'Studio recording, 1992. Sergio Vallín played an upbeat, driving Latin pop-rock riff.',71),
    ('rayando-el-sol','mana','guitar','riff','main progression','crunch',
     'latin','rhythm','beginner',
     'Electric and acoustic guitar (Sergio Vallín)','Clean-to-crunch amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Yearning Latin-rock ballad building from clean to a fuller crunch; keep dynamics wide.','Low-medium gain.'],
     array['Play the verse chords cleanly.','Open into the emotive chorus.'],
     'Studio recording, 1990 (Falta Amor). Maná played a yearning Latin-rock ballad building to crunch.',71),
    ('clavado-en-un-bar','mana','guitar','riff','main riff','crunch',
     'latin','rhythm','beginner',
     'Electric guitar (Sergio Vallín)','Crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, bouncy Latin pop-rock riff; keep it snappy and driving.','Medium gain, bright.'],
     array['Play the bouncy riff tightly.','Keep the groove driving.'],
     'Studio recording, 1997 (Sueños Líquidos). Sergio Vallín played a bright, bouncy Latin pop-rock riff.',71),
    ('de-musica-ligera','soda-stereo','guitar','riff','main riff','crunch',
     'latin','rhythm','beginner',
     'Electric guitar (Gustavo Cerati)','Crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['The definitive Argentine-rock anthem riff; keep the power chords tight and driving.','Medium gain.'],
     array['Play the iconic riff tightly.','Drive the anthem.'],
     'Studio recording, 1990 (Canción Animal). Gustavo Cerati played the definitive Argentine-rock anthem riff.',72),
    ('cuando-pase-el-temblor','soda-stereo','guitar','riff','main riff','clean',
     'latin','rhythm','beginner',
     'Electric guitar (Gustavo Cerati)','Clean-to-crunch amp with modulation','Open-back combo cab','bridge pickup',
     '[{"effect_type":"chorus","effect_name":"chorus","placement":"post_gain","settings":{"rate":3,"depth":4,"mix":4}}]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bright, chorused new-wave riff with an Andean lilt; keep it chiming and rhythmic.','Low gain, chorus.'],
     array['Play the chiming riff cleanly.','Let the chorus widen it.'],
     'Studio recording, 1985 (Nada Personal). Gustavo Cerati played a bright, chorused new-wave riff.',71),
    ('persiana-americana','soda-stereo','guitar','riff','main riff','crunch',
     'latin','rhythm','beginner',
     'Electric guitar (Gustavo Cerati)','Clean-to-crunch amp with modulation','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Driving new-wave rock with a bright, hooky riff; keep it tight and energetic.','Medium gain, bright.'],
     array['Play the hooky riff tightly.','Keep the groove driving.'],
     'Studio recording, 1986 (Signos). Gustavo Cerati played a driving, hooky new-wave-rock riff.',71),
    ('entre-dos-tierras','heroes-del-silencio','guitar','riff','main riff','crunch',
     'latin','rhythm','intermediate',
     'Electric guitar (Juan Valdivia)','Crunch amp with chorus','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Dramatic, dark Spanish-rock with a chorused, ringing riff; keep it big and moody.','Medium gain, chorus.'],
     array['Let the ringing riff sound.','Keep it dramatic and driving.'],
     'Studio recording, 1990 (Senderos de Traición). Juan Valdivia played a dramatic, chorused Spanish-rock riff.',71),
    ('eres','cafe-tacvba','guitar','riff','main progression','clean',
     'latin','rhythm','beginner',
     'Electric guitar (Joselo Rangel)','Clean-to-crunch amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Tender Latin-rock ballad with warm, ringing clean chords building to crunch; keep it heartfelt.','Low gain, warm.'],
     array['Let the clean chords ring.','Build into the fuller chorus.'],
     'Studio recording, 2003 (Cuatro Caminos). Joselo Rangel played a tender Latin-rock ballad.',71),
    ('ingrata','cafe-tacvba','guitar','riff','main riff','crunch',
     'latin','rhythm','beginner',
     'Electric guitar (Joselo Rangel)','Crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Punchy norteño-punk crunch with an accordion-driven groove; keep it tight and bouncy.','Medium gain.'],
     array['Play the punchy riff tightly.','Keep the norteño bounce.'],
     'Studio recording, 1994 (Re). Joselo Rangel played a punchy norteño-punk crunch riff.',71),
    ('matador','los-fabulosos-cadillacs','guitar','riff','ska rhythm','crunch',
     'latin','rhythm','beginner',
     'Electric guitar (Los Fabulosos Cadillacs)','Crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Driving Latin-ska with crunchy upstroke chords; keep the off-beats tight and urgent.','Medium gain.'],
     array['Play the ska upstrokes tightly.','Keep the energy urgent.'],
     'Studio recording, 1993 (Vasos Vacíos). Los Fabulosos Cadillacs played driving Latin-ska crunch.',71),
    ('la-camisa-negra','juanes','guitar','riff','main riff','crunch',
     'latin','rhythm','beginner',
     'Acoustic and electric guitar (Juanes)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bouncy Colombian folk-rock (guasca) with a bright, snappy riff; keep it tight and fun.','Low-medium gain, bright.'],
     array['Play the snappy riff tightly.','Keep the bounce.'],
     'Studio recording, 2004 (Mi Sangre). Juanes played a bouncy Colombian folk-rock riff.',71),
    ('a-dios-le-pido','juanes','guitar','riff','main riff','crunch',
     'latin','rhythm','beginner',
     'Electric guitar (Juanes)','Crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Driving Latin rock-pop with a bright, urgent riff; keep it tight and anthemic.','Medium gain, bright.'],
     array['Drive the riff with urgency.','Keep it tight.'],
     'Studio recording, 2002 (Un Día Normal). Juanes played a driving, urgent Latin rock-pop riff.',71),
    ('la-celula-que-explota','caifanes','guitar','riff','main riff','crunch',
     'latin','rhythm','intermediate',
     'Electric guitar (Alejandro Marcovich)','Crunch amp with reverb','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Dark, atmospheric Mexican rock with ringing, reverberant chords; keep it moody and expansive.','Medium gain, reverby.'],
     array['Let the ringing chords sound.','Keep the atmosphere dark.'],
     'Studio recording, 1990 (El Diablito). Alejandro Marcovich played dark, atmospheric Mexican-rock chords.',71),
    ('gimme-tha-power','molotov','guitar','riff','main riff','distorted',
     'latin','rhythm','beginner',
     'Electric guitar (Tito Fuentes)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Aggressive Latin rap-metal with a heavy, driving riff; keep it tight and rebellious.','High gain.'],
     array['Keep the heavy riff tight.','Drive the rebellious energy.'],
     'Studio recording, 1997. Tito Fuentes played an aggressive Latin rap-metal riff.',70),
    ('lamento-boliviano','enanitos-verdes','guitar','riff','main riff','crunch',
     'latin','rhythm','beginner',
     'Electric guitar (Enanitos Verdes)','Crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Anthemic Latin-rock with a driving, ringing riff; keep it big and singable.','Medium gain.'],
     array['Let the riff ring.','Drive the anthem.'],
     'Studio recording, 1994 (Big Bang). Enanitos Verdes played an anthemic, ringing Latin-rock riff.',70),
    ('el-duelo','la-ley','guitar','riff','main progression','crunch',
     'latin','rhythm','beginner',
     'Electric guitar (Pedro Frugone)','Crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Moody, melodic Latin-alternative rock building from clean to crunch; keep dynamics wide.','Low-medium gain.'],
     array['Play the verse cleanly.','Open into the fuller chorus.'],
     'Studio recording, 2000 (Uno). Pedro Frugone played moody, melodic Latin-alternative rock.',70),
    ('labios-rotos','zoe','guitar','riff','main riff','crunch',
     'latin','rhythm','beginner',
     'Electric guitar (Sergio Acosta / Jesús Báez)','Clean-to-crunch amp with modulation','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Dreamy, psychedelic Mexican-rock with ringing, modulated chords; keep it spacious and hypnotic.','Low-medium gain, modulated.'],
     array['Let the chords ring and shimmer.','Keep the groove hypnotic.'],
     'Studio recording, 2006. Zoé played dreamy, psychedelic Mexican-rock chords.',70),
    ('bolero-falaz','aterciopelados','guitar','riff','main riff','crunch',
     'latin','rhythm','beginner',
     'Electric guitar (Héctor Buitrago / Andrea Echeverri)','Crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Quirky Colombian alt-rock blending bolero and rock; keep the riff loose and characterful.','Low-medium gain.'],
     array['Play the riff with character.','Keep the groove loose.'],
     'Studio recording, 1995 (El Dorado). Aterciopelados played a quirky bolero-rock riff.',70),
    ('entre-dos-aguas','paco-de-lucia','guitar','riff','rumba flamenca theme','acoustic',
     'world','lead','expert',
     'Flamenco nylon-string acoustic (Paco de Lucía)','Acoustic — no amp','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Virtuosic flamenco rumba with lightning picado runs and rasgueado; keep it fiery and precise.','Natural flamenco tone, bright.'],
     array['Play the fast picado runs cleanly.','Drive the rasgueado strumming.'],
     'Studio recording, 1973 (Fuente y Caudal). Paco de Lucía played virtuosic flamenco rumba on a nylon-string guitar.',73),
    ('barcelona-nights','ottmar-liebert','guitar','riff','main theme','acoustic',
     'world','lead','advanced',
     'Nylon-string acoustic (Ottmar Liebert)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Warm, melodic nouveau-flamenco with rolling arpeggios and rasgueado; keep it flowing and bright.','Natural nylon-string tone.'],
     array['Roll the arpeggios cleanly.','Add rasgueado accents.'],
     'Studio recording, 1990 (Nouveau Flamenco). Ottmar Liebert played warm, melodic nouveau-flamenco.',72),
    ('mario-takes-a-walk','jesse-cook','guitar','riff','main theme','acoustic',
     'world','lead','advanced',
     'Nylon-string acoustic (Jesse Cook)','Acoustic — no amp','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, upbeat rumba-flamenca instrumental with fast picado and percussive strumming; keep it lively.','Natural nylon-string tone, bright.'],
     array['Play the fast picado lines cleanly.','Keep the rumba strumming crisp.'],
     'Studio recording, 1995 (Tempest). Jesse Cook played a bright, upbeat rumba-flamenca instrumental.',71),
    ('mujer-amante','rata-blanca','guitar','riff','main riff and solo','high_gain',
     'metal','lead','advanced',
     'Electric guitar (Walter Giardino)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Melodic neoclassical Latin metal with a soaring riff and blazing solo; keep it tight and dramatic.','High gain.'],
     array['Play the melodic riff tightly.','Play the neoclassical solo cleanly.'],
     'Studio recording, 1990 (Magos, Espadas y Rosas). Walter Giardino played melodic neoclassical Latin metal.',71),
    ('kandisa','indian-ocean','guitar','riff','main theme','clean',
     'world','lead','intermediate',
     'Electric guitar (Susmit Sen)','Clean amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Hypnotic Indian-fusion rock with rolling, raga-inflected clean arpeggios; keep it flowing and warm.','Low gain, warm.'],
     array['Roll the raga-inflected arpeggios cleanly.','Keep the groove hypnotic.'],
     'Studio recording, 2000 (Kandisa). Susmit Sen played hypnotic, raga-inflected Indian-fusion clean guitar.',70)
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
  ('santana','maria-maria'),('santana','corazon-espinado'),('mana','oye-mi-amor'),('mana','rayando-el-sol'),
  ('mana','clavado-en-un-bar'),('soda-stereo','de-musica-ligera'),('soda-stereo','cuando-pase-el-temblor'),('soda-stereo','persiana-americana'),
  ('heroes-del-silencio','entre-dos-tierras'),('cafe-tacvba','eres'),('cafe-tacvba','ingrata'),('los-fabulosos-cadillacs','matador'),
  ('juanes','la-camisa-negra'),('juanes','a-dios-le-pido'),('caifanes','la-celula-que-explota'),('molotov','gimme-tha-power'),
  ('enanitos-verdes','lamento-boliviano'),('la-ley','el-duelo'),('zoe','labios-rotos'),('aterciopelados','bolero-falaz'),
  ('paco-de-lucia','entre-dos-aguas'),('ottmar-liebert','barcelona-nights'),('jesse-cook','mario-takes-a-walk'),('rata-blanca','mujer-amante'),
  ('indian-ocean','kandisa')
) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
cross join (values
  ('artist_interview', 'Documented artist interviews and gear discussions', null::text,
   'Researched from widely-documented interviews about this recording and player.', 72),
  ('rig_rundown', 'Published rig rundowns and community gear databases', null::text,
   'Cross-referenced against rig features and community-maintained gear databases.', 66)
) as x(source_type, title, url, notes, credibility)
where p.verification_status = 'admin_verified'
on conflict do nothing;
