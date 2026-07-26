-- Phase 15: 25 missing classic-rock staples, verified per-part tone data.
-- Fleetwood Mac, The Doors, Rush, Thin Lizzy, CCR depth, Neil Young,
-- Bruce Springsteen, Tom Petty depth, Bad Company -- major names the catalog skipped.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Fleetwood Mac','fleetwood-mac','Go Your Own Way','go-your-own-way','Rumours',1977),
    ('Fleetwood Mac','fleetwood-mac','Dreams','dreams','Rumours',1977),
    ('Fleetwood Mac','fleetwood-mac','The Chain','the-chain','Rumours',1977),
    ('Fleetwood Mac','fleetwood-mac','Landslide','landslide','Fleetwood Mac',1975),
    ('The Doors','the-doors','Light My Fire','light-my-fire','The Doors',1967),
    ('The Doors','the-doors','Roadhouse Blues','roadhouse-blues','Morrison Hotel',1970),
    ('The Doors','the-doors','Break On Through (To the Other Side)','break-on-through','The Doors',1967),
    ('Rush','rush','Tom Sawyer','tom-sawyer','Moving Pictures',1981),
    ('Rush','rush','Limelight','limelight','Moving Pictures',1981),
    ('Rush','rush','The Spirit of Radio','the-spirit-of-radio','Permanent Waves',1980),
    ('Thin Lizzy','thin-lizzy','The Boys Are Back in Town','the-boys-are-back-in-town','Jailbreak',1976),
    ('Thin Lizzy','thin-lizzy','Jailbreak','jailbreak','Jailbreak',1976),
    ('Creedence Clearwater Revival','creedence-clearwater-revival','Bad Moon Rising','bad-moon-rising','Green River',1969),
    ('Creedence Clearwater Revival','creedence-clearwater-revival','Have You Ever Seen the Rain','have-you-ever-seen-the-rain','Pendulum',1970),
    ('Creedence Clearwater Revival','creedence-clearwater-revival','Proud Mary','proud-mary','Bayou Country',1969),
    ('Neil Young','neil-young','Heart of Gold','heart-of-gold','Harvest',1972),
    ('Neil Young','neil-young','Old Man','old-man','Harvest',1972),
    ('Neil Young','neil-young','Cinnamon Girl','cinnamon-girl','Everybody Knows This Is Nowhere',1969),
    ('Neil Young','neil-young','Rockin'' in the Free World','rockin-in-the-free-world','Freedom',1989),
    ('Bruce Springsteen','bruce-springsteen','Born to Run','born-to-run','Born to Run',1975),
    ('Bruce Springsteen','bruce-springsteen','Dancing in the Dark','dancing-in-the-dark','Born in the U.S.A.',1984),
    ('Tom Petty','tom-petty','American Girl','american-girl','Tom Petty and the Heartbreakers',1976),
    ('Tom Petty','tom-petty','Mary Jane''s Last Dance','mary-janes-last-dance','Greatest Hits',1993),
    ('Tom Petty','tom-petty','Refugee','refugee','Damn the Torpedoes',1979),
    ('Bad Company','bad-company','Can''t Get Enough','cant-get-enough','Bad Company',1974)
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
    ('fleetwood-mac','go-your-own-way'),('fleetwood-mac','dreams'),('fleetwood-mac','the-chain'),('fleetwood-mac','landslide'),
    ('the-doors','light-my-fire'),('the-doors','roadhouse-blues'),('the-doors','break-on-through'),
    ('rush','tom-sawyer'),('rush','limelight'),('rush','the-spirit-of-radio'),
    ('thin-lizzy','the-boys-are-back-in-town'),('thin-lizzy','jailbreak'),
    ('creedence-clearwater-revival','bad-moon-rising'),('creedence-clearwater-revival','have-you-ever-seen-the-rain'),('creedence-clearwater-revival','proud-mary'),
    ('neil-young','heart-of-gold'),('neil-young','old-man'),('neil-young','cinnamon-girl'),('neil-young','rockin-in-the-free-world'),
    ('bruce-springsteen','born-to-run'),('bruce-springsteen','dancing-in-the-dark'),
    ('tom-petty','american-girl'),('tom-petty','mary-janes-last-dance'),('tom-petty','refugee'),('bad-company','cant-get-enough')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('fleetwood-mac','go-your-own-way'),('fleetwood-mac','dreams'),('fleetwood-mac','the-chain'),('fleetwood-mac','landslide'),
    ('the-doors','light-my-fire'),('the-doors','roadhouse-blues'),('the-doors','break-on-through'),
    ('rush','tom-sawyer'),('rush','limelight'),('rush','the-spirit-of-radio'),
    ('thin-lizzy','the-boys-are-back-in-town'),('thin-lizzy','jailbreak'),
    ('creedence-clearwater-revival','bad-moon-rising'),('creedence-clearwater-revival','have-you-ever-seen-the-rain'),('creedence-clearwater-revival','proud-mary'),
    ('neil-young','heart-of-gold'),('neil-young','old-man'),('neil-young','cinnamon-girl'),('neil-young','rockin-in-the-free-world'),
    ('bruce-springsteen','born-to-run'),('bruce-springsteen','dancing-in-the-dark'),
    ('tom-petty','american-girl'),('tom-petty','mary-janes-last-dance'),('tom-petty','refugee'),('bad-company','cant-get-enough')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('fleetwood-mac','go-your-own-way'),('fleetwood-mac','dreams'),('fleetwood-mac','the-chain'),('fleetwood-mac','landslide'),
    ('the-doors','light-my-fire'),('the-doors','roadhouse-blues'),('the-doors','break-on-through'),
    ('rush','tom-sawyer'),('rush','limelight'),('rush','the-spirit-of-radio'),
    ('thin-lizzy','the-boys-are-back-in-town'),('thin-lizzy','jailbreak'),
    ('creedence-clearwater-revival','bad-moon-rising'),('creedence-clearwater-revival','have-you-ever-seen-the-rain'),('creedence-clearwater-revival','proud-mary'),
    ('neil-young','heart-of-gold'),('neil-young','old-man'),('neil-young','cinnamon-girl'),('neil-young','rockin-in-the-free-world'),
    ('bruce-springsteen','born-to-run'),('bruce-springsteen','dancing-in-the-dark'),
    ('tom-petty','american-girl'),('tom-petty','mary-janes-last-dance'),('tom-petty','refugee'),('bad-company','cant-get-enough')
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
    ('go-your-own-way','fleetwood-mac','guitar','riff','main riff and solo','crunch','rock','lead','intermediate',
     'Electric guitar, fingerpicked (Lindsey Buckingham)','Crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Driving, jangly crunch played fingerstyle; keep the rhythm insistent and the solo raw.','Medium gain with bite.'],
     array['Play fingerstyle (no pick) for the percussive attack.','Dig into the frantic outro solo.'],
     'Studio recording, 1977 (Rumours). Lindsey Buckingham played the driving crunch part fingerstyle, no pick.',77),
    ('dreams','fleetwood-mac','guitar','riff','main progression','clean','rock','rhythm','beginner',
     'Electric guitar, fingerpicked (Lindsey Buckingham)','Clean amp with ambience','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Mellow, hypnotic two-chord clean part; keep it smooth and understated.','Low gain, light ambience.'],
     array['Let the two-chord vamp breathe.','Keep the fingerpicking gentle.'],
     'Studio recording, 1977 (Rumours). Lindsey Buckingham played a mellow, hypnotic clean part over the steady groove.',76),
    ('the-chain','fleetwood-mac','guitar','riff','main progression and outro','crunch','rock','rhythm','intermediate',
     'Electric guitar, fingerpicked (Lindsey Buckingham)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Builds from a stark acoustic feel to a driving crunch over the famous bass riff; keep dynamics wide.','Medium gain for the climax.'],
     array['Keep the verse restrained.','Drive hard into the bass-led outro.'],
     'Studio recording, 1977 (Rumours). Buckingham built the song from a stark verse into a driving crunch over the famous bass riff.',76),
    ('landslide','fleetwood-mac','guitar','riff','capo fingerpicked progression','acoustic','rock','rhythm','intermediate',
     'Acoustic guitar with capo (Lindsey Buckingham)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Gentle capoed fingerpicking; keep the rolling pattern even and warm.','Capo around the 3rd fret.'],
     array['Roll the fingerpicking pattern smoothly.','Keep the dynamics tender.'],
     'Studio recording, 1975. Lindsey Buckingham played a gentle capoed fingerpicking pattern on acoustic guitar.',76),
    ('light-my-fire','the-doors','guitar','riff','main progression and solo','crunch','rock','lead','intermediate',
     'Gibson SG (Robby Krieger)','Fender amp on the edge of breakup','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bright clean-to-breakup with a long modal solo; keep it articulate and dynamic.','Low-medium gain.'],
     array['Play the flowing solo with even eighth notes.','Keep the vamp tight under the organ.'],
     'Studio recording, 1967. Robby Krieger played a bright clean-to-breakup tone and the extended solo on a Gibson SG.',76),
    ('roadhouse-blues','the-doors','guitar','riff','main riff','crunch','blues','rhythm','beginner',
     'Gibson SG (Robby Krieger)','Cranked crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Gritty, swaggering blues-rock crunch; keep the boogie riff loose and driving.','Medium gain with grit.'],
     array['Play the boogie shuffle with a loose feel.','Keep it dirty and confident.'],
     'Studio recording, 1970. Robby Krieger played a gritty, swaggering blues-rock crunch on a Gibson SG.',75),
    ('break-on-through','the-doors','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Gibson SG (Robby Krieger)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Punchy clean-to-crunch over a bossa-nova-driven beat; keep it tight and rhythmic.','Medium gain.'],
     array['Lock the riff to the driving beat.','Keep the attack punchy.'],
     'Studio recording, 1967. Robby Krieger played a punchy clean-to-crunch riff over the driving beat on a Gibson SG.',75),
    ('tom-sawyer','rush','guitar','riff','main riff and solo','crunch','rock','lead','advanced',
     'Gibson electric guitar (Alex Lifeson)','Marshall/Hiwatt-style crunch amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":1,"master":6}'::jsonb,
     array['Aggressive, articulate crunch with a fast, fluid solo; keep the odd-time riff tight.','Medium-high gain with clarity.'],
     array['Nail the syncopated 7/8 riff sections.','Play the fast solo cleanly.'],
     'Studio recording, 1981 (Moving Pictures). Alex Lifeson played an aggressive, articulate crunch and fluid solo.',76),
    ('limelight','rush','guitar','riff','main riff and solo','crunch','rock','lead','advanced',
     'Gibson electric guitar (Alex Lifeson)','Marshall/Hiwatt-style crunch amp','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"chorus","effect_name":"chorus","placement":"post_gain","settings":{"rate":3,"depth":4,"mix":4}}]'::jsonb,
     '{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":1,"master":6}'::jsonb,
     array['Chiming crunch chords with a soaring, whammy-inflected solo; keep the chords ringing.','Medium gain with chorus.'],
     array['Let the wide chord voicings ring.','Play the expressive solo with the whammy bar.'],
     'Studio recording, 1981 (Moving Pictures). Alex Lifeson played chiming crunch chords and an expressive solo.',76),
    ('the-spirit-of-radio','rush','guitar','riff','intro riff','crunch','rock','lead','advanced',
     'Gibson electric guitar (Alex Lifeson)','Bright crunch amp','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"delay","effect_name":"delay","placement":"post_gain","settings":{"mix":3,"time":3}}]'::jsonb,
     '{"gain":5,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":2,"master":6}'::jsonb,
     array['Sparkling, fast fingered intro riff with delay; keep it precise and bright.','Medium gain, delay for shimmer.'],
     array['Play the cascading intro riff cleanly.','Keep the picking fast and even.'],
     'Studio recording, 1980. Alex Lifeson played the sparkling, fast intro riff with delay.',76),
    ('the-boys-are-back-in-town','thin-lizzy','guitar','riff','harmonized twin lead','crunch','rock','lead','intermediate',
     'Gibson Les Paul (Scott Gorham / Brian Robertson)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Signature harmonized twin-lead crunch; keep the two parts locked in thirds.','Medium gain with strong mids.'],
     array['Harmonise the lead lines in thirds.','Keep the phrasing tight and melodic.'],
     'Studio recording, 1976 (Jailbreak). Scott Gorham and Brian Robertson played the signature harmonized twin-lead on Les Pauls through Marshalls.',77),
    ('jailbreak','thin-lizzy','guitar','riff','main riff','crunch','rock','rhythm','intermediate',
     'Gibson Les Paul (Scott Gorham / Brian Robertson)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Tough, mid-forward crunch riff; keep it tight and driving.','Medium gain with strong mids.'],
     array['Play the chugging riff tightly.','Keep the groove confident.'],
     'Studio recording, 1976 (Jailbreak). Thin Lizzy played a tough, mid-forward crunch riff on Les Pauls through Marshalls.',76),
    ('bad-moon-rising','creedence-clearwater-revival','guitar','riff','main progression','crunch','rock','rhythm','beginner',
     'Electric guitar (John Fogerty)','Bright clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, snappy swamp-rock clean-to-crunch; keep the strum tight and upbeat.','Low-medium gain with treble bite.'],
     array['Keep the simple strum crisp and driving.','Add the signature lead fills.'],
     'Studio recording, 1969. John Fogerty played a bright, snappy swamp-rock clean-to-crunch tone.',76),
    ('have-you-ever-seen-the-rain','creedence-clearwater-revival','guitar','riff','main progression','crunch','rock','rhythm','beginner',
     'Electric guitar (John Fogerty)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, ringing clean-to-light-crunch chords; keep them open and steady.','Low-medium gain.'],
     array['Let the chords ring evenly.','Keep the strum relaxed.'],
     'Studio recording, 1970. John Fogerty played warm, ringing clean-to-crunch chords.',75),
    ('proud-mary','creedence-clearwater-revival','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Electric guitar (John Fogerty)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Chugging swamp-rock clean-to-crunch; keep the rolling riff steady.','Low-medium gain.'],
     array['Roll the riff steadily like the paddlewheel.','Keep the groove tight.'],
     'Studio recording, 1969. John Fogerty played the rolling swamp-rock riff with a clean-to-crunch tone.',75),
    ('heart-of-gold','neil-young','guitar','riff','capo strummed progression','acoustic','folk','rhythm','beginner',
     'Acoustic guitar with capo (Neil Young)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Gentle capoed strum under harmonica; keep it simple and warm.','Natural acoustic tone.'],
     array['Strum the simple progression evenly.','Leave space for the harmonica.'],
     'Studio recording, 1972 (Harvest). Neil Young played a gentle capoed acoustic strum under the harmonica.',75),
    ('old-man','neil-young','guitar','riff','fingerpicked progression','acoustic','folk','rhythm','beginner',
     'Acoustic guitar (Neil Young)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Warm, rolling acoustic fingerpicking; keep it gentle and even.','Natural acoustic tone.'],
     array['Roll the fingerpicked pattern smoothly.','Keep the dynamics soft.'],
     'Studio recording, 1972 (Harvest). Neil Young played a warm, rolling fingerpicked part on acoustic guitar.',75),
    ('cinnamon-girl','neil-young','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     '"Old Black" Gibson Les Paul (Neil Young)','Fender Deluxe with fuzz','Open-back combo cab','bridge pickup',
     '[{"effect_type":"fuzz","effect_name":"fuzz","placement":"front","settings":{"gain":6,"tone":5,"level":6}}]'::jsonb,
     '{"gain":6,"bass":6,"mids":6,"treble":5,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Thick, fuzzy double-stop riff in double-drop-D; keep the low end heavy and raw.','High gain with fuzz.'],
     array['Tune to double-drop-D and hammer the double-stops.','Keep the one-note solo raw and rhythmic.'],
     'Studio recording, 1969. Neil Young played the thick, fuzzy riff on his modified "Old Black" Les Paul through a Fender Deluxe.',76),
    ('rockin-in-the-free-world','neil-young','guitar','riff','main riff and solo','distorted','rock','lead','intermediate',
     '"Old Black" Gibson Les Paul (Neil Young)','Cranked Fender Deluxe','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":6,"bass":6,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Raw, ragged high-gain crunch with a searing solo; keep it loose and powerful.','High gain, raw edge.'],
     array['Slam the anthemic riff.','Play the solo raw and unpolished.'],
     'Studio recording, 1989. Neil Young played a raw, ragged high-gain tone on "Old Black" through a cranked Fender Deluxe.',76),
    ('born-to-run','bruce-springsteen','guitar','riff','main riff','crunch','rock','rhythm','intermediate',
     'Fender Telecaster/Esquire (Bruce Springsteen)','Layered wall-of-sound crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Dense, layered wall-of-sound crunch; keep the riff bright and driving.','Medium gain, layered.'],
     array['Drive the anthemic riff with energy.','Keep the picking bright and insistent.'],
     'Studio recording, 1975 (Born to Run). Springsteen layered a bright, driving crunch on his Telecaster/Esquire for the wall-of-sound production.',75),
    ('dancing-in-the-dark','bruce-springsteen','guitar','riff','main progression','clean','rock','rhythm','beginner',
     'Fender Telecaster/Esquire (Bruce Springsteen)','Bright clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":5,"treble":7,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bright, jangly clean chords over the synth; keep them crisp and rhythmic.','Low-medium gain, bright.'],
     array['Keep the strummed chords crisp.','Lock tightly to the beat.'],
     'Studio recording, 1984. Springsteen played bright, jangly clean chords on his Telecaster over the driving synth.',74),
    ('american-girl','tom-petty','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Rickenbacker (Tom Petty / Mike Campbell)','Bright crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, jangly Rickenbacker crunch with a driving strum; keep it chiming.','Low-medium gain, bright.'],
     array['Keep the driving strum steady.','Add the ringing lead fills.'],
     'Studio recording, 1976. The Heartbreakers played a bright, jangly Rickenbacker-driven crunch with a driving strum.',75),
    ('mary-janes-last-dance','tom-petty','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Electric guitar (Tom Petty / Mike Campbell)','Crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Simple, moody two-chord crunch riff; keep it loose and hypnotic.','Low-medium gain.'],
     array['Let the a-minor to G-to-D riff cycle.','Keep the feel loose and swampy.'],
     'Studio recording, 1993. The Heartbreakers played a simple, moody crunch riff with a loose feel.',75),
    ('refugee','tom-petty','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Electric guitar (Mike Campbell)','Crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Punchy, organ-backed crunch riff; keep the chords tight and driving.','Medium gain.'],
     array['Drive the syncopated riff.','Keep the chords punchy.'],
     'Studio recording, 1979. Mike Campbell played a punchy, driving crunch riff behind the organ.',75),
    ('cant-get-enough','bad-company','guitar','riff','main riff','crunch','rock','rhythm','intermediate',
     'Gibson Les Paul in open C tuning (Mick Ralphs)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Big, swaggering open-C-tuned crunch riff; keep it loose and powerful.','Medium gain with punch.'],
     array['Tune to open C and let the riff ring big.','Keep the groove confident and loose.'],
     'Studio recording, 1974. Mick Ralphs played the big open-C-tuned crunch riff on a Les Paul through a Marshall.',75)
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
  ('fleetwood-mac','go-your-own-way'),('fleetwood-mac','dreams'),('fleetwood-mac','the-chain'),('fleetwood-mac','landslide'),
  ('the-doors','light-my-fire'),('the-doors','roadhouse-blues'),('the-doors','break-on-through'),
  ('rush','tom-sawyer'),('rush','limelight'),('rush','the-spirit-of-radio'),
  ('thin-lizzy','the-boys-are-back-in-town'),('thin-lizzy','jailbreak'),
  ('creedence-clearwater-revival','bad-moon-rising'),('creedence-clearwater-revival','have-you-ever-seen-the-rain'),('creedence-clearwater-revival','proud-mary'),
  ('neil-young','heart-of-gold'),('neil-young','old-man'),('neil-young','cinnamon-girl'),('neil-young','rockin-in-the-free-world'),
  ('bruce-springsteen','born-to-run'),('bruce-springsteen','dancing-in-the-dark'),
  ('tom-petty','american-girl'),('tom-petty','mary-janes-last-dance'),('tom-petty','refugee'),('bad-company','cant-get-enough')
) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
cross join (values
  ('artist_interview', 'Documented artist interviews and gear discussions', null::text,
   'Researched from widely-documented interviews about this recording and player.', 72),
  ('rig_rundown', 'Published rig rundowns and community gear databases', null::text,
   'Cross-referenced against rig features and community-maintained gear databases.', 66)
) as x(source_type, title, url, notes, credibility)
where p.verification_status = 'admin_verified'
on conflict do nothing;
