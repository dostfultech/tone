-- Phase 98a: blues cluster: researched verified tone profiles (generated 2026-08-06).
-- Assembled from per-artist research fragments; rigs sourced from
-- Equipboard/GroundGuitar/manufacturer interviews per song.
begin;

create temp table phase_targets(
  artist_name text, artist_slug text, song_title text, song_slug text,
  album text, release_year int
) on commit drop;

insert into phase_targets(artist_name, artist_slug, song_title, song_slug, album, release_year) values
('Albert Collins','albert-collins','Master Charge','master-charge','Frostbite',1980),
('Albert Collins','albert-collins','Iceman','iceman','Iceman',1991),
('Albert Collins','albert-collins','If Trouble Was Money','if-trouble-was-money','Showdown!',1985),
('Albert Collins','albert-collins','Sno-Cone','sno-cone','Truckin'' with Albert Collins',1969),
('Albert Collins','albert-collins','Defrost','defrost','Truckin'' with Albert Collins',1969),
('Albert Collins','albert-collins','Don''t Lose Your Cool','dont-lose-your-cool','Don''t Lose Your Cool',1983),
('Albert Collins','albert-collins','Conversation with Collins','conversation-with-collins','The Cool Sound of Albert Collins',1965),
('Albert Collins','albert-collins','Cold Cold Feeling','cold-cold-feeling','Cold Snap',1986),
('Albert Collins','albert-collins','Travelin'' South','travelin-south','The Cool Sound of Albert Collins',1965),
('Albert Collins','albert-collins','Same Old Blues','same-old-blues','Ice Pickin''',1978),
('Robert Cray','robert-cray','Right Next Door (Because of Me)','right-next-door-because-of-me','Strong Persuader',1986),
('Robert Cray','robert-cray','Bad Influence','bad-influence','Bad Influence',1983),
('Robert Cray','robert-cray','Phone Booth','phone-booth','Bad Influence',1983),
('Robert Cray','robert-cray','Nothin'' but a Woman','nothin-but-a-woman','Strong Persuader',1986),
('Robert Cray','robert-cray','Time Makes Two','time-makes-two','Midnight Stroll',1990),
('Robert Cray','robert-cray','I Guess I Showed Her','i-guess-i-showed-her','Bad Influence',1983),
('Robert Cray','robert-cray','The Forecast (Calls for Pain)','the-forecast-calls-for-pain','Shame + a Sin',1993),
('Robert Cray','robert-cray','1040 Blues','1040-blues','Shame + a Sin',1993),
('Robert Cray','robert-cray','That''s What Keeps Me Rockin''','thats-what-keeps-me-rockin','I Was Warned',1992),
('Robert Cray','robert-cray','Acting This Way','acting-this-way','False Accusations',1985),
('Susan Tedeschi','susan-tedeschi','Rock Me Right','rock-me-right','Just Won''t Burn',1998),
('Susan Tedeschi','susan-tedeschi','It Hurt So Bad','it-hurt-so-bad','Just Won''t Burn',1998),
('Susan Tedeschi','susan-tedeschi','Alone','alone','Just Won''t Burn',1998),
('Susan Tedeschi','susan-tedeschi','Angel from Montgomery','angel-from-montgomery','Just Won''t Burn',1998),
('Susan Tedeschi','susan-tedeschi','Just Won''t Burn','just-wont-burn','Just Won''t Burn',1998),
('Susan Tedeschi','susan-tedeschi','You Need to Be with Me','you-need-to-be-with-me','Wait for Me',2002),
('Susan Tedeschi','susan-tedeschi','Little by Little','little-by-little','Just Won''t Burn',1998),
('Susan Tedeschi','susan-tedeschi','Wait for Me','wait-for-me','Wait for Me',2002),
('Susan Tedeschi','susan-tedeschi','Looking for Answers','looking-for-answers','Just Won''t Burn',1998),
('Susan Tedeschi','susan-tedeschi','Gonna Move','gonna-move','Hope and Desire',2005),
('Eric Gales','eric-gales','Boogie Man','boogie-man','Middle of the Road',2017),
('Eric Gales','eric-gales','Change in Me','change-in-me','Middle of the Road',2017),
('Eric Gales','eric-gales','I Gotta Feeling','i-gotta-feeling','The Bookends',2019),
('Eric Gales','eric-gales','Storm','storm','The Bookends',2019),
('Eric Gales','eric-gales','Survivor','survivor','Crown',2022),
('Eric Gales','eric-gales','Rattlesnake Boogie','rattlesnake-boogie','Crown',2022),
('Eric Gales','eric-gales','Death of Me','death-of-me','Crown',2022),
('Eric Gales','eric-gales','Put Your Cape On','put-your-cape-on','Crown',2022),
('Eric Gales','eric-gales','Southern Comfort','southern-comfort','Relentless',2010),
('Eric Gales','eric-gales','In My Head','in-my-head','The Bookends',2019);

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
('master-charge','albert-collins','guitar','lead','Icy Tele lead','crunch','texas blues','lead','advanced',
 '1966 Fender Telecaster (Custom, maple cap)','Fender Quad Reverb','4x12 combo','Single-coil bridge',
 '[]'::jsonb,'{"gain":4,"bass":2,"mids":4,"treble":10,"presence":9,"reverb":2,"delay":0,"master":8}'::jsonb,
 array['Stinging treble-forward attack with the bass rolled nearly off','Fingerstyle snap gives each note a percussive pop'],
 array['Play with bare fingers, no pick, for the biting Iceman pluck','Capo high and think in his open F-minor tuning shapes'],
 'Albert Collins Frostbite (1980): capoed Telecaster into a treble-cranked Fender Quad Reverb.',76),
