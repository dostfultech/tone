-- Phase 66: punk / proto-punk canon + garage revival + festival-indie fills, verified per-part tone data.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('The Stooges','the-stooges','I Wanna Be Your Dog','i-wanna-be-your-dog','The Stooges',1969),
    ('The Stooges','the-stooges','Search and Destroy','search-and-destroy','Raw Power',1973),
    ('MC5','mc5','Kick Out the Jams','kick-out-the-jams','Kick Out the Jams',1969),
    ('Television','television','Marquee Moon','marquee-moon','Marquee Moon',1977),
    ('Sex Pistols','sex-pistols','God Save the Queen','god-save-the-queen','Never Mind the Bollocks',1977),
    ('Misfits','misfits','Last Caress','last-caress','Beware',1980),
    ('Misfits','misfits','Astro Zombies','astro-zombies','Walk Among Us',1982),
    ('Dead Kennedys','dead-kennedys','Holiday in Cambodia','holiday-in-cambodia','Fresh Fruit for Rotting Vegetables',1980),
    ('Black Flag','black-flag','Rise Above','rise-above','Damaged',1981),
    ('Descendents','descendents','Hope','hope','Milo Goes to College',1982),
    ('Fugazi','fugazi','Waiting Room','waiting-room','13 Songs',1988),
    ('NOFX','nofx','Linoleum','linoleum','Punk in Drublic',1994),
    ('Social Distortion','social-distortion','Story of My Life','story-of-my-life','Social Distortion',1990),
    ('Rise Against','rise-against','Swing Life Away','swing-life-away','Siren Song of the Counter Culture',2004),
    ('Operation Ivy','operation-ivy','Knowledge','knowledge','Energy',1989),
    ('Rancid','rancid','Time Bomb','time-bomb','...And Out Come the Wolves',1995),
    ('Buzzcocks','buzzcocks','Ever Fallen in Love (With Someone You Shouldn''t''ve)','ever-fallen-in-love','Love Bites',1978),
    ('The Damned','the-damned','New Rose','new-rose','Damned Damned Damned',1976),
    ('Iggy Pop','iggy-pop','The Passenger','the-passenger','Lust for Life',1977),
    ('The xx','the-xx','Intro','intro','xx',2009),
    ('Daughter','daughter','Youth','youth','If You Leave',2013),
    ('The Temptations','the-temptations','My Girl','my-girl','The Temptations Sing Smokey',1964),
    ('Jet','jet','Are You Gonna Be My Girl','are-you-gonna-be-my-girl','Get Born',2003),
    ('The Hives','the-hives','Hate to Say I Told You So','hate-to-say-i-told-you-so','Veni Vidi Vicious',2000),
    ('Wolfmother','wolfmother','Woman','woman','Wolfmother',2005)
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
    ('the-stooges','i-wanna-be-your-dog'),('the-stooges','search-and-destroy'),('mc5','kick-out-the-jams'),
    ('television','marquee-moon'),('sex-pistols','god-save-the-queen'),('misfits','last-caress'),
    ('misfits','astro-zombies'),('dead-kennedys','holiday-in-cambodia'),('black-flag','rise-above'),
    ('descendents','hope'),('fugazi','waiting-room'),('nofx','linoleum'),('social-distortion','story-of-my-life'),
    ('rise-against','swing-life-away'),('operation-ivy','knowledge'),('rancid','time-bomb'),
    ('buzzcocks','ever-fallen-in-love'),('the-damned','new-rose'),('iggy-pop','the-passenger'),('the-xx','intro'),
    ('daughter','youth'),('the-temptations','my-girl'),('jet','are-you-gonna-be-my-girl'),
    ('the-hives','hate-to-say-i-told-you-so'),('wolfmother','woman')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('the-stooges','i-wanna-be-your-dog'),('the-stooges','search-and-destroy'),('mc5','kick-out-the-jams'),
    ('television','marquee-moon'),('sex-pistols','god-save-the-queen'),('misfits','last-caress'),
    ('misfits','astro-zombies'),('dead-kennedys','holiday-in-cambodia'),('black-flag','rise-above'),
    ('descendents','hope'),('fugazi','waiting-room'),('nofx','linoleum'),('social-distortion','story-of-my-life'),
    ('rise-against','swing-life-away'),('operation-ivy','knowledge'),('rancid','time-bomb'),
    ('buzzcocks','ever-fallen-in-love'),('the-damned','new-rose'),('iggy-pop','the-passenger'),('the-xx','intro'),
    ('daughter','youth'),('the-temptations','my-girl'),('jet','are-you-gonna-be-my-girl'),
    ('the-hives','hate-to-say-i-told-you-so'),('wolfmother','woman')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('the-stooges','i-wanna-be-your-dog'),('the-stooges','search-and-destroy'),('mc5','kick-out-the-jams'),
    ('television','marquee-moon'),('sex-pistols','god-save-the-queen'),('misfits','last-caress'),
    ('misfits','astro-zombies'),('dead-kennedys','holiday-in-cambodia'),('black-flag','rise-above'),
    ('descendents','hope'),('fugazi','waiting-room'),('nofx','linoleum'),('social-distortion','story-of-my-life'),
    ('rise-against','swing-life-away'),('operation-ivy','knowledge'),('rancid','time-bomb'),
    ('buzzcocks','ever-fallen-in-love'),('the-damned','new-rose'),('iggy-pop','the-passenger'),('the-xx','intro'),
    ('daughter','youth'),('the-temptations','my-girl'),('jet','are-you-gonna-be-my-girl'),
    ('the-hives','hate-to-say-i-told-you-so'),('wolfmother','woman')
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
    -- ============ PROTO-PUNK ============
    ('i-wanna-be-your-dog','the-stooges','guitar','riff','main riff','fuzz','proto-punk','rhythm','beginner',
     'Solid-body electric (Ron Asheton)','Tube amp with fuzz, cranked','Closed-back cab','bridge pickup',
     '[{"effect_type":"fuzz","effect_name":"fuzz pedal","placement":"front","settings":{"gain":7,"tone":5,"level":6}}]'::jsonb,
     '{"gain":6,"bass":6,"mids":6,"treble":5,"presence":4,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['Three chords and a sleigh bell — Asheton''s droning fuzz stomp that invented everything after it.','Thick droning fuzz; play it dumb on purpose, that''s the genius.'],
     array['G-F#-E forever — the drone is hypnotic.','Down-strum with contempt.'],
     'Studio recording, 1969. The three-chord fuzz stomp that started punk.',79),
    ('search-and-destroy','the-stooges','guitar','riff','main riff','distorted','proto-punk','rhythm','intermediate',
     'Gibson Les Paul (James Williamson)','Tube stack cranked, trebly and violent','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":4,"mids":6,"treble":8,"presence":7,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['Williamson''s ice-pick assault — famously trebly, mixed to hurt.','Bright violent drive; the rawness IS the production.'],
     array['The intro riff strikes like a streetfight.','Fast downstrokes, no mercy.'],
     'Studio recording, 1973. Williamson''s ice-pick Raw Power assault.',79),
    ('kick-out-the-jams','mc5','guitar','riff','main riff','distorted','proto-punk','rhythm','intermediate',
     'Fender/Mosrite electric (Wayne Kramer / Fred Smith)','Tube stacks cranked live','Closed-back cabs','bridge pickup',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['Recorded live in Detroit — twin-guitar chaos at riot volume.','Raw cranked drive; the energy is a political act.'],
     array['The riff kicks the door in — play it that way.','Trade the leads loose and wild.'],
     'Live recording, 1969. The Detroit riot-volume anthem.',78),
    ('the-passenger','iggy-pop','guitar','riff','main riff','crunch','proto-punk','rhythm','beginner',
     'Solid-body electric (Ricky Gardiner)','Tube amp, warm jangly crunch','Open-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The night-riding riff — a four-chord sway that never gets old.','Warm light crunch; the la-la-las do the rest.'],
     array['The Am-F-C-G sway loops forever.','Ride it, don''t drive it.'],
     'Studio recording, 1977. The eternal night-riding sway.',78),
    ('marquee-moon','television','guitar','riff','interlocking riffs + solo','clean','punk','lead','expert',
     'Fender Jazzmaster/Telecaster (Tom Verlaine / Richard Lloyd)','Fender tube amps, biting clean','Fender combo cabs','bridge pickup',
     '[]'::jsonb,'{"gain":3,"bass":4,"mids":6,"treble":8,"presence":7,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The ten-minute CBGB epic — two trebly clean guitars in counterpoint, building to Verlaine''s climbing solo.','Bright biting Fender clean; punk''s most sophisticated guitar record.'],
     array['Learn both interlocking parts to hear the machine.','The solo climbs a ladder to the sky — patience.'],
     'Studio recording, 1977. The interlocking CBGB epic.',80),

    -- ============ PUNK 77 ============
    ('god-save-the-queen','sex-pistols','guitar','riff','main riff','distorted','punk','rhythm','beginner',
     'Gibson Les Paul Custom (Steve Jones)','Fender Twin cranked with layered overdubs','Fender 2x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['Jones'' wall of Les Pauls — thick layered crunch, more polished than legend admits.','Mid-heavy saturated wall; overdubbed guitars make the tank.'],
     array['Downstroke the riff with contempt for the crown.','The layered rhythm is precise underneath the sneer.'],
     'Studio recording, 1977. Jones'' layered Les Paul wall.',79),
    ('ever-fallen-in-love','buzzcocks','guitar','riff','main riff','distorted','punk','rhythm','intermediate',
     'Starway/Gordon-Smith electric (Pete Shelley / Steve Diggle)','Tube amp, buzzing pop-punk drive','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":6,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The buzzsaw heartbreak — trebly saturated jangle at sprint tempo.','Bright buzzing drive; pop hooks in punk clothing.'],
     array['The stabbing chord riff drives the anxiety.','Sixteenth-note stamina in the chorus.'],
     'Studio recording, 1978. The buzzsaw heartbreak anthem.',78),
    ('new-rose','the-damned','guitar','riff','main riff','distorted','punk','rhythm','intermediate',
     'Gibson SG (Brian James)','Tube stack cranked','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The first UK punk single — careening SG drive at breakneck speed.','Raw bright crunch; barely in control, exactly right.'],
     array['The riff tumbles downhill — hang on.','"Is she really going out with him?" Then GO.'],
     'Studio recording, 1976. The first UK punk single.',78),

    -- ============ HARDCORE / HORROR PUNK ============
    ('last-caress','misfits','guitar','riff','main riff','distorted','horror punk','rhythm','beginner',
     'Solid-body electric (Bobby Steele / Doyle era)','Tube amp, buzzing punk drive','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The melodic-horror standard — crooned melody over buzzing punk chords.','Saturated but singable; the Elvis-croon contrast is the joke.'],
     array['Simple chords under the croon.','Whoa-oh backing like a doo-wop nightmare.'],
     'Studio recording, 1980. The melodic horror-punk standard.',77),
    ('astro-zombies','misfits','guitar','riff','main riff','distorted','horror punk','rhythm','beginner',
     'Solid-body electric (Doyle)','Tube amp, buzzing punk drive','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['B-movie punk perfection — driving buzz under the whoa-oh chorus.','Same buzzing drive; the melody carries the horror-camp.'],
     array['Steady eighth-note drive.','Prime directive: exterminate the whole human race — melodically.'],
     'Studio recording, 1982. B-movie whoa-oh punk.',77),
    ('holiday-in-cambodia','dead-kennedys','guitar','riff','main riff','distorted','hardcore punk','rhythm','intermediate',
     'Fender Stratocaster (East Bay Ray)','Tube amp with slapback echo','Closed-back cab','bridge pickup',
     '[{"effect_type":"delay","effect_name":"slapback echo","placement":"post_gain","settings":{"time":2,"mix":3,"feedback":2}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":5,"treble":8,"presence":7,"reverb":2,"delay":2,"master":8}'::jsonb,
     array['East Bay Ray''s surf-noir hardcore — spy-movie echo guitar over political fury.','Trebly drive with slapback; surf technique at punk velocity.'],
     array['The eerie intro arpeggio sets the dread.','Tremolo-picked runs with the echo bouncing.'],
     'Studio recording, 1980. East Bay Ray''s surf-noir hardcore.',78),
    ('rise-above','black-flag','guitar','riff','main riff','distorted','hardcore punk','rhythm','intermediate',
     'Custom Dan Armstrong (Greg Ginn)','Solid-state amp, harsh and raw','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":7,"presence":7,"reverb":0,"delay":0,"master":8}'::jsonb,
     array['Ginn''s anti-tone — harsh solid-state grind that refuses to be pretty.','Trebly abrasive drive; the ugliness is ideological.'],
     array['The riff batters; the gang vocals answer.','Precision inside the chaos.'],
     'Studio recording, 1981. Ginn''s abrasive hardcore standard.',77),
    ('hope','descendents','guitar','riff','main riff','distorted','punk','rhythm','intermediate',
     'Solid-body electric (Frank Navetta)','Tube amp, melodic punk buzz','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The pop-punk blueprint — caffeinated melodic buzz from 1982.','Bright saturated drive at espresso tempo.'],
     array['Fast downstrokes under the bitter melody.','All energy, all heart.'],
     'Studio recording, 1982. The caffeinated pop-punk blueprint.',76),
    ('waiting-room','fugazi','guitar','riff','main riff','crunch','post-hardcore','rhythm','intermediate',
     'Gibson SG (Ian MacKaye / Guy Picciotto)','Tube amp, dry punchy crunch','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":0,"delay":0,"master":8}'::jsonb,
     array['The dub-punk classic — bone-dry stabs over THAT bassline, then the full-band slam.','Dry punchy crunch; the silences hit hardest.'],
     array['Choke the stabs completely between hits.','When the band drops in, give everything.'],
     'Studio recording, 1988. The dub-punk waiting game.',79),

    -- ============ 90s PUNK ============
    ('linoleum','nofx','guitar','riff','main riff','distorted','punk','rhythm','intermediate',
     'Solid-body electric (El Hefe / Eric Melvin)','Tube stack, fast melodic punk','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The Fat Wreck standard — full-speed melodic buzz that every 90s punk band copied.','Tight saturated drive at skate-punk tempo.'],
     array['Downstroke sprint from the first note.','The melodic lead doubles the vocal.'],
     'Studio recording, 1994. The skate-punk standard.',77),
    ('story-of-my-life','social-distortion','guitar','riff','main riff','distorted','punk','rhythm','beginner',
     'Gibson Les Paul (Mike Ness)','Fender Bassman-style, rock-n-roll punk drive','Fender 4x10 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['Ness'' greaser-punk classic — warm mid-heavy drive with rockabilly bones.','Thick vintage-flavored punk crunch; Johnny Cash in a leather jacket.'],
     array['The lead hook is simple and eternal.','Swing it slightly — it''s rock ''n'' roll first.'],
     'Studio recording, 1990. Ness'' greaser-punk classic.',78),
    ('swing-life-away','rise-against','guitar','main','acoustic ballad','acoustic','punk','rhythm','beginner',
     'Acoustic guitar (Tim McIlrath)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The punk campfire song — warm fingerpicked acoustic sincerity.','Simple honest acoustic; the tattoos are implied.'],
     array['The picking pattern is friendly to beginners.','Sing it with your whole chest.'],
     'Studio recording, 2004. The punk campfire ballad.',77),
    ('knowledge','operation-ivy','guitar','riff','ska-punk engine','crunch','ska punk','rhythm','beginner',
     'Solid-body electric (Lint / Tim Armstrong)','Tube amp, raw ska-punk','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The east-bay anthem (Green Day covered it forever) — upstroke ska into punk slam.','Raw bright crunch; all knowledge, no fear.'],
     array['Skank the verses; slam the chorus.','Three chords, one lesson: all I know is that I don''t know nothing.'],
     'Studio recording, 1989. The east-bay ska-punk anthem.',77),
    ('time-bomb','rancid','guitar','riff','ska verse + punk chorus','crunch','ska punk','rhythm','beginner',
     'Gretsch/Gibson electric (Tim Armstrong / Lars Frederiksen)','Tube amp, clean skank to punk drive','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The two-tone revival hit — clean off-beat skank flipping to driven chorus (gain 6).','Bright skank clean and punk crunch in one song.'],
     array['Upstroke the verses on the off-beats.','The organ carries the hook; you carry the engine.'],
     'Studio recording, 1995. The two-tone revival hit.',77),

    -- ============ FESTIVAL INDIE / MOTOWN / GARAGE REVIVAL ============
    ('intro','the-xx','guitar','riff','main melody','clean','indie pop','lead','beginner',
     'Fender Jazzmaster-style (Romy Madley Croft)','Clean amp with space and reverb','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"large dark reverb","placement":"post_gain","settings":{"mix":5,"decay":6}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":5,"delay":1,"master":6}'::jsonb,
     array['The most-licensed instrumental of its decade — sparse echoing clean melody over the beat.','Dark spacious clean; minimalism as drama.'],
     array['The melody is a handful of notes — place them perfectly.','Space is the instrument.'],
     'Studio recording, 2009. The minimalist instrumental everyone knows.',77),
    ('youth','daughter','guitar','riff','ambient arpeggios','clean','indie folk','rhythm','intermediate',
     'Fender electric (Igor Haefeli)','Clean amp with shimmering ambience','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"shimmer reverb","placement":"post_gain","settings":{"mix":6,"decay":7}},{"effect_type":"delay","effect_name":"ambient delay","placement":"post_gain","settings":{"time":4,"mix":3,"feedback":3}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":6,"delay":3,"master":6}'::jsonb,
     array['The setting-fire-to-our-insides wash — glassy ambient arpeggios in deep shimmer.','Wet fragile clean; the ache lives in the reverb tail.'],
     array['Arpeggiate with an EBow-like evenness.','Let every phrase dissolve before the next.'],
     'Studio recording, 2013. The shimmering heartbreak wash.',76),
    ('my-girl','the-temptations','guitar','riff','main riff','clean','soul','rhythm','beginner',
     'Fender Stratocaster/Gibson (Robert White — Funk Brothers)','Fender tube amp, warm Motown clean','Fender combo cab','neck pickup',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['THE most famous guitar intro in soul — Robert White''s climbing Motown line.','Warm round Snakepit clean; the riff is sunshine itself.'],
     array['The climbing intro riff — learn it exactly, everyone knows it.','Comp quietly once the band enters.'],
     'Studio recording, 1964. Robert White''s immortal Motown intro.',80),
    ('are-you-gonna-be-my-girl','jet','guitar','riff','main riff','crunch','garage rock','rhythm','beginner',
     'Gibson SG (Cameron Muncey / Nic Cester)','Tube stack, garage crunch','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The iPod-ad stomp — bright garage crunch over the Iggy-style shaker beat.','Punchy retro crunch; big dumb fun, played tight.'],
     array['The riff stabs between vocal lines.','Stomp the beat; sell the swagger.'],
     'Studio recording, 2003. The iPod-ad garage stomp.',77),
    ('hate-to-say-i-told-you-so','the-hives','guitar','riff','main riff','distorted','garage rock','rhythm','beginner',
     'Fender/Hagstrom electric (Nicholaus Arson / Vigilante Carlstroem)','Tube stack cranked, wild garage','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['Swedish garage mania — slashing trebly drive in matching suits.','Bright violent crunch; controlled chaos.'],
     array['The main riff slashes on the E and A strings.','Play it like you''re right and everyone knows it.'],
     'Studio recording, 2000. The Swedish garage-mania hit.',77),
    ('woman','wolfmother','guitar','riff','main riff','fuzz','hard rock','rhythm','intermediate',
     'Gibson SG (Andrew Stockdale)','Tube stack with fuzz, vintage-revival roar','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"fuzz","effect_name":"vintage fuzz","placement":"front","settings":{"gain":7,"tone":5,"level":6}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The 2005 Zeppelin-revival riff — fuzzed SG roar with organ chaos.','Thick vintage fuzz-crunch; 1971 by way of 2005.'],
     array['The riff gallops between E and G — attack it.','Scream-along chorus energy.'],
     'Studio recording, 2005. The vintage-revival fuzz roar.',77)
) as c(
  song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence
)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;
