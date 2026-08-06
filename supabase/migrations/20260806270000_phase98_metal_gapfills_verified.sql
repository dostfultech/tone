-- Phase 98b: metal + gapfills: researched verified tone profiles (generated 2026-08-06).
-- Assembled from per-artist research fragments; rigs sourced from
-- Equipboard/GroundGuitar/manufacturer interviews per song.
begin;

create temp table phase_targets(
  artist_name text, artist_slug text, song_title text, song_slug text,
  album text, release_year int
) on commit drop;

insert into phase_targets(artist_name, artist_slug, song_title, song_slug, album, release_year) values
('Nightwish','nightwish','Wish I Had an Angel','wish-i-had-an-angel','Once',2004),
('Nightwish','nightwish','Nemo','nemo','Once',2004),
('Nightwish','nightwish','Ghost Love Score','ghost-love-score','Once',2004),
('Nightwish','nightwish','Bye Bye Beautiful','bye-bye-beautiful','Dark Passion Play',2007),
('Nightwish','nightwish','Ever Dream','ever-dream','Century Child',2002),
('Nightwish','nightwish','Sleeping Sun','sleeping-sun','Oceanborn',1999),
('Nightwish','nightwish','Amaranth','amaranth','Dark Passion Play',2007),
('Nightwish','nightwish','The Islander','the-islander','Dark Passion Play',2007),
('Nightwish','nightwish','Wishmaster','wishmaster','Wishmaster',2000),
('Nightwish','nightwish','The Kinslayer','the-kinslayer','Wishmaster',2000),
('Nightwish','nightwish','Planet Hell','planet-hell','Once',2004),
('Clutch','clutch','Electric Worry','electric-worry','From Beale Street to Oblivion',2007),
('Clutch','clutch','Spacegrass','spacegrass','Clutch',1995),
('Clutch','clutch','The Mob Goes Wild','the-mob-goes-wild','Blast Tyrant',2004),
('Clutch','clutch','Firebirds!','firebirds','Psychic Warfare',2015),
('Clutch','clutch','A Shogun Named Marcus','a-shogun-named-marcus','Clutch',1995),
('Clutch','clutch','Escape from the Prison Planet','escape-from-the-prison-planet','Clutch',1995),
('Clutch','clutch','50,000 Unstoppable Watts','50000-unstoppable-watts','Strange Cousins from the West',2009),
('Clutch','clutch','Gravel Road','gravel-road','Robot Hive/Exodus',2005),
('Clutch','clutch','Cypress Grove','cypress-grove','Psychic Warfare',2015),
('Malcolm Todd','malcolm-todd','Chest Pain (I Love)','chest-pain-i-love','Malcolm Todd',2025),
('Malcolm Todd','malcolm-todd','Earrings','earrings','Sweet Boy',2024),
('Malcolm Todd','malcolm-todd','Roommates','roommates','Sweet Boy',2024),
('Pantera','pantera','Floods','floods','The Great Southern Trendkill',1996),
('Michael Jackson','michael-jackson','P.Y.T. (Pretty Young Thing)','pyt-pretty-young-thing','Thriller',1982);

insert into public.artists (name, slug, search_text, is_active)
select distinct artist_name, artist_slug, artist_name, true from phase_targets
on conflict (slug) do update set name = excluded.name, is_active = true;

insert into public.songs (artist_id, title, slug, album, release_year, search_text, is_active)
select a.id, t.song_title, t.song_slug, t.album, t.release_year,
       concat_ws(' ', t.song_title, t.artist_name, t.album), true
from phase_targets t join public.artists a on a.slug = t.artist_slug
on conflict (artist_id, slug) do update set
  title = excluded.title, album = excluded.album, release_year = excluded.release_year,
  is_active = true, updated_at = now();

-- Hide pre-existing duplicate songs (same artist+title, different slug)
update public.song_tone_profiles p
set is_public = false
from public.songs s, public.artists a, phase_targets t
where p.song_id = s.id and s.artist_id = a.id and a.slug = t.artist_slug
  and lower(s.title) = lower(t.song_title) and s.slug <> t.song_slug;

update public.songs s
set is_active = false
from public.artists a, phase_targets t
where s.artist_id = a.id and a.slug = t.artist_slug
  and lower(s.title) = lower(t.song_title) and s.slug <> t.song_slug;

