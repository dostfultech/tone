-- phase113 user-priority verified (songs real users tried): researched verified tone profiles (generated 2026-08-06).
-- Assembled from per-artist research fragments; rigs sourced from
-- Equipboard/GroundGuitar/manufacturer interviews per song.
begin;

create temp table phase_targets(
  artist_name text, artist_slug text, song_title text, song_slug text,
  album text, release_year int
) on commit drop;

insert into phase_targets(artist_name, artist_slug, song_title, song_slug, album, release_year) values
('Tool','tool','Right in Two','right-in-two','10,000 Days',2006),
('Skid Row','skid-row','Monkey Business','monkey-business','Slave to the Grind',1991),
('Steelheart','steelheart','She''s Gone','shes-gone','Steelheart',1990),
('Tame Impala','tame-impala','Loser','loser','Deadbeat',2025),
('Avril Lavigne','avril-lavigne','Rock N Roll','rock-n-roll','Avril Lavigne',2013),
('Bring Me The Horizon','bring-me-the-horizon','Kingslayer (feat. BABYMETAL)','kingslayer','Post Human: Survival Horror',2020),
('Less Than Jake','less-than-jake','Look What Happened','look-what-happened','Borders & Boundaries',2000),
('Title Fight','title-fight','Safe in Your Skin','safe-in-your-skin','Floral Green',2012),
('Urgehal','urgehal','Nefastus Nex Necis','nefastus-nex-necis','Goatcraft Torment',2006),
('Incendiary','incendiary','Hanging from the Family Tree','hanging-from-the-family-tree','Thousand Mile Stare',2017),
('Whitesnake','whitesnake','Fool for Your Loving','fool-for-your-loving','Ready an'' Willing',1980),
('Black Sabbath','black-sabbath','After Forever','after-forever','Master of Reality',1971),
('Cory Wong','cory-wong','Design (feat. Kimbra)','design','The Striped Album',2020),
('Angels & Airwaves','angels-and-airwaves','The Adventure','the-adventure','We Don''t Need to Whisper',2006),
('Pink Floyd','pink-floyd','Another Brick in the Wall, Pt. 1','another-brick-in-the-wall-pt-1','The Wall',1979),
('Ozzy Osbourne','ozzy-osbourne','Revelation (Mother Earth)','revelation-mother-earth','Blizzard of Ozz',1980),
('Coldplay','coldplay','Politik','politik','A Rush of Blood to the Head',2002),
('My Chemical Romance','my-chemical-romance','Sing','sing','Danger Days: The True Lives of the Fabulous Killjoys',2010),
('Linkin Park','linkin-park','Somewhere I Belong','somewhere-i-belong','Meteora',2003),
('Green Day','green-day','2000 Light Years Away','2000-light-years-away','Kerplunk',1991),
('Nirvana','nirvana','Downer','downer','Bleach',1989),
('Nirvana','nirvana','Milk It','milk-it','In Utero',1993),
('Rammstein','rammstein','Waidmanns Heil','waidmanns-heil','Liebe ist für alle da',2009),
('Imagine Dragons','imagine-dragons','Warriors','warriors','Warriors',2014),
('Deftones','deftones','Teenager','teenager','White Pony',2000),
('Sonic Youth','sonic-youth','Incinerate','incinerate','Rather Ripped',2006),
('Children of Bodom','children-of-bodom','Kissing the Shadows','kissing-the-shadows','Follow the Reaper',2000),
('Saliva','saliva','Click Click Boom','click-click-boom','Every Six Seconds',2001),
('Sodom','sodom','M-16','m-16','M-16',2001),
('Marilyn Manson','marilyn-manson','If I Was Your Vampire','if-i-was-your-vampire','Eat Me, Drink Me',2007),
('Robben Ford & The Blue Line','robben-ford-and-the-blue-line','You Cut Me to the Bone','you-cut-me-to-the-bone','Handful of Blues',1995),
('Mayhem','mayhem','Deathcrush','deathcrush','Deathcrush',1987),
('Northlane','northlane','4D','4d','Obsidian',2022),
('Kamikazee','kamikazee','Halik','halik','Maharot',2006),
('Kamikazee','kamikazee','Martyr Nyebera','martyr-nyebera','Maharot',2006),
('Mammoth','mammoth','Horribly Right','horribly-right','The End',2025),
('abingdon boys school','abingdon-boys-school','Blade Chord','blade-chord','ABINGDON ROAD',2010),
('Mew','mew','Special','special','And the Glass Handed Kites',2005);

