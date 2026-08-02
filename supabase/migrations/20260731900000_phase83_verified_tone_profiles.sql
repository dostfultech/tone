-- Phase 83: iconic basslines vol. 3 — post-punk school + legendary bass parts (bass-mode profiles).
-- Deletes restricted to mode='bass' so existing guitar profiles are preserved.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Joy Division','joy-division','Love Will Tear Us Apart','love-will-tear-us-apart','Substance',1980),
    ('Joy Division','joy-division','Transmission','transmission','Substance',1979),
    ('Joy Division','joy-division','Disorder','disorder','Unknown Pleasures',1979),
    ('New Order','new-order','Age of Consent','age-of-consent','Power, Corruption & Lies',1983),
    ('New Order','new-order','Ceremony','ceremony','Ceremony',1981),
    ('The Cure','the-cure','A Forest','a-forest','Seventeen Seconds',1980),
    ('The Cure','the-cure','Fascination Street','fascination-street','Disintegration',1989),
    ('Talking Heads','talking-heads','Psycho Killer','psycho-killer','Talking Heads: 77',1977),
    ('The Beatles','the-beatles','Rain','rain','Rain',1966),
    ('The Beatles','the-beatles','Something','something','Abbey Road',1969),
    ('Led Zeppelin','led-zeppelin','The Lemon Song','the-lemon-song','Led Zeppelin II',1969),
    ('Guns N'' Roses','guns-n-roses','Sweet Child o'' Mine','sweet-child-o-mine','Appetite for Destruction',1987),
    ('Rancid','rancid','Maxwell Murder','maxwell-murder','...And Out Come the Wolves',1995),
    ('The Stranglers','the-stranglers','Peaches','peaches','Rattus Norvegicus',1977),
    ('Pixies','pixies','Gigantic','gigantic','Surfer Rosa',1988),
    ('Radiohead','radiohead','The National Anthem','the-national-anthem','Kid A',2000),
    ('Muse','muse','Time Is Running Out','time-is-running-out','Absolution',2003),
    ('Beastie Boys','beastie-boys','Sabotage','sabotage','Ill Communication',1994),
    ('Rage Against the Machine','rage-against-the-machine','Killing in the Name','killing-in-the-name','Rage Against the Machine',1992),
    ('Primus','primus','Jerry Was a Race Car Driver','jerry-was-a-race-car-driver','Sailing the Seas of Cheese',1991),
    ('The Temptations','the-temptations','My Girl','my-girl','The Temptations Sing Smokey',1964),
    ('Ben E. King','ben-e-king','Stand by Me','stand-by-me','Don''t Play That Song!',1961),
    ('Lou Reed','lou-reed','Walk on the Wild Side','walk-on-the-wild-side','Transformer',1972),
    ('Tool','tool','Forty Six & 2','forty-six-and-2','AEnima',1996),
    ('Megadeth','megadeth','Peace Sells','peace-sells','Peace Sells... but Who''s Buying?',1986)
),
ins_artists as (
  insert into public.artists (name, slug, search_text, is_active)
  select distinct artist_name, artist_slug, artist_name, true from target
  on conflict (slug) do update set name = excluded.name, is_active = true
  returning id, slug
)
insert into public.songs (artist_id, title, slug, album, release_year, search_text, is_active)
select a.id, t.song_title, t.song_slug, t.album, t.release_year,
       concat_ws(' ', t.song_title, t.artist_name, t.album, 'bassline bass'), true
from target t join ins_artists a on a.slug = t.artist_slug
on conflict (artist_id, slug) do update set
  is_active = true, updated_at = now();

