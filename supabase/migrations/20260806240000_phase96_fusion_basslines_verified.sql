-- Phase 96 bass: Jaco / Weather Report fusion basslines: researched verified tone profiles (generated 2026-08-06).
-- Assembled from per-artist research fragments; rigs sourced from
-- Equipboard/GroundGuitar/manufacturer interviews per song.
begin;

create temp table phase_targets(
  artist_name text, artist_slug text, song_title text, song_slug text,
  album text, release_year int
) on commit drop;

insert into phase_targets(artist_name, artist_slug, song_title, song_slug, album, release_year) values
('Jaco Pastorius','jaco-pastorius','Come On, Come Over','come-on-come-over','Jaco Pastorius',1976),
('Jaco Pastorius','jaco-pastorius','Continuum','continuum','Jaco Pastorius',1976),
('Jaco Pastorius','jaco-pastorius','Liberty City','liberty-city','Word of Mouth',1981),
('Jaco Pastorius','jaco-pastorius','Donna Lee','donna-lee','Jaco Pastorius',1976),
('Jaco Pastorius','jaco-pastorius','Punk Jazz','punk-jazz','Mr. Gone',1978),
('Jaco Pastorius','jaco-pastorius','Kuru/Speak Like a Child','kuru-speak-like-a-child','Jaco Pastorius',1976),
('Jaco Pastorius','jaco-pastorius','(Used to Be a) Cha-Cha','used-to-be-a-cha-cha','Jaco Pastorius',1976),
('Jaco Pastorius','jaco-pastorius','Okonkole y Trompa','okonkole-y-trompa','Jaco Pastorius',1976),
('Jaco Pastorius','jaco-pastorius','Chicken','chicken','The Birthday Concert',1995),
('Weather Report','weather-report','Barbary Coast','barbary-coast','Black Market',1976),
('Weather Report','weather-report','A Remark You Made','a-remark-you-made','Heavy Weather',1977),
('Weather Report','weather-report','Havona','havona','Heavy Weather',1977),
('Weather Report','weather-report','Black Market','black-market','Black Market',1976),
('Weather Report','weather-report','Palladium','palladium','Heavy Weather',1977),
('Weather Report','weather-report','Elegant People','elegant-people','Black Market',1976),
('Weather Report','weather-report','Cucumber Slumber','cucumber-slumber','Mysterious Traveller',1974),
('Weather Report','weather-report','125th Street Congress','125th-street-congress','Sweetnighter',1973);

insert into public.artists (name, slug, search_text, is_active)
select distinct artist_name, artist_slug, artist_name, true from phase_targets
on conflict (slug) do update set name = excluded.name, is_active = true;

insert into public.songs (artist_id, title, slug, album, release_year, search_text, is_active)
select a.id, t.song_title, t.song_slug, t.album, t.release_year,
       concat_ws(' ', t.song_title, t.artist_name, t.album), true
from phase_targets t join public.artists a on a.slug = t.artist_slug
on conflict (artist_id, slug) do update set
  title = excluded.title, album = excluded.album, release_year = excluded.release_year,
  is_active = true, updated_at = now();

-- Hide pre-existing duplicate songs (same artist+title, different slug)
update public.song_tone_profiles p
set is_public = false
from public.songs s, public.artists a, phase_targets t
where p.song_id = s.id and s.artist_id = a.id and a.slug = t.artist_slug
  and lower(s.title) = lower(t.song_title) and s.slug <> t.song_slug;

update public.songs s
set is_active = false
from public.artists a, phase_targets t
where s.artist_id = a.id and a.slug = t.artist_slug
  and lower(s.title) = lower(t.song_title) and s.slug <> t.song_slug;

