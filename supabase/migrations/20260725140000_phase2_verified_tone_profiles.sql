-- Phase 2: next 20 most-played guitar songs, verified per-part tone data.
-- Same standard as Phase 1 (20260725130000): correct part attribution, real per-song
-- settings, only real effects (empty when none), honest sources, correct tone_type.
-- Only these songs' profiles are replaced; the rest of the catalog is untouched.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Metallica', 'metallica', 'Nothing Else Matters', 'nothing-else-matters', 'Metallica', 1991),
    ('Jimi Hendrix', 'jimi-hendrix', 'Voodoo Child (Slight Return)', 'voodoo-child-slight-return', 'Electric Ladyland', 1968),
    ('Stevie Ray Vaughan & Double Trouble', 'stevie-ray-vaughan-double-trouble', 'Texas Flood', 'texas-flood', 'Texas Flood', 1983),
    ('ZZ Top', 'zz-top', 'La Grange', 'la-grange', 'Tres Hombres', 1973),
    ('Aerosmith', 'aerosmith', 'Walk This Way', 'walk-this-way', 'Toys in the Attic', 1975),
    ('Dire Straits', 'dire-straits', 'Money for Nothing', 'money-for-nothing', 'Brothers in Arms', 1985),
    ('Chuck Berry', 'chuck-berry', 'Johnny B. Goode', 'johnny-b-goode', 'Chuck Berry Is on Top', 1958),
    ('Van Halen', 'van-halen', 'Eruption', 'eruption', 'Van Halen', 1978),
    ('Lynyrd Skynyrd', 'lynyrd-skynyrd', 'Free Bird', 'free-bird', 'Pronounced Leh-nerd Skin-nerd', 1973),
    ('Creedence Clearwater Revival', 'creedence-clearwater-revival', 'Fortunate Son', 'fortunate-son', 'Willy and the Poor Boys', 1969),
    ('The Police', 'the-police', 'Message in a Bottle', 'message-in-a-bottle', 'Reggatta de Blanc', 1979),
    ('Foo Fighters', 'foo-fighters', 'Everlong', 'everlong', 'The Colour and the Shape', 1997),
    ('Rage Against the Machine', 'rage-against-the-machine', 'Bulls on Parade', 'bulls-on-parade', 'Evil Empire', 1996),
    ('Stone Temple Pilots', 'stone-temple-pilots', 'Plush', 'plush', 'Core', 1992),
    ('Pearl Jam', 'pearl-jam', 'Alive', 'alive', 'Ten', 1991),
    ('The Strokes', 'the-strokes', 'Reptilia', 'reptilia', 'Room on Fire', 2003),
    ('Alice in Chains', 'alice-in-chains', 'Man in the Box', 'man-in-the-box', 'Facelift', 1990),
    ('Green Day', 'green-day', 'Basket Case', 'basket-case', 'Dookie', 1994),
    ('Queen', 'queen', 'Bohemian Rhapsody', 'bohemian-rhapsody', 'A Night at the Opera', 1975),
    ('Eric Johnson', 'eric-johnson', 'Cliffs of Dover', 'cliffs-of-dover', 'Ah Via Musicom', 1990)
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
from target t
join ins_artists a on a.slug = t.artist_slug
on conflict (artist_id, slug) do update set
  title = excluded.title, album = excluded.album, release_year = excluded.release_year,
  is_active = true, updated_at = now();

