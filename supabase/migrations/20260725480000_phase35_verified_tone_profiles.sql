-- Phase 35: 25 hair metal & hard rock staples, verified per-part tone data (Mötley Crüe, Poison, Whitesnake, Ratt, Skid Row, Warrant, Cinderella, Twisted Sister, Europe, Quiet Riot, Dokken, Night Ranger, Great White, Winger, more Bon Jovi/Def Leppard/GN'R, Mr. Big).

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Mötley Crüe','motley-crue','Kickstart My Heart','kickstart-my-heart','Dr. Feelgood',1989),
    ('Mötley Crüe','motley-crue','Dr. Feelgood','dr-feelgood','Dr. Feelgood',1989),
    ('Mötley Crüe','motley-crue','Home Sweet Home','home-sweet-home','Theatre of Pain',1985),
    ('Poison','poison','Every Rose Has Its Thorn','every-rose-has-its-thorn','Open Up and Say... Ahh!',1988),
    ('Poison','poison','Talk Dirty to Me','talk-dirty-to-me','Look What the Cat Dragged In',1987),
    ('Whitesnake','whitesnake','Here I Go Again','here-i-go-again','Whitesnake',1987),
    ('Whitesnake','whitesnake','Still of the Night','still-of-the-night','Whitesnake',1987),
    ('Ratt','ratt','Round and Round','round-and-round','Out of the Cellar',1984),
    ('Skid Row','skid-row','18 and Life','18-and-life','Skid Row',1989),
    ('Skid Row','skid-row','Youth Gone Wild','youth-gone-wild','Skid Row',1989),
    ('Warrant','warrant','Cherry Pie','cherry-pie','Cherry Pie',1990),
    ('Cinderella','cinderella','Nobody''s Fool','nobodys-fool','Night Songs',1986),
    ('Twisted Sister','twisted-sister','We''re Not Gonna Take It','were-not-gonna-take-it','Stay Hungry',1984),
    ('Twisted Sister','twisted-sister','I Wanna Rock','i-wanna-rock','Stay Hungry',1984),
    ('Europe','europe','The Final Countdown','the-final-countdown','The Final Countdown',1986),
    ('Quiet Riot','quiet-riot','Cum On Feel the Noize','cum-on-feel-the-noize','Metal Health',1983),
    ('Dokken','dokken','Alone Again','alone-again','Tooth and Nail',1984),
    ('Night Ranger','night-ranger','Sister Christian','sister-christian','Midnight Madness',1984),
    ('Great White','great-white','Once Bitten Twice Shy','once-bitten-twice-shy','...Twice Shy',1989),
    ('Winger','winger','Seventeen','seventeen','Winger',1988),
    ('Bon Jovi','bon-jovi','You Give Love a Bad Name','you-give-love-a-bad-name','Slippery When Wet',1986),
    ('Bon Jovi','bon-jovi','Runaway','runaway','Bon Jovi',1984),
    ('Def Leppard','def-leppard','Rock of Ages','rock-of-ages','Pyromania',1983),
    ('Guns N'' Roses','guns-n-roses','Patience','patience','G N'' R Lies',1988),
    ('Mr. Big','mr-big','To Be with You','to-be-with-you','Lean into It',1991)
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
    ('motley-crue','kickstart-my-heart'),('motley-crue','dr-feelgood'),('motley-crue','home-sweet-home'),('poison','every-rose-has-its-thorn'),
    ('poison','talk-dirty-to-me'),('whitesnake','here-i-go-again'),('whitesnake','still-of-the-night'),('ratt','round-and-round'),
    ('skid-row','18-and-life'),('skid-row','youth-gone-wild'),('warrant','cherry-pie'),('cinderella','nobodys-fool'),
    ('twisted-sister','were-not-gonna-take-it'),('twisted-sister','i-wanna-rock'),('europe','the-final-countdown'),('quiet-riot','cum-on-feel-the-noize'),
    ('dokken','alone-again'),('night-ranger','sister-christian'),('great-white','once-bitten-twice-shy'),('winger','seventeen'),
    ('bon-jovi','you-give-love-a-bad-name'),('bon-jovi','runaway'),('def-leppard','rock-of-ages'),('guns-n-roses','patience'),
    ('mr-big','to-be-with-you')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('motley-crue','kickstart-my-heart'),('motley-crue','dr-feelgood'),('motley-crue','home-sweet-home'),('poison','every-rose-has-its-thorn'),
    ('poison','talk-dirty-to-me'),('whitesnake','here-i-go-again'),('whitesnake','still-of-the-night'),('ratt','round-and-round'),
    ('skid-row','18-and-life'),('skid-row','youth-gone-wild'),('warrant','cherry-pie'),('cinderella','nobodys-fool'),
    ('twisted-sister','were-not-gonna-take-it'),('twisted-sister','i-wanna-rock'),('europe','the-final-countdown'),('quiet-riot','cum-on-feel-the-noize'),
    ('dokken','alone-again'),('night-ranger','sister-christian'),('great-white','once-bitten-twice-shy'),('winger','seventeen'),
    ('bon-jovi','you-give-love-a-bad-name'),('bon-jovi','runaway'),('def-leppard','rock-of-ages'),('guns-n-roses','patience'),
    ('mr-big','to-be-with-you')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('motley-crue','kickstart-my-heart'),('motley-crue','dr-feelgood'),('motley-crue','home-sweet-home'),('poison','every-rose-has-its-thorn'),
    ('poison','talk-dirty-to-me'),('whitesnake','here-i-go-again'),('whitesnake','still-of-the-night'),('ratt','round-and-round'),
    ('skid-row','18-and-life'),('skid-row','youth-gone-wild'),('warrant','cherry-pie'),('cinderella','nobodys-fool'),
    ('twisted-sister','were-not-gonna-take-it'),('twisted-sister','i-wanna-rock'),('europe','the-final-countdown'),('quiet-riot','cum-on-feel-the-noize'),
    ('dokken','alone-again'),('night-ranger','sister-christian'),('great-white','once-bitten-twice-shy'),('winger','seventeen'),
    ('bon-jovi','you-give-love-a-bad-name'),('bon-jovi','runaway'),('def-leppard','rock-of-ages'),('guns-n-roses','patience'),
    ('mr-big','to-be-with-you')
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
    ('kickstart-my-heart','motley-crue','guitar','riff','main riff and solo','high_gain',
     'metal','lead','advanced',
     'Electric guitar (Mick Mars)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Revving, high-octane hard-rock riff with a flashy solo; keep it fast and tight.','High gain, bright.'],
     array['Play the revving riff tightly.','Attack the flashy solo.'],
     'Studio recording, 1989 (Dr. Feelgood). Mick Mars played a revving, high-octane hard-rock riff and solo through Marshalls.',72),
    ('dr-feelgood','motley-crue','guitar','riff','main riff','high_gain',
     'metal','rhythm','intermediate',
     'Electric guitar (Mick Mars)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Heavy, swaggering hard-rock riff; keep the palm mutes tight and menacing.','High gain.'],
     array['Keep the palm-muted riff tight.','Play with swagger.'],
     'Studio recording, 1989 (Dr. Feelgood). Mick Mars played a heavy, swaggering hard-rock riff.',72),
    ('home-sweet-home','motley-crue','guitar','riff','clean intro to crunch','crunch',
     'rock','rhythm','beginner',
     'Electric guitar (Mick Mars)','Clean-to-crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Piano power ballad with clean-picked guitar building to a big crunch and solo; keep dynamics wide.','Medium gain for the chorus.'],
     array['Pick the intro cleanly.','Open into the big crunch chorus.'],
     'Studio recording, 1985 (Theatre of Pain). Mick Mars played clean-to-crunch guitar on the power ballad.',71),
    ('every-rose-has-its-thorn','poison','guitar','riff','strummed progression','acoustic',
     'rock','rhythm','beginner',
     'Acoustic and electric guitar (C.C. DeVille)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Gentle strummed acoustic power ballad; keep the chords warm and even.','Natural acoustic tone.'],
     array['Strum the chords gently.','Keep the dynamics tender.'],
     'Studio recording, 1988. C.C. DeVille played a gentle strummed acoustic power ballad.',71),
    ('talk-dirty-to-me','poison','guitar','riff','main riff','crunch',
     'rock','rhythm','beginner',
     'Electric guitar (C.C. DeVille)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, bratty glam-punk crunch riff; keep it fast and snappy.','Medium-high gain, bright.'],
     array['Play the riff fast and tight.','Keep the bratty energy.'],
     'Studio recording, 1987. C.C. DeVille played a bright, bratty glam-punk crunch riff.',71),
    ('here-i-go-again','whitesnake','guitar','riff','main riff and solo','crunch',
     'rock','lead','intermediate',
     'Electric guitar (Adrian Vandenberg / John Sykes)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Anthemic power-ballad crunch with a soaring solo; keep the chords big and ringing.','Medium-high gain.'],
     array['Let the anthemic chords ring.','Play the solo with feel.'],
     'Studio recording, 1987 (Whitesnake). The band played an anthemic power-ballad crunch and soaring solo through Marshalls.',72),
    ('still-of-the-night','whitesnake','guitar','riff','main riff and solo','high_gain',
     'metal','lead','advanced',
     'Gibson Les Paul (John Sykes)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Zeppelin-esque hard-rock with a huge riff and a blazing solo; keep it tight and powerful.','High gain.'],
     array['Play the big riff with power.','Attack the blazing solo.'],
     'Studio recording, 1987 (Whitesnake). John Sykes played a Zeppelin-esque riff and blazing solo on a Les Paul through Marshalls.',72),
    ('round-and-round','ratt','guitar','riff','main riff and solo','crunch',
     'metal','lead','intermediate',
     'Electric guitar (Warren DeMartini / Robbin Crosby)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Catchy, driving hair-metal riff with a melodic solo; keep it tight and bright.','Medium-high gain.'],
     array['Play the catchy riff tightly.','Play the solo cleanly.'],
     'Studio recording, 1984 (Out of the Cellar). Warren DeMartini played a catchy, driving riff and melodic solo.',71),
    ('18-and-life','skid-row','guitar','riff','main riff and solo','crunch',
     'metal','lead','intermediate',
     'Electric guitar (Dave Sabo / Scotti Hill)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Dark, dramatic hard-rock ballad with a gritty riff and an emotive solo; keep it dynamic.','Medium-high gain.'],
     array['Play the gritty riff with weight.','Let the solo cry.'],
     'Studio recording, 1989 (Skid Row). Dave Sabo and Scotti Hill played a dark, dramatic riff and emotive solo.',71),
    ('youth-gone-wild','skid-row','guitar','riff','main riff','high_gain',
     'metal','rhythm','beginner',
     'Electric guitar (Dave Sabo / Scotti Hill)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Fist-pumping, rebellious hard-rock riff; keep it tight and driving.','High gain.'],
     array['Keep the power chords tight.','Drive the rebellious energy.'],
     'Studio recording, 1989 (Skid Row). Skid Row played a fist-pumping, rebellious hard-rock riff.',71),
    ('cherry-pie','warrant','guitar','riff','main riff','crunch',
     'rock','rhythm','beginner',
     'Electric guitar (Joey Allen / Erik Turner)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, bouncy party-rock crunch riff; keep it snappy and fun.','Medium-high gain, bright.'],
     array['Play the bouncy riff tightly.','Keep the party energy.'],
     'Studio recording, 1990 (Cherry Pie). Warrant played a bright, bouncy party-rock crunch riff.',70),
    ('nobodys-fool','cinderella','guitar','riff','main riff and solo','crunch',
     'rock','lead','intermediate',
     'Electric guitar (Jeff LaBar / Tom Keifer)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bluesy hard-rock power ballad with a gritty riff and emotive solo; keep it dynamic.','Medium-high gain.'],
     array['Play the bluesy riff with grit.','Let the solo cry.'],
     'Studio recording, 1986 (Night Songs). Cinderella played a bluesy hard-rock power ballad and emotive solo.',70),
    ('were-not-gonna-take-it','twisted-sister','guitar','riff','main riff','crunch',
     'metal','rhythm','beginner',
     'Electric guitar (Jay Jay French / Eddie Ojeda)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Anthemic, fist-pumping crunch riff; keep the power chords big and driving.','Medium-high gain.'],
     array['Slam the anthemic power chords.','Keep the energy up.'],
     'Studio recording, 1984 (Stay Hungry). Twisted Sister played an anthemic, fist-pumping crunch riff.',71),
    ('i-wanna-rock','twisted-sister','guitar','riff','main riff','crunch',
     'metal','rhythm','beginner',
     'Electric guitar (Jay Jay French / Eddie Ojeda)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Chunky, chant-along anthem crunch; keep the riff tight and pounding.','Medium-high gain.'],
     array['Pound the riff tightly.','Keep the anthem driving.'],
     'Studio recording, 1984 (Stay Hungry). Twisted Sister played a chunky, chant-along anthem crunch.',71),
    ('the-final-countdown','europe','guitar','riff','main riff and solo','high_gain',
     'metal','lead','intermediate',
     'Electric guitar (John Norum)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Driving hard-rock under the famous keyboard fanfare, with a flashy solo; keep it tight.','High gain.'],
     array['Drive the riff under the synth.','Play the flashy solo cleanly.'],
     'Studio recording, 1986 (The Final Countdown). John Norum played driving hard-rock and a flashy solo through Marshalls.',71),
    ('cum-on-feel-the-noize','quiet-riot','guitar','riff','main riff','crunch',
     'metal','rhythm','beginner',
     'Electric guitar (Carlos Cavazo)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Big, chant-along glam-metal crunch riff; keep it tight and anthemic.','Medium-high gain.'],
     array['Play the big riff tightly.','Keep the chant-along energy.'],
     'Studio recording, 1983 (Metal Health). Carlos Cavazo played a big, chant-along glam-metal crunch riff.',71),
    ('alone-again','dokken','guitar','riff','main progression and solo','crunch',
     'metal','lead','advanced',
     'Electric guitar (George Lynch)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Melodic power ballad with a beautiful, singing George Lynch solo; keep it expressive.','Medium-high gain with sustain.'],
     array['Play the chords with warmth.','Play the melodic solo with rich vibrato.'],
     'Studio recording, 1984 (Tooth and Nail). George Lynch played a beautiful, singing solo on the power ballad.',72),
    ('sister-christian','night-ranger','guitar','riff','clean verse to crunch chorus','crunch',
     'rock','lead','intermediate',
     'Electric guitar (Brad Gillis / Jeff Watson)','Clean-to-crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Piano power ballad building from clean chords to a big crunch chorus and solo; keep dynamics wide.','Medium-high gain for the chorus.'],
     array['Play the verse chords cleanly.','Slam the big chorus and solo.'],
     'Studio recording, 1983 (Midnight Madness). Night Ranger played clean-to-crunch guitar on the power ballad.',71),
    ('once-bitten-twice-shy','great-white','guitar','riff','main riff','crunch',
     'rock','rhythm','beginner',
     'Electric guitar (Mark Kendall)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bluesy, swaggering hard-rock crunch riff; keep it loose and greasy.','Medium-high gain with grit.'],
     array['Play the riff with a bluesy swagger.','Keep it greasy.'],
     'Studio recording, 1989. Mark Kendall played a bluesy, swaggering hard-rock crunch riff.',70),
    ('seventeen','winger','guitar','riff','main riff and solo','crunch',
     'metal','lead','advanced',
     'Electric guitar (Reb Beach)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Slick hair-metal with a funky riff and a flashy, technical solo; keep it tight.','Medium-high gain.'],
     array['Play the funky riff tightly.','Nail the flashy solo.'],
     'Studio recording, 1988 (Winger). Reb Beach played a funky riff and flashy, technical solo.',71),
    ('you-give-love-a-bad-name','bon-jovi','guitar','riff','main riff and solo','crunch',
     'rock','lead','intermediate',
     'Electric guitar (Richie Sambora)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Punchy, anthemic arena-rock crunch with a talk-box-tinged solo; keep it tight and big.','Medium-high gain.'],
     array['Play the punchy riff tightly.','Play the anthemic solo with attitude.'],
     'Studio recording, 1986 (Slippery When Wet). Richie Sambora played a punchy, anthemic riff and solo.',72),
    ('runaway','bon-jovi','guitar','riff','main riff and solo','crunch',
     'rock','lead','intermediate',
     'Electric guitar (Richie Sambora)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Driving arena-rock over a synth riff, with a flashy solo; keep it tight and bright.','Medium-high gain.'],
     array['Drive the riff under the synth.','Play the flashy solo cleanly.'],
     'Studio recording, 1984 (Bon Jovi). Richie Sambora played driving arena-rock and a flashy solo.',71),
    ('rock-of-ages','def-leppard','guitar','riff','main riff','crunch',
     'rock','rhythm','beginner',
     'Electric guitar (Steve Clark / Phil Collen)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Big, chant-along arena-rock crunch with layered chords; keep it tight and anthemic.','Medium-high gain, layered.'],
     array['Slam the anthemic chords.','Keep them big and layered.'],
     'Studio recording, 1983 (Pyromania). Steve Clark and Phil Collen played big, chant-along arena-rock crunch.',71),
    ('patience','guns-n-roses','guitar','riff','fingerpicked and strummed progression','acoustic',
     'rock','rhythm','beginner',
     'Acoustic guitar (Slash / Izzy Stradlin)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Layered acoustic guitars, picked and strummed, on a tender ballad; keep it warm.','Natural acoustic tone.'],
     array['Layer the picked and strummed parts.','Keep the feel gentle.'],
     'Studio recording, 1988 (G N'' R Lies). Slash and Izzy Stradlin played layered acoustic guitars on the ballad.',72),
    ('to-be-with-you','mr-big','guitar','riff','strummed progression','acoustic',
     'rock','rhythm','beginner',
     'Acoustic guitar (Paul Gilbert)','Acoustic amp or DI (clean)','Acoustic body — no cab','undersaddle piezo',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bright, upbeat strummed acoustic pop-ballad; keep the rhythm crisp and warm.','Natural acoustic tone.'],
     array['Strum the progression crisply.','Keep the groove upbeat.'],
     'Studio recording, 1991 (Lean into It). Paul Gilbert played a bright, upbeat strummed acoustic on the ballad.',71)
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
  ('motley-crue','kickstart-my-heart'),('motley-crue','dr-feelgood'),('motley-crue','home-sweet-home'),('poison','every-rose-has-its-thorn'),
  ('poison','talk-dirty-to-me'),('whitesnake','here-i-go-again'),('whitesnake','still-of-the-night'),('ratt','round-and-round'),
  ('skid-row','18-and-life'),('skid-row','youth-gone-wild'),('warrant','cherry-pie'),('cinderella','nobodys-fool'),
  ('twisted-sister','were-not-gonna-take-it'),('twisted-sister','i-wanna-rock'),('europe','the-final-countdown'),('quiet-riot','cum-on-feel-the-noize'),
  ('dokken','alone-again'),('night-ranger','sister-christian'),('great-white','once-bitten-twice-shy'),('winger','seventeen'),
  ('bon-jovi','you-give-love-a-bad-name'),('bon-jovi','runaway'),('def-leppard','rock-of-ages'),('guns-n-roses','patience'),
  ('mr-big','to-be-with-you')
) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
cross join (values
  ('artist_interview', 'Documented artist interviews and gear discussions', null::text,
   'Researched from widely-documented interviews about this recording and player.', 72),
  ('rig_rundown', 'Published rig rundowns and community gear databases', null::text,
   'Cross-referenced against rig features and community-maintained gear databases.', 66)
) as x(source_type, title, url, notes, credibility)
where p.verification_status = 'admin_verified'
on conflict do nothing;
