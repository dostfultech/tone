-- Phase 42: Beta-tester requests + deep Weezer catalog + midwest emo staples, verified per-part tone data.
-- Requested by Discord testers: Go Away (Weezer), I'm Still Cheering for the 1980 US Hockey Team (Oakwood).

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Weezer','weezer','Go Away','go-away','Everything Will Be Alright in the End',2014),
    ('Oakwood','oakwood','I''m Still Cheering for the 1980 US Hockey Team','i-m-still-cheering-for-the-1980-us-hockey-team',null,null),
    ('Weezer','weezer','Undone - The Sweater Song','undone-the-sweater-song','Weezer (Blue Album)',1994),
    ('Weezer','weezer','The World Has Turned and Left Me Here','the-world-has-turned-and-left-me-here','Weezer (Blue Album)',1994),
    ('Weezer','weezer','Surf Wax America','surf-wax-america','Weezer (Blue Album)',1994),
    ('Weezer','weezer','In the Garage','in-the-garage','Weezer (Blue Album)',1994),
    ('Weezer','weezer','Holiday','holiday','Weezer (Blue Album)',1994),
    ('Weezer','weezer','No One Else','no-one-else','Weezer (Blue Album)',1994),
    ('Weezer','weezer','Only in Dreams','only-in-dreams','Weezer (Blue Album)',1994),
    ('Weezer','weezer','Tired of Sex','tired-of-sex','Pinkerton',1996),
    ('Weezer','weezer','The Good Life','the-good-life','Pinkerton',1996),
    ('Weezer','weezer','El Scorcho','el-scorcho','Pinkerton',1996),
    ('Weezer','weezer','Pink Triangle','pink-triangle','Pinkerton',1996),
    ('Weezer','weezer','Across the Sea','across-the-sea','Pinkerton',1996),
    ('Weezer','weezer','Why Bother?','why-bother','Pinkerton',1996),
    ('Weezer','weezer','Hash Pipe','hash-pipe','Weezer (Green Album)',2001),
    ('Weezer','weezer','Photograph','photograph','Weezer (Green Album)',2001),
    ('Weezer','weezer','Beverly Hills','beverly-hills','Make Believe',2005),
    ('Weezer','weezer','Perfect Situation','perfect-situation','Make Believe',2005),
    ('Weezer','weezer','Pork and Beans','pork-and-beans','Weezer (Red Album)',2008),
    ('Modern Baseball','modern-baseball','The Weekend','the-weekend','Sports',2012),
    ('Modern Baseball','modern-baseball','Fine, Great','fine-great','You''re Gonna Miss It All',2014),
    ('Modern Baseball','modern-baseball','Rock Bottom','rock-bottom','You''re Gonna Miss It All',2014),
    ('American Football','american-football','Never Meant','never-meant','American Football (LP1)',1999),
    ('American Football','american-football','Honestly?','honestly','American Football (LP1)',1999)
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
    ('weezer','go-away'),('oakwood','i-m-still-cheering-for-the-1980-us-hockey-team'),
    ('weezer','undone-the-sweater-song'),('weezer','the-world-has-turned-and-left-me-here'),
    ('weezer','surf-wax-america'),('weezer','in-the-garage'),('weezer','holiday'),
    ('weezer','no-one-else'),('weezer','only-in-dreams'),('weezer','tired-of-sex'),
    ('weezer','the-good-life'),('weezer','el-scorcho'),('weezer','pink-triangle'),
    ('weezer','across-the-sea'),('weezer','why-bother'),('weezer','hash-pipe'),
    ('weezer','photograph'),('weezer','beverly-hills'),('weezer','perfect-situation'),
    ('weezer','pork-and-beans'),('modern-baseball','the-weekend'),('modern-baseball','fine-great'),
    ('modern-baseball','rock-bottom'),('american-football','never-meant'),('american-football','honestly')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('weezer','go-away'),('oakwood','i-m-still-cheering-for-the-1980-us-hockey-team'),
    ('weezer','undone-the-sweater-song'),('weezer','the-world-has-turned-and-left-me-here'),
    ('weezer','surf-wax-america'),('weezer','in-the-garage'),('weezer','holiday'),
    ('weezer','no-one-else'),('weezer','only-in-dreams'),('weezer','tired-of-sex'),
    ('weezer','the-good-life'),('weezer','el-scorcho'),('weezer','pink-triangle'),
    ('weezer','across-the-sea'),('weezer','why-bother'),('weezer','hash-pipe'),
    ('weezer','photograph'),('weezer','beverly-hills'),('weezer','perfect-situation'),
    ('weezer','pork-and-beans'),('modern-baseball','the-weekend'),('modern-baseball','fine-great'),
    ('modern-baseball','rock-bottom'),('american-football','never-meant'),('american-football','honestly')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('weezer','go-away'),('oakwood','i-m-still-cheering-for-the-1980-us-hockey-team'),
    ('weezer','undone-the-sweater-song'),('weezer','the-world-has-turned-and-left-me-here'),
    ('weezer','surf-wax-america'),('weezer','in-the-garage'),('weezer','holiday'),
    ('weezer','no-one-else'),('weezer','only-in-dreams'),('weezer','tired-of-sex'),
    ('weezer','the-good-life'),('weezer','el-scorcho'),('weezer','pink-triangle'),
    ('weezer','across-the-sea'),('weezer','why-bother'),('weezer','hash-pipe'),
    ('weezer','photograph'),('weezer','beverly-hills'),('weezer','perfect-situation'),
    ('weezer','pork-and-beans'),('modern-baseball','the-weekend'),('modern-baseball','fine-great'),
    ('modern-baseball','rock-bottom'),('american-football','never-meant'),('american-football','honestly')
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
    -- ============ USER-REQUESTED SONGS ============
    ('go-away','weezer','guitar','riff','main riff','crunch','alternative rock','rhythm','beginner',
     'Electric guitar (Rivers Cuomo)','Bright crunch amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Jangly power-pop crunch duet; brighter and less saturated than Blue Album-era Weezer.','Medium gain — let the chords breathe rather than wall-of-fuzz.'],
     array['Strum the chords with an even, bouncy feel.','Leave space for the vocal duet.'],
     'Studio recording, 2014. Bright power-pop crunch, vintage-leaning production with Best Coast guest vocal.',76),
    ('go-away','weezer','guitar','solo','melodic solo','distorted','alternative rock','lead','intermediate',
     'Electric guitar (Rivers Cuomo)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Melodic mid-forward lead; more mids than the rhythm so it sits on top.','Medium-high gain with clarity.'],
     array['Phrase the melody like the vocal line.','Keep vibrato controlled.'],
     'Studio recording, 2014. Melodic, mid-forward lead tone.',74),
    ('i-m-still-cheering-for-the-1980-us-hockey-team','oakwood','guitar','intro','clean twinkle riff','clean','midwest emo','rhythm','intermediate',
     'Electric guitar (Oakwood)','Clean amp with light breakup','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Twinkly midwest-emo clean tone with room reverb; keep the amp just below breakup.','Sparse official documentation — modeled on the recording; refine by ear.'],
     array['Let the open-string arpeggios ring into each other.','Light pick attack keeps the twinkle.'],
     'Independent emo recording. Clean twinkly arpeggios building to a distorted climax; limited gear documentation.',68),
    ('i-m-still-cheering-for-the-1980-us-hockey-team','oakwood','guitar','chorus','distorted climax','distorted','midwest emo','rhythm','intermediate',
     'Electric guitar (Oakwood)','Crunch amp pushed hard','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['Raw, emotional full-band climax; ragged edges are part of the sound.','Push a crunch amp hard rather than using tight modern high gain.'],
     array['Dig in hard on the strums.','Dynamics carry the build — start softer, end wide open.'],
     'Independent emo recording. Raw pushed-amp climax; limited gear documentation.',68),

    -- ============ WEEZER — BLUE ALBUM (1994) ============
    ('undone-the-sweater-song','weezer','guitar','intro','clean verse riff','clean','alternative rock','rhythm','beginner',
     'Electric guitar (Rivers Cuomo)','Clean amp','Closed-back 4x12 cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":2,"delay":0,"master":5}'::jsonb,
     array['Loose, lazy clean riff under the spoken-word verses.','Warm and round — neck pickup, low gain.'],
     array['Play the riff slightly behind the beat, relaxed.','Let the notes bleed together.'],
     'Studio recording, 1994. Lazy clean riff under spoken verses, exploding into the chorus.',77),
    ('undone-the-sweater-song','weezer','guitar','chorus','chorus wall of distortion','distorted','alternative rock','rhythm','beginner',
     'Electric guitar (Rivers Cuomo)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['The same riff hits as a wall of thick layered distortion in the chorus.','High gain, layered double-tracked guitars — thick but not scooped.'],
     array['Hit the chords wide open.','Match the loose feel of the clean verses.'],
     'Studio recording, 1994. Signature quiet-loud jump from lazy clean to layered wall of distortion.',77),
    ('the-world-has-turned-and-left-me-here','weezer','guitar','riff','main riff','distorted','alternative rock','rhythm','beginner',
     'Electric guitar (Rivers Cuomo)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Thick, melodic power-pop distortion; the arpeggiated figure needs note clarity under the gain.','Medium-high gain with strong mids.'],
     array['Keep the arpeggiated sections articulate.','Steady down-strums in the choruses.'],
     'Studio recording, 1994. Thick melodic power-pop distortion with arpeggiated figures.',76),
    ('surf-wax-america','weezer','guitar','riff','main riff','distorted','alternative rock','rhythm','intermediate',
     'Electric guitar (Rivers Cuomo)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Fast surf-punk energy with the Blue Album wall of fuzz; brighter and more aggressive than the mid-tempo tracks.','Medium-high gain, extra treble bite.'],
     array['Fast, even down-picking drives the verses.','Nail the stop-start hits in the bridge.'],
     'Studio recording, 1994. Fast, bright surf-punk take on the Blue Album wall of distortion.',75),
    ('in-the-garage','weezer','guitar','riff','main riff','distorted','alternative rock','rhythm','beginner',
     'Electric guitar (Rivers Cuomo)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Warm, mid-heavy garage distortion; less bright than the singles.','Medium-high gain, mids pushed.'],
     array['Relaxed strumming — it should feel homemade.','The harmonica intro sits over a quiet clean figure before the band enters.'],
     'Studio recording, 1994. Warm mid-heavy distortion; intentionally homemade garage feel.',75),
    ('holiday','weezer','guitar','riff','main riff','distorted','alternative rock','rhythm','intermediate',
     'Electric guitar (Rivers Cuomo)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Chunky syncopated power-pop distortion.','Medium-high gain; the stops need tight muting.'],
     array['Lock the syncopated riff with the drums.','Mute cleanly between hits.'],
     'Studio recording, 1994. Chunky syncopated power-pop distortion.',75),
    ('no-one-else','weezer','guitar','riff','main riff','distorted','alternative rock','rhythm','beginner',
     'Electric guitar (Rivers Cuomo)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, punchy Blue Album distortion — same core rig as Buddy Holly.','Medium-high gain, thick but clear.'],
     array['Punchy down-strums with tight rhythm.','Bounce the riff off the drum groove.'],
     'Studio recording, 1994. Bright punchy Blue Album distortion.',76),
    ('only-in-dreams','weezer','guitar','intro','clean verse arpeggios','clean','alternative rock','rhythm','intermediate',
     'Electric guitar (Rivers Cuomo)','Clean amp','Closed-back 4x12 cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":5}'::jsonb,
     array['Gentle clean arpeggios over the iconic bassline.','Low gain, warm and patient — the song is a slow build.'],
     array['Let the bass carry the melody; support it.','Save energy for the outro.'],
     'Studio recording, 1994. Gentle clean arpeggios over the iconic bassline; eight-minute slow build.',76),
    ('only-in-dreams','weezer','guitar','solo','building outro solo','distorted','alternative rock','lead','advanced',
     'Electric guitar (Rivers Cuomo)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":7,"treble":6,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The outro builds to a cathartic dual-guitar climax.','High gain with pushed mids so the melody cuts through the wall.'],
     array['Build intensity gradually across the outro.','The climax should feel earned — start restrained.'],
     'Studio recording, 1994. Cathartic building outro climax with dual lead guitars.',75),

    -- ============ WEEZER — PINKERTON (1996) ============
    ('tired-of-sex','weezer','guitar','riff','main riff','distorted','alternative rock','rhythm','intermediate',
     'Electric guitar (Rivers Cuomo)','Cranked high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Pinkerton is rawer and louder than the Blue Album — self-produced, with feedback and rough edges left in.','High gain, loose and aggressive; don''t over-polish.'],
     array['Play aggressively; the ragged feel is the point.','Let the feedback squeals happen between phrases.'],
     'Studio recording, 1996. Raw, self-produced high-gain tone with feedback left in.',75),
    ('the-good-life','weezer','guitar','riff','main riff','distorted','alternative rock','rhythm','intermediate',
     'Electric guitar (Rivers Cuomo)','Cranked high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":6,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Thick, raw Pinkerton crunch — warmer and looser than Blue Album polish.','Medium-high gain with full low end.'],
     array['Drive the riff with confident down-strums.','Loosen up — Pinkerton grooves are less rigid.'],
     'Studio recording, 1996. Thick raw Pinkerton crunch, warmer and looser than the Blue Album.',75),
    ('el-scorcho','weezer','guitar','riff','main riff','distorted','alternative rock','rhythm','intermediate',
     'Electric guitar (Rivers Cuomo)','Cranked high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":6,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Loose, lurching riff with raw Pinkerton distortion; sloppy on purpose.','Medium-high gain; keep it unpolished.'],
     array['Lean into the lurching, off-kilter rhythm.','The half-time chorus should open wide.'],
     'Studio recording, 1996. Loose lurching riff with raw self-produced distortion.',75),
    ('pink-triangle','weezer','guitar','riff','main riff','distorted','alternative rock','rhythm','beginner',
     'Electric guitar (Rivers Cuomo)','Cranked high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Mid-tempo Pinkerton crunch with a melodic top line.','Medium-high gain, mids forward.'],
     array['Steady strums; let the vocal melody lead.','Ring the chorus chords fully.'],
     'Studio recording, 1996. Mid-tempo raw crunch with melodic top line.',74),
    ('across-the-sea','weezer','guitar','riff','main riff','distorted','alternative rock','rhythm','intermediate',
     'Electric guitar (Rivers Cuomo)','Cranked high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":6,"mids":6,"treble":5,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Dynamic Pinkerton track — quiet verses swelling into heavy, emotional choruses.','Medium-high gain, slightly darker voicing.'],
     array['Control the verse dynamics with pick attack.','Open up fully for the chorus swells.'],
     'Studio recording, 1996. Dynamic quiet-loud arrangement with raw emotional choruses.',74),
    ('why-bother','weezer','guitar','riff','main riff','distorted','alternative rock','rhythm','intermediate',
     'Electric guitar (Rivers Cuomo)','Cranked high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Fast, punky Pinkerton blast — the most aggressive tone on the record.','High gain, bright and cutting.'],
     array['Fast down-picking start to finish.','Keep energy maxed — it''s a two-minute sprint.'],
     'Studio recording, 1996. Fast punky blast, the most aggressive Pinkerton tone.',74),

    -- ============ WEEZER — LATER ALBUMS ============
    ('hash-pipe','weezer','guitar','riff','main riff','high_gain','alternative rock','rhythm','intermediate',
     'Electric guitar (Rivers Cuomo)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['Heavy, chunky chromatic riff — tighter and more modern than 90s Weezer.','High gain with tight low end; palm-mute definition matters.'],
     array['Palm-mute the chromatic riff tightly.','Lock in with the kick drum.'],
     'Studio recording, 2001. Heavy tight chromatic riff, Green Album''s most aggressive tone.',77),
    ('photograph','weezer','guitar','riff','main riff','crunch','alternative rock','rhythm','beginner',
     'Electric guitar (Rivers Cuomo)','Bright crunch amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, bouncy Green Album power-pop crunch.','Medium gain — polished and controlled, not raw.'],
     array['Bright bouncy strums with consistent dynamics.','Keep it tight; Green Album is precise.'],
     'Studio recording, 2001. Bright bouncy power-pop crunch, polished Green Album production.',75),
    ('beverly-hills','weezer','guitar','riff','main riff','crunch','alternative rock','rhythm','beginner',
     'Electric guitar (Rivers Cuomo)','Crunch amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Stomping, simple crunch riff built around the drum beat.','Medium gain with solid low end.'],
     array['Play the stomp riff dead simple and heavy.','Space is part of the groove.'],
     'Studio recording, 2005. Stomping simple crunch riff.',76),
    ('beverly-hills','weezer','guitar','solo','talk box solo','distorted','alternative rock','lead','advanced',
     'Electric guitar (Rivers Cuomo)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"filter","effect_name":"talk box","placement":"post_gain","settings":{"mix":10}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['The solo runs through a talk box — that vowel sound is the effect, not the amp.','Without a talk box, a wah rocked slowly approximates the vowel sweep.'],
     array['Shape each note with the talk box vowels.','Keep phrases simple; the effect is the hook.'],
     'Studio recording, 2005. Talk box lead — the solo''s vowel sound comes from the talk box.',78),
    ('perfect-situation','weezer','guitar','riff','main riff','distorted','alternative rock','rhythm','intermediate',
     'Electric guitar (Rivers Cuomo)','High-gain amp with ambience','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Big anthemic distortion with a touch of ambience.','Medium-high gain; the intro lead hook needs sustain.'],
     array['Sing the intro lead hook with full sustain.','Open the chorus chords wide.'],
     'Studio recording, 2005. Big anthemic distortion with ambience.',75),
    ('pork-and-beans','weezer','guitar','riff','main riff','distorted','alternative rock','rhythm','beginner',
     'Electric guitar (Rivers Cuomo)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":6,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Thick fuzzy pop riff — classic Weezer wall of distortion, modern production.','Medium-high gain with full low end.'],
     array['Simple confident down-strums.','Quiet verses, wide-open choruses.'],
     'Studio recording, 2008. Thick fuzzy pop riff with modern production.',75),

    -- ============ MODERN BASEBALL ============
    ('the-weekend','modern-baseball','guitar','intro','clean intro riff','clean','midwest emo','rhythm','beginner',
     'Telecaster-style electric (Modern Baseball)','Clean amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":5}'::jsonb,
     array['Bright twinkly clean intro — bedroom-recording character.','Just-clean amp; a hint of edge when you dig in is authentic.'],
     array['Let the open strings ring through the riff.','Relaxed, conversational feel.'],
     'Studio recording, 2012. Bright twinkly clean intro with DIY bedroom character.',74),
    ('the-weekend','modern-baseball','guitar','chorus','full-band crunch strums','crunch','midwest emo','rhythm','beginner',
     'Telecaster-style electric (Modern Baseball)','Crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Ragged, energetic crunch strums when the band kicks in.','Medium gain; rough edges fit the DIY production.'],
     array['Strum hard and loose.','Match the shouted-vocal energy.'],
     'Studio recording, 2012. Ragged energetic crunch, DIY emo-revival production.',74),
    ('fine-great','modern-baseball','guitar','riff','main riff','crunch','midwest emo','rhythm','beginner',
     'Telecaster-style electric (Modern Baseball)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Talky, wiry clean-to-crunch tone that follows the conversational vocal.','Low-medium gain; articulation over saturation.'],
     array['Follow the vocal phrasing with your strumming.','Keep the wiry single-note lines clear.'],
     'Studio recording, 2014. Wiry conversational clean-to-crunch tone.',73),
    ('rock-bottom','modern-baseball','guitar','riff','main riff','crunch','midwest emo','rhythm','beginner',
     'Telecaster-style electric (Modern Baseball)','Crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Catchy, driving emo-pop crunch.','Medium gain, bright and punchy.'],
     array['Drive the riff with steady eighths.','Keep the hooks bouncy.'],
     'Studio recording, 2014. Catchy driving emo-pop crunch.',73),

    -- ============ AMERICAN FOOTBALL ============
    ('never-meant','american-football','guitar','riff','intertwining clean arpeggios','clean','midwest emo','rhythm','advanced',
     'Telecaster-style electric (Mike Kinsella)','Clean amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":5}'::jsonb,
     array['The defining midwest-emo clean tone — warm, round, roomy.','Totally clean amp with natural room reverb; the tuning does the harmonic work.'],
     array['Played in an alternate open tuning; two clean guitars interlock in different positions.','Even fingerpicking; let every string ring.'],
     'Studio recording, 1999. The genre-defining clean interlocking-arpeggio tone, recorded live and roomy.',80),
    ('honestly','american-football','guitar','riff','clean arpeggio riff','clean','midwest emo','rhythm','advanced',
     'Telecaster-style electric (Mike Kinsella)','Clean amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":5}'::jsonb,
     array['Delicate clean arpeggios in odd meter; same warm roomy rig as Never Meant.','Keep it fully clean; dynamics come from the fingers.'],
     array['Count carefully — the meter shifts under the riff.','Soft, even attack throughout.'],
     'Studio recording, 1999. Delicate odd-meter clean arpeggios, live roomy recording.',76)
) as c(
  song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence
)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;
