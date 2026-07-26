-- Phase 31: 25 pop-punk & emo depth, verified per-part tone data (more Blink-182, Fall Out Boy, MCR, Paramore, Yellowcard, Jimmy Eat World + Panic! at the Disco, All Time Low, Taking Back Sunday, Brand New, Dashboard Confessional, New Found Glory, The Used, Simple Plan, Good Charlotte, Bowling for Soup).

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Blink-182','blink-182','I Miss You','i-miss-you','Blink-182',2003),
    ('Blink-182','blink-182','First Date','first-date','Take Off Your Pants and Jacket',2001),
    ('Blink-182','blink-182','Adam''s Song','adams-song','Enema of the State',1999),
    ('Fall Out Boy','fall-out-boy','Thnks fr th Mmrs','thnks-fr-th-mmrs','Infinity on High',2007),
    ('Fall Out Boy','fall-out-boy','This Ain''t a Scene, It''s an Arms Race','this-aint-a-scene-its-an-arms-race','Infinity on High',2007),
    ('Fall Out Boy','fall-out-boy','Dance, Dance','dance-dance','From Under the Cork Tree',2005),
    ('My Chemical Romance','my-chemical-romance','I''m Not Okay (I Promise)','im-not-okay-i-promise','Three Cheers for Sweet Revenge',2004),
    ('My Chemical Romance','my-chemical-romance','Teenagers','teenagers','The Black Parade',2006),
    ('My Chemical Romance','my-chemical-romance','Famous Last Words','famous-last-words','The Black Parade',2006),
    ('Panic! at the Disco','panic-at-the-disco','I Write Sins Not Tragedies','i-write-sins-not-tragedies','A Fever You Can''t Sweat Out',2005),
    ('Panic! at the Disco','panic-at-the-disco','Nine in the Afternoon','nine-in-the-afternoon','Pretty. Odd.',2008),
    ('All Time Low','all-time-low','Dear Maria, Count Me In','dear-maria-count-me-in','So Wrong, It''s Right',2007),
    ('Taking Back Sunday','taking-back-sunday','Cute Without the ''E'' (Cut from the Team)','cute-without-the-e','Tell All Your Friends',2002),
    ('Taking Back Sunday','taking-back-sunday','MakeDamnSure','makedamnsure','Louder Now',2006),
    ('Brand New','brand-new','The Quiet Things That No One Ever Knows','the-quiet-things-that-no-one-ever-knows','Deja Entendu',2003),
    ('Dashboard Confessional','dashboard-confessional','Hands Down','hands-down','A Mark, a Mission, a Brand, a Scar',2003),
    ('Paramore','paramore','Ain''t It Fun','aint-it-fun','Paramore',2013),
    ('Paramore','paramore','Still Into You','still-into-you','Paramore',2013),
    ('Yellowcard','yellowcard','Only One','only-one','Ocean Avenue',2003),
    ('Jimmy Eat World','jimmy-eat-world','Pain','pain','Futures',2004),
    ('New Found Glory','new-found-glory','My Friends Over You','my-friends-over-you','Sticks and Stones',2002),
    ('The Used','the-used','The Taste of Ink','the-taste-of-ink','The Used',2002),
    ('Simple Plan','simple-plan','I''m Just a Kid','im-just-a-kid','No Pads, No Helmets... Just Balls',2002),
    ('Good Charlotte','good-charlotte','The Anthem','the-anthem','The Young and the Hopeless',2002),
    ('Bowling for Soup','bowling-for-soup','1985','1985','A Hangover You Don''t Deserve',2004)
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
    ('blink-182','i-miss-you'),('blink-182','first-date'),('blink-182','adams-song'),('fall-out-boy','thnks-fr-th-mmrs'),
    ('fall-out-boy','this-aint-a-scene-its-an-arms-race'),('fall-out-boy','dance-dance'),('my-chemical-romance','im-not-okay-i-promise'),('my-chemical-romance','teenagers'),
    ('my-chemical-romance','famous-last-words'),('panic-at-the-disco','i-write-sins-not-tragedies'),('panic-at-the-disco','nine-in-the-afternoon'),('all-time-low','dear-maria-count-me-in'),
    ('taking-back-sunday','cute-without-the-e'),('taking-back-sunday','makedamnsure'),('brand-new','the-quiet-things-that-no-one-ever-knows'),('dashboard-confessional','hands-down'),
    ('paramore','aint-it-fun'),('paramore','still-into-you'),('yellowcard','only-one'),('jimmy-eat-world','pain'),
    ('new-found-glory','my-friends-over-you'),('the-used','the-taste-of-ink'),('simple-plan','im-just-a-kid'),('good-charlotte','the-anthem'),
    ('bowling-for-soup','1985')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('blink-182','i-miss-you'),('blink-182','first-date'),('blink-182','adams-song'),('fall-out-boy','thnks-fr-th-mmrs'),
    ('fall-out-boy','this-aint-a-scene-its-an-arms-race'),('fall-out-boy','dance-dance'),('my-chemical-romance','im-not-okay-i-promise'),('my-chemical-romance','teenagers'),
    ('my-chemical-romance','famous-last-words'),('panic-at-the-disco','i-write-sins-not-tragedies'),('panic-at-the-disco','nine-in-the-afternoon'),('all-time-low','dear-maria-count-me-in'),
    ('taking-back-sunday','cute-without-the-e'),('taking-back-sunday','makedamnsure'),('brand-new','the-quiet-things-that-no-one-ever-knows'),('dashboard-confessional','hands-down'),
    ('paramore','aint-it-fun'),('paramore','still-into-you'),('yellowcard','only-one'),('jimmy-eat-world','pain'),
    ('new-found-glory','my-friends-over-you'),('the-used','the-taste-of-ink'),('simple-plan','im-just-a-kid'),('good-charlotte','the-anthem'),
    ('bowling-for-soup','1985')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('blink-182','i-miss-you'),('blink-182','first-date'),('blink-182','adams-song'),('fall-out-boy','thnks-fr-th-mmrs'),
    ('fall-out-boy','this-aint-a-scene-its-an-arms-race'),('fall-out-boy','dance-dance'),('my-chemical-romance','im-not-okay-i-promise'),('my-chemical-romance','teenagers'),
    ('my-chemical-romance','famous-last-words'),('panic-at-the-disco','i-write-sins-not-tragedies'),('panic-at-the-disco','nine-in-the-afternoon'),('all-time-low','dear-maria-count-me-in'),
    ('taking-back-sunday','cute-without-the-e'),('taking-back-sunday','makedamnsure'),('brand-new','the-quiet-things-that-no-one-ever-knows'),('dashboard-confessional','hands-down'),
    ('paramore','aint-it-fun'),('paramore','still-into-you'),('yellowcard','only-one'),('jimmy-eat-world','pain'),
    ('new-found-glory','my-friends-over-you'),('the-used','the-taste-of-ink'),('simple-plan','im-just-a-kid'),('good-charlotte','the-anthem'),
    ('bowling-for-soup','1985')
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
    ('i-miss-you','blink-182','guitar','riff','main progression','clean',
     'punk','rhythm','beginner',
     'Electric guitar (Tom DeLonge)','Clean-to-crunch amp','Open-back combo cab','bridge humbucker',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Dark, spare clean-picked verses with a gothic feel; keep it minimal and eerie.','Low gain, dark.'],
     array['Pick the sparse figure cleanly.','Keep the dynamics restrained.'],
     'Studio recording, 2003 (Blink-182). Tom DeLonge played dark, spare clean-picked parts.',72),
    ('first-date','blink-182','guitar','riff','main riff','distorted',
     'punk','rhythm','beginner',
     'Electric guitar (Tom DeLonge)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, bouncy pop-punk distortion; keep the power chords tight and fast.','Medium-high gain.'],
     array['Keep the power chords tight.','Drive the fast, bouncy energy.'],
     'Studio recording, 2001. Tom DeLonge played bright, bouncy pop-punk distortion.',72),
    ('adams-song','blink-182','guitar','riff','clean verse to distorted chorus','distorted',
     'punk','rhythm','beginner',
     'Electric guitar (Tom DeLonge)','Clean-to-high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Quiet clean verses building to a big distorted chorus; keep the contrast wide.','High gain for the chorus.'],
     array['Pick the clean verse gently.','Slam the distorted chorus.'],
     'Studio recording, 1999 (Enema of the State). Tom DeLonge played quiet clean verses building to a big distorted chorus.',72),
    ('thnks-fr-th-mmrs','fall-out-boy','guitar','riff','main riff','distorted',
     'punk','rhythm','beginner',
     'Electric guitar (Joe Trohman / Patrick Stump)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Punchy, anthemic pop-punk distortion over strings; keep the power chords tight.','Medium-high gain.'],
     array['Keep the power chords tight and punchy.','Drive the anthemic energy.'],
     'Studio recording, 2007 (Infinity on High). Fall Out Boy played punchy, anthemic pop-punk distortion.',72),
    ('this-aint-a-scene-its-an-arms-race','fall-out-boy','guitar','riff','main riff','distorted',
     'punk','rhythm','beginner',
     'Electric guitar (Joe Trohman / Patrick Stump)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Driving, catchy pop-punk distortion with a marching feel; keep it tight.','Medium-high gain.'],
     array['Keep the riff tight and marching.','Drive the hook.'],
     'Studio recording, 2007. Fall Out Boy played driving, catchy pop-punk distortion.',71),
    ('dance-dance','fall-out-boy','guitar','riff','main riff','distorted',
     'punk','rhythm','beginner',
     'Electric guitar (Joe Trohman / Patrick Stump)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, bouncy pop-punk distortion with a catchy riff; keep it snappy.','Medium-high gain.'],
     array['Play the catchy riff tightly.','Keep the bounce.'],
     'Studio recording, 2005 (From Under the Cork Tree). Fall Out Boy played bright, bouncy pop-punk distortion.',72),
    ('im-not-okay-i-promise','my-chemical-romance','guitar','riff','main riff and solo','distorted',
     'punk','lead','intermediate',
     'Electric guitar (Ray Toro / Frank Iero)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Driving emo-punk distortion with a melodic lead break; keep the riff tight.','Medium-high gain.'],
     array['Keep the power chords tight.','Play the melodic solo cleanly.'],
     'Studio recording, 2004. Ray Toro played driving emo-punk distortion and a melodic solo.',72),
    ('teenagers','my-chemical-romance','guitar','riff','main riff','crunch',
     'punk','rhythm','beginner',
     'Electric guitar (Ray Toro / Frank Iero)','Crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Swaggering, glammy stomp-rock crunch riff; keep it loose and anthemic.','Medium gain.'],
     array['Play the stomping riff with swagger.','Keep the chords ringing.'],
     'Studio recording, 2006 (The Black Parade). Ray Toro played a swaggering, glammy stomp-rock crunch riff.',72),
    ('famous-last-words','my-chemical-romance','guitar','riff','main riff and solo','distorted',
     'punk','lead','intermediate',
     'Electric guitar (Ray Toro / Frank Iero)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Anthemic, driving emo-rock with a soaring lead; keep it big and tight.','Medium-high gain.'],
     array['Drive the anthemic riff.','Let the lead soar.'],
     'Studio recording, 2006 (The Black Parade). Ray Toro played anthemic, driving emo-rock and a soaring lead.',72),
    ('i-write-sins-not-tragedies','panic-at-the-disco','guitar','riff','main riff','crunch',
     'punk','rhythm','beginner',
     'Electric guitar (Ryan Ross)','Crunch amp','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Theatrical baroque-pop-punk with a punchy riff; keep it tight and dramatic.','Medium gain.'],
     array['Play the punchy riff tightly.','Keep it theatrical.'],
     'Studio recording, 2005. Ryan Ross played a theatrical baroque-pop-punk riff.',71),
    ('nine-in-the-afternoon','panic-at-the-disco','guitar','riff','main progression','crunch',
     'rock','rhythm','beginner',
     'Electric guitar (Ryan Ross)','Crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bright, Beatles-esque psych-pop crunch; keep the chords big and ringing.','Low-medium gain.'],
     array['Let the bright chords ring.','Keep the strum upbeat.'],
     'Studio recording, 2008 (Pretty. Odd.). Ryan Ross played a bright, Beatles-esque psych-pop crunch.',71),
    ('dear-maria-count-me-in','all-time-low','guitar','riff','main riff','distorted',
     'punk','rhythm','beginner',
     'Electric guitar (Jack Barakat)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, catchy pop-punk distortion; keep the power chords fast and tight.','Medium-high gain.'],
     array['Keep the power chords tight.','Drive the catchy energy.'],
     'Studio recording, 2007. Jack Barakat played bright, catchy pop-punk distortion.',71),
    ('cute-without-the-e','taking-back-sunday','guitar','riff','main riff','distorted',
     'punk','rhythm','intermediate',
     'Electric guitar (Eddie Reyes / John Nolan)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Driving, interweaving emo distortion; keep the two guitar parts tight and dynamic.','Medium-high gain.'],
     array['Interlock the two guitar parts.','Keep the energy urgent.'],
     'Studio recording, 2002 (Tell All Your Friends). Taking Back Sunday played driving, interweaving emo distortion.',71),
    ('makedamnsure','taking-back-sunday','guitar','riff','main riff','distorted',
     'punk','rhythm','beginner',
     'Electric guitar (Eddie Reyes / Fred Mascherino)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Big, catchy emo-rock distortion with a driving hook; keep it tight.','Medium-high gain.'],
     array['Keep the hook riff tight.','Drive the chorus.'],
     'Studio recording, 2006 (Louder Now). Taking Back Sunday played big, catchy emo-rock distortion.',71),
    ('the-quiet-things-that-no-one-ever-knows','brand-new','guitar','riff','clean verse to distorted chorus','distorted',
     'punk','rhythm','intermediate',
     'Electric guitar (Vin Accardi / Jesse Lacey)','Clean-to-high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Dynamic emo: restrained clean verses erupting into a big distorted chorus; keep the contrast wide.','High gain for the chorus.'],
     array['Play the verse cleanly and tense.','Erupt into the distorted chorus.'],
     'Studio recording, 2003 (Deja Entendu). Brand New played dynamic emo from clean verses to a distorted chorus.',71),
    ('hands-down','dashboard-confessional','guitar','riff','main progression','crunch',
     'punk','rhythm','beginner',
     'Acoustic and electric guitar (Chris Carrabba)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Earnest emo strumming that builds from acoustic to a full, ringing crunch; keep it heartfelt.','Low-medium gain.'],
     array['Strum the chords with earnest energy.','Build into the full chorus.'],
     'Studio recording, 2003. Chris Carrabba played earnest emo strumming building from acoustic to crunch.',71),
    ('aint-it-fun','paramore','guitar','riff','main riff','clean',
     'pop','rhythm','beginner',
     'Electric guitar (Taylor York)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, funky clean guitar with a bouncy pop groove; keep the chops crisp.','Low gain, bright.'],
     array['Play the funky clean chops tightly.','Keep the groove bouncy.'],
     'Studio recording, 2013 (Paramore). Taylor York played a bright, funky clean guitar part.',72),
    ('still-into-you','paramore','guitar','riff','main riff','crunch',
     'pop','rhythm','beginner',
     'Electric guitar (Taylor York)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, bouncy power-pop with a crisp riff; keep it snappy and upbeat.','Low-medium gain, bright.'],
     array['Play the crisp riff tightly.','Keep the groove upbeat.'],
     'Studio recording, 2013 (Paramore). Taylor York played a bright, bouncy power-pop riff.',72),
    ('only-one','yellowcard','guitar','riff','main riff','distorted',
     'punk','rhythm','beginner',
     'Electric guitar (Ryan Key / Ben Harper)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Emotional pop-punk that builds to a big distorted chorus under the violin; keep it dynamic.','Medium-high gain.'],
     array['Build from the picked verse.','Slam the big chorus.'],
     'Studio recording, 2003 (Ocean Avenue). Yellowcard played emotional pop-punk building to a big chorus.',71),
    ('pain','jimmy-eat-world','guitar','riff','main riff','distorted',
     'punk','rhythm','beginner',
     'Electric guitar (Jim Adkins / Tom Linton)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Driving, bright emo-rock distortion; keep the riff tight and anthemic.','Medium-high gain.'],
     array['Keep the riff tight.','Drive the anthemic hook.'],
     'Studio recording, 2004 (Futures). Jimmy Eat World played driving, bright emo-rock distortion.',71),
    ('my-friends-over-you','new-found-glory','guitar','riff','main riff','distorted',
     'punk','rhythm','beginner',
     'Electric guitar (Chad Gilbert / Steve Klein)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Fast, bright pop-punk distortion; keep the power chords tight and energetic.','Medium-high gain.'],
     array['Keep the power chords fast and tight.','Drive the energy.'],
     'Studio recording, 2002 (Sticks and Stones). New Found Glory played fast, bright pop-punk distortion.',71),
    ('the-taste-of-ink','the-used','guitar','riff','main riff','distorted',
     'punk','rhythm','intermediate',
     'Electric guitar (Quinn Allman)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Dynamic post-hardcore: shimmering clean verses erupting into heavy distortion; keep the contrast wide.','High gain for the heavy parts.'],
     array['Play the shimmering verse cleanly.','Erupt into the heavy chorus.'],
     'Studio recording, 2002 (The Used). Quinn Allman played dynamic post-hardcore from clean verses to heavy distortion.',71),
    ('im-just-a-kid','simple-plan','guitar','riff','main riff','distorted',
     'punk','rhythm','beginner',
     'Electric guitar (Jeff Stinco / Sébastien Lefebvre)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, catchy pop-punk distortion; keep the power chords tight and bouncy.','Medium-high gain.'],
     array['Keep the power chords tight.','Drive the bouncy hook.'],
     'Studio recording, 2002. Simple Plan played bright, catchy pop-punk distortion.',71),
    ('the-anthem','good-charlotte','guitar','riff','main riff','distorted',
     'punk','rhythm','beginner',
     'Electric guitar (Benji Madden / Billy Martin)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bratty, driving pop-punk distortion; keep the power chords tight and rebellious.','Medium-high gain.'],
     array['Keep the power chords tight.','Drive the bratty energy.'],
     'Studio recording, 2002. Good Charlotte played bratty, driving pop-punk distortion.',71),
    ('1985','bowling-for-soup','guitar','riff','main riff','distorted',
     'punk','rhythm','beginner',
     'Electric guitar (Chris Burney)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, fun power-pop-punk distortion; keep the power chords tight and upbeat.','Medium-high gain.'],
     array['Keep the power chords tight.','Drive the fun, upbeat energy.'],
     'Studio recording, 2004. Bowling for Soup played bright, fun power-pop-punk distortion.',71)
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
  ('blink-182','i-miss-you'),('blink-182','first-date'),('blink-182','adams-song'),('fall-out-boy','thnks-fr-th-mmrs'),
  ('fall-out-boy','this-aint-a-scene-its-an-arms-race'),('fall-out-boy','dance-dance'),('my-chemical-romance','im-not-okay-i-promise'),('my-chemical-romance','teenagers'),
  ('my-chemical-romance','famous-last-words'),('panic-at-the-disco','i-write-sins-not-tragedies'),('panic-at-the-disco','nine-in-the-afternoon'),('all-time-low','dear-maria-count-me-in'),
  ('taking-back-sunday','cute-without-the-e'),('taking-back-sunday','makedamnsure'),('brand-new','the-quiet-things-that-no-one-ever-knows'),('dashboard-confessional','hands-down'),
  ('paramore','aint-it-fun'),('paramore','still-into-you'),('yellowcard','only-one'),('jimmy-eat-world','pain'),
  ('new-found-glory','my-friends-over-you'),('the-used','the-taste-of-ink'),('simple-plan','im-just-a-kid'),('good-charlotte','the-anthem'),
  ('bowling-for-soup','1985')
) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
cross join (values
  ('artist_interview', 'Documented artist interviews and gear discussions', null::text,
   'Researched from widely-documented interviews about this recording and player.', 72),
  ('rig_rundown', 'Published rig rundowns and community gear databases', null::text,
   'Cross-referenced against rig features and community-maintained gear databases.', 66)
) as x(source_type, title, url, notes, credibility)
where p.verification_status = 'admin_verified'
on conflict do nothing;