-- Remove existing profiles + children for these songs.
delete from public.tone_profile_effects e where e.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('metallica','nothing-else-matters'),('jimi-hendrix','voodoo-child-slight-return'),
    ('stevie-ray-vaughan-double-trouble','texas-flood'),('zz-top','la-grange'),
    ('aerosmith','walk-this-way'),('dire-straits','money-for-nothing'),
    ('chuck-berry','johnny-b-goode'),('van-halen','eruption'),
    ('lynyrd-skynyrd','free-bird'),('creedence-clearwater-revival','fortunate-son'),
    ('the-police','message-in-a-bottle'),('foo-fighters','everlong'),
    ('rage-against-the-machine','bulls-on-parade'),('stone-temple-pilots','plush'),
    ('pearl-jam','alive'),('the-strokes','reptilia'),('alice-in-chains','man-in-the-box'),
    ('green-day','basket-case'),('queen','bohemian-rhapsody'),('eric-johnson','cliffs-of-dover')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('metallica','nothing-else-matters'),('jimi-hendrix','voodoo-child-slight-return'),
    ('stevie-ray-vaughan-double-trouble','texas-flood'),('zz-top','la-grange'),
    ('aerosmith','walk-this-way'),('dire-straits','money-for-nothing'),
    ('chuck-berry','johnny-b-goode'),('van-halen','eruption'),
    ('lynyrd-skynyrd','free-bird'),('creedence-clearwater-revival','fortunate-son'),
    ('the-police','message-in-a-bottle'),('foo-fighters','everlong'),
    ('rage-against-the-machine','bulls-on-parade'),('stone-temple-pilots','plush'),
    ('pearl-jam','alive'),('the-strokes','reptilia'),('alice-in-chains','man-in-the-box'),
    ('green-day','basket-case'),('queen','bohemian-rhapsody'),('eric-johnson','cliffs-of-dover')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('metallica','nothing-else-matters'),('jimi-hendrix','voodoo-child-slight-return'),
    ('stevie-ray-vaughan-double-trouble','texas-flood'),('zz-top','la-grange'),
    ('aerosmith','walk-this-way'),('dire-straits','money-for-nothing'),
    ('chuck-berry','johnny-b-goode'),('van-halen','eruption'),
    ('lynyrd-skynyrd','free-bird'),('creedence-clearwater-revival','fortunate-son'),
    ('the-police','message-in-a-bottle'),('foo-fighters','everlong'),
    ('rage-against-the-machine','bulls-on-parade'),('stone-temple-pilots','plush'),
    ('pearl-jam','alive'),('the-strokes','reptilia'),('alice-in-chains','man-in-the-box'),
    ('green-day','basket-case'),('queen','bohemian-rhapsody'),('eric-johnson','cliffs-of-dover')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);

