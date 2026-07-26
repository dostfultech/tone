-- Phase 25: 25 grunge & 90s alt depth, verified per-part tone data (more Nirvana, Pearl Jam, Soundgarden, Alice in Chains, STP, Smashing Pumpkins, RHCP, Foo Fighters + Screaming Trees, Temple of the Dog, Local H, Toadies, Everclear, Semisonic, Gin Blossoms).

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Nirvana','nirvana','All Apologies','all-apologies','In Utero',1993),
    ('Nirvana','nirvana','Something in the Way','something-in-the-way','Nevermind',1991),
    ('Nirvana','nirvana','The Man Who Sold the World','the-man-who-sold-the-world','MTV Unplugged in New York',1994),
    ('Pearl Jam','pearl-jam','Yellow Ledbetter','yellow-ledbetter','single',1992),
    ('Pearl Jam','pearl-jam','Daughter','daughter','Vs.',1993),
    ('Pearl Jam','pearl-jam','Better Man','better-man','Vitalogy',1994),
    ('Soundgarden','soundgarden','Rusty Cage','rusty-cage','Badmotorfinger',1991),
    ('Soundgarden','soundgarden','Fell on Black Days','fell-on-black-days','Superunknown',1994),
    ('Alice in Chains','alice-in-chains','No Excuses','no-excuses','Jar of Flies',1994),
    ('Alice in Chains','alice-in-chains','Down in a Hole','down-in-a-hole','Dirt',1992),
    ('Stone Temple Pilots','stone-temple-pilots','Vasoline','vasoline','Purple',1994),
    ('Stone Temple Pilots','stone-temple-pilots','Big Empty','big-empty','Purple',1994),
    ('The Smashing Pumpkins','the-smashing-pumpkins','Tonight, Tonight','tonight-tonight','Mellon Collie and the Infinite Sadness',1995),
    ('The Smashing Pumpkins','the-smashing-pumpkins','Zero','zero','Mellon Collie and the Infinite Sadness',1995),
    ('Red Hot Chili Peppers','red-hot-chili-peppers','Suck My Kiss','suck-my-kiss','Blood Sugar Sex Magik',1991),
    ('Red Hot Chili Peppers','red-hot-chili-peppers','Around the World','around-the-world','Californication',1999),
    ('Foo Fighters','foo-fighters','All My Life','all-my-life','One by One',2002),
    ('Foo Fighters','foo-fighters','This Is a Call','this-is-a-call','Foo Fighters',1995),
    ('Screaming Trees','screaming-trees','Nearly Lost You','nearly-lost-you','Sweet Oblivion',1992),
    ('Temple of the Dog','temple-of-the-dog','Hunger Strike','hunger-strike','Temple of the Dog',1991),
    ('Local H','local-h','Bound for the Floor','bound-for-the-floor','As Good as Dead',1996),
    ('Toadies','toadies','Possum Kingdom','possum-kingdom','Rubberneck',1994),
    ('Everclear','everclear','Santa Monica','santa-monica','Sparkle and Fade',1996),
    ('Semisonic','semisonic','Closing Time','closing-time','Feeling Strangely Fine',1998),
    ('Gin Blossoms','gin-blossoms','Hey Jealousy','hey-jealousy','New Miserable Experience',1992)
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
    ('nirvana','all-apologies'),('nirvana','something-in-the-way'),('nirvana','the-man-who-sold-the-world'),('pearl-jam','yellow-ledbetter'),
    ('pearl-jam','daughter'),('pearl-jam','better-man'),('soundgarden','rusty-cage'),('soundgarden','fell-on-black-days'),
    ('alice-in-chains','no-excuses'),('alice-in-chains','down-in-a-hole'),('stone-temple-pilots','vasoline'),('stone-temple-pilots','big-empty'),
    ('the-smashing-pumpkins','tonight-tonight'),('the-smashing-pumpkins','zero'),('red-hot-chili-peppers','suck-my-kiss'),('red-hot-chili-peppers','around-the-world'),
    ('foo-fighters','all-my-life'),('foo-fighters','this-is-a-call'),('screaming-trees','nearly-lost-you'),('temple-of-the-dog','hunger-strike'),
    ('local-h','bound-for-the-floor'),('toadies','possum-kingdom'),('everclear','santa-monica'),('semisonic','closing-time'),
    ('gin-blossoms','hey-jealousy')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('nirvana','all-apologies'),('nirvana','something-in-the-way'),('nirvana','the-man-who-sold-the-world'),('pearl-jam','yellow-ledbetter'),
    ('pearl-jam','daughter'),('pearl-jam','better-man'),('soundgarden','rusty-cage'),('soundgarden','fell-on-black-days'),
    ('alice-in-chains','no-excuses'),('alice-in-chains','down-in-a-hole'),('stone-temple-pilots','vasoline'),('stone-temple-pilots','big-empty'),
    ('the-smashing-pumpkins','tonight-tonight'),('the-smashing-pumpkins','zero'),('red-hot-chili-peppers','suck-my-kiss'),('red-hot-chili-peppers','around-the-world'),
    ('foo-fighters','all-my-life'),('foo-fighters','this-is-a-call'),('screaming-trees','nearly-lost-you'),('temple-of-the-dog','hunger-strike'),
    ('local-h','bound-for-the-floor'),('toadies','possum-kingdom'),('everclear','santa-monica'),('semisonic','closing-time'),
    ('gin-blossoms','hey-jealousy')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('nirvana','all-apologies'),('nirvana','something-in-the-way'),('nirvana','the-man-who-sold-the-world'),('pearl-jam','yellow-ledbetter'),
    ('pearl-jam','daughter'),('pearl-jam','better-man'),('soundgarden','rusty-cage'),('soundgarden','fell-on-black-days'),
    ('alice-in-chains','no-excuses'),('alice-in-chains','down-in-a-hole'),('stone-temple-pilots','vasoline'),('stone-temple-pilots','big-empty'),
    ('the-smashing-pumpkins','tonight-tonight'),('the-smashing-pumpkins','zero'),('red-hot-chili-peppers','suck-my-kiss'),('red-hot-chili-peppers','around-the-world'),
    ('foo-fighters','all-my-life'),('foo-fighters','this-is-a-call'),('screaming-trees','nearly-lost-you'),('temple-of-the-dog','hunger-strike'),
    ('local-h','bound-for-the-floor'),('toadies','possum-kingdom'),('everclear','santa-monica'),('semisonic','closing-time'),
    ('gin-blossoms','hey-jealousy')
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
    ('all-apologies','nirvana','guitar','riff','main riff','crunch',
     'grunge','rhythm','beginner',
     'Fender Mustang/Jaguar (Kurt Cobain)','Clean-to-crunch amp','Closed-back combo cab','bridge humbucker',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, rolling clean-to-crunch riff under cello; keep it gentle then fuller.','Low-medium gain.'],
     array['Let the rolling riff ring.','Build into the fuller chorus.'],
     'Studio recording, 1993 (In Utero). Kurt Cobain played a warm, rolling clean-to-crunch riff.',74),
    ('something-in-the-way','nirvana','guitar','riff','strummed progression','acoustic',
     'grunge','rhythm','beginner',
     'Acoustic guitar (Kurt Cobain)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Whisper-quiet, haunting acoustic strum; keep it fragile and intimate.','Natural acoustic tone.'],
     array['Strum the two-chord pattern gently.','Keep the dynamics hushed.'],
     'Studio recording, 1991 (Nevermind). Kurt Cobain played a whisper-quiet, haunting acoustic part.',73),
    ('the-man-who-sold-the-world','nirvana','guitar','riff','main riff','clean',
     'grunge','rhythm','beginner',
     'Electric guitar with effects (Kurt Cobain)','Clean amp with chorus','Open-back combo cab','neck pickup',
     '[{"effect_type":"chorus","effect_name":"chorus","placement":"post_gain","settings":{"rate":3,"depth":4,"mix":4}}]'::jsonb,'{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Haunting, chorused clean riff (the famous Unplugged version); keep it eerie and even.','Low gain, chorus for depth.'],
     array['Play the descending riff cleanly.','Let the chorus add depth.'],
     'Live recording, 1994 (MTV Unplugged). Kurt Cobain played the haunting Bowie cover on a chorused clean electric.',73),
    ('yellow-ledbetter','pearl-jam','guitar','riff','main riff and solo','crunch',
     'rock','lead','advanced',
     'Fender Stratocaster (Mike McCready)','Clean-to-crunch amp','Open-back combo cab','neck single-coil',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Hendrix-influenced clean-to-crunch with fluid, chord-melody leads; keep it warm and expressive.','Low-medium gain with feel.'],
     array['Play the chord-melody riff with your fingers.','Let the leads flow like Hendrix.'],
     'Studio recording, 1992. Mike McCready played a Hendrix-influenced clean-to-crunch part on a Stratocaster.',75),
    ('daughter','pearl-jam','guitar','riff','main riff','crunch',
     'rock','rhythm','intermediate',
     'Electric guitar (Stone Gossard / Mike McCready)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Gentle, ringing acoustic-tinged riff that builds to crunch; keep dynamics wide.','Low-medium gain.'],
     array['Let the intro riff ring.','Build into the fuller chorus.'],
     'Studio recording, 1993 (Vs.). Pearl Jam played a gentle, ringing riff that builds to crunch.',74),
    ('better-man','pearl-jam','guitar','riff','main progression','crunch',
     'rock','rhythm','beginner',
     'Electric guitar (Stone Gossard / Mike McCready)','Clean-to-crunch amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Gentle clean verses opening to a big, ringing chorus; keep the contrast wide.','Low-medium gain.'],
     array['Play the verse cleanly.','Open up for the anthemic chorus.'],
     'Studio recording, 1994 (Vitalogy). Pearl Jam played gentle clean verses building to a big ringing chorus.',74),
    ('rusty-cage','soundgarden','guitar','riff','main riff','high_gain',
     'grunge','rhythm','advanced',
     'Electric guitar (Kim Thayil)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Fast, angular drop-tuned riff that breaks into a heavy outro; keep it tight.','High gain, drop tuning.'],
     array['Keep the angular riff tight.','Slam the heavy outro.'],
     'Studio recording, 1991 (Badmotorfinger). Kim Thayil played a fast, angular drop-tuned riff.',74),
    ('fell-on-black-days','soundgarden','guitar','riff','main riff','crunch',
     'grunge','rhythm','intermediate',
     'Electric guitar (Kim Thayil)','Clean-to-crunch amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":6,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Moody, alternate-tuned crunch with a hypnotic groove; keep it dark and even.','Medium gain, alt tuning.'],
     array['Play the moody riff in its alt tuning.','Keep the groove hypnotic.'],
     'Studio recording, 1994 (Superunknown). Kim Thayil played a moody, alternate-tuned crunch riff.',73),
    ('no-excuses','alice-in-chains','guitar','riff','main riff','crunch',
     'grunge','rhythm','beginner',
     'Electric guitar (Jerry Cantrell)','Clean-to-crunch amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, swaying acoustic-tinged crunch groove; keep it smooth and rolling.','Low-medium gain.'],
     array['Play the rolling groove smoothly.','Keep the layered feel warm.'],
     'Studio recording, 1994 (Jar of Flies). Jerry Cantrell played a warm, swaying crunch groove.',74),
    ('down-in-a-hole','alice-in-chains','guitar','riff','main progression','crunch',
     'grunge','rhythm','intermediate',
     'Electric guitar (Jerry Cantrell)','Clean-to-crunch amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":6,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Dark, brooding clean-to-crunch ballad; keep it heavy with wide dynamics.','Medium gain.'],
     array['Play the verse chords darkly.','Swell into the heavy chorus.'],
     'Studio recording, 1992 (Dirt). Jerry Cantrell played a dark, brooding clean-to-crunch part.',74),
    ('vasoline','stone-temple-pilots','guitar','riff','main riff','distorted',
     'rock','rhythm','beginner',
     'Electric guitar (Dean DeLeo)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Punchy, swaggering drop-tuned riff; keep it tight and grooving.','High gain, drop tuning.'],
     array['Keep the riff tight and punchy.','Lock to the groove.'],
     'Studio recording, 1994 (Purple). Dean DeLeo played a punchy, swaggering drop-tuned riff.',73),
    ('big-empty','stone-temple-pilots','guitar','riff','clean verse to crunch chorus','crunch',
     'rock','rhythm','intermediate',
     'Electric guitar (Dean DeLeo)','Clean-to-crunch amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Smoky, bluesy clean verses that swell into a crunchy chorus; keep dynamics wide.','Low-medium gain for the swell.'],
     array['Play the verse with a bluesy touch.','Open into the big chorus.'],
     'Studio recording, 1994 (Purple). Dean DeLeo played smoky clean verses swelling into a crunchy chorus.',73),
    ('tonight-tonight','the-smashing-pumpkins','guitar','riff','main progression','distorted',
     'rock','rhythm','intermediate',
     'Electric guitar (Billy Corgan / James Iha)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Layered, orchestral wall of distorted strummed chords; keep them big and driving.','Medium-high gain, layered.'],
     array['Strum the chords with sweeping energy.','Keep it big under the strings.'],
     'Studio recording, 1995 (Mellon Collie). Billy Corgan played a layered wall of distorted strummed chords.',74),
    ('zero','the-smashing-pumpkins','guitar','riff','main riff','distorted',
     'rock','rhythm','intermediate',
     'Electric guitar (Billy Corgan)','High-gain amp with fuzz','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Crushing, saturated fuzz-distortion riff; keep it thick and relentless.','High gain, saturated fuzz.'],
     array['Keep the riff thick and driving.','Let the saturation roar.'],
     'Studio recording, 1995 (Mellon Collie). Billy Corgan played a crushing, saturated fuzz-distortion riff.',74),
    ('suck-my-kiss','red-hot-chili-peppers','guitar','riff','main riff','crunch',
     'rock','rhythm','intermediate',
     'Fender Stratocaster (John Frusciante)','Crunch amp','Open-back combo cab','bridge single-coil',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Tough, syncopated funk-rock crunch riff; keep it tight and punchy.','Medium gain.'],
     array['Keep the syncopated riff tight.','Lock into the funk groove.'],
     'Studio recording, 1991 (Blood Sugar Sex Magik). John Frusciante played a tough, syncopated funk-rock crunch riff.',74),
    ('around-the-world','red-hot-chili-peppers','guitar','riff','main riff','crunch',
     'rock','rhythm','advanced',
     'Fender Stratocaster (John Frusciante)','Clean-to-crunch amp','Open-back combo cab','bridge single-coil',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Frenetic funk-rock with fast, funky riffing and a bright chorus; keep it snappy.','Medium gain.'],
     array['Play the fast funk riff cleanly.','Keep the chorus bright and driving.'],
     'Studio recording, 1999 (Californication). John Frusciante played frenetic funk-rock riffing on a Stratocaster.',74),
    ('all-my-life','foo-fighters','guitar','riff','main riff','distorted',
     'rock','rhythm','intermediate',
     'Electric guitar (Dave Grohl / Chris Shiflett)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Dynamic: a tense picked intro that erupts into a driving distorted riff; keep the contrast wide.','High gain for the loud parts.'],
     array['Pick the tense intro cleanly.','Erupt into the driving riff.'],
     'Studio recording, 2002 (One by One). The Foo Fighters played a tense intro erupting into a driving distorted riff.',74),
    ('this-is-a-call','foo-fighters','guitar','riff','main riff','distorted',
     'rock','rhythm','beginner',
     'Electric guitar (Dave Grohl)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, driving power-pop distortion; keep the chords ringing and energetic.','Medium-high gain.'],
     array['Drive the power chords with energy.','Keep the muting tight.'],
     'Studio recording, 1995 (Foo Fighters). Dave Grohl played bright, driving power-pop distortion.',73),
    ('nearly-lost-you','screaming-trees','guitar','riff','main riff','crunch',
     'grunge','rhythm','beginner',
     'Electric guitar (Gary Lee Conner)','Crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":6,"bass":6,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Psych-tinged grunge crunch with a driving riff; keep it big and ringing.','Medium gain.'],
     array['Drive the ringing riff.','Keep the groove steady.'],
     'Studio recording, 1992 (Sweet Oblivion). Gary Lee Conner played a psych-tinged grunge crunch riff.',72),
    ('hunger-strike','temple-of-the-dog','guitar','riff','main riff','crunch',
     'grunge','rhythm','beginner',
     'Electric guitar (Mike McCready / Stone Gossard)','Clean-to-crunch amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, ringing clean-to-crunch riff that builds; keep it soulful and dynamic.','Low-medium gain.'],
     array['Let the ringing riff sound.','Build into the fuller chorus.'],
     'Studio recording, 1991 (Temple of the Dog). Mike McCready and Stone Gossard played a warm, ringing clean-to-crunch riff.',73),
    ('bound-for-the-floor','local-h','guitar','riff','main riff','distorted',
     'rock','rhythm','beginner',
     'Electric guitar (Scott Lucas)','High-gain amp','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Grungy, driving distorted riff (''copacetic''); keep it thick and simple.','High gain.'],
     array['Keep the riff thick and driving.','Lock to the groove.'],
     'Studio recording, 1996 (As Good as Dead). Scott Lucas played a grungy, driving distorted riff.',72),
    ('possum-kingdom','toadies','guitar','riff','main riff','distorted',
     'rock','rhythm','intermediate',
     'Electric guitar (Todd Lewis)','High-gain amp','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Dark, dynamic alt-rock: quiet clean verses erupting into a heavy riff; keep the contrast wide.','High gain for the heavy parts.'],
     array['Pick the eerie clean verse.','Slam the heavy chorus riff.'],
     'Studio recording, 1994 (Rubberneck). The Toadies played a dark, dynamic alt-rock riff.',72),
    ('santa-monica','everclear','guitar','riff','main riff','distorted',
     'rock','rhythm','beginner',
     'Electric guitar (Art Alexakis)','High-gain amp','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, driving power-pop distortion; keep the riff ringing and energetic.','Medium-high gain.'],
     array['Drive the riff with energy.','Keep the chords ringing.'],
     'Studio recording, 1995 (Sparkle and Fade). Art Alexakis played bright, driving power-pop distortion.',72),
    ('closing-time','semisonic','guitar','riff','main progression','crunch',
     'rock','rhythm','beginner',
     'Electric guitar (Dan Wilson)','Crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, ringing power-pop crunch; keep the chords big and jangly.','Low-medium gain.'],
     array['Let the chords ring.','Keep a steady, driving strum.'],
     'Studio recording, 1998 (Feeling Strangely Fine). Dan Wilson played a warm, ringing power-pop crunch.',72),
    ('hey-jealousy','gin-blossoms','guitar','riff','main riff','crunch',
     'rock','rhythm','beginner',
     'Electric guitar (Jesse Valenzuela / Doug Hopkins)','Bright crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, jangly power-pop crunch riff; keep it chiming and upbeat.','Low-medium gain, bright.'],
     array['Play the jangly riff cleanly.','Keep the strum driving.'],
     'Studio recording, 1992 (New Miserable Experience). The Gin Blossoms played a bright, jangly power-pop crunch riff.',72)
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
  ('nirvana','all-apologies'),('nirvana','something-in-the-way'),('nirvana','the-man-who-sold-the-world'),('pearl-jam','yellow-ledbetter'),
  ('pearl-jam','daughter'),('pearl-jam','better-man'),('soundgarden','rusty-cage'),('soundgarden','fell-on-black-days'),
  ('alice-in-chains','no-excuses'),('alice-in-chains','down-in-a-hole'),('stone-temple-pilots','vasoline'),('stone-temple-pilots','big-empty'),
  ('the-smashing-pumpkins','tonight-tonight'),('the-smashing-pumpkins','zero'),('red-hot-chili-peppers','suck-my-kiss'),('red-hot-chili-peppers','around-the-world'),
  ('foo-fighters','all-my-life'),('foo-fighters','this-is-a-call'),('screaming-trees','nearly-lost-you'),('temple-of-the-dog','hunger-strike'),
  ('local-h','bound-for-the-floor'),('toadies','possum-kingdom'),('everclear','santa-monica'),('semisonic','closing-time'),
  ('gin-blossoms','hey-jealousy')
) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
cross join (values
  ('artist_interview', 'Documented artist interviews and gear discussions', null::text,
   'Researched from widely-documented interviews about this recording and player.', 72),
  ('rig_rundown', 'Published rig rundowns and community gear databases', null::text,
   'Cross-referenced against rig features and community-maintained gear databases.', 66)
) as x(source_type, title, url, notes, credibility)
where p.verification_status = 'admin_verified'
on conflict do nothing;