('iceman','albert-collins','guitar','solo','Iceman solo','crunch','texas blues','lead','advanced',
 '1966 Fender Telecaster (Custom, maple cap)','Fender Quad Reverb','4x12 combo','Single-coil bridge',
 '[]'::jsonb,'{"gain":5,"bass":2,"mids":4,"treble":10,"presence":9,"reverb":3,"delay":0,"master":8}'::jsonb,
 array['Cutting glassy edge-of-breakup that slices over the band','Long sustained bends held with vibrato from the fingertips'],
 array['Attack hard on the bridge pickup for the cold, spitting tone','Use a capo and finger the minor-tuned voicings up the neck'],
 'Albert Collins Iceman (1991): signature capoed Tele and Quad Reverb blues.',75),
('if-trouble-was-money','albert-collins','guitar','lead','Showdown trade','crunch','texas blues','lead','advanced',
 '1966 Fender Telecaster (Custom, maple cap)','Fender Quad Reverb','4x12 combo','Single-coil bridge',
 '[]'::jsonb,'{"gain":5,"bass":2,"mids":5,"treble":9,"presence":8,"reverb":2,"delay":0,"master":8}'::jsonb,
 array['Aggressive treble bark that answers the vocal call-and-response','Punchy staccato phrasing punctuated by wide finger bends'],
 array['Dig in with the thumb and fingers for percussive Texas snap','Trade phrases short and sharp, leaving space between licks'],
 'Albert Collins Showdown! (1985): trio blues summit, capoed Tele into Quad Reverb.',75),
('sno-cone','albert-collins','guitar','main','Instrumental theme','crunch','texas blues','lead','advanced',
 '1966 Fender Telecaster (Custom, maple cap)','Fender Quad Reverb','4x12 combo','Single-coil bridge',
 '[]'::jsonb,'{"gain":4,"bass":2,"mids":4,"treble":10,"presence":9,"reverb":2,"delay":0,"master":7}'::jsonb,
 array['Ice-cold instrumental melody built on stinging single notes','Sharp treble transients pop off the capoed high strings'],
 array['Let each melody note ring with fingertip vibrato','Keep the bass control low so the highs stay glassy and cold'],
 'Albert Collins early instrumental Sno-Cone: capoed Tele, treble-heavy Fender tone.',74),
('defrost','albert-collins','guitar','main','Instrumental groove','crunch','texas blues','lead','advanced',
 '1966 Fender Telecaster (Custom, maple cap)','Fender Quad Reverb','4x12 combo','Single-coil bridge',
 '[]'::jsonb,'{"gain":4,"bass":2,"mids":5,"treble":9,"presence":8,"reverb":2,"delay":0,"master":7}'::jsonb,
 array['Snappy shuffle riff with a bright, brittle top end','Percussive muted plucks drive the instrumental groove'],
 array['Mute lightly with the palm and pluck with the fingers','Emphasize the upper strings for the cool, icy shimmer'],
 'Albert Collins instrumental Defrost: signature capoed Tele into cranked-treble Fender.',74),