-- BASS-ONLY deletes: existing guitar profiles on these songs are preserved.
delete from public.tone_profile_effects e where e.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('joy-division','love-will-tear-us-apart'),('joy-division','transmission'),('joy-division','disorder'),
    ('new-order','age-of-consent'),('new-order','ceremony'),('the-cure','a-forest'),('the-cure','fascination-street'),
    ('talking-heads','psycho-killer'),('the-beatles','rain'),('the-beatles','something'),('led-zeppelin','the-lemon-song'),
    ('guns-n-roses','sweet-child-o-mine'),('rancid','maxwell-murder'),('the-stranglers','peaches'),('pixies','gigantic'),
    ('radiohead','the-national-anthem'),('muse','time-is-running-out'),('beastie-boys','sabotage'),
    ('rage-against-the-machine','killing-in-the-name'),('primus','jerry-was-a-race-car-driver'),
    ('the-temptations','my-girl'),('ben-e-king','stand-by-me'),('lou-reed','walk-on-the-wild-side'),
    ('tool','forty-six-and-2'),('megadeth','peace-sells')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
  where p.mode = 'bass'
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('joy-division','love-will-tear-us-apart'),('joy-division','transmission'),('joy-division','disorder'),
    ('new-order','age-of-consent'),('new-order','ceremony'),('the-cure','a-forest'),('the-cure','fascination-street'),
    ('talking-heads','psycho-killer'),('the-beatles','rain'),('the-beatles','something'),('led-zeppelin','the-lemon-song'),
    ('guns-n-roses','sweet-child-o-mine'),('rancid','maxwell-murder'),('the-stranglers','peaches'),('pixies','gigantic'),
    ('radiohead','the-national-anthem'),('muse','time-is-running-out'),('beastie-boys','sabotage'),
    ('rage-against-the-machine','killing-in-the-name'),('primus','jerry-was-a-race-car-driver'),
    ('the-temptations','my-girl'),('ben-e-king','stand-by-me'),('lou-reed','walk-on-the-wild-side'),
    ('tool','forty-six-and-2'),('megadeth','peace-sells')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
  where p.mode = 'bass'
);
delete from public.song_tone_profiles p where p.mode = 'bass' and p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('joy-division','love-will-tear-us-apart'),('joy-division','transmission'),('joy-division','disorder'),
    ('new-order','age-of-consent'),('new-order','ceremony'),('the-cure','a-forest'),('the-cure','fascination-street'),
    ('talking-heads','psycho-killer'),('the-beatles','rain'),('the-beatles','something'),('led-zeppelin','the-lemon-song'),
    ('guns-n-roses','sweet-child-o-mine'),('rancid','maxwell-murder'),('the-stranglers','peaches'),('pixies','gigantic'),
    ('radiohead','the-national-anthem'),('muse','time-is-running-out'),('beastie-boys','sabotage'),
    ('rage-against-the-machine','killing-in-the-name'),('primus','jerry-was-a-race-car-driver'),
    ('the-temptations','my-girl'),('ben-e-king','stand-by-me'),('lou-reed','walk-on-the-wild-side'),
    ('tool','forty-six-and-2'),('megadeth','peace-sells')
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
  concat_ws(' ', s.title, a.name, c.part_label, c.tone_type, c.original_guitar, c.original_amp, 'bassline researched verified tone'),
  true
