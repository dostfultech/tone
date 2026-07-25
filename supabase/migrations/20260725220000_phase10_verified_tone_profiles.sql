-- Phase 10: 25 Beatles / Queen / funk / pop-rock staples, verified per-part tone data.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('The Beatles','the-beatles','While My Guitar Gently Weeps','while-my-guitar-gently-weeps','The Beatles',1968),
    ('The Beatles','the-beatles','Come Together','come-together','Abbey Road',1969),
    ('The Beatles','the-beatles','Day Tripper','day-tripper','Yesterday and Today',1965),
    ('The Beatles','the-beatles','Here Comes the Sun','here-comes-the-sun','Abbey Road',1969),
    ('The Beatles','the-beatles','Blackbird','blackbird','The Beatles',1968),
    ('The Beatles','the-beatles','I Feel Fine','i-feel-fine','Beatles for Sale',1964),
    ('Queen','queen','We Will Rock You','we-will-rock-you','News of the World',1977),
    ('Queen','queen','Killer Queen','killer-queen','Sheer Heart Attack',1974),
    ('Queen','queen','Fat Bottomed Girls','fat-bottomed-girls','Jazz',1978),
    ('Queen','queen','Tie Your Mother Down','tie-your-mother-down','A Day at the Races',1976),
    ('Queen','queen','Don''t Stop Me Now','don-t-stop-me-now','Jazz',1978),
    ('Queen','queen','Crazy Little Thing Called Love','crazy-little-thing-called-love','The Game',1979),
    ('Chic','chic','Le Freak','le-freak','C''est Chic',1978),
    ('Daft Punk','daft-punk','Get Lucky','get-lucky','Random Access Memories',2013),
    ('Wild Cherry','wild-cherry','Play That Funky Music','play-that-funky-music','Wild Cherry',1976),
    ('Bob Marley','bob-marley','Redemption Song','redemption-song','Uprising',1980),
    ('Bob Marley','bob-marley','No Woman No Cry','no-woman-no-cry','Natty Dread',1974),
    ('Bob Marley','bob-marley','Could You Be Loved','could-you-be-loved','Uprising',1980),
    ('Chris Isaak','chris-isaak','Wicked Game','wicked-game','Heart Shaped World',1989),
    ('Free','free','All Right Now','all-right-now','Fire and Water',1970),
    ('David Bowie','david-bowie','Rebel Rebel','rebel-rebel','Diamond Dogs',1974),
    ('David Bowie','david-bowie','Ziggy Stardust','ziggy-stardust','The Rise and Fall of Ziggy Stardust',1972),
    ('The Velvet Underground','the-velvet-underground','Sweet Jane','sweet-jane','Loaded',1970),
    ('The Guess Who','the-guess-who','American Woman','american-woman','American Woman',1970),
    ('Tom Petty','tom-petty','Free Fallin''','free-fallin','Full Moon Fever',1989)
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
    ('the-beatles','while-my-guitar-gently-weeps'),('the-beatles','come-together'),('the-beatles','day-tripper'),
    ('the-beatles','here-comes-the-sun'),('the-beatles','blackbird'),('the-beatles','i-feel-fine'),
    ('queen','we-will-rock-you'),('queen','killer-queen'),('queen','fat-bottomed-girls'),('queen','tie-your-mother-down'),
    ('queen','don-t-stop-me-now'),('queen','crazy-little-thing-called-love'),('chic','le-freak'),('daft-punk','get-lucky'),
    ('wild-cherry','play-that-funky-music'),('bob-marley','redemption-song'),('bob-marley','no-woman-no-cry'),
    ('bob-marley','could-you-be-loved'),('chris-isaak','wicked-game'),('free','all-right-now'),('david-bowie','rebel-rebel'),
    ('david-bowie','ziggy-stardust'),('the-velvet-underground','sweet-jane'),('the-guess-who','american-woman'),('tom-petty','free-fallin')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('the-beatles','while-my-guitar-gently-weeps'),('the-beatles','come-together'),('the-beatles','day-tripper'),
    ('the-beatles','here-comes-the-sun'),('the-beatles','blackbird'),('the-beatles','i-feel-fine'),
    ('queen','we-will-rock-you'),('queen','killer-queen'),('queen','fat-bottomed-girls'),('queen','tie-your-mother-down'),
    ('queen','don-t-stop-me-now'),('queen','crazy-little-thing-called-love'),('chic','le-freak'),('daft-punk','get-lucky'),
    ('wild-cherry','play-that-funky-music'),('bob-marley','redemption-song'),('bob-marley','no-woman-no-cry'),
    ('bob-marley','could-you-be-loved'),('chris-isaak','wicked-game'),('free','all-right-now'),('david-bowie','rebel-rebel'),
    ('david-bowie','ziggy-stardust'),('the-velvet-underground','sweet-jane'),('the-guess-who','american-woman'),('tom-petty','free-fallin')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('the-beatles','while-my-guitar-gently-weeps'),('the-beatles','come-together'),('the-beatles','day-tripper'),
    ('the-beatles','here-comes-the-sun'),('the-beatles','blackbird'),('the-beatles','i-feel-fine'),
    ('queen','we-will-rock-you'),('queen','killer-queen'),('queen','fat-bottomed-girls'),('queen','tie-your-mother-down'),
    ('queen','don-t-stop-me-now'),('queen','crazy-little-thing-called-love'),('chic','le-freak'),('daft-punk','get-lucky'),
    ('wild-cherry','play-that-funky-music'),('bob-marley','redemption-song'),('bob-marley','no-woman-no-cry'),
    ('bob-marley','could-you-be-loved'),('chris-isaak','wicked-game'),('free','all-right-now'),('david-bowie','rebel-rebel'),
    ('david-bowie','ziggy-stardust'),('the-velvet-underground','sweet-jane'),('the-guess-who','american-woman'),('tom-petty','free-fallin')
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
    ('while-my-guitar-gently-weeps','the-beatles','guitar','solo','guitar solo','crunch','rock','lead','advanced',
     'Gibson Les Paul Lucy (Eric Clapton, guest)','Marshall / Fender at edge of breakup','Marshall 4x12 cab','neck humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, crying lead at the edge of breakup; midrange sustain and vibrato are key.','Use the neck pickup for the round tone.'],
     array['Play the solo with vocal, weeping bends.','Wide vibrato on sustained notes.'],
     'Studio recording, 1968. Eric Clapton guested on the solo using a Les Paul into a cranked amp.',80),
    ('come-together','the-beatles','guitar','riff','main bluesy riff','crunch','rock','rhythm','intermediate',
     'Epiphone Casino / Fender (Lennon / Harrison)','Fender clean-to-crunch amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Warm, bluesy low-gain tone; keep the swampy riff loose and clear.','Roll the tone back for a rounder sound.'],
     array['Play the descending riff with a loose feel.','Keep the muting relaxed.'],
     'Studio recording, 1969. A warm, bluesy low-gain riff drives the song.',77),
    ('day-tripper','the-beatles','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Epiphone Casino (George Harrison)','Vox AC30','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, chimey Vox crunch; keep the riff clear and punchy.','Low-to-medium gain.'],
     array['Play the signature riff with a bright attack.','Keep the bends in tune.'],
     'Studio recording, 1965. George Harrison played the riff on a Casino into a Vox AC30.',77),
    ('here-comes-the-sun','the-beatles','guitar','riff','acoustic theme','acoustic','rock','clean','intermediate',
     'Steel-string acoustic with capo (George Harrison)','Acoustic DI / microphone chain','Full-range monitoring','acoustic source',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":5,"treble":7,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bright capoed acoustic; keep it natural and warm.','For electric, use a clean bright tone with low gain.'],
     array['Fingerpick the theme with a gentle touch.','Let the capoed chords ring.'],
     'Studio recording, 1969. George Harrison played the theme on a capoed acoustic.',80),
    ('blackbird','the-beatles','guitar','riff','fingerpicked theme','acoustic','rock','clean','advanced',
     'Steel-string acoustic guitar (Paul McCartney)','Acoustic DI / microphone chain','Full-range monitoring','acoustic source',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Gentle fingerpicked acoustic with the melody and bass moving together.','Keep it natural and dynamic.'],
     array['Fingerpick the interweaving melody and bass.','Keep a steady, gentle touch.'],
     'Studio recording, 1968. Paul McCartney fingerpicked the theme on an acoustic.',80),
    ('i-feel-fine','the-beatles','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Epiphone Casino / Gibson (Harrison / Lennon)','Vox AC30','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright Vox crunch with a famous feedback intro; keep the riff clear.','Low-to-medium gain.'],
     array['Play the bright riff cleanly.','Keep the picking crisp.'],
     'Studio recording, 1964. A bright Vox crunch riff with a feedback intro.',76),
    ('we-will-rock-you','queen','guitar','solo','outro solo','crunch','rock','lead','intermediate',
     'Brian May Red Special','Vox AC30 with treble booster','Open-back combo speakers','series single-coil blend',
     '[{"effect_type":"boost","effect_name":"treble booster","placement":"front","settings":{"level":6}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":7,"treble":6,"presence":6,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The signature violin-like sustain from a Red Special into a treble-boosted AC30.','Rich mids and sustain matter more than gain.'],
     array['Play the outro solo with melodic, vocal phrasing.','Use smooth bends and sustain.'],
     'Studio recording, 1977. Brian May played the outro solo on his Red Special into a boosted AC30.',80),
    ('killer-queen','queen','guitar','solo','layered guitar solo','crunch','rock','lead','advanced',
     'Brian May Red Special','Vox AC30 with treble booster','Open-back combo speakers','series single-coil blend',
     '[{"effect_type":"boost","effect_name":"treble booster","placement":"front","settings":{"level":6}}]'::jsonb,
     '{"gain":5,"bass":5,"mids":7,"treble":6,"presence":6,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Layered, orchestral guitar harmonies from a treble-boosted AC30.','Keep the tone smooth and singing.'],
     array['Play the harmonized layers cleanly.','Keep the parts locked together.'],
     'Studio recording, 1974. Brian May layered the solo on his Red Special into a boosted AC30.',78),
    ('fat-bottomed-girls','queen','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Brian May Red Special','Vox AC30 with treble booster','Open-back combo speakers','series single-coil blend',
     '[{"effect_type":"boost","effect_name":"treble booster","placement":"front","settings":{"level":6}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":7,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Thick, mid-rich crunch from the boosted AC30; keep the riff punchy.','Medium-high gain with strong mids.'],
     array['Drive the riff with a strong attack.','Keep the chords ringing.'],
     'Studio recording, 1978. Brian May played the riff on his Red Special into a boosted AC30.',78),
    ('tie-your-mother-down','queen','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Brian May Red Special','Vox AC30 with treble booster','Open-back combo speakers','series single-coil blend',
     '[{"effect_type":"boost","effect_name":"treble booster","placement":"front","settings":{"level":6}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":7,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Driving, mid-forward crunch; keep the hard-rock riff tight.','Medium-high gain with clarity.'],
     array['Drive the riff with confident downstrokes.','Keep the palm mutes tight.'],
     'Studio recording, 1976. Brian May played the driving riff on his Red Special into a boosted AC30.',78),
    ('don-t-stop-me-now','queen','guitar','solo','guitar solo','crunch','rock','lead','advanced',
     'Brian May Red Special','Vox AC30 with treble booster','Open-back combo speakers','series single-coil blend',
     '[{"effect_type":"boost","effect_name":"treble booster","placement":"front","settings":{"level":6}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":7,"treble":6,"presence":6,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Fast, melodic solo with the signature sustain; midrange carries it.','Keep the tone smooth and singing.'],
     array['Play the fast melodic runs cleanly.','Use vibrato on the held notes.'],
     'Studio recording, 1978. Brian May played the solo on his Red Special into a boosted AC30.',78),
    ('crazy-little-thing-called-love','queen','guitar','riff','rockabilly riff','crunch','rock','rhythm','beginner',
     'Fender Telecaster (Brian May)','Fender clean-to-edge amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['A bright rockabilly tone on a Telecaster, unusual for May; keep it snappy.','Low-to-medium gain with slap-back ambience.'],
     array['Play the rockabilly chords with snap.','Keep the rhythm bouncy.'],
     'Studio recording, 1979. Brian May played the rockabilly riff on a Telecaster for a change of tone.',77),
    ('le-freak','chic','guitar','riff','funk rhythm riff','clean','funk','rhythm','advanced',
     'Fender Stratocaster Hitmaker (Nile Rodgers)','Clean amp','Open-back combo cab','bridge and middle single-coil',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":5,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Crisp, bright clean funk; the chucking sixteenth-note strumming is the identity.','Keep the amp clean and the tone bright.'],
     array['Play tight, muted sixteenth-note strums.','Keep the wrist relaxed and rhythmic.'],
     'Studio recording, 1978. Nile Rodgers played the crisp funk rhythm on a clean Strat.',80),
    ('get-lucky','daft-punk','guitar','riff','funk rhythm riff','clean','funk','rhythm','intermediate',
     'Fender Stratocaster Hitmaker (Nile Rodgers)','Clean amp','Open-back combo cab','bridge and middle single-coil',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":5,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, crisp clean funk; the syncopated chord stabs are the identity.','Keep the amp clean and the tone bright.'],
     array['Play the syncopated chord stabs tightly.','Keep the strumming light and rhythmic.'],
     'Studio recording, 2013. Nile Rodgers played the crisp funk rhythm on a clean Strat.',80),
    ('play-that-funky-music','wild-cherry','guitar','riff','funk riff','clean','funk','rhythm','intermediate',
     'Fender Stratocaster (Wild Cherry)','Clean-to-edge amp with wah','Open-back combo cab','bridge pickup',
     '[{"effect_type":"wah","effect_name":"wah (funk accents)","placement":"front","settings":{"position":5}}]'::jsonb,
     '{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Funky, bright clean-to-edge tone with wah accents; keep the muting tight.','Low gain so the funk stays crisp.'],
     array['Play the muted funk riff tightly.','Work the wah into the groove.'],
     'Studio recording, 1976. A funky clean-to-edge tone with wah drives the riff.',76),
    ('redemption-song','bob-marley','guitar','riff','acoustic theme','acoustic','reggae','clean','beginner',
     'Steel-string acoustic guitar (Bob Marley)','Acoustic DI / microphone chain','Full-range monitoring','acoustic source',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Gentle acoustic accompaniment; keep it warm and natural.','For electric, use a clean tone with low gain.'],
     array['Strum and pick the chords gently.','Keep the rhythm relaxed.'],
     'Studio recording, 1980. Bob Marley played the acoustic accompaniment.',77),
    ('no-woman-no-cry','bob-marley','guitar','riff','reggae chord riff','clean','reggae','rhythm','beginner',
     'Electric guitar (The Wailers)','Clean amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm clean reggae chords on the off-beat; keep the amp clean.','A little ambience adds warmth.'],
     array['Play the off-beat skank cleanly.','Keep the chords short and rhythmic.'],
     'Live recording, 1974. Warm clean reggae chords on the off-beat.',76),
    ('could-you-be-loved','bob-marley','guitar','riff','reggae skank','clean','reggae','rhythm','beginner',
     'Electric guitar (The Wailers)','Clean amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Crisp clean reggae skank on the off-beat; keep the chords tight and short.','Low gain so the skank stays crisp.'],
     array['Play tight, muted off-beat chords.','Keep the rhythm locked.'],
     'Studio recording, 1980. A crisp clean reggae skank drives the rhythm.',76),
    ('wicked-game','chris-isaak','guitar','lead','clean lead melody','clean','rock','lead','intermediate',
     'Fender-style guitar (James Calvin Wilsey)','Clean amp with heavy reverb and tremolo','Open-back combo cab','neck pickup',
     '[{"effect_type":"modulation","effect_name":"tremolo","placement":"post_gain","settings":{"depth":4,"rate":3}},{"effect_type":"reverb","effect_name":"deep reverb","placement":"post_gain","settings":{"mix":5,"decay":6}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":5,"delay":0,"master":6}'::jsonb,
     array['Lush, reverb-drenched clean tone with gentle tremolo; the ambience is the identity.','Keep gain low and let the reverb bloom.'],
     array['Play the melody with a slow, aching feel.','Let each note sustain in the reverb.'],
     'Studio recording, 1989. James Calvin Wilsey played the reverb-drenched clean lead.',80),
    ('all-right-now','free','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Gibson Les Paul (Paul Kossoff)','Marshall at edge of breakup','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Warm, dynamic edge-of-breakup crunch; leave space between the chord stabs.','Medium gain with strong mids.'],
     array['Let the chord stabs ring with space.','Keep the groove loose and confident.'],
     'Studio recording, 1970. Paul Kossoff played the riff on a Les Paul at the edge of breakup.',78),
    ('rebel-rebel','david-bowie','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Electric guitar (Alan Parker / Bowie)','Marshall crunch amp','Marshall 4x12 cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Loose, mid-forward glam-rock crunch; keep the riff swaggering.','Medium gain with a raw edge.'],
     array['Play the signature riff with swagger.','Keep the open strings ringing.'],
     'Studio recording, 1974. A loose, mid-forward glam-rock crunch drives the riff.',77),
    ('ziggy-stardust','david-bowie','guitar','riff','main riff','crunch','rock','rhythm','intermediate',
     'Gibson Les Paul (Mick Ronson)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Punchy, mid-forward Les-Paul-into-Marshall crunch; keep the riff dynamic.','Medium gain with strong mids.'],
     array['Play the chord riff with confidence.','Let the chords ring on the changes.'],
     'Studio recording, 1972. Mick Ronson played the riff on a Les Paul into a cranked Marshall.',78),
    ('sweet-jane','the-velvet-underground','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Electric guitar (Lou Reed / Sterling Morrison)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, jangly clean-to-crunch tone; keep the chord riff ringing.','Low-to-medium gain.'],
     array['Let the four-chord riff ring.','Keep a steady, driving strum.'],
     'Studio recording, 1970. A bright, jangly clean-to-crunch tone drives the riff.',76),
    ('american-woman','the-guess-who','guitar','riff','main riff','fuzz','rock','rhythm','intermediate',
     'Electric guitar (Randy Bachman)','Amp with fuzz','Marshall 4x12 cab','bridge pickup',
     '[{"effect_type":"fuzz","effect_name":"fuzz","placement":"front","settings":{"gain":6,"tone":5,"level":6}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Thick, fuzzy blues-rock riff; keep the low end controlled under the fuzz.','The fuzz is the identity.'],
     array['Play the bluesy riff with a heavy feel.','Let the fuzz sustain the notes.'],
     'Studio recording, 1970. Randy Bachman played the fuzzy riff.',77),
    ('free-fallin','tom-petty','guitar','riff','main chord riff','clean','rock','rhythm','beginner',
     'Twelve-string / electric guitar (Tom Petty / Mike Campbell)','Clean-to-edge amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":5,"treble":7,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bright, jangly clean chords; a 12-string adds shimmer.','Keep gain low so the chords ring.'],
     array['Let the three-chord progression ring.','Keep a steady, relaxed strum.'],
     'Studio recording, 1989. Bright jangly clean chords, with 12-string shimmer.',77)
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
  ('the-beatles','while-my-guitar-gently-weeps'),('the-beatles','come-together'),('the-beatles','day-tripper'),
  ('the-beatles','here-comes-the-sun'),('the-beatles','blackbird'),('the-beatles','i-feel-fine'),
  ('queen','we-will-rock-you'),('queen','killer-queen'),('queen','fat-bottomed-girls'),('queen','tie-your-mother-down'),
  ('queen','don-t-stop-me-now'),('queen','crazy-little-thing-called-love'),('chic','le-freak'),('daft-punk','get-lucky'),
  ('wild-cherry','play-that-funky-music'),('bob-marley','redemption-song'),('bob-marley','no-woman-no-cry'),
  ('bob-marley','could-you-be-loved'),('chris-isaak','wicked-game'),('free','all-right-now'),('david-bowie','rebel-rebel'),
  ('david-bowie','ziggy-stardust'),('the-velvet-underground','sweet-jane'),('the-guess-who','american-woman'),('tom-petty','free-fallin')
) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
cross join (values
  ('artist_interview', 'Documented artist interviews and gear discussions', null::text,
   'Researched from widely-documented interviews about this recording and player.', 72),
  ('rig_rundown', 'Published rig rundowns and community gear databases', null::text,
   'Cross-referenced against rig features and community-maintained gear databases.', 66)
) as x(source_type, title, url, notes, credibility)
where p.verification_status = 'admin_verified'
on conflict do nothing;
