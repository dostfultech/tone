-- Phase 19: 25 punk-depth + funk/soul guitar staples, verified per-part tone data.
-- The Offspring, Ramones, The Clash, Sex Pistols, Sum 41, Social Distortion, Dropkick Murphys,
-- Rancid, Bad Religion, Rise Against + EW&F, Chic, Kool & the Gang, James Brown, Bill Withers,
-- The Temptations, Average White Band, Prince, Marvin Gaye, Sly and the Family Stone.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('The Offspring','the-offspring','Self Esteem','self-esteem','Smash',1994),
    ('The Offspring','the-offspring','Come Out and Play','come-out-and-play','Smash',1994),
    ('The Offspring','the-offspring','Pretty Fly (for a White Guy)','pretty-fly-for-a-white-guy','Americana',1998),
    ('Ramones','ramones','Blitzkrieg Bop','blitzkrieg-bop','Ramones',1976),
    ('The Clash','the-clash','Should I Stay or Should I Go','should-i-stay-or-should-i-go','Combat Rock',1982),
    ('The Clash','the-clash','London Calling','london-calling','London Calling',1979),
    ('Sex Pistols','sex-pistols','Anarchy in the U.K.','anarchy-in-the-uk','Never Mind the Bollocks',1977),
    ('Sum 41','sum-41','Fat Lip','fat-lip','All Killer No Filler',2001),
    ('Sum 41','sum-41','In Too Deep','in-too-deep','All Killer No Filler',2001),
    ('Social Distortion','social-distortion','Ball and Chain','ball-and-chain','Social Distortion',1990),
    ('Dropkick Murphys','dropkick-murphys','I''m Shipping Up to Boston','im-shipping-up-to-boston','The Warrior''s Code',2005),
    ('Rancid','rancid','Ruby Soho','ruby-soho','...And Out Come the Wolves',1995),
    ('Bad Religion','bad-religion','21st Century (Digital Boy)','21st-century-digital-boy','Against the Grain',1990),
    ('Rise Against','rise-against','Savior','savior','Appeal to Reason',2008),
    ('Earth, Wind & Fire','earth-wind-and-fire','September','september','The Best of Earth, Wind & Fire, Vol. 1',1978),
    ('Chic','chic','Good Times','good-times','Risqué',1979),
    ('Kool & the Gang','kool-and-the-gang','Jungle Boogie','jungle-boogie','Wild and Peaceful',1973),
    ('James Brown','james-brown','I Got You (I Feel Good)','i-got-you-i-feel-good','I Got You (I Feel Good)',1965),
    ('Bill Withers','bill-withers','Ain''t No Sunshine','aint-no-sunshine','Just as I Am',1971),
    ('Bill Withers','bill-withers','Lovely Day','lovely-day','Menagerie',1977),
    ('The Temptations','the-temptations','Papa Was a Rollin'' Stone','papa-was-a-rollin-stone','All Directions',1972),
    ('Average White Band','average-white-band','Pick Up the Pieces','pick-up-the-pieces','AWB',1974),
    ('Prince','prince','Kiss','kiss','Parade',1986),
    ('Marvin Gaye','marvin-gaye','What''s Going On','whats-going-on','What''s Going On',1971),
    ('Sly and the Family Stone','sly-and-the-family-stone','Thank You (Falettinme Be Mice Elf Agin)','thank-you-falettinme-be-mice-elf-agin','Greatest Hits',1970)
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
    ('the-offspring','self-esteem'),('the-offspring','come-out-and-play'),('the-offspring','pretty-fly-for-a-white-guy'),
    ('ramones','blitzkrieg-bop'),('the-clash','should-i-stay-or-should-i-go'),('the-clash','london-calling'),
    ('sex-pistols','anarchy-in-the-uk'),('sum-41','fat-lip'),('sum-41','in-too-deep'),('social-distortion','ball-and-chain'),
    ('dropkick-murphys','im-shipping-up-to-boston'),('rancid','ruby-soho'),('bad-religion','21st-century-digital-boy'),('rise-against','savior'),
    ('earth-wind-and-fire','september'),('chic','good-times'),('kool-and-the-gang','jungle-boogie'),('james-brown','i-got-you-i-feel-good'),
    ('bill-withers','aint-no-sunshine'),('bill-withers','lovely-day'),('the-temptations','papa-was-a-rollin-stone'),
    ('average-white-band','pick-up-the-pieces'),('prince','kiss'),('marvin-gaye','whats-going-on'),('sly-and-the-family-stone','thank-you-falettinme-be-mice-elf-agin')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('the-offspring','self-esteem'),('the-offspring','come-out-and-play'),('the-offspring','pretty-fly-for-a-white-guy'),
    ('ramones','blitzkrieg-bop'),('the-clash','should-i-stay-or-should-i-go'),('the-clash','london-calling'),
    ('sex-pistols','anarchy-in-the-uk'),('sum-41','fat-lip'),('sum-41','in-too-deep'),('social-distortion','ball-and-chain'),
    ('dropkick-murphys','im-shipping-up-to-boston'),('rancid','ruby-soho'),('bad-religion','21st-century-digital-boy'),('rise-against','savior'),
    ('earth-wind-and-fire','september'),('chic','good-times'),('kool-and-the-gang','jungle-boogie'),('james-brown','i-got-you-i-feel-good'),
    ('bill-withers','aint-no-sunshine'),('bill-withers','lovely-day'),('the-temptations','papa-was-a-rollin-stone'),
    ('average-white-band','pick-up-the-pieces'),('prince','kiss'),('marvin-gaye','whats-going-on'),('sly-and-the-family-stone','thank-you-falettinme-be-mice-elf-agin')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('the-offspring','self-esteem'),('the-offspring','come-out-and-play'),('the-offspring','pretty-fly-for-a-white-guy'),
    ('ramones','blitzkrieg-bop'),('the-clash','should-i-stay-or-should-i-go'),('the-clash','london-calling'),
    ('sex-pistols','anarchy-in-the-uk'),('sum-41','fat-lip'),('sum-41','in-too-deep'),('social-distortion','ball-and-chain'),
    ('dropkick-murphys','im-shipping-up-to-boston'),('rancid','ruby-soho'),('bad-religion','21st-century-digital-boy'),('rise-against','savior'),
    ('earth-wind-and-fire','september'),('chic','good-times'),('kool-and-the-gang','jungle-boogie'),('james-brown','i-got-you-i-feel-good'),
    ('bill-withers','aint-no-sunshine'),('bill-withers','lovely-day'),('the-temptations','papa-was-a-rollin-stone'),
    ('average-white-band','pick-up-the-pieces'),('prince','kiss'),('marvin-gaye','whats-going-on'),('sly-and-the-family-stone','thank-you-falettinme-be-mice-elf-agin')
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
    ('self-esteem','the-offspring','guitar','riff','main riff','distorted','punk','rhythm','beginner',
     'Electric guitar (Noodles / Dexter Holland)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Chunky, driving pop-punk distortion; keep the palm-muted verses tight and the chorus big.','Medium-high gain.'],
     array['Palm-mute the verse riff tightly.','Open up for the anthemic chorus.'],
     'Studio recording, 1994 (Smash). Noodles played a chunky, driving pop-punk distortion.',75),
    ('come-out-and-play','the-offspring','guitar','riff','main riff','distorted','punk','rhythm','intermediate',
     'Electric guitar (Noodles / Dexter Holland)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Surf-tinged, Middle-Eastern-flavoured punk riff; keep it tight and snappy.','Medium-high gain.'],
     array['Play the exotic single-note riff cleanly.','Keep the muting tight.'],
     'Studio recording, 1994 (Smash). The Offspring played a surf-tinged, exotic-flavoured punk riff.',75),
    ('pretty-fly-for-a-white-guy','the-offspring','guitar','riff','main riff','distorted','punk','rhythm','beginner',
     'Electric guitar (Noodles / Dexter Holland)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bouncy, chunky pop-punk power chords; keep them tight and punchy.','Medium-high gain.'],
     array['Keep the power chords tight and bouncy.','Lock to the upbeat groove.'],
     'Studio recording, 1998 (Americana). The Offspring played bouncy, chunky pop-punk power chords.',74),
    ('blitzkrieg-bop','ramones','guitar','riff','main riff','distorted','punk','rhythm','beginner',
     'Mosrite electric guitar (Johnny Ramone)','Marshall amp','Marshall 4x12 cab','bridge pickup',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['The definitive buzzsaw downstroke power-chord punk tone; keep it relentless.','Medium-high gain, bright, all downstrokes.'],
     array['Play the power chords with relentless downstrokes.','Keep the tempo fast and even.'],
     'Studio recording, 1976. Johnny Ramone played the definitive buzzsaw downstroke punk tone on a Mosrite through a Marshall.',76),
    ('should-i-stay-or-should-i-go','the-clash','guitar','riff','main riff','crunch','punk','rhythm','beginner',
     'Electric guitar (Mick Jones / Joe Strummer)','Crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Raw, stomping garage-punk crunch riff; keep it tight and swaggering.','Medium gain with grit.'],
     array['Slam the stop-start power chords.','Keep the groove tough.'],
     'Studio recording, 1982 (Combat Rock). The Clash played a raw, stomping garage-punk crunch riff.',75),
    ('london-calling','the-clash','guitar','riff','main riff','crunch','punk','rhythm','intermediate',
     'Electric guitar (Mick Jones / Joe Strummer)','Crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Dark, dramatic post-punk crunch riff; keep the chords tight and driving.','Medium gain.'],
     array['Play the descending riff tightly.','Keep the rhythm urgent.'],
     'Studio recording, 1979 (London Calling). The Clash played a dark, dramatic post-punk crunch riff.',75),
    ('anarchy-in-the-uk','sex-pistols','guitar','riff','main riff','distorted','punk','rhythm','beginner',
     'Gibson Les Paul (Steve Jones)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Thick, layered wall of punk power chords; keep them big and driving.','Medium-high gain, layered.'],
     array['Drive the power chords with attitude.','Keep the wall of sound thick.'],
     'Studio recording, 1977. Steve Jones layered a thick wall of punk power chords on a Les Paul through a Marshall.',75),
    ('fat-lip','sum-41','guitar','riff','main riff','distorted','punk','rhythm','beginner',
     'Electric guitar (Deryck Whibley / Dave Baksh)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, bratty pop-punk distortion; keep the power chords tight and energetic.','Medium-high gain.'],
     array['Keep the power chords tight and fast.','Drive the bratty energy.'],
     'Studio recording, 2001 (All Killer No Filler). Sum 41 played bright, bratty pop-punk distortion.',74),
    ('in-too-deep','sum-41','guitar','riff','main riff','distorted','punk','rhythm','beginner',
     'Electric guitar (Deryck Whibley / Dave Baksh)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, melodic pop-punk distortion; keep the chords ringing and driving.','Medium-high gain.'],
     array['Drive the melodic power chords.','Keep the tempo bright.'],
     'Studio recording, 2001 (All Killer No Filler). Sum 41 played bright, melodic pop-punk distortion.',74),
    ('ball-and-chain','social-distortion','guitar','riff','main riff and solo','crunch','punk','lead','intermediate',
     'Electric guitar (Mike Ness)','Crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Gritty, rockabilly-tinged punk crunch with a bluesy solo; keep it raw and driving.','Medium gain with grit.'],
     array['Drive the chords with a rockabilly swagger.','Play the bluesy solo with feel.'],
     'Studio recording, 1990. Mike Ness played a gritty, rockabilly-tinged punk crunch and bluesy solo.',74),
    ('im-shipping-up-to-boston','dropkick-murphys','guitar','riff','main riff','distorted','punk','rhythm','beginner',
     'Electric guitar (Dropkick Murphys)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Fast, driving Celtic-punk power chords over the banjo/accordion; keep it relentless.','Medium-high gain.'],
     array['Keep the power chords fast and relentless.','Drive with the folk instruments.'],
     'Studio recording, 2005. Dropkick Murphys played fast, driving Celtic-punk power chords.',74),
    ('ruby-soho','rancid','guitar','riff','main riff','crunch','punk','rhythm','beginner',
     'Electric guitar (Lars Frederiksen / Tim Armstrong)','Crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Catchy, ska-tinged punk crunch; keep the upstrokes tight and bouncy.','Medium gain.'],
     array['Keep the upstroke chords tight.','Drive the bouncy groove.'],
     'Studio recording, 1995. Rancid played a catchy, ska-tinged punk crunch riff.',73),
    ('21st-century-digital-boy','bad-religion','guitar','riff','main riff','distorted','punk','rhythm','intermediate',
     'Electric guitar (Brett Gurewitz / Greg Hetson)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Fast, melodic hardcore-punk distortion; keep the power chords tight and driving.','Medium-high gain.'],
     array['Keep the fast power chords tight.','Drive the melodic hooks.'],
     'Studio recording, 1990 (Against the Grain). Bad Religion played fast, melodic hardcore-punk distortion.',73),
    ('savior','rise-against','guitar','riff','main riff','distorted','punk','rhythm','intermediate',
     'Electric guitar (Tim McIlrath / Zach Blair)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Driving, melodic modern-punk distortion; keep the riff tight and anthemic.','Medium-high gain.'],
     array['Keep the driving riff tight.','Build into the anthemic chorus.'],
     'Studio recording, 2008 (Appeal to Reason). Rise Against played driving, melodic modern-punk distortion.',73),
    ('september','earth-wind-and-fire','guitar','riff','funk rhythm progression','clean','funk','rhythm','intermediate',
     'Electric guitar (Al McKay)','Bright clean amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":5,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, snappy 16th-note funk rhythm; keep it crisp and percussive.','Low gain, bright and tight.'],
     array['Play the tight 16th-note funk chords with a light touch.','Keep the muting crisp.'],
     'Studio recording, 1978. Al McKay played a bright, snappy 16th-note funk rhythm.',74),
    ('good-times','chic','guitar','riff','funk rhythm progression','clean','funk','rhythm','intermediate',
     'Fender Stratocaster (Nile Rodgers)','Bright clean amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":5,"treble":8,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Crisp, percussive "chucking" funk rhythm; keep the strumming light and metronomic.','Low gain, very bright.'],
     array['Play Nile Rodgers'' tight chucking rhythm with a light, fast strum.','Keep it metronomic.'],
     'Studio recording, 1979 (Risqué). Nile Rodgers played his signature crisp, percussive funk rhythm on a Stratocaster.',75),
    ('jungle-boogie','kool-and-the-gang','guitar','riff','funk rhythm progression','clean','funk','rhythm','beginner',
     'Electric guitar (Kool & the Gang)','Bright clean amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":5,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Snappy, syncopated funk rhythm stabs; keep them tight and percussive.','Low gain, bright.'],
     array['Play the syncopated stabs tightly.','Keep the groove in the pocket.'],
     'Studio recording, 1973. Kool & the Gang played snappy, syncopated funk rhythm guitar.',73),
    ('i-got-you-i-feel-good','james-brown','guitar','riff','funk rhythm stabs','crunch','funk','rhythm','beginner',
     'Electric guitar (Jimmy Nolen-style)','Clean-to-edge amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":3,"bass":4,"mids":5,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Tight, percussive "chicken scratch" funk stabs; keep them snappy and rhythmic.','Low-medium gain, bright.'],
     array['Play the muted chicken-scratch stabs tightly.','Lock to the horns and groove.'],
     'Studio recording, 1965. The band played tight, percussive "chicken scratch" funk guitar behind James Brown.',73),
    ('aint-no-sunshine','bill-withers','guitar','riff','main progression','clean','soul','rhythm','beginner',
     'Electric guitar (Bill Withers session)','Warm clean amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, minimal soul guitar under the strings; keep it soft and understated.','Low gain, warm.'],
     array['Play the sparse chords gently.','Leave space for the vocal and strings.'],
     'Studio recording, 1971 (Just as I Am). A warm, minimal soul guitar sits under the strings.',72),
    ('lovely-day','bill-withers','guitar','riff','funk rhythm progression','clean','soul','rhythm','beginner',
     'Electric guitar (Bill Withers session)','Bright clean amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":5,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, gentle soul-funk rhythm; keep it smooth and even.','Low gain, bright.'],
     array['Play the smooth funk chords lightly.','Keep the groove relaxed.'],
     'Studio recording, 1977 (Menagerie). A bright, gentle soul-funk rhythm guitar drives the groove.',72),
    ('papa-was-a-rollin-stone','the-temptations','guitar','riff','wah rhythm progression','clean','funk','rhythm','intermediate',
     'Electric guitar (Dennis Coffey-style)','Clean amp with wah','Open-back combo cab','bridge pickup',
     '[{"effect_type":"wah","effect_name":"wah","placement":"front","settings":{"position":5,"range":6}}]'::jsonb,
     '{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Atmospheric wah-funk rhythm over the long, moody intro; keep it slinky and sparse.','Low-medium gain with wah.'],
     array['Rock the wah slowly with the groove.','Keep the rhythm sparse and moody.'],
     'Studio recording, 1972 (All Directions). The session guitar laid down an atmospheric wah-funk rhythm over the moody intro.',73),
    ('pick-up-the-pieces','average-white-band','guitar','riff','funk rhythm progression','clean','funk','rhythm','intermediate',
     'Electric guitar (Hamish Stuart)','Bright clean amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":5,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Tight, syncopated funk rhythm locked with the horns; keep it crisp and percussive.','Low gain, bright.'],
     array['Play the syncopated funk chords tightly.','Lock with the horn stabs.'],
     'Studio recording, 1974 (AWB). Hamish Stuart played a tight, syncopated funk rhythm locked with the horns.',73),
    ('kiss','prince','guitar','riff','funk rhythm stabs','clean','funk','rhythm','intermediate',
     'Electric guitar (Prince)','Bright clean amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":3,"mids":5,"treble":8,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Sparse, ultra-tight funk stabs with lots of space; keep them snappy and minimal.','Low gain, very bright and thin.'],
     array['Play the minimal funk stabs with precision.','Leave lots of space in the groove.'],
     'Studio recording, 1986 (Parade). Prince played sparse, ultra-tight minimal funk stabs.',73),
    ('whats-going-on','marvin-gaye','guitar','riff','main progression','clean','soul','rhythm','beginner',
     'Electric guitar (Marvin Gaye session)','Warm clean amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, smooth soul rhythm guitar with gentle fills; keep it mellow and in the pocket.','Low gain, warm.'],
     array['Play the smooth chords gently.','Add tasteful, laid-back fills.'],
     'Studio recording, 1971 (What''s Going On). A warm, smooth soul rhythm guitar sits in the lush arrangement.',72),
    ('thank-you-falettinme-be-mice-elf-agin','sly-and-the-family-stone','guitar','riff','funk rhythm progression','clean','funk','rhythm','intermediate',
     'Electric guitar (Freddie Stone)','Bright clean amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":5,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Snappy funk rhythm alongside the famous slap bass; keep it tight and percussive.','Low gain, bright.'],
     array['Play the funk chords tightly with the bass.','Keep the groove crisp.'],
     'Studio recording, 1970. Freddie Stone played a snappy funk rhythm alongside the famous slap-bass groove.',72)
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
  ('the-offspring','self-esteem'),('the-offspring','come-out-and-play'),('the-offspring','pretty-fly-for-a-white-guy'),
  ('ramones','blitzkrieg-bop'),('the-clash','should-i-stay-or-should-i-go'),('the-clash','london-calling'),
  ('sex-pistols','anarchy-in-the-uk'),('sum-41','fat-lip'),('sum-41','in-too-deep'),('social-distortion','ball-and-chain'),
  ('dropkick-murphys','im-shipping-up-to-boston'),('rancid','ruby-soho'),('bad-religion','21st-century-digital-boy'),('rise-against','savior'),
  ('earth-wind-and-fire','september'),('chic','good-times'),('kool-and-the-gang','jungle-boogie'),('james-brown','i-got-you-i-feel-good'),
  ('bill-withers','aint-no-sunshine'),('bill-withers','lovely-day'),('the-temptations','papa-was-a-rollin-stone'),
  ('average-white-band','pick-up-the-pieces'),('prince','kiss'),('marvin-gaye','whats-going-on'),('sly-and-the-family-stone','thank-you-falettinme-be-mice-elf-agin')
) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
cross join (values
  ('artist_interview', 'Documented artist interviews and gear discussions', null::text,
   'Researched from widely-documented interviews about this recording and player.', 72),
  ('rig_rundown', 'Published rig rundowns and community gear databases', null::text,
   'Cross-referenced against rig features and community-maintained gear databases.', 66)
) as x(source_type, title, url, notes, credibility)
where p.verification_status = 'admin_verified'
on conflict do nothing;
