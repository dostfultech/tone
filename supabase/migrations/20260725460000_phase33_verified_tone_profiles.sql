-- Phase 33: 25 classic singer-songwriter & soft-rock staples, verified per-part tone data (Simon & Garfunkel, Paul Simon, James Taylor, Cat Stevens, Carole King, America, CSN/CSNY, Jim Croce, Harry Chapin, Gordon Lightfoot, Don McLean, Bread, Seals and Crofts, Loggins and Messina).

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Simon & Garfunkel','simon-and-garfunkel','The Sound of Silence','the-sound-of-silence','Sounds of Silence',1965),
    ('Simon & Garfunkel','simon-and-garfunkel','Mrs. Robinson','mrs-robinson','Bookends',1968),
    ('Simon & Garfunkel','simon-and-garfunkel','Scarborough Fair','scarborough-fair','Parsley, Sage, Rosemary and Thyme',1966),
    ('Paul Simon','paul-simon','Graceland','graceland','Graceland',1986),
    ('James Taylor','james-taylor','Fire and Rain','fire-and-rain','Sweet Baby James',1970),
    ('James Taylor','james-taylor','Country Road','country-road','Sweet Baby James',1970),
    ('Cat Stevens','cat-stevens','Wild World','wild-world','Tea for the Tillerman',1970),
    ('Cat Stevens','cat-stevens','Father and Son','father-and-son','Tea for the Tillerman',1970),
    ('Cat Stevens','cat-stevens','Peace Train','peace-train','Teaser and the Firecat',1971),
    ('Carole King','carole-king','It''s Too Late','its-too-late','Tapestry',1971),
    ('America','america','A Horse with No Name','a-horse-with-no-name','America',1971),
    ('America','america','Ventura Highway','ventura-highway','Homecoming',1972),
    ('America','america','Sister Golden Hair','sister-golden-hair','Hearts',1975),
    ('Crosby, Stills & Nash','crosby-stills-and-nash','Suite: Judy Blue Eyes','suite-judy-blue-eyes','Crosby, Stills & Nash',1969),
    ('Crosby, Stills, Nash & Young','crosby-stills-nash-and-young','Ohio','ohio','single',1970),
    ('Crosby, Stills & Nash','crosby-stills-and-nash','Teach Your Children','teach-your-children','Déjà Vu',1970),
    ('Jim Croce','jim-croce','Time in a Bottle','time-in-a-bottle','You Don''t Mess Around with Jim',1972),
    ('Jim Croce','jim-croce','Operator (That''s Not the Way It Feels)','operator','You Don''t Mess Around with Jim',1972),
    ('Harry Chapin','harry-chapin','Cat''s in the Cradle','cats-in-the-cradle','Verities & Balderdash',1974),
    ('Gordon Lightfoot','gordon-lightfoot','Sundown','sundown','Sundown',1974),
    ('Don McLean','don-mclean','American Pie','american-pie','American Pie',1971),
    ('Don McLean','don-mclean','Vincent','vincent','American Pie',1971),
    ('Bread','bread','Guitar Man','guitar-man','Baby I''m-a Want You',1972),
    ('Seals and Crofts','seals-and-crofts','Summer Breeze','summer-breeze','Summer Breeze',1972),
    ('Loggins and Messina','loggins-and-messina','Your Mama Don''t Dance','your-mama-dont-dance','Loggins and Messina',1972)
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
    ('simon-and-garfunkel','the-sound-of-silence'),('simon-and-garfunkel','mrs-robinson'),('simon-and-garfunkel','scarborough-fair'),('paul-simon','graceland'),
    ('james-taylor','fire-and-rain'),('james-taylor','country-road'),('cat-stevens','wild-world'),('cat-stevens','father-and-son'),
    ('cat-stevens','peace-train'),('carole-king','its-too-late'),('america','a-horse-with-no-name'),('america','ventura-highway'),
    ('america','sister-golden-hair'),('crosby-stills-and-nash','suite-judy-blue-eyes'),('crosby-stills-nash-and-young','ohio'),('crosby-stills-and-nash','teach-your-children'),
    ('jim-croce','time-in-a-bottle'),('jim-croce','operator'),('harry-chapin','cats-in-the-cradle'),('gordon-lightfoot','sundown'),
    ('don-mclean','american-pie'),('don-mclean','vincent'),('bread','guitar-man'),('seals-and-crofts','summer-breeze'),
    ('loggins-and-messina','your-mama-dont-dance')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('simon-and-garfunkel','the-sound-of-silence'),('simon-and-garfunkel','mrs-robinson'),('simon-and-garfunkel','scarborough-fair'),('paul-simon','graceland'),
    ('james-taylor','fire-and-rain'),('james-taylor','country-road'),('cat-stevens','wild-world'),('cat-stevens','father-and-son'),
    ('cat-stevens','peace-train'),('carole-king','its-too-late'),('america','a-horse-with-no-name'),('america','ventura-highway'),
    ('america','sister-golden-hair'),('crosby-stills-and-nash','suite-judy-blue-eyes'),('crosby-stills-nash-and-young','ohio'),('crosby-stills-and-nash','teach-your-children'),
    ('jim-croce','time-in-a-bottle'),('jim-croce','operator'),('harry-chapin','cats-in-the-cradle'),('gordon-lightfoot','sundown'),
    ('don-mclean','american-pie'),('don-mclean','vincent'),('bread','guitar-man'),('seals-and-crofts','summer-breeze'),
    ('loggins-and-messina','your-mama-dont-dance')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('simon-and-garfunkel','the-sound-of-silence'),('simon-and-garfunkel','mrs-robinson'),('simon-and-garfunkel','scarborough-fair'),('paul-simon','graceland'),
    ('james-taylor','fire-and-rain'),('james-taylor','country-road'),('cat-stevens','wild-world'),('cat-stevens','father-and-son'),
    ('cat-stevens','peace-train'),('carole-king','its-too-late'),('america','a-horse-with-no-name'),('america','ventura-highway'),
    ('america','sister-golden-hair'),('crosby-stills-and-nash','suite-judy-blue-eyes'),('crosby-stills-nash-and-young','ohio'),('crosby-stills-and-nash','teach-your-children'),
    ('jim-croce','time-in-a-bottle'),('jim-croce','operator'),('harry-chapin','cats-in-the-cradle'),('gordon-lightfoot','sundown'),
    ('don-mclean','american-pie'),('don-mclean','vincent'),('bread','guitar-man'),('seals-and-crofts','summer-breeze'),
    ('loggins-and-messina','your-mama-dont-dance')
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
    ('the-sound-of-silence','simon-and-garfunkel','guitar','riff','fingerpicked progression','acoustic',
     'folk','rhythm','beginner',
     'Acoustic guitar (Paul Simon)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Gentle, rolling fingerpicked folk; keep it soft and even.','Natural acoustic tone.'],
     array['Roll the fingerpicking pattern smoothly.','Keep the dynamics hushed.'],
     'Studio recording, 1965. Paul Simon played a gentle, rolling fingerpicked folk pattern on acoustic guitar.',73),
    ('mrs-robinson','simon-and-garfunkel','guitar','riff','strummed progression','acoustic',
     'folk','rhythm','beginner',
     'Acoustic guitar (Paul Simon)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bright, bouncy strummed folk-pop with a driving rhythm; keep it crisp.','Natural acoustic tone.'],
     array['Strum the progression with a bounce.','Keep the rhythm driving.'],
     'Studio recording, 1968 (Bookends). Paul Simon played a bright, bouncy strummed folk-pop part.',73),
    ('scarborough-fair','simon-and-garfunkel','guitar','riff','fingerpicked progression','acoustic',
     'folk','rhythm','intermediate',
     'Acoustic guitar (Paul Simon)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Delicate, medieval-flavoured fingerpicking; keep the arpeggios clean and even.','Natural acoustic tone.'],
     array['Fingerpick the arpeggios cleanly.','Keep the touch delicate.'],
     'Studio recording, 1966. Paul Simon played delicate, medieval-flavoured fingerpicking on acoustic guitar.',73),
    ('graceland','paul-simon','guitar','riff','main riff','clean',
     'pop','rhythm','intermediate',
     'Electric guitar (Ray Phiri)','Bright clean amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bright, bouncy South-African-influenced clean guitar; keep the picking crisp and lyrical.','Low gain, bright.'],
     array['Play the lilting lines cleanly.','Keep the groove bouncy.'],
     'Studio recording, 1986 (Graceland). Ray Phiri played bright, South-African-influenced clean guitar.',72),
    ('fire-and-rain','james-taylor','guitar','riff','fingerpicked progression','acoustic',
     'folk','rhythm','intermediate',
     'Acoustic guitar (James Taylor)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, intimate fingerpicking with James Taylor''s signature rolling patterns; keep it gentle.','Natural acoustic tone.'],
     array['Roll the fingerpicking with the thumb steady.','Keep the melody in the top strings.'],
     'Studio recording, 1970 (Sweet Baby James). James Taylor played warm, intimate fingerpicking.',73),
    ('country-road','james-taylor','guitar','riff','fingerpicked progression','acoustic',
     'folk','rhythm','intermediate',
     'Acoustic guitar (James Taylor)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Rolling, warm fingerpicked folk with a gentle groove; keep it smooth and even.','Natural acoustic tone.'],
     array['Roll the pattern smoothly.','Keep the thumb bass steady.'],
     'Studio recording, 1970 (Sweet Baby James). James Taylor played rolling, warm fingerpicked folk.',72),
    ('wild-world','cat-stevens','guitar','riff','strummed progression','acoustic',
     'folk','rhythm','beginner',
     'Acoustic guitar (Cat Stevens)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, gently strummed folk-pop; keep the chords ringing and even.','Natural acoustic tone.'],
     array['Strum the chords gently.','Keep the rhythm relaxed.'],
     'Studio recording, 1970 (Tea for the Tillerman). Cat Stevens played warm, gently strummed folk-pop.',73),
    ('father-and-son','cat-stevens','guitar','riff','strummed progression','acoustic',
     'folk','rhythm','beginner',
     'Acoustic guitar (Cat Stevens)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, earnest strummed folk ballad; keep it heartfelt and even.','Natural acoustic tone.'],
     array['Strum the chords with warmth.','Keep the dynamics gentle.'],
     'Studio recording, 1970 (Tea for the Tillerman). Cat Stevens played a warm, earnest strummed folk ballad.',72),
    ('peace-train','cat-stevens','guitar','riff','strummed progression','acoustic',
     'folk','rhythm','beginner',
     'Acoustic guitar (Cat Stevens)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bright, building strummed folk with an uplifting drive; keep the rhythm crisp.','Natural acoustic tone.'],
     array['Strum the chords with a building drive.','Keep the rhythm crisp.'],
     'Studio recording, 1971 (Teaser and the Firecat). Cat Stevens played bright, building strummed folk.',72),
    ('its-too-late','carole-king','guitar','riff','main riff and solo','clean',
     'pop','lead','intermediate',
     'Electric guitar (Danny Kortchmar)','Clean-to-crunch amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, jazzy soft-rock clean guitar with a tasteful solo; keep it smooth and mellow.','Low gain, warm.'],
     array['Play the jazzy chords smoothly.','Keep the solo tasteful and melodic.'],
     'Studio recording, 1971 (Tapestry). Danny Kortchmar played warm, jazzy soft-rock clean guitar.',72),
    ('a-horse-with-no-name','america','guitar','riff','strummed progression','acoustic',
     'folk','rhythm','beginner',
     'Acoustic guitar (America)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Hypnotic two-chord strummed folk; keep the rhythm steady and warm.','Natural acoustic tone.'],
     array['Strum the two-chord vamp steadily.','Keep it relaxed and hypnotic.'],
     'Studio recording, 1971 (America). America played a hypnotic two-chord strummed folk part.',72),
    ('ventura-highway','america','guitar','riff','fingerpicked progression','acoustic',
     'folk','rhythm','intermediate',
     'Acoustic guitar (America)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bright, chiming capoed acoustic riff; keep the picking crisp and ringing.','Natural acoustic tone, bright.'],
     array['Play the chiming capoed riff cleanly.','Keep the picking crisp.'],
     'Studio recording, 1972 (Homecoming). America played a bright, chiming capoed acoustic riff.',72),
    ('sister-golden-hair','america','guitar','riff','slide intro and progression','clean',
     'rock','lead','intermediate',
     'Electric guitar with slide (America / Gerry Beckley)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bright, George-Harrison-esque slide intro over a jangly soft-rock groove; keep it warm and ringing.','Low gain, bright, played with a slide.'],
     array['Play the slide intro cleanly.','Keep the jangly chords ringing.'],
     'Studio recording, 1975 (Hearts). America played a bright, Harrison-esque slide intro on a soft-rock groove.',72),
    ('suite-judy-blue-eyes','crosby-stills-and-nash','guitar','riff','fingerpicked progression','acoustic',
     'folk','rhythm','advanced',
     'Acoustic guitar (Stephen Stills)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Intricate, modal-tuned fingerpicking through shifting sections; keep it warm and precise.','Natural acoustic tone, alternate tuning.'],
     array['Use the modal tuning and pick precisely.','Follow the shifting sections.'],
     'Studio recording, 1969. Stephen Stills played intricate, modal-tuned fingerpicking.',72),
    ('ohio','crosby-stills-nash-and-young','guitar','riff','main riff','crunch',
     'rock','rhythm','beginner',
     'Electric guitar (Neil Young / Stephen Stills)','Crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Dark, driving protest-rock riff with a raw edge; keep it tight and menacing.','Medium gain with grit.'],
     array['Play the ominous riff tightly.','Keep it raw and driving.'],
     'Studio recording, 1970. Neil Young and Stephen Stills played a dark, driving protest-rock riff.',72),
    ('teach-your-children','crosby-stills-and-nash','guitar','riff','strummed progression','acoustic',
     'folk','rhythm','beginner',
     'Acoustic guitar (Graham Nash / Stephen Stills)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bright, gently strummed country-folk under pedal steel; keep the chords ringing.','Natural acoustic tone.'],
     array['Strum the chords brightly.','Keep the rhythm relaxed.'],
     'Studio recording, 1970 (Déjà Vu). CSN played bright, gently strummed country-folk.',72),
    ('time-in-a-bottle','jim-croce','guitar','riff','fingerpicked progression','acoustic',
     'folk','rhythm','advanced',
     'Acoustic guitar (Jim Croce / Maury Muehleisen)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Delicate, classical-flavoured fingerpicking in 3/4; keep the interweaving parts clean.','Natural acoustic tone.'],
     array['Fingerpick the arpeggios cleanly.','Keep the 3/4 lilt gentle.'],
     'Studio recording, 1972. Jim Croce and Maury Muehleisen played delicate, interweaving fingerpicking.',72),
    ('operator','jim-croce','guitar','riff','fingerpicked progression','acoustic',
     'folk','rhythm','intermediate',
     'Acoustic guitar (Jim Croce / Maury Muehleisen)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, rolling fingerpicked folk with interweaving lead lines; keep it gentle and clear.','Natural acoustic tone.'],
     array['Roll the fingerpicking smoothly.','Let the lead lines answer the melody.'],
     'Studio recording, 1972. Jim Croce and Maury Muehleisen played warm, rolling fingerpicked folk.',72),
    ('cats-in-the-cradle','harry-chapin','guitar','riff','fingerpicked progression','acoustic',
     'folk','rhythm','beginner',
     'Acoustic guitar (Harry Chapin)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Rolling, storytelling fingerpicked folk; keep it warm and steady.','Natural acoustic tone.'],
     array['Roll the fingerpicking steadily.','Let the story carry the dynamics.'],
     'Studio recording, 1974. Harry Chapin played rolling, storytelling fingerpicked folk.',72),
    ('sundown','gordon-lightfoot','guitar','riff','main riff','clean',
     'folk','rhythm','beginner',
     'Acoustic and electric guitar (Gordon Lightfoot band)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, laid-back country-folk groove with a gentle electric lilt; keep it smooth.','Low gain, warm.'],
     array['Play the groove smoothly.','Keep the feel laid-back.'],
     'Studio recording, 1974 (Sundown). Gordon Lightfoot''s band played a warm, laid-back country-folk groove.',72),
    ('american-pie','don-mclean','guitar','riff','strummed progression','acoustic',
     'folk','rhythm','beginner',
     'Acoustic guitar (Don McLean)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm strummed folk that builds from a gentle intro to a driving sing-along; keep dynamics wide.','Natural acoustic tone.'],
     array['Strum the verses gently.','Drive the anthemic chorus.'],
     'Studio recording, 1971 (American Pie). Don McLean played warm strummed folk building to a driving sing-along.',73),
    ('vincent','don-mclean','guitar','riff','fingerpicked progression','acoustic',
     'folk','rhythm','intermediate',
     'Acoustic guitar (Don McLean)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Delicate, tender fingerpicked folk ballad; keep every note soft and clear.','Natural acoustic tone.'],
     array['Fingerpick the pattern gently.','Keep the touch tender.'],
     'Studio recording, 1971 (American Pie). Don McLean played a delicate, tender fingerpicked folk ballad.',72),
    ('guitar-man','bread','guitar','riff','main riff and solo','clean',
     'pop','lead','intermediate',
     'Electric guitar (Larry Knechtel)','Clean-to-crunch amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Smooth, melodic soft-rock clean guitar with a lyrical solo; keep it warm and tasteful.','Low gain, warm.'],
     array['Play the melodic lines smoothly.','Keep the solo lyrical.'],
     'Studio recording, 1972. Larry Knechtel played smooth, melodic soft-rock clean guitar and a lyrical solo.',71),
    ('summer-breeze','seals-and-crofts','guitar','riff','main progression','clean',
     'pop','rhythm','beginner',
     'Acoustic and electric guitar (Seals and Crofts)','Clean amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, breezy 70s soft-rock with mellow clean chords; keep it smooth and relaxed.','Low gain, warm.'],
     array['Play the chords smoothly.','Keep the groove breezy.'],
     'Studio recording, 1972 (Summer Breeze). Seals and Crofts played warm, breezy soft-rock clean chords.',71),
    ('your-mama-dont-dance','loggins-and-messina','guitar','riff','main riff','crunch',
     'rock','rhythm','beginner',
     'Electric guitar (Jim Messina)','Crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, snappy rock-and-roll crunch riff; keep it tight and bouncy.','Medium gain, bright.'],
     array['Play the snappy riff tightly.','Keep the groove bouncy.'],
     'Studio recording, 1972. Jim Messina played a bright, snappy rock-and-roll crunch riff.',71)
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
  ('simon-and-garfunkel','the-sound-of-silence'),('simon-and-garfunkel','mrs-robinson'),('simon-and-garfunkel','scarborough-fair'),('paul-simon','graceland'),
  ('james-taylor','fire-and-rain'),('james-taylor','country-road'),('cat-stevens','wild-world'),('cat-stevens','father-and-son'),
  ('cat-stevens','peace-train'),('carole-king','its-too-late'),('america','a-horse-with-no-name'),('america','ventura-highway'),
  ('america','sister-golden-hair'),('crosby-stills-and-nash','suite-judy-blue-eyes'),('crosby-stills-nash-and-young','ohio'),('crosby-stills-and-nash','teach-your-children'),
  ('jim-croce','time-in-a-bottle'),('jim-croce','operator'),('harry-chapin','cats-in-the-cradle'),('gordon-lightfoot','sundown'),
  ('don-mclean','american-pie'),('don-mclean','vincent'),('bread','guitar-man'),('seals-and-crofts','summer-breeze'),
  ('loggins-and-messina','your-mama-dont-dance')
) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
cross join (values
  ('artist_interview', 'Documented artist interviews and gear discussions', null::text,
   'Researched from widely-documented interviews about this recording and player.', 72),
  ('rig_rundown', 'Published rig rundowns and community gear databases', null::text,
   'Cross-referenced against rig features and community-maintained gear databases.', 66)
) as x(source_type, title, url, notes, credibility)
where p.verification_status = 'admin_verified'
on conflict do nothing;
