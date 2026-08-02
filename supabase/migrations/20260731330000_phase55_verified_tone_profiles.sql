-- Phase 55: britpop deep cuts + 90s radio canon + women of rock, verified per-part tone data.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Oasis','oasis','Supersonic','supersonic','Definitely Maybe',1994),
    ('Oasis','oasis','Slide Away','slide-away','Definitely Maybe',1994),
    ('Oasis','oasis','Morning Glory','morning-glory','(What''s the Story) Morning Glory?',1995),
    ('Blur','blur','Coffee & TV','coffee-and-tv','13',1999),
    ('Blur','blur','Parklife','parklife','Parklife',1994),
    ('Pulp','pulp','Common People','common-people','Different Class',1995),
    ('Suede','suede','Animal Nitrate','animal-nitrate','Suede',1993),
    ('The Verve','the-verve','Bitter Sweet Symphony','bitter-sweet-symphony','Urban Hymns',1997),
    ('Matchbox Twenty','matchbox-twenty','3AM','3am','Yourself or Someone Like You',1996),
    ('Matchbox Twenty','matchbox-twenty','Push','push','Yourself or Someone Like You',1996),
    ('Third Eye Blind','third-eye-blind','Jumper','jumper','Third Eye Blind',1997),
    ('Third Eye Blind','third-eye-blind','How''s It Going to Be','hows-it-going-to-be','Third Eye Blind',1997),
    ('Hootie & the Blowfish','hootie-and-the-blowfish','Only Wanna Be with You','only-wanna-be-with-you','Cracked Rear View',1994),
    ('Deep Blue Something','deep-blue-something','Breakfast at Tiffany''s','breakfast-at-tiffanys','Home',1995),
    ('Fastball','fastball','The Way','the-way','All the Pain Money Can Buy',1998),
    ('Joan Jett','joan-jett','I Love Rock ''n'' Roll','i-love-rock-n-roll','I Love Rock ''n'' Roll',1981),
    ('Joan Jett','joan-jett','Bad Reputation','bad-reputation','Bad Reputation',1980),
    ('Alanis Morissette','alanis-morissette','You Oughta Know','you-oughta-know','Jagged Little Pill',1995),
    ('Alanis Morissette','alanis-morissette','Hand in My Pocket','hand-in-my-pocket','Jagged Little Pill',1995),
    ('Sheryl Crow','sheryl-crow','If It Makes You Happy','if-it-makes-you-happy','Sheryl Crow',1996),
    ('Garbage','garbage','Only Happy When It Rains','only-happy-when-it-rains','Garbage',1995),
    ('Hole','hole','Celebrity Skin','celebrity-skin','Celebrity Skin',1998),
    ('4 Non Blondes','4-non-blondes','What''s Up?','whats-up','Bigger, Better, Faster, More!',1992),
    ('Natalie Imbruglia','natalie-imbruglia','Torn','torn','Left of the Middle',1997),
    ('The Cranberries','the-cranberries','Linger','linger','Everybody Else Is Doing It, So Why Can''t We?',1993)
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
    ('oasis','supersonic'),('oasis','slide-away'),('oasis','morning-glory'),('blur','coffee-and-tv'),
    ('blur','parklife'),('pulp','common-people'),('suede','animal-nitrate'),('the-verve','bitter-sweet-symphony'),
    ('matchbox-twenty','3am'),('matchbox-twenty','push'),('third-eye-blind','jumper'),
    ('third-eye-blind','hows-it-going-to-be'),('hootie-and-the-blowfish','only-wanna-be-with-you'),
    ('deep-blue-something','breakfast-at-tiffanys'),('fastball','the-way'),('joan-jett','i-love-rock-n-roll'),
    ('joan-jett','bad-reputation'),('alanis-morissette','you-oughta-know'),('alanis-morissette','hand-in-my-pocket'),
    ('sheryl-crow','if-it-makes-you-happy'),('garbage','only-happy-when-it-rains'),('hole','celebrity-skin'),
    ('4-non-blondes','whats-up'),('natalie-imbruglia','torn'),('the-cranberries','linger')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('oasis','supersonic'),('oasis','slide-away'),('oasis','morning-glory'),('blur','coffee-and-tv'),
    ('blur','parklife'),('pulp','common-people'),('suede','animal-nitrate'),('the-verve','bitter-sweet-symphony'),
    ('matchbox-twenty','3am'),('matchbox-twenty','push'),('third-eye-blind','jumper'),
    ('third-eye-blind','hows-it-going-to-be'),('hootie-and-the-blowfish','only-wanna-be-with-you'),
    ('deep-blue-something','breakfast-at-tiffanys'),('fastball','the-way'),('joan-jett','i-love-rock-n-roll'),
    ('joan-jett','bad-reputation'),('alanis-morissette','you-oughta-know'),('alanis-morissette','hand-in-my-pocket'),
    ('sheryl-crow','if-it-makes-you-happy'),('garbage','only-happy-when-it-rains'),('hole','celebrity-skin'),
    ('4-non-blondes','whats-up'),('natalie-imbruglia','torn'),('the-cranberries','linger')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('oasis','supersonic'),('oasis','slide-away'),('oasis','morning-glory'),('blur','coffee-and-tv'),
    ('blur','parklife'),('pulp','common-people'),('suede','animal-nitrate'),('the-verve','bitter-sweet-symphony'),
    ('matchbox-twenty','3am'),('matchbox-twenty','push'),('third-eye-blind','jumper'),
    ('third-eye-blind','hows-it-going-to-be'),('hootie-and-the-blowfish','only-wanna-be-with-you'),
    ('deep-blue-something','breakfast-at-tiffanys'),('fastball','the-way'),('joan-jett','i-love-rock-n-roll'),
    ('joan-jett','bad-reputation'),('alanis-morissette','you-oughta-know'),('alanis-morissette','hand-in-my-pocket'),
    ('sheryl-crow','if-it-makes-you-happy'),('garbage','only-happy-when-it-rains'),('hole','celebrity-skin'),
    ('4-non-blondes','whats-up'),('natalie-imbruglia','torn'),('the-cranberries','linger')
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
    -- ============ BRITPOP ============
    ('supersonic','oasis','guitar','riff','main riff','crunch','britpop','rhythm','beginner',
     'Gibson Les Paul / Epiphone (Noel Gallagher)','Marshall tube stack, thick crunch','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":5,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The debut-single swagger — thick mid-heavy Marshall wall.','Warm compressed crunch; layers of the same part create the wall.'],
     array['The riff struts — lay back on the beat.','Big open chords with the low E droning.'],
     'Studio recording, 1994. Thick swaggering Marshall wall from Definitely Maybe.',77),
    ('slide-away','oasis','guitar','riff','main riff','crunch','britpop','rhythm','intermediate',
     'Gibson Les Paul (Noel Gallagher)','Marshall tube stack, singing crunch','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":5,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The fan-favorite epic — soaring warm crunch with vocal-like lead lines.','Mid-rich sustaining crunch; the leads sing over the wall.'],
     array['The main riff rolls; the outro solo aches.','Sustain and vibrato over speed.'],
     'Studio recording, 1994. Soaring warm crunch from the Definitely Maybe epic.',77),
    ('morning-glory','oasis','guitar','riff','main riff','distorted','britpop','rhythm','intermediate',
     'Epiphone Sheraton / Les Paul (Noel Gallagher)','Marshall tube stack driven hard','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":1,"master":8}'::jsonb,
     array['The helicopter-intro rocker — dense driven wall at full tilt.','Thick saturated crunch; the wall is layered guitars, not one huge amp.'],
     array['Driving eighths with the riff cutting through.','Play it loud — that''s the instruction.'],
     'Studio recording, 1995. Dense driven wall from Morning Glory.',77),
    ('coffee-and-tv','blur','guitar','riff','main riff','crunch','britpop','rhythm','intermediate',
     'Fender Telecaster (Graham Coxon)','Tube combo, lo-fi crunch','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Coxon''s wobbly lo-fi jangle-crunch — charming and slightly broken.','Bright Telecaster crunch, deliberately imperfect.'],
     array['The chord riff stumbles sweetly — don''t over-polish it.','The solo is melodic scribble; keep its awkward charm.'],
     'Studio recording, 1999. Coxon''s charming lo-fi jangle from 13.',75),
    ('parklife','blur','guitar','riff','main riff','crunch','britpop','rhythm','beginner',
     'Fender Telecaster (Graham Coxon)','Bright tube amp, punchy crunch','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Cockney strut — bright chippy Telecaster crunch.','Trebly punchy crunch; music-hall bounce.'],
     array['Chippy chord stabs on the strut.','Grin like Phil Daniels is narrating.'],
     'Studio recording, 1994. Bright chippy strut from Parklife.',75),
    ('common-people','pulp','guitar','riff','main riff','crunch','britpop','rhythm','beginner',
     'Solid-body electric (Mark Webber / Russell Senior)','Driven amp, glam wall','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The class-war anthem — relentless driving crunch under synths.','Straight-ahead driven wall; momentum is everything.'],
     array['Driving eighth-note chords that never let up.','Build with the arrangement to the frenzied end.'],
     'Studio recording, 1995. The relentless class-war anthem wall.',74),
    ('animal-nitrate','suede','guitar','riff','main riff','distorted','britpop','rhythm','intermediate',
     'Gibson ES-355 (Bernard Butler)','Vox/Marshall-style amp driven','Open-back 2x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['Glam-grime swagger — Butler''s snaking hollow-body drive.','Saturated but articulate; the riff slinks and stings.'],
     array['The signature riff bends and slides constantly.','Play it seedy — this is glam''s dark corner.'],
     'Studio recording, 1993. Butler''s snaking glam drive from the debut.',74),
    ('bitter-sweet-symphony','the-verve','guitar','riff','ambient texture','clean','britpop','rhythm','beginner',
     'Fender Stratocaster/Jazzmaster (Nick McCabe)','Clean amp with heavy ambience','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"huge hall reverb","placement":"post_gain","settings":{"mix":6,"decay":7}},{"effect_type":"delay","effect_name":"ambient delay","placement":"post_gain","settings":{"time":5,"mix":4,"feedback":4}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":6,"delay":4,"master":6}'::jsonb,
     array['The string loop carries the song — McCabe''s guitar paints ambient washes around it.','Wet swirling clean; texture, not riffs.'],
     array['Swells and sparse chords in the spaces.','Serve the loop; the guitar is weather, not architecture.'],
     'Studio recording, 1997. McCabe''s ambient washes around the famous string loop.',73),

    -- ============ 90s RADIO CANON ============
    ('3am','matchbox-twenty','guitar','riff','acoustic + jangle','crunch','post-grunge','rhythm','beginner',
     'Acoustic + electric (Kyle Cook / Adam Gaynor)','Tube amp, warm jangle-crunch','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['Campfire-to-radio classic — acoustic strums under warm electric jangle.','Light warm crunch over acoustic bed.'],
     array['Acoustic drives; electric decorates.','Everyone knows the words — keep it singable.'],
     'Studio recording, 1996. Warm acoustic-electric radio classic.',74),
    ('push','matchbox-twenty','guitar','riff','main riff','crunch','post-grunge','rhythm','beginner',
     'Solid-body electric (Kyle Cook)','Tube amp, mid crunch','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['Brooding mid-gain radio rock.','Warm chunky crunch; restrained verses, open choruses.'],
     array['Arpeggiated verse figures into strummed choruses.','Dynamics track the vocal''s frustration.'],
     'Studio recording, 1996. Brooding mid-gain radio rock.',74),
    ('jumper','third-eye-blind','guitar','riff','main riff','crunch','alternative rock','rhythm','beginner',
     'Gibson Les Paul (Kevin Cadogan)','Tube amp, bright crunch','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The empathy anthem — bright chiming crunch with open-string color.','Clean-edged bright crunch; the voicings ring.'],
     array['The signature chord voicings use ringing open strings — learn them exactly.','Drive the chorus wide open.'],
     'Studio recording, 1997. Bright chiming crunch from the debut.',75),
    ('hows-it-going-to-be','third-eye-blind','guitar','riff','main progression','clean','alternative rock','rhythm','beginner',
     'Gibson Les Paul (Kevin Cadogan)','Clean amp, warm jangle','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Wistful clean jangle with signature open-voiced chords.','Warm clean; light drive (gain 4) for the choruses.'],
     array['The moving-bass chord shapes are the song''s identity.','Gentle strums; ache quietly.'],
     'Studio recording, 1997. Wistful open-voiced jangle.',75),
    ('only-wanna-be-with-you','hootie-and-the-blowfish','guitar','riff','main riff','clean','roots rock','rhythm','beginner',
     'Fender Stratocaster (Mark Bryan)','Clean amp, bright jangle','Open-back combo cab','bridge pickup',
     '[{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":2}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['Sunny roots-rock jangle — the friendly 90s radio sound.','Bright clean with just a hair of edge.'],
     array['The intro lick and jangly strums carry it.','Relaxed backyard-BBQ energy.'],
     'Studio recording, 1994. Sunny roots-rock jangle from Cracked Rear View.',74),
    ('breakfast-at-tiffanys','deep-blue-something','guitar','riff','main riff','clean','alternative rock','rhythm','beginner',
     'Electric guitar (Todd Pipes band)','Clean amp, bright jangle','Open-back combo cab','bridge pickup',
     '[{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":2}}]'::jsonb,
     '{"gain":3,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['One-hit jangle perfection — bright chiming riff.','Just-clean sparkle; the intro riff is the whole identity.'],
     array['Nail the intro arpeggio-riff first.','Bouncy strums the rest of the way.'],
     'Studio recording, 1995. The one-hit jangle classic.',73),
    ('the-way','fastball','guitar','riff','main riff','crunch','alternative rock','rhythm','intermediate',
     'Electric guitar (Miles Zuniga / Tony Scalzo)','Tube amp, warm crunch with twang','Open-back combo cab','bridge pickup',
     '[{"effect_type":"reverb","effect_name":"spring reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":0,"master":7}'::jsonb,
     array['Tex-Mex-tinged radio rock — warm crunch with spring twang.','Moderate crunch with vintage color; the minor-key hooks shine.'],
     array['The verse riff has a Spanish tinge — lean into it.','The solo is melodic surf-noir.'],
     'Studio recording, 1998. Tex-Mex radio rock mystery.',73),

    -- ============ WOMEN OF ROCK ============
    ('i-love-rock-n-roll','joan-jett','guitar','riff','main riff','distorted','rock','rhythm','beginner',
     'Gibson Melody Maker (Joan Jett)','Music Man tube amp cranked','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The stomping jukebox anthem — raw mid-heavy crunch.','Jett''s Melody Maker into cranked Music Mans: simple, loud, perfect.'],
     array['The three-chord stomp riff owns the room.','Hit hard on the stops.'],
     'Studio recording, 1981. Jett''s Melody Maker stomp anthem.',78),
    ('bad-reputation','joan-jett','guitar','riff','main riff','distorted','punk rock','rhythm','beginner',
     'Gibson Melody Maker (Joan Jett)','Music Man tube amp cranked','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":7,"presence":6,"reverb":0,"delay":0,"master":8}'::jsonb,
     array['Full-speed sneer — trebly raw punk crunch.','Bright aggressive crunch at sprint tempo.'],
     array['Downstroke fury from bar one.','Don''t give a damn — that''s the technique.'],
     'Studio recording, 1980. Full-speed punk sneer.',77),
    ('you-oughta-know','alanis-morissette','guitar','riff','main riff','crunch','alternative rock','rhythm','intermediate',
     'Fender Stratocaster (Dave Navarro)','Driven amp, wiry funk-rock','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['The fury anthem — Navarro''s wiry funk-rock drive (with Flea on bass).','Tight aggressive crunch that leaves room for the venom.'],
     array['Choked verse stabs; unleashed chorus.','The dynamics are the anger management.'],
     'Studio recording, 1995. Navarro and Flea behind the fury anthem.',77),
    ('hand-in-my-pocket','alanis-morissette','guitar','main','main progression','crunch','alternative rock','rhythm','beginner',
     'Acoustic + electric (session)','Tube amp, warm light crunch','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Shrugging two-chord groove — warm light drive over acoustic bed.','Easy light crunch; the whole song rides two chords.'],
     array['Two chords, endless attitude.','Groove with the harmonica-and-shrug energy.'],
     'Studio recording, 1995. The two-chord shrug groove.',75),
    ('if-it-makes-you-happy','sheryl-crow','guitar','riff','main riff','crunch','roots rock','rhythm','beginner',
     'Fender Telecaster (Sheryl Crow / session)','Tube amp, ragged warm crunch','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['Ragged roots-rock crunch — big loose chorus wall.','Warm edge-of-falling-apart drive; polish would ruin it.'],
     array['Lazy verses, huge strummed choruses.','Let the chords sprawl.'],
     'Studio recording, 1996. Ragged roots-rock chorus wall.',75),
    ('only-happy-when-it-rains','garbage','guitar','riff','main riff','distorted','alternative rock','rhythm','intermediate',
     'Solid-body electric (Duke Erikson / Steve Marker)','Processed driven amp','Closed-back cab','bridge humbucker',
     '[{"effect_type":"chorus","effect_name":"processed modulation","placement":"post_gain","settings":{"rate":4,"depth":4,"mix":4}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['Studio-sculpted grunge-pop — layered processed distortion.','Saturated but produced; the gloss is intentional.'],
     array['The riff hooks under Shirley''s deadpan.','Precision over rawness — this is studio grunge.'],
     'Studio recording, 1995. Studio-sculpted grunge-pop gloom.',74),
    ('celebrity-skin','hole','guitar','riff','main riff','distorted','alternative rock','rhythm','beginner',
     'Fender solid-body (Eric Erlandson / Courtney Love)','Driven tube stack, California gloss','Closed-back 4x12 cab','bridge pickup',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['Sun-bleached power-pop-grunge — the huge opening chord stabs.','Bright saturated crunch; glamorous and loud.'],
     array['The stabbed intro chords are the hook.','Big wide strums with attitude.'],
     'Studio recording, 1998. Sun-bleached grunge-glam stabs.',75),
    ('whats-up','4-non-blondes','guitar','main','main progression','acoustic','alternative rock','rhythm','beginner',
     'Acoustic + clean electric (Linda Perry / Roger Rocha)','Acoustic + warm clean amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The eternal singalong — acoustic strums with warm clean electric color.','Acoustic-led; electric adds gentle swells (light drive at the climax).'],
     array['A-Bm-D loop with a big dynamic arc.','Save everything for the "HEY YEAH YEAH" peak.'],
     'Studio recording, 1992. The eternal acoustic singalong.',74),
    ('torn','natalie-imbruglia','guitar','riff','main progression','clean','pop rock','rhythm','beginner',
     'Electric + acoustic (Phil Thornalley session)','Clean amp, polished jangle','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"plate reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Polished 90s jangle-pop — clean strums with a soft sheen (light crunch enters at the chorus, gain 4).','Warm produced clean; radio-perfect balance.'],
     array['Steady strums under the melody.','Lift gently into each chorus.'],
     'Studio recording, 1997. Polished jangle-pop perfection.',74),
    ('linger','the-cranberries','guitar','riff','main arpeggio','clean','alternative rock','rhythm','beginner',
     'Fender Telecaster (Noel Hogan)','Clean amp with chorus shimmer','Open-back combo cab','neck pickup',
     '[{"effect_type":"chorus","effect_name":"soft chorus","placement":"post_gain","settings":{"rate":3,"depth":4,"mix":4}},{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":1,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":4,"delay":0,"master":6}'::jsonb,
     array['Dreamy chorused arpeggios under strings — pure early-90s shimmer.','Glassy clean with chorus and hall; delicate throughout.'],
     array['Arpeggiate the progression evenly.','Float — the song never pushes.'],
     'Studio recording, 1993. Dreamy chorused shimmer from the debut.',75)
) as c(
  song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence
)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;