-- Replace existing bass profiles for target songs
delete from public.tone_profile_effects e where e.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join phase_targets t on t.artist_slug = a.slug and t.song_slug = s.slug
  where p.mode = 'bass'
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join phase_targets t on t.artist_slug = a.slug and t.song_slug = s.slug
  where p.mode = 'bass'
);
delete from public.song_tone_profiles p where p.mode = 'bass' and p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join phase_targets t on t.artist_slug = a.slug and t.song_slug = s.slug
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
('come-on-come-over','jaco-pastorius','bass','bassline','Main Bassline','clean','funk','bass','intermediate',
 '1962 Fender Jazz Bass fretless "Bass of Doom"','Acoustic 360 preamp','Acoustic 361 1x18 folded-horn cab','Bridge single-coil favored',
 '[]'::jsonb,'{"gain":3,"bass":5,"mids":8,"treble":6,"presence":4,"reverb":0,"delay":0,"master":7}'::jsonb,
 array['Tight staccato fretless funk under Sam & Dave vocals -- bridge pickup soloed for that hollow nasal bark','Rotosound roundwounds and light muting keep every sixteenth punchy, not boomy'],
 array['Lock the ghost-note sixteenths with the horn stabs -- the groove is in the muted notes','Pluck near the bridge with a firm attack; release each note early for staccato punch'],
 'Jaco Pastorius debut album (1976); his 1962 fretless Jazz Bass "Bass of Doom" with Rotosound roundwounds and Acoustic 360/361 rig is among the best-documented bass setups ever.',78),
('continuum','jaco-pastorius','bass','bassline','Fretless Melody','clean','jazz fusion','bass','advanced',
 '1962 Fender Jazz Bass fretless "Bass of Doom"','Acoustic 360 preamp','Acoustic 361 1x18 folded-horn cab','Bridge single-coil favored',
 '[]'::jsonb,'{"gain":3,"bass":5,"mids":8,"treble":5,"presence":4,"reverb":2,"delay":0,"master":6}'::jsonb,
 array['The definitive singing fretless tone -- the chorus-like shimmer came from two detuned takes layered, not a pedal','Bridge pickup plus sliding vibrato gives the vocal, horn-like sustain'],
 array['Intonation is everything on fretless -- slide into pitch and correct by ear instantly','Use wide, slow left-hand vibrato along the string (not across) to make notes sing'],
 'Jaco Pastorius debut album (1976); rig thoroughly documented -- fretless 1962 Jazz Bass, bridge pickup, roundwounds; the doubling trick is well chronicled in interviews and biographies.',78),
('liberty-city','jaco-pastorius','bass','bassline','Main Bassline','clean','jazz fusion','bass','intermediate',
 '1962 Fender Jazz Bass fretless "Bass of Doom"','Acoustic 360 preamp','Acoustic 361 1x18 folded-horn cab','Bridge single-coil favored',
 '[]'::jsonb,'{"gain":3,"bass":6,"mids":7,"treble":6,"presence":4,"reverb":1,"delay":0,"master":7}'::jsonb,
 array['Joyful calypso-flavored big-band groove -- round fretless midrange anchors 14 horns and steel drums','Clean Acoustic 360 headroom keeps the bouncing line fat but articulate'],
 array['Keep the repeating two-bar figure buoyant -- think steel-drum bounce, not swing','Stay disciplined under the horn shout choruses; the bass is the anchor, save fills for the turnarounds'],
 'Word of Mouth (1981) big-band centerpiece, also on The Birthday Concert; Jaco''s fretless Jazz Bass and Acoustic 360 rig are extensively documented from this era.',74),
('donna-lee','jaco-pastorius','bass','bassline','Bebop Head','clean','jazz fusion','bass','advanced',
 '1962 Fender Jazz Bass fretless "Bass of Doom"','Acoustic 360 preamp','Acoustic 361 1x18 folded-horn cab','Bridge single-coil favored',
 '[]'::jsonb,'{"gain":3,"bass":4,"mids":8,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
 array['Charlie Parker''s bebop head played on bare fretless with only congas -- every nuance of the bridge-pickup tone is exposed','Dry, midrange-forward recording, essentially the direct sound of the Bass of Doom'],
 array['Learn the head at half speed and nail the intonation before adding tempo','Use economical right-hand two-finger alternation; the swing feel comes from slight note-length variation'],
 'Opening track of Jaco Pastorius (1976), one of the most transcribed electric bass performances ever; instrument and technique exhaustively documented.',80),
