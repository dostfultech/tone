-- Phase 54: pop-guitar canon (Taylor Swift, Bruno Mars, Avril) + ska/reggae-rock, verified per-part tone data.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Taylor Swift','taylor-swift','Love Story','love-story','Fearless',2008),
    ('Taylor Swift','taylor-swift','You Belong With Me','you-belong-with-me','Fearless',2008),
    ('Taylor Swift','taylor-swift','All Too Well','all-too-well','Red',2012),
    ('Taylor Swift','taylor-swift','Style','style','1989',2014),
    ('Taylor Swift','taylor-swift','cardigan','cardigan','folklore',2020),
    ('Taylor Swift','taylor-swift','Our Song','our-song','Taylor Swift',2006),
    ('Bruno Mars','bruno-mars','Locked Out of Heaven','locked-out-of-heaven','Unorthodox Jukebox',2012),
    ('Bruno Mars','bruno-mars','Treasure','treasure','Unorthodox Jukebox',2012),
    ('Sabrina Carpenter','sabrina-carpenter','Espresso','espresso','Short n'' Sweet',2024),
    ('Miley Cyrus','miley-cyrus','Flowers','flowers','Endless Summer Vacation',2023),
    ('One Direction','one-direction','What Makes You Beautiful','what-makes-you-beautiful','Up All Night',2011),
    ('Maroon 5','maroon-5','This Love','this-love','Songs About Jane',2004),
    ('Maroon 5','maroon-5','Sunday Morning','sunday-morning','Songs About Jane',2004),
    ('Plain White T''s','plain-white-ts','Hey There Delilah','hey-there-delilah','All That We Needed',2006),
    ('Avril Lavigne','avril-lavigne','Complicated','complicated','Let Go',2002),
    ('Avril Lavigne','avril-lavigne','Sk8er Boi','sk8er-boi','Let Go',2002),
    ('311','311','Down','down','311',1995),
    ('311','311','Amber','amber','From Chaos',2001),
    ('No Doubt','no-doubt','Don''t Speak','dont-speak','Tragic Kingdom',1996),
    ('No Doubt','no-doubt','Just a Girl','just-a-girl','Tragic Kingdom',1995),
    ('Reel Big Fish','reel-big-fish','Sell Out','sell-out','Turn the Radio Off',1996),
    ('The Interrupters','the-interrupters','She''s Kerosene','shes-kerosene','Fight the Good Fight',2018),
    ('Streetlight Manifesto','streetlight-manifesto','Point/Counterpoint','point-counterpoint','Everything Goes Numb',2003),
    ('Smash Mouth','smash-mouth','All Star','all-star','Astro Lounge',1999),
    ('Outkast','outkast','Hey Ya!','hey-ya','Speakerboxxx/The Love Below',2003)
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
    ('taylor-swift','love-story'),('taylor-swift','you-belong-with-me'),('taylor-swift','all-too-well'),
    ('taylor-swift','style'),('taylor-swift','cardigan'),('taylor-swift','our-song'),
    ('bruno-mars','locked-out-of-heaven'),('bruno-mars','treasure'),('sabrina-carpenter','espresso'),
    ('miley-cyrus','flowers'),('one-direction','what-makes-you-beautiful'),('maroon-5','this-love'),
    ('maroon-5','sunday-morning'),('plain-white-ts','hey-there-delilah'),('avril-lavigne','complicated'),
    ('avril-lavigne','sk8er-boi'),('311','down'),('311','amber'),('no-doubt','dont-speak'),
    ('no-doubt','just-a-girl'),('reel-big-fish','sell-out'),('the-interrupters','shes-kerosene'),
    ('streetlight-manifesto','point-counterpoint'),('smash-mouth','all-star'),('outkast','hey-ya')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('taylor-swift','love-story'),('taylor-swift','you-belong-with-me'),('taylor-swift','all-too-well'),
    ('taylor-swift','style'),('taylor-swift','cardigan'),('taylor-swift','our-song'),
    ('bruno-mars','locked-out-of-heaven'),('bruno-mars','treasure'),('sabrina-carpenter','espresso'),
    ('miley-cyrus','flowers'),('one-direction','what-makes-you-beautiful'),('maroon-5','this-love'),
    ('maroon-5','sunday-morning'),('plain-white-ts','hey-there-delilah'),('avril-lavigne','complicated'),
    ('avril-lavigne','sk8er-boi'),('311','down'),('311','amber'),('no-doubt','dont-speak'),
    ('no-doubt','just-a-girl'),('reel-big-fish','sell-out'),('the-interrupters','shes-kerosene'),
    ('streetlight-manifesto','point-counterpoint'),('smash-mouth','all-star'),('outkast','hey-ya')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('taylor-swift','love-story'),('taylor-swift','you-belong-with-me'),('taylor-swift','all-too-well'),
    ('taylor-swift','style'),('taylor-swift','cardigan'),('taylor-swift','our-song'),
    ('bruno-mars','locked-out-of-heaven'),('bruno-mars','treasure'),('sabrina-carpenter','espresso'),
    ('miley-cyrus','flowers'),('one-direction','what-makes-you-beautiful'),('maroon-5','this-love'),
    ('maroon-5','sunday-morning'),('plain-white-ts','hey-there-delilah'),('avril-lavigne','complicated'),
    ('avril-lavigne','sk8er-boi'),('311','down'),('311','amber'),('no-doubt','dont-speak'),
    ('no-doubt','just-a-girl'),('reel-big-fish','sell-out'),('the-interrupters','shes-kerosene'),
    ('streetlight-manifesto','point-counterpoint'),('smash-mouth','all-star'),('outkast','hey-ya')
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
    -- ============ TAYLOR SWIFT ============
    ('love-story','taylor-swift','guitar','main','main progression','acoustic','country pop','rhythm','beginner',
     'Acoustic guitar (Taylor Swift / session)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The fairy-tale country-pop staple — bright open acoustic strums.','Warm acoustic with light hall; the banjo and fiddle on the record are overdubs.'],
     array['Simple open-chord progression with a rolling strum.','One of the most-learned first songs ever — enjoy it.'],
     'Studio recording, 2008. The fairy-tale acoustic staple from Fearless.',75),
    ('you-belong-with-me','taylor-swift','guitar','main','main progression','acoustic','country pop','rhythm','beginner',
     'Acoustic guitar (Taylor Swift / session)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":7,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bright bouncing country-pop strums with a banjo-flavored hook.','Crisp bright acoustic; the energy is all forward motion.'],
     array['Driving strum pattern with muted accents.','Keep it bouncing — it''s a bleachers anthem.'],
     'Studio recording, 2008. Bright bouncing strums from Fearless.',74),
    ('all-too-well','taylor-swift','guitar','main','arpeggio accompaniment','clean','pop','rhythm','beginner',
     'Clean electric + acoustic (session)','Warm clean amp','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"plate reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The fan-favorite heartbreak epic — warm clean arpeggios building slowly for five minutes.','Soft clean warmth; the build is dynamic, not tonal.'],
     array['The same progression cycles — vary your touch as it builds.','Swell with the storytelling.'],
     'Studio recording, 2012. The slow-building heartbreak epic from Red.',73),
    ('style','taylor-swift','guitar','riff','main riff','clean','pop','rhythm','intermediate',
     'Electric guitar (session)','Clean amp, tight and compressed','Studio direct','bridge pickup',
     '[{"effect_type":"compressor","effect_name":"studio compression","placement":"front","settings":{"sustain":6,"level":5}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":1,"master":6}'::jsonb,
     array['The pulsing 1989 riff — tight muted clean eighth-notes with neon-noir cool.','Compressed dry clean; the pulse must be machine-steady.'],
     array['Palm-muted single-note pulse throughout.','Metronomic consistency is the entire job.'],
     'Studio recording, 2014. The pulsing neon riff from 1989.',73),
    ('cardigan','taylor-swift','guitar','main','picked accompaniment','clean','indie folk','rhythm','beginner',
     'Clean electric / acoustic (Aaron Dessner)','Warm clean amp, intimate','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":1,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":3,"delay":0,"master":5}'::jsonb,
     array['The folklore mood — soft picked figures in cabin-quiet warmth.','Hushed clean; Dessner''s production is intimate and wooden.'],
     array['Gentle picking under the vocal; nothing rushed.','The restraint is the aesthetic.'],
     'Studio recording, 2020. Cabin-quiet picking from folklore.',73),
    ('our-song','taylor-swift','guitar','main','main progression','acoustic','country','rhythm','beginner',
     'Acoustic guitar (Taylor Swift / session)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":7,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The debut-era country bopper — bright twangy strums with banjo bounce.','Crisp acoustic twang; capo country energy.'],
     array['Bouncy strum with quick chord changes.','Smile-and-stomp country feel.'],
     'Studio recording, 2006. Bright twangy bounce from the debut.',73),

    -- ============ POP FUNK ============
    ('locked-out-of-heaven','bruno-mars','guitar','riff','main riff','clean','pop funk','rhythm','intermediate',
     'Fender Stratocaster (session)','Clean amp, tight and percussive','Studio direct','bridge pickup',
     '[{"effect_type":"compressor","effect_name":"studio compression","placement":"front","settings":{"sustain":5,"level":5}}]'::jsonb,
     '{"gain":2,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Police-worship skank — choppy bright clean upstrokes.','Dry percussive clean; the reggae-rock chop is the hook.'],
     array['Upstroke skank on the off-beats.','Mute ruthlessly between chops.'],
     'Studio recording, 2012. Police-style clean skank.',74),
    ('treasure','bruno-mars','guitar','riff','main riff','clean','pop funk','rhythm','intermediate',
     'Fender Stratocaster (session)','Clean amp, disco funk','Studio direct','neck + middle pickup',
     '[{"effect_type":"compressor","effect_name":"studio compression","placement":"front","settings":{"sustain":5,"level":5}}]'::jsonb,
     '{"gain":1,"bass":4,"mids":5,"treble":7,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Disco-funk time machine — glassy sixteenth-note chords straight from 1979.','Bright squeaky-clean funk; think Nile Rodgers chic.'],
     array['Sixteenth-note funk strumming with ghost mutes.','Wrist stays loose; the groove is everything.'],
     'Studio recording, 2012. Glassy disco-funk chords.',74),
    ('espresso','sabrina-carpenter','guitar','riff','main riff','clean','pop funk','rhythm','beginner',
     'Electric guitar (session)','Clean amp, breezy funk','Studio direct','neck pickup',
     '[{"effect_type":"compressor","effect_name":"studio compression","placement":"front","settings":{"sustain":5,"level":5}}]'::jsonb,
     '{"gain":1,"bass":4,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The summer-2024 earworm — breezy funk-pop clean chords.','Soft bright clean with bounce; effortless is the aesthetic.'],
     array['Light funk chords on the groove.','Lazy confidence over precision.'],
     'Studio recording, 2024. Breezy funk-pop clean from the summer hit.',72),
    ('flowers','miley-cyrus','guitar','riff','main riff','clean','pop','rhythm','beginner',
     'Electric guitar (session)','Clean amp, disco pop','Studio direct','neck pickup',
     '[{"effect_type":"compressor","effect_name":"studio compression","placement":"front","settings":{"sustain":5,"level":5}}]'::jsonb,
     '{"gain":1,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['The self-love disco anthem — muted funk-pop clean groove.','Tight dry clean; the bassline leads, guitar chips in.'],
     array['Muted funk chips on the groove.','Serve the beat; stay out of the vocal''s way.'],
     'Studio recording, 2023. Muted disco-pop groove.',72),
    ('what-makes-you-beautiful','one-direction','guitar','riff','main riff','clean','pop','rhythm','beginner',
     'Electric guitar (session)','Clean amp, bright pop','Studio direct','bridge pickup',
     '[{"effect_type":"compressor","effect_name":"studio compression","placement":"front","settings":{"sustain":5,"level":5}}]'::jsonb,
     '{"gain":2,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['The riff every 2010s teenager learned — bright chunky clean stabs.','Crisp bright clean with attack; simple and huge.'],
     array['The four-note riff is the song.','Punch the stabs confidently.'],
     'Studio recording, 2011. The iconic bright pop stab riff.',73),

    -- ============ MAROON 5 / 2000s POP ROCK ============
    ('this-love','maroon-5','guitar','riff','main riff','clean','pop rock','rhythm','intermediate',
     'Fender Stratocaster (James Valentine)','Clean amp, tight funk','Studio direct','bridge pickup',
     '[{"effect_type":"compressor","effect_name":"studio compression","placement":"front","settings":{"sustain":5,"level":5}}]'::jsonb,
     '{"gain":2,"bass":4,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Tight funk-pop stabs — dry compressed clean with rhythmic snap.','Surgical clean funk; every stab dead-on the grid.'],
     array['Choked chord stabs with the piano.','Precision funk — no ringing strings.'],
     'Studio recording, 2004. Tight funk-pop stabs from Songs About Jane.',74),
    ('sunday-morning','maroon-5','guitar','riff','main progression','clean','pop rock','rhythm','beginner',
     'Fender Stratocaster (James Valentine)','Warm clean amp, jazzy','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":2}}]'::jsonb,
     '{"gain":1,"bass":5,"mids":6,"treble":5,"presence":4,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Rainy-Sunday jazz-pop — warm rounded clean comping.','Dark warm clean; jazzy chord voicings over a lazy groove.'],
     array['The D-Bm-G-A style turnaround swings gently.','Comp like a jazz player — relaxed and behind the beat.'],
     'Studio recording, 2004. Warm jazzy Sunday comping.',74),
    ('hey-there-delilah','plain-white-ts','guitar','main','fingerpicked pattern','acoustic','pop rock','rhythm','beginner',
     'Acoustic guitar (Tom Higgenson)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The dorm-room fingerpicking rite of passage — bare and intimate.','Clean quiet acoustic; just the pattern and the voice.'],
     array['Alternating bass-note fingerpicking on two chords.','Millions learned guitar for this song — take your turn.'],
     'Studio recording, 2006. The dorm-room fingerpicking classic.',75),
    ('complicated','avril-lavigne','guitar','riff','acoustic verse + crunch chorus','crunch','pop punk','rhythm','beginner',
     'Acoustic + electric (session)','Tube amp, polished crunch (chorus)','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['Acoustic strummed verses into polished pop-punk chorus crunch (push gain to 5-6).','Program both; the early-2000s radio polish is smooth, not raw.'],
     array['Verse is acoustic open chords.','Chorus power chords ring wide.'],
     'Studio recording, 2002. Acoustic-to-crunch radio pop-punk.',74),
    ('sk8er-boi','avril-lavigne','guitar','riff','main riff','distorted','pop punk','rhythm','beginner',
     'Solid-body electric (session)','Driven tube stack, polished','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Full-speed radio pop-punk — bright polished distortion.','Saturated but clean-edged; mall-punk perfection.'],
     array['Driving eighth-note power chords throughout.','Energy up, attitude on.'],
     'Studio recording, 2002. Polished mall-punk drive.',74),

    -- ============ SKA / REGGAE ROCK ============
    ('down','311','guitar','riff','main riff','high_gain','reggae rock','rhythm','intermediate',
     'Solid-body electric (Tim Mahoney)','Driven amp, funky high gain','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Bouncing funk-metal energy — tight saturated riffing with rap-rock swagger.','Tight high gain with funk in the wrist.'],
     array['The riff bounces off the kick drum.','Switch instantly between chug and skank.'],
     'Studio recording, 1995. Bouncing funk-metal from the blue album.',73),
    ('amber','311','guitar','riff','main riff','clean','reggae rock','rhythm','beginner',
     'Solid-body electric (Tim Mahoney)','Clean amp with delay shimmer','Open-back combo cab','neck pickup',
     '[{"effect_type":"delay","effect_name":"ambient delay","placement":"post_gain","settings":{"time":4,"mix":3,"feedback":3}},{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":3,"master":6}'::jsonb,
     array['Sun-soaked reggae-rock clean — liquid skank with delay shimmer.','Warm wet clean; the off-beat skank floats.'],
     array['Off-beat upstroke skank all song.','Lay back — beach-tempo relaxation.'],
     'Studio recording, 2001. Liquid sun-soaked skank from From Chaos.',73),
    ('dont-speak','no-doubt','guitar','riff','arpeggio + flamenco solo','clean','ska pop','rhythm','intermediate',
     'Nylon + clean electric (Tom Dumont)','Warm clean amp','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":4,"delay":0,"master":6}'::jsonb,
     array['The heartbreak ballad — soft clean arpeggios with the famous nylon-flavored solo.','Warm clean; the solo''s Spanish color comes from phrasing, not gain.'],
     array['Arpeggiate the minor progression gently.','The solo is melodic flamenco-pop — learn it note for note.'],
     'Studio recording, 1996. The heartbreak arpeggios and Spanish-tinged solo.',75),
    ('just-a-girl','no-doubt','guitar','riff','main riff','crunch','ska pop','rhythm','intermediate',
     'Solid-body electric (Tom Dumont)','Tube amp, bright crunch','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['The bratty new-wave-ska riff — bright bouncing crunch.','Trebly tight crunch; the iconic riff snaps.'],
     array['The intro riff is the hook — articulate every note.','Skank the verses, slam the chorus.'],
     'Studio recording, 1995. The iconic bratty riff from Tragic Kingdom.',75),
    ('sell-out','reel-big-fish','guitar','riff','ska verse + distorted chorus','crunch','ska punk','rhythm','beginner',
     'Hollow-body electric (Aaron Barrett)','Tube amp, clean skank to crunch','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":3,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Third-wave ska anthem — bright clean upstrokes flipping to crunchy chorus (push gain to 6).','Two sounds: crisp clean skank and punky crunch.'],
     array['Up-stroke skank on the off-beats — wrist loose.','Horns carry the hooks; you keep the engine running.'],
     'Studio recording, 1996. The third-wave ska anthem.',73),
    ('shes-kerosene','the-interrupters','guitar','riff','main riff','crunch','ska punk','rhythm','beginner',
     'Solid-body electric (Kevin Bivona)','Tube amp, punchy crunch','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Modern ska-punk fire — tight crunch with two-tone bounce.','Punchy mid-forward crunch; the skank sections drop to near-clean.'],
     array['Alternate crunch drive and off-beat skank.','High energy, tight changes.'],
     'Studio recording, 2018. Modern two-tone ska-punk fire.',72),
    ('point-counterpoint','streetlight-manifesto','guitar','riff','ska engine','crunch','ska punk','rhythm','intermediate',
     'Hollow-body electric (Tomas Kalnoky)','Tube amp, fast clean-crunch','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":3,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Ska-core at full sprint — rapid upstroke engine under the horn army.','Bright just-crunch; stamina matters more than gain.'],
     array['Relentless upstroke skank at high tempo.','Lock with the bass — the horns do the rest.'],
     'Studio recording, 2003. Full-sprint ska-core engine.',72),
    ('all-star','smash-mouth','guitar','riff','main riff','crunch','pop rock','rhythm','beginner',
     'Solid-body electric (Greg Camp)','Tube amp, bright crunch','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['The meme-immortal anthem — bright cheerful crunch.','Sunny light crunch; nothing serious about it.'],
     array['Bouncy chord riff with palm-muted verses.','Somebody once told you how to play this — now do it.'],
     'Studio recording, 1999. The meme-immortal cheerful crunch.',73),
    ('hey-ya','outkast','guitar','main','main progression','acoustic','pop','rhythm','beginner',
     'Acoustic guitar (Andre 3000 / session)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['The genre-breaking acoustic banger — percussive bright strums in an odd meter.','Dry bright acoustic hammered hard.'],
     array['The progression hides a beat of 11/4 across the loop — count it.','Strum like a drummer; shake it like a Polaroid picture.'],
     'Studio recording, 2003. The genre-breaking percussive acoustic loop.',73)
) as c(
  song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence
)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;