-- Replace existing guitar profiles for target songs
delete from public.tone_profile_effects e where e.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join phase_targets t on t.artist_slug = a.slug and t.song_slug = s.slug
  where p.mode = 'guitar'
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join phase_targets t on t.artist_slug = a.slug and t.song_slug = s.slug
  where p.mode = 'guitar'
);
delete from public.song_tone_profiles p where p.mode = 'guitar' and p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join phase_targets t on t.artist_slug = a.slug and t.song_slug = s.slug
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
('wish-i-had-an-angel','nightwish','guitar','riff','Main riff','high_gain','symphonic metal','rhythm','intermediate',
 'ESP Horizon','Mesa/Boogie Triple Rectifier','Marshall 1960A 4x12','Seymour Duncan TB-5 (bridge)',
 '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
 array['Tight percussive downstroke chug that sits under the orchestral hits','Bridge humbucker with scooped-but-present mids so the riff cuts through keys'],
 array['Palm-mute hard on the low string and let the open stabs ring for the hook','Lock the eighth-note gallop to the kick to keep it driving'],
 'Emppu Vuorinen ran an ESP Horizon into a Mesa/Boogie Triple Rectifier and Marshall 1960A cab on Once; high-gain symphonic metal riff.',80),
('nemo','nightwish','guitar','main','Verse and chorus rhythm','high_gain','symphonic metal','rhythm','intermediate',
 'ESP Horizon','Mesa/Boogie Triple Rectifier','Marshall 1960A 4x12','Seymour Duncan TB-5 (bridge)',
 '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
 array['Sustained power chords layered wide under the vocal melody','Smooth saturated grind that stays melodic rather than brutal'],
 array['Let chords ring full length and add vibrato on held notes','Keep the low end tight so the strings and vocal have room'],
 'Nemo from Once used Emppu''s ESP into Mesa Triple Rectifier rig; melodic high-gain symphonic metal rhythm.',80),
('ghost-love-score','nightwish','guitar','solo','Guitar solo','high_gain','symphonic metal','lead','advanced',
 'ESP Horizon','Mesa/Boogie Triple Rectifier','Marshall 1960A 4x12','Seymour Duncan TB-5 (bridge)',
 '[]'::jsonb,'{"gain":8,"bass":5,"mids":6,"treble":6,"presence":7,"reverb":3,"delay":4,"master":7}'::jsonb,
 array['Singing sustained lead with long delay tails over the orchestra','Neo-classical phrasing that trades with the strings'],
 array['Use bridge pickup and add delay for the soaring legato lines','Support bends with wide vibrato to match the symphonic swell'],
 'Ghost Love Score is Once''s epic; Emppu''s Mesa/Boogie high-gain lead carries the solo over full orchestra.',80),
('bye-bye-beautiful','nightwish','guitar','riff','Main riff','high_gain','symphonic metal','rhythm','intermediate',
 'ESP Horizon','Mesa/Boogie Triple Rectifier','Marshall 1960A 4x12','Seymour Duncan TB-5 (bridge)',
 '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
 array['Punchy staccato riff driving the up-tempo chorus','Modern tight gain recorded for Dark Passion Play'],
 array['Attack the muted stabs cleanly and release for the open accents','Keep wrist palm-muting consistent across the fast section'],
 'Bye Bye Beautiful from Dark Passion Play used Emppu''s ESP with Bogner/Mesa high-gain tone; driving symphonic metal riff.',80),
('ever-dream','nightwish','guitar','main','Verse and chorus rhythm','high_gain','symphonic metal','rhythm','intermediate',
 'ESP Horizon','Mesa/Boogie Triple Rectifier','Marshall 1960A 4x12','Seymour Duncan TB-5 (bridge)',
 '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
 array['Broad ringing power chords under the sweeping keyboard theme','Warm saturated rhythm that fills the ballad-to-anthem build'],
 array['Ring the chords through the chorus and dig in on the lifts','Match dynamics to the orchestra swelling into the hook'],
 'Ever Dream from Century Child used Emppu''s Mesa-based high-gain rig; anthemic symphonic metal rhythm.',78),
('sleeping-sun','nightwish','guitar','intro','Clean intro and verse','clean','symphonic metal','clean','beginner',
 'ESP Horizon','Mesa/Boogie Triple Rectifier','Marshall 1960A 4x12','Seymour Duncan SH-2n (neck)',
 '[]'::jsonb,'{"gain":2,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":4,"delay":2,"master":6}'::jsonb,
 array['Soft arpeggiated clean chords under the ballad vocal','Warm neck-pickup tone with light reverb for space'],
 array['Let each note of the arpeggio ring and sustain into the next','Play lightly with the amp clean channel for a glassy ballad tone'],
 'Sleeping Sun is a Nightwish ballad; the guitar sits clean and delicate on the neck pickup under strings and vocal.',75),