('dont-lose-your-cool','albert-collins','guitar','lead','Cool title lead','crunch','texas blues','lead','advanced',
 '1966 Fender Telecaster (Custom, maple cap)','Fender Quad Reverb','4x12 combo','Single-coil bridge',
 '[]'::jsonb,'{"gain":5,"bass":2,"mids":5,"treble":9,"presence":8,"reverb":3,"delay":0,"master":8}'::jsonb,
 array['Laid-back yet stinging lead with signature icy bite','Bends land dead-on pitch with slow finger vibrato'],
 array['Keep phrasing relaxed but attack each note hard','Roll the bass off and lean on treble for the cold voice'],
 'Albert Collins Don''t Lose Your Cool (1983): capoed Tele, Quad Reverb blues.',75),
('conversation-with-collins','albert-collins','guitar','main','Instrumental melody','crunch','texas blues','lead','advanced',
 '1966 Fender Telecaster (Custom, maple cap)','Fender Quad Reverb','4x12 combo','Single-coil bridge',
 '[]'::jsonb,'{"gain":4,"bass":2,"mids":4,"treble":10,"presence":9,"reverb":2,"delay":0,"master":7}'::jsonb,
 array['Talking, vocal-like phrasing mimics a spoken conversation','Bright biting single notes carry the whole melody'],
 array['Bend into notes to make the guitar speak like a voice','Use fingers for the vocal, expressive attack Collins favored'],
 'Albert Collins early instrumental Conversation with Collins: capoed Tele, icy Fender tone.',74),
('cold-cold-feeling','albert-collins','guitar','lead','Slow blues lead','crunch','texas blues','lead','advanced',
 '1966 Fender Telecaster (Custom, maple cap)','Fender Quad Reverb','4x12 combo','Single-coil bridge',
 '[]'::jsonb,'{"gain":5,"bass":3,"mids":5,"treble":9,"presence":8,"reverb":4,"delay":0,"master":8}'::jsonb,
 array['Deep, emotive slow-blues lead with weeping bends','Cold sustained notes cut through the minor-key backing'],
 array['Take your time and let each bend fully bloom','Add a touch more reverb for the aching slow-blues space'],
 'Albert Collins Cold Snap (1986): slow blues on capoed Tele and Quad Reverb.',75),
('travelin-south','albert-collins','guitar','main','Instrumental shuffle','crunch','texas blues','lead','advanced',
 '1966 Fender Telecaster (Custom, maple cap)','Fender Quad Reverb','4x12 combo','Single-coil bridge',
 '[]'::jsonb,'{"gain":4,"bass":2,"mids":5,"treble":9,"presence":8,"reverb":2,"delay":0,"master":7}'::jsonb,
 array['Up-tempo shuffle riff with a bright, driving snap','Instrumental melody rides high and glassy on the top strings'],
 array['Keep the shuffle tight and percussive with the fingers','Favor the bridge pickup for the cutting Texas bite'],
 'Albert Collins early instrumental Travelin'' South: capoed Tele into treble-forward Fender.',74),
('same-old-blues','albert-collins','guitar','lead','Ice Pickin lead','crunch','texas blues','lead','advanced',
 '1966 Fender Telecaster (Custom, maple cap)','Fender Quad Reverb','4x12 combo','Single-coil bridge',
 '[]'::jsonb,'{"gain":5,"bass":3,"mids":5,"treble":9,"presence":8,"reverb":3,"delay":0,"master":8}'::jsonb,
 array['Soulful mid-tempo lead with the trademark stinging highs','Fat yet biting single-note lines soaked in vibrato'],
 array['Balance a little more low end while keeping the treble bark','Phrase behind the beat for a relaxed, greasy feel'],
 'Albert Collins Ice Pickin'' (1978): breakthrough LP, capoed Tele and Quad Reverb.',76),
('right-next-door-because-of-me','robert-cray','guitar','lead','Clean Strat lead','clean','soul blues','clean','intermediate',
 'Fender Robert Cray Stratocaster','Matchless Clubman 35','4x10 cabinet','Single-coil neck',
 '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":0,"master":7}'::jsonb,
 array['Pristine fat neck-pickup clean with soulful sustain','Articulate note separation, every string rings clear'],
 array['Select the neck single-coil and pick with a light touch','Add mild compression to hold the singing sustain'],
 'Robert Cray Strong Persuader (1986): hardtail Strat into Matchless clean tone.',78),
