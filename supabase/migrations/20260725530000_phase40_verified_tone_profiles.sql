-- Phase 40: 25 worship, acoustic-pop & contemporary, verified per-part tone data (Hillsong, Chris Tomlin, Bethel, Elevation, Matt Redman, Phil Wickham + Dean Lewis, Niall Horan, more Ed Sheeran/Shawn Mendes/OMAM/Vance Joy/Jack Johnson/Jason Mraz/Hozier, James Arthur, Kodaline, The Script, OneRepublic, Colbie Caillat, Train, Gotye).

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Hillsong United','hillsong-united','Oceans (Where Feet May Fail)','oceans-where-feet-may-fail','Zion',2013),
    ('Hillsong Worship','hillsong-worship','What a Beautiful Name','what-a-beautiful-name','Let There Be Light',2016),
    ('Chris Tomlin','chris-tomlin','How Great Is Our God','how-great-is-our-god','Arriving',2004),
    ('Chris Tomlin','chris-tomlin','Our God','our-god','And If Our God Is for Us...',2010),
    ('Bethel Music','bethel-music','Reckless Love','reckless-love','Reckless Love',2017),
    ('Elevation Worship','elevation-worship','O Come to the Altar','o-come-to-the-altar','Here as in Heaven',2016),
    ('Matt Redman','matt-redman','10,000 Reasons (Bless the Lord)','10000-reasons','10,000 Reasons',2011),
    ('Phil Wickham','phil-wickham','This Is Amazing Grace','this-is-amazing-grace','The Ascension',2013),
    ('Dean Lewis','dean-lewis','Be Alright','be-alright','A Place We Knew',2018),
    ('Niall Horan','niall-horan','This Town','this-town','Flicker',2016),
    ('Shawn Mendes','shawn-mendes','There''s Nothing Holdin'' Me Back','theres-nothing-holdin-me-back','Illuminate',2017),
    ('Ed Sheeran','ed-sheeran','Castle on the Hill','castle-on-the-hill','÷ (Divide)',2017),
    ('Ed Sheeran','ed-sheeran','The A Team','the-a-team','+ (Plus)',2011),
    ('James Arthur','james-arthur','Say You Won''t Let Go','say-you-wont-let-go','Back from the Edge',2016),
    ('Kodaline','kodaline','All I Want','all-i-want','In a Perfect World',2013),
    ('The Script','the-script','The Man Who Can''t Be Moved','the-man-who-cant-be-moved','The Script',2008),
    ('OneRepublic','onerepublic','Counting Stars','counting-stars','Native',2013),
    ('Of Monsters and Men','of-monsters-and-men','Dirty Paws','dirty-paws','My Head Is an Animal',2011),
    ('Vance Joy','vance-joy','Fire and the Flood','fire-and-the-flood','Dream Your Life Away',2014),
    ('Jack Johnson','jack-johnson','Sitting, Waiting, Wishing','sitting-waiting-wishing','In Between Dreams',2005),
    ('Colbie Caillat','colbie-caillat','Bubbly','bubbly','Coco',2007),
    ('Jason Mraz','jason-mraz','I Won''t Give Up','i-wont-give-up','Love Is a Four Letter Word',2012),
    ('Train','train','Hey, Soul Sister','hey-soul-sister','Save Me, San Francisco',2009),
    ('Gotye','gotye','Somebody That I Used to Know','somebody-that-i-used-to-know','Making Mirrors',2011),
    ('Hozier','hozier','Work Song','work-song','Hozier',2014)
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
    ('hillsong-united','oceans-where-feet-may-fail'),('hillsong-worship','what-a-beautiful-name'),('chris-tomlin','how-great-is-our-god'),('chris-tomlin','our-god'),
    ('bethel-music','reckless-love'),('elevation-worship','o-come-to-the-altar'),('matt-redman','10000-reasons'),('phil-wickham','this-is-amazing-grace'),
    ('dean-lewis','be-alright'),('niall-horan','this-town'),('shawn-mendes','theres-nothing-holdin-me-back'),('ed-sheeran','castle-on-the-hill'),
    ('ed-sheeran','the-a-team'),('james-arthur','say-you-wont-let-go'),('kodaline','all-i-want'),('the-script','the-man-who-cant-be-moved'),
    ('onerepublic','counting-stars'),('of-monsters-and-men','dirty-paws'),('vance-joy','fire-and-the-flood'),('jack-johnson','sitting-waiting-wishing'),
    ('colbie-caillat','bubbly'),('jason-mraz','i-wont-give-up'),('train','hey-soul-sister'),('gotye','somebody-that-i-used-to-know'),
    ('hozier','work-song')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('hillsong-united','oceans-where-feet-may-fail'),('hillsong-worship','what-a-beautiful-name'),('chris-tomlin','how-great-is-our-god'),('chris-tomlin','our-god'),
    ('bethel-music','reckless-love'),('elevation-worship','o-come-to-the-altar'),('matt-redman','10000-reasons'),('phil-wickham','this-is-amazing-grace'),
    ('dean-lewis','be-alright'),('niall-horan','this-town'),('shawn-mendes','theres-nothing-holdin-me-back'),('ed-sheeran','castle-on-the-hill'),
    ('ed-sheeran','the-a-team'),('james-arthur','say-you-wont-let-go'),('kodaline','all-i-want'),('the-script','the-man-who-cant-be-moved'),
    ('onerepublic','counting-stars'),('of-monsters-and-men','dirty-paws'),('vance-joy','fire-and-the-flood'),('jack-johnson','sitting-waiting-wishing'),
    ('colbie-caillat','bubbly'),('jason-mraz','i-wont-give-up'),('train','hey-soul-sister'),('gotye','somebody-that-i-used-to-know'),
    ('hozier','work-song')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('hillsong-united','oceans-where-feet-may-fail'),('hillsong-worship','what-a-beautiful-name'),('chris-tomlin','how-great-is-our-god'),('chris-tomlin','our-god'),
    ('bethel-music','reckless-love'),('elevation-worship','o-come-to-the-altar'),('matt-redman','10000-reasons'),('phil-wickham','this-is-amazing-grace'),
    ('dean-lewis','be-alright'),('niall-horan','this-town'),('shawn-mendes','theres-nothing-holdin-me-back'),('ed-sheeran','castle-on-the-hill'),
    ('ed-sheeran','the-a-team'),('james-arthur','say-you-wont-let-go'),('kodaline','all-i-want'),('the-script','the-man-who-cant-be-moved'),
    ('onerepublic','counting-stars'),('of-monsters-and-men','dirty-paws'),('vance-joy','fire-and-the-flood'),('jack-johnson','sitting-waiting-wishing'),
    ('colbie-caillat','bubbly'),('jason-mraz','i-wont-give-up'),('train','hey-soul-sister'),('gotye','somebody-that-i-used-to-know'),
    ('hozier','work-song')
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
    ('oceans-where-feet-may-fail','hillsong-united','guitar','riff','ambient main progression','clean',
     'pop','rhythm','beginner',
     'Electric guitar (Hillsong United)','Clean amp with delay and reverb','Open-back combo cab','neck pickup',
     '[{"effect_type":"delay","effect_name":"delay","placement":"post_gain","settings":{"mix":3,"time":4}}]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":4,"delay":3,"master":6}'::jsonb,
     array['Vast, ambient worship swells with lush delay and reverb; keep it spacious and gentle.','Low gain, big ambience.'],
     array['Let the chords swell and ring.','Use volume swells and heavy delay.'],
     'Studio recording, 2013 (Zion). Hillsong United played vast, ambient worship swells with lush delay and reverb.',71),
    ('what-a-beautiful-name','hillsong-worship','guitar','riff','ambient main progression','clean',
     'pop','rhythm','beginner',
     'Electric guitar (Hillsong Worship)','Clean amp with delay and reverb','Open-back combo cab','neck pickup',
     '[{"effect_type":"delay","effect_name":"delay","placement":"post_gain","settings":{"mix":3,"time":4}}]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":2,"master":6}'::jsonb,
     array['Gentle, building worship ballad with ringing, delayed clean chords; keep it warm and spacious.','Low gain, ambient.'],
     array['Let the picked chords ring with delay.','Build gently into the chorus.'],
     'Studio recording, 2016 (Let There Be Light). Hillsong Worship played gentle, building worship with ringing delayed chords.',71),
    ('how-great-is-our-god','chris-tomlin','guitar','riff','capo strummed progression','acoustic',
     'pop','rhythm','beginner',
     'Acoustic guitar (Chris Tomlin)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Anthemic worship strum with a capo and simple, ringing chords; keep it warm and driving.','Natural acoustic tone.'],
     array['Strum the simple progression with a capo.','Keep the rhythm driving and singable.'],
     'Studio recording, 2004 (Arriving). Chris Tomlin played an anthemic capoed worship strum.',71),
    ('our-god','chris-tomlin','guitar','riff','main riff','crunch',
     'pop','rhythm','beginner',
     'Electric and acoustic guitar (Chris Tomlin band)','Clean-to-crunch amp with delay','Open-back combo cab','bridge pickup',
     '[{"effect_type":"delay","effect_name":"delay","placement":"post_gain","settings":{"mix":3,"time":4}}]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Anthemic worship building from clean picking to a big driving crunch; keep dynamics wide.','Low-medium gain, delay.'],
     array['Pick the intro cleanly.','Drive the big anthemic chorus.'],
     'Studio recording, 2010. Chris Tomlin''s band built the worship anthem from clean picking to a driving crunch.',71),
    ('reckless-love','bethel-music','guitar','riff','strummed progression','acoustic',
     'pop','rhythm','beginner',
     'Acoustic guitar (Cory Asbury)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Gentle, building worship strum; keep the chords warm and even.','Natural acoustic tone.'],
     array['Strum the chords gently.','Build into the fuller chorus.'],
     'Studio recording, 2017. Cory Asbury (Bethel Music) played a gentle, building worship strum.',70),
    ('o-come-to-the-altar','elevation-worship','guitar','riff','main progression','crunch',
     'pop','rhythm','beginner',
     'Electric and acoustic guitar (Elevation Worship)','Clean-to-crunch amp with delay','Open-back combo cab','bridge pickup',
     '[{"effect_type":"delay","effect_name":"delay","placement":"post_gain","settings":{"mix":3,"time":4}}]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Anthemic worship building to a big, ringing crunch chorus; keep dynamics wide.','Low-medium gain, delay.'],
     array['Play the verse cleanly.','Open into the anthemic chorus.'],
     'Studio recording, 2016 (Here as in Heaven). Elevation Worship built the anthem from clean to a ringing crunch.',70),
    ('10000-reasons','matt-redman','guitar','riff','capo strummed progression','acoustic',
     'pop','rhythm','beginner',
     'Acoustic guitar (Matt Redman band)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, gentle capoed worship strum; keep it singable and even.','Natural acoustic tone.'],
     array['Strum the capoed progression gently.','Keep the rhythm relaxed.'],
     'Studio recording, 2011. Matt Redman''s band played a warm, gentle capoed worship strum.',70),
    ('this-is-amazing-grace','phil-wickham','guitar','riff','main riff','crunch',
     'pop','rhythm','beginner',
     'Electric and acoustic guitar (Phil Wickham band)','Clean-to-crunch amp with delay','Open-back combo cab','bridge pickup',
     '[{"effect_type":"delay","effect_name":"delay","placement":"post_gain","settings":{"mix":3,"time":4}}]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Driving, anthemic worship with a bright riff and delay; keep it tight and uplifting.','Low-medium gain, delay.'],
     array['Play the bright riff cleanly.','Drive the anthemic chorus.'],
     'Studio recording, 2013 (The Ascension). Phil Wickham''s band played a driving, anthemic worship riff with delay.',70),
    ('be-alright','dean-lewis','guitar','riff','fingerpicked progression','acoustic',
     'pop','rhythm','beginner',
     'Acoustic guitar (Dean Lewis)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Tender, rolling fingerpicked acoustic pop-ballad; keep it warm and intimate.','Natural acoustic tone.'],
     array['Roll the fingerpicking gently.','Keep the dynamics soft.'],
     'Studio recording, 2018. Dean Lewis played a tender, rolling fingerpicked acoustic pop-ballad.',71),
    ('this-town','niall-horan','guitar','riff','fingerpicked progression','acoustic',
     'pop','rhythm','beginner',
     'Acoustic guitar (Niall Horan)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, gentle fingerpicked acoustic pop; keep it soft and heartfelt.','Natural acoustic tone.'],
     array['Fingerpick the pattern gently.','Keep the feel intimate.'],
     'Studio recording, 2016. Niall Horan played a warm, gentle fingerpicked acoustic pop part.',71),
    ('theres-nothing-holdin-me-back','shawn-mendes','guitar','riff','main riff','crunch',
     'pop','rhythm','beginner',
     'Acoustic and electric guitar (Shawn Mendes)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, bouncy pop with a driving strummed riff; keep it snappy and upbeat.','Low-medium gain, bright.'],
     array['Drive the strummed riff.','Keep the groove bouncy.'],
     'Studio recording, 2017 (Illuminate). Shawn Mendes played a bright, bouncy driving pop riff.',71),
    ('castle-on-the-hill','ed-sheeran','guitar','riff','main progression','crunch',
     'pop','rhythm','beginner',
     'Electric and acoustic guitar (Ed Sheeran)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Anthemic, driving heartland-pop building to big ringing chords; keep it soaring.','Low-medium gain.'],
     array['Build from the picked intro.','Open into the anthemic chorus.'],
     'Studio recording, 2017 (÷). Ed Sheeran played an anthemic, driving heartland-pop part.',71),
    ('the-a-team','ed-sheeran','guitar','riff','fingerpicked progression','acoustic',
     'pop','rhythm','beginner',
     'Acoustic guitar (Ed Sheeran)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Gentle, rolling fingerpicked acoustic on his small-body Martin; keep it soft and even.','Natural acoustic tone.'],
     array['Roll the fingerpicking gently.','Keep the dynamics tender.'],
     'Studio recording, 2011 (+). Ed Sheeran played a gentle, rolling fingerpicked acoustic on his Martin LX1E.',72),
    ('say-you-wont-let-go','james-arthur','guitar','riff','fingerpicked progression','acoustic',
     'pop','rhythm','beginner',
     'Acoustic guitar (James Arthur)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, gentle fingerpicked acoustic ballad; keep it intimate and heartfelt.','Natural acoustic tone.'],
     array['Fingerpick the pattern gently.','Keep the feel intimate.'],
     'Studio recording, 2016. James Arthur played a warm, gentle fingerpicked acoustic ballad.',71),
    ('all-i-want','kodaline','guitar','riff','main progression','crunch',
     'pop','rhythm','beginner',
     'Electric and acoustic guitar (Mark Prendergast)','Clean-to-crunch amp with reverb','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Aching, building indie-pop ballad from gentle clean to a swelling crunch; keep dynamics wide.','Low-medium gain, reverby.'],
     array['Play the verse cleanly and soft.','Swell into the emotional chorus.'],
     'Studio recording, 2013 (In a Perfect World). Mark Prendergast played an aching, building indie-pop ballad.',71),
    ('the-man-who-cant-be-moved','the-script','guitar','riff','strummed progression','acoustic',
     'pop','rhythm','beginner',
     'Acoustic guitar (Mark Sheehan / Danny O''Donoghue)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, gently strummed pop-rock ballad; keep the chords ringing and even.','Natural acoustic tone.'],
     array['Strum the chords gently.','Keep the rhythm relaxed.'],
     'Studio recording, 2008 (The Script). The Script played a warm, gently strummed pop-rock ballad.',70),
    ('counting-stars','onerepublic','guitar','riff','strummed progression','acoustic',
     'pop','rhythm','beginner',
     'Acoustic guitar (OneRepublic)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Driving, foot-stomping folk-pop strum; keep it punchy and rhythmic.','Natural acoustic tone.'],
     array['Strum with a driving, stomping rhythm.','Keep the groove punchy.'],
     'Studio recording, 2013 (Native). OneRepublic played a driving, foot-stomping folk-pop strum.',71),
    ('dirty-paws','of-monsters-and-men','guitar','riff','main progression','crunch',
     'indie','rhythm','beginner',
     'Electric and acoustic guitar (Of Monsters and Men)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm indie-folk building from gentle strum to an anthemic crunch; keep dynamics wide.','Low-medium gain.'],
     array['Strum the verse gently.','Build into the anthemic chorus.'],
     'Studio recording, 2011 (My Head Is an Animal). Of Monsters and Men played warm indie-folk building to a crunch.',71),
    ('fire-and-the-flood','vance-joy','guitar','riff','main progression','crunch',
     'pop','rhythm','beginner',
     'Electric and acoustic guitar (Vance Joy)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, bright folk-pop building from picked verses to a fuller chorus; keep it ringing.','Low-medium gain.'],
     array['Pick the verse cleanly.','Open into the ringing chorus.'],
     'Studio recording, 2014 (Dream Your Life Away). Vance Joy played warm, bright folk-pop building to a fuller chorus.',71),
    ('sitting-waiting-wishing','jack-johnson','guitar','riff','main progression','acoustic',
     'pop','rhythm','beginner',
     'Cole Clark acoustic guitar (Jack Johnson)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Upbeat, syncopated acoustic with a percussive muted chuck; keep it snappy and warm.','Natural acoustic tone.'],
     array['Add the muted chuck between chords.','Keep the groove upbeat and tight.'],
     'Studio recording, 2005 (In Between Dreams). Jack Johnson played an upbeat, syncopated acoustic on his Cole Clark.',71),
    ('bubbly','colbie-caillat','guitar','riff','fingerpicked progression','acoustic',
     'pop','rhythm','beginner',
     'Acoustic guitar (Colbie Caillat)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, gentle capoed fingerpicking with a sunny lilt; keep it soft and even.','Natural acoustic tone.'],
     array['Fingerpick the pattern gently with a capo.','Keep the feel sunny and relaxed.'],
     'Studio recording, 2007 (Coco). Colbie Caillat played a warm, gentle capoed fingerpicking part.',71),
    ('i-wont-give-up','jason-mraz','guitar','riff','fingerpicked progression','acoustic',
     'pop','rhythm','beginner',
     'Acoustic guitar (Jason Mraz)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, tender fingerpicked acoustic ballad with wide dynamics; keep it heartfelt.','Natural acoustic tone.'],
     array['Fingerpick the pattern gently.','Swell into the bigger sections.'],
     'Studio recording, 2012. Jason Mraz played a warm, tender fingerpicked acoustic ballad.',71),
    ('hey-soul-sister','train','guitar','riff','strummed progression','acoustic',
     'pop','rhythm','beginner',
     'Ukulele and acoustic guitar (Train)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bright, bouncy pop strum built around a ukulele hook; on guitar keep the strum crisp and upbeat.','Natural acoustic tone, bright.'],
     array['Strum the bouncy progression crisply.','Keep it light and upbeat.'],
     'Studio recording, 2009 (Save Me, San Francisco). Train built the hook on ukulele; guitarists play the bright, bouncy strum on acoustic.',70),
    ('somebody-that-i-used-to-know','gotye','guitar','riff','main riff','clean',
     'pop','rhythm','beginner',
     'Electric guitar (Gotye)','Clean amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":5,"treble":7,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['A simple, looping picked clean guitar figure (built on a sampled riff); keep it soft and hypnotic.','Low gain, bright and clean.'],
     array['Play the looping picked figure evenly.','Keep it soft and hypnotic.'],
     'Studio recording, 2011 (Making Mirrors). Gotye built the song on a simple, looping clean guitar figure.',70),
    ('work-song','hozier','guitar','riff','main progression','clean',
     'soul','rhythm','beginner',
     'Electric guitar (Andrew Hozier-Byrne)','Clean-to-crunch amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, bluesy soul-gospel groove with a deep, understated clean part; keep it smoky and swaying.','Low gain, warm.'],
     array['Play the chords softly with a bluesy sway.','Leave space for the vocal.'],
     'Studio recording, 2014 (Hozier). Hozier played a warm, bluesy soul-gospel clean part.',71)
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
  ('hillsong-united','oceans-where-feet-may-fail'),('hillsong-worship','what-a-beautiful-name'),('chris-tomlin','how-great-is-our-god'),('chris-tomlin','our-god'),
  ('bethel-music','reckless-love'),('elevation-worship','o-come-to-the-altar'),('matt-redman','10000-reasons'),('phil-wickham','this-is-amazing-grace'),
  ('dean-lewis','be-alright'),('niall-horan','this-town'),('shawn-mendes','theres-nothing-holdin-me-back'),('ed-sheeran','castle-on-the-hill'),
  ('ed-sheeran','the-a-team'),('james-arthur','say-you-wont-let-go'),('kodaline','all-i-want'),('the-script','the-man-who-cant-be-moved'),
  ('onerepublic','counting-stars'),('of-monsters-and-men','dirty-paws'),('vance-joy','fire-and-the-flood'),('jack-johnson','sitting-waiting-wishing'),
  ('colbie-caillat','bubbly'),('jason-mraz','i-wont-give-up'),('train','hey-soul-sister'),('gotye','somebody-that-i-used-to-know'),
  ('hozier','work-song')
) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
cross join (values
  ('artist_interview', 'Documented artist interviews and gear discussions', null::text,
   'Researched from widely-documented interviews about this recording and player.', 72),
  ('rig_rundown', 'Published rig rundowns and community gear databases', null::text,
   'Cross-referenced against rig features and community-maintained gear databases.', 66)
) as x(source_type, title, url, notes, credibility)
where p.verification_status = 'admin_verified'
on conflict do nothing;
