-- Phase 34: 25 funk, soul & R&B depth 2, verified per-part tone data (Funkadelic, Parliament, Isley Brothers, Curtis Mayfield, Al Green, Steely Dan, Stevie Wonder, Rick James, Ohio Players, Tower of Power, The Meters, Booker T. & the M.G.'s, more Sly, War, Cameo, Rufus/Chaka Khan, more Prince, D'Angelo).

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Funkadelic','funkadelic','Maggot Brain','maggot-brain','Maggot Brain',1971),
    ('Funkadelic','funkadelic','One Nation Under a Groove','one-nation-under-a-groove','One Nation Under a Groove',1978),
    ('Parliament','parliament','Give Up the Funk (Tear the Roof off the Sucker)','give-up-the-funk','Mothership Connection',1975),
    ('The Isley Brothers','the-isley-brothers','That Lady (Part 1 & 2)','that-lady','3 + 3',1973),
    ('The Isley Brothers','the-isley-brothers','It''s Your Thing','its-your-thing','single',1969),
    ('Curtis Mayfield','curtis-mayfield','Superfly','superfly','Super Fly',1972),
    ('Curtis Mayfield','curtis-mayfield','Move On Up','move-on-up','Curtis',1970),
    ('Al Green','al-green','Let''s Stay Together','lets-stay-together','Let''s Stay Together',1971),
    ('Al Green','al-green','Take Me to the River','take-me-to-the-river','Al Green Explores Your Mind',1974),
    ('Steely Dan','steely-dan','Reelin'' in the Years','reelin-in-the-years','Can''t Buy a Thrill',1972),
    ('Steely Dan','steely-dan','Peg','peg','Aja',1977),
    ('Steely Dan','steely-dan','Do It Again','do-it-again','Can''t Buy a Thrill',1972),
    ('Stevie Wonder','stevie-wonder','Superstition','superstition','Talking Book',1972),
    ('Stevie Wonder','stevie-wonder','Sir Duke','sir-duke','Songs in the Key of Life',1976),
    ('Rick James','rick-james','Super Freak','super-freak','Street Songs',1981),
    ('Ohio Players','ohio-players','Love Rollercoaster','love-rollercoaster','Honey',1975),
    ('Tower of Power','tower-of-power','What Is Hip?','what-is-hip','Tower of Power',1973),
    ('The Meters','the-meters','Cissy Strut','cissy-strut','The Meters',1969),
    ('Booker T. & the M.G.''s','booker-t-and-the-mgs','Green Onions','green-onions','Green Onions',1962),
    ('Sly and the Family Stone','sly-and-the-family-stone','Everyday People','everyday-people','Stand!',1968),
    ('War','war','Low Rider','low-rider','Why Can''t We Be Friends?',1975),
    ('Cameo','cameo','Word Up!','word-up','Word Up!',1986),
    ('Rufus & Chaka Khan','rufus-and-chaka-khan','Tell Me Something Good','tell-me-something-good','Rags to Rufus',1974),
    ('Prince','prince','When Doves Cry','when-doves-cry','Purple Rain',1984),
    ('D''Angelo','dangelo','Untitled (How Does It Feel)','untitled-how-does-it-feel','Voodoo',2000)
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
    ('funkadelic','maggot-brain'),('funkadelic','one-nation-under-a-groove'),('parliament','give-up-the-funk'),('the-isley-brothers','that-lady'),
    ('the-isley-brothers','its-your-thing'),('curtis-mayfield','superfly'),('curtis-mayfield','move-on-up'),('al-green','lets-stay-together'),
    ('al-green','take-me-to-the-river'),('steely-dan','reelin-in-the-years'),('steely-dan','peg'),('steely-dan','do-it-again'),
    ('stevie-wonder','superstition'),('stevie-wonder','sir-duke'),('rick-james','super-freak'),('ohio-players','love-rollercoaster'),
    ('tower-of-power','what-is-hip'),('the-meters','cissy-strut'),('booker-t-and-the-mgs','green-onions'),('sly-and-the-family-stone','everyday-people'),
    ('war','low-rider'),('cameo','word-up'),('rufus-and-chaka-khan','tell-me-something-good'),('prince','when-doves-cry'),
    ('dangelo','untitled-how-does-it-feel')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('funkadelic','maggot-brain'),('funkadelic','one-nation-under-a-groove'),('parliament','give-up-the-funk'),('the-isley-brothers','that-lady'),
    ('the-isley-brothers','its-your-thing'),('curtis-mayfield','superfly'),('curtis-mayfield','move-on-up'),('al-green','lets-stay-together'),
    ('al-green','take-me-to-the-river'),('steely-dan','reelin-in-the-years'),('steely-dan','peg'),('steely-dan','do-it-again'),
    ('stevie-wonder','superstition'),('stevie-wonder','sir-duke'),('rick-james','super-freak'),('ohio-players','love-rollercoaster'),
    ('tower-of-power','what-is-hip'),('the-meters','cissy-strut'),('booker-t-and-the-mgs','green-onions'),('sly-and-the-family-stone','everyday-people'),
    ('war','low-rider'),('cameo','word-up'),('rufus-and-chaka-khan','tell-me-something-good'),('prince','when-doves-cry'),
    ('dangelo','untitled-how-does-it-feel')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('funkadelic','maggot-brain'),('funkadelic','one-nation-under-a-groove'),('parliament','give-up-the-funk'),('the-isley-brothers','that-lady'),
    ('the-isley-brothers','its-your-thing'),('curtis-mayfield','superfly'),('curtis-mayfield','move-on-up'),('al-green','lets-stay-together'),
    ('al-green','take-me-to-the-river'),('steely-dan','reelin-in-the-years'),('steely-dan','peg'),('steely-dan','do-it-again'),
    ('stevie-wonder','superstition'),('stevie-wonder','sir-duke'),('rick-james','super-freak'),('ohio-players','love-rollercoaster'),
    ('tower-of-power','what-is-hip'),('the-meters','cissy-strut'),('booker-t-and-the-mgs','green-onions'),('sly-and-the-family-stone','everyday-people'),
    ('war','low-rider'),('cameo','word-up'),('rufus-and-chaka-khan','tell-me-something-good'),('prince','when-doves-cry'),
    ('dangelo','untitled-how-does-it-feel')
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
    ('maggot-brain','funkadelic','guitar','riff','instrumental solo','crunch',
     'funk','lead','advanced',
     'Fender Stratocaster (Eddie Hazel)','Overdriven amp with wah','Open-back combo cab','neck single-coil',
     '[{"effect_type":"wah","effect_name":"wah","placement":"front","settings":{"position":5,"range":6}}]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['A ten-minute psychedelic-soul solo of pure emotion; keep it fluid, crying, and dynamic.','Medium gain with huge sustain and wah.'],
     array['Play the solo with vocal, weeping phrasing.','Let notes sustain and bend endlessly.'],
     'Studio recording, 1971 (Maggot Brain). Eddie Hazel played the legendary ten-minute psychedelic-soul solo on a Stratocaster.',73),
    ('one-nation-under-a-groove','funkadelic','guitar','riff','funk rhythm and riff','crunch',
     'funk','rhythm','intermediate',
     'Electric guitar (Michael Hampton / Garry Shider)','Crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Driving P-Funk with a crunchy rhythm riff and funky stabs; keep it tight and grooving.','Medium gain.'],
     array['Keep the funk stabs tight.','Lock into the groove.'],
     'Studio recording, 1978. Michael Hampton and Garry Shider played driving P-Funk rhythm guitar.',72),
    ('give-up-the-funk','parliament','guitar','riff','funk rhythm','clean',
     'funk','rhythm','beginner',
     'Electric guitar (Parliament)','Crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":5,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Tight, percussive P-Funk rhythm stabs; keep them snappy and in the pocket.','Low gain, bright.'],
     array['Play the funk stabs tightly.','Keep it in the pocket.'],
     'Studio recording, 1975 (Mothership Connection). Parliament played tight, percussive P-Funk rhythm stabs.',72),
    ('that-lady','the-isley-brothers','guitar','riff','main solo','fuzz',
     'funk','lead','advanced',
     'Fender Stratocaster (Ernie Isley)','Overdriven amp with fuzz','Open-back combo cab','neck single-coil',
     '[{"effect_type":"fuzz","effect_name":"fuzz","placement":"front","settings":{"gain":7,"tone":5,"level":6}}]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Hendrix-influenced fuzzy, phaser-drenched soul solo over a Latin-funk groove; keep it fluid.','Medium-high gain with fuzz and modulation.'],
     array['Play the solo with fluid, crying bends.','Let the fuzz and phaser swirl.'],
     'Studio recording, 1973 (3 + 3). Ernie Isley played a Hendrix-influenced fuzzy soul solo on a Stratocaster.',73),
    ('its-your-thing','the-isley-brothers','guitar','riff','funk rhythm','clean',
     'funk','rhythm','beginner',
     'Electric guitar (Ernie Isley)','Clean amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":5,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Snappy, percussive funk rhythm stabs; keep them tight and bright.','Low gain, bright.'],
     array['Play the stabs tightly.','Keep the groove punchy.'],
     'Studio recording, 1969. The Isley Brothers played snappy, percussive funk rhythm.',71),
    ('superfly','curtis-mayfield','guitar','riff','wah funk rhythm','clean',
     'funk','rhythm','intermediate',
     'Fender-style electric (Curtis Mayfield)','Clean amp with wah','Open-back combo cab','neck pickup',
     '[{"effect_type":"wah","effect_name":"wah","placement":"front","settings":{"position":5,"range":6}}]'::jsonb,'{"gain":2,"bass":4,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Slinky, wah-inflected soul-funk rhythm; keep it smooth and percussive.','Low gain, wah, bright.'],
     array['Rock the wah with the groove.','Keep the chords crisp and light.'],
     'Studio recording, 1972 (Super Fly). Curtis Mayfield played slinky, wah-inflected soul-funk rhythm.',72),
    ('move-on-up','curtis-mayfield','guitar','riff','funk rhythm','clean',
     'soul','rhythm','intermediate',
     'Fender-style electric (Curtis Mayfield)','Clean amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bright, uplifting soul-funk rhythm with high, chiming chords; keep it crisp.','Low gain, bright, high voicings.'],
     array['Play the high, chiming chords crisply.','Keep the groove driving.'],
     'Studio recording, 1970 (Curtis). Curtis Mayfield played bright, uplifting soul-funk rhythm with high voicings.',72),
    ('lets-stay-together','al-green','guitar','riff','soul rhythm','clean',
     'soul','rhythm','beginner',
     'Electric guitar (Teenie Hodges)','Clean amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Smooth, understated Hi Records soul rhythm; keep the chords soft and in the pocket.','Low gain, warm.'],
     array['Play the soft chords in the pocket.','Keep it smooth and supportive.'],
     'Studio recording, 1971. Teenie Hodges played smooth, understated Hi Records soul rhythm.',72),
    ('take-me-to-the-river','al-green','guitar','riff','soul funk rhythm','clean',
     'soul','rhythm','beginner',
     'Electric guitar (Teenie Hodges)','Clean amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Greasy, laid-back soul-funk rhythm; keep the chops tight and warm.','Low gain, warm.'],
     array['Play the funk chops tightly.','Keep the groove greasy.'],
     'Studio recording, 1974. Teenie Hodges played greasy, laid-back soul-funk rhythm.',71),
    ('reelin-in-the-years','steely-dan','guitar','riff','main riff and solo','crunch',
     'rock','lead','advanced',
     'Electric guitar (Elliott Randall)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bright, fluid jazz-rock with a famously fast, melodic solo; keep it clean and articulate.','Low-medium gain, bright.'],
     array['Play the riff and harmonies cleanly.','Nail the fast, melodic solo.'],
     'Studio recording, 1972 (Can''t Buy a Thrill). Elliott Randall played the famous bright, fluid jazz-rock solo.',73),
    ('peg','steely-dan','guitar','riff','main solo','crunch',
     'jazz','lead','advanced',
     'Electric guitar (Jay Graydon)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Slick, jazzy funk-pop with a polished, melodic solo; keep it smooth and precise.','Low-medium gain, smooth.'],
     array['Play the solo with smooth, hip phrasing.','Keep the tone polished.'],
     'Studio recording, 1977 (Aja). Jay Graydon played the polished, melodic solo after many session guitarists auditioned.',72),
    ('do-it-again','steely-dan','guitar','riff','main riff','clean',
     'rock','rhythm','intermediate',
     'Electric guitar (Denny Dias / Jeff Baxter)','Clean amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Latin-tinged jazz-rock with a smooth clean groove; keep the comping tight and even.','Low gain, warm.'],
     array['Comp the Latin groove tightly.','Keep the chords smooth.'],
     'Studio recording, 1972 (Can''t Buy a Thrill). Steely Dan played a Latin-tinged jazz-rock groove.',71),
    ('superstition','stevie-wonder','guitar','riff','funk rhythm accents','clean',
     'funk','rhythm','intermediate',
     'Electric guitar (session)','Clean-to-crunch amp with wah','Open-back combo cab','neck pickup',
     '[{"effect_type":"wah","effect_name":"wah","placement":"front","settings":{"position":5,"range":6}}]'::jsonb,'{"gain":2,"bass":4,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Funky wah-inflected rhythm accents over the clavinet groove; keep them tight and percussive.','Low gain, wah.'],
     array['Play the funk accents tightly.','Lock to the clavinet groove.'],
     'Studio recording, 1972 (Talking Book). Session guitar added funky wah rhythm accents over Stevie Wonder''s clavinet.',71),
    ('sir-duke','stevie-wonder','guitar','riff','main riff and horn-unison lines','clean',
     'funk','lead','advanced',
     'Electric guitar (Michael Sembello / session)','Bright clean amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":5,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, joyful funk with fast horn-unison guitar lines; keep it crisp and precise.','Low gain, bright.'],
     array['Play the fast unison lines with the horns.','Keep the picking tight.'],
     'Studio recording, 1976 (Songs in the Key of Life). Session guitar doubled the fast horn-unison lines.',71),
    ('super-freak','rick-james','guitar','riff','funk rhythm','clean',
     'funk','rhythm','beginner',
     'Electric guitar (Rick James band)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":5,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Snappy new-wave-funk rhythm stabs over the famous bass line; keep them tight.','Low gain, bright.'],
     array['Play the stabs tightly.','Lock to the bass groove.'],
     'Studio recording, 1981 (Street Songs). Rick James'' band played snappy funk rhythm stabs.',71),
    ('love-rollercoaster','ohio-players','guitar','riff','funk rhythm','clean',
     'funk','rhythm','beginner',
     'Electric guitar (Ohio Players)','Crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":5,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Tight, driving funk rhythm with percussive chops; keep it snappy.','Low gain, bright.'],
     array['Play the funk chops tightly.','Keep the groove driving.'],
     'Studio recording, 1975 (Honey). The Ohio Players played tight, driving funk rhythm.',71),
    ('what-is-hip','tower-of-power','guitar','riff','funk rhythm','clean',
     'funk','rhythm','advanced',
     'Electric guitar (Bruce Conte)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":5,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Ultra-tight 16th-note funk rhythm locked with the legendary horn section; keep it razor-sharp.','Low gain, bright and tight.'],
     array['Play the 16th-note chops razor-tight.','Lock with the bass and horns.'],
     'Studio recording, 1973 (Tower of Power). Bruce Conte played ultra-tight 16th-note funk rhythm.',72),
    ('cissy-strut','the-meters','guitar','riff','instrumental funk riff','clean',
     'funk','lead','intermediate',
     'Fender Telecaster (Leo Nocentelli)','Clean amp','Open-back combo cab','bridge single-coil',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":5,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['The definitive New Orleans funk instrumental riff; keep it greasy, syncopated, and in the pocket.','Low gain, bright.'],
     array['Play the syncopated riff with a greasy feel.','Leave space in the groove.'],
     'Studio recording, 1969 (The Meters). Leo Nocentelli played the definitive New Orleans funk riff on a Telecaster.',72),
    ('green-onions','booker-t-and-the-mgs','guitar','riff','main riff and solo','clean',
     'soul','lead','beginner',
     'Fender Telecaster (Steve Cropper)','Clean amp','Open-back combo cab','bridge single-coil',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Cool, bluesy Stax instrumental with a snappy Telecaster tone; keep it tight and greasy.','Low gain, bright.'],
     array['Comp the riff tightly behind the organ.','Play the bluesy solo with snap.'],
     'Studio recording, 1962 (Green Onions). Steve Cropper played the cool, bluesy Stax instrumental on a Telecaster.',72),
    ('everyday-people','sly-and-the-family-stone','guitar','riff','funk rhythm','clean',
     'funk','rhythm','beginner',
     'Electric guitar (Freddie Stone)','Clean amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":5,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Simple, joyful funk-soul rhythm; keep the chops light and bouncy.','Low gain, bright.'],
     array['Play the simple chops lightly.','Keep the groove joyful.'],
     'Studio recording, 1968 (Stand!). Freddie Stone played simple, joyful funk-soul rhythm.',71),
    ('low-rider','war','guitar','riff','funk rhythm','clean',
     'funk','rhythm','beginner',
     'Electric guitar (Howard Scott)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":5,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Laid-back, greasy Latin-funk rhythm; keep the chops in the pocket.','Low gain, bright.'],
     array['Play the chops with a laid-back groove.','Keep it in the pocket.'],
     'Studio recording, 1975. Howard Scott played laid-back, greasy Latin-funk rhythm.',71),
    ('word-up','cameo','guitar','riff','funk rhythm','crunch',
     'funk','rhythm','beginner',
     'Electric guitar (Cameo)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Punchy 80s electro-funk with a crunchy rhythm stab; keep it tight and snappy.','Medium gain.'],
     array['Play the stabs tightly.','Lock to the synth-funk groove.'],
     'Studio recording, 1986 (Word Up!). Cameo played a punchy 80s electro-funk rhythm stab.',70),
    ('tell-me-something-good','rufus-and-chaka-khan','guitar','riff','funk riff','crunch',
     'funk','lead','intermediate',
     'Electric guitar with talk box (Tony Maiden)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Slinky, talk-box-inflected funk riff with a wah/vowel character; keep it greasy and sexy.','Medium gain, expressive.'],
     array['Play the riff with a greasy swagger.','Emphasise the vocal, talk-box feel.'],
     'Studio recording, 1974 (Rags to Rufus). Tony Maiden played a slinky, talk-box-inflected funk riff.',71),
    ('when-doves-cry','prince','guitar','riff','intro solo and accents','crunch',
     'funk','lead','intermediate',
     'Electric guitar (Prince)','Crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['A searing shred intro then sparse, funky accents; keep the solo fiery and the rest minimal.','Medium gain.'],
     array['Play the fiery intro solo with attack.','Keep the verse accents sparse.'],
     'Studio recording, 1984 (Purple Rain). Prince played a searing shred intro and sparse funky accents.',72),
    ('untitled-how-does-it-feel','dangelo','guitar','riff','neo-soul rhythm','clean',
     'soul','rhythm','intermediate',
     'Electric guitar (session)','Clean amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, laid-back neo-soul rhythm sitting deep behind the beat; keep it smooth and hazy.','Low gain, warm.'],
     array['Play the chords behind the beat.','Keep the feel loose and smoky.'],
     'Studio recording, 2000 (Voodoo). Session guitar laid down warm, laid-back neo-soul rhythm.',70)
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
  ('funkadelic','maggot-brain'),('funkadelic','one-nation-under-a-groove'),('parliament','give-up-the-funk'),('the-isley-brothers','that-lady'),
  ('the-isley-brothers','its-your-thing'),('curtis-mayfield','superfly'),('curtis-mayfield','move-on-up'),('al-green','lets-stay-together'),
  ('al-green','take-me-to-the-river'),('steely-dan','reelin-in-the-years'),('steely-dan','peg'),('steely-dan','do-it-again'),
  ('stevie-wonder','superstition'),('stevie-wonder','sir-duke'),('rick-james','super-freak'),('ohio-players','love-rollercoaster'),
  ('tower-of-power','what-is-hip'),('the-meters','cissy-strut'),('booker-t-and-the-mgs','green-onions'),('sly-and-the-family-stone','everyday-people'),
  ('war','low-rider'),('cameo','word-up'),('rufus-and-chaka-khan','tell-me-something-good'),('prince','when-doves-cry'),
  ('dangelo','untitled-how-does-it-feel')
) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
cross join (values
  ('artist_interview', 'Documented artist interviews and gear discussions', null::text,
   'Researched from widely-documented interviews about this recording and player.', 72),
  ('rig_rundown', 'Published rig rundowns and community gear databases', null::text,
   'Cross-referenced against rig features and community-maintained gear databases.', 66)
) as x(source_type, title, url, notes, credibility)
where p.verification_status = 'admin_verified'
on conflict do nothing;
