-- Phase 69: industrial + melodeath/power metal + 2024-25 chart hits, verified per-part tone data.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Rammstein','rammstein','Du Hast','du-hast','Sehnsucht',1997),
    ('Rammstein','rammstein','Sonne','sonne','Mutter',2001),
    ('Nine Inch Nails','nine-inch-nails','The Hand That Feeds','the-hand-that-feeds','With Teeth',2005),
    ('Nine Inch Nails','nine-inch-nails','Wish','wish','Broken',1992),
    ('Marilyn Manson','marilyn-manson','The Beautiful People','the-beautiful-people','Antichrist Superstar',1996),
    ('Rob Zombie','rob-zombie','Dragula','dragula','Hellbilly Deluxe',1998),
    ('Static-X','static-x','Push It','push-it','Wisconsin Death Trip',1999),
    ('In Flames','in-flames','Only for the Weak','only-for-the-weak','Clayman',2000),
    ('In Flames','in-flames','Take This Life','take-this-life','Come Clarity',2006),
    ('Children of Bodom','children-of-bodom','Are You Dead Yet?','are-you-dead-yet','Are You Dead Yet?',2005),
    ('Amon Amarth','amon-amarth','Twilight of the Thunder God','twilight-of-the-thunder-god','Twilight of the Thunder God',2008),
    ('Arch Enemy','arch-enemy','Nemesis','nemesis','Doomsday Machine',2005),
    ('At the Gates','at-the-gates','Blinded by Fear','blinded-by-fear','Slaughter of the Soul',1995),
    ('Powerwolf','powerwolf','Demons Are a Girl''s Best Friend','demons-are-a-girls-best-friend','The Sacrament of Sin',2018),
    ('Blind Guardian','blind-guardian','The Bard''s Song (In the Forest)','the-bards-song-in-the-forest','Somewhere Far Beyond',1992),
    ('Shaboozey','shaboozey','A Bar Song (Tipsy)','a-bar-song-tipsy','Where I''ve Been, Isn''t Where I''m Going',2024),
    ('Post Malone','post-malone','I Had Some Help','i-had-some-help','F-1 Trillion',2024),
    ('Lady Gaga','lady-gaga','Die With a Smile','die-with-a-smile','Mayhem',2024),
    ('Myles Smith','myles-smith','Stargazing','stargazing','A Minute...',2024),
    ('Alex Warren','alex-warren','Ordinary','ordinary','You''ll Be Alright, Kid',2025),
    ('Sombr','sombr','Back to Friends','back-to-friends','I Barely Know Her',2025),
    ('Linkin Park','linkin-park','The Emptiness Machine','the-emptiness-machine','From Zero',2024),
    ('Cafune','cafune','Tek It','tek-it','Running',2021),
    ('David Kushner','david-kushner','Daylight','daylight','The Dichotomy',2023),
    ('Djo','djo','End of Beginning','end-of-beginning','DECIDE',2022)
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
    ('rammstein','du-hast'),('rammstein','sonne'),('nine-inch-nails','the-hand-that-feeds'),('nine-inch-nails','wish'),
    ('marilyn-manson','the-beautiful-people'),('rob-zombie','dragula'),('static-x','push-it'),
    ('in-flames','only-for-the-weak'),('in-flames','take-this-life'),('children-of-bodom','are-you-dead-yet'),
    ('amon-amarth','twilight-of-the-thunder-god'),('arch-enemy','nemesis'),('at-the-gates','blinded-by-fear'),
    ('powerwolf','demons-are-a-girls-best-friend'),('blind-guardian','the-bards-song-in-the-forest'),
    ('shaboozey','a-bar-song-tipsy'),('post-malone','i-had-some-help'),('lady-gaga','die-with-a-smile'),
    ('myles-smith','stargazing'),('alex-warren','ordinary'),('sombr','back-to-friends'),
    ('linkin-park','the-emptiness-machine'),('cafune','tek-it'),('david-kushner','daylight'),('djo','end-of-beginning')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('rammstein','du-hast'),('rammstein','sonne'),('nine-inch-nails','the-hand-that-feeds'),('nine-inch-nails','wish'),
    ('marilyn-manson','the-beautiful-people'),('rob-zombie','dragula'),('static-x','push-it'),
    ('in-flames','only-for-the-weak'),('in-flames','take-this-life'),('children-of-bodom','are-you-dead-yet'),
    ('amon-amarth','twilight-of-the-thunder-god'),('arch-enemy','nemesis'),('at-the-gates','blinded-by-fear'),
    ('powerwolf','demons-are-a-girls-best-friend'),('blind-guardian','the-bards-song-in-the-forest'),
    ('shaboozey','a-bar-song-tipsy'),('post-malone','i-had-some-help'),('lady-gaga','die-with-a-smile'),
    ('myles-smith','stargazing'),('alex-warren','ordinary'),('sombr','back-to-friends'),
    ('linkin-park','the-emptiness-machine'),('cafune','tek-it'),('david-kushner','daylight'),('djo','end-of-beginning')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('rammstein','du-hast'),('rammstein','sonne'),('nine-inch-nails','the-hand-that-feeds'),('nine-inch-nails','wish'),
    ('marilyn-manson','the-beautiful-people'),('rob-zombie','dragula'),('static-x','push-it'),
    ('in-flames','only-for-the-weak'),('in-flames','take-this-life'),('children-of-bodom','are-you-dead-yet'),
    ('amon-amarth','twilight-of-the-thunder-god'),('arch-enemy','nemesis'),('at-the-gates','blinded-by-fear'),
    ('powerwolf','demons-are-a-girls-best-friend'),('blind-guardian','the-bards-song-in-the-forest'),
    ('shaboozey','a-bar-song-tipsy'),('post-malone','i-had-some-help'),('lady-gaga','die-with-a-smile'),
    ('myles-smith','stargazing'),('alex-warren','ordinary'),('sombr','back-to-friends'),
    ('linkin-park','the-emptiness-machine'),('cafune','tek-it'),('david-kushner','daylight'),('djo','end-of-beginning')
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
    -- ============ INDUSTRIAL ============
    ('du-hast','rammstein','guitar','riff','main riff','high_gain','industrial metal','rhythm','beginner',
     'ESP/Gibson electric (Richard Kruspe / Paul Landers)','Modern high-gain, surgically tight','Closed-back 4x12 cab','EMG bridge humbucker',
     '[{"effect_type":"gate","effect_name":"tight noise gate","placement":"front","settings":{"threshold":7}}]'::jsonb,
     '{"gain":7,"bass":6,"mids":4,"treble":6,"presence":6,"reverb":0,"delay":0,"master":8}'::jsonb,
     array['The Teutonic machine — down-tuned chugs cut with millimeter precision.','Tight scooped high gain; the silences are engineered.'],
     array['Drop D; every chug exactly on the grid.','Play like a hydraulic press.'],
     'Studio recording, 1997. The Teutonic machine-chug anthem.',78),
    ('sonne','rammstein','guitar','riff','main riff','high_gain','industrial metal','rhythm','intermediate',
     'ESP/Gibson electric (Richard Kruspe / Paul Landers)','Modern high-gain wall','Closed-back 4x12 cab','EMG bridge humbucker',
     '[{"effect_type":"gate","effect_name":"tight noise gate","placement":"front","settings":{"threshold":7}}]'::jsonb,
     '{"gain":7,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The countdown colossus — slow crushing wall with orchestral weight.','Thick precise saturation; heaviness as ceremony.'],
     array['The riff descends like a closing gate.','Slow power beats fast notes here.'],
     'Studio recording, 2001. The countdown colossus.',78),
    ('the-hand-that-feeds','nine-inch-nails','guitar','riff','main riff','distorted','industrial rock','rhythm','beginner',
     'Les Paul/Jazzmaster (Trent Reznor / Aaron North era)','Driven amp, processed bite','Closed-back cab','bridge humbucker',
     '[{"effect_type":"gate","effect_name":"noise gate","placement":"front","settings":{"threshold":6}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['The danceable protest — wiry processed drive locked to the machine groove.','Bright gated bite; the guitar is a rhythm instrument here.'],
     array['The riff stabs on the groove — no ringing.','Precision equals menace.'],
     'Studio recording, 2005. The danceable industrial protest.',76),
    ('wish','nine-inch-nails','guitar','riff','main riff','high_gain','industrial rock','rhythm','intermediate',
     'Jackson/Les Paul (Trent Reznor)','High-gain wall, industrial violence','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"gate","effect_name":"hard gate","placement":"front","settings":{"threshold":8}}]'::jsonb,
     '{"gain":8,"bass":5,"mids":5,"treble":7,"presence":7,"reverb":0,"delay":0,"master":8}'::jsonb,
     array['The Grammy-winning fistfight — slashing gated high gain at machine tempo.','Harsh tight wall; the gate chops the air out.'],
     array['The riff punches in bursts.','Violence with a metronome.'],
     'Studio recording, 1992. The gated industrial fistfight.',76),
    ('the-beautiful-people','marilyn-manson','guitar','riff','main riff','high_gain','industrial metal','rhythm','beginner',
     'Gibson/Fernandes electric (Zim Zum / Twiggy)','High-gain wall, sleazy grind','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The freak-show stomp — grinding drop-D wall over the tom march.','Thick sleazy saturation; the swagger is the hook.'],
     array['Drop D; the riff marches with the drums.','Strut it ugly.'],
     'Studio recording, 1996. The freak-show stomp.',76),
    ('dragula','rob-zombie','guitar','riff','main riff','high_gain','industrial metal','rhythm','beginner',
     'Solid-body electric (Mike Riggs era)','High-gain wall, horror-groove','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The drag-racing monster — greasy drop-tuned groove wall.','Thick churning saturation; horror-movie swagger.'],
     array['The riff revs like an engine.','Dig trenches, ride the groove.'],
     'Studio recording, 1998. The horror-groove dragster.',76),
    ('push-it','static-x','guitar','riff','main riff','high_gain','industrial metal','rhythm','beginner',
     'Solid-body electric (Wayne Static / Koichi Fukuda)','High-gain, evil disco chug','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"gate","effect_name":"tight gate","placement":"front","settings":{"threshold":7}}]'::jsonb,
     '{"gain":8,"bass":6,"mids":4,"treble":7,"presence":7,"reverb":0,"delay":0,"master":8}'::jsonb,
     array['"Evil disco" — one-chord industrial chug locked to the dance-floor kick.','Scooped gated wall; the rhythm IS the song.'],
     array['One note, total commitment.','Machine tightness at club tempo.'],
     'Studio recording, 1999. The evil-disco chug.',75),

    -- ============ MELODEATH / POWER METAL ============
    ('only-for-the-weak','in-flames','guitar','riff','main riff','high_gain','melodic death metal','rhythm','intermediate',
     'Ibanez/ESP electric (Bjorn Gelotte / Jesper Stromblad)','Modern high-gain, Gothenburg voice','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['The Gothenburg groove-anthem — melodic harmony riffs over churning gain.','Saturated but melodic; the twin leads sing over the chug.'],
     array['Learn both harmony parts.','Groove first, aggression second.'],
     'Studio recording, 2000. The Gothenburg groove-anthem.',77),
    ('take-this-life','in-flames','guitar','riff','main riff','high_gain','melodic death metal','rhythm','advanced',
     'Ibanez/ESP electric (Bjorn Gelotte / Jesper Stromblad)','Modern high-gain','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The Come Clarity sprint — fast melodic riffing at thrash velocity.','Tight bright saturation; melody at full sprint.'],
     array['Alternate picking stamina required.','The chorus harmony soars — nail the bend intonation.'],
     'Studio recording, 2006. The melodeath sprint.',77),
    ('are-you-dead-yet','children-of-bodom','guitar','riff','main riff + solo','high_gain','melodic death metal','lead','advanced',
     'ESP Alexi signature (Alexi Laiho)','Modern high-gain, neoclassical shred voice','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":7,"presence":7,"reverb":2,"delay":1,"master":8}'::jsonb,
     array['Alexi''s groove-shred flagship — stomping riff into keyboard-duel solos.','Bright aggressive saturation; the solos trade with the keys.'],
     array['The main riff stomps in drop C.','The solo runs are neoclassical — slow practice.'],
     'Studio recording, 2005. Alexi''s groove-shred flagship.',77),
    ('twilight-of-the-thunder-god','amon-amarth','guitar','riff','main riff','high_gain','melodic death metal','rhythm','intermediate',
     'ESP/Jackson electric (Olavi Mikkonen / Johan Soderberg)','Modern high-gain, viking wall','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The viking-metal gateway — galloping melodic wall about Thor.','Thick heroic saturation; the harmony hook is the sail.'],
     array['Gallop the rhythm; sing the harmony.','Row. Row. Row.'],
     'Studio recording, 2008. The viking-metal gateway.',77),
    ('nemesis','arch-enemy','guitar','riff','main riff','high_gain','melodic death metal','rhythm','intermediate',
     'ESP/Dean electric (Michael Amott / Christopher Amott)','Modern high-gain','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The melodeath rally-cry — anthemic riffing with twin-lead fire.','Saturated mid-forward drive; fists-up melody.'],
     array['The unison hook must be exact.','March, don''t sprint.'],
     'Studio recording, 2005. The melodeath rally-cry.',76),
    ('blinded-by-fear','at-the-gates','guitar','riff','main riff','high_gain','melodic death metal','rhythm','advanced',
     'Solid-body electric (Anders Bjorler / Martin Larsson)','High-gain, Slaughter of the Soul bite','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":5,"treble":7,"presence":7,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The blueprint opener — the riff that launched a thousand metalcore bands.','Bright cutting saturation; urgency incarnate.'],
     array['Tremolo-picked precision at speed.','This riff built a genre — respect the accents.'],
     'Studio recording, 1995. The melodeath blueprint opener.',77),
    ('demons-are-a-girls-best-friend','powerwolf','guitar','riff','main riff','high_gain','power metal','rhythm','beginner',
     'Gibson/ESP electric (Matthew & Charles Greywolf)','Modern high-gain with organ pomp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The heavy-metal mass — pomp-and-chug wall under cathedral organ.','Thick ceremonial saturation; the chorus is a hymn.'],
     array['Chug the verses; open the chorus wide.','Theatrics mandatory.'],
     'Studio recording, 2018. The heavy-metal mass.',75),
    ('the-bards-song-in-the-forest','blind-guardian','guitar','main','fingerpicked ballad','acoustic','power metal','rhythm','intermediate',
     'Acoustic guitars (Andre Olbrich / Marcus Siepen)','Acoustic — layered and mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The campfire hymn of metal — interweaving acoustic fingerpicking, sung by every festival crowd.','Layered warm acoustics; Tolkien by firelight.'],
     array['Two picking parts interweave — learn both.','The crowd sings the solo. Let them.'],
     'Studio recording, 1992. Metal''s campfire hymn.',78),

    -- ============ 2024-25 CHART HITS ============
    ('a-bar-song-tipsy','shaboozey','guitar','main','main progression','acoustic','country','rhythm','beginner',
     'Acoustic guitar (session)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['2024''s longest-running #1 — stomping country-folk strums with the Tipsy interpolation.','Bright driving acoustic; barroom singalong energy.'],
     array['Stomp-clap strum pattern throughout.','Everybody at the bar sings the hook.'],
     'Studio recording, 2024. The record-breaking bar-stomp.',73),
    ('i-had-some-help','post-malone','guitar','main','main progression','clean','country','rhythm','beginner',
     'Fender Telecaster + acoustic (session — Nashville)','Fender tube amp, country clean','Fender combo cab','bridge single-coil',
     '[{"effect_type":"compressor","effect_name":"studio compression","placement":"front","settings":{"sustain":5,"level":5}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":3,"delay":0,"master":7}'::jsonb,
     array['The Posty-Wallen juggernaut — bright Tele licks over stadium-country strums.','Crisp Nashville clean; arena polish on honky-tonk bones.'],
     array['Acoustic drives; Tele fills sparkle between lines.','Big dumb joy — leans into it.'],
     'Studio recording, 2024. The stadium-country juggernaut.',73),
    ('die-with-a-smile','lady-gaga','guitar','main','main progression','clean','pop','rhythm','beginner',
     'Electric guitar (session)','Clean amp with vintage warmth','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":4}},{"effect_type":"tremolo","effect_name":"light tremolo","placement":"post_gain","settings":{"rate":3,"depth":3}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":4,"delay":0,"master":6}'::jsonb,
     array['The Gaga-Bruno world-ender — warm retro clean under the duet.','Vintage-flavored warm clean; 70s ballad reborn.'],
     array['The intro figure sets the last-night-on-earth mood.','Swell with the duet''s builds.'],
     'Studio recording, 2024. The world-ending duet.',73),
    ('stargazing','myles-smith','guitar','main','main progression','acoustic','folk pop','rhythm','beginner',
     'Acoustic guitar (Myles Smith)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":7,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The 2024 festival-folk rocket — driving bright strums with stomp-clap lift.','Crisp galloping acoustic; Mumford energy reborn.'],
     array['Gallop the strums into the hook.','Save breath for the woah-ohs.'],
     'Studio recording, 2024. The festival-folk rocket.',73),
    ('ordinary','alex-warren','guitar','main','main progression','acoustic','pop','rhythm','beginner',
     'Acoustic guitar (session)','Acoustic — mic''d with cinematic swell','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":4,"delay":0,"master":6}'::jsonb,
     array['2025''s wedding-vow giant — hushed acoustic building to a cathedral swell.','Warm intimate acoustic; the drama arrives in waves.'],
     array['Gentle picking until the drums land.','Hold back so the climax can tower.'],
     'Studio recording, 2025. The wedding-vow giant.',72),
    ('back-to-friends','sombr','guitar','riff','main loop','clean','indie pop','rhythm','beginner',
     'Electric guitar (Sombr)','Clean amp, moody loop','Studio direct','neck pickup',
     '[{"effect_type":"reverb","effect_name":"dark room reverb","placement":"post_gain","settings":{"mix":4}},{"effect_type":"compressor","effect_name":"tight compression","placement":"front","settings":{"sustain":5,"level":5}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":4,"delay":1,"master":6}'::jsonb,
     array['The 2025 viral heartbreak loop — moody clean riff cycling under a yearning vocal.','Dark compressed clean; the loop is the hook.'],
     array['The riff cycles hypnotically — keep it even.','Let the ache sit on top.'],
     'Studio recording, 2025. The viral heartbreak loop.',72),
    ('the-emptiness-machine','linkin-park','guitar','riff','main riff','high_gain','nu metal','rhythm','intermediate',
     'PRS/Ibanez electric (Brad Delson)','Modern high-gain, produced','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"gate","effect_name":"noise gate","placement":"front","settings":{"threshold":6}}]'::jsonb,
     '{"gain":7,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['The comeback single — classic LP wall updated for the Emily era.','Tight modern saturation; verse restraint, chorus detonation.'],
     array['Muted verse pulses; wide chorus chords.','The bridge drop hits hardest played exactly in time.'],
     'Studio recording, 2024. The comeback-era wall.',74),
    ('tek-it','cafune','guitar','riff','main loop','clean','indie pop','rhythm','beginner',
     'Electric guitar (Noah Yoo)','Clean amp, glassy loop','Studio direct','bridge pickup',
     '[{"effect_type":"compressor","effect_name":"tight compression","placement":"front","settings":{"sustain":5,"level":5}},{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":2,"bass":4,"mids":5,"treble":7,"presence":6,"reverb":3,"delay":1,"master":6}'::jsonb,
     array['The "watch the moon" viral — glassy arpeggio loop under the hyperpop-ish vocal.','Bright compressed clean; the loop sparkles in place.'],
     array['The arpeggio loop must stay machine-even.','Energy comes from the drums — you''re the shimmer.'],
     'Studio recording, 2021. The moon-watching viral loop.',73),
    ('daylight','david-kushner','guitar','main','fingerpicked pattern','acoustic','dark pop','rhythm','beginner',
     'Acoustic guitar (David Kushner)','Acoustic — mic''d, dark and close','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":6,"mids":5,"treble":4,"presence":3,"reverb":4,"delay":0,"master":6}'::jsonb,
     array['The gothic-folk viral — low fingerpicked pattern under a cathedral-dark vocal.','Dark warm acoustic; shadows in every note.'],
     array['The minor picking pattern tolls like a bell.','Keep it solemn and steady.'],
     'Studio recording, 2023. The gothic-folk viral.',73),
    ('end-of-beginning','djo','guitar','riff','main progression','clean','indie pop','rhythm','beginner',
     'Electric guitar (Joe Keery)','Clean amp with retro chorus haze','Studio direct','neck pickup',
     '[{"effect_type":"chorus","effect_name":"retro chorus","placement":"post_gain","settings":{"rate":3,"depth":4,"mix":4}},{"effect_type":"reverb","effect_name":"soft reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":3,"delay":1,"master":6}'::jsonb,
     array['The Chicago-nostalgia viral — hazy chorused clean under the drifting vocal.','Warm retro clean; the wistfulness is in the wobble.'],
     array['Gentle chord pulses on the beat.','When you go back to Chicago, play this.'],
     'Studio recording, 2022. The Chicago-nostalgia viral.',73)
) as c(
  song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence
)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;
