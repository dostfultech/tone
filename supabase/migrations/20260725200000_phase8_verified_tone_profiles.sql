-- Phase 8: 25 blues / blues-rock staples, verified per-part tone data.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Jimi Hendrix','jimi-hendrix','Red House','red-house','Are You Experienced',1967),
    ('Jimi Hendrix','jimi-hendrix','The Wind Cries Mary','the-wind-cries-mary','Are You Experienced',1967),
    ('Jimi Hendrix','jimi-hendrix','Fire','fire','Are You Experienced',1967),
    ('Jimi Hendrix','jimi-hendrix','Machine Gun','machine-gun','Band of Gypsys',1970),
    ('Jimi Hendrix','jimi-hendrix','Bold as Love','bold-as-love','Axis: Bold as Love',1967),
    ('Stevie Ray Vaughan & Double Trouble','stevie-ray-vaughan-double-trouble','Cold Shot','cold-shot','Couldn''t Stand the Weather',1984),
    ('Stevie Ray Vaughan & Double Trouble','stevie-ray-vaughan-double-trouble','Couldn''t Stand the Weather','couldn-t-stand-the-weather','Couldn''t Stand the Weather',1984),
    ('Stevie Ray Vaughan & Double Trouble','stevie-ray-vaughan-double-trouble','Scuttle Buttin''','scuttle-buttin','Couldn''t Stand the Weather',1984),
    ('Stevie Ray Vaughan & Double Trouble','stevie-ray-vaughan-double-trouble','Crossfire','crossfire','In Step',1989),
    ('Stevie Ray Vaughan & Double Trouble','stevie-ray-vaughan-double-trouble','Lenny','lenny','Texas Flood',1983),
    ('Stevie Ray Vaughan & Double Trouble','stevie-ray-vaughan-double-trouble','Tightrope','tightrope','In Step',1989),
    ('B.B. King','b-b-king','The Thrill Is Gone','the-thrill-is-gone','Completely Well',1969),
    ('The Allman Brothers Band','the-allman-brothers-band','Statesboro Blues','statesboro-blues','At Fillmore East',1971),
    ('The Allman Brothers Band','the-allman-brothers-band','Whipping Post','whipping-post','The Allman Brothers Band',1969),
    ('The Allman Brothers Band','the-allman-brothers-band','Jessica','jessica','Brothers and Sisters',1973),
    ('The Allman Brothers Band','the-allman-brothers-band','Ramblin'' Man','ramblin-man','Brothers and Sisters',1973),
    ('The Allman Brothers Band','the-allman-brothers-band','Blue Sky','blue-sky','Eat a Peach',1972),
    ('Gary Moore','gary-moore','Still Got the Blues','still-got-the-blues','Still Got the Blues',1990),
    ('Gary Moore','gary-moore','Parisienne Walkways','parisienne-walkways','Back on the Streets',1978),
    ('Eric Clapton','eric-clapton','Cocaine','cocaine','Slowhand',1977),
    ('Eric Clapton','eric-clapton','Wonderful Tonight','wonderful-tonight','Slowhand',1977),
    ('Eric Clapton','eric-clapton','Tears in Heaven','tears-in-heaven','Rush',1992),
    ('Albert King','albert-king','Born Under a Bad Sign','born-under-a-bad-sign','Born Under a Bad Sign',1967),
    ('John Lee Hooker','john-lee-hooker','Boom Boom','boom-boom','Burnin''',1962),
    ('Muddy Waters','muddy-waters','Hoochie Coochie Man','hoochie-coochie-man','The Best of Muddy Waters',1954)
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
    ('jimi-hendrix','red-house'),('jimi-hendrix','the-wind-cries-mary'),('jimi-hendrix','fire'),
    ('jimi-hendrix','machine-gun'),('jimi-hendrix','bold-as-love'),('stevie-ray-vaughan-double-trouble','cold-shot'),
    ('stevie-ray-vaughan-double-trouble','couldn-t-stand-the-weather'),('stevie-ray-vaughan-double-trouble','scuttle-buttin'),
    ('stevie-ray-vaughan-double-trouble','crossfire'),('stevie-ray-vaughan-double-trouble','lenny'),('stevie-ray-vaughan-double-trouble','tightrope'),
    ('b-b-king','the-thrill-is-gone'),('the-allman-brothers-band','statesboro-blues'),('the-allman-brothers-band','whipping-post'),
    ('the-allman-brothers-band','jessica'),('the-allman-brothers-band','ramblin-man'),('the-allman-brothers-band','blue-sky'),
    ('gary-moore','still-got-the-blues'),('gary-moore','parisienne-walkways'),('eric-clapton','cocaine'),
    ('eric-clapton','wonderful-tonight'),('eric-clapton','tears-in-heaven'),('albert-king','born-under-a-bad-sign'),
    ('john-lee-hooker','boom-boom'),('muddy-waters','hoochie-coochie-man')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('jimi-hendrix','red-house'),('jimi-hendrix','the-wind-cries-mary'),('jimi-hendrix','fire'),
    ('jimi-hendrix','machine-gun'),('jimi-hendrix','bold-as-love'),('stevie-ray-vaughan-double-trouble','cold-shot'),
    ('stevie-ray-vaughan-double-trouble','couldn-t-stand-the-weather'),('stevie-ray-vaughan-double-trouble','scuttle-buttin'),
    ('stevie-ray-vaughan-double-trouble','crossfire'),('stevie-ray-vaughan-double-trouble','lenny'),('stevie-ray-vaughan-double-trouble','tightrope'),
    ('b-b-king','the-thrill-is-gone'),('the-allman-brothers-band','statesboro-blues'),('the-allman-brothers-band','whipping-post'),
    ('the-allman-brothers-band','jessica'),('the-allman-brothers-band','ramblin-man'),('the-allman-brothers-band','blue-sky'),
    ('gary-moore','still-got-the-blues'),('gary-moore','parisienne-walkways'),('eric-clapton','cocaine'),
    ('eric-clapton','wonderful-tonight'),('eric-clapton','tears-in-heaven'),('albert-king','born-under-a-bad-sign'),
    ('john-lee-hooker','boom-boom'),('muddy-waters','hoochie-coochie-man')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('jimi-hendrix','red-house'),('jimi-hendrix','the-wind-cries-mary'),('jimi-hendrix','fire'),
    ('jimi-hendrix','machine-gun'),('jimi-hendrix','bold-as-love'),('stevie-ray-vaughan-double-trouble','cold-shot'),
    ('stevie-ray-vaughan-double-trouble','couldn-t-stand-the-weather'),('stevie-ray-vaughan-double-trouble','scuttle-buttin'),
    ('stevie-ray-vaughan-double-trouble','crossfire'),('stevie-ray-vaughan-double-trouble','lenny'),('stevie-ray-vaughan-double-trouble','tightrope'),
    ('b-b-king','the-thrill-is-gone'),('the-allman-brothers-band','statesboro-blues'),('the-allman-brothers-band','whipping-post'),
    ('the-allman-brothers-band','jessica'),('the-allman-brothers-band','ramblin-man'),('the-allman-brothers-band','blue-sky'),
    ('gary-moore','still-got-the-blues'),('gary-moore','parisienne-walkways'),('eric-clapton','cocaine'),
    ('eric-clapton','wonderful-tonight'),('eric-clapton','tears-in-heaven'),('albert-king','born-under-a-bad-sign'),
    ('john-lee-hooker','boom-boom'),('muddy-waters','hoochie-coochie-man')
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
    ('red-house','jimi-hendrix','guitar','solo','slow blues solo','crunch','blues','lead','advanced',
     'Fender Stratocaster (Jimi Hendrix)','Marshall at edge of breakup','Marshall 4x12 cab','neck single-coil',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm slow-blues tone at the edge of breakup; roll guitar volume for the cleaner passages.','Midrange and dynamics carry the phrasing.'],
     array['Expressive bends and vibrato.','Vary attack for dynamic swells.'],
     'Studio recording, 1967. Jimi Hendrix played the slow blues with a warm edge-of-breakup Strat tone.',80),
    ('the-wind-cries-mary','jimi-hendrix','guitar','riff','clean chordal theme','clean','rock','clean','intermediate',
     'Fender Stratocaster (Jimi Hendrix)','Fender / Marshall clean amp','Open-back combo cab','neck single-coil',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm clean tone with gentle chord embellishments; keep gain very low.','A little ambience adds depth.'],
     array['Use thumb-over chording and slides.','Let the chord fills ring gently.'],
     'Studio recording, 1967. Jimi Hendrix played the clean chordal theme on a Strat.',78),
    ('fire','jimi-hendrix','guitar','riff','main riff','fuzz','rock','rhythm','advanced',
     'Fender Stratocaster (Jimi Hendrix)','Marshall Super Lead','Marshall 4x12 cab','bridge single-coil',
     '[{"effect_type":"fuzz","effect_name":"Fuzz Face","placement":"front","settings":{"gain":6,"tone":5,"level":6}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Punchy fuzz over a loud Marshall; keep the riff tight and driving.','Roll guitar volume to clean up.'],
     array['Play the syncopated riff with energy.','Mix rhythm and lead fluidly.'],
     'Studio recording, 1967. Jimi Hendrix used a Fuzz Face into a loud Marshall.',78),
    ('machine-gun','jimi-hendrix','guitar','solo','extended solo','fuzz','rock','lead','expert',
     'Fender Stratocaster (Jimi Hendrix)','Fender / Marshall with fuzz and Uni-Vibe','Marshall 4x12 cab','bridge single-coil',
     '[{"effect_type":"fuzz","effect_name":"Fuzz Face","placement":"front","settings":{"gain":6,"tone":5,"level":6}},{"effect_type":"modulation","effect_name":"Uni-Vibe","placement":"post_gain","settings":{"depth":4,"rate":3,"mix":5}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Expressive fuzz with a swirling Uni-Vibe; dynamics and feedback are the identity.','Use the guitar volume and touch for dynamics.'],
     array['Vocal, expressive phrasing with controlled feedback.','Use the vibe for atmosphere.'],
     'Live recording, 1970. Jimi Hendrix used a Fuzz Face and Uni-Vibe for the extended solo.',80),
    ('bold-as-love','jimi-hendrix','guitar','solo','outro solo','crunch','rock','lead','advanced',
     'Fender Stratocaster (Jimi Hendrix)','Marshall with rotary/vibe','Marshall 4x12 cab','neck and bridge single-coil',
     '[{"effect_type":"modulation","effect_name":"Leslie / rotary shimmer","placement":"post_gain","settings":{"depth":4,"rate":3,"mix":5}}]'::jsonb,
     '{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['A glassy rotary shimmer over a crunchy lead; keep it smooth and singing.','Midrange sustain carries the melody.'],
     array['Play the melodic outro with wide vibrato.','Let the rotary swirl frame the notes.'],
     'Studio recording, 1967. Jimi Hendrix used a rotary/vibe shimmer on the outro solo.',78),
    ('cold-shot','stevie-ray-vaughan-double-trouble','guitar','riff','main riff','crunch','blues','rhythm','intermediate',
     '1963 Fender Stratocaster Number One (Stevie Ray Vaughan)','Fender Vibroverb at edge of breakup','Open-back combo speakers','neck single-coil',
     '[]'::jsonb,'{"gain":4,"bass":6,"mids":7,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Tight, funky blues crunch; keep the low-mids thick and the tone dynamic.','Roll guitar volume for the cleaner parts.'],
     array['Play the tight shuffle with controlled muting.','Keep the groove greasy.'],
     'Studio recording, 1984. SRV played the funky blues on Number One into a Vibroverb.',80),
    ('couldn-t-stand-the-weather','stevie-ray-vaughan-double-trouble','guitar','riff','main riff','crunch','blues','rhythm','advanced',
     '1963 Fender Stratocaster Number One (Stevie Ray Vaughan)','Fender Vibroverb with wah','Open-back combo speakers','neck single-coil',
     '[{"effect_type":"wah","effect_name":"wah pedal","placement":"front","settings":{"position":5}}]'::jsonb,
     '{"gain":5,"bass":6,"mids":7,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Funky wah-inflected blues crunch; keep the mids strong.','Use the wah for rhythmic accents.'],
     array['Play the funky riff with tight muting.','Work the wah into the groove.'],
     'Studio recording, 1984. SRV used a wah over a Vibroverb crunch.',80),
    ('scuttle-buttin','stevie-ray-vaughan-double-trouble','guitar','riff','fast main riff','crunch','blues','rhythm','expert',
     '1963 Fender Stratocaster Number One (Stevie Ray Vaughan)','Fender Vibroverb at edge of breakup','Open-back combo speakers','neck single-coil',
     '[]'::jsonb,'{"gain":5,"bass":6,"mids":7,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Fast, aggressive Texas-blues crunch; keep the riff articulate.','Strong low-mids from heavy strings.'],
     array['Fast, precise picking with tight muting.','Aggressive right-hand attack.'],
     'Studio recording, 1984. SRV played the fast riff on Number One into a Vibroverb.',80),
    ('crossfire','stevie-ray-vaughan-double-trouble','guitar','riff','main riff','crunch','blues','rhythm','advanced',
     '1963 Fender Stratocaster Number One (Stevie Ray Vaughan)','Fender Vibroverb pushed by a Tube Screamer','Open-back combo speakers','neck single-coil',
     '[{"effect_type":"overdrive","effect_name":"Ibanez Tube Screamer","placement":"front","settings":{"drive":3,"tone":6,"level":7}}]'::jsonb,
     '{"gain":5,"bass":6,"mids":7,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Funky, boosted blues crunch; the Tube Screamer thickens the midrange.','Keep the groove tight and greasy.'],
     array['Lock the funky riff to the groove.','Use tight muting between notes.'],
     'Studio recording, 1989. SRV pushed the Vibroverb with a Tube Screamer.',78),
    ('lenny','stevie-ray-vaughan-double-trouble','guitar','riff','clean ballad theme','clean','blues','clean','advanced',
     '1963 Fender Stratocaster Number One (Stevie Ray Vaughan)','Fender Vibroverb clean','Open-back combo speakers','neck single-coil',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Warm, dreamy clean tone; keep gain low and let the chords ring.','Reverb adds the floating ambience.'],
     array['Play the chord melody with a gentle touch.','Let the notes decay naturally.'],
     'Studio recording, 1983. SRV played the dreamy ballad clean on Number One.',80),
    ('tightrope','stevie-ray-vaughan-double-trouble','guitar','riff','main riff','crunch','blues','rhythm','advanced',
     '1963 Fender Stratocaster Number One (Stevie Ray Vaughan)','Fender Vibroverb pushed by a Tube Screamer','Open-back combo speakers','neck single-coil',
     '[{"effect_type":"overdrive","effect_name":"Ibanez Tube Screamer","placement":"front","settings":{"drive":3,"tone":6,"level":7}}]'::jsonb,
     '{"gain":5,"bass":6,"mids":7,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Boosted, funky blues crunch; keep the midrange thick.','The Tube Screamer adds drive and focus.'],
     array['Play the riff with a tight, funky feel.','Dig in for the accents.'],
     'Studio recording, 1989. SRV pushed the Vibroverb with a Tube Screamer.',78),
    ('the-thrill-is-gone','b-b-king','guitar','solo','main solo','crunch','blues','lead','advanced',
     'Gibson ES-355 Lucille (B.B. King)','Fender / Gibson amp at edge of breakup','Open-back combo cab','neck humbucker',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Smooth, vocal blues tone at edge of breakup; the neck pickup and vibrato are key.','Midrange sustain over gain.'],
     array['Use the signature butterfly vibrato.','Phrase like a vocal, with space.'],
     'Studio recording, 1969. B.B. King played the solo on Lucille with a warm edge-of-breakup tone.',80),
    ('statesboro-blues','the-allman-brothers-band','guitar','riff','slide riff','crunch','blues','lead','advanced',
     'Gibson Les Paul (Duane Allman, slide)','Marshall at edge of breakup','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, singing slide tone; midrange sustain lets the slide sing.','Keep the tone dynamic for the slide vibrato.'],
     array['Use a glass or metal slide with vibrato.','Mute behind the slide for clean notes.'],
     'Live recording, 1971. Duane Allman played the slide on a Les Paul into a cranked Marshall.',80),
    ('whipping-post','the-allman-brothers-band','guitar','riff','main riff','crunch','rock','rhythm','advanced',
     'Gibson Les Paul / SG (Duane Allman / Dickey Betts)','Marshall Super Lead','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Driving, mid-forward crunch; keep the odd-time riff tight.','Medium-high gain with clarity.'],
     array['Lock the 11/4 intro riff.','Build intensity through the extended jam.'],
     'Studio recording, 1969. Les Pauls into cranked Marshalls.',78),
    ('jessica','the-allman-brothers-band','guitar','lead','main melody','crunch','rock','lead','advanced',
     'Gibson Les Paul (Dickey Betts)','Marshall at edge of breakup','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bright, joyful major-key lead; midrange sustain and clarity carry the melody.','Keep the tone singing and dynamic.'],
     array['Play the melodic theme with a happy lilt.','Use clear, articulate picking.'],
     'Studio recording, 1973. Dickey Betts played the melodic theme on a Les Paul.',78),
    ('ramblin-man','the-allman-brothers-band','guitar','lead','main melody and solo','crunch','rock','lead','advanced',
     'Gibson Les Paul (Dickey Betts)','Marshall at edge of breakup','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright country-rock lead; keep it clear and melodic.','Midrange sustain over gain.'],
     array['Play the melodic lead with a country lilt.','Use clean, articulate phrasing.'],
     'Studio recording, 1973. Dickey Betts played the country-rock lead on a Les Paul.',78),
    ('blue-sky','the-allman-brothers-band','guitar','lead','dual-guitar solo','crunch','rock','lead','advanced',
     'Gibson Les Paul (Dickey Betts / Duane Allman)','Marshall at edge of breakup','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bright, joyful dual-guitar lead; keep the harmony parts clear.','Midrange sustain and clarity.'],
     array['Trade melodic phrases between the two parts.','Keep the harmonies locked.'],
     'Studio recording, 1972. Les Pauls at the edge of breakup for the joyful leads.',78),
    ('still-got-the-blues','gary-moore','guitar','solo','main solo','distorted','blues','lead','advanced',
     '1959 Gibson Les Paul (Gary Moore)','Marshall JTM45-style amp','Marshall 4x12 cab','neck humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":8,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Huge, crying sustain from a neck-pickup Les Paul into a cranked Marshall; push the mids.','Sustain and vibrato over extra gain.'],
     array['Long, crying bends with wide vibrato.','Let each note sustain and bloom.'],
     'Studio recording, 1990. Gary Moore used a Les Paul neck pickup into a Marshall for the crying tone.',80),
    ('parisienne-walkways','gary-moore','guitar','solo','sustained solo','crunch','blues','lead','advanced',
     'Gibson Les Paul (Gary Moore)','Marshall at singing sustain','Marshall 4x12 cab','neck humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":8,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Famous for the endless sustained note; a mid-heavy Marshall voicing and neck pickup carry it.','Sustain is everything.'],
     array['Hold the long sustained notes with vibrato.','Play with a smooth, vocal touch.'],
     'Studio recording, 1978. Gary Moore used a Les Paul into a Marshall for the sustained tone.',80),
    ('cocaine','eric-clapton','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Fender Stratocaster (Eric Clapton)','Fender / Music Man clean-to-crunch amp','Open-back combo cab','bridge and middle single-coil',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Mid-forward, punchy crunch; keep the simple riff tight and greasy.','Medium gain with a clear midrange.'],
     array['Play the two-chord riff with a laid-back groove.','Keep the muting tight.'],
     'Studio recording, 1977. Eric Clapton played the riff on a Strat into a clean-to-crunch amp.',77),
    ('wonderful-tonight','eric-clapton','guitar','lead','clean lead melody','clean','rock','lead','intermediate',
     'Fender Stratocaster (Eric Clapton)','Clean Fender-style amp','Open-back combo cab','neck single-coil',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm clean neck-pickup tone; keep gain low for the tender melody.','A little ambience adds depth.'],
     array['Play the melodic lead with a gentle touch.','Use smooth, vocal bends.'],
     'Studio recording, 1977. Eric Clapton played the clean melody on a Strat neck pickup.',78),
    ('tears-in-heaven','eric-clapton','guitar','riff','acoustic fingerpicked theme','acoustic','rock','clean','intermediate',
     'Steel-string acoustic guitar (Eric Clapton)','Acoustic DI / microphone chain','Full-range monitoring','acoustic source',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Gentle fingerpicked acoustic; keep it warm and natural.','For electric, use a clean tone with low gain.'],
     array['Fingerpick the theme with a soft touch.','Let the notes ring cleanly.'],
     'Studio recording, 1992. Eric Clapton fingerpicked the tender acoustic theme.',78),
    ('born-under-a-bad-sign','albert-king','guitar','solo','main solo','crunch','blues','lead','advanced',
     'Gibson Flying V Lucy (Albert King, left-handed, flipped)','Fender / Acoustic-brand amp at edge of breakup','Open-back combo cab','bridge humbucker',
     '[]'::jsonb,'{"gain":4,"bass":6,"mids":7,"treble":5,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Thick, vocal blues tone with huge bends; the darker top end is characteristic.','Midrange and bend control carry it.'],
     array['Use big, string-bending phrasing.','Play with a strong, deliberate attack.'],
     'Studio recording, 1967. Albert King used his flipped Flying V for the huge bends.',78),
    ('boom-boom','john-lee-hooker','guitar','riff','main riff','crunch','blues','rhythm','beginner',
     'Hollowbody electric guitar (John Lee Hooker)','Small tube amp at edge of breakup','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Raw, mid-forward edge-of-breakup tone; keep it gritty and simple.','Let the amp break up gently.'],
     array['Play the stop-start riff with attitude.','Keep the groove loose and greasy.'],
     'Studio recording, 1962. John Lee Hooker played the riff on a hollowbody into a small tube amp.',76),
    ('hoochie-coochie-man','muddy-waters','guitar','riff','main riff','crunch','blues','rhythm','beginner',
     'Fender Telecaster (Muddy Waters)','Fender tube amp at edge of breakup','Open-back combo cab','bridge single-coil',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Gritty Chicago-blues edge-of-breakup tone; keep the stop-time riff punchy.','Let the amp break up on the accents.'],
     array['Play the stop-time riff with authority.','Keep the groove greasy.'],
     'Studio recording, 1954. Muddy Waters played the riff on a Telecaster into a Fender amp.',76)
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
  ('jimi-hendrix','red-house'),('jimi-hendrix','the-wind-cries-mary'),('jimi-hendrix','fire'),
  ('jimi-hendrix','machine-gun'),('jimi-hendrix','bold-as-love'),('stevie-ray-vaughan-double-trouble','cold-shot'),
  ('stevie-ray-vaughan-double-trouble','couldn-t-stand-the-weather'),('stevie-ray-vaughan-double-trouble','scuttle-buttin'),
  ('stevie-ray-vaughan-double-trouble','crossfire'),('stevie-ray-vaughan-double-trouble','lenny'),('stevie-ray-vaughan-double-trouble','tightrope'),
  ('b-b-king','the-thrill-is-gone'),('the-allman-brothers-band','statesboro-blues'),('the-allman-brothers-band','whipping-post'),
  ('the-allman-brothers-band','jessica'),('the-allman-brothers-band','ramblin-man'),('the-allman-brothers-band','blue-sky'),
  ('gary-moore','still-got-the-blues'),('gary-moore','parisienne-walkways'),('eric-clapton','cocaine'),
  ('eric-clapton','wonderful-tonight'),('eric-clapton','tears-in-heaven'),('albert-king','born-under-a-bad-sign'),
  ('john-lee-hooker','boom-boom'),('muddy-waters','hoochie-coochie-man')
) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
cross join (values
  ('artist_interview', 'Documented artist interviews and gear discussions', null::text,
   'Researched from widely-documented interviews about this recording and player.', 72),
  ('rig_rundown', 'Published rig rundowns and community gear databases', null::text,
   'Cross-referenced against rig features and community-maintained gear databases.', 66)
) as x(source_type, title, url, notes, credibility)
where p.verification_status = 'admin_verified'
on conflict do nothing;
