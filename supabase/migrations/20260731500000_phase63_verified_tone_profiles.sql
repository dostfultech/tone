-- Phase 63: power-ballad canon + iconic screen themes, verified per-part tone data.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Guns N'' Roses','guns-n-roses','November Rain','november-rain','Use Your Illusion I',1991),
    ('Guns N'' Roses','guns-n-roses','Don''t Cry','dont-cry','Use Your Illusion I',1991),
    ('Guns N'' Roses','guns-n-roses','Civil War','civil-war','Use Your Illusion II',1991),
    ('Guns N'' Roses','guns-n-roses','Estranged','estranged','Use Your Illusion II',1991),
    ('Bon Jovi','bon-jovi','Always','always','Cross Road',1994),
    ('Bon Jovi','bon-jovi','Bed of Roses','bed-of-roses','Keep the Faith',1992),
    ('White Lion','white-lion','When the Children Cry','when-the-children-cry','Pride',1987),
    ('Tesla','tesla','Love Song','love-song','The Great Radio Controversy',1989),
    ('FireHouse','firehouse','Love of a Lifetime','love-of-a-lifetime','FireHouse',1990),
    ('Slaughter','slaughter','Fly to the Angels','fly-to-the-angels','Stick It to Ya',1990),
    ('Skid Row','skid-row','I Remember You','i-remember-you','Skid Row',1989),
    ('Cinderella','cinderella','Don''t Know What You Got (Till It''s Gone)','dont-know-what-you-got-till-its-gone','Long Cold Winter',1988),
    ('Ozzy Osbourne','ozzy-osbourne','Mama, I''m Coming Home','mama-im-coming-home','No More Tears',1991),
    ('Aerosmith','aerosmith','I Don''t Want to Miss a Thing','i-dont-want-to-miss-a-thing','Armageddon: The Album',1998),
    ('Nazareth','nazareth','Love Hurts','love-hurts','Hair of the Dog',1975),
    ('Scorpions','scorpions','Still Loving You','still-loving-you','Love at First Sting',1984),
    ('Scorpions','scorpions','Wind of Change','wind-of-change','Crazy World',1990),
    ('Steve Stevens','steve-stevens','Top Gun Anthem','top-gun-anthem','Top Gun (Original Motion Picture Soundtrack)',1986),
    ('John Barry','john-barry','The James Bond Theme','the-james-bond-theme','Dr. No',1962),
    ('Gustavo Santaolalla','gustavo-santaolalla','The Last of Us (Main Theme)','the-last-of-us-main-theme','The Last of Us',2013),
    ('Nick Cave & The Bad Seeds','nick-cave-and-the-bad-seeds','Red Right Hand','red-right-hand','Let Love In',1994),
    ('The Handsome Family','the-handsome-family','Far From Any Road','far-from-any-road','Singing Bones',2003),
    ('Angelo Badalamenti','angelo-badalamenti','Falling (Twin Peaks Theme)','falling-twin-peaks-theme','Twin Peaks',1990),
    ('Ramin Djawadi','ramin-djawadi','Game of Thrones (Main Title)','game-of-thrones-main-title','Game of Thrones',2011),
    ('The Ventures','the-ventures','Hawaii Five-O','hawaii-five-o','Hawaii Five-O',1969)
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
    ('guns-n-roses','november-rain'),('guns-n-roses','dont-cry'),('guns-n-roses','civil-war'),('guns-n-roses','estranged'),
    ('bon-jovi','always'),('bon-jovi','bed-of-roses'),('white-lion','when-the-children-cry'),('tesla','love-song'),
    ('firehouse','love-of-a-lifetime'),('slaughter','fly-to-the-angels'),('skid-row','i-remember-you'),
    ('cinderella','dont-know-what-you-got-till-its-gone'),('ozzy-osbourne','mama-im-coming-home'),
    ('aerosmith','i-dont-want-to-miss-a-thing'),('nazareth','love-hurts'),('scorpions','still-loving-you'),
    ('scorpions','wind-of-change'),('steve-stevens','top-gun-anthem'),('john-barry','the-james-bond-theme'),
    ('gustavo-santaolalla','the-last-of-us-main-theme'),('nick-cave-and-the-bad-seeds','red-right-hand'),
    ('the-handsome-family','far-from-any-road'),('angelo-badalamenti','falling-twin-peaks-theme'),
    ('ramin-djawadi','game-of-thrones-main-title'),('the-ventures','hawaii-five-o')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('guns-n-roses','november-rain'),('guns-n-roses','dont-cry'),('guns-n-roses','civil-war'),('guns-n-roses','estranged'),
    ('bon-jovi','always'),('bon-jovi','bed-of-roses'),('white-lion','when-the-children-cry'),('tesla','love-song'),
    ('firehouse','love-of-a-lifetime'),('slaughter','fly-to-the-angels'),('skid-row','i-remember-you'),
    ('cinderella','dont-know-what-you-got-till-its-gone'),('ozzy-osbourne','mama-im-coming-home'),
    ('aerosmith','i-dont-want-to-miss-a-thing'),('nazareth','love-hurts'),('scorpions','still-loving-you'),
    ('scorpions','wind-of-change'),('steve-stevens','top-gun-anthem'),('john-barry','the-james-bond-theme'),
    ('gustavo-santaolalla','the-last-of-us-main-theme'),('nick-cave-and-the-bad-seeds','red-right-hand'),
    ('the-handsome-family','far-from-any-road'),('angelo-badalamenti','falling-twin-peaks-theme'),
    ('ramin-djawadi','game-of-thrones-main-title'),('the-ventures','hawaii-five-o')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('guns-n-roses','november-rain'),('guns-n-roses','dont-cry'),('guns-n-roses','civil-war'),('guns-n-roses','estranged'),
    ('bon-jovi','always'),('bon-jovi','bed-of-roses'),('white-lion','when-the-children-cry'),('tesla','love-song'),
    ('firehouse','love-of-a-lifetime'),('slaughter','fly-to-the-angels'),('skid-row','i-remember-you'),
    ('cinderella','dont-know-what-you-got-till-its-gone'),('ozzy-osbourne','mama-im-coming-home'),
    ('aerosmith','i-dont-want-to-miss-a-thing'),('nazareth','love-hurts'),('scorpions','still-loving-you'),
    ('scorpions','wind-of-change'),('steve-stevens','top-gun-anthem'),('john-barry','the-james-bond-theme'),
    ('gustavo-santaolalla','the-last-of-us-main-theme'),('nick-cave-and-the-bad-seeds','red-right-hand'),
    ('the-handsome-family','far-from-any-road'),('angelo-badalamenti','falling-twin-peaks-theme'),
    ('ramin-djawadi','game-of-thrones-main-title'),('the-ventures','hawaii-five-o')
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
    -- ============ GN'R ILLUSION ERA (Slash: Les Paul + AFD Marshall) ============
    ('november-rain','guns-n-roses','guitar','solo','outro solo','high_gain','rock','lead','advanced',
     'Gibson Les Paul (Slash)','Marshall modified tube stack','Marshall 4x12 cab','bridge humbucker (Alnico II)',
     '[{"effect_type":"delay","effect_name":"studio lead delay","placement":"post_gain","settings":{"time":3,"mix":2,"feedback":2}}]'::jsonb,
     '{"gain":7,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":3,"delay":2,"master":7}'::jsonb,
     array['The church-front solo — Slash''s singing mid-heavy Marshall lead at maximum emotion.','Thick sustaining lead voice; mids pushed hard, never scooped.'],
     array['Both solos are melodies first — sing every bend.','Wide vibrato and full-value notes; nothing rushed.'],
     'Studio recording, 1991. Slash''s epic wedding-chapel leads.',82),
    ('dont-cry','guns-n-roses','guitar','riff','clean verse + solo','clean','rock','lead','intermediate',
     'Gibson Les Paul (Slash / Izzy Stradlin)','Marshall tube stack, clean to lead','Marshall 4x12 cab','bridge humbucker',
     '[{"effect_type":"reverb","effect_name":"studio plate reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":1,"master":6}'::jsonb,
     array['Warm clean arpeggios under the verse (settings shown); the solo pushes to singing lead gain (7).','Two voices: patient clean, aching lead.'],
     array['Arpeggiate the verse changes evenly.','The solo is one long vocal phrase.'],
     'Studio recording, 1991. Clean-verse-to-crying-solo ballad.',81),
    ('civil-war','guns-n-roses','guitar','riff','clean intro + heavy build','clean','rock','rhythm','intermediate',
     'Gibson Les Paul (Slash)','Marshall tube stack, clean to driven','Marshall 4x12 cab','neck pickup (intro)',
     '[{"effect_type":"wah","effect_name":"Dunlop wah (solo)","placement":"front","settings":{"position":6}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The whistled intro rides gentle clean picking; the song builds to full Marshall drive (gain 7) with wah leads.','Program clean and lead; the seven-minute arc earns both.'],
     array['The intro figure is delicate — neck pickup, soft touch.','The wah solo cries; rock it slowly.'],
     'Studio recording, 1991. The clean-to-wah-lead protest epic.',80),
    ('estranged','guns-n-roses','guitar','solo','lead themes','high_gain','rock','lead','advanced',
     'Gibson Les Paul (Slash)','Marshall modified tube stack','Marshall 4x12 cab','bridge humbucker',
     '[{"effect_type":"delay","effect_name":"studio lead delay","placement":"post_gain","settings":{"time":3,"mix":2,"feedback":2}}]'::jsonb,
     '{"gain":7,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":3,"delay":2,"master":7}'::jsonb,
     array['Slash''s nine-minute lead odyssey — recurring singing themes over shifting movements.','Same mid-rich sustaining Marshall voice; the themes recur like characters.'],
     array['Learn the recurring lead theme first — it anchors everything.','Patience across the movements; this is a suite.'],
     'Studio recording, 1991. The nine-minute lead odyssey.',81),

    -- ============ POWER BALLAD CANON ============
    ('always','bon-jovi','guitar','riff','clean verse + big chorus','clean','rock','rhythm','beginner',
     'Solid-body electric (Richie Sambora)','Tube amp, clean to driven','Closed-back cab','bridge humbucker',
     '[{"effect_type":"chorus","effect_name":"80s chorus gloss","placement":"post_gain","settings":{"rate":3,"depth":4,"mix":4}},{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":4,"delay":1,"master":6}'::jsonb,
     array['The mega-ballad — glossy chorused clean verses into a soaring driven chorus (gain 6) and crying solo.','Big-hair production: chorus, hall, heart on sleeve.'],
     array['Arpeggiate the verses with the chorus pedal.','The solo bends want maximum drama.'],
     'Studio recording, 1994. The glossy mega-ballad.',77),
    ('bed-of-roses','bon-jovi','guitar','riff','clean arpeggios + solo','clean','rock','lead','intermediate',
     'Solid-body electric (Richie Sambora)','Tube amp with chorus and hall','Closed-back cab','neck pickup',
     '[{"effect_type":"chorus","effect_name":"lush chorus","placement":"post_gain","settings":{"rate":3,"depth":4,"mix":4}},{"effect_type":"reverb","effect_name":"large hall","placement":"post_gain","settings":{"mix":5}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":5,"delay":1,"master":6}'::jsonb,
     array['Piano-led ballad with Sambora''s lush clean arpeggios and a soaring lead (gain 6 for the solo).','Wet 90s ballad clean; the lead sings over everything.'],
     array['Support the piano with arpeggiated color.','Phrase the solo like the second vocalist.'],
     'Studio recording, 1992. Sambora''s lush ballad voice.',76),
    ('when-the-children-cry','white-lion','guitar','main','fingerpicked ballad','clean','hair metal','lead','advanced',
     'Solid-body electric (Vito Bratta)','Clean amp, glassy and compressed','Open-back combo cab','neck pickup',
     '[{"effect_type":"compressor","effect_name":"studio compression","placement":"front","settings":{"sustain":5,"level":5}},{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":7,"presence":5,"reverb":4,"delay":0,"master":6}'::jsonb,
     array['Vito Bratta''s fingerpicked masterpiece — classical-tinged clean electric picking.','Glassy compressed clean; the picking is intricate and exact.'],
     array['The fingerpicked figure blends bass and melody — learn it slowly.','The brief solo is tasteful fire; keep its restraint.'],
     'Studio recording, 1987. Bratta''s fingerpicked ballad clinic.',78),
    ('love-song','tesla','guitar','riff','acoustic intro + electric build','acoustic','hair metal','rhythm','intermediate',
     'Acoustic + Gibson electric (Frank Hannon / Tommy Skeoch)','Tube amp for the electric build','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The classical acoustic prelude opens it; the band arrives in warm driven glory (electric sections: gain 6).','Two acts: nylon-flavored acoustic intro, soaring Marshall payoff.'],
     array['The intro is genuinely classical — fingerpick it clean.','The outro solo climbs forever; enjoy the ride.'],
     'Studio recording, 1989. The classical-intro arena ballad.',77),
    ('love-of-a-lifetime','firehouse','guitar','riff','clean verse + big chorus','clean','hair metal','rhythm','beginner',
     'Solid-body electric (Bill Leverty)','Tube amp with 80s gloss','Closed-back cab','bridge humbucker',
     '[{"effect_type":"chorus","effect_name":"80s chorus","placement":"post_gain","settings":{"rate":3,"depth":4,"mix":4}},{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":4,"delay":1,"master":6}'::jsonb,
     array['The wedding-band staple — chorused clean arpeggios into a glossy driven chorus (gain 6).','Peak 1990 ballad production; shameless and lovely.'],
     array['Arpeggiate the verse in wide voicings.','The key-change chorus wants full commitment.'],
     'Studio recording, 1990. The wedding-band ballad staple.',75),
    ('fly-to-the-angels','slaughter','guitar','riff','clean verse + soaring chorus','clean','hair metal','rhythm','intermediate',
     'Solid-body electric (Tim Kelly)','Tube amp with gloss','Closed-back cab','bridge humbucker',
     '[{"effect_type":"chorus","effect_name":"80s chorus","placement":"post_gain","settings":{"rate":3,"depth":4,"mix":4}},{"effect_type":"reverb","effect_name":"large hall","placement":"post_gain","settings":{"mix":5}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":5,"delay":1,"master":6}'::jsonb,
     array['The farewell ballad — wet chorused cleans into a soaring driven chorus (gain 6).','Big-hall 1990 production; grief with hairspray.'],
     array['Pick the verse figure gently.','Send the chorus skyward.'],
     'Studio recording, 1990. The soaring farewell ballad.',74),
    ('i-remember-you','skid-row','guitar','riff','clean verse + solo','clean','hair metal','lead','intermediate',
     'Solid-body electric (Dave Sabo / Scotti Hill)','Tube amp, clean to lead','Closed-back cab','neck pickup',
     '[{"effect_type":"chorus","effect_name":"light chorus","placement":"post_gain","settings":{"rate":3,"depth":3,"mix":3}},{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":4,"delay":1,"master":6}'::jsonb,
     array['The yearbook-quote ballad — chiming clean arpeggios and a screaming climax solo (gain 7).','From whisper to wail; both tones matter.'],
     array['The intro arpeggio figure is the memory.','The final solo screams what the verses whispered.'],
     'Studio recording, 1989. The yearbook ballad with the screaming climax.',77),
    ('dont-know-what-you-got-till-its-gone','cinderella','guitar','riff','piano ballad + slide solo','clean','hair metal','lead','intermediate',
     'Gibson electric (Tom Keifer)','Tube amp, bluesy lead voice','Closed-back cab','bridge humbucker',
     '[{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":4,"delay":1,"master":6}'::jsonb,
     array['Keifer''s bluesy heartbreak — piano-led with crying guitar answers and a soaring solo (gain 6).','Warm bluesy lead voice; the guitar weeps between vocal lines.'],
     array['Answer the piano with short blues cries.','The solo builds from moan to wail.'],
     'Studio recording, 1988. Keifer''s bluesy piano-ballad leads.',77),
    ('mama-im-coming-home','ozzy-osbourne','guitar','riff','clean verse + power chorus','clean','metal','rhythm','beginner',
     'Gibson Les Paul (Zakk Wylde)','Marshall JCM800, clean to driven','Marshall 4x12 cab','EMG bridge humbucker',
     '[{"effect_type":"chorus","effect_name":"light chorus","placement":"post_gain","settings":{"rate":3,"depth":3,"mix":3}}]'::jsonb,
     '{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Zakk''s gentle side — chiming clean verses with pinch-harmonic color, then a driven chorus (gain 6).','Warm Marshall clean into thick drive; Zakk''s squeals decorate even the ballad.'],
     array['The verse figure rings with open strings.','Land the pinch harmonics in the fills.'],
     'Studio recording, 1991. Zakk''s ballad-mode Marshall.',79),
    ('i-dont-want-to-miss-a-thing','aerosmith','guitar','riff','ballad progression + solo','clean','rock','rhythm','beginner',
     'Gibson electric (Joe Perry / Brad Whitford)','Tube amp, orchestral ballad gloss','Closed-back cab','bridge humbucker',
     '[{"effect_type":"reverb","effect_name":"large hall","placement":"post_gain","settings":{"mix":5}}]'::jsonb,
     '{"gain":3,"bass":5,"mids":6,"treble":5,"presence":4,"reverb":5,"delay":1,"master":6}'::jsonb,
     array['The Armageddon mega-ballad — warm supportive chords under the orchestra, with a brief singing solo (gain 6).','Glossy warm tone in service of the strings.'],
     array['Support the orchestra; don''t fight it.','The solo phrase is short and vocal.'],
     'Studio recording, 1998. The asteroid-movie mega-ballad.',76),
    ('love-hurts','nazareth','guitar','riff','ballad progression','crunch','rock','rhythm','beginner',
     'Gibson electric (Manny Charlton)','Tube amp, warm 70s crunch','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":5,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The original power ballad — warm 70s crunch swells under the wail.','Vintage warm drive; no 80s gloss, just ache.'],
     array['Slow arpeggios and swelling chords.','Let the vocal bleed; you''re the bandage.'],
     'Studio recording, 1975. The original power-ballad ache.',77),
    ('still-loving-you','scorpions','guitar','riff','clean build + lead','clean','metal','lead','intermediate',
     'Gibson/Fender electric (Rudolf Schenker / Matthias Jabs)','Marshall tube stack, clean to lead','Marshall 4x12 cab','bridge humbucker',
     '[{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":4,"delay":1,"master":6}'::jsonb,
     array['The six-minute smolder — clean arpeggios building to Jabs'' crying leads (gain 7).','Slow-burn dynamics from whisper to full Marshall wail.'],
     array['The arpeggiated build is patience incarnate.','Jabs'' fills cry between every vocal line.'],
     'Studio recording, 1984. The six-minute smolder ballad.',78),
    ('wind-of-change','scorpions','guitar','riff','clean progression + solo','clean','rock','rhythm','beginner',
     'Electric guitar (Rudolf Schenker / Matthias Jabs)','Clean amp with gloss','Closed-back cab','neck pickup',
     '[{"effect_type":"chorus","effect_name":"light chorus","placement":"post_gain","settings":{"rate":3,"depth":3,"mix":3}},{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":4,"delay":1,"master":6}'::jsonb,
     array['The whistled history-anthem — glossy clean chords and a melodic solo (gain 5).','Soft chorused clean; the whistle carries the hook.'],
     array['Gentle chord work under verses.','The solo sings the melody straight.'],
     'Studio recording, 1990. The Berlin Wall anthem.',77),

    -- ============ SCREEN THEMES ============
    ('top-gun-anthem','steve-stevens','guitar','lead','main melody','high_gain','instrumental rock','lead','intermediate',
     'Hamer custom (Steve Stevens)','Marshall-style stack with studio gloss','Marshall 4x12 cab','bridge humbucker',
     '[{"effect_type":"delay","effect_name":"lead delay","placement":"post_gain","settings":{"time":3,"mix":3,"feedback":3}},{"effect_type":"reverb","effect_name":"large hall","placement":"post_gain","settings":{"mix":5}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":5,"delay":3,"master":7}'::jsonb,
     array['The flight-deck anthem — Stevens'' soaring sustained lead over the synth bed.','Singing saturated lead with big hall; every note held forever.'],
     array['Long sustained bends with slow vibrato.','Play it like the jet is banking.'],
     'Studio recording, 1986. Stevens'' Grammy-winning flight anthem.',80),
    ('the-james-bond-theme','john-barry','guitar','riff','main riff','clean','soundtrack','lead','intermediate',
     'Hollow-body electric (Vic Flick)','Tube combo, biting vintage clean','Open-back combo cab','bridge pickup',
     '[{"effect_type":"reverb","effect_name":"studio plate reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":3,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Vic Flick''s 1962 spy riff — biting hollow-body clean with knife-edge attack.','Trebly vintage clean; the menace is in the pick attack.'],
     array['The chromatic riff creeps — precise and cold.','Hit the stabs like gunshots.'],
     'Studio recording, 1962. Vic Flick''s original spy riff.',79),
    ('the-last-of-us-main-theme','gustavo-santaolalla','guitar','main','fingerpicked theme','acoustic','soundtrack','lead','intermediate',
     'Ronroco / detuned acoustic (Gustavo Santaolalla)','Acoustic — close-mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":6,"mids":5,"treble":5,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Santaolalla''s desolate theme — played on ronroco/detuned acoustic; on guitar, drop the tuning and pick sparsely.','Woody intimate acoustic; the silence between notes is the apocalypse.'],
     array['Sparse arpeggios in a drop tuning.','Every note costs something — place them carefully.'],
     'Studio recording, 2013. Santaolalla''s desolate ronroco theme (guitar-adapted).',77),
    ('red-right-hand','nick-cave-and-the-bad-seeds','guitar','riff','main riff','clean','alternative rock','rhythm','beginner',
     'Hollow-body electric (Mick Harvey / Blixa Bargeld)','Tube combo with tremolo menace','Open-back combo cab','neck pickup',
     '[{"effect_type":"tremolo","effect_name":"amp tremolo","placement":"post_gain","settings":{"rate":4,"depth":5}},{"effect_type":"reverb","effect_name":"dark spring reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":3,"bass":6,"mids":6,"treble":4,"presence":3,"reverb":4,"delay":0,"master":6}'::jsonb,
     array['The Peaky Blinders theme — dark tremolo clean prowling under the organ and bell.','Low, dark, and wet; the menace saunters.'],
     array['The descending riff stalks — behind the beat.','Leave room for the bell toll.'],
     'Studio recording, 1994. The prowling Peaky Blinders theme.',77),
    ('far-from-any-road','the-handsome-family','guitar','main','fingerpicked pattern','acoustic','gothic country','rhythm','intermediate',
     'Acoustic + nylon guitar (Brett Sparks)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The True Detective theme — desert-gothic fingerpicking with mariachi shadows.','Dry dark acoustic; heat-shimmer stillness.'],
     array['The minor picking pattern circles like a vulture.','Duet voices trade — keep the guitar hypnotic.'],
     'Studio recording, 2003. The desert-gothic True Detective theme.',76),
    ('falling-twin-peaks-theme','angelo-badalamenti','guitar','lead','main melody','clean','soundtrack','lead','beginner',
     'Clean electric (guitar arrangement)','Clean amp drowned in reverb, slow tremolo','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"cavernous hall reverb","placement":"post_gain","settings":{"mix":6,"decay":8}},{"effect_type":"tremolo","effect_name":"slow tremolo","placement":"post_gain","settings":{"rate":2,"depth":4}}]'::jsonb,
     '{"gain":1,"bass":6,"mids":5,"treble":4,"presence":3,"reverb":6,"delay":1,"master":6}'::jsonb,
     array['Synth on the record — the beloved guitar arrangement uses dark clean twang in cavernous reverb.','Deep wet clean; dreamy and wrong in the Lynch way.'],
     array['Play the melody on the low strings, slow as fog.','Let the reverb swallow every phrase.'],
     'Studio recording, 1990. The Lynchian dream theme (guitar-adapted).',74),
    ('game-of-thrones-main-title','ramin-djawadi','guitar','main','fingerstyle arrangement','acoustic','soundtrack','lead','intermediate',
     'Acoustic/classical guitar (standard arrangement)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":6,"mids":5,"treble":5,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Cello original — profiled as the popular fingerstyle guitar arrangement.','Dark driving acoustic; the 3/4 gallop carries it.'],
     array['Alternate bass drives the galloping 3/4.','The melody sits on top — keep both voices clear.'],
     'Studio recording, 2011. Cello theme; profiled as the fingerstyle arrangement.',74),
    ('hawaii-five-o','the-ventures','guitar','lead','main melody','clean','surf rock','lead','beginner',
     'Fender Jazzmaster (The Ventures)','Fender tube combo with spring reverb','Fender combo cab','bridge pickup',
     '[{"effect_type":"reverb","effect_name":"spring reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":7,"presence":6,"reverb":4,"delay":0,"master":7}'::jsonb,
     array['The wave-crash TV theme — driving surf twang at full sail.','Bright Fender clean with spring; the horns are in your head anyway.'],
     array['Drive the melody with confident downstrokes.','Book ''em.'],
     'Studio recording, 1969. The wave-crash TV theme.',78)
) as c(
  song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence
)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;