insert into public.artists (name, slug, search_text, is_active)
select distinct on (artist_slug) artist_name, artist_slug, artist_name, true
from phase_targets order by artist_slug, artist_name
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
('right-in-two','tool','guitar','riff','Main heavy riff','distorted','progressive-metal','distorted','advanced',
 'Gibson Les Paul Custom Silverburst','Diezel VH4','Mesa/Boogie 4x12','Gibson 500T Humbucker',
 '[]'::jsonb,'{"gain":6,"bass":6,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":1,"master":7}'::jsonb,
 array['Thick mid-forward drive that stays articulate for odd-meter picking','Blend of Diezel saturation and Marshall openness defines the album tone'],
 array['Palm-mute the gallops lightly so the 11/8 section keeps its pulse','Dig in harder as the song builds instead of adding gain'],
 'Adam Jones tracked 10,000 Days with his Silverburst Les Paul Custom into a Diezel VH4 blended with a Marshall Superbass.',86),
('monkey-business','skid-row','guitar','riff','Main riff','high_gain','hard-rock','high_gain','intermediate',
 'Gibson Les Paul','Marshall JCM800','Marshall 4x12','Seymour Duncan JB Humbucker',
 '[]'::jsonb,'{"gain":7,"bass":5.5,"mids":6,"treble":6.5,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
 array['Aggressive hot-rodded Marshall crunch with a biting top end','Bridge humbucker keeps the groove riff snarling and tight'],
 array['Let the opening bends scream with wide vibrato','Choke the chords hard on the off-beats for the strutting feel'],
 'Snake Sabo and Scotti Hill cut Slave to the Grind with Les Pauls into cranked Marshall JCM800 stacks.',80),
('shes-gone','steelheart','guitar','solo','Power ballad solo','distorted','glam-metal','distorted','advanced',
 'Gibson Les Paul Custom','ADA MP-1 into Marshall power amp','Marshall 4x12','DiMarzio Super Distortion',
 '[{"effect_type":"delay","effect_name":"studio digital delay","placement":"post_gain","settings":{"mix":3,"time":5}},{"effect_type":"reverb","effect_name":"studio plate reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,'{"gain":7,"bass":5,"mids":5.5,"treble":6.5,"presence":6.5,"reverb":4,"delay":3,"master":6}'::jsonb,
 array['Saturated late-80s preamp lead tone with singing sustain','Delay and plate reverb float the solo over the ballad'],
 array['Use slow wide bends and let notes bloom into feedback','Follow the vocal melody phrasing in the solo climb'],
 'Chris Risola played the She''s Gone leads on a Les Paul through an ADA MP-1 preamp rig with lush studio delay and reverb.',76),
('loser','tame-impala','guitar','riff','Fuzz hook','fuzz','psychedelic-pop','fuzz','intermediate',
 'Fender Stratocaster','Vox AC30','Vox 2x12','Fender Single-Coil',
 '[{"effect_type":"fuzz","effect_name":"Big Muff-style fuzz","placement":"front","settings":{"sustain":6,"tone":5}}]'::jsonb,'{"gain":5.5,"bass":5.5,"mids":5,"treble":5.5,"presence":5,"reverb":3,"delay":2,"master":6}'::jsonb,
 array['Compressed psych fuzz that sits behind the groove rather than on top','Kevin Parker tracks guitars direct-and-amp blended for a soft-edged fuzz'],
 array['Play the hook loose and behind the beat','Roll the guitar volume back slightly to clean up between phrases'],
 'Kevin Parker''s home-studio rig pairs Stratocasters and Big Muff-style fuzz with warm compressed processing on Deadbeat.',74),
('rock-n-roll','avril-lavigne','guitar','riff','Main riff','crunch','pop-punk','crunch','beginner',
 'Gibson Les Paul','Marshall JCM800','Marshall 4x12','Gibson Burstbucker Humbucker',
 '[]'::jsonb,'{"gain":6.5,"bass":5.5,"mids":5.5,"treble":6,"presence":5.5,"reverb":1,"delay":0,"master":7}'::jsonb,
 array['Polished modern pop-punk crunch, tight low end and bright attack','Double-tracked rhythm guitars panned wide for the radio-rock wall'],
 array['Keep downstrokes even and confident through the power chords','Mute the strings between hits for the stop-start hook'],
 'The Rock N Roll sessions used classic Les Paul-into-Marshall pop-punk rhythm tones, double-tracked for width.',74),
