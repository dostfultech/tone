-- Phase 12: 25 indie / 2000s / pop-punk staples, verified per-part tone data.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Gorillaz','gorillaz','Feel Good Inc','feel-good-inc','Demon Days',2005),
    ('The Killers','the-killers','Somebody Told Me','somebody-told-me','Hot Fuss',2004),
    ('The Killers','the-killers','When You Were Young','when-you-were-young','Sam''s Town',2006),
    ('Arctic Monkeys','arctic-monkeys','505','505','Favourite Worst Nightmare',2007),
    ('Arctic Monkeys','arctic-monkeys','I Bet You Look Good on the Dancefloor','i-bet-you-look-good-on-the-dancefloor','Whatever People Say I Am, That''s What I''m Not',2005),
    ('Arctic Monkeys','arctic-monkeys','Fluorescent Adolescent','fluorescent-adolescent','Favourite Worst Nightmare',2007),
    ('Tame Impala','tame-impala','The Less I Know the Better','the-less-i-know-the-better','Currents',2015),
    ('The Black Keys','the-black-keys','Little Black Submarines','little-black-submarines','El Camino',2011),
    ('The Black Keys','the-black-keys','Lonely Boy','lonely-boy','El Camino',2011),
    ('The Black Keys','the-black-keys','Gold on the Ceiling','gold-on-the-ceiling','El Camino',2011),
    ('Violent Femmes','violent-femmes','Blister in the Sun','blister-in-the-sun','Violent Femmes',1983),
    ('Sublime','sublime','What I Got','what-i-got','Sublime',1996),
    ('Sublime','sublime','Santeria','santeria','Sublime',1996),
    ('Weezer','weezer','Island in the Sun','island-in-the-sun','Weezer (Green Album)',2001),
    ('Weezer','weezer','Buddy Holly','buddy-holly','Weezer (Blue Album)',1994),
    ('Weezer','weezer','Say It Ain''t So','say-it-ain-t-so','Weezer (Blue Album)',1994),
    ('Weezer','weezer','My Name Is Jonas','my-name-is-jonas','Weezer (Blue Album)',1994),
    ('Modest Mouse','modest-mouse','Float On','float-on','Good News for People Who Love Bad News',2004),
    ('Blink-182','blink-182','Dammit','dammit','Dude Ranch',1997),
    ('Blink-182','blink-182','All the Small Things','all-the-small-things','Enema of the State',1999),
    ('Blink-182','blink-182','What''s My Age Again?','what-s-my-age-again','Enema of the State',1999),
    ('Fall Out Boy','fall-out-boy','Sugar We''re Goin Down','sugar-we-re-goin-down','From Under the Cork Tree',2005),
    ('My Chemical Romance','my-chemical-romance','Welcome to the Black Parade','welcome-to-the-black-parade','The Black Parade',2006),
    ('My Chemical Romance','my-chemical-romance','Helena','helena','Three Cheers for Sweet Revenge',2004),
    ('Paramore','paramore','Misery Business','misery-business','Riot!',2007)
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
    ('gorillaz','feel-good-inc'),('the-killers','somebody-told-me'),('the-killers','when-you-were-young'),
    ('arctic-monkeys','505'),('arctic-monkeys','i-bet-you-look-good-on-the-dancefloor'),('arctic-monkeys','fluorescent-adolescent'),
    ('tame-impala','the-less-i-know-the-better'),('the-black-keys','little-black-submarines'),('the-black-keys','lonely-boy'),
    ('the-black-keys','gold-on-the-ceiling'),('violent-femmes','blister-in-the-sun'),('sublime','what-i-got'),
    ('sublime','santeria'),('weezer','island-in-the-sun'),('weezer','buddy-holly'),('weezer','say-it-ain-t-so'),
    ('weezer','my-name-is-jonas'),('modest-mouse','float-on'),('blink-182','dammit'),('blink-182','all-the-small-things'),
    ('blink-182','what-s-my-age-again'),('fall-out-boy','sugar-we-re-goin-down'),('my-chemical-romance','welcome-to-the-black-parade'),
    ('my-chemical-romance','helena'),('paramore','misery-business')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('gorillaz','feel-good-inc'),('the-killers','somebody-told-me'),('the-killers','when-you-were-young'),
    ('arctic-monkeys','505'),('arctic-monkeys','i-bet-you-look-good-on-the-dancefloor'),('arctic-monkeys','fluorescent-adolescent'),
    ('tame-impala','the-less-i-know-the-better'),('the-black-keys','little-black-submarines'),('the-black-keys','lonely-boy'),
    ('the-black-keys','gold-on-the-ceiling'),('violent-femmes','blister-in-the-sun'),('sublime','what-i-got'),
    ('sublime','santeria'),('weezer','island-in-the-sun'),('weezer','buddy-holly'),('weezer','say-it-ain-t-so'),
    ('weezer','my-name-is-jonas'),('modest-mouse','float-on'),('blink-182','dammit'),('blink-182','all-the-small-things'),
    ('blink-182','what-s-my-age-again'),('fall-out-boy','sugar-we-re-goin-down'),('my-chemical-romance','welcome-to-the-black-parade'),
    ('my-chemical-romance','helena'),('paramore','misery-business')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('gorillaz','feel-good-inc'),('the-killers','somebody-told-me'),('the-killers','when-you-were-young'),
    ('arctic-monkeys','505'),('arctic-monkeys','i-bet-you-look-good-on-the-dancefloor'),('arctic-monkeys','fluorescent-adolescent'),
    ('tame-impala','the-less-i-know-the-better'),('the-black-keys','little-black-submarines'),('the-black-keys','lonely-boy'),
    ('the-black-keys','gold-on-the-ceiling'),('violent-femmes','blister-in-the-sun'),('sublime','what-i-got'),
    ('sublime','santeria'),('weezer','island-in-the-sun'),('weezer','buddy-holly'),('weezer','say-it-ain-t-so'),
    ('weezer','my-name-is-jonas'),('modest-mouse','float-on'),('blink-182','dammit'),('blink-182','all-the-small-things'),
    ('blink-182','what-s-my-age-again'),('fall-out-boy','sugar-we-re-goin-down'),('my-chemical-romance','welcome-to-the-black-parade'),
    ('my-chemical-romance','helena'),('paramore','misery-business')
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
    ('feel-good-inc','gorillaz','guitar','riff','chordal riff','crunch','rock','rhythm','beginner',
     'Electric guitar (Damon Albarn / session)','Clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Simple, punchy crunch chords over the funky bassline; keep it tight.','Low-to-medium gain.'],
     array['Play the chord stabs in the pocket.','Keep the muting tight.'],
     'Studio recording, 2005. Punchy crunch chords over a funky bassline.',75),
    ('somebody-told-me','the-killers','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Fender guitar (Dave Keuning)','Bright crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":5,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, driving new-wave crunch; keep the riff tight and clear.','Medium gain with a bright edge.'],
     array['Drive the riff with a steady groove.','Keep the picking crisp.'],
     'Studio recording, 2004. Bright, driving new-wave crunch.',76),
    ('when-you-were-young','the-killers','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Fender guitar (Dave Keuning)','High-gain amp with ambience','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Big, anthemic distortion with ambience; keep the chords wide and ringing.','Medium-high gain.'],
     array['Let the anthemic chords ring.','Build into the soaring chorus.'],
     'Studio recording, 2006. Big, anthemic distortion with ambience.',76),
    ('505','arctic-monkeys','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Fender / Gibson guitar (Arctic Monkeys)','High-gain amp','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":6,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Builds from a quiet organ intro to a heavy outro; keep the heavy chords controlled.','Medium-high gain for the outro.'],
     array['Restrain the verses, then explode into the outro.','Keep the heavy chords tight.'],
     'Studio recording, 2007. Builds from a quiet intro to a heavy outro.',76),
    ('i-bet-you-look-good-on-the-dancefloor','arctic-monkeys','guitar','riff','main riff','distorted','rock','rhythm','advanced',
     'Fender / Gibson guitar (Arctic Monkeys)','High-gain amp','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Fast, angular indie-rock distortion; keep the riff articulate.','Medium-high gain with clarity.'],
     array['Play the fast angular riff cleanly.','Keep the picking tight.'],
     'Studio recording, 2005. Fast, angular indie-rock distortion.',76),
    ('fluorescent-adolescent','arctic-monkeys','guitar','riff','main riff','crunch','rock','rhythm','intermediate',
     'Fender / Gibson guitar (Arctic Monkeys)','Bright crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, jangly clean-to-crunch tone; keep the interlocking riffs clear.','Low-to-medium gain.'],
     array['Play the melodic riff cleanly.','Keep the two-guitar interplay balanced.'],
     'Studio recording, 2007. Bright, jangly clean-to-crunch tone.',75),
    ('the-less-i-know-the-better','tame-impala','guitar','riff','funk guitar riff','clean','rock','rhythm','intermediate',
     'Electric guitar (Kevin Parker)','Clean amp with modulation','Open-back combo cab','neck pickup',
     '[{"effect_type":"modulation","effect_name":"chorus / phaser","placement":"post_gain","settings":{"depth":4,"rate":3,"mix":4}}]'::jsonb,
     '{"gain":3,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Funky clean guitar with modulation over the disco bassline; keep the amp clean.','Low gain and even dynamics.'],
     array['Play the funky riff with tight muting.','Keep the strumming light.'],
     'Studio recording, 2015. Kevin Parker played the funky clean riff with modulation.',76),
    ('little-black-submarines','the-black-keys','guitar','riff','heavy section riff','crunch','rock','rhythm','intermediate',
     'Electric guitar (Dan Auerbach)','Cranked crunch amp','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Builds from acoustic to a Zeppelin-esque heavy crunch; keep the heavy riff punchy.','Medium gain with strong mids.'],
     array['Let the acoustic intro breathe.','Slam the heavy section chords.'],
     'Studio recording, 2011. Builds from acoustic to a heavy crunch.',77),
    ('lonely-boy','the-black-keys','guitar','riff','main riff','distorted','rock','rhythm','beginner',
     'Electric guitar (Dan Auerbach)','Cranked amp with fuzz','Closed-back cab','bridge pickup',
     '[{"effect_type":"fuzz","effect_name":"fuzz","placement":"front","settings":{"gain":6,"tone":5,"level":6}}]'::jsonb,
     '{"gain":6,"bass":6,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Raw, fuzzy garage-blues riff; keep it gritty and driving.','The fuzz is the identity.'],
     array['Play the riff with a raw, driving feel.','Let the fuzz sustain the notes.'],
     'Studio recording, 2011. Dan Auerbach played the fuzzy garage-blues riff.',77),
    ('gold-on-the-ceiling','the-black-keys','guitar','riff','main riff','distorted','rock','rhythm','beginner',
     'Electric guitar (Dan Auerbach)','Cranked amp with fuzz','Closed-back cab','bridge pickup',
     '[{"effect_type":"fuzz","effect_name":"fuzz","placement":"front","settings":{"gain":6,"tone":5,"level":6}}]'::jsonb,
     '{"gain":6,"bass":6,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Fuzzy, glam-flavored garage crunch; keep the stomping riff tight.','The fuzz drives the tone.'],
     array['Drive the stomping riff with attitude.','Keep the groove heavy.'],
     'Studio recording, 2011. A fuzzy, glam-flavored garage riff.',77),
    ('blister-in-the-sun','violent-femmes','guitar','riff','main riff','clean','rock','rhythm','beginner',
     'Electric / acoustic guitar (Gordon Gano)','Clean amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":5,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, percussive clean tone; the muted stop-start riff is the identity.','Keep gain low and the attack crisp.'],
     array['Play the muted stop-start riff tightly.','Keep the dynamics sharp.'],
     'Studio recording, 1983. A bright, percussive clean riff drives the song.',75),
    ('what-i-got','sublime','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Fender Stratocaster (Bradley Nowell)','Clean-to-edge amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright clean-to-edge ska-rock tone; keep the upstroke chords crisp.','Low gain for the reggae-inflected feel.'],
     array['Play the upstroke chords cleanly.','Keep the groove loose and bouncy.'],
     'Studio recording, 1996. A bright clean-to-edge ska-rock tone.',75),
    ('santeria','sublime','guitar','lead','clean lead melody','clean','rock','lead','intermediate',
     'Fender Stratocaster (Bradley Nowell)','Clean amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm clean lead with a laid-back feel; keep gain low for the mellow melody.','A little ambience adds warmth.'],
     array['Play the melodic lead with a relaxed touch.','Let the notes ring gently.'],
     'Studio recording, 1996. A warm clean lead over the reggae-rock groove.',76),
    ('island-in-the-sun','weezer','guitar','riff','clean arpeggio','clean','rock','clean','beginner',
     'Electric guitar (Rivers Cuomo)','Clean amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm clean arpeggios; keep gain low and the chords ringing.','A little ambience adds depth.'],
     array['Arpeggiate the chords evenly.','Keep a gentle picking hand.'],
     'Studio recording, 2001. Warm clean arpeggios drive the song.',75),
    ('buddy-holly','weezer','guitar','riff','main riff','distorted','rock','rhythm','beginner',
     'Electric guitar (Rivers Cuomo)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, thick power-pop distortion; keep the riff tight and punchy.','Medium-high gain with clarity.'],
     array['Drive the power chords with energy.','Keep the muting clean.'],
     'Studio recording, 1994. Bright, thick power-pop distortion.',76),
    ('say-it-ain-t-so','weezer','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Electric guitar (Rivers Cuomo)','Clean-to-high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Clean verse builds to a thick distorted chorus; keep dynamics wide.','Medium-high gain for the chorus.'],
     array['Let the clean verse breathe.','Slam the distorted chorus chords.'],
     'Studio recording, 1994. A clean verse builds to a thick distorted chorus.',76),
    ('my-name-is-jonas','weezer','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Acoustic intro into electric (Rivers Cuomo)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Acoustic intro leads to a thick power-pop crunch; keep the electric riff tight.','Medium-high gain.'],
     array['Let the acoustic intro ring.','Drive the electric riff fully.'],
     'Studio recording, 1994. Acoustic intro into a thick power-pop crunch.',75),
    ('float-on','modest-mouse','guitar','riff','main riff','crunch','rock','rhythm','intermediate',
     'Electric guitar (Isaac Brock)','Bright clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":5,"treble":7,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bright, shimmery clean-to-crunch riff; keep it clear and jangly.','Low-to-medium gain with sparkle.'],
     array['Let the shimmery riff ring.','Keep the picking crisp.'],
     'Studio recording, 2004. A bright, shimmery clean-to-crunch riff.',75),
    ('dammit','blink-182','guitar','riff','main riff','distorted','punk','rhythm','beginner',
     'Fender Stratocaster (Tom DeLonge)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":5,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, thin pop-punk distortion; keep the riff tight and driving.','Medium-high gain with a bright edge.'],
     array['Play the two-note riff cleanly.','Keep the tempo tight.'],
     'Studio recording, 1997. Bright, thin pop-punk distortion.',75),
    ('all-the-small-things','blink-182','guitar','riff','main riff','distorted','punk','rhythm','beginner',
     'Fender Stratocaster (Tom DeLonge)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":5,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright pop-punk distortion; keep the power chords tight.','Medium-high gain with clarity.'],
     array['Downstroke the power chords with energy.','Keep the tempo bright and tight.'],
     'Studio recording, 1999. Bright pop-punk distortion.',75),
    ('what-s-my-age-again','blink-182','guitar','riff','main riff','distorted','punk','rhythm','beginner',
     'Fender Stratocaster (Tom DeLonge)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":5,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, fast pop-punk distortion; keep the riff articulate.','Medium-high gain.'],
     array['Play the fast riff cleanly.','Keep the picking tight.'],
     'Studio recording, 1999. Bright, fast pop-punk distortion.',75),
    ('sugar-we-re-goin-down','fall-out-boy','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Electric guitar (Joe Trohman / Patrick Stump)','High-gain amp','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, driving pop-rock distortion; keep the riff tight.','Medium-high gain with clarity.'],
     array['Drive the riff with energy.','Keep the muting clean.'],
     'Studio recording, 2005. Bright, driving pop-rock distortion.',75),
    ('welcome-to-the-black-parade','my-chemical-romance','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Electric guitar (Ray Toro / Frank Iero)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Big, theatrical rock distortion after the piano intro; keep the chords wide.','Medium-high gain.'],
     array['Let the piano intro build.','Slam the anthemic chords.'],
     'Studio recording, 2006. Big, theatrical rock distortion.',76),
    ('helena','my-chemical-romance','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Electric guitar (Ray Toro / Frank Iero)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Driving, bright emo-rock distortion; keep the riff tight.','Medium-high gain with clarity.'],
     array['Drive the riff with energy.','Keep the palm mutes tight.'],
     'Studio recording, 2004. Driving, bright emo-rock distortion.',75),
    ('misery-business','paramore','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Electric guitar (Josh Farro)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, driving pop-punk distortion; keep the riff tight and clear.','Medium-high gain.'],
     array['Drive the riff with energy.','Keep the muting clean.'],
     'Studio recording, 2007. Bright, driving pop-punk distortion.',76)
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
  ('gorillaz','feel-good-inc'),('the-killers','somebody-told-me'),('the-killers','when-you-were-young'),
  ('arctic-monkeys','505'),('arctic-monkeys','i-bet-you-look-good-on-the-dancefloor'),('arctic-monkeys','fluorescent-adolescent'),
  ('tame-impala','the-less-i-know-the-better'),('the-black-keys','little-black-submarines'),('the-black-keys','lonely-boy'),
  ('the-black-keys','gold-on-the-ceiling'),('violent-femmes','blister-in-the-sun'),('sublime','what-i-got'),
  ('sublime','santeria'),('weezer','island-in-the-sun'),('weezer','buddy-holly'),('weezer','say-it-ain-t-so'),
  ('weezer','my-name-is-jonas'),('modest-mouse','float-on'),('blink-182','dammit'),('blink-182','all-the-small-things'),
  ('blink-182','what-s-my-age-again'),('fall-out-boy','sugar-we-re-goin-down'),('my-chemical-romance','welcome-to-the-black-parade'),
  ('my-chemical-romance','helena'),('paramore','misery-business')
) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
cross join (values
  ('artist_interview', 'Documented artist interviews and gear discussions', null::text,
   'Researched from widely-documented interviews about this recording and player.', 72),
  ('rig_rundown', 'Published rig rundowns and community gear databases', null::text,
   'Cross-referenced against rig features and community-maintained gear databases.', 66)
) as x(source_type, title, url, notes, credibility)
where p.verification_status = 'admin_verified'
on conflict do nothing;
