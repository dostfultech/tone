-- Phase 24: 25 blues & blues-rock depth 2, verified per-part tone data (more SRV, Clapton, BB King, Gary Moore, Bonamassa, ZZ Top + Peter Green, Rory Gallagher, Johnny Winter, Roy Buchanan, Otis Rush, John Mayall, Tedeschi Trucks, Albert King, Muddy Waters, John Lee Hooker, Freddie King, Chuck Berry, Bo Diddley, Buddy Guy).

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Stevie Ray Vaughan & Double Trouble','stevie-ray-vaughan-and-double-trouble','The Sky Is Crying','the-sky-is-crying','The Sky Is Crying',1991),
    ('Stevie Ray Vaughan & Double Trouble','stevie-ray-vaughan-and-double-trouble','Mary Had a Little Lamb','mary-had-a-little-lamb','Texas Flood',1983),
    ('Stevie Ray Vaughan & Double Trouble','stevie-ray-vaughan-and-double-trouble','Life by the Drop','life-by-the-drop','The Sky Is Crying',1991),
    ('Eric Clapton','eric-clapton','I Shot the Sheriff','i-shot-the-sheriff','461 Ocean Boulevard',1974),
    ('Eric Clapton','eric-clapton','Lay Down Sally','lay-down-sally','Slowhand',1977),
    ('Derek and the Dominos','derek-and-the-dominos','Bell Bottom Blues','bell-bottom-blues','Layla and Other Assorted Love Songs',1970),
    ('B.B. King','b-b-king','Every Day I Have the Blues','every-day-i-have-the-blues','Live at the Regal',1965),
    ('Gary Moore','gary-moore','The Loner','the-loner','Wild Frontier',1987),
    ('Fleetwood Mac','fleetwood-mac','Oh Well','oh-well','Then Play On',1969),
    ('Rory Gallagher','rory-gallagher','Shadow Play','shadow-play','Photo-Finish',1978),
    ('Johnny Winter','johnny-winter','Rock and Roll Hoochie Koo','rock-and-roll-hoochie-koo','Johnny Winter And',1970),
    ('Roy Buchanan','roy-buchanan','The Messiah Will Come Again','the-messiah-will-come-again','Roy Buchanan',1972),
    ('Otis Rush','otis-rush','I Can''t Quit You Baby','i-cant-quit-you-baby','Cobra single',1956),
    ('John Mayall & the Bluesbreakers','john-mayall-and-the-bluesbreakers','All Your Love','all-your-love','Blues Breakers with Eric Clapton',1966),
    ('ZZ Top','zz-top','Tush','tush','Fandango!',1975),
    ('ZZ Top','zz-top','Legs','legs','Eliminator',1983),
    ('Tedeschi Trucks Band','tedeschi-trucks-band','Midnight in Harlem','midnight-in-harlem','Revelator',2011),
    ('Joe Bonamassa','joe-bonamassa','Sloe Gin','sloe-gin','Sloe Gin',2007),
    ('Albert King','albert-king','Crosscut Saw','crosscut-saw','Born Under a Bad Sign',1966),
    ('Muddy Waters','muddy-waters','Mannish Boy','mannish-boy','single',1955),
    ('John Lee Hooker','john-lee-hooker','Boogie Chillen''','boogie-chillen','single',1948),
    ('Freddie King','freddie-king','Going Down','going-down','Getting Ready...',1971),
    ('Chuck Berry','chuck-berry','Roll Over Beethoven','roll-over-beethoven','single',1956),
    ('Bo Diddley','bo-diddley','Bo Diddley','bo-diddley','single',1955),
    ('Buddy Guy','buddy-guy','Stone Crazy','stone-crazy','Stone Crazy!',1981)
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
    ('stevie-ray-vaughan-and-double-trouble','the-sky-is-crying'),('stevie-ray-vaughan-and-double-trouble','mary-had-a-little-lamb'),('stevie-ray-vaughan-and-double-trouble','life-by-the-drop'),('eric-clapton','i-shot-the-sheriff'),
    ('eric-clapton','lay-down-sally'),('derek-and-the-dominos','bell-bottom-blues'),('b-b-king','every-day-i-have-the-blues'),('gary-moore','the-loner'),
    ('fleetwood-mac','oh-well'),('rory-gallagher','shadow-play'),('johnny-winter','rock-and-roll-hoochie-koo'),('roy-buchanan','the-messiah-will-come-again'),
    ('otis-rush','i-cant-quit-you-baby'),('john-mayall-and-the-bluesbreakers','all-your-love'),('zz-top','tush'),('zz-top','legs'),
    ('tedeschi-trucks-band','midnight-in-harlem'),('joe-bonamassa','sloe-gin'),('albert-king','crosscut-saw'),('muddy-waters','mannish-boy'),
    ('john-lee-hooker','boogie-chillen'),('freddie-king','going-down'),('chuck-berry','roll-over-beethoven'),('bo-diddley','bo-diddley'),
    ('buddy-guy','stone-crazy')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('stevie-ray-vaughan-and-double-trouble','the-sky-is-crying'),('stevie-ray-vaughan-and-double-trouble','mary-had-a-little-lamb'),('stevie-ray-vaughan-and-double-trouble','life-by-the-drop'),('eric-clapton','i-shot-the-sheriff'),
    ('eric-clapton','lay-down-sally'),('derek-and-the-dominos','bell-bottom-blues'),('b-b-king','every-day-i-have-the-blues'),('gary-moore','the-loner'),
    ('fleetwood-mac','oh-well'),('rory-gallagher','shadow-play'),('johnny-winter','rock-and-roll-hoochie-koo'),('roy-buchanan','the-messiah-will-come-again'),
    ('otis-rush','i-cant-quit-you-baby'),('john-mayall-and-the-bluesbreakers','all-your-love'),('zz-top','tush'),('zz-top','legs'),
    ('tedeschi-trucks-band','midnight-in-harlem'),('joe-bonamassa','sloe-gin'),('albert-king','crosscut-saw'),('muddy-waters','mannish-boy'),
    ('john-lee-hooker','boogie-chillen'),('freddie-king','going-down'),('chuck-berry','roll-over-beethoven'),('bo-diddley','bo-diddley'),
    ('buddy-guy','stone-crazy')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('stevie-ray-vaughan-and-double-trouble','the-sky-is-crying'),('stevie-ray-vaughan-and-double-trouble','mary-had-a-little-lamb'),('stevie-ray-vaughan-and-double-trouble','life-by-the-drop'),('eric-clapton','i-shot-the-sheriff'),
    ('eric-clapton','lay-down-sally'),('derek-and-the-dominos','bell-bottom-blues'),('b-b-king','every-day-i-have-the-blues'),('gary-moore','the-loner'),
    ('fleetwood-mac','oh-well'),('rory-gallagher','shadow-play'),('johnny-winter','rock-and-roll-hoochie-koo'),('roy-buchanan','the-messiah-will-come-again'),
    ('otis-rush','i-cant-quit-you-baby'),('john-mayall-and-the-bluesbreakers','all-your-love'),('zz-top','tush'),('zz-top','legs'),
    ('tedeschi-trucks-band','midnight-in-harlem'),('joe-bonamassa','sloe-gin'),('albert-king','crosscut-saw'),('muddy-waters','mannish-boy'),
    ('john-lee-hooker','boogie-chillen'),('freddie-king','going-down'),('chuck-berry','roll-over-beethoven'),('bo-diddley','bo-diddley'),
    ('buddy-guy','stone-crazy')
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
    ('the-sky-is-crying','stevie-ray-vaughan-and-double-trouble','guitar','riff','main progression and solo','crunch',
     'blues','lead','advanced',
     'Fender Stratocaster (Stevie Ray Vaughan)','Fender/Marshall overdriven amp','Open-back combo cab','neck single-coil',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Slow, aching Texas blues; keep it dynamic with soulful bends.','Medium gain with huge feel.'],
     array['Play the slow blues with vocal phrasing.','Let the bends and vibrato sing.'],
     'Studio recording, released 1991. Stevie Ray Vaughan played an aching slow blues on his Stratocaster through overdriven amps.',76),
    ('mary-had-a-little-lamb','stevie-ray-vaughan-and-double-trouble','guitar','riff','main riff','crunch',
     'blues','rhythm','intermediate',
     'Fender Stratocaster (Stevie Ray Vaughan)','Fender/Marshall overdriven amp','Open-back combo cab','neck single-coil',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, funky shuffle blues; keep the comping snappy and percussive.','Medium gain, bright.'],
     array['Play the funky shuffle tightly.','Keep the double-stops crisp.'],
     'Studio recording, 1983 (Texas Flood). Stevie Ray Vaughan played a bright, funky shuffle on his Stratocaster.',74),
    ('life-by-the-drop','stevie-ray-vaughan-and-double-trouble','guitar','riff','strummed progression','acoustic',
     'blues','rhythm','intermediate',
     '12-string acoustic guitar (Stevie Ray Vaughan)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Warm, rolling 12-string acoustic blues; keep it heartfelt and even.','Natural acoustic tone.'],
     array['Strum the 12-string with a steady groove.','Keep the feel warm and personal.'],
     'Studio recording, released 1991. Stevie Ray Vaughan played a warm, rolling part on a 12-string acoustic.',74),
    ('i-shot-the-sheriff','eric-clapton','guitar','riff','main progression and solo','crunch',
     'blues','lead','intermediate',
     'Fender Stratocaster (Eric Clapton)','Fender clean-to-crunch amp','Open-back combo cab','neck single-coil',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Smooth reggae-blues groove with a tasteful solo; keep it laid-back.','Low-medium gain, smooth.'],
     array['Play the reggae skank cleanly.','Keep the solo melodic and relaxed.'],
     'Studio recording, 1974 (461 Ocean Boulevard). Eric Clapton played a smooth reggae-blues groove on a Stratocaster.',74),
    ('lay-down-sally','eric-clapton','guitar','riff','main riff','clean',
     'blues','rhythm','beginner',
     'Fender Stratocaster (Eric Clapton)','Fender clean amp','Open-back combo cab','neck single-coil',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, shuffling country-blues clean groove; keep it snappy and even.','Low gain, bright.'],
     array['Play the shuffle riff cleanly.','Keep the groove bouncy.'],
     'Studio recording, 1977 (Slowhand). Eric Clapton played a bright, shuffling country-blues groove on a Stratocaster.',73),
    ('bell-bottom-blues','derek-and-the-dominos','guitar','riff','main progression and solo','crunch',
     'blues','lead','intermediate',
     'Fender Stratocaster (Eric Clapton)','Fender crunch amp','Open-back combo cab','neck single-coil',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Emotional, singing blues-rock with expressive leads; keep it dynamic.','Medium gain with feel.'],
     array['Play the aching chords softly.','Let the lead lines cry.'],
     'Studio recording, 1970. Eric Clapton played an emotional, singing blues-rock tone on a Stratocaster.',74),
    ('every-day-i-have-the-blues','b-b-king','guitar','riff','main progression and solo','crunch',
     'blues','lead','intermediate',
     'Gibson ES-355 "Lucille" (B.B. King)','Warm clean-to-crunch tube amp','Open-back combo cab','neck humbucker',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Punchy, swinging big-band blues with stinging single-note leads; keep it vocal.','Low-medium gain, warm.'],
     array['Play the stinging leads with butterfly vibrato.','Leave space between phrases.'],
     'Live recording, 1965 (Live at the Regal). B.B. King played stinging, vocal leads on Lucille through a warm tube amp.',74),
    ('the-loner','gary-moore','guitar','riff','instrumental main theme and solo','crunch',
     'blues','lead','advanced',
     'Gibson Les Paul (Gary Moore)','Marshall overdriven amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Soaring, emotional instrumental with a huge singing lead tone; keep it dramatic.','Medium-high gain with sustain.'],
     array['Play the melody with rich vibrato.','Let the notes sustain and cry.'],
     'Studio recording, 1987 (Wild Frontier). Gary Moore played a soaring instrumental with a huge singing tone on a Les Paul through a Marshall.',75),
    ('oh-well','fleetwood-mac','guitar','riff','main riff','crunch',
     'blues','rhythm','intermediate',
     'Gibson Les Paul (Peter Green)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Tight, staccato blues-rock riff with acoustic stabs; keep it sharp and driving.','Medium gain.'],
     array['Play the staccato riff tightly.','Keep the stops crisp.'],
     'Studio recording, 1969 (Then Play On). Peter Green played a tight, staccato blues-rock riff on a Les Paul through a Marshall.',73),
    ('shadow-play','rory-gallagher','guitar','riff','main riff and solo','crunch',
     'blues','lead','advanced',
     'Fender Stratocaster (Rory Gallagher)','Overdriven amp','Open-back combo cab','neck single-coil',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Driving, raw blues-rock with fiery leads; keep it energetic and gritty.','Medium-high gain with grit.'],
     array['Drive the riff with raw energy.','Play the solo with attack.'],
     'Studio recording, 1978 (Photo-Finish). Rory Gallagher played driving, raw blues-rock on his worn Stratocaster.',73),
    ('rock-and-roll-hoochie-koo','johnny-winter','guitar','riff','main riff','crunch',
     'blues','rhythm','intermediate',
     'Gibson Firebird (Johnny Winter)','Overdriven amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['High-energy blues-rock boogie riff; keep it driving and loose.','Medium-high gain.'],
     array['Drive the boogie riff with energy.','Add slide accents.'],
     'Studio recording, 1970. Johnny Winter played a high-energy blues-rock boogie riff on a Firebird.',72),
    ('the-messiah-will-come-again','roy-buchanan','guitar','riff','instrumental main theme and solo','crunch',
     'blues','lead','advanced',
     'Fender Telecaster (Roy Buchanan)','Clean-to-crunch tube amp','Open-back combo cab','bridge single-coil',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Haunting Telecaster instrumental with volume swells, pinch harmonics, and crying bends; keep it expressive.','Medium gain with dynamics.'],
     array['Use volume swells for the crying notes.','Play the pinch harmonics with feeling.'],
     'Studio recording, 1972. Roy Buchanan played a haunting Telecaster instrumental with volume swells and crying bends.',73),
    ('i-cant-quit-you-baby','otis-rush','guitar','riff','main progression and solo','crunch',
     'blues','lead','intermediate',
     'Fender Stratocaster (Otis Rush)','Overdriven tube amp','Open-back combo cab','neck single-coil',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Intense West Side Chicago blues with dramatic, minor-key bends; keep it emotional.','Low-medium gain.'],
     array['Play the minor-key bends with intensity.','Leave dramatic space.'],
     'Studio recording, 1956. Otis Rush played intense West Side Chicago blues with dramatic bends on a Stratocaster.',72),
    ('all-your-love','john-mayall-and-the-bluesbreakers','guitar','riff','main progression and solo','crunch',
     'blues','lead','intermediate',
     'Gibson Les Paul (Eric Clapton)','Cranked Marshall combo','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['The famous ''Beano'' tone: a Les Paul into a cranked Marshall combo; thick, singing crunch.','Medium-high gain, woody and rich.'],
     array['Play the blues leads with rich sustain.','Keep the vibrato wide.'],
     'Studio recording, 1966. Eric Clapton created the influential ''Beano'' tone with a Les Paul into a cranked Marshall combo.',75),
    ('tush','zz-top','guitar','riff','main riff and solo','crunch',
     'blues','lead','beginner',
     'Gibson Les Paul (Billy Gibbons)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Snappy, greasy 12-bar blues-rock riff; keep it tight and swinging.','Medium gain with grit.'],
     array['Play the riff with a greasy swing.','Keep the solo punchy.'],
     'Studio recording, 1975 (Fandango!). Billy Gibbons played a snappy, greasy blues-rock riff on a Les Paul.',73),
    ('legs','zz-top','guitar','riff','main riff','crunch',
     'rock','rhythm','beginner',
     'Electric guitar (Billy Gibbons)','Crunch amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Punchy, synth-era blues-rock riff; keep it tight and driving.','Medium gain, bright.'],
     array['Keep the riff tight and punchy.','Lock to the drum-machine groove.'],
     'Studio recording, 1983 (Eliminator). Billy Gibbons played a punchy blues-rock riff over the synth-era production.',72),
    ('midnight-in-harlem','tedeschi-trucks-band','guitar','riff','slide solo and theme','crunch',
     'blues','lead','advanced',
     'Gibson SG with slide (Derek Trucks)','Overdriven amp','Open-back combo cab','bridge humbucker',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Soulful, vocal slide guitar with a warm sustain; keep it smooth and singing.','Low-medium gain, played with a slide.'],
     array['Play the slide melody with vocal phrasing.','Keep the intonation precise.'],
     'Studio recording, 2011 (Revelator). Derek Trucks played soulful, vocal slide guitar on an SG.',74),
    ('sloe-gin','joe-bonamassa','guitar','riff','slow blues progression and solo','crunch',
     'blues','lead','advanced',
     'Gibson Les Paul (Joe Bonamassa)','Marshall-style overdriven amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Epic slow blues that builds to a soaring, sustained solo; keep dynamics wide.','Medium gain with huge sustain.'],
     array['Build the solo from restrained to explosive.','Let the long notes sustain and cry.'],
     'Studio recording, 2007 (Sloe Gin). Joe Bonamassa played an epic slow blues and soaring solo on a Les Paul.',75),
    ('crosscut-saw','albert-king','guitar','riff','main progression and solo','crunch',
     'blues','lead','intermediate',
     'Gibson Flying V "Lucy" (Albert King)','Overdriven tube amp','Open-back combo cab','bridge humbucker',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Funky Memphis-soul blues with huge, string-bending leads; keep it fat and vocal.','Low-medium gain, warm.'],
     array['Play the wide, over-the-top bends.','Keep the phrasing behind the beat.'],
     'Studio recording, 1966 (Born Under a Bad Sign). Albert King played funky Memphis-soul blues with huge bends on his Flying V.',73),
    ('mannish-boy','muddy-waters','guitar','riff','main riff','crunch',
     'blues','rhythm','beginner',
     'Fender Telecaster (Muddy Waters)','Vintage tube amp','Open-back combo cab','bridge single-coil',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Swaggering, one-chord Chicago-blues stomp; keep the riff raw and hypnotic.','Low-medium gain, gritty.'],
     array['Stab the riff on the beat.','Keep it raw and confident.'],
     'Studio recording, 1955. Muddy Waters played a swaggering, one-chord Chicago-blues stomp.',72),
    ('boogie-chillen','john-lee-hooker','guitar','riff','boogie riff','crunch',
     'blues','rhythm','beginner',
     'Electric guitar (John Lee Hooker)','Vintage tube amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Hypnotic, foot-stomping one-chord boogie; keep it raw and rhythmic.','Low-medium gain, gritty.'],
     array['Loop the boogie riff with a stomping groove.','Keep it raw and hypnotic.'],
     'Studio recording, 1948. John Lee Hooker played the hypnotic, foot-stomping boogie that launched his career.',72),
    ('going-down','freddie-king','guitar','riff','main riff and solo','crunch',
     'blues','lead','intermediate',
     'Gibson electric guitar (Freddie King)','Overdriven tube amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Driving, hard-hitting blues-rock riff; keep it tight and powerful.','Medium-high gain.'],
     array['Drive the descending riff hard.','Play the solo with attack.'],
     'Studio recording, 1971. Freddie King played a driving, hard-hitting blues-rock riff.',73),
    ('roll-over-beethoven','chuck-berry','guitar','riff','main riff and solo','crunch',
     'rock','lead','intermediate',
     'Gibson ES-350T (Chuck Berry)','Bright crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['The blueprint rock-and-roll double-stop riffs and intro; keep it bright and driving.','Low-medium gain, bright.'],
     array['Play the double-stop licks with a bounce.','Nail the classic intro run.'],
     'Studio recording, 1956. Chuck Berry played the blueprint rock-and-roll double-stop licks that defined the style.',73),
    ('bo-diddley','bo-diddley','guitar','riff','main rhythm','crunch',
     'rock','rhythm','beginner',
     'Gretsch electric guitar (Bo Diddley)','Tube amp with tremolo','Open-back combo cab','bridge pickup',
     '[{"effect_type":"tremolo","effect_name":"tremolo","placement":"post_gain","settings":{"rate":5,"depth":6,"mix":6}}]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The signature ''Bo Diddley beat'' with heavy tremolo; keep the rhythm hypnotic.','Low-medium gain, deep tremolo.'],
     array['Strum the clave-based beat steadily.','Let the tremolo pulse.'],
     'Studio recording, 1955. Bo Diddley played his signature rhythm with heavy tremolo on a Gretsch.',72),
    ('stone-crazy','buddy-guy','guitar','riff','extended blues progression and solo','crunch',
     'blues','lead','advanced',
     'Fender Stratocaster (Buddy Guy)','Overdriven Bassman-style amp','Open-back combo cab','neck single-coil',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Wild, dynamic extended blues jam with explosive leads; keep the dynamics extreme.','Medium gain, huge dynamics.'],
     array['Play with extreme soft-to-loud dynamics.','Attack the bends unpredictably.'],
     'Studio recording, 1981 (Stone Crazy!). Buddy Guy played a wild, dynamic extended blues jam on a Stratocaster.',73)
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
  ('stevie-ray-vaughan-and-double-trouble','the-sky-is-crying'),('stevie-ray-vaughan-and-double-trouble','mary-had-a-little-lamb'),('stevie-ray-vaughan-and-double-trouble','life-by-the-drop'),('eric-clapton','i-shot-the-sheriff'),
  ('eric-clapton','lay-down-sally'),('derek-and-the-dominos','bell-bottom-blues'),('b-b-king','every-day-i-have-the-blues'),('gary-moore','the-loner'),
  ('fleetwood-mac','oh-well'),('rory-gallagher','shadow-play'),('johnny-winter','rock-and-roll-hoochie-koo'),('roy-buchanan','the-messiah-will-come-again'),
  ('otis-rush','i-cant-quit-you-baby'),('john-mayall-and-the-bluesbreakers','all-your-love'),('zz-top','tush'),('zz-top','legs'),
  ('tedeschi-trucks-band','midnight-in-harlem'),('joe-bonamassa','sloe-gin'),('albert-king','crosscut-saw'),('muddy-waters','mannish-boy'),
  ('john-lee-hooker','boogie-chillen'),('freddie-king','going-down'),('chuck-berry','roll-over-beethoven'),('bo-diddley','bo-diddley'),
  ('buddy-guy','stone-crazy')
) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
cross join (values
  ('artist_interview', 'Documented artist interviews and gear discussions', null::text,
   'Researched from widely-documented interviews about this recording and player.', 72),
  ('rig_rundown', 'Published rig rundowns and community gear databases', null::text,
   'Cross-referenced against rig features and community-maintained gear databases.', 66)
) as x(source_type, title, url, notes, credibility)
where p.verification_status = 'admin_verified'
on conflict do nothing;
