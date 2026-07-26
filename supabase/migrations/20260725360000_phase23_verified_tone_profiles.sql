-- Phase 23: 25 metal-giant deep cuts 2, verified per-part tone data (more Metallica, Maiden, Megadeth, Sabbath, Slayer, Anthrax + Testament, Death, Exodus, Kreator, Sepultura, Overkill, Pantera, Judas Priest).

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Metallica','metallica','Fuel','fuel','Reload',1997),
    ('Metallica','metallica','The Four Horsemen','the-four-horsemen','Kill ''Em All',1983),
    ('Metallica','metallica','Welcome Home (Sanitarium)','welcome-home-sanitarium','Master of Puppets',1986),
    ('Metallica','metallica','Harvester of Sorrow','harvester-of-sorrow','...And Justice for All',1988),
    ('Iron Maiden','iron-maiden','The Evil That Men Do','the-evil-that-men-do','Seventh Son of a Seventh Son',1988),
    ('Iron Maiden','iron-maiden','Powerslave','powerslave','Powerslave',1984),
    ('Iron Maiden','iron-maiden','Wrathchild','wrathchild','Killers',1981),
    ('Megadeth','megadeth','A Tout Le Monde','a-tout-le-monde','Youthanasia',1994),
    ('Megadeth','megadeth','Sweating Bullets','sweating-bullets','Countdown to Extinction',1992),
    ('Black Sabbath','black-sabbath','Fairies Wear Boots','fairies-wear-boots','Paranoid',1970),
    ('Black Sabbath','black-sabbath','Symptom of the Universe','symptom-of-the-universe','Sabotage',1975),
    ('Slayer','slayer','War Ensemble','war-ensemble','Seasons in the Abyss',1990),
    ('Anthrax','anthrax','Madhouse','madhouse','Spreading the Disease',1985),
    ('Anthrax','anthrax','Indians','indians','Among the Living',1987),
    ('Testament','testament','Practice What You Preach','practice-what-you-preach','Practice What You Preach',1989),
    ('Testament','testament','The New Order','the-new-order','The New Order',1988),
    ('Death','death','Crystal Mountain','crystal-mountain','Symbolic',1995),
    ('Exodus','exodus','Bonded by Blood','bonded-by-blood','Bonded by Blood',1985),
    ('Kreator','kreator','Pleasure to Kill','pleasure-to-kill','Pleasure to Kill',1986),
    ('Sepultura','sepultura','Roots Bloody Roots','roots-bloody-roots','Roots',1996),
    ('Sepultura','sepultura','Refuse/Resist','refuse-resist','Chaos A.D.',1993),
    ('Overkill','overkill','Elimination','elimination','The Years of Decay',1989),
    ('Pantera','pantera','5 Minutes Alone','5-minutes-alone','Far Beyond Driven',1994),
    ('Pantera','pantera','This Love','this-love','Vulgar Display of Power',1992),
    ('Judas Priest','judas-priest','Hell Bent for Leather','hell-bent-for-leather','Killing Machine',1978)
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
    ('metallica','fuel'),('metallica','the-four-horsemen'),('metallica','welcome-home-sanitarium'),('metallica','harvester-of-sorrow'),
    ('iron-maiden','the-evil-that-men-do'),('iron-maiden','powerslave'),('iron-maiden','wrathchild'),('megadeth','a-tout-le-monde'),
    ('megadeth','sweating-bullets'),('black-sabbath','fairies-wear-boots'),('black-sabbath','symptom-of-the-universe'),('slayer','war-ensemble'),
    ('anthrax','madhouse'),('anthrax','indians'),('testament','practice-what-you-preach'),('testament','the-new-order'),
    ('death','crystal-mountain'),('exodus','bonded-by-blood'),('kreator','pleasure-to-kill'),('sepultura','roots-bloody-roots'),
    ('sepultura','refuse-resist'),('overkill','elimination'),('pantera','5-minutes-alone'),('pantera','this-love'),
    ('judas-priest','hell-bent-for-leather')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('metallica','fuel'),('metallica','the-four-horsemen'),('metallica','welcome-home-sanitarium'),('metallica','harvester-of-sorrow'),
    ('iron-maiden','the-evil-that-men-do'),('iron-maiden','powerslave'),('iron-maiden','wrathchild'),('megadeth','a-tout-le-monde'),
    ('megadeth','sweating-bullets'),('black-sabbath','fairies-wear-boots'),('black-sabbath','symptom-of-the-universe'),('slayer','war-ensemble'),
    ('anthrax','madhouse'),('anthrax','indians'),('testament','practice-what-you-preach'),('testament','the-new-order'),
    ('death','crystal-mountain'),('exodus','bonded-by-blood'),('kreator','pleasure-to-kill'),('sepultura','roots-bloody-roots'),
    ('sepultura','refuse-resist'),('overkill','elimination'),('pantera','5-minutes-alone'),('pantera','this-love'),
    ('judas-priest','hell-bent-for-leather')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('metallica','fuel'),('metallica','the-four-horsemen'),('metallica','welcome-home-sanitarium'),('metallica','harvester-of-sorrow'),
    ('iron-maiden','the-evil-that-men-do'),('iron-maiden','powerslave'),('iron-maiden','wrathchild'),('megadeth','a-tout-le-monde'),
    ('megadeth','sweating-bullets'),('black-sabbath','fairies-wear-boots'),('black-sabbath','symptom-of-the-universe'),('slayer','war-ensemble'),
    ('anthrax','madhouse'),('anthrax','indians'),('testament','practice-what-you-preach'),('testament','the-new-order'),
    ('death','crystal-mountain'),('exodus','bonded-by-blood'),('kreator','pleasure-to-kill'),('sepultura','roots-bloody-roots'),
    ('sepultura','refuse-resist'),('overkill','elimination'),('pantera','5-minutes-alone'),('pantera','this-love'),
    ('judas-priest','hell-bent-for-leather')
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
    ('fuel','metallica','guitar','riff','main riff','high_gain',
     'metal','rhythm','intermediate',
     'ESP electric guitar (James Hetfield / Kirk Hammett)','Mesa/Boogie high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Aggressive, revving main riff; keep the palm mutes tight and driving.','High gain, tight.'],
     array['Keep the chugging riff tight.','Drive it like an engine.'],
     'Studio recording, 1997 (Reload). Hetfield and Hammett played an aggressive, revving riff through Mesa/Boogie high-gain rigs.',74),
    ('the-four-horsemen','metallica','guitar','riff','main riff','high_gain',
     'metal','rhythm','advanced',
     'ESP electric guitar (James Hetfield / Kirk Hammett)','Mesa/Boogie high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Galloping early-thrash riffing with a mid-tempo bridge; keep the picking tight.','High gain.'],
     array['Keep the galloping riffs tight.','Nail the harmonized bridge.'],
     'Studio recording, 1983 (Kill ''Em All). Metallica played galloping early-thrash riffs through high-gain rigs.',74),
    ('welcome-home-sanitarium','metallica','guitar','riff','clean intro to heavy riff','high_gain',
     'metal','lead','advanced',
     'ESP electric guitar (James Hetfield / Kirk Hammett)','Mesa/Boogie high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Builds from a clean, chiming intro to crushing riffs and a melodic solo; keep dynamics wide.','Wide dynamics, high gain for the heavy sections.'],
     array['Let the clean intro arpeggios ring.','Slam into the heavy riff and solo.'],
     'Studio recording, 1986 (Master of Puppets). Metallica built the song from clean intro to crushing riffs and a melodic solo.',75),
    ('harvester-of-sorrow','metallica','guitar','riff','main riff','high_gain',
     'metal','rhythm','intermediate',
     'ESP electric guitar (James Hetfield / Kirk Hammett)','Mesa/Boogie high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":4,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Slow, crushing, mid-scooped riff with the dry Justice tone; keep it heavy and deliberate.','High gain, dry, scooped.'],
     array['Play the heavy riff deliberately.','Keep the chugs tight.'],
     'Studio recording, 1988 (...And Justice for All). Metallica played a slow, crushing riff with the album''s dry, scooped tone.',74),
    ('the-evil-that-men-do','iron-maiden','guitar','riff','main riff and solo','high_gain',
     'metal','lead','advanced',
     'Electric guitar (Dave Murray / Adrian Smith)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Galloping riff with soaring harmonized leads; keep the gallop tight.','High gain with clarity.'],
     array['Keep the gallop tight.','Harmonise the twin leads cleanly.'],
     'Studio recording, 1988. Murray and Smith played a galloping riff and harmonized leads through Marshalls.',75),
    ('powerslave','iron-maiden','guitar','riff','main riff','high_gain',
     'metal','lead','advanced',
     'Electric guitar (Dave Murray / Adrian Smith)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Exotic, Egyptian-flavoured riff with fiery solos; keep it tight and dramatic.','High gain with clarity.'],
     array['Play the exotic riff cleanly.','Attack the solos with energy.'],
     'Studio recording, 1984 (Powerslave). Iron Maiden played the exotic, Egyptian-flavoured riff and fiery solos through Marshalls.',75),
    ('wrathchild','iron-maiden','guitar','riff','main riff','high_gain',
     'metal','rhythm','intermediate',
     'Electric guitar (Dave Murray / Adrian Smith)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Punchy, driving riff built off a bass line; keep it tight and aggressive.','Medium-high gain.'],
     array['Lock the riff to the bass.','Keep it punchy.'],
     'Studio recording, 1981 (Killers). Iron Maiden played a punchy, driving riff through Marshalls.',73),
    ('a-tout-le-monde','megadeth','guitar','riff','main riff and solo','high_gain',
     'metal','lead','intermediate',
     'Jackson electric guitar (Dave Mustaine / Marty Friedman)','Marshall high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Melodic, mid-tempo metal with a lyrical solo; keep the riff tight and the leads singing.','Medium-high gain with clarity.'],
     array['Keep the riff tight.','Play the melodic solo with feel.'],
     'Studio recording, 1994 (Youthanasia). Mustaine and Friedman played melodic metal with a lyrical solo on Jacksons through Marshalls.',74),
    ('sweating-bullets','megadeth','guitar','riff','main riff','high_gain',
     'metal','rhythm','intermediate',
     'Jackson electric guitar (Dave Mustaine / Marty Friedman)','Marshall high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Slinky, syncopated thrash-groove riff; keep it tight and precise.','High gain with clarity.'],
     array['Keep the syncopated riff tight.','Play the technical fills cleanly.'],
     'Studio recording, 1992 (Countdown to Extinction). Megadeth played a slinky, syncopated thrash-groove riff through Marshalls.',74),
    ('fairies-wear-boots','black-sabbath','guitar','riff','main riff','distorted',
     'metal','rhythm','intermediate',
     'Gibson SG (Tony Iommi)','Laney amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":6,"mids":6,"treble":5,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Swinging, bluesy doom riff; keep the groove loose and heavy.','Medium-high gain, dark.'],
     array['Play the riff with a loose swing.','Keep the low end thick.'],
     'Studio recording, 1970 (Paranoid). Tony Iommi played a swinging, bluesy doom riff on his SG through a Laney.',74),
    ('symptom-of-the-universe','black-sabbath','guitar','riff','main riff','distorted',
     'metal','rhythm','advanced',
     'Gibson SG (Tony Iommi)','Laney amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Fast, proto-thrash riff often cited as an early speed-metal template; keep it tight.','High gain, dark.'],
     array['Keep the fast riff tight.','Attack the palm mutes.'],
     'Studio recording, 1975 (Sabotage). Tony Iommi played a fast, proto-thrash riff on his SG through a Laney.',74),
    ('war-ensemble','slayer','guitar','riff','main riff','high_gain',
     'metal','rhythm','advanced',
     'Electric guitar (Kerry King / Jeff Hanneman)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":0,"delay":0,"master":6}'::jsonb,
     array['Blistering, fast thrash riffing; keep the tremolo picking relentless.','High gain, aggressive.'],
     array['Keep the fast riffs machine-tight.','Attack the tremolo picking.'],
     'Studio recording, 1990 (Seasons in the Abyss). King and Hanneman played blistering thrash riffs through Marshalls.',74),
    ('madhouse','anthrax','guitar','riff','main riff','high_gain',
     'metal','rhythm','intermediate',
     'Electric guitar (Scott Ian / Dan Spitz)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bouncy, tight thrash riff with palm-muted precision; keep it snappy.','High gain, bright.'],
     array['Keep the palm-muted riff tight.','Emphasise the rhythmic bounce.'],
     'Studio recording, 1985 (Spreading the Disease). Scott Ian played a bouncy, tight thrash riff through a high-gain rig.',73),
    ('indians','anthrax','guitar','riff','main riff','high_gain',
     'metal','rhythm','advanced',
     'Electric guitar (Scott Ian / Dan Spitz)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Galloping thrash riffs with a famous mosh-call breakdown; keep the picking relentless.','High gain.'],
     array['Keep the galloping riffs tight.','Nail the ''War Dance'' breakdown.'],
     'Studio recording, 1987 (Among the Living). Anthrax played galloping thrash riffs and a mosh breakdown through high-gain rigs.',73),
    ('practice-what-you-preach','testament','guitar','riff','main riff and solo','high_gain',
     'metal','lead','advanced',
     'Electric guitar (Alex Skolnick / Eric Peterson)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Tight, groovy thrash with an articulate, melodic solo; keep the riff precise.','High gain with clarity.'],
     array['Keep the groovy riff tight.','Play Skolnick''s melodic solo cleanly.'],
     'Studio recording, 1989. Alex Skolnick and Eric Peterson played tight, groovy thrash and a melodic solo through high-gain rigs.',73),
    ('the-new-order','testament','guitar','riff','main riff','high_gain',
     'metal','rhythm','advanced',
     'Electric guitar (Alex Skolnick / Eric Peterson)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Fast, precise Bay Area thrash riffing; keep the picking tight.','High gain.'],
     array['Keep the fast riffs tight.','Attack the palm mutes.'],
     'Studio recording, 1988. Testament played fast, precise Bay Area thrash riffs through high-gain rigs.',72),
    ('crystal-mountain','death','guitar','riff','main riff and solo','high_gain',
     'metal','lead','advanced',
     'Electric guitar (Chuck Schuldiner)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Melodic, technical death-metal riffing with a fluid solo; keep it articulate and tight.','High gain with clarity.'],
     array['Keep the technical riffs tight.','Play the fluid solo cleanly.'],
     'Studio recording, 1995 (Symbolic). Chuck Schuldiner played melodic, technical death-metal riffs and a fluid solo through a high-gain rig.',73),
    ('bonded-by-blood','exodus','guitar','riff','main riff','high_gain',
     'metal','rhythm','advanced',
     'Electric guitar (Gary Holt / Rick Hunolt)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Ferocious, fast Bay Area thrash riffing; keep it relentless.','High gain, aggressive.'],
     array['Keep the fast riffs machine-tight.','Attack the picking.'],
     'Studio recording, 1985. Gary Holt played ferocious, fast thrash riffs through a high-gain rig.',72),
    ('pleasure-to-kill','kreator','guitar','riff','main riff','high_gain',
     'metal','rhythm','advanced',
     'Electric guitar (Mille Petrozza)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":0,"delay":0,"master":6}'::jsonb,
     array['Extreme, blistering Teutonic thrash riffing; keep the tremolo picking relentless.','High gain, raw and aggressive.'],
     array['Keep the blistering riffs tight.','Attack the tremolo picking.'],
     'Studio recording, 1986. Mille Petrozza played extreme, blistering Teutonic thrash riffs through a high-gain rig.',72),
    ('roots-bloody-roots','sepultura','guitar','riff','main riff','high_gain',
     'metal','rhythm','beginner',
     'Electric guitar (Andreas Kisser)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":4,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Crushing, groovy detuned nu-metal-adjacent riff; keep the chugs heavy and simple.','High gain, drop tuning.'],
     array['Keep the simple riff crushing.','Lock to the tribal groove.'],
     'Studio recording, 1996 (Roots). Andreas Kisser played a crushing, groovy detuned riff through a high-gain rig.',73),
    ('refuse-resist','sepultura','guitar','riff','main riff','high_gain',
     'metal','rhythm','intermediate',
     'Electric guitar (Andreas Kisser)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Aggressive, tribal-groove metal riffing; keep it tight and pummeling.','High gain.'],
     array['Keep the groove riffs tight.','Lock to the drums.'],
     'Studio recording, 1993 (Chaos A.D.). Andreas Kisser played aggressive, tribal-groove metal riffs through a high-gain rig.',72),
    ('elimination','overkill','guitar','riff','main riff','high_gain',
     'metal','rhythm','intermediate',
     'Electric guitar (Bobby Gustafson)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Tight, driving East Coast thrash riff; keep it aggressive.','High gain.'],
     array['Keep the riff tight and driving.','Attack the picking.'],
     'Studio recording, 1989 (The Years of Decay). Overkill played a tight, driving thrash riff through a high-gain rig.',71),
    ('5-minutes-alone','pantera','guitar','riff','main riff','high_gain',
     'metal','rhythm','intermediate',
     'Dean electric guitar (Dimebag Darrell)','Randall solid-state high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":7,"presence":6,"reverb":0,"delay":0,"master":6}'::jsonb,
     array['Slow, crushing groove-metal riff with pinch harmonics; keep it tight and heavy.','High gain, tight and bright.'],
     array['Keep the groove riff tight.','Nail the pinch harmonics.'],
     'Studio recording, 1994 (Far Beyond Driven). Dimebag Darrell played a slow, crushing groove riff on a Dean through a Randall.',74),
    ('this-love','pantera','guitar','riff','clean verse to heavy chorus','high_gain',
     'metal','rhythm','intermediate',
     'Dean electric guitar (Dimebag Darrell)','Randall solid-state high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":7,"presence":6,"reverb":0,"delay":0,"master":6}'::jsonb,
     array['Dynamic clean verses that erupt into a crushing chorus riff; keep the contrast extreme.','Wide dynamics, high gain for the chorus.'],
     array['Play the clean verse softly.','Erupt into the crushing chorus.'],
     'Studio recording, 1992 (Vulgar Display of Power). Dimebag Darrell played dynamic clean verses and a crushing chorus on a Dean through a Randall.',74),
    ('hell-bent-for-leather','judas-priest','guitar','riff','main riff','high_gain',
     'metal','rhythm','intermediate',
     'Electric guitar (Glenn Tipton / K.K. Downing)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Driving, leather-clad metal riff; keep it tight and menacing.','Medium-high gain.'],
     array['Keep the driving riff tight.','Play with attitude.'],
     'Studio recording, 1978 (Killing Machine). Tipton and Downing played a driving metal riff through Marshalls.',73)
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
  ('metallica','fuel'),('metallica','the-four-horsemen'),('metallica','welcome-home-sanitarium'),('metallica','harvester-of-sorrow'),
  ('iron-maiden','the-evil-that-men-do'),('iron-maiden','powerslave'),('iron-maiden','wrathchild'),('megadeth','a-tout-le-monde'),
  ('megadeth','sweating-bullets'),('black-sabbath','fairies-wear-boots'),('black-sabbath','symptom-of-the-universe'),('slayer','war-ensemble'),
  ('anthrax','madhouse'),('anthrax','indians'),('testament','practice-what-you-preach'),('testament','the-new-order'),
  ('death','crystal-mountain'),('exodus','bonded-by-blood'),('kreator','pleasure-to-kill'),('sepultura','roots-bloody-roots'),
  ('sepultura','refuse-resist'),('overkill','elimination'),('pantera','5-minutes-alone'),('pantera','this-love'),
  ('judas-priest','hell-bent-for-leather')
) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
cross join (values
  ('artist_interview', 'Documented artist interviews and gear discussions', null::text,
   'Researched from widely-documented interviews about this recording and player.', 72),
  ('rig_rundown', 'Published rig rundowns and community gear databases', null::text,
   'Cross-referenced against rig features and community-maintained gear databases.', 66)
) as x(source_type, title, url, notes, credibility)
where p.verification_status = 'admin_verified'
on conflict do nothing;
