-- Phase 46: classic metal deep cuts, verified per-part tone data.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Metallica','metallica','Orion','orion','Master of Puppets',1986),
    ('Metallica','metallica','Disposable Heroes','disposable-heroes','Master of Puppets',1986),
    ('Metallica','metallica','Damage, Inc.','damage-inc','Master of Puppets',1986),
    ('Metallica','metallica','The Day That Never Comes','the-day-that-never-comes','Death Magnetic',2008),
    ('Megadeth','megadeth','Trust','trust','Cryptic Writings',1997),
    ('Megadeth','megadeth','In My Darkest Hour','in-my-darkest-hour','So Far, So Good... So What!',1988),
    ('Megadeth','megadeth','Wake Up Dead','wake-up-dead','Peace Sells... but Who''s Buying?',1986),
    ('Iron Maiden','iron-maiden','The Wicker Man','the-wicker-man','Brave New World',2000),
    ('Iron Maiden','iron-maiden','Phantom of the Opera','phantom-of-the-opera','Iron Maiden',1980),
    ('Iron Maiden','iron-maiden','Brave New World','brave-new-world','Brave New World',2000),
    ('Judas Priest','judas-priest','The Sentinel','the-sentinel','Defenders of the Faith',1984),
    ('Judas Priest','judas-priest','Freewheel Burning','freewheel-burning','Defenders of the Faith',1984),
    ('Judas Priest','judas-priest','Beyond the Realms of Death','beyond-the-realms-of-death','Stained Class',1978),
    ('Pantera','pantera','Floods','floods','The Great Southern Trendkill',1996),
    ('Pantera','pantera','Becoming','becoming','Far Beyond Driven',1994),
    ('Pantera','pantera','Revolution Is My Name','revolution-is-my-name','Reinventing the Steel',2000),
    ('Ozzy Osbourne','ozzy-osbourne','No More Tears','no-more-tears','No More Tears',1991),
    ('Ozzy Osbourne','ozzy-osbourne','Over the Mountain','over-the-mountain','Diary of a Madman',1981),
    ('Ozzy Osbourne','ozzy-osbourne','Flying High Again','flying-high-again','Diary of a Madman',1981),
    ('Black Sabbath','black-sabbath','Heaven and Hell','heaven-and-hell','Heaven and Hell',1980),
    ('Black Sabbath','black-sabbath','Neon Knights','neon-knights','Heaven and Hell',1980),
    ('Black Sabbath','black-sabbath','The Mob Rules','the-mob-rules','Mob Rules',1981),
    ('Slayer','slayer','Dead Skin Mask','dead-skin-mask','Seasons in the Abyss',1990),
    ('Slayer','slayer','Hell Awaits','hell-awaits','Hell Awaits',1985),
    ('Motorhead','motorhead','Iron Fist','iron-fist','Iron Fist',1982)
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
    ('metallica','orion'),('metallica','disposable-heroes'),('metallica','damage-inc'),('metallica','the-day-that-never-comes'),
    ('megadeth','trust'),('megadeth','in-my-darkest-hour'),('megadeth','wake-up-dead'),
    ('iron-maiden','the-wicker-man'),('iron-maiden','phantom-of-the-opera'),('iron-maiden','brave-new-world'),
    ('judas-priest','the-sentinel'),('judas-priest','freewheel-burning'),('judas-priest','beyond-the-realms-of-death'),
    ('pantera','floods'),('pantera','becoming'),('pantera','revolution-is-my-name'),
    ('ozzy-osbourne','no-more-tears'),('ozzy-osbourne','over-the-mountain'),('ozzy-osbourne','flying-high-again'),
    ('black-sabbath','heaven-and-hell'),('black-sabbath','neon-knights'),('black-sabbath','the-mob-rules'),
    ('slayer','dead-skin-mask'),('slayer','hell-awaits'),('motorhead','iron-fist')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('metallica','orion'),('metallica','disposable-heroes'),('metallica','damage-inc'),('metallica','the-day-that-never-comes'),
    ('megadeth','trust'),('megadeth','in-my-darkest-hour'),('megadeth','wake-up-dead'),
    ('iron-maiden','the-wicker-man'),('iron-maiden','phantom-of-the-opera'),('iron-maiden','brave-new-world'),
    ('judas-priest','the-sentinel'),('judas-priest','freewheel-burning'),('judas-priest','beyond-the-realms-of-death'),
    ('pantera','floods'),('pantera','becoming'),('pantera','revolution-is-my-name'),
    ('ozzy-osbourne','no-more-tears'),('ozzy-osbourne','over-the-mountain'),('ozzy-osbourne','flying-high-again'),
    ('black-sabbath','heaven-and-hell'),('black-sabbath','neon-knights'),('black-sabbath','the-mob-rules'),
    ('slayer','dead-skin-mask'),('slayer','hell-awaits'),('motorhead','iron-fist')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('metallica','orion'),('metallica','disposable-heroes'),('metallica','damage-inc'),('metallica','the-day-that-never-comes'),
    ('megadeth','trust'),('megadeth','in-my-darkest-hour'),('megadeth','wake-up-dead'),
    ('iron-maiden','the-wicker-man'),('iron-maiden','phantom-of-the-opera'),('iron-maiden','brave-new-world'),
    ('judas-priest','the-sentinel'),('judas-priest','freewheel-burning'),('judas-priest','beyond-the-realms-of-death'),
    ('pantera','floods'),('pantera','becoming'),('pantera','revolution-is-my-name'),
    ('ozzy-osbourne','no-more-tears'),('ozzy-osbourne','over-the-mountain'),('ozzy-osbourne','flying-high-again'),
    ('black-sabbath','heaven-and-hell'),('black-sabbath','neon-knights'),('black-sabbath','the-mob-rules'),
    ('slayer','dead-skin-mask'),('slayer','hell-awaits'),('motorhead','iron-fist')
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
    -- ============ METALLICA (Master of Puppets era: Mesa Mark IIC+) ============
    ('orion','metallica','guitar','riff','main riff','high_gain','metal','rhythm','advanced',
     'Gibson Explorer-style guitar (James Hetfield)','Mesa/Boogie Mark IIC+','Marshall 4x12 cab','bridge humbucker (EMG-style output)',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":4,"treble":7,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['The Master of Puppets rhythm sound — tight scooped Mark IIC+ chunk.','High gain but articulate; the mid-scoop is moderate, not extreme.'],
     array['The instrumental has many moods — from chunky riffing to the melodic bass-led middle section.','Down-picking stamina and precision throughout.'],
     'Studio recording, 1986. Hetfield''s Mesa Mark IIC+ rhythm tone from the Master of Puppets sessions.',82),
    ('disposable-heroes','metallica','guitar','riff','main riff','high_gain','metal','rhythm','expert',
     'Gibson Explorer-style guitar (James Hetfield)','Mesa/Boogie Mark IIC+','Marshall 4x12 cab','bridge humbucker (EMG-style output)',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":4,"treble":7,"presence":6,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['Relentless thrash gallop — the same Puppets rhythm tone at maximum aggression.','Tight low end is everything; too much bass smears the gallop.'],
     array['One of the most demanding down-picking songs ever recorded.','Build stamina slowly — the verse riff is a marathon at 220 BPM.'],
     'Studio recording, 1986. Peak thrash down-picking on the Mark IIC+ rig.',82),
    ('damage-inc','metallica','guitar','riff','main riff','high_gain','metal','rhythm','expert',
     'Gibson Explorer-style guitar (James Hetfield)','Mesa/Boogie Mark IIC+','Marshall 4x12 cab','bridge humbucker (EMG-style output)',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":4,"treble":7,"presence":6,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['Album-closing thrash fury — dry, tight, in-your-face Mark IIC+ chunk.','No ambience; the tone is bone dry and percussive.'],
     array['Fast alternate-picked riffing mixed with brutal down-picked sections.','Keep palm mutes consistent at speed.'],
     'Studio recording, 1986. Dry aggressive thrash rhythm from Master of Puppets.',81),
    ('the-day-that-never-comes','metallica','guitar','riff','intro clean + heavy riff','crunch','metal','rhythm','intermediate',
     'ESP Explorer (James Hetfield)','Mesa/Marshall blended high-gain rig','Marshall 4x12 cab','EMG humbucker',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":1,"master":6}'::jsonb,
     array['Opens with a chiming near-clean arpeggio before erupting into modern Metallica high gain (raise gain to 7-8 for the heavy sections).','Two tones in one song — program both if your rig allows.'],
     array['The clean intro arpeggios need even fingerpicking.','The outro is fast One-style tremolo riffing.'],
     'Studio recording, 2008. Clean-to-crushing dynamic from Death Magnetic.',77),

    -- ============ MEGADETH ============
    ('trust','megadeth','guitar','riff','main riff','high_gain','metal','rhythm','intermediate',
     'Jackson King V (Dave Mustaine)','Marshall JCM800-style modified high-gain','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Polished late-90s Megadeth crunch — more midrange than 80s thrash.','Tight modern high gain with the mids left in.'],
     array['The main riff is groove-based, not speed-based.','Accent the syncopated hits with the drums.'],
     'Studio recording, 1997. Polished mid-forward metal crunch from Cryptic Writings.',78),
    ('in-my-darkest-hour','megadeth','guitar','riff','main riff','high_gain','metal','rhythm','intermediate',
     'Jackson King V (Dave Mustaine)','Marshall-style modified high-gain','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":5,"treble":7,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Brooding mid-tempo thrash with an aggressive edge.','80s Marshall bite — bright and cutting, moderate bass.'],
     array['The clean-ish intro builds into heavy down-picked verses.','Feel the drag of the half-time groove.'],
     'Studio recording, 1988. Brooding Marshall-driven thrash, written for Cliff Burton.',79),
    ('wake-up-dead','megadeth','guitar','riff','main riff','high_gain','metal','rhythm','expert',
     'Jackson King V (Dave Mustaine)','Marshall-style modified high-gain','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":4,"mids":5,"treble":7,"presence":6,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['Wiry, surgical 80s thrash — brighter and rawer than Metallica''s scoop.','Keep bass tight; the riffs are intricate and need definition.'],
     array['Constantly shifting riffs — memorize the map before chasing speed.','The dual-guitar solo section trades rapid-fire licks.'],
     'Studio recording, 1986. Wiry intricate thrash from Peace Sells.',79),

    -- ============ IRON MAIDEN ============
    ('the-wicker-man','iron-maiden','guitar','riff','main riff','distorted','metal','rhythm','intermediate',
     'Fender Stratocaster with humbucker (Adrian Smith)','Marshall JCM2000-style tube head','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Modern-era Maiden crunch — warmer and thicker than the 80s records.','Classic Marshall drive, mids intact; never scooped.'],
     array['Galloping eighth-note drive under the riff.','Three guitars on the record — yours should sit tight and rhythmic.'],
     'Studio recording, 2000. Reunion-era Marshall crunch from Brave New World.',77),
    ('phantom-of-the-opera','iron-maiden','guitar','riff','main riff','distorted','metal','rhythm','advanced',
     'Fender Stratocaster (Dave Murray)','Marshall-style tube stack, moderate gain','Marshall 4x12 cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Raw debut-album tone — punky Marshall crunch, less gain than later Maiden.','The galloping harmonies need brightness and cut.'],
     array['The unison harmony runs are the centerpiece — nail the timing.','Shifting sections demand full concentration.'],
     'Studio recording, 1980. Raw early-Maiden Marshall crunch from the debut.',78),
    ('brave-new-world','iron-maiden','guitar','riff','main riff','distorted','metal','rhythm','intermediate',
     'Fender Stratocaster (Dave Murray / Adrian Smith / Janick Gers)','Marshall JCM2000-style tube head','Marshall 4x12 cab','bridge pickup',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['Melodic modern Maiden — clean arpeggiated intro into warm Marshall drive.','Moderate gain preserves the melodic chord voicings.'],
     array['The intro arpeggios set the mood — play them clean and patient.','Gallops arrive in the chorus; keep them light-footed.'],
     'Studio recording, 2000. Melodic reunion-era Marshall tone.',76),

    -- ============ JUDAS PRIEST ============
    ('the-sentinel','judas-priest','guitar','riff','main riff','high_gain','metal','rhythm','advanced',
     'Hamer/Gibson solid-body (Glenn Tipton)','Marshall JCM800','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Peak 80s Priest — tight JCM800 aggression with dual-guitar precision.','Bright cutting high gain; the mids stay in for punch.'],
     array['The intro builds menace — restrain until the main riff hits.','The trade-off solos are fast and melodic; learn both parts.'],
     'Studio recording, 1984. Tight JCM800 twin-guitar aggression from Defenders of the Faith.',79),
    ('freewheel-burning','judas-priest','guitar','riff','main riff','high_gain','metal','rhythm','advanced',
     'Hamer/Gibson solid-body (Glenn Tipton / K.K. Downing)','Marshall JCM800','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":0,"delay":0,"master":8}'::jsonb,
     array['Full-speed opener — JCM800s cranked, dry and fierce.','Speed-metal picking demands a dry, immediate tone.'],
     array['Rapid-fire down-picked gallops from the first bar.','The solo section is a two-guitar duel at full tilt.'],
     'Studio recording, 1984. Cranked JCM800 speed metal.',78),
    ('beyond-the-realms-of-death','judas-priest','guitar','riff','clean verse + heavy chorus','crunch','metal','rhythm','intermediate',
     'Gibson solid-body (Glenn Tipton / K.K. Downing)','Marshall tube stack','Marshall 4x12 cab','neck pickup (verse) / bridge (chorus)',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Quiet arpeggiated verses (settings shown) exploding into heavy choruses — raise gain to 6-7 for the heavy parts.','70s Marshall warmth, not 80s brightness.'],
     array['Fingerpick or softly pick the verse arpeggios.','The climactic solo is one of Tipton''s most emotional.'],
     'Studio recording, 1978. Quiet-loud epic from Stained Class.',77),

    -- ============ PANTERA (Dimebag: Dean ML + Randall solid-state) ============
    ('floods','pantera','guitar','riff','main riff + solo','high_gain','groove metal','rhythm','advanced',
     'Dean ML (Dimebag Darrell)','Randall solid-state head (RG100-style)','Randall 4x12 cab','Bill Lawrence XL500 bridge humbucker',
     '[{"effect_type":"eq","effect_name":"MXR 6-band EQ mid boost","placement":"front","settings":{"mid_boost":6}}]'::jsonb,
     '{"gain":8,"bass":6,"mids":3,"treble":7,"presence":7,"reverb":2,"delay":2,"master":7}'::jsonb,
     array['Dark brooding groove into one of the greatest solos ever — Dime''s scooped Randall grind with delay ambience on the lead.','Solid-state edge: scooped mids, razor attack; add delay + reverb for the solo outro.'],
     array['The verse riff is moody and restrained.','The solo''s tapped harmonic outro needs patience and a delay pedal.'],
     'Studio recording, 1996. Dimebag''s scooped Randall grind with the legendary Floods solo.',82),
    ('becoming','pantera','guitar','riff','main riff','high_gain','groove metal','rhythm','advanced',
     'Dean ML (Dimebag Darrell)','Randall solid-state head (RG100-style)','Randall 4x12 cab','Bill Lawrence XL500 bridge humbucker',
     '[{"effect_type":"pitch","effect_name":"DigiTech Whammy (harmony squeal)","placement":"front","settings":{"mode":"octave_up","mix":8}}]'::jsonb,
     '{"gain":8,"bass":6,"mids":3,"treble":7,"presence":7,"reverb":0,"delay":0,"master":8}'::jsonb,
     array['Crushing groove with the famous Whammy-pedal squeal hook.','Maximum scoop and attack; the squeals are Whammy octave-up pulls.'],
     array['Lock the stomping groove with the kick drum.','The Whammy licks are rhythmic — treat the pedal as an instrument.'],
     'Studio recording, 1994. Whammy-squeal groove metal from Far Beyond Driven.',81),
    ('revolution-is-my-name','pantera','guitar','riff','main riff','high_gain','groove metal','rhythm','advanced',
     'Dean ML (Dimebag Darrell)','Randall Warhead solid-state head','Randall 4x12 cab','Bill Lawrence XL500 bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":4,"treble":7,"presence":7,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['Late-era Pantera — slightly thicker Randall Warhead grind.','Still scooped and solid-state tight, marginally warmer than the 90s records.'],
     array['Swampy south-groove verses into a soaring melodic chorus.','Dime''s fills mix squeals and bluesy bends.'],
     'Studio recording, 2000. Randall Warhead groove from Reinventing the Steel.',79),

    -- ============ OZZY OSBOURNE ============
    ('no-more-tears','ozzy-osbourne','guitar','riff','main riff','high_gain','metal','rhythm','intermediate',
     'Gibson Les Paul Custom (Zakk Wylde)','Marshall JCM800 boosted','Marshall 4x12 cab','EMG 81 bridge humbucker',
     '[{"effect_type":"overdrive","effect_name":"boost/overdrive into the front end","placement":"front","settings":{"gain":3,"level":7}}]'::jsonb,
     '{"gain":7,"bass":6,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Zakk''s boosted JCM800 wall — thick, mid-strong, with signature pinch harmonics.','EMG-into-boosted-Marshall saturation; mids stay pushed.'],
     array['The iconic bass intro leads; guitar enters with the massive riff.','Pinch harmonics on demand — practice the pick-thumb technique.'],
     'Studio recording, 1991. Zakk Wylde''s boosted JCM800 wall of sound.',81),
    ('over-the-mountain','ozzy-osbourne','guitar','riff','main riff','high_gain','metal','rhythm','advanced',
     'Jackson polka-dot V / cream Les Paul (Randy Rhoads)','Marshall 1959 Super Lead cranked','Marshall 4x12 cab','bridge humbucker',
     '[{"effect_type":"distortion","effect_name":"MXR Distortion+","placement":"front","settings":{"gain":6,"level":6}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":7,"treble":6,"presence":6,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['Randy''s cranked-Plexi-plus-Distortion+ roar — mid-heavy, articulate, classical precision.','The MXR pushes a loud Plexi; mids forward, never scooped.'],
     array['The opening drum barrage drops into fast riffing — precision first.','Rhodes'' double-tracked precision means clean execution matters.'],
     'Studio recording, 1981. Randy Rhoads'' MXR-boosted Marshall roar from Diary of a Madman.',82),
    ('flying-high-again','ozzy-osbourne','guitar','riff','main riff','high_gain','metal','rhythm','intermediate',
     'Jackson polka-dot V / cream Les Paul (Randy Rhoads)','Marshall 1959 Super Lead cranked','Marshall 4x12 cab','bridge humbucker',
     '[{"effect_type":"distortion","effect_name":"MXR Distortion+","placement":"front","settings":{"gain":6,"level":6}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":7,"treble":6,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['Swaggering mid-tempo Rhoads riff — warm boosted-Plexi crunch.','Same Diary rig: Distortion+ into loud Marshall, strong mids.'],
     array['The main riff swings — don''t play it stiff.','The tapped section of the solo is a signature moment.'],
     'Studio recording, 1981. Warm swaggering Rhoads crunch.',81),

    -- ============ BLACK SABBATH (Dio era: Iommi + Laney) ============
    ('heaven-and-hell','black-sabbath','guitar','riff','main riff','high_gain','metal','rhythm','intermediate',
     'Gibson SG (Tony Iommi)','Laney tube stack','Laney 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":6,"mids":6,"treble":5,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['Dio-era Iommi — thicker and more polished than the Ozzy years.','Warm dark Laney drive; huge sustain from the SG humbuckers.'],
     array['The galloping middle section shifts the whole song''s energy.','Iommi''s light-touch fingering (his famous fingertips) favors legato.'],
     'Studio recording, 1980. Iommi''s Laney-driven Dio-era epic.',79),
    ('neon-knights','black-sabbath','guitar','riff','main riff','high_gain','metal','rhythm','intermediate',
     'Gibson SG (Tony Iommi)','Laney tube stack','Laney 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Uptempo Dio-era opener — brighter and faster than classic Sabbath doom.','Driving Laney crunch with more top-end than the 70s records.'],
     array['Fast eighth-note drive throughout.','The solo is melodic Iommi at full speed.'],
     'Studio recording, 1980. Bright driving Dio-era Sabbath.',78),
    ('the-mob-rules','black-sabbath','guitar','riff','main riff','high_gain','metal','rhythm','intermediate',
     'Gibson SG (Tony Iommi)','Laney tube stack','Laney 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":6,"treble":5,"presence":5,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Aggressive stomping Dio-era riff — heavy Laney saturation.','Thick dark drive; the riff punches in short bursts.'],
     array['Stab the riff accents hard with the band.','Keep the shuffle undercurrent in the groove.'],
     'Studio recording, 1981. Stomping aggressive Dio-era Sabbath.',78),

    -- ============ SLAYER ============
    ('dead-skin-mask','slayer','guitar','riff','main riff','high_gain','thrash metal','rhythm','intermediate',
     'B.C. Rich / Jackson (Kerry King / Jeff Hanneman)','Marshall JCM800 boosted','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":5,"mids":4,"treble":7,"presence":7,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['Creeping mid-tempo Slayer — eerie chorused-feel intro into boosted JCM800 grind.','Scooped aggressive Marshall; the creepiness is in the riff, not effects.'],
     array['The hypnotic main riff repeats — keep it menacing and even.','Tremolo-picked sections build the dread.'],
     'Studio recording, 1990. Creeping boosted-Marshall menace from Seasons in the Abyss.',79),
    ('hell-awaits','slayer','guitar','riff','main riff','high_gain','thrash metal','rhythm','expert',
     'B.C. Rich (Kerry King / Jeff Hanneman)','Marshall JCM800 boosted','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":5,"mids":4,"treble":7,"presence":7,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['Raw mid-80s Slayer chaos — trebly boosted Marshall shred.','Rawer and brighter than later records; embrace the chaos.'],
     array['The long doomy intro reverses into full-speed thrash.','Tremolo picking and chromatic runs at extreme tempo.'],
     'Studio recording, 1985. Raw chaotic boosted-Marshall thrash.',78),

    -- ============ MOTORHEAD ============
    ('iron-fist','motorhead','guitar','riff','main riff','distorted','metal','rhythm','intermediate',
     'Fender Stratocaster (Fast Eddie Clarke)','Marshall tube stack cranked','Marshall 4x12 cab','bridge pickup',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['Filthy cranked-Marshall rock ''n'' roll at thrash speed.','Raw Marshall grind — loose, trebly, and loud; polish is wrong.'],
     array['Full-speed boogie riffing from bar one.','Play it dirty — Motorhead precision is controlled sloppiness.'],
     'Studio recording, 1982. Fast Eddie''s cranked-Marshall filth.',77)
) as c(
  song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence
)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;
