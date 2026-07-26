-- Phase 37: 25 2010s indie/alt depth, verified per-part tone data (more Tame Impala, Arctic Monkeys, Black Keys, Kings of Leon, Killers, Cage the Elephant, Vampire Weekend, Two Door Cinema Club + Foals, alt-J, War on Drugs, Mac DeMarco, Bombay Bicycle Club, Grizzly Bear, The xx, Beach House, Catfish and the Bottlemen, Death Cab for Cutie).

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Tame Impala','tame-impala','Elephant','elephant','Lonerism',2012),
    ('Tame Impala','tame-impala','Feels Like We Only Go Backwards','feels-like-we-only-go-backwards','Lonerism',2012),
    ('Tame Impala','tame-impala','Let It Happen','let-it-happen','Currents',2015),
    ('Arctic Monkeys','arctic-monkeys','When the Sun Goes Down','when-the-sun-goes-down','Whatever People Say I Am, That''s What I''m Not',2006),
    ('Arctic Monkeys','arctic-monkeys','Why''d You Only Call Me When You''re High?','whyd-you-only-call-me-when-youre-high','AM',2013),
    ('Arctic Monkeys','arctic-monkeys','Brianstorm','brianstorm','Favourite Worst Nightmare',2007),
    ('The Black Keys','the-black-keys','Tighten Up','tighten-up','Brothers',2010),
    ('The Black Keys','the-black-keys','Fever','fever','Turn Blue',2014),
    ('Kings of Leon','kings-of-leon','The Bucket','the-bucket','Aha Shake Heartbreak',2004),
    ('The Killers','the-killers','All These Things That I''ve Done','all-these-things-that-ive-done','Hot Fuss',2004),
    ('Cage the Elephant','cage-the-elephant','Come a Little Closer','come-a-little-closer','Melophobia',2013),
    ('Cage the Elephant','cage-the-elephant','Cigarette Daydreams','cigarette-daydreams','Melophobia',2013),
    ('Foals','foals','My Number','my-number','Holy Fire',2013),
    ('Foals','foals','Mountain at My Gates','mountain-at-my-gates','What Went Down',2015),
    ('alt-J','alt-j','Breezeblocks','breezeblocks','An Awesome Wave',2012),
    ('The War on Drugs','the-war-on-drugs','Red Eyes','red-eyes','Lost in the Dream',2014),
    ('Mac DeMarco','mac-demarco','My Kind of Woman','my-kind-of-woman','2',2012),
    ('Vampire Weekend','vampire-weekend','Harmony Hall','harmony-hall','Father of the Bride',2019),
    ('Bombay Bicycle Club','bombay-bicycle-club','Shuffle','shuffle','A Different Kind of Fix',2011),
    ('Two Door Cinema Club','two-door-cinema-club','Undercover Martyn','undercover-martyn','Tourist History',2010),
    ('Grizzly Bear','grizzly-bear','Two Weeks','two-weeks','Veckatimest',2009),
    ('The xx','the-xx','Crystalised','crystalised','xx',2009),
    ('Beach House','beach-house','Space Song','space-song','Depression Cherry',2015),
    ('Catfish and the Bottlemen','catfish-and-the-bottlemen','Cocoon','cocoon','The Balcony',2014),
    ('Death Cab for Cutie','death-cab-for-cutie','I Will Follow You into the Dark','i-will-follow-you-into-the-dark','Plans',2005)
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
    ('tame-impala','elephant'),('tame-impala','feels-like-we-only-go-backwards'),('tame-impala','let-it-happen'),('arctic-monkeys','when-the-sun-goes-down'),
    ('arctic-monkeys','whyd-you-only-call-me-when-youre-high'),('arctic-monkeys','brianstorm'),('the-black-keys','tighten-up'),('the-black-keys','fever'),
    ('kings-of-leon','the-bucket'),('the-killers','all-these-things-that-ive-done'),('cage-the-elephant','come-a-little-closer'),('cage-the-elephant','cigarette-daydreams'),
    ('foals','my-number'),('foals','mountain-at-my-gates'),('alt-j','breezeblocks'),('the-war-on-drugs','red-eyes'),
    ('mac-demarco','my-kind-of-woman'),('vampire-weekend','harmony-hall'),('bombay-bicycle-club','shuffle'),('two-door-cinema-club','undercover-martyn'),
    ('grizzly-bear','two-weeks'),('the-xx','crystalised'),('beach-house','space-song'),('catfish-and-the-bottlemen','cocoon'),
    ('death-cab-for-cutie','i-will-follow-you-into-the-dark')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('tame-impala','elephant'),('tame-impala','feels-like-we-only-go-backwards'),('tame-impala','let-it-happen'),('arctic-monkeys','when-the-sun-goes-down'),
    ('arctic-monkeys','whyd-you-only-call-me-when-youre-high'),('arctic-monkeys','brianstorm'),('the-black-keys','tighten-up'),('the-black-keys','fever'),
    ('kings-of-leon','the-bucket'),('the-killers','all-these-things-that-ive-done'),('cage-the-elephant','come-a-little-closer'),('cage-the-elephant','cigarette-daydreams'),
    ('foals','my-number'),('foals','mountain-at-my-gates'),('alt-j','breezeblocks'),('the-war-on-drugs','red-eyes'),
    ('mac-demarco','my-kind-of-woman'),('vampire-weekend','harmony-hall'),('bombay-bicycle-club','shuffle'),('two-door-cinema-club','undercover-martyn'),
    ('grizzly-bear','two-weeks'),('the-xx','crystalised'),('beach-house','space-song'),('catfish-and-the-bottlemen','cocoon'),
    ('death-cab-for-cutie','i-will-follow-you-into-the-dark')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('tame-impala','elephant'),('tame-impala','feels-like-we-only-go-backwards'),('tame-impala','let-it-happen'),('arctic-monkeys','when-the-sun-goes-down'),
    ('arctic-monkeys','whyd-you-only-call-me-when-youre-high'),('arctic-monkeys','brianstorm'),('the-black-keys','tighten-up'),('the-black-keys','fever'),
    ('kings-of-leon','the-bucket'),('the-killers','all-these-things-that-ive-done'),('cage-the-elephant','come-a-little-closer'),('cage-the-elephant','cigarette-daydreams'),
    ('foals','my-number'),('foals','mountain-at-my-gates'),('alt-j','breezeblocks'),('the-war-on-drugs','red-eyes'),
    ('mac-demarco','my-kind-of-woman'),('vampire-weekend','harmony-hall'),('bombay-bicycle-club','shuffle'),('two-door-cinema-club','undercover-martyn'),
    ('grizzly-bear','two-weeks'),('the-xx','crystalised'),('beach-house','space-song'),('catfish-and-the-bottlemen','cocoon'),
    ('death-cab-for-cutie','i-will-follow-you-into-the-dark')
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
    ('elephant','tame-impala','guitar','riff','main riff','fuzz',
     'rock','rhythm','beginner',
     'Electric guitar (Kevin Parker)','Fuzzy amp with modulation','Closed-back combo cab','bridge humbucker',
     '[{"effect_type":"fuzz","effect_name":"fuzz","placement":"front","settings":{"gain":7,"tone":5,"level":6}}]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Big, stomping psych-rock fuzz riff; keep it thick and swaggering.','High gain with fuzz.'],
     array['Play the stomping riff with swagger.','Let the fuzz roar.'],
     'Studio recording, 2012 (Lonerism). Kevin Parker played a big, stomping psych-rock fuzz riff.',72),
    ('feels-like-we-only-go-backwards','tame-impala','guitar','riff','main progression','clean',
     'rock','rhythm','beginner',
     'Electric guitar (Kevin Parker)','Clean amp with modulation','Open-back combo cab','neck pickup',
     '[{"effect_type":"chorus","effect_name":"phaser","placement":"post_gain","settings":{"rate":3,"depth":5,"mix":5}}]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Warped, phasey psych-pop clean chords; keep them dreamy and swirling.','Low gain, heavy modulation.'],
     array['Play the chords softly.','Let the phaser swirl the tone.'],
     'Studio recording, 2012 (Lonerism). Kevin Parker played warped, phasey psych-pop clean chords.',71),
    ('let-it-happen','tame-impala','guitar','riff','main riff','crunch',
     'rock','rhythm','intermediate',
     'Electric guitar (Kevin Parker)','Clean-to-crunch amp with modulation','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Disco-psych groove with driving, modulated guitar stabs; keep it tight and hypnotic.','Medium gain, modulation.'],
     array['Play the stabs tightly.','Keep the groove hypnotic.'],
     'Studio recording, 2015 (Currents). Kevin Parker played driving, modulated disco-psych guitar.',71),
    ('when-the-sun-goes-down','arctic-monkeys','guitar','riff','clean intro to crunch','crunch',
     'indie','rhythm','intermediate',
     'Electric guitar (Jamie Cook / Alex Turner)','Crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Gentle clean intro erupting into frantic garage-indie crunch; keep the contrast wide.','Medium gain for the loud parts.'],
     array['Play the clean intro softly.','Slam into the frantic riff.'],
     'Studio recording, 2006. Jamie Cook played a clean intro erupting into frantic garage-indie crunch.',72),
    ('whyd-you-only-call-me-when-youre-high','arctic-monkeys','guitar','riff','main riff','clean',
     'indie','rhythm','beginner',
     'Electric guitar (Jamie Cook / Alex Turner)','Clean-to-crunch amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Slinky, late-night clean groove with a bluesy lilt; keep it smooth and laid-back.','Low gain, warm.'],
     array['Play the slinky riff smoothly.','Keep the groove laid-back.'],
     'Studio recording, 2013 (AM). Arctic Monkeys played a slinky, late-night clean groove.',72),
    ('brianstorm','arctic-monkeys','guitar','riff','main riff','distorted',
     'indie','rhythm','advanced',
     'Electric guitar (Jamie Cook / Alex Turner)','High-gain amp','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Frantic, fast tremolo-picked indie-punk riff; keep the picking relentless and tight.','High gain.'],
     array['Play the fast tremolo riff tightly.','Keep the energy frantic.'],
     'Studio recording, 2007. Jamie Cook played a frantic, fast tremolo-picked indie-punk riff.',72),
    ('tighten-up','the-black-keys','guitar','riff','main riff','crunch',
     'blues','rhythm','beginner',
     'Electric guitar (Dan Auerbach)','Fuzzy crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Greasy, bluesy garage-rock crunch riff with a whistled hook; keep it loose and fat.','Medium gain with grit.'],
     array['Play the riff with a greasy groove.','Keep it loose and fat.'],
     'Studio recording, 2010 (Brothers). Dan Auerbach played a greasy, bluesy garage-rock crunch riff.',72),
    ('fever','the-black-keys','guitar','riff','main riff','crunch',
     'rock','rhythm','beginner',
     'Electric guitar (Dan Auerbach)','Clean-to-crunch amp with modulation','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Psychedelic, organ-tinged garage-pop crunch; keep the riff tight and hypnotic.','Medium gain, modulation.'],
     array['Keep the riff tight.','Lock to the hypnotic groove.'],
     'Studio recording, 2014 (Turn Blue). Dan Auerbach played a psychedelic, organ-tinged garage-pop riff.',71),
    ('the-bucket','kings-of-leon','guitar','riff','main riff','crunch',
     'rock','rhythm','beginner',
     'Electric guitar (Matthew Followill)','Crunch amp with delay','Open-back combo cab','bridge pickup',
     '[{"effect_type":"delay","effect_name":"delay","placement":"post_gain","settings":{"mix":3,"time":3}}]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, jangly Southern garage-rock riff with delay; keep it snappy and ringing.','Medium gain, bright, delay.'],
     array['Play the jangly riff cleanly.','Let the delay add movement.'],
     'Studio recording, 2004 (Aha Shake Heartbreak). Matthew Followill played a bright, jangly garage-rock riff with delay.',71),
    ('all-these-things-that-ive-done','the-killers','guitar','riff','main riff','crunch',
     'rock','rhythm','beginner',
     'Electric guitar (Dave Keuning)','Crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Anthemic, building new-wave-rock crunch with big ringing chords; keep it driving.','Medium gain.'],
     array['Let the ringing chords build.','Drive into the gospel-tinged climax.'],
     'Studio recording, 2004 (Hot Fuss). Dave Keuning played anthemic, building new-wave-rock crunch.',72),
    ('come-a-little-closer','cage-the-elephant','guitar','riff','main riff','crunch',
     'rock','rhythm','beginner',
     'Electric guitar (Cage the Elephant)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, psychedelic alt-rock with a swaying riff; keep it loose and hypnotic.','Medium gain.'],
     array['Play the swaying riff loosely.','Keep the groove hypnotic.'],
     'Studio recording, 2013 (Melophobia). Cage the Elephant played a warm, psychedelic alt-rock riff.',71),
    ('cigarette-daydreams','cage-the-elephant','guitar','riff','main progression','crunch',
     'rock','rhythm','beginner',
     'Electric and acoustic guitar (Cage the Elephant)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, jangly folk-rock that builds to a fuller crunch; keep the chords ringing.','Low-medium gain.'],
     array['Let the jangly chords ring.','Build into the fuller chorus.'],
     'Studio recording, 2013 (Melophobia). Cage the Elephant played warm, jangly folk-rock building to crunch.',71),
    ('my-number','foals','guitar','riff','main riff','clean',
     'indie','rhythm','intermediate',
     'Electric guitar (Yannis Philippakis / Jimmy Smith)','Clean amp with delay','Open-back combo cab','bridge pickup',
     '[{"effect_type":"delay","effect_name":"delay","placement":"post_gain","settings":{"mix":3,"time":3}}]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":1,"delay":1,"master":6}'::jsonb,
     array['Bright, interlocking math-rock clean lines with a danceable groove; keep the picking crisp.','Low gain, bright, delay.'],
     array['Play the interlocking lines cleanly.','Keep the groove danceable.'],
     'Studio recording, 2013 (Holy Fire). Foals played bright, interlocking math-rock clean lines.',71),
    ('mountain-at-my-gates','foals','guitar','riff','main riff','crunch',
     'indie','rhythm','intermediate',
     'Electric guitar (Yannis Philippakis / Jimmy Smith)','Clean-to-crunch amp with delay','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Driving, anthemic indie-rock with an intricate riff building to a big chorus; keep it tight.','Medium gain.'],
     array['Play the intricate riff cleanly.','Drive into the big chorus.'],
     'Studio recording, 2015 (What Went Down). Foals played driving, anthemic indie-rock with an intricate riff.',71),
    ('breezeblocks','alt-j','guitar','riff','main riff','clean',
     'indie','rhythm','intermediate',
     'Electric guitar (Gwil Sainsbury / Joe Newman)','Clean amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Quirky, staccato clean riff with an off-kilter rhythm; keep it precise and dry.','Low gain, dry.'],
     array['Play the staccato riff precisely.','Keep the rhythm off-kilter and tight.'],
     'Studio recording, 2012 (An Awesome Wave). alt-J played a quirky, staccato clean riff.',71),
    ('red-eyes','the-war-on-drugs','guitar','riff','main riff','crunch',
     'rock','rhythm','intermediate',
     'Electric guitar (Adam Granduciel)','Clean-to-crunch amp with delay and reverb','Open-back combo cab','bridge pickup',
     '[{"effect_type":"delay","effect_name":"delay","placement":"post_gain","settings":{"mix":3,"time":4}}]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Anthemic, hazy heartland-rock with chiming delayed chords; keep it driving and atmospheric.','Medium gain, ambient delay.'],
     array['Let the chiming chords ring with delay.','Drive the propulsive groove.'],
     'Studio recording, 2014 (Lost in the Dream). Adam Granduciel played anthemic, hazy heartland-rock with delay.',71),
    ('my-kind-of-woman','mac-demarco','guitar','riff','main progression','clean',
     'indie','rhythm','beginner',
     'Electric guitar (Mac DeMarco)','Clean amp with vibrato/chorus','Open-back combo cab','neck pickup',
     '[{"effect_type":"chorus","effect_name":"vibrato","placement":"post_gain","settings":{"rate":3,"depth":5,"mix":5}}]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warbly, warm ''jangle-slacker'' clean chords with wobbly vibrato; keep it soft and woozy.','Low gain, heavy vibrato.'],
     array['Play the chords softly.','Let the vibrato wobble the pitch.'],
     'Studio recording, 2012 (2). Mac DeMarco played warbly, warm clean chords with his signature wobbly vibrato.',71),
    ('harmony-hall','vampire-weekend','guitar','riff','main riff','clean',
     'indie','rhythm','intermediate',
     'Electric and acoustic guitar (Ezra Koenig)','Bright clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bright, rolling fingerpicked-and-strummed jangle with a sunny groove; keep it crisp.','Low gain, bright.'],
     array['Roll the fingerpicked figure cleanly.','Keep the groove sunny.'],
     'Studio recording, 2019 (Father of the Bride). Ezra Koenig played bright, rolling jangle guitar.',71),
    ('shuffle','bombay-bicycle-club','guitar','riff','main riff','clean',
     'indie','rhythm','intermediate',
     'Electric guitar (Jamie MacColl / Jack Steadman)','Clean amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bright, looping picked indie riff over a piano sample; keep it crisp and rhythmic.','Low gain, bright.'],
     array['Play the looping picked riff cleanly.','Keep it crisp and even.'],
     'Studio recording, 2011 (A Different Kind of Fix). Bombay Bicycle Club played a bright, looping picked riff.',70),
    ('undercover-martyn','two-door-cinema-club','guitar','riff','main riff','crunch',
     'indie','rhythm','intermediate',
     'Electric guitar (Sam Halliday)','Bright crunch amp with delay','Open-back combo cab','bridge pickup',
     '[{"effect_type":"delay","effect_name":"delay","placement":"post_gain","settings":{"mix":3,"time":3}}]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, bouncy picked indie riff with delay; keep the picking clean and precise.','Medium gain, bright, delay.'],
     array['Play the bouncy riff cleanly.','Let the delay drive it.'],
     'Studio recording, 2010 (Tourist History). Sam Halliday played a bright, bouncy picked indie riff with delay.',70),
    ('two-weeks','grizzly-bear','guitar','riff','main progression','clean',
     'indie','rhythm','intermediate',
     'Electric guitar (Daniel Rossen)','Clean amp with reverb','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Lush, reverberant clean chords with rich harmony; keep it warm and spacious.','Low gain, reverby.'],
     array['Play the chords softly and evenly.','Let the harmonies ring.'],
     'Studio recording, 2009 (Veckatimest). Daniel Rossen played lush, reverberant clean chords.',70),
    ('crystalised','the-xx','guitar','riff','main riff','clean',
     'indie','rhythm','beginner',
     'Electric guitar (Romy Madley Croft)','Clean amp with reverb and delay','Open-back combo cab','neck pickup',
     '[{"effect_type":"delay","effect_name":"delay","placement":"post_gain","settings":{"mix":3,"time":4}}]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":1,"master":6}'::jsonb,
     array['Sparse, minimal clean guitar with lots of space and reverb; keep every note deliberate.','Low gain, spacious, ambient.'],
     array['Play the sparse notes deliberately.','Leave lots of space.'],
     'Studio recording, 2009 (xx). Romy Madley Croft played sparse, minimal clean guitar with reverb and delay.',70),
    ('space-song','beach-house','guitar','riff','main riff','clean',
     'indie','rhythm','beginner',
     'Electric guitar (Alex Scally)','Clean amp with modulation and reverb','Open-back combo cab','neck pickup',
     '[{"effect_type":"chorus","effect_name":"modulation","placement":"post_gain","settings":{"rate":3,"depth":4,"mix":4}}]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Dreamy, chiming dream-pop clean guitar with lush modulation; keep it soft and shimmering.','Low gain, ambient, modulated.'],
     array['Play the chiming figure softly.','Let the modulation shimmer.'],
     'Studio recording, 2015 (Depression Cherry). Alex Scally played dreamy, chiming dream-pop clean guitar.',70),
    ('cocoon','catfish-and-the-bottlemen','guitar','riff','main riff','crunch',
     'indie','rhythm','beginner',
     'Electric guitar (Johnny Bond)','Crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Driving, anthemic indie-rock crunch that builds to a big chorus; keep it tight.','Medium gain.'],
     array['Play the picked verse cleanly.','Slam the big chorus.'],
     'Studio recording, 2014 (The Balcony). Johnny Bond played driving, anthemic indie-rock crunch.',70),
    ('i-will-follow-you-into-the-dark','death-cab-for-cutie','guitar','riff','fingerpicked progression','acoustic',
     'indie','rhythm','beginner',
     'Acoustic guitar (Ben Gibbard)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Simple, intimate solo-acoustic fingerpicking; keep it warm and tender.','Natural acoustic tone.'],
     array['Fingerpick the pattern gently.','Keep the dynamics intimate.'],
     'Studio recording, 2005 (Plans). Ben Gibbard played a simple, intimate solo-acoustic fingerpicking part.',71)
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
  ('tame-impala','elephant'),('tame-impala','feels-like-we-only-go-backwards'),('tame-impala','let-it-happen'),('arctic-monkeys','when-the-sun-goes-down'),
  ('arctic-monkeys','whyd-you-only-call-me-when-youre-high'),('arctic-monkeys','brianstorm'),('the-black-keys','tighten-up'),('the-black-keys','fever'),
  ('kings-of-leon','the-bucket'),('the-killers','all-these-things-that-ive-done'),('cage-the-elephant','come-a-little-closer'),('cage-the-elephant','cigarette-daydreams'),
  ('foals','my-number'),('foals','mountain-at-my-gates'),('alt-j','breezeblocks'),('the-war-on-drugs','red-eyes'),
  ('mac-demarco','my-kind-of-woman'),('vampire-weekend','harmony-hall'),('bombay-bicycle-club','shuffle'),('two-door-cinema-club','undercover-martyn'),
  ('grizzly-bear','two-weeks'),('the-xx','crystalised'),('beach-house','space-song'),('catfish-and-the-bottlemen','cocoon'),
  ('death-cab-for-cutie','i-will-follow-you-into-the-dark')
) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
cross join (values
  ('artist_interview', 'Documented artist interviews and gear discussions', null::text,
   'Researched from widely-documented interviews about this recording and player.', 72),
  ('rig_rundown', 'Published rig rundowns and community gear databases', null::text,
   'Cross-referenced against rig features and community-maintained gear databases.', 66)
) as x(source_type, title, url, notes, credibility)
where p.verification_status = 'admin_verified'
on conflict do nothing;
