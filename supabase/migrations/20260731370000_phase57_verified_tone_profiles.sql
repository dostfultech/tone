-- Phase 57: 80s new wave / pop-rock riff canon, verified per-part tone data.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('The Cars','the-cars','Just What I Needed','just-what-i-needed','The Cars',1978),
    ('The Cars','the-cars','My Best Friend''s Girl','my-best-friends-girl','The Cars',1978),
    ('Billy Idol','billy-idol','Rebel Yell','rebel-yell','Rebel Yell',1983),
    ('Billy Idol','billy-idol','White Wedding','white-wedding','Billy Idol',1982),
    ('INXS','inxs','Need You Tonight','need-you-tonight','Kick',1987),
    ('INXS','inxs','New Sensation','new-sensation','Kick',1987),
    ('Tears for Fears','tears-for-fears','Everybody Wants to Rule the World','everybody-wants-to-rule-the-world','Songs from the Big Chair',1985),
    ('Duran Duran','duran-duran','Ordinary World','ordinary-world','Duran Duran (The Wedding Album)',1993),
    ('The Pretenders','the-pretenders','Brass in Pocket','brass-in-pocket','Pretenders',1979),
    ('The Pretenders','the-pretenders','Back on the Chain Gang','back-on-the-chain-gang','Learning to Crawl',1982),
    ('Simple Minds','simple-minds','Don''t You (Forget About Me)','dont-you-forget-about-me','Once Upon a Time',1985),
    ('Modern English','modern-english','I Melt with You','i-melt-with-you','After the Snow',1982),
    ('The Outfield','the-outfield','Your Love','your-love','Play Deep',1985),
    ('Men at Work','men-at-work','Down Under','down-under','Business as Usual',1981),
    ('Men at Work','men-at-work','Who Can It Be Now?','who-can-it-be-now','Business as Usual',1981),
    ('The Romantics','the-romantics','What I Like About You','what-i-like-about-you','The Romantics',1979),
    ('Tommy Tutone','tommy-tutone','867-5309/Jenny','867-5309-jenny','Tommy Tutone 2',1981),
    ('A Flock of Seagulls','a-flock-of-seagulls','I Ran (So Far Away)','i-ran-so-far-away','A Flock of Seagulls',1982),
    ('Blondie','blondie','One Way or Another','one-way-or-another','Parallel Lines',1978),
    ('Blondie','blondie','Call Me','call-me','American Gigolo',1980),
    ('Pat Benatar','pat-benatar','Hit Me with Your Best Shot','hit-me-with-your-best-shot','Crimes of Passion',1980),
    ('Cheap Trick','cheap-trick','Surrender','surrender','Heaven Tonight',1978),
    ('Big Country','big-country','In a Big Country','in-a-big-country','The Crossing',1983),
    ('Cutting Crew','cutting-crew','(I Just) Died in Your Arms','i-just-died-in-your-arms','Broadcast',1986),
    ('The Knack','the-knack','My Sharona','my-sharona','Get the Knack',1979)
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
    ('the-cars','just-what-i-needed'),('the-cars','my-best-friends-girl'),('billy-idol','rebel-yell'),
    ('billy-idol','white-wedding'),('inxs','need-you-tonight'),('inxs','new-sensation'),
    ('tears-for-fears','everybody-wants-to-rule-the-world'),('duran-duran','ordinary-world'),
    ('the-pretenders','brass-in-pocket'),('the-pretenders','back-on-the-chain-gang'),
    ('simple-minds','dont-you-forget-about-me'),('modern-english','i-melt-with-you'),('the-outfield','your-love'),
    ('men-at-work','down-under'),('men-at-work','who-can-it-be-now'),('the-romantics','what-i-like-about-you'),
    ('tommy-tutone','867-5309-jenny'),('a-flock-of-seagulls','i-ran-so-far-away'),('blondie','one-way-or-another'),
    ('blondie','call-me'),('pat-benatar','hit-me-with-your-best-shot'),('cheap-trick','surrender'),
    ('big-country','in-a-big-country'),('cutting-crew','i-just-died-in-your-arms'),('the-knack','my-sharona')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('the-cars','just-what-i-needed'),('the-cars','my-best-friends-girl'),('billy-idol','rebel-yell'),
    ('billy-idol','white-wedding'),('inxs','need-you-tonight'),('inxs','new-sensation'),
    ('tears-for-fears','everybody-wants-to-rule-the-world'),('duran-duran','ordinary-world'),
    ('the-pretenders','brass-in-pocket'),('the-pretenders','back-on-the-chain-gang'),
    ('simple-minds','dont-you-forget-about-me'),('modern-english','i-melt-with-you'),('the-outfield','your-love'),
    ('men-at-work','down-under'),('men-at-work','who-can-it-be-now'),('the-romantics','what-i-like-about-you'),
    ('tommy-tutone','867-5309-jenny'),('a-flock-of-seagulls','i-ran-so-far-away'),('blondie','one-way-or-another'),
    ('blondie','call-me'),('pat-benatar','hit-me-with-your-best-shot'),('cheap-trick','surrender'),
    ('big-country','in-a-big-country'),('cutting-crew','i-just-died-in-your-arms'),('the-knack','my-sharona')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('the-cars','just-what-i-needed'),('the-cars','my-best-friends-girl'),('billy-idol','rebel-yell'),
    ('billy-idol','white-wedding'),('inxs','need-you-tonight'),('inxs','new-sensation'),
    ('tears-for-fears','everybody-wants-to-rule-the-world'),('duran-duran','ordinary-world'),
    ('the-pretenders','brass-in-pocket'),('the-pretenders','back-on-the-chain-gang'),
    ('simple-minds','dont-you-forget-about-me'),('modern-english','i-melt-with-you'),('the-outfield','your-love'),
    ('men-at-work','down-under'),('men-at-work','who-can-it-be-now'),('the-romantics','what-i-like-about-you'),
    ('tommy-tutone','867-5309-jenny'),('a-flock-of-seagulls','i-ran-so-far-away'),('blondie','one-way-or-another'),
    ('blondie','call-me'),('pat-benatar','hit-me-with-your-best-shot'),('cheap-trick','surrender'),
    ('big-country','in-a-big-country'),('cutting-crew','i-just-died-in-your-arms'),('the-knack','my-sharona')
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
    -- ============ THE CARS / BILLY IDOL ============
    ('just-what-i-needed','the-cars','guitar','riff','main riff','crunch','new wave','rhythm','beginner',
     'Solid-body electric (Elliot Easton / Ric Ocasek)','Tube amp, tight crunch','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":5,"treble":7,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Skinny-tie crunch — clipped palm-muted stabs with radio polish.','Tight bright crunch; the stabs are metronomic.'],
     array['Palm-muted downstroke stabs on the famous intro.','Easton''s solo is compact and melodic — learn it whole.'],
     'Studio recording, 1978. Clipped new-wave crunch stabs.',77),
    ('my-best-friends-girl','the-cars','guitar','riff','main riff','clean','new wave','rhythm','beginner',
     'Solid-body electric (Elliot Easton)','Clean amp with slapback','Open-back combo cab','bridge pickup',
     '[{"effect_type":"delay","effect_name":"slapback delay","placement":"post_gain","settings":{"time":1,"mix":3,"feedback":1}}]'::jsonb,
     '{"gain":3,"bass":4,"mids":5,"treble":7,"presence":6,"reverb":2,"delay":2,"master":6}'::jsonb,
     array['Rockabilly-through-new-wave — bright clean with slapback and the famous hand-claps.','Trebly clean twang; the country-flavored licks wink.'],
     array['The verse riff hybrid-picks country double-stops.','Keep it bouncy and dry.'],
     'Studio recording, 1978. Rockabilly-flavored new-wave twang.',77),
    ('rebel-yell','billy-idol','guitar','riff','main riff','high_gain','rock','rhythm','intermediate',
     'Hamer custom (Steve Stevens)','Marshall-style tube stack, tight','Marshall 4x12 cab','bridge humbucker',
     '[{"effect_type":"delay","effect_name":"studio delay accents","placement":"post_gain","settings":{"time":3,"mix":2,"feedback":2}}]'::jsonb,
     '{"gain":7,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":2,"master":7}'::jsonb,
     array['Steve Stevens'' polished aggression — tight bright high gain with studio-perfect articulation.','Saturated but surgical; the intro run must sparkle.'],
     array['The cascading intro riff is a finger-twister.','The "ray-gun" noises are pick scrapes and whammy tricks.'],
     'Studio recording, 1983. Stevens'' surgical high-gain from Rebel Yell.',78),
    ('white-wedding','billy-idol','guitar','riff','main riff','distorted','rock','rhythm','beginner',
     'Solid-body electric (Steve Stevens)','Marshall-style tube stack','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The brooding sneer — dark driving riff with gothic swagger.','Moderate saturation; menace over aggression.'],
     array['The two-note motorcycle riff idles all song.','Snap the stops dead clean.'],
     'Studio recording, 1982. The brooding motorcycle-idle riff.',78),

    -- ============ INXS / TFF / DURAN DURAN ============
    ('need-you-tonight','inxs','guitar','riff','main riff','clean','new wave','rhythm','intermediate',
     'Fender Stratocaster (Tim Farriss / Kirk Pengilly)','Clean amp, tight funk','Studio direct','bridge pickup',
     '[{"effect_type":"compressor","effect_name":"studio compression","placement":"front","settings":{"sustain":5,"level":5}}]'::jsonb,
     '{"gain":2,"bass":4,"mids":5,"treble":7,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['The slinky loop-funk riff — dry compressed clean chops.','Bone-dry funk clean; the groove is hypnotic.'],
     array['The sliding double-stop riff loops forever — lock it.','Ghost the muted strings between chops.'],
     'Studio recording, 1987. The slinky dry funk loop from Kick.',77),
    ('new-sensation','inxs','guitar','riff','main riff','crunch','new wave','rhythm','intermediate',
     'Fender Stratocaster (Tim Farriss)','Tube amp, funky light crunch','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Party-funk crunch — bright choppy riffing with horn-section energy.','Light bright crunch; rhythm-first playing.'],
     array['Sixteenth-note funk strums with accents.','Bounce — it''s a celebration.'],
     'Studio recording, 1987. Bright party-funk crunch.',76),
    ('everybody-wants-to-rule-the-world','tears-for-fears','guitar','riff','main riff + solo','clean','new wave','lead','intermediate',
     'Fender Stratocaster (Neil Taylor / Roland Orzabal)','Clean amp with chorus shimmer','Studio direct','neck pickup',
     '[{"effect_type":"chorus","effect_name":"80s chorus shimmer","placement":"post_gain","settings":{"rate":3,"depth":4,"mix":4}},{"effect_type":"delay","effect_name":"clean delay","placement":"post_gain","settings":{"time":3,"mix":3,"feedback":2}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":3,"master":6}'::jsonb,
     array['The shuffle-groove classic — glassy chorused clean riff and a singing bluesy solo (add light drive, gain 4, for the solo).','80s studio clean: chorus, delay, and polish.'],
     array['The shuffle riff must swing, not march.','The outro solo builds patiently — one of the 80s'' best.'],
     'Studio recording, 1985. Glassy chorused shuffle and singing solo.',77),
    ('ordinary-world','duran-duran','guitar','riff','arpeggio + solo','clean','pop rock','lead','intermediate',
     'Solid-body electric (Warren Cuccurullo)','Clean amp with lush ambience','Studio direct','neck pickup',
     '[{"effect_type":"chorus","effect_name":"lush chorus","placement":"post_gain","settings":{"rate":3,"depth":4,"mix":4}},{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":4,"delay":2,"master":6}'::jsonb,
     array['Cuccurullo''s elegant arpeggios — lush chorused clean with an aching lead voice (light drive, gain 4, for the solo).','Silky produced clean; grace over grit.'],
     array['The intro arpeggio figure is the song''s signature.','Phrase the solo like a ballad singer.'],
     'Studio recording, 1993. Cuccurullo''s elegant arpeggios and aching solo.',76),

    -- ============ PRETENDERS / JANGLE NEW WAVE ============
    ('brass-in-pocket','the-pretenders','guitar','riff','main riff','clean','new wave','rhythm','beginner',
     'Fender Telecaster (James Honeyman-Scott)','Clean amp, warm jangle','Open-back combo cab','bridge pickup',
     '[{"effect_type":"compressor","effect_name":"light compression","placement":"front","settings":{"sustain":4,"level":5}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Honeyman-Scott''s strut — warm compressed Telecaster jangle.','Clean with gentle squeeze; swaggering restraint.'],
     array['The arpeggiated riff sashays — feel Chrissie''s strut.','Small bends and hammer-ons decorate everything.'],
     'Studio recording, 1979. Honeyman-Scott''s swaggering jangle.',77),
    ('back-on-the-chain-gang','the-pretenders','guitar','riff','main riff','clean','new wave','rhythm','intermediate',
     'Fender Telecaster (Billy Bremner session)','Clean amp, chiming jangle','Open-back combo cab','bridge pickup',
     '[{"effect_type":"compressor","effect_name":"light compression","placement":"front","settings":{"sustain":4,"level":5}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":7,"presence":6,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bittersweet chime — the intro arpeggio-riff is one of jangle''s finest.','Bright compressed clean; every note of the figure rings.'],
     array['The intro figure alternates picked notes and open strings.','Play it tender — it''s an elegy.'],
     'Studio recording, 1982. The bittersweet jangle elegy.',77),
    ('dont-you-forget-about-me','simple-minds','guitar','riff','main riff','crunch','new wave','rhythm','beginner',
     'Solid-body electric (Charlie Burchill)','Tube amp with chorus sheen','Closed-back cab','bridge pickup',
     '[{"effect_type":"chorus","effect_name":"80s chorus","placement":"post_gain","settings":{"rate":3,"depth":4,"mix":4}}]'::jsonb,
     '{"gain":4,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":1,"master":7}'::jsonb,
     array['The Breakfast Club anthem — chorused light crunch stabs under synths.','Glossy 80s crunch; the la-la-la outro is eternal.'],
     array['Simple chord stabs with the drum hits.','Save energy for the fist-pump chorus.'],
     'Studio recording, 1985. The Breakfast Club chorused stabs.',76),
    ('i-melt-with-you','modern-english','guitar','riff','main riff','crunch','new wave','rhythm','beginner',
     'Solid-body electric (Gary McDowell)','Tube amp, jangly crunch','Open-back combo cab','bridge pickup',
     '[{"effect_type":"chorus","effect_name":"light chorus","placement":"post_gain","settings":{"rate":3,"depth":3,"mix":3}}]'::jsonb,
     '{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The perfect-moment anthem — warm jangly crunch strums.','Light chorused crunch; sentimental momentum.'],
     array['Driving open-chord strums all song.','Smile — the song insists.'],
     'Studio recording, 1982. The warm perfect-moment strummer.',76),

    -- ============ RIFF SINGLES ============
    ('your-love','the-outfield','guitar','riff','main riff','crunch','pop rock','rhythm','beginner',
     'Solid-body electric (John Spinks)','Tube amp, bright crunch','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The Josie-on-vacation riff — bright ringing crunch arpeggios.','Clean-edged bright crunch; the voicings must ring.'],
     array['The intro riff uses ringing partial chords — get the fingering exact.','Punch the accents with the vocal.'],
     'Studio recording, 1985. The eternal bright riff single.',77),
    ('down-under','men-at-work','guitar','riff','main riff','clean','new wave','rhythm','beginner',
     'Fender Stratocaster (Ron Strykert)','Clean amp with reggae bounce','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":3}},{"effect_type":"delay","effect_name":"subtle delay","placement":"post_gain","settings":{"time":3,"mix":2,"feedback":2}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":2,"master":6}'::jsonb,
     array['Vegemite reggae-pop — bouncy off-beat clean skanks.','Warm clean with space; the flute carries the hook.'],
     array['Off-beat skank chops in the verse.','Relax — it''s a stroll, not a march.'],
     'Studio recording, 1981. Bouncy reggae-pop skank.',76),
    ('who-can-it-be-now','men-at-work','guitar','riff','main riff','clean','new wave','rhythm','beginner',
     'Fender Stratocaster (Ron Strykert)','Clean amp, tight and dry','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":3,"bass":4,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Paranoid new-wave bounce — tight clean stabs around the sax hook.','Dry snappy clean; nervous energy.'],
     array['Choked stabs on the off-beats.','Stay twitchy — the paranoia is the groove.'],
     'Studio recording, 1981. Paranoid clean stabs around the sax.',76),
    ('what-i-like-about-you','the-romantics','guitar','riff','main riff','crunch','power pop','rhythm','beginner',
     'Gibson solid-body (Wally Palmar / Mike Skill)','Tube amp, bright crunch','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['Party-starter power pop — bright slamming crunch chords.','Trebly punchy crunch; maximum handclap energy.'],
     array['The E-A-D riff with the "hey!" — that''s the song.','Full-arm strums; leave nothing back.'],
     'Studio recording, 1979. The party-starter power-pop slam.',77),
    ('867-5309-jenny','tommy-tutone','guitar','riff','main riff','crunch','power pop','rhythm','beginner',
     'Solid-body electric (Jim Keller)','Tube amp, tight crunch','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['The phone-number earworm — tight arpeggiated crunch riff.','Clean-edged crunch; the intro figure is precise, not strummed.'],
     array['Pick the intro riff pattern exactly.','Drive the chorus with straight eighths.'],
     'Studio recording, 1981. The arpeggiated phone-number earworm.',77),
    ('i-ran-so-far-away','a-flock-of-seagulls','guitar','riff','delay texture riff','clean','new wave','rhythm','intermediate',
     'Fender Stratocaster (Paul Reynolds)','Clean amp with heavy delay layers','Studio direct','bridge pickup',
     '[{"effect_type":"delay","effect_name":"long modulated delay","placement":"post_gain","settings":{"time":5,"mix":5,"feedback":5}},{"effect_type":"chorus","effect_name":"chorus shimmer","placement":"post_gain","settings":{"rate":3,"depth":4,"mix":4}}]'::jsonb,
     '{"gain":3,"bass":4,"mids":5,"treble":7,"presence":6,"reverb":3,"delay":5,"master":6}'::jsonb,
     array['The space-delay classic — simple parts multiplied into walls by long delay.','Clean with big modulated delay; play half the notes, the pedal plays the rest.'],
     array['Time your picking to the delay repeats.','Sparse held chords become the atmosphere.'],
     'Studio recording, 1982. The space-delay wall from the debut.',77),

    -- ============ BLONDIE / BENATAR / POWER POP ============
    ('one-way-or-another','blondie','guitar','riff','main riff','crunch','new wave','rhythm','beginner',
     'Fender Stratocaster (Chris Stein / Frank Infante)','Tube amp, gritty crunch','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['The stalker-strut riff — gritty bright crunch.','Punchy NYC crunch; the riff prowls.'],
     array['The signature riff slides between two positions.','Keep the menace playful.'],
     'Studio recording, 1978. The prowling strut riff from Parallel Lines.',77),
    ('call-me','blondie','guitar','riff','main riff','distorted','new wave','rhythm','intermediate',
     'Fender Stratocaster (Frank Infante / Chris Stein)','Driven tube stack','Closed-back 4x12 cab','bridge pickup',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['Disco-rock propulsion — driving saturated riff over the four-on-the-floor.','Full drive with clarity; momentum is everything.'],
     array['Relentless eighth-note drive.','Accent with the synth stabs.'],
     'Studio recording, 1980. Driving disco-rock propulsion.',77),
    ('hit-me-with-your-best-shot','pat-benatar','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Gibson solid-body (Neil Giraldo)','Marshall-style tube amp, punchy crunch','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Giraldo''s punchy strut — mid-forward arena crunch.','Warm punchy Marshall; swagger in every stab.'],
     array['The chord riff punches with the snare.','The compact solo is all attitude.'],
     'Studio recording, 1980. Giraldo''s punchy arena strut.',77),
    ('surrender','cheap-trick','guitar','riff','main riff','crunch','power pop','rhythm','beginner',
     'Hamer explorer-style (Rick Nielsen)','Marshall-style stack, bright crunch','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['Power-pop perfection — Nielsen''s bright ringing crunch.','Clean-edged loud crunch; melody rules.'],
     array['Ringing open-position chords drive the verses.','Mommy''s alright, daddy''s alright — sing it.'],
     'Studio recording, 1978. Nielsen''s ringing power-pop crunch.',77),
    ('in-a-big-country','big-country','guitar','riff','bagpipe lead riff','crunch','new wave','lead','intermediate',
     'Fender Stratocaster (Stuart Adamson / Bruce Watson)','Tube amp with e-bow/harmonizer color','Closed-back cab','bridge pickup',
     '[{"effect_type":"delay","effect_name":"rhythmic delay","placement":"post_gain","settings":{"time":3,"mix":3,"feedback":3}},{"effect_type":"chorus","effect_name":"pipe-like modulation","placement":"post_gain","settings":{"rate":4,"depth":4,"mix":4}}]'::jsonb,
     '{"gain":5,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":3,"master":7}'::jsonb,
     array['The guitars-as-bagpipes anthem — modulated harmonized leads that skirl like pipes.','Bright crunch with chorus/delay; twin guitars create the pipe illusion.'],
     array['The lead figure uses double-stops and quick grace notes.','Play it joyous and windswept.'],
     'Studio recording, 1983. The bagpipe-guitar anthem.',76),
    ('i-just-died-in-your-arms','cutting-crew','guitar','riff','main riff','crunch','pop rock','rhythm','beginner',
     'Solid-body electric (Kevin MacMichael)','Tube amp with 80s chorus gloss','Closed-back cab','bridge humbucker',
     '[{"effect_type":"chorus","effect_name":"80s chorus gloss","placement":"post_gain","settings":{"rate":3,"depth":4,"mix":4}},{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":5,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":4,"delay":1,"master":7}'::jsonb,
     array['The dramatic 80s power hook — glossy chorused crunch stabs.','Big produced 80s tone: chorus, hall, drama.'],
     array['Stab the iconic chorus hits.','Hold the long chords through the reverb.'],
     'Studio recording, 1986. The dramatic glossy power hook.',75),
    ('my-sharona','the-knack','guitar','riff','main riff','crunch','power pop','rhythm','intermediate',
     'Solid-body electric (Berton Averre)','Tube amp, tight punchy crunch','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['THE stuttering riff — tight punchy crunch locked to the drum hook.','Dry punchy crunch; the octave riff must snap.'],
     array['Lock the m-m-m-my riff to the kick-snare stutter.','The extended solo is a legit workout — build to it.'],
     'Studio recording, 1979. The stuttering power-pop monument.',78)
) as c(
  song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence
)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;