('punk-jazz','jaco-pastorius','bass','bassline','Intro Solo and Groove','clean','jazz fusion','bass','advanced',
 '1962 Fender Jazz Bass fretless "Bass of Doom"','Acoustic 360 preamp','Acoustic 361 1x18 folded-horn cab','Bridge single-coil favored',
 '[]'::jsonb,'{"gain":4,"bass":5,"mids":8,"treble":6,"presence":5,"reverb":1,"delay":0,"master":7}'::jsonb,
 array['Explosive unaccompanied fretless flurry that opens the track, then a fat swung fusion groove','Aggressive attack pushes the Acoustic 360 toward its natural edge while staying clean'],
 array['Treat the rubato intro as a drum roll on bass -- bursts of notes with dramatic silences','Dig in hard near the bridge for the growl; back off dynamics when the band enters'],
 'Jaco''s composition recorded with Weather Report on Mr. Gone (1978); his rig in this period is thoroughly documented, and the track is a celebrated Jaco showcase.',72),
('kuru-speak-like-a-child','jaco-pastorius','bass','bassline','Driving Groove','clean','jazz fusion','bass','advanced',
 '1962 Fender Jazz Bass fretless "Bass of Doom"','Acoustic 360 preamp','Acoustic 361 1x18 folded-horn cab','Bridge single-coil favored',
 '[]'::jsonb,'{"gain":3,"bass":5,"mids":8,"treble":6,"presence":4,"reverb":1,"delay":0,"master":7}'::jsonb,
 array['Relentless sixteenth-note fretless engine under Herbie Hancock''s piano and a string orchestra -- the strings carry the themes, the bass carries the motion','Percussive right hand plus fretless legato makes the ostinato both drive and sing'],
 array['Build sixteenth-note stamina slowly -- tension-free right hand or the nine-minute groove will fall apart','Accent the syncopations against the strings rather than playing every note evenly'],
 'Jaco Pastorius (1976); orchestral, piano-topped piece where the bass groove is the rhythmic core -- rig documentation is definitive for this album.',72),
('used-to-be-a-cha-cha','jaco-pastorius','bass','bassline','Latin Fusion Line','clean','jazz fusion','bass','advanced',
 '1962 Fender Jazz Bass fretless "Bass of Doom"','Acoustic 360 preamp','Acoustic 361 1x18 folded-horn cab','Bridge single-coil favored',
 '[]'::jsonb,'{"gain":3,"bass":5,"mids":8,"treble":6,"presence":4,"reverb":1,"delay":0,"master":6}'::jsonb,
 array['Springy latin-jazz fretless line that morphs between tumbao-flavored groove and melodic soloing','Clean bridge-pickup tone with sustain that lets upper-register phrases float over Hubert Laws'' flute'],
 array['Internalize the cha-cha clave feel first -- the line dances around the beat, not on it','Practice smooth position shifts up the neck; the part travels the whole fingerboard'],
 'Jaco Pastorius (1976); the album''s gear is exhaustively documented and this track is a frequently transcribed fretless workout.',72),
('okonkole-y-trompa','jaco-pastorius','bass','bassline','Harmonics Ostinato','clean','jazz fusion','bass','advanced',
 '1962 Fender Jazz Bass fretless "Bass of Doom"','Acoustic 360 preamp','Acoustic 361 1x18 folded-horn cab','Bridge single-coil favored',
 '[]'::jsonb,'{"gain":3,"bass":4,"mids":7,"treble":7,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
 array['Hypnotic ostinato built from natural and false harmonics, ringing like bells under French horn and percussion','Bright bridge-pickup setting with fresh roundwounds is essential -- dead strings kill harmonics'],
 array['Touch the string exactly over the harmonic node and lift instantly for maximum chime','Loop the ostinato until it is automatic -- the piece lives on unwavering repetition'],
 'Jaco Pastorius (1976); trio piece for bass, French horn and percussion built on Jaco''s trademark harmonics technique -- deeply documented in transcriptions and lessons.',72),
('chicken','jaco-pastorius','bass','bassline','Funk Groove','clean','funk','bass','intermediate',
 '1962 Fender Jazz Bass fretless "Bass of Doom"','Acoustic 360 preamp','Acoustic 361 1x18 folded-horn cab','Bridge single-coil favored',
 '[]'::jsonb,'{"gain":4,"bass":5,"mids":8,"treble":6,"presence":5,"reverb":1,"delay":0,"master":8}'::jsonb,
 array['The jam-session standard: greasy dominant-7 funk groove with fretless slides and double-stops, live big-band energy','Live Acoustic 360/361 rig pushed loud -- warm, midrange-heavy, slightly compressed by the folded horn'],
 array['Nail the signature two-bar figure verbatim first, then loosen it with ghost notes and slides','Follow the blues-based changes -- each four-bar section transposes the groove'],
 'Soul Intro/The Chicken from The Birthday Concert (recorded Fort Lauderdale 1981, released 1995); Jaco''s live rig from this period is very well documented.',74),