('bad-influence','robert-cray','guitar','riff','Signature riff','clean','soul blues','rhythm','intermediate',
 'Fender Robert Cray Stratocaster','Matchless Clubman 35','4x10 cabinet','Single-coil neck',
 '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
 array['Tight, funky clean riff with crisp percussive attack','Bright Strat spank that stays clean under the groove'],
 array['Dig into the middle pickup position for the funky cluck','Keep the rhythm tight and syncopated with muted stabs'],
 'Robert Cray Bad Influence (1983): clean articulate Strat into Fender/Matchless amps.',77),
('phone-booth','robert-cray','guitar','solo','Phone Booth solo','clean','soul blues','lead','intermediate',
 'Fender Robert Cray Stratocaster','Matchless Clubman 35','4x10 cabinet','Single-coil neck',
 '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":3,"delay":0,"master":7}'::jsonb,
 array['Cutting clean solo with just a hint of amp hair','Vocal, stinging bends over a driving minor groove'],
 array['Push the amp toward edge-of-breakup with your picking','Bend with confident vibrato and let notes sustain clean'],
 'Robert Cray Bad Influence (1983): Phone Booth clean-to-edge Strat solo.',77),
('nothin-but-a-woman','robert-cray','guitar','lead','Soul lead','clean','soul blues','clean','intermediate',
 'Fender Robert Cray Stratocaster','Matchless Clubman 35','4x10 cabinet','Single-coil neck',
 '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":0,"master":7}'::jsonb,
 array['Smooth soulful clean lead that sits behind the vocal','Warm rounded neck-pickup tone with silky sustain'],
 array['Play sparse, tasteful fills between vocal lines','Let the neck pickup do the work with a soft attack'],
 'Robert Cray Strong Persuader (1986): understated clean Strat soul-blues.',77),
('time-makes-two','robert-cray','guitar','lead','Ballad lead','clean','soul blues','clean','intermediate',
 'Fender Robert Cray Stratocaster','Matchless Clubman 35','4x10 cabinet','Single-coil neck',
 '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":4,"delay":0,"master":7}'::jsonb,
 array['Tender ballad clean with lush, singing sustain','Rounded neck tone with light reverb for space'],
 array['Phrase slowly and leave breathing room between licks','Use vibrato on held notes to keep them alive'],
 'Robert Cray Midnight Stroll (1990): soulful clean Strat ballad.',76),
('i-guess-i-showed-her','robert-cray','guitar','rhythm','Clean groove','clean','soul blues','rhythm','intermediate',
 'Fender Robert Cray Stratocaster','Matchless Clubman 35','4x10 cabinet','Single-coil neck',
 '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
 array['Crisp, funky clean rhythm with tight upstroke chops','Bright Strat chording that stays punchy and dry'],
 array['Keep chords short and rhythmic with palm control','Lock into the pocket with the bass and drums'],
 'Robert Cray Bad Influence (1983): clean funky Strat rhythm work.',76),
('the-forecast-calls-for-pain','robert-cray','guitar','lead','Minor-key lead','clean','soul blues','lead','intermediate',
 'Fender Robert Cray Stratocaster','Matchless Clubman 35','4x10 cabinet','Single-coil neck',
 '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":3,"delay":0,"master":7}'::jsonb,
 array['Emotive minor-key lead with clean, biting sustain','Expressive bends that cry over the tense groove'],
 array['Lean into the neck pickup for warmth with clarity','Milk each bend with slow, controlled vibrato'],
 'Robert Cray Shame + a Sin (1993): clean expressive Strat blues lead.',76),
('1040-blues','robert-cray','guitar','solo','Uptempo solo','clean','soul blues','lead','intermediate',
 'Fender Robert Cray Stratocaster','Matchless Clubman 35','4x10 cabinet','Single-coil neck',
 '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
 array['Bright uptempo solo with snappy clean articulation','Fast fluid runs that stay clear and defined'],
 array['Pick cleanly and evenly for note-perfect fast runs','Use the bridge-plus-middle position for extra cut'],
 'Robert Cray Shame + a Sin (1993): uptempo clean Strat blues solo.',76),
('thats-what-keeps-me-rockin','robert-cray','guitar','riff','Rocking groove','crunch','soul blues','rhythm','intermediate',
 'Fender Robert Cray Stratocaster','Matchless Clubman 35','4x10 cabinet','Single-coil neck',
 '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
 array['Driving mild-crunch groove with a rocking swagger','Slightly pushed amp adds grit to the Strat spank'],
 array['Push the amp into light breakup with a firm attack','Keep the rhythm swinging and greasy in the pocket'],
 'Robert Cray I Was Warned (1992): pushed clean-to-crunch Strat groove.',75),