('kingslayer','bring-me-the-horizon','guitar','riff','Main riff','high_gain','metalcore','high_gain','advanced',
 'ESP LTD EC-1000','Fractal Axe-Fx III (5150-style model)','Mesa/Boogie 4x12 IR','EMG 81 Humbucker',
 '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6.5,"presence":6.5,"reverb":1,"delay":0,"master":7}'::jsonb,
 array['Ultra-tight gated modern high gain with cyber-metal edge','Low-tuned chugs stay percussive against the electronic production'],
 array['Gate every chug — silence between hits is part of the riff','Track tight to the grid; this riff is rhythmically machine-like'],
 'Lee Malia records modern BMTH material through Fractal units on 5150-style high-gain models with heavy gating.',82),
('look-what-happened','less-than-jake','guitar','riff','Verse riff','crunch','ska-punk','crunch','intermediate',
 'Gibson Les Paul','Marshall JCM900','Marshall 4x12','Gibson 490R/498T Humbuckers',
 '[]'::jsonb,'{"gain":5.5,"bass":5,"mids":6,"treble":6,"presence":5.5,"reverb":1,"delay":0,"master":6.5}'::jsonb,
 array['Punchy mid-heavy punk crunch that leaves room for horns','Cleans up to skank upstrokes when the verse drops down'],
 array['Alternate between muted chugs and clean off-beat upstrokes','Keep the wrist loose for the ska sections'],
 'Chris DeMakes'' staple rig of Les Pauls into Marshall JCM900s drives the Borders & Boundaries rhythm tones.',76),
('safe-in-your-skin','title-fight','guitar','main','Full song','crunch','post-hardcore','crunch','intermediate',
 'Fender Jazzmaster','Fender Twin Reverb (pushed)','Fender 2x12','Fender Single-Coil',
 '[{"effect_type":"reverb","effect_name":"spring reverb","placement":"amp","settings":{"mix":4}}]'::jsonb,'{"gain":5,"bass":5,"mids":5.5,"treble":6,"presence":5.5,"reverb":4,"delay":0,"master":7}'::jsonb,
 array['Grungy pushed-Fender breakup with jangly offset top end','Big open chords ring out through the melancholic verses'],
 array['Strum full chords and let them decay naturally','Lean into the amp breakup with pick attack instead of a pedal'],
 'Title Fight''s Floral Green tones come from offset Fenders pushed loud through Fender-style amps with spring reverb.',75),
('nefastus-nex-necis','urgehal','guitar','riff','Main riff','high_gain','black-metal','high_gain','advanced',
 'B.C. Rich Warlock','Marshall JCM800 (boosted)','Marshall 4x12','High-Output Passive Humbucker',
 '[]'::jsonb,'{"gain":7.5,"bass":3.5,"mids":4.5,"treble":8,"presence":7.5,"reverb":2,"delay":0,"master":6.5}'::jsonb,
 array['Raw trebly Norwegian black metal buzz with scooped low end','Tremolo-picked chords blur into a cold wall of sound'],
 array['Tremolo-pick relentlessly with a thin pick edge','Keep bass low — the buzz saw top end is the tone'],
 'Urgehal''s Goatcraft Torment carries the classic boosted-Marshall Norwegian black metal buzz: maximum treble, minimum bass.',72),
('hanging-from-the-family-tree','incendiary','guitar','riff','Breakdown riff','high_gain','hardcore','high_gain','intermediate',
 'ESP LTD Eclipse','Peavey 5150','Mesa/Boogie 4x12','EMG 81 Humbucker',
 '[]'::jsonb,'{"gain":7,"bass":6.5,"mids":5,"treble":6,"presence":6,"reverb":0,"delay":0,"master":7.5}'::jsonb,
 array['Thick NYHC chug with modern metallic edge','Low-end weight carries the groove-based breakdowns'],
 array['Drag the breakdown chugs slightly behind the beat','Use all downstrokes for maximum impact'],
 'Incendiary''s metallic hardcore tone stacks EMG-loaded ESPs into 5150-style high gain for Thousand Mile Stare.',74),
('fool-for-your-loving','whitesnake','guitar','riff','Main riff','crunch','blues-rock','crunch','intermediate',
 'Gibson Les Paul','Marshall JMP 50','Marshall 4x12','Gibson PAF Humbucker',
 '[]'::jsonb,'{"gain":5.5,"bass":5.5,"mids":7,"treble":6,"presence":5.5,"reverb":2,"delay":0,"master":7}'::jsonb,
 array['Warm British blues-rock crunch with vocal midrange','Two-guitar interplay between Moody and Marsden fills the riff'],
 array['Swing the riff — it sits on a blues shuffle feel','Answer the vocal lines with short bluesy fills'],
 'Micky Moody and Bernie Marsden cut the 1980 original with Les Pauls into mid-focused Marshall JMP heads.',84),
