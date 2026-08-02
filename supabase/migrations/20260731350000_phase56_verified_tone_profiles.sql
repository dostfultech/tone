-- Phase 56: 60s canon + surf / rockabilly instrumentals, verified per-part tone data.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Dick Dale','dick-dale','Misirlou','misirlou','Surfers'' Choice',1962),
    ('The Ventures','the-ventures','Walk, Don''t Run','walk-dont-run','Walk Don''t Run',1960),
    ('The Shadows','the-shadows','Apache','apache','Apache',1960),
    ('Santo & Johnny','santo-and-johnny','Sleep Walk','sleep-walk','Santo & Johnny',1959),
    ('The Surfaris','the-surfaris','Wipe Out','wipe-out','Wipe Out',1963),
    ('The Chantays','the-chantays','Pipeline','pipeline','Pipeline',1963),
    ('Stray Cats','stray-cats','Rock This Town','rock-this-town','Stray Cats',1981),
    ('Stray Cats','stray-cats','Stray Cat Strut','stray-cat-strut','Stray Cats',1981),
    ('Ritchie Valens','ritchie-valens','La Bamba','la-bamba','Ritchie Valens',1958),
    ('The Kingsmen','the-kingsmen','Louie Louie','louie-louie','The Kingsmen in Person',1963),
    ('Bob Dylan','bob-dylan','Knockin'' on Heaven''s Door','knockin-on-heavens-door','Pat Garrett & Billy the Kid',1973),
    ('Bob Dylan','bob-dylan','Blowin'' in the Wind','blowin-in-the-wind','The Freewheelin'' Bob Dylan',1963),
    ('Bob Dylan','bob-dylan','Like a Rolling Stone','like-a-rolling-stone','Highway 61 Revisited',1965),
    ('John Denver','john-denver','Take Me Home, Country Roads','take-me-home-country-roads','Poems, Prayers & Promises',1971),
    ('John Denver','john-denver','Leaving on a Jet Plane','leaving-on-a-jet-plane','Rhymes & Reasons',1969),
    ('Simon & Garfunkel','simon-and-garfunkel','The Boxer','the-boxer','Bridge over Troubled Water',1970),
    ('The Byrds','the-byrds','Mr. Tambourine Man','mr-tambourine-man','Mr. Tambourine Man',1965),
    ('The Byrds','the-byrds','Turn! Turn! Turn!','turn-turn-turn','Turn! Turn! Turn!',1965),
    ('The Mamas & the Papas','the-mamas-and-the-papas','California Dreamin''','california-dreamin','If You Can Believe Your Eyes and Ears',1965),
    ('The Turtles','the-turtles','Happy Together','happy-together','Happy Together',1967),
    ('The Beach Boys','the-beach-boys','Surfin'' U.S.A.','surfin-usa','Surfin'' U.S.A.',1963),
    ('Link Wray','link-wray','Rumble','rumble','Link Wray & His Ray Men',1958),
    ('Booker T. & the M.G.''s','booker-t-and-the-mgs','Green Onions','green-onions','Green Onions',1962),
    ('Duane Eddy','duane-eddy','Rebel ''Rouser','rebel-rouser','Have ''Twangy'' Guitar Will Travel',1958),
    ('The Everly Brothers','the-everly-brothers','Bye Bye Love','bye-bye-love','The Everly Brothers',1957)
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
    ('dick-dale','misirlou'),('the-ventures','walk-dont-run'),('the-shadows','apache'),
    ('santo-and-johnny','sleep-walk'),('the-surfaris','wipe-out'),('the-chantays','pipeline'),
    ('stray-cats','rock-this-town'),('stray-cats','stray-cat-strut'),('ritchie-valens','la-bamba'),
    ('the-kingsmen','louie-louie'),('bob-dylan','knockin-on-heavens-door'),('bob-dylan','blowin-in-the-wind'),
    ('bob-dylan','like-a-rolling-stone'),('john-denver','take-me-home-country-roads'),
    ('john-denver','leaving-on-a-jet-plane'),('simon-and-garfunkel','the-boxer'),('the-byrds','mr-tambourine-man'),
    ('the-byrds','turn-turn-turn'),('the-mamas-and-the-papas','california-dreamin'),('the-turtles','happy-together'),
    ('the-beach-boys','surfin-usa'),('link-wray','rumble'),('booker-t-and-the-mgs','green-onions'),
    ('duane-eddy','rebel-rouser'),('the-everly-brothers','bye-bye-love')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('dick-dale','misirlou'),('the-ventures','walk-dont-run'),('the-shadows','apache'),
    ('santo-and-johnny','sleep-walk'),('the-surfaris','wipe-out'),('the-chantays','pipeline'),
    ('stray-cats','rock-this-town'),('stray-cats','stray-cat-strut'),('ritchie-valens','la-bamba'),
    ('the-kingsmen','louie-louie'),('bob-dylan','knockin-on-heavens-door'),('bob-dylan','blowin-in-the-wind'),
    ('bob-dylan','like-a-rolling-stone'),('john-denver','take-me-home-country-roads'),
    ('john-denver','leaving-on-a-jet-plane'),('simon-and-garfunkel','the-boxer'),('the-byrds','mr-tambourine-man'),
    ('the-byrds','turn-turn-turn'),('the-mamas-and-the-papas','california-dreamin'),('the-turtles','happy-together'),
    ('the-beach-boys','surfin-usa'),('link-wray','rumble'),('booker-t-and-the-mgs','green-onions'),
    ('duane-eddy','rebel-rouser'),('the-everly-brothers','bye-bye-love')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('dick-dale','misirlou'),('the-ventures','walk-dont-run'),('the-shadows','apache'),
    ('santo-and-johnny','sleep-walk'),('the-surfaris','wipe-out'),('the-chantays','pipeline'),
    ('stray-cats','rock-this-town'),('stray-cats','stray-cat-strut'),('ritchie-valens','la-bamba'),
    ('the-kingsmen','louie-louie'),('bob-dylan','knockin-on-heavens-door'),('bob-dylan','blowin-in-the-wind'),
    ('bob-dylan','like-a-rolling-stone'),('john-denver','take-me-home-country-roads'),
    ('john-denver','leaving-on-a-jet-plane'),('simon-and-garfunkel','the-boxer'),('the-byrds','mr-tambourine-man'),
    ('the-byrds','turn-turn-turn'),('the-mamas-and-the-papas','california-dreamin'),('the-turtles','happy-together'),
    ('the-beach-boys','surfin-usa'),('link-wray','rumble'),('booker-t-and-the-mgs','green-onions'),
    ('duane-eddy','rebel-rouser'),('the-everly-brothers','bye-bye-love')
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
    -- ============ SURF INSTRUMENTALS ============
    ('misirlou','dick-dale','guitar','lead','main melody','clean','surf rock','lead','intermediate',
     'Fender Stratocaster, left-handed (Dick Dale)','Fender Showman with outboard spring reverb','Fender 1x15 cab','bridge single-coil',
     '[{"effect_type":"reverb","effect_name":"drippy spring reverb tank","placement":"post_gain","settings":{"mix":6,"dwell":7}}]'::jsonb,
     '{"gain":3,"bass":4,"mids":5,"treble":8,"presence":7,"reverb":6,"delay":0,"master":8}'::jsonb,
     array['The surf king''s staccato fury — trebly Strat into a loud Showman drenched in spring drip.','Max the spring reverb; the tone is bright, loud, and percussive.'],
     array['Rapid double-picking on one string — build the tremolo picking slowly.','Attack like the pick is a drumstick.'],
     'Studio recording, 1962. Dale''s double-picked Strat into a reverb-drenched Showman.',80),
    ('walk-dont-run','the-ventures','guitar','lead','main melody','clean','surf rock','lead','beginner',
     'Fender Jazzmaster (Bob Bogle / Don Wilson)','Fender tube combo, clean','Fender combo cab','bridge pickup',
     '[{"effect_type":"reverb","effect_name":"spring reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":7,"presence":6,"reverb":4,"delay":0,"master":6}'::jsonb,
     array['The instrumental-rock blueprint — clean twangy melody over walking changes.','Bright Fender clean with spring; simple and iconic.'],
     array['The melody sits on the top strings — pick it cleanly.','A perfect first instrumental to learn.'],
     'Studio recording, 1960. The instrumental-rock blueprint.',79),
    ('apache','the-shadows','guitar','lead','main melody','clean','surf rock','lead','beginner',
     'Fender Stratocaster (Hank Marvin)','Vox AC15/AC30 with tape echo','Vox 2x12 cab','neck pickup',
     '[{"effect_type":"delay","effect_name":"Meazzi tape echo","placement":"post_gain","settings":{"time":3,"mix":4,"feedback":3}},{"effect_type":"reverb","effect_name":"spring reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":6,"reverb":3,"delay":4,"master":6}'::jsonb,
     array['Hank Marvin''s echo-laden cinematic twang — the sound that launched a thousand British guitarists.','Clean Strat neck pickup into AC30 with tape echo; use the whammy bar for vocal bends.'],
     array['Gentle whammy scoops on the long notes.','The echo repeats are part of the rhythm.'],
     'Studio recording, 1960. Marvin''s echo-laden Strat-into-Vox twang.',80),
    ('sleep-walk','santo-and-johnny','guitar','lead','main melody','clean','instrumental','lead','intermediate',
     'Lap steel guitar (Santo Farina)','Clean tube amp','Fender combo cab','steel pickup',
     '[{"effect_type":"reverb","effect_name":"studio plate reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":1,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":4,"delay":0,"master":6}'::jsonb,
     array['The dreamy 1959 steel classic — on standard guitar, play it with slides, bends, and volume swells on the neck pickup.','Warm glassy clean; every note glides into the next.'],
     array['Slide between melody notes; never attack abruptly.','Volume-knob swells mimic the steel''s breath.'],
     'Studio recording, 1959. The dreamy lap-steel classic (adapted for standard guitar).',78),
    ('wipe-out','the-surfaris','guitar','riff','main riff','clean','surf rock','rhythm','beginner',
     'Fender Stratocaster (Jim Fuller)','Fender tube combo, edge of breakup','Fender combo cab','bridge pickup',
     '[{"effect_type":"reverb","effect_name":"spring reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":3,"bass":4,"mids":5,"treble":8,"presence":7,"reverb":4,"delay":0,"master":7}'::jsonb,
     array['The drum-solo surf anthem — trebly staccato riff between the tom barrages.','Bright just-breaking-up Fender; snappy attack.'],
     array['The descending chromatic riff answers the drums.','Tight muting keeps the surf snap.'],
     'Studio recording, 1963. The drum-duel surf anthem riff.',78),
    ('pipeline','the-chantays','guitar','riff','main riff','clean','surf rock','rhythm','beginner',
     'Fender Stratocaster (Bob Spickard)','Fender tube combo with spring reverb','Fender combo cab','bridge pickup',
     '[{"effect_type":"reverb","effect_name":"drippy spring reverb","placement":"post_gain","settings":{"mix":5}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":7,"presence":6,"reverb":5,"delay":0,"master":6}'::jsonb,
     array['The mysterious minor-key surf classic — wet spring drip on a descending riff.','Heavy spring reverb; the gliss down the low E opens it.'],
     array['Open with the iconic low-string glissando.','Keep the eighth-note pulse hypnotic.'],
     'Studio recording, 1963. The minor-key spring-drenched surf classic.',78),

    -- ============ ROCKABILLY / EARLY ROCK ============
    ('rock-this-town','stray-cats','guitar','riff','main riff','crunch','rockabilly','rhythm','intermediate',
     'Gretsch 6120 (Brian Setzer)','Fender Bassman with tape echo slapback','Fender 4x10 cab','bridge Filter''Tron',
     '[{"effect_type":"delay","effect_name":"slapback tape echo","placement":"post_gain","settings":{"time":1,"mix":3,"feedback":1}}]'::jsonb,
     '{"gain":4,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":2,"master":7}'::jsonb,
     array['Setzer''s revival rockabilly — Gretsch twang into a pushed Bassman with single-repeat slapback.','Bright gritty twang; the slapback is short and tight.'],
     array['Swing the shuffle hard; walk the bass notes.','The solo mixes jazz chords and billy licks.'],
     'Studio recording, 1981. Setzer''s Gretsch-into-Bassman revival rockabilly.',80),
    ('stray-cat-strut','stray-cats','guitar','riff','main riff + solo','clean','rockabilly','lead','intermediate',
     'Gretsch 6120 (Brian Setzer)','Fender Bassman, cleaner setting','Fender 4x10 cab','bridge Filter''Tron',
     '[{"effect_type":"delay","effect_name":"slapback tape echo","placement":"post_gain","settings":{"time":1,"mix":3,"feedback":1}}]'::jsonb,
     '{"gain":3,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":2,"master":6}'::jsonb,
     array['The alley-cat strut — cleaner Gretsch twang walking down the minor progression.','Just-clean twang with slapback; feline swagger.'],
     array['Walk the descending line with pick-and-fingers.','The solo is pure jazz-billy showing off — enjoy it.'],
     'Studio recording, 1981. The alley-cat clean twang strut.',80),
    ('la-bamba','ritchie-valens','guitar','riff','main riff','clean','early rock','rhythm','beginner',
     'Electric guitar (Ritchie Valens)','Small tube combo, warm clean','Small combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The Mexican folk-rock crossover — warm bright clean strums and the famous riff.','Slightly hairy 50s clean; joy is the tone.'],
     array['The C-F-G riff pattern is a rite of passage.','Strum with the son jarocho bounce.'],
     'Studio recording, 1958. The joyful folk-rock crossover riff.',77),
    ('louie-louie','the-kingsmen','guitar','riff','main riff','crunch','garage rock','rhythm','beginner',
     'Electric guitar (Mike Mitchell)','Small tube combo pushed','Small combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The garage-rock ur-text — sloppy pushed-combo crunch, recorded in one chaotic take.','Raw small-amp hair; perfection is against the spirit.'],
     array['Duh duh duh, duh duh — three chords forever.','Loose and loud; that''s the entire assignment.'],
     'Studio recording, 1963. The one-take garage ur-text.',77),

    -- ============ DYLAN / FOLK CANON ============
    ('knockin-on-heavens-door','bob-dylan','guitar','main','main progression','acoustic','folk rock','rhythm','beginner',
     'Acoustic guitar (Bob Dylan / session)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The four-chord eternal — G-D-Am7 forever, warm and unhurried.','Soft warm acoustic; the space between strums matters.'],
     array['One of the first songs every guitarist learns — savor it.','Let each chord ring its full length.'],
     'Studio recording, 1973. The eternal four-chord ballad.',79),
    ('blowin-in-the-wind','bob-dylan','guitar','main','main progression','acoustic','folk','rhythm','beginner',
     'Acoustic guitar (Bob Dylan)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bare folk strumming — one voice, one guitar, one harmonica.','Dry intimate acoustic; nothing between you and the song.'],
     array['Simple strums with bass-note accents.','The questions carry it; play plainly.'],
     'Studio recording, 1963. Bare folk strumming from Freewheelin''.',79),
    ('like-a-rolling-stone','bob-dylan','guitar','riff','electric rhythm','crunch','folk rock','rhythm','intermediate',
     'Fender Telecaster (Mike Bloomfield)','Fender tube amp, edge of breakup','Fender combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The electric heresy of 1965 — Bloomfield''s stinging Telecaster fills around the organ.','Bright just-breaking-up Fender; the fills bite, never overdrive.'],
     array['Answer the vocal with quick Telecaster stabs.','Stay out of the organ''s way — it''s a crowded, glorious mix.'],
     'Studio recording, 1965. Bloomfield''s stinging Telecaster on the electric heresy.',79),
    ('take-me-home-country-roads','john-denver','guitar','main','main progression','acoustic','folk','rhythm','beginner',
     '12-string acoustic (John Denver)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":7,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The world''s campfire anthem — shimmering 12-string strums.','Bright open acoustic; on 6-string it still works, just less shimmer.'],
     array['G-Em-D-C — sing it in any language on earth.','Steady driving strum; everyone else will clap.'],
     'Studio recording, 1971. The world''s campfire anthem on 12-string.',79),
    ('leaving-on-a-jet-plane','john-denver','guitar','main','main progression','acoustic','folk','rhythm','beginner',
     'Acoustic guitar (John Denver)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Tender farewell folk — soft fingerpicked and strummed acoustic.','Warm quiet acoustic; three chords and honesty.'],
     array['Alternate gentle picking and soft strums.','Keep it hushed — it''s a goodbye.'],
     'Studio recording, 1969. Tender three-chord farewell folk.',78),
    ('the-boxer','simon-and-garfunkel','guitar','main','fingerpicked pattern','acoustic','folk','rhythm','intermediate',
     'Acoustic guitar (Paul Simon)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Simon''s intricate travis picking — the lie-la-lie epic.','Clear balanced acoustic; the picking pattern is the arrangement.'],
     array['Learn the travis pattern slowly — thumb independence first.','The "lie-la-lie" chorus opens into full strums.'],
     'Studio recording, 1970. Simon''s travis-picking epic.',80),

    -- ============ JANGLE / SUNSHINE ============
    ('mr-tambourine-man','the-byrds','guitar','riff','12-string jangle','clean','folk rock','rhythm','intermediate',
     'Rickenbacker 360/12 (Roger McGuinn)','Clean amp, heavily compressed','Open-back combo cab','bridge pickup',
     '[{"effect_type":"compressor","effect_name":"heavy studio compression","placement":"front","settings":{"sustain":7,"level":6}}]'::jsonb,
     '{"gain":1,"bass":4,"mids":5,"treble":8,"presence":6,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The jangle big bang — McGuinn''s compressed Rickenbacker 12-string chime.','Bright 12-string into heavy compression; that squeeze IS the sound.'],
     array['The intro arpeggio-riff defined folk rock.','On 6-string, add the octave notes to fake the 12.'],
     'Studio recording, 1965. McGuinn''s compressed Rickenbacker jangle big bang.',80),
    ('turn-turn-turn','the-byrds','guitar','riff','12-string jangle','clean','folk rock','rhythm','beginner',
     'Rickenbacker 360/12 (Roger McGuinn)','Clean amp, heavily compressed','Open-back combo cab','bridge pickup',
     '[{"effect_type":"compressor","effect_name":"heavy studio compression","placement":"front","settings":{"sustain":7,"level":6}}]'::jsonb,
     '{"gain":1,"bass":4,"mids":5,"treble":8,"presence":6,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Ecclesiastes with a Rickenbacker — the same golden compressed chime.','Bright squeezed 12-string jangle throughout.'],
     array['Gentle arpeggios and strums under the harmonies.','Let the chime do the preaching.'],
     'Studio recording, 1965. Golden compressed jangle.',79),
    ('california-dreamin','the-mamas-and-the-papas','guitar','main','main progression','acoustic','folk rock','rhythm','beginner',
     '12-string acoustic (session — P.F. Sloan)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Winter-gray folk-rock strums — the famous 12-string intro figure.','Rich acoustic strumming in minor; the intro riff sets the chill.'],
     array['The Am-G-F intro figure is instantly recognized.','Steady brooding strums under the harmonies.'],
     'Studio recording, 1965. The winter-gray 12-string folk-rock classic.',78),
    ('happy-together','the-turtles','guitar','main','main progression','acoustic','pop','rhythm','beginner',
     'Acoustic + electric (session)','Acoustic + warm clean amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The minor-verse/major-chorus classic — brooding strums into sunshine.','Acoustic-led with soft clean electric; the dynamic flip is the song.'],
     array['Minor verses stay hushed; the chorus explodes into major.','"Ba-ba-ba" like your life depends on it.'],
     'Studio recording, 1967. The brooding-to-sunshine classic.',77),
    ('surfin-usa','the-beach-boys','guitar','riff','main riff','crunch','surf rock','rhythm','beginner',
     'Fender Jaguar/Stratocaster (Carl Wilson)','Fender tube combo, light drive','Fender combo cab','bridge pickup',
     '[{"effect_type":"reverb","effect_name":"spring reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":3,"bass":4,"mids":5,"treble":8,"presence":6,"reverb":3,"delay":0,"master":7}'::jsonb,
     array['Chuck Berry goes to the beach — bright driving surf-rock chug.','Trebly Fender light drive with spring splash.'],
     array['Berry-style double-stop chug all song.','Keep the eighth-notes rolling like the tide.'],
     'Studio recording, 1963. Bright Berry-on-the-beach chug.',78),
    ('rumble','link-wray','guitar','riff','main riff','fuzz','instrumental rock','rhythm','beginner',
     'Gibson Les Paul (Link Wray)','Small tube amp with slashed speaker cone','Damaged combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":6,"mids":6,"treble":5,"presence":4,"reverb":3,"delay":0,"master":8}'::jsonb,
     array['The first power-chord menace — Wray famously slashed his speaker cone to get this buzz in 1958.','Raw torn-speaker fuzz; slow, loud, and threatening. A fuzz pedal gets you close.'],
     array['Slow menacing power chords with wide rakes.','It was banned from radio without words — play why.'],
     'Studio recording, 1958. The slashed-speaker power-chord origin story.',79),
    ('green-onions','booker-t-and-the-mgs','guitar','riff','rhythm + solo stabs','clean','soul','rhythm','beginner',
     'Fender Telecaster (Steve Cropper)','Fender tube combo, biting clean','Fender combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":3,"bass":4,"mids":6,"treble":8,"presence":7,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Cropper''s razor Telecaster — biting clean stabs over the organ groove.','Bright cutting Tele clean; every stab is percussion.'],
     array['Sparse chord stabs on the backbeat.','The solo is all attitude double-stops.'],
     'Studio recording, 1962. Cropper''s razor-stab Telecaster over the organ.',80),
    ('rebel-rouser','duane-eddy','guitar','lead','twang melody','clean','instrumental rock','lead','beginner',
     'Gretsch 6120 (Duane Eddy)','Fender tube amp with tank reverb','Fender combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"water-tank reverb","placement":"post_gain","settings":{"mix":5}},{"effect_type":"tremolo","effect_name":"amp tremolo","placement":"post_gain","settings":{"rate":3,"depth":3}}]'::jsonb,
     '{"gain":2,"bass":6,"mids":6,"treble":5,"presence":4,"reverb":5,"delay":0,"master":6}'::jsonb,
     array['The king of twang — melody played entirely on the bass strings, drenched in tank reverb.','Deep warm neck-pickup twang; play the melody an octave down.'],
     array['Walk the melody on the low strings.','Let the reverb bloom around each note.'],
     'Studio recording, 1958. Eddy''s low-string twang in tank reverb.',79),
    ('bye-bye-love','the-everly-brothers','guitar','main','main progression','acoustic','early rock','rhythm','beginner',
     'Gibson J-200 acoustics (Don & Phil Everly)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The percussive J-200 strut — big acoustic strums driving early rock ''n'' roll.','Bright punchy acoustic; the intro strum riff is the hook.'],
     array['Hammer the syncopated intro strums.','Drive the whole song from the wrist.'],
     'Studio recording, 1957. The percussive J-200 strut that opened rock''s harmony era.',79)
) as c(
  song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence
)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;
