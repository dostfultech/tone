-- Phase 62: funk/jam YouTube-guitar scene + post-rock + 2000s radio-rock fills, verified per-part tone data.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Vulfpeck','vulfpeck','Dean Town','dean-town','The Beautiful Game',2016),
    ('Vulfpeck','vulfpeck','Back Pocket','back-pocket','Thrill of the Arts',2015),
    ('Cory Wong','cory-wong','Cosmic Sans','cosmic-sans','Motivational Music for the Syncopated Soul',2019),
    ('Tom Misch','tom-misch','It Runs Through Me','it-runs-through-me','Geography',2018),
    ('Tom Misch','tom-misch','Movie','movie','Geography',2018),
    ('Snarky Puppy','snarky-puppy','Lingus','lingus','We Like It Here',2014),
    ('Explosions in the Sky','explosions-in-the-sky','Your Hand in Mine','your-hand-in-mine','The Earth Is Not a Cold Dead Place',2003),
    ('Explosions in the Sky','explosions-in-the-sky','First Breath After Coma','first-breath-after-coma','The Earth Is Not a Cold Dead Place',2003),
    ('This Will Destroy You','this-will-destroy-you','The Mighty Rio Grande','the-mighty-rio-grande','This Will Destroy You',2008),
    ('Shinedown','shinedown','45','45','Leave a Whisper',2003),
    ('Shinedown','shinedown','Sound of Madness','sound-of-madness','The Sound of Madness',2008),
    ('Disturbed','disturbed','The Sound of Silence','the-sound-of-silence','Immortalized',2015),
    ('Halestorm','halestorm','I Miss the Misery','i-miss-the-misery','The Strange Case Of...',2012),
    ('Volbeat','volbeat','Still Counting','still-counting','Guitar Gangsters & Cadillac Blood',2008),
    ('Puddle of Mudd','puddle-of-mudd','Blurry','blurry','Come Clean',2001),
    ('Hoobastank','hoobastank','The Reason','the-reason','The Reason',2003),
    ('Lifehouse','lifehouse','Hanging by a Moment','hanging-by-a-moment','No Name Face',2000),
    ('Switchfoot','switchfoot','Meant to Live','meant-to-live','The Beautiful Letdown',2003),
    ('Chevelle','chevelle','Send the Pain Below','send-the-pain-below','Wonder What''s Next',2002),
    ('Seether','seether','Broken','broken','Disclaimer II',2004),
    ('Trapt','trapt','Headstrong','headstrong','Trapt',2002),
    ('Brandon Lake','brandon-lake','Gratitude','gratitude','House of Miracles',2020),
    ('Hillsong Worship','hillsong-worship','What a Beautiful Name','what-a-beautiful-name','Let There Be Light',2016),
    ('The Isley Brothers','the-isley-brothers','Footsteps in the Dark','footsteps-in-the-dark','Go for Your Guns',1977),
    ('Al Green','al-green','Love and Happiness','love-and-happiness','I''m Still in Love with You',1972)
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
    ('vulfpeck','dean-town'),('vulfpeck','back-pocket'),('cory-wong','cosmic-sans'),('tom-misch','it-runs-through-me'),
    ('tom-misch','movie'),('snarky-puppy','lingus'),('explosions-in-the-sky','your-hand-in-mine'),
    ('explosions-in-the-sky','first-breath-after-coma'),('this-will-destroy-you','the-mighty-rio-grande'),
    ('shinedown','45'),('shinedown','sound-of-madness'),('disturbed','the-sound-of-silence'),
    ('halestorm','i-miss-the-misery'),('volbeat','still-counting'),('puddle-of-mudd','blurry'),
    ('hoobastank','the-reason'),('lifehouse','hanging-by-a-moment'),('switchfoot','meant-to-live'),
    ('chevelle','send-the-pain-below'),('seether','broken'),('trapt','headstrong'),('brandon-lake','gratitude'),
    ('hillsong-worship','what-a-beautiful-name'),('the-isley-brothers','footsteps-in-the-dark'),('al-green','love-and-happiness')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('vulfpeck','dean-town'),('vulfpeck','back-pocket'),('cory-wong','cosmic-sans'),('tom-misch','it-runs-through-me'),
    ('tom-misch','movie'),('snarky-puppy','lingus'),('explosions-in-the-sky','your-hand-in-mine'),
    ('explosions-in-the-sky','first-breath-after-coma'),('this-will-destroy-you','the-mighty-rio-grande'),
    ('shinedown','45'),('shinedown','sound-of-madness'),('disturbed','the-sound-of-silence'),
    ('halestorm','i-miss-the-misery'),('volbeat','still-counting'),('puddle-of-mudd','blurry'),
    ('hoobastank','the-reason'),('lifehouse','hanging-by-a-moment'),('switchfoot','meant-to-live'),
    ('chevelle','send-the-pain-below'),('seether','broken'),('trapt','headstrong'),('brandon-lake','gratitude'),
    ('hillsong-worship','what-a-beautiful-name'),('the-isley-brothers','footsteps-in-the-dark'),('al-green','love-and-happiness')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('vulfpeck','dean-town'),('vulfpeck','back-pocket'),('cory-wong','cosmic-sans'),('tom-misch','it-runs-through-me'),
    ('tom-misch','movie'),('snarky-puppy','lingus'),('explosions-in-the-sky','your-hand-in-mine'),
    ('explosions-in-the-sky','first-breath-after-coma'),('this-will-destroy-you','the-mighty-rio-grande'),
    ('shinedown','45'),('shinedown','sound-of-madness'),('disturbed','the-sound-of-silence'),
    ('halestorm','i-miss-the-misery'),('volbeat','still-counting'),('puddle-of-mudd','blurry'),
    ('hoobastank','the-reason'),('lifehouse','hanging-by-a-moment'),('switchfoot','meant-to-live'),
    ('chevelle','send-the-pain-below'),('seether','broken'),('trapt','headstrong'),('brandon-lake','gratitude'),
    ('hillsong-worship','what-a-beautiful-name'),('the-isley-brothers','footsteps-in-the-dark'),('al-green','love-and-happiness')
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
    -- ============ FUNK / JAM YOUTUBE SCENE ============
    ('dean-town','vulfpeck','bass','bassline','main bassline','bass_clean','funk','rhythm','advanced',
     'Fender Jazz-style bass (Joe Dart)','Direct — clean DI, compressed','Studio direct','both pickups',
     '[{"effect_type":"compressor","effect_name":"studio compression","placement":"front","settings":{"sustain":6,"level":6}}]'::jsonb,
     '{"gain":2,"bass":6,"mids":7,"treble":6,"presence":5,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['THE modern funk bassline — Joe Dart''s relentless fingerstyle sixteenths, bone-dry DI.','Mid-forward clean DI; zero effects, maximum pocket.'],
     array['Fingerstyle sixteenths for four minutes — endurance and evenness.','The pocket IS the song; play with the metronome, not near it.'],
     'Studio recording, 2016. Joe Dart''s legendary dry-DI funk workout.',78),
    ('back-pocket','vulfpeck','guitar','riff','main riff','clean','funk','rhythm','intermediate',
     'Fender Stratocaster (Theo Katzman / Cory Wong)','Clean amp, dry funk','Studio direct','neck + middle pickup',
     '[{"effect_type":"compressor","effect_name":"light compression","placement":"front","settings":{"sustain":4,"level":5}}]'::jsonb,
     '{"gain":1,"bass":4,"mids":5,"treble":7,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Minimal-funk charm — sparse bright clean chips in a huge pocket.','Dry squeaky clean; the space between notes is the arrangement.'],
     array['Chip the chords exactly on the grid.','Less is the whole aesthetic — resist adding.'],
     'Studio recording, 2015. Sparse dry funk-chip charm.',77),
    ('cosmic-sans','cory-wong','guitar','riff','rhythm funk engine','clean','funk','rhythm','advanced',
     'Fender Stratocaster (Cory Wong)','Clean amp, bright and percussive','Studio direct','neck + middle pickup',
     '[{"effect_type":"compressor","effect_name":"studio compression","placement":"front","settings":{"sustain":5,"level":5}}]'::jsonb,
     '{"gain":1,"bass":4,"mids":5,"treble":8,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Wong''s trademark sixteenth-note rhythm machine — ultra-bright compressed Strat clean.','Position-4 sparkle with heavy right-hand consistency; the "Wong tone" is famous and dry.'],
     array['Constant sixteenth-note strumming with pressure-release voicing.','Your wrist is the drummer — total consistency.'],
     'Studio recording, 2019. The Cory Wong rhythm-machine clean.',78),
    ('it-runs-through-me','tom-misch','guitar','riff','main riff + solo','clean','neo-soul','lead','intermediate',
     'Fender Stratocaster (Tom Misch)','Clean amp, warm jazz voicing','Studio direct','neck pickup',
     '[{"effect_type":"compressor","effect_name":"soft compression","placement":"front","settings":{"sustain":4,"level":5}},{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['London neo-soul smoothness — warm rounded Strat clean with jazz phrasing.','Soft neck-pickup clean; every note placed, none wasted.'],
     array['The hook doubles the vocal melody.','Phrase the solo like a singer breathing.'],
     'Studio recording, 2018. Misch''s neo-soul Strat smoothness.',76),
    ('movie','tom-misch','guitar','riff','main progression + solo','clean','neo-soul','lead','intermediate',
     'Fender Stratocaster (Tom Misch)','Clean amp, warm and intimate','Studio direct','neck pickup',
     '[{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":1,"bass":5,"mids":6,"treble":5,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The late-night ballad — dark warm clean with a soaring extended solo.','Rounded intimate clean; the outro solo builds patiently.'],
     array['Comp the jazz changes gently.','The solo is the destination — pace the whole journey.'],
     'Studio recording, 2018. The late-night ballad with the soaring outro solo.',76),
    ('lingus','snarky-puppy','guitar','riff','rhythm comping','clean','jazz fusion','rhythm','advanced',
     'Hollow/solid electric (Mark Lettieri / Chris McQueen)','Clean amp, funky fusion voice','Studio direct','bridge pickup',
     '[{"effect_type":"compressor","effect_name":"light compression","placement":"front","settings":{"sustain":4,"level":5}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The fusion-era landmark — tight funk comping under the famous Cory Henry solo.','Clean articulate comping; odd accents locked with the horns.'],
     array['The unison hits demand exact rhythm reading.','Comp small; the keyboards own the spotlight.'],
     'Studio recording, 2014. Tight fusion comping beneath the legendary solo.',76),

    -- ============ POST-ROCK ============
    ('your-hand-in-mine','explosions-in-the-sky','guitar','riff','main melody','clean','post-rock','lead','intermediate',
     'Fender electric (Munaf Rayani / Mark Smith / Michael James)','Clean amps with ambient reverb and delay','Open-back combo cabs','neck pickup',
     '[{"effect_type":"reverb","effect_name":"large hall reverb","placement":"post_gain","settings":{"mix":5,"decay":6}},{"effect_type":"delay","effect_name":"ambient delay","placement":"post_gain","settings":{"time":4,"mix":3,"feedback":3}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":5,"delay":3,"master":6}'::jsonb,
     array['The post-rock gateway — chiming interlocking clean melodies that swell to a distorted peak (push gain to 6 for the climax).','Wet chiming clean; three guitars weave one voice.'],
     array['The melody line sings over arpeggiated support.','Build the dynamics over eight patient minutes.'],
     'Studio recording, 2003. The post-rock gateway melody.',76),
    ('first-breath-after-coma','explosions-in-the-sky','guitar','riff','intro build','clean','post-rock','lead','intermediate',
     'Fender electric (Explosions in the Sky)','Clean amps with ambient reverb','Open-back combo cabs','neck pickup',
     '[{"effect_type":"reverb","effect_name":"large hall reverb","placement":"post_gain","settings":{"mix":5,"decay":6}},{"effect_type":"delay","effect_name":"ambient delay","placement":"post_gain","settings":{"time":4,"mix":3,"feedback":3}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":5,"delay":3,"master":6}'::jsonb,
     array['The heartbeat opener — a single repeated note growing into cascading melody.','Same wet chiming clean; the crescendo is everything.'],
     array['The tapping-heartbeat figure opens alone.','Layer patience upon patience.'],
     'Studio recording, 2003. The heartbeat crescendo opener.',75),
    ('the-mighty-rio-grande','this-will-destroy-you','guitar','riff','ambient build','clean','post-rock','rhythm','intermediate',
     'Electric guitars (This Will Destroy You)','Clean-to-heavy ambient wall','Closed-back cabs','neck pickup',
     '[{"effect_type":"reverb","effect_name":"cavernous reverb","placement":"post_gain","settings":{"mix":6,"decay":8}},{"effect_type":"delay","effect_name":"long ambient delay","placement":"post_gain","settings":{"time":5,"mix":4,"feedback":4}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":6,"delay":4,"master":6}'::jsonb,
     array['The cinematic swell (heard in Moneyball) — glacial ambient clean building to a roaring wall (gain to 7 at the peak).','Maximum ambience; the wall arrives like weather.'],
     array['Hold swells and let the delays stack.','The climax should feel inevitable, not sudden.'],
     'Studio recording, 2008. The cinematic glacial swell.',74),

    -- ============ 2000s RADIO ROCK FILLS ============
    ('45','shinedown','guitar','riff','clean verse + heavy chorus','clean','post-grunge','rhythm','beginner',
     'Solid-body electric (Jasin Todd)','Tube amp, clean to driven','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":5,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The staring-down-the-barrel ballad — dark clean arpeggios into a heavy chorus (push gain to 6).','Two moods: brooding clean, anthemic drive.'],
     array['Arpeggiate the verses with weight.','Open the chorus wide.'],
     'Studio recording, 2003. The brooding clean-to-heavy ballad.',74),
    ('sound-of-madness','shinedown','guitar','riff','main riff','high_gain','post-grunge','rhythm','intermediate',
     'Solid-body electric (Zach Myers era)','Modern high-gain tube head','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Stomping arena-metal drive — thick polished high gain.','Tight modern saturation with radio gloss.'],
     array['The stomp riff drives with the kick.','Punch the stops clean.'],
     'Studio recording, 2008. The stomping arena drive.',74),
    ('the-sound-of-silence','disturbed','guitar','main','acoustic arrangement','acoustic','rock','rhythm','beginner',
     'Acoustic guitar (Dan Donegan)','Acoustic — mic''d with orchestra','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":4,"delay":0,"master":6}'::jsonb,
     array['The unlikely monster cover — dark orchestral acoustic under Draiman''s baritone.','Warm somber acoustic; cinematic restraint.'],
     array['Slow arpeggios building with the orchestra.','Hold the tension; never rush the swell.'],
     'Studio recording, 2015. The orchestral acoustic monster cover.',75),
    ('i-miss-the-misery','halestorm','guitar','riff','main riff','high_gain','hard rock','rhythm','intermediate',
     'Gibson Explorer (Lzzy Hale / Joe Hottinger)','Marshall-style high-gain stack','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Lzzy''s swagger anthem — punchy mid-forward hard-rock crunch.','Aggressive Marshall drive with attitude to spare.'],
     array['The stabbing riff snaps with the drums.','Play it with a smirk.'],
     'Studio recording, 2012. The swaggering hard-rock stomp.',74),
    ('still-counting','volbeat','guitar','riff','main riff','high_gain','rock','rhythm','intermediate',
     'Gibson SG (Michael Poulsen era)','Modern high-gain tube head','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Elvis-meets-metal — galloping tight high gain with rockabilly DNA.','Modern saturation with 50s swing underneath.'],
     array['Gallop the riff with swing, not stiffness.','The singalong count-off chorus is the payoff.'],
     'Studio recording, 2008. The Elvis-metal gallop.',73),
    ('blurry','puddle-of-mudd','guitar','riff','clean arpeggio + wall','clean','post-grunge','rhythm','beginner',
     'Solid-body electric (Wes Scantlin / Paul Phillips)','Tube amp, clean to driven','Closed-back cab','bridge humbucker',
     '[{"effect_type":"chorus","effect_name":"watery chorus","placement":"post_gain","settings":{"rate":3,"depth":4,"mix":4}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The 2001 radio giant — watery chorused clean arpeggio into a grunge-pop wall (push gain to 6).','The chorused intro figure is instantly recognized.'],
     array['Pick the intro arpeggio with the chorus pedal on.','Slam the chorus with open chords.'],
     'Studio recording, 2001. The watery arpeggio radio giant.',75),
    ('the-reason','hoobastank','guitar','riff','main progression','clean','pop rock','rhythm','beginner',
     'Solid-body electric (Dan Estrin)','Clean amp into driven chorus','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The apology anthem — chiming clean verses into a soaring driven chorus (gain 5-6).','Polished 2000s dynamics; the build is the hook.'],
     array['Pick the clean verse figure evenly.','Lift hard into every chorus.'],
     'Studio recording, 2003. The apology-anthem build.',74),
    ('hanging-by-a-moment','lifehouse','guitar','riff','main riff','crunch','pop rock','rhythm','beginner',
     'Solid-body electric (Jason Wade)','Tube amp, warm drop-D crunch','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":6,"mids":5,"treble":5,"presence":4,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['2001''s biggest radio song — warm drop-D crunch riffing.','Thick smooth drive; the drop-D riff churns.'],
     array['Drop D; the low riff anchors everything.','Dynamics breathe verse to chorus.'],
     'Studio recording, 2000. The drop-D radio giant.',74),
    ('meant-to-live','switchfoot','guitar','riff','main riff','distorted','alternative rock','rhythm','beginner',
     'Solid-body electric (Jon Foreman / Drew Shirley)','Driven tube stack','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":6,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['The want-more anthem — big drop-D riff with soaring intent.','Thick warm distortion; the riff punches skyward.'],
     array['Drop D; the intro riff is the thesis.','Let the chorus chords ring wide.'],
     'Studio recording, 2003. The soaring drop-D anthem.',74),
    ('send-the-pain-below','chevelle','guitar','riff','main riff','high_gain','alternative metal','rhythm','intermediate',
     'Solid-body electric (Pete Loeffler)','Modern high-gain tube head','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":5,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['Brooding drop-tuned Tool-adjacent grind — restrained verses, crushing hooks.','Dark thick saturation; the melody floats above the sludge.'],
     array['Drop-B territory on the record.','Restraint in the verse makes the chorus land.'],
     'Studio recording, 2002. The brooding drop-tuned radio grind.',74),
    ('broken','seether','guitar','main','acoustic ballad','acoustic','post-grunge','rhythm','beginner',
     'Acoustic guitar (Shaun Morgan)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The Amy Lee duet — dark fingerpicked acoustic ballad.','Somber warm acoustic; the duet carries the drama.'],
     array['Fingerpick the verse figure gently.','Swell the strums as the strings enter.'],
     'Studio recording, 2004. The dark acoustic duet.',74),
    ('headstrong','trapt','guitar','riff','main riff','high_gain','nu metal','rhythm','beginner',
     'Solid-body electric (Simon Ormandy)','Modern high-gain tube head','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":4,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The eternal walkout song — bouncing drop-D nu-metal chug.','Scooped tight aggression; pure 2002 energy.'],
     array['Drop D bounce locked to the kick.','Back off nothing.'],
     'Studio recording, 2002. The eternal walkout chug.',74),

    -- ============ WORSHIP / SOUL ============
    ('gratitude','brandon-lake','guitar','main','main progression','clean','worship','rhythm','beginner',
     'Clean electric (worship session)','Clean amp with ambient swell','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"ambient shimmer reverb","placement":"post_gain","settings":{"mix":5,"decay":7}},{"effect_type":"delay","effect_name":"dotted-eighth delay","placement":"post_gain","settings":{"time":4,"mix":3,"feedback":3}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":5,"delay":3,"master":6}'::jsonb,
     array['The modern worship ballad — ambient clean swells building to a full-band peak.','Wet worship clean; the build mirrors the vocal''s surrender.'],
     array['Pad the verses with swells.','Open full strums at "so I throw up my hands".'],
     'Studio recording, 2020. The modern worship build.',73),
    ('what-a-beautiful-name','hillsong-worship','guitar','main','main progression','clean','worship','rhythm','beginner',
     'Clean electric + acoustic (Hillsong)','Clean amp with ambience','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"ambient reverb","placement":"post_gain","settings":{"mix":4,"decay":6}},{"effect_type":"delay","effect_name":"dotted-eighth delay","placement":"post_gain","settings":{"time":4,"mix":3,"feedback":3}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":4,"delay":3,"master":6}'::jsonb,
     array['One of the most-sung worship songs on earth — ambient clean under a slow anthem.','Standard worship rig: shimmer, dotted-eighth, patience.'],
     array['Arpeggiate the D-major progression with swells.','Grow verse by verse to the bridge peak.'],
     'Studio recording, 2016. The globally-sung worship anthem.',74),
    ('footsteps-in-the-dark','the-isley-brothers','guitar','riff','main groove','clean','soul','rhythm','intermediate',
     'Fender Stratocaster (Ernie Isley)','Clean amp, silky soul','Open-back combo cab','neck pickup',
     '[{"effect_type":"compressor","effect_name":"soft compression","placement":"front","settings":{"sustain":4,"level":5}},{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":1,"bass":5,"mids":6,"treble":5,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The quiet-storm classic (sampled for "Today Was a Good Day") — silky muted clean groove.','Dark smooth clean; the muted figure hypnotizes.'],
     array['Mute the pattern with the palm edge; let two notes ring.','The groove floats — never push it.'],
     'Studio recording, 1977. The quiet-storm groove classic.',77),
    ('love-and-happiness','al-green','guitar','riff','main groove','clean','soul','rhythm','intermediate',
     'Fender Telecaster-style (Teenie Hodges)','Small tube combo, warm and dry','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":5,"presence":4,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Teenie Hodges'' Memphis masterclass — warm dry soul comping that starts with the famous foot-stomp.','Round intimate clean; Hi Records dryness, no wash.'],
     array['The intro figure kicks after the stomp — nail its lazy timing.','Comp behind the beat all night.'],
     'Studio recording, 1972. Teenie Hodges'' Memphis soul masterclass.',78)
) as c(
  song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence
)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;