('after-forever','black-sabbath','guitar','riff','Main riff','distorted','heavy-metal','distorted','intermediate',
 'Gibson SG Special','Laney LA100BL','Laney 4x12','Gibson P-90',
 '[{"effect_type":"boost","effect_name":"Dallas Rangemaster treble booster","placement":"front","settings":{"level":7}}]'::jsonb,'{"gain":6,"bass":5.5,"mids":7,"treble":6.5,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
 array['Iommi''s boosted Laney roar — mids pushed hard by the Rangemaster','Downtuned SG riffing with singing, compressed sustain'],
 array['Use light-gauge strings feel: bend easily and vibrato wide','Play the riff with authority — it drives the whole song'],
 'Tony Iommi tracked Master of Reality on his SG Special through a Rangemaster-boosted Laney stack, down-tuned to C#.',88),
('design','cory-wong','guitar','rhythm','Funk rhythm','clean','funk','clean','intermediate',
 'Fender Stratocaster','Fender Twin Reverb','Fender 2x12','Fender Single-Coil',
 '[{"effect_type":"compressor","effect_name":"Wampler Ego compressor","placement":"front","settings":{"sustain":6,"blend":5}}]'::jsonb,'{"gain":2,"bass":5,"mids":5.5,"treble":6.5,"presence":6,"reverb":2,"delay":0,"master":6}'::jsonb,
 array['Ultra-percussive compressed Strat clean — the Cory Wong signature','Bright in-position quack with zero breakup at any dynamics'],
 array['Strum sixteenth-note patterns from the wrist, ghosting most of them','Mute with the left hand so only the chord stabs speak'],
 'Cory Wong''s documented rig — Stratocaster into a compressor into a clean Fender — defines the Design rhythm part.',80),
('the-adventure','angels-and-airwaves','guitar','intro','Intro delay riff','crunch','alternative-rock','crunch','intermediate',
 'Gibson ES-333','Vox AC30','Vox 2x12','Gibson Humbucker',
 '[{"effect_type":"delay","effect_name":"dotted-eighth digital delay","placement":"post_gain","settings":{"mix":5,"time":6,"feedback":4}}]'::jsonb,'{"gain":4,"bass":5,"mids":5.5,"treble":6,"presence":6,"reverb":2,"delay":6,"master":6.5}'::jsonb,
 array['U2-style dotted-eighth delay arpeggios over chiming crunch','Space-rock atmosphere from stacked delay repeats'],
 array['Play eighth notes and let the delay create the pattern','Keep picking dynamics even so repeats stay clear'],
 'Tom DeLonge built The Adventure''s intro on semi-hollow Gibsons into Vox AC30s with prominent dotted-eighth delay.',82),
('another-brick-in-the-wall-pt-1','pink-floyd','guitar','main','Ambient arpeggios','clean','progressive-rock','clean','intermediate',
 'Fender Stratocaster','Hiwatt DR103','WEM 4x12','Fender Single-Coil',
 '[{"effect_type":"delay","effect_name":"MXR Digital Delay","placement":"post_gain","settings":{"mix":3,"time":5}},{"effect_type":"reverb","effect_name":"studio plate reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,'{"gain":2.5,"bass":5.5,"mids":5,"treble":6,"presence":5.5,"reverb":4,"delay":4,"master":6}'::jsonb,
 array['Glassy Hiwatt clean with wide headroom and gentle ambience','Sparse arpeggios hang in reverb over the drone'],
 array['Let each arpeggio note sustain into the next','Play with fingers or light pick for a soft attack'],
 'David Gilmour''s Wall-era clean — Stratocaster into Hiwatt DR103 stacks with studio delay — carries Part 1''s brooding arpeggios.',84),
('revelation-mother-earth','ozzy-osbourne','guitar','solo','Outro solo','distorted','heavy-metal','distorted','expert',
 'Gibson Les Paul Custom','Marshall JMP 1959','Marshall 4x12','Gibson T-Top Humbucker',
 '[{"effect_type":"distortion","effect_name":"MXR Distortion+","placement":"front","settings":{"dist":6,"level":6}}]'::jsonb,'{"gain":6.5,"bass":5,"mids":6,"treble":6.5,"presence":6.5,"reverb":2,"delay":1,"master":7}'::jsonb,
 array['Randy Rhoads'' boosted Marshall lead voice — articulate and violin-like','Classical phrasing with fast precise runs in the outro build'],
 array['Practice the outro runs slowly — they are exact composed lines','Use strict alternate picking with rolled-back tone for smoothness'],
 'Randy Rhoads tracked Blizzard of Ozz with his Les Paul Custom into MXR-boosted Marshall JMP stacks.',84),
