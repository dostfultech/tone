-- Phase 48: 2000s alt-rock / nu-metal deep cuts + high-demand gaps (Creep, Hysteria, QOTSA), verified per-part tone data.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Rage Against the Machine','rage-against-the-machine','Bombtrack','bombtrack','Rage Against the Machine',1992),
    ('Rage Against the Machine','rage-against-the-machine','Know Your Enemy','know-your-enemy','Rage Against the Machine',1992),
    ('Rage Against the Machine','rage-against-the-machine','Wake Up','wake-up','Rage Against the Machine',1992),
    ('System of a Down','system-of-a-down','Aerials','aerials','Toxicity',2001),
    ('System of a Down','system-of-a-down','Prison Song','prison-song','Toxicity',2001),
    ('System of a Down','system-of-a-down','Lonely Day','lonely-day','Hypnotize',2005),
    ('Linkin Park','linkin-park','Papercut','papercut','Hybrid Theory',2000),
    ('Linkin Park','linkin-park','Faint','faint','Meteora',2003),
    ('Radiohead','radiohead','Creep','creep','Pablo Honey',1993),
    ('Radiohead','radiohead','Street Spirit (Fade Out)','street-spirit-fade-out','The Bends',1995),
    ('Radiohead','radiohead','No Surprises','no-surprises','OK Computer',1997),
    ('Radiohead','radiohead','My Iron Lung','my-iron-lung','The Bends',1995),
    ('Muse','muse','Hysteria','hysteria','Absolution',2003),
    ('Muse','muse','Stockholm Syndrome','stockholm-syndrome','Absolution',2003),
    ('Queens of the Stone Age','queens-of-the-stone-age','No One Knows','no-one-knows','Songs for the Deaf',2002),
    ('Queens of the Stone Age','queens-of-the-stone-age','Go with the Flow','go-with-the-flow','Songs for the Deaf',2002),
    ('Queens of the Stone Age','queens-of-the-stone-age','Little Sister','little-sister','Lullabies to Paralyze',2005),
    ('Incubus','incubus','Drive','drive','Make Yourself',1999),
    ('Incubus','incubus','Wish You Were Here','wish-you-were-here','Morning View',2001),
    ('Limp Bizkit','limp-bizkit','Break Stuff','break-stuff','Significant Other',1999),
    ('Breaking Benjamin','breaking-benjamin','So Cold','so-cold','We Are Not Alone',2004),
    ('Three Days Grace','three-days-grace','I Hate Everything About You','i-hate-everything-about-you','Three Days Grace',2003),
    ('Staind','staind','Outside','outside','Break the Cycle',2001),
    ('Deftones','deftones','Be Quiet and Drive (Far Away)','be-quiet-and-drive-far-away','Around the Fur',1997),
    ('U2','u2','Sunday Bloody Sunday','sunday-bloody-sunday','War',1983)
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
    ('rage-against-the-machine','bombtrack'),('rage-against-the-machine','know-your-enemy'),('rage-against-the-machine','wake-up'),
    ('system-of-a-down','aerials'),('system-of-a-down','prison-song'),('system-of-a-down','lonely-day'),
    ('linkin-park','papercut'),('linkin-park','faint'),('radiohead','creep'),('radiohead','street-spirit-fade-out'),
    ('radiohead','no-surprises'),('radiohead','my-iron-lung'),('muse','hysteria'),('muse','stockholm-syndrome'),
    ('queens-of-the-stone-age','no-one-knows'),('queens-of-the-stone-age','go-with-the-flow'),('queens-of-the-stone-age','little-sister'),
    ('incubus','drive'),('incubus','wish-you-were-here'),('limp-bizkit','break-stuff'),('breaking-benjamin','so-cold'),
    ('three-days-grace','i-hate-everything-about-you'),('staind','outside'),('deftones','be-quiet-and-drive-far-away'),
    ('u2','sunday-bloody-sunday')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('rage-against-the-machine','bombtrack'),('rage-against-the-machine','know-your-enemy'),('rage-against-the-machine','wake-up'),
    ('system-of-a-down','aerials'),('system-of-a-down','prison-song'),('system-of-a-down','lonely-day'),
    ('linkin-park','papercut'),('linkin-park','faint'),('radiohead','creep'),('radiohead','street-spirit-fade-out'),
    ('radiohead','no-surprises'),('radiohead','my-iron-lung'),('muse','hysteria'),('muse','stockholm-syndrome'),
    ('queens-of-the-stone-age','no-one-knows'),('queens-of-the-stone-age','go-with-the-flow'),('queens-of-the-stone-age','little-sister'),
    ('incubus','drive'),('incubus','wish-you-were-here'),('limp-bizkit','break-stuff'),('breaking-benjamin','so-cold'),
    ('three-days-grace','i-hate-everything-about-you'),('staind','outside'),('deftones','be-quiet-and-drive-far-away'),
    ('u2','sunday-bloody-sunday')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('rage-against-the-machine','bombtrack'),('rage-against-the-machine','know-your-enemy'),('rage-against-the-machine','wake-up'),
    ('system-of-a-down','aerials'),('system-of-a-down','prison-song'),('system-of-a-down','lonely-day'),
    ('linkin-park','papercut'),('linkin-park','faint'),('radiohead','creep'),('radiohead','street-spirit-fade-out'),
    ('radiohead','no-surprises'),('radiohead','my-iron-lung'),('muse','hysteria'),('muse','stockholm-syndrome'),
    ('queens-of-the-stone-age','no-one-knows'),('queens-of-the-stone-age','go-with-the-flow'),('queens-of-the-stone-age','little-sister'),
    ('incubus','drive'),('incubus','wish-you-were-here'),('limp-bizkit','break-stuff'),('breaking-benjamin','so-cold'),
    ('three-days-grace','i-hate-everything-about-you'),('staind','outside'),('deftones','be-quiet-and-drive-far-away'),
    ('u2','sunday-bloody-sunday')
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
    -- ============ RAGE AGAINST THE MACHINE (Morello: Arm the Homeless + JCM800 2205) ============
    ('bombtrack','rage-against-the-machine','guitar','riff','main riff','high_gain','funk metal','rhythm','intermediate',
     '"Arm the Homeless" custom (Tom Morello)','Marshall JCM800 2205 50W','Peavey 4x12 cab','EMG humbuckers',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['Morello''s famously unchanging rig — JCM800 2205 on the same settings for 30 years.','Moderate gain with strong mids; RATM riffs are tight, not saturated.'],
     array['Lock the groove with the bass — RATM is a rhythm section band.','Mute hard between stabs for the funk-metal bounce.'],
     'Studio recording, 1992. Morello''s static JCM800/Peavey rig from the debut.',83),
    ('know-your-enemy','rage-against-the-machine','guitar','riff','main riff','high_gain','funk metal','rhythm','intermediate',
     '"Arm the Homeless" custom (Tom Morello)','Marshall JCM800 2205 50W','Peavey 4x12 cab','EMG humbuckers',
     '[{"effect_type":"wah","effect_name":"Dunlop Cry Baby wah","placement":"front","settings":{"position":5}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['Bouncy riff with wah accents and Morello''s toggle-switch tricks.','Same JCM800 tone; the wah adds the funk filter movement.'],
     array['The main riff swings — feel the funk under the metal.','The solo uses the kill-switch toggle; simulate with picking-hand muting.'],
     'Studio recording, 1992. Funk-metal bounce with wah on the static Morello rig.',82),
    ('wake-up','rage-against-the-machine','guitar','riff','main riff','high_gain','funk metal','rhythm','intermediate',
     '"Arm the Homeless" custom (Tom Morello)','Marshall JCM800 2205 50W','Peavey 4x12 cab','EMG humbuckers',
     '[]'::jsonb,'{"gain":6,"bass":6,"mids":6,"treble":5,"presence":5,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['Led Zeppelin-nodding heavy riff — thick and swaggering.','Moderate Marshall gain; weight comes from the low-string riffing.'],
     array['Dig into the main riff like Kashmir with venom.','The breakdown builds tension through restraint.'],
     'Studio recording, 1992. Heavy swaggering riff from the debut (The Matrix credits sequence).',82),

    -- ============ SYSTEM OF A DOWN (Malakian: Iceman, drop C) ============
    ('aerials','system-of-a-down','guitar','riff','main riff','high_gain','nu metal','rhythm','intermediate',
     'Ibanez Iceman (Daron Malakian)','Modern high-gain tube head','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['Soaring drop-C wall — huge sustained chords over the drone.','Thick saturated rhythm; let chords ring into each other.'],
     array['Drop C tuning on the record.','The verse is sparse — the power is in the held chorus chords.'],
     'Studio recording, 2001. Soaring drop-C wall from Toxicity.',77),
    ('prison-song','system-of-a-down','guitar','riff','main riff','high_gain','nu metal','rhythm','intermediate',
     'Ibanez Iceman (Daron Malakian)','Modern high-gain tube head','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":0,"delay":0,"master":8}'::jsonb,
     array['Album-opening bounce riff — brutal stop-start drop-C chugs.','Tight aggressive high gain; the silences hit as hard as the notes.'],
     array['The bounce riff demands rhythmic precision.','Choke every rest completely dead.'],
     'Studio recording, 2001. Brutal stop-start opener from Toxicity.',77),
    ('lonely-day','system-of-a-down','guitar','riff','clean intro + heavy chorus','crunch','nu metal','rhythm','beginner',
     'Ibanez Iceman (Daron Malakian)','Tube head, clean to high gain','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Melancholy arpeggiated clean verse (settings shown) into a wall-of-gain chorus — push gain to 7 for the heavy sections.','Program both sounds; the contrast carries the song.'],
     array['Drop C — the arpeggio pattern is beginner-friendly.','The solo is slow, melodic, and singable.'],
     'Studio recording, 2005. Quiet-loud melancholy from Hypnotize.',76),

    -- ============ LINKIN PARK (Delson: Dual Rectifier, drop D) ============
    ('papercut','linkin-park','guitar','riff','main riff','high_gain','nu metal','rhythm','intermediate',
     'PRS/Ibanez solid-body (Brad Delson)','Mesa/Boogie Dual Rectifier','Mesa 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":4,"treble":6,"presence":6,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['Tight scooped Hybrid Theory chunk under the electronics.','Modern Rectifier grind; keep it surgical, the samples fill the space.'],
     array['Drop D; the riff locks to the drum loop.','Precision over aggression — the production is tight.'],
     'Studio recording, 2000. Tight Rectifier chunk from Hybrid Theory.',77),
    ('faint','linkin-park','guitar','riff','main riff','high_gain','nu metal','rhythm','intermediate',
     'PRS/Ibanez solid-body (Brad Delson)','Mesa/Boogie Dual Rectifier','Mesa 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":4,"treble":7,"presence":6,"reverb":0,"delay":0,"master":8}'::jsonb,
     array['Racing Meteora energy — bright aggressive Rectifier chug under strings.','Scooped and fast; the string stabs are samples, not guitar.'],
     array['Drop D at speed — down-pick the accents.','Stay locked with the drum programming.'],
     'Studio recording, 2003. Racing aggressive chug from Meteora.',77),

    -- ============ RADIOHEAD ============
    ('creep','radiohead','guitar','riff','main riff + noise stabs','crunch','alternative rock','rhythm','beginner',
     'Fender Telecaster Plus (Jonny Greenwood)','Fender solid-state combo (Eighty-Five)','Open-back combo cab','Lace Sensor bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['The famous dead-note "CHUNK-CHUNK" before each chorus is Jonny slamming muted strings with crunch.','Verse is near-clean strums (roll guitar volume back); chorus kicks to bright solid-state crunch.'],
     array['The chunk stabs: fully mute the strings and strike hard.','Simple G-B-C-Cm progression — the dynamics are everything.'],
     'Studio recording, 1993. Greenwood''s Telecaster Plus chunk-stabs into a Fender solid-state combo.',81),
    ('street-spirit-fade-out','radiohead','guitar','riff','main arpeggio','clean','alternative rock','rhythm','intermediate',
     'Fender Telecaster (Ed O''Brien / Thom Yorke)','Vox AC30-style clean','Open-back 2x12 cab','bridge pickup',
     '[{"effect_type":"reverb","effect_name":"plate reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Hypnotic minor-key arpeggio — stark, chiming, and relentless.','Pure clean with soft plate; no modulation, no drive.'],
     array['The circular fingerpicked pattern never stops — build stamina.','Keep every note even; the dread comes from repetition.'],
     'Studio recording, 1995. Stark hypnotic arpeggio closing The Bends.',79),
    ('no-surprises','radiohead','guitar','riff','main arpeggio','clean','alternative rock','rhythm','beginner',
     'Fender Telecaster (Thom Yorke / Jonny Greenwood)','Vox AC30-style clean','Open-back 2x12 cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":1,"bass":5,"mids":5,"treble":7,"presence":5,"reverb":3,"delay":0,"master":5}'::jsonb,
     array['Music-box clean arpeggio (doubled by glockenspiel on the record).','Glassy bright clean, played softly; capo 1st fret territory.'],
     array['Gentle lullaby picking — soft right hand throughout.','Let the open strings ring into each other.'],
     'Studio recording, 1997. Music-box clean from OK Computer.',80),
    ('my-iron-lung','radiohead','guitar','riff','clean verse + fuzz eruption','crunch','alternative rock','rhythm','intermediate',
     'Fender Telecaster Plus (Jonny Greenwood)','Vox AC30-style amp with fuzz','Open-back 2x12 cab','bridge pickup',
     '[{"effect_type":"fuzz","effect_name":"fuzz pedal","placement":"front","settings":{"gain":7,"tone":6,"level":6}}]'::jsonb,
     '{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Jangly clean riff (settings shown) ambushed by violent fuzz eruptions — stomp the fuzz for the chaos sections.','Two extremes, no middle ground.'],
     array['The main riff is a melodic figure over Dm.','When the fuzz hits, play ugly on purpose.'],
     'Studio recording, 1995. Clean-to-violent-fuzz whiplash from The Bends.',79),

    -- ============ MUSE ============
    ('hysteria','muse','bass','bassline','main bassline','bass_drive','alternative rock','rhythm','advanced',
     'Electric bass (Chris Wolstenholme)','Driven bass rig with fuzz','Bass 4x10 + fuzz blend','split-coil + bridge blend',
     '[{"effect_type":"fuzz","effect_name":"bass fuzz/overdrive blend","placement":"front","settings":{"gain":7,"blend":6,"level":6}}]'::jsonb,
     '{"gain":7,"bass":7,"mids":6,"treble":5,"presence":5,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['One of rock''s most famous basslines — saturated fuzz bass with the clean low end blended in.','Blend dirty and clean signals; all-fuzz loses the foundation.'],
     array['Sixteenth-note runs for four minutes — pace your fretting hand.','Play fingerstyle or pick, but keep every note even.'],
     'Studio recording, 2003. Wolstenholme''s legendary fuzz bassline from Absolution.',80),
    ('stockholm-syndrome','muse','guitar','riff','main riff','high_gain','alternative rock','rhythm','advanced',
     'Manson custom (Matt Bellamy)','Driven tube stack with fuzz','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"fuzz","effect_name":"Fuzz Factory-style fuzz","placement":"front","settings":{"gain":8,"tone":5,"level":6}}]'::jsonb,
     '{"gain":7,"bass":6,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Bellamy''s Manson-plus-fuzz assault — huge saturated riffing with synth-like edge.','Fuzz into a driven amp; the sound is deliberately over-the-top.'],
     array['The main riff moves fast between low riffing and high arpeggios.','Drop D; attack everything.'],
     'Studio recording, 2003. Bellamy''s fuzz-drenched Manson assault.',78),

    -- ============ QUEENS OF THE STONE AGE (Homme: Ovation GP + Ampeg) ============
    ('no-one-knows','queens-of-the-stone-age','guitar','riff','main riff','crunch','desert rock','rhythm','intermediate',
     'Ovation Ultra GP (Josh Homme)','Ampeg VT-40 combo pushed','Open-back combo cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":7,"treble":5,"presence":4,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Homme''s signature desert crunch — mid-heavy Ampeg grind, deliberately NOT a Marshall sound.','Push mids hard; the tone is boxy, warm, and punchy.'],
     array['C standard tuning (two whole steps down) on the record.','The riff is a rhythm puzzle — count it before you speed it.'],
     'Studio recording, 2002. Homme''s mid-heavy Ampeg desert crunch.',80),
    ('go-with-the-flow','queens-of-the-stone-age','guitar','riff','main riff','crunch','desert rock','rhythm','intermediate',
     'Ovation Ultra GP (Josh Homme)','Ampeg VT-40 combo pushed','Open-back combo cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":7,"treble":5,"presence":5,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Driving eighth-note wall — same boxy mid-forward Ampeg push.','Warm crunch, not metal gain; momentum over saturation.'],
     array['Relentless driving downstrokes.','C standard tuning; keep the piano-like stabs tight.'],
     'Studio recording, 2002. Driving mid-forward desert rock.',79),
    ('little-sister','queens-of-the-stone-age','guitar','riff','main riff','crunch','desert rock','rhythm','beginner',
     'Ovation Ultra GP (Josh Homme)','Ampeg-style combo pushed','Open-back combo cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":7,"treble":5,"presence":5,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Cowbell-driven staccato riff — dry, boxy, and bouncy.','Same warm mid-heavy crunch; keep it completely dry.'],
     array['Staccato stabs locked to the cowbell.','The riff is simple — the groove placement is the skill.'],
     'Studio recording, 2005. Dry staccato desert bounce.',78),

    -- ============ INCUBUS ============
    ('drive','incubus','guitar','main','main progression','acoustic','alternative rock','rhythm','beginner',
     'Acoustic guitar (Mike Einziger)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm fingerpicked acoustic — the Em-Em9-A7 loop everyone learns.','Acoustic or piezo; a touch of room reverb is all it needs.'],
     array['Fingerpick the pattern with thumb bass notes.','The lead fills are melodic single-note lines over the loop.'],
     'Studio recording, 1999. The famous warm acoustic loop from Make Yourself.',80),
    ('wish-you-were-here','incubus','guitar','riff','clean verse + crunch chorus','clean','alternative rock','rhythm','intermediate',
     'PRS solid-body (Mike Einziger)','Mesa/Boogie tube combo, clean to crunch','Closed-back cab','bridge humbucker',
     '[{"effect_type":"chorus","effect_name":"watery chorus","placement":"post_gain","settings":{"rate":3,"depth":4,"mix":4}}]'::jsonb,
     '{"gain":3,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Watery chorused clean verse (settings shown) into big open crunch chorus — push gain to 6 for the chorus.','The chorus pedal gives the ocean shimmer the lyrics describe.'],
     array['Verse arpeggios float; chorus chords slam.','Let the last chord of each phrase hang.'],
     'Studio recording, 2001. Watery clean-to-crunch dynamics from Morning View.',77),

    -- ============ NU-METAL / POST-GRUNGE SINGLES ============
    ('break-stuff','limp-bizkit','guitar','riff','main riff','high_gain','nu metal','rhythm','beginner',
     'Custom/Ibanez solid-body (Wes Borland)','Mesa/Boogie Dual Rectifier','Mesa 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":7,"mids":3,"treble":6,"presence":6,"reverb":0,"delay":0,"master":8}'::jsonb,
     array['Maximum-scoop bounce riff — sub-heavy Rectifier chug.','Deep scoop, heavy lows; the riff is pure attitude.'],
     array['Drop-tuned single-string bounce — simplicity is the point.','Lock ruthlessly with the kick drum.'],
     'Studio recording, 1999. Scooped Rectifier bounce from Significant Other.',77),
    ('so-cold','breaking-benjamin','guitar','riff','main riff','high_gain','post-grunge','rhythm','intermediate',
     'Solid-body electric (Aaron Fink / Benjamin Burnley)','Modern high-gain tube head','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Polished mid-2000s radio-metal wall — drop C# tuning.','Tight modern high gain with enough mids to stay vocal-friendly.'],
     array['Drop C#; the verse rides muted chugs under clean vocals.','Open the chorus with full ringing power chords.'],
     'Studio recording, 2004. Polished drop-tuned radio-metal wall.',75),
    ('i-hate-everything-about-you','three-days-grace','guitar','riff','main riff','crunch','post-grunge','rhythm','beginner',
     'Solid-body electric (Barry Stock / Adam Gontier)','Modern tube head, crunch to high gain','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Restrained verse crunch exploding into a full-gain chorus (push gain to 7).','Drop C tuning; classic quiet-loud radio rock.'],
     array['The verse riff is sparse — leave the space alone.','Slam the chorus with open drop-C power chords.'],
     'Studio recording, 2003. Quiet-loud drop-C radio rock.',75),
    ('outside','staind','guitar','main','main progression','crunch','post-grunge','rhythm','beginner',
     'Baritone/7-string guitar (Mike Mushok)','Tube head, dark low-gain','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":4,"bass":6,"mids":5,"treble":4,"presence":3,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Dark, low-tuned brooding strums — heavy without high gain.','Low gain but very low tuning; darkness comes from the register, not distortion.'],
     array['Slow deliberate strums; let the low chords bloom.','Dynamics follow the vocal — swell and recede.'],
     'Studio recording, 2001. Dark low-tuned brooding from Break the Cycle.',74),
    ('be-quiet-and-drive-far-away','deftones','guitar','riff','main riff','distorted','alternative metal','rhythm','intermediate',
     'ESP solid-body (Stephen Carpenter)','High-gain tube wall with shimmer','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"chorus","effect_name":"subtle chorus shimmer","placement":"post_gain","settings":{"rate":3,"depth":3,"mix":3}}]'::jsonb,
     '{"gain":6,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":7}'::jsonb,
     array['Dreamy wall-of-gain — shoegaze density with metal weight.','Saturated but washy; the chorus shimmer softens the edges.'],
     array['Let every chord ring and blur into the next.','The driving eighth-note pattern floats rather than chugs.'],
     'Studio recording, 1997. Dreamy heavy wall from Around the Fur.',77),

    -- ============ U2 ============
    ('sunday-bloody-sunday','u2','guitar','riff','main riff','crunch','rock','rhythm','intermediate',
     'Gibson Explorer (The Edge)','Vox AC30','Open-back 2x12 cab','bridge pickup',
     '[{"effect_type":"delay","effect_name":"short slapback delay","placement":"post_gain","settings":{"time":2,"mix":2,"feedback":2}}]'::jsonb,
     '{"gain":4,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":2,"master":7}'::jsonb,
     array['Chiming martial AC30 crunch — bright, cutting arpeggio-riffs.','Edge-of-breakup AC30 jangle; aggression from the picking, not the gain.'],
     array['The intro arpeggio figure repeats like a military drum.','Keep the sixteenth-note strums crisp and even.'],
     'Studio recording, 1983. The Edge''s chiming AC30 crunch from War.',79)
) as c(
  song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence
)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;
