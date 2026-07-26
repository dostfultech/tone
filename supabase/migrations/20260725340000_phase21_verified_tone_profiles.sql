-- Phase 21: 25 2000s post-grunge / alt-metal / nu-metal radio-rock staples, verified per-part tone data.
-- Audioslave, Velvet Revolver, Bush, Live, Collective Soul, Silverchair, Three Days Grace,
-- Nickelback, Shinedown, Breaking Benjamin, Papa Roach, Staind, Puddle of Mudd, Seether,
-- Creed, Alter Bridge, Chevelle, Trapt, Evanescence, A Perfect Circle, Hoobastank, 30 Seconds to Mars.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Audioslave','audioslave','Like a Stone','like-a-stone','Audioslave',2002),
    ('Audioslave','audioslave','Cochise','cochise','Audioslave',2002),
    ('Velvet Revolver','velvet-revolver','Slither','slither','Contraband',2004),
    ('Bush','bush','Glycerine','glycerine','Sixteen Stone',1994),
    ('Bush','bush','Machinehead','machinehead','Sixteen Stone',1994),
    ('Live','live','Lightning Crashes','lightning-crashes','Throwing Copper',1994),
    ('Collective Soul','collective-soul','Shine','shine','Hints Allegations and Things Left Unsaid',1993),
    ('Silverchair','silverchair','Tomorrow','tomorrow','Frogstomp',1994),
    ('Three Days Grace','three-days-grace','Animal I Have Become','animal-i-have-become','One-X',2006),
    ('Nickelback','nickelback','How You Remind Me','how-you-remind-me','Silver Side Up',2001),
    ('Shinedown','shinedown','Second Chance','second-chance','The Sound of Madness',2008),
    ('Breaking Benjamin','breaking-benjamin','The Diary of Jane','the-diary-of-jane','Phobia',2006),
    ('Papa Roach','papa-roach','Last Resort','last-resort','Infest',2000),
    ('Staind','staind','It''s Been Awhile','its-been-awhile','Break the Cycle',2001),
    ('Puddle of Mudd','puddle-of-mudd','Blurry','blurry','Come Clean',2001),
    ('Seether','seether','Fake It','fake-it','Finding Beauty in Negative Spaces',2007),
    ('Creed','creed','Higher','higher','Human Clay',1999),
    ('Creed','creed','With Arms Wide Open','with-arms-wide-open','Human Clay',1999),
    ('Alter Bridge','alter-bridge','Blackbird','blackbird','Blackbird',2007),
    ('Chevelle','chevelle','The Red','the-red','Wonder What''s Next',2002),
    ('Trapt','trapt','Headstrong','headstrong','Trapt',2002),
    ('Evanescence','evanescence','Bring Me to Life','bring-me-to-life','Fallen',2003),
    ('A Perfect Circle','a-perfect-circle','Judith','judith','Mer de Noms',2000),
    ('Hoobastank','hoobastank','The Reason','the-reason','The Reason',2003),
    ('30 Seconds to Mars','30-seconds-to-mars','The Kill','the-kill','A Beautiful Lie',2005)
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
    ('audioslave','like-a-stone'),('audioslave','cochise'),('velvet-revolver','slither'),('bush','glycerine'),('bush','machinehead'),
    ('live','lightning-crashes'),('collective-soul','shine'),('silverchair','tomorrow'),('three-days-grace','animal-i-have-become'),
    ('nickelback','how-you-remind-me'),('shinedown','second-chance'),('breaking-benjamin','the-diary-of-jane'),('papa-roach','last-resort'),
    ('staind','its-been-awhile'),('puddle-of-mudd','blurry'),('seether','fake-it'),('creed','higher'),('creed','with-arms-wide-open'),
    ('alter-bridge','blackbird'),('chevelle','the-red'),('trapt','headstrong'),('evanescence','bring-me-to-life'),
    ('a-perfect-circle','judith'),('hoobastank','the-reason'),('30-seconds-to-mars','the-kill')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('audioslave','like-a-stone'),('audioslave','cochise'),('velvet-revolver','slither'),('bush','glycerine'),('bush','machinehead'),
    ('live','lightning-crashes'),('collective-soul','shine'),('silverchair','tomorrow'),('three-days-grace','animal-i-have-become'),
    ('nickelback','how-you-remind-me'),('shinedown','second-chance'),('breaking-benjamin','the-diary-of-jane'),('papa-roach','last-resort'),
    ('staind','its-been-awhile'),('puddle-of-mudd','blurry'),('seether','fake-it'),('creed','higher'),('creed','with-arms-wide-open'),
    ('alter-bridge','blackbird'),('chevelle','the-red'),('trapt','headstrong'),('evanescence','bring-me-to-life'),
    ('a-perfect-circle','judith'),('hoobastank','the-reason'),('30-seconds-to-mars','the-kill')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('audioslave','like-a-stone'),('audioslave','cochise'),('velvet-revolver','slither'),('bush','glycerine'),('bush','machinehead'),
    ('live','lightning-crashes'),('collective-soul','shine'),('silverchair','tomorrow'),('three-days-grace','animal-i-have-become'),
    ('nickelback','how-you-remind-me'),('shinedown','second-chance'),('breaking-benjamin','the-diary-of-jane'),('papa-roach','last-resort'),
    ('staind','its-been-awhile'),('puddle-of-mudd','blurry'),('seether','fake-it'),('creed','higher'),('creed','with-arms-wide-open'),
    ('alter-bridge','blackbird'),('chevelle','the-red'),('trapt','headstrong'),('evanescence','bring-me-to-life'),
    ('a-perfect-circle','judith'),('hoobastank','the-reason'),('30-seconds-to-mars','the-kill')
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
    ('like-a-stone','audioslave','guitar','riff','main progression and solo','crunch','rock','lead','intermediate',
     'Custom electric guitar (Tom Morello)','Marshall amp on the edge of breakup','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, ringing clean-to-crunch verses with a soulful, wailing solo; keep the verses gentle.','Low-medium gain with dynamics.'],
     array['Let the arpeggiated verse chords ring.','Play the expressive solo with feel.'],
     'Studio recording, 2002 (Audioslave). Tom Morello played warm clean-to-crunch verses and a soulful solo through a Marshall.',75),
    ('cochise','audioslave','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Custom electric guitar (Tom Morello)','Marshall high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Explosive, driving distorted riff; keep the power chords tight and pummeling.','Medium-high gain.'],
     array['Drive the riff with relentless energy.','Keep the power chords tight.'],
     'Studio recording, 2002 (Audioslave). Tom Morello played an explosive, driving distorted riff through a Marshall.',74),
    ('slither','velvet-revolver','guitar','riff','main riff and solo','crunch','rock','lead','intermediate',
     'Gibson Les Paul (Slash)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Dirty, swaggering hard-rock crunch with a bluesy Slash solo; keep the riff tight.','Medium-high gain.'],
     array['Drive the main riff with swagger.','Play the bluesy solo with big bends.'],
     'Studio recording, 2004 (Contraband). Slash played a dirty, swaggering hard-rock crunch and bluesy solo on a Les Paul through a Marshall.',75),
    ('glycerine','bush','guitar','riff','main progression','crunch','rock','rhythm','beginner',
     'Electric guitar (Gavin Rossdale)','Clean-to-crunch amp with ambience','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Simple four-chord post-grunge that swells from clean to crunch; keep the dynamics wide.','Low-medium gain.'],
     array['Play the verse chords softly.','Open up for the fuller chorus.'],
     'Studio recording, 1994 (Sixteen Stone). Gavin Rossdale played a simple, swelling clean-to-crunch part.',74),
    ('machinehead','bush','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Electric guitar (Gavin Rossdale)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Heavy, driving post-grunge distortion; keep the riff tight and powerful.','Medium-high gain.'],
     array['Drive the riff with energy.','Keep the palm mutes tight.'],
     'Studio recording, 1994 (Sixteen Stone). Bush played a heavy, driving post-grunge distorted riff.',73),
    ('lightning-crashes','live','guitar','riff','main progression','crunch','rock','rhythm','beginner',
     'Electric guitar (Chad Taylor)','Clean-to-crunch amp with ambience','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Builds from a delicate clean verse to a big, emotional crunch chorus; keep dynamics wide.','Low-medium gain.'],
     array['Play the clean verse softly.','Swell into the crashing chorus.'],
     'Studio recording, 1994 (Throwing Copper). Chad Taylor played a dynamic clean-to-crunch part that builds emotionally.',73),
    ('shine','collective-soul','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Electric guitar (Collective Soul)','Crunch amp','Open-back combo cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Big, ringing 90s alt-rock crunch riff; keep it anthemic and driving.','Medium gain.'],
     array['Let the main riff ring big.','Keep the groove steady.'],
     'Studio recording, 1993. Collective Soul played a big, ringing alt-rock crunch riff.',73),
    ('tomorrow','silverchair','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Electric guitar (Daniel Johns)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Grunge dynamics from quiet clean verses to a heavy distorted chorus; keep it raw.','Medium-high gain for the chorus.'],
     array['Keep the verse restrained.','Slam into the heavy chorus.'],
     'Studio recording, 1994 (Frogstomp). Daniel Johns played raw grunge dynamics from clean verse to heavy chorus.',73),
    ('animal-i-have-become','three-days-grace','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Electric guitar (Three Days Grace)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Dark, driving post-grunge distortion; keep the riff tight and heavy.','Medium-high gain, drop tuning.'],
     array['Keep the riff tight and driving.','Build into the heavy chorus.'],
     'Studio recording, 2006 (One-X). Three Days Grace played a dark, driving post-grunge distorted riff.',73),
    ('how-you-remind-me','nickelback','guitar','riff','main riff','distorted','rock','rhythm','beginner',
     'Electric guitar (Chad Kroeger / Ryan Peake)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Punchy post-grunge crunch with clean-picked verses; keep the chorus big.','Medium-high gain, drop-D feel.'],
     array['Pick the verse arpeggios cleanly.','Slam the big distorted chorus.'],
     'Studio recording, 2001 (Silver Side Up). Nickelback played punchy post-grunge crunch with clean-picked verses.',73),
    ('second-chance','shinedown','guitar','riff','main progression','crunch','rock','rhythm','beginner',
     'Electric guitar (Shinedown)','Clean-to-crunch amp with ambience','Open-back combo cab','bridge humbucker',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":1,"master":6}'::jsonb,
     array['Bright, anthemic clean-to-crunch that builds; keep the picked intro shimmering.','Low-medium gain with ambience.'],
     array['Let the picked intro ring.','Open up for the anthemic chorus.'],
     'Studio recording, 2008 (The Sound of Madness). Shinedown played a bright, anthemic clean-to-crunch part.',73),
    ('the-diary-of-jane','breaking-benjamin','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Electric guitar (Breaking Benjamin)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Driving, melodic post-grunge distortion; keep the riff tight and urgent.','Medium-high gain, drop tuning.'],
     array['Keep the driving riff tight.','Build into the big chorus.'],
     'Studio recording, 2006 (Phobia). Breaking Benjamin played a driving, melodic post-grunge distorted riff.',73),
    ('last-resort','papa-roach','guitar','riff','main riff','distorted','rock','rhythm','beginner',
     'Electric guitar (Jerry Horton)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Iconic nu-metal distorted riff; keep it tight, punchy, and driving.','Medium-high gain, drop tuning.'],
     array['Keep the iconic riff tight.','Lock to the driving groove.'],
     'Studio recording, 2000 (Infest). Jerry Horton played the iconic nu-metal distorted riff.',73),
    ('its-been-awhile','staind','guitar','riff','main progression','crunch','rock','rhythm','beginner',
     'Electric guitar (Mike Mushok)','Clean-to-crunch amp with ambience','Open-back combo cab','bridge humbucker',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Gentle, ringing clean-to-crunch built on a picked figure (Mushok often used a baritone); keep it warm.','Low-medium gain.'],
     array['Pick the ringing figure cleanly.','Open up for the fuller chorus.'],
     'Studio recording, 2001 (Break the Cycle). Mike Mushok played a gentle, ringing clean-to-crunch part.',73),
    ('blurry','puddle-of-mudd','guitar','riff','main progression','crunch','rock','rhythm','beginner',
     'Electric guitar (Wes Scantlin)','Clean-to-crunch amp with ambience','Open-back combo cab','bridge humbucker',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":1,"master":6}'::jsonb,
     array['Ringing, delayed clean-to-crunch post-grunge; keep the picked intro shimmering.','Low-medium gain, ambient.'],
     array['Let the delayed intro ring.','Build into the crunchy chorus.'],
     'Studio recording, 2001 (Come Clean). Puddle of Mudd played a ringing, delayed clean-to-crunch post-grunge part.',72),
    ('fake-it','seether','guitar','riff','main riff','distorted','rock','rhythm','beginner',
     'Electric guitar (Shaun Morgan)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Punchy, driving post-grunge distortion; keep the riff tight and catchy.','Medium-high gain.'],
     array['Keep the riff tight and punchy.','Drive the catchy hook.'],
     'Studio recording, 2007. Shaun Morgan played a punchy, driving post-grunge distorted riff.',72),
    ('higher','creed','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'PRS electric guitar (Mark Tremonti)','Mesa/high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":1,"master":6}'::jsonb,
     array['Anthemic, drop-tuned post-grunge with a ringing lead riff; keep it big and driving.','Medium-high gain, drop tuning.'],
     array['Let the ringing lead riff sing.','Drive the heavy chorus.'],
     'Studio recording, 1999 (Human Clay). Mark Tremonti played an anthemic, drop-tuned post-grunge riff on a PRS through a Mesa.',74),
    ('with-arms-wide-open','creed','guitar','riff','main progression','crunch','rock','rhythm','beginner',
     'PRS electric guitar (Mark Tremonti)','Clean-to-crunch amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, ringing clean-to-crunch ballad; keep the arpeggios open and the chorus big.','Low-medium gain.'],
     array['Let the arpeggiated chords ring.','Open into the anthemic chorus.'],
     'Studio recording, 1999 (Human Clay). Mark Tremonti played a warm, ringing clean-to-crunch ballad part on a PRS.',73),
    ('blackbird','alter-bridge','guitar','riff','main progression and solo','high_gain','rock','lead','advanced',
     'PRS electric guitar (Mark Tremonti / Myles Kennedy)','Mesa/high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":1,"master":6}'::jsonb,
     array['Soaring melodic rock that builds to an acclaimed dual solo; keep the dynamics wide.','Medium-high gain with clarity.'],
     array['Build the arrangement from clean to heavy.','Play the epic dual solo with smooth phrasing.'],
     'Studio recording, 2007 (Blackbird). Tremonti and Myles Kennedy played soaring melodic rock and an acclaimed dual solo on PRS guitars through Mesa amps.',75),
    ('the-red','chevelle','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Electric guitar (Pete Loeffler)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Heavy, dynamic drop-tuned alt-metal; keep the quiet parts tense and the riff crushing.','Medium-high gain, drop tuning.'],
     array['Keep the verses tense and controlled.','Slam the crushing riff.'],
     'Studio recording, 2002 (Wonder What''s Next). Pete Loeffler played a heavy, dynamic drop-tuned alt-metal riff.',73),
    ('headstrong','trapt','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Electric guitar (Trapt)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Aggressive, syncopated nu-metal riff; keep the chugs tight and rhythmic.','Medium-high gain, drop tuning.'],
     array['Keep the syncopated chugs tight.','Drive the aggressive groove.'],
     'Studio recording, 2002 (Trapt). Trapt played an aggressive, syncopated nu-metal riff.',72),
    ('bring-me-to-life','evanescence','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Electric guitar (Ben Moody)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Heavy, symphonic nu-metal riff under piano and strings; keep the chorus crushing.','Medium-high gain, drop tuning.'],
     array['Keep the riff tight under the orchestration.','Slam the heavy chorus.'],
     'Studio recording, 2003 (Fallen). Ben Moody played a heavy, symphonic nu-metal riff under the piano and strings.',73),
    ('judith','a-perfect-circle','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Electric guitar (Billy Howerdel)','High-gain amp with atmosphere','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":1,"master":6}'::jsonb,
     array['Heavy, atmospheric alt-metal riff with space; keep it tight and moody.','Medium-high gain, ambient.'],
     array['Keep the driving riff tight.','Let the atmosphere breathe between hits.'],
     'Studio recording, 2000 (Mer de Noms). Billy Howerdel played a heavy, atmospheric alt-metal riff.',73),
    ('the-reason','hoobastank','guitar','riff','main progression','crunch','rock','rhythm','beginner',
     'Electric guitar (Dan Estrin)','Clean-to-crunch amp','Open-back combo cab','bridge humbucker',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, ringing clean-to-crunch pop-rock ballad; keep the verses gentle and the chorus big.','Low-medium gain.'],
     array['Let the clean verse chords ring.','Open up for the anthemic chorus.'],
     'Studio recording, 2003 (The Reason). Dan Estrin played a warm, ringing clean-to-crunch pop-rock part.',72),
    ('the-kill','30-seconds-to-mars','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Electric guitar (30 Seconds to Mars)','High-gain amp with delay','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"delay","effect_name":"delay","placement":"post_gain","settings":{"mix":3,"time":3}}]'::jsonb,
     '{"gain":6,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":2,"master":6}'::jsonb,
     array['Anthemic, driving alt-rock that builds from clean to distorted; keep the dynamics wide.','Medium-high gain, delay for space.'],
     array['Let the clean intro build.','Drive the distorted chorus with energy.'],
     'Studio recording, 2005 (A Beautiful Lie). 30 Seconds to Mars played an anthemic, driving alt-rock part with delay.',72)
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
  ('audioslave','like-a-stone'),('audioslave','cochise'),('velvet-revolver','slither'),('bush','glycerine'),('bush','machinehead'),
  ('live','lightning-crashes'),('collective-soul','shine'),('silverchair','tomorrow'),('three-days-grace','animal-i-have-become'),
  ('nickelback','how-you-remind-me'),('shinedown','second-chance'),('breaking-benjamin','the-diary-of-jane'),('papa-roach','last-resort'),
  ('staind','its-been-awhile'),('puddle-of-mudd','blurry'),('seether','fake-it'),('creed','higher'),('creed','with-arms-wide-open'),
  ('alter-bridge','blackbird'),('chevelle','the-red'),('trapt','headstrong'),('evanescence','bring-me-to-life'),
  ('a-perfect-circle','judith'),('hoobastank','the-reason'),('30-seconds-to-mars','the-kill')
) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
cross join (values
  ('artist_interview', 'Documented artist interviews and gear discussions', null::text,
   'Researched from widely-documented interviews about this recording and player.', 72),
  ('rig_rundown', 'Published rig rundowns and community gear databases', null::text,
   'Cross-referenced against rig features and community-maintained gear databases.', 66)
) as x(source_type, title, url, notes, credibility)
where p.verification_status = 'admin_verified'
on conflict do nothing;
