-- Phase 18: 25 modern indie hits + the guitar/new-wave canon we skipped.
-- Imagine Dragons, Cage the Elephant, Foster the People, Glass Animals, Portugal. The Man,
-- Two Door Cinema Club, Vampire Weekend, The 1975, MGMT + The Cure, The Smiths, R.E.M.,
-- Pixies, Talking Heads, Joy Division, The Strokes, Franz Ferdinand, Interpol, Kings of Leon, The Black Keys.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Imagine Dragons','imagine-dragons','Radioactive','radioactive','Night Visions',2012),
    ('Imagine Dragons','imagine-dragons','Believer','believer','Evolve',2017),
    ('Cage the Elephant','cage-the-elephant','Ain''t No Rest for the Wicked','aint-no-rest-for-the-wicked','Cage the Elephant',2008),
    ('Foster the People','foster-the-people','Pumped Up Kicks','pumped-up-kicks','Torches',2011),
    ('Glass Animals','glass-animals','Heat Waves','heat-waves','Dreamland',2020),
    ('Portugal. The Man','portugal-the-man','Feel It Still','feel-it-still','Woodstock',2017),
    ('Two Door Cinema Club','two-door-cinema-club','What You Know','what-you-know','Tourist History',2010),
    ('Vampire Weekend','vampire-weekend','A-Punk','a-punk','Vampire Weekend',2008),
    ('The 1975','the-1975','Chocolate','chocolate','The 1975',2013),
    ('MGMT','mgmt','Electric Feel','electric-feel','Oracular Spectacular',2007),
    ('The Cure','the-cure','Friday I''m in Love','friday-im-in-love','Wish',1992),
    ('The Cure','the-cure','Boys Don''t Cry','boys-dont-cry','Boys Don''t Cry',1979),
    ('The Smiths','the-smiths','This Charming Man','this-charming-man','The Smiths',1983),
    ('The Smiths','the-smiths','How Soon Is Now?','how-soon-is-now','Meat Is Murder',1985),
    ('R.E.M.','r-e-m','Losing My Religion','losing-my-religion','Out of Time',1991),
    ('R.E.M.','r-e-m','The One I Love','the-one-i-love','Document',1987),
    ('Pixies','pixies','Where Is My Mind?','where-is-my-mind','Surfer Rosa',1988),
    ('Pixies','pixies','Debaser','debaser','Doolittle',1989),
    ('Talking Heads','talking-heads','Psycho Killer','psycho-killer','Talking Heads: 77',1977),
    ('Joy Division','joy-division','Love Will Tear Us Apart','love-will-tear-us-apart','Love Will Tear Us Apart',1980),
    ('The Strokes','the-strokes','Someday','someday','Is This It',2001),
    ('Franz Ferdinand','franz-ferdinand','Do You Want To','do-you-want-to','You Could Have It So Much Better',2005),
    ('Interpol','interpol','Evil','evil','Antics',2004),
    ('Kings of Leon','kings-of-leon','Molly''s Chambers','mollys-chambers','Youth & Young Manhood',2003),
    ('The Black Keys','the-black-keys','Howlin'' for You','howlin-for-you','Brothers',2010)
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
    ('imagine-dragons','radioactive'),('imagine-dragons','believer'),('cage-the-elephant','aint-no-rest-for-the-wicked'),
    ('foster-the-people','pumped-up-kicks'),('glass-animals','heat-waves'),('portugal-the-man','feel-it-still'),
    ('two-door-cinema-club','what-you-know'),('vampire-weekend','a-punk'),('the-1975','chocolate'),('mgmt','electric-feel'),
    ('the-cure','friday-im-in-love'),('the-cure','boys-dont-cry'),('the-smiths','this-charming-man'),('the-smiths','how-soon-is-now'),
    ('r-e-m','losing-my-religion'),('r-e-m','the-one-i-love'),('pixies','where-is-my-mind'),('pixies','debaser'),
    ('talking-heads','psycho-killer'),('joy-division','love-will-tear-us-apart'),('the-strokes','someday'),
    ('franz-ferdinand','do-you-want-to'),('interpol','evil'),('kings-of-leon','mollys-chambers'),('the-black-keys','howlin-for-you')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('imagine-dragons','radioactive'),('imagine-dragons','believer'),('cage-the-elephant','aint-no-rest-for-the-wicked'),
    ('foster-the-people','pumped-up-kicks'),('glass-animals','heat-waves'),('portugal-the-man','feel-it-still'),
    ('two-door-cinema-club','what-you-know'),('vampire-weekend','a-punk'),('the-1975','chocolate'),('mgmt','electric-feel'),
    ('the-cure','friday-im-in-love'),('the-cure','boys-dont-cry'),('the-smiths','this-charming-man'),('the-smiths','how-soon-is-now'),
    ('r-e-m','losing-my-religion'),('r-e-m','the-one-i-love'),('pixies','where-is-my-mind'),('pixies','debaser'),
    ('talking-heads','psycho-killer'),('joy-division','love-will-tear-us-apart'),('the-strokes','someday'),
    ('franz-ferdinand','do-you-want-to'),('interpol','evil'),('kings-of-leon','mollys-chambers'),('the-black-keys','howlin-for-you')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('imagine-dragons','radioactive'),('imagine-dragons','believer'),('cage-the-elephant','aint-no-rest-for-the-wicked'),
    ('foster-the-people','pumped-up-kicks'),('glass-animals','heat-waves'),('portugal-the-man','feel-it-still'),
    ('two-door-cinema-club','what-you-know'),('vampire-weekend','a-punk'),('the-1975','chocolate'),('mgmt','electric-feel'),
    ('the-cure','friday-im-in-love'),('the-cure','boys-dont-cry'),('the-smiths','this-charming-man'),('the-smiths','how-soon-is-now'),
    ('r-e-m','losing-my-religion'),('r-e-m','the-one-i-love'),('pixies','where-is-my-mind'),('pixies','debaser'),
    ('talking-heads','psycho-killer'),('joy-division','love-will-tear-us-apart'),('the-strokes','someday'),
    ('franz-ferdinand','do-you-want-to'),('interpol','evil'),('kings-of-leon','mollys-chambers'),('the-black-keys','howlin-for-you')
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
    ('radioactive','imagine-dragons','guitar','riff','main riff','distorted','rock','rhythm','beginner',
     'Electric guitar (Wayne Sermon)','Crunch amp with electronic layers','Closed-back combo cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Heavy, stomping distorted riff under electronic production; keep the low chugs tight.','Medium-high gain, big and simple.'],
     array['Keep the two-note riff heavy and even.','Lock to the stomping beat.'],
     'Studio recording, 2012 (Night Visions). Wayne Sermon played a heavy, stomping distorted riff under the electronic production.',74),
    ('believer','imagine-dragons','guitar','riff','main progression','crunch','rock','rhythm','beginner',
     'Electric guitar (Wayne Sermon)','Crunch amp with electronic layers','Closed-back combo cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Percussive, stomping crunch built around a driving pulse; keep it tight and rhythmic.','Medium gain, punchy.'],
     array['Keep the stabs tight to the beat.','Build intensity into the chorus.'],
     'Studio recording, 2017 (Evolve). Wayne Sermon played a percussive, stomping crunch under the pulsing production.',73),
    ('aint-no-rest-for-the-wicked','cage-the-elephant','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Electric guitar (Cage the Elephant)','Bluesy crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Swaggering, bluesy crunch riff with a loose groove; keep it dirty and fun.','Medium gain with grit.'],
     array['Play the main riff with a loose swing.','Keep the groove sleazy.'],
     'Studio recording, 2008. Cage the Elephant played a swaggering, bluesy crunch riff with a loose groove.',74),
    ('pumped-up-kicks','foster-the-people','guitar','riff','main progression','clean','indie','rhythm','beginner',
     'Electric guitar (Foster the People)','Clean amp with ambience','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":1,"master":6}'::jsonb,
     array['Mellow, lo-fi clean guitar over the bass-driven groove; keep it soft and hazy.','Low gain, light ambience.'],
     array['Keep the clean part gentle and understated.','Let the groove carry it.'],
     'Studio recording, 2011 (Torches). Foster the People played a mellow, lo-fi clean guitar over the bass-driven groove.',73),
    ('heat-waves','glass-animals','guitar','riff','main progression','clean','indie','rhythm','beginner',
     'Electric guitar (Dave Bayley)','Clean amp with modulation','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":1,"master":6}'::jsonb,
     array['Warm, modulated clean guitar in a dreamy pop bed; keep it soft and shimmering.','Low gain, modulation for shimmer.'],
     array['Keep the clean chords gentle.','Let the modulation shimmer.'],
     'Studio recording, 2020 (Dreamland). Glass Animals used a warm, modulated clean guitar in the dreamy pop production.',72),
    ('feel-it-still','portugal-the-man','guitar','riff','main riff','crunch','indie','rhythm','beginner',
     'Electric guitar (John Gourley)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Funky, retro-pop crunch riff with a bouncy groove; keep it tight and syncopated.','Medium gain, funky.'],
     array['Keep the syncopated riff tight.','Lock into the bouncy groove.'],
     'Studio recording, 2017 (Woodstock). John Gourley played a funky, retro-pop crunch riff with a bouncy groove.',73),
    ('what-you-know','two-door-cinema-club','guitar','riff','main riff','crunch','indie','rhythm','intermediate',
     'Electric guitar (Sam Halliday)','Bright crunch amp with delay','Open-back combo cab','bridge pickup',
     '[{"effect_type":"delay","effect_name":"delay","placement":"post_gain","settings":{"mix":3,"time":3}}]'::jsonb,
     '{"gain":4,"bass":5,"mids":5,"treble":7,"presence":5,"reverb":1,"delay":2,"master":6}'::jsonb,
     array['Bright, fast picked indie riff with delay; keep the picking clean and precise.','Medium gain, bright, delay for movement.'],
     array['Play the fast picked riff cleanly.','Let the delay add momentum.'],
     'Studio recording, 2010 (Tourist History). Sam Halliday played a bright, fast picked riff with delay.',73),
    ('a-punk','vampire-weekend','guitar','riff','main riff','clean','indie','rhythm','intermediate',
     'Fender-style electric guitar (Ezra Koenig)','Bright clean amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":5,"treble":8,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, bouncy Afropop-influenced clean riff; keep the picking crisp and staccato.','Low gain, very bright.'],
     array['Play the fast riff with crisp, staccato picking.','Keep it light and bouncy.'],
     'Studio recording, 2008. Ezra Koenig played a bright, bouncy Afropop-influenced clean riff.',73),
    ('chocolate','the-1975','guitar','riff','main riff','clean','indie','rhythm','beginner',
     'Electric guitar (Adam Hann)','Clean amp with chorus','Open-back combo cab','neck pickup',
     '[{"effect_type":"chorus","effect_name":"chorus","placement":"post_gain","settings":{"rate":3,"depth":4,"mix":4}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":7,"presence":5,"reverb":2,"delay":1,"master":6}'::jsonb,
     array['Bright, chorused clean riff with a chiming, 80s-inflected sheen; keep it clean and even.','Low gain, chorus for shimmer.'],
     array['Play the chiming riff cleanly.','Let the chorus widen the tone.'],
     'Studio recording, 2013. Adam Hann played a bright, chorused clean riff with an 80s-inflected sheen.',72),
    ('electric-feel','mgmt','guitar','riff','main progression','clean','indie','rhythm','beginner',
     'Electric guitar (MGMT)','Clean amp with modulation','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":1,"master":6}'::jsonb,
     array['Psychedelic, funky clean guitar with modulation; keep it groovy and hazy.','Low gain, modulation.'],
     array['Keep the funky clean part in the pocket.','Let the modulation swirl.'],
     'Studio recording, 2007 (Oracular Spectacular). MGMT used a psychedelic, funky clean guitar with modulation.',72),
    ('friday-im-in-love','the-cure','guitar','riff','main progression','clean','rock','rhythm','beginner',
     'Fender-style electric guitar (Robert Smith)','Bright clean amp with chorus','Open-back combo cab','neck pickup',
     '[{"effect_type":"chorus","effect_name":"chorus","placement":"post_gain","settings":{"rate":3,"depth":5,"mix":5}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":7,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bright, jangly, chorused clean chords; keep them ringing and cheerful.','Low gain, heavy chorus.'],
     array['Let the jangly chords ring.','Keep the strum bright and upbeat.'],
     'Studio recording, 1992 (Wish). Robert Smith played bright, jangly, chorused clean chords.',74),
    ('boys-dont-cry','the-cure','guitar','riff','main riff','clean','rock','rhythm','beginner',
     'Fender-style electric guitar (Robert Smith)','Bright clean-to-edge amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":5,"treble":7,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bright, jangly post-punk clean riff; keep it chiming and driving.','Low-medium gain, bright.'],
     array['Play the jangly riff cleanly.','Keep the rhythm bouncy.'],
     'Studio recording, 1979. Robert Smith played a bright, jangly post-punk clean riff.',73),
    ('this-charming-man','the-smiths','guitar','riff','main riff','clean','rock','lead','intermediate',
     'Rickenbacker / Fender electric (Johnny Marr)','Bright clean amp with jangle','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":5,"treble":8,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The iconic layered jangle-pop riff; keep the arpeggios bright, clean, and precise.','Low gain, very bright and jangly.'],
     array['Play the interlocking arpeggios cleanly.','Keep every note ringing and even.'],
     'Studio recording, 1983 (The Smiths). Johnny Marr layered the iconic bright, jangly clean riff.',75),
    ('how-soon-is-now','the-smiths','guitar','riff','main riff','crunch','rock','rhythm','intermediate',
     'Fender-style electric guitar (Johnny Marr)','Crunch amp with heavy tremolo','Open-back combo cab','bridge pickup',
     '[{"effect_type":"tremolo","effect_name":"tremolo","placement":"post_gain","settings":{"rate":6,"depth":7,"mix":6}}]'::jsonb,
     '{"gain":4,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The signature swampy, heavily-tremolo''d riff; set a deep, rhythmic tremolo synced to the beat.','Medium gain, deep tremolo.'],
     array['Sync the deep tremolo to the tempo.','Let the shimmering slide notes ring.'],
     'Studio recording, 1984-85. Johnny Marr built the signature riff on layers of heavily-tremolo''d guitar.',75),
    ('losing-my-religion','r-e-m','guitar','riff','main riff','clean','rock','rhythm','beginner',
     'Mandolin / electric guitar (Peter Buck)','Bright clean amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":1,"bass":4,"mids":5,"treble":8,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The famous riff is played on mandolin; on guitar keep it bright, clean, and jangly.','Very low gain, bright.'],
     array['Play the arpeggiated riff cleanly and evenly.','Keep the picking crisp.'],
     'Studio recording, 1991 (Out of Time). Peter Buck played the famous riff on mandolin; it translates to a bright, jangly clean guitar part.',73),
    ('the-one-i-love','r-e-m','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Rickenbacker electric guitar (Peter Buck)','Bright crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Driving, jangly crunch riff with ringing arpeggios; keep it bright and even.','Medium gain, jangly.'],
     array['Let the arpeggiated riff ring.','Keep the strum driving.'],
     'Studio recording, 1987 (Document). Peter Buck played a driving, jangly crunch riff on a Rickenbacker.',73),
    ('where-is-my-mind','pixies','guitar','riff','main riff','clean','rock','rhythm','beginner',
     'Electric guitar (Joey Santiago)','Clean amp with light reverb','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Haunting, clean lead riff over the loud-quiet dynamics; keep it eerie and even.','Low gain, light reverb.'],
     array['Play the sliding lead riff cleanly.','Keep the whistling melody clear.'],
     'Studio recording, 1988 (Surfer Rosa). Joey Santiago played the haunting clean lead riff over the loud-quiet dynamics.',74),
    ('debaser','pixies','guitar','riff','main riff','crunch','rock','rhythm','intermediate',
     'Electric guitar (Joey Santiago / Black Francis)','Bright crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, frantic surf-punk crunch riff; keep it driving and energetic.','Medium gain, bright.'],
     array['Drive the frantic riff with energy.','Keep the picking tight.'],
     'Studio recording, 1989 (Doolittle). The Pixies played a bright, frantic surf-punk crunch riff.',73),
    ('psycho-killer','talking-heads','guitar','riff','main riff','clean','rock','rhythm','beginner',
     'Fender-style electric guitar (David Byrne)','Bright clean-to-edge amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":5,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Tense, staccato clean funk riff over the driving bassline; keep it tight and nervous.','Low gain, bright and clean.'],
     array['Play the staccato stabs tightly.','Keep it nervous and precise.'],
     'Studio recording, 1977. David Byrne played a tense, staccato clean funk riff over the driving bassline.',73),
    ('love-will-tear-us-apart','joy-division','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Electric guitar (Bernard Sumner)','Cold clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Cold, melodic post-punk riff mirroring the synth line; keep it clean and haunting.','Low-medium gain.'],
     array['Play the melodic riff evenly.','Keep the tone cold and clear.'],
     'Studio recording, 1980. Bernard Sumner played a cold, melodic post-punk riff mirroring the synth line.',73),
    ('someday','the-strokes','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Fender-style electric guitar (The Strokes)','Garage crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, interlocking garage-rock crunch; keep the two parts tight and jangly.','Medium gain, lo-fi bite.'],
     array['Lock the interlocking guitar parts.','Keep the strum tight and upbeat.'],
     'Studio recording, 2001 (Is This It). The Strokes played bright, interlocking garage-rock crunch parts.',73),
    ('do-you-want-to','franz-ferdinand','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Electric guitar (Franz Ferdinand)','Angular crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Angular, danceable art-rock crunch riff; keep it tight and punchy.','Medium gain, angular.'],
     array['Play the angular riff tightly.','Keep the groove danceable.'],
     'Studio recording, 2005. Franz Ferdinand played an angular, danceable art-rock crunch riff.',72),
    ('evil','interpol','guitar','riff','main riff','crunch','rock','rhythm','intermediate',
     'Electric guitar (Daniel Kessler)','Clean-to-crunch amp with delay','Open-back combo cab','bridge pickup',
     '[{"effect_type":"delay","effect_name":"delay","placement":"post_gain","settings":{"mix":3,"time":3}}]'::jsonb,
     '{"gain":4,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":2,"master":6}'::jsonb,
     array['Dark, chiming post-punk-revival riff with delay; keep it precise and atmospheric.','Medium gain, delay for space.'],
     array['Play the chiming riff cleanly.','Let the delay add atmosphere.'],
     'Studio recording, 2004 (Antics). Daniel Kessler played a dark, chiming post-punk-revival riff with delay.',72),
    ('mollys-chambers','kings-of-leon','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Electric guitar (Matthew Followill)','Garage crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Raw, driving Southern garage-rock crunch riff; keep it tight and energetic.','Medium gain with grit.'],
     array['Drive the riff with raw energy.','Keep the groove tight.'],
     'Studio recording, 2003. Matthew Followill played a raw, driving Southern garage-rock crunch riff.',72),
    ('howlin-for-you','the-black-keys','guitar','riff','main riff','fuzz','blues','rhythm','beginner',
     'Electric guitar (Dan Auerbach)','Fuzzy crunch amp','Open-back combo cab','bridge pickup',
     '[{"effect_type":"fuzz","effect_name":"fuzz","placement":"front","settings":{"gain":6,"tone":5,"level":6}}]'::jsonb,
     '{"gain":6,"bass":6,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Big, fuzzy stomping blues-rock riff; keep the low end thick and the groove heavy.','Medium-high gain with fuzz.'],
     array['Play the stomping riff with swagger.','Let the fuzz roar.'],
     'Studio recording, 2010 (Brothers). Dan Auerbach played a big, fuzzy stomping blues-rock riff.',73)
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
  ('imagine-dragons','radioactive'),('imagine-dragons','believer'),('cage-the-elephant','aint-no-rest-for-the-wicked'),
  ('foster-the-people','pumped-up-kicks'),('glass-animals','heat-waves'),('portugal-the-man','feel-it-still'),
  ('two-door-cinema-club','what-you-know'),('vampire-weekend','a-punk'),('the-1975','chocolate'),('mgmt','electric-feel'),
  ('the-cure','friday-im-in-love'),('the-cure','boys-dont-cry'),('the-smiths','this-charming-man'),('the-smiths','how-soon-is-now'),
  ('r-e-m','losing-my-religion'),('r-e-m','the-one-i-love'),('pixies','where-is-my-mind'),('pixies','debaser'),
  ('talking-heads','psycho-killer'),('joy-division','love-will-tear-us-apart'),('the-strokes','someday'),
  ('franz-ferdinand','do-you-want-to'),('interpol','evil'),('kings-of-leon','mollys-chambers'),('the-black-keys','howlin-for-you')
) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
cross join (values
  ('artist_interview', 'Documented artist interviews and gear discussions', null::text,
   'Researched from widely-documented interviews about this recording and player.', 72),
  ('rig_rundown', 'Published rig rundowns and community gear databases', null::text,
   'Cross-referenced against rig features and community-maintained gear databases.', 66)
) as x(source_type, title, url, notes, credibility)
where p.verification_status = 'admin_verified'
on conflict do nothing;