('barbary-coast','weather-report','bass','bassline','Main Bassline','clean','jazz fusion','bass','intermediate',
 '1962 Fender Jazz Bass fretless "Bass of Doom"','Acoustic 360 preamp','Acoustic 361 1x18 folded-horn cab','Bridge single-coil favored',
 '[]'::jsonb,'{"gain":4,"bass":5,"mids":8,"treble":6,"presence":4,"reverb":1,"delay":0,"master":7}'::jsonb,
 array['Jaco''s first recorded Weather Report track -- lowdown, gritty funk strut with fretless slides and bar-line anticipations','Bridge-pickup bark with palm-tight ghost notes; the groove swaggers rather than rushes'],
 array['Play behind the beat -- the strut comes from laying back against the drums','Use ghost notes and short slides into target pitches to copy the greasy phrasing'],
 'Black Market (1976); album credits confirm Jaco (not Alphonso Johnson) plays this track -- his own composition and Weather Report debut.',74),
('a-remark-you-made','weather-report','bass','bassline','Fretless Ballad Melody','clean','jazz fusion','bass','intermediate',
 '1962 Fender Jazz Bass fretless "Bass of Doom"','Acoustic 360 preamp','Acoustic 361 1x18 folded-horn cab','Bridge single-coil favored',
 '[]'::jsonb,'{"gain":3,"bass":6,"mids":8,"treble":5,"presence":4,"reverb":2,"delay":0,"master":6}'::jsonb,
 array['Zawinul wrote the ballad around Jaco''s voice -- the fretless answers the melody like a second singer, warm and vocal','Long portamento slides and slow vibrato with maximum sustain; darker and rounder than his funk setting'],
 array['Shape every phrase like a breath -- start slides slow and land dead in tune','Balance the duet role: support the keyboard melody, then bloom into the answering phrases'],
 'Heavy Weather (1977); a keyboard-led Zawinul ballad, but Jaco''s counter-melodic fretless part is fully documented and central to the track.',76),
('havona','weather-report','bass','bassline','Groove and Solo','clean','jazz fusion','bass','advanced',
 '1962 Fender Jazz Bass fretless "Bass of Doom"','Acoustic 360 preamp','Acoustic 361 1x18 folded-horn cab','Bridge single-coil favored',
 '[]'::jsonb,'{"gain":3,"bass":5,"mids":8,"treble":6,"presence":5,"reverb":1,"delay":0,"master":7}'::jsonb,
 array['Jaco''s own tune and arguably his greatest recorded solo -- burbling sixteenth-note latin groove into fluid bebop lines','Clean, articulate bridge-pickup fretless tone; every note speaks even at breakneck tempo'],
 array['Master the ostinato groove and the solo separately -- they demand different right-hand feels','Transcribe the solo phrase by phrase; the vocabulary is bebop, the delivery is legato fretless'],
 'Heavy Weather (1977); Jaco composition, universally cited as a landmark electric bass performance with exhaustively documented gear.',78),
('black-market','weather-report','bass','bassline','Main Groove','clean','jazz fusion','bass','intermediate',
 'Fender Jazz Bass','Ampeg SVT','Ampeg 8x10 cab','Both single-coils blended',
 '[]'::jsonb,'{"gain":3,"bass":6,"mids":6,"treble":5,"presence":4,"reverb":1,"delay":0,"master":7}'::jsonb,
 array['Alphonso Johnson (not Jaco) plays the title track -- a rolling, fretted funk-fusion groove under Zawinul''s synth melodies','Warm, round fingerstyle tone that sits beneath the synth-led arrangement rather than out front'],
 array['Keep the eighth-note pulse even and hypnotic -- this groove is about momentum, not fills','Mute lightly with the palm so the low end stays defined under dense keyboards'],
 'Black Market (1976); credits confirm Alphonso Johnson on this synth-led title track (Jaco appears only on Cannon Ball and Barbary Coast); his exact amp is not well documented -- settings approximated.',66),
