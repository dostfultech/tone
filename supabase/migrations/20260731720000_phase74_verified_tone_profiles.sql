-- Phase 74: 2000s heavy completeness — ADTR, nu-metal singles, post-hardcore canon, metalcore fills.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('A Day to Remember','a-day-to-remember','All I Want','all-i-want','What Separates Me from You',2010),
    ('A Day to Remember','a-day-to-remember','If It Means a Lot to You','if-it-means-a-lot-to-you','Homesick',2009),
    ('A Day to Remember','a-day-to-remember','The Downfall of Us All','the-downfall-of-us-all','Homesick',2009),
    ('Slipknot','slipknot','Before I Forget','before-i-forget','Vol. 3: (The Subliminal Verses)',2004),
    ('Slipknot','slipknot','Wait and Bleed','wait-and-bleed','Slipknot',1999),
    ('Korn','korn','Falling Away from Me','falling-away-from-me','Issues',1999),
    ('Mudvayne','mudvayne','Happy?','happy','Lost and Found',2005),
    ('P.O.D.','p-o-d','Alive','alive','Satellite',2001),
    ('P.O.D.','p-o-d','Youth of the Nation','youth-of-the-nation','Satellite',2001),
    ('Drowning Pool','drowning-pool','Bodies','bodies','Sinner',2001),
    ('Underoath','underoath','A Boy Brushed Red Living in Black and White','a-boy-brushed-red','They''re Only Chasing Safety',2004),
    ('Thrice','thrice','The Artist in the Ambulance','the-artist-in-the-ambulance','The Artist in the Ambulance',2003),
    ('Thursday','thursday','Understanding in a Car Crash','understanding-in-a-car-crash','Full Collapse',2001),
    ('Silverstein','silverstein','My Heroine','my-heroine','Discovering the Waterfront',2005),
    ('Alexisonfire','alexisonfire','This Could Be Anywhere in the World','this-could-be-anywhere-in-the-world','Crisis',2006),
    ('Saosin','saosin','Seven Years','seven-years','Translating the Name',2003),
    ('Senses Fail','senses-fail','Can''t Be Saved','cant-be-saved','Still Searching',2006),
    ('Ice Nine Kills','ice-nine-kills','Hip to Be Scared','hip-to-be-scared','The Silver Scream 2: Welcome to Horrorwood',2021),
    ('The Devil Wears Prada','the-devil-wears-prada','Danger: Wildman','danger-wildman','Dead Throne',2011),
    ('Parkway Drive','parkway-drive','Carrion','carrion','Deep Blue',2010),
    ('While She Sleeps','while-she-sleeps','Anti-Social','anti-social','So What?',2019),
    ('Beartooth','beartooth','In Between','in-between','Disgusting',2014),
    ('Wage War','wage-war','Low','low','Deadweight',2017),
    ('Of Mice & Men','of-mice-and-men','Second & Sebring','second-and-sebring','Of Mice & Men',2010),
    ('Asking Alexandria','asking-alexandria','The Final Episode (Let''s Change the Channel)','the-final-episode','Stand Up and Scream',2009)
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
    ('a-day-to-remember','all-i-want'),('a-day-to-remember','if-it-means-a-lot-to-you'),('a-day-to-remember','the-downfall-of-us-all'),
    ('slipknot','before-i-forget'),('slipknot','wait-and-bleed'),('korn','falling-away-from-me'),('mudvayne','happy'),
    ('p-o-d','alive'),('p-o-d','youth-of-the-nation'),('drowning-pool','bodies'),('underoath','a-boy-brushed-red'),
    ('thrice','the-artist-in-the-ambulance'),('thursday','understanding-in-a-car-crash'),('silverstein','my-heroine'),
    ('alexisonfire','this-could-be-anywhere-in-the-world'),('saosin','seven-years'),('senses-fail','cant-be-saved'),
    ('ice-nine-kills','hip-to-be-scared'),('the-devil-wears-prada','danger-wildman'),('parkway-drive','carrion'),
    ('while-she-sleeps','anti-social'),('beartooth','in-between'),('wage-war','low'),('of-mice-and-men','second-and-sebring'),
    ('asking-alexandria','the-final-episode')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('a-day-to-remember','all-i-want'),('a-day-to-remember','if-it-means-a-lot-to-you'),('a-day-to-remember','the-downfall-of-us-all'),
    ('slipknot','before-i-forget'),('slipknot','wait-and-bleed'),('korn','falling-away-from-me'),('mudvayne','happy'),
    ('p-o-d','alive'),('p-o-d','youth-of-the-nation'),('drowning-pool','bodies'),('underoath','a-boy-brushed-red'),
    ('thrice','the-artist-in-the-ambulance'),('thursday','understanding-in-a-car-crash'),('silverstein','my-heroine'),
    ('alexisonfire','this-could-be-anywhere-in-the-world'),('saosin','seven-years'),('senses-fail','cant-be-saved'),
    ('ice-nine-kills','hip-to-be-scared'),('the-devil-wears-prada','danger-wildman'),('parkway-drive','carrion'),
    ('while-she-sleeps','anti-social'),('beartooth','in-between'),('wage-war','low'),('of-mice-and-men','second-and-sebring'),
    ('asking-alexandria','the-final-episode')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('a-day-to-remember','all-i-want'),('a-day-to-remember','if-it-means-a-lot-to-you'),('a-day-to-remember','the-downfall-of-us-all'),
    ('slipknot','before-i-forget'),('slipknot','wait-and-bleed'),('korn','falling-away-from-me'),('mudvayne','happy'),
    ('p-o-d','alive'),('p-o-d','youth-of-the-nation'),('drowning-pool','bodies'),('underoath','a-boy-brushed-red'),
    ('thrice','the-artist-in-the-ambulance'),('thursday','understanding-in-a-car-crash'),('silverstein','my-heroine'),
    ('alexisonfire','this-could-be-anywhere-in-the-world'),('saosin','seven-years'),('senses-fail','cant-be-saved'),
    ('ice-nine-kills','hip-to-be-scared'),('the-devil-wears-prada','danger-wildman'),('parkway-drive','carrion'),
    ('while-she-sleeps','anti-social'),('beartooth','in-between'),('wage-war','low'),('of-mice-and-men','second-and-sebring'),
    ('asking-alexandria','the-final-episode')
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
    -- ============ A DAY TO REMEMBER ============
    ('all-i-want','a-day-to-remember','guitar','riff','main riff','high_gain','metalcore','rhythm','intermediate',
     'ESP/Gibson electric (Kevin Skaff / Neil Westfall)','Modern high-gain, pop-mosh polish','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"gate","effect_name":"noise gate","placement":"front","settings":{"threshold":6}}]'::jsonb,
     '{"gain":7,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The pop-mosh flagship — drop-D wall flipping between breakdown chug and soaring pop chorus.','Tight modern saturation; two personalities, one tone.'],
     array['Drop D; the verse chugs, the chorus flies.','The gang-vocal bridge wants everything you have.'],
     'Studio recording, 2010. The pop-mosh flagship.',75),
    ('if-it-means-a-lot-to-you','a-day-to-remember','guitar','main','acoustic duet','acoustic','metalcore','rhythm','beginner',
     'Acoustic guitar (Tom Denney / Neil Westfall)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The metalcore prom song — tender country-tinged acoustic duet that every scene kid knows by heart.','Warm open acoustic; the full-band swell arrives late.'],
     array['Gentle strums under the duet verses.','Hey darling — save the big strums for the climax.'],
     'Studio recording, 2009. The scene''s acoustic prom song.',76),
    ('the-downfall-of-us-all','a-day-to-remember','guitar','riff','main riff','high_gain','metalcore','rhythm','intermediate',
     'ESP/Gibson electric (Tom Denney / Neil Westfall)','Modern high-gain','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"gate","effect_name":"tight gate","placement":"front","settings":{"threshold":7}}]'::jsonb,
     '{"gain":7,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":0,"delay":0,"master":8}'::jsonb,
     array['The circle-pit anthem — bouncing drop chug with the woah-oh intro.','Percussive tight wall; pure Warped Tour energy.'],
     array['The intro woahs, then the bounce hits.','Chug with the kick; jump with the crowd.'],
     'Studio recording, 2009. The circle-pit woah anthem.',75),

    -- ============ NU-METAL SINGLES ============
    ('before-i-forget','slipknot','guitar','riff','main riff','high_gain','nu metal','rhythm','intermediate',
     'B.C. Rich/Ibanez (Mick Thomson / Jim Root)','Rivera/Orange-style high-gain wall','Closed-back 4x12 cab','EMG bridge humbucker',
     '[{"effect_type":"gate","effect_name":"tight gate","placement":"front","settings":{"threshold":7}}]'::jsonb,
     '{"gain":8,"bass":6,"mids":4,"treble":6,"presence":6,"reverb":0,"delay":0,"master":8}'::jsonb,
     array['The Grammy winner — drop-B groove riff, tight as a vault door.','Scooped crushing wall; the groove is the hook.'],
     array['Drop B; the main riff rolls like a tank.','I. Am. A. World. Before. I. Am. A. Man. — that cadence.'],
     'Studio recording, 2004. The Grammy-winning vault-door groove.',77),
    ('wait-and-bleed','slipknot','guitar','riff','main riff','high_gain','nu metal','rhythm','intermediate',
     'B.C. Rich/Jackson (Mick Thomson / Josh Brainard)','High-gain wall, debut-era rawness','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"gate","effect_name":"gate","placement":"front","settings":{"threshold":7}}]'::jsonb,
     '{"gain":8,"bass":6,"mids":4,"treble":7,"presence":7,"reverb":0,"delay":0,"master":8}'::jsonb,
     array['The breakout — nine-man chaos compressed into a drop-B hook.','Raw scooped aggression with a melodic chorus hiding inside.'],
     array['The verse riff stabs; the chorus opens.','Controlled violence — the Slipknot job description.'],
     'Studio recording, 1999. The nine-man breakout.',77),
    ('falling-away-from-me','korn','guitar','riff','main riff','high_gain','nu metal','rhythm','intermediate',
     'Ibanez 7-string (Munky / Head)','Mesa/Marshall hybrid wall','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":7,"mids":4,"treble":6,"presence":5,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The Issues opener — creeping 7-string clicks into the drop wall.','Deep scooped 7-string grind; the creepy verse textures are pick scrapes and harmonics.'],
     array['7-string A tuning; the verse whispers before the beating.','The stop-start chorus demands total sync.'],
     'Studio recording, 1999. The creeping Issues single.',77),
    ('happy','mudvayne','guitar','riff','main riff','high_gain','nu metal','rhythm','advanced',
     'Ibanez/ESP (Greg Tribbett)','Modern high-gain, prog-nu precision','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"gate","effect_name":"tight gate","placement":"front","settings":{"threshold":7}}]'::jsonb,
     '{"gain":7,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The math-nu single — syncopated drop riffing with that slithering bass underneath.','Tight surgical wall; the rhythm section does calculus.'],
     array['Count the syncopations before chasing speed.','Lock to Ryan Martinie''s bass — he leads.'],
     'Studio recording, 2005. The math-nu radio single.',75),
    ('alive','p-o-d','guitar','riff','main riff','high_gain','nu metal','rhythm','beginner',
     'Ibanez (Marcos Curiel)','Modern high-gain with SoCal bounce','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The sunlit nu-metal anthem — soaring drop-D wall with gratitude instead of rage.','Thick warm saturation; the chorus lifts skyward.'],
     array['Drop D; ride the groove joyfully.','I feel so alive — play like you mean it.'],
     'Studio recording, 2001. The sunlit gratitude anthem.',75),
    ('youth-of-the-nation','p-o-d','guitar','riff','clean verse + heavy chorus','clean','nu metal','rhythm','beginner',
     'Ibanez (Marcos Curiel)','Clean-to-heavy rig','Closed-back 4x12 cab','neck pickup (verse)',
     '[{"effect_type":"chorus","effect_name":"soft chorus (verse)","placement":"post_gain","settings":{"rate":3,"depth":3,"mix":3}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The eulogy anthem — chorused clean verses (settings shown) into the heavy chorus (gain 7).','Two rigs: mournful clean, massive drop wall.'],
     array['Arpeggiate the somber verse figure.','The children''s-choir outro carries it home.'],
     'Studio recording, 2001. The eulogy anthem.',75),
    ('bodies','drowning-pool','guitar','riff','main riff','high_gain','nu metal','rhythm','beginner',
     'ESP/Jackson (C.J. Pierce)','High-gain wall','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"gate","effect_name":"tight gate","placement":"front","settings":{"threshold":7}}]'::jsonb,
     '{"gain":8,"bass":6,"mids":4,"treble":6,"presence":6,"reverb":0,"delay":0,"master":8}'::jsonb,
     array['Let the bodies hit the floor — the whisper-to-scream drop wall everyone knows.','Scooped crushing chug; dynamics from whisper to detonation.'],
     array['The riff is simple; the tension build is the art.','One. Nothing wrong with me. You know what comes next.'],
     'Studio recording, 2001. The whisper-to-detonation anthem.',75),

    -- ============ POST-HARDCORE CANON ============
    ('a-boy-brushed-red','underoath','guitar','riff','main riff','high_gain','post-hardcore','rhythm','intermediate',
     'Fender/Gibson electric (Tim McTague / James Smith)','Modern high-gain with ambient breaks','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"delay","effect_name":"ambient delay (breaks)","placement":"post_gain","settings":{"time":4,"mix":3,"feedback":3}}]'::jsonb,
     '{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":2,"master":8}'::jsonb,
     array['The scream-sing blueprint — churning drive with glassy ambient interludes.','Saturated but melodic; the quiet breaks breathe.'],
     array['The verse churns; the bridge floats.','Can you feel your heart beat racing? — that tempo.'],
     'Studio recording, 2004. The scream-sing blueprint.',76),
    ('the-artist-in-the-ambulance','thrice','guitar','riff','main riff','high_gain','post-hardcore','rhythm','advanced',
     'Gibson Les Paul (Teppei Teranishi / Dustin Kensrue)','Driven stack, intricate melodic hardcore','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The technical melodic-hardcore peak — sprinting riffs with intricate lead weaving.','Bright saturated precision; punk speed, prog detail.'],
     array['The intro riff sprints — alternate picking discipline.','The dual-guitar weave rewards learning both parts.'],
     'Studio recording, 2003. The technical melodic-hardcore peak.',76),
    ('understanding-in-a-car-crash','thursday','guitar','riff','main riff','distorted','post-hardcore','rhythm','intermediate',
     'Fender/Gibson electric (Tom Keeley / Steve Pedulla)','Driven amps, urgent and raw','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The Full Collapse siren — angular urgent drive that named a genre''s feelings.','Bright raw saturation; beauty mid-collision.'],
     array['The intro figure keens like a siren.','Push-pull dynamics between chaos and melody.'],
     'Studio recording, 2001. The Full Collapse siren.',75),
    ('my-heroine','silverstein','guitar','riff','main riff','high_gain','post-hardcore','rhythm','intermediate',
     'Gibson/PRS electric (Neil Boshart / Josh Bradford)','Modern high-gain, emo-core polish','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The screamo staple — melodic drop-tuned wall under the scream-sing trade.','Saturated melodic drive; heartbreak at stage volume.'],
     array['The lead hook answers every vocal line.','Quiet bridge, then total release.'],
     'Studio recording, 2005. The screamo staple.',75),
    ('this-could-be-anywhere-in-the-world','alexisonfire','guitar','riff','main riff','distorted','post-hardcore','rhythm','intermediate',
     'Gibson Les Paul (Wade MacNeil / Dallas Green)','Driven stack, anthemic grit','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The Canadian post-hardcore anthem — gritty drive under George''s bark and Dallas'' croon.','Warm aggressive crunch-wall; three voices, one riff.'],
     array['The verse riff marches; the chorus soars.','The gang-vocal end is a hometown chant.'],
     'Studio recording, 2006. The Canadian anthem.',75),
    ('seven-years','saosin','guitar','riff','tapped intro + wall','clean','post-hardcore','lead','advanced',
     'Fender/Ibanez electric (Beau Burchell / Justin Shekoski era)','Clean-to-driven rig','Closed-back cab','bridge humbucker',
     '[{"effect_type":"delay","effect_name":"ambient delay","placement":"post_gain","settings":{"time":4,"mix":3,"feedback":3}},{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":7,"presence":6,"reverb":4,"delay":3,"master":6}'::jsonb,
     array['The tapped-intro legend — glassy clean tapping (settings shown) into the soaring wall (gain 7).','Bright ambient clean; the intro tap figure is scene scripture.'],
     array['The intro taps must ring crystal-clear.','When the wall drops, hold nothing back.'],
     'Studio recording, 2003. The tapped-intro scene scripture.',76),
    ('cant-be-saved','senses-fail','guitar','riff','main riff','distorted','post-hardcore','rhythm','intermediate',
     'Gibson/ESP electric (Garrett Zablocki / Heath Saraceno)','Driven stack, emo-core bite','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The Still Searching single — bright biting drive with the sing-along lift.','Trebly saturated crunch; misery you can pogo to.'],
     array['The lead riff hooks over the chords.','Follow your bliss — at 170 BPM.'],
     'Studio recording, 2006. The Still Searching single.',75),

    -- ============ MODERN METALCORE FILLS ============
    ('hip-to-be-scared','ice-nine-kills','guitar','riff','main riff','high_gain','metalcore','rhythm','intermediate',
     'ESP/Jackson (Ricky Armellino / Dan Sugarman)','Modern high-gain, theatrical production','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"gate","effect_name":"tight gate","placement":"front","settings":{"threshold":7}}]'::jsonb,
     '{"gain":7,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The American Psycho homage — theatrical metalcore with swing-jazz stabs.','Tight produced wall; horror-musical whiplash.'],
     array['The suit-and-axe swing section is the twist.','Play the breakdown like a business card reveal.'],
     'Studio recording, 2021. The American Psycho homage.',74),
    ('danger-wildman','the-devil-wears-prada','guitar','riff','main riff','high_gain','metalcore','rhythm','advanced',
     'ESP/Ibanez (Chris Rubey / Jeremy DePoyster)','Modern high-gain','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"gate","effect_name":"tight gate","placement":"front","settings":{"threshold":7}}]'::jsonb,
     '{"gain":7,"bass":6,"mids":5,"treble":7,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The Dead Throne opener-adjacent frenzy — jagged drop riffing at full sprint.','Bright surgical wall; chaos with a grid.'],
     array['The riff jags — subdivide carefully.','Breakdown restraint makes the drop hit.'],
     'Studio recording, 2011. The Dead Throne frenzy.',74),
    ('carrion','parkway-drive','guitar','riff','main riff','high_gain','metalcore','rhythm','intermediate',
     'ESP (Jeff Ling / Luke Kilpatrick)','Modern high-gain, Byron-era wall','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"gate","effect_name":"tight gate","placement":"front","settings":{"threshold":7}}]'::jsonb,
     '{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The Deep Blue standard — galloping Aussie metalcore with the singalong lead.','Crushing tight wall; the melodic lead cuts through.'],
     array['Gallop the verse; sing the lead line.','The breakdown asks for the whole room.'],
     'Studio recording, 2010. The Deep Blue standard.',75),
    ('anti-social','while-she-sleeps','guitar','riff','main riff','high_gain','metalcore','rhythm','intermediate',
     'ESP/Fender (Sean Long / Mat Welsh)','Modern high-gain, UK grit','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"gate","effect_name":"gate","placement":"front","settings":{"threshold":6}}]'::jsonb,
     '{"gain":7,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The Sheffield statement — hooky drop riffing with anthemic gang vocals.','Tight modern wall with punk snarl.'],
     array['The main riff bounces; the chant carries.','You say I''m antisocial — louder.'],
     'Studio recording, 2019. The Sheffield anti-anthem.',74),
    ('in-between','beartooth','guitar','riff','main riff','high_gain','metalcore','rhythm','beginner',
     'ESP/Gibson (Caleb Shomo — all instruments)','Modern high-gain, one-man wall','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"gate","effect_name":"gate","placement":"front","settings":{"threshold":6}}]'::jsonb,
     '{"gain":7,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The Disgusting single — Shomo''s punk-metalcore drive, hooky and huge.','Thick saturated wall; every part written by one guy screaming honestly.'],
     array['Drive the chords; the melody is the vocal''s.','Caught in between who I am and who I wanna be — the riff carries both.'],
     'Studio recording, 2014. Shomo''s one-man wall.',74),
    ('low','wage-war','guitar','riff','main riff','high_gain','metalcore','rhythm','intermediate',
     'PRS/ESP (Seth Blake / Cody Quistad)','Modern amp-sim high-gain','Studio direct (IR cab)','bridge humbucker',
     '[{"effect_type":"gate","effect_name":"tight gate","placement":"front","settings":{"threshold":7}}]'::jsonb,
     '{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The Deadweight crusher — low-tuned modern production chug with a melodic hook.','Surgical produced wall; the drop hits like machinery.'],
     array['Very low tuning; palm-mute discipline.','Restraint until the drop; then none.'],
     'Studio recording, 2017. The Deadweight crusher.',74),
    ('second-and-sebring','of-mice-and-men','guitar','riff','main riff','high_gain','metalcore','rhythm','intermediate',
     'Ibanez/ESP (Phil Manansala / Shayley Bourget era)','Modern high-gain with clean bridge','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"gate","effect_name":"gate","placement":"front","settings":{"threshold":6}}]'::jsonb,
     '{"gain":7,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The tribute single — crushing verses into the clean-sung promise of the bridge.','Tight wall with a soft heart; the address is a mother''s memory.'],
     array['The clean bridge (gain 2) is the emotional core.','Scream the verses; mean the bridge.'],
     'Studio recording, 2010. The tribute single.',75),
    ('the-final-episode','asking-alexandria','guitar','riff','main riff','high_gain','metalcore','rhythm','intermediate',
     'ESP (Ben Bruce / Cameron Liddell)','Modern high-gain with synth stabs','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"gate","effect_name":"tight gate","placement":"front","settings":{"threshold":7}}]'::jsonb,
     '{"gain":8,"bass":6,"mids":4,"treble":7,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The MySpace-core landmark — trancecore synth stabs over drop-C chug.','Scooped tight wall; the electronics are half the riff.'],
     array['Stop-start with the synth hits.','The breakdown believed in itself completely. So must you.'],
     'Studio recording, 2009. The trancecore landmark.',74)
) as c(
  song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence
)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;