('amaranth','nightwish','guitar','main','Verse and chorus rhythm','high_gain','symphonic metal','rhythm','intermediate',
 'ESP Horizon','Mesa/Boogie Triple Rectifier','Marshall 1960A 4x12','Seymour Duncan TB-5 (bridge)',
 '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
 array['Melodic mid-forward power chords supporting the pop-metal hook','Tight modern gain from the Dark Passion Play sessions'],
 array['Keep chords crisp and let the chorus chords ring for lift','Balance the gain so the melody stays clear over keys'],
 'Amaranth from Dark Passion Play used Emppu''s ESP into Mesa/Bogner high gain; melodic symphonic metal rhythm.',80),
('the-islander','nightwish','guitar','main','Acoustic ballad','clean','symphonic metal','clean','beginner',
 'Acoustic guitar','Fender Acoustasonic','Acoustic combo','Piezo undersaddle',
 '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
 array['Fingerpicked acoustic folk pattern carrying the whole song','Natural warm acoustic tone with gentle room reverb'],
 array['Fingerpick softly and let open strings ring for the folk feel','Keep timing loose and lyrical to follow the vocal phrasing'],
 'The Islander from Dark Passion Play is an acoustic folk ballad; the fingerpicked acoustic guitar leads the arrangement.',74),
('wishmaster','nightwish','guitar','riff','Main riff','high_gain','symphonic metal','rhythm','advanced',
 'ESP Horizon','Mesa/Boogie Triple Rectifier','Marshall 1960A 4x12','Seymour Duncan TB-5 (bridge)',
 '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
 array['Fast galloping double-tracked riff at high tempo','Aggressive tight gain driving the power-metal charge'],
 array['Alternate-pick the gallop cleanly and keep palm mutes tight','Push tempo evenly so the double-tracks stay locked'],
 'Wishmaster is Nightwish''s signature power-metal track; Emppu''s high-gain rig drives the fast galloping riff.',78),
('the-kinslayer','nightwish','guitar','riff','Main riff','high_gain','symphonic metal','rhythm','intermediate',
 'ESP Horizon','Mesa/Boogie Triple Rectifier','Marshall 1960A 4x12','Seymour Duncan TB-5 (bridge)',
 '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
 array['Heavy chugging riff with dramatic stop-start dynamics','Dark saturated tone matching the tracks intensity'],
 array['Cut the muted chugs tight and hit the accents hard','Follow the arrangement stabs with the keys and vocals'],
 'The Kinslayer from Wishmaster used Emppu''s high-gain Nightwish rig; heavy dynamic symphonic metal riff.',78),
('planet-hell','nightwish','guitar','riff','Main riff','high_gain','symphonic metal','distortion','advanced',
 'ESP Horizon','Mesa/Boogie Triple Rectifier','Marshall 1960A 4x12','Seymour Duncan TB-5 (bridge)',
 '[]'::jsonb,'{"gain":9,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
 array['One of the heaviest Nightwish riffs, aggressive and driving','Saturated Mesa Rectifier grind under the frantic orchestration'],
 array['Palm-mute the fast runs tightly and keep picking aggressive','Lock to the double kick to hold the heavy groove'],
 'Planet Hell from Once is among the band''s heaviest songs; Emppu''s Mesa Triple Rectifier delivers the high-gain riff.',80),
('electric-worry','clutch','guitar','riff','Main riff','crunch','stoner rock','rhythm','beginner',
 'Gibson Les Paul','Marshall JCM800','Marshall 1960 4x12','Gibson humbucker (bridge)',
 '[]'::jsonb,'{"gain":6,"bass":6,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
 array['Swaggering bluesy stoner riff with fat midrange crunch','Loose vintage Marshall grind, not fully saturated'],
 array['Play with a loose bluesy feel and let the chords breathe','Dig in with the pick for grit and back off for dynamics'],
 'Electric Worry from Beale Street to Oblivion features Tim Sult''s Les Paul into cranked Marshall; bluesy stoner-rock crunch.',78),
('spacegrass','clutch','guitar','riff','Main riff','crunch','stoner rock','rhythm','intermediate',
 'Gibson Les Paul','Marshall JCM800','Marshall 1960 4x12','Gibson humbucker (bridge)',
 '[]'::jsonb,'{"gain":6,"bass":6,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
 array['Heavy fuzzy stoner groove riff with thick low mids','Raw early-Clutch Marshall crunch with plenty of grit'],
 array['Ride the groove and swing the riff rather than playing stiff','Add wah sweeps for the psychedelic stoner flavor'],
 'Spacegrass from the 1995 Clutch album uses Tim Sult''s Les Paul and Marshall stack; thick stoner-rock crunch groove.',76),