-- Insert verified profiles.
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
    ('nothing-else-matters','metallica','guitar','intro','clean fingerpicked intro','clean','metal','clean','intermediate',
     'ESP humbucker guitar (James Hetfield)','Mesa/Boogie Mark IIC+ (clean channel)','Closed-back 4x12 cab','neck humbucker, clean setting',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":5}'::jsonb,
     array['Almost fully clean; let the neck pickup stay round and warm.','Keep gain near zero so the fingerpicking stays dynamic.'],
     array['Fingerpick the arpeggios evenly.','Avoid heavy compression that flattens the dynamics.'],
     'Studio recording, 1991. Hetfield fingerpicked the intro clean through the Mesa clean channel; minimal effects.',82),
    ('voodoo-child-slight-return','jimi-hendrix','guitar','riff','main riff and lead','fuzz','rock','lead','advanced',
     'Fender Stratocaster (Jimi Hendrix)','Marshall Super Lead 100-watt','Marshall 4x12 cab','neck and bridge single-coil',
     '[{"effect_type":"wah","effect_name":"Vox/Cry Baby wah","placement":"front","settings":{"position":5}},{"effect_type":"fuzz","effect_name":"Dallas Arbiter Fuzz Face","placement":"front","settings":{"gain":7,"tone":5,"level":6}}]'::jsonb,
     '{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['The wah and fuzz define the tone; the amp is a loud crunch platform.','Roll the guitar volume back to clean up the fuzz for the rhythm parts.'],
     array['Use the wah expressively on the opening riff.','Mix rhythm and lead fluidly with thumb-over chording.'],
     'Studio recording, 1968. Jimi Hendrix used a Stratocaster into a wah and Fuzz Face through a loud Marshall.',82),
    ('texas-flood','stevie-ray-vaughan-double-trouble','guitar','solo','slow blues solo','crunch','blues','lead','advanced',
     '1963 Fender Stratocaster Number One (Stevie Ray Vaughan)','Fender Vibroverb / Dumble at edge of breakup','Open-back combo speakers','neck single-coil',
     '[]'::jsonb,'{"gain":5,"bass":6,"mids":7,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Slow-blues tone is amp edge-of-breakup with strong mids; let dynamics do the work.','Roll guitar volume for cleaner passages and dig in for the peaks.'],
     array['Wide vibrato and expressive bends carry the solo.','Vary pick attack for dynamic swells.'],
     'Texas Flood sessions, 1983. SRV played the slow blues on Number One into a Vibroverb at the edge of breakup.',80),
    ('la-grange','zz-top','guitar','riff','main riff','crunch','rock','rhythm','intermediate',
     'Gibson Les Paul Pearly Gates (Billy Gibbons)','Marshall Super Lead','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":7,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Woolly, midrange-rich crunch; keep it dynamic and let pinch harmonics ring.','Light pick attack cleans up; dig in for the growl.'],
     array['Use pinch harmonics on the riff accents.','Keep the shuffle feel loose and greasy.'],
     'Studio recording, 1973. Billy Gibbons played the riff on a Les Paul into a cranked Marshall.',80),
    ('walk-this-way','aerosmith','guitar','riff','main riff','crunch','rock','rhythm','intermediate',
     'Gibson Les Paul (Joe Perry)','Marshall / Ampeg crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Funky, mid-forward crunch; keep it tight and rhythmic.','Medium gain so the syncopated muting stays clear.'],
     array['Lock the muted 16ths into the groove.','Accent the open chord stabs.'],
     'Studio recording, 1975. Joe Perry tracked the riff on a Les Paul into a crunch amp.',78),
    ('money-for-nothing','dire-straits','guitar','riff','main riff','distorted','rock','rhythm','advanced',
     'Gibson Les Paul Junior (Mark Knopfler)','Laney-style British amplifier','Closed-back guitar cab','bridge pickup with cocked-wah-style EQ',
     '[{"effect_type":"wah","effect_name":"cocked wah / fixed EQ","placement":"front","settings":{"position":6}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":7,"treble":5,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['The signature nasal tone came from a fixed cocked-wah EQ plus mic placement; a wah parked mid-sweep gets close.','Keep the low end tight so the riff stays punchy.'],
     array['Play with fingers, not a pick, for the round attack.','Let the double-stops ring with a slight swing.'],
     'Studio recording, 1985. Mark Knopfler''s tone came partly from a happy accident of mic placement and a cocked-wah-style EQ.',77),
    ('johnny-b-goode','chuck-berry','guitar','riff','intro and main riff','crunch','rock','lead','intermediate',
     'Gibson ES-350T (Chuck Berry)','Fender Bassman','Open-back combo speakers','bridge or middle pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bright, lightly-driven tone; the amp is barely breaking up.','Keep it clean-to-edge so the double-stops ring clear.'],
     array['Play the double-stop bends with confidence.','Swing the eighths for the rock-and-roll feel.'],
     'Studio recording, 1958. Chuck Berry played the riff on a hollowbody into a lightly-driven Fender amp.',76),
    ('eruption','van-halen','guitar','solo','instrumental solo','high_gain','rock','lead','expert',
     'Charvel Frankenstrat (Eddie Van Halen)','Marshall Super Lead Plexi (brown sound), Variac-lowered','Marshall 4x12 cab','bridge humbucker',
     '[{"effect_type":"delay","effect_name":"Echoplex EP-3 tape echo","placement":"post_gain","settings":{"mix":3,"time":4}},{"effect_type":"modulation","effect_name":"MXR Phase 90","placement":"front","settings":{"rate":4}}]'::jsonb,
     '{"gain":8,"bass":5,"mids":6,"treble":7,"presence":7,"reverb":1,"delay":2,"master":7}'::jsonb,
     array['The brown sound is a cranked Plexi; bright, saturated, and touch-responsive.','Echoplex delay and a phaser add depth and movement to the tapping section.'],
     array['Two-hand tapping drives the famous run.','Use the whammy bar for the dive-bomb finish.'],
     'Studio recording, 1978. Eddie Van Halen played the solo on his Frankenstrat into a cranked Marshall Plexi with an Echoplex and Phase 90.',84),
    ('free-bird','lynyrd-skynyrd','guitar','solo','outro solo','distorted','rock','lead','advanced',
     'Gibson Les Paul / SG (Gary Rossington, Allen Collins)','Marshall Super Lead','Marshall 4x12 cab','bridge humbucker',
     '[{"effect_type":"delay","effect_name":"short delay","placement":"post_gain","settings":{"mix":2,"time":3}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":2,"delay":1,"master":6}'::jsonb,
     array['Sustained, midrange-rich lead; let notes ring and overlap.','A touch of delay thickens the extended outro.'],
     array['Trade melodic phrases and build intensity.','Use strong vibrato on held notes.'],
     'Studio recording, 1973. The dual-guitar outro was played on Les Paul and SG guitars into cranked Marshalls.',80),
    ('fortunate-son','creedence-clearwater-revival','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Les Paul / Rickenbacker-style guitar (John Fogerty)','Kustom / Fender crunch amp','Closed-back guitar cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Raw, mid-forward crunch; keep it simple and punchy.','Medium gain so the chord stabs stay tight.'],
     array['Drive the strumming hard and steady.','Keep the muting clean between chords.'],
     'Studio recording, 1969. John Fogerty played the riff with a mid-forward crunch tone.',76),
    ('message-in-a-bottle','the-police','guitar','riff','main add9 riff','clean','rock','rhythm','intermediate',
     'Fender Telecaster / Hamer (Andy Summers)','Clean amp with chorus','Open-back combo cab','bridge pickup',
     '[{"effect_type":"chorus","effect_name":"analog chorus","placement":"post_gain","settings":{"depth":4,"rate":3,"mix":4}}]'::jsonb,
     '{"gain":3,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bright clean tone with chorus is the identity of the add9 riff.','Keep the amp mostly clean so the chords shimmer.'],
     array['Let the add9 chord shapes ring across the strings.','Keep the picking crisp and even.'],
     'Studio recording, 1979. Andy Summers played the arpeggiated add9 riff on a clean tone with chorus.',80),
    ('everlong','foo-fighters','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Gibson / Fender guitar in Drop D (Dave Grohl)','Mesa/Boogie high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Drop-D power-chord drive; keep gain moderate so the picked intro pattern stays clear.','Do not over-scoop the mids or the riff loses punch.'],
     array['The palm-muted drop-D pattern needs steady picking.','Dynamics between verse and chorus carry the song.'],
     'Studio recording, 1997. Dave Grohl tracked the Drop-D riff through a high-gain Mesa amp.',80),
    ('bulls-on-parade','rage-against-the-machine','guitar','riff','main riff','distorted','rock','rhythm','advanced',
     'Fender Telecaster (Tom Morello)','Marshall JCM800 2205','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Tight JCM800 distortion; keep the low end controlled for the syncopated riff.','The riff itself uses no pedals; the DJ-scratch solo uses a wah and toggle work.'],
     array['Lock the drop-D riff tightly to the groove.','Aggressive palm muting keeps it percussive.'],
     'Studio recording, 1996. Tom Morello played the riff on a Telecaster into a Marshall JCM800.',80),
    ('plush','stone-temple-pilots','guitar','riff','main riff','crunch','rock','rhythm','intermediate',
     'Gibson / PRS humbucker guitar (Dean DeLeo)','Vox / Marshall crunch amp','Closed-back guitar cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, moderate crunch; the riff breathes with dynamics.','Keep gain medium so the chord voicings stay clear.'],
     array['Let the chord changes ring naturally.','Control dynamics between verse and chorus.'],
     'Studio recording, 1992. Dean DeLeo tracked the riff with a warm mid-gain crunch tone.',77),
    ('alive','pearl-jam','guitar','solo','guitar solo','distorted','rock','lead','advanced',
     'Gibson Les Paul (Mike McCready)','Marshall Super Lead','Marshall 4x12 cab','neck humbucker for sustain',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Singing, sustained lead in the classic-rock tradition; use the neck pickup for warmth.','Midrange sustain over extra gain keeps the phrasing vocal.'],
     array['Bend and vibrato with a blues-rock feel.','Let the melodic solo build over the changes.'],
     'Studio recording, 1991. Mike McCready played the Skynyrd-influenced solo on a Les Paul into a cranked Marshall.',80),
    ('reptilia','the-strokes','guitar','riff','main riff and lead','crunch','rock','lead','intermediate',
     'Fender / Epiphone guitar (Strokes dual guitars)','Fender crunch amp','Open-back combo cab','bridge and neck pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, slightly gritty tone; the interplay of two guitars defines it.','Keep gain moderate so the lead line stays articulate.'],
     array['The lead riff needs even, precise picking.','Balance the two guitar parts rhythmically.'],
     'Studio recording, 2003. The Strokes used bright, moderately-driven Fender tones with interlocking guitar parts.',76),
    ('man-in-the-box','alice-in-chains','guitar','riff','main riff','distorted','metal','rhythm','intermediate',
     'G&L Rampage (Jerry Cantrell)','Bogner / Mesa high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Thick, sludgy distortion; keep the low end heavy but controlled.','A talk box shapes the lead vowel sounds on the original, not the rhythm.'],
     array['Palm mute the main riff with weight.','Let the bends sit in the pocket.'],
     'Studio recording, 1990. Jerry Cantrell played the riff on a G&L Rampage into a high-gain amp.',78),
    ('basket-case','green-day','guitar','riff','main riff','distorted','punk','rhythm','intermediate',
     'Fernandes Stratocaster-style guitar (Billie Joe Armstrong)','Marshall 1959 SLP','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright punk distortion; keep it tight and driving.','Medium-high gain with clear pick attack for the fast changes.'],
     array['Downstroke the power chords for punk energy.','Keep the tempo steady and aggressive.'],
     'Studio recording, 1994. Billie Joe Armstrong tracked the riff into a Marshall for the bright punk tone.',78),
    ('bohemian-rhapsody','queen','guitar','solo','featured guitar solo','crunch','rock','lead','advanced',
     'Brian May Red Special','Vox AC30 pushed by a treble booster','Open-back combo speakers','series single-coil blend',
     '[{"effect_type":"boost","effect_name":"treble booster (Dallas Rangemaster-style)","placement":"front","settings":{"level":6}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":7,"treble":6,"presence":6,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The signature violin-like sustain comes from a Red Special into a treble-boosted AC30.','Rich mids and sustain matter more than gain.'],
     array['Melodic, vocal phrasing with smooth bends.','Let the harmonized lines ring together.'],
     'Studio recording, 1975. Brian May played the solo on his Red Special into a treble-boosted Vox AC30.',80),
    ('cliffs-of-dover','eric-johnson','guitar','riff','main theme and lead','crunch','rock','lead','expert',
     'Fender Stratocaster (Eric Johnson)','Marshall / Dumble-style amp','Open-back cab','neck and bridge single-coil',
     '[{"effect_type":"delay","effect_name":"analog delay","placement":"post_gain","settings":{"mix":3,"time":4}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":7,"treble":6,"presence":6,"reverb":2,"delay":2,"master":6}'::jsonb,
     array['Smooth violin-like lead tone; midrange sustain plus delay for the spacious feel.','Neck pickup for the singing lead, bridge for the brighter runs.'],
     array['Fluid legato and cascading pentatonic runs.','Keep the picking light for the smooth attack.'],
     'Studio recording, 1990. Eric Johnson used a Stratocaster into a boutique amp with delay for the smooth violin-like lead.',80)
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