('acting-this-way','robert-cray','guitar','lead','Slow blues lead','clean','soul blues','clean','intermediate',
 'Fender Robert Cray Stratocaster','Matchless Clubman 35','4x10 cabinet','Single-coil neck',
 '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":4,"delay":0,"master":7}'::jsonb,
 array['Aching slow-blues clean lead with vocal phrasing','Warm sustaining neck tone dripping with feel'],
 array['Play sparse and let the silence carry weight','Bend into notes and hold them with tender vibrato'],
 'Robert Cray False Accusations (1985): clean slow-blues Strat lead.',76),
('rock-me-right','susan-tedeschi','guitar','riff','Tweed shuffle riff','crunch','blues rock','rhythm','intermediate',
 'Fender Telecaster','Fender tweed amp','1x12 combo','Single-coil bridge',
 '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
 array['Warm tweed-driven shuffle riff with gritty midrange','Tele twang softened by tube overdrive warmth'],
 array['Push the tweed amp into natural breakup with your pick','Keep the shuffle rhythm loose and swinging'],
 'Susan Tedeschi Just Won''t Burn (1998): Telecaster into a cranked Fender tweed.',76),
('it-hurt-so-bad','susan-tedeschi','guitar','lead','Soul-blues lead','crunch','blues rock','lead','intermediate',
 'Fender Telecaster','Fender tweed amp','1x12 combo','Single-coil bridge',
 '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":0,"master":7}'::jsonb,
 array['Gritty, impassioned lead with warm tweed overdrive','Vocal-like bends that match her soulful delivery'],
 array['Dig in hard to coax breakup from the tweed amp','Phrase your bends to echo the vocal melody'],
 'Susan Tedeschi Just Won''t Burn (1998): soulful Tele lead through Fender tweed.',75),
('alone','susan-tedeschi','guitar','lead','Slow blues lead','crunch','blues rock','lead','intermediate',
 'Fender Telecaster','Fender tweed amp','1x12 combo','Single-coil bridge',
 '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":4,"delay":0,"master":7}'::jsonb,
 array['Weeping slow-blues lead with warm, saturated sustain','Emotional bends riding the edge of the tweed breakup'],
 array['Let notes sustain and bloom into natural feedback','Take your time and lean into each bend for feel'],
 'Susan Tedeschi Just Won''t Burn (1998): slow-blues Tele lead into Fender tweed.',75),
('angel-from-montgomery','susan-tedeschi','guitar','lead','Cover ballad lead','clean','blues rock','clean','intermediate',
 'Fender Telecaster','Fender tweed amp','1x12 combo','Single-coil bridge',
 '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":0,"master":7}'::jsonb,
 array['Warm mostly-clean tone supporting a tender vocal cover','Gentle Tele fills with rounded tweed warmth'],
 array['Play softly with light fills between vocal phrases','Roll back the guitar volume for a cleaner ballad tone'],
 'Susan Tedeschi cover of John Prine''s acoustic Angel from Montgomery; electric-blues adaptation, tone approximate.',64),
('just-wont-burn','susan-tedeschi','guitar','lead','Title-track lead','crunch','blues rock','lead','intermediate',
 'Fender Telecaster','Fender tweed amp','1x12 combo','Single-coil bridge',
 '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
 array['Fiery blues-rock lead with warm tweed grind','Bright Tele bite pushed into singing overdrive'],
 array['Attack the strings hard for the aggressive breakup','Combine pentatonic runs with wide, vocal bends'],
 'Susan Tedeschi Just Won''t Burn (1998): title-track Tele lead through Fender tweed.',76),
('you-need-to-be-with-me','susan-tedeschi','guitar','lead','Soul lead','crunch','blues rock','lead','intermediate',
 'Fender Telecaster','Fender tweed amp','1x12 combo','Single-coil bridge',
 '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":0,"master":7}'::jsonb,
 array['Smooth soul-blues lead with light tweed warmth','Rounded Tele tone with just a touch of grit'],
 array['Keep the gain moderate for a warm, soulful edge','Play melodically and let the phrasing breathe'],
 'Susan Tedeschi Wait for Me (2002): soulful Tele lead into Fender tweed.',75),
