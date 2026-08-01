-- Phase 50: 2020s rock revival + indie singer-songwriter, verified per-part tone data.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('The 1975','the-1975','About You','about-you','Being Funny in a Foreign Language',2022),
    ('The 1975','the-1975','Robbers','robbers','The 1975',2013),
    ('Wallows','wallows','Are You Bored Yet?','are-you-bored-yet','Nothing Happens',2019),
    ('Wallows','wallows','Pleaser','pleaser','Spring',2018),
    ('Dayglow','dayglow','Can I Call You Tonight?','can-i-call-you-tonight','Fuzzybrain',2018),
    ('Declan McKenna','declan-mckenna','Brazil','brazil','What Do You Think About the Car?',2017),
    ('Greta Van Fleet','greta-van-fleet','Highway Tune','highway-tune','From the Fires',2017),
    ('Greta Van Fleet','greta-van-fleet','Safari Song','safari-song','From the Fires',2017),
    ('Maneskin','maneskin','Zitti e buoni','zitti-e-buoni','Teatro d''ira: Vol. I',2021),
    ('Olivia Rodrigo','olivia-rodrigo','vampire','vampire','GUTS',2023),
    ('Olivia Rodrigo','olivia-rodrigo','bad idea right?','bad-idea-right','GUTS',2023),
    ('Phoebe Bridgers','phoebe-bridgers','Motion Sickness','motion-sickness','Stranger in the Alps',2017),
    ('Phoebe Bridgers','phoebe-bridgers','Scott Street','scott-street','Stranger in the Alps',2017),
    ('boygenius','boygenius','$20','20','the record',2023),
    ('Big Thief','big-thief','Not','not','Two Hands',2019),
    ('Noah Kahan','noah-kahan','Northern Attitude','northern-attitude','Stick Season',2022),
    ('Noah Kahan','noah-kahan','All My Love','all-my-love','Stick Season',2022),
    ('Sam Fender','sam-fender','Hypersonic Missiles','hypersonic-missiles','Hypersonic Missiles',2019),
    ('Wet Leg','wet-leg','Wet Dream','wet-dream','Wet Leg',2022),
    ('Inhaler','inhaler','My Honest Face','my-honest-face','It Won''t Always Be Like This',2021),
    ('The Last Dinner Party','the-last-dinner-party','The Feminine Urge','the-feminine-urge','Prelude to Ecstasy',2024),
    ('Fontaines D.C.','fontaines-dc','Jackie Down the Line','jackie-down-the-line','Skinty Fia',2022),
    ('Fontaines D.C.','fontaines-dc','Boys in the Better Land','boys-in-the-better-land','Dogrel',2019),
    ('Harry Styles','harry-styles','Golden','golden','Fine Line',2019),
    ('Harry Styles','harry-styles','Watermelon Sugar','watermelon-sugar','Fine Line',2019)
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
    ('the-1975','about-you'),('the-1975','robbers'),('wallows','are-you-bored-yet'),('wallows','pleaser'),
    ('dayglow','can-i-call-you-tonight'),('declan-mckenna','brazil'),('greta-van-fleet','highway-tune'),
    ('greta-van-fleet','safari-song'),('maneskin','zitti-e-buoni'),('olivia-rodrigo','vampire'),
    ('olivia-rodrigo','bad-idea-right'),('phoebe-bridgers','motion-sickness'),('phoebe-bridgers','scott-street'),
    ('boygenius','20'),('big-thief','not'),('noah-kahan','northern-attitude'),('noah-kahan','all-my-love'),
    ('sam-fender','hypersonic-missiles'),('wet-leg','wet-dream'),('inhaler','my-honest-face'),
    ('the-last-dinner-party','the-feminine-urge'),('fontaines-dc','jackie-down-the-line'),
    ('fontaines-dc','boys-in-the-better-land'),('harry-styles','golden'),('harry-styles','watermelon-sugar')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('the-1975','about-you'),('the-1975','robbers'),('wallows','are-you-bored-yet'),('wallows','pleaser'),
    ('dayglow','can-i-call-you-tonight'),('declan-mckenna','brazil'),('greta-van-fleet','highway-tune'),
    ('greta-van-fleet','safari-song'),('maneskin','zitti-e-buoni'),('olivia-rodrigo','vampire'),
    ('olivia-rodrigo','bad-idea-right'),('phoebe-bridgers','motion-sickness'),('phoebe-bridgers','scott-street'),
    ('boygenius','20'),('big-thief','not'),('noah-kahan','northern-attitude'),('noah-kahan','all-my-love'),
    ('sam-fender','hypersonic-missiles'),('wet-leg','wet-dream'),('inhaler','my-honest-face'),
    ('the-last-dinner-party','the-feminine-urge'),('fontaines-dc','jackie-down-the-line'),
    ('fontaines-dc','boys-in-the-better-land'),('harry-styles','golden'),('harry-styles','watermelon-sugar')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('the-1975','about-you'),('the-1975','robbers'),('wallows','are-you-bored-yet'),('wallows','pleaser'),
    ('dayglow','can-i-call-you-tonight'),('declan-mckenna','brazil'),('greta-van-fleet','highway-tune'),
    ('greta-van-fleet','safari-song'),('maneskin','zitti-e-buoni'),('olivia-rodrigo','vampire'),
    ('olivia-rodrigo','bad-idea-right'),('phoebe-bridgers','motion-sickness'),('phoebe-bridgers','scott-street'),
    ('boygenius','20'),('big-thief','not'),('noah-kahan','northern-attitude'),('noah-kahan','all-my-love'),
    ('sam-fender','hypersonic-missiles'),('wet-leg','wet-dream'),('inhaler','my-honest-face'),
    ('the-last-dinner-party','the-feminine-urge'),('fontaines-dc','jackie-down-the-line'),
    ('fontaines-dc','boys-in-the-better-land'),('harry-styles','golden'),('harry-styles','watermelon-sugar')
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
    -- ============ THE 1975 ============
    ('about-you','the-1975','guitar','riff','main wall','crunch','indie rock','rhythm','intermediate',
     'Fender offset electric (Adam Hann)','Driven amp in a shoegaze wash','Open-back cab','bridge pickup',
     '[{"effect_type":"reverb","effect_name":"huge modulated reverb","placement":"post_gain","settings":{"mix":6,"decay":8}},{"effect_type":"delay","effect_name":"ambient delay","placement":"post_gain","settings":{"time":5,"mix":4,"feedback":5}}]'::jsonb,
     '{"gain":4,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":7,"delay":4,"master":6}'::jsonb,
     array['Shoegaze-scale wall — mid-gain guitars dissolved in modulated reverb and delay.','Ambience over articulation; the strings section fills the rest.'],
     array['Slow swells and sustained chords — nothing percussive.','Let the reverb tail be part of the arrangement.'],
     'Studio recording, 2022. Shoegaze wall from the viral closer of Being Funny.',74),
    ('robbers','the-1975','guitar','riff','main riff','crunch','indie rock','rhythm','intermediate',
     'Fender offset electric (Adam Hann)','Tube amp, edge of breakup with ambience','Open-back cab','bridge pickup',
     '[{"effect_type":"reverb","effect_name":"large hall reverb","placement":"post_gain","settings":{"mix":5,"decay":6}},{"effect_type":"delay","effect_name":"dotted-eighth delay","placement":"post_gain","settings":{"time":4,"mix":3,"feedback":3}}]'::jsonb,
     '{"gain":4,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":5,"delay":3,"master":6}'::jsonb,
     array['Cinematic emotional build — chiming ambient crunch that climaxes in a cathartic wall.','Light drive with heavy ambience; the climax gains intensity from playing, not settings.'],
     array['The arpeggiated figures shimmer under the verse.','Hold nothing back in the final chorus.'],
     'Studio recording, 2013. Cinematic ambient build from the debut.',74),

    -- ============ WALLOWS / DAYGLOW / DECLAN MCKENNA ============
    ('are-you-bored-yet','wallows','guitar','riff','main riff','clean','indie rock','rhythm','beginner',
     'Fender electric (Braeden Lemasters / Dylan Minnette)','Clean amp with light chorus','Open-back combo cab','neck pickup',
     '[{"effect_type":"chorus","effect_name":"light chorus","placement":"post_gain","settings":{"rate":3,"depth":3,"mix":3}},{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Soft jangly clean hook — gentle chorus sheen over a lazy melody.','Barely-clean warmth; the vibe is bedroom-casual.'],
     array['The intro hook is simple single notes — make them sing.','Relaxed strums; nothing urgent.'],
     'Studio recording, 2019. Soft jangle hook from Nothing Happens.',73),
    ('pleaser','wallows','guitar','riff','main riff','crunch','indie rock','rhythm','intermediate',
     'Fender electric (Braeden Lemasters)','Tube combo with light drive','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['Driving indie-rock energy — bright light crunch with momentum.','Edge-of-breakup pushed a little harder; keep the jangle.'],
     array['Driving eighth-note strums carry the verse.','The lead break is melodic and quick.'],
     'Studio recording, 2018. Driving bright indie crunch.',72),
    ('can-i-call-you-tonight','dayglow','guitar','riff','main riff','clean','indie pop','rhythm','beginner',
     'Fender Stratocaster (Sloan Struble)','Clean amp with chorus','Open-back combo cab','neck pickup',
     '[{"effect_type":"chorus","effect_name":"prominent chorus","placement":"post_gain","settings":{"rate":4,"depth":5,"mix":5}},{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":2,"bass":4,"mids":5,"treble":7,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Glassy chorused bedroom-pop hook — bright and bouncy.','Clean with strong chorus; the sparkle is the identity.'],
     array['The interlocking clean parts bounce off each other.','Precise, light picking keeps it danceable.'],
     'Studio recording, 2018. Glassy chorus-clean bedroom pop hit.',74),
    ('brazil','declan-mckenna','guitar','riff','main riff','clean','indie rock','rhythm','beginner',
     'Fender electric (Declan McKenna)','Bright clean amp, slight edge','Open-back combo cab','bridge pickup',
     '[{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":3,"bass":4,"mids":5,"treble":7,"presence":6,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Sunny jangle-riff — bright, bouncy, and instantly recognizable.','Just-clean sparkle; dig in slightly for natural edge.'],
     array['The main riff is the song — groove it, don''t rush it.','Muted funk strums connect the phrases.'],
     'Studio recording, 2017. Sunny viral jangle riff.',74),

    -- ============ GRETA VAN FLEET (Jake Kiszka: SG + Marshall) ============
    ('highway-tune','greta-van-fleet','guitar','riff','main riff','crunch','rock','rhythm','intermediate',
     'Gibson SG (Jake Kiszka)','Marshall tube stack cranked','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":6,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['Zeppelin-revival crunch — SG into cranked Marshall, mids pushed hard.','Vintage-style power-tube crunch; no pedals, just volume.'],
     array['The stabbing riff swings — feel the blues under it.','Answer the vocal with quick bluesy fills.'],
     'Studio recording, 2017. Kiszka''s SG-into-Marshall revival crunch.',77),
    ('safari-song','greta-van-fleet','guitar','riff','main riff','crunch','rock','rhythm','intermediate',
     'Gibson SG (Jake Kiszka)','Marshall tube stack cranked','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":6,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['Swaggering blues-rock stomp — same cranked-Marshall recipe.','Warm vintage crunch with bite; the mids do the talking.'],
     array['Heavy blues bends in the riff.','Lock with the drums'' swing, not a straight grid.'],
     'Studio recording, 2017. Swaggering cranked-Marshall stomp.',77),

    -- ============ MANESKIN / OLIVIA RODRIGO ============
    ('zitti-e-buoni','maneskin','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Fender Telecaster (Thomas Raggi)','British tube stack driven','Closed-back 4x12 cab','bridge pickup',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['The Eurovision-winning riff — bright Telecaster grind into a driven British stack.','Cutting single-coil distortion; trebly and aggressive.'],
     array['The staccato main riff drives the whole song.','Tight muting between stabs.'],
     'Studio recording, 2021. Raggi''s cutting Telecaster grind — the Eurovision winner.',75),
    ('vampire','olivia-rodrigo','guitar','riff','climax wall','distorted','pop rock','rhythm','intermediate',
     'Solid-body electric (session)','Driven amp wall (produced)','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['Piano ballad that erupts into a driving rock climax — this profile covers the final-act wall.','Modern produced drive; thick but controlled.'],
     array['Enter with the drums in the final act.','Driving eighths under the vocal runs.'],
     'Studio recording, 2023. The rock climax of the GUTS opener single.',73),
    ('bad-idea-right','olivia-rodrigo','guitar','riff','main riff','crunch','pop rock','rhythm','beginner',
     'Solid-body electric (session)','Driven amp, 90s alt flavor','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['90s alt-rock pastiche — bouncy garage crunch under talk-sung verses.','Medium gain with jangle; think Elastica/Breeders energy.'],
     array['The riff bounces — palm-mute the verses lightly.','Slam the chorus wide open.'],
     'Studio recording, 2023. Bouncy 90s-revival crunch from GUTS.',73),

    -- ============ PHOEBE BRIDGERS / BOYGENIUS / BIG THIEF ============
    ('motion-sickness','phoebe-bridgers','guitar','riff','main riff','crunch','indie rock','rhythm','beginner',
     'Fender offset electric (Phoebe Bridgers)','Tube combo, edge of breakup','Open-back combo cab','bridge pickup',
     '[{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":4,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Chiming melancholy crunch — warm strums with soft edges.','Edge-of-breakup jangle; emotional but restrained.'],
     array['Steady strums carry the song — consistency is the feel.','The lead fills are sparse single notes.'],
     'Studio recording, 2017. Melancholy jangle-crunch from Stranger in the Alps.',74),
    ('scott-street','phoebe-bridgers','guitar','main','main progression','clean','indie folk','rhythm','beginner',
     'Fender offset electric (Phoebe Bridgers)','Warm clean amp','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"soft plate reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":1,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":4,"delay":0,"master":5}'::jsonb,
     array['Hushed intimate clean — barely-touched strings in soft reverb.','Whisper-quiet clean; dynamics stay small.'],
     array['Brush the chords gently; the space between notes matters.','Follow the vocal''s fragile pacing.'],
     'Studio recording, 2017. Hushed intimate clean.',74),
    ('20','boygenius','guitar','riff','main riff','crunch','indie rock','rhythm','intermediate',
     'Electric guitars (Julien Baker / Phoebe Bridgers / Lucy Dacus)','Driven tube combo','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['Urgent driving crunch — raw and insistent under stacked harmonies.','Medium gain with grit; momentum over polish.'],
     array['The driving riff barely pauses — build wrist stamina.','The screamed climax wants maximum energy.'],
     'Studio recording, 2023. Urgent driving crunch from the record.',73),
    ('not','big-thief','guitar','riff','main riff + solo','crunch','indie rock','rhythm','advanced',
     'Electric guitar (Adrianne Lenker / Buck Meek)','Tube combo pushed hard, raw','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['Ragged cathartic crunch — raw, cracking, on the edge of falling apart.','Pushed tube breakup with no polish; the fraying edges are the point.'],
     array['The outro solo is pure catharsis — feel over precision.','Let the amp fight back; don''t tame it.'],
     'Studio recording, 2019. Ragged cathartic crunch from Two Hands.',74),

    -- ============ NOAH KAHAN (acoustic folk) ============
    ('northern-attitude','noah-kahan','guitar','main','main progression','acoustic','folk','rhythm','beginner',
     'Acoustic guitar (Noah Kahan)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Driving folk strumming — bright acoustic with a steady pulse.','Acoustic or piezo; a touch of room ambience.'],
     array['Steady driving strum pattern throughout.','Capo work on the record — check your key.'],
     'Studio recording, 2022. Driving folk strums from Stick Season.',75),
    ('all-my-love','noah-kahan','guitar','main','main progression','acoustic','folk','rhythm','beginner',
     'Acoustic guitar (Noah Kahan)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm upbeat folk picking and strums.','Bright acoustic, light ambience, nothing else.'],
     array['Alternate between fingerpicked verses and strummed choruses.','Keep the bounce light.'],
     'Studio recording, 2022. Warm upbeat folk from Stick Season.',75),

    -- ============ HEARTLAND / POST-PUNK / ART ROCK ============
    ('hypersonic-missiles','sam-fender','guitar','riff','main riff','crunch','heartland rock','rhythm','intermediate',
     'Fender Jazzmaster (Sam Fender)','Tube amp, edge of breakup with ambience','Open-back combo cab','bridge pickup',
     '[{"effect_type":"reverb","effect_name":"large plate reverb","placement":"post_gain","settings":{"mix":4,"decay":5}},{"effect_type":"delay","effect_name":"subtle delay","placement":"post_gain","settings":{"time":3,"mix":2,"feedback":2}}]'::jsonb,
     '{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":4,"delay":2,"master":7}'::jsonb,
     array['Springsteen-lineage heartland jangle — big chiming Jazzmaster chords in wide reverb.','Light crunch with major ambience; anthemic, not aggressive.'],
     array['Wide open chords ring under the verses.','Build relentlessly into the sax-led climax.'],
     'Studio recording, 2019. Fender''s heartland Jazzmaster jangle.',75),
    ('wet-dream','wet-leg','guitar','riff','main riff','crunch','post-punk','rhythm','beginner',
     'Solid-body electric (Rhian Teasdale / Hester Chambers)','Tube amp with tight crunch','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Deadpan post-punk bounce — dry angular crunch.','Bright tight crunch, minimal ambience; the hooks are rhythmic.'],
     array['Staccato riff stabs between vocal lines.','Keep it robotic-tight — the deadpan is the joke.'],
     'Studio recording, 2022. Dry angular post-punk bounce.',73),
    ('my-honest-face','inhaler','guitar','riff','main riff','crunch','indie rock','rhythm','intermediate',
     'Fender Stratocaster (Josh Jenkinson / Elijah Hewson)','British tube amp driven','Open-back 2x12 cab','bridge pickup',
     '[{"effect_type":"delay","effect_name":"slapback delay","placement":"post_gain","settings":{"time":2,"mix":2,"feedback":2}}]'::jsonb,
     '{"gain":5,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":2,"master":7}'::jsonb,
     array['Anthemic driving crunch with U2 DNA (literally).','Bright driven chime; the riff gallops.'],
     array['Driving eighth-note momentum throughout.','The chorus opens up — let the chords ring.'],
     'Studio recording, 2021. Anthemic driving crunch.',73),
    ('the-feminine-urge','the-last-dinner-party','guitar','riff','main riff','crunch','art rock','rhythm','intermediate',
     'Electric guitar (Emily Roberts)','Tube amp, theatrical crunch','Open-back cab','bridge humbucker',
     '[{"effect_type":"reverb","effect_name":"plate reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":0,"master":7}'::jsonb,
     array['Theatrical baroque-rock crunch — dramatic riffs with glam flair.','Warm mid-gain with room; grandeur over grit.'],
     array['The riff struts — play it theatrical.','Dynamics swing wide between verse and chorus.'],
     'Studio recording, 2024. Theatrical baroque-rock from Prelude to Ecstasy.',72),
    ('jackie-down-the-line','fontaines-dc','guitar','riff','main riff','crunch','post-punk','rhythm','intermediate',
     'Fender electric (Carlos O''Connell / Conor Curley)','Tube amp, dark jangle','Open-back cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"dark room reverb","placement":"post_gain","settings":{"mix":4}},{"effect_type":"chorus","effect_name":"subtle chorus","placement":"post_gain","settings":{"rate":3,"depth":3,"mix":3}}]'::jsonb,
     '{"gain":4,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":4,"delay":0,"master":6}'::jsonb,
     array['Gloomy melodic jangle — dark chorused strums with Cure undertones.','Low-gain darkness; roll treble back and let the chorus haunt.'],
     array['Steady melancholy strums under the drawl.','The melodic fills echo the vocal.'],
     'Studio recording, 2022. Gloomy chorused jangle from Skinty Fia.',73),
    ('boys-in-the-better-land','fontaines-dc','guitar','riff','main riff','crunch','post-punk','rhythm','intermediate',
     'Fender electric (Carlos O''Connell / Conor Curley)','Tube amp driven hard','Open-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['Furious garage post-punk drive — bright, urgent, relentless.','Trebly driven jangle at full momentum.'],
     array['Machine-gun downstrokes through the verse.','Don''t let the tempo sag — urgency is the song.'],
     'Studio recording, 2019. Furious garage-punk drive from Dogrel.',73),

    -- ============ HARRY STYLES (Mitch Rowland) ============
    ('golden','harry-styles','guitar','riff','main riff','clean','pop rock','rhythm','beginner',
     'Electric guitar (Mitch Rowland)','Bright clean amp','Open-back combo cab','neck pickup',
     '[{"effect_type":"compressor","effect_name":"light compression","placement":"front","settings":{"sustain":4,"level":5}},{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":7,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Sun-drenched opening jangle — bright shimmering clean.','Sparkling clean with light squeeze; joyous and open.'],
     array['Bouncing arpeggio-strum hybrid pattern.','Play it like driving down a coast road.'],
     'Studio recording, 2019. Sun-drenched clean jangle from Fine Line.',74),
    ('watermelon-sugar','harry-styles','guitar','riff','main riff','clean','pop rock','rhythm','beginner',
     'Electric guitar (Mitch Rowland)','Warm clean amp','Open-back combo cab','neck pickup',
     '[{"effect_type":"compressor","effect_name":"light compression","placement":"front","settings":{"sustain":4,"level":5}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Funky warm clean riff — round, muted, and groovy.','Warm clean with soft compression; the groove is percussive.'],
     array['The muted funk riff drives everything.','Ghost notes between the chords keep it moving.'],
     'Studio recording, 2019. Funky warm clean groove.',74)
) as c(
  song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence
)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;