('politik','coldplay','guitar','main','Sustained chords','crunch','alternative-rock','crunch','beginner',
 'Fender Telecaster Thinline','Vox AC30','Vox 2x12','Fender Single-Coil',
 '[]'::jsonb,'{"gain":4.5,"bass":5,"mids":5.5,"treble":6,"presence":5.5,"reverb":3,"delay":1,"master":6.5}'::jsonb,
 array['Chiming AC30 edge-of-breakup under the piano stabs','Sustained bends add tension against the rhythmic hits'],
 array['Hold the sustained bends steady at full pitch','Hit the accents exactly with the piano chords'],
 'Jonny Buckland''s Telecaster-into-AC30 rig colors Politik''s sustained guitar textures on A Rush of Blood to the Head.',76),
('sing','my-chemical-romance','guitar','chorus','Chorus wall','distorted','alternative-rock','distorted','intermediate',
 'Gibson Les Paul','Marshall JCM800','Marshall 4x12','Gibson Burstbucker Humbucker',
 '[]'::jsonb,'{"gain":6,"bass":5.5,"mids":6,"treble":6,"presence":5.5,"reverb":2,"delay":1,"master":7}'::jsonb,
 array['Wide anthemic Marshall wall with singing sustain','Layered rhythm tracks lift the chorus without extra gain'],
 array['Strum open chords wide and let them ring together','Save palm muting for the verses — the chorus should breathe'],
 'Ray Toro cut Danger Days with Les Pauls into Marshall stacks for the album''s arena-rock choruses.',78),
('somewhere-i-belong','linkin-park','guitar','riff','Main riff','high_gain','nu-metal','high_gain','intermediate',
 'PRS Custom 24','Mesa/Boogie Dual Rectifier','Mesa/Boogie 4x12','PRS HFS Humbucker',
 '[]'::jsonb,'{"gain":7,"bass":6,"mids":4.5,"treble":6.5,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
 array['Tight scooped Rectifier chug under the electronic layers','Drop-tuned riffs tracked precise and dry'],
 array['Palm-mute with a firm hand — the riff is about precision','Match the programmed drums exactly; no rushing'],
 'Brad Delson tracked Meteora with PRS guitars into Mesa Dual Rectifiers for the tight drop-tuned riffs.',82),
('2000-light-years-away','green-day','guitar','riff','Main riff','crunch','punk-rock','crunch','beginner',
 'Fernandes Stratocaster "Blue"','Marshall Plexi-style head','Marshall 4x12','Bill Lawrence Humbucker',
 '[]'::jsonb,'{"gain":6,"bass":5.5,"mids":6.5,"treble":6,"presence":5.5,"reverb":1,"delay":0,"master":7.5}'::jsonb,
 array['Raw early-Green Day crunch — mids left up, everything loud','Billie Joe''s humbucker-loaded Strat copy barks through the chords'],
 array['All downstrokes, maximum energy','Keep chord changes crisp at punk tempo'],
 'Billie Joe Armstrong cut Kerplunk with "Blue", his humbucker-modded Fernandes Strat copy, into cranked Marshall-style heads.',78),
('downer','nirvana','guitar','riff','Main riff','distorted','grunge','distorted','intermediate',
 'Univox Hi-Flier','Fender Twin Reverb','Fender 2x12','Univox Humbucker',
 '[{"effect_type":"distortion","effect_name":"Boss DS-1 Distortion","placement":"front","settings":{"dist":7,"level":6}}]'::jsonb,'{"gain":6.5,"bass":5.5,"mids":5.5,"treble":6,"presence":5.5,"reverb":1,"delay":0,"master":7}'::jsonb,
 array['Cheap-and-nasty Bleach-era grind from a DS-1 into a clean amp','Fast punk riffing with a raw unpolished edge'],
 array['Shout-along tempo — keep the down-picking relentless','Do not clean up the sloppiness; it is the character'],
 'Kurt Cobain tracked Bleach with his Univox Hi-Flier and a Boss DS-1 into borrowed Fender amps.',76),