('palladium','weather-report','bass','bassline','Main Bassline','clean','jazz fusion','bass','advanced',
 '1962 Fender Jazz Bass fretless "Bass of Doom"','Acoustic 360 preamp','Acoustic 361 1x18 folded-horn cab','Bridge single-coil favored',
 '[]'::jsonb,'{"gain":4,"bass":5,"mids":8,"treble":6,"presence":5,"reverb":1,"delay":0,"master":7}'::jsonb,
 array['Caribbean-flavored burner -- Jaco doubles horn-like figures and drives the steel-drum-tinged ensemble with punchy fretless attack','Bright, percussive bridge-pickup tone; the bass jumps registers like a lead instrument'],
 array['Practice the unison ensemble figures slowly -- the rhythmic hits must be exact','Keep the calypso feel light on top even when the sixteenth-note bursts get dense'],
 'Heavy Weather (1977); Wayne Shorter composition with Jaco''s documented fretless rig; a frequently transcribed high-energy part.',72),
('elegant-people','weather-report','bass','bassline','Main Groove','clean','jazz fusion','bass','intermediate',
 'Fender Jazz Bass','Ampeg SVT','Ampeg 8x10 cab','Both single-coils blended',
 '[]'::jsonb,'{"gain":3,"bass":6,"mids":6,"treble":5,"presence":4,"reverb":1,"delay":0,"master":6}'::jsonb,
 array['Alphonso Johnson holds down this majestic Shorter piece -- a stately, melodic fretted line under horn-like synth and sax themes','Smooth, warm fingerstyle tone; the bass moves melodically but never crowds the keyboard-led arrangement'],
 array['Voice-lead between chord tones -- the line is a slow melody, not a static root pattern','Play with a soft attack and full note lengths to match the track''s regal pacing'],
 'Black Market (1976); credits confirm Alphonso Johnson on this track (Jaco plays only two album tracks); a keys/sax-led piece, and Johnson''s per-song amp is undocumented -- settings approximated.',65),
('cucumber-slumber','weather-report','bass','bassline','Funk Groove','clean','funk','bass','intermediate',
 'Fender Jazz Bass','Ampeg SVT','Ampeg 8x10 cab','Both single-coils blended',
 '[]'::jsonb,'{"gain":3,"bass":6,"mids":7,"treble":5,"presence":4,"reverb":0,"delay":0,"master":7}'::jsonb,
 array['Johnson co-wrote this around his own slinky fingerstyle riff -- one of fusion''s great one-chord funk vamps','Round, singing fretted Jazz Bass tone with a soft attack; groove first, flash never'],
 array['Loop the main riff until the ghost-note placement is second nature -- the funk lives in the space between notes','Resist embellishing early; the line evolves gradually over the whole vamp'],
 'Mysterious Traveller (1974); Alphonso Johnson co-composition built on his bassline -- his Fender Jazz era is documented, though per-song amp details are thin.',70),
('125th-street-congress','weather-report','bass','bassline','Funk Vamp','clean','funk','bass','intermediate',
 'Fender Jazz Bass','Ampeg B-15','Ampeg 1x15 cab','Both single-coils blended',
 '[]'::jsonb,'{"gain":3,"bass":6,"mids":6,"treble":4,"presence":3,"reverb":0,"delay":0,"master":6}'::jsonb,
 array['Andrew White -- not Vitous or Alphonso Johnson -- plays the remorselessly funky electric bass vamp on this Sweetnighter jam','Deep, slightly dull early-70s fingerstyle tone that loops one groove for twelve hypnotic minutes'],
 array['Commit to the repetition -- the vamp barely changes, so make the pocket airtight','Deaden the strings slightly (or roll off treble) to get the vintage thumpy attack'],
 'Sweetnighter (1973); album credits confirm Andrew White on electric bass for this track; his specific instrument and amp are undocumented, so gear here is a period-typical approximation.',62)
) as c(song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
       original_guitar, original_amp, original_cab, original_pickup,
       original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;

do $$
declare
  expected int;
  actual int;
begin
  select count(*) into expected from phase_targets;
  select count(*) into actual
  from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id
  join public.artists a on a.id = s.artist_id
  join phase_targets t on t.artist_slug = a.slug and t.song_slug = s.slug
  where p.mode = 'bass' and p.verification_status = 'admin_verified';
  if actual < expected then
    raise exception 'POST-CONDITION FAILED: % verified bass profiles for % targets — slug mismatch between fragments', actual, expected;
  end if;
end $$;

commit;
