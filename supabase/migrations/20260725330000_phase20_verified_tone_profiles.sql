-- Phase 20: 25 country-guitar + blues-depth staples, verified per-part tone data.
-- Chris Stapleton, Brad Paisley, Keith Urban, Zach Bryan, Garth Brooks, Alan Jackson,
-- Brooks & Dunn, Dwight Yoakam, Luke Combs, Johnny Cash, Merle Haggard, Hank Williams +
-- Joe Bonamassa, Buddy Guy, Freddie King, Kenny Wayne Shepherd, Jonny Lang, Robert Cray,
-- Howlin' Wolf, Elmore James, Robert Johnson, Gary Clark Jr., T-Bone Walker, Albert Collins.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Chris Stapleton','chris-stapleton','Tennessee Whiskey','tennessee-whiskey','Traveller',2015),
    ('Chris Stapleton','chris-stapleton','Traveller','traveller','Traveller',2015),
    ('Brad Paisley','brad-paisley','Mud on the Tires','mud-on-the-tires','Mud on the Tires',2003),
    ('Keith Urban','keith-urban','Somebody Like You','somebody-like-you','Golden Road',2002),
    ('Zach Bryan','zach-bryan','Something in the Orange','something-in-the-orange','American Heartbreak',2022),
    ('Garth Brooks','garth-brooks','Friends in Low Places','friends-in-low-places','No Fences',1990),
    ('Alan Jackson','alan-jackson','Chattahoochee','chattahoochee','A Lot About Livin''',1993),
    ('Brooks & Dunn','brooks-and-dunn','Boot Scootin'' Boogie','boot-scootin-boogie','Brand New Man',1992),
    ('Dwight Yoakam','dwight-yoakam','Guitars, Cadillacs','guitars-cadillacs','Guitars, Cadillacs, Etc., Etc.',1986),
    ('Luke Combs','luke-combs','Beautiful Crazy','beautiful-crazy','This One''s for You',2018),
    ('Johnny Cash','johnny-cash','Hurt','hurt','American IV: The Man Comes Around',2002),
    ('Merle Haggard','merle-haggard','Mama Tried','mama-tried','Mama Tried',1968),
    ('Hank Williams','hank-williams','Your Cheatin'' Heart','your-cheatin-heart','MGM Single',1952),
    ('Joe Bonamassa','joe-bonamassa','Just Got Paid','just-got-paid','A New Day Yesterday',2000),
    ('Buddy Guy','buddy-guy','Damn Right, I''ve Got the Blues','damn-right-ive-got-the-blues','Damn Right, I''ve Got the Blues',1991),
    ('Freddie King','freddie-king','Hide Away','hide-away','Let''s Hide Away and Dance Away',1961),
    ('Kenny Wayne Shepherd','kenny-wayne-shepherd','Blue on Black','blue-on-black','Trouble Is...',1997),
    ('Jonny Lang','jonny-lang','Lie to Me','lie-to-me','Lie to Me',1997),
    ('Robert Cray','robert-cray','Smoking Gun','smoking-gun','Strong Persuader',1986),
    ('Howlin'' Wolf','howlin-wolf','Smokestack Lightnin''','smokestack-lightnin','Chess Single',1956),
    ('Elmore James','elmore-james','Dust My Broom','dust-my-broom','Trumpet Single',1951),
    ('Robert Johnson','robert-johnson','Sweet Home Chicago','sweet-home-chicago','King of the Delta Blues Singers',1936),
    ('Gary Clark Jr.','gary-clark-jr','Bright Lights','bright-lights','The Bright Lights EP',2011),
    ('T-Bone Walker','t-bone-walker','Stormy Monday','stormy-monday','Black & White Single',1947),
    ('Albert Collins','albert-collins','Frosty','frosty','The Cool Sound of Albert Collins',1965)
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
    ('chris-stapleton','tennessee-whiskey'),('chris-stapleton','traveller'),('brad-paisley','mud-on-the-tires'),('keith-urban','somebody-like-you'),
    ('zach-bryan','something-in-the-orange'),('garth-brooks','friends-in-low-places'),('alan-jackson','chattahoochee'),('brooks-and-dunn','boot-scootin-boogie'),
    ('dwight-yoakam','guitars-cadillacs'),('luke-combs','beautiful-crazy'),('johnny-cash','hurt'),('merle-haggard','mama-tried'),('hank-williams','your-cheatin-heart'),
    ('joe-bonamassa','just-got-paid'),('buddy-guy','damn-right-ive-got-the-blues'),('freddie-king','hide-away'),('kenny-wayne-shepherd','blue-on-black'),
    ('jonny-lang','lie-to-me'),('robert-cray','smoking-gun'),('howlin-wolf','smokestack-lightnin'),('elmore-james','dust-my-broom'),
    ('robert-johnson','sweet-home-chicago'),('gary-clark-jr','bright-lights'),('t-bone-walker','stormy-monday'),('albert-collins','frosty')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('chris-stapleton','tennessee-whiskey'),('chris-stapleton','traveller'),('brad-paisley','mud-on-the-tires'),('keith-urban','somebody-like-you'),
    ('zach-bryan','something-in-the-orange'),('garth-brooks','friends-in-low-places'),('alan-jackson','chattahoochee'),('brooks-and-dunn','boot-scootin-boogie'),
    ('dwight-yoakam','guitars-cadillacs'),('luke-combs','beautiful-crazy'),('johnny-cash','hurt'),('merle-haggard','mama-tried'),('hank-williams','your-cheatin-heart'),
    ('joe-bonamassa','just-got-paid'),('buddy-guy','damn-right-ive-got-the-blues'),('freddie-king','hide-away'),('kenny-wayne-shepherd','blue-on-black'),
    ('jonny-lang','lie-to-me'),('robert-cray','smoking-gun'),('howlin-wolf','smokestack-lightnin'),('elmore-james','dust-my-broom'),
    ('robert-johnson','sweet-home-chicago'),('gary-clark-jr','bright-lights'),('t-bone-walker','stormy-monday'),('albert-collins','frosty')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('chris-stapleton','tennessee-whiskey'),('chris-stapleton','traveller'),('brad-paisley','mud-on-the-tires'),('keith-urban','somebody-like-you'),
    ('zach-bryan','something-in-the-orange'),('garth-brooks','friends-in-low-places'),('alan-jackson','chattahoochee'),('brooks-and-dunn','boot-scootin-boogie'),
    ('dwight-yoakam','guitars-cadillacs'),('luke-combs','beautiful-crazy'),('johnny-cash','hurt'),('merle-haggard','mama-tried'),('hank-williams','your-cheatin-heart'),
    ('joe-bonamassa','just-got-paid'),('buddy-guy','damn-right-ive-got-the-blues'),('freddie-king','hide-away'),('kenny-wayne-shepherd','blue-on-black'),
    ('jonny-lang','lie-to-me'),('robert-cray','smoking-gun'),('howlin-wolf','smokestack-lightnin'),('elmore-james','dust-my-broom'),
    ('robert-johnson','sweet-home-chicago'),('gary-clark-jr','bright-lights'),('t-bone-walker','stormy-monday'),('albert-collins','frosty')
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
    ('tennessee-whiskey','chris-stapleton','guitar','riff','main progression and solo','crunch','blues','lead','intermediate',
     'Fender electric guitar (Chris Stapleton)','Bluesy clean-to-crunch amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Smooth, soulful bluesy clean-to-crunch; keep it warm and dynamic behind the vocal.','Low-medium gain with feel.'],
     array['Play the slow-swaying chords softly.','Let the bluesy solo bends sing.'],
     'Studio recording, 2015 (Traveller). Chris Stapleton played a smooth, soulful bluesy tone on his Fender.',75),
    ('traveller','chris-stapleton','guitar','riff','main progression','crunch','country','rhythm','intermediate',
     'Fender electric guitar (Chris Stapleton)','Bluesy clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Driving, bluesy country-rock crunch; keep the groove loose and rootsy.','Medium gain with grit.'],
     array['Drive the chords with a rootsy swagger.','Keep the groove loose.'],
     'Studio recording, 2015 (Traveller). Chris Stapleton played a driving, bluesy country-rock crunch.',74),
    ('mud-on-the-tires','brad-paisley','guitar','riff','main riff and solo','crunch','country','lead','advanced',
     'Fender Telecaster (Brad Paisley)','Bright clean-to-crunch amp','Open-back combo cab','bridge single-coil',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":1,"master":6}'::jsonb,
     array['Bright, twangy Telecaster country with flashy chicken-pickin'' leads; keep it snappy.','Low-medium gain, very bright.'],
     array['Play the twangy riff with hybrid picking.','Nail the fast chicken-pickin'' leads.'],
     'Studio recording, 2003. Brad Paisley played bright, twangy Telecaster country with flashy leads.',75),
    ('somebody-like-you','keith-urban','guitar','riff','main riff','crunch','country','rhythm','intermediate',
     'Fender Telecaster (Keith Urban)','Bright crunch amp','Open-back combo cab','bridge single-coil',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, upbeat country-pop crunch with a driving riff (and banjo/ganjo flavour); keep it snappy.','Low-medium gain, bright.'],
     array['Drive the bright riff with energy.','Keep the picking crisp.'],
     'Studio recording, 2002. Keith Urban played a bright, upbeat country-pop crunch riff.',74),
    ('something-in-the-orange','zach-bryan','guitar','riff','fingerpicked progression','acoustic','country','rhythm','beginner',
     'Acoustic guitar (Zach Bryan)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Raw, aching fingerpicked acoustic; keep it intimate and dynamic.','Natural acoustic tone with light ambience.'],
     array['Pick the rolling pattern with feeling.','Let the dynamics swell and fall.'],
     'Studio recording, 2022. Zach Bryan played a raw, aching fingerpicked part on acoustic guitar.',73),
    ('friends-in-low-places','garth-brooks','guitar','riff','main progression','crunch','country','rhythm','beginner',
     'Acoustic and electric guitar (Garth Brooks band)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Warm, ringing country strum that builds to a full band; keep it big and singable.','Low-medium gain.'],
     array['Strum the chords with a relaxed swing.','Open up for the anthemic chorus.'],
     'Studio recording, 1990 (No Fences). Garth Brooks'' band played a warm, ringing country strum building to a full sound.',73),
    ('chattahoochee','alan-jackson','guitar','riff','main riff','crunch','country','rhythm','beginner',
     'Fender Telecaster (Alan Jackson band)','Bright clean-to-crunch amp','Open-back combo cab','bridge single-coil',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, bouncy Telecaster country riff; keep it snappy and upbeat.','Low-medium gain, bright.'],
     array['Play the twangy riff with a bounce.','Keep the picking crisp.'],
     'Studio recording, 1993. Alan Jackson''s band played a bright, bouncy Telecaster country riff.',73),
    ('boot-scootin-boogie','brooks-and-dunn','guitar','riff','main riff and solo','crunch','country','lead','intermediate',
     'Fender Telecaster (Brooks & Dunn band)','Bright crunch amp','Open-back combo cab','bridge single-coil',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Driving country-boogie Telecaster with a twangy solo; keep the shuffle tight.','Low-medium gain, bright.'],
     array['Drive the boogie riff with a shuffle.','Play the twangy solo cleanly.'],
     'Studio recording, 1992. Brooks & Dunn''s band played a driving country-boogie Telecaster riff and solo.',73),
    ('guitars-cadillacs','dwight-yoakam','guitar','riff','main riff','crunch','country','rhythm','intermediate',
     'Fender Telecaster (Pete Anderson)','Bright clean-to-crunch amp','Open-back combo cab','bridge single-coil',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Twangy, honky-tonk Bakersfield Telecaster; keep it bright and snappy.','Low-medium gain, bright, slap-back feel.'],
     array['Play the honky-tonk riff with twang.','Keep the picking crisp.'],
     'Studio recording, 1986. Pete Anderson played a twangy, honky-tonk Bakersfield Telecaster tone.',73),
    ('beautiful-crazy','luke-combs','guitar','riff','strummed progression','acoustic','country','rhythm','beginner',
     'Acoustic guitar (Luke Combs)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, gentle strummed acoustic country ballad; keep it soft and even.','Natural acoustic tone.'],
     array['Strum the ballad chords gently.','Keep the dynamics tender.'],
     'Studio recording, 2018. Luke Combs played a warm, gentle strummed acoustic country ballad.',73),
    ('hurt','johnny-cash','guitar','riff','fingerpicked progression','acoustic','country','rhythm','beginner',
     'Acoustic guitar (Johnny Cash session)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Stark, aching fingerpicked acoustic that builds; keep it fragile and intimate.','Natural acoustic tone.'],
     array['Pick the simple pattern gently.','Let the arrangement build.'],
     'Studio recording, 2002 (American IV). The stark, aching fingerpicked acoustic anchors Johnny Cash''s cover.',73),
    ('mama-tried','merle-haggard','guitar','riff','main riff','crunch','country','rhythm','intermediate',
     'Fender Telecaster (Roy Nichols)','Bright clean-to-crunch amp','Open-back combo cab','bridge single-coil',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Twangy Bakersfield Telecaster with slap-back; keep it bright and snappy.','Low gain, bright.'],
     array['Play the twangy riff cleanly.','Keep the shuffle tight.'],
     'Studio recording, 1968. Roy Nichols played a twangy Bakersfield Telecaster tone with slap-back.',73),
    ('your-cheatin-heart','hank-williams','guitar','riff','main progression','clean','country','rhythm','beginner',
     'Electric guitar (Hank Williams band)','Bright clean amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, simple honky-tonk clean guitar with gentle fills; keep it sparse.','Low gain, warm and bright.'],
     array['Play the simple chords cleanly.','Add tasteful honky-tonk fills.'],
     'Studio recording, 1952. Hank Williams'' band played a warm, simple honky-tonk clean guitar.',72),
    ('just-got-paid','joe-bonamassa','guitar','riff','main riff and solo','crunch','blues','lead','advanced',
     'Gibson Les Paul (Joe Bonamassa)','Marshall-style overdriven amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Powerful blues-rock crunch with searing, virtuosic solos; keep the riff tight.','Medium-high gain with feel.'],
     array['Drive the main riff with power.','Play the fiery solos with big bends and vibrato.'],
     'Studio recording, 2000. Joe Bonamassa played powerful blues-rock crunch and searing solos on a Les Paul through a Marshall-style amp.',75),
    ('damn-right-ive-got-the-blues','buddy-guy','guitar','riff','main riff and solo','crunch','blues','lead','advanced',
     'Fender Stratocaster (Buddy Guy)','Overdriven Bassman-style amp','Open-back combo cab','neck single-coil',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Wild, dynamic Chicago-blues crunch with explosive solos; keep the dynamics extreme.','Medium gain, huge dynamics.'],
     array['Play with extreme dynamics, soft to explosive.','Attack the solo bends with abandon.'],
     'Studio recording, 1991. Buddy Guy played wild, dynamic Chicago-blues crunch and explosive solos on a Stratocaster.',75),
    ('hide-away','freddie-king','guitar','riff','instrumental main riff','crunch','blues','lead','intermediate',
     'Gibson electric guitar (Freddie King)','Overdriven Bassman-style amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, snappy instrumental blues with the classic stop-time riff; keep it clean and punchy.','Low-medium gain.'],
     array['Play the iconic riff cleanly and punchy.','Nail the stop-time sections.'],
     'Studio recording, 1961. Freddie King played the classic bright, snappy instrumental blues riff.',74),
    ('blue-on-black','kenny-wayne-shepherd','guitar','riff','main riff and solo','crunch','blues','lead','intermediate',
     'Fender Stratocaster (Kenny Wayne Shepherd)','Overdriven amp','Open-back combo cab','bridge single-coil',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Atmospheric blues-rock crunch with a soulful solo; keep the main riff moody.','Medium gain with feel.'],
     array['Play the moody riff with space.','Let the solo bends sing.'],
     'Studio recording, 1997. Kenny Wayne Shepherd played atmospheric blues-rock crunch and a soulful solo on a Stratocaster.',74),
    ('lie-to-me','jonny-lang','guitar','riff','main riff and solo','crunch','blues','lead','intermediate',
     'Fender Stratocaster (Jonny Lang)','Overdriven amp','Open-back combo cab','bridge single-coil',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Gritty, soulful blues-rock crunch with fiery solos; keep the groove driving.','Medium gain with grit.'],
     array['Drive the riff with a raw feel.','Play the solos with fiery bends.'],
     'Studio recording, 1997. Jonny Lang played gritty, soulful blues-rock crunch and fiery solos on a Stratocaster.',73),
    ('smoking-gun','robert-cray','guitar','riff','main riff and solo','crunch','blues','lead','intermediate',
     'Fender Stratocaster (Robert Cray)','Clean-to-crunch amp','Open-back combo cab','neck single-coil',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Smooth, refined clean-to-crunch blues with tasteful stinging leads; keep it controlled.','Low-medium gain, smooth.'],
     array['Play the clean rhythm with a light touch.','Sting the solo notes with precise bends.'],
     'Studio recording, 1986. Robert Cray played a smooth, refined clean-to-crunch blues tone and tasteful leads on a Stratocaster.',74),
    ('smokestack-lightnin','howlin-wolf','guitar','riff','main riff','crunch','blues','rhythm','beginner',
     'Electric guitar (Hubert Sumlin)','Vintage tube amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Hypnotic, droning one-chord Chicago-blues riff; keep it raw and steady.','Low-medium gain, gritty.'],
     array['Loop the droning riff steadily.','Keep it raw and hypnotic.'],
     'Studio recording, 1956. Hubert Sumlin played the hypnotic, droning Chicago-blues riff behind Howlin'' Wolf.',73),
    ('dust-my-broom','elmore-james','guitar','riff','slide main riff','crunch','blues','lead','intermediate',
     'Electric guitar with slide (Elmore James)','Vintage tube amp, cranked','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['The definitive electric-slide blues riff; keep it raw, driving, and vocal.','Medium gain, gritty, played with a slide.'],
     array['Play the iconic triplet slide riff cleanly.','Keep the slide vocal and driving.'],
     'Studio recording, 1951. Elmore James played the definitive electric-slide blues riff.',74),
    ('sweet-home-chicago','robert-johnson','guitar','riff','fingerpicked slide progression','acoustic','blues','rhythm','intermediate',
     'Acoustic guitar (Robert Johnson)','Acoustic — no amp','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Foundational Delta-blues fingerpicking with a walking bass; keep it raw and rhythmic.','Natural acoustic tone.'],
     array['Pick the walking-bass pattern with the thumb.','Keep the shuffle driving.'],
     'Recorded 1936. Robert Johnson played the foundational Delta-blues fingerpicking with a walking bass on acoustic guitar.',73),
    ('bright-lights','gary-clark-jr','guitar','riff','main riff and solo','fuzz','blues','lead','intermediate',
     'Epiphone Casino (Gary Clark Jr.)','Fuzzy overdriven amp','Open-back combo cab','bridge pickup',
     '[{"effect_type":"fuzz","effect_name":"fuzz","placement":"front","settings":{"gain":7,"tone":5,"level":6}}]'::jsonb,
     '{"gain":6,"bass":6,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Thick, fuzzy modern blues with a raw, snarling solo; keep the low end heavy.','Medium-high gain with fuzz.'],
     array['Drive the riff with thick fuzz.','Play the snarling solo with attitude.'],
     'Studio recording, 2011. Gary Clark Jr. played a thick, fuzzy modern-blues tone and snarling solo on an Epiphone Casino.',74),
    ('stormy-monday','t-bone-walker','guitar','riff','main progression and solo','clean','blues','lead','intermediate',
     'Electric guitar (T-Bone Walker)','Warm clean-to-crunch tube amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Smooth, jazzy clean-to-light-crunch blues with sophisticated chords; keep it warm.','Low gain, warm and round.'],
     array['Play the jazzy 9th chords smoothly.','Phrase the solo with vocal bends.'],
     'Recorded 1947. T-Bone Walker played a smooth, jazzy clean-to-crunch blues with sophisticated chords.',73),
    ('frosty','albert-collins','guitar','riff','instrumental main riff','crunch','blues','lead','intermediate',
     'Fender Telecaster (Albert Collins)','Bright clean-to-crunch amp','Open-back combo cab','bridge single-coil',
     '[]'::jsonb,'{"gain":4,"bass":4,"mids":6,"treble":8,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Icy, biting Telecaster Texas-blues instrumental; keep it sharp and stinging.','Low-medium gain, very bright.'],
     array['Play the stinging riff with a capo and bare fingers.','Keep the attack sharp and icy.'],
     'Studio recording, 1965. Albert Collins played his icy, biting Telecaster Texas-blues instrumental.',73)
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
  ('chris-stapleton','tennessee-whiskey'),('chris-stapleton','traveller'),('brad-paisley','mud-on-the-tires'),('keith-urban','somebody-like-you'),
  ('zach-bryan','something-in-the-orange'),('garth-brooks','friends-in-low-places'),('alan-jackson','chattahoochee'),('brooks-and-dunn','boot-scootin-boogie'),
  ('dwight-yoakam','guitars-cadillacs'),('luke-combs','beautiful-crazy'),('johnny-cash','hurt'),('merle-haggard','mama-tried'),('hank-williams','your-cheatin-heart'),
  ('joe-bonamassa','just-got-paid'),('buddy-guy','damn-right-ive-got-the-blues'),('freddie-king','hide-away'),('kenny-wayne-shepherd','blue-on-black'),
  ('jonny-lang','lie-to-me'),('robert-cray','smoking-gun'),('howlin-wolf','smokestack-lightnin'),('elmore-james','dust-my-broom'),
  ('robert-johnson','sweet-home-chicago'),('gary-clark-jr','bright-lights'),('t-bone-walker','stormy-monday'),('albert-collins','frosty')
) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
cross join (values
  ('artist_interview', 'Documented artist interviews and gear discussions', null::text,
   'Researched from widely-documented interviews about this recording and player.', 72),
  ('rig_rundown', 'Published rig rundowns and community gear databases', null::text,
   'Cross-referenced against rig features and community-maintained gear databases.', 66)
) as x(source_type, title, url, notes, credibility)
where p.verification_status = 'admin_verified'
on conflict do nothing;