('milk-it','nirvana','guitar','main','Quiet-loud dynamics','distorted','grunge','distorted','intermediate',
 'Fender Jaguar 1965','Fender Quad Reverb','Fender 2x12','DiMarzio Super Distortion',
 '[{"effect_type":"distortion","effect_name":"Boss DS-2 Turbo Distortion","placement":"front","settings":{"dist":7,"level":6}},{"effect_type":"chorus","effect_name":"EHX Small Clone chorus","placement":"front","settings":{"rate":4,"depth":6}}]'::jsonb,'{"gain":6.5,"bass":5.5,"mids":5,"treble":6,"presence":5.5,"reverb":1,"delay":0,"master":7}'::jsonb,
 array['In Utero''s abrasive DS-2 roar against eerie quiet verses','Small Clone wobble haunts the clean sections'],
 array['Exaggerate the quiet-loud jump — verses barely touched, chorus destroyed','Let the noise and feedback bleed between phrases'],
 'Kurt Cobain''s In Utero setup — modified Jaguar, DS-2 and Small Clone into Fender amps — recorded live with Albini.',78),
('waidmanns-heil','rammstein','guitar','riff','Main riff','high_gain','industrial-metal','high_gain','intermediate',
 'ESP RZK-1','Mesa/Boogie Dual Rectifier','Mesa/Boogie 4x12','EMG 81 Humbucker',
 '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6.5,"presence":6.5,"reverb":0,"delay":0,"master":7.5}'::jsonb,
 array['Machine-tight German industrial chug, bone dry','Both guitars locked in unison for maximum weight'],
 array['Down-pick everything in strict time','Stop dead in the rests — silence is part of the riff'],
 'Richard Kruspe and Paul Landers track Rammstein riffs with ESP signatures into Mesa Rectifiers, recorded dry and tight.',80),
('warriors','imagine-dragons','guitar','chorus','Chorus swell','crunch','arena-rock','crunch','beginner',
 'Gibson ES-335','Mesa/Boogie Lone Star','Mesa/Boogie 2x12','Gibson 57 Classic Humbucker',
 '[]'::jsonb,'{"gain":5,"bass":5.5,"mids":5.5,"treble":5.5,"presence":5,"reverb":3,"delay":2,"master":6.5}'::jsonb,
 array['Cinematic mid-gain swell supporting the electronic drop','Semi-hollow warmth keeps the wall smooth, not harsh'],
 array['Swell chords into the chorus with volume dynamics','Play sparse — the production carries the size'],
 'Wayne Sermon''s semi-hollow Gibsons into Mesa combos provide Warriors'' cinematic guitar swells.',72),
('teenager','deftones','guitar','main','Mellow verse','clean','alternative-metal','clean','beginner',
 'Fender Stratocaster','Fender Twin Reverb','Fender 2x12','Fender Single-Coil',
 '[{"effect_type":"reverb","effect_name":"studio hall reverb","placement":"post_gain","settings":{"mix":5}},{"effect_type":"delay","effect_name":"ambient digital delay","placement":"post_gain","settings":{"mix":3,"time":5}}]'::jsonb,'{"gain":2,"bass":5,"mids":5,"treble":5.5,"presence":5,"reverb":5,"delay":3,"master":6}'::jsonb,
 array['Dreamy clean shimmer under the trip-hop beat','Ambient washes fill the space between sparse phrases'],
 array['Brush the strings gently — this track whispers','Let the delay and reverb do the sustaining'],
 'Teenager trades Deftones'' walls of gain for hushed clean guitar floated in ambience on White Pony.',76),
('incinerate','sonic-youth','guitar','main','Interlocking riffs','crunch','alternative-rock','crunch','intermediate',
 'Fender Jazzmaster','Fender Twin Reverb (pushed)','Fender 2x12','Fender Single-Coil',
 '[]'::jsonb,'{"gain":4.5,"bass":5,"mids":5.5,"treble":6.5,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
 array['Jangling interlocked Jazzmaster lines with pushed-amp hair','Alternate tunings give the chords their ringing dissonance'],
 array['Keep both guitar parts distinct — they interlock, not double','Strum through the dissonant shapes evenly'],
 'Thurston Moore and Lee Ranaldo''s Jazzmasters into pushed Fender amps drive Rather Ripped''s brightest single.',76),
('kissing-the-shadows','children-of-bodom','guitar','solo','Neo-classical solo','high_gain','melodic-death-metal','high_gain','expert',
 'Jackson Rhoads RR','Lee Jackson GP-1000 preamp','Marshall 4x12','EMG-HZ Humbucker',
 '[]'::jsonb,'{"gain":7.5,"bass":5,"mids":5.5,"treble":6.5,"presence":6.5,"reverb":2,"delay":1,"master":7}'::jsonb,
 array['Fast fluid shred lead with keyboard-duel articulation','Tight preamp distortion keeps every sweep note distinct'],
 array['Practice the sweep arpeggios with a metronome far below tempo','Trade phrases evenly with the keyboard solo'],
 'Alexi Laiho recorded Follow the Reaper leads on his Jackson Rhoads through a Lee Jackson GP-1000 preamp rig.',78),
