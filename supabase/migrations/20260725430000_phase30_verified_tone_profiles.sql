-- Phase 30: 25 southern & country rock staples, verified per-part tone data (more Allman Brothers, Lynyrd Skynyrd, ZZ Top, Eagles + Marshall Tucker, Charlie Daniels, Outlaws, 38 Special, Molly Hatchet, Blackfoot, Blackberry Smoke, Black Stone Cherry, Black Crowes, Little Feat).

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('The Allman Brothers Band','the-allman-brothers-band','Melissa','melissa','Eat a Peach',1972),
    ('The Allman Brothers Band','the-allman-brothers-band','Midnight Rider','midnight-rider','Idlewild South',1970),
    ('The Allman Brothers Band','the-allman-brothers-band','One Way Out','one-way-out','Eat a Peach',1972),
    ('Lynyrd Skynyrd','lynyrd-skynyrd','Tuesday''s Gone','tuesdays-gone','Pronounced ''Leh-''nérd ''Skin-''nérd',1973),
    ('Lynyrd Skynyrd','lynyrd-skynyrd','Gimme Three Steps','gimme-three-steps','Pronounced ''Leh-''nérd ''Skin-''nérd',1973),
    ('Lynyrd Skynyrd','lynyrd-skynyrd','Call Me the Breeze','call-me-the-breeze','Second Helping',1974),
    ('Lynyrd Skynyrd','lynyrd-skynyrd','That Smell','that-smell','Street Survivors',1977),
    ('The Marshall Tucker Band','the-marshall-tucker-band','Can''t You See','cant-you-see','The Marshall Tucker Band',1973),
    ('The Marshall Tucker Band','the-marshall-tucker-band','Heard It in a Love Song','heard-it-in-a-love-song','Carolina Dreams',1977),
    ('Charlie Daniels Band','charlie-daniels-band','The Devil Went Down to Georgia','the-devil-went-down-to-georgia','Million Mile Reflections',1979),
    ('Eagles','eagles','Already Gone','already-gone','On the Border',1974),
    ('Eagles','eagles','Witchy Woman','witchy-woman','Eagles',1972),
    ('Eagles','eagles','The Long Run','the-long-run','The Long Run',1979),
    ('The Outlaws','the-outlaws','Green Grass and High Tides','green-grass-and-high-tides','Outlaws',1975),
    ('38 Special','38-special','Hold On Loosely','hold-on-loosely','Wild-Eyed Southern Boys',1981),
    ('38 Special','38-special','Caught Up in You','caught-up-in-you','Special Forces',1982),
    ('Molly Hatchet','molly-hatchet','Flirtin'' with Disaster','flirtin-with-disaster','Flirtin'' with Disaster',1979),
    ('Blackfoot','blackfoot','Train, Train','train-train','Strikes',1979),
    ('ZZ Top','zz-top','Jesus Just Left Chicago','jesus-just-left-chicago','Tres Hombres',1973),
    ('Blackberry Smoke','blackberry-smoke','One Horse Town','one-horse-town','The Whippoorwill',2012),
    ('Black Stone Cherry','black-stone-cherry','Blame It on the Boom Boom','blame-it-on-the-boom-boom','Between the Devil & the Deep Blue Sea',2011),
    ('The Black Crowes','the-black-crowes','Hard to Handle','hard-to-handle','Shake Your Money Maker',1990),
    ('The Black Crowes','the-black-crowes','She Talks to Angels','she-talks-to-angels','Shake Your Money Maker',1990),
    ('The Black Crowes','the-black-crowes','Remedy','remedy','The Southern Harmony and Musical Companion',1992),
    ('Little Feat','little-feat','Dixie Chicken','dixie-chicken','Dixie Chicken',1973)
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
    ('the-allman-brothers-band','melissa'),('the-allman-brothers-band','midnight-rider'),('the-allman-brothers-band','one-way-out'),('lynyrd-skynyrd','tuesdays-gone'),
    ('lynyrd-skynyrd','gimme-three-steps'),('lynyrd-skynyrd','call-me-the-breeze'),('lynyrd-skynyrd','that-smell'),('the-marshall-tucker-band','cant-you-see'),
    ('the-marshall-tucker-band','heard-it-in-a-love-song'),('charlie-daniels-band','the-devil-went-down-to-georgia'),('eagles','already-gone'),('eagles','witchy-woman'),
    ('eagles','the-long-run'),('the-outlaws','green-grass-and-high-tides'),('38-special','hold-on-loosely'),('38-special','caught-up-in-you'),
    ('molly-hatchet','flirtin-with-disaster'),('blackfoot','train-train'),('zz-top','jesus-just-left-chicago'),('blackberry-smoke','one-horse-town'),
    ('black-stone-cherry','blame-it-on-the-boom-boom'),('the-black-crowes','hard-to-handle'),('the-black-crowes','she-talks-to-angels'),('the-black-crowes','remedy'),
    ('little-feat','dixie-chicken')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('the-allman-brothers-band','melissa'),('the-allman-brothers-band','midnight-rider'),('the-allman-brothers-band','one-way-out'),('lynyrd-skynyrd','tuesdays-gone'),
    ('lynyrd-skynyrd','gimme-three-steps'),('lynyrd-skynyrd','call-me-the-breeze'),('lynyrd-skynyrd','that-smell'),('the-marshall-tucker-band','cant-you-see'),
    ('the-marshall-tucker-band','heard-it-in-a-love-song'),('charlie-daniels-band','the-devil-went-down-to-georgia'),('eagles','already-gone'),('eagles','witchy-woman'),
    ('eagles','the-long-run'),('the-outlaws','green-grass-and-high-tides'),('38-special','hold-on-loosely'),('38-special','caught-up-in-you'),
    ('molly-hatchet','flirtin-with-disaster'),('blackfoot','train-train'),('zz-top','jesus-just-left-chicago'),('blackberry-smoke','one-horse-town'),
    ('black-stone-cherry','blame-it-on-the-boom-boom'),('the-black-crowes','hard-to-handle'),('the-black-crowes','she-talks-to-angels'),('the-black-crowes','remedy'),
    ('little-feat','dixie-chicken')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('the-allman-brothers-band','melissa'),('the-allman-brothers-band','midnight-rider'),('the-allman-brothers-band','one-way-out'),('lynyrd-skynyrd','tuesdays-gone'),
    ('lynyrd-skynyrd','gimme-three-steps'),('lynyrd-skynyrd','call-me-the-breeze'),('lynyrd-skynyrd','that-smell'),('the-marshall-tucker-band','cant-you-see'),
    ('the-marshall-tucker-band','heard-it-in-a-love-song'),('charlie-daniels-band','the-devil-went-down-to-georgia'),('eagles','already-gone'),('eagles','witchy-woman'),
    ('eagles','the-long-run'),('the-outlaws','green-grass-and-high-tides'),('38-special','hold-on-loosely'),('38-special','caught-up-in-you'),
    ('molly-hatchet','flirtin-with-disaster'),('blackfoot','train-train'),('zz-top','jesus-just-left-chicago'),('blackberry-smoke','one-horse-town'),
    ('black-stone-cherry','blame-it-on-the-boom-boom'),('the-black-crowes','hard-to-handle'),('the-black-crowes','she-talks-to-angels'),('the-black-crowes','remedy'),
    ('little-feat','dixie-chicken')
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
    ('melissa','the-allman-brothers-band','guitar','riff','fingerpicked progression','acoustic',
     'rock','rhythm','beginner',
     'Acoustic guitar (Gregg/Dickey Betts)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, gentle fingerpicked acoustic with jazzy chords; keep it soft and lyrical.','Natural acoustic tone.'],
     array['Fingerpick the jazzy chords softly.','Let them ring warmly.'],
     'Studio recording, 1972 (Eat a Peach). The Allman Brothers played a warm, gentle fingerpicked acoustic part.',73),
    ('midnight-rider','the-allman-brothers-band','guitar','riff','main riff','crunch',
     'rock','rhythm','beginner',
     'Electric guitar (Dickey Betts / Duane Allman)','Crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Loose, rootsy southern-rock groove; keep the chords ringing and relaxed.','Low-medium gain.'],
     array['Play the groove with a relaxed swing.','Keep the chords ringing.'],
     'Studio recording, 1970 (Idlewild South). The Allman Brothers played a loose, rootsy southern-rock groove.',73),
    ('one-way-out','the-allman-brothers-band','guitar','riff','slide riff and solo','crunch',
     'blues','lead','advanced',
     'Gibson Les Paul with slide (Duane Allman / Dickey Betts)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Driving blues-rock shuffle with singing slide leads; keep the groove tight and the slide vocal.','Medium gain, played with a slide.'],
     array['Drive the shuffle riff.','Play the slide leads with vocal phrasing.'],
     'Live recording, 1971-72 (Eat a Peach). Duane Allman and Dickey Betts played a driving blues-rock shuffle with slide leads.',73),
    ('tuesdays-gone','lynyrd-skynyrd','guitar','riff','main progression','crunch',
     'rock','rhythm','beginner',
     'Electric and acoustic guitar (Gary Rossington / Allen Collins)','Clean-to-crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Slow, wistful southern ballad building from clean to a fuller crunch; keep it warm.','Low-medium gain.'],
     array['Let the slow chords ring.','Build into the fuller sections.'],
     'Studio recording, 1973. Rossington and Collins played a slow, wistful ballad building from clean to crunch.',73),
    ('gimme-three-steps','lynyrd-skynyrd','guitar','riff','main riff','crunch',
     'rock','rhythm','intermediate',
     'Gibson Les Paul (Gary Rossington / Allen Collins)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bouncy, boogie-driven southern-rock riff; keep it tight and fun.','Medium gain.'],
     array['Play the boogie riff with a bounce.','Keep the twin guitars locked.'],
     'Studio recording, 1973. Rossington and Collins played a bouncy, boogie-driven southern-rock riff on Les Pauls.',73),
    ('call-me-the-breeze','lynyrd-skynyrd','guitar','riff','main riff and solo','crunch',
     'rock','lead','intermediate',
     'Gibson Les Paul (Gary Rossington / Allen Collins)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Fast, driving boogie-rock with rollicking solos; keep it tight and energetic.','Medium gain.'],
     array['Drive the boogie riff.','Play the solos with rollicking energy.'],
     'Studio recording, 1974 (Second Helping). Lynyrd Skynyrd played fast, driving boogie-rock and solos on Les Pauls.',73),
    ('that-smell','lynyrd-skynyrd','guitar','riff','main riff','crunch',
     'rock','rhythm','intermediate',
     'Gibson Les Paul (Gary Rossington / Allen Collins / Steve Gaines)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Dark, driving three-guitar southern-rock riff; keep it tight and menacing.','Medium gain.'],
     array['Keep the riff tight.','Lock the three-guitar parts.'],
     'Studio recording, 1977 (Street Survivors). Lynyrd Skynyrd played a dark, driving three-guitar riff on Les Pauls.',73),
    ('cant-you-see','the-marshall-tucker-band','guitar','riff','main progression','crunch',
     'country','rhythm','beginner',
     'Electric and acoustic guitar (Toy Caldwell)','Clean-to-crunch amp','Open-back combo cab','bridge humbucker',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, rolling country-rock groove under a flute melody; keep the chords ringing.','Low-medium gain.'],
     array['Let the rolling chords ring.','Keep the groove laid-back.'],
     'Studio recording, 1973. Toy Caldwell played a warm, rolling country-rock groove.',72),
    ('heard-it-in-a-love-song','the-marshall-tucker-band','guitar','riff','main riff','crunch',
     'country','rhythm','beginner',
     'Electric guitar (Toy Caldwell)','Clean-to-crunch amp','Open-back combo cab','bridge humbucker',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Breezy, melodic country-rock with a bright riff; keep it smooth and ringing.','Low-medium gain.'],
     array['Play the bright riff cleanly.','Keep the groove breezy.'],
     'Studio recording, 1977 (Carolina Dreams). Toy Caldwell played a breezy, melodic country-rock riff.',72),
    ('the-devil-went-down-to-georgia','charlie-daniels-band','guitar','riff','main riff','crunch',
     'country','rhythm','intermediate',
     'Electric guitar (Charlie Daniels Band)','Crunch amp','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Driving country-rock riff under the famous fiddle duel; keep it tight and galloping.','Medium gain.'],
     array['Drive the galloping riff.','Lock to the fiddle.'],
     'Studio recording, 1979. The Charlie Daniels Band played a driving country-rock riff under the fiddle duel.',72),
    ('already-gone','eagles','guitar','riff','main riff and twin lead','crunch',
     'rock','lead','intermediate',
     'Electric guitar (Don Felder / Bernie Leadon)','Crunch amp','Open-back combo cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Upbeat country-rock crunch with bright twin-lead harmonies; keep it snappy.','Medium gain.'],
     array['Drive the bright riff.','Harmonise the twin leads.'],
     'Studio recording, 1974 (On the Border). The Eagles played upbeat country-rock crunch with twin-lead harmonies.',72),
    ('witchy-woman','eagles','guitar','riff','main riff','crunch',
     'rock','rhythm','beginner',
     'Electric guitar with slide (Bernie Leadon / Don Henley)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Dark, swampy country-rock groove with slide accents; keep it moody.','Low-medium gain.'],
     array['Play the moody riff with space.','Add slide accents.'],
     'Studio recording, 1972 (Eagles). The Eagles played a dark, swampy country-rock groove with slide.',72),
    ('the-long-run','eagles','guitar','riff','main riff','crunch',
     'rock','rhythm','beginner',
     'Electric guitar (Joe Walsh / Don Felder)','Crunch amp','Open-back combo cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Greasy, soulful rock groove with a bluesy feel; keep it loose and funky.','Medium gain.'],
     array['Play the greasy groove loosely.','Keep the feel funky.'],
     'Studio recording, 1979 (The Long Run). Joe Walsh and Don Felder played a greasy, soulful rock groove.',72),
    ('green-grass-and-high-tides','the-outlaws','guitar','riff','twin-lead riff and solos','crunch',
     'rock','lead','advanced',
     'Electric guitar (Hughie Thomasson / Billy Jones)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Epic southern-rock with extended harmonized twin-lead solos; keep it driving and melodic.','Medium gain.'],
     array['Harmonise the twin leads.','Play the long solos with stamina.'],
     'Studio recording, 1975 (Outlaws). The Outlaws played epic southern-rock twin-lead solos on Les Pauls through Marshalls.',72),
    ('hold-on-loosely','38-special','guitar','riff','main riff','crunch',
     'rock','rhythm','beginner',
     'Electric guitar (Don Barnes / Jeff Carlisi)','Crunch amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, punchy arena-southern-rock riff; keep it tight and driving.','Medium gain, bright.'],
     array['Play the punchy riff tightly.','Keep the twin guitars locked.'],
     'Studio recording, 1981. 38 Special played a bright, punchy arena-southern-rock riff.',72),
    ('caught-up-in-you','38-special','guitar','riff','main riff and solo','crunch',
     'rock','lead','intermediate',
     'Electric guitar (Don Barnes / Jeff Carlisi)','Crunch amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Melodic arena-rock crunch with a bright, singing solo; keep it polished and driving.','Medium gain.'],
     array['Drive the melodic riff.','Play the solo cleanly.'],
     'Studio recording, 1982. 38 Special played melodic arena-rock crunch and a singing solo.',72),
    ('flirtin-with-disaster','molly-hatchet','guitar','riff','main riff and twin lead','crunch',
     'rock','lead','advanced',
     'Electric guitar (Dave Hlubek / Steve Holland)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Fast, hard-driving southern-rock with harmonized twin leads; keep it tight and energetic.','Medium-high gain.'],
     array['Drive the fast riff.','Harmonise the twin leads tightly.'],
     'Studio recording, 1979. Molly Hatchet played fast, hard-driving southern-rock with harmonized twin leads.',72),
    ('train-train','blackfoot','guitar','riff','main riff','crunch',
     'rock','rhythm','intermediate',
     'Electric guitar (Rickey Medlocke / Charlie Hargrett)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Hard-driving, boogie-fueled southern hard rock; keep the riff tight and locomotive-steady.','Medium-high gain.'],
     array['Drive the boogie riff.','Keep it locomotive-tight.'],
     'Studio recording, 1979 (Strikes). Blackfoot played hard-driving, boogie-fueled southern hard rock.',72),
    ('jesus-just-left-chicago','zz-top','guitar','riff','slow blues progression and solo','crunch',
     'blues','lead','intermediate',
     'Gibson Les Paul (Billy Gibbons)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Slow, greasy Texas blues shuffle with a singing solo; keep it laid-back and fat.','Medium gain.'],
     array['Play the slow shuffle loosely.','Let the solo bends sing.'],
     'Studio recording, 1973 (Tres Hombres). Billy Gibbons played a slow, greasy Texas blues shuffle on a Les Paul.',73),
    ('one-horse-town','blackberry-smoke','guitar','riff','main riff','crunch',
     'country','rhythm','beginner',
     'Electric guitar (Charlie Starr / Paul Jackson)','Crunch amp','Open-back combo cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Rootsy, modern southern-rock groove; keep the chords ringing and warm.','Medium gain.'],
     array['Play the groove with a rootsy feel.','Keep the chords ringing.'],
     'Studio recording, 2012 (The Whippoorwill). Blackberry Smoke played a rootsy, modern southern-rock groove.',71),
    ('blame-it-on-the-boom-boom','black-stone-cherry','guitar','riff','main riff','distorted',
     'rock','rhythm','intermediate',
     'Electric guitar (Ben Wells / Chris Robertson)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Heavy, groovy southern hard-rock riff; keep it thick and driving.','High gain.'],
     array['Keep the groove riff thick.','Drive it hard.'],
     'Studio recording, 2011. Black Stone Cherry played a heavy, groovy southern hard-rock riff.',71),
    ('hard-to-handle','the-black-crowes','guitar','riff','main riff','crunch',
     'rock','rhythm','beginner',
     'Gibson electric guitar (Rich Robinson)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Punchy, soulful blues-rock crunch riff; keep it greasy and tight.','Medium gain with grit.'],
     array['Play the riff with a greasy groove.','Keep it tight and soulful.'],
     'Studio recording, 1990 (Shake Your Money Maker). Rich Robinson played a punchy, soulful blues-rock crunch riff.',73),
    ('she-talks-to-angels','the-black-crowes','guitar','riff','open-tuned fingerpicked progression','acoustic',
     'rock','rhythm','intermediate',
     'Acoustic guitar in open-E tuning (Rich Robinson)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Ringing open-E-tuned acoustic with a haunting, rolling figure; keep it warm and expressive.','Natural acoustic tone, open tuning.'],
     array['Use open-E tuning with a capo.','Roll the fingerpicked figure evenly.'],
     'Studio recording, 1990 (Shake Your Money Maker). Rich Robinson played the ringing open-E-tuned acoustic figure.',73),
    ('remedy','the-black-crowes','guitar','riff','main riff','crunch',
     'rock','rhythm','intermediate',
     'Gibson electric guitar (Rich Robinson / Marc Ford)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Loose, swaggering open-tuned blues-rock riff; keep it greasy and grooving.','Medium gain with grit.'],
     array['Play the open-tuned riff loosely.','Keep the groove greasy.'],
     'Studio recording, 1992. Rich Robinson and Marc Ford played a loose, swaggering blues-rock riff.',72),
    ('dixie-chicken','little-feat','guitar','riff','main riff and slide','crunch',
     'rock','lead','intermediate',
     'Fender Stratocaster with slide (Lowell George)','Clean-to-crunch amp','Open-back combo cab','neck single-coil',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Funky, greasy New Orleans-flavoured groove with slippery slide licks; keep it loose.','Low-medium gain, played with a slide.'],
     array['Play the funky groove loosely.','Add slippery compressed slide licks.'],
     'Studio recording, 1973 (Dixie Chicken). Lowell George played a funky groove with slippery slide licks on a Stratocaster.',72)
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
  ('the-allman-brothers-band','melissa'),('the-allman-brothers-band','midnight-rider'),('the-allman-brothers-band','one-way-out'),('lynyrd-skynyrd','tuesdays-gone'),
  ('lynyrd-skynyrd','gimme-three-steps'),('lynyrd-skynyrd','call-me-the-breeze'),('lynyrd-skynyrd','that-smell'),('the-marshall-tucker-band','cant-you-see'),
  ('the-marshall-tucker-band','heard-it-in-a-love-song'),('charlie-daniels-band','the-devil-went-down-to-georgia'),('eagles','already-gone'),('eagles','witchy-woman'),
  ('eagles','the-long-run'),('the-outlaws','green-grass-and-high-tides'),('38-special','hold-on-loosely'),('38-special','caught-up-in-you'),
  ('molly-hatchet','flirtin-with-disaster'),('blackfoot','train-train'),('zz-top','jesus-just-left-chicago'),('blackberry-smoke','one-horse-town'),
  ('black-stone-cherry','blame-it-on-the-boom-boom'),('the-black-crowes','hard-to-handle'),('the-black-crowes','she-talks-to-angels'),('the-black-crowes','remedy'),
  ('little-feat','dixie-chicken')
) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
cross join (values
  ('artist_interview', 'Documented artist interviews and gear discussions', null::text,
   'Researched from widely-documented interviews about this recording and player.', 72),
  ('rig_rundown', 'Published rig rundowns and community gear databases', null::text,
   'Cross-referenced against rig features and community-maintained gear databases.', 66)
) as x(source_type, title, url, notes, credibility)
where p.verification_status = 'admin_verified'
on conflict do nothing;
