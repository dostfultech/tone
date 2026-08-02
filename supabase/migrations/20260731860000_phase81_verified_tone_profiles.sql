-- Phase 81: riff-classic one-hitters + 70s-00s radio canon, verified per-part tone data.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Foghat','foghat','Slow Ride','slow-ride','Fool for the City',1975),
    ('Ted Nugent','ted-nugent','Stranglehold','stranglehold','Ted Nugent',1975),
    ('The Edgar Winter Group','the-edgar-winter-group','Frankenstein','frankenstein','They Only Come Out at Night',1972),
    ('The Edgar Winter Group','the-edgar-winter-group','Free Ride','free-ride','They Only Come Out at Night',1972),
    ('Chicago','chicago','25 or 6 to 4','25-or-6-to-4','Chicago',1970),
    ('Elvin Bishop','elvin-bishop','Fooled Around and Fell in Love','fooled-around-and-fell-in-love','Struttin'' My Stuff',1975),
    ('Joe Walsh','joe-walsh','Rocky Mountain Way','rocky-mountain-way','The Smoker You Drink, the Player You Get',1973),
    ('Joe Walsh','joe-walsh','Life''s Been Good','lifes-been-good','But Seriously, Folks...',1978),
    ('Foreigner','foreigner','Hot Blooded','hot-blooded','Double Vision',1978),
    ('Foreigner','foreigner','Juke Box Hero','juke-box-hero','4',1981),
    ('Mott the Hoople','mott-the-hoople','All the Young Dudes','all-the-young-dudes','All the Young Dudes',1972),
    ('Robert Palmer','robert-palmer','Addicted to Love','addicted-to-love','Riptide',1985),
    ('Tom Petty','tom-petty','Runnin'' Down a Dream','runnin-down-a-dream','Full Moon Fever',1989),
    ('Tom Petty','tom-petty','Learning to Fly','learning-to-fly','Into the Great Wide Open',1991),
    ('3 Doors Down','3-doors-down','Kryptonite','kryptonite','The Better Life',2000),
    ('3 Doors Down','3-doors-down','Here Without You','here-without-you','Away from the Sun',2002),
    ('Lenny Kravitz','lenny-kravitz','Are You Gonna Go My Way','are-you-gonna-go-my-way','Are You Gonna Go My Way',1993),
    ('Lenny Kravitz','lenny-kravitz','Fly Away','fly-away','5',1998),
    ('U2','u2','Beautiful Day','beautiful-day','All That You Can''t Leave Behind',2000),
    ('U2','u2','One','one-u2','Achtung Baby',1991),
    ('The Spencer Davis Group','the-spencer-davis-group','Gimme Some Lovin''','gimme-some-lovin','Gimme Some Lovin''',1966),
    ('The Doobie Brothers','the-doobie-brothers','China Grove','china-grove','The Captain and Me',1973),
    ('The Doobie Brothers','the-doobie-brothers','Black Water','black-water','What Were Once Vices Are Now Habits',1974),
    ('David Bowie','david-bowie','Suffragette City','suffragette-city','The Rise and Fall of Ziggy Stardust',1972),
    ('Steppenwolf','steppenwolf','Magic Carpet Ride','magic-carpet-ride','The Second',1968)
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
    ('foghat','slow-ride'),('ted-nugent','stranglehold'),('the-edgar-winter-group','frankenstein'),
    ('the-edgar-winter-group','free-ride'),('chicago','25-or-6-to-4'),('elvin-bishop','fooled-around-and-fell-in-love'),
    ('joe-walsh','rocky-mountain-way'),('joe-walsh','lifes-been-good'),('foreigner','hot-blooded'),
    ('foreigner','juke-box-hero'),('mott-the-hoople','all-the-young-dudes'),('robert-palmer','addicted-to-love'),
    ('tom-petty','runnin-down-a-dream'),('tom-petty','learning-to-fly'),('3-doors-down','kryptonite'),
    ('3-doors-down','here-without-you'),('lenny-kravitz','are-you-gonna-go-my-way'),('lenny-kravitz','fly-away'),
    ('u2','beautiful-day'),('u2','one-u2'),('the-spencer-davis-group','gimme-some-lovin'),
    ('the-doobie-brothers','china-grove'),('the-doobie-brothers','black-water'),('david-bowie','suffragette-city'),
    ('steppenwolf','magic-carpet-ride')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
  where p.mode = 'guitar'
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('foghat','slow-ride'),('ted-nugent','stranglehold'),('the-edgar-winter-group','frankenstein'),
    ('the-edgar-winter-group','free-ride'),('chicago','25-or-6-to-4'),('elvin-bishop','fooled-around-and-fell-in-love'),
    ('joe-walsh','rocky-mountain-way'),('joe-walsh','lifes-been-good'),('foreigner','hot-blooded'),
    ('foreigner','juke-box-hero'),('mott-the-hoople','all-the-young-dudes'),('robert-palmer','addicted-to-love'),
    ('tom-petty','runnin-down-a-dream'),('tom-petty','learning-to-fly'),('3-doors-down','kryptonite'),
    ('3-doors-down','here-without-you'),('lenny-kravitz','are-you-gonna-go-my-way'),('lenny-kravitz','fly-away'),
    ('u2','beautiful-day'),('u2','one-u2'),('the-spencer-davis-group','gimme-some-lovin'),
    ('the-doobie-brothers','china-grove'),('the-doobie-brothers','black-water'),('david-bowie','suffragette-city'),
    ('steppenwolf','magic-carpet-ride')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
  where p.mode = 'guitar'
);
delete from public.song_tone_profiles p where p.mode = 'guitar' and p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('foghat','slow-ride'),('ted-nugent','stranglehold'),('the-edgar-winter-group','frankenstein'),
    ('the-edgar-winter-group','free-ride'),('chicago','25-or-6-to-4'),('elvin-bishop','fooled-around-and-fell-in-love'),
    ('joe-walsh','rocky-mountain-way'),('joe-walsh','lifes-been-good'),('foreigner','hot-blooded'),
    ('foreigner','juke-box-hero'),('mott-the-hoople','all-the-young-dudes'),('robert-palmer','addicted-to-love'),
    ('tom-petty','runnin-down-a-dream'),('tom-petty','learning-to-fly'),('3-doors-down','kryptonite'),
    ('3-doors-down','here-without-you'),('lenny-kravitz','are-you-gonna-go-my-way'),('lenny-kravitz','fly-away'),
    ('u2','beautiful-day'),('u2','one-u2'),('the-spencer-davis-group','gimme-some-lovin'),
    ('the-doobie-brothers','china-grove'),('the-doobie-brothers','black-water'),('david-bowie','suffragette-city'),
    ('steppenwolf','magic-carpet-ride')
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
    ('slow-ride','foghat','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Gibson Les Paul (Lonesome Dave Peverett / Rod Price)','Tube stack, boogie crunch','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The boogie eternal — thick swinging crunch with Rod Price''s slide answers.','Warm greasy drive; take it easy at exactly this tempo.'],
     array['The riff swings — never straighten it.','Slow ride — the instruction is in the title.'],
     'Studio recording, 1975. The boogie eternal.',77),
    ('stranglehold','ted-nugent','guitar','riff','main riff + solo','crunch','rock','lead','intermediate',
     'Gibson Byrdland (Ted Nugent)','Fender tube stack cranked, feedback-hot','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":6,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The eight-minute prowl — hollow-body feedback heat over the hypnotic groove.','Mid-hot sustaining crunch; the solo stalks for minutes.'],
     array['The riff circles; the solo hunts.','Sustain, feedback, patience — repeat.'],
     'Studio recording, 1975. The eight-minute prowl.',77),
    ('frankenstein','the-edgar-winter-group','guitar','riff','instrumental riff','crunch','rock','rhythm','intermediate',
     'Gibson/Fender electric (Ronnie Montrose)','Tube stack, monster crunch','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":6,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The monster instrumental — Montrose''s stomping riff trading with the synth.','Thick punchy crunch; the riff lumbers gloriously.'],
     array['The main theme stomps in unison.','It''s alive — keep it that way.'],
     'Studio recording, 1972. The monster instrumental stomp.',77),
    ('free-ride','the-edgar-winter-group','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Gibson/Fender electric (Dan Hartman / Ronnie Montrose)','Tube amp, sunny crunch','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The sunshine riff — bright chiming crunch hook.','Open warm drive; the intro riff grins.'],
     array['The double-stop intro hook is the song.','Come on and take a free ride — happily.'],
     'Studio recording, 1972. The sunshine hook.',77),
    ('25-or-6-to-4','chicago','guitar','riff','main riff + solo','crunch','rock','lead','intermediate',
     'Gibson SG (Terry Kath)','Tube stack, wah-torched crunch','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"wah","effect_name":"wah solo","placement":"front","settings":{"position":6}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The descending monolith — and Terry Kath''s wah solo that Hendrix reportedly envied.','Thick aggressive crunch; the solo burns the building down.'],
     array['The descending riff anchors the horns.','Kath''s wah solo is the reason guitarists know this band.'],
     'Studio recording, 1970. Kath''s envied wah inferno.',79),
    ('fooled-around-and-fell-in-love','elvin-bishop','guitar','solo','ballad solo','clean','rock','lead','intermediate',
     'Gibson ES-345 (Elvin Bishop)','Tube amp, singing warm lead','Small combo cab','neck pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":7,"treble":5,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The one-that-got-away solo — warm singing hollow-body leads around Mickey Thomas'' vocal.','Round creamy lead voice; every phrase a sigh.'],
     array['The fills answer like a second singer.','I fooled around and fell in love — the guitar did too.'],
     'Studio recording, 1975. The warm ballad-solo classic.',77),
    ('rocky-mountain-way','joe-walsh','guitar','riff','slide riff + talk box','crunch','rock','rhythm','intermediate',
     'Gibson Les Paul with slide (Joe Walsh)','Tube stack with talk box solo','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"filter","effect_name":"talk box (solo)","placement":"post_gain","settings":{"mix":8}}]'::jsonb,
     '{"gain":6,"bass":6,"mids":6,"treble":5,"presence":5,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The talk-box landmark — Walsh''s lumbering slide riff and the mouth-tube solo that started it all.','Fat greasy crunch; slide the riff, talk the solo.'],
     array['Open tuning for the slide riff.','The talk box solo needs the tube — or your best wah imitation.'],
     'Studio recording, 1973. Walsh''s talk-box landmark.',79),
    ('lifes-been-good','joe-walsh','guitar','riff','multi-section riff suite','crunch','rock','rhythm','intermediate',
     'Gibson Les Paul (Joe Walsh)','Tube stack, wry crunch','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The rock-star tax return — eight minutes of riff suites, reggae breaks, and the deadpan.','Warm wry crunch; every section a different joke.'],
     array['Learn the sections as separate songs.','My Maserati does one-eighty-five — play it that smug.'],
     'Studio recording, 1978. The deadpan riff suite.',78),
    ('hot-blooded','foreigner','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Gibson Les Paul (Mick Jones)','Marshall tube stack','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['Check it and see — the strutting Marshall riff with the fever hook.','Punchy warm Marshall; arena swagger in G.'],
     array['The riff struts; the stops sell it.','I got a fever of a hundred and three — sustain accordingly.'],
     'Studio recording, 1978. The fever strut.',77),
    ('juke-box-hero','foreigner','guitar','riff','build riff','high_gain','rock','rhythm','intermediate',
     'Gibson Les Paul (Mick Jones)','Marshall stack, building wall','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":6,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The origin-story anthem — one guitar in a pawn shop window, then the wall arrives.','Thick building drive; stars in his eyes, gain on yours.'],
     array['The bass-note build explodes into the chorus wall.','He heard one guitar — be that guitar.'],
     'Studio recording, 1981. The origin-story wall.',77),
    ('all-the-young-dudes','mott-the-hoople','guitar','riff','glam anthem comping','crunch','glam rock','rhythm','beginner',
     'Gibson Les Paul (Mick Ralphs)','Tube amp, warm glam crunch','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['Bowie''s gift to Mott — warm anthem comping under the generational chorus.','Soft glam crunch; carry the news gently.'],
     array['Arpeggiate the verses; swell the chorus.','All the young dudes — sing it for them.'],
     'Studio recording, 1972. Bowie''s gifted anthem.',77),
    ('addicted-to-love','robert-palmer','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Fender/Gibson electric (Eddie Martinez)','Tube amp, chunky 80s crunch','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":6,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The lipstick-video monolith — chunky deliberate crunch riff.','Thick slow-stomp drive; might as well face it.'],
     array['The riff lands like a runway walk.','Slower than you think; heavier than it looks.'],
     'Studio recording, 1985. The runway-stomp riff.',77),
    ('runnin-down-a-dream','tom-petty','guitar','riff','main riff + outro solo','crunch','heartland rock','lead','intermediate',
     'Gibson/Rickenbacker electric (Mike Campbell)','Tube amp, driving crunch','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The highway sprint — Campbell''s descending riff and the endless outro solo.','Driving warm crunch; the outro solo runs to the fade and beyond.'],
     array['The E-riff descends like mile markers.','The outro solo never resolves — that''s the dream.'],
     'Studio recording, 1989. Campbell''s highway sprint.',79),
    ('learning-to-fly','tom-petty','guitar','main','strummed anthem','acoustic','heartland rock','rhythm','beginner',
     'Acoustic + electric (Mike Campbell / Tom Petty)','Acoustic with clean electric color','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Four chords forever — F-C-Am-G and the whole sky.','Warm open strums; coming down is the hardest thing.'],
     array['The four-chord loop never changes.','What goes up must come down — but not the strumming.'],
     'Studio recording, 1991. The four-chord sky.',79),
    ('kryptonite','3-doors-down','guitar','riff','main riff','crunch','post-grunge','rhythm','beginner',
     'PRS/Gibson electric (Matt Roberts / Chris Henderson)','Tube amp, tight radio crunch','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The Superman single — circling minor riff that owned 2000s radio.','Tight warm crunch; the riff loops like a worry.'],
     array['The three-chord circle repeats hypnotically.','If I go crazy — the riff stays sane.'],
     'Studio recording, 2000. The Superman circle riff.',77),
    ('here-without-you','3-doors-down','guitar','main','ballad arpeggios','acoustic','post-grunge','rhythm','beginner',
     'Acoustic guitar (3 Doors Down)','Acoustic — mic''d with strings','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The deployment ballad — gentle acoustic arpeggios under the miles.','Warm soft acoustic; a thousand miles in every chord.'],
     array['Arpeggiate the verses patiently.','I''m here without you — steady as a heartbeat.'],
     'Studio recording, 2002. The deployment ballad.',76),
    ('are-you-gonna-go-my-way','lenny-kravitz','guitar','riff','main riff','crunch','rock','rhythm','intermediate',
     'Gibson Flying V (Lenny Kravitz / Craig Ross)','Vintage tube stack cranked','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":6,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The retro-rocket riff — Hendrix-school Flying V through vintage stacks.','Mid-hot vintage crunch; 1968 rebuilt in 1993.'],
     array['The riff sprints E-minor pentatonic fire.','Ask the question at full volume.'],
     'Studio recording, 1993. The retro-rocket riff.',78),
    ('fly-away','lenny-kravitz','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Gibson/Fender electric (Lenny Kravitz)','Tube amp, phased warm crunch','Closed-back cab','bridge humbucker',
     '[{"effect_type":"phaser","effect_name":"slow phaser","placement":"post_gain","settings":{"rate":3,"depth":4,"mix":4}}]'::jsonb,
     '{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The dragonfly single — phased warm crunch on the A-G-D circle.','Swirly thick drive; I want to get away, smoothly.'],
     array['The chord circle floats through the phaser.','Yeah yeah yeah — with lift.'],
     'Studio recording, 1998. The phased dragonfly riff.',77),
    ('beautiful-day','u2','guitar','riff','chime riff','clean','rock','rhythm','intermediate',
     'Fender/Gibson electric (The Edge)','Clean amp with dotted-eighth delay','Vox 2x12 cab','bridge pickup',
     '[{"effect_type":"delay","effect_name":"dotted-eighth delay","placement":"post_gain","settings":{"time":4,"mix":4,"feedback":3}},{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":3,"bass":5,"mids":5,"treble":7,"presence":6,"reverb":3,"delay":4,"master":7}'::jsonb,
     array['The reboot anthem — Edge''s delay-chime arpeggios reborn for the millennium.','Bright dotted-eighth shimmer; the sky falls and you feel it.'],
     array['Time the arpeggios to the delay grid.','It''s a beautiful day — don''t let it get away.'],
     'Studio recording, 2000. The delay-chime reboot.',78),
    ('one-u2','u2','guitar','main','ballad arpeggios','clean','rock','rhythm','beginner',
     'Fender/Gibson electric (The Edge)','Clean-to-warm amp, intimate','Vox 2x12 cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"soft hall","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":3,"delay":1,"master":6}'::jsonb,
     array['The Achtung Baby truce — warm sparse arpeggios under the hardest lyric they wrote.','Gentle warm clean; one love, one blood.'],
     array['Arpeggiate Am-D-F-G with restraint.','We get to carry each other. Play like that.'],
     'Studio recording, 1991. The truce ballad.',78),
    ('gimme-some-lovin','the-spencer-davis-group','guitar','riff','riff + organ stabs','crunch','rock','rhythm','beginner',
     'Fender/Gibson electric (Spencer Davis)','Tube amp, garage-soul crunch','Small combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The teenage-Winwood detonation — guitar riffs locked with THAT organ.','Raw bright crunch; so glad we made it.'],
     array['The G-riff pumps with the bass ostinato.','Gimme some lovin'' — every day.'],
     'Studio recording, 1966. The organ-and-riff detonation.',77),
    ('china-grove','the-doobie-brothers','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Gibson Les Paul (Tom Johnston)','Tube amp, punchy crunch','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The Texas-town sprint — Johnston''s punchy E-riff at highway pace.','Bright punchy crunch; the riff hits and runs.'],
     array['The E-D-E riff snaps — tight downstrokes.','Talkin'' ''bout China Grove — at 90 mph.'],
     'Studio recording, 1973. Johnston''s highway sprint riff.',78),
    ('black-water','the-doobie-brothers','guitar','main','fingerpicked swamp folk','acoustic','rock','rhythm','intermediate',
     'Acoustic guitar in open tuning (Patrick Simmons)','Acoustic — mic''d with viola','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The Mississippi moon float — Simmons'' open-tuned fingerpicking and the a-cappella round.','Warm rolling acoustic; catfish-lazy tempo.'],
     array['Open tuning; the pattern rolls like the river.','I''d like to hear some funky Dixieland — then the round begins.'],
     'Studio recording, 1974. Simmons'' swamp-folk float.',78),
    ('suffragette-city','david-bowie','guitar','riff','main riff','distorted','glam rock','rhythm','beginner',
     'Gibson Les Paul Custom (Mick Ronson)','Marshall Major cranked','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['Wham bam thank you ma''am — Ronson''s piston-pump glam riff.','Mid-heavy cranked Marshall; the riff pumps relentlessly.'],
     array['Piston the A-riff without mercy.','Ohhh don''t lean on me man — full sprint.'],
     'Studio recording, 1972. Ronson''s piston-pump glam.',78),
    ('magic-carpet-ride','steppenwolf','guitar','riff','fuzz riff','fuzz','rock','rhythm','beginner',
     'Gibson/Fender electric (Michael Monarch)','Tube amp with fuzz, psychedelic drive','Closed-back cab','bridge pickup',
     '[{"effect_type":"fuzz","effect_name":"psychedelic fuzz","placement":"front","settings":{"gain":6,"tone":5,"level":6}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The psychedelic cruiser — fuzzy stomp riff with the freakout middle.','Warm buzzing fuzz; close your eyes girl.'],
     array['The riff pumps two chords.','The middle section dissolves — dissolve with it.'],
     'Studio recording, 1968. The psychedelic cruiser.',77)
) as c(
  song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence
)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;