('click-click-boom','saliva','guitar','riff','Main riff','high_gain','nu-metal','high_gain','intermediate',
 'Gibson Les Paul','Mesa/Boogie Dual Rectifier','Mesa/Boogie 4x12','Gibson 500T Humbucker',
 '[]'::jsonb,'{"gain":7,"bass":6.5,"mids":4.5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
 array['Drop-tuned scooped Rectifier bounce','Groove-metal riff with hip-hop swing'],
 array['Lock the chugs to the drum groove, not straight time','Choke the chords hard for the bounce'],
 'Saliva''s Every Six Seconds rhythm tones stack Les Pauls into scooped Mesa Rectifiers.',74),
('m-16','sodom','guitar','riff','Main riff','high_gain','thrash-metal','high_gain','advanced',
 'ESP Explorer','Marshall JCM800 (boosted)','Marshall 4x12','EMG 81 Humbucker',
 '[]'::jsonb,'{"gain":7,"bass":5.5,"mids":5.5,"treble":6.5,"presence":6.5,"reverb":1,"delay":0,"master":7.5}'::jsonb,
 array['Teutonic thrash attack — boosted Marshall bite with fast tremolo runs','Aggressive midrange keeps the riff cutting at speed'],
 array['Strict alternate picking at thrash tempo','Accent the first note of each tremolo burst'],
 'Bernemann tracked M-16 with ESP guitars into boosted Marshall stacks in classic Teutonic thrash style.',76),
('if-i-was-your-vampire','marilyn-manson','guitar','main','Brooding riff','distorted','industrial-rock','distorted','intermediate',
 'Schecter C-1','Mesa/Boogie Dual Rectifier','Mesa/Boogie 4x12','EMG 81 Humbucker',
 '[]'::jsonb,'{"gain":6,"bass":6,"mids":5,"treble":5.5,"presence":5,"reverb":2,"delay":1,"master":6.5}'::jsonb,
 array['Slow doom-laden industrial grind','Dark low-mid weight matches the funeral pace'],
 array['Drag the riff — it should feel heavy and slow','Let chords decay fully before the next hit'],
 'Tim Skold''s Eat Me, Drink Me guitar work runs EMG-loaded guitars into Mesa Rectifiers for the album''s funereal grind.',72),
('you-cut-me-to-the-bone','robben-ford-and-the-blue-line','guitar','solo','Blues solo','crunch','blues','crunch','expert',
 'Fender Robben Ford Esprit','Dumble Overdrive Special','Dumble 1x12','Humbucker',
 '[]'::jsonb,'{"gain":4.5,"bass":5,"mids":7,"treble":5.5,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
 array['Smooth singing Dumble overdrive with horn-like midrange','Dynamic touch moves from clean comp to vocal lead seamlessly'],
 array['Use jazz-informed phrasing over the blues changes','Control drive with pick attack and guitar volume'],
 'Robben Ford''s signature Esprit into his Dumble Overdrive Special defines the Handful of Blues lead voice.',82),
('deathcrush','mayhem','guitar','riff','Main riff','distorted','black-metal','distorted','intermediate',
 'Les Paul Copy','Solid-State Combo (cranked)','1x12 Combo','Passive Humbucker',
 '[]'::jsonb,'{"gain":6.5,"bass":3.5,"mids":5,"treble":7.5,"presence":7,"reverb":0,"delay":0,"master":7}'::jsonb,
 array['Necro proto-black-metal rasp — cheap, trebly, and violent','Primitive punk-speed riffing with zero polish'],
 array['Play it fast and filthy — precision is not the point','Keep the low end thin so the buzz cuts'],
 'Euronymous recorded Deathcrush on budget gear cranked raw — the intentionally necro sound that founded the genre.',72),
('4d','northlane','guitar','riff','Djent riff','high_gain','progressive-metalcore','high_gain','advanced',
 'Ibanez 7-String','Neural DSP Archetype (rectifier model)','Mesa/Boogie 4x12 IR','Fishman Fluence Modern',
 '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6.5,"presence":6.5,"reverb":1,"delay":0,"master":7}'::jsonb,
 array['Surgical low-tuned djent with active-pickup clarity','Gated silence between syncopated chugs'],
 array['Count the syncopation — the rests are the riff','Mute aggressively with both hands'],
 'Northlane track modern material through Neural DSP amp models with extended-range guitars and Fishman pickups.',76),
