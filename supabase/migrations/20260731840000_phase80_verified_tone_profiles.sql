-- Phase 80: funk/soul guitar canon vol. 2 — JB chicken-scratch school, Stax deep cuts, 70s funk singles.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('James Brown','james-brown','Papa''s Got a Brand New Bag','papas-got-a-brand-new-bag','Papa''s Got a Brand New Bag',1965),
    ('James Brown','james-brown','Get Up (I Feel Like Being a) Sex Machine','get-up-sex-machine','Sex Machine',1970),
    ('James Brown','james-brown','Cold Sweat','cold-sweat','Cold Sweat',1967),
    ('James Brown','james-brown','The Payback','the-payback','The Payback',1973),
    ('The Meters','the-meters','Look-Ka Py Py','look-ka-py-py','Look-Ka Py Py',1969),
    ('Wilson Pickett','wilson-pickett','In the Midnight Hour','in-the-midnight-hour','In the Midnight Hour',1965),
    ('Wilson Pickett','wilson-pickett','Mustang Sally','mustang-sally','The Wicked Pickett',1966),
    ('Eddie Floyd','eddie-floyd','Knock on Wood','knock-on-wood','Knock on Wood',1966),
    ('Sam & Dave','sam-and-dave','Hold On, I''m Comin''','hold-on-im-comin','Hold On, I''m Comin''',1966),
    ('Otis Redding','otis-redding','Try a Little Tenderness','try-a-little-tenderness','Complete & Unbelievable: The Otis Redding Dictionary of Soul',1966),
    ('Aretha Franklin','aretha-franklin','Respect','respect','I Never Loved a Man the Way I Love You',1967),
    ('Marvin Gaye','marvin-gaye','I Heard It Through the Grapevine','i-heard-it-through-the-grapevine','In the Groove',1968),
    ('Ohio Players','ohio-players','Fire','fire-ohio-players','Fire',1974),
    ('The Temptations','the-temptations','Ain''t Too Proud to Beg','aint-too-proud-to-beg','Gettin'' Ready',1966),
    ('KC and the Sunshine Band','kc-and-the-sunshine-band','Get Down Tonight','get-down-tonight','KC and the Sunshine Band',1975),
    ('Commodores','commodores','Easy','easy','Commodores',1977),
    ('Isaac Hayes','isaac-hayes','Theme from Shaft','theme-from-shaft','Shaft',1971),
    ('The J.B.''s','the-jbs','Pass the Peas','pass-the-peas','Food for Thought',1972),
    ('Archie Bell & The Drells','archie-bell-and-the-drells','Tighten Up','tighten-up','Tighten Up',1968),
    ('Sly & The Family Stone','sly-and-the-family-stone','Dance to the Music','dance-to-the-music','Dance to the Music',1968),
    ('Rufus & Chaka Khan','rufus-and-chaka-khan','Tell Me Something Good','tell-me-something-good','Rags to Rufus',1974),
    ('Curtis Mayfield','curtis-mayfield','Pusherman','pusherman','Super Fly',1972),
    ('Bobby Womack','bobby-womack','Across 110th Street','across-110th-street','Across 110th Street',1972),
    ('War','war','Low Rider','low-rider','Why Can''t We Be Friends?',1975),
    ('The Chambers Brothers','the-chambers-brothers','Time Has Come Today','time-has-come-today','The Time Has Come',1967)
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
    ('james-brown','papas-got-a-brand-new-bag'),('james-brown','get-up-sex-machine'),('james-brown','cold-sweat'),
    ('james-brown','the-payback'),('the-meters','look-ka-py-py'),('wilson-pickett','in-the-midnight-hour'),
    ('wilson-pickett','mustang-sally'),('eddie-floyd','knock-on-wood'),('sam-and-dave','hold-on-im-comin'),
    ('otis-redding','try-a-little-tenderness'),('aretha-franklin','respect'),('marvin-gaye','i-heard-it-through-the-grapevine'),
    ('ohio-players','fire-ohio-players'),('the-temptations','aint-too-proud-to-beg'),
    ('kc-and-the-sunshine-band','get-down-tonight'),('commodores','easy'),('isaac-hayes','theme-from-shaft'),
    ('the-jbs','pass-the-peas'),('archie-bell-and-the-drells','tighten-up'),('sly-and-the-family-stone','dance-to-the-music'),
    ('rufus-and-chaka-khan','tell-me-something-good'),('curtis-mayfield','pusherman'),('bobby-womack','across-110th-street'),
    ('war','low-rider'),('the-chambers-brothers','time-has-come-today')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
  where p.mode = 'guitar'
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('james-brown','papas-got-a-brand-new-bag'),('james-brown','get-up-sex-machine'),('james-brown','cold-sweat'),
    ('james-brown','the-payback'),('the-meters','look-ka-py-py'),('wilson-pickett','in-the-midnight-hour'),
    ('wilson-pickett','mustang-sally'),('eddie-floyd','knock-on-wood'),('sam-and-dave','hold-on-im-comin'),
    ('otis-redding','try-a-little-tenderness'),('aretha-franklin','respect'),('marvin-gaye','i-heard-it-through-the-grapevine'),
    ('ohio-players','fire-ohio-players'),('the-temptations','aint-too-proud-to-beg'),
    ('kc-and-the-sunshine-band','get-down-tonight'),('commodores','easy'),('isaac-hayes','theme-from-shaft'),
    ('the-jbs','pass-the-peas'),('archie-bell-and-the-drells','tighten-up'),('sly-and-the-family-stone','dance-to-the-music'),
    ('rufus-and-chaka-khan','tell-me-something-good'),('curtis-mayfield','pusherman'),('bobby-womack','across-110th-street'),
    ('war','low-rider'),('the-chambers-brothers','time-has-come-today')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
  where p.mode = 'guitar'
);
delete from public.song_tone_profiles p where p.mode = 'guitar' and p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('james-brown','papas-got-a-brand-new-bag'),('james-brown','get-up-sex-machine'),('james-brown','cold-sweat'),
    ('james-brown','the-payback'),('the-meters','look-ka-py-py'),('wilson-pickett','in-the-midnight-hour'),
    ('wilson-pickett','mustang-sally'),('eddie-floyd','knock-on-wood'),('sam-and-dave','hold-on-im-comin'),
    ('otis-redding','try-a-little-tenderness'),('aretha-franklin','respect'),('marvin-gaye','i-heard-it-through-the-grapevine'),
    ('ohio-players','fire-ohio-players'),('the-temptations','aint-too-proud-to-beg'),
    ('kc-and-the-sunshine-band','get-down-tonight'),('commodores','easy'),('isaac-hayes','theme-from-shaft'),
    ('the-jbs','pass-the-peas'),('archie-bell-and-the-drells','tighten-up'),('sly-and-the-family-stone','dance-to-the-music'),
    ('rufus-and-chaka-khan','tell-me-something-good'),('curtis-mayfield','pusherman'),('bobby-womack','across-110th-street'),
    ('war','low-rider'),('the-chambers-brothers','time-has-come-today')
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
    ('papas-got-a-brand-new-bag','james-brown','guitar','riff','chicken-scratch comping','clean','funk','rhythm','intermediate',
     'Gibson ES-series (Jimmy Nolen)','Small tube amp, dry scratch','Small combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Where funk guitar begins — Nolen''s chicken-scratch ninths on the record that invented the genre.','Dry trebly clean; the scratch is muted strums with chord stabs on the One.'],
     array['Ninth chords, staccato, on the One.','Papa''s got a brand new bag — and you''ve got a new right hand.'],
     'Studio recording, 1965. Nolen invents funk guitar.',80),
    ('get-up-sex-machine','james-brown','guitar','riff','scratch groove','clean','funk','rhythm','intermediate',
     'Gibson/Fender electric (Catfish Collins)','Small tube amp, dry','Small combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":0,"delay":0,"master":6}'::jsonb,
     array['Get on up — Catfish Collins'' single-chord scratch machine.','Bone-dry trebly clean; one chord, infinite groove.'],
     array['The E9 scratch never stops.','Shall we take it to the bridge? Only when James says.'],
     'Studio recording, 1970. Catfish''s one-chord machine.',79),
    ('cold-sweat','james-brown','guitar','riff','scratch groove','clean','funk','rhythm','intermediate',
     'Gibson ES-series (Jimmy Nolen)','Small tube amp, dry','Small combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":0,"delay":0,"master":6}'::jsonb,
     array['The first pure-funk record — Nolen''s scratch over the drum break that hip-hop later mined forever.','Dry chip clean; the groove is the entire architecture.'],
     array['Chip the D9 pattern with ghost strums.','Give the drummer some — and stay out of his way.'],
     'Studio recording, 1967. The first pure-funk scratch.',79),
    ('the-payback','james-brown','guitar','riff','wah-scratch groove','clean','funk','rhythm','intermediate',
     'Fender/Gibson electric (Jimmy Nolen / Hearlon Martin)','Small amp with wah','Small combo cab','bridge pickup',
     '[{"effect_type":"wah","effect_name":"slow wah scratch","placement":"front","settings":{"position":5}}]'::jsonb,
     '{"gain":2,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Revenge in 7 minutes — the wah-scratch groove sampled a thousand times.','Dry scratch through a slow wah; menace at simmer.'],
     array['Rock the wah lazily against the scratch.','I don''t know karate, but I know ka-razy.'],
     'Studio recording, 1973. The sampled-forever wah-scratch.',79),
    ('look-ka-py-py','the-meters','guitar','riff','second-line funk riff','clean','funk','rhythm','intermediate',
     'Fender/Gibson electric (Leo Nocentelli)','Small tube amp, dry NOLA snap','Small combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['New Orleans in one riff — Nocentelli''s snapping syncopation with the second-line strut.','Dry snappy clean; the space IS the funk.'],
     array['The riff answers the drums'' strut.','Py py — exactly where the band grunts.'],
     'Studio recording, 1969. Nocentelli''s second-line snap.',79),
    ('in-the-midnight-hour','wilson-pickett','guitar','riff','stax backbeat comping','clean','soul','rhythm','beginner',
     'Fender Telecaster (Steve Cropper)','Fender tube amp, warm Stax','Fender combo cab','bridge single-coil',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The delayed-backbeat classic — Cropper''s chords pushed famously behind the beat.','Warm dry Tele; the lag is the invention (Jerry Wexler danced it for them).'],
     array['Push the chord stabs just behind beat two and four.','Wait for it. Then wait a little more.'],
     'Studio recording, 1965. Cropper''s delayed-backbeat invention.',80),
    ('mustang-sally','wilson-pickett','guitar','riff','slow-burn comping','clean','soul','rhythm','beginner',
     'Fender Telecaster (session — Muscle Shoals)','Fender tube amp, greasy clean','Fender combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The bar-band eternal — greasy slow-burn comping every covers act knows.','Warm just-hairy clean; ride Sally ride at exactly this simmer.'],
     array['Comp the C7 groove with double-stop slides.','All you want to do is ride around — so groove accordingly.'],
     'Studio recording, 1966. The bar-band eternal.',78),
    ('knock-on-wood','eddie-floyd','guitar','riff','stax stabs','clean','soul','rhythm','beginner',
     'Fender Telecaster (Steve Cropper)','Fender tube amp, biting Stax','Fender combo cab','bridge single-coil',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Co-written by Cropper — the ascending horn-echo stabs and superstition backbeats.','Bright cutting Tele; knock the stabs like the title.'],
     array['The rising figure mirrors the horns.','It''s like thunder — lightning — hit those two.'],
     'Studio recording, 1966. Cropper''s superstition stabs.',79),
    ('hold-on-im-comin','sam-and-dave','guitar','riff','stax riff','clean','soul','rhythm','beginner',
     'Fender Telecaster (Steve Cropper)','Fender tube amp, warm Stax','Fender combo cab','bridge single-coil',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The rescue anthem — Cropper''s riff locked arm-in-arm with the horns.','Warm punchy Tele; the unison riff carries the promise.'],
     array['Double the horn line exactly.','Don''t you ever be sad — the riff won''t allow it.'],
     'Studio recording, 1966. The rescue-anthem unison riff.',79),
    ('try-a-little-tenderness','otis-redding','guitar','riff','build comping','clean','soul','rhythm','intermediate',
     'Fender Telecaster (Steve Cropper)','Fender tube amp, warm to driving','Fender combo cab','bridge single-coil',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The greatest build in soul — Cropper''s chords growing from whisper to the got-ta-got-ta finale.','Warm clean intensifying with the arrangement; the crescendo is everything.'],
     array['Start at a whisper; add stabs as Otis ignites.','By the end you''re strumming for your life.'],
     'Studio recording, 1966. The greatest crescendo in soul.',80),
    ('respect','aretha-franklin','guitar','riff','atlantic soul comping','clean','soul','rhythm','beginner',
     'Fender Telecaster (Jimmy Johnson — Muscle Shoals school)','Fender tube amp, tight soul','Fender combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The anthem of anthems — tight session comping under the Queen demanding hers.','Crisp dry clean; the guitar serves and never leads.'],
     array['Stab the backbeats with the horns.','R-E-S-P-E-C-T — the chord chart is that simple; the feel is not.'],
     'Studio recording, 1967. The session comping behind the Queen.',79),
    ('i-heard-it-through-the-grapevine','marvin-gaye','guitar','riff','motown minor groove','clean','soul','rhythm','beginner',
     'Fender/Gibson electric (Funk Brothers — Joe Messina / Robert White)','Fender tube amp, dark Motown','Fender combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":5,"presence":4,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The paranoid masterpiece — muted minor-key chanks under the electric piano riff.','Dark warm clean; dread in E-flat minor.'],
     array['Chank the off-beats muted and low.','Honey honey yeah — but make it ominous.'],
     'Studio recording, 1968. The paranoid Motown chank.',79),
    ('fire-ohio-players','ohio-players','guitar','riff','funk-rock riff','crunch','funk','rhythm','intermediate',
     'Gibson/Fender electric (Leroy Bonner)','Tube amp, gritty funk-rock','Closed-back cab','bridge pickup',
     '[{"effect_type":"wah","effect_name":"wah accents","placement":"front","settings":{"position":5}}]'::jsonb,
     '{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['The siren-opener stomp — Sugarfoot''s gritty wah-kissed funk-rock riff.','Warm gritty funk crunch; the siren says it all.'],
     array['The riff struts through the wah.','Fire! — then burn steadily.'],
     'Studio recording, 1974. Sugarfoot''s siren stomp.',78),
    ('aint-too-proud-to-beg','the-temptations','guitar','riff','motown comping','clean','soul','rhythm','beginner',
     'Fender/Gibson electric (Funk Brothers)','Fender tube amp, bright Motown','Fender combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The pleading stomp — bright Motown chanks driving David Ruffin''s rasp.','Crisp trebly clean; the backbeat chank is relentless.'],
     array['Chank every backbeat, no exceptions.','I know you wanna leave me — but the groove won''t.'],
     'Studio recording, 1966. The pleading backbeat stomp.',79),
    ('get-down-tonight','kc-and-the-sunshine-band','guitar','riff','sped-up intro + funk chank','clean','funk','rhythm','intermediate',
     'Fender Stratocaster (Jerome Smith)','Clean amp, Miami disco-funk','Studio direct','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":5,"treble":8,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['The famous intro is a guitar solo recorded at HALF SPEED then doubled — then Jerome Smith''s chank takes over.','Bright disco clean; the intro chatter is studio magic, the groove is real.'],
     array['Play the intro figure fast an octave up — or slow it and speed the tape like they did.','Do a little dance. That''s the chart.'],
     'Studio recording, 1975. The sped-up-tape intro and Miami chank.',78),
    ('easy','commodores','guitar','riff','ballad comping + solo','clean','soul','lead','intermediate',
     'Gibson electric (Thomas McClary)','Clean amp into singing lead','Small combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":5,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Easy like Sunday morning — gentle comping and McClary''s beloved melodic solo (gain 5).','Warm rounded clean; the solo sings the sermon.'],
     array['Comp the ballad soft.','The solo is a hymn — phrase it in full sentences.'],
     'Studio recording, 1977. McClary''s Sunday-morning solo.',79),
    ('theme-from-shaft','isaac-hayes','guitar','riff','wah sixteenths','clean','soul','rhythm','intermediate',
     'Gibson electric (Charles "Skip" Pitts)','Clean amp with wah','Small combo cab','bridge pickup',
     '[{"effect_type":"wah","effect_name":"continuous wah sixteenths","placement":"front","settings":{"position":5}}]'::jsonb,
     '{"gain":2,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['THE wah-wah part — Skip Pitts'' sixteenth-note wacka-wacka that scored a decade.','Clean muted sixteenths with constant wah rocking; the foot is the melody.'],
     array['Mute the strings; rock the wah on the sixteenth grid.','Who''s the cat who won''t cop out? Your right foot.'],
     'Studio recording, 1971. Skip Pitts'' wacka-wacka monument.',80),
    ('pass-the-peas','the-jbs','guitar','riff','jb funk riff','clean','funk','rhythm','intermediate',
     'Fender/Gibson electric (Hearlon "Cheese" Martin)','Small tube amp, dry','Small combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":0,"delay":0,"master":6}'::jsonb,
     array['The JB''s instrumental staple — dry chank under Fred Wesley''s horns.','Bone-dry funk chip; pass it like they ask.'],
     array['Chip the pattern behind the horn hits.','Like they used to say — pass the peas.'],
     'Studio recording, 1972. The JB''s dry-chank staple.',78),
    ('tighten-up','archie-bell-and-the-drells','guitar','riff','houston funk riff','clean','funk','rhythm','beginner',
     'Fender electric (T.S.U. Toronadoes session)','Clean amp, tight Houston funk','Small combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Do the tighten up — the skeletal Houston groove where every instrument gets introduced.','Dry tight clean; when he says tighten the guitar, that''s you.'],
     array['The riff walks the I-IV politely.','In Houston, Texas — and everywhere since.'],
     'Studio recording, 1968. The tighten-up introduction groove.',78),
    ('dance-to-the-music','sly-and-the-family-stone','guitar','riff','psychedelic soul riff','crunch','funk','rhythm','beginner',
     'Fender/Gibson electric (Freddie Stone)','Tube amp, bright fuzz-kissed soul','Small combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The instruction-manual hit — Freddie''s bright gritty riff as the band builds itself.','Bright hairy clean-crunch; joy with teeth.'],
     array['The riff enters when Freddie''s introduced — be ready.','All the squares, go home!'],
     'Studio recording, 1968. Freddie''s build-the-band riff.',78),
    ('tell-me-something-good','rufus-and-chaka-khan','guitar','riff','talk-box funk','clean','funk','rhythm','intermediate',
     'Fender/Gibson electric (Tony Maiden)','Amp with talk-box/wah color','Small combo cab','bridge pickup',
     '[{"effect_type":"wah","effect_name":"talk-box-style wah vowels","placement":"front","settings":{"position":5}}]'::jsonb,
     '{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Stevie''s gift to Chaka — the drawling talk-box/wah figure that answers every line.','Vowel-shaped wah drawl; the guitar talks back.'],
     array['Shape the wah like speech — aow, aow.','Tell me that you like it — the guitar already did.'],
     'Studio recording, 1974. Maiden''s talking funk drawl.',78),
    ('pusherman','curtis-mayfield','guitar','riff','wah soul groove','clean','soul','rhythm','intermediate',
     'Fender Stratocaster (Curtis Mayfield)','Clean amp with wah, open F# tuning','Small combo cab','neck pickup',
     '[{"effect_type":"wah","effect_name":"soft wah groove","placement":"front","settings":{"position":5}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Superfly''s street sermon — Curtis'' open-tuned wah groove, soft-spoken and lethal.','Gentle wah clean in his F# open tuning; menace at whisper volume.'],
     array['The muted wah groove rides under the conga.','I''m your mama, I''m your daddy — coolly.'],
     'Studio recording, 1972. Curtis'' whisper-menace wah groove.',79),
    ('across-110th-street','bobby-womack','guitar','riff','soul comping + fills','clean','soul','rhythm','intermediate',
     'Gibson ES-series (Bobby Womack)','Clean amp, warm soul','Small combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":5,"presence":4,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The ghetto-documentary theme (Tarantino brought it back) — Womack''s own aching comping.','Warm rounded clean; testimony in every fill.'],
     array['Comp the changes; sigh the fills.','Trying to catch a woman that''s weak — no judgment in the chords.'],
     'Studio recording, 1972. Womack''s aching street theme.',78),
    ('low-rider','war','guitar','riff','chank groove','clean','funk','rhythm','beginner',
     'Fender electric (Howard Scott)','Clean amp, laid-back chank','Small combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['The cruise anthem — Scott''s laid-back chank under the cowbell and horn hook.','Dry relaxed chip; take a little trip with it.'],
     array['Chank the G groove behind the beat.','The low rider don''t use no gas — neither should your picking.'],
     'Studio recording, 1975. The cruise-anthem chank.',78),
    ('time-has-come-today','the-chambers-brothers','guitar','riff','psychedelic soul riff','fuzz','psychedelic soul','rhythm','intermediate',
     'Fender/Gibson electric (Joe & Willie Chambers)','Tube amp with fuzz and cavern echo','Closed-back cab','bridge pickup',
     '[{"effect_type":"fuzz","effect_name":"psychedelic fuzz","placement":"front","settings":{"gain":6,"tone":5,"level":6}},{"effect_type":"delay","effect_name":"cavern echo (the cuckoo section)","placement":"post_gain","settings":{"time":5,"mix":4,"feedback":5}}]'::jsonb,
     '{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":3,"master":7}'::jsonb,
     array['The 11-minute psychedelic-soul trip — cowbell clock, fuzz riffing, and the echo-canyon breakdown.','Fuzzy gritty drive; the middle section dissolves into echo — let it.'],
     array['The main riff tolls with the cowbell tick.','Time! — then fall down the echo well and climb back out.'],
     'Studio recording, 1967. The psychedelic-soul time trip.',78)
) as c(
  song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence
)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;
