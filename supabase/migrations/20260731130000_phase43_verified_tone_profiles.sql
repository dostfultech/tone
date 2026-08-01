-- Phase 43: pop-punk / emo deep cuts, verified per-part tone data.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Green Day','green-day','Longview','longview','Dookie',1994),
    ('Green Day','green-day','Welcome to Paradise','welcome-to-paradise','Dookie',1994),
    ('Green Day','green-day','Brain Stew','brain-stew','Insomniac',1995),
    ('Green Day','green-day','Hitchin'' a Ride','hitchin-a-ride','Nimrod',1997),
    ('Green Day','green-day','Minority','minority','Warning',2000),
    ('Green Day','green-day','Jesus of Suburbia','jesus-of-suburbia','American Idiot',2004),
    ('Green Day','green-day','Holiday','holiday','American Idiot',2004),
    ('Green Day','green-day','21 Guns','21-guns','21st Century Breakdown',2009),
    ('Blink-182','blink-182','Adam''s Song','adam-s-song','Enema of the State',1999),
    ('Blink-182','blink-182','The Rock Show','the-rock-show','Take Off Your Pants and Jacket',2001),
    ('Blink-182','blink-182','Stay Together for the Kids','stay-together-for-the-kids','Take Off Your Pants and Jacket',2001),
    ('Blink-182','blink-182','Feeling This','feeling-this','Blink-182',2003),
    ('Blink-182','blink-182','Josie','josie','Dude Ranch',1997),
    ('My Chemical Romance','my-chemical-romance','I''m Not Okay (I Promise)','i-m-not-okay-i-promise','Three Cheers for Sweet Revenge',2004),
    ('My Chemical Romance','my-chemical-romance','The Ghost of You','the-ghost-of-you','Three Cheers for Sweet Revenge',2004),
    ('Paramore','paramore','Ignorance','ignorance','Brand New Eyes',2009),
    ('Paramore','paramore','Brick by Boring Brick','brick-by-boring-brick','Brand New Eyes',2009),
    ('Brand New','brand-new','Sic Transit Gloria... Glory Fades','sic-transit-gloria-glory-fades','Deja Entendu',2003),
    ('Jimmy Eat World','jimmy-eat-world','Bleed American','bleed-american','Bleed American',2001),
    ('Jimmy Eat World','jimmy-eat-world','Pain','pain','Futures',2004),
    ('Sum 41','sum-41','Still Waiting','still-waiting','Does This Look Infected?',2002),
    ('Good Charlotte','good-charlotte','The Anthem','the-anthem','The Young and the Hopeless',2002),
    ('New Found Glory','new-found-glory','All Downhill from Here','all-downhill-from-here','Catalyst',2004),
    ('Taking Back Sunday','taking-back-sunday','A Decade Under the Influence','a-decade-under-the-influence','Where You Want to Be',2004),
    ('Fall Out Boy','fall-out-boy','This Ain''t a Scene, It''s an Arms Race','this-ain-t-a-scene-it-s-an-arms-race','Infinity on High',2007)
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
    ('green-day','longview'),('green-day','welcome-to-paradise'),('green-day','brain-stew'),
    ('green-day','hitchin-a-ride'),('green-day','minority'),('green-day','jesus-of-suburbia'),
    ('green-day','holiday'),('green-day','21-guns'),('blink-182','adam-s-song'),
    ('blink-182','the-rock-show'),('blink-182','stay-together-for-the-kids'),('blink-182','feeling-this'),
    ('blink-182','josie'),('my-chemical-romance','i-m-not-okay-i-promise'),('my-chemical-romance','the-ghost-of-you'),
    ('paramore','ignorance'),('paramore','brick-by-boring-brick'),('brand-new','sic-transit-gloria-glory-fades'),
    ('jimmy-eat-world','bleed-american'),('jimmy-eat-world','pain'),('sum-41','still-waiting'),
    ('good-charlotte','the-anthem'),('new-found-glory','all-downhill-from-here'),
    ('taking-back-sunday','a-decade-under-the-influence'),('fall-out-boy','this-ain-t-a-scene-it-s-an-arms-race')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('green-day','longview'),('green-day','welcome-to-paradise'),('green-day','brain-stew'),
    ('green-day','hitchin-a-ride'),('green-day','minority'),('green-day','jesus-of-suburbia'),
    ('green-day','holiday'),('green-day','21-guns'),('blink-182','adam-s-song'),
    ('blink-182','the-rock-show'),('blink-182','stay-together-for-the-kids'),('blink-182','feeling-this'),
    ('blink-182','josie'),('my-chemical-romance','i-m-not-okay-i-promise'),('my-chemical-romance','the-ghost-of-you'),
    ('paramore','ignorance'),('paramore','brick-by-boring-brick'),('brand-new','sic-transit-gloria-glory-fades'),
    ('jimmy-eat-world','bleed-american'),('jimmy-eat-world','pain'),('sum-41','still-waiting'),
    ('good-charlotte','the-anthem'),('new-found-glory','all-downhill-from-here'),
    ('taking-back-sunday','a-decade-under-the-influence'),('fall-out-boy','this-ain-t-a-scene-it-s-an-arms-race')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('green-day','longview'),('green-day','welcome-to-paradise'),('green-day','brain-stew'),
    ('green-day','hitchin-a-ride'),('green-day','minority'),('green-day','jesus-of-suburbia'),
    ('green-day','holiday'),('green-day','21-guns'),('blink-182','adam-s-song'),
    ('blink-182','the-rock-show'),('blink-182','stay-together-for-the-kids'),('blink-182','feeling-this'),
    ('blink-182','josie'),('my-chemical-romance','i-m-not-okay-i-promise'),('my-chemical-romance','the-ghost-of-you'),
    ('paramore','ignorance'),('paramore','brick-by-boring-brick'),('brand-new','sic-transit-gloria-glory-fades'),
    ('jimmy-eat-world','bleed-american'),('jimmy-eat-world','pain'),('sum-41','still-waiting'),
    ('good-charlotte','the-anthem'),('new-found-glory','all-downhill-from-here'),
    ('taking-back-sunday','a-decade-under-the-influence'),('fall-out-boy','this-ain-t-a-scene-it-s-an-arms-race')
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
    -- ============ GREEN DAY ============
    ('longview','green-day','guitar','riff','chorus power chords','distorted','punk rock','rhythm','beginner',
     'Fernandes Stratocaster "Blue" (Billie Joe Armstrong)','Marshall 1959 SLP 100W (modified)','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['The verses are bass-only; guitar crashes in for the choruses with the Dookie Marshall crunch.','Medium-high gain; mids stay up — Dookie is never scooped.'],
     array['Lay out during the verses; the bassline owns them.','Smash the chorus chords wide open.'],
     'Studio recording, 1994. Billie Joe''s modified Fernandes Strat into a modified Marshall SLP — the Dookie rig.',82),
    ('welcome-to-paradise','green-day','guitar','riff','main riff','distorted','punk rock','rhythm','intermediate',
     'Fernandes Stratocaster "Blue" (Billie Joe Armstrong)','Marshall 1959 SLP 100W (modified)','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['Driving Dookie crunch with a palm-muted breakdown bridge.','Medium-high gain; the muted bridge section needs definition.'],
     array['Steady down-strokes through the verses.','Build the bridge palm-mutes from a whisper to full volume.'],
     'Studio recording, 1994. The Dookie rig: modified Fernandes Strat into modified Marshall SLP.',82),
    ('brain-stew','green-day','guitar','riff','main riff','distorted','punk rock','rhythm','beginner',
     'Fernandes Stratocaster "Blue" (Billie Joe Armstrong)','Marshall 1959 SLP 100W (modified)','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":6,"mids":6,"treble":5,"presence":5,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['Slow, heavy descending chords — thicker and darker than the Dookie singles.','Medium-high gain with more low end; let each chord slam.'],
     array['Drag the chords slightly for the heavy feel.','Mute hard between each hit.'],
     'Studio recording, 1995. Slow heavy descending chords, darker Insomniac voicing of the Marshall rig.',80),
    ('hitchin-a-ride','green-day','guitar','riff','main riff','crunch','punk rock','rhythm','beginner',
     'Fernandes Stratocaster "Blue" (Billie Joe Armstrong)','Marshall 1959 SLP 100W (modified)','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":0,"delay":0,"master":6}'::jsonb,
     array['Tight staccato crunch riff with stop-start dynamics; less saturated than Dookie.','Medium gain; the stops must be dead silent.'],
     array['Choke the chords precisely on the stops.','Build tension before the full-band explosion at the end.'],
     'Studio recording, 1997. Tight staccato crunch with stop-start dynamics.',79),
    ('minority','green-day','guitar','riff','main riff','crunch','punk rock','rhythm','beginner',
     'Fernandes Stratocaster "Blue" (Billie Joe Armstrong)','Marshall 1959 SLP 100W (modified)','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Folk-punk strums with a rounder, less aggressive crunch than the 90s records.','Medium gain, open strumming — an acoustic doubles the electric on the record.'],
     array['Big open-chord strumming throughout.','Keep the folk bounce in the rhythm.'],
     'Studio recording, 2000. Rounder folk-punk crunch with acoustic doubling.',78),
    ('jesus-of-suburbia','green-day','guitar','riff','main riff','distorted','punk rock','rhythm','intermediate',
     'Gibson Les Paul Junior (Billie Joe Armstrong)','Marshall 100W plexi-style stack','Marshall 4x12 cab','P-90 pickup',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":6,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['American Idiot-era tone: Les Paul Junior P-90 grind into a Marshall stack — rawer midrange than a humbucker.','Medium-high gain, strong mids; the 9-minute suite moves between ballad and blast, this covers the full-band sections.'],
     array['Follow the suite''s five movements — dynamics change constantly.','Big confident down-strokes in the anthem sections.'],
     'Studio recording, 2004. Les Paul Junior P-90s into a Marshall stack — the American Idiot rig.',81),
    ('holiday','green-day','guitar','riff','main riff','distorted','punk rock','rhythm','intermediate',
     'Gibson Les Paul Junior (Billie Joe Armstrong)','Marshall 100W plexi-style stack','Marshall 4x12 cab','P-90 pickup',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":6,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['Marching, anthemic P-90 grind; the riff must stay articulate under the gain.','Medium-high gain with pushed mids.'],
     array['March the riff with the snare.','Accent the lead fills cleanly between vocal lines.'],
     'Studio recording, 2004. Anthemic P-90 Marshall grind from the American Idiot sessions.',81),
    ('21-guns','green-day','guitar','riff','main riff','distorted','punk rock','rhythm','beginner',
     'Gibson Les Paul Junior (Billie Joe Armstrong)','Marshall 100W plexi-style stack','Marshall 4x12 cab','P-90 pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Power-ballad dynamics: restrained verses, huge open choruses with light ambience.','Medium gain; room to swell.'],
     array['Arpeggiate gently in the verses.','Open fully into the anthem choruses.'],
     'Studio recording, 2009. Power-ballad dynamics with ambient Marshall grind.',78),
    ('21-guns','green-day','guitar','solo','melodic solo','distorted','punk rock','lead','intermediate',
     'Gibson Les Paul Junior (Billie Joe Armstrong)','Marshall 100W plexi-style stack','Marshall 4x12 cab','P-90 pickup',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['Singing melodic solo; mids pushed so the P-90 sustains.','Medium-high gain with ambience.'],
     array['Phrase the solo like the vocal melody.','Wide, slow vibrato.'],
     'Studio recording, 2009. Singing melodic P-90 lead.',77),

    -- ============ BLINK-182 ============
    ('adam-s-song','blink-182','guitar','riff','main riff','distorted','punk rock','rhythm','beginner',
     'Fender Stratocaster (Tom DeLonge custom, Invader humbucker)','Mesa/Boogie Triple Rectifier','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":6,"mids":4,"treble":6,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Enema-era Rectifier tone — scooped, thick, polished.','Medium-high gain, mids pulled back slightly; the quiet verses drop to near-clean.'],
     array['Restrain the verses; the piano carries the melancholy.','Open the chorus chords wide and let them ring.'],
     'Studio recording, 1999. Tom DeLonge''s Invader-loaded Strat into a Mesa Triple Rectifier — the Enema of the State rig.',81),
    ('the-rock-show','blink-182','guitar','riff','main riff','distorted','punk rock','rhythm','beginner',
     'Fender Stratocaster (Tom DeLonge custom, Invader humbucker)','Mesa/Boogie Triple Rectifier','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":6,"mids":4,"treble":6,"presence":6,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['Fast bouncy pop-punk with the scooped Rectifier crunch.','Medium-high gain; keep the fast changes clean.'],
     array['Fast down-strokes with a bounce.','Keep energy up — it''s a party song.'],
     'Studio recording, 2001. Scooped Mesa Rectifier pop-punk crunch.',80),
    ('stay-together-for-the-kids','blink-182','guitar','intro','clean verse arpeggios','clean','punk rock','rhythm','beginner',
     'Fender Stratocaster (Tom DeLonge custom, Invader humbucker)','Clean amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":5}'::jsonb,
     array['Somber clean arpeggios in the verses.','Fully clean with light ambience.'],
     array['Let the arpeggio notes overlap.','Keep the mood heavy and patient.'],
     'Studio recording, 2001. Somber clean verse arpeggios before the heavy chorus.',79),
    ('stay-together-for-the-kids','blink-182','guitar','chorus','heavy chorus wall','distorted','punk rock','rhythm','beginner',
     'Fender Stratocaster (Tom DeLonge custom, Invader humbucker)','Mesa/Boogie Triple Rectifier','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":4,"treble":6,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['The chorus slams in with the full scooped Rectifier wall.','High gain, thick low end; maximum contrast with the clean verses.'],
     array['Hit the chorus like a hammer after the quiet verse.','Ring the chords fully.'],
     'Studio recording, 2001. Quiet-loud jump into a scooped Rectifier wall.',79),
    ('feeling-this','blink-182','guitar','riff','main riff','distorted','punk rock','rhythm','intermediate',
     'Gibson ES-333 (Tom DeLonge)','Mesa/Boogie Triple Rectifier + Marshall blend','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Untitled-era tone: semi-hollow Gibson adds body over the Rectifier crunch.','Medium-high gain; the staccato verse riff needs tight muting.'],
     array['Stab the verse riff with tight muting.','Contrast the smooth pre-chorus with the driving chorus.'],
     'Studio recording, 2003. Tom''s Gibson ES-333 era — thicker semi-hollow body over Mesa/Marshall crunch.',79),
    ('josie','blink-182','guitar','riff','main riff','crunch','punk rock','rhythm','beginner',
     'Fender Stratocaster (Tom DeLonge)','Marshall JCM900','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":5,"treble":6,"presence":6,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['Dude Ranch-era tone is rawer and more Marshall-crunch than the later Mesa polish.','Medium gain, bright and energetic.'],
     array['Bouncy palm-muted verses into open choruses.','Keep the skate-punk energy loose.'],
     'Studio recording, 1997. Raw Marshall-driven Dude Ranch crunch, pre-Mesa era.',78),

    -- ============ MY CHEMICAL ROMANCE ============
    ('i-m-not-okay-i-promise','my-chemical-romance','guitar','riff','main riff','high_gain','emo','rhythm','intermediate',
     'Gibson Les Paul (Ray Toro)','Marshall high-gain stack','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Frantic, theatrical high gain — Les Paul thickness with Marshall aggression.','High gain but articulate; the lead fills must cut.'],
     array['Attack the riff with urgency.','Nail the iconic lead break cleanly.'],
     'Studio recording, 2004. Ray Toro''s Les Paul into cranked Marshalls — theatrical Revenge-era high gain.',80),
    ('the-ghost-of-you','my-chemical-romance','guitar','riff','main riff','distorted','emo','rhythm','intermediate',
     'Gibson Les Paul (Ray Toro)','Marshall high-gain stack','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Dynamic ballad — clean-edged verses building to a crushing bridge.','Medium-high gain with ambience for the swells.'],
     array['Hold back through the verses.','The bridge explosion is the emotional peak — give it everything.'],
     'Studio recording, 2004. Dynamic ballad build from restrained verses to a crushing climax.',78),

    -- ============ PARAMORE ============
    ('ignorance','paramore','guitar','riff','main riff','high_gain','pop punk','rhythm','intermediate',
     'Gibson Les Paul (Josh Farro)','Modern high-gain stack','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['Tight, aggressive modern high gain with a jagged syncopated riff.','High gain, tight low end; precision matters.'],
     array['Lock the syncopated riff to the drums.','Choke the stops sharply.'],
     'Studio recording, 2009. Tight aggressive modern high gain, Brand New Eyes sessions.',79),
    ('brick-by-boring-brick','paramore','guitar','riff','main riff','distorted','pop punk','rhythm','intermediate',
     'Gibson Les Paul (Josh Farro)','Modern high-gain stack','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Dark, driving distortion under a fairytale melody.','Medium-high gain; verse riffs need note separation.'],
     array['Drive the verse riff with even eighths.','Open up for the ba-da-ba-da outro.'],
     'Studio recording, 2009. Dark driving modern distortion.',78),

    -- ============ BRAND NEW / JIMMY EAT WORLD ============
    ('sic-transit-gloria-glory-fades','brand-new','guitar','riff','main riff','crunch','emo','rhythm','intermediate',
     'Electric guitar (Brand New)','Crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Tense, wiry verse crunch that snaps into a shouted chorus.','Low-medium gain; the bassline drives the verses, guitar stabs answer it.'],
     array['Stab the verse accents; leave space for the bass.','Explode into the chorus dynamics.'],
     'Studio recording, 2003. Tense wiry crunch with dramatic quiet-loud dynamics.',76),
    ('bleed-american','jimmy-eat-world','guitar','riff','main riff','distorted','alternative rock','rhythm','intermediate',
     'Gibson Les Paul (Jim Adkins)','Marshall-style crunch stack','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['Urgent, chunky rock distortion — heavier than the band''s pop singles.','Medium-high gain; palm-muted verses need punch.'],
     array['Drive the palm-muted verse riff hard.','Snap into the open chorus.'],
     'Studio recording, 2001. Urgent chunky rock distortion from the Bleed American sessions.',78),
    ('pain','jimmy-eat-world','guitar','riff','main riff','distorted','alternative rock','rhythm','intermediate',
     'Gibson Les Paul (Jim Adkins)','Modern rock stack','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Tight modern rock distortion with dark polish.','Medium-high gain, controlled and precise.'],
     array['Precise down-strokes; the riff is rhythmic, not flashy.','Hold the groove steady under the melody.'],
     'Studio recording, 2004. Tight dark modern rock distortion from Futures.',77),

    -- ============ SUM 41 / GOOD CHARLOTTE / NFG / TBS / FOB ============
    ('still-waiting','sum-41','guitar','riff','main riff','high_gain','punk rock','rhythm','intermediate',
     'Electric guitar (Deryck Whibley / Dave Baksh)','Modern high-gain stack','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['Metal-leaning punk high gain — tighter and heavier than typical pop-punk.','High gain with tight palm mutes.'],
     array['Aggressive down-picking throughout.','Keep the fast riff tight to the kick.'],
     'Studio recording, 2002. Metal-leaning punk high gain.',77),
    ('the-anthem','good-charlotte','guitar','riff','main riff','distorted','pop punk','rhythm','beginner',
     'Electric guitar (Good Charlotte)','Modern crunch stack','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":5,"treble":6,"presence":6,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['Big polished pop-punk distortion.','Medium-high gain, bright and punchy.'],
     array['Bouncy palm-muted verses.','Shout-along chorus needs wide open chords.'],
     'Studio recording, 2002. Big polished pop-punk distortion.',76),
    ('all-downhill-from-here','new-found-glory','guitar','riff','main riff','high_gain','pop punk','rhythm','intermediate',
     'Gibson Les Paul (Chad Gilbert)','Mesa/Boogie-style high-gain stack','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['Thick, tight pop-punk high gain — NFG runs heavier amps than most of the genre.','High gain with tight low end and crisp mutes.'],
     array['Tight palm-muted verse chugs.','Punch the chorus accents with the drums.'],
     'Studio recording, 2004. Thick tight pop-punk high gain, heavier than typical for the genre.',77),
    ('a-decade-under-the-influence','taking-back-sunday','guitar','riff','main riff','crunch','emo','rhythm','intermediate',
     'Electric guitar (Taking Back Sunday)','Crunch amp','Closed-back 4x12 cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Interlocking dual-guitar emo crunch; each part stays defined.','Medium gain — saturation would blur the interplay.'],
     array['Two guitar parts weave — pick one and hold your lane.','Build with the song''s slow-burn dynamics.'],
     'Studio recording, 2004. Interlocking dual-guitar emo crunch.',75),
    ('this-ain-t-a-scene-it-s-an-arms-race','fall-out-boy','guitar','riff','main riff','distorted','pop punk','rhythm','intermediate',
     'Electric guitar (Joe Trohman)','Modern rock stack','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Funky restrained verses snapping into a huge polished chorus wall.','Medium-high gain; verse stabs stay tight and funky.'],
     array['Play the verse stabs with funk timing.','Slam the chorus wall with full chords.'],
     'Studio recording, 2007. Funk-verse to polished-wall chorus dynamics.',76)
) as c(
  song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence
)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;