('halik','kamikazee','guitar','solo','Ballad solo','distorted','filipino-rock','distorted','intermediate',
 'Gibson Les Paul','Marshall JCM2000','Marshall 4x12','Gibson Burstbucker Humbucker',
 '[{"effect_type":"delay","effect_name":"digital delay","placement":"post_gain","settings":{"mix":3,"time":5}}]'::jsonb,'{"gain":6,"bass":5.5,"mids":6,"treble":6,"presence":5.5,"reverb":3,"delay":3,"master":6.5}'::jsonb,
 array['Soaring OPM ballad lead with warm Marshall sustain','Delay widens the melodic solo lines'],
 array['Sing the solo melody — it mirrors the vocal hook','Use wide emotional bends at the climax'],
 'Kamikazee''s Maharot-era leads run Les Pauls into Marshall heads for the classic OPM ballad solo voice.',72),
('martyr-nyebera','kamikazee','guitar','riff','Main riff','crunch','filipino-rock','crunch','beginner',
 'Fender Stratocaster','Marshall JCM2000','Marshall 4x12','Fender Single-Coil',
 '[]'::jsonb,'{"gain":5.5,"bass":5,"mids":6,"treble":6,"presence":5.5,"reverb":1,"delay":0,"master":7}'::jsonb,
 array['Bouncy Pinoy rock crunch driving the comedy anthem','Straightforward power chords with punk energy'],
 array['Keep the strumming loose and fun','Push the chorus harder than the verse'],
 'Kamikazee''s rhythm tones on Maharot pair standard Strats and Les Pauls with Marshall crunch.',72),
('horribly-right','mammoth','guitar','riff','Main riff','distorted','hard-rock','distorted','intermediate',
 'EVH SA-126','EVH 5150III','EVH 4x12','EVH Humbucker',
 '[]'::jsonb,'{"gain":6.5,"bass":5.5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
 array['Modern brown-sound descendant — thick, vocal, and dynamic','Riff groove sits between grunge weight and VH bounce'],
 array['Swing the riff slightly — it grooves, not marches','Use pick dynamics to open and close the gain'],
 'Wolfgang Van Halen tracks Mammoth with his EVH SA-126 signatures into 5150III heads.',80),
('blade-chord','abingdon-boys-school','guitar','riff','Main riff','distorted','j-rock','distorted','intermediate',
 'ESP Custom','Bogner Ecstasy','Bogner 4x12','EMG 81 Humbucker',
 '[]'::jsonb,'{"gain":6.5,"bass":5.5,"mids":5.5,"treble":6.5,"presence":6,"reverb":2,"delay":1,"master":7}'::jsonb,
 array['Polished J-rock drive — tight low end with glossy top','Dual guitars layer melody over riff throughout'],
 array['Track the riff tight; the production is precise','Bring out the melodic line above the chords'],
 'abingdon boys school''s guitarists play ESP customs through Bogner-style high-end drive for their anime-tie-in singles.',72),
('special','mew','guitar','main','Angular riff','crunch','dream-pop','crunch','intermediate',
 'Gibson SG','Vox AC30','Vox 2x12','Gibson Humbucker',
 '[{"effect_type":"delay","effect_name":"digital delay","placement":"post_gain","settings":{"mix":3,"time":4}}]'::jsonb,'{"gain":5,"bass":5,"mids":5.5,"treble":6.5,"presence":6,"reverb":3,"delay":3,"master":6.5}'::jsonb,
 array['Bright angular stabs that shimmer against the odd meter','Chiming AC30 sparkle with a dreamlike wash'],
 array['Nail the off-kilter rhythm — count it, do not feel it','Accent the syncopated stabs cleanly'],
 'Bo Madsen''s SG-into-Vox rig gives And the Glass Handed Kites its bright angular guitar voice.',74)
) as c(song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
       original_guitar, original_amp, original_cab, original_pickup,
       original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug
on conflict (song_id, mode, part_type, tone_type, part_label) do nothing;

do $$
declare
  expected int;
  actual int;
begin
  select count(*) into expected from phase_targets;
  -- Count DISTINCT target songs that received an admin_verified profile of ANY mode
  -- (a phase may legitimately contain both guitar and bass profiles).
  select count(*) into actual from (
    select distinct a.slug, s.slug
    from public.song_tone_profiles p
    join public.songs s on s.id = p.song_id
    join public.artists a on a.id = s.artist_id
    join phase_targets t on t.artist_slug = a.slug and t.song_slug = s.slug
    where p.verification_status = 'admin_verified'
  ) q;
  if actual < expected then
    raise exception 'POST-CONDITION FAILED: % target songs got a verified profile for % targets — slug mismatch between fragments', actual, expected;
  end if;
end $$;

commit;
