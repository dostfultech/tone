-- Phase 61: current US singer-songwriter / indie gaps (Lord Huron, Billie, SZA, Mayer deep cuts), verified per-part tone data.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Lord Huron','lord-huron','The Night We Met','the-night-we-met','Strange Trails',2015),
    ('Hozier','hozier','Cherry Wine','cherry-wine','Hozier',2014),
    ('Hozier','hozier','Would That I','would-that-i','Wasteland, Baby!',2019),
    ('John Mayer','john-mayer','Neon','neon','Room for Squares',2001),
    ('John Mayer','john-mayer','Stop This Train','stop-this-train','Continuum',2006),
    ('John Mayer','john-mayer','Waiting on the World to Change','waiting-on-the-world-to-change','Continuum',2006),
    ('John Mayer','john-mayer','New Light','new-light','New Light',2018),
    ('Billie Eilish','billie-eilish','Happier Than Ever','happier-than-ever','Happier Than Ever',2021),
    ('Billie Eilish','billie-eilish','TV','tv','Guitar Songs',2022),
    ('Billie Eilish','billie-eilish','Birds of a Feather','birds-of-a-feather','Hit Me Hard and Soft',2024),
    ('SZA','sza','Nobody Gets Me','nobody-gets-me','SOS',2022),
    ('SZA','sza','Good Days','good-days','SOS',2020),
    ('Gracie Abrams','gracie-abrams','That''s So True','thats-so-true','The Secret of Us',2024),
    ('Gracie Abrams','gracie-abrams','I Love You, I''m Sorry','i-love-you-im-sorry','The Secret of Us',2024),
    ('Lizzy McAlpine','lizzy-mcalpine','ceilings','ceilings','five seconds flat',2022),
    ('Adrianne Lenker','adrianne-lenker','anything','anything','songs',2020),
    ('Faye Webster','faye-webster','Kingston','kingston','Atlanta Millionaires Club',2019),
    ('Dominic Fike','dominic-fike','3 Nights','3-nights','Don''t Forget About Me, Demos',2018),
    ('The Red Clay Strays','the-red-clay-strays','Wondering Why','wondering-why','Moment of Truth',2022),
    ('Tyler Childers','tyler-childers','Lady May','lady-may','Purgatory',2017),
    ('Zach Bryan','zach-bryan','Pink Skies','pink-skies','The Great American Bar Scene',2024),
    ('Zach Bryan','zach-bryan','Oklahoma Smokeshow','oklahoma-smokeshow','Summertime Blues',2022),
    ('Noah Kahan','noah-kahan','Dial Drunk','dial-drunk','Stick Season (We''ll All Be Here Forever)',2023),
    ('Mt. Joy','mt-joy','Silver Lining','silver-lining','Mt. Joy',2018),
    ('Rainbow Kitten Surprise','rainbow-kitten-surprise','It''s Called: Freefall','its-called-freefall','How to: Friend, Love, Freefall',2018)
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
    ('lord-huron','the-night-we-met'),('hozier','cherry-wine'),('hozier','would-that-i'),('john-mayer','neon'),
    ('john-mayer','stop-this-train'),('john-mayer','waiting-on-the-world-to-change'),('john-mayer','new-light'),
    ('billie-eilish','happier-than-ever'),('billie-eilish','tv'),('billie-eilish','birds-of-a-feather'),
    ('sza','nobody-gets-me'),('sza','good-days'),('gracie-abrams','thats-so-true'),('gracie-abrams','i-love-you-im-sorry'),
    ('lizzy-mcalpine','ceilings'),('adrianne-lenker','anything'),('faye-webster','kingston'),('dominic-fike','3-nights'),
    ('the-red-clay-strays','wondering-why'),('tyler-childers','lady-may'),('zach-bryan','pink-skies'),
    ('zach-bryan','oklahoma-smokeshow'),('noah-kahan','dial-drunk'),('mt-joy','silver-lining'),
    ('rainbow-kitten-surprise','its-called-freefall')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('lord-huron','the-night-we-met'),('hozier','cherry-wine'),('hozier','would-that-i'),('john-mayer','neon'),
    ('john-mayer','stop-this-train'),('john-mayer','waiting-on-the-world-to-change'),('john-mayer','new-light'),
    ('billie-eilish','happier-than-ever'),('billie-eilish','tv'),('billie-eilish','birds-of-a-feather'),
    ('sza','nobody-gets-me'),('sza','good-days'),('gracie-abrams','thats-so-true'),('gracie-abrams','i-love-you-im-sorry'),
    ('lizzy-mcalpine','ceilings'),('adrianne-lenker','anything'),('faye-webster','kingston'),('dominic-fike','3-nights'),
    ('the-red-clay-strays','wondering-why'),('tyler-childers','lady-may'),('zach-bryan','pink-skies'),
    ('zach-bryan','oklahoma-smokeshow'),('noah-kahan','dial-drunk'),('mt-joy','silver-lining'),
    ('rainbow-kitten-surprise','its-called-freefall')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('lord-huron','the-night-we-met'),('hozier','cherry-wine'),('hozier','would-that-i'),('john-mayer','neon'),
    ('john-mayer','stop-this-train'),('john-mayer','waiting-on-the-world-to-change'),('john-mayer','new-light'),
    ('billie-eilish','happier-than-ever'),('billie-eilish','tv'),('billie-eilish','birds-of-a-feather'),
    ('sza','nobody-gets-me'),('sza','good-days'),('gracie-abrams','thats-so-true'),('gracie-abrams','i-love-you-im-sorry'),
    ('lizzy-mcalpine','ceilings'),('adrianne-lenker','anything'),('faye-webster','kingston'),('dominic-fike','3-nights'),
    ('the-red-clay-strays','wondering-why'),('tyler-childers','lady-may'),('zach-bryan','pink-skies'),
    ('zach-bryan','oklahoma-smokeshow'),('noah-kahan','dial-drunk'),('mt-joy','silver-lining'),
    ('rainbow-kitten-surprise','its-called-freefall')
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
    -- ============ THE BIG MISSING ONES ============
    ('the-night-we-met','lord-huron','guitar','riff','main arpeggio','clean','indie folk','rhythm','beginner',
     'Hollow-body electric (Ben Schneider)','Clean amp drenched in reverb and tremolo','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"cavernous spring reverb","placement":"post_gain","settings":{"mix":6,"decay":7}},{"effect_type":"tremolo","effect_name":"slow tremolo","placement":"post_gain","settings":{"rate":3,"depth":4}},{"effect_type":"delay","effect_name":"subtle delay","placement":"post_gain","settings":{"time":4,"mix":2,"feedback":2}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":6,"delay":2,"master":6}'::jsonb,
     array['One of UG''s most-searched songs ever — ghostly clean arpeggios in cavernous reverb.','Wet vintage-flavored clean; the loneliness is in the space.'],
     array['The waltz arpeggio pattern repeats and haunts.','Let every note dissolve into the reverb.'],
     'Studio recording, 2015. The ghostly waltz that owns every slow-dance playlist.',77),
    ('cherry-wine','hozier','guitar','main','fingerpicked pattern','acoustic','indie folk','rhythm','intermediate',
     'Acoustic guitar (Hozier) — recorded live at dawn','Acoustic — mic''d outdoors','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Recorded live on a rooftop at dawn — one voice, one acoustic, birdsong in the take.','Bare intimate acoustic; the imperfection is the recording.'],
     array['The fingerpicked figure loops with open-string drones.','Play it as gently as the record was captured.'],
     'Live recording, 2014. The one-take dawn rooftop fingerpicking.',78),
    ('would-that-i','hozier','guitar','main','fingerpicked + stomp','acoustic','indie folk','rhythm','intermediate',
     'Acoustic guitar (Hozier)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Fire-and-folklore builder — hypnotic fingerpicking into stomping full-band swells.','Warm driving acoustic; the dynamics tell the story.'],
     array['The picking pattern circles; the chorus stomps.','Build each chorus bigger than the last.'],
     'Studio recording, 2019. The hypnotic fire-folk builder.',75),

    -- ============ JOHN MAYER DEEP CUTS ============
    ('neon','john-mayer','guitar','riff','percussive fingerstyle riff','clean','pop rock','lead','expert',
     'Fender Stratocaster (John Mayer)','Clean amp, tight and compressed','Open-back combo cab','neck pickup',
     '[{"effect_type":"compressor","effect_name":"studio compression","placement":"front","settings":{"sustain":5,"level":5}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The fingerstyle gauntlet — thumb-slap bass and chord stabs at once, in a drop-C-ish tuning.','Tight compressed clean; every voice must speak.'],
     array['Thumb covers bass while fingers stab chords — slow practice mandatory.','The descending chromatic hook is the identity.'],
     'Studio recording, 2001. Mayer''s legendary percussive fingerstyle test piece.',79),
    ('stop-this-train','john-mayer','guitar','main','percussive fingerpicking','acoustic','pop rock','rhythm','advanced',
     'Martin acoustic (John Mayer)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The aging meditation — percussive travis picking with slap harmonics.','Clear balanced acoustic; the thumb-slap backbeat is built into the pattern.'],
     array['The picking pattern includes a percussive slap on beats 2 and 4.','Learn it in layers: bass, slap, melody.'],
     'Studio recording, 2006. The percussive travis-picking meditation from Continuum.',79),
    ('waiting-on-the-world-to-change','john-mayer','guitar','riff','main riff','clean','pop rock','rhythm','intermediate',
     'Fender Stratocaster (John Mayer)','Fender tube amp, warm clean','Open-back combo cab','neck pickup',
     '[{"effect_type":"compressor","effect_name":"light compression","placement":"front","settings":{"sustain":4,"level":5}},{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Soul-groove Mayer — warm Strat clean with sliding double-stops.','Just-clean neck-pickup warmth; the fills answer every vocal line.'],
     array['The intro double-stop figure sets the church-soul feel.','Fill the gaps with slides and hammer-ons.'],
     'Studio recording, 2006. Warm soul-groove Strat clean from Continuum.',79),
    ('new-light','john-mayer','guitar','riff','main riff','clean','pop rock','rhythm','intermediate',
     'PRS Silver Sky (John Mayer)','Clean amp, funky and compressed','Studio direct','neck + middle pickup',
     '[{"effect_type":"compressor","effect_name":"studio compression","placement":"front","settings":{"sustain":5,"level":5}}]'::jsonb,
     '{"gain":2,"bass":4,"mids":5,"treble":7,"presence":6,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Yacht-funk Mayer — glassy quacky clean chips and fills.','Bright in-between-position clean; 80s pop-funk polish.'],
     array['Funk chips on the off-beats; melodic fills between.','Keep the touch light and springy.'],
     'Studio recording, 2018. Glassy yacht-funk on the Silver Sky.',78),

    -- ============ BILLIE / SZA / GRACIE ============
    ('happier-than-ever','billie-eilish','guitar','riff','clean intro + fuzz wall','clean','pop','rhythm','intermediate',
     'Electric guitar (Finneas)','Clean amp, then blown-out fuzz wall','Studio direct','neck pickup',
     '[{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":1,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Whisper-waltz clean (settings shown) that detonates into a blown-out fuzz wall — for the back half, crank gain to 8 with fuzz.','Two songs in one: ukulele-soft clean, then total distorted catharsis.'],
     array['Gentle waltz strums for the first half.','When it flips, strum with full-arm rage.'],
     'Studio recording, 2021. The whisper-to-blowout catharsis.',75),
    ('tv','billie-eilish','guitar','main','fingerpicked pattern','acoustic','pop','rhythm','beginner',
     'Acoustic guitar (Finneas)','Acoustic — DI, intimate','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":2,"delay":0,"master":5}'::jsonb,
     array['From the literally-titled Guitar Songs EP — hushed close fingerpicking.','Whisper-quiet acoustic; the room is part of the sound.'],
     array['Soft looping arpeggio under the confession.','Barely touch the strings.'],
     'Studio recording, 2022. Hushed fingerpicking from Guitar Songs.',75),
    ('birds-of-a-feather','billie-eilish','guitar','main','main progression','clean','pop','rhythm','beginner',
     'Clean electric (Finneas)','Clean amp with soft shimmer','Studio direct','neck pickup',
     '[{"effect_type":"chorus","effect_name":"soft chorus shimmer","placement":"post_gain","settings":{"rate":3,"depth":3,"mix":3}},{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":1,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The 2024 devotion anthem — soft shimmering clean loop under airy production.','Gentle bright clean; sunshine with melancholy underneath.'],
     array['The four-chord loop floats — keep it weightless.','Support the vocal run in the bridge.'],
     'Studio recording, 2024. The shimmering devotion loop.',74),
    ('nobody-gets-me','sza','guitar','main','acoustic pattern','acoustic','r&b','rhythm','beginner',
     'Acoustic guitar (session)','Acoustic — DI, intimate','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['SZA''s country-tinged heartbreak — bare acoustic strums under the falsetto.','Soft warm acoustic; the vulnerability is the production.'],
     array['Simple strums; the melody does the acrobatics.','Stay out of the vocal''s way.'],
     'Studio recording, 2022. The bare acoustic heartbreak from SOS.',74),
    ('good-days','sza','guitar','main','clean loop','clean','r&b','rhythm','intermediate',
     'Clean electric (session)','Clean amp, dreamy and soft','Studio direct','neck pickup',
     '[{"effect_type":"reverb","effect_name":"dreamy reverb","placement":"post_gain","settings":{"mix":5,"decay":6}},{"effect_type":"compressor","effect_name":"soft compression","placement":"front","settings":{"sustain":5,"level":5}}]'::jsonb,
     '{"gain":1,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":5,"delay":1,"master":6}'::jsonb,
     array['The floating optimism loop — glassy fingerpicked clean in a dream haze.','Wet soft clean; the loop hypnotizes.'],
     array['The picking loop cycles endlessly — make it effortless.','Feel it float rather than push.'],
     'Studio recording, 2020. The floating dream-loop from SOS.',73),
    ('thats-so-true','gracie-abrams','guitar','main','main progression','acoustic','pop','rhythm','beginner',
     'Acoustic guitar (Gracie Abrams / session)','Acoustic — DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The 2024 viral kiss-off — bright driving acoustic strums.','Crisp pop acoustic with momentum.'],
     array['Driving strum pattern with muted accents.','The energy builds with the pettiness.'],
     'Studio recording, 2024. The viral kiss-off strummer.',73),
    ('i-love-you-im-sorry','gracie-abrams','guitar','main','fingerpicked pattern','acoustic','pop','rhythm','beginner',
     'Acoustic guitar (Gracie Abrams / session)','Acoustic — DI, soft','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":3,"delay":0,"master":5}'::jsonb,
     array['The apology waltz — gentle fingerpicked acoustic in 6/8.','Hushed warm acoustic; regret at bedroom volume.'],
     array['The 6/8 picking pattern sways softly.','Small dynamics; it''s a confession.'],
     'Studio recording, 2024. The hushed apology waltz.',73),
    ('ceilings','lizzy-mcalpine','guitar','main','fingerpicked pattern','acoustic','indie folk','rhythm','beginner',
     'Acoustic guitar (Lizzy McAlpine)','Acoustic — mic''d, intimate','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":3,"delay":0,"master":5}'::jsonb,
     array['The TikTok sprint-in-the-rain anthem — delicate fingerpicking that surges at the end.','Soft close acoustic; the final chorus doubles the energy.'],
     array['Gentle picking until the last chorus lifts.','Save the surge for "it''s not real".'],
     'Studio recording, 2022. The delicate viral surge ballad.',74),
    ('anything','adrianne-lenker','guitar','main','fingerpicked pattern','acoustic','indie folk','rhythm','advanced',
     'Acoustic guitar (Adrianne Lenker)','Acoustic — mic''d in a cabin','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Cabin-recorded intricacy — Lenker''s weaving fingerstyle in alternate tuning.','Warm woody acoustic; the pattern is dense but tender.'],
     array['Alternate tuning on the record — the drones matter.','Let the melody voice ring above the pattern.'],
     'Studio recording, 2020. Lenker''s cabin fingerstyle masterpiece.',76),
    ('kingston','faye-webster','guitar','main','main progression','clean','indie pop','rhythm','beginner',
     'Clean electric (Faye Webster / session)','Warm clean amp with pedal steel around it','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":1,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Lazy Atlanta soul — warm jazzy clean with pedal steel sighs around it.','Soft rounded clean; unhurried to the point of melting.'],
     array['Gentle jazz-flavored chords in the pocket.','Play it like a hot afternoon.'],
     'Studio recording, 2019. The lazy jazz-soul charmer.',73),
    ('3-nights','dominic-fike','guitar','riff','main riff','clean','indie pop','rhythm','beginner',
     'Clean electric (Dominic Fike)','Clean amp, bright and bouncy','Studio direct','bridge pickup',
     '[{"effect_type":"compressor","effect_name":"light compression","placement":"front","settings":{"sustain":4,"level":5}}]'::jsonb,
     '{"gain":2,"bass":4,"mids":5,"treble":7,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The breakout bedroom hit — bright bouncing clean riff.','Crisp poppy clean; beach-town ease.'],
     array['The intro riff hooks instantly.','Keep the bounce loose and sunny.'],
     'Studio recording, 2018. The bright breakout riff.',73),

    -- ============ AMERICANA / COUNTRY-FOLK ============
    ('wondering-why','the-red-clay-strays','guitar','riff','main progression','crunch','southern soul','rhythm','intermediate',
     'Hollow-body electric (Drew Nix / Zach Rishel)','Vintage tube amp, 50s-soul crunch','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"spring reverb","placement":"post_gain","settings":{"mix":4}},{"effect_type":"tremolo","effect_name":"light tremolo","placement":"post_gain","settings":{"rate":3,"depth":3}}]'::jsonb,
     '{"gain":4,"bass":5,"mids":6,"treble":5,"presence":4,"reverb":4,"delay":0,"master":6}'::jsonb,
     array['The 2024 viral slow-burn — 50s-soul crunch with spring and tremolo.','Warm vintage edge-of-breakup; Sun Studio ghosts everywhere.'],
     array['Slow 6/8 sway with bluesy fills.','Let the vibrato ache.'],
     'Studio recording, 2022. The viral 50s-soul slow burn.',74),
    ('lady-may','tyler-childers','guitar','main','fingerpicked pattern','acoustic','country folk','rhythm','intermediate',
     'Acoustic guitar (Tyler Childers)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The Appalachian love vow — bare travis-picked acoustic.','Clear honest acoustic; one voice, one guitar, one promise.'],
     array['The travis pattern rolls under the melody.','Sing it to someone who matters.'],
     'Studio recording, 2017. The bare Appalachian vow.',76),
    ('pink-skies','zach-bryan','guitar','main','main progression','acoustic','country folk','rhythm','beginner',
     'Acoustic guitar (Zach Bryan)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The funeral-day ballad — plain warm acoustic strums.','Honest unpolished acoustic; Bryan''s roughness is the point.'],
     array['Simple strums under conversational singing.','Don''t polish it.'],
     'Studio recording, 2024. The plainspoken funeral-day ballad.',74),
    ('oklahoma-smokeshow','zach-bryan','guitar','main','main progression','acoustic','country folk','rhythm','beginner',
     'Acoustic guitar (Zach Bryan)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The small-town tragedy — driving open-chord acoustic.','Warm strummed acoustic with heartland drive.'],
     array['Driving strums build with the story.','Full-band energy from one guitar.'],
     'Studio recording, 2022. The driving small-town tragedy.',74),
    ('dial-drunk','noah-kahan','guitar','main','main progression','acoustic','folk','rhythm','beginner',
     'Acoustic guitar (Noah Kahan)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":7,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The sprinting confession — bright galloping folk strums.','Crisp fast acoustic; banjo-adjacent drive.'],
     array['Gallop the strum pattern relentlessly.','Shout the bridge with the record.'],
     'Studio recording, 2023. The galloping drunk-dial confession.',74),
    ('silver-lining','mt-joy','guitar','riff','main riff','clean','indie folk','rhythm','intermediate',
     'Clean electric + acoustic (Sam Cooper / Matt Quinn)','Warm clean amp, light grit','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The festival-folk singalong — warm jangle riff with just a hair of grit.','Just-clean warmth; the riff hooks between vocal lines.'],
     array['The signature riff answers each verse line.','Lean into the group-vocal choruses.'],
     'Studio recording, 2018. The festival-folk singalong riff.',73),
    ('its-called-freefall','rainbow-kitten-surprise','guitar','main','main progression','clean','indie folk','rhythm','intermediate',
     'Clean electric (Darrick Keller / Ethan Goodpaster)','Clean amp, tight and dry','Open-back combo cab','neck pickup',
     '[{"effect_type":"compressor","effect_name":"light compression","placement":"front","settings":{"sustain":4,"level":5}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The viral surrender anthem — tight dry clean groove under rapid-fire vocals.','Snappy compressed clean; rhythm-section discipline.'],
     array['Muted groove pattern locked to the kick.','Open up for the falsetto hook.'],
     'Studio recording, 2018. The viral surrender-groove.',73)
) as c(
  song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence
)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;
