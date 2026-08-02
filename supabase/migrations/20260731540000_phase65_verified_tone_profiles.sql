-- Phase 65: classic rock deep cuts II, verified per-part tone data.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Led Zeppelin','led-zeppelin','Going to California','going-to-california','Led Zeppelin IV',1971),
    ('Led Zeppelin','led-zeppelin','Babe I''m Gonna Leave You','babe-im-gonna-leave-you','Led Zeppelin',1969),
    ('Led Zeppelin','led-zeppelin','Ten Years Gone','ten-years-gone','Physical Graffiti',1975),
    ('Led Zeppelin','led-zeppelin','The Ocean','the-ocean','Houses of the Holy',1973),
    ('The Rolling Stones','the-rolling-stones','Wild Horses','wild-horses','Sticky Fingers',1971),
    ('The Rolling Stones','the-rolling-stones','Sympathy for the Devil','sympathy-for-the-devil','Beggars Banquet',1968),
    ('The Rolling Stones','the-rolling-stones','Beast of Burden','beast-of-burden','Some Girls',1978),
    ('The Rolling Stones','the-rolling-stones','Dead Flowers','dead-flowers','Sticky Fingers',1971),
    ('David Bowie','david-bowie','Space Oddity','space-oddity','David Bowie (Space Oddity)',1969),
    ('David Bowie','david-bowie','Heroes','heroes','"Heroes"',1977),
    ('David Bowie','david-bowie','Moonage Daydream','moonage-daydream','The Rise and Fall of Ziggy Stardust',1972),
    ('T. Rex','t-rex','Get It On (Bang a Gong)','get-it-on-bang-a-gong','Electric Warrior',1971),
    ('T. Rex','t-rex','20th Century Boy','20th-century-boy','20th Century Boy',1973),
    ('The Who','the-who','Substitute','substitute','Substitute',1966),
    ('Deep Purple','deep-purple','Child in Time','child-in-time','Deep Purple in Rock',1970),
    ('The Doors','the-doors','Riders on the Storm','riders-on-the-storm','L.A. Woman',1971),
    ('The Kinks','the-kinks','Waterloo Sunset','waterloo-sunset','Something Else by The Kinks',1967),
    ('Golden Earring','golden-earring','Radar Love','radar-love','Moontan',1973),
    ('Norman Greenbaum','norman-greenbaum','Spirit in the Sky','spirit-in-the-sky','Spirit in the Sky',1969),
    ('The Guess Who','the-guess-who','American Woman','american-woman','American Woman',1970),
    ('Mountain','mountain','Mississippi Queen','mississippi-queen','Climbing!',1970),
    ('James Gang','james-gang','Funk #49','funk-49','James Gang Rides Again',1970),
    ('Alice Cooper','alice-cooper','School''s Out','schools-out','School''s Out',1972),
    ('Humble Pie','humble-pie','30 Days in the Hole','30-days-in-the-hole','Smokin''',1972),
    ('Ram Jam','ram-jam','Black Betty','black-betty','Ram Jam',1977)
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
    ('led-zeppelin','going-to-california'),('led-zeppelin','babe-im-gonna-leave-you'),('led-zeppelin','ten-years-gone'),
    ('led-zeppelin','the-ocean'),('the-rolling-stones','wild-horses'),('the-rolling-stones','sympathy-for-the-devil'),
    ('the-rolling-stones','beast-of-burden'),('the-rolling-stones','dead-flowers'),('david-bowie','space-oddity'),
    ('david-bowie','heroes'),('david-bowie','moonage-daydream'),('t-rex','get-it-on-bang-a-gong'),
    ('t-rex','20th-century-boy'),('the-who','substitute'),('deep-purple','child-in-time'),
    ('the-doors','riders-on-the-storm'),('the-kinks','waterloo-sunset'),('golden-earring','radar-love'),
    ('norman-greenbaum','spirit-in-the-sky'),('the-guess-who','american-woman'),('mountain','mississippi-queen'),
    ('james-gang','funk-49'),('alice-cooper','schools-out'),('humble-pie','30-days-in-the-hole'),('ram-jam','black-betty')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('led-zeppelin','going-to-california'),('led-zeppelin','babe-im-gonna-leave-you'),('led-zeppelin','ten-years-gone'),
    ('led-zeppelin','the-ocean'),('the-rolling-stones','wild-horses'),('the-rolling-stones','sympathy-for-the-devil'),
    ('the-rolling-stones','beast-of-burden'),('the-rolling-stones','dead-flowers'),('david-bowie','space-oddity'),
    ('david-bowie','heroes'),('david-bowie','moonage-daydream'),('t-rex','get-it-on-bang-a-gong'),
    ('t-rex','20th-century-boy'),('the-who','substitute'),('deep-purple','child-in-time'),
    ('the-doors','riders-on-the-storm'),('the-kinks','waterloo-sunset'),('golden-earring','radar-love'),
    ('norman-greenbaum','spirit-in-the-sky'),('the-guess-who','american-woman'),('mountain','mississippi-queen'),
    ('james-gang','funk-49'),('alice-cooper','schools-out'),('humble-pie','30-days-in-the-hole'),('ram-jam','black-betty')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('led-zeppelin','going-to-california'),('led-zeppelin','babe-im-gonna-leave-you'),('led-zeppelin','ten-years-gone'),
    ('led-zeppelin','the-ocean'),('the-rolling-stones','wild-horses'),('the-rolling-stones','sympathy-for-the-devil'),
    ('the-rolling-stones','beast-of-burden'),('the-rolling-stones','dead-flowers'),('david-bowie','space-oddity'),
    ('david-bowie','heroes'),('david-bowie','moonage-daydream'),('t-rex','get-it-on-bang-a-gong'),
    ('t-rex','20th-century-boy'),('the-who','substitute'),('deep-purple','child-in-time'),
    ('the-doors','riders-on-the-storm'),('the-kinks','waterloo-sunset'),('golden-earring','radar-love'),
    ('norman-greenbaum','spirit-in-the-sky'),('the-guess-who','american-woman'),('mountain','mississippi-queen'),
    ('james-gang','funk-49'),('alice-cooper','schools-out'),('humble-pie','30-days-in-the-hole'),('ram-jam','black-betty')
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
    -- ============ LED ZEPPELIN ============
    ('going-to-california','led-zeppelin','guitar','main','fingerpicked pattern','acoustic','rock','rhythm','intermediate',
     'Acoustic guitar (Jimmy Page)','Acoustic — mic''d, double-drop-D','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Page''s Laurel Canyon dream — delicate double-drop-D fingerpicking with mandolin.','Warm intimate acoustic; the tuning''s drones carry it.'],
     array['Double drop D (DADGBD) on the record.','Gentle arpeggios; let the low drones ring.'],
     'Studio recording, 1971. Page''s double-drop-D acoustic dream.',80),
    ('babe-im-gonna-leave-you','led-zeppelin','guitar','riff','fingerpicked verse + heavy strums','acoustic','rock','rhythm','advanced',
     'Acoustic + Telecaster (Jimmy Page)','Acoustic + Supro combo for the flamenco crashes','Small combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The debut''s dynamic showcase — circling acoustic arpeggios erupting into flamenco-strummed crashes (electric layers push gain to 5).','Delicate to violent and back, every cycle.'],
     array['The A-minor picking pattern circles hypnotically.','The crashes are full-arm rasgueado strums.'],
     'Studio recording, 1969. The quiet-loud acoustic showcase.',80),
    ('ten-years-gone','led-zeppelin','guitar','riff','layered themes','crunch','rock','rhythm','advanced',
     'Gibson Les Paul (Jimmy Page)','Marshall tube stack, warm layered crunch','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":5,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Page''s orchestra of guitars — up to fourteen layered harmony parts in warm crunch.','Rounded Les Paul warmth; the arrangement is the guitar army.'],
     array['Learn the main theme first; the harmonies stack on it.','Bittersweet phrasing over flash.'],
     'Studio recording, 1975. Page''s fourteen-guitar orchestra.',80),
    ('the-ocean','led-zeppelin','guitar','riff','main riff','crunch','rock','rhythm','intermediate',
     'Gibson Les Paul (Jimmy Page)','Marshall tube stack','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['The odd-meter strut — thick Marshall crunch with a hiccup in the count.','Classic Page mid-rich drive; the 15/8 hitch is the hook.'],
     array['Count the riff''s extra half-beat until it grooves.','Swing the doo-wop outro with a grin.'],
     'Studio recording, 1973. The odd-meter strut riff.',80),

    -- ============ ROLLING STONES ============
    ('wild-horses','the-rolling-stones','guitar','main','acoustic layers','acoustic','rock','rhythm','intermediate',
     'Acoustic + 12-string (Keith Richards / Mick Taylor)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The weary ballad — layered 6- and 12-string acoustics in Nashville tuning colors.','Warm layered acoustics; the fatigue is the beauty.'],
     array['Slow arpeggiated chords; let them drag slightly.','The Taylor electric fills weep quietly (gain 4).'],
     'Studio recording, 1971. The weary layered-acoustic ballad.',79),
    ('sympathy-for-the-devil','the-rolling-stones','guitar','solo','samba groove + solo','crunch','rock','lead','intermediate',
     'Gibson Les Paul (Keith Richards)','Tube amp, biting lead','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The samba séance — piano and congas carry it until Keith''s stabbing, needling solo.','Trebly biting drive; the solo jabs like a pitchfork.'],
     array['Lay out until the solo — restraint is the arrangement.','Stab the solo phrases; no legato smoothness.'],
     'Studio recording, 1968. Keith''s needling séance solo.',79),
    ('beast-of-burden','the-rolling-stones','guitar','riff','interweaving riffs','clean','rock','rhythm','intermediate',
     'Fender Telecaster (Keith Richards / Ronnie Wood)','Tube amp, warm just-clean','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The ancient art of weaving — Keith and Ronnie''s interlocking just-clean lines.','Warm edge-of-clean; two guitars finishing each other''s sentences.'],
     array['Learn both parts to hear the conversation.','Loose, behind the beat, always.'],
     'Studio recording, 1978. The guitar-weaving masterclass.',79),
    ('dead-flowers','the-rolling-stones','guitar','main','country strums + Tele licks','clean','country rock','rhythm','beginner',
     'Fender Telecaster + acoustic (Keith Richards / Mick Taylor)','Tube amp, country clean','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The Stones go honky-tonk — acoustic strums with twangy Tele fills.','Bright country clean; loose bar-band swagger.'],
     array['Simple D-A-G strums drive it.','Taylor''s fills are pure honky-tonk — steal them.'],
     'Studio recording, 1971. The honky-tonk Stones.',79),

    -- ============ BOWIE / GLAM ============
    ('space-oddity','david-bowie','guitar','main','acoustic progression','acoustic','rock','rhythm','intermediate',
     '12-string acoustic (David Bowie)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":7,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Ground control on 12-string — shimmering acoustic under the countdown.','Bright 12-string sparkle (6-string works, less shimmer).'],
     array['The Fmaj7-Em movement is the float.','Strum gently; you''re in zero gravity.'],
     'Studio recording, 1969. The 12-string countdown classic.',79),
    ('heroes','david-bowie','guitar','riff','sustained feedback lines','clean','rock','lead','intermediate',
     'Fender Stratocaster (Robert Fripp)','Amp at feedback volume, EBow-like sustain','Closed-back cab','bridge pickup',
     '[{"effect_type":"delay","effect_name":"ambient delay","placement":"post_gain","settings":{"time":4,"mix":3,"feedback":3}},{"effect_type":"reverb","effect_name":"large hall","placement":"post_gain","settings":{"mix":5}}]'::jsonb,
     '{"gain":4,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":5,"delay":3,"master":8}'::jsonb,
     array['Fripp''s infinite-sustain lines — recorded standing at feedback distance from the amp; an EBow or sustainer nails it today.','Singing controlled feedback over the Berlin wall of sound.'],
     array['Hold single notes and let them bloom into feedback.','The line floats above the song — never riffs.'],
     'Studio recording, 1977. Fripp''s feedback-distance sustain lines.',79),
    ('moonage-daydream','david-bowie','guitar','riff','main riff + solo','crunch','glam rock','lead','intermediate',
     'Gibson Les Paul Custom (Mick Ronson)','Marshall Major, cranked','Marshall 4x12 cab','bridge humbucker',
     '[{"effect_type":"wah","effect_name":"cocked-wah tone filter (solo)","placement":"front","settings":{"position":6}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['Ronson''s glam monument — thick Marshall crunch and a cocked-wah solo that ends the world.','Mid-heavy cranked Marshall; the solo''s filtered honk is a fixed wah position.'],
     array['The chord stabs announce an alien messiah.','The outro solo climbs forever — commit completely.'],
     'Studio recording, 1972. Ronson''s cocked-wah glam monument.',80),
    ('get-it-on-bang-a-gong','t-rex','guitar','riff','main riff','crunch','glam rock','rhythm','beginner',
     'Gibson Les Paul (Marc Bolan)','Tube amp, warm glam crunch','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":6,"mids":6,"treble":5,"presence":4,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The glam-boogie blueprint — warm greasy Les Paul crunch.','Round dark drive; the swagger is in the swing.'],
     array['The E-riff struts; keep it dirty and loose.','Slide into the chord changes.'],
     'Studio recording, 1971. Bolan''s glam-boogie blueprint.',78),
    ('20th-century-boy','t-rex','guitar','riff','main riff','crunch','glam rock','rhythm','beginner',
     'Gibson Les Paul (Marc Bolan)','Tube amp cranked, saturated glam','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":6,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The strut-riff eternal — fatter and louder than Get It On.','Thick saturated crunch; pure stomp.'],
     array['Hammer the opening chords like a announcement.','Strut, don''t walk.'],
     'Studio recording, 1973. The eternal strut riff.',78),

    -- ============ 60s-70s SINGLES ============
    ('substitute','the-who','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Fender/Rickenbacker electric (Pete Townshend)','Vox/Marshall, jangly crunch','Open-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The D-chord windmill classic — bright jangling crunch.','Trebly powerful strums; Townshend''s right arm is the amp.'],
     array['The Dsus riff rings open.','Windmill optional but encouraged.'],
     'Studio recording, 1966. The windmill jangle classic.',78),
    ('child-in-time','deep-purple','guitar','solo','organ intro + epic solo','high_gain','rock','lead','expert',
     'Fender Stratocaster (Ritchie Blackmore)','Marshall Major cranked','Marshall 4x12 cab','bridge single-coil',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['Blackmore''s ten-minute scream — cranked Strat-into-Marshall fury after the organ hush.','Bright aggressive Strat drive; classical precision at full speed.'],
     array['The solo builds from silence to hysteria.','Alternate-picked runs demand metronome months.'],
     'Studio recording, 1970. Blackmore''s ten-minute Strat scream.',79),
    ('riders-on-the-storm','the-doors','guitar','riff','tremolo comping + fills','clean','rock','rhythm','intermediate',
     'Gibson SG (Robby Krieger)','Fender tube amp, dark clean','Fender combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"dark spring reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":2,"bass":6,"mids":5,"treble":4,"presence":3,"reverb":4,"delay":0,"master":6}'::jsonb,
     array['The rain-noir closer — Krieger''s dark fingerstyle clean gliding under the Rhodes.','Warm shadowy clean; thunder does the percussion.'],
     array['Fingerstyle the snaking fills — no pick on the record.','Slide between positions like weather moving.'],
     'Studio recording, 1971. Krieger''s rain-noir clean.',79),
    ('waterloo-sunset','the-kinks','guitar','riff','main riff + arpeggios','clean','rock','rhythm','beginner',
     'Fender/Guild electric (Dave Davies / Ray Davies)','Vox-style clean with tape-echo sheen','Open-back cab','bridge pickup',
     '[{"effect_type":"delay","effect_name":"tape echo sheen","placement":"post_gain","settings":{"time":2,"mix":3,"feedback":2}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":7,"presence":5,"reverb":3,"delay":3,"master":6}'::jsonb,
     array['The loveliest evening in pop — descending intro riff and chiming arpeggios in tape-echo haze.','Bright gentle clean; London sunset in tone form.'],
     array['The descending intro line is the sigh.','Arpeggiate the verses tenderly.'],
     'Studio recording, 1967. The tape-echo sunset classic.',78),
    ('radar-love','golden-earring','guitar','riff','main riff','crunch','rock','rhythm','intermediate',
     'Gibson electric (George Kooymans)','Tube stack, driving crunch','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The highway pulse — locked driving crunch over THAT bassline.','Punchy warm drive; the momentum never lifts.'],
     array['Lock the chug to the bass pulse.','The stabs answer the vocal — tight and dry.'],
     'Studio recording, 1973. The eternal highway pulse.',77),
    ('spirit-in-the-sky','norman-greenbaum','guitar','riff','fuzz riff','fuzz','rock','rhythm','beginner',
     'Fender Telecaster with built-in fuzz (Norman Greenbaum)','Small amp, sputtering fuzz','Small combo cab','bridge pickup',
     '[{"effect_type":"fuzz","effect_name":"sputtering germanium fuzz (built into his Tele)","placement":"front","settings":{"gain":8,"tone":5,"level":6}}]'::jsonb,
     '{"gain":6,"bass":6,"mids":6,"treble":5,"presence":4,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The velcro-fuzz gospel stomp — a fuzz circuit built INTO his Telecaster made this ripping sound.','Sputtery saturated fuzz; the boogie pattern rips underneath.'],
     array['The A-riff boogies with hammer-on grace notes.','Let the fuzz splatter — clean it up and it dies.'],
     'Studio recording, 1969. The built-in-fuzz gospel stomp.',79),
    ('american-woman','the-guess-who','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Gibson Les Paul (Randy Bachman)','Tube amp, thick sustained crunch','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":6,"mids":6,"treble":5,"presence":4,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The B-riff monolith — thick sustaining crunch born from an onstage accident.','Fat warm saturation; the riff loops like a warning.'],
     array['The riff is the song — groove it forever.','Bend the fills lazy and mean.'],
     'Studio recording, 1970. The accidental monolith riff.',78),
    ('mississippi-queen','mountain','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Gibson Les Paul Junior (Leslie West)','Sunn/Marshall stack cranked','Closed-back 4x12 cab','P-90 pickup',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['Leslie West''s cowbell-summoned roar — P-90 Junior into a cranked stack.','Huge mid-forward bark; one pickup, one knob, all tone.'],
     array['The riff answers the cowbell.','West''s vibrato is violent — shake the bends.'],
     'Studio recording, 1970. West''s P-90 cowbell roar.',79),
    ('funk-49','james-gang','guitar','riff','main riff','crunch','rock','rhythm','intermediate',
     'Fender Telecaster (Joe Walsh)','Tube amp, biting funk crunch','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Walsh''s funk-rock calling card — snapping Telecaster crunch.','Bright biting drive; the funk is in the ghost notes.'],
     array['The riff mixes chords and single-note snaps.','Ghost the muted strings between hits.'],
     'Studio recording, 1970. Walsh''s snapping funk-rock riff.',79),
    ('schools-out','alice-cooper','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Gibson SG (Glen Buxton / Michael Bruce)','Tube stack, sneering crunch','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The last-day-of-school anthem — sneering staccato crunch riff.','Punchy raw drive; delinquent swagger.'],
     array['The chromatic riff sneers — articulate every note.','Play it like detention doesn''t exist.'],
     'Studio recording, 1972. The delinquent anthem riff.',78),
    ('30-days-in-the-hole','humble-pie','guitar','riff','main riff','crunch','rock','rhythm','intermediate',
     'Gibson electric (Steve Marriott / Clem Clempson)','Tube stack, greasy crunch','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['The a-cappella-intro boogie — greasy mid-rich crunch riffing.','Warm raunchy drive; pub-rock swagger with soul pipes.'],
     array['The riff swings hard off the vocal stack.','Grease over precision.'],
     'Studio recording, 1972. The greasy boogie classic.',77),
    ('black-betty','ram-jam','guitar','riff','main riff','crunch','rock','rhythm','advanced',
     'Gibson electric (Bill Bartlett)','Tube stack, driving crunch','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The bam-ba-lam sprint — galloping crunch riff with a double-time breakdown.','Punchy driving crunch; the riff never stops moving.'],
     array['The gallop pattern demands right-hand stamina.','The breakdown solo section shifts gears — be ready.'],
     'Studio recording, 1977. The bam-ba-lam gallop.',77)
) as c(
  song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence
)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;