from (
  values
    ('love-will-tear-us-apart','joy-division','bass','bassline','high melodic bassline','bass_clean','post-punk','rhythm','beginner',
     'Rickenbacker/Hondo bass (Peter Hook)','Amp, trebly high-melody','Bass cab','high-output pickup',
     '[{"effect_type":"chorus","effect_name":"light chorus color","placement":"post_gain","settings":{"rate":3,"depth":3,"mix":3}}]'::jsonb,
     '{"gain":2,"bass":4,"mids":6,"treble":8,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Hooky''s high-melody thesis — the bass plays the hook because Barney''s guitar wouldn''t.','Trebly picked high-register melody; the bass IS the chorus.'],
     array['Play the melody high on the neck with a pick.','Love will tear us apart — the bass holds it together.'],
     'Studio recording, 1980. Hooky''s high-melody thesis.',80),
    ('transmission','joy-division','bass','bassline','driving bassline','bass_clean','post-punk','rhythm','beginner',
     'Rickenbacker bass (Peter Hook)','Amp, driving and bright','Bass cab','high-output pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Dance dance dance to the radio — Hooky''s relentless eighth-note transmission.','Bright picked drive; the pulse never breaks.'],
     array['Eighth notes with a pick, forever.','And we would go on as though nothing was wrong.'],
     'Studio recording, 1979. The relentless radio transmission.',79),
    ('disorder','joy-division','bass','bassline','melodic pulse','bass_clean','post-punk','rhythm','intermediate',
     'Rickenbacker bass (Peter Hook)','Amp, urgent melodic pulse','Bass cab','high-output pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['The Unknown Pleasures opener — Hooky''s racing melodic figure over Morris'' hi-hats.','Bright urgent picking; the spirit, the feeling, the pulse.'],
     array['The figure races and lifts.','I''ve been waiting for a guide — the bass is it.'],
     'Studio recording, 1979. The racing opener pulse.',79),
    ('age-of-consent','new-order','bass','bassline','lead bassline','bass_clean','post-punk','rhythm','intermediate',
     'Yamaha/Shergold bass (Peter Hook)','Amp with chorus shimmer','Bass cab','high-output pickup',
     '[{"effect_type":"chorus","effect_name":"NW chorus shimmer","placement":"post_gain","settings":{"rate":3,"depth":4,"mix":4}}]'::jsonb,
     '{"gain":2,"bass":4,"mids":6,"treble":8,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Hooky in the sunlight — the sprinting high melody that opens Power, Corruption & Lies.','Chorused trebly melody; grief learning to dance.'],
     array['The intro line sprints high and bright.','I''m not the kind that likes to tell you — the bass tells everything.'],
     'Studio recording, 1983. Hooky''s sunlight sprint.',79),
    ('ceremony','new-order','bass','bassline','driving melody','bass_clean','post-punk','rhythm','intermediate',
     'Bass (Peter Hook)','Amp, bright driving melody','Bass cab','high-output pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['The bridge between bands — Curtis'' last song, New Order''s first, carried by Hooky''s climbing line.','Bright picked melody; this is why events unnerve me.'],
     array['The line climbs through the changes.','Watching her, these things she said — keep moving.'],
     'Studio recording, 1981. The bridge-between-bands line.',79),
    ('a-forest','the-cure','bass','bassline','hypnotic pulse','bass_clean','post-punk','rhythm','beginner',
     'Fender Precision Bass (Simon Gallup)','Amp with chorus, cold pulse','Bass cab','split-coil pickup',
     '[{"effect_type":"chorus","effect_name":"cold chorus","placement":"post_gain","settings":{"rate":3,"depth":4,"mix":4}}]'::jsonb,
     '{"gain":2,"bass":6,"mids":5,"treble":5,"presence":4,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The Cure''s cold heartbeat — Gallup''s hypnotic pulse through the trees.','Chorused dark pulse; the girl was never there.'],
     array['Eighth-note pulse, chorus on, emotions off.','It''s always the same — that''s the point.'],
     'Studio recording, 1980. Gallup''s forest heartbeat.',79),
    ('fascination-street','the-cure','bass','bassline','main riff','bass_drive','post-punk','rhythm','intermediate',
     'Fender Bass VI/P-Bass (Simon Gallup)','Amp with drive and chorus','Bass cab','split-coil pickup',
     '[{"effect_type":"chorus","effect_name":"deep chorus","placement":"post_gain","settings":{"rate":3,"depth":5,"mix":5}},{"effect_type":"distortion","effect_name":"light grind","placement":"front","settings":{"gain":4,"level":6}}]'::jsonb,
     '{"gain":4,"bass":6,"mids":6,"treble":5,"presence":4,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The Disintegration prowl — Gallup''s driven chorused riff IS the song''s spine.','Gritty chorused growl; oh it''s opening time.'],
     array['The riff prowls down Fascination Street.','So pull on your hair, pull on your pout.'],
     'Studio recording, 1989. Gallup''s Disintegration prowl.',79),
    ('psycho-killer','talking-heads','bass','bassline','main bassline','bass_clean','new wave','rhythm','beginner',
     'Fender Precision/Mustang Bass (Tina Weymouth)','Amp, dry nervous pulse','Bass cab','split-coil pickup',
     '[]'::jsonb,'{"gain":2,"bass":6,"mids":6,"treble":5,"presence":4,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['Fa-fa-fa-fa-fa — Tina''s nervous walking pulse under Byrne''s twitch.','Dry round pulse; anxiety with a groove.'],
     array['The line walks tense and even.','Qu''est-ce que c''est — exactly that steady.'],
     'Studio recording, 1977. Tina''s nervous pulse.',80),
    ('rain','the-beatles','bass','bassline','lead bassline','bass_clean','rock','rhythm','advanced',
     'Rickenbacker 4001 (Paul McCartney)','Vox amp, hot-mic''d and loud','Vox cab','toaster pickups',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['McCartney''s own favorite — the roaming lead bass mixed louder than anything Beatles before it.','Growling melodic Rick; the bass is the weather system.'],
     array['The line roams the whole neck.','Rain — I don''t mind. The bass clearly doesn''t.'],
     'Studio recording, 1966. McCartney''s roaming favorite.',80),
    ('something','the-beatles','bass','bassline','countermelody bassline','bass_clean','rock','rhythm','advanced',
     'Fender Jazz Bass (Paul McCartney)','Amp, warm singing countermelody','Bass cab','J pickups',
     '[]'::jsonb,'{"gain":2,"bass":6,"mids":6,"treble":5,"presence":4,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['The countermelody masterclass — McCartney answers Harrison''s love song with a second one.','Warm melodic Jazz Bass; busy, but never in the way.'],
     array['Every fill is a melody — learn them as vocal lines.','George grumbled it was busy. George was outvoted by history.'],
     'Studio recording, 1969. The countermelody masterclass.',80),
    ('the-lemon-song','led-zeppelin','bass','bassline','walking blues masterclass','bass_clean','rock','rhythm','expert',
     'Fender Jazz Bass (John Paul Jones)','Amp, warm walking blues','Bass cab','J pickups',
     '[]'::jsonb,'{"gain":2,"bass":6,"mids":6,"treble":5,"presence":4,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['JPJ''s improvised walking clinic — the fast section is bass-school scripture.','Warm nimble Jazz tone; jazz chops in a blues riot.'],
     array['The fast walking section never repeats — study the logic, not the notes.','Squeeze me baby — the bass already is.'],
     'Studio recording, 1969. JPJ''s walking clinic.',80),
    ('sweet-child-o-mine','guns-n-roses','bass','bassline','melodic bassline','bass_clean','rock','rhythm','intermediate',
     'Fender Jazz Bass Special (Duff McKagan)','Amp with chorus, punk-schooled melody','Bass cab','P/J pickups',
     '[{"effect_type":"chorus","effect_name":"Duff chorus","placement":"post_gain","settings":{"rate":3,"depth":4,"mix":4}}]'::jsonb,
     '{"gain":2,"bass":6,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Duff''s chorused counterline — the melodic bass nobody notices holding the whole ballad up.','Chorused round punch; punk feel, pop brain.'],
     array['The verse line moves — it never just roots.','Where do we go now? Follow Duff.'],
     'Studio recording, 1987. Duff''s chorused counterline.',79),
    ('maxwell-murder','rancid','bass','bassline','bass solo showcase','bass_drive','punk','lead','expert',
     'Fender Precision Bass (Matt Freeman)','Amp, punk grind','Bass cab','split-coil pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":7,"treble":6,"presence":6,"reverb":0,"delay":0,"master":8}'::jsonb,
     array['The greatest punk bass solo ever cut — Freeman''s 20-second flurry that ended arguments.','Gritty punchy P-Bass; jazz hands in a street fight.'],
     array['The solo runs triplets at punk tempo — decades of chops in 20 seconds.','Learn it slow. Everyone does.'],
     'Studio recording, 1995. Freeman''s argument-ending solo.',79),
    ('peaches','the-stranglers','bass','bassline','growling riff','bass_drive','punk','rhythm','beginner',
     'Fender Precision Bass (Jean-Jacques Burnel)','Hiwatt cranked, the growl','Bass 4x12 stack','split-coil, roundwounds',
     '[{"effect_type":"distortion","effect_name":"Burnel growl (cranked Hiwatt)","placement":"front","settings":{"gain":5,"level":7}}]'::jsonb,
     '{"gain":5,"bass":6,"mids":7,"treble":6,"presence":6,"reverb":0,"delay":0,"master":8}'::jsonb,
     array['THE bass growl — Burnel''s snarling strut that defined the meanest tone in punk.','Overdriven Hiwatt snarl; walking on the beaches.'],
     array['The riff struts filthy.','Is she trying to get out of that clitares? Focus on the riff.'],
     'Studio recording, 1977. Burnel''s definitive growl.',79),
    ('gigantic','pixies','bass','bassline','main bassline','bass_clean','alternative rock','rhythm','beginner',
     'Fender Precision Bass (Kim Deal)','Amp, round and huge','Bass cab','split-coil pickup',
     '[]'::jsonb,'{"gain":2,"bass":7,"mids":5,"treble":5,"presence":4,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Kim Deal''s big big love — the round rolling line that IS the song.','Deep warm roll; a big big love indeed.'],
     array['The line rolls four notes forever.','And this I know — the bass never doubts.'],
     'Studio recording, 1988. Kim Deal''s big big line.',79),
    ('the-national-anthem','radiohead','bass','bassline','fuzz ostinato','bass_drive','alternative rock','rhythm','beginner',
     'Fender Precision Bass (Colin Greenwood / Thom Yorke)','Amp with fuzz, relentless ostinato','Bass cab','split-coil pickup',
     '[{"effect_type":"fuzz","effect_name":"bass fuzz","placement":"front","settings":{"gain":6,"level":6}}]'::jsonb,
     '{"gain":5,"bass":6,"mids":6,"treble":5,"presence":5,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The Kid A riot — one fuzz ostinato holding while the horn section loses its mind.','Gritty fuzz drone; everyone around you can panic, you cannot.'],
     array['The riff never changes. Ever. That''s the job.','Everyone has got the fear — you''ve got the ostinato.'],
     'Studio recording, 2000. The unmovable fuzz ostinato.',79),
    ('time-is-running-out','muse','bass','bassline','fuzz intro riff','bass_drive','alternative rock','rhythm','beginner',
     'Pedulla/Status bass (Chris Wolstenholme)','Amp with fuzz blend','Bass cab','humbucker pickups',
     '[{"effect_type":"fuzz","effect_name":"filtered fuzz blend","placement":"front","settings":{"gain":6,"blend":6,"level":6}}]'::jsonb,
     '{"gain":5,"bass":6,"mids":6,"treble":5,"presence":5,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['The clicking fuzz intro everyone recognizes in one bar — Wolstenholme''s filtered snarl.','Filtered fuzz blend; the intro riff is the hook.'],
     array['The muted intro riff clicks and snarls.','Bury it — I won''t let you.'],
     'Studio recording, 2003. The clicking fuzz intro.',79),
    ('sabotage','beastie-boys','bass','bassline','fuzz riff','bass_drive','rap rock','rhythm','beginner',
     'Fender/Gibson bass (Adam Yauch)','Amp with heavy fuzz','Bass cab','split-coil pickup',
     '[{"effect_type":"fuzz","effect_name":"heavy bass fuzz","placement":"front","settings":{"gain":7,"level":7}}]'::jsonb,
     '{"gain":6,"bass":6,"mids":6,"treble":6,"presence":6,"reverb":0,"delay":0,"master":8}'::jsonb,
     array['MCA''s fuzz alarm — the sliding riff that IS Sabotage.','Blown-out fuzz slide; listen all y''all.'],
     array['Slide into the riff hard.','I can''t stand it — the riff can.'],
     'Studio recording, 1994. MCA''s fuzz alarm.',79),
    ('killing-in-the-name','rage-against-the-machine','bass','bassline','drop-D groove','bass_drive','funk metal','rhythm','intermediate',
     'Fender Jazz Bass (Tim Commerford)','Amp with grind, drop-D weight','Bass 4x10 stack','J pickups',
     '[{"effect_type":"distortion","effect_name":"bass grind","placement":"front","settings":{"gain":5,"level":6}}]'::jsonb,
     '{"gain":4,"bass":7,"mids":6,"treble":5,"presence":5,"reverb":0,"delay":0,"master":8}'::jsonb,
     array['Timmy C''s drop-D anchor — the intro bass figure and the weight under the fury.','Thick grinding Jazz tone; the groove IS the protest.'],
     array['The intro figure bends into drop D.','And now you do what they told ya — except the bass never did.'],
     'Studio recording, 1992. Timmy C''s drop-D anchor.',79),
    ('jerry-was-a-race-car-driver','primus','bass','bassline','tapped slap riff','bass_drive','alternative metal','lead','expert',
     'Carl Thompson 6-string fretless (Les Claypool)','Amp, clanking tapped chaos','Bass 4x10 cab','custom pickups',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":7,"treble":7,"presence":6,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['The tapped-and-strummed mutant — Claypool''s signature riff on six fretless strings.','Clanking percussive weirdness; the riff IS the song IS the riff.'],
     array['Tap the chord shape while strumming — yes, simultaneously.','Jerry was a race car driver — and Les is unquestionable.'],
     'Studio recording, 1991. Claypool''s tapped mutant riff.',79),
    ('my-girl','the-temptations','bass','bassline','main bassline','bass_clean','soul','rhythm','beginner',
     'Fender Precision Bass (James Jamerson)','Direct to console, Motown','Studio DI','split-coil, flatwounds',
     '[]'::jsonb,'{"gain":2,"bass":6,"mids":6,"treble":4,"presence":3,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Jamerson under the sunshine — the walking warmth beneath the most famous intro in soul.','Warm flatwound thump; sunshine needs a floor.'],
     array['Walk the changes with gentle swing.','I guess you''d say — the bass already said it.'],
     'Studio recording, 1964. Jamerson''s sunshine floor.',80),
    ('stand-by-me','ben-e-king','bass','bassline','the eternal line','bass_clean','soul','rhythm','beginner',
     'Upright/electric bass (session — Lloyd Trotman)','Direct, warm and eternal','Studio DI','n/a (upright feel)',
     '[]'::jsonb,'{"gain":1,"bass":7,"mids":5,"treble":4,"presence":3,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Possibly the most famous bassline ever — Trotman''s dum, dum-dum, dum-dum figure.','Deep round warmth; the whole song stands on six notes.'],
     array['The figure is six notes — place them like stones.','When the night has come — you are the land.'],
     'Studio recording, 1961. The six-note eternal.',80),
    ('walk-on-the-wild-side','lou-reed','bass','bassline','double bassline','bass_clean','rock','rhythm','intermediate',
     'Upright + fretless electric, layered (Herbie Flowers)','Direct, the famous double-track','Studio DI','n/a (layered)',
     '[]'::jsonb,'{"gain":1,"bass":7,"mids":5,"treble":4,"presence":3,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Herbie Flowers'' double-tracked glide — upright below, fretless sliding a tenth above (he got paid twice; the line got immortal).','Warm layered slide; doo do-doo do-doo.'],
     array['Play the sliding upper line; imply the root below.','Hey babe — take a walk on the low side.'],
     'Studio recording, 1972. Flowers'' double-tracked glide.',80),
    ('forty-six-and-2','tool','bass','bassline','main riff','bass_drive','progressive metal','rhythm','intermediate',
     'Wal Mk2 bass (Justin Chancellor)','Amp, honking Wal grind','Bass 4x10 stack','Wal pickups',
     '[]'::jsonb,'{"gain":4,"bass":6,"mids":7,"treble":6,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['The shadow-work groove — Chancellor''s picked D riff every bassist''s YouTube algorithm eventually serves.','Honking picked Wal; my shadow''s shedding skin.'],
     array['The riff pivots on the low D — pick it even.','Change is coming through my shadow — and your right hand.'],
     'Studio recording, 1996. Chancellor''s shadow-work groove.',79),
    ('peace-sells','megadeth','bass','bassline','intro bassline','bass_drive','thrash metal','rhythm','intermediate',
     'Jackson bass (David Ellefson)','Amp with grind, MTV-news famous','Bass stack','P/J pickups',
     '[{"effect_type":"distortion","effect_name":"bass grind","placement":"front","settings":{"gain":5,"level":6}}]'::jsonb,
     '{"gain":4,"bass":6,"mids":7,"treble":6,"presence":6,"reverb":0,"delay":0,"master":8}'::jsonb,
     array['The MTV News theme — Ellefson''s snapping intro riff that introduced a generation to thrash bass.','Gritty punchy grind; peace sells, but who''s buying?'],
     array['The intro riff snaps and rolls.','If there''s a new way — it starts on your low E.'],
     'Studio recording, 1986. Ellefson''s MTV-famous intro.',79)
) as c(
  song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence
)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;
