-- Phase 85: US radio completeness — Van Halen deep cuts, heartland anthems, college rock, arena party singles.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Van Halen','van-halen','Jump','jump','1984',1984),
    ('Van Halen','van-halen','Unchained','unchained','Fair Warning',1981),
    ('Van Halen','van-halen','Ain''t Talkin'' ''bout Love','aint-talkin-bout-love','Van Halen',1978),
    ('Poison','poison','Nothin'' but a Good Time','nothin-but-a-good-time','Open Up and Say... Ahh!',1988),
    ('R.E.M.','r-e-m','Man on the Moon','man-on-the-moon','Automatic for the People',1992),
    ('R.E.M.','r-e-m','Everybody Hurts','everybody-hurts','Automatic for the People',1992),
    ('R.E.M.','r-e-m','It''s the End of the World as We Know It (And I Feel Fine)','its-the-end-of-the-world','Document',1987),
    ('Gin Blossoms','gin-blossoms','Found Out About You','found-out-about-you','New Miserable Experience',1992),
    ('Counting Crows','counting-crows','Round Here','round-here','August and Everything After',1993),
    ('Matchbox Twenty','matchbox-twenty','Unwell','unwell','More Than You Think You Are',2002),
    ('Train','train','Drops of Jupiter','drops-of-jupiter','Drops of Jupiter',2001),
    ('Hootie & the Blowfish','hootie-and-the-blowfish','Let Her Cry','let-her-cry','Cracked Rear View',1994),
    ('Bryan Adams','bryan-adams','Summer of ''69','summer-of-69','Reckless',1984),
    ('John Mellencamp','john-mellencamp','Jack & Diane','jack-and-diane','American Fool',1982),
    ('John Mellencamp','john-mellencamp','Hurts So Good','hurts-so-good','American Fool',1982),
    ('Eddie Money','eddie-money','Two Tickets to Paradise','two-tickets-to-paradise','Eddie Money',1977),
    ('Rick Derringer','rick-derringer','Rock and Roll, Hoochie Koo','rock-and-roll-hoochie-koo','All American Boy',1973),
    ('Grand Funk Railroad','grand-funk-railroad','We''re an American Band','were-an-american-band','We''re an American Band',1973),
    ('Kiss','kiss','Detroit Rock City','detroit-rock-city','Destroyer',1976),
    ('Cheap Trick','cheap-trick','I Want You to Want Me','i-want-you-to-want-me','In Color',1977),
    ('Journey','journey','Any Way You Want It','any-way-you-want-it','Departure',1980),
    ('REO Speedwagon','reo-speedwagon','Take It on the Run','take-it-on-the-run','Hi Infidelity',1980),
    ('Night Ranger','night-ranger','Sister Christian','sister-christian','Midnight Madness',1983),
    ('Loverboy','loverboy','Working for the Weekend','working-for-the-weekend','Get Lucky',1981),
    ('Sammy Hagar','sammy-hagar','I Can''t Drive 55','i-cant-drive-55','VOA',1984)
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
    ('van-halen','jump'),('van-halen','unchained'),('van-halen','aint-talkin-bout-love'),
    ('poison','nothin-but-a-good-time'),('r-e-m','man-on-the-moon'),('r-e-m','everybody-hurts'),
    ('r-e-m','its-the-end-of-the-world'),('gin-blossoms','found-out-about-you'),('counting-crows','round-here'),
    ('matchbox-twenty','unwell'),('train','drops-of-jupiter'),('hootie-and-the-blowfish','let-her-cry'),
    ('bryan-adams','summer-of-69'),('john-mellencamp','jack-and-diane'),('john-mellencamp','hurts-so-good'),
    ('eddie-money','two-tickets-to-paradise'),('rick-derringer','rock-and-roll-hoochie-koo'),
    ('grand-funk-railroad','were-an-american-band'),('kiss','detroit-rock-city'),('cheap-trick','i-want-you-to-want-me'),
    ('journey','any-way-you-want-it'),('reo-speedwagon','take-it-on-the-run'),('night-ranger','sister-christian'),
    ('loverboy','working-for-the-weekend'),('sammy-hagar','i-cant-drive-55')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
  where p.mode = 'guitar'
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('van-halen','jump'),('van-halen','unchained'),('van-halen','aint-talkin-bout-love'),
    ('poison','nothin-but-a-good-time'),('r-e-m','man-on-the-moon'),('r-e-m','everybody-hurts'),
    ('r-e-m','its-the-end-of-the-world'),('gin-blossoms','found-out-about-you'),('counting-crows','round-here'),
    ('matchbox-twenty','unwell'),('train','drops-of-jupiter'),('hootie-and-the-blowfish','let-her-cry'),
    ('bryan-adams','summer-of-69'),('john-mellencamp','jack-and-diane'),('john-mellencamp','hurts-so-good'),
    ('eddie-money','two-tickets-to-paradise'),('rick-derringer','rock-and-roll-hoochie-koo'),
    ('grand-funk-railroad','were-an-american-band'),('kiss','detroit-rock-city'),('cheap-trick','i-want-you-to-want-me'),
    ('journey','any-way-you-want-it'),('reo-speedwagon','take-it-on-the-run'),('night-ranger','sister-christian'),
    ('loverboy','working-for-the-weekend'),('sammy-hagar','i-cant-drive-55')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
  where p.mode = 'guitar'
);
delete from public.song_tone_profiles p where p.mode = 'guitar' and p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('van-halen','jump'),('van-halen','unchained'),('van-halen','aint-talkin-bout-love'),
    ('poison','nothin-but-a-good-time'),('r-e-m','man-on-the-moon'),('r-e-m','everybody-hurts'),
    ('r-e-m','its-the-end-of-the-world'),('gin-blossoms','found-out-about-you'),('counting-crows','round-here'),
    ('matchbox-twenty','unwell'),('train','drops-of-jupiter'),('hootie-and-the-blowfish','let-her-cry'),
    ('bryan-adams','summer-of-69'),('john-mellencamp','jack-and-diane'),('john-mellencamp','hurts-so-good'),
    ('eddie-money','two-tickets-to-paradise'),('rick-derringer','rock-and-roll-hoochie-koo'),
    ('grand-funk-railroad','were-an-american-band'),('kiss','detroit-rock-city'),('cheap-trick','i-want-you-to-want-me'),
    ('journey','any-way-you-want-it'),('reo-speedwagon','take-it-on-the-run'),('night-ranger','sister-christian'),
    ('loverboy','working-for-the-weekend'),('sammy-hagar','i-cant-drive-55')
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
    ('jump','van-halen','guitar','solo','solo (synth-led song)','high_gain','rock','lead','advanced',
     'Frankenstrat (Eddie Van Halen)','Marshall Plexi "brown sound"','Marshall 4x12 cab','custom humbucker',
     '[{"effect_type":"phaser","effect_name":"MXR Phase 90 color","placement":"front","settings":{"rate":3,"mix":3}},{"effect_type":"delay","effect_name":"tape echo","placement":"post_gain","settings":{"time":3,"mix":2,"feedback":2}}]'::jsonb,
     '{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":2,"master":8}'::jsonb,
     array['Synth carries the hook — but Ed''s solo is pure brown-sound tapping and swagger.','Cranked Plexi warmth with phaser sheen; the solo is a fireworks break.'],
     array['The solo taps and dives — learn it phrase by phrase.','Might as well jump — the synth part waits for you.'],
     'Studio recording, 1984. Ed''s brown-sound fireworks on the synth hit.',80),
    ('unchained','van-halen','guitar','riff','main riff','high_gain','rock','rhythm','intermediate',
     'Frankenstrat (Eddie Van Halen)','Marshall Plexi with flanger','Marshall 4x12 cab','custom humbucker',
     '[{"effect_type":"flanger","effect_name":"MXR flanger (THE sound)","placement":"front","settings":{"rate":3,"depth":6,"mix":6}}]'::jsonb,
     '{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The flanger riff — drop-tuned brown sound swept by the MXR flanger.','Cranked Plexi with flanger engaged; the jet-sweep IS the riff.'],
     array['Drop D-flat family tuning; the flanger stays on.','One break, coming up — Ed''s favorite VH riff, maybe yours too.'],
     'Studio recording, 1981. The flanger-swept favorite.',80),
    ('aint-talkin-bout-love','van-halen','guitar','riff','main riff','high_gain','rock','rhythm','intermediate',
     'Frankenstrat (Eddie Van Halen)','Marshall Plexi, brown sound','Marshall 4x12 cab','custom humbucker',
     '[{"effect_type":"phaser","effect_name":"MXR Phase 90","placement":"front","settings":{"rate":3,"mix":4}}]'::jsonb,
     '{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The Am arpeggio sneer — written as a "dumb" punk riff, immortal anyway.','Phased brown sound; the arpeggiated riff rings and bites.'],
     array['The Am-G figure arpeggiates with attitude.','You know you semi-know the words. Everyone does.'],
     'Studio recording, 1978. The "dumb" immortal arpeggio.',80),
    ('nothin-but-a-good-time','poison','guitar','riff','main riff','high_gain','hair metal','rhythm','beginner',
     'B.C. Rich/Charvel (C.C. DeVille)','Marshall stack, party gain','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The Friday-night thesis — bright party gain and a grinning riff.','Hot bright drive; don''t need nothin'' but exactly this.'],
     array['The riff kicks the dishroom door open.','C.C.''s solo is confetti — throw it.'],
     'Studio recording, 1988. The Friday-night thesis.',76),
    ('man-on-the-moon','r-e-m','guitar','main','strums + slide color','clean','alternative rock','rhythm','beginner',
     'Rickenbacker/Gibson (Peter Buck)','Clean amp, warm jangle with slide','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The Andy Kaufman elegy — Buck''s easy strums with sighing slide answers.','Warm open jangle; if you believe they put a man on the moon.'],
     array['Strum the C-D verses loose.','The slide fills sigh — yeah, yeah, yeah, yeah.'],
     'Studio recording, 1992. The Kaufman elegy jangle.',77),
    ('everybody-hurts','r-e-m','guitar','main','arpeggio ballad','clean','alternative rock','rhythm','beginner',
     'Fender Telecaster (Peter Buck)','Clean amp with tremolo-tinged warmth','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"soft hall","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":1,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":4,"delay":0,"master":6}'::jsonb,
     array['The hold-on hymn — the gentle D-G arpeggio that talked a generation down.','Soft glassy clean; take comfort in your friends.'],
     array['The 6/8 arpeggio pattern is the embrace.','Everybody hurts — play like you mean the comfort.'],
     'Studio recording, 1992. The hold-on hymn.',78),
    ('its-the-end-of-the-world','r-e-m','guitar','riff','sprint strums','crunch','alternative rock','rhythm','intermediate',
     'Rickenbacker (Peter Buck)','Tube amp, jangle-crunch sprint','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The apocalypse patter-song — Buck''s sprint strums under the word-flood.','Bright driving jangle-crunch; and I feel fine.'],
     array['Strum the sprint evenly — the words do the racing.','Leonard Bernstein! (That''s your cue to keep strumming.)'],
     'Studio recording, 1987. The apocalypse patter sprint.',77),
    ('found-out-about-you','gin-blossoms','guitar','riff','jangle riff','clean','alternative rock','rhythm','beginner',
     'Fender/Rickenbacker (Jesse Valenzuela / Doug Hopkins)','Clean amp, bittersweet jangle','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The whispers-in-the-street jangle — Hopkins'' bittersweet chime.','Bright melancholy clean; streets they turn to circles.'],
     array['The arpeggiated riff rings under the ache.','Did you love me at all — the jangle answers.'],
     'Studio recording, 1992. Hopkins'' bittersweet chime.',76),
    ('round-here','counting-crows','guitar','main','atmospheric strums','clean','alternative rock','rhythm','beginner',
     'Fender/Gibson electric (David Bryson / Dan Vickrey)','Clean amp, dusky Americana','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"dusky reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":4,"delay":0,"master":6}'::jsonb,
     array['The August opener — dusky arpeggios under Adam''s unraveling.','Warm spacious clean; step out the front door like a ghost.'],
     array['Arpeggiate the intro figure patiently.','Round here we always stand up straight — the guitar leans.'],
     'Studio recording, 1993. The August opener.',76),
    ('unwell','matchbox-twenty','guitar','riff','banjo-tinged riff','clean','pop rock','rhythm','beginner',
     'Electric + banjo color (Kyle Cook)','Clean amp, warm radio polish','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The I''m-not-crazy single — warm picked figure (banjo doubles it on record).','Soft rolling clean; I''m just a little unwell.'],
     array['Pick the rolling figure evenly.','I know right now you can''t tell — the riff can.'],
     'Studio recording, 2002. The little-unwell roller.',75),
    ('drops-of-jupiter','train','guitar','main','ballad strums + solo','clean','pop rock','rhythm','beginner',
     'Electric + acoustic (Jimmy Stafford)','Clean-to-warm amp under strings','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":4,"delay":0,"master":6}'::jsonb,
     array['The atmosphere ballad — warm supportive strums and a singing slide-kissed solo (gain 5).','Glossy warm clean; she''s back in the atmosphere.'],
     array['Support the piano through the verses.','Tell me, did you sail across the sun — the solo answers.'],
     'Studio recording, 2001. The atmosphere ballad.',75),
    ('let-her-cry','hootie-and-the-blowfish','guitar','main','ballad strums','acoustic','roots rock','rhythm','beginner',
     'Acoustic + electric (Mark Bryan / Darius Rucker)','Acoustic with warm electric fills','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The barroom heartbreak — warm open strums under Rucker''s baritone.','Soft roots acoustic; let her go, let her walk right out on me.'],
     array['Roll the G-C strums gently.','The electric fills weep quietly between lines.'],
     'Studio recording, 1994. The barroom heartbreak.',75),
    ('summer-of-69','bryan-adams','guitar','riff','main riff','crunch','heartland rock','rhythm','beginner',
     'Fender Stratocaster (Keith Scott)','Tube amp, driving heartland crunch','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The first-real-six-string anthem — driving D-A crunch about this exact instrument.','Bright punchy drive; bought it at the five-and-dime.'],
     array['Drive the D-A verses relentlessly.','Those were the best days of my life — play them back.'],
     'Studio recording, 1984. The first-six-string anthem.',78),
    ('jack-and-diane','john-mellencamp','guitar','riff','acoustic riff + claps','acoustic','heartland rock','rhythm','beginner',
     'Acoustic + electric (Mike Wanchic / Larry Crane)','Acoustic with punchy electric stabs','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The little-ditty eternal — the acoustic stab riff and handclap break.','Bright percussive acoustic; two American kids growin'' up.'],
     array['The stab riff punches between lines.','Oh yeah, life goes on — clap the break.'],
     'Studio recording, 1982. The little-ditty eternal.',78),
    ('hurts-so-good','john-mellencamp','guitar','riff','main riff','crunch','heartland rock','rhythm','beginner',
     'Gibson/Fender electric (Larry Crane)','Tube amp, swaggering crunch','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The heartland strut — chunky riff with smalltown swagger.','Warm punchy crunch; sometimes love don''t feel like it should.'],
     array['The riff struts on the A.','Sink your teeth right through my bones — with the backbeat.'],
     'Studio recording, 1982. The heartland strut.',77),
    ('two-tickets-to-paradise','eddie-money','guitar','riff','main riff + harmonized solo','crunch','rock','lead','intermediate',
     'Gibson Les Paul (Jimmy Lyon)','Tube stack, escape-plan crunch','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The escape-plan anthem — driving riff and THAT harmonized solo.','Warm driving crunch; pack your bags, we''ll leave tonight.'],
     array['The verse riff climbs restlessly.','The harmonized solo is the paradise — learn both voices.'],
     'Studio recording, 1977. The escape-plan harmonized solo.',77),
    ('rock-and-roll-hoochie-koo','rick-derringer','guitar','riff','main riff','crunch','rock','rhythm','intermediate',
     'Gibson Les Paul (Rick Derringer)','Tube stack, strutting crunch','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The lawdy-mama strut — Derringer''s slippery riff and pinch squeals.','Hot mid-rich crunch; the riff slides and stings.'],
     array['The riff slips between double-stops.','Lawdy mama, light my fuse — pinch the harmonics.'],
     'Studio recording, 1973. The lawdy-mama strut.',77),
    ('were-an-american-band','grand-funk-railroad','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Gibson/Fender electric (Mark Farner)','Tube stack, party crunch','Closed-back 4x12 cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The tour-diary stomp — chunky crunch under the cowbell count-in.','Punchy warm drive; we''re comin'' to your town.'],
     array['Stomp the riff with the cowbell.','We''ll help you party it down — that''s the whole chart.'],
     'Studio recording, 1973. The tour-diary stomp.',77),
    ('detroit-rock-city','kiss','guitar','riff','main riff + harmonized solo','crunch','rock','lead','intermediate',
     'Gibson Les Paul (Ace Frehley)','Marshall stack, arena crunch','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The Destroyer opener — galloping riff into Ace''s harmonized Spanish-tinged solo.','Hot arena crunch; get up, everybody''s gonna move their feet.'],
     array['Gallop the verse riff tight.','Ace''s harmonized solo is the monument — both parts.'],
     'Studio recording, 1976. Ace''s harmonized monument.',78),
    ('i-want-you-to-want-me','cheap-trick','guitar','riff','main riff','crunch','power pop','rhythm','beginner',
     'Hamer custom (Rick Nielsen)','Tube amp, bright power pop','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The Budokan eternal — bright bouncing power-pop chords (the live version conquered the world).','Snappy clean-edged crunch; cryin'', cryin'', cryin''.'],
     array['Bounce the progression with the piano stabs.','Didn''t I, didn''t I, didn''t I see you cryin'' — every syllable a chord.'],
     'Studio recording, 1977. The Budokan eternal.',78),
    ('any-way-you-want-it','journey','guitar','riff','main riff + solo','crunch','rock','lead','intermediate',
     'Gibson Les Paul (Neal Schon)','Marshall stack, singing crunch','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The she-loves-to-laugh sprint — Schon''s stabbing riff and cascading solo.','Bright singing crunch; any way you want it, that''s the way you need it.'],
     array['Stab the riff with the vocal hits.','Schon''s solo cascades — cleanly at speed.'],
     'Studio recording, 1980. Schon''s cascading sprint.',77),
    ('take-it-on-the-run','reo-speedwagon','guitar','riff','arpeggio + solo','clean','rock','lead','intermediate',
     'Gibson Les Paul (Gary Richrath)','Tube amp, clean-to-singing lead','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The heard-it-from-a-friend classic — clean arpeggios into Richrath''s soaring solo (gain 6).','Warm arpeggiated clean; but I don''t believe it.'],
     array['Arpeggiate the intro figure exactly.','Richrath''s solo cries — one of AOR''s best.'],
     'Studio recording, 1980. Richrath''s heard-it-from-a-friend solo.',77),
    ('sister-christian','night-ranger','guitar','solo','power-ballad solo','high_gain','rock','lead','intermediate',
     'Gibson/Charvel (Brad Gillis / Jeff Watson)','Marshall stack, soaring lead','Marshall 4x12 cab','bridge humbucker',
     '[{"effect_type":"delay","effect_name":"lead delay","placement":"post_gain","settings":{"time":3,"mix":2,"feedback":2}}]'::jsonb,
     '{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":3,"delay":2,"master":8}'::jsonb,
     array['Motorin'' — the piano ballad with the soaring twin-school solo (Boogie Nights immortalized it).','Singing saturated lead; what''s your price for flight.'],
     array['The solo soars over the piano — sustain and bends.','You''re motorin''. The whole room is.'],
     'Studio recording, 1983. The motorin'' solo.',77),
    ('working-for-the-weekend','loverboy','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Fender/Gibson electric (Paul Dean)','Tube stack, Friday crunch','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The Friday-at-five anthem — bright stabbing crunch riff.','Snappy party drive; everybody''s watching to see what you will do.'],
     array['Stab the riff on the new-wave grid.','Everybody''s working for the weekend — so is the riff.'],
     'Studio recording, 1981. The Friday-at-five stabs.',76),
    ('i-cant-drive-55','sammy-hagar','guitar','riff','main riff','high_gain','rock','rhythm','intermediate',
     'Gibson/Fender electric (Sammy Hagar)','Marshall stack, speeding crunch','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The speed-limit protest — revving riff and red-line solo.','Hot driving crunch; write me up for 125.'],
     array['Rev the riff like a downshift.','I can''t drive fifty-five — the tempo can''t either.'],
     'Studio recording, 1984. The speed-limit protest.',76)
) as c(
  song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence
)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;
