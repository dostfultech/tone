-- Phase 71: songbook second tier (Beatles deep cuts, Queen/Floyd acoustic side, 60s-70s staples), verified per-part tone data.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('The Beatles','the-beatles','Norwegian Wood (This Bird Has Flown)','norwegian-wood','Rubber Soul',1965),
    ('The Beatles','the-beatles','In My Life','in-my-life','Rubber Soul',1965),
    ('The Beatles','the-beatles','Something','something','Abbey Road',1969),
    ('The Beatles','the-beatles','A Hard Day''s Night','a-hard-days-night','A Hard Day''s Night',1964),
    ('The Beatles','the-beatles','Help!','help','Help!',1965),
    ('The Beatles','the-beatles','Twist and Shout','twist-and-shout','Please Please Me',1963),
    ('The Beatles','the-beatles','Dear Prudence','dear-prudence','The Beatles (White Album)',1968),
    ('The Beatles','the-beatles','Eight Days a Week','eight-days-a-week','Beatles for Sale',1964),
    ('Queen','queen','Love of My Life','love-of-my-life','A Night at the Opera',1975),
    ('Queen','queen','''39','39','A Night at the Opera',1975),
    ('Pink Floyd','pink-floyd','Is There Anybody Out There?','is-there-anybody-out-there','The Wall',1979),
    ('Pink Floyd','pink-floyd','Mother','mother','The Wall',1979),
    ('Eagles','eagles','Peaceful Easy Feeling','peaceful-easy-feeling','Eagles',1972),
    ('Eagles','eagles','Tequila Sunrise','tequila-sunrise','Desperado',1973),
    ('Simon & Garfunkel','simon-and-garfunkel','America','america','Bookends',1968),
    ('Simon & Garfunkel','simon-and-garfunkel','April Come She Will','april-come-she-will','Sounds of Silence',1966),
    ('Fleetwood Mac','fleetwood-mac','Never Going Back Again','never-going-back-again','Rumours',1977),
    ('Bob Seger','bob-seger','Night Moves','night-moves','Night Moves',1976),
    ('Bob Seger','bob-seger','Turn the Page','turn-the-page','Back in ''72',1973),
    ('Van Morrison','van-morrison','Brown Eyed Girl','brown-eyed-girl','Blowin'' Your Mind!',1967),
    ('Van Morrison','van-morrison','Moondance','moondance','Moondance',1970),
    ('Otis Redding','otis-redding','(Sittin'' On) The Dock of the Bay','sittin-on-the-dock-of-the-bay','The Dock of the Bay',1968),
    ('Cat Stevens','cat-stevens','Trouble','trouble','Mona Bone Jakon',1970),
    ('Kenny Loggins','kenny-loggins','Danny''s Song','dannys-song','Sittin'' In',1971),
    ('Ben E. King','ben-e-king','Stand by Me','stand-by-me','Don''t Play That Song!',1961)
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
    ('the-beatles','norwegian-wood'),('the-beatles','in-my-life'),('the-beatles','something'),
    ('the-beatles','a-hard-days-night'),('the-beatles','help'),('the-beatles','twist-and-shout'),
    ('the-beatles','dear-prudence'),('the-beatles','eight-days-a-week'),('queen','love-of-my-life'),('queen','39'),
    ('pink-floyd','is-there-anybody-out-there'),('pink-floyd','mother'),('eagles','peaceful-easy-feeling'),
    ('eagles','tequila-sunrise'),('simon-and-garfunkel','america'),('simon-and-garfunkel','april-come-she-will'),
    ('fleetwood-mac','never-going-back-again'),('bob-seger','night-moves'),('bob-seger','turn-the-page'),
    ('van-morrison','brown-eyed-girl'),('van-morrison','moondance'),('otis-redding','sittin-on-the-dock-of-the-bay'),
    ('cat-stevens','trouble'),('kenny-loggins','dannys-song'),('ben-e-king','stand-by-me')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('the-beatles','norwegian-wood'),('the-beatles','in-my-life'),('the-beatles','something'),
    ('the-beatles','a-hard-days-night'),('the-beatles','help'),('the-beatles','twist-and-shout'),
    ('the-beatles','dear-prudence'),('the-beatles','eight-days-a-week'),('queen','love-of-my-life'),('queen','39'),
    ('pink-floyd','is-there-anybody-out-there'),('pink-floyd','mother'),('eagles','peaceful-easy-feeling'),
    ('eagles','tequila-sunrise'),('simon-and-garfunkel','america'),('simon-and-garfunkel','april-come-she-will'),
    ('fleetwood-mac','never-going-back-again'),('bob-seger','night-moves'),('bob-seger','turn-the-page'),
    ('van-morrison','brown-eyed-girl'),('van-morrison','moondance'),('otis-redding','sittin-on-the-dock-of-the-bay'),
    ('cat-stevens','trouble'),('kenny-loggins','dannys-song'),('ben-e-king','stand-by-me')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('the-beatles','norwegian-wood'),('the-beatles','in-my-life'),('the-beatles','something'),
    ('the-beatles','a-hard-days-night'),('the-beatles','help'),('the-beatles','twist-and-shout'),
    ('the-beatles','dear-prudence'),('the-beatles','eight-days-a-week'),('queen','love-of-my-life'),('queen','39'),
    ('pink-floyd','is-there-anybody-out-there'),('pink-floyd','mother'),('eagles','peaceful-easy-feeling'),
    ('eagles','tequila-sunrise'),('simon-and-garfunkel','america'),('simon-and-garfunkel','april-come-she-will'),
    ('fleetwood-mac','never-going-back-again'),('bob-seger','night-moves'),('bob-seger','turn-the-page'),
    ('van-morrison','brown-eyed-girl'),('van-morrison','moondance'),('otis-redding','sittin-on-the-dock-of-the-bay'),
    ('cat-stevens','trouble'),('kenny-loggins','dannys-song'),('ben-e-king','stand-by-me')
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
    -- ============ BEATLES DEEP CUTS ============
    ('norwegian-wood','the-beatles','guitar','main','acoustic waltz + sitar','acoustic','rock','rhythm','intermediate',
     'Gibson J-160E acoustic (John Lennon)','Acoustic — mic''d with sitar','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The sitar landmark — Lennon''s capo''d waltz strums under Harrison''s drone.','Warm capo''d acoustic in 3/4; the sitar melody adapts to guitar beautifully.'],
     array['Capo II, D-shapes, waltz strum.','Play the sitar line on high strings for the full effect.'],
     'Studio recording, 1965. The capo''d waltz with the first sitar.',80),
    ('in-my-life','the-beatles','guitar','riff','intro riff + comping','clean','rock','rhythm','beginner',
     'Fender Stratocaster/Gibson (George Harrison)','Vox AC30, chiming clean','Vox 2x12 cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":5,"treble":7,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The memory hymn — Harrison''s chiming intro figure and gentle comping.','Bright Vox clean; the intro riff is instantly recognized.'],
     array['The intro double-stop figure opens and closes the song.','Comp softly under the verses; the piano solo is Martin''s.'],
     'Studio recording, 1965. The chiming memory hymn.',80),
    ('something','the-beatles','guitar','riff','main riff + solo','clean','rock','lead','intermediate',
     'Gibson Les Paul "Lucy" (George Harrison)','Leslie-tinged warm clean-crunch','Leslie/Vox cab','bridge humbucker',
     '[{"effect_type":"chorus","effect_name":"Leslie rotary color","placement":"post_gain","settings":{"rate":4,"depth":4,"mix":4}}]'::jsonb,
     '{"gain":3,"bass":5,"mids":6,"treble":5,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Harrison''s masterpiece — the sliding signature riff and one of rock''s most singable solos.','Warm rounded tone with Leslie shimmer; every note deliberate.'],
     array['The five-note riff answers each verse line.','The solo is a composed melody — learn it note for note.'],
     'Studio recording, 1969. Harrison''s sliding masterpiece.',81),
    ('a-hard-days-night','the-beatles','guitar','riff','THE chord + 12-string riffs','clean','rock','rhythm','intermediate',
     'Rickenbacker 360/12 (George Harrison)','Vox AC30, bright jangle','Vox 2x12 cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":5,"treble":8,"presence":6,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Opens with the most-analyzed chord in pop — Rickenbacker 12-string clang plus piano.','Bright 12-string jangle; the arpeggiated outro fades on the same colors.'],
     array['The famous chord: Fadd9 shapes across the band.','Drive the verses with tight jangle strums.'],
     'Studio recording, 1964. THE chord and the 12-string jangle.',80),
    ('help','the-beatles','guitar','riff','strums + descending riff','clean','rock','rhythm','beginner',
     'Gibson J-160E + Rickenbacker (John Lennon / George Harrison)','Vox AC30, bright clean','Vox 2x12 cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":5,"treble":7,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The cry for help at full sprint — driving strums with Harrison''s descending lead cascade.','Bright energetic clean; the descending fills are the hook.'],
     array['Drive the strums; the tempo never rests.','Harrison''s cascading fills tumble into each verse.'],
     'Studio recording, 1965. The sprinting cry for help.',80),
    ('twist-and-shout','the-beatles','guitar','riff','main riff','clean','early rock','rhythm','beginner',
     'Gretsch/Rickenbacker (George Harrison / John Lennon)','Vox amp, edge of breakup','Vox 2x12 cab','bridge pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The throat-shredding closer — D-G-A forever with just-breaking-up edge.','Bright slightly hairy clean; recorded last, sung raw.'],
     array['Three chords and total commitment.','The build-up "aaah" stack is the moment — hold the A.'],
     'Studio recording, 1963. The three-chord throat-shredder.',80),
    ('dear-prudence','the-beatles','guitar','main','travis-picked pattern','acoustic','rock','rhythm','intermediate',
     'Martin D-28 (John Lennon)','Acoustic — close-mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The White Album''s gentle wake-up — Lennon''s travis picking (learned from Donovan in India) over a droning D.','Warm droning acoustic; the pattern descends while the D rings.'],
     array['Travis-pick with the thumb holding the D drone.','The bass walks down; the sun comes up.'],
     'Studio recording, 1968. Lennon''s India-learned travis picking.',80),
    ('eight-days-a-week','the-beatles','guitar','riff','chiming riff + strums','clean','rock','rhythm','beginner',
     'Rickenbacker 360/12 (George Harrison)','Vox AC30, bright jangle','Vox 2x12 cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":5,"treble":8,"presence":6,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Pop''s first fade-IN — chiming 12-string figure into handclap joy.','Bright 12-string jangle; sunshine mechanics.'],
     array['The fading-in intro figure sets the grin.','Strum the D-E-G-D verse brightly.'],
     'Studio recording, 1964. The fade-in jangle joy.',79),

    -- ============ QUEEN / FLOYD ACOUSTIC SIDE ============
    ('love-of-my-life','queen','guitar','main','fingerpicked ballad','acoustic','rock','rhythm','advanced',
     'Nylon + 12-string (Brian May)','Acoustic — mic''d with harp','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Freddie''s tenderest — May''s intricate classical-tinged fingerpicking (the live 12-string version is the one crowds sing).','Delicate layered acoustics; opera-house intimacy.'],
     array['The fingerpicked arrangement is genuinely classical — slow practice.','Live, the crowd sings it back; leave them room.'],
     'Studio recording, 1975. May''s classical-tinged tenderness.',79),
    ('39','queen','guitar','main','skiffle strums','acoustic','rock','rhythm','beginner',
     'Martin acoustic (Brian May)','Acoustic — mic''d, skiffle band','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":7,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The relativity folk song — May''s galloping skiffle strums about time dilation.','Bright driving acoustic; a sea shanty in space.'],
     array['Gallop the strums with skiffle bounce.','Written by an astrophysicist about coming home late. Play it wistful.'],
     'Studio recording, 1975. The astrophysicist''s space shanty.',79),
    ('is-there-anybody-out-there','pink-floyd','guitar','main','classical fingerpicking','acoustic','rock','lead','intermediate',
     'Nylon-string classical (session — Joe DiBlasi / David Gilmour)','Classical — close-mic''d','No cab (classical)','n/a (classical)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":3,"delay":0,"master":5}'::jsonb,
     array['The Wall''s loneliest moment — spare classical fingerpicking in the dark.','Soft nylon intimacy; every note a question.'],
     array['The Am arpeggio study builds by small additions.','Play it alone, quietly, like the title.'],
     'Studio recording, 1979. The loneliest classical study on The Wall.',79),
    ('mother','pink-floyd','guitar','main','acoustic + solo','acoustic','rock','rhythm','intermediate',
     'Acoustic + Les Paul (Roger Waters / David Gilmour)','Acoustic + warm lead amp for the solo','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The over-protection waltz — gentle acoustic in shifting meters with Gilmour''s warm solo (gain 5).','Soft acoustic base; the solo sings with Gilmour patience.'],
     array['Count the meter shifts — the song breathes oddly on purpose.','The solo bends cry gently; no hurry.'],
     'Studio recording, 1979. The shifting-meter lullaby and solo.',79),

    -- ============ 70s SOFT-ROCK STAPLES ============
    ('peaceful-easy-feeling','eagles','guitar','main','country-rock strums','acoustic','country rock','rhythm','beginner',
     'Acoustic + Telecaster (Glenn Frey / Bernie Leadon)','Acoustic + clean Fender amp','Fender combo cab','bridge single-coil',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":7,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The desert-night opener — bright acoustic strums with Telecaster curls.','Crisp acoustic bed; B-bender-flavored fills answer.'],
     array['Easy E-A strums with country lift.','The Tele fills sparkle like desert stars.'],
     'Studio recording, 1972. The desert-night country-rock staple.',78),
    ('tequila-sunrise','eagles','guitar','main','country-rock strums','acoustic','country rock','rhythm','beginner',
     'Acoustic + Telecaster (Glenn Frey / Bernie Leadon)','Acoustic + clean Fender amp','Fender combo cab','bridge single-coil',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The barroom sunrise — gentle strums with weeping Tele bends.','Warm relaxed acoustic; the fills sigh like last call.'],
     array['Roll the G-shapes with a soft swing.','The Tele bends imitate pedal steel — slow and sad.'],
     'Studio recording, 1973. The barroom-sunrise ballad.',78),
    ('america','simon-and-garfunkel','guitar','main','fingerpicked journey','acoustic','folk','rhythm','intermediate',
     'Acoustic guitar (Paul Simon)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The Greyhound-window epic — Simon''s flowing picking under the search for America.','Warm cinematic acoustic; the arrangement swells like passing landscape.'],
     array['The picking flows in waves — never mechanical.','Counting the cars on the New Jersey Turnpike takes exactly this tempo.'],
     'Studio recording, 1968. The Greyhound-window epic.',80),
    ('april-come-she-will','simon-and-garfunkel','guitar','main','fingerpicked miniature','acoustic','folk','rhythm','intermediate',
     'Acoustic guitar (Paul Simon)','Acoustic — close-mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":5}'::jsonb,
     array['The two-minute seasons — Simon''s crystalline picking miniature.','Bright delicate acoustic; a whole year in 110 seconds.'],
     array['The picking pattern shifts with each month.','Whisper it; it''s over before you know.'],
     'Studio recording, 1966. The two-minute seasons miniature.',80),
    ('never-going-back-again','fleetwood-mac','guitar','main','travis-picked showpiece','acoustic','rock','lead','expert',
     'Acoustic guitar (Lindsey Buckingham)','Acoustic — close-mic''d, tuned down','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Buckingham''s travis-picking Everest — capo''d, tuned-down, and fingerpicked at conversation speed.','Bright dry acoustic; the two-hand independence is the whole song.'],
     array['Capo IV over a down-tuned guitar on the record.','Thumb independence first; the melody rides on top.'],
     'Studio recording, 1977. Buckingham''s travis-picking Everest.',80),
    ('night-moves','bob-seger','guitar','main','heartland strums','acoustic','heartland rock','rhythm','beginner',
     'Acoustic + electric (Bob Seger / Silver Bullet Band)','Acoustic + warm clean amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The backseat memoir — warm acoustic strums with the famous quiet bridge.','Open honest acoustic; 1962 summer in G-C-F.'],
     array['Strum the verses steady; drop to nothing at "I woke last night".','Autumn closing in — let the last chorus ache.'],
     'Studio recording, 1976. The backseat memoir.',78),
    ('turn-the-page','bob-seger','guitar','main','lonely arpeggios','clean','heartland rock','rhythm','beginner',
     'Electric guitar (Silver Bullet Band)','Clean amp, road-lonely warmth','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":4,"delay":0,"master":6}'::jsonb,
     array['The road-dog confession — sparse Em arpeggios under the lonely sax.','Warm empty clean; sixteen hours of highway in every chord.'],
     array['Arpeggiate Em-D-C-A with maximum space.','Here I am. On the road again. Play exactly that tired.'],
     'Studio recording, 1973. The road-dog confession.',78),

    -- ============ 60s SOUL / FOLK STAPLES ============
    ('brown-eyed-girl','van-morrison','guitar','riff','main riff','clean','rock','rhythm','beginner',
     'Fender/Gibson electric (session)','Clean amp, bright and joyful','Fender combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":5,"treble":8,"presence":6,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The wedding-band eternal — the double-stop intro riff every guitarist eventually plays.','Bright sparkling clean; G-C-G-D sunshine.'],
     array['The intro double-stops climb in thirds — exact and joyful.','Sha la la la la la la la. You know the rest.'],
     'Studio recording, 1967. The double-stop wedding eternal.',79),
    ('moondance','van-morrison','guitar','riff','jazz comping','clean','rock','rhythm','intermediate',
     'Hollow-body electric (session)','Warm jazz clean amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":4,"presence":3,"reverb":2,"delay":0,"master":5}'::jsonb,
     array['The October-sky swinger — walking jazz comping in Am.','Dark round jazz clean; snap the 2 and 4.'],
     array['Comp the Am7-Bm7 vamp with swing.','A fantabulous night needs a fantabulous pocket.'],
     'Studio recording, 1970. The October-sky jazz swinger.',78),
    ('sittin-on-the-dock-of-the-bay','otis-redding','guitar','main','soul strums + fills','clean','soul','rhythm','beginner',
     'Fender Telecaster (Steve Cropper)','Fender tube amp, warm Stax clean','Fender combo cab','bridge single-coil',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Cropper''s last gift to Otis — warm Stax clean with those falling intro fills.','Round Memphis clean; the seagulls whistle the outro.'],
     array['The descending intro fills mimic waves.','Comp gently; whistle when the words run out.'],
     'Studio recording, 1968. Cropper''s wave-fall fills for Otis.',80),
    ('trouble','cat-stevens','guitar','main','fingerpicked plea','acoustic','folk','rhythm','beginner',
     'Acoustic guitar (Cat Stevens)','Acoustic — close-mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":2,"delay":0,"master":5}'::jsonb,
     array['The Harold and Maude prayer — hushed fingerpicked plea.','Soft intimate acoustic; barely above breathing.'],
     array['The gentle picking pattern pleads — small and steady.','Trouble, set me free. Quietly.'],
     'Studio recording, 1970. The hushed Harold and Maude prayer.',78),
    ('dannys-song','kenny-loggins','guitar','main','fingerpicked love song','acoustic','folk','rhythm','beginner',
     'Acoustic guitar (Kenny Loggins)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The everything-gonna-be-fine waltz — warm picked acoustic for a newborn nephew.','Soft rolling acoustic; pure domestic joy.'],
     array['Pick the waltz pattern gently.','Even though we ain''t got money — play rich.'],
     'Studio recording, 1971. The newborn-nephew waltz.',77),
    ('stand-by-me','ben-e-king','guitar','main','chord accompaniment','clean','soul','rhythm','beginner',
     'Electric guitar (session — Leiber/Stoller date)','Clean amp, warm 60s studio','Small combo cab','neck pickup',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The 50s-progression monument — the bass line leads; guitar comps the eternal A-F#m-D-E.','Warm gentle clean; the progression outlived every era.'],
     array['Comp the changes softly behind the melody.','When the night has come — you know all four chords already.'],
     'Studio recording, 1961. The eternal-progression monument.',79)
) as c(
  song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence
)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;
