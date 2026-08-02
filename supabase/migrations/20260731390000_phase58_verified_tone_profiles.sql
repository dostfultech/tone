-- Phase 58: country canon (modern + classic), verified per-part tone data.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Morgan Wallen','morgan-wallen','Last Night','last-night','One Thing at a Time',2023),
    ('Morgan Wallen','morgan-wallen','Wasted on You','wasted-on-you','Dangerous: The Double Album',2021),
    ('Zach Top','zach-top','Sounds Like the Radio','sounds-like-the-radio','Cold Beer & Country Music',2024),
    ('Jelly Roll','jelly-roll','Save Me','save-me','Whitsitt Chapel',2023),
    ('Lainey Wilson','lainey-wilson','Things a Man Oughta Know','things-a-man-oughta-know','Sayin'' What I''m Thinkin''',2021),
    ('George Strait','george-strait','Amarillo by Morning','amarillo-by-morning','Strait from the Heart',1982),
    ('George Strait','george-strait','Check Yes or No','check-yes-or-no','Strait Out of the Box',1995),
    ('Shania Twain','shania-twain','Man! I Feel Like a Woman!','man-i-feel-like-a-woman','Come On Over',1997),
    ('Shania Twain','shania-twain','You''re Still the One','youre-still-the-one','Come On Over',1997),
    ('The Chicks','the-chicks','Wide Open Spaces','wide-open-spaces','Wide Open Spaces',1998),
    ('The Chicks','the-chicks','Cowboy Take Me Away','cowboy-take-me-away','Fly',1999),
    ('Vince Gill','vince-gill','One More Last Chance','one-more-last-chance','I Still Believe in You',1992),
    ('Charley Crockett','charley-crockett','Welcome to Hard Times','welcome-to-hard-times','Welcome to Hard Times',2020),
    ('Colter Wall','colter-wall','Sleeping on the Blacktop','sleeping-on-the-blacktop','Imaginary Appalachia',2015),
    ('Brooks & Dunn','brooks-and-dunn','Neon Moon','neon-moon','Brand New Man',1992),
    ('Alan Jackson','alan-jackson','Remember When','remember-when','Greatest Hits Volume II',2003),
    ('Toby Keith','toby-keith','Should''ve Been a Cowboy','shouldve-been-a-cowboy','Toby Keith',1993),
    ('Randy Travis','randy-travis','Forever and Ever, Amen','forever-and-ever-amen','Always & Forever',1987),
    ('Travis Tritt','travis-tritt','It''s a Great Day to Be Alive','its-a-great-day-to-be-alive','Down the Road I Go',2000),
    ('Miranda Lambert','miranda-lambert','The House That Built Me','the-house-that-built-me','Revolution',2010),
    ('Carrie Underwood','carrie-underwood','Before He Cheats','before-he-cheats','Some Hearts',2005),
    ('Zac Brown Band','zac-brown-band','Chicken Fried','chicken-fried','The Foundation',2008),
    ('Old Crow Medicine Show','old-crow-medicine-show','Wagon Wheel','wagon-wheel','O.C.M.S.',2004),
    ('Eric Church','eric-church','Springsteen','springsteen','Chief',2011),
    ('Kacey Musgraves','kacey-musgraves','Slow Burn','slow-burn','Golden Hour',2018)
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
    ('morgan-wallen','last-night'),('morgan-wallen','wasted-on-you'),('zach-top','sounds-like-the-radio'),
    ('jelly-roll','save-me'),('lainey-wilson','things-a-man-oughta-know'),('george-strait','amarillo-by-morning'),
    ('george-strait','check-yes-or-no'),('shania-twain','man-i-feel-like-a-woman'),('shania-twain','youre-still-the-one'),
    ('the-chicks','wide-open-spaces'),('the-chicks','cowboy-take-me-away'),('vince-gill','one-more-last-chance'),
    ('charley-crockett','welcome-to-hard-times'),('colter-wall','sleeping-on-the-blacktop'),('brooks-and-dunn','neon-moon'),
    ('alan-jackson','remember-when'),('toby-keith','shouldve-been-a-cowboy'),('randy-travis','forever-and-ever-amen'),
    ('travis-tritt','its-a-great-day-to-be-alive'),('miranda-lambert','the-house-that-built-me'),
    ('carrie-underwood','before-he-cheats'),('zac-brown-band','chicken-fried'),('old-crow-medicine-show','wagon-wheel'),
    ('eric-church','springsteen'),('kacey-musgraves','slow-burn')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('morgan-wallen','last-night'),('morgan-wallen','wasted-on-you'),('zach-top','sounds-like-the-radio'),
    ('jelly-roll','save-me'),('lainey-wilson','things-a-man-oughta-know'),('george-strait','amarillo-by-morning'),
    ('george-strait','check-yes-or-no'),('shania-twain','man-i-feel-like-a-woman'),('shania-twain','youre-still-the-one'),
    ('the-chicks','wide-open-spaces'),('the-chicks','cowboy-take-me-away'),('vince-gill','one-more-last-chance'),
    ('charley-crockett','welcome-to-hard-times'),('colter-wall','sleeping-on-the-blacktop'),('brooks-and-dunn','neon-moon'),
    ('alan-jackson','remember-when'),('toby-keith','shouldve-been-a-cowboy'),('randy-travis','forever-and-ever-amen'),
    ('travis-tritt','its-a-great-day-to-be-alive'),('miranda-lambert','the-house-that-built-me'),
    ('carrie-underwood','before-he-cheats'),('zac-brown-band','chicken-fried'),('old-crow-medicine-show','wagon-wheel'),
    ('eric-church','springsteen'),('kacey-musgraves','slow-burn')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('morgan-wallen','last-night'),('morgan-wallen','wasted-on-you'),('zach-top','sounds-like-the-radio'),
    ('jelly-roll','save-me'),('lainey-wilson','things-a-man-oughta-know'),('george-strait','amarillo-by-morning'),
    ('george-strait','check-yes-or-no'),('shania-twain','man-i-feel-like-a-woman'),('shania-twain','youre-still-the-one'),
    ('the-chicks','wide-open-spaces'),('the-chicks','cowboy-take-me-away'),('vince-gill','one-more-last-chance'),
    ('charley-crockett','welcome-to-hard-times'),('colter-wall','sleeping-on-the-blacktop'),('brooks-and-dunn','neon-moon'),
    ('alan-jackson','remember-when'),('toby-keith','shouldve-been-a-cowboy'),('randy-travis','forever-and-ever-amen'),
    ('travis-tritt','its-a-great-day-to-be-alive'),('miranda-lambert','the-house-that-built-me'),
    ('carrie-underwood','before-he-cheats'),('zac-brown-band','chicken-fried'),('old-crow-medicine-show','wagon-wheel'),
    ('eric-church','springsteen'),('kacey-musgraves','slow-burn')
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
    -- ============ MODERN COUNTRY ============
    ('last-night','morgan-wallen','guitar','main','main progression','acoustic','country','rhythm','beginner',
     'Acoustic guitar (session)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The streaming juggernaut — simple warm acoustic loop under pop-country production.','Bright modern acoustic; the loop repeats hypnotically.'],
     array['A four-chord loop with a light strum-pick pattern.','Keep it loose and barroom-casual.'],
     'Studio recording, 2023. The streaming-era acoustic loop hit.',73),
    ('wasted-on-you','morgan-wallen','guitar','main','main progression','acoustic','country','rhythm','beginner',
     'Acoustic guitar (session)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Moody minor-key country — dark acoustic picking under trap-tinged drums.','Warm dark acoustic; the gloom is the hook.'],
     array['Minor arpeggio pattern in the verse.','Open into strums for the chorus.'],
     'Studio recording, 2021. Moody minor-key acoustic from Dangerous.',72),
    ('sounds-like-the-radio','zach-top','guitar','riff','main riff + solo','clean','country','lead','intermediate',
     'Fender Telecaster (Zach Top / session)','Fender tube amp, clean twang','Fender combo cab','bridge single-coil',
     '[{"effect_type":"compressor","effect_name":"chicken-pickin compression","placement":"front","settings":{"sustain":5,"level":5}},{"effect_type":"reverb","effect_name":"studio plate","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":2,"bass":4,"mids":6,"treble":8,"presence":7,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The 90s-country revival — pure compressed Telecaster twang and chicken pickin''.','Bright squeezed Tele clean; this is trad country played straight.'],
     array['Hybrid-pick the fills — pick plus middle finger snap.','The solo is classic Tele bends and double-stops.'],
     'Studio recording, 2024. The trad-Telecaster revival hit.',75),
    ('save-me','jelly-roll','guitar','main','main progression','acoustic','country','rhythm','beginner',
     'Acoustic guitar (Jelly Roll / session)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Raw confession ballad — bare dark acoustic under a broken vocal.','Quiet warm acoustic; the pain does the work.'],
     array['Slow picked pattern, minimal movement.','Serve the vocal completely.'],
     'Studio recording, 2023. The bare confession ballad.',72),
    ('things-a-man-oughta-know','lainey-wilson','guitar','main','main progression','acoustic','country','rhythm','beginner',
     'Acoustic guitar (session)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bell-bottom country wisdom — warm steady acoustic strums.','Classic Nashville acoustic bed with light electric color.'],
     array['Steady mid-tempo strum throughout.','Let the lyric lead.'],
     'Studio recording, 2021. Warm steady Nashville strums.',72),

    -- ============ CLASSIC / 90s COUNTRY ============
    ('amarillo-by-morning','george-strait','guitar','main','main progression','acoustic','country','rhythm','beginner',
     'Acoustic guitar (session)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The rodeo anthem — gentle acoustic waltz-time strums under the fiddle.','Warm traditional acoustic; the fiddle owns the hooks.'],
     array['Gentle rolling strums in the two-step feel.','Space for the fiddle and steel between lines.'],
     'Studio recording, 1982. The rodeo-anthem acoustic bed.',75),
    ('check-yes-or-no','george-strait','guitar','riff','main riff','clean','country','rhythm','beginner',
     'Fender Telecaster (session — Nashville A-team)','Fender tube amp, clean twang','Fender combo cab','bridge single-coil',
     '[{"effect_type":"compressor","effect_name":"studio compression","placement":"front","settings":{"sustain":5,"level":5}}]'::jsonb,
     '{"gain":2,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['90s Strait perfection — bright compressed Tele licks around acoustic strums.','Clean Nashville Tele sparkle; polite and precise.'],
     array['The signature intro lick is pure 90s Nashville.','Answer the vocal with short Tele fills.'],
     'Studio recording, 1995. Bright 90s Nashville Tele sparkle.',75),
    ('man-i-feel-like-a-woman','shania-twain','guitar','riff','main riff','crunch','country pop','rhythm','beginner',
     'Solid-body electric (session)','Tube amp, arena-country crunch','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The girls''-night stomp — big polished arena-country crunch riff.','Punchy radio crunch; rock energy, country hooks.'],
     array['The descending intro riff announces the party.','Stab the accents with the band.'],
     'Studio recording, 1997. The arena-country party riff.',74),
    ('youre-still-the-one','shania-twain','guitar','main','main progression','clean','country pop','rhythm','beginner',
     'Clean electric + acoustic (session)','Warm clean amp','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":1,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":4,"delay":0,"master":6}'::jsonb,
     array['The wedding-dance staple — soft warm clean arpeggios.','Gentle clean with hall; first-dance tenderness.'],
     array['Slow 6/8 arpeggios under the melody.','Play it like a slow dance.'],
     'Studio recording, 1997. The wedding-dance clean ballad.',74),
    ('wide-open-spaces','the-chicks','guitar','main','main progression','acoustic','country','rhythm','beginner',
     'Acoustic guitar (Emily Strayer / session)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The leaving-home anthem — bright open acoustic with banjo and fiddle around it.','Crisp open strums; room for the bluegrass instruments.'],
     array['Open-chord strums with a light lift.','The song breathes — don''t crowd it.'],
     'Studio recording, 1998. The leaving-home acoustic anthem.',74),
    ('cowboy-take-me-away','the-chicks','guitar','main','fingerpicked intro + strums','acoustic','country','rhythm','intermediate',
     'Acoustic guitar (Emily Strayer / session)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Windswept romance — delicate fingerpicked intro opening into soaring strums.','Warm rich acoustic; dynamics carry the longing.'],
     array['The intro picking pattern is the signature.','Lift into full strums for the chorus.'],
     'Studio recording, 1999. The windswept fingerpicked romance.',74),
    ('one-more-last-chance','vince-gill','guitar','riff','main riff + solo','clean','country','lead','advanced',
     'Fender Telecaster (Vince Gill)','Fender tube amp, singing clean twang','Fender combo cab','bridge single-coil',
     '[{"effect_type":"compressor","effect_name":"light compression","placement":"front","settings":{"sustain":4,"level":5}},{"effect_type":"reverb","effect_name":"studio plate","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":3,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Gill''s Telecaster masterclass — singing clean twang with effortless bends.','Just-clean Tele with sparkle; touch does everything.'],
     array['The solo is a chicken-pickin'' clinic — learn it slow.','Bend into notes like a steel player.'],
     'Studio recording, 1992. Gill''s Telecaster masterclass.',77),
    ('welcome-to-hard-times','charley-crockett','guitar','main','main progression','clean','country','rhythm','beginner',
     'Hollow-body electric (Charley Crockett / session)','Vintage tube amp, dusty clean','Open-back combo cab','neck pickup',
     '[{"effect_type":"tremolo","effect_name":"amp tremolo","placement":"post_gain","settings":{"rate":3,"depth":4}},{"effect_type":"reverb","effect_name":"spring reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":6,"treble":5,"presence":4,"reverb":4,"delay":0,"master":6}'::jsonb,
     array['Gulf & Western noir — dusty tremolo clean straight from a 60s jukebox.','Warm vintage clean with tremolo and spring; sepia-toned on purpose.'],
     array['Simple downstroke strums with the tremolo pulsing.','Play it like an old 45.'],
     'Studio recording, 2020. Dusty jukebox-noir tremolo clean.',73),
    ('sleeping-on-the-blacktop','colter-wall','guitar','main','fingerpicked riff','acoustic','country folk','rhythm','intermediate',
     'Acoustic guitar (Colter Wall)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":6,"mids":5,"treble":5,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Prairie-gothic fingerpicking — dark droning acoustic riff.','Boomy dark acoustic; the low strings drone like an engine.'],
     array['The blues-tinged picking riff loops all song.','Keep it ominous and steady.'],
     'Studio recording, 2015. The prairie-gothic droning riff.',74),
    ('neon-moon','brooks-and-dunn','guitar','riff','main riff','clean','country','rhythm','beginner',
     'Fender Telecaster (session — Brent Mason school)','Fender tube amp, glassy clean','Fender combo cab','bridge single-coil',
     '[{"effect_type":"chorus","effect_name":"90s studio chorus","placement":"post_gain","settings":{"rate":3,"depth":3,"mix":4}},{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":7,"presence":6,"reverb":4,"delay":1,"master":6}'::jsonb,
     array['The lonely barroom classic — glassy chorused Tele under the neon.','Wet 90s Nashville clean; the chorused shimmer IS the neon light.'],
     array['The intro lick sets the loneliness.','Gentle fills between vocal lines.'],
     'Studio recording, 1992. The neon-lit chorused Tele classic.',75),
    ('remember-when','alan-jackson','guitar','main','fingerpicked progression','clean','country','rhythm','beginner',
     'Clean electric + acoustic (session)','Warm clean amp','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":1,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":4,"delay":0,"master":6}'::jsonb,
     array['The life-in-verses waltz — tender fingerpicked clean.','Soft warm clean; a lifetime in 3/4 time.'],
     array['Fingerpick the waltz pattern gently.','Dynamics swell with the decades.'],
     'Studio recording, 2003. The tender life-story waltz.',74),

    -- ============ 90s-2000s RADIO COUNTRY ============
    ('shouldve-been-a-cowboy','toby-keith','guitar','riff','main riff','clean','country','rhythm','beginner',
     'Fender Telecaster (session)','Fender tube amp, clean twang','Fender combo cab','bridge single-coil',
     '[{"effect_type":"reverb","effect_name":"studio plate","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The daydream anthem — bright Tele twang with steel answers.','Clean 90s Nashville sparkle throughout.'],
     array['The intro lick is the invitation.','Easy loping strums under the verses.'],
     'Studio recording, 1993. The cowboy-daydream twang anthem.',74),
    ('forever-and-ever-amen','randy-travis','guitar','main','main progression','acoustic','country','rhythm','beginner',
     'Acoustic guitar (session)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Neo-traditional vows — warm acoustic strums with Tele fills around them.','Classic 80s Nashville acoustic bed.'],
     array['Bouncy two-step strums.','Grin through the "amen".'],
     'Studio recording, 1987. Neo-traditional country vows.',74),
    ('its-a-great-day-to-be-alive','travis-tritt','guitar','main','fingerpicked riff','acoustic','country','rhythm','intermediate',
     'Acoustic guitar (session)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The rice-cookin'' gratitude song — rolling fingerpicked acoustic riff.','Warm articulate acoustic; the intro pattern is the identity.'],
     array['The rolling picking riff repeats — make it effortless.','Sunshine feel, even in the minor moments.'],
     'Studio recording, 2000. The rolling gratitude riff.',74),
    ('the-house-that-built-me','miranda-lambert','guitar','main','fingerpicked pattern','acoustic','country','rhythm','beginner',
     'Acoustic guitar (session)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":3,"delay":0,"master":5}'::jsonb,
     array['The homecoming tear-jerker — hushed fingerpicked acoustic.','Quiet intimate acoustic; barely above a whisper.'],
     array['Gentle travis-style picking throughout.','Restraint is the emotion.'],
     'Studio recording, 2010. The hushed homecoming ballad.',74),
    ('before-he-cheats','carrie-underwood','guitar','riff','main riff','crunch','country rock','rhythm','beginner',
     'Solid-body electric (session)','Tube amp, dark country-rock crunch','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":6,"mids":5,"treble":5,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The Louisville-slugger revenge stomp — dark chunky crunch.','Moody mid-gain stomp; menace with polish.'],
     array['The minor-key riff prowls.','Dig in when the bat comes out.'],
     'Studio recording, 2005. The revenge-stomp crunch.',73),
    ('chicken-fried','zac-brown-band','guitar','main','main progression','acoustic','country','rhythm','beginner',
     'Acoustic guitar (Zac Brown)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":7,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The Friday-night gratitude list — bright bouncing acoustic strums.','Crisp campfire acoustic with a picked intro riff.'],
     array['The intro picking pattern kicks it off.','Bounce the strums; toes will tap.'],
     'Studio recording, 2008. The Friday-night acoustic bounce.',74),
    ('wagon-wheel','old-crow-medicine-show','guitar','main','main progression','acoustic','country folk','rhythm','beginner',
     'Acoustic guitar (Old Crow Medicine Show)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The eternal busker anthem — driving G-D-Em-C acoustic strums.','Bright stomping acoustic; fiddle and banjo swirl around it.'],
     array['Four chords, maximum singalong.','Drive the strum like a train.'],
     'Studio recording, 2004. The eternal four-chord busker anthem.',75),
    ('springsteen','eric-church','guitar','main','main progression','clean','country rock','rhythm','beginner',
     'Clean electric + acoustic (session)','Warm clean amp with ambience','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":4}},{"effect_type":"delay","effect_name":"subtle delay","placement":"post_gain","settings":{"time":3,"mix":2,"feedback":2}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":4,"delay":2,"master":6}'::jsonb,
     array['Nostalgia as a song — warm ambient clean under the memory.','Soft wet clean; a summer night in tone form.'],
     array['Gentle arpeggios and swelling strums.','The "whoa-oh" outro carries itself — support it.'],
     'Studio recording, 2011. The warm nostalgia ballad.',73),
    ('slow-burn','kacey-musgraves','guitar','main','fingerpicked pattern','acoustic','country pop','rhythm','beginner',
     'Acoustic guitar (session)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Golden-hour opener — patient fingerpicked acoustic glow.','Warm spacious acoustic; unhurried by design.'],
     array['The picking pattern ambles — never rush it.','Let the chords glow into each other.'],
     'Studio recording, 2018. The golden-hour fingerpicked glow.',74)
) as c(
  song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence
)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;