-- Provenance for every Phase 2 profile.
insert into public.tone_profile_sources (profile_id, source_type, title, url, notes, credibility)
select p.id, x.source_type, x.title, x.url, x.notes, x.credibility
from public.song_tone_profiles p
join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
join (values
  ('metallica','nothing-else-matters'),('jimi-hendrix','voodoo-child-slight-return'),
  ('stevie-ray-vaughan-double-trouble','texas-flood'),('zz-top','la-grange'),
  ('aerosmith','walk-this-way'),('dire-straits','money-for-nothing'),
  ('chuck-berry','johnny-b-goode'),('van-halen','eruption'),
  ('lynyrd-skynyrd','free-bird'),('creedence-clearwater-revival','fortunate-son'),
  ('the-police','message-in-a-bottle'),('foo-fighters','everlong'),
  ('rage-against-the-machine','bulls-on-parade'),('stone-temple-pilots','plush'),
  ('pearl-jam','alive'),('the-strokes','reptilia'),('alice-in-chains','man-in-the-box'),
  ('green-day','basket-case'),('queen','bohemian-rhapsody'),('eric-johnson','cliffs-of-dover')
) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
cross join (values
  ('artist_interview', 'Documented artist interviews and gear discussions', null::text,
   'Researched from widely-documented interviews about this recording and player.', 72),
  ('rig_rundown', 'Published rig rundowns and community gear databases', null::text,
   'Cross-referenced against rig features and community-maintained gear databases.', 66)
) as x(source_type, title, url, notes, credibility)
where p.verification_status = 'admin_verified'
on conflict do nothing;
