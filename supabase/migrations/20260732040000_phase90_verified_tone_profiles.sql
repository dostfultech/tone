-- Phase 90: iconic weird/characteristic guitar sounds — the tones people hear once and search for.
-- Selection heuristic per user research (Reddit): people mostly look for songs with
-- weird or characteristic sounds, not generic songs.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('The Cure','the-cure','Just Like Heaven','just-like-heaven','Kiss Me, Kiss Me, Kiss Me',1987),
    ('The Cure','the-cure','Lovesong','lovesong','Disintegration',1989),
    ('The Smiths','the-smiths','There Is a Light That Never Goes Out','there-is-a-light-that-never-goes-out','The Queen Is Dead',1986),
    ('The Smiths','the-smiths','Bigmouth Strikes Again','bigmouth-strikes-again','The Queen Is Dead',1986),
    ('Iron Butterfly','iron-butterfly','In-A-Gadda-Da-Vida','in-a-gadda-da-vida','In-A-Gadda-Da-Vida',1968),
    ('The Breeders','the-breeders','Cannonball','cannonball','Last Splash',1993),
    ('Jane''s Addiction','janes-addiction','Been Caught Stealing','been-caught-stealing','Ritual de lo Habitual',1990),
    ('Jane''s Addiction','janes-addiction','Jane Says','jane-says','Nothing''s Shocking',1988),
    ('Yes','yes-band','Owner of a Lonely Heart','owner-of-a-lonely-heart','90125',1983),
    ('Yes','yes-band','Roundabout','roundabout','Fragile',1971),
    ('Michael Jackson','michael-jackson','Beat It','beat-it','Thriller',1982),
    ('Sonic Youth','sonic-youth','Kool Thing','kool-thing','Goo',1990),
    ('Focus','focus-band','Hocus Pocus','hocus-pocus','Moving Waves',1971),
    ('Hum','hum-band','Stars','stars','You''d Prefer an Astronaut',1995),
    ('Butthole Surfers','butthole-surfers','Pepper','pepper','Electriclarryland',1996),
    ('Soundgarden','soundgarden','Rusty Cage','rusty-cage','Badmotorfinger',1991),
    ('Talking Heads','talking-heads','This Must Be the Place (Naive Melody)','this-must-be-the-place','Speaking in Tongues',1983),
    ('Beck','beck','Loser','loser','Mellow Gold',1994),
    ('Ween','ween','Ocean Man','ocean-man','The Mollusk',1997),
    ('The Presidents of the United States of America','the-presidents-of-the-united-states-of-america','Peaches','peaches','The Presidents of the United States of America',1995),
    ('Cake','cake-band','The Distance','the-distance','Fashion Nugget',1996),
    ('Dinosaur Jr.','dinosaur-jr','Feel the Pain','feel-the-pain','Without a Sound',1994),
    ('Helmet','helmet-band','Unsung','unsung','Meantime',1992),
    ('Kyuss','kyuss','Green Machine','green-machine','Blues for the Red Sun',1992),
    ('Meat Puppets','meat-puppets','Backwater','backwater','Too High to Die',1994)
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
    ('the-cure','just-like-heaven'),('the-cure','lovesong'),
    ('the-smiths','there-is-a-light-that-never-goes-out'),('the-smiths','bigmouth-strikes-again'),
    ('iron-butterfly','in-a-gadda-da-vida'),('the-breeders','cannonball'),
    ('janes-addiction','been-caught-stealing'),('janes-addiction','jane-says'),
    ('yes-band','owner-of-a-lonely-heart'),('yes-band','roundabout'),('michael-jackson','beat-it'),
    ('sonic-youth','kool-thing'),('focus-band','hocus-pocus'),('hum-band','stars'),
    ('butthole-surfers','pepper'),('soundgarden','rusty-cage'),('talking-heads','this-must-be-the-place'),
    ('beck','loser'),('ween','ocean-man'),('the-presidents-of-the-united-states-of-america','peaches'),
    ('cake-band','the-distance'),('dinosaur-jr','feel-the-pain'),('helmet-band','unsung'),
    ('kyuss','green-machine'),('meat-puppets','backwater')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
  where p.mode = 'guitar'
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('the-cure','just-like-heaven'),('the-cure','lovesong'),
    ('the-smiths','there-is-a-light-that-never-goes-out'),('the-smiths','bigmouth-strikes-again'),
    ('iron-butterfly','in-a-gadda-da-vida'),('the-breeders','cannonball'),
    ('janes-addiction','been-caught-stealing'),('janes-addiction','jane-says'),
    ('yes-band','owner-of-a-lonely-heart'),('yes-band','roundabout'),('michael-jackson','beat-it'),
    ('sonic-youth','kool-thing'),('focus-band','hocus-pocus'),('hum-band','stars'),
    ('butthole-surfers','pepper'),('soundgarden','rusty-cage'),('talking-heads','this-must-be-the-place'),
    ('beck','loser'),('ween','ocean-man'),('the-presidents-of-the-united-states-of-america','peaches'),
    ('cake-band','the-distance'),('dinosaur-jr','feel-the-pain'),('helmet-band','unsung'),
    ('kyuss','green-machine'),('meat-puppets','backwater')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
  where p.mode = 'guitar'
);
delete from public.song_tone_profiles p where p.mode = 'guitar' and p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('the-cure','just-like-heaven'),('the-cure','lovesong'),
    ('the-smiths','there-is-a-light-that-never-goes-out'),('the-smiths','bigmouth-strikes-again'),
    ('iron-butterfly','in-a-gadda-da-vida'),('the-breeders','cannonball'),
    ('janes-addiction','been-caught-stealing'),('janes-addiction','jane-says'),
    ('yes-band','owner-of-a-lonely-heart'),('yes-band','roundabout'),('michael-jackson','beat-it'),
    ('sonic-youth','kool-thing'),('focus-band','hocus-pocus'),('hum-band','stars'),
    ('butthole-surfers','pepper'),('soundgarden','rusty-cage'),('talking-heads','this-must-be-the-place'),
    ('beck','loser'),('ween','ocean-man'),('the-presidents-of-the-united-states-of-america','peaches'),
    ('cake-band','the-distance'),('dinosaur-jr','feel-the-pain'),('helmet-band','unsung'),
    ('kyuss','green-machine'),('meat-puppets','backwater')
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
    ('just-like-heaven','the-cure','guitar','riff','chiming intro riff','clean','new wave','lead','intermediate',
     'Fender Jazzmaster/Bass VI (Robert Smith / Porl Thompson)','Clean amp with chorus and flange shimmer','Closed-back cab','neck pickup',
     '[{"effect_type":"chorus","effect_name":"lush 80s chorus","placement":"post_gain","settings":{"rate":3,"depth":5,"mix":5}},{"effect_type":"flanger","effect_name":"subtle flange","placement":"post_gain","settings":{"rate":2,"depth":3,"mix":3}},{"effect_type":"reverb","effect_name":"bright reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":7,"presence":5,"reverb":4,"delay":2,"master":7}'::jsonb,
     array['The most beautiful riff of the 80s — cascading chorused clean that everyone recognizes in one bar.','Glassy swirling chime; show me, show me, show me.'],
     array['The descending riff cascades — let every note ring into the next.','The chorus pedal IS the song; don''t skimp on depth.'],
     'Studio recording, 1987. The cascading chime.',78),
    ('lovesong','the-cure','guitar','riff','spider-line riff','clean','new wave','lead','beginner',
     'Fender Jazzmaster (Robert Smith)','Clean amp with dark chorus','Closed-back cab','neck pickup',
     '[{"effect_type":"chorus","effect_name":"dark chorus","placement":"post_gain","settings":{"rate":3,"depth":4,"mix":5}},{"effect_type":"reverb","effect_name":"dark reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":3,"delay":1,"master":6}'::jsonb,
     array['The wedding-gift single — the spidery minor riff crawling under however far away.','Dark watery clean; whenever I''m alone with you.'],
     array['Pick the minor line precisely.','Adele covered it; 311 covered it; the riff survives everything.'],
     'Studio recording, 1989. The spider-line single.',77),
    ('there-is-a-light-that-never-goes-out','the-smiths','guitar','main','jangling strums','clean','indie rock','rhythm','intermediate',
     'Rickenbacker/Telecaster (Johnny Marr)','Clean amp, layered jangle','Open-back combo cab','bridge pickup',
     '[{"effect_type":"chorus","effect_name":"subtle chorus","placement":"post_gain","settings":{"rate":3,"depth":3,"mix":3}},{"effect_type":"reverb","effect_name":"plate reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":7,"presence":5,"reverb":3,"delay":1,"master":6}'::jsonb,
     array['The ten-ton-truck hymn — Marr''s layered jangle with the synth-string swells.','Bright layered chime; to die by your side is such a heavenly way to die.'],
     array['Capo 2; strum the pattern with constant motion.','Marr tracked many layers — one good acoustic-feel strum carries it live.'],
     'Studio recording, 1986. The ten-ton-truck hymn.',77),
    ('bigmouth-strikes-again','the-smiths','guitar','riff','galloping jangle riff','clean','indie rock','rhythm','advanced',
     'Rickenbacker/Les Paul (Johnny Marr)','Clean amp pushed, galloping jangle','Open-back combo cab','bridge pickup',
     '[{"effect_type":"compressor","effect_name":"tight compression","placement":"front","settings":{"sustain":5,"level":5}}]'::jsonb,
     '{"gain":3,"bass":5,"mids":5,"treble":7,"presence":6,"reverb":2,"delay":1,"master":7}'::jsonb,
     array['Marr''s Jumpin'' Jack Flash — the relentless galloping capo riff.','Bright percussive clean; now I know how Joan of Arc felt.'],
     array['Capo 4; the strum-picking gallop never stops for four minutes.','Build forearm stamina — this is the Marr workout.'],
     'Studio recording, 1986. The galloping jangle.',77),
    ('in-a-gadda-da-vida','iron-butterfly','guitar','riff','the eternal riff','fuzz','psychedelic rock','riff','beginner',
     'Mosrite/Gibson SG (Erik Brann)','Tube amp with fuzz, acid-rock heat','Closed-back cab','bridge pickup',
     '[{"effect_type":"fuzz","effect_name":"60s fuzz","placement":"front","settings":{"gain":7,"tone":5,"level":6}}]'::jsonb,
     '{"gain":6,"bass":6,"mids":5,"treble":5,"presence":4,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The 17-minute acid monolith — the four-note riff every beginner learns third.','Wooly vintage fuzz; in the garden of Eden, slurred forever.'],
     array['The riff walks down — four notes, infinite menace.','The album version has a drum solo; you''re excused from that part.'],
     'Studio recording, 1968. The acid monolith.',77),
    ('cannonball','the-breeders','guitar','riff','check-check riff','crunch','alt rock','rhythm','intermediate',
     'Fender/Gibson electric (Kim & Kelley Deal)','Tube amp, lopsided alt-rock','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The check-check-one-two classic — lurching bass intro, spitting surf-punk verse riff.','Loose gnarly crunch; want you, koo koo, cannonball.'],
     array['The riff lurches on purpose — don''t straighten it.','Spitting into the distorted mic is optional but canon.'],
     'Studio recording, 1993. The check-check classic.',76),
    ('been-caught-stealing','janes-addiction','guitar','riff','funk-rock strut','crunch','alt rock','rhythm','intermediate',
     'Ibanez/PRS electric (Dave Navarro)','Tube amp, funky strut crunch','Closed-back cab','bridge humbucker',
     '[{"effect_type":"wah","effect_name":"wah accents","placement":"front","settings":{"mix":5}}]'::jsonb,
     '{"gain":5,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The dog-bark funk-rock strut — Navarro''s greasy wah-flecked groove.','Springy strutting crunch; I''ve been caught stealing once when I was five.'],
     array['Strut the riff with the bass line.','The barking dogs count you in.'],
     'Studio recording, 1990. The dog-bark strut.',76),
    ('jane-says','janes-addiction','guitar','main','steel-drum campfire','clean','alt rock','rhythm','beginner',
     'Acoustic + clean electric (Dave Navarro)','Clean amp with steel drum colors','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The two-chord immortal — G to A forever, with steel drums making it weightless.','Open ringing clean; Jane says she''s done with Sergio.'],
     array['Two chords: G and A. The song is the story, not the changes.','Every busker knows it; play it better than they do.'],
     'Studio recording, 1988. The two-chord immortal.',76),
    ('owner-of-a-lonely-heart','yes-band','guitar','riff','orchestral-hit riff','distorted','prog rock','riff','intermediate',
     'Fender/custom electric (Trevor Rabin)','Tube amp, punchy 80s rock','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The prog band''s pop heist — the strutting riff cut apart by sampled orchestra stabs.','Punchy dry drive; the weirdest #1 riff of 1983.'],
     array['Stab the riff staccato; silence between hits is the hook.','The solo bends are pure Rabin showmanship.'],
     'Studio recording, 1983. The orchestral-hit heist.',76),
    ('roundabout','yes-band','guitar','riff','harmonic intro + gallop','clean','prog rock','riff','advanced',
     'Gibson ES-175 / Fender Telecaster (Steve Howe)','Clean amp, articulate prog','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":3,"bass":4,"mids":5,"treble":7,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The harmonics that launched a thousand memes — Howe''s crystalline intro into the galloping funk verse.','Bright precise clean; in and around the lake.'],
     array['The intro: natural harmonics at 12 and 7, ring them pure.','The verse gallop locks with Squire''s growling bass.'],
     'Studio recording, 1971. The harmonic launch.',77),
    ('beat-it','michael-jackson','guitar','riff','main riff + EVH solo','distorted','pop rock','lead','intermediate',
     'Gibson/Kramer (Steve Lukather riff, Eddie Van Halen solo)','Marshall-style tube amp, hot rock','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The pop-metal summit — Lukather''s E-minor riff and Eddie''s donated tornado solo.','Hot tight saturation; the solo Eddie recorded free in half an hour.'],
     array['The riff locks with the synth bass.','The solo: taps, dives, and the famous studio-monitor fire myth.'],
     'Studio recording, 1982. The pop-metal summit.',78),
    ('kool-thing','sonic-youth','guitar','riff','alt-tuned strut','distorted','alt rock','riff','intermediate',
     'Fender Jazzmasters, alt tunings (Thurston Moore / Lee Ranaldo)','Tube amp, clanging art-rock','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":5,"treble":7,"presence":6,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The art-noise hit — clanging altered-tuning riff that sounds wrong and perfect.','Metallic clanging drive; Sonic Youth tuned guitars like nobody else dared.'],
     array['Standard-tuning approximation works; the clang is in the attack.','Hit near the bridge for the metallic spray.'],
     'Studio recording, 1990. The art-noise hit.',74),
    ('hocus-pocus','focus-band','guitar','riff','yodel-metal riff','distorted','prog rock','riff','intermediate',
     'Gibson Les Paul (Jan Akkerman)','Tube amp, hot British-style drive','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The yodeling rocker — Akkerman''s stomping riff trading bars with actual yodels and flute.','Hot crunchy drive; the weirdest song classic-rock radio ever embraced.'],
     array['Stomp the riff hard between the yodel breaks.','Yodeling optional; conviction mandatory.'],
     'Studio recording, 1971. The yodel-metal riff.',75),
    ('stars','hum-band','guitar','riff','space-fuzz wall','distorted','space rock','riff','intermediate',
     'Gibson Les Paul / Fender (Matt Talbott / Tim Lash)','High-gain amp stack, layered space-fuzz','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":4,"treble":6,"presence":5,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The she-thinks-she-missed-the-train drop — quiet single-note intro, then THE wall.','Massive layered fuzz-gain; the tone every shoegaze-metal band chases.','Deftones, Nothing, every heavy-gaze band cite this drop.'],
     array['The intro note ticks alone; then all guitars land at once.','It''s about the contrast — keep the intro tiny.'],
     'Studio recording, 1995. The space-fuzz drop.',75),
    ('pepper','butthole-surfers','guitar','riff','sitar-slide weirdness','clean','alt rock','riff','beginner',
     'Electric with slide/sitar effect (Paul Leary)','Clean amp with warped colors','Studio direct','bridge pickup',
     '[{"effect_type":"phaser","effect_name":"warped phaser","placement":"post_gain","settings":{"rate":3,"depth":5,"mix":4}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":3,"delay":1,"master":6}'::jsonb,
     array['The they-were-all-in-love-with-dying drawl — woozy sitar-slide figures over the loop.','Warped woozy clean; the weirdest #1 alternative hit of 1996.'],
     array['Slide into the figure lazily.','Texas surrealism — play it half-asleep.'],
     'Studio recording, 1996. The woozy drawl.',73),
    ('rusty-cage','soundgarden','guitar','riff','runaway riff + drop drop','distorted','grunge','riff','advanced',
     'Gibson/Guild electric, drop-D and lower (Kim Thayil / Chris Cornell)','Tube amp, hot grunge drive','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The runaway-train riff — sprinting spidery line that collapses into the doom-slow outro drop.','Wiry hot drive; Johnny Cash covered it and made it scarier.'],
     array['The fast riff runs on open-string pull-offs.','The outro drops to half-time sludge — the best gear change in grunge.'],
     'Studio recording, 1991. The runaway-train riff.',76),
    ('this-must-be-the-place','talking-heads','guitar','main','naive melody loop','clean','new wave','rhythm','beginner',
     'Fender/Gibson clean electrics (David Byrne / band swap)','Clean amp, tight naive loop','Studio direct','bridge pickup',
     '[{"effect_type":"compressor","effect_name":"tight compression","placement":"front","settings":{"sustain":5,"level":5}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The naive melody — the band swapped instruments and looped two chords into the warmest song ever made.','Dry chirping clean; home is where I want to be.'],
     array['Loop the two-chord figure with total steadiness.','Naive on purpose — expertise would ruin it.'],
     'Studio recording, 1983. The naive melody.',75),
    ('loser','beck','guitar','riff','slide-loop riff','clean','alt rock','riff','beginner',
     'Slide guitar (Beck Hansen)','Small amp, lo-fi slide loop','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":5,"presence":4,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The soy-un-perdedor loop — greasy slide riff over the folk-hop beat.','Dusty lo-fi warmth; the slacker anthem built on one slide lick.'],
     array['Slide the riff loose; it''s a loop, keep it identical.','In the time of chimpanzees I was a monkey.'],
     'Studio recording, 1994. The slide loop.',75),
    ('ocean-man','ween','guitar','riff','pitch-warped jangle','clean','alt rock','rhythm','beginner',
     'Electric guitar, tape-warped (Dean & Gene Ween)','Clean amp, sped-up sparkle','Studio direct','bridge pickup',
     '[{"effect_type":"chorus","effect_name":"warble chorus","placement":"post_gain","settings":{"rate":4,"depth":4,"mix":4}}]'::jsonb,
     '{"gain":2,"bass":4,"mids":5,"treble":7,"presence":6,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The SpongeBob-credits classic — chipmunked jangle sparkling at tape-warped pitch.','Bright warbled clean; ocean man, take me by the hand.'],
     array['Capo high to fake the sped-up sheen.','Two minutes of pure serotonin — don''t overthink it.'],
     'Studio recording, 1997. The tape-warp jangle.',74),
    ('peaches','the-presidents-of-the-united-states-of-america','guitar','riff','two-string guitbass riff','crunch','alt rock','riff','beginner',
     'Custom 3-string guitbass (Chris Ballew / Dave Dederer)','Tube amp, rubbery crunch','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":6,"mids":5,"treble":5,"presence":5,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['The moving-to-the-country stomp — played on homemade two- and three-string instruments.','Rubbery low crunch; millions of peaches, peaches for me.'],
     array['The riff lives on the low strings — you only need two.','Novelty on the surface, groove underneath.'],
     'Studio recording, 1995. The guitbass stomp.',74),
    ('the-distance','cake-band','guitar','riff','deadpan strut riff','crunch','alt rock','riff','beginner',
     'Fender electric (Greg Brown)','Tube amp, dry deadpan crunch','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['The reluctantly-crouched banger — bone-dry strut riff under the deadpan verses and trumpet.','Dead-dry punchy crunch; he''s going the distance.'],
     array['Zero reverb — the dryness IS the tone.','Lock with the trumpet stabs.'],
     'Studio recording, 1996. The deadpan strut.',75),
    ('feel-the-pain','dinosaur-jr','guitar','riff','quiet-loud whammy','distorted','alt rock','lead','intermediate',
     'Fender Jazzmaster (J Mascis)','Marshall stacks, glorious sloppy roar','Closed-back 4x12 cab','bridge pickup',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":9}'::jsonb,
     array['The golf-video classic — whispered verses, then Mascis'' roaring wall and drooping whammy bends.','Huge sagging roar; I feel the pain of everyone.'],
     array['Verses barely strummed; chorus full Marshall.','The whammy sags lazily — Mascis never hurries.'],
     'Studio recording, 1994. The quiet-loud whammy classic.',75),
    ('unsung','helmet-band','guitar','riff','staccato drop-D stomp','high_gain','alt metal','riff','intermediate',
     'ESP electric, drop D (Page Hamilton)','High-gain amp, clipped precision','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":6,"treble":6,"presence":6,"reverb":0,"delay":0,"master":8}'::jsonb,
     array['The staccato blueprint — clipped drop-D stabs with total silence between; nu-metal''s secret source.','Tight clipped high gain; mids IN, unlike everyone who copied it.'],
     array['Mute everything between stabs — the silence is the riff.','Jazz-trained precision disguised as brutality.'],
     'Studio recording, 1992. The staccato blueprint.',76),
    ('green-machine','kyuss','guitar','riff','desert-fuzz groove','fuzz','stoner rock','riff','intermediate',
     'Gibson SG into bass amp (Josh Homme)','Bass amp with fuzz, desert rumble','Closed-back 8x10 bass cab','bridge humbucker',
     '[{"effect_type":"fuzz","effect_name":"desert fuzz","placement":"front","settings":{"gain":7,"tone":4,"level":6}}]'::jsonb,
     '{"gain":6,"bass":7,"mids":5,"treble":4,"presence":4,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The desert-rock cornerstone — Homme''s down-tuned guitar through BASS amps, generator-party thick.','Subterranean fuzz rumble; the tone that invented a genre in the California desert.'],
     array['Tune to C; play through a bass amp if you can.','The groove swings — stoner rock is dance music, slowly.'],
     'Studio recording, 1992. The desert cornerstone.',75),
    ('backwater','meat-puppets','guitar','riff','psychedelic-country crunch','crunch','alt rock','rhythm','beginner',
     'Fender/Gibson electric (Curt Kirkwood)','Tube amp, warm desert crunch','Closed-back cab','bridge pickup',
     '[{"effect_type":"chorus","effect_name":"watery chorus","placement":"post_gain","settings":{"rate":3,"depth":4,"mix":4}}]'::jsonb,
     '{"gain":5,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":7}'::jsonb,
     array['The MTV moment — watery chorused crunch on the desert-psych riff (the Nirvana Unplugged band, electrified).','Liquid warm drive; some things will never change.'],
     array['The riff rolls loose and sun-baked.','Kirkwood''s bends wobble — precision isn''t the point.'],
     'Studio recording, 1994. The desert-psych hit.',74)
) as c(
  song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence
)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;