('little-by-little','susan-tedeschi','guitar','riff','Uptempo riff','crunch','blues rock','rhythm','intermediate',
 'Fender Telecaster','Fender tweed amp','1x12 combo','Single-coil bridge',
 '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
 array['Punchy uptempo riff with bright, gritty tweed drive','Snappy Tele attack cutting through the groove'],
 array['Keep the riff tight and percussive with the pick','Push the tweed into breakup for the raw energy'],
 'Susan Tedeschi Just Won''t Burn (1998): uptempo Tele riff through Fender tweed.',75),
('wait-for-me','susan-tedeschi','guitar','lead','Ballad lead','clean','blues rock','clean','intermediate',
 'Fender Telecaster','Fender tweed amp','1x12 combo','Single-coil bridge',
 '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":4,"delay":0,"master":7}'::jsonb,
 array['Tender clean ballad tone with warm tweed roundness','Delicate Tele fills with a touch of reverb space'],
 array['Play softly and let the clean tone stay open','Add subtle vibrato to sustained ballad notes'],
 'Susan Tedeschi Wait for Me (2002): clean Tele ballad into Fender tweed.',75),
('looking-for-answers','susan-tedeschi','guitar','lead','Blues-rock lead','crunch','blues rock','lead','intermediate',
 'Fender Telecaster','Fender tweed amp','1x12 combo','Single-coil bridge',
 '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":3,"delay":0,"master":7}'::jsonb,
 array['Driving blues-rock lead with warm overdriven grit','Expressive bends soaked in tweed saturation'],
 array['Dig in for the natural amp breakup and sustain','Mix pentatonic licks with soulful vocal phrasing'],
 'Susan Tedeschi Just Won''t Burn (1998): blues-rock Tele lead through Fender tweed.',75),
('gonna-move','susan-tedeschi','guitar','riff','Gospel-blues riff','crunch','blues rock','rhythm','intermediate',
 'Fender Telecaster','Fender tweed amp','1x12 combo','Single-coil bridge',
 '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
 array['Rollicking gospel-blues riff with gritty tweed warmth','Driving Tele groove with a joyful, raw energy'],
 array['Keep the groove loose and swinging with a hard attack','Let the tweed amp break up naturally under the riff'],
 'Susan Tedeschi Hope and Desire (2005): gospel-blues Tele riff into Fender tweed.',74),
('boogie-man','eric-gales','guitar','riff','Boogie riff','crunch','fusion blues','rhythm','advanced',
 'Magneto Sonnet Raw Dawg (right-strung lefty)','Two-Rock Dumble-style amp','2x12 cabinet','Single-coil bridge',
 '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
 array['Chunky boogie riff with responsive Dumble-style grind','Fast, fluid articulation from the upside-down attack'],
 array['Drive the amp with a firm pick attack for touch dynamics','Roll guitar volume back to clean up between phrases'],
 'Eric Gales Middle of the Road (2017): flipped Magneto Strat into a Two-Rock Dumble-style amp.',76),
('change-in-me','eric-gales','guitar','lead','Emotive lead','crunch','fusion blues','lead','advanced',
 'Magneto Sonnet Raw Dawg (right-strung lefty)','Two-Rock Dumble-style amp','2x12 cabinet','Single-coil bridge',
 '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":3,"delay":1,"master":7}'::jsonb,
 array['Soaring emotive lead with singing Dumble-style sustain','Vocal bends and fast fusion runs with smooth overdrive'],
 array['Use the amp''s touch response for dynamic swells','Blend blues bends with legato fusion phrasing'],
 'Eric Gales Middle of the Road (2017): emotive lead on flipped Strat and Two-Rock amp.',76),
('i-gotta-feeling','eric-gales','guitar','lead','Blues-rock lead','crunch','fusion blues','lead','advanced',
 'Magneto Sonnet Raw Dawg (right-strung lefty)','Two-Rock Dumble-style amp','2x12 cabinet','Single-coil bridge',
 '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
 array['Punchy blues-rock lead with warm, saturated bite','Fluid runs delivered with lefty upside-down fire'],
 array['Attack with confidence for the aggressive breakup','Mix rapid runs with held, vocal-style bends'],
 'Eric Gales The Bookends (2019): blues-rock lead on flipped Strat into Two-Rock amp.',75),
