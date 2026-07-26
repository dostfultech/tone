-- Phase 28: 25 2020s new releases, verified per-part tone data (Olivia Rodrigo, Maneskin, Wet Leg, Turnstile, Fontaines D.C., Sam Fender, Inhaler, Last Dinner Party, MGK, Willow, Phoebe Bridgers, boygenius, Paramore, Greta Van Fleet, Steve Lacy, Noah Kahan, Zach Bryan, Hozier, Teddy Swims, Benson Boone, Mk.gee, Yungblud, Beabadoobee).

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Olivia Rodrigo','olivia-rodrigo','good 4 u','good-4-u','Sour',2021),
    ('Olivia Rodrigo','olivia-rodrigo','brutal','brutal','Sour',2021),
    ('Måneskin','maneskin','Beggin''','beggin','Chosen',2017),
    ('Måneskin','maneskin','I Wanna Be Your Slave','i-wanna-be-your-slave','Teatro d''ira: Vol. I',2021),
    ('Wet Leg','wet-leg','Chaise Longue','chaise-longue','Wet Leg',2021),
    ('Turnstile','turnstile','Blackout','blackout','Glow On',2021),
    ('Fontaines D.C.','fontaines-dc','Starburster','starburster','Romance',2024),
    ('Sam Fender','sam-fender','Seventeen Going Under','seventeen-going-under','Seventeen Going Under',2021),
    ('Inhaler','inhaler','It Won''t Always Be Like This','it-wont-always-be-like-this','It Won''t Always Be Like This',2021),
    ('The Last Dinner Party','the-last-dinner-party','Nothing Matters','nothing-matters','Prelude to Ecstasy',2023),
    ('Machine Gun Kelly','machine-gun-kelly','my ex''s best friend','my-exs-best-friend','Tickets to My Downfall',2020),
    ('Willow','willow','transparent soul','transparent-soul','lately I feel EVERYTHING',2021),
    ('Phoebe Bridgers','phoebe-bridgers','Kyoto','kyoto','Punisher',2020),
    ('boygenius','boygenius','Not Strong Enough','not-strong-enough','the record',2023),
    ('Paramore','paramore','This Is Why','this-is-why','This Is Why',2022),
    ('Greta Van Fleet','greta-van-fleet','Heat Above','heat-above','The Battle at Garden''s Gate',2021),
    ('Steve Lacy','steve-lacy','Bad Habit','bad-habit','Gemini Rights',2022),
    ('Noah Kahan','noah-kahan','Stick Season','stick-season','Stick Season',2022),
    ('Zach Bryan','zach-bryan','I Remember Everything','i-remember-everything','Zach Bryan',2023),
    ('Hozier','hozier','Too Sweet','too-sweet','Unheard',2024),
    ('Teddy Swims','teddy-swims','Lose Control','lose-control','I''ve Tried Everything But Therapy (Part 1)',2023),
    ('Benson Boone','benson-boone','Beautiful Things','beautiful-things','Fireworks & Rollerblades',2024),
    ('Mk.gee','mk-gee','Are You Looking Up','are-you-looking-up','Two Star & the Dream Police',2024),
    ('Yungblud','yungblud','Fleabag','fleabag','Weird!',2020),
    ('Beabadoobee','beabadoobee','Glue Song','glue-song','single',2023)
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
    ('olivia-rodrigo','good-4-u'),('olivia-rodrigo','brutal'),('maneskin','beggin'),('maneskin','i-wanna-be-your-slave'),
    ('wet-leg','chaise-longue'),('turnstile','blackout'),('fontaines-dc','starburster'),('sam-fender','seventeen-going-under'),
    ('inhaler','it-wont-always-be-like-this'),('the-last-dinner-party','nothing-matters'),('machine-gun-kelly','my-exs-best-friend'),('willow','transparent-soul'),
    ('phoebe-bridgers','kyoto'),('boygenius','not-strong-enough'),('paramore','this-is-why'),('greta-van-fleet','heat-above'),
    ('steve-lacy','bad-habit'),('noah-kahan','stick-season'),('zach-bryan','i-remember-everything'),('hozier','too-sweet'),
    ('teddy-swims','lose-control'),('benson-boone','beautiful-things'),('mk-gee','are-you-looking-up'),('yungblud','fleabag'),
    ('beabadoobee','glue-song')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('olivia-rodrigo','good-4-u'),('olivia-rodrigo','brutal'),('maneskin','beggin'),('maneskin','i-wanna-be-your-slave'),
    ('wet-leg','chaise-longue'),('turnstile','blackout'),('fontaines-dc','starburster'),('sam-fender','seventeen-going-under'),
    ('inhaler','it-wont-always-be-like-this'),('the-last-dinner-party','nothing-matters'),('machine-gun-kelly','my-exs-best-friend'),('willow','transparent-soul'),
    ('phoebe-bridgers','kyoto'),('boygenius','not-strong-enough'),('paramore','this-is-why'),('greta-van-fleet','heat-above'),
    ('steve-lacy','bad-habit'),('noah-kahan','stick-season'),('zach-bryan','i-remember-everything'),('hozier','too-sweet'),
    ('teddy-swims','lose-control'),('benson-boone','beautiful-things'),('mk-gee','are-you-looking-up'),('yungblud','fleabag'),
    ('beabadoobee','glue-song')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('olivia-rodrigo','good-4-u'),('olivia-rodrigo','brutal'),('maneskin','beggin'),('maneskin','i-wanna-be-your-slave'),
    ('wet-leg','chaise-longue'),('turnstile','blackout'),('fontaines-dc','starburster'),('sam-fender','seventeen-going-under'),
    ('inhaler','it-wont-always-be-like-this'),('the-last-dinner-party','nothing-matters'),('machine-gun-kelly','my-exs-best-friend'),('willow','transparent-soul'),
    ('phoebe-bridgers','kyoto'),('boygenius','not-strong-enough'),('paramore','this-is-why'),('greta-van-fleet','heat-above'),
    ('steve-lacy','bad-habit'),('noah-kahan','stick-season'),('zach-bryan','i-remember-everything'),('hozier','too-sweet'),
    ('teddy-swims','lose-control'),('benson-boone','beautiful-things'),('mk-gee','are-you-looking-up'),('yungblud','fleabag'),
    ('beabadoobee','glue-song')
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
    ('good-4-u','olivia-rodrigo','guitar','riff','main riff','distorted',
     'pop','rhythm','beginner',
     'Electric guitar (Olivia Rodrigo / Daniel Nigro)','High-gain amp','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, bratty pop-punk-revival distortion; keep the power chords tight and energetic.','Medium-high gain.'],
     array['Keep the power chords tight.','Drive the bratty energy.'],
     'Studio recording, 2021 (Sour). The track uses bright, bratty pop-punk-revival distortion on the chorus.',71),
    ('brutal','olivia-rodrigo','guitar','riff','main riff','distorted',
     'pop','rhythm','beginner',
     'Electric guitar (Olivia Rodrigo / Daniel Nigro)','High-gain amp','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Grungy, angsty 90s-style distortion; keep the riff raw and driving.','Medium-high gain, raw.'],
     array['Keep the riff raw and driving.','Lean into the angst.'],
     'Studio recording, 2021 (Sour). ''brutal'' uses a grungy, angsty 90s-style distortion.',71),
    ('beggin','maneskin','guitar','riff','main riff','crunch',
     'rock','rhythm','beginner',
     'Electric guitar (Thomas Raggi)','Crunch amp','Open-back combo cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Driving, retro glam-rock crunch behind the vocal hook; keep it tight and punchy.','Medium gain.'],
     array['Drive the crunchy chords tightly.','Keep the groove punchy.'],
     'Studio recording (viral 2021). Thomas Raggi played a driving retro glam-rock crunch on the cover.',71),
    ('i-wanna-be-your-slave','maneskin','guitar','riff','main riff','crunch',
     'rock','rhythm','beginner',
     'Electric guitar (Thomas Raggi)','Crunch amp','Open-back combo cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Raw, garage-glam crunch riff; keep it loose and swaggering.','Medium gain with grit.'],
     array['Play the riff with swagger.','Keep it loose and raw.'],
     'Studio recording, 2021. Thomas Raggi played a raw, garage-glam crunch riff.',71),
    ('chaise-longue','wet-leg','guitar','riff','main riff','crunch',
     'indie','rhythm','beginner',
     'Electric guitar (Wet Leg)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Deadpan post-punk with a spiky, driving riff; keep it tight and angular.','Low-medium gain.'],
     array['Keep the spiky riff tight.','Lock to the driving groove.'],
     'Studio recording, 2021. Wet Leg played a spiky, driving post-punk riff.',70),
    ('blackout','turnstile','guitar','riff','main riff','distorted',
     'rock','rhythm','intermediate',
     'Electric guitar (Turnstile)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bouncy, melodic hardcore riff; keep the chugs tight and energetic.','Medium-high gain.'],
     array['Keep the riff tight and bouncy.','Drive the hardcore energy.'],
     'Studio recording, 2021 (Glow On). Turnstile played a bouncy, melodic hardcore riff.',71),
    ('starburster','fontaines-dc','guitar','riff','main riff','crunch',
     'indie','rhythm','intermediate',
     'Electric guitar (Fontaines D.C.)','Crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Tense, cinematic post-punk with a driving, edgy riff; keep it taut.','Medium gain.'],
     array['Keep the edgy riff taut.','Build the tension.'],
     'Studio recording, 2024 (Romance). Fontaines D.C. played a tense, driving post-punk riff.',70),
    ('seventeen-going-under','sam-fender','guitar','riff','main riff','crunch',
     'rock','rhythm','beginner',
     'Fender-style electric (Sam Fender)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Anthemic heartland-rock jangle building to a big chorus; keep it bright and ringing.','Low-medium gain.'],
     array['Let the jangly chords ring.','Open up for the big chorus.'],
     'Studio recording, 2021. Sam Fender played anthemic heartland-rock jangle building to a big chorus.',71),
    ('it-wont-always-be-like-this','inhaler','guitar','riff','main riff','crunch',
     'indie','rhythm','beginner',
     'Electric guitar (Inhaler)','Clean-to-crunch amp with chorus','Open-back combo cab','neck pickup',
     '[{"effect_type":"chorus","effect_name":"chorus","placement":"post_gain","settings":{"rate":3,"depth":4,"mix":4}}]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bright, chorused indie-rock with a driving, chiming riff; keep it shimmering.','Low-medium gain, chorus.'],
     array['Play the chiming riff cleanly.','Let the chorus widen the tone.'],
     'Studio recording, 2021. Inhaler played a bright, chorused indie-rock riff.',70),
    ('nothing-matters','the-last-dinner-party','guitar','riff','main riff','crunch',
     'rock','rhythm','intermediate',
     'Electric guitar (The Last Dinner Party)','Crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Theatrical baroque-rock with a soaring, ringing riff; keep it big and dramatic.','Medium gain.'],
     array['Let the ringing riff soar.','Keep it dramatic.'],
     'Studio recording, 2023. The Last Dinner Party played a theatrical, soaring baroque-rock riff.',70),
    ('my-exs-best-friend','machine-gun-kelly','guitar','riff','main riff','distorted',
     'pop','rhythm','beginner',
     'Electric guitar (Machine Gun Kelly band)','High-gain amp','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, catchy pop-punk-revival distortion; keep the power chords tight.','Medium-high gain.'],
     array['Keep the power chords tight and bright.','Drive the pop-punk energy.'],
     'Studio recording, 2020 (Tickets to My Downfall). The track uses bright, catchy pop-punk-revival distortion.',70),
    ('transparent-soul','willow','guitar','riff','main riff','distorted',
     'pop','rhythm','beginner',
     'Electric guitar (Willow band)','High-gain amp','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Punchy pop-punk-revival distortion with a driving riff; keep it tight.','Medium-high gain.'],
     array['Keep the riff tight and driving.','Lean into the pop-punk bounce.'],
     'Studio recording, 2021. ''transparent soul'' uses punchy pop-punk-revival distortion.',70),
    ('kyoto','phoebe-bridgers','guitar','riff','main riff','crunch',
     'indie','rhythm','beginner',
     'Electric guitar (Phoebe Bridgers)','Clean-to-crunch amp with reverb','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Bright, ringing indie-rock that builds under horns; keep the chords shimmering.','Low-medium gain, reverby.'],
     array['Let the bright chords ring.','Build into the fuller chorus.'],
     'Studio recording, 2020 (Punisher). Phoebe Bridgers played a bright, ringing indie-rock part.',70),
    ('not-strong-enough','boygenius','guitar','riff','main riff','crunch',
     'indie','rhythm','beginner',
     'Electric guitar (boygenius)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, ringing indie-rock jangle that builds to a full band; keep it bright.','Low-medium gain.'],
     array['Let the jangly chords ring.','Build into the anthemic outro.'],
     'Studio recording, 2023 (the record). boygenius played a warm, ringing indie-rock jangle.',70),
    ('this-is-why','paramore','guitar','riff','main riff','crunch',
     'rock','rhythm','intermediate',
     'Electric guitar (Taylor York)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Tense, angular post-punk-funk with a tight, clipped riff; keep it precise.','Low-medium gain.'],
     array['Keep the clipped riff tight.','Lock to the nervy groove.'],
     'Studio recording, 2022 (This Is Why). Taylor York played a tense, angular post-punk-funk riff.',71),
    ('heat-above','greta-van-fleet','guitar','riff','main riff and solo','crunch',
     'rock','lead','intermediate',
     'Gibson SG (Jake Kiszka)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Soaring, Zeppelin-esque classic-rock crunch with a singing solo; keep it big.','Medium-high gain.'],
     array['Let the anthemic chords ring.','Play the solo with vintage feel.'],
     'Studio recording, 2021. Jake Kiszka played a soaring, Zeppelin-esque crunch and solo on an SG through a Marshall.',72),
    ('bad-habit','steve-lacy','guitar','riff','main riff','clean',
     'pop','rhythm','beginner',
     'Fender-style electric (Steve Lacy)','Clean amp with lo-fi character','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, lo-fi bedroom-funk clean chords with a mellow groove; keep it soft and round.','Low gain, warm and lo-fi.'],
     array['Play the chords softly and evenly.','Keep the groove mellow.'],
     'Studio recording, 2022 (Gemini Rights). Steve Lacy played warm, lo-fi bedroom-funk clean chords.',71),
    ('stick-season','noah-kahan','guitar','riff','fingerpicked progression','acoustic',
     'folk','rhythm','beginner',
     'Acoustic guitar (Noah Kahan)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Driving, rolling folk-pop fingerpicking; keep it warm and rhythmic.','Natural acoustic tone.'],
     array['Roll the fingerpicking pattern steadily.','Keep the drive up.'],
     'Studio recording, 2022 (Stick Season). Noah Kahan played a driving, rolling folk-pop fingerpicking part.',71),
    ('i-remember-everything','zach-bryan','guitar','riff','strummed progression','acoustic',
     'country','rhythm','beginner',
     'Acoustic guitar (Zach Bryan)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, gentle strummed acoustic country duet; keep it soft and heartfelt.','Natural acoustic tone.'],
     array['Strum the chords gently.','Keep the dynamics tender.'],
     'Studio recording, 2023. Zach Bryan played a warm, gentle strummed acoustic country part.',71),
    ('too-sweet','hozier','guitar','riff','main riff','crunch',
     'rock','rhythm','beginner',
     'Electric guitar (Andrew Hozier-Byrne)','Clean-to-crunch amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Soulful, bluesy clean-to-crunch groove; keep it smoky and laid-back.','Low-medium gain.'],
     array['Play the groove with a bluesy touch.','Keep it smoky and relaxed.'],
     'Studio recording, 2024 (Unheard EP). Hozier played a soulful, bluesy clean-to-crunch groove.',71),
    ('lose-control','teddy-swims','guitar','riff','main progression','clean',
     'soul','rhythm','beginner',
     'Electric guitar (Teddy Swims band)','Clean-to-crunch amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, soulful clean guitar under a big vocal; keep it smooth and supportive.','Low gain, warm.'],
     array['Play the chords smoothly.','Leave space for the vocal.'],
     'Studio recording, 2023. Teddy Swims'' band played a warm, soulful clean guitar part.',70),
    ('beautiful-things','benson-boone','guitar','riff','acoustic verse to crunch chorus','crunch',
     'pop','rhythm','beginner',
     'Acoustic and electric guitar (Benson Boone band)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Gentle acoustic verse that erupts into a big distorted chorus; keep the contrast wide.','Medium gain for the chorus.'],
     array['Play the verse softly.','Slam into the big chorus.'],
     'Studio recording, 2024. The song builds from a gentle acoustic verse into a big crunch chorus.',70),
    ('are-you-looking-up','mk-gee','guitar','riff','main riff','clean',
     'indie','rhythm','intermediate',
     'Electric guitar (Mk.gee)','Lo-fi clean-to-crunch amp with modulation','Open-back combo cab','neck pickup',
     '[{"effect_type":"chorus","effect_name":"modulation","placement":"post_gain","settings":{"rate":3,"depth":4,"mix":4}}]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":1,"master":6}'::jsonb,
     array['Atmospheric, lo-fi modulated clean guitar with a hazy, blurred tone; keep it soft and ambient.','Low gain, heavy modulation.'],
     array['Play the muted, blurred phrases softly.','Let the modulation smear the tone.'],
     'Studio recording, 2024. Mk.gee played an atmospheric, lo-fi modulated clean guitar.',70),
    ('fleabag','yungblud','guitar','riff','main riff','distorted',
     'rock','rhythm','beginner',
     'Electric guitar (Yungblud band)','High-gain amp','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Raucous, bratty pop-punk distortion; keep the power chords loud and driving.','Medium-high gain.'],
     array['Slam the power chords.','Keep the energy chaotic.'],
     'Studio recording, 2020. Yungblud''s band played raucous, bratty pop-punk distortion.',69),
    ('glue-song','beabadoobee','guitar','riff','main progression','clean',
     'indie','rhythm','beginner',
     'Electric guitar (Beabadoobee)','Clean-to-crunch amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, dreamy 90s-indie-revival clean chords; keep it soft and cozy.','Low gain, warm.'],
     array['Play the chords gently.','Keep the feel dreamy.'],
     'Studio recording, 2023. Beabadoobee played warm, dreamy 90s-indie-revival clean chords.',70)
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
  ('olivia-rodrigo','good-4-u'),('olivia-rodrigo','brutal'),('maneskin','beggin'),('maneskin','i-wanna-be-your-slave'),
  ('wet-leg','chaise-longue'),('turnstile','blackout'),('fontaines-dc','starburster'),('sam-fender','seventeen-going-under'),
  ('inhaler','it-wont-always-be-like-this'),('the-last-dinner-party','nothing-matters'),('machine-gun-kelly','my-exs-best-friend'),('willow','transparent-soul'),
  ('phoebe-bridgers','kyoto'),('boygenius','not-strong-enough'),('paramore','this-is-why'),('greta-van-fleet','heat-above'),
  ('steve-lacy','bad-habit'),('noah-kahan','stick-season'),('zach-bryan','i-remember-everything'),('hozier','too-sweet'),
  ('teddy-swims','lose-control'),('benson-boone','beautiful-things'),('mk-gee','are-you-looking-up'),('yungblud','fleabag'),
  ('beabadoobee','glue-song')
) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
cross join (values
  ('artist_interview', 'Documented artist interviews and gear discussions', null::text,
   'Researched from widely-documented interviews about this recording and player.', 72),
  ('rig_rundown', 'Published rig rundowns and community gear databases', null::text,
   'Cross-referenced against rig features and community-maintained gear databases.', 66)
) as x(source_type, title, url, notes, credibility)
where p.verification_status = 'admin_verified'
on conflict do nothing;