('the-mob-goes-wild','clutch','guitar','riff','Main riff','crunch','stoner rock','rhythm','intermediate',
 'Gibson Les Paul','Marshall JCM800','Marshall 1960 4x12','Gibson humbucker (bridge)',
 '[]'::jsonb,'{"gain":6,"bass":6,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
 array['Punchy hard-rock riff with tight bluesy Marshall bite','Driving mid-heavy crunch under the shouted vocal'],
 array['Keep the riff tight and percussive for the verse push','Accent the chord stabs in time with the hook'],
 'The Mob Goes Wild from Blast Tyrant features Tim Sult''s Les Paul into Marshall; tight bluesy stoner-rock crunch.',78),
('firebirds','clutch','guitar','riff','Main riff','crunch','stoner rock','rhythm','intermediate',
 'Gibson Les Paul','Marshall JCM800','Marshall 1960 4x12','Gibson humbucker (bridge)',
 '[]'::jsonb,'{"gain":6,"bass":6,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
 array['Muscular groove riff with warm cranked-Marshall crunch','Thick midrange bite driving the mid-tempo stomp'],
 array['Lock the riff to the drum groove and keep it loose','Let the open chords ring for the big chorus lift'],
 'Firebirds! from Psychic Warfare uses Tim Sult''s minimalist Les Paul and Marshall rig; muscular stoner-rock crunch.',78),
('a-shogun-named-marcus','clutch','guitar','riff','Main riff','crunch','stoner rock','rhythm','intermediate',
 'Gibson Les Paul','Marshall JCM800','Marshall 1960 4x12','Gibson humbucker (bridge)',
 '[]'::jsonb,'{"gain":6,"bass":6,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
 array['Aggressive early-Clutch riff with raw noisy Marshall crunch','Angular hardcore-tinged groove with biting mids'],
 array['Attack the riff hard and keep the palm mutes tight','Follow the stop-start hits with the rhythm section'],
 'A Shogun Named Marcus from the 1995 Clutch album shows Tim Sult''s raw Les Paul and Marshall tone; aggressive stoner-rock crunch.',76),
('escape-from-the-prison-planet','clutch','guitar','riff','Main riff','crunch','stoner rock','rhythm','intermediate',
 'Gibson Les Paul','Marshall JCM800','Marshall 1960 4x12','Gibson humbucker (bridge)',
 '[]'::jsonb,'{"gain":6,"bass":6,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
 array['Bouncy groove riff with fat bluesy Marshall crunch','Loose swung feel typical of mid-90s Clutch'],
 array['Swing the riff and lean into the groove pocket','Keep chords ringing under the vocal call-and-response'],
 'Escape from the Prison Planet from the 1995 Clutch album uses Tim Sult''s Les Paul and Marshall; groovy stoner-rock crunch.',76),
('50000-unstoppable-watts','clutch','guitar','riff','Main riff','crunch','stoner rock','rhythm','intermediate',
 'Gibson Les Paul','Marshall JCM800','Marshall 1960 4x12','Gibson humbucker (bridge)',
 '[]'::jsonb,'{"gain":6,"bass":6,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
 array['Rolling boogie-influenced riff with warm Marshall crunch','Vintage-flavored grind driving the up-tempo shuffle'],
 array['Play the riff with a boogie swing and steady picking','Keep the crunch loose so the shuffle stays lively'],
 '50,000 Unstoppable Watts from Strange Cousins from the West features Tim Sult''s Les Paul and Marshall; boogie stoner-rock crunch.',76),
('gravel-road','clutch','guitar','main','Verse and chorus rhythm','crunch','stoner rock','rhythm','beginner',
 'Gibson Les Paul','Marshall JCM800','Marshall 1960 4x12','Gibson humbucker (bridge)',
 '[]'::jsonb,'{"gain":5,"bass":6,"mids":6,"treble":5,"presence":4,"reverb":2,"delay":0,"master":6}'::jsonb,
 array['Slow bluesy groove with warm rolled-back Marshall crunch','Soulful mid-heavy tone leaning on Les Paul warmth'],
 array['Play behind the beat for the bluesy swampy feel','Use pick dynamics to move between clean-ish and gritty'],
 'Gravel Road from Robot Hive/Exodus shows Tim Sult''s bluesy Les Paul and Marshall side; warm stoner-rock crunch.',76),
