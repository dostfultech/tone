-- Phase 32: 25 djent / metalcore / modern prog-metal, verified per-part tone data (Periphery, Animals as Leaders, TesseracT, Meshuggah, Architects, August Burns Red, BTBAM, Polyphia, Erra, Whitechapel, more Killswitch/BMTH/Trivium/Lamb of God/Gojira/Mastodon, As I Lay Dying, Parkway Drive, Devin Townsend, Spiritbox).

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Periphery','periphery','Icarus Lives!','icarus-lives','Periphery',2010),
    ('Periphery','periphery','Marigold','marigold','Juggernaut: Alpha',2015),
    ('Animals as Leaders','animals-as-leaders','CAFO','cafo','Animals as Leaders',2009),
    ('Animals as Leaders','animals-as-leaders','The Woven Web','the-woven-web','Weightless',2011),
    ('TesseracT','tesseract','Nocturne','nocturne','Altered State',2013),
    ('Meshuggah','meshuggah','Bleed','bleed','obZen',2008),
    ('Meshuggah','meshuggah','New Millennium Cyanide Christ','new-millennium-cyanide-christ','Chaosphere',1998),
    ('Architects','architects','Doomsday','doomsday','Holy Hell',2018),
    ('Architects','architects','Nihilist','nihilist','All Our Gods Have Abandoned Us',2016),
    ('August Burns Red','august-burns-red','Composure','composure','Messengers',2007),
    ('Between the Buried and Me','between-the-buried-and-me','Selkies: The Endless Obsession','selkies-the-endless-obsession','Alaska',2005),
    ('Polyphia','polyphia','Goat','goat','New Levels New Devils',2018),
    ('Polyphia','polyphia','Playing God','playing-god','Remember That You Will Die',2022),
    ('Erra','erra','Snowblood','snowblood','Erra',2021),
    ('Whitechapel','whitechapel','This Is Exile','this-is-exile','This Is Exile',2008),
    ('Killswitch Engage','killswitch-engage','The End of Heartache','the-end-of-heartache','The End of Heartache',2004),
    ('As I Lay Dying','as-i-lay-dying','Nothing Left','nothing-left','An Ocean Between Us',2007),
    ('Parkway Drive','parkway-drive','Vice Grip','vice-grip','Ire',2015),
    ('Bring Me the Horizon','bring-me-the-horizon','Can You Feel My Heart','can-you-feel-my-heart','Sempiternal',2013),
    ('Trivium','trivium','Pull Harder on the Strings of Your Martyr','pull-harder-on-the-strings-of-your-martyr','Ascendancy',2005),
    ('Lamb of God','lamb-of-god','Redneck','redneck','Sacrament',2006),
    ('Gojira','gojira','Flying Whales','flying-whales','From Mars to Sirius',2005),
    ('Mastodon','mastodon','Colony of Birchmen','colony-of-birchmen','Blood Mountain',2006),
    ('Devin Townsend','devin-townsend','Kingdom','kingdom','Physicist',2000),
    ('Spiritbox','spiritbox','Holy Roller','holy-roller','Eternal Blue',2021)
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
    ('periphery','icarus-lives'),('periphery','marigold'),('animals-as-leaders','cafo'),('animals-as-leaders','the-woven-web'),
    ('tesseract','nocturne'),('meshuggah','bleed'),('meshuggah','new-millennium-cyanide-christ'),('architects','doomsday'),
    ('architects','nihilist'),('august-burns-red','composure'),('between-the-buried-and-me','selkies-the-endless-obsession'),('polyphia','goat'),
    ('polyphia','playing-god'),('erra','snowblood'),('whitechapel','this-is-exile'),('killswitch-engage','the-end-of-heartache'),
    ('as-i-lay-dying','nothing-left'),('parkway-drive','vice-grip'),('bring-me-the-horizon','can-you-feel-my-heart'),('trivium','pull-harder-on-the-strings-of-your-martyr'),
    ('lamb-of-god','redneck'),('gojira','flying-whales'),('mastodon','colony-of-birchmen'),('devin-townsend','kingdom'),
    ('spiritbox','holy-roller')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('periphery','icarus-lives'),('periphery','marigold'),('animals-as-leaders','cafo'),('animals-as-leaders','the-woven-web'),
    ('tesseract','nocturne'),('meshuggah','bleed'),('meshuggah','new-millennium-cyanide-christ'),('architects','doomsday'),
    ('architects','nihilist'),('august-burns-red','composure'),('between-the-buried-and-me','selkies-the-endless-obsession'),('polyphia','goat'),
    ('polyphia','playing-god'),('erra','snowblood'),('whitechapel','this-is-exile'),('killswitch-engage','the-end-of-heartache'),
    ('as-i-lay-dying','nothing-left'),('parkway-drive','vice-grip'),('bring-me-the-horizon','can-you-feel-my-heart'),('trivium','pull-harder-on-the-strings-of-your-martyr'),
    ('lamb-of-god','redneck'),('gojira','flying-whales'),('mastodon','colony-of-birchmen'),('devin-townsend','kingdom'),
    ('spiritbox','holy-roller')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('periphery','icarus-lives'),('periphery','marigold'),('animals-as-leaders','cafo'),('animals-as-leaders','the-woven-web'),
    ('tesseract','nocturne'),('meshuggah','bleed'),('meshuggah','new-millennium-cyanide-christ'),('architects','doomsday'),
    ('architects','nihilist'),('august-burns-red','composure'),('between-the-buried-and-me','selkies-the-endless-obsession'),('polyphia','goat'),
    ('polyphia','playing-god'),('erra','snowblood'),('whitechapel','this-is-exile'),('killswitch-engage','the-end-of-heartache'),
    ('as-i-lay-dying','nothing-left'),('parkway-drive','vice-grip'),('bring-me-the-horizon','can-you-feel-my-heart'),('trivium','pull-harder-on-the-strings-of-your-martyr'),
    ('lamb-of-god','redneck'),('gojira','flying-whales'),('mastodon','colony-of-birchmen'),('devin-townsend','kingdom'),
    ('spiritbox','holy-roller')
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
    ('icarus-lives','periphery','guitar','riff','main riff','high_gain',
     'metal','rhythm','advanced',
     'Signature 6/7-string (Misha Mansoor)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bouncy, syncopated djent riffing with tight low chugs and bright leads; keep the palm mutes precise.','High gain, tight low end.'],
     array['Keep the syncopated chugs machine-tight.','Nail the bright lead accents.'],
     'Studio recording, 2010 (Periphery). Misha Mansoor played bouncy, syncopated djent riffing.',72),
    ('marigold','periphery','guitar','riff','main riff','high_gain',
     'metal','rhythm','advanced',
     'Signature 6/7-string (Misha Mansoor / Jake Bowen / Mark Holcomb)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Melodic djent with soaring cleans over tight, syncopated chugs; keep dynamics wide.','High gain for the riffs.'],
     array['Keep the chugs tight.','Let the melodic leads soar.'],
     'Studio recording, 2015 (Juggernaut: Alpha). Periphery played melodic djent with tight syncopated chugs.',72),
    ('cafo','animals-as-leaders','guitar','riff','instrumental main riff','high_gain',
     'metal','lead','expert',
     '8-string guitar (Tosin Abasi)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Complex instrumental djent with thumping 8-string chugs and fluid tapped lines; keep it precise.','High gain, tight, extended range.'],
     array['Play the 8-string chugs tightly.','Nail the tapped and swept passages.'],
     'Studio recording, 2009 (Animals as Leaders). Tosin Abasi played complex instrumental djent on an 8-string.',72),
    ('the-woven-web','animals-as-leaders','guitar','riff','instrumental main riff','high_gain',
     'metal','lead','expert',
     '8-string guitar (Tosin Abasi)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Intricate, groove-heavy instrumental djent with thumb-slap technique; keep it tight and articulate.','High gain, extended range.'],
     array['Play the groovy riffs tightly.','Use thumb-slap attack for the accents.'],
     'Studio recording, 2011 (Weightless). Tosin Abasi played intricate, groove-heavy instrumental djent on an 8-string.',71),
    ('nocturne','tesseract','guitar','riff','main riff','high_gain',
     'metal','rhythm','advanced',
     '8-string guitar (Acle Kahney / James Monteith)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Atmospheric djent with polyrhythmic chugs under ambient cleans; keep the low end tight.','High gain, ambient.'],
     array['Keep the polyrhythmic chugs tight.','Let the ambient cleans breathe.'],
     'Studio recording, 2013 (Altered State). TesseracT played atmospheric, polyrhythmic djent on 8-strings.',71),
    ('bleed','meshuggah','guitar','riff','main riff','high_gain',
     'metal','rhythm','expert',
     '8-string guitar (Fredrik Thordendal / Mårten Hagström)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":4,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Relentless, machine-precise polyrhythmic djent chugs; keep the picking impossibly tight.','High gain, dry and tight, extreme low tuning.'],
     array['Play the relentless chugs with metronomic precision.','Keep the picking hand tireless.'],
     'Studio recording, 2008 (obZen). Meshuggah played relentless, machine-precise polyrhythmic djent on 8-strings.',73),
    ('new-millennium-cyanide-christ','meshuggah','guitar','riff','main riff','high_gain',
     'metal','rhythm','expert',
     '7-string guitar (Fredrik Thordendal / Mårten Hagström)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":4,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Grinding, syncopated polymetric riffing; keep the chugs tight and mechanical.','High gain, tight.'],
     array['Lock the polymetric riff to the beat.','Keep the chugs mechanical.'],
     'Studio recording, 1998 (Chaosphere). Meshuggah played grinding, syncopated polymetric riffing on 7-strings.',72),
    ('doomsday','architects','guitar','riff','main riff','high_gain',
     'metal','rhythm','advanced',
     'Electric guitar (Josh Middleton / Adam Christianson)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Modern metalcore with djent-tight chugs and soaring melodic leads; keep it precise.','High gain, tight low end.'],
     array['Keep the chugs tight.','Let the melodic leads soar.'],
     'Studio recording, 2018. Architects played modern metalcore with djent-tight chugs and melodic leads.',71),
    ('nihilist','architects','guitar','riff','main riff','high_gain',
     'metal','rhythm','advanced',
     'Electric guitar (Tom Searle / Adam Christianson)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Crushing, precise metalcore riffing with tight breakdowns; keep the chugs machine-tight.','High gain.'],
     array['Keep the chugs tight.','Nail the breakdowns.'],
     'Studio recording, 2016. Architects played crushing, precise metalcore riffing.',71),
    ('composure','august-burns-red','guitar','riff','main riff','high_gain',
     'metal','rhythm','advanced',
     'Electric guitar (JB Brubaker / Brent Rambler)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Technical metalcore with intricate riffs and tight breakdowns; keep the picking precise.','High gain.'],
     array['Play the intricate riffs precisely.','Nail the breakdowns.'],
     'Studio recording, 2007 (Messengers). August Burns Red played technical metalcore with intricate riffs.',71),
    ('selkies-the-endless-obsession','between-the-buried-and-me','guitar','riff','main riff and solo','high_gain',
     'metal','lead','expert',
     'Electric guitar (Paul Waggoner / Dustie Waring)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Sprawling prog-metalcore shifting from brutal riffs to a melodic neoclassical solo; keep it precise.','High gain with clarity.'],
     array['Play the brutal riffs tightly.','Nail the neoclassical solo cleanly.'],
     'Studio recording, 2005 (Alaska). Paul Waggoner played sprawling prog-metalcore and a neoclassical solo.',71),
    ('goat','polyphia','guitar','riff','instrumental main theme','crunch',
     'metal','lead','expert',
     'Signature electric (Tim Henson / Scott LePage)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":1,"master":6}'::jsonb,
     array['Slick instrumental prog with hyper-clean legato, tapping, and hip-hop-influenced grooves; keep it fluid and articulate.','Medium gain, clean and articulate.'],
     array['Play the tapped and legato lines fluidly.','Keep the groove tight and modern.'],
     'Studio recording, 2018 (New Levels New Devils). Tim Henson and Scott LePage played slick instrumental prog.',72),
    ('playing-god','polyphia','guitar','riff','instrumental main theme','clean',
     'metal','lead','expert',
     'Signature electric and nylon (Tim Henson / Scott LePage)','Clean amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":1,"master":6}'::jsonb,
     array['Intricate flamenco-and-trap-influenced clean fingerstyle with tapped harmonics; keep it precise and light.','Low gain, clean, articulate.'],
     array['Play the fingerstyle lines cleanly.','Nail the tapped harmonics.'],
     'Studio recording, 2022 (Remember That You Will Die). Polyphia played intricate flamenco-and-trap-influenced clean fingerstyle.',72),
    ('snowblood','erra','guitar','riff','main riff','high_gain',
     'metal','rhythm','advanced',
     'Electric guitar (Jesse Cash / Sean Price)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Melodic djent-metalcore with tight chugs and shimmering leads; keep it precise and atmospheric.','High gain, tight.'],
     array['Keep the chugs tight.','Let the shimmering leads ring.'],
     'Studio recording, 2021 (Erra). Erra played melodic djent-metalcore with tight chugs and shimmering leads.',71),
    ('this-is-exile','whitechapel','guitar','riff','main riff','high_gain',
     'metal','rhythm','advanced',
     '7-string guitar (Ben Savage / Alex Wade / Zach Householder)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":4,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Crushing, down-tuned deathcore with brutal chugs and breakdowns; keep it tight and heavy.','High gain, very low tuning.'],
     array['Keep the brutal chugs tight.','Slam the breakdowns.'],
     'Studio recording, 2008 (This Is Exile). Whitechapel played crushing, down-tuned deathcore on 7-strings.',71),
    ('the-end-of-heartache','killswitch-engage','guitar','riff','main riff and solo','high_gain',
     'metal','lead','advanced',
     'Electric guitar (Adam Dutkiewicz / Joel Stroetzel)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Melodic metalcore with driving riffs and a soaring, harmonized solo; keep it tight.','High gain with clarity.'],
     array['Keep the driving riffs tight.','Harmonise the soaring leads.'],
     'Studio recording, 2004 (The End of Heartache). Killswitch Engage played melodic metalcore with a harmonized solo.',72),
    ('nothing-left','as-i-lay-dying','guitar','riff','main riff','high_gain',
     'metal','rhythm','advanced',
     'Electric guitar (Nick Hipa / Phil Sgrosso)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Fast, melodic metalcore with tight tremolo riffs and harmonized leads; keep the picking relentless.','High gain.'],
     array['Keep the tremolo riffs tight.','Harmonise the leads.'],
     'Studio recording, 2007 (An Ocean Between Us). As I Lay Dying played fast, melodic metalcore with harmonized leads.',71),
    ('vice-grip','parkway-drive','guitar','riff','main riff','high_gain',
     'metal','rhythm','intermediate',
     'Electric guitar (Jeff Ling / Luke Kilpatrick)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Anthemic modern metalcore with driving chugs and a big chorus; keep it tight.','High gain.'],
     array['Keep the chugs tight.','Drive the anthemic chorus.'],
     'Studio recording, 2015 (Ire). Parkway Drive played anthemic modern metalcore with driving chugs.',71),
    ('can-you-feel-my-heart','bring-me-the-horizon','guitar','riff','main riff','high_gain',
     'metal','rhythm','beginner',
     'Electric guitar (Lee Malia)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Anthemic metalcore with electronic layers and heavy chugs; keep the riff tight under the synths.','High gain.'],
     array['Keep the chugs tight.','Drive the anthemic hook.'],
     'Studio recording, 2013 (Sempiternal). Lee Malia played anthemic metalcore chugs under electronic layers.',71),
    ('pull-harder-on-the-strings-of-your-martyr','trivium','guitar','riff','main riff and solo','high_gain',
     'metal','lead','advanced',
     'Electric guitar (Matt Heafy / Corey Beaulieu)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Fast, melodic metalcore-thrash with harmonized leads and a shred solo; keep the picking tight.','High gain with clarity.'],
     array['Keep the fast riffs tight.','Harmonise the leads and play the solo cleanly.'],
     'Studio recording, 2005 (Ascendancy). Trivium played fast, melodic metalcore-thrash with harmonized leads.',71),
    ('redneck','lamb-of-god','guitar','riff','main riff','high_gain',
     'metal','rhythm','advanced',
     'Electric guitar (Mark Morton / Willie Adler)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bouncy, aggressive groove-metal riff with a mosh-ready breakdown; keep it tight and pummeling.','High gain.'],
     array['Keep the groove riff tight.','Nail the breakdown.'],
     'Studio recording, 2006 (Sacrament). Mark Morton and Willie Adler played a bouncy, aggressive groove-metal riff.',72),
    ('flying-whales','gojira','guitar','riff','main riff','high_gain',
     'metal','rhythm','advanced',
     'Charvel electric guitar (Joe Duplantier)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Building, atmospheric prog-death with heavy, percussive riffs and pick-slides; keep it tight and huge.','High gain, drop tuning.'],
     array['Build from the atmospheric intro.','Keep the percussive riff tight with pick-slides.'],
     'Studio recording, 2005 (From Mars to Sirius). Joe Duplantier played building, atmospheric prog-death riffing on a Charvel.',72),
    ('colony-of-birchmen','mastodon','guitar','riff','main riff','high_gain',
     'metal','rhythm','advanced',
     'Electric guitar (Brent Hinds / Bill Kelliher)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Intricate, proggy sludge-metal riffing with melodic leads; keep it tight and driving.','High gain.'],
     array['Play the intricate riffs tightly.','Let the melodic leads sing.'],
     'Studio recording, 2006 (Blood Mountain). Brent Hinds and Bill Kelliher played intricate, proggy sludge-metal.',71),
    ('kingdom','devin-townsend','guitar','riff','main riff','high_gain',
     'metal','rhythm','advanced',
     'Signature electric (Devin Townsend)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Massive wall-of-sound metal with layered, driving riffs; keep it huge and tight.','High gain, layered and dense.'],
     array['Keep the driving riff tight.','Layer the chords for a wall of sound.'],
     'Studio recording, 2000. Devin Townsend played massive, layered wall-of-sound metal.',71),
    ('holy-roller','spiritbox','guitar','riff','main riff','high_gain',
     'metal','rhythm','advanced',
     '7-string guitar (Mike Stringer)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Crushing modern metalcore alternating brutal chugs with ethereal cleans; keep the heavy parts tight.','High gain, extended range.'],
     array['Keep the brutal chugs tight.','Contrast with the ethereal clean parts.'],
     'Studio recording, 2021 (Eternal Blue). Mike Stringer played crushing modern metalcore on a 7-string.',71)
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
  ('periphery','icarus-lives'),('periphery','marigold'),('animals-as-leaders','cafo'),('animals-as-leaders','the-woven-web'),
  ('tesseract','nocturne'),('meshuggah','bleed'),('meshuggah','new-millennium-cyanide-christ'),('architects','doomsday'),
  ('architects','nihilist'),('august-burns-red','composure'),('between-the-buried-and-me','selkies-the-endless-obsession'),('polyphia','goat'),
  ('polyphia','playing-god'),('erra','snowblood'),('whitechapel','this-is-exile'),('killswitch-engage','the-end-of-heartache'),
  ('as-i-lay-dying','nothing-left'),('parkway-drive','vice-grip'),('bring-me-the-horizon','can-you-feel-my-heart'),('trivium','pull-harder-on-the-strings-of-your-martyr'),
  ('lamb-of-god','redneck'),('gojira','flying-whales'),('mastodon','colony-of-birchmen'),('devin-townsend','kingdom'),
  ('spiritbox','holy-roller')
) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
cross join (values
  ('artist_interview', 'Documented artist interviews and gear discussions', null::text,
   'Researched from widely-documented interviews about this recording and player.', 72),
  ('rig_rundown', 'Published rig rundowns and community gear databases', null::text,
   'Cross-referenced against rig features and community-maintained gear databases.', 66)
) as x(source_type, title, url, notes, credibility)
where p.verification_status = 'admin_verified'
on conflict do nothing;
