-- Phase 41: 25 modern country & Americana depth, verified per-part tone data (more Stapleton, Zach Bryan, Luke Combs, Keith Urban, Brad Paisley + Tyler Childers, Sturgill Simpson, Jason Isbell, Eric Church, Cody Johnson, Morgan Wallen, Kacey Musgraves, Miranda Lambert, Kenny Chesney, Tim McGraw, Brothers Osborne, Dierks Bentley, Old Dominion, Zac Brown Band, Turnpike Troubadours, The Avett Brothers).

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Chris Stapleton','chris-stapleton','Broken Halos','broken-halos','From A Room: Volume 1',2017),
    ('Chris Stapleton','chris-stapleton','Nobody to Blame','nobody-to-blame','Traveller',2015),
    ('Zach Bryan','zach-bryan','Heading South','heading-south','DeAnn',2019),
    ('Tyler Childers','tyler-childers','Feathered Indians','feathered-indians','Purgatory',2017),
    ('Tyler Childers','tyler-childers','All Your''n','all-yourn','Country Squire',2019),
    ('Sturgill Simpson','sturgill-simpson','Turtles All the Way Down','turtles-all-the-way-down','Metamodern Sounds in Country Music',2014),
    ('Jason Isbell','jason-isbell','Cover Me Up','cover-me-up','Southeastern',2013),
    ('Jason Isbell','jason-isbell','24 Frames','24-frames','Something More Than Free',2015),
    ('Eric Church','eric-church','Springsteen','springsteen','Chief',2011),
    ('Eric Church','eric-church','Drink in My Hand','drink-in-my-hand','Chief',2011),
    ('Cody Johnson','cody-johnson','''Til You Can''t','til-you-cant','Human: The Double Album',2021),
    ('Luke Combs','luke-combs','Hurricane','hurricane','This One''s for You',2017),
    ('Morgan Wallen','morgan-wallen','Whiskey Glasses','whiskey-glasses','If I Know Me',2018),
    ('Kacey Musgraves','kacey-musgraves','Butterflies','butterflies','Golden Hour',2018),
    ('Miranda Lambert','miranda-lambert','The House That Built Me','the-house-that-built-me','Revolution',2010),
    ('Keith Urban','keith-urban','Blue Ain''t Your Color','blue-aint-your-color','Ripcord',2016),
    ('Brad Paisley','brad-paisley','Whiskey Lullaby','whiskey-lullaby','Mud on the Tires',2004),
    ('Kenny Chesney','kenny-chesney','No Shoes, No Shirt, No Problems','no-shoes-no-shirt-no-problems','No Shoes, No Shirt, No Problems',2003),
    ('Tim McGraw','tim-mcgraw','Live Like You Were Dying','live-like-you-were-dying','Live Like You Were Dying',2004),
    ('Brothers Osborne','brothers-osborne','Stay a Little Longer','stay-a-little-longer','Pawn Shop',2015),
    ('Dierks Bentley','dierks-bentley','What Was I Thinkin''','what-was-i-thinkin','Dierks Bentley',2003),
    ('Old Dominion','old-dominion','Break Up with Him','break-up-with-him','Meat and Candy',2015),
    ('Zac Brown Band','zac-brown-band','Chicken Fried','chicken-fried','The Foundation',2008),
    ('Turnpike Troubadours','turnpike-troubadours','Every Girl','every-girl','A Long Way from Your Heart',2017),
    ('The Avett Brothers','the-avett-brothers','I and Love and You','i-and-love-and-you','I and Love and You',2009)
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
    ('chris-stapleton','broken-halos'),('chris-stapleton','nobody-to-blame'),('zach-bryan','heading-south'),('tyler-childers','feathered-indians'),
    ('tyler-childers','all-yourn'),('sturgill-simpson','turtles-all-the-way-down'),('jason-isbell','cover-me-up'),('jason-isbell','24-frames'),
    ('eric-church','springsteen'),('eric-church','drink-in-my-hand'),('cody-johnson','til-you-cant'),('luke-combs','hurricane'),
    ('morgan-wallen','whiskey-glasses'),('kacey-musgraves','butterflies'),('miranda-lambert','the-house-that-built-me'),('keith-urban','blue-aint-your-color'),
    ('brad-paisley','whiskey-lullaby'),('kenny-chesney','no-shoes-no-shirt-no-problems'),('tim-mcgraw','live-like-you-were-dying'),('brothers-osborne','stay-a-little-longer'),
    ('dierks-bentley','what-was-i-thinkin'),('old-dominion','break-up-with-him'),('zac-brown-band','chicken-fried'),('turnpike-troubadours','every-girl'),
    ('the-avett-brothers','i-and-love-and-you')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('chris-stapleton','broken-halos'),('chris-stapleton','nobody-to-blame'),('zach-bryan','heading-south'),('tyler-childers','feathered-indians'),
    ('tyler-childers','all-yourn'),('sturgill-simpson','turtles-all-the-way-down'),('jason-isbell','cover-me-up'),('jason-isbell','24-frames'),
    ('eric-church','springsteen'),('eric-church','drink-in-my-hand'),('cody-johnson','til-you-cant'),('luke-combs','hurricane'),
    ('morgan-wallen','whiskey-glasses'),('kacey-musgraves','butterflies'),('miranda-lambert','the-house-that-built-me'),('keith-urban','blue-aint-your-color'),
    ('brad-paisley','whiskey-lullaby'),('kenny-chesney','no-shoes-no-shirt-no-problems'),('tim-mcgraw','live-like-you-were-dying'),('brothers-osborne','stay-a-little-longer'),
    ('dierks-bentley','what-was-i-thinkin'),('old-dominion','break-up-with-him'),('zac-brown-band','chicken-fried'),('turnpike-troubadours','every-girl'),
    ('the-avett-brothers','i-and-love-and-you')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('chris-stapleton','broken-halos'),('chris-stapleton','nobody-to-blame'),('zach-bryan','heading-south'),('tyler-childers','feathered-indians'),
    ('tyler-childers','all-yourn'),('sturgill-simpson','turtles-all-the-way-down'),('jason-isbell','cover-me-up'),('jason-isbell','24-frames'),
    ('eric-church','springsteen'),('eric-church','drink-in-my-hand'),('cody-johnson','til-you-cant'),('luke-combs','hurricane'),
    ('morgan-wallen','whiskey-glasses'),('kacey-musgraves','butterflies'),('miranda-lambert','the-house-that-built-me'),('keith-urban','blue-aint-your-color'),
    ('brad-paisley','whiskey-lullaby'),('kenny-chesney','no-shoes-no-shirt-no-problems'),('tim-mcgraw','live-like-you-were-dying'),('brothers-osborne','stay-a-little-longer'),
    ('dierks-bentley','what-was-i-thinkin'),('old-dominion','break-up-with-him'),('zac-brown-band','chicken-fried'),('turnpike-troubadours','every-girl'),
    ('the-avett-brothers','i-and-love-and-you')
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
    ('broken-halos','chris-stapleton','guitar','riff','main progression','crunch',
     'country','rhythm','beginner',
     'Fender electric guitar (Chris Stapleton)','Bluesy clean-to-crunch amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, rootsy country-soul groove with a bluesy edge; keep the chords ringing and relaxed.','Low-medium gain, warm.'],
     array['Play the groove with a rootsy feel.','Keep the chords ringing.'],
     'Studio recording, 2017 (From A Room: Volume 1). Chris Stapleton played a warm, rootsy country-soul groove.',72),
    ('nobody-to-blame','chris-stapleton','guitar','riff','main riff','crunch',
     'country','rhythm','beginner',
     'Fender electric guitar (Chris Stapleton)','Bluesy clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Driving, bluesy outlaw-country riff; keep it tight and greasy.','Medium gain with grit.'],
     array['Drive the riff with a bluesy swagger.','Keep the groove tight.'],
     'Studio recording, 2015 (Traveller). Chris Stapleton played a driving, bluesy outlaw-country riff.',72),
    ('heading-south','zach-bryan','guitar','riff','strummed progression','acoustic',
     'country','rhythm','beginner',
     'Acoustic guitar (Zach Bryan)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Raw, hard-driving strummed acoustic with a ragged energy; keep it urgent and heartfelt.','Natural acoustic tone.'],
     array['Strum the chords hard and driving.','Keep the raw, urgent energy.'],
     'Studio recording, 2019 (DeAnn). Zach Bryan played a raw, hard-driving strummed acoustic part.',71),
    ('feathered-indians','tyler-childers','guitar','riff','main progression','crunch',
     'country','rhythm','beginner',
     'Acoustic and electric guitar (Tyler Childers band)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm Appalachian country with jangly, ringing chords; keep it rootsy and even.','Low-medium gain.'],
     array['Let the jangly chords ring.','Keep the groove rootsy.'],
     'Studio recording, 2017 (Purgatory). Tyler Childers played warm, jangly Appalachian country.',71),
    ('all-yourn','tyler-childers','guitar','riff','main progression','crunch',
     'country','rhythm','beginner',
     'Acoustic and electric guitar (Tyler Childers band)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, swaying Appalachian country love song; keep the chords ringing and tender.','Low-medium gain.'],
     array['Play the swaying groove gently.','Keep the chords ringing.'],
     'Studio recording, 2019 (Country Squire). Tyler Childers played a warm, swaying Appalachian country part.',71),
    ('turtles-all-the-way-down','sturgill-simpson','guitar','riff','main progression','clean',
     'country','rhythm','beginner',
     'Electric guitar (Laur Joamets / Sturgill Simpson)','Clean-to-crunch amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, psychedelic-tinged outlaw country with smooth clean chords and tasteful fills; keep it mellow.','Low gain, warm.'],
     array['Play the chords smoothly.','Add tasteful country fills.'],
     'Studio recording, 2014. Laur Joamets played warm, psychedelic-tinged outlaw-country guitar.',71),
    ('cover-me-up','jason-isbell','guitar','riff','main progression','crunch',
     'country','rhythm','intermediate',
     'Acoustic and electric guitar (Jason Isbell)','Clean-to-crunch amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Aching Americana ballad building from soft acoustic to a swelling electric climax; keep dynamics huge.','Low-medium gain for the swell.'],
     array['Play the verse softly.','Swell into the powerful climax.'],
     'Studio recording, 2013 (Southeastern). Jason Isbell played an aching Americana ballad building to a swelling climax.',72),
    ('24-frames','jason-isbell','guitar','riff','main riff','crunch',
     'country','rhythm','beginner',
     'Fender Telecaster (Jason Isbell)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bright, driving heartland-Americana with a jangly, ringing riff; keep it tight and warm.','Low-medium gain, bright.'],
     array['Play the jangly riff cleanly.','Keep the groove driving.'],
     'Studio recording, 2015 (Something More Than Free). Jason Isbell played a bright, driving heartland-Americana riff.',72),
    ('springsteen','eric-church','guitar','riff','main progression','crunch',
     'country','rhythm','beginner',
     'Electric and acoustic guitar (Eric Church band)','Clean-to-crunch amp with delay','Open-back combo cab','bridge pickup',
     '[{"effect_type":"delay","effect_name":"delay","placement":"post_gain","settings":{"mix":3,"time":3}}]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Nostalgic country-rock with ringing, delayed chords building to a full band; keep it warm and anthemic.','Low-medium gain, delay.'],
     array['Let the delayed chords ring.','Build into the anthemic chorus.'],
     'Studio recording, 2011 (Chief). Eric Church''s band played nostalgic country-rock with ringing, delayed chords.',71),
    ('drink-in-my-hand','eric-church','guitar','riff','main riff','crunch',
     'country','rhythm','beginner',
     'Electric guitar (Eric Church band)','Crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Driving, party-ready country-rock riff; keep it tight and punchy.','Medium gain.'],
     array['Drive the riff with energy.','Keep the groove punchy.'],
     'Studio recording, 2011 (Chief). Eric Church''s band played a driving, party-ready country-rock riff.',71),
    ('til-you-cant','cody-johnson','guitar','riff','main progression','crunch',
     'country','rhythm','beginner',
     'Electric and acoustic guitar (Cody Johnson band)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Anthemic modern country ballad building from acoustic to a big electric chorus; keep dynamics wide.','Low-medium gain.'],
     array['Play the verse cleanly.','Open into the big chorus.'],
     'Studio recording, 2021. Cody Johnson''s band played an anthemic modern-country ballad building to a big chorus.',71),
    ('hurricane','luke-combs','guitar','riff','main riff','crunch',
     'country','rhythm','beginner',
     'Electric guitar (Luke Combs band)','Crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Driving, modern country-rock riff with a big hook; keep it tight and anthemic.','Medium gain.'],
     array['Drive the riff with energy.','Keep it tight and hooky.'],
     'Studio recording, 2017 (This One''s for You). Luke Combs'' band played a driving country-rock riff.',71),
    ('whiskey-glasses','morgan-wallen','guitar','riff','main riff','crunch',
     'country','rhythm','beginner',
     'Electric and acoustic guitar (Morgan Wallen band)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Catchy, modern country with a bright riff and a driving groove; keep it snappy.','Low-medium gain, bright.'],
     array['Play the bright riff cleanly.','Keep the groove driving.'],
     'Studio recording, 2018 (If I Know Me). Morgan Wallen''s band played a catchy, modern country riff.',70),
    ('butterflies','kacey-musgraves','guitar','riff','strummed progression','acoustic',
     'country','rhythm','beginner',
     'Acoustic guitar (Kacey Musgraves)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, dreamy country-pop strum; keep the chords soft and shimmering.','Natural acoustic tone.'],
     array['Strum the chords gently.','Keep the feel dreamy.'],
     'Studio recording, 2018 (Golden Hour). Kacey Musgraves played a warm, dreamy country-pop strum.',71),
    ('the-house-that-built-me','miranda-lambert','guitar','riff','fingerpicked progression','acoustic',
     'country','rhythm','beginner',
     'Acoustic guitar (Miranda Lambert band)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Tender, gently fingerpicked country ballad; keep it warm and intimate.','Natural acoustic tone.'],
     array['Fingerpick the pattern gently.','Keep the dynamics soft.'],
     'Studio recording, 2009 (Revolution). Miranda Lambert''s band played a tender, gently fingerpicked country ballad.',71),
    ('blue-aint-your-color','keith-urban','guitar','riff','main progression and fills','clean',
     'country','lead','intermediate',
     'Fender Telecaster (Keith Urban)','Bluesy clean-to-crunch amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Smooth, bluesy country-soul with warm clean chords and tasteful lead fills; keep it silky.','Low gain, warm.'],
     array['Play the chords smoothly.','Add tasteful bluesy fills.'],
     'Studio recording, 2016 (Ripcord). Keith Urban played smooth, bluesy country-soul on a Telecaster.',71),
    ('whiskey-lullaby','brad-paisley','guitar','riff','fingerpicked progression and fills','acoustic',
     'country','rhythm','intermediate',
     'Acoustic and Telecaster (Brad Paisley)','Bright clean amp','Open-back combo cab','bridge single-coil',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Somber country ballad with gentle acoustic fingerpicking and mournful Telecaster fills; keep it tender.','Natural acoustic tone with clean electric fills.'],
     array['Fingerpick the acoustic gently.','Add the mournful Telecaster fills.'],
     'Studio recording, 2003 (Mud on the Tires). Brad Paisley played gentle acoustic fingerpicking and mournful Telecaster fills.',72),
    ('no-shoes-no-shirt-no-problems','kenny-chesney','guitar','riff','main riff','crunch',
     'country','rhythm','beginner',
     'Electric and acoustic guitar (Kenny Chesney band)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, breezy beach-country riff; keep it snappy and relaxed.','Low-medium gain, bright.'],
     array['Play the breezy riff cleanly.','Keep the groove relaxed.'],
     'Studio recording, 2003. Kenny Chesney''s band played a bright, breezy beach-country riff.',70),
    ('live-like-you-were-dying','tim-mcgraw','guitar','riff','main progression','crunch',
     'country','rhythm','beginner',
     'Electric and acoustic guitar (Tim McGraw band)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Uplifting country ballad building from gentle acoustic to a full, ringing chorus; keep dynamics wide.','Low-medium gain.'],
     array['Play the verse cleanly.','Open into the ringing chorus.'],
     'Studio recording, 2004. Tim McGraw''s band played an uplifting country ballad building to a ringing chorus.',70),
    ('stay-a-little-longer','brothers-osborne','guitar','riff','main riff and extended solo','crunch',
     'country','lead','advanced',
     'Electric guitar (John Osborne)','Crunch amp with overdrive','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bluesy modern country-rock with a greasy riff and a long, ripping solo; keep it loose and fiery.','Medium gain with grit.'],
     array['Play the greasy riff with a bluesy feel.','Rip the extended solo with big bends.'],
     'Studio recording, 2015 (Pawn Shop). John Osborne played a bluesy modern country-rock riff and a long, ripping solo.',72),
    ('what-was-i-thinkin','dierks-bentley','guitar','riff','main riff','crunch',
     'country','rhythm','beginner',
     'Electric and acoustic guitar (Dierks Bentley band)','Crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Fast, driving bluegrass-tinged country-rock riff; keep it tight and snappy.','Medium gain, bright.'],
     array['Play the fast riff tightly.','Keep the drive up.'],
     'Studio recording, 2003 (Dierks Bentley). Dierks Bentley''s band played a fast, driving bluegrass-tinged country-rock riff.',70),
    ('break-up-with-him','old-dominion','guitar','riff','main riff','clean',
     'country','rhythm','beginner',
     'Electric guitar (Brad Tursi)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, bouncy pop-country with a crisp picked riff; keep it snappy and modern.','Low gain, bright.'],
     array['Play the crisp riff cleanly.','Keep the groove bouncy.'],
     'Studio recording, 2015 (Meat and Candy). Brad Tursi played a bright, bouncy pop-country riff.',70),
    ('chicken-fried','zac-brown-band','guitar','riff','strummed progression','acoustic',
     'country','rhythm','beginner',
     'Acoustic guitar (Zac Brown)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, feel-good strummed country with a relaxed groove; keep the chords ringing.','Natural acoustic tone.'],
     array['Strum the chords with a relaxed groove.','Keep it warm and easy.'],
     'Studio recording, 2008 (The Foundation). Zac Brown played a warm, feel-good strummed country part.',71),
    ('every-girl','turnpike-troubadours','guitar','riff','main progression','crunch',
     'country','rhythm','beginner',
     'Electric and acoustic guitar (Turnpike Troubadours)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, rollicking red-dirt country with jangly chords and fiddle; keep it rootsy and tight.','Low-medium gain.'],
     array['Play the jangly chords cleanly.','Keep the groove rollicking.'],
     'Studio recording, 2017 (A Long Way from Your Heart). The Turnpike Troubadours played warm, rollicking red-dirt country.',70),
    ('i-and-love-and-you','the-avett-brothers','guitar','riff','strummed progression','acoustic',
     'folk','rhythm','beginner',
     'Acoustic guitar (The Avett Brothers)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, heartfelt folk strum with a gentle build; keep the chords ringing and even.','Natural acoustic tone.'],
     array['Strum the chords gently.','Build into the fuller sections.'],
     'Studio recording, 2009 (I and Love and You). The Avett Brothers played a warm, heartfelt folk strum.',71)
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
  ('chris-stapleton','broken-halos'),('chris-stapleton','nobody-to-blame'),('zach-bryan','heading-south'),('tyler-childers','feathered-indians'),
  ('tyler-childers','all-yourn'),('sturgill-simpson','turtles-all-the-way-down'),('jason-isbell','cover-me-up'),('jason-isbell','24-frames'),
  ('eric-church','springsteen'),('eric-church','drink-in-my-hand'),('cody-johnson','til-you-cant'),('luke-combs','hurricane'),
  ('morgan-wallen','whiskey-glasses'),('kacey-musgraves','butterflies'),('miranda-lambert','the-house-that-built-me'),('keith-urban','blue-aint-your-color'),
  ('brad-paisley','whiskey-lullaby'),('kenny-chesney','no-shoes-no-shirt-no-problems'),('tim-mcgraw','live-like-you-were-dying'),('brothers-osborne','stay-a-little-longer'),
  ('dierks-bentley','what-was-i-thinkin'),('old-dominion','break-up-with-him'),('zac-brown-band','chicken-fried'),('turnpike-troubadours','every-girl'),
  ('the-avett-brothers','i-and-love-and-you')
) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
cross join (values
  ('artist_interview', 'Documented artist interviews and gear discussions', null::text,
   'Researched from widely-documented interviews about this recording and player.', 72),
  ('rig_rundown', 'Published rig rundowns and community gear databases', null::text,
   'Cross-referenced against rig features and community-maintained gear databases.', 66)
) as x(source_type, title, url, notes, credibility)
where p.verification_status = 'admin_verified'
on conflict do nothing;