('storm','eric-gales','guitar','solo','Fusion solo','crunch','fusion blues','lead','advanced',
 'Magneto Sonnet Raw Dawg (right-strung lefty)','Two-Rock Dumble-style amp','2x12 cabinet','Single-coil bridge',
 '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":3,"delay":1,"master":7}'::jsonb,
 array['Stormy fusion solo with rapid, articulate runs','Smooth Dumble-style overdrive with singing sustain'],
 array['Practice the legato runs slowly before speeding up','Use dynamics to build intensity through the solo'],
 'Eric Gales The Bookends (2019): fusion-blues solo on flipped Strat and Two-Rock amp.',75),
('survivor','eric-gales','guitar','lead','Anthemic lead','crunch','fusion blues','lead','advanced',
 'Magneto Sonnet Raw Dawg (right-strung lefty)','Two-Rock Dumble-style amp','2x12 cabinet','Single-coil bridge',
 '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":3,"delay":0,"master":7}'::jsonb,
 array['Anthemic lead with powerful, sustaining Dumble-style grind','Wide expressive bends over a driving groove'],
 array['Let notes sustain into controlled feedback','Use vibrato and bends to give the lead a vocal quality'],
 'Eric Gales Crown (2022): anthemic lead on flipped Strat through Two-Rock amp.',76),
('rattlesnake-boogie','eric-gales','guitar','riff','Boogie shuffle riff','crunch','fusion blues','rhythm','advanced',
 'Magneto Sonnet Raw Dawg (right-strung lefty)','Two-Rock Dumble-style amp','2x12 cabinet','Single-coil bridge',
 '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
 array['Fast rattling boogie riff with gritty Dumble-style drive','Tight muted chugs punctuated by snappy fills'],
 array['Keep the boogie shuffle tight and percussive','Palm-mute the low strings for the driving chug'],
 'Eric Gales Crown (2022): boogie riff on flipped Strat into Two-Rock amp.',75),
('death-of-me','eric-gales','guitar','lead','Heavy blues lead','crunch','fusion blues','lead','advanced',
 'Magneto Sonnet Raw Dawg (right-strung lefty)','Two-Rock Dumble-style amp','2x12 cabinet','Single-coil bridge',
 '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
 array['Heavy, driving blues-rock lead with thick overdrive','Aggressive bends and fast runs with fierce sustain'],
 array['Push the gain slightly higher for extra weight','Combine muscular bends with rapid pentatonic bursts'],
 'Eric Gales Crown (2022): heavy blues-rock lead on flipped Strat and Two-Rock amp.',76),
('put-your-cape-on','eric-gales','guitar','lead','Uplifting lead','crunch','fusion blues','lead','advanced',
 'Magneto Sonnet Raw Dawg (right-strung lefty)','Two-Rock Dumble-style amp','2x12 cabinet','Single-coil bridge',
 '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":3,"delay":1,"master":7}'::jsonb,
 array['Uplifting, soulful lead with warm singing sustain','Melodic fusion phrasing over an inspiring groove'],
 array['Focus on melody and let the notes breathe','Use the amp''s dynamics to swell into each phrase'],
 'Eric Gales Crown (2022): uplifting lead on flipped Strat through Two-Rock amp.',75),
('southern-comfort','eric-gales','guitar','solo','Fusion-blues solo','crunch','fusion blues','lead','advanced',
 'Magneto Sonnet Raw Dawg (right-strung lefty)','Two-Rock Dumble-style amp','2x12 cabinet','Single-coil bridge',
 '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":3,"delay":1,"master":7}'::jsonb,
 array['Slick fusion-blues solo with smooth Dumble-style overdrive','Fluid legato lines mixed with soulful blues bends'],
 array['Work the legato phrasing evenly across the neck','Balance speed with tasteful, vocal-style bends'],
 'Eric Gales Relentless (2010): fusion-blues solo on flipped Strat into Two-Rock amp.',74),
('in-my-head','eric-gales','guitar','lead','Introspective lead','crunch','fusion blues','lead','advanced',
 'Magneto Sonnet Raw Dawg (right-strung lefty)','Two-Rock Dumble-style amp','2x12 cabinet','Single-coil bridge',
 '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":3,"delay":0,"master":7}'::jsonb,
 array['Introspective lead with warm, expressive sustain','Thoughtful phrasing blending blues feel and fusion runs'],
 array['Let each phrase develop with dynamic control','Use vibrato to add emotion to the sustained notes'],
 'Eric Gales The Bookends (2019): introspective lead on flipped Strat and Two-Rock amp.',74)
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
