-- Phase 91: J-Rock / anime guitar canon (per Discord tip: Metal, J-Rock, Pop Rock)
-- + modern metal gap fills. Anime songs are among the most-tabbed guitar songs online.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Kessoku Band','kessoku-band','Guitar, Loneliness and Blue Planet','guitar-loneliness-and-blue-planet','Kessoku Band',2022),
    ('Kessoku Band','kessoku-band','Ano Band','ano-band','Kessoku Band',2022),
    ('MAN WITH A MISSION','man-with-a-mission','Raise Your Flag','raise-your-flag','The World''s On Fire',2016),
    ('X Japan','x-japan','Kurenai','kurenai','Blue Blood',1989),
    ('The Gazette','the-gazette','Filth in the Beauty','filth-in-the-beauty','Stacked Rubbish',2007),
    ('FLOW','flow-band','GO!!!','go','GO!!!',2004),
    ('SCANDAL','scandal-band','Shunkan Sentimental','shunkan-sentimental','Temptation Box',2010),
    ('Tomoyasu Hotei','hotei','Battle Without Honor or Humanity','battle-without-honor-or-humanity',null,2000),
    ('One Ok Rock','one-ok-rock','Clock Strikes','clock-strikes','Jinsei x Boku =',2013),
    ('Asian Kung-Fu Generation','asian-kung-fu-generation','After Dark','after-dark','World World World',2008),
    ('L''Arc-en-Ciel','larc-en-ciel','Driver''s High','drivers-high','Ark',1999),
    ('Maximum the Hormone','maximum-the-hormone','Zetsubou Billy','zetsubou-billy','Bu-ikikaesu',2007),
    ('BABYMETAL','babymetal','Megitsune','megitsune','BABYMETAL',2014),
    ('Nightmare','nightmare-band','The World','the-world','The World Ruler',2007),
    ('BURNOUT SYNDROMES','burnout-syndromes','Hikari Are','hikari-are','Hikari Are',2016),
    ('Wagakki Band','wagakki-band','Senbonzakura','senbonzakura','Vocalo Zanmai',2014),
    ('GRANRODEO','granrodeo','Can Do','can-do','Can Do',2012),
    ('Linked Horizon','linked-horizon','Guren no Yumiya','guren-no-yumiya','Jiyuu e no Shingeki',2013),
    ('YUI','yui','Again','again','Again',2009),
    ('Eve','eve-jp','Kaikai Kitan','kaikai-kitan','Smile',2020),
    ('ORANGE RANGE','orange-range','Asterisk','asterisk','musiQ',2004),
    ('SiM','sim-band','The Rumbling','the-rumbling','Beware',2022),
    ('Knocked Loose','knocked-loose','Blinding Faith','blinding-faith','You Won''t Go Before You''re Supposed To',2024),
    ('Electric Callboy','electric-callboy','Hypa Hypa','hypa-hypa','MMXX',2020),
    ('Slaughter to Prevail','slaughter-to-prevail','Baba Yaga','baba-yaga','Kostolom',2021)
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
    ('kessoku-band','guitar-loneliness-and-blue-planet'),('kessoku-band','ano-band'),
    ('man-with-a-mission','raise-your-flag'),('x-japan','kurenai'),('the-gazette','filth-in-the-beauty'),
    ('flow-band','go'),('scandal-band','shunkan-sentimental'),('hotei','battle-without-honor-or-humanity'),
    ('one-ok-rock','clock-strikes'),('asian-kung-fu-generation','after-dark'),('larc-en-ciel','drivers-high'),
    ('maximum-the-hormone','zetsubou-billy'),('babymetal','megitsune'),('nightmare-band','the-world'),
    ('burnout-syndromes','hikari-are'),('wagakki-band','senbonzakura'),('granrodeo','can-do'),
    ('linked-horizon','guren-no-yumiya'),('yui','again'),('eve-jp','kaikai-kitan'),
    ('orange-range','asterisk'),('sim-band','the-rumbling'),('knocked-loose','blinding-faith'),
    ('electric-callboy','hypa-hypa'),('slaughter-to-prevail','baba-yaga')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
  where p.mode = 'guitar'
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('kessoku-band','guitar-loneliness-and-blue-planet'),('kessoku-band','ano-band'),
    ('man-with-a-mission','raise-your-flag'),('x-japan','kurenai'),('the-gazette','filth-in-the-beauty'),
    ('flow-band','go'),('scandal-band','shunkan-sentimental'),('hotei','battle-without-honor-or-humanity'),
    ('one-ok-rock','clock-strikes'),('asian-kung-fu-generation','after-dark'),('larc-en-ciel','drivers-high'),
    ('maximum-the-hormone','zetsubou-billy'),('babymetal','megitsune'),('nightmare-band','the-world'),
    ('burnout-syndromes','hikari-are'),('wagakki-band','senbonzakura'),('granrodeo','can-do'),
    ('linked-horizon','guren-no-yumiya'),('yui','again'),('eve-jp','kaikai-kitan'),
    ('orange-range','asterisk'),('sim-band','the-rumbling'),('knocked-loose','blinding-faith'),
    ('electric-callboy','hypa-hypa'),('slaughter-to-prevail','baba-yaga')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
  where p.mode = 'guitar'
);
delete from public.song_tone_profiles p where p.mode = 'guitar' and p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('kessoku-band','guitar-loneliness-and-blue-planet'),('kessoku-band','ano-band'),
    ('man-with-a-mission','raise-your-flag'),('x-japan','kurenai'),('the-gazette','filth-in-the-beauty'),
    ('flow-band','go'),('scandal-band','shunkan-sentimental'),('hotei','battle-without-honor-or-humanity'),
    ('one-ok-rock','clock-strikes'),('asian-kung-fu-generation','after-dark'),('larc-en-ciel','drivers-high'),
    ('maximum-the-hormone','zetsubou-billy'),('babymetal','megitsune'),('nightmare-band','the-world'),
    ('burnout-syndromes','hikari-are'),('wagakki-band','senbonzakura'),('granrodeo','can-do'),
    ('linked-horizon','guren-no-yumiya'),('yui','again'),('eve-jp','kaikai-kitan'),
    ('orange-range','asterisk'),('sim-band','the-rumbling'),('knocked-loose','blinding-faith'),
    ('electric-callboy','hypa-hypa'),('slaughter-to-prevail','baba-yaga')
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
    ('guitar-loneliness-and-blue-planet','kessoku-band','guitar','riff','main riff + solo','distorted','j-rock','lead','intermediate',
     'Gibson Les Paul Custom (Bocchi / Hitori Gotoh)','Tube amp, driving J-rock crunch','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['THE Bocchi the Rock! song — the driving riff and outro solo that put a Les Paul Custom in ten thousand bedrooms.','Bright driving J-rock crunch; every anime guitarist''s first real challenge.'],
     array['The verse riff drives eighth-notes relentlessly.','The outro solo is Bocchi''s moment — bends must cry.'],
     'Studio recording, 2022. The Bocchi anthem.',76),
    ('ano-band','kessoku-band','guitar','riff','frantic set-piece riff','distorted','j-rock','rhythm','advanced',
     'Gibson Les Paul Custom (Kessoku Band)','Tube amp, frantic live J-rock','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The culture-festival set-piece — frantic interlocking riffing from the show''s best episode.','Urgent tight crunch; the bottleneck-slide save is canon.'],
     array['Fast alternate picking through the changes.','Play it like the room depends on you — in the show, it did.'],
     'Studio recording, 2022. The festival set-piece.',74),
    ('raise-your-flag','man-with-a-mission','guitar','riff','Gundam charge riff','distorted','j-rock','rhythm','intermediate',
     'Fender/ESP electric (Jean-Ken Johnny)','Tube amp, arena wolf-rock drive','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":5,"treble":6,"presence":6,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The Iron-Blooded Orphans opener — driving arena rock from the wolf-headed band.','Big polished drive; raise your flag, koe karashite.'],
     array['Drive the chords with the march.','The pre-chorus lifts a gear — shift with it.'],
     'Studio recording, 2016. The Gundam charge.',73),
    ('kurenai','x-japan','guitar','riff','speed-metal anthem','high_gain','j-metal','lead','advanced',
     'ESP guitars (hide / Pata)','High-gain amp, 80s speed metal','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":5,"mids":5,"treble":6,"presence":6,"reverb":2,"delay":1,"master":8}'::jsonb,
     array['The J-metal cornerstone — hide and Pata''s twin-guitar gallop under Toshi''s wail.','Searing 80s speed-metal saturation; crimson-titled, nation-defining.'],
     array['Gallop the verse riff at full sprint.','The balladic intro is a fake-out — then it detonates.'],
     'Studio recording, 1989. The J-metal cornerstone.',75),
    ('filth-in-the-beauty','the-gazette','guitar','riff','visual-kei groove','high_gain','j-metal','rhythm','intermediate',
     'ESP custom guitars (Uruha / Aoi)','High-gain amp, modern visual-kei','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The visual-kei gateway — grinding drop-tuned groove with the clean-sung chorus lift.','Thick modern saturation; the GazettE''s signature stomp.'],
     array['Chug the groove with the kick pattern.','Verse growl, chorus soar — the visual-kei formula perfected.'],
     'Studio recording, 2007. The visual-kei gateway.',73),
    ('go','flow-band','guitar','riff','Naruto sprint riff','distorted','j-rock','rhythm','beginner',
     'Electric guitar (Take / FLOW)','Tube amp, sprinting pop-punk energy','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The Naruto sprint — fighting-dreamers pop-punk drive every 2000s anime kid air-guitared.','Bright punchy drive; we are fighting dreamers!'],
     array['Drive the chords at full sprint.','Shout the gang vocals — it''s mandatory.'],
     'Studio recording, 2004. The Naruto sprint.',74),
    ('shunkan-sentimental','scandal-band','guitar','riff','FMA:B closer riff','distorted','j-rock','rhythm','beginner',
     'Fender/Epiphone electrics (Haruna / Mami)','Tube amp, bright girl-band rock','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":5,"treble":7,"presence":6,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The Fullmetal Alchemist: Brotherhood ending — SCANDAL''s brightest driving rock.','Glossy energetic drive; the girl-band that made a generation pick up guitars.'],
     array['Drive the chords with lift.','The chorus jumps the octave — jump with it.'],
     'Studio recording, 2010. The FMA:B closer.',73),
    ('battle-without-honor-or-humanity','hotei','guitar','riff','the strut riff','crunch','instrumental rock','riff','beginner',
     'Fenix/custom Telecaster-style (Tomoyasu Hotei)','Tube amp, punchy dry strut','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The Kill Bill strut — the horn-answered riff everyone knows without knowing its name.','Punchy dry crunch; Japan''s most famous guitar export.'],
     array['Stab the riff with total swagger.','Walk somewhere important while playing it.'],
     'Studio recording, 2000. The Kill Bill strut.',76),
    ('clock-strikes','one-ok-rock','guitar','riff','arena J-rock riff','distorted','j-rock','rhythm','intermediate',
     'Gibson/ESP electric (Toru Yamashita)','Tube amp, arena J-rock','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":5,"treble":6,"presence":6,"reverb":2,"delay":1,"master":8}'::jsonb,
     array['The arena chant — soaring riff under Taka''s bilingual hook.','Big polished saturation; what waits for you?'],
     array['Ring the chorus chords wide.','Build the bridge like a festival headline set.'],
     'Studio recording, 2013. The arena chant.',74),
    ('after-dark','asian-kung-fu-generation','guitar','riff','Bleach opener riff','crunch','j-rock','rhythm','intermediate',
     'Gibson Les Paul (Masafumi Gotoh / Kensuke Kita)','Tube amp, jangly AKFG crunch','Open-back combo cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The Bleach opening — AKFG''s wiry interlocking indie-rock riffing.','Wiry warm crunch; the band that soundtracked 2000s anime.'],
     array['The lead line weaves through the strums.','Tight but human — AKFG never quantized.'],
     'Studio recording, 2008. The Bleach opening.',74),
    ('drivers-high','larc-en-ciel','guitar','riff','GTO opener riff','distorted','j-rock','rhythm','intermediate',
     'ESP custom (Ken)','Tube amp, glossy speed-pop rock','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":5,"treble":7,"presence":6,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The GTO opener — Ken''s gleaming full-throttle riff.','Glossy fast drive; L''Arc at maximum velocity.'],
     array['Drive the riff at highway speed.','The chorus flies — keep your right hand loose.'],
     'Studio recording, 1999. The GTO opener.',73),
    ('zetsubou-billy','maximum-the-hormone','guitar','riff','Death Note chaos riff','high_gain','nu-metal','riff','advanced',
     'ESP electric, drop tuning (Maximum the Ryo)','High-gain amp, whiplash nu-metal','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The Death Note ending — whiplash genre-shredding: death-metal verse, candy chorus, funk break.','Brutal elastic high gain; Japan''s most gleefully unhinged band.'],
     array['Every section is a different genre — commit to each fully.','The mood swings ARE the composition.'],
     'Studio recording, 2007. The Death Note chaos.',74),
    ('megitsune','babymetal','guitar','riff','kawaii-metal gallop','high_gain','j-metal','rhythm','intermediate',
     'ESP guitars (Kami Band)','High-gain amp, precision kawaii-metal','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":5,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The fox-god gallop — Kami Band''s razor speed-metal under the traditional melody.','Surgical high gain; kitsune chants over blast-tight riffing.'],
     array['Gallop the riff with metronome discipline.','The trad-scale melody sections need clean position shifts.'],
     'Studio recording, 2014. The fox-god gallop.',73),
    ('the-world','nightmare-band','guitar','riff','Death Note opener','distorted','j-rock','rhythm','intermediate',
     'ESP electrics (Sakito / Hitsugi)','Tube amp, dark visual-kei rock','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":5,"treble":6,"presence":6,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The Death Note opening — sleek dark riffing behind the era''s most iconic anime intro.','Dark polished drive; the whole world watched this every week.'],
     array['The verse riff snakes; the chorus rings.','Light''s theme song — play it calculating.'],
     'Studio recording, 2007. The Death Note opening.',73),
    ('hikari-are','burnout-syndromes','guitar','riff','Haikyuu literary rock','crunch','j-rock','rhythm','intermediate',
     'Fender Telecaster (Kazuumi Ishida)','Tube amp, bright literary rock','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":5,"treble":7,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The Haikyuu!! Shiratorizawa opener — sprinting bright riffing with choir-boy hooks.','Gleaming urgent crunch; let there be light.'],
     array['Sprint the riff with clean articulation.','The stop-starts mirror the volleyball rallies.'],
     'Studio recording, 2016. The Haikyuu opener.',73),
    ('senbonzakura','wagakki-band','guitar','riff','shred + shamisen','high_gain','j-rock','lead','advanced',
     'ESP electric (Machiya)','High-gain amp, neo-trad shred','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":5,"mids":5,"treble":6,"presence":6,"reverb":2,"delay":1,"master":8}'::jsonb,
     array['The vocaloid classic gone traditional — Machiya''s shred racing shamisen and shakuhachi.','Fast precise high gain; a billion views of guitar-versus-shamisen.'],
     array['The lead lines race the shamisen — alternate-pick cleanly.','Trad scale runs; bend Japanese, not blues.'],
     'Studio recording, 2014. The neo-trad shred.',74),
    ('can-do','granrodeo','guitar','riff','Kuroko opener shred','distorted','j-rock','lead','intermediate',
     'ESP electric (e-ZUKA)','Tube amp, hot shreddy J-rock','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":5,"treble":6,"presence":6,"reverb":2,"delay":1,"master":8}'::jsonb,
     array['The Kuroko''s Basketball opener — e-ZUKA''s flashy runs under Kishou''s belt.','Hot flashy drive; sports-anime adrenaline in riff form.'],
     array['The fills shred between vocal lines.','Play it fast-break tempo.'],
     'Studio recording, 2012. The Kuroko opener.',72),
    ('guren-no-yumiya','linked-horizon','guitar','riff','Attack on Titan charge','distorted','j-rock','rhythm','intermediate',
     'Session electric guitars (Linked Horizon)','Tube amp, orchestral-rock charge','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":5,"treble":6,"presence":6,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The Attack on Titan charge — galloping guitars under choir and strings; the seid-ihr-das-Essen intro everyone chants.','Epic galloping drive; the most meme''d anime opening of the 2010s.'],
     array['Gallop with the snare charge.','You''re the rhythm section of an army — play like it.'],
     'Studio recording, 2013. The Titan charge.',73),
    ('again','yui','guitar','riff','FMA:B sprint','crunch','j-rock','rhythm','intermediate',
     'Fender Telecaster (YUI)','Tube amp, wiry sprint crunch','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":5,"treble":7,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The Fullmetal Alchemist: Brotherhood opener — YUI''s wiry sprinting riff.','Bright urgent crunch; one of the most-tabbed anime songs of all.'],
     array['The intro riff sprints on the high strings.','Singer-songwriter turned riff-writer — keep it wiry.'],
     'Studio recording, 2009. The FMA:B opener.',75),
    ('kaikai-kitan','eve-jp','guitar','riff','Jujutsu Kaisen riff','crunch','j-rock','rhythm','advanced',
     'Session electric guitars (Eve / Numa)','Tube amp, jittery vocaloid-rock','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The Jujutsu Kaisen opener — jittery vocaloid-style riffing at finger-twisting speed.','Wiry precise crunch; internet-rock DNA in an anime juggernaut.'],
     array['The riff jitters sixteenths — drill with a metronome.','Breathless by design; find the pocket inside the panic.'],
     'Studio recording, 2020. The JJK opener.',74),
    ('asterisk','orange-range','guitar','riff','Bleach opener bounce','crunch','j-rock','rhythm','beginner',
     'Fender electric (Naoto Hiroyama)','Tube amp, sunny Okinawa rap-rock','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":5,"treble":6,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The Bleach opening — Okinawan rap-rock bounce that launched a thousand 2004 playlists.','Sunny springy crunch; mihanaseba afureteku hikari.'],
     array['Bounce the chords with the rap cadence.','Beach-party energy over anime urgency.'],
     'Studio recording, 2004. The Bleach opener.',73),
    ('the-rumbling','sim-band','guitar','riff','AoT final-season stomp','high_gain','metalcore','rhythm','intermediate',
     'ESP electric, drop tuning (SiM)','High-gain amp, doom-stomp metalcore','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":5,"presence":5,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The Attack on Titan Final Season stomp — earth-shaking half-time metalcore for the apocalypse.','Crushing slow high gain; all I ever wanted to do was do right things.'],
     array['Stomp the half-time riff — weight over speed.','You''re scoring the end of the world; play it inevitable.'],
     'Studio recording, 2022. The Rumbling stomp.',74),
    ('blinding-faith','knocked-loose','guitar','riff','panic-chord assault','high_gain','hardcore','riff','advanced',
     'ESP/LTD electric, drop G# (Isaac Hale / Nicko Calderon)','High-gain amp, ugly hardcore assault','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":9,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The Grammy-nominated assault — panic chords, dissonant bends, and the ugliest breakdown on network TV (they played Jimmy Kimmel).','Vicious scraping high gain; hardcore''s crossover moment.'],
     array['Panic chords scream between chugs.','The tempo drags on purpose — mosh time, not grid time.'],
     'Studio recording, 2024. The crossover assault.',74),
    ('hypa-hypa','electric-callboy','guitar','riff','electrocore party riff','high_gain','metalcore','rhythm','intermediate',
     'ESP electric, drop tuning (Electric Callboy)','High-gain amp with synth party','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The gym-meme juggernaut — metalcore chugs crashing into eurodance drops.','Bouncing tight high gain; the most fun heavy band alive.'],
     array['Chug the verse; the drop is synth — mute and flex.','Irony and breakdowns in equal measure.'],
     'Studio recording, 2020. The gym-meme juggernaut.',73),
    ('baba-yaga','slaughter-to-prevail','guitar','riff','Russian deathcore stomp','high_gain','deathcore','riff','advanced',
     'Aristides 8-string, drop E (Jack Simmons)','High-gain amp, subterranean deathcore','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":9,"bass":7,"mids":4,"treble":5,"presence":6,"reverb":0,"delay":0,"master":8}'::jsonb,
     array['The gym-deathcore standard — 8-string sub-riffing under Alex Terrible''s inhuman lows.','Seismic scooped high gain; the folklore witch as a breakdown.'],
     array['8-string territory — drop your lowest string and chug.','Groove first: deathcore that swings.'],
     'Studio recording, 2021. The gym-deathcore standard.',73)
) as c(
  song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence
)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;