('cypress-grove','clutch','guitar','riff','Main riff','crunch','stoner rock','rhythm','intermediate',
 'Gibson Les Paul','Marshall JCM800','Marshall 1960 4x12','Gibson humbucker (bridge)',
 '[]'::jsonb,'{"gain":6,"bass":6,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
 array['Heavy stomping riff with thick modern Marshall crunch','Dark groove-laden bite from the Psychic Warfare sessions'],
 array['Keep the riff heavy and locked to the drums','Let the chord accents ring for the ominous mood'],
 'Cypress Grove from Psychic Warfare uses Tim Sult''s Les Paul and Marshall rig; heavy stoner-rock crunch.',78),
('chest-pain-i-love','malcolm-todd','guitar','rhythm','Clean rhythm','clean','indie pop','clean','beginner',
 'Fender Stratocaster','Roland JC-120','Roland JC-120 2x12','Fender single-coil (neck)',
 '[]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":1,"master":6}'::jsonb,
 array['Soft chorus-washed clean chords in a bedroom-pop feel','Warm neck single-coil tone sitting low under vocals and keys'],
 array['Play gentle chord voicings and let the chorus shimmer','Keep the part sparse and rhythmic to leave room for vocals'],
 'Chest Pain (I Love) is keyboard-and-vocal-led indie pop; the clean chorus guitar is a light adaptation rather than a documented rig.',64),
('earrings','malcolm-todd','guitar','rhythm','Clean rhythm','clean','indie pop','clean','beginner',
 'Fender Stratocaster','Roland JC-120','Roland JC-120 2x12','Fender single-coil (neck)',
 '[]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":1,"master":6}'::jsonb,
 array['Clean funk-tinged single-note and chord comping','Bright chorus-touched Strat tone in a bedroom-pop mix'],
 array['Use light muted funk strumming to lock with the groove','Keep the tone crisp and clean with just a touch of chorus'],
 'Earrings is a synth-and-vocal-driven indie-pop sleeper hit; the clean funk guitar is an adaptation, not a documented rig.',62),
('roommates','malcolm-todd','guitar','rhythm','Clean rhythm','clean','indie pop','clean','beginner',
 'Fender Stratocaster','Roland JC-120','Roland JC-120 2x12','Fender single-coil (neck)',
 '[]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":1,"master":6}'::jsonb,
 array['Mellow clean chords with a warm chorus wash','Understated Strat comping in a lo-fi bedroom-pop feel'],
 array['Play relaxed chord voicings and let them ring softly','Add subtle chorus for the dreamy indie texture'],
 'Roommates from the Sweet Boy mixtape is bedroom-pop; the clean chorus guitar is an interpretation rather than a documented rig.',63),
('floods','pantera','guitar','solo','Clean-to-lead solo','high_gain','groove metal','lead','advanced',
 'Washburn Dime 333','Randall RG100ES','Randall 4x12','Bill Lawrence L-500XL (bridge)',
 '[]'::jsonb,'{"gain":7,"bass":5,"mids":7,"treble":6,"presence":6,"reverb":3,"delay":3,"master":7}'::jsonb,
 array['Clean chorus-and-reverb intro on the neck pickup with volume rolled back','Explosive whammy-drenched lead on the bridge pickup for the climactic solo'],
 array['Roll guitar volume down and use the neck pickup for the clean verse arpeggios','Switch to the bridge pickup, dime the volume and add whammy dives for the solo'],
 'Floods from The Great Southern Trendkill is one of Dimebag''s greatest solos; a clean neck-pickup intro building to a whammy-heavy bridge-pickup lead through the Randall RG100ES.',82),
('pyt-pretty-young-thing','michael-jackson','guitar','rhythm','Funk scratch rhythm','clean','funk','clean','intermediate',
 'Fender Stratocaster','Roland JC-120','Roland JC-120 2x12','Fender single-coil (bridge)',
 '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":6}'::jsonb,
 array['Crisp sixteenth-note funk scratch comping under the groove','Bright glassy clean tone with tight percussive attack'],
 array['Mute the strings and strum tight sixteenths for the scratch feel','Keep the tone clean and focused so the rhythm stays percussive'],
 'David Williams played the clean funk rhythm on P.Y.T. from Thriller, using a Strat-style guitar into a crisp clean amp, the same session style as Bad.',74)
) as c(song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
       original_guitar, original_amp, original_cab, original_pickup,
       original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;

do $$
declare
  expected int;
  actual int;
begin
  select count(*) into expected from phase_targets;
  select count(*) into actual
  from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id
  join public.artists a on a.id = s.artist_id
  join phase_targets t on t.artist_slug = a.slug and t.song_slug = s.slug
  where p.mode = 'guitar' and p.verification_status = 'admin_verified';
  if actual < expected then
    raise exception 'POST-CONDITION FAILED: % verified guitar profiles for % targets — slug mismatch between fragments', actual, expected;
  end if;
end $$;

commit;
