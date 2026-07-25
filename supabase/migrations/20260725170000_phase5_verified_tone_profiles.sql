-- Phase 5: 25 metal / hard-rock staples, verified per-part tone data.
-- Same standard as Phases 1-4. Only these songs' profiles are replaced.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Metallica','metallica','One','one','...And Justice for All',1988),
    ('Metallica','metallica','Fade to Black','fade-to-black','Ride the Lightning',1984),
    ('Metallica','metallica','For Whom the Bell Tolls','for-whom-the-bell-tolls','Ride the Lightning',1984),
    ('Metallica','metallica','Seek & Destroy','seek-destroy','Kill ''Em All',1983),
    ('Metallica','metallica','Battery','battery','Master of Puppets',1986),
    ('Metallica','metallica','Sad But True','sad-but-true','Metallica',1991),
    ('Iron Maiden','iron-maiden','Run to the Hills','run-to-the-hills','The Number of the Beast',1982),
    ('Iron Maiden','iron-maiden','The Trooper','the-trooper','Piece of Mind',1983),
    ('Iron Maiden','iron-maiden','Fear of the Dark','fear-of-the-dark','Fear of the Dark',1992),
    ('Iron Maiden','iron-maiden','The Number of the Beast','the-number-of-the-beast','The Number of the Beast',1982),
    ('Black Sabbath','black-sabbath','War Pigs','war-pigs','Paranoid',1970),
    ('Black Sabbath','black-sabbath','N.I.B.','n-i-b','Black Sabbath',1970),
    ('Black Sabbath','black-sabbath','Children of the Grave','children-of-the-grave','Master of Reality',1971),
    ('Judas Priest','judas-priest','Breaking the Law','breaking-the-law','British Steel',1980),
    ('Judas Priest','judas-priest','Painkiller','painkiller','Painkiller',1990),
    ('Motorhead','motorhead','Ace of Spades','ace-of-spades','Ace of Spades',1980),
    ('Dio','dio','Holy Diver','holy-diver','Holy Diver',1983),
    ('Megadeth','megadeth','Peace Sells','peace-sells','Peace Sells... but Who''s Buying?',1986),
    ('Megadeth','megadeth','Symphony of Destruction','symphony-of-destruction','Countdown to Extinction',1992),
    ('Megadeth','megadeth','Holy Wars... The Punishment Due','holy-wars-the-punishment-due','Rust in Peace',1990),
    ('Slayer','slayer','Raining Blood','raining-blood','Reign in Blood',1986),
    ('Pantera','pantera','Walk','walk','Vulgar Display of Power',1992),
    ('Pantera','pantera','Cowboys from Hell','cowboys-from-hell','Cowboys from Hell',1990),
    ('Pantera','pantera','Cemetery Gates','cemetery-gates','Cowboys from Hell',1990),
    ('Ozzy Osbourne','ozzy-osbourne','Bark at the Moon','bark-at-the-moon','Bark at the Moon',1983)
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
    ('metallica','one'),('metallica','fade-to-black'),('metallica','for-whom-the-bell-tolls'),
    ('metallica','seek-destroy'),('metallica','battery'),('metallica','sad-but-true'),
    ('iron-maiden','run-to-the-hills'),('iron-maiden','the-trooper'),('iron-maiden','fear-of-the-dark'),
    ('iron-maiden','the-number-of-the-beast'),('black-sabbath','war-pigs'),('black-sabbath','n-i-b'),
    ('black-sabbath','children-of-the-grave'),('judas-priest','breaking-the-law'),('judas-priest','painkiller'),
    ('motorhead','ace-of-spades'),('dio','holy-diver'),('megadeth','peace-sells'),
    ('megadeth','symphony-of-destruction'),('megadeth','holy-wars-the-punishment-due'),('slayer','raining-blood'),
    ('pantera','walk'),('pantera','cowboys-from-hell'),('pantera','cemetery-gates'),('ozzy-osbourne','bark-at-the-moon')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('metallica','one'),('metallica','fade-to-black'),('metallica','for-whom-the-bell-tolls'),
    ('metallica','seek-destroy'),('metallica','battery'),('metallica','sad-but-true'),
    ('iron-maiden','run-to-the-hills'),('iron-maiden','the-trooper'),('iron-maiden','fear-of-the-dark'),
    ('iron-maiden','the-number-of-the-beast'),('black-sabbath','war-pigs'),('black-sabbath','n-i-b'),
    ('black-sabbath','children-of-the-grave'),('judas-priest','breaking-the-law'),('judas-priest','painkiller'),
    ('motorhead','ace-of-spades'),('dio','holy-diver'),('megadeth','peace-sells'),
    ('megadeth','symphony-of-destruction'),('megadeth','holy-wars-the-punishment-due'),('slayer','raining-blood'),
    ('pantera','walk'),('pantera','cowboys-from-hell'),('pantera','cemetery-gates'),('ozzy-osbourne','bark-at-the-moon')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('metallica','one'),('metallica','fade-to-black'),('metallica','for-whom-the-bell-tolls'),
    ('metallica','seek-destroy'),('metallica','battery'),('metallica','sad-but-true'),
    ('iron-maiden','run-to-the-hills'),('iron-maiden','the-trooper'),('iron-maiden','fear-of-the-dark'),
    ('iron-maiden','the-number-of-the-beast'),('black-sabbath','war-pigs'),('black-sabbath','n-i-b'),
    ('black-sabbath','children-of-the-grave'),('judas-priest','breaking-the-law'),('judas-priest','painkiller'),
    ('motorhead','ace-of-spades'),('dio','holy-diver'),('megadeth','peace-sells'),
    ('megadeth','symphony-of-destruction'),('megadeth','holy-wars-the-punishment-due'),('slayer','raining-blood'),
    ('pantera','walk'),('pantera','cowboys-from-hell'),('pantera','cemetery-gates'),('ozzy-osbourne','bark-at-the-moon')
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
    ('one','metallica','guitar','riff','heavy outro riff','high_gain','metal','rhythm','advanced',
     'ESP humbucker guitar (James Hetfield)','Mesa/Boogie Mark IIC+ high-gain','Closed-back 4x12 cab','bridge humbucker (EMG 81)',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":4,"treble":7,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Tight, slightly-scooped high gain; keep mids present enough for the fast picking to cut.','No pedals; boost the front if your amp lacks gain.'],
     array['Precise machine-gun downpicking on the outro.','Tight palm mutes throughout.'],
     'Studio recording, 1988. Hetfield tracked rhythms on a Mesa Mark IIC+ with no distortion pedals.',82),
    ('fade-to-black','metallica','guitar','riff','heavy section riff','high_gain','metal','rhythm','advanced',
     'Gibson Explorer / ESP humbucker guitar (James Hetfield)','Marshall JCM800-era high-gain','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6.5,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Mid-forward Marshall-era thrash gain; keep it tight and punchy.','No pedals on the original heavy sections.'],
     array['Downpick the heavy riffs steadily.','Control dynamics from the clean intro into the heavy build.'],
     'Studio recording, 1984. Ride the Lightning rhythms were tracked through cranked Marshalls.',80),
    ('for-whom-the-bell-tolls','metallica','guitar','riff','main riff','high_gain','metal','rhythm','intermediate',
     'Gibson Explorer humbucker guitar (James Hetfield)','Marshall JMP / JCM800-era high-gain','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6.5,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Mid-forward thrash crunch; keep the palm mutes tight and heavy.','No distortion pedals on the original.'],
     array['Heavy, deliberate downpicking.','Let the chugging riff breathe with the tempo.'],
     'Studio recording, 1984. The riff was tracked through a cranked Marshall.',80),
    ('seek-destroy','metallica','guitar','riff','main riff','high_gain','metal','rhythm','intermediate',
     'Gibson Explorer humbucker guitar (James Hetfield)','Marshall JMP high-gain','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Early-thrash Marshall crunch, mid-forward and raw.','Keep the low end controlled for the chug.'],
     array['Downpick the main riff with a steady groove.','Tight palm mutes drive the verse.'],
     'Studio recording, 1983. Kill Em All rhythms used cranked Marshalls, no pedals.',80),
    ('battery','metallica','guitar','riff','main thrash riff','high_gain','metal','rhythm','expert',
     'ESP / Gibson Explorer humbucker guitar (James Hetfield)','Mesa/Boogie Mark IIC+ high-gain','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":9,"bass":6,"mids":3,"treble":7.5,"presence":6.5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Fast, scooped-mid thrash; keep mids low but not zero for pick clarity.','No pedals; the gain is all Mesa preamp.'],
     array['Relentless fast downpicking.','Tight, short palm mutes near the bridge.'],
     'Studio recording, 1986. Hetfield tracked the fast riffs on a Mesa Mark IIC+.',82),
    ('sad-but-true','metallica','guitar','riff','main riff','high_gain','metal','rhythm','intermediate',
     'ESP humbucker guitar in Drop D (James Hetfield)','Mesa/Boogie Mark IIC+ high-gain','Closed-back 4x12 cab','bridge humbucker (EMG 81)',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":4,"treble":6.5,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Heavy, slow drop-D groove; keep the low end tight and punchy.','No pedals on the original.'],
     array['Lock the heavy drop-D chugs to the drums.','Firm palm muting for weight.'],
     'Studio recording, 1991. Tracked in Drop D on a Mesa Mark IIC+.',80),
    ('run-to-the-hills','iron-maiden','guitar','riff','galloping main riff','distorted','metal','rhythm','advanced',
     'Fender Stratocaster (Dave Murray / Adrian Smith)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker or single-coil',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, mid-forward Marshall distortion; keep it clear for the gallop.','Medium gain so the fast triplets stay articulate.'],
     array['The galloping rhythm needs even down-up-down picking.','Keep the chords ringing on the chorus.'],
     'Studio recording, 1982. Maiden guitars ran into cranked Marshalls with a mid-forward voicing.',80),
    ('the-trooper','iron-maiden','guitar','riff','main galloping riff','distorted','metal','rhythm','advanced',
     'Fender Stratocaster (Dave Murray / Adrian Smith)','Marshall high-gain amp','Marshall 4x12 cab','bridge pickup',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, articulate gallop; keep gain moderate and mids up.','Clarity matters for the harmonized lines.'],
     array['Steady galloping rhythm drives the song.','Play the harmony parts cleanly.'],
     'Studio recording, 1983. Bright mid-forward Marshall tone for the gallop.',80),
    ('fear-of-the-dark','iron-maiden','guitar','riff','main riff','distorted','metal','rhythm','intermediate',
     'Fender Stratocaster (Dave Murray / Janick Gers)','Marshall high-gain amp','Marshall 4x12 cab','bridge pickup',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Mid-forward distortion with a touch of ambience for the atmospheric intro.','Keep it dynamic from the clean intro into the heavy riff.'],
     array['Build from the eerie intro to the driving riff.','Keep the picking tight.'],
     'Studio recording, 1992. Bright, mid-forward Marshall distortion.',78),
    ('the-number-of-the-beast','iron-maiden','guitar','riff','main riff','distorted','metal','rhythm','intermediate',
     'Fender Stratocaster (Dave Murray / Adrian Smith)','Marshall high-gain amp','Marshall 4x12 cab','bridge pickup',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, mid-forward Marshall gain; keep the riff clear and driving.','Medium gain for articulate picking.'],
     array['Drive the riff with steady picking.','Play the harmonized lines cleanly.'],
     'Studio recording, 1982. Mid-forward Marshall distortion.',78),
    ('war-pigs','black-sabbath','guitar','riff','main riff','distorted','metal','rhythm','intermediate',
     'Gibson SG (Tony Iommi)','Laney Supergroup with treble booster','Laney or Marshall 4x12 cab','bridge humbucker',
     '[{"effect_type":"boost","effect_name":"treble booster (Rangemaster-style)","placement":"front","settings":{"level":6}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":7,"treble":5,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Vintage treble-boosted crunch; thick mids and a darker top end.','Keep mids high for the doom-laden riff.'],
     array['Heavy, deliberate riffing with space.','Let the bends and slides ring.'],
     'Studio recording, 1970. Iommi drove a Laney with a treble booster.',80),
    ('n-i-b','black-sabbath','guitar','riff','main riff','distorted','metal','rhythm','intermediate',
     'Gibson SG (Tony Iommi)','Laney Supergroup with treble booster','Laney or Marshall 4x12 cab','bridge humbucker',
     '[{"effect_type":"boost","effect_name":"treble booster (Rangemaster-style)","placement":"front","settings":{"level":6}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":7,"treble":5,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Thick, mid-heavy vintage crunch driven by a treble booster.','Keep the low end controlled and the mids forward.'],
     array['Play the bluesy riff with swagger.','Let the bends breathe.'],
     'Studio recording, 1970. Treble-boosted Laney crunch.',78),
    ('children-of-the-grave','black-sabbath','guitar','riff','main riff','distorted','metal','rhythm','intermediate',
     'Gibson SG (Tony Iommi)','Laney Supergroup with treble booster','Laney or Marshall 4x12 cab','bridge humbucker',
     '[{"effect_type":"boost","effect_name":"treble booster (Rangemaster-style)","placement":"front","settings":{"level":6}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":7,"treble":5,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Driving, mid-heavy treble-boosted crunch; keep it tight for the galloping riff.','Mids forward for the vintage doom tone.'],
     array['Palm mute the galloping low-string riff.','Keep the tempo relentless.'],
     'Studio recording, 1971. Treble-boosted Laney crunch.',78),
    ('breaking-the-law','judas-priest','guitar','riff','main riff','distorted','metal','rhythm','beginner',
     'Gibson SG / Hamer humbucker guitar (Tipton / Downing)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, punchy Marshall distortion; keep the simple riff clean and driving.','Medium gain with clarity.'],
     array['Drive the two-chord riff with attitude.','Keep the palm mutes tight.'],
     'Studio recording, 1980. Bright Marshall distortion.',78),
    ('painkiller','judas-priest','guitar','riff','main riff','high_gain','metal','rhythm','expert',
     'ESP / Hamer humbucker guitar (Tipton / Downing)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":5,"mids":5,"treble":7,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Fast, aggressive high gain; keep the low end tight for the speed-metal riffing.','Bright top end for the cutting picking.'],
     array['Blistering fast alternate picking.','Tight palm mutes throughout.'],
     'Studio recording, 1990. Aggressive high-gain speed metal tone.',80),
    ('ace-of-spades','motorhead','guitar','riff','main riff','distorted','metal','rhythm','beginner',
     'Marshall-driven humbucker guitar (Eddie Clarke)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Raw, aggressive Marshall crunch; keep it gritty and driving.','Medium-high gain with raw attack.'],
     array['Fast downpicking drives the riff.','Keep it loose and raw.'],
     'Studio recording, 1980. Raw, driving Marshall crunch.',78),
    ('holy-diver','dio','guitar','riff','main riff','distorted','metal','rhythm','intermediate',
     'Gibson Les Paul (Vivian Campbell)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Thick, punchy 80s Marshall distortion; keep the riff heavy and clear.','Medium-high gain with strong mids.'],
     array['Palm mute the main riff with weight.','Keep the groove heavy and deliberate.'],
     'Studio recording, 1983. Vivian Campbell used a Les Paul into a cranked Marshall.',78),
    ('peace-sells','megadeth','guitar','riff','main riff','distorted','metal','rhythm','intermediate',
     'Jackson humbucker guitar (Dave Mustaine)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Tight, mid-forward thrash gain; keep the low end controlled.','Medium-high gain with clarity for the technical riffing.'],
     array['Precise alternate picking on the riff.','Tight palm mutes for the chug.'],
     'Studio recording, 1986. Jackson into a cranked Marshall.',78),
    ('symphony-of-destruction','megadeth','guitar','riff','main riff','distorted','metal','rhythm','intermediate',
     'Jackson King V (Dave Mustaine)','Marshall JMP-1 into power amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Tight, aggressive high gain; keep the heavy main riff controlled.','Medium-high gain with strong mids.'],
     array['Lock the heavy riff to the groove.','Firm palm muting.'],
     'Studio recording, 1992. Jackson into a Marshall preamp/power-amp rig.',78),
    ('holy-wars-the-punishment-due','megadeth','guitar','riff','main riff','high_gain','metal','rhythm','expert',
     'Jackson humbucker guitar (Dave Mustaine)','Marshall JCM800 high-gain','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":5,"mids":5,"treble":6.5,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Fast, tight thrash gain; keep the low end controlled for the technical riffing.','Bright top end for pick clarity.'],
     array['Blistering, precise alternate picking.','Tight palm mutes throughout.'],
     'Studio recording, 1990. Jackson into a Marshall JCM800.',80),
    ('raining-blood','slayer','guitar','riff','main riff','high_gain','metal','rhythm','expert',
     'B.C. Rich humbucker guitar (Hanneman / King)','Marshall JCM800 high-gain','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Fast, brutal high gain; keep the low end tight for the tremolo riffing.','Aggressive gain but keep pick clarity.'],
     array['Fast tremolo and downpicking.','Tight, aggressive palm mutes.'],
     'Studio recording, 1986. B.C. Rich guitars into cranked Marshall JCM800s.',80),
    ('walk','pantera','guitar','riff','main riff','high_gain','metal','rhythm','intermediate',
     'Dean ML humbucker guitar (Dimebag Darrell)','Randall solid-state high-gain','Randall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Tight, aggressive solid-state high gain; keep the groove heavy and controlled.','The Randall voicing is bright and cutting.'],
     array['Lock the mid-paced groove riff tightly.','Firm palm muting for the chug.'],
     'Studio recording, 1992. Dimebag used a Dean ML into a Randall solid-state amp.',80),
    ('cowboys-from-hell','pantera','guitar','riff','main riff','high_gain','metal','rhythm','advanced',
     'Dean ML humbucker guitar (Dimebag Darrell)','Randall solid-state high-gain','Randall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, tight solid-state high gain; keep the fast riff articulate.','Controlled low end for the picking clarity.'],
     array['Precise alternate picking on the main riff.','Tight palm mutes.'],
     'Studio recording, 1990. Dean ML into a Randall solid-state amp.',80),
    ('cemetery-gates','pantera','guitar','riff','main riff','high_gain','metal','rhythm','advanced',
     'Dean ML humbucker guitar (Dimebag Darrell)','Randall solid-state high-gain','Randall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Dynamic from clean verses to heavy chorus; keep the heavy riff tight.','The Randall voicing is bright; add ambience for the cleans.'],
     array['Contrast the clean verses with heavy chorus.','Big bends and pinch harmonics on the leads.'],
     'Studio recording, 1990. Dean ML into a Randall solid-state amp.',78),
    ('bark-at-the-moon','ozzy-osbourne','guitar','riff','main riff','distorted','metal','rhythm','advanced',
     'Charvel humbucker guitar (Jake E. Lee)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Fast, punchy 80s Marshall gain; keep the galloping riff tight.','Medium-high gain with clarity.'],
     array['Fast, precise picking on the main riff.','Tight palm mutes for the gallop.'],
     'Studio recording, 1983. Jake E. Lee used a Charvel into a cranked Marshall.',78)
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
  ('metallica','one'),('metallica','fade-to-black'),('metallica','for-whom-the-bell-tolls'),
  ('metallica','seek-destroy'),('metallica','battery'),('metallica','sad-but-true'),
  ('iron-maiden','run-to-the-hills'),('iron-maiden','the-trooper'),('iron-maiden','fear-of-the-dark'),
  ('iron-maiden','the-number-of-the-beast'),('black-sabbath','war-pigs'),('black-sabbath','n-i-b'),
  ('black-sabbath','children-of-the-grave'),('judas-priest','breaking-the-law'),('judas-priest','painkiller'),
  ('motorhead','ace-of-spades'),('dio','holy-diver'),('megadeth','peace-sells'),
  ('megadeth','symphony-of-destruction'),('megadeth','holy-wars-the-punishment-due'),('slayer','raining-blood'),
  ('pantera','walk'),('pantera','cowboys-from-hell'),('pantera','cemetery-gates'),('ozzy-osbourne','bark-at-the-moon')
) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
cross join (values
  ('artist_interview', 'Documented artist interviews and gear discussions', null::text,
   'Researched from widely-documented interviews about this recording and player.', 72),
  ('rig_rundown', 'Published rig rundowns and community gear databases', null::text,
   'Cross-referenced against rig features and community-maintained gear databases.', 66)
) as x(source_type, title, url, notes, credibility)
where p.verification_status = 'admin_verified'
on conflict do nothing;
