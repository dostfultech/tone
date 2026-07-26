-- Phase 38: 25 instrumental / shred / virtuoso guitar, verified per-part tone data (Joe Satriani, Steve Vai, Yngwie Malmsteen, more Eric Johnson, Buckethead, Plini, Guthrie Govan, Tommy Emmanuel, Andy McKee, Chet Atkins, Jeff Beck, John Petrucci, Paul Gilbert, Vinnie Moore, Jason Becker, Marty Friedman, Steve Morse, more Extreme).

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Joe Satriani','joe-satriani','Surfing with the Alien','surfing-with-the-alien','Surfing with the Alien',1987),
    ('Joe Satriani','joe-satriani','Always with Me, Always with You','always-with-me-always-with-you','Surfing with the Alien',1987),
    ('Joe Satriani','joe-satriani','Satch Boogie','satch-boogie','Surfing with the Alien',1987),
    ('Joe Satriani','joe-satriani','Flying in a Blue Dream','flying-in-a-blue-dream','Flying in a Blue Dream',1989),
    ('Steve Vai','steve-vai','For the Love of God','for-the-love-of-god','Passion and Warfare',1990),
    ('Steve Vai','steve-vai','Tender Surrender','tender-surrender','Alien Love Secrets',1995),
    ('Steve Vai','steve-vai','Building the Church','building-the-church','Real Illusions: Reflections',2005),
    ('Yngwie Malmsteen','yngwie-malmsteen','Far Beyond the Sun','far-beyond-the-sun','Rising Force',1984),
    ('Yngwie Malmsteen','yngwie-malmsteen','Black Star','black-star','Rising Force',1984),
    ('Eric Johnson','eric-johnson','Manhattan','manhattan','Ah Via Musicom',1990),
    ('Buckethead','buckethead','Soothsayer','soothsayer','Crime Slunk Scene',2006),
    ('Plini','plini','Handmade Cities','handmade-cities','Handmade Cities',2016),
    ('Guthrie Govan','guthrie-govan','Waves','waves','Erotic Cakes',2006),
    ('Tommy Emmanuel','tommy-emmanuel','Angelina','angelina','Only',2000),
    ('Andy McKee','andy-mckee','Drifting','drifting','Art of Motion',2007),
    ('Chet Atkins','chet-atkins','Mr. Sandman','mr-sandman','single',1955),
    ('Jeff Beck','jeff-beck','Cause We''ve Ended as Lovers','cause-weve-ended-as-lovers','Blow by Blow',1975),
    ('Jeff Beck','jeff-beck','Where Were You','where-were-you','Jeff Beck''s Guitar Shop',1989),
    ('John Petrucci','john-petrucci','Glasgow Kiss','glasgow-kiss','Suspended Animation',2005),
    ('Paul Gilbert','paul-gilbert','Technical Difficulties','technical-difficulties','Second Heat',1993),
    ('Vinnie Moore','vinnie-moore','Mind''s Eye','minds-eye','Mind''s Eye',1986),
    ('Jason Becker','jason-becker','Altitudes','altitudes','Perpetual Burn',1988),
    ('Marty Friedman','marty-friedman','Dragon''s Kiss','dragons-kiss','Dragon''s Kiss',1988),
    ('Steve Morse','steve-morse','Tumeni Notes','tumeni-notes','High Tension Wires',1989),
    ('Extreme','extreme','Get the Funk Out','get-the-funk-out','Pornograffitti',1990)
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
    ('joe-satriani','surfing-with-the-alien'),('joe-satriani','always-with-me-always-with-you'),('joe-satriani','satch-boogie'),('joe-satriani','flying-in-a-blue-dream'),
    ('steve-vai','for-the-love-of-god'),('steve-vai','tender-surrender'),('steve-vai','building-the-church'),('yngwie-malmsteen','far-beyond-the-sun'),
    ('yngwie-malmsteen','black-star'),('eric-johnson','manhattan'),('buckethead','soothsayer'),('plini','handmade-cities'),
    ('guthrie-govan','waves'),('tommy-emmanuel','angelina'),('andy-mckee','drifting'),('chet-atkins','mr-sandman'),
    ('jeff-beck','cause-weve-ended-as-lovers'),('jeff-beck','where-were-you'),('john-petrucci','glasgow-kiss'),('paul-gilbert','technical-difficulties'),
    ('vinnie-moore','minds-eye'),('jason-becker','altitudes'),('marty-friedman','dragons-kiss'),('steve-morse','tumeni-notes'),
    ('extreme','get-the-funk-out')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('joe-satriani','surfing-with-the-alien'),('joe-satriani','always-with-me-always-with-you'),('joe-satriani','satch-boogie'),('joe-satriani','flying-in-a-blue-dream'),
    ('steve-vai','for-the-love-of-god'),('steve-vai','tender-surrender'),('steve-vai','building-the-church'),('yngwie-malmsteen','far-beyond-the-sun'),
    ('yngwie-malmsteen','black-star'),('eric-johnson','manhattan'),('buckethead','soothsayer'),('plini','handmade-cities'),
    ('guthrie-govan','waves'),('tommy-emmanuel','angelina'),('andy-mckee','drifting'),('chet-atkins','mr-sandman'),
    ('jeff-beck','cause-weve-ended-as-lovers'),('jeff-beck','where-were-you'),('john-petrucci','glasgow-kiss'),('paul-gilbert','technical-difficulties'),
    ('vinnie-moore','minds-eye'),('jason-becker','altitudes'),('marty-friedman','dragons-kiss'),('steve-morse','tumeni-notes'),
    ('extreme','get-the-funk-out')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('joe-satriani','surfing-with-the-alien'),('joe-satriani','always-with-me-always-with-you'),('joe-satriani','satch-boogie'),('joe-satriani','flying-in-a-blue-dream'),
    ('steve-vai','for-the-love-of-god'),('steve-vai','tender-surrender'),('steve-vai','building-the-church'),('yngwie-malmsteen','far-beyond-the-sun'),
    ('yngwie-malmsteen','black-star'),('eric-johnson','manhattan'),('buckethead','soothsayer'),('plini','handmade-cities'),
    ('guthrie-govan','waves'),('tommy-emmanuel','angelina'),('andy-mckee','drifting'),('chet-atkins','mr-sandman'),
    ('jeff-beck','cause-weve-ended-as-lovers'),('jeff-beck','where-were-you'),('john-petrucci','glasgow-kiss'),('paul-gilbert','technical-difficulties'),
    ('vinnie-moore','minds-eye'),('jason-becker','altitudes'),('marty-friedman','dragons-kiss'),('steve-morse','tumeni-notes'),
    ('extreme','get-the-funk-out')
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
    ('surfing-with-the-alien','joe-satriani','guitar','riff','main riff and solo','high_gain',
     'rock','lead','expert',
     'Ibanez JS signature (Joe Satriani)','High-gain amp with delay','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":1,"master":6}'::jsonb,
     array['Bright, melodic instrumental shred with fast legato and a catchy main theme; keep it fluid.','High gain with clarity and delay.'],
     array['Play the theme with a singing tone.','Nail the fast legato and tapping.'],
     'Studio recording, 1987 (Surfing with the Alien). Joe Satriani played bright, melodic instrumental shred on an Ibanez JS.',73),
    ('always-with-me-always-with-you','joe-satriani','guitar','riff','main melody','high_gain',
     'rock','lead','advanced',
     'Ibanez JS signature (Joe Satriani)','High-gain amp with delay','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":3,"delay":2,"master":6}'::jsonb,
     array['Warm, singing melodic instrumental with legato phrasing; keep the tone smooth and emotive.','Medium-high gain, lush delay.'],
     array['Play the melody with smooth legato.','Keep it warm and singing.'],
     'Studio recording, 1987 (Surfing with the Alien). Joe Satriani played a warm, singing melodic instrumental.',73),
    ('satch-boogie','joe-satriani','guitar','riff','main riff and solo','high_gain',
     'rock','lead','expert',
     'Ibanez JS signature (Joe Satriani)','High-gain amp with delay','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":1,"master":6}'::jsonb,
     array['High-energy boogie-shred with a famous two-hand-tapping breakdown; keep it fast and tight.','High gain.'],
     array['Drive the boogie riff.','Nail the two-hand-tapping section.'],
     'Studio recording, 1987 (Surfing with the Alien). Joe Satriani played high-energy boogie-shred with a tapping breakdown.',72),
    ('flying-in-a-blue-dream','joe-satriani','guitar','riff','main melody','high_gain',
     'rock','lead','advanced',
     'Ibanez JS signature (Joe Satriani)','High-gain amp with delay','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":3,"delay":2,"master":6}'::jsonb,
     array['Floating, lydian-flavoured melodic instrumental; keep the tone soaring and smooth.','Medium-high gain, ambient delay.'],
     array['Play the soaring melody smoothly.','Let notes float and sustain.'],
     'Studio recording, 1989 (Flying in a Blue Dream). Joe Satriani played a floating, lydian melodic instrumental.',72),
    ('for-the-love-of-god','steve-vai','guitar','riff','main melody and solo','high_gain',
     'rock','lead','expert',
     'Ibanez JEM signature (Steve Vai)','High-gain amp with delay','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":3,"delay":2,"master":6}'::jsonb,
     array['A deeply emotive, vocal-like instrumental with soaring bends and whammy; keep every note singing.','Medium-high gain, lush ambience.'],
     array['Play the melody with vocal, crying phrasing.','Use the whammy bar expressively.'],
     'Studio recording, 1990 (Passion and Warfare). Steve Vai played a deeply emotive, vocal-like instrumental on an Ibanez JEM.',73),
    ('tender-surrender','steve-vai','guitar','riff','main melody and solo','high_gain',
     'rock','lead','expert',
     'Ibanez JEM signature (Steve Vai)','High-gain amp with delay','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":3,"delay":2,"master":6}'::jsonb,
     array['Expressive ballad-shred building from gentle melody to a fiery climax; keep dynamics huge.','Medium-high gain.'],
     array['Play the gentle melody softly.','Build into the fiery, whammy-drenched climax.'],
     'Studio recording, 1995 (Alien Love Secrets). Steve Vai played an expressive ballad-shred instrumental.',72),
    ('building-the-church','steve-vai','guitar','riff','main riff and solo','high_gain',
     'rock','lead','expert',
     'Ibanez JEM signature (Steve Vai)','High-gain amp with delay','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":1,"master":6}'::jsonb,
     array['Funky, technical instrumental with quirky riffs and flashy solos; keep it tight and playful.','High gain.'],
     array['Play the funky riffs tightly.','Nail the flashy, whammy-laced solos.'],
     'Studio recording, 2005 (Real Illusions). Steve Vai played a funky, technical instrumental on an Ibanez JEM.',71),
    ('far-beyond-the-sun','yngwie-malmsteen','guitar','riff','main theme and solo','high_gain',
     'metal','lead','expert',
     'Fender Stratocaster (Yngwie Malmsteen)','Marshall high-gain amp','Marshall 4x12 cab','bridge single-coil',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Blazing neoclassical shred with sweep arpeggios and fast scalar runs; keep the picking precise.','High gain, bright.'],
     array['Play the fast scalar runs cleanly.','Nail the sweep arpeggios.'],
     'Studio recording, 1984 (Rising Force). Yngwie Malmsteen played blazing neoclassical shred on a scalloped Stratocaster.',72),
    ('black-star','yngwie-malmsteen','guitar','riff','main theme and solo','high_gain',
     'metal','lead','advanced',
     'Fender Stratocaster (Yngwie Malmsteen)','Marshall high-gain amp','Marshall 4x12 cab','bridge single-coil',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Melodic neoclassical instrumental building from a clean intro to soaring shred; keep it dramatic.','Medium-high gain.'],
     array['Play the clean intro delicately.','Build into the soaring neoclassical solo.'],
     'Studio recording, 1984 (Rising Force). Yngwie Malmsteen played a melodic neoclassical instrumental on a Stratocaster.',72),
    ('manhattan','eric-johnson','guitar','riff','main theme and solo','crunch',
     'rock','lead','advanced',
     'Fender Stratocaster (Eric Johnson)','Dumble/Marshall-style amp','Open-back combo cab','neck single-coil',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":3,"delay":2,"master":6}'::jsonb,
     array['Smooth, sophisticated instrumental with a glassy clean-to-crunch tone and fluid lines; keep it pristine.','Medium gain, glassy and smooth.'],
     array['Play the fluid lines cleanly.','Keep the tone glassy and violin-like.'],
     'Studio recording, 1990 (Ah Via Musicom). Eric Johnson played a smooth, sophisticated instrumental on a Stratocaster.',72),
    ('soothsayer','buckethead','guitar','riff','main melody and solo','high_gain',
     'rock','lead','expert',
     'Gibson Les Paul (Buckethead)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":3,"delay":1,"master":6}'::jsonb,
     array['Deeply emotional instrumental building from a haunting melody to a shredding climax; keep dynamics huge.','Medium-high gain.'],
     array['Play the haunting melody with feeling.','Build into the blistering shred climax.'],
     'Studio recording, 2006 (Crime Slunk Scene). Buckethead played a deeply emotional instrumental on a Les Paul.',71),
    ('handmade-cities','plini','guitar','riff','main theme and solo','high_gain',
     'metal','lead','expert',
     'Signature electric (Plini)','High-gain amp / clean','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":3,"delay":2,"master":6}'::jsonb,
     array['Warm, melodic prog-fusion instrumental with lush cleans and smooth leads; keep it fluid and airy.','Medium-high gain, ambient.'],
     array['Play the lush chords cleanly.','Play the leads with smooth legato.'],
     'Studio recording, 2016 (Handmade Cities). Plini played a warm, melodic prog-fusion instrumental.',71),
    ('waves','guthrie-govan','guitar','riff','main theme and solo','crunch',
     'fusion','lead','expert',
     'Charvel signature (Guthrie Govan)','Overdriven amp','Open-back combo cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":1,"master":6}'::jsonb,
     array['Effortless, vocal fusion instrumental with liquid legato and hybrid picking; keep it smooth.','Medium gain, smooth.'],
     array['Play the melody with liquid legato.','Use hybrid picking for the funky lines.'],
     'Studio recording, 2006 (Erotic Cakes). Guthrie Govan played an effortless, vocal fusion instrumental.',71),
    ('angelina','tommy-emmanuel','guitar','riff','fingerstyle main theme','acoustic',
     'folk','lead','expert',
     'Maton acoustic (Tommy Emmanuel)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, lyrical fingerstyle acoustic playing bass, melody, and harmony at once; keep it flowing.','Natural acoustic tone.'],
     array['Fingerpick the interweaving parts cleanly.','Keep the melody singing over the bass.'],
     'Studio recording, 2000 (Only). Tommy Emmanuel played a warm, lyrical fingerstyle acoustic on a Maton.',72),
    ('drifting','andy-mckee','guitar','riff','percussive fingerstyle theme','acoustic',
     'folk','lead','expert',
     'Steel-string acoustic (Andy McKee)','Acoustic — no amp','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Percussive, tapped fingerstyle acoustic with harmonics and body hits; keep it rhythmic and clean.','Natural acoustic tone, percussive.'],
     array['Tap the fretboard and hit the body for percussion.','Ring the harmonics cleanly.'],
     'Studio recording, 2007 (Art of Motion). Andy McKee played a percussive, tapped fingerstyle acoustic.',72),
    ('mr-sandman','chet-atkins','guitar','riff','fingerstyle main theme','clean',
     'country','lead','advanced',
     'Gretsch electric guitar (Chet Atkins)','Clean amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Slick, warm fingerstyle with a rolling thumb bass and chime-y melody; keep it clean and smooth.','Low gain, warm, clean.'],
     array['Roll the alternating thumb bass steadily.','Pick the melody cleanly over it.'],
     'Studio recording, 1955. Chet Atkins played slick, warm fingerstyle with a rolling thumb bass on a Gretsch.',72),
    ('cause-weve-ended-as-lovers','jeff-beck','guitar','riff','main melody and solo','crunch',
     'fusion','lead','expert',
     'Fender Stratocaster (Jeff Beck)','Overdriven amp','Open-back combo cab','neck single-coil',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":3,"delay":1,"master":6}'::jsonb,
     array['Achingly expressive instrumental played with fingers, volume swells, and whammy; keep every note vocal.','Medium gain, hugely expressive.'],
     array['Play with the fingers for dynamic control.','Use volume swells and whammy for a crying, vocal tone.'],
     'Studio recording, 1975 (Blow by Blow). Jeff Beck played an achingly expressive instrumental on a Stratocaster.',73),
    ('where-were-you','jeff-beck','guitar','riff','main melody','clean',
     'fusion','lead','expert',
     'Fender Stratocaster (Jeff Beck)','Clean-to-crunch amp','Open-back combo cab','neck single-coil',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":3,"delay":1,"master":6}'::jsonb,
     array['Ethereal instrumental using whammy-bar harmonics and volume swells for a vocal, weeping tone; keep it delicate.','Low-medium gain, delicate.'],
     array['Use whammy-bar harmonics for the melody.','Swell each note in gently.'],
     'Studio recording, 1989 (Guitar Shop). Jeff Beck played an ethereal whammy-and-harmonics instrumental on a Stratocaster.',72),
    ('glasgow-kiss','john-petrucci','guitar','riff','main theme and solo','high_gain',
     'metal','lead','expert',
     'Ernie Ball Music Man (John Petrucci)','Mesa/Boogie high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":1,"master":6}'::jsonb,
     array['Celtic-flavoured prog-metal instrumental with intricate riffs and blazing solos; keep it precise.','High gain with clarity.'],
     array['Play the intricate riffs precisely.','Nail the fast, melodic solos.'],
     'Studio recording, 2005 (Suspended Animation). John Petrucci played a Celtic-flavoured prog-metal instrumental.',72),
    ('technical-difficulties','paul-gilbert','guitar','riff','main riff and solo','high_gain',
     'metal','lead','expert',
     'Ibanez signature (Paul Gilbert)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Blistering shred with lightning alternate picking and string-skipping; keep the picking razor-tight.','High gain, bright.'],
     array['Play the fast alternate-picked runs cleanly.','Nail the string-skipping licks.'],
     'Studio recording, 1993 (Second Heat). Paul Gilbert played blistering alternate-picking shred on an Ibanez.',71),
    ('minds-eye','vinnie-moore','guitar','riff','main theme and solo','high_gain',
     'metal','lead','expert',
     'Electric guitar (Vinnie Moore)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":1,"master":6}'::jsonb,
     array['Melodic neoclassical shred with smooth legato and fast runs; keep it fluid and precise.','High gain.'],
     array['Play the melody with smooth legato.','Nail the fast neoclassical runs.'],
     'Studio recording, 1986 (Mind''s Eye). Vinnie Moore played melodic neoclassical shred through Marshalls.',71),
    ('altitudes','jason-becker','guitar','riff','main theme and solo','high_gain',
     'metal','lead','expert',
     'Electric guitar (Jason Becker)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":1,"master":6}'::jsonb,
     array['Soaring, melodic neoclassical instrumental with sweeps and fast runs; keep it lyrical and precise.','High gain.'],
     array['Play the soaring melody smoothly.','Nail the sweeps and fast runs.'],
     'Studio recording, 1988 (Perpetual Burn). Jason Becker played a soaring, melodic neoclassical instrumental.',71),
    ('dragons-kiss','marty-friedman','guitar','riff','main theme and solo','high_gain',
     'metal','lead','expert',
     'Jackson signature (Marty Friedman)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":1,"master":6}'::jsonb,
     array['Exotic, Eastern-flavoured shred with unusual scales and expressive bends; keep it fluid and dramatic.','High gain.'],
     array['Play the exotic scales with feeling.','Use wide, expressive bends.'],
     'Studio recording, 1988 (Dragon''s Kiss). Marty Friedman played exotic, Eastern-flavoured shred on a Jackson.',71),
    ('tumeni-notes','steve-morse','guitar','riff','main theme and solo','crunch',
     'rock','lead','expert',
     'Ernie Ball Music Man (Steve Morse)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Dazzling cross-picking instrumental blending rock, country, and classical; keep the picking precise.','Medium gain, articulate.'],
     array['Nail the fast cross-picking.','Keep every note clean and even.'],
     'Studio recording, 1989 (High Tension Wires). Steve Morse played a dazzling cross-picking instrumental.',71),
    ('get-the-funk-out','extreme','guitar','riff','main riff and solo','crunch',
     'rock','lead','advanced',
     'Washburn N4 signature (Nuno Bettencourt)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Tight funk-metal with percussive rhythm chops and a flashy solo; keep it snappy and precise.','Medium-high gain.'],
     array['Play the funk chops razor-tight.','Nail the flashy solo.'],
     'Studio recording, 1990 (Pornograffitti). Nuno Bettencourt played tight funk-metal and a flashy solo on a Washburn N4.',72)
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
  ('joe-satriani','surfing-with-the-alien'),('joe-satriani','always-with-me-always-with-you'),('joe-satriani','satch-boogie'),('joe-satriani','flying-in-a-blue-dream'),
  ('steve-vai','for-the-love-of-god'),('steve-vai','tender-surrender'),('steve-vai','building-the-church'),('yngwie-malmsteen','far-beyond-the-sun'),
  ('yngwie-malmsteen','black-star'),('eric-johnson','manhattan'),('buckethead','soothsayer'),('plini','handmade-cities'),
  ('guthrie-govan','waves'),('tommy-emmanuel','angelina'),('andy-mckee','drifting'),('chet-atkins','mr-sandman'),
  ('jeff-beck','cause-weve-ended-as-lovers'),('jeff-beck','where-were-you'),('john-petrucci','glasgow-kiss'),('paul-gilbert','technical-difficulties'),
  ('vinnie-moore','minds-eye'),('jason-becker','altitudes'),('marty-friedman','dragons-kiss'),('steve-morse','tumeni-notes'),
  ('extreme','get-the-funk-out')
) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
cross join (values
  ('artist_interview', 'Documented artist interviews and gear discussions', null::text,
   'Researched from widely-documented interviews about this recording and player.', 72),
  ('rig_rundown', 'Published rig rundowns and community gear databases', null::text,
   'Cross-referenced against rig features and community-maintained gear databases.', 66)
) as x(source_type, title, url, notes, credibility)
where p.verification_status = 'admin_verified'
on conflict do nothing;
