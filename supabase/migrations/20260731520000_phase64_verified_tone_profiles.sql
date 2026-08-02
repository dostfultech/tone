-- Phase 64: folk / indie-folk fingerpicking canon, verified per-part tone data.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Nick Drake','nick-drake','Pink Moon','pink-moon','Pink Moon',1972),
    ('Nick Drake','nick-drake','River Man','river-man','Five Leaves Left',1969),
    ('Elliott Smith','elliott-smith','Between the Bars','between-the-bars','Either/Or',1997),
    ('Elliott Smith','elliott-smith','Angeles','angeles','Either/Or',1997),
    ('Jose Gonzalez','jose-gonzalez','Heartbeats','heartbeats','Veneer',2003),
    ('Iron & Wine','iron-and-wine','Flightless Bird, American Mouth','flightless-bird-american-mouth','The Shepherd''s Dog',2007),
    ('Iron & Wine','iron-and-wine','Naked as We Came','naked-as-we-came','Our Endless Numbered Days',2004),
    ('Fleet Foxes','fleet-foxes','White Winter Hymnal','white-winter-hymnal','Fleet Foxes',2008),
    ('Sufjan Stevens','sufjan-stevens','Mystery of Love','mystery-of-love','Call Me by Your Name',2017),
    ('Sufjan Stevens','sufjan-stevens','Death with Dignity','death-with-dignity','Carrie & Lowell',2015),
    ('Bon Iver','bon-iver','Holocene','holocene','Bon Iver, Bon Iver',2011),
    ('First Aid Kit','first-aid-kit','Emmylou','emmylou','The Lion''s Roar',2012),
    ('Edward Sharpe & The Magnetic Zeros','edward-sharpe-and-the-magnetic-zeros','Home','home','Up from Below',2009),
    ('The Head and the Heart','the-head-and-the-heart','Rivers and Roads','rivers-and-roads','The Head and the Heart',2011),
    ('Milky Chance','milky-chance','Stolen Dance','stolen-dance','Sadnecessary',2013),
    ('The Tallest Man on Earth','the-tallest-man-on-earth','The Gardener','the-gardener','Shallow Grave',2008),
    ('Damien Rice','damien-rice','Cannonball','cannonball','O',2002),
    ('Angus & Julia Stone','angus-and-julia-stone','Big Jet Plane','big-jet-plane','Down the Way',2010),
    ('Ben Howard','ben-howard','Old Pine','old-pine','Every Kingdom',2011),
    ('Mumford & Sons','mumford-and-sons','Little Lion Man','little-lion-man','Sigh No More',2009),
    ('Mumford & Sons','mumford-and-sons','The Cave','the-cave','Sigh No More',2009),
    ('The Paper Kites','the-paper-kites','Bloom','bloom','Woodland',2013),
    ('Gregory Alan Isakov','gregory-alan-isakov','The Stable Song','the-stable-song','That Sea, the Gambler',2007),
    ('Novo Amor','novo-amor','Anchor','anchor','Bathing Beach',2017),
    ('The Civil Wars','the-civil-wars','Poison & Wine','poison-and-wine','Barton Hollow',2011)
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
    ('nick-drake','pink-moon'),('nick-drake','river-man'),('elliott-smith','between-the-bars'),('elliott-smith','angeles'),
    ('jose-gonzalez','heartbeats'),('iron-and-wine','flightless-bird-american-mouth'),('iron-and-wine','naked-as-we-came'),
    ('fleet-foxes','white-winter-hymnal'),('sufjan-stevens','mystery-of-love'),('sufjan-stevens','death-with-dignity'),
    ('bon-iver','holocene'),('first-aid-kit','emmylou'),('edward-sharpe-and-the-magnetic-zeros','home'),
    ('the-head-and-the-heart','rivers-and-roads'),('milky-chance','stolen-dance'),('the-tallest-man-on-earth','the-gardener'),
    ('damien-rice','cannonball'),('angus-and-julia-stone','big-jet-plane'),('ben-howard','old-pine'),
    ('mumford-and-sons','little-lion-man'),('mumford-and-sons','the-cave'),('the-paper-kites','bloom'),
    ('gregory-alan-isakov','the-stable-song'),('novo-amor','anchor'),('the-civil-wars','poison-and-wine')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('nick-drake','pink-moon'),('nick-drake','river-man'),('elliott-smith','between-the-bars'),('elliott-smith','angeles'),
    ('jose-gonzalez','heartbeats'),('iron-and-wine','flightless-bird-american-mouth'),('iron-and-wine','naked-as-we-came'),
    ('fleet-foxes','white-winter-hymnal'),('sufjan-stevens','mystery-of-love'),('sufjan-stevens','death-with-dignity'),
    ('bon-iver','holocene'),('first-aid-kit','emmylou'),('edward-sharpe-and-the-magnetic-zeros','home'),
    ('the-head-and-the-heart','rivers-and-roads'),('milky-chance','stolen-dance'),('the-tallest-man-on-earth','the-gardener'),
    ('damien-rice','cannonball'),('angus-and-julia-stone','big-jet-plane'),('ben-howard','old-pine'),
    ('mumford-and-sons','little-lion-man'),('mumford-and-sons','the-cave'),('the-paper-kites','bloom'),
    ('gregory-alan-isakov','the-stable-song'),('novo-amor','anchor'),('the-civil-wars','poison-and-wine')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('nick-drake','pink-moon'),('nick-drake','river-man'),('elliott-smith','between-the-bars'),('elliott-smith','angeles'),
    ('jose-gonzalez','heartbeats'),('iron-and-wine','flightless-bird-american-mouth'),('iron-and-wine','naked-as-we-came'),
    ('fleet-foxes','white-winter-hymnal'),('sufjan-stevens','mystery-of-love'),('sufjan-stevens','death-with-dignity'),
    ('bon-iver','holocene'),('first-aid-kit','emmylou'),('edward-sharpe-and-the-magnetic-zeros','home'),
    ('the-head-and-the-heart','rivers-and-roads'),('milky-chance','stolen-dance'),('the-tallest-man-on-earth','the-gardener'),
    ('damien-rice','cannonball'),('angus-and-julia-stone','big-jet-plane'),('ben-howard','old-pine'),
    ('mumford-and-sons','little-lion-man'),('mumford-and-sons','the-cave'),('the-paper-kites','bloom'),
    ('gregory-alan-isakov','the-stable-song'),('novo-amor','anchor'),('the-civil-wars','poison-and-wine')
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
    -- ============ THE FINGERPICKING SAINTS ============
    ('pink-moon','nick-drake','guitar','main','fingerpicked pattern','acoustic','folk','rhythm','intermediate',
     'Guild M-20 acoustic (Nick Drake)','Acoustic — close-mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":6,"treble":5,"presence":4,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Recorded in two midnight sessions — dry close-mic''d fingerpicking in one of Drake''s custom tunings.','Bone-dry intimate acoustic; the room barely exists.'],
     array['Drake''s tuning and picking are inseparable — learn the CGCFCE-family voicings.','Steady, private, unhurried.'],
     'Studio recording, 1972. The midnight-session title track.',79),
    ('river-man','nick-drake','guitar','main','fingerpicked pattern','acoustic','folk','rhythm','advanced',
     'Guild/Martin acoustic (Nick Drake)','Acoustic — mic''d with strings','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The 5/4 masterpiece — circular fingerpicking under Harry Robinson''s strings.','Warm soft acoustic; the odd meter flows like water.'],
     array['Count the 5/4 until it stops feeling odd.','The pattern circles hypnotically — no accents.'],
     'Studio recording, 1969. The 5/4 orchestral-folk masterpiece.',78),
    ('between-the-bars','elliott-smith','guitar','main','fingerpicked pattern','acoustic','indie folk','rhythm','intermediate',
     'Acoustic guitar (Elliott Smith)','Acoustic — close-mic''d, double-tracked','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":1,"delay":0,"master":5}'::jsonb,
     array['The whispered addiction waltz — dry double-tracked fingerpicking under a breath-quiet vocal.','Bone-dry close acoustic; Smith''s double-tracking makes one guitar sound like a secret shared twice.'],
     array['Fingerpick the waltz pattern softly.','Whisper-level dynamics throughout.'],
     'Studio recording, 1997. The whispered waltz from Either/Or.',79),
    ('angeles','elliott-smith','guitar','main','fingerpicked pattern','acoustic','indie folk','rhythm','expert',
     'Acoustic guitar (Elliott Smith)','Acoustic — close-mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":1,"delay":0,"master":5}'::jsonb,
     array['Smith''s fingerpicking peak — rapid rolling arpeggios that never stop moving.','Dry intimate acoustic; the pattern shimmers at speed.'],
     array['The rolling pattern is deceptively fast — months of slow practice.','Keep it soft even at tempo; that''s the hard part.'],
     'Studio recording, 1997. Smith''s rolling fingerpicking peak.',79),
    ('heartbeats','jose-gonzalez','guitar','main','classical fingerpicking','acoustic','indie folk','rhythm','advanced',
     'Nylon-string classical (Jose Gonzalez)','Acoustic — close-mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":6,"treble":5,"presence":4,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The Knife cover that conquered the world — hypnotic classical-guitar pattern.','Warm nylon intimacy; the pattern loops like a heartbeat.'],
     array['Nylon strings and fingertips — no pick.','The cross-rhythm pattern needs patient separation.'],
     'Studio recording, 2003. The nylon-string cover that conquered the world.',78),

    -- ============ TWILIGHT-CORE / STOMP FOLK ============
    ('flightless-bird-american-mouth','iron-and-wine','guitar','main','fingerpicked pattern','acoustic','indie folk','rhythm','intermediate',
     'Acoustic guitar (Sam Beam)','Acoustic — mic''d, layered','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The Twilight prom song — hushed layered fingerpicking in 6/8.','Soft warm acoustic; a lullaby that fills a gymnasium.'],
     array['The 6/8 pattern sways; the accordion fills the rest.','Whisper dynamics all the way.'],
     'Studio recording, 2007. The Twilight prom waltz.',76),
    ('naked-as-we-came','iron-and-wine','guitar','main','fingerpicked pattern','acoustic','indie folk','rhythm','intermediate',
     'Acoustic guitar (Sam Beam)','Acoustic — close-mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":2,"delay":0,"master":5}'::jsonb,
     array['Beam''s hushed mortality hymn — gentle rolling fingerpicking, whisper-close.','Dry soft acoustic; the intimacy is total.'],
     array['Roll the pattern evenly under the melody.','Sing it to one person, not a room.'],
     'Studio recording, 2004. The hushed mortality hymn.',76),
    ('white-winter-hymnal','fleet-foxes','guitar','main','strummed pattern','acoustic','indie folk','rhythm','beginner',
     'Acoustic + clean electric (Robin Pecknold / Skyler Skjelset)','Acoustic + warm clean amp with reverb','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"cathedral reverb","placement":"post_gain","settings":{"mix":5,"decay":6}}]'::jsonb,
     '{"gain":1,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":5,"delay":0,"master":6}'::jsonb,
     array['The snow-globe round — warm strums in cathedral reverb under stacked harmonies.','Reverb-washed folk; the voices are the lead instrument.'],
     array['Steady pulsing strums under the round.','Serve the harmony stack completely.'],
     'Studio recording, 2008. The snow-globe harmony round.',75),
    ('mystery-of-love','sufjan-stevens','guitar','main','fingerpicked pattern','acoustic','indie folk','rhythm','advanced',
     'Acoustic guitar (Sufjan Stevens)','Acoustic — close-mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":2,"delay":0,"master":5}'::jsonb,
     array['The Call Me by Your Name heart-wrecker — fast delicate fingerpicking, feather-light.','Bright soft acoustic; intricate but weightless.'],
     array['The rapid pattern must stay whisper-quiet.','Precision without tension.'],
     'Studio recording, 2017. The CMBYN fingerpicked heart-wrecker.',77),
    ('death-with-dignity','sufjan-stevens','guitar','main','fingerpicked pattern','acoustic','indie folk','rhythm','intermediate',
     'Acoustic guitar (Sufjan Stevens)','Acoustic — close-mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":2,"delay":0,"master":5}'::jsonb,
     array['The Carrie & Lowell opener — circling arpeggio pattern under grief laid bare.','Dry intimate acoustic; the pattern breathes with the words.'],
     array['The arpeggio figure circles without resolution — like grief.','Feather dynamics; no drama.'],
     'Studio recording, 2015. The grief-opener arpeggios.',77),
    ('holocene','bon-iver','guitar','main','fingerpicked pattern','acoustic','indie folk','rhythm','intermediate',
     'Acoustic guitar (Justin Vernon)','Acoustic — mic''d with ambience','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The "once I knew I was not magnificent" moment — glassy interlocking picking in open tuning.','Bright spacious acoustic; the pattern glimmers like frost.'],
     array['Open tuning on the record — the shimmer needs the drones.','Interlock the two picking voices patiently.'],
     'Studio recording, 2011. The glass-frost picking from Bon Iver, Bon Iver.',76),

    -- ============ FOLK REVIVAL ============
    ('emmylou','first-aid-kit','guitar','main','main progression','acoustic','folk','rhythm','beginner',
     'Acoustic guitar (Klara Soderberg)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The Swedish sisters'' country-folk hymn — warm open strums under close harmony.','Rich warm acoustic; the harmonies do the shining.'],
     array['Gentle rolling strums in the country waltz.','Leave space for both voices.'],
     'Studio recording, 2012. The harmony-duo country-folk hymn.',75),
    ('home','edward-sharpe-and-the-magnetic-zeros','guitar','main','main progression','acoustic','indie folk','rhythm','beginner',
     'Acoustic guitar (Edward Sharpe band)','Acoustic — mic''d, room sound','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":7}'::jsonb,
     array['The whistled campfire duet — loose joyful strums with the whole band clapping.','Warm roomy acoustic; the sloppiness is love.'],
     array['Bouncing strums under the whistle hook.','Grin at somebody while you play it.'],
     'Studio recording, 2009. The whistled campfire duet.',75),
    ('rivers-and-roads','the-head-and-the-heart','guitar','main','main progression','acoustic','indie folk','rhythm','beginner',
     'Acoustic guitar (Josiah Johnson / Jonathan Russell)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The graduation-season closer — sparse acoustic building to a full-room chorale.','Soft warm acoustic; the build is human voices, not gain.'],
     array['Sparse picking until the voices stack.','Let the final chorus lift you with it.'],
     'Studio recording, 2011. The farewell chorale builder.',75),
    ('stolen-dance','milky-chance','guitar','riff','muted groove riff','clean','indie pop','rhythm','beginner',
     'Acoustic/electric (Clemens Rehbein)','Clean DI, muted groove','Studio direct','neck pickup',
     '[{"effect_type":"compressor","effect_name":"tight compression","placement":"front","settings":{"sustain":5,"level":5}}]'::jsonb,
     '{"gain":1,"bass":5,"mids":6,"treble":5,"presence":4,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['The muted-groove earworm — palm-muted clean pattern locked to the beat.','Dry compressed chug; the muting IS the sound.'],
     array['Palm-mute the pattern with total consistency.','It''s a drum part played on guitar.'],
     'Studio recording, 2013. The muted-groove earworm.',75),
    ('the-gardener','the-tallest-man-on-earth','guitar','main','fingerpicked pattern','acoustic','folk','rhythm','advanced',
     'Acoustic guitar (Kristian Matsson)','Acoustic — close-mic''d, raw','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Dylan-esque fire — bright aggressive fingerpicking in open tuning, recorded raw.','Trebly dry acoustic hit hard; the intensity is percussive.'],
     array['Open tuning; attack the pattern with force.','The drive comes from your right hand, not tempo.'],
     'Studio recording, 2008. The raw open-tuning fire.',76),
    ('cannonball','damien-rice','guitar','main','fingerpicked pattern','acoustic','folk','rhythm','intermediate',
     'Acoustic guitar (Damien Rice)','Acoustic — close-mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":2,"delay":0,"master":5}'::jsonb,
     array['The fragile Irish heartbreaker — delicate picking with sudden dynamic surges.','Hushed dry acoustic that swells without warning.'],
     array['The pattern tiptoes; the surges crash.','Ride the dynamic waves with the vocal.'],
     'Studio recording, 2002. The fragile surging heartbreaker.',76),
    ('big-jet-plane','angus-and-julia-stone','guitar','main','main progression','acoustic','indie folk','rhythm','beginner',
     'Acoustic guitar (Angus Stone)','Acoustic — mic''d with soft ambience','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The drowsy love-drift — lazy warm strums under a half-asleep vocal.','Soft hazy acoustic; slow-motion sunshine.'],
     array['Lazy behind-the-beat strums.','Never wake it up.'],
     'Studio recording, 2010. The drowsy love-drift.',75),
    ('old-pine','ben-howard','guitar','main','percussive fingerstyle','acoustic','folk','rhythm','advanced',
     'Acoustic guitar (Ben Howard)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Howard''s percussive style — slap harmonics, body hits, and rolling picking in an altered tuning.','Woody percussive acoustic; the guitar is also the drum kit.'],
     array['Learn the tuning first, then the slap-and-roll pattern.','The percussion hits live inside the picking pattern.'],
     'Studio recording, 2011. Howard''s percussive open-tuning style.',76),
    ('little-lion-man','mumford-and-sons','guitar','main','driving strums','acoustic','folk rock','rhythm','intermediate',
     'Acoustic guitar + banjo (Marcus Mumford / Winston Marshall)','Acoustic — mic''d, driven hard','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The stomp-folk detonator — furious acoustic strumming with banjo rolls.','Bright percussive acoustic slammed hard; kick-drum energy.'],
     array['Machine-gun strumming stamina.','Choke the stops dead with the band.'],
     'Studio recording, 2009. The stomp-folk detonator.',76),
    ('the-cave','mumford-and-sons','guitar','main','picked verse + stomp chorus','acoustic','folk rock','rhythm','intermediate',
     'Acoustic guitar + banjo (Mumford & Sons)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['Picked restraint into full gallop — the Sigh No More blueprint.','Bright dynamic acoustic; the horns arrive at the peak.'],
     array['Gentle picking until the kick drum says go.','Gallop the chorus strums.'],
     'Studio recording, 2009. The pick-to-gallop blueprint.',75),
    ('bloom','the-paper-kites','guitar','main','fingerpicked pattern','acoustic','indie folk','rhythm','intermediate',
     'Acoustic guitar (Sam Bentley / Christina Lacy)','Acoustic — close-mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":2,"delay":0,"master":5}'::jsonb,
     array['The soft viral duet — interlocking gentle fingerpicking, barely awake.','Feather-soft acoustic; two guitars breathing together.'],
     array['The picking figure is simple but must float.','Duet it if you can — it''s written for two.'],
     'Studio recording, 2013. The soft interlocking viral duet.',75),
    ('the-stable-song','gregory-alan-isakov','guitar','main','fingerpicked pattern','acoustic','indie folk','rhythm','intermediate',
     'Acoustic guitar (Gregory Alan Isakov)','Acoustic — mic''d, warm room','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":3,"delay":0,"master":5}'::jsonb,
     array['The candle-lit prayer — slow warm fingerpicking under a dusty vocal.','Warm dark acoustic; firelight pace.'],
     array['Unhurried picking with long breaths between phrases.','Turn the lights down first.'],
     'Studio recording, 2007. The candle-lit fingerpicked prayer.',75),
    ('anchor','novo-amor','guitar','main','fingerpicked pattern','acoustic','indie folk','rhythm','intermediate',
     'Acoustic guitar (Ali Lacey)','Acoustic — mic''d with ambience','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":4,"delay":0,"master":5}'::jsonb,
     array['The falsetto ache — glassy fingerpicking in soft ambience.','Bright delicate acoustic with a reverb halo.'],
     array['The picking pattern glistens — light fingertips.','Follow the falsetto''s fragility.'],
     'Studio recording, 2017. The glassy falsetto ache.',74),
    ('poison-and-wine','the-civil-wars','guitar','main','fingerpicked duet','acoustic','folk','rhythm','beginner',
     'Acoustic guitar (John Paul White)','Acoustic — close-mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":3,"delay":0,"master":5}'::jsonb,
     array['The devastating duet — sparse picked acoustic under two intertwined voices.','Hushed warm acoustic; the tension lives in the harmony.'],
     array['Minimal picking; maximum restraint.','The voices fight and embrace — stay out of the way.'],
     'Studio recording, 2011. The devastating harmony duet.',75)
) as c(
  song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence
)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;
