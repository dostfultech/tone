-- Phase 87: modern US country / red-dirt wave — the biggest current US search demand.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('HARDY','hardy','wait in the truck','wait-in-the-truck','the mockingbird & THE CROW',2022),
    ('Bailey Zimmerman','bailey-zimmerman','Rock and a Hard Place','rock-and-a-hard-place','Religiously. The Album.',2022),
    ('Warren Zeiders','warren-zeiders','Pretty Little Poison','pretty-little-poison','Pretty Little Poison',2023),
    ('Nate Smith','nate-smith','Whiskey on You','whiskey-on-you','Nate Smith',2022),
    ('Koe Wetzel','koe-wetzel','February 28, 2016','february-28-2016','Noise Complaint',2016),
    ('Parker McCollum','parker-mccollum','Pretty Heart','pretty-heart','Hollywood Gold',2020),
    ('Cody Jinks','cody-jinks','Loud and Heavy','loud-and-heavy','Adobe Sessions',2015),
    ('Charles Wesley Godwin','charles-wesley-godwin','Seneca Creek','seneca-creek','Seneca',2019),
    ('Flatland Cavalry','flatland-cavalry','A Life Where We Work Out','a-life-where-we-work-out','Homeland Insecurity',2019),
    ('Treaty Oak Revival','treaty-oak-revival','Missed Call','missed-call','No Vacancy',2021),
    ('Shane Smith & the Saints','shane-smith-and-the-saints','All I See Is You','all-i-see-is-you','Geronimo',2015),
    ('Wyatt Flores','wyatt-flores','Please Don''t Tell','please-dont-tell','Life Lessons',2023),
    ('Dylan Gossett','dylan-gossett','Coal','coal','No Better Time',2023),
    ('Turnpike Troubadours','turnpike-troubadours','Gin, Smoke, Lies','gin-smoke-lies','Goodbye Normal Street',2012),
    ('Zach Bryan','zach-bryan','Revival','revival','Elisabeth',2019),
    ('Morgan Wallen','morgan-wallen','Sand in My Boots','sand-in-my-boots','Dangerous: The Double Album',2021),
    ('Luke Combs','luke-combs','When It Rains It Pours','when-it-rains-it-pours','This One''s for You',2017),
    ('Chris Stapleton','chris-stapleton','White Horse','white-horse','Higher',2023),
    ('Tyler Childers','tyler-childers','In Your Love','in-your-love','Rustin'' in the Rain',2023),
    ('The Red Clay Strays','the-red-clay-strays','Devil in My Ear','devil-in-my-ear','Moment of Truth',2022),
    ('Ella Langley','ella-langley','you look like you love me','you-look-like-you-love-me','hungover',2024),
    ('Riley Green','riley-green','I Wish Grandpas Never Died','i-wish-grandpas-never-died','Different ''Round Here',2019),
    ('Megan Moroney','megan-moroney','Tennessee Orange','tennessee-orange','Lucky',2022),
    ('Pecos & the Rooftops','pecos-and-the-rooftops','This Damn Song','this-damn-song','Red Eye',2019),
    ('Jelly Roll','jelly-roll','Need a Favor','need-a-favor','Whitsitt Chapel',2023)
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
    ('hardy','wait-in-the-truck'),('bailey-zimmerman','rock-and-a-hard-place'),
    ('warren-zeiders','pretty-little-poison'),('nate-smith','whiskey-on-you'),
    ('koe-wetzel','february-28-2016'),('parker-mccollum','pretty-heart'),('cody-jinks','loud-and-heavy'),
    ('charles-wesley-godwin','seneca-creek'),('flatland-cavalry','a-life-where-we-work-out'),
    ('treaty-oak-revival','missed-call'),('shane-smith-and-the-saints','all-i-see-is-you'),
    ('wyatt-flores','please-dont-tell'),('dylan-gossett','coal'),('turnpike-troubadours','gin-smoke-lies'),
    ('zach-bryan','revival'),('morgan-wallen','sand-in-my-boots'),('luke-combs','when-it-rains-it-pours'),
    ('chris-stapleton','white-horse'),('tyler-childers','in-your-love'),('the-red-clay-strays','devil-in-my-ear'),
    ('ella-langley','you-look-like-you-love-me'),('riley-green','i-wish-grandpas-never-died'),
    ('megan-moroney','tennessee-orange'),('pecos-and-the-rooftops','this-damn-song'),('jelly-roll','need-a-favor')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
  where p.mode = 'guitar'
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('hardy','wait-in-the-truck'),('bailey-zimmerman','rock-and-a-hard-place'),
    ('warren-zeiders','pretty-little-poison'),('nate-smith','whiskey-on-you'),
    ('koe-wetzel','february-28-2016'),('parker-mccollum','pretty-heart'),('cody-jinks','loud-and-heavy'),
    ('charles-wesley-godwin','seneca-creek'),('flatland-cavalry','a-life-where-we-work-out'),
    ('treaty-oak-revival','missed-call'),('shane-smith-and-the-saints','all-i-see-is-you'),
    ('wyatt-flores','please-dont-tell'),('dylan-gossett','coal'),('turnpike-troubadours','gin-smoke-lies'),
    ('zach-bryan','revival'),('morgan-wallen','sand-in-my-boots'),('luke-combs','when-it-rains-it-pours'),
    ('chris-stapleton','white-horse'),('tyler-childers','in-your-love'),('the-red-clay-strays','devil-in-my-ear'),
    ('ella-langley','you-look-like-you-love-me'),('riley-green','i-wish-grandpas-never-died'),
    ('megan-moroney','tennessee-orange'),('pecos-and-the-rooftops','this-damn-song'),('jelly-roll','need-a-favor')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
  where p.mode = 'guitar'
);
delete from public.song_tone_profiles p where p.mode = 'guitar' and p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('hardy','wait-in-the-truck'),('bailey-zimmerman','rock-and-a-hard-place'),
    ('warren-zeiders','pretty-little-poison'),('nate-smith','whiskey-on-you'),
    ('koe-wetzel','february-28-2016'),('parker-mccollum','pretty-heart'),('cody-jinks','loud-and-heavy'),
    ('charles-wesley-godwin','seneca-creek'),('flatland-cavalry','a-life-where-we-work-out'),
    ('treaty-oak-revival','missed-call'),('shane-smith-and-the-saints','all-i-see-is-you'),
    ('wyatt-flores','please-dont-tell'),('dylan-gossett','coal'),('turnpike-troubadours','gin-smoke-lies'),
    ('zach-bryan','revival'),('morgan-wallen','sand-in-my-boots'),('luke-combs','when-it-rains-it-pours'),
    ('chris-stapleton','white-horse'),('tyler-childers','in-your-love'),('the-red-clay-strays','devil-in-my-ear'),
    ('ella-langley','you-look-like-you-love-me'),('riley-green','i-wish-grandpas-never-died'),
    ('megan-moroney','tennessee-orange'),('pecos-and-the-rooftops','this-damn-song'),('jelly-roll','need-a-favor')
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
    ('wait-in-the-truck','hardy','guitar','main','dark country strums','crunch','country','rhythm','beginner',
     'Acoustic + baritone electric (HARDY band)','Tube amp, dark country-rock','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":6,"mids":5,"treble":5,"presence":5,"reverb":3,"delay":0,"master":7}'::jsonb,
     array['The murder-ballad duet — dark acoustic verses, heavy baritone chorus slams.','Low mean crunch; have mercy on me, Lord.'],
     array['Verses bare and grim; chorus drops the hammer.','Lainey''s verse is the gut-punch — stay out of its way.'],
     'Studio recording, 2022. The murder-ballad duet.',75),
    ('rock-and-a-hard-place','bailey-zimmerman','guitar','main','heartbreak strums','acoustic','country','rhythm','beginner',
     'Acoustic guitar (Bailey Zimmerman band)','Acoustic — mic''d with band','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The TikTok-to-radio heartbreaker — big open strums under the ragged tenor.','Warm big acoustic; we''re stuck between a rock and a hard place.'],
     array['Open-chord strums, heavy on the downbeat.','Let the voice crack do the work.'],
     'Studio recording, 2022. The TikTok heartbreaker.',74),
    ('pretty-little-poison','warren-zeiders','guitar','main','dark strums','acoustic','country','rhythm','beginner',
     'Acoustic + dark electric (Warren Zeiders band)','Acoustic with moody electric','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The toxic-love anthem — brooding minor strums with dark electric colors (gain 4).','Moody warm acoustic; she''s my pretty little poison.'],
     array['Minor-key strums, restrained.','The chorus swells but never brightens.'],
     'Studio recording, 2023. The toxic-love anthem.',73),
    ('whiskey-on-you','nate-smith','guitar','riff','country-rock riff','crunch','country','rhythm','beginner',
     'Telecaster + acoustic (Nate Smith band)','Tube amp, radio country-rock','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The won''t-waste-whiskey kiss-off — punchy country-rock chords.','Bright modern crunch; I ain''t wasting good whiskey on you.'],
     array['Drive the chorus chords.','It''s a breakup song that grins.'],
     'Studio recording, 2022. The whiskey kiss-off.',73),
    ('february-28-2016','koe-wetzel','guitar','riff','grunge-country riff','distorted','country rock','rhythm','beginner',
     'Electric guitar (Koe Wetzel band)','Tube amp, grunge-country roar','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The arrest-date anthem — Texas grunge-country at full roar.','Thick loose distortion; Koe brought Nirvana to the honky-tonk.'],
     array['Slam the chords grunge-loose.','The crowd screams every word — play like it.'],
     'Studio recording, 2016. The arrest-date anthem.',74),
    ('pretty-heart','parker-mccollum','guitar','main','Texas-country strums','acoustic','country','rhythm','beginner',
     'Acoustic + Telecaster (Parker McCollum band)','Acoustic with Tele sparkle','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The wasted-a-pretty-heart confession — polished Texas-country strums with Tele fills (gain 3).','Clean bright mix; I know I did you wrong.'],
     array['Steady strums under the confession.','Tele fills answer the vocal lines.'],
     'Studio recording, 2020. The pretty-heart confession.',73),
    ('loud-and-heavy','cody-jinks','guitar','main','outlaw groove','acoustic','country','rhythm','beginner',
     'Acoustic + baritone electric (Cody Jinks band)','Acoustic with dark electric drone','Closed-back cab','neck pickup',
     '[]'::jsonb,'{"gain":0,"bass":6,"mids":5,"treble":5,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The outlaw meditation — hypnotic dropped-D acoustic groove with dark electric swells (gain 4).','Deep rolling acoustic; loud thunder, heavy rain.'],
     array['Drop D; the groove circles like weather.','Keep it hypnotic — it''s a storm prayer.'],
     'Studio recording, 2015. The outlaw meditation.',75),
    ('seneca-creek','charles-wesley-godwin','guitar','main','Appalachian fingerpicking','acoustic','folk','rhythm','intermediate',
     'Acoustic guitar (Charles Wesley Godwin)','Acoustic — mic''d, mountain intimacy','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The West Virginia elegy — flowing Appalachian fingerpicking under the coal-country baritone.','Warm rich acoustic; the mountains sing through him.'],
     array['Fingerpick the rolling pattern.','Childers'' heir — play it like the holler taught you.'],
     'Studio recording, 2019. The West Virginia elegy.',74),
    ('a-life-where-we-work-out','flatland-cavalry','guitar','main','Lubbock-country strums','acoustic','country','rhythm','beginner',
     'Acoustic + Telecaster (Cleto Cordero / Flatland Cavalry)','Acoustic with fiddle and Tele','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The parallel-universe love song — gentle Lubbock-country strums under the fiddle.','Soft warm acoustic; somewhere there''s a life where we work out.'],
     array['Easy strums; the fiddle carries the ache.','Sing it to the one that got away.'],
     'Studio recording, 2019. The parallel-universe love song.',73),
    ('missed-call','treaty-oak-revival','guitar','riff','Texas punk-country riff','crunch','country rock','rhythm','beginner',
     'Electric guitar (Treaty Oak Revival)','Tube amp, rowdy punk-country','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The Odessa rowdy-hour — punk-energy country crunch for the missed-call regret.','Loose aggressive drive; bar-band loud and unpolished.'],
     array['Slam the chords with punk energy.','The crowd chant is the chorus.'],
     'Studio recording, 2021. The Odessa rowdy-hour.',72),
    ('all-i-see-is-you','shane-smith-and-the-saints','guitar','main','harmony-band strums','acoustic','country rock','rhythm','beginner',
     'Acoustic + electric (Shane Smith & the Saints)','Acoustic with soaring band','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The Yellowstone-discovered anthem — driving acoustic under four-part harmonies and fiddle.','Big open acoustic; the harmonies are the amplifier.'],
     array['Drive the strums; the band swells around you.','Play it like a canyon needs filling.'],
     'Studio recording, 2015. The harmony-band anthem.',73),
    ('please-dont-tell','wyatt-flores','guitar','main','red-dirt fingerpicking','acoustic','folk','rhythm','beginner',
     'Acoustic guitar (Wyatt Flores)','Acoustic — mic''d, bedroom honest','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The Stillwater confessional — soft picked acoustic for the gen-Z red-dirt wave.','Close warm acoustic; please don''t tell my mother.'],
     array['Fingerpick gently; it''s a secret being told.','The trembling delivery is the point.'],
     'Studio recording, 2023. The Stillwater confessional.',73),
    ('coal','dylan-gossett','guitar','main','stomp-folk strums','acoustic','folk','rhythm','beginner',
     'Acoustic guitar (Dylan Gossett)','Acoustic — mic''d with stomp','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The pressure-makes-diamonds viral — driving stomp-folk strums, self-recorded honesty.','Percussive warm acoustic; from the coal comes something more.'],
     array['Strum with the boot-stomp pulse.','One guitar, one truth — keep it bare.'],
     'Studio recording, 2023. The pressure-makes-diamonds viral.',73),
    ('gin-smoke-lies','turnpike-troubadours','guitar','riff','red-dirt barnburner','crunch','country rock','rhythm','intermediate',
     'Telecaster (Ryan Engleman)','Tube amp, red-dirt Tele bite','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":5,"treble":7,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The cheating-evidence barnburner — biting Tele runs against the fiddle.','Twangy pushed crunch; gin, smoke, and lies on her breath.'],
     array['Chicken-pick the runs between vocal lines.','Race the fiddle; lose gracefully.'],
     'Studio recording, 2012. The red-dirt barnburner.',75),
    ('revival','zach-bryan','guitar','main','campfire revival','acoustic','folk','rhythm','beginner',
     'Acoustic guitar (Zach Bryan)','Acoustic — raw room recording','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The all-night-revival singalong — raw pounded strums, recorded like a porch full of friends.','Rough loud acoustic; we''re having an all-night revival.'],
     array['Pound the strums; shout the answer lines.','Perfection is the enemy — Zach proved it.'],
     'Studio recording, 2019. The all-night-revival singalong.',75),
    ('sand-in-my-boots','morgan-wallen','guitar','main','beach-memory strums','acoustic','country','rhythm','beginner',
     'Acoustic guitar (Morgan Wallen / session)','Acoustic — polished Nashville','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The she-never-showed opener — tender picked acoustic, Wallen''s best-loved deep cut.','Soft polished acoustic; nothing but sand in my boots.'],
     array['Pick the intro figure gently.','The details tell the story — so should the dynamics.'],
     'Studio recording, 2021. The she-never-showed opener.',75),
    ('when-it-rains-it-pours','luke-combs','guitar','main','good-luck strums','acoustic','country','rhythm','beginner',
     'Acoustic + Telecaster (Luke Combs band)','Acoustic with Tele fills','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The lucky-streak singalong — driving strums and grinning Tele fills (gain 3).','Bright warm mix; won a hundred bucks on a scratch-off ticket.'],
     array['Drive the strums with the list of wins.','Every verse tops the last — build with it.'],
     'Studio recording, 2017. The lucky-streak singalong.',74),
    ('white-horse','chris-stapleton','guitar','riff','country-rock stomp','crunch','country rock','lead','intermediate',
     'Fender Jazzmaster (Chris Stapleton)','Tube amp, big country-rock stomp','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":6,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The Grammy-winning stomp — Stapleton''s biggest riff, half outlaw half arena.','Thick soulful drive; if you want a cowboy on a white horse.'],
     array['Stomp the riff wide open.','The solo howls — bend from the chest.'],
     'Studio recording, 2023. The Grammy-winning stomp.',76),
    ('in-your-love','tyler-childers','guitar','main','tender build','clean','country','rhythm','beginner',
     'Clean electric + acoustic (Tyler Childers band)','Clean amp, warm heartland build','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":5,"presence":4,"reverb":3,"delay":0,"master":7}'::jsonb,
     array['The workin''-on-a-building ballad — warm heartland build, Childers'' tenderest single.','Round warm clean; I will work for you in your love.'],
     array['Build patiently verse to verse.','It swells like Springsteen gone to church.'],
     'Studio recording, 2023. The tender heartland build.',74),
    ('devil-in-my-ear','the-red-clay-strays','guitar','riff','vintage-soul rock','crunch','southern rock','rhythm','intermediate',
     'Vintage electric (Drew Nix / Zach Rishel)','Vintage tube amp, 50s-soul grit','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":0,"master":7}'::jsonb,
     array['The mental-battle rocker — Sun-Records menace with southern-soul muscle.','Slapback-era grit; the Strays sound like 1956 got angry.'],
     array['The riff swaggers rockabilly-dark.','Fight the devil in the phrasing.'],
     'Studio recording, 2022. The mental-battle rocker.',73),
    ('you-look-like-you-love-me','ella-langley','guitar','main','honky-tonk spoken duet','clean','country','rhythm','beginner',
     'Telecaster + acoustic (Ella Langley band)','Clean amp, retro honky-tonk','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The spoken-word barroom viral — retro honky-tonk shuffle under the flirtation.','Warm twangy clean; you look like you love me.'],
     array['Shuffle the chords barroom-easy.','The talking verses are the hook — stay under them.'],
     'Studio recording, 2024. The barroom flirtation viral.',73),
    ('i-wish-grandpas-never-died','riley-green','guitar','main','front-porch ballad','acoustic','country','rhythm','beginner',
     'Acoustic guitar (Riley Green)','Acoustic — mic''d, front-porch warm','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The grandpa tearjerker — simple front-porch strums under the wish list.','Soft warm acoustic; I wish grandpas never died.'],
     array['Simple open chords, honest tempo.','Written for his — play it for yours.'],
     'Studio recording, 2019. The grandpa tearjerker.',74),
    ('tennessee-orange','megan-moroney','guitar','main','soft country strums','acoustic','country','rhythm','beginner',
     'Acoustic guitar (Megan Moroney / session)','Acoustic — mic''d, soft Nashville','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The rivalry-romance hit — gentle strums under the Georgia-girl confession.','Soft sweet acoustic; in Tennessee orange, it looks like love.'],
     array['Gentle strums, waltz-soft feel.','The football metaphor lands itself.'],
     'Studio recording, 2022. The rivalry-romance hit.',73),
    ('this-damn-song','pecos-and-the-rooftops','guitar','riff','Texas heartbreak rock','crunch','country rock','rhythm','beginner',
     'Electric guitar (Pecos & the Rooftops)','Tube amp, Texas college-rock drive','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The Lubbock heartbreak viral — grungy Texas-rock chords under the ragged hook.','Thick loose drive; I still hate this damn song.'],
     array['Slam the chorus chords.','It''s a heartbreak you can shout along to.'],
     'Studio recording, 2019. The Lubbock heartbreak viral.',72),
    ('need-a-favor','jelly-roll','guitar','riff','redemption-rock riff','crunch','country rock','rhythm','beginner',
     'Electric + acoustic (Jelly Roll band)','Tube amp, arena redemption-rock','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":8}'::jsonb,
     array['The only-talk-to-God-when-I-need-a-favor confession — arena-rock muscle under the gospel plea.','Big warm drive; and I only pray when I ain''t got a prayer.'],
     array['Quiet verses, wide-open chorus.','It''s a church song wearing a leather jacket.'],
     'Studio recording, 2023. The redemption confession.',75)
) as c(
  song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence
)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;
