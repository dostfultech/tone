-- Phase 72: delta/country blues roots + soul standards + Christmas guitar canon, verified per-part tone data.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Son House','son-house','Death Letter','death-letter','Father of Folk Blues',1965),
    ('Skip James','skip-james','Hard Time Killing Floor Blues','hard-time-killing-floor-blues','Skip James Today!',1964),
    ('Mississippi John Hurt','mississippi-john-hurt','Spike Driver Blues','spike-driver-blues','Folk Songs and Blues',1963),
    ('Lead Belly','lead-belly','Where Did You Sleep Last Night','where-did-you-sleep-last-night','Lead Belly''s Last Sessions',1944),
    ('Lightnin'' Hopkins','lightnin-hopkins','Mojo Hand','mojo-hand','Mojo Hand',1960),
    ('Big Bill Broonzy','big-bill-broonzy','Key to the Highway','key-to-the-highway','Key to the Highway',1941),
    ('Elizabeth Cotten','elizabeth-cotten','Freight Train','freight-train','Folksongs and Instrumentals with Guitar',1958),
    ('Doc Watson','doc-watson','Deep River Blues','deep-river-blues','Doc Watson',1964),
    ('Robert Johnson','robert-johnson','Come On in My Kitchen','come-on-in-my-kitchen','King of the Delta Blues Singers',1936),
    ('Sam Cooke','sam-cooke','A Change Is Gonna Come','a-change-is-gonna-come','Ain''t That Good News',1964),
    ('The Impressions','the-impressions','People Get Ready','people-get-ready','People Get Ready',1965),
    ('The Staple Singers','the-staple-singers','I''ll Take You There','ill-take-you-there','Be Altitude: Respect Yourself',1972),
    ('Bill Withers','bill-withers','Use Me','use-me','Still Bill',1972),
    ('Bill Withers','bill-withers','Grandma''s Hands','grandmas-hands','Just As I Am',1971),
    ('Sam & Dave','sam-and-dave','Soul Man','soul-man','Soul Men',1967),
    ('Marvin Gaye','marvin-gaye','Let''s Get It On','lets-get-it-on','Let''s Get It On',1973),
    ('Keb'' Mo''','keb-mo','Am I Wrong','am-i-wrong','Keb'' Mo''',1994),
    ('Taj Mahal','taj-mahal','Fishin'' Blues','fishin-blues','De Ole Folks at Home',1969),
    ('Bobby Helms','bobby-helms','Jingle Bell Rock','jingle-bell-rock','Jingle Bell Rock',1957),
    ('Chuck Berry','chuck-berry','Run Rudolph Run','run-rudolph-run','Run Rudolph Run',1958),
    ('Elvis Presley','elvis-presley','Blue Christmas','blue-christmas','Elvis'' Christmas Album',1957),
    ('Jose Feliciano','jose-feliciano','Feliz Navidad','feliz-navidad','Feliz Navidad',1970),
    ('Wham!','wham','Last Christmas','last-christmas','Last Christmas',1984),
    ('Brenda Lee','brenda-lee','Rockin'' Around the Christmas Tree','rockin-around-the-christmas-tree','Rockin'' Around the Christmas Tree',1958),
    ('Trans-Siberian Orchestra','trans-siberian-orchestra','Christmas Eve / Sarajevo 12/24','christmas-eve-sarajevo','Christmas Eve and Other Stories',1996)
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
    ('son-house','death-letter'),('skip-james','hard-time-killing-floor-blues'),('mississippi-john-hurt','spike-driver-blues'),
    ('lead-belly','where-did-you-sleep-last-night'),('lightnin-hopkins','mojo-hand'),('big-bill-broonzy','key-to-the-highway'),
    ('elizabeth-cotten','freight-train'),('doc-watson','deep-river-blues'),('robert-johnson','come-on-in-my-kitchen'),
    ('sam-cooke','a-change-is-gonna-come'),('the-impressions','people-get-ready'),('the-staple-singers','ill-take-you-there'),
    ('bill-withers','use-me'),('bill-withers','grandmas-hands'),('sam-and-dave','soul-man'),('marvin-gaye','lets-get-it-on'),
    ('keb-mo','am-i-wrong'),('taj-mahal','fishin-blues'),('bobby-helms','jingle-bell-rock'),('chuck-berry','run-rudolph-run'),
    ('elvis-presley','blue-christmas'),('jose-feliciano','feliz-navidad'),('wham','last-christmas'),
    ('brenda-lee','rockin-around-the-christmas-tree'),('trans-siberian-orchestra','christmas-eve-sarajevo')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('son-house','death-letter'),('skip-james','hard-time-killing-floor-blues'),('mississippi-john-hurt','spike-driver-blues'),
    ('lead-belly','where-did-you-sleep-last-night'),('lightnin-hopkins','mojo-hand'),('big-bill-broonzy','key-to-the-highway'),
    ('elizabeth-cotten','freight-train'),('doc-watson','deep-river-blues'),('robert-johnson','come-on-in-my-kitchen'),
    ('sam-cooke','a-change-is-gonna-come'),('the-impressions','people-get-ready'),('the-staple-singers','ill-take-you-there'),
    ('bill-withers','use-me'),('bill-withers','grandmas-hands'),('sam-and-dave','soul-man'),('marvin-gaye','lets-get-it-on'),
    ('keb-mo','am-i-wrong'),('taj-mahal','fishin-blues'),('bobby-helms','jingle-bell-rock'),('chuck-berry','run-rudolph-run'),
    ('elvis-presley','blue-christmas'),('jose-feliciano','feliz-navidad'),('wham','last-christmas'),
    ('brenda-lee','rockin-around-the-christmas-tree'),('trans-siberian-orchestra','christmas-eve-sarajevo')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('son-house','death-letter'),('skip-james','hard-time-killing-floor-blues'),('mississippi-john-hurt','spike-driver-blues'),
    ('lead-belly','where-did-you-sleep-last-night'),('lightnin-hopkins','mojo-hand'),('big-bill-broonzy','key-to-the-highway'),
    ('elizabeth-cotten','freight-train'),('doc-watson','deep-river-blues'),('robert-johnson','come-on-in-my-kitchen'),
    ('sam-cooke','a-change-is-gonna-come'),('the-impressions','people-get-ready'),('the-staple-singers','ill-take-you-there'),
    ('bill-withers','use-me'),('bill-withers','grandmas-hands'),('sam-and-dave','soul-man'),('marvin-gaye','lets-get-it-on'),
    ('keb-mo','am-i-wrong'),('taj-mahal','fishin-blues'),('bobby-helms','jingle-bell-rock'),('chuck-berry','run-rudolph-run'),
    ('elvis-presley','blue-christmas'),('jose-feliciano','feliz-navidad'),('wham','last-christmas'),
    ('brenda-lee','rockin-around-the-christmas-tree'),('trans-siberian-orchestra','christmas-eve-sarajevo')
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
    -- ============ DELTA / COUNTRY BLUES ROOTS ============
    ('death-letter','son-house','guitar','riff','slide resonator','acoustic','delta blues','rhythm','intermediate',
     'National resonator (Son House)','Acoustic resonator — mic''d','No cab (resonator)','n/a (resonator)',
     '[]'::jsonb,'{"gain":0,"bass":6,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['The delta thunderclap — House''s slashing open-G slide on steel resonator.','Metallic dry resonator; violence and grief in every rake.'],
     array['Open G with a slide; strike the strings like judgment.','The rhythm stomps — your foot is the drummer.'],
     'Studio recording, 1965. House''s slashing resonator thunder.',78),
    ('hard-time-killing-floor-blues','skip-james','guitar','main','fingerpicked lament','acoustic','delta blues','rhythm','advanced',
     'Acoustic guitar (Skip James)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":1,"delay":0,"master":5}'::jsonb,
     array['The ghost-tuning lament (heard in O Brother) — James'' eerie D-minor "Bentonia" tuning fingerpicking.','Dry haunted acoustic; the open-Dm tuning is the sorrow.'],
     array['Open D minor tuning (DADFAD).','Pick it sparse and let the minor drones moan.'],
     'Studio recording, 1964 (orig. 1931). The Bentonia ghost-tuning lament.',78),
    ('spike-driver-blues','mississippi-john-hurt','guitar','main','syncopated fingerpicking','acoustic','country blues','rhythm','intermediate',
     'Acoustic guitar (Mississippi John Hurt)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['The gentlest blues ever — Hurt''s rolling syncopated thumb-picking, warm as a porch.','Soft dry acoustic; the alternating thumb never stops.'],
     array['Steady alternating bass under the syncopated melody.','Smile while you play — Hurt always did.'],
     'Studio recording, 1963. Hurt''s porch-warm thumb-picking.',79),
    ('where-did-you-sleep-last-night','lead-belly','guitar','main','12-string strums','acoustic','folk blues','rhythm','beginner',
     'Stella 12-string (Lead Belly)','Acoustic — recorded direct to disc','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['In the pines, where the sun don''t ever shine — Lead Belly''s booming 12-string dirge (the song Nirvana ended Unplugged with).','Huge low-tuned 12-string; dread in E minor.'],
     array['Slow heavy strums; the shiver is the tempo.','Nirvana''s Unplugged version maps straight onto this.'],
     'Recording, 1944. The pines dirge on booming 12-string.',79),
    ('mojo-hand','lightnin-hopkins','guitar','riff','boogie fingerpicking','acoustic','texas blues','rhythm','intermediate',
     'Acoustic/electric guitar (Lightnin'' Hopkins)','Small amp or mic''d acoustic, dry','Small combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":6,"mids":6,"treble":5,"presence":4,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['The Houston hypnosis — Hopkins'' one-chord thumb-boogie with stinging treble fills.','Dry warm tone; thumb drives the boogie, fingers sting the answers.'],
     array['The thumb never stops the E boogie.','Answer your own lines — it''s a conversation with yourself.'],
     'Studio recording, 1960. Hopkins'' one-chord hypnosis.',77),
    ('key-to-the-highway','big-bill-broonzy','guitar','main','eight-bar blues picking','acoustic','blues','rhythm','intermediate',
     'Acoustic guitar (Big Bill Broonzy)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['The eight-bar standard everyone from Clapton to Derek covers — Broonzy''s ragtime-touched original.','Warm articulate acoustic; the turnarounds swing.'],
     array['Eight bars, not twelve — learn the form.','Broonzy''s bass runs connect every change.'],
     'Studio recording, 1941. The eight-bar highway standard.',78),
    ('freight-train','elizabeth-cotten','guitar','main','left-handed travis picking','acoustic','folk','rhythm','intermediate',
     'Acoustic guitar, played left-handed upside down (Elizabeth Cotten)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['The fingerpicking rite of passage — written at 11, played upside-down and left-handed, copied by everyone forever.','Clear gentle acoustic; "Cotten picking" alternates bass with the thumb on TREBLE strings.'],
     array['Standard players: alternate thumb bass, melody on top.','The tune every fingerstyle teacher assigns first.'],
     'Studio recording, 1958. The upside-down fingerpicking rite of passage.',80),
    ('deep-river-blues','doc-watson','guitar','main','travis-picked showpiece','acoustic','country blues','lead','advanced',
     'Martin dreadnought (Doc Watson)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Doc''s travis-picking calling card — the Delmore Brothers tune turned flat-top masterclass.','Clear powerful dreadnought; the picking rolls like the river.'],
     array['Travis pattern with moving chord shapes — the E7 stretch is the test.','Doc played it effortless; get there slowly.'],
     'Studio recording, 1964. Doc''s travis-picking calling card.',79),
    ('come-on-in-my-kitchen','robert-johnson','guitar','main','slide lament','acoustic','delta blues','rhythm','advanced',
     'Gibson L-1 acoustic (Robert Johnson)','Acoustic — hotel-room recording','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":5}'::jsonb,
     array['The saddest slide in the canon — Johnson''s open-tuning moan following his voice note for note.','Dry 1936 intimacy; slide and voice as one.'],
     array['Open A/G tuning; the slide mirrors the vocal exactly.','The hushed passage — "can''t you hear the wind howl?" — is the lesson in dynamics.'],
     'Studio recording, 1936. Johnson''s slide-and-voice lament.',79),

    -- ============ SOUL STANDARDS ============
    ('a-change-is-gonna-come','sam-cooke','guitar','main','orchestral soul accompaniment','clean','soul','rhythm','beginner',
     'Hollow-body electric (session)','Clean amp under orchestra','Small combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"studio plate","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":1,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":3,"delay":0,"master":5}'::jsonb,
     array['The civil-rights hymn — gentle guitar inside the orchestral swell.','Warm unobtrusive clean; the song carries history.'],
     array['Comp softly under the strings.','It''s been a long time coming — play it with that weight.'],
     'Studio recording, 1964. The civil-rights hymn.',77),
    ('people-get-ready','the-impressions','guitar','riff','gospel soul figures','clean','soul','rhythm','intermediate',
     'Fender Stratocaster (Curtis Mayfield)','Clean amp, gospel warmth','Fender combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"spring reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":1,"bass":5,"mids":6,"treble":5,"presence":4,"reverb":3,"delay":0,"master":5}'::jsonb,
     array['Curtis''s open-F# tuning gospel — the train-to-Jordan figures that taught Hendrix.','Soft warm clean; Mayfield tuned to F# major open — his voicings float.'],
     array['Standard tuning works with careful voicings; his open tuning explains the sound.','The figures answer the harmony like a fourth voice.'],
     'Studio recording, 1965. Mayfield''s open-tuning gospel train.',79),
    ('ill-take-you-there','the-staple-singers','guitar','riff','muscle shoals groove','clean','soul','rhythm','intermediate',
     'Fender Telecaster (Eddie Hinton — Muscle Shoals)','Fender tube amp, tight funk clean','Fender combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The Muscle Shoals invitation — sparse funk chips over THAT bassline.','Tight dry clean; the groove is a group effort — play small.'],
     array['Chip the chords on the off-beats.','Pops Staples'' tremolo fills float above — add them sparingly.'],
     'Studio recording, 1972. The Muscle Shoals invitation groove.',78),
    ('use-me','bill-withers','guitar','riff','clav-funk guitar','clean','soul','rhythm','intermediate',
     'Electric guitar (Benorce Blackmon)','Clean amp, sinewy funk','Small combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['The sinewy funk confession — guitar snakes around the clavinet riff.','Dry wiry clean; the pocket is everything.'],
     array['Lock with the clav; ghost the sixteenths.','Until you use me up — keep the groove that committed.'],
     'Studio recording, 1972. The sinewy clav-funk confession.',77),
    ('grandmas-hands','bill-withers','guitar','main','soul-folk figures','clean','soul','rhythm','beginner',
     'Electric guitar (session)','Clean amp, warm and bare','Small combo cab','neck pickup',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":5,"presence":4,"reverb":2,"delay":0,"master":5}'::jsonb,
     array['The two-minute memorial — bare warm figures under Withers'' memory.','Round soft clean; church-pew intimacy.'],
     array['The blues-gospel figure repeats like a rocking chair.','Two minutes; make each one count.'],
     'Studio recording, 1971. The rocking-chair memorial.',77),
    ('soul-man','sam-and-dave','guitar','riff','stax stabs + slide-up','clean','soul','rhythm','beginner',
     'Fender Telecaster (Steve Cropper)','Fender tube amp, biting Stax clean','Fender combo cab','bridge single-coil',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['"Play it, Steve!" — Cropper''s slide-up intro licks and backbeat stabs.','Bright cutting Tele; the slides announce every verse.'],
     array['Slide into the double-stops with a match... or a slide.','Stab the backbeats dry.'],
     'Studio recording, 1967. Play it, Steve.',80),
    ('lets-get-it-on','marvin-gaye','guitar','riff','wah soul intro','clean','soul','rhythm','beginner',
     'Electric guitar (Melvin "Wah Wah Watson" Ragin school)','Clean amp with wah','Small combo cab','neck pickup',
     '[{"effect_type":"wah","effect_name":"slow wah sweep","placement":"front","settings":{"position":5}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":6,"treble":5,"presence":4,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The four-note invitation — the wah-kissed intro everyone recognizes in one bar.','Warm clean with slow wah; the intro figure IS the mood.'],
     array['The opening lick: slow wah, full commitment.','Comp gently after; the song does the rest.'],
     'Studio recording, 1973. The four-note wah invitation.',78),

    -- ============ MODERN ACOUSTIC BLUES ============
    ('am-i-wrong','keb-mo','guitar','main','resonator blues','acoustic','blues','rhythm','intermediate',
     'National resonator (Keb'' Mo'')','Acoustic resonator — mic''d','No cab (resonator)','n/a (resonator)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The modern-delta calling card — driving resonator groove with slide accents.','Bright metallic resonator; old form, modern polish.'],
     array['Drive the groove with the thumb.','Slide fills answer the vocal hooks.'],
     'Studio recording, 1994. The modern-delta calling card.',77),
    ('fishin-blues','taj-mahal','guitar','main','ragtime fingerpicking','acoustic','blues','rhythm','intermediate',
     'Acoustic guitar (Taj Mahal)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['The sunniest blues — Taj''s ragtime picking about going fishing.','Warm bouncing acoustic; pure porch joy.'],
     array['Rag the pattern with a lazy bounce.','Anybody can catch this groove if they try.'],
     'Studio recording, 1969. The sunny fishing rag.',77),

    -- ============ CHRISTMAS GUITAR CANON ============
    ('jingle-bell-rock','bobby-helms','guitar','riff','main riff + solo','clean','holiday','lead','beginner',
     'Gibson/Gretsch electric (Hank Garland)','Tube amp, warm 50s clean','Small combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"studio plate","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The most-played guitar intro every December — Hank Garland''s jazzy chimes.','Warm round 50s clean; the intro chord-melody is the whole assignment.'],
     array['The intro figure mixes chords and single notes — learn it exact.','The solo swings politely; keep the eggnog energy.'],
     'Studio recording, 1957. Garland''s eternal December intro.',79),
    ('run-rudolph-run','chuck-berry','guitar','riff','berry boogie','crunch','holiday','rhythm','beginner',
     'Gibson ES-350T (Chuck Berry)','Tube amp, edge of breakup','Small combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['Johnny B. Goode in a sleigh — Berry''s double-stop boogie with reindeer.','Bright just-driven hollow-body; the intro is pure Chuck.'],
     array['The double-stop intro bends — Berry vocabulary 101.','Boogie the rhythm like it''s any other Saturday night.'],
     'Studio recording, 1958. Berry''s reindeer boogie.',78),
    ('blue-christmas','elvis-presley','guitar','riff','tic-toc figures','clean','holiday','rhythm','beginner',
     'Gibson Super 400 (Scotty Moore)','Small tube amp with slapback','Small combo cab','neck pickup',
     '[{"effect_type":"delay","effect_name":"tape slapback","placement":"post_gain","settings":{"time":1,"mix":3,"feedback":1}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":2,"master":6}'::jsonb,
     array['The lonesome Elvis December — Scotty''s tic-toc triplet figures with slapback.','Warm slapback clean; the triplet chime answers every line.'],
     array['The descending triplet figure is the hook.','Sway it slow — it''s a blue, blue Christmas.'],
     'Studio recording, 1957. Scotty''s tic-toc December.',78),
    ('feliz-navidad','jose-feliciano','guitar','main','nylon strums + riff','acoustic','holiday','rhythm','beginner',
     'Nylon-string classical (Jose Feliciano)','Acoustic — mic''d','No cab (classical)','n/a (classical)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The bilingual joy machine — Feliciano''s bright nylon strums and the singalong riff.','Crisp nylon attack; happiness in D major.'],
     array['Strum the pattern with flamenco-adjacent snap.','From the bottom of your heart — that''s the dynamic marking.'],
     'Studio recording, 1970. The bilingual nylon joy machine.',78),
    ('last-christmas','wham','guitar','main','acoustic arrangement','acoustic','holiday','rhythm','beginner',
     'Acoustic guitar (standard arrangement)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Synth-pop original — profiled as the acoustic-chords arrangement everyone actually plays each December.','Warm gentle strums; four chords of heartbreak tinsel.'],
     array['D-Bm-Em-A around the loop.','Gave you my heart; give it steady eighth-note strums.'],
     'Studio recording, 1984. Synth original; profiled as the December chords arrangement.',74),
    ('rockin-around-the-christmas-tree','brenda-lee','guitar','riff','rockabilly comping + solo','clean','holiday','rhythm','beginner',
     'Gibson electric (Hank Garland)','Tube amp, rockabilly clean','Small combo cab','bridge pickup',
     '[{"effect_type":"delay","effect_name":"light slapback","placement":"post_gain","settings":{"time":1,"mix":2,"feedback":1}}]'::jsonb,
     '{"gain":3,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":2,"master":6}'::jsonb,
     array['Garland again — rockabilly comping and a wink of a solo under 13-year-old Brenda.','Bright snappy clean with slapback; sock-hop swing.'],
     array['Comp the swing pattern crisp.','The little solo swings — sentimental AND sharp.'],
     'Studio recording, 1958. Garland''s sock-hop Christmas.',78),
    ('christmas-eve-sarajevo','trans-siberian-orchestra','guitar','lead','carol shred medley','high_gain','holiday','lead','advanced',
     'Solid-body electric (Al Pitrelli / Chris Caffery)','High-gain stack with orchestra','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"delay","effect_name":"lead delay","placement":"post_gain","settings":{"time":3,"mix":2,"feedback":2}},{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":4,"delay":2,"master":8}'::jsonb,
     array['Carol of the Bells goes metal — soaring saturated leads dueling the orchestra.','Singing high gain with hall; precision carols at arena volume.'],
     array['The Carol of the Bells motif must be metronome-exact.','Trade with the strings; crescendo forever.'],
     'Studio recording, 1996. The metal Carol of the Bells.',77)
) as c(
  song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence
)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;
