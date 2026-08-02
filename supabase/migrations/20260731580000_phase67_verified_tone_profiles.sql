-- Phase 67: shoegaze / dream-pop canon + atmospheric indie, verified per-part tone data.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('My Bloody Valentine','my-bloody-valentine','Only Shallow','only-shallow','Loveless',1991),
    ('My Bloody Valentine','my-bloody-valentine','When You Sleep','when-you-sleep','Loveless',1991),
    ('My Bloody Valentine','my-bloody-valentine','Sometimes','sometimes','Loveless',1991),
    ('Slowdive','slowdive','When the Sun Hits','when-the-sun-hits','Souvlaki',1993),
    ('Slowdive','slowdive','Alison','alison','Souvlaki',1993),
    ('Slowdive','slowdive','Sugar for the Pill','sugar-for-the-pill','Slowdive',2017),
    ('Ride','ride','Vapour Trail','vapour-trail','Nowhere',1990),
    ('Cocteau Twins','cocteau-twins','Cherry-Coloured Funk','cherry-coloured-funk','Heaven or Las Vegas',1990),
    ('Cocteau Twins','cocteau-twins','Heaven or Las Vegas','heaven-or-las-vegas','Heaven or Las Vegas',1990),
    ('Mazzy Star','mazzy-star','Fade Into You','fade-into-you','So Tonight That I Might See',1993),
    ('DIIV','diiv','Doused','doused','Oshin',2012),
    ('DIIV','diiv','Under the Sun','under-the-sun','Is the Is Are',2016),
    ('Alvvays','alvvays','Archie, Marry Me','archie-marry-me','Alvvays',2014),
    ('Alvvays','alvvays','Dreams Tonite','dreams-tonite','Antisocialites',2017),
    ('Beach House','beach-house','Myth','myth','Bloom',2012),
    ('Wild Nothing','wild-nothing','Chinatown','chinatown','Gemini',2010),
    ('Duster','duster','Inside Out','inside-out','Stratosphere',1998),
    ('The War on Drugs','the-war-on-drugs','Under the Pressure','under-the-pressure','Lost in the Dream',2014),
    ('The National','the-national','About Today','about-today','Cherry Tree',2004),
    ('Radiohead','radiohead','Let Down','let-down','OK Computer',1997),
    ('Radiohead','radiohead','Weird Fishes/Arpeggi','weird-fishes-arpeggi','In Rainbows',2007),
    ('Hum','hum','Stars','stars','You''d Prefer an Astronaut',1995),
    ('Sonic Youth','sonic-youth','Teen Age Riot','teen-age-riot','Daydream Nation',1988),
    ('Pavement','pavement','Cut Your Hair','cut-your-hair','Crooked Rain, Crooked Rain',1994),
    ('Yo La Tengo','yo-la-tengo','Sugarcube','sugarcube','I Can Hear the Heart Beating as One',1997)
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
    ('my-bloody-valentine','only-shallow'),('my-bloody-valentine','when-you-sleep'),('my-bloody-valentine','sometimes'),
    ('slowdive','when-the-sun-hits'),('slowdive','alison'),('slowdive','sugar-for-the-pill'),('ride','vapour-trail'),
    ('cocteau-twins','cherry-coloured-funk'),('cocteau-twins','heaven-or-las-vegas'),('mazzy-star','fade-into-you'),
    ('diiv','doused'),('diiv','under-the-sun'),('alvvays','archie-marry-me'),('alvvays','dreams-tonite'),
    ('beach-house','myth'),('wild-nothing','chinatown'),('duster','inside-out'),('the-war-on-drugs','under-the-pressure'),
    ('the-national','about-today'),('radiohead','let-down'),('radiohead','weird-fishes-arpeggi'),('hum','stars'),
    ('sonic-youth','teen-age-riot'),('pavement','cut-your-hair'),('yo-la-tengo','sugarcube')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('my-bloody-valentine','only-shallow'),('my-bloody-valentine','when-you-sleep'),('my-bloody-valentine','sometimes'),
    ('slowdive','when-the-sun-hits'),('slowdive','alison'),('slowdive','sugar-for-the-pill'),('ride','vapour-trail'),
    ('cocteau-twins','cherry-coloured-funk'),('cocteau-twins','heaven-or-las-vegas'),('mazzy-star','fade-into-you'),
    ('diiv','doused'),('diiv','under-the-sun'),('alvvays','archie-marry-me'),('alvvays','dreams-tonite'),
    ('beach-house','myth'),('wild-nothing','chinatown'),('duster','inside-out'),('the-war-on-drugs','under-the-pressure'),
    ('the-national','about-today'),('radiohead','let-down'),('radiohead','weird-fishes-arpeggi'),('hum','stars'),
    ('sonic-youth','teen-age-riot'),('pavement','cut-your-hair'),('yo-la-tengo','sugarcube')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('my-bloody-valentine','only-shallow'),('my-bloody-valentine','when-you-sleep'),('my-bloody-valentine','sometimes'),
    ('slowdive','when-the-sun-hits'),('slowdive','alison'),('slowdive','sugar-for-the-pill'),('ride','vapour-trail'),
    ('cocteau-twins','cherry-coloured-funk'),('cocteau-twins','heaven-or-las-vegas'),('mazzy-star','fade-into-you'),
    ('diiv','doused'),('diiv','under-the-sun'),('alvvays','archie-marry-me'),('alvvays','dreams-tonite'),
    ('beach-house','myth'),('wild-nothing','chinatown'),('duster','inside-out'),('the-war-on-drugs','under-the-pressure'),
    ('the-national','about-today'),('radiohead','let-down'),('radiohead','weird-fishes-arpeggi'),('hum','stars'),
    ('sonic-youth','teen-age-riot'),('pavement','cut-your-hair'),('yo-la-tengo','sugarcube')
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
    -- ============ MY BLOODY VALENTINE (Shields: Jazzmaster glide + reverse reverb) ============
    ('only-shallow','my-bloody-valentine','guitar','riff','glide-strum wall','fuzz','shoegaze','rhythm','advanced',
     'Fender Jazzmaster (Kevin Shields)','Tube amps with reverse reverb, tremolo-arm glide strums','Closed-back cabs','bridge pickup',
     '[{"effect_type":"reverb","effect_name":"reverse reverb (the glide sound)","placement":"post_gain","settings":{"mix":6,"decay":6}},{"effect_type":"fuzz","effect_name":"fuzz/overdrive stack","placement":"front","settings":{"gain":7,"tone":5,"level":6}}]'::jsonb,
     '{"gain":7,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":6,"delay":0,"master":8}'::jsonb,
     array['The Loveless opener — Shields'' "glide guitar": strumming while bending the Jazzmaster tremolo arm, through reverse reverb.','The pitch-seasick wall needs the trem-arm technique plus reverse reverb; nothing else sounds like it.'],
     array['Hold the trem arm while strumming and rock it gently.','The wobble is the note — don''t fight it.'],
     'Studio recording, 1991. Shields'' glide-guitar wall that named a genre.',79),
    ('when-you-sleep','my-bloody-valentine','guitar','riff','glide melody wall','fuzz','shoegaze','rhythm','advanced',
     'Fender Jazzmaster (Kevin Shields)','Tube amps, layered glide strums','Closed-back cabs','bridge pickup',
     '[{"effect_type":"reverb","effect_name":"reverse reverb","placement":"post_gain","settings":{"mix":5,"decay":6}},{"effect_type":"fuzz","effect_name":"fuzz/overdrive stack","placement":"front","settings":{"gain":7,"tone":5,"level":6}}]'::jsonb,
     '{"gain":7,"bass":5,"mids":6,"treble":5,"presence":4,"reverb":5,"delay":0,"master":8}'::jsonb,
     array['The melodic peak of Loveless — the riff melody smeared inside the glide wall.','Same trem-arm technique; the hook survives the blur.'],
     array['The melody rides the top of the wobbling chords.','Loud, warm, and underwater.'],
     'Studio recording, 1991. The melodic glide-wall anthem.',79),
    ('sometimes','my-bloody-valentine','guitar','main','strummed wall','fuzz','shoegaze','rhythm','intermediate',
     'Acoustic layered with fuzz electric (Kevin Shields)','Tube amps, dense strummed layers','Closed-back cabs','bridge pickup',
     '[{"effect_type":"fuzz","effect_name":"warm fuzz layers","placement":"front","settings":{"gain":6,"tone":4,"level":6}},{"effect_type":"reverb","effect_name":"soft reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":6,"bass":6,"mids":5,"treble":4,"presence":3,"reverb":4,"delay":0,"master":7}'::jsonb,
     array['The Lost in Translation moment — warm blanket-fuzz strums with buried vocals.','Dark warm wall; strums like breathing under covers.'],
     array['Steady eighth-note strums, no accents.','The vocal whispers inside your wall — leave room.'],
     'Studio recording, 1991. The blanket-fuzz strummed lullaby.',79),

    -- ============ SLOWDIVE / RIDE / COCTEAU ============
    ('when-the-sun-hits','slowdive','guitar','riff','main wall','crunch','shoegaze','rhythm','intermediate',
     'Fender Jazzmaster/Strat (Neil Halstead / Christian Savill)','Tube amps with cascading delay and reverb','Closed-back cabs','neck pickup',
     '[{"effect_type":"delay","effect_name":"cascading delays","placement":"post_gain","settings":{"time":5,"mix":4,"feedback":5}},{"effect_type":"reverb","effect_name":"huge hall reverb","placement":"post_gain","settings":{"mix":6,"decay":7}}]'::jsonb,
     '{"gain":4,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":6,"delay":5,"master":7}'::jsonb,
     array['The quiet-loud shoegaze standard — glassy delay verses detonating into the wall chorus (push gain to 6).','Stacked delays into hall reverb; the chorus is a tidal event.'],
     array['Gentle chords through the delay web in the verse.','The chorus lands like sunlight through clouds — full arm.'],
     'Studio recording, 1993. The quiet-loud tidal standard.',78),
    ('alison','slowdive','guitar','riff','main wall','crunch','shoegaze','rhythm','intermediate',
     'Fender electrics (Neil Halstead / Rachel Goswell)','Tube amps, washed drive','Closed-back cabs','neck pickup',
     '[{"effect_type":"delay","effect_name":"long delay wash","placement":"post_gain","settings":{"time":5,"mix":4,"feedback":4}},{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":5,"decay":6}}]'::jsonb,
     '{"gain":5,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":5,"delay":4,"master":7}'::jsonb,
     array['The Souvlaki opener-of-hearts — warm washed drive swirling around the duet.','Medium gain dissolved in delay; melancholy in soft focus.'],
     array['Strummed chords blur into one another.','The little lead bends float above the mix.'],
     'Studio recording, 1993. The soft-focus duet wall.',78),
    ('sugar-for-the-pill','slowdive','guitar','riff','delay arpeggio','clean','shoegaze','rhythm','intermediate',
     'Fender Jazzmaster (Neil Halstead)','Clean amp with rhythmic delay','Open-back cab','neck pickup',
     '[{"effect_type":"delay","effect_name":"rhythmic dotted delay","placement":"post_gain","settings":{"time":4,"mix":5,"feedback":4}},{"effect_type":"reverb","effect_name":"plate reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":4,"delay":5,"master":6}'::jsonb,
     array['The reunion-era gem — crystalline delay arpeggios, cleaner than the 90s records.','Glassy clean with rhythmic delay; the pattern shimmers in place.'],
     array['Time the arpeggio to the delay repeats.','Restraint start to finish.'],
     'Studio recording, 2017. The crystalline reunion arpeggios.',77),
    ('vapour-trail','ride','guitar','riff','jangle wall','crunch','shoegaze','rhythm','beginner',
     'Rickenbacker/Fender (Andy Bell / Mark Gardener)','Tube amps, chiming wash','Closed-back cabs','bridge pickup',
     '[{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":5,"decay":6}},{"effect_type":"delay","effect_name":"soft delay","placement":"post_gain","settings":{"time":4,"mix":3,"feedback":3}}]'::jsonb,
     '{"gain":4,"bass":5,"mids":5,"treble":7,"presence":5,"reverb":5,"delay":3,"master":7}'::jsonb,
     array['The chiming shoegaze farewell — bright ringing chords in a reverb sky, strings at the end.','Jangle-forward wash; brighter than MBV, sadder than everything.'],
     array['The four-chord figure rings openly all song.','Let the last chord hang for the cellos.'],
     'Studio recording, 1990. The chiming farewell from Nowhere.',78),
    ('cherry-coloured-funk','cocteau-twins','guitar','riff','shimmer layers','clean','dream pop','rhythm','intermediate',
     'Fender Jazzmaster (Robin Guthrie)','Clean amp through racks of chorus, delay and reverb','Studio direct','neck pickup',
     '[{"effect_type":"chorus","effect_name":"lush rack chorus","placement":"post_gain","settings":{"rate":3,"depth":5,"mix":6}},{"effect_type":"delay","effect_name":"multi-tap delay","placement":"post_gain","settings":{"time":4,"mix":4,"feedback":4}},{"effect_type":"reverb","effect_name":"cathedral reverb","placement":"post_gain","settings":{"mix":6,"decay":7}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":4,"treble":6,"presence":4,"reverb":6,"delay":4,"master":6}'::jsonb,
     array['Guthrie''s liquid-glass layers — clean guitar processed into pure atmosphere.','Chorus + delay + cathedral reverb until the guitar becomes weather.'],
     array['Simple arpeggios; the racks do the painting.','Play less than feels right — then less again.'],
     'Studio recording, 1990. Guthrie''s liquid-glass processing.',77),
    ('heaven-or-las-vegas','cocteau-twins','guitar','riff','shimmer riff','clean','dream pop','rhythm','intermediate',
     'Fender Jazzmaster (Robin Guthrie)','Clean amp through rack processing','Studio direct','neck pickup',
     '[{"effect_type":"chorus","effect_name":"lush rack chorus","placement":"post_gain","settings":{"rate":3,"depth":5,"mix":6}},{"effect_type":"reverb","effect_name":"cathedral reverb","placement":"post_gain","settings":{"mix":5,"decay":6}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":5,"delay":3,"master":6}'::jsonb,
     array['The title-track glow — brighter and poppier, still swimming in shimmer.','The dream-pop blueprint: glassy chords in chorus-reverb bloom.'],
     array['The chord riff sparkles under the melody.','Glide between shapes; never chop.'],
     'Studio recording, 1990. The dream-pop title-track glow.',77),

    -- ============ SLOWCORE / DREAM POP US ============
    ('fade-into-you','mazzy-star','guitar','main','strums + slide colors','acoustic','dream pop','rhythm','beginner',
     'Acoustic + slide electric (David Roback)','Acoustic + warm clean amp','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"dark room reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":0,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":4,"delay":0,"master":6}'::jsonb,
     array['The slow-dance eternal — waltzing acoustic strums with weeping slide colors.','Warm dark acoustic; the slide sighs in the spaces (clean electric, gain 2).'],
     array['Waltz the strums unhurried.','Slide fills answer like sighs.'],
     'Studio recording, 1993. The slow-dance eternal.',78),
    ('doused','diiv','guitar','riff','driving jangle','clean','shoegaze','rhythm','intermediate',
     'Fender Jazzmaster (Zachary Cole Smith)','Clean amp pushed, wet and urgent','Open-back cab','bridge pickup',
     '[{"effect_type":"reverb","effect_name":"spring reverb wash","placement":"post_gain","settings":{"mix":5}},{"effect_type":"delay","effect_name":"slap delay","placement":"post_gain","settings":{"time":2,"mix":3,"feedback":2}}]'::jsonb,
     '{"gain":3,"bass":4,"mids":5,"treble":7,"presence":6,"reverb":5,"delay":2,"master":7}'::jsonb,
     array['The dark sprint — wet trebly jangle riffing at post-punk speed.','Bright washed clean pushed hard; urgency in soft focus.'],
     array['The riff sprints; keep the picking even.','Momentum is the emotion.'],
     'Studio recording, 2012. The dark jangle sprint.',76),
    ('under-the-sun','diiv','guitar','riff','interlocking jangle','clean','shoegaze','rhythm','intermediate',
     'Fender Jazzmaster (Zachary Cole Smith / Andrew Bailey)','Clean amp, chiming wash','Open-back cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"spring reverb","placement":"post_gain","settings":{"mix":4}},{"effect_type":"delay","effect_name":"soft delay","placement":"post_gain","settings":{"time":3,"mix":3,"feedback":3}}]'::jsonb,
     '{"gain":2,"bass":4,"mids":5,"treble":7,"presence":6,"reverb":4,"delay":3,"master":6}'::jsonb,
     array['Sun-dappled interlocking lines — two clean guitars weaving in wash.','Bright liquid clean; Krautrock pulse under dream jangle.'],
     array['Learn both weaving parts.','Ride the motorik pulse evenly.'],
     'Studio recording, 2016. The sun-dappled weave.',76),
    ('archie-marry-me','alvvays','guitar','riff','fuzz-jangle wall','crunch','indie pop','rhythm','beginner',
     'Fender Jazzmaster (Molly Rankin / Alec O''Hanley)','Tube amp, fuzzy jangle','Open-back cab','bridge pickup',
     '[{"effect_type":"fuzz","effect_name":"soft fuzz layer","placement":"front","settings":{"gain":5,"tone":5,"level":6}},{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":5,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":4,"delay":1,"master":7}'::jsonb,
     array['The indie wedding proposal — fuzzy jangle wall under a perfect pop melody.','Soft fuzz over bright chords; sweetness with static.'],
     array['Big open strums through the fuzz.','The hook does the work — support it.'],
     'Studio recording, 2014. The fuzz-jangle proposal anthem.',77),
    ('dreams-tonite','alvvays','guitar','riff','dream jangle','clean','indie pop','rhythm','beginner',
     'Fender Jazzmaster (Alec O''Hanley)','Clean amp with dreamy shimmer','Open-back cab','neck pickup',
     '[{"effect_type":"chorus","effect_name":"soft chorus","placement":"post_gain","settings":{"rate":3,"depth":4,"mix":4}},{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":5}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":5,"delay":2,"master":6}'::jsonb,
     array['The prom-in-heaven ballad — glassy chorused jangle in slow motion.','Wet soft clean; every chord a slow blink.'],
     array['Gentle arpeggio-strums at half speed.','Float; never push.'],
     'Studio recording, 2017. The prom-in-heaven jangle.',77),
    ('myth','beach-house','guitar','riff','arpeggio shimmer','clean','dream pop','rhythm','intermediate',
     'Fender/Gibson electric (Alex Scally)','Clean amp with tremolo shimmer','Open-back cab','neck pickup',
     '[{"effect_type":"tremolo","effect_name":"shimmer tremolo","placement":"post_gain","settings":{"rate":4,"depth":4}},{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":5,"decay":6}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":5,"delay":2,"master":6}'::jsonb,
     array['The Bloom opener — cascading arpeggio shimmer under Legrand''s voice.','Glassy tremolo-kissed clean; the pattern is a waterfall in slow motion.'],
     array['The arpeggio cascade repeats and builds.','Blend into the organ — you''re one instrument.'],
     'Studio recording, 2012. The cascading Bloom opener.',77),
    ('chinatown','wild-nothing','guitar','riff','chorus jangle','clean','dream pop','rhythm','beginner',
     'Fender electric (Jack Tatum)','Clean amp with 80s chorus haze','Studio direct','neck pickup',
     '[{"effect_type":"chorus","effect_name":"hazy chorus","placement":"post_gain","settings":{"rate":3,"depth":5,"mix":5}},{"effect_type":"reverb","effect_name":"soft reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":1,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":4,"delay":2,"master":6}'::jsonb,
     array['Bedroom dream-pop nostalgia — chorused jangle like a memory of the 80s.','Hazy chorused clean; VHS summer in tone form.'],
     array['The jangle riff drifts on the pulse.','Soft attack; let the chorus wobble.'],
     'Studio recording, 2010. The VHS-summer jangle.',75),
    ('inside-out','duster','guitar','riff','space-rock drift','crunch','slowcore','rhythm','beginner',
     'Solid-body electric (Clay Parton / Canaan Dove Amber)','Small amp, lo-fi warm crunch','Small combo cab','bridge pickup',
     '[{"effect_type":"reverb","effect_name":"dim room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":4,"bass":6,"mids":5,"treble":4,"presence":3,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The slowcore touchstone — dim warm crunch drifting at orbit speed.','Lo-fi dark drive; recorded like a transmission from far away.'],
     array['Slow drifting chords; let them decay.','Play at bedroom volume even on stage.'],
     'Studio recording, 1998. The orbital slowcore drift.',75),

    -- ============ ATMOSPHERIC INDIE ============
    ('under-the-pressure','the-war-on-drugs','guitar','riff','heartland shimmer','clean','indie rock','rhythm','intermediate',
     'Fender Stratocaster/Jazzmaster (Adam Granduciel)','Clean amp with cascading delay shimmer','Open-back cab','neck pickup',
     '[{"effect_type":"delay","effect_name":"cascading analog delays","placement":"post_gain","settings":{"time":4,"mix":4,"feedback":4}},{"effect_type":"reverb","effect_name":"plate reverb","placement":"post_gain","settings":{"mix":4}},{"effect_type":"compressor","effect_name":"smooth compression","placement":"front","settings":{"sustain":5,"level":5}}]'::jsonb,
     '{"gain":3,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":4,"delay":4,"master":6}'::jsonb,
     array['The nine-minute heartland drift — Springsteen through a delay dream.','Compressed shimmer-clean with stacked delays; motion without hurry.'],
     array['Strums and licks dissolve into the delay stream.','The groove is a highway — stay on it.'],
     'Studio recording, 2014. The nine-minute heartland drift.',77),
    ('about-today','the-national','guitar','main','sparse clean build','clean','indie rock','rhythm','beginner',
     'Fender/Gibson electric (Aaron & Bryce Dessner)','Clean amp, sparse and warm','Open-back cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"soft room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The quiet devastation (and Warrior finale) — sparse clean picking building to a crushing swell (gain 5 at the peak).','Warm minimal clean; the question "how close am I to losing you" does the rest.'],
     array['The two-note figure repeats like a held breath.','The final build earns every decibel.'],
     'Studio recording, 2004. The quiet-devastation builder.',77),
    ('let-down','radiohead','guitar','riff','interlocking arpeggios','clean','alternative rock','rhythm','advanced',
     'Fender Telecaster/Rickenbacker (Ed O''Brien / Jonny Greenwood)','Clean amps, chiming interlocked layers','Open-back cabs','bridge pickup',
     '[{"effect_type":"delay","effect_name":"subtle delay","placement":"post_gain","settings":{"time":3,"mix":2,"feedback":2}},{"effect_type":"reverb","effect_name":"plate reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":2,"bass":4,"mids":5,"treble":7,"presence":6,"reverb":3,"delay":2,"master":6}'::jsonb,
     array['The OK Computer heart — glittering arpeggios in different meters interlocking like traffic.','Bright chiming cleans; the parts phase against each other by design.'],
     array['The arpeggios run in 5-against-4 feels — learn each alone.','Transcendence through repetition.'],
     'Studio recording, 1997. The interlocking arpeggio heart of OK Computer.',79),
    ('weird-fishes-arpeggi','radiohead','guitar','riff','arpeggio trio','clean','alternative rock','rhythm','advanced',
     'Fender Telecaster (Thom Yorke / Jonny Greenwood / Ed O''Brien)','Clean amps, three-guitar arpeggio weave','Open-back cabs','bridge pickup',
     '[{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":2,"bass":4,"mids":5,"treble":7,"presence":6,"reverb":3,"delay":1,"master":6}'::jsonb,
     array['The In Rainbows undertow — three clean arpeggio parts circling the drum pulse.','Bright dry-ish cleans; the hypnosis is the stacking.'],
     array['Each arpeggio is simple; together they''re the ocean.','Stay metronomic — the drums push, you circle.'],
     'Studio recording, 2007. The three-guitar undertow.',79),
    ('stars','hum','guitar','riff','main riff','high_gain','space rock','rhythm','intermediate',
     'Les Paul/Ibanez (Matt Talbott / Tim Lash)','Tube stacks, massive drop-tuned wall','Closed-back 4x12 cabs','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":5,"presence":5,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The space-rock monolith — quiet pinging intro into a drop-tuned continent of fuzz.','Huge warm wall; heavy without aggression, like gravity.'],
     array['The intro single-note ping repeats alone, then the wall arrives.','Hold the chords; let mass do the work.'],
     'Studio recording, 1995. The space-rock monolith riff.',77),
    ('teen-age-riot','sonic-youth','guitar','riff','alternate-tuning jangle','crunch','noise rock','rhythm','advanced',
     'Fender Jazzmasters in alternate tunings (Thurston Moore / Lee Ranaldo)','Tube amps, chiming drive','Closed-back cabs','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The Daydream Nation opener — droning alternate-tuned Jazzmasters ringing like bells.','Bright chiming drive; the tunings (GGDDGG-family) make the drone.'],
     array['Standard tuning approximates it; the real thing needs their tunings.','Ride the drone strings constantly.'],
     'Studio recording, 1988. The alternate-tuning bell-drone opener.',78),
    ('cut-your-hair','pavement','guitar','riff','slacker riff','crunch','indie rock','rhythm','beginner',
     'Fender Telecaster/Jazzmaster (Stephen Malkmus / Scott Kannberg)','Tube amp, loose slacker crunch','Open-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The ooh-ooh-ooh slacker anthem — loose jangly crunch, perfectly careless.','Light ragged drive; polish would kill it.'],
     array['Strum casually; mean it secretly.','The solo is gloriously wrong on purpose.'],
     'Studio recording, 1994. The slacker-anthem shrug.',77),
    ('sugarcube','yo-la-tengo','guitar','riff','fuzz-pop wall','fuzz','indie rock','rhythm','beginner',
     'Fender Jazzmaster (Ira Kaplan)','Tube amp with fuzz, warm noise-pop','Open-back cab','bridge pickup',
     '[{"effect_type":"fuzz","effect_name":"warm fuzz","placement":"front","settings":{"gain":6,"tone":5,"level":6}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":3,"delay":0,"master":7}'::jsonb,
     array['The Hoboken valentine — warm fuzz-pop wall with feedback halos.','Soft-edged fuzz; noise as affection.'],
     array['Strum the wall; let feedback bloom at the edges.','Sweetness first, volume second.'],
     'Studio recording, 1997. The warm fuzz-pop valentine.',76)
) as c(
  song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence
)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;
