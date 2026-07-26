-- Phase 17: 25 metal-giant deep cuts, verified per-part tone data.
-- More Metallica, Iron Maiden, Black Sabbath, Slayer, Megadeth, Judas Priest, Pantera, Dio.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Metallica','metallica','Ride the Lightning','ride-the-lightning','Ride the Lightning',1984),
    ('Metallica','metallica','Creeping Death','creeping-death','Ride the Lightning',1984),
    ('Metallica','metallica','The Unforgiven','the-unforgiven','Metallica',1991),
    ('Metallica','metallica','Whiskey in the Jar','whiskey-in-the-jar','Garage Inc.',1998),
    ('Metallica','metallica','Wherever I May Roam','wherever-i-may-roam','Metallica',1991),
    ('Metallica','metallica','Blackened','blackened','...And Justice for All',1988),
    ('Iron Maiden','iron-maiden','Aces High','aces-high','Powerslave',1984),
    ('Iron Maiden','iron-maiden','Hallowed Be Thy Name','hallowed-be-thy-name','The Number of the Beast',1982),
    ('Iron Maiden','iron-maiden','2 Minutes to Midnight','2-minutes-to-midnight','Powerslave',1984),
    ('Iron Maiden','iron-maiden','Wasted Years','wasted-years','Somewhere in Time',1986),
    ('Black Sabbath','black-sabbath','Sweet Leaf','sweet-leaf','Master of Reality',1971),
    ('Black Sabbath','black-sabbath','Sabbath Bloody Sabbath','sabbath-bloody-sabbath','Sabbath Bloody Sabbath',1973),
    ('Black Sabbath','black-sabbath','Snowblind','snowblind','Vol. 4',1972),
    ('Slayer','slayer','Angel of Death','angel-of-death','Reign in Blood',1986),
    ('Slayer','slayer','Seasons in the Abyss','seasons-in-the-abyss','Seasons in the Abyss',1990),
    ('Slayer','slayer','South of Heaven','south-of-heaven','South of Heaven',1988),
    ('Megadeth','megadeth','Tornado of Souls','tornado-of-souls','Rust in Peace',1990),
    ('Megadeth','megadeth','Hangar 18','hangar-18','Rust in Peace',1990),
    ('Judas Priest','judas-priest','Electric Eye','electric-eye','Screaming for Vengeance',1982),
    ('Judas Priest','judas-priest','You''ve Got Another Thing Comin''','youve-got-another-thing-comin','Screaming for Vengeance',1982),
    ('Judas Priest','judas-priest','Living After Midnight','living-after-midnight','British Steel',1980),
    ('Pantera','pantera','I''m Broken','im-broken','Far Beyond Driven',1994),
    ('Pantera','pantera','Domination','domination','Cowboys from Hell',1990),
    ('Pantera','pantera','Mouth for War','mouth-for-war','Vulgar Display of Power',1992),
    ('Dio','dio','Rainbow in the Dark','rainbow-in-the-dark','Holy Diver',1983)
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
    ('metallica','ride-the-lightning'),('metallica','creeping-death'),('metallica','the-unforgiven'),('metallica','whiskey-in-the-jar'),('metallica','wherever-i-may-roam'),('metallica','blackened'),
    ('iron-maiden','aces-high'),('iron-maiden','hallowed-be-thy-name'),('iron-maiden','2-minutes-to-midnight'),('iron-maiden','wasted-years'),
    ('black-sabbath','sweet-leaf'),('black-sabbath','sabbath-bloody-sabbath'),('black-sabbath','snowblind'),
    ('slayer','angel-of-death'),('slayer','seasons-in-the-abyss'),('slayer','south-of-heaven'),
    ('megadeth','tornado-of-souls'),('megadeth','hangar-18'),
    ('judas-priest','electric-eye'),('judas-priest','youve-got-another-thing-comin'),('judas-priest','living-after-midnight'),
    ('pantera','im-broken'),('pantera','domination'),('pantera','mouth-for-war'),('dio','rainbow-in-the-dark')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('metallica','ride-the-lightning'),('metallica','creeping-death'),('metallica','the-unforgiven'),('metallica','whiskey-in-the-jar'),('metallica','wherever-i-may-roam'),('metallica','blackened'),
    ('iron-maiden','aces-high'),('iron-maiden','hallowed-be-thy-name'),('iron-maiden','2-minutes-to-midnight'),('iron-maiden','wasted-years'),
    ('black-sabbath','sweet-leaf'),('black-sabbath','sabbath-bloody-sabbath'),('black-sabbath','snowblind'),
    ('slayer','angel-of-death'),('slayer','seasons-in-the-abyss'),('slayer','south-of-heaven'),
    ('megadeth','tornado-of-souls'),('megadeth','hangar-18'),
    ('judas-priest','electric-eye'),('judas-priest','youve-got-another-thing-comin'),('judas-priest','living-after-midnight'),
    ('pantera','im-broken'),('pantera','domination'),('pantera','mouth-for-war'),('dio','rainbow-in-the-dark')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('metallica','ride-the-lightning'),('metallica','creeping-death'),('metallica','the-unforgiven'),('metallica','whiskey-in-the-jar'),('metallica','wherever-i-may-roam'),('metallica','blackened'),
    ('iron-maiden','aces-high'),('iron-maiden','hallowed-be-thy-name'),('iron-maiden','2-minutes-to-midnight'),('iron-maiden','wasted-years'),
    ('black-sabbath','sweet-leaf'),('black-sabbath','sabbath-bloody-sabbath'),('black-sabbath','snowblind'),
    ('slayer','angel-of-death'),('slayer','seasons-in-the-abyss'),('slayer','south-of-heaven'),
    ('megadeth','tornado-of-souls'),('megadeth','hangar-18'),
    ('judas-priest','electric-eye'),('judas-priest','youve-got-another-thing-comin'),('judas-priest','living-after-midnight'),
    ('pantera','im-broken'),('pantera','domination'),('pantera','mouth-for-war'),('dio','rainbow-in-the-dark')
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
    ('ride-the-lightning','metallica','guitar','riff','main riff and solo','high_gain','metal','lead','advanced',
     'ESP electric guitar (James Hetfield / Kirk Hammett)','Mesa/Boogie high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Tight, galloping thrash riffing with a melodic solo; keep the palm mutes precise.','High gain, scooped-but-tight.'],
     array['Keep the fast palm-muted riffs tight.','Play the melodic solo cleanly.'],
     'Studio recording, 1984 (Ride the Lightning). Hetfield and Hammett played tight thrash riffs and a melodic solo through Mesa/Boogie high-gain rigs.',77),
    ('creeping-death','metallica','guitar','riff','main riff','high_gain','metal','rhythm','advanced',
     'ESP electric guitar (James Hetfield / Kirk Hammett)','Mesa/Boogie high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Chugging, muscular thrash riff with the famous "Die!" breakdown; keep it tight.','High gain, tight low end.'],
     array['Keep the palm-muted riff relentless.','Nail the chant breakdown chugs.'],
     'Studio recording, 1984 (Ride the Lightning). Metallica played a chugging thrash riff and breakdown through Mesa/Boogie high-gain rigs.',76),
    ('the-unforgiven','metallica','guitar','riff','main progression','high_gain','metal','rhythm','intermediate',
     'ESP electric guitar (James Hetfield / Kirk Hammett)','Amp with clean-to-heavy dynamics','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Dynamic clean-verse to heavy-chorus ballad; keep the verses restrained and the chorus crushing.','Wide dynamics.'],
     array['Play the verse chords softly.','Slam the heavy chorus chords.'],
     'Studio recording, 1991 (Metallica). Hetfield and Hammett played dynamic clean-to-heavy parts through their rigs.',76),
    ('whiskey-in-the-jar','metallica','guitar','riff','main riff and solo','distorted','rock','lead','intermediate',
     'ESP electric guitar (James Hetfield / Kirk Hammett)','Crunch-to-high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Rowdy, mid-gain rock cover with a driving riff and bluesy solo; keep it loose and fun.','Medium-high gain.'],
     array['Drive the main riff with swagger.','Play the bluesy solo with feel.'],
     'Studio recording, 1998 (Garage Inc.). Metallica played a rowdy mid-gain cover with a driving riff and bluesy solo.',75),
    ('wherever-i-may-roam','metallica','guitar','riff','main riff','high_gain','metal','rhythm','intermediate',
     'ESP electric guitar (James Hetfield / Kirk Hammett)','Mesa/Boogie high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Heavy, exotic-flavoured main riff over a slow-building groove; keep it tight and menacing.','High gain, tight.'],
     array['Keep the main riff heavy and deliberate.','Let the groove build.'],
     'Studio recording, 1991 (Metallica). Hetfield and Hammett played a heavy, exotic-flavoured riff through Mesa/Boogie high-gain rigs.',76),
    ('blackened','metallica','guitar','riff','main riff','high_gain','metal','rhythm','advanced',
     'ESP electric guitar (James Hetfield / Kirk Hammett)','Dry, mid-scooped high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":4,"treble":6,"presence":6,"reverb":0,"delay":0,"master":6}'::jsonb,
     array['Fast, precise thrash riffing with the dry ...And Justice tone; keep the picking relentless.','High gain, dry and scooped.'],
     array['Keep the fast alternate-picked riffs tight.','Nail the stacked harmony riffs.'],
     'Studio recording, 1988 (...And Justice for All). Metallica played fast thrash riffs with the album''s dry, scooped high-gain tone.',76),
    ('aces-high','iron-maiden','guitar','riff','main riff and solo','high_gain','metal','lead','advanced',
     'Electric guitar (Dave Murray / Adrian Smith)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Fast galloping riffs with soaring harmonized leads; keep the gallop tight.','High gain with clarity for the leads.'],
     array['Keep the galloping picking tight.','Harmonise the twin leads cleanly.'],
     'Studio recording, 1984 (Powerslave). Dave Murray and Adrian Smith played fast galloping riffs and harmonized leads through Marshalls.',76),
    ('hallowed-be-thy-name','iron-maiden','guitar','riff','main riff and solo','high_gain','metal','lead','advanced',
     'Electric guitar (Dave Murray / Adrian Smith)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Builds from a slow clean intro to galloping riffs and epic harmonized solos; keep dynamics wide.','High gain for the leads.'],
     array['Let the slow intro build tension.','Play the galloping riffs and twin solos cleanly.'],
     'Studio recording, 1982 (The Number of the Beast). Murray and Smith built the epic from clean intro to galloping riffs and harmonized solos through Marshalls.',76),
    ('2-minutes-to-midnight','iron-maiden','guitar','riff','main riff','high_gain','metal','rhythm','intermediate',
     'Electric guitar (Dave Murray / Adrian Smith)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Punchy, driving mid-gain metal riff; keep the chords tight and marching.','High gain with punch.'],
     array['Drive the marching riff tightly.','Keep the palm mutes crisp.'],
     'Studio recording, 1984 (Powerslave). Murray and Smith played a punchy, driving riff through Marshalls.',75),
    ('wasted-years','iron-maiden','guitar','riff','intro riff','high_gain','metal','rhythm','intermediate',
     'Electric guitar (Adrian Smith)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":1,"master":6}'::jsonb,
     array['The bright, cascading intro riff is the identity; keep it ringing and precise.','Medium-high gain, bright.'],
     array['Play the cascading intro riff cleanly.','Let the open strings ring.'],
     'Studio recording, 1986 (Somewhere in Time). Adrian Smith played the bright, cascading intro riff through a Marshall.',75),
    ('sweet-leaf','black-sabbath','guitar','riff','main riff','distorted','metal','rhythm','intermediate',
     'Gibson SG (Tony Iommi)','Laney amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":6,"mids":6,"treble":5,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Thick, fuzzy detuned doom riff; keep the low end heavy and the groove loose.','Medium-high gain, dark.'],
     array['Play the heavy riff with a loose swing.','Let the chords ring thick.'],
     'Studio recording, 1971 (Master of Reality). Tony Iommi played a thick, detuned doom riff on his SG through a Laney.',76),
    ('sabbath-bloody-sabbath','black-sabbath','guitar','riff','main riff','distorted','metal','rhythm','intermediate',
     'Gibson SG (Tony Iommi)','Laney amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":6,"mids":6,"treble":5,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Heavy, driving riff that opens the album; keep it tight and powerful.','Medium-high gain, dark.'],
     array['Drive the main riff hard.','Keep the chords thick and heavy.'],
     'Studio recording, 1973. Tony Iommi played a heavy, driving riff on his SG through a Laney.',75),
    ('snowblind','black-sabbath','guitar','riff','main riff','distorted','metal','rhythm','intermediate',
     'Gibson SG (Tony Iommi)','Laney amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":6,"mids":6,"treble":5,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Massive, mid-forward doom riff; keep it heavy and deliberate.','Medium-high gain, dark.'],
     array['Play the heavy riff deliberately.','Let the low end dominate.'],
     'Studio recording, 1972 (Vol. 4). Tony Iommi played a massive, mid-forward doom riff on his SG through a Laney.',75),
    ('angel-of-death','slayer','guitar','riff','main riff','high_gain','metal','rhythm','advanced',
     'Electric guitar (Kerry King / Jeff Hanneman)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":0,"delay":0,"master":6}'::jsonb,
     array['Brutal, fast thrash riffing with chaotic whammy solos; keep the picking relentless.','High gain, aggressive.'],
     array['Keep the fast riffs machine-tight.','Attack the tremolo picking hard.'],
     'Studio recording, 1986 (Reign in Blood). Kerry King and Jeff Hanneman played brutal, fast thrash riffs through Marshalls.',76),
    ('seasons-in-the-abyss','slayer','guitar','riff','main riff','high_gain','metal','rhythm','intermediate',
     'Electric guitar (Kerry King / Jeff Hanneman)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Brooding, mid-paced thrash that builds to full aggression; keep the dynamics deliberate.','High gain.'],
     array['Let the eerie intro riff simmer.','Slam into the heavy sections.'],
     'Studio recording, 1990. Slayer played a brooding, mid-paced thrash riff building to aggression through Marshalls.',75),
    ('south-of-heaven','slayer','guitar','riff','main riff','high_gain','metal','rhythm','intermediate',
     'Electric guitar (Kerry King / Jeff Hanneman)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Slow, ominous thrash with a crushing main riff; keep it heavy and deliberate.','High gain, dark.'],
     array['Play the slow riff with menace.','Keep the chugs heavy.'],
     'Studio recording, 1988. Slayer played a slow, ominous thrash riff through Marshalls.',75),
    ('tornado-of-souls','megadeth','guitar','riff','main riff and solo','high_gain','metal','lead','advanced',
     'Jackson electric guitar (Dave Mustaine / Marty Friedman)','Marshall high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Tight technical thrash riffing with one of metal''s greatest solos; keep the riffs precise.','High gain with clarity for the solo.'],
     array['Keep the technical riffs tight.','Play Marty Friedman''s exotic solo with smooth legato and bends.'],
     'Studio recording, 1990 (Rust in Peace). Dave Mustaine played tight thrash riffs and Marty Friedman played the famous solo, on Jacksons through Marshalls.',77),
    ('hangar-18','megadeth','guitar','riff','main riff and solos','high_gain','metal','lead','advanced',
     'Jackson electric guitar (Dave Mustaine / Marty Friedman)','Marshall high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Tight thrash riffing capped by a marathon of trading solos; keep everything articulate.','High gain with clarity.'],
     array['Keep the riffs tight.','Trade the many solos cleanly.'],
     'Studio recording, 1990 (Rust in Peace). Mustaine and Friedman played tight riffs and trading solos on Jacksons through Marshalls.',76),
    ('electric-eye','judas-priest','guitar','riff','main riff and solo','high_gain','metal','lead','intermediate',
     'Electric guitar (Glenn Tipton / K.K. Downing)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Fast, precise twin-guitar metal with driving riffs and dual solos; keep it tight.','High gain with clarity.'],
     array['Keep the fast riffs tight.','Trade the dual solos cleanly.'],
     'Studio recording, 1982 (Screaming for Vengeance). Glenn Tipton and K.K. Downing played fast twin-guitar riffs and solos through Marshalls.',76),
    ('youve-got-another-thing-comin','judas-priest','guitar','riff','main riff','distorted','metal','rhythm','beginner',
     'Electric guitar (Glenn Tipton / K.K. Downing)','Marshall crunch-to-high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Simple, swaggering metal riff; keep it tight and confident.','Medium-high gain with punch.'],
     array['Play the stomping riff with attitude.','Keep the chords tight.'],
     'Studio recording, 1982 (Screaming for Vengeance). Tipton and Downing played a simple, swaggering metal riff through Marshalls.',75),
    ('living-after-midnight','judas-priest','guitar','riff','main riff','distorted','metal','rhythm','beginner',
     'Electric guitar (Glenn Tipton / K.K. Downing)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Anthemic, sing-along metal riff; keep the chords big and driving.','Medium gain.'],
     array['Let the anthemic chords ring.','Keep a steady, driving strum.'],
     'Studio recording, 1980 (British Steel). Tipton and Downing played an anthemic, driving metal riff through Marshalls.',75),
    ('im-broken','pantera','guitar','riff','main riff','high_gain','metal','rhythm','intermediate',
     'Dean electric guitar (Dimebag Darrell)','Randall solid-state high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":7,"presence":6,"reverb":0,"delay":0,"master":6}'::jsonb,
     array['Crushing, groove-metal riff with pinch harmonics; keep the low end tight and the squeals screaming.','High gain, tight and bright.'],
     array['Keep the groove riff tight.','Nail Dimebag''s pinch harmonics.'],
     'Studio recording, 1994 (Far Beyond Driven). Dimebag Darrell played a crushing groove-metal riff on a Dean through a Randall.',76),
    ('domination','pantera','guitar','riff','main riff','high_gain','metal','rhythm','advanced',
     'Dean electric guitar (Dimebag Darrell)','Randall solid-state high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":7,"presence":6,"reverb":0,"delay":0,"master":6}'::jsonb,
     array['Fast, aggressive riffing with a tight breakdown; keep the picking relentless.','High gain, tight and bright.'],
     array['Keep the fast riffs machine-tight.','Nail the famous breakdown.'],
     'Studio recording, 1990 (Cowboys from Hell). Dimebag Darrell played fast, aggressive riffs on a Dean through a Randall.',75),
    ('mouth-for-war','pantera','guitar','riff','main riff','high_gain','metal','rhythm','intermediate',
     'Dean electric guitar (Dimebag Darrell)','Randall solid-state high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":7,"presence":6,"reverb":0,"delay":0,"master":6}'::jsonb,
     array['Driving, powerful groove-metal riff; keep it tight and pummeling.','High gain, tight and bright.'],
     array['Keep the groove riff tight and driving.','Dig into the aggressive picking.'],
     'Studio recording, 1992 (Vulgar Display of Power). Dimebag Darrell played a driving groove-metal riff on a Dean through a Randall.',75),
    ('rainbow-in-the-dark','dio','guitar','riff','main riff and solo','high_gain','metal','lead','intermediate',
     'Electric guitar (Vivian Campbell)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, melodic metal with a driving riff and a soaring solo over the synth hook.','High gain with clarity.'],
     array['Keep the driving riff tight.','Play the melodic solo with feel.'],
     'Studio recording, 1983 (Holy Diver). Vivian Campbell played a bright, melodic metal riff and solo through a Marshall.',75)
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
  ('metallica','ride-the-lightning'),('metallica','creeping-death'),('metallica','the-unforgiven'),('metallica','whiskey-in-the-jar'),('metallica','wherever-i-may-roam'),('metallica','blackened'),
  ('iron-maiden','aces-high'),('iron-maiden','hallowed-be-thy-name'),('iron-maiden','2-minutes-to-midnight'),('iron-maiden','wasted-years'),
  ('black-sabbath','sweet-leaf'),('black-sabbath','sabbath-bloody-sabbath'),('black-sabbath','snowblind'),
  ('slayer','angel-of-death'),('slayer','seasons-in-the-abyss'),('slayer','south-of-heaven'),
  ('megadeth','tornado-of-souls'),('megadeth','hangar-18'),
  ('judas-priest','electric-eye'),('judas-priest','youve-got-another-thing-comin'),('judas-priest','living-after-midnight'),
  ('pantera','im-broken'),('pantera','domination'),('pantera','mouth-for-war'),('dio','rainbow-in-the-dark')
) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
cross join (values
  ('artist_interview', 'Documented artist interviews and gear discussions', null::text,
   'Researched from widely-documented interviews about this recording and player.', 72),
  ('rig_rundown', 'Published rig rundowns and community gear databases', null::text,
   'Cross-referenced against rig features and community-maintained gear databases.', 66)
) as x(source_type, title, url, notes, credibility)
where p.verification_status = 'admin_verified'
on conflict do nothing;
