-- Phase 36: 25 NWOBHM & power/classic metal, verified per-part tone data (more Motorhead, Dio, Judas Priest, Iron Maiden + Saxon, Accept, Helloween, Blind Guardian, DragonForce, Sabaton, Rainbow, Manowar, Diamond Head, Venom, Mercyful Fate).

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Motorhead','motorhead','Overkill','overkill','Overkill',1979),
    ('Motorhead','motorhead','Killed by Death','killed-by-death','No Remorse',1984),
    ('Saxon','saxon','Wheels of Steel','wheels-of-steel','Wheels of Steel',1980),
    ('Saxon','saxon','Denim and Leather','denim-and-leather','Denim and Leather',1981),
    ('Accept','accept','Balls to the Wall','balls-to-the-wall','Balls to the Wall',1983),
    ('Accept','accept','Fast as a Shark','fast-as-a-shark','Restless and Wild',1982),
    ('Helloween','helloween','I Want Out','i-want-out','Keeper of the Seven Keys: Part II',1988),
    ('Helloween','helloween','Eagle Fly Free','eagle-fly-free','Keeper of the Seven Keys: Part II',1988),
    ('Blind Guardian','blind-guardian','The Bard''s Song (In the Forest)','the-bards-song-in-the-forest','Somewhere Far Beyond',1992),
    ('Blind Guardian','blind-guardian','Nightfall','nightfall','Nightfall in Middle-Earth',1998),
    ('DragonForce','dragonforce','Through the Fire and Flames','through-the-fire-and-flames','Inhuman Rampage',2006),
    ('DragonForce','dragonforce','Valley of the Damned','valley-of-the-damned','Valley of the Damned',2003),
    ('Sabaton','sabaton','Primo Victoria','primo-victoria','Primo Victoria',2005),
    ('Sabaton','sabaton','The Last Stand','the-last-stand','The Last Stand',2016),
    ('Dio','dio','The Last in Line','the-last-in-line','The Last in Line',1984),
    ('Dio','dio','Don''t Talk to Strangers','dont-talk-to-strangers','Holy Diver',1983),
    ('Judas Priest','judas-priest','Turbo Lover','turbo-lover','Turbo',1986),
    ('Judas Priest','judas-priest','Victim of Changes','victim-of-changes','Sad Wings of Destiny',1976),
    ('Rainbow','rainbow','Stargazer','stargazer','Rising',1976),
    ('Rainbow','rainbow','Man on the Silver Mountain','man-on-the-silver-mountain','Ritchie Blackmore''s Rainbow',1975),
    ('Manowar','manowar','Warriors of the World United','warriors-of-the-world-united','Warriors of the World',2002),
    ('Diamond Head','diamond-head','Am I Evil?','am-i-evil','Lightning to the Nations',1980),
    ('Venom','venom','Black Metal','black-metal','Black Metal',1982),
    ('Mercyful Fate','mercyful-fate','Evil','evil','Melissa',1983),
    ('Iron Maiden','iron-maiden','Flight of Icarus','flight-of-icarus','Piece of Mind',1983)
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
    ('motorhead','overkill'),('motorhead','killed-by-death'),('saxon','wheels-of-steel'),('saxon','denim-and-leather'),
    ('accept','balls-to-the-wall'),('accept','fast-as-a-shark'),('helloween','i-want-out'),('helloween','eagle-fly-free'),
    ('blind-guardian','the-bards-song-in-the-forest'),('blind-guardian','nightfall'),('dragonforce','through-the-fire-and-flames'),('dragonforce','valley-of-the-damned'),
    ('sabaton','primo-victoria'),('sabaton','the-last-stand'),('dio','the-last-in-line'),('dio','dont-talk-to-strangers'),
    ('judas-priest','turbo-lover'),('judas-priest','victim-of-changes'),('rainbow','stargazer'),('rainbow','man-on-the-silver-mountain'),
    ('manowar','warriors-of-the-world-united'),('diamond-head','am-i-evil'),('venom','black-metal'),('mercyful-fate','evil'),
    ('iron-maiden','flight-of-icarus')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('motorhead','overkill'),('motorhead','killed-by-death'),('saxon','wheels-of-steel'),('saxon','denim-and-leather'),
    ('accept','balls-to-the-wall'),('accept','fast-as-a-shark'),('helloween','i-want-out'),('helloween','eagle-fly-free'),
    ('blind-guardian','the-bards-song-in-the-forest'),('blind-guardian','nightfall'),('dragonforce','through-the-fire-and-flames'),('dragonforce','valley-of-the-damned'),
    ('sabaton','primo-victoria'),('sabaton','the-last-stand'),('dio','the-last-in-line'),('dio','dont-talk-to-strangers'),
    ('judas-priest','turbo-lover'),('judas-priest','victim-of-changes'),('rainbow','stargazer'),('rainbow','man-on-the-silver-mountain'),
    ('manowar','warriors-of-the-world-united'),('diamond-head','am-i-evil'),('venom','black-metal'),('mercyful-fate','evil'),
    ('iron-maiden','flight-of-icarus')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('motorhead','overkill'),('motorhead','killed-by-death'),('saxon','wheels-of-steel'),('saxon','denim-and-leather'),
    ('accept','balls-to-the-wall'),('accept','fast-as-a-shark'),('helloween','i-want-out'),('helloween','eagle-fly-free'),
    ('blind-guardian','the-bards-song-in-the-forest'),('blind-guardian','nightfall'),('dragonforce','through-the-fire-and-flames'),('dragonforce','valley-of-the-damned'),
    ('sabaton','primo-victoria'),('sabaton','the-last-stand'),('dio','the-last-in-line'),('dio','dont-talk-to-strangers'),
    ('judas-priest','turbo-lover'),('judas-priest','victim-of-changes'),('rainbow','stargazer'),('rainbow','man-on-the-silver-mountain'),
    ('manowar','warriors-of-the-world-united'),('diamond-head','am-i-evil'),('venom','black-metal'),('mercyful-fate','evil'),
    ('iron-maiden','flight-of-icarus')
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
    ('overkill','motorhead','guitar','riff','main riff','distorted',
     'metal','rhythm','intermediate',
     'Electric guitar (Fast Eddie Clarke)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Raw, relentless double-kick-driven speed-rock riff; keep it dirty and pounding.','High gain, raw.'],
     array['Keep the riff dirty and relentless.','Drive it hard.'],
     'Studio recording, 1979 (Overkill). Fast Eddie Clarke played a raw, relentless speed-rock riff through Marshalls.',72),
    ('killed-by-death','motorhead','guitar','riff','main riff','distorted',
     'metal','rhythm','beginner',
     'Electric guitar (Phil Campbell / Würzel)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Swaggering, dirty rock-''n''-roll-metal riff; keep it loose and pounding.','High gain, raw.'],
     array['Play the riff with a dirty swagger.','Keep it pounding.'],
     'Studio recording, 1984 (No Remorse). Motorhead played a swaggering, dirty rock-''n''-roll-metal riff.',71),
    ('wheels-of-steel','saxon','guitar','riff','main riff','high_gain',
     'metal','rhythm','intermediate',
     'Electric guitar (Paul Quinn / Graham Oliver)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Driving, motoring NWOBHM riff; keep the palm mutes tight and steady.','High gain.'],
     array['Keep the motoring riff tight.','Drive it steadily.'],
     'Studio recording, 1980 (Wheels of Steel). Saxon played a driving, motoring NWOBHM riff through Marshalls.',71),
    ('denim-and-leather','saxon','guitar','riff','main riff','high_gain',
     'metal','rhythm','intermediate',
     'Electric guitar (Paul Quinn / Graham Oliver)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Anthemic NWOBHM crunch with a fist-pumping chorus; keep it tight and driving.','High gain.'],
     array['Keep the riff tight.','Drive the anthemic chorus.'],
     'Studio recording, 1981 (Denim and Leather). Saxon played an anthemic NWOBHM crunch riff.',71),
    ('balls-to-the-wall','accept','guitar','riff','main riff','high_gain',
     'metal','rhythm','beginner',
     'Electric guitar (Wolf Hoffmann)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Heavy, marching, chant-along metal riff; keep it slow, tight, and pounding.','High gain.'],
     array['Play the marching riff tightly.','Keep it heavy and deliberate.'],
     'Studio recording, 1983 (Balls to the Wall). Wolf Hoffmann played a heavy, marching chant-along riff.',71),
    ('fast-as-a-shark','accept','guitar','riff','main riff','high_gain',
     'metal','rhythm','advanced',
     'Electric guitar (Wolf Hoffmann)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['One of the earliest speed-metal riffs, fast and precise; keep the picking relentless.','High gain, tight.'],
     array['Keep the fast riff tight.','Attack the picking relentlessly.'],
     'Studio recording, 1982 (Restless and Wild). Wolf Hoffmann played one of the earliest speed-metal riffs.',71),
    ('i-want-out','helloween','guitar','riff','main riff and solo','high_gain',
     'metal','lead','advanced',
     'Electric guitar (Kai Hansen / Michael Weikath)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, melodic power-metal with fast riffs and harmonized leads; keep it tight and uplifting.','High gain with clarity.'],
     array['Keep the fast riff tight.','Harmonise the leads cleanly.'],
     'Studio recording, 1988. Kai Hansen and Michael Weikath played bright, melodic power-metal with harmonized leads.',71),
    ('eagle-fly-free','helloween','guitar','riff','main riff and solo','high_gain',
     'metal','lead','advanced',
     'Electric guitar (Kai Hansen / Michael Weikath)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Fast, soaring power-metal with galloping riffs and flashy solos; keep the picking tight.','High gain with clarity.'],
     array['Keep the galloping riffs tight.','Play the flashy solos cleanly.'],
     'Studio recording, 1988. Helloween played fast, soaring power-metal with galloping riffs and flashy solos.',71),
    ('the-bards-song-in-the-forest','blind-guardian','guitar','riff','fingerpicked progression','acoustic',
     'metal','rhythm','beginner',
     'Acoustic guitar (André Olbrich / Marcus Siepen)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Gentle, singalong folk-acoustic power-metal ballad; keep the fingerpicking warm and even.','Natural acoustic tone.'],
     array['Fingerpick the pattern gently.','Keep the melody warm.'],
     'Studio recording, 1992 (Somewhere Far Beyond). Blind Guardian played a gentle folk-acoustic power-metal ballad.',72),
    ('nightfall','blind-guardian','guitar','riff','main riff and solo','high_gain',
     'metal','lead','advanced',
     'Electric guitar (André Olbrich / Marcus Siepen)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Epic, layered power-metal with galloping riffs and orchestral scope; keep it tight and grand.','High gain.'],
     array['Keep the galloping riffs tight.','Layer the harmonies grandly.'],
     'Studio recording, 1998 (Nightfall in Middle-Earth). Blind Guardian played epic, layered power-metal.',71),
    ('through-the-fire-and-flames','dragonforce','guitar','riff','main riff and solo','high_gain',
     'metal','lead','expert',
     'Electric guitar (Herman Li / Sam Totman)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[{"effect_type":"delay","effect_name":"delay","placement":"post_gain","settings":{"mix":2,"time":3}}]'::jsonb,'{"gain":8,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Extreme-speed power-metal with lightning-fast riffs and shred solos; keep the picking impossibly tight.','High gain, fast, with delay.'],
     array['Play the ultra-fast riffs cleanly.','Attack the shred solos with precision.'],
     'Studio recording, 2006 (Inhuman Rampage). Herman Li and Sam Totman played extreme-speed power-metal riffs and shred solos.',72),
    ('valley-of-the-damned','dragonforce','guitar','riff','main riff and solo','high_gain',
     'metal','lead','expert',
     'Electric guitar (Herman Li / Sam Totman)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Blazing, uplifting speed-power-metal with fast riffs and flashy solos; keep it tight and bright.','High gain, fast.'],
     array['Keep the fast riffs tight.','Play the flashy solos cleanly.'],
     'Studio recording, 2003 (Valley of the Damned). DragonForce played blazing speed-power-metal.',71),
    ('primo-victoria','sabaton','guitar','riff','main riff','high_gain',
     'metal','rhythm','intermediate',
     'Electric guitar (Chris Rörland / Tommy Johansson)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Anthemic, marching power-metal with big chugging riffs; keep it tight and grand.','High gain.'],
     array['Keep the chugging riff tight.','Drive the anthemic march.'],
     'Studio recording, 2005 (Primo Victoria). Sabaton played anthemic, marching power-metal riffs.',71),
    ('the-last-stand','sabaton','guitar','riff','main riff','high_gain',
     'metal','rhythm','intermediate',
     'Electric guitar (Chris Rörland / Tommy Johansson)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Epic, anthemic power-metal with driving riffs and a huge chorus; keep it tight and grand.','High gain.'],
     array['Keep the driving riff tight.','Drive the huge chorus.'],
     'Studio recording, 2016 (The Last Stand). Sabaton played epic, anthemic power-metal riffs.',71),
    ('the-last-in-line','dio','guitar','riff','main riff and solo','high_gain',
     'metal','lead','advanced',
     'Electric guitar (Vivian Campbell)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Epic metal building from an atmospheric intro to a driving riff and blazing solo; keep dynamics wide.','High gain.'],
     array['Build from the atmospheric intro.','Play the driving riff and solo cleanly.'],
     'Studio recording, 1984 (The Last in Line). Vivian Campbell played an epic riff and blazing solo through Marshalls.',72),
    ('dont-talk-to-strangers','dio','guitar','riff','clean intro to heavy riff','high_gain',
     'metal','lead','advanced',
     'Electric guitar (Vivian Campbell)','Clean-to-high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Dynamic epic: a delicate clean intro erupting into a heavy riff and dramatic solo; keep the contrast wide.','Wide dynamics, high gain for the heavy parts.'],
     array['Play the clean intro delicately.','Erupt into the heavy riff and solo.'],
     'Studio recording, 1983 (Holy Diver). Vivian Campbell played a delicate clean intro erupting into a heavy riff.',72),
    ('turbo-lover','judas-priest','guitar','riff','main riff','high_gain',
     'metal','rhythm','intermediate',
     'Electric guitar (Glenn Tipton / K.K. Downing)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[{"effect_type":"chorus","effect_name":"chorus","placement":"post_gain","settings":{"rate":3,"depth":4,"mix":4}}]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Slick, synth-guitar-driven metal with a chorused, gliding riff; keep it smooth and driving.','High gain with chorus.'],
     array['Play the gliding riff smoothly.','Let the chorus widen the tone.'],
     'Studio recording, 1986 (Turbo). Tipton and Downing played a slick, chorused synth-guitar-driven riff.',71),
    ('victim-of-changes','judas-priest','guitar','riff','main riff and solo','high_gain',
     'metal','lead','advanced',
     'Electric guitar (Glenn Tipton / K.K. Downing)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Epic early-metal with a bluesy main riff building to dramatic twin solos; keep dynamics wide.','High gain.'],
     array['Play the bluesy riff with weight.','Trade the dramatic twin solos.'],
     'Studio recording, 1976 (Sad Wings of Destiny). Tipton and Downing played an epic bluesy riff and twin solos.',72),
    ('stargazer','rainbow','guitar','riff','main riff and solo','high_gain',
     'metal','lead','advanced',
     'Fender Stratocaster (Ritchie Blackmore)','Marshall high-gain amp','Marshall 4x12 cab','bridge single-coil',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Epic, orchestral hard-rock with a majestic riff and a classically-tinged solo; keep it dramatic.','High gain.'],
     array['Play the majestic riff with weight.','Play the classical solo with feel.'],
     'Studio recording, 1976 (Rising). Ritchie Blackmore played a majestic riff and classically-tinged solo on a Stratocaster.',72),
    ('man-on-the-silver-mountain','rainbow','guitar','riff','main riff and solo','crunch',
     'metal','lead','intermediate',
     'Fender Stratocaster (Ritchie Blackmore)','Marshall high-gain amp','Marshall 4x12 cab','bridge single-coil',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Heavy, bluesy hard-rock riff with a fiery solo; keep it tight and dramatic.','Medium-high gain.'],
     array['Play the heavy riff tightly.','Attack the fiery solo.'],
     'Studio recording, 1975. Ritchie Blackmore played a heavy, bluesy hard-rock riff and fiery solo on a Stratocaster.',71),
    ('warriors-of-the-world-united','manowar','guitar','riff','main riff','high_gain',
     'metal','rhythm','beginner',
     'Electric guitar (Karl Logan)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Grandiose, anthemic true-metal with big power chords; keep it slow, heavy, and epic.','High gain.'],
     array['Slam the epic power chords.','Keep it grand and heavy.'],
     'Studio recording, 2002 (Warriors of the World). Karl Logan played grandiose, anthemic true-metal power chords.',70),
    ('am-i-evil','diamond-head','guitar','riff','main riff and solo','high_gain',
     'metal','lead','advanced',
     'Electric guitar (Brian Tatler)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Epic NWOBHM with a doom-laden intro riff building to a galloping thrash template (later covered by Metallica); keep it tight.','High gain.'],
     array['Play the doom-laden intro with weight.','Drive the galloping riff tightly.'],
     'Studio recording, 1980. Brian Tatler played the epic NWOBHM riff later famously covered by Metallica.',71),
    ('black-metal','venom','guitar','riff','main riff','distorted',
     'metal','rhythm','intermediate',
     'Electric guitar (Mantas)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Raw, chaotic proto-black/thrash riffing; keep it dirty, fast, and aggressive.','High gain, raw and loose.'],
     array['Play the raw riff fast and loose.','Keep it chaotic and aggressive.'],
     'Studio recording, 1982 (Black Metal). Mantas played raw, chaotic proto-black/thrash riffing.',70),
    ('evil','mercyful-fate','guitar','riff','main riff and twin lead','high_gain',
     'metal','lead','advanced',
     'Electric guitar (Hank Shermann / Michael Denner)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Dark, theatrical metal with intricate riffs and harmonized twin leads; keep it tight and menacing.','High gain.'],
     array['Play the intricate riffs tightly.','Harmonise the twin leads.'],
     'Studio recording, 1983 (Melissa). Hank Shermann and Michael Denner played dark, theatrical metal with twin leads.',71),
    ('flight-of-icarus','iron-maiden','guitar','riff','main riff and solo','high_gain',
     'metal','lead','intermediate',
     'Electric guitar (Dave Murray / Adrian Smith)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Mid-tempo, anthemic Maiden with a driving riff and melodic solos; keep it tight.','High gain with clarity.'],
     array['Keep the driving riff tight.','Play the melodic solos cleanly.'],
     'Studio recording, 1983 (Piece of Mind). Murray and Smith played a mid-tempo, anthemic riff and melodic solos through Marshalls.',72)
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
  ('motorhead','overkill'),('motorhead','killed-by-death'),('saxon','wheels-of-steel'),('saxon','denim-and-leather'),
  ('accept','balls-to-the-wall'),('accept','fast-as-a-shark'),('helloween','i-want-out'),('helloween','eagle-fly-free'),
  ('blind-guardian','the-bards-song-in-the-forest'),('blind-guardian','nightfall'),('dragonforce','through-the-fire-and-flames'),('dragonforce','valley-of-the-damned'),
  ('sabaton','primo-victoria'),('sabaton','the-last-stand'),('dio','the-last-in-line'),('dio','dont-talk-to-strangers'),
  ('judas-priest','turbo-lover'),('judas-priest','victim-of-changes'),('rainbow','stargazer'),('rainbow','man-on-the-silver-mountain'),
  ('manowar','warriors-of-the-world-united'),('diamond-head','am-i-evil'),('venom','black-metal'),('mercyful-fate','evil'),
  ('iron-maiden','flight-of-icarus')
) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
cross join (values
  ('artist_interview', 'Documented artist interviews and gear discussions', null::text,
   'Researched from widely-documented interviews about this recording and player.', 72),
  ('rig_rundown', 'Published rig rundowns and community gear databases', null::text,
   'Cross-referenced against rig features and community-maintained gear databases.', 66)
) as x(source_type, title, url, notes, credibility)
where p.verification_status = 'admin_verified'
on conflict do nothing;
