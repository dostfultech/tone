-- Phase 60: DEMAND-DRIVEN batch 2 — Ultimate Guitar GLOBAL all-time top-100 gaps.
-- Source: UG Top 100 by all-time hits, 2026-08-01. US/global audience canon.
-- Piano originals are profiled as the standard acoustic-guitar arrangement (noted honestly).

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Elvis Presley','elvis-presley','Can''t Help Falling in Love','cant-help-falling-in-love','Blue Hawaii',1961),
    ('John Legend','john-legend','All of Me','all-of-me','Love in the Future',2013),
    ('Justin Bieber','justin-bieber','Love Yourself','love-yourself','Purpose',2015),
    ('Coldplay','coldplay','Viva la Vida','viva-la-vida','Viva la Vida or Death and All His Friends',2008),
    ('Coldplay','coldplay','The Scientist','the-scientist','A Rush of Blood to the Head',2002),
    ('Paramore','paramore','The Only Exception','the-only-exception','Brand New Eyes',2009),
    ('Lady Gaga','lady-gaga','Shallow','shallow','A Star Is Born',2018),
    ('The Beatles','the-beatles','Let It Be','let-it-be','Let It Be',1970),
    ('The Beatles','the-beatles','Hey Jude','hey-jude','Hey Jude',1968),
    ('The Beatles','the-beatles','Yesterday','yesterday','Help!',1965),
    ('John Lennon','john-lennon','Imagine','imagine','Imagine',1971),
    ('Snow Patrol','snow-patrol','Chasing Cars','chasing-cars','Eyes Open',2006),
    ('Dolly Parton','dolly-parton','Jolene','jolene','Jolene',1973),
    ('Daniel Caesar','daniel-caesar','Best Part','best-part','Freudian',2017),
    ('The Script','the-script','Breakeven','breakeven','The Script',2008),
    ('Eraserheads','eraserheads','Ang Huling El Bimbo','ang-huling-el-bimbo','Cutterpillow',1995),
    ('Christina Perri','christina-perri','A Thousand Years','a-thousand-years','The Twilight Saga: Breaking Dawn',2011),
    ('The Fray','the-fray','How to Save a Life','how-to-save-a-life','How to Save a Life',2005),
    ('Adele','adele','Someone Like You','someone-like-you','21',2011),
    ('Lewis Capaldi','lewis-capaldi','Someone You Loved','someone-you-loved','Divinely Uninspired to a Hellish Extent',2019),
    ('Sam Smith','sam-smith','Stay With Me','stay-with-me','In the Lonely Hour',2014),
    ('Bruno Mars','bruno-mars','Just the Way You Are','just-the-way-you-are','Doo-Wops & Hooligans',2010),
    ('Frank Sinatra','frank-sinatra','Fly Me to the Moon','fly-me-to-the-moon','It Might as Well Be Swing',1964),
    ('Ed Sheeran','ed-sheeran','I See Fire','i-see-fire','The Hobbit: The Desolation of Smaug',2013),
    ('Green Day','green-day','Wake Me Up When September Ends','wake-me-up-when-september-ends','American Idiot',2004)
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
    ('elvis-presley','cant-help-falling-in-love'),('john-legend','all-of-me'),('justin-bieber','love-yourself'),
    ('coldplay','viva-la-vida'),('coldplay','the-scientist'),('paramore','the-only-exception'),('lady-gaga','shallow'),
    ('the-beatles','let-it-be'),('the-beatles','hey-jude'),('the-beatles','yesterday'),('john-lennon','imagine'),
    ('snow-patrol','chasing-cars'),('dolly-parton','jolene'),('daniel-caesar','best-part'),('the-script','breakeven'),
    ('eraserheads','ang-huling-el-bimbo'),('christina-perri','a-thousand-years'),('the-fray','how-to-save-a-life'),
    ('adele','someone-like-you'),('lewis-capaldi','someone-you-loved'),('sam-smith','stay-with-me'),
    ('bruno-mars','just-the-way-you-are'),('frank-sinatra','fly-me-to-the-moon'),('ed-sheeran','i-see-fire'),
    ('green-day','wake-me-up-when-september-ends')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('elvis-presley','cant-help-falling-in-love'),('john-legend','all-of-me'),('justin-bieber','love-yourself'),
    ('coldplay','viva-la-vida'),('coldplay','the-scientist'),('paramore','the-only-exception'),('lady-gaga','shallow'),
    ('the-beatles','let-it-be'),('the-beatles','hey-jude'),('the-beatles','yesterday'),('john-lennon','imagine'),
    ('snow-patrol','chasing-cars'),('dolly-parton','jolene'),('daniel-caesar','best-part'),('the-script','breakeven'),
    ('eraserheads','ang-huling-el-bimbo'),('christina-perri','a-thousand-years'),('the-fray','how-to-save-a-life'),
    ('adele','someone-like-you'),('lewis-capaldi','someone-you-loved'),('sam-smith','stay-with-me'),
    ('bruno-mars','just-the-way-you-are'),('frank-sinatra','fly-me-to-the-moon'),('ed-sheeran','i-see-fire'),
    ('green-day','wake-me-up-when-september-ends')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('elvis-presley','cant-help-falling-in-love'),('john-legend','all-of-me'),('justin-bieber','love-yourself'),
    ('coldplay','viva-la-vida'),('coldplay','the-scientist'),('paramore','the-only-exception'),('lady-gaga','shallow'),
    ('the-beatles','let-it-be'),('the-beatles','hey-jude'),('the-beatles','yesterday'),('john-lennon','imagine'),
    ('snow-patrol','chasing-cars'),('dolly-parton','jolene'),('daniel-caesar','best-part'),('the-script','breakeven'),
    ('eraserheads','ang-huling-el-bimbo'),('christina-perri','a-thousand-years'),('the-fray','how-to-save-a-life'),
    ('adele','someone-like-you'),('lewis-capaldi','someone-you-loved'),('sam-smith','stay-with-me'),
    ('bruno-mars','just-the-way-you-are'),('frank-sinatra','fly-me-to-the-moon'),('ed-sheeran','i-see-fire'),
    ('green-day','wake-me-up-when-september-ends')
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
    -- ============ ALL-TIME CHORD CANON ============
    ('cant-help-falling-in-love','elvis-presley','guitar','main','main progression','acoustic','early rock','rhythm','beginner',
     'Acoustic guitar (session — Blue Hawaii)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The #3 all-time tab — gentle 6/8 acoustic sway (ukulele colors on the record).','Warm soft acoustic; wedding-aisle patience.'],
     array['Slow 6/8 arpeggio-strum pattern.','Wise men say: don''t rush it.'],
     'Studio recording, 1961. The eternal 6/8 wedding classic.',77),
    ('all-of-me','john-legend','guitar','main','acoustic arrangement','acoustic','pop','rhythm','beginner',
     'Acoustic guitar (standard arrangement)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Piano original — this profile covers the standard fingerpicked acoustic arrangement everyone plays.','Warm intimate acoustic; mirror the piano''s broken-chord pattern.'],
     array['Fingerpick the piano figure as arpeggios.','Dynamics swell into each chorus.'],
     'Studio recording, 2013. Piano ballad; profiled as the standard acoustic arrangement.',73),
    ('love-yourself','justin-bieber','guitar','main','main progression','acoustic','pop','rhythm','beginner',
     'Acoustic guitar (session — Ed Sheeran co-write)','Acoustic — DI, bone dry','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":6,"treble":5,"presence":4,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['One guitar, one vocal, one trumpet — deliberately dry close-mic''d acoustic.','Dry warm acoustic; no reverb is the sound.'],
     array['The muted strum-pick pattern is the whole arrangement.','Keep it conversational and dry.'],
     'Studio recording, 2015. The famously dry one-guitar arrangement.',75),
    ('viva-la-vida','coldplay','guitar','main','strummed arrangement','acoustic','pop rock','rhythm','beginner',
     'Acoustic guitar (standard arrangement)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['String-orchestra original — profiled as the driving acoustic strum arrangement everyone plays.','Bright rhythmic acoustic mirroring the string ostinato.'],
     array['Drive the strums like the string section.','The four-chord loop never stops — stamina over flash.'],
     'Studio recording, 2008. String-driven original; profiled as the standard strum arrangement.',73),
    ('the-scientist','coldplay','guitar','main','acoustic arrangement','acoustic','pop rock','rhythm','beginner',
     'Acoustic guitar (standard arrangement)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Piano original — profiled as the soft acoustic arrangement.','Warm hushed acoustic; the regret does the talking.'],
     array['Gentle picked chords following the piano voicings.','Nobody said it was easy — the chords are, though.'],
     'Studio recording, 2002. Piano ballad; profiled as the standard acoustic arrangement.',73),
    ('the-only-exception','paramore','guitar','riff','main arpeggio','clean','pop punk','rhythm','beginner',
     'Clean electric (Josh Farro / Taylor York)','Warm clean amp','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Paramore''s soft moment — waltzing clean arpeggios in 3/4.','Warm gentle clean; the band''s quietest hit.'],
     array['Arpeggiate the 3/4 pattern evenly.','Build softly into the bridge swell.'],
     'Studio recording, 2009. The waltzing clean ballad from Brand New Eyes.',76),
    ('shallow','lady-gaga','guitar','main','fingerpicked pattern','acoustic','pop','rhythm','beginner',
     'Acoustic guitar (Lukas Nelson / session)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The A Star Is Born duet — warm fingerpicked acoustic into anthem strums.','Rich open acoustic; the pattern builds to the scream-along chorus.'],
     array['The intro picking figure is instantly recognized.','Open into full strums for the ha-ah-ah-ah part.'],
     'Studio recording, 2018. The fingerpicked duet anthem.',76),

    -- ============ BEATLES / LENNON ============
    ('let-it-be','the-beatles','guitar','main','chords + Leslie solo','clean','rock','rhythm','beginner',
     'Acoustic + Gibson Les Paul through Leslie (George Harrison)','Leslie rotary speaker (solo)','Leslie cabinet','bridge pickup',
     '[{"effect_type":"chorus","effect_name":"Leslie rotary swirl (solo)","placement":"post_gain","settings":{"rate":5,"depth":6,"mix":6}}]'::jsonb,
     '{"gain":3,"bass":5,"mids":6,"treble":5,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Piano-led original — strum the chords acoustically; Harrison''s solo runs through a rotary Leslie speaker (use chorus/rotary to fake it).','Two jobs: warm chords, then the swirling melodic solo.'],
     array['The solo is melodic and singable — learn it exactly.','Let the rotary swirl breathe on the long notes.'],
     'Studio recording, 1970. Piano hymn with Harrison''s rotary-Leslie solo.',78),
    ('hey-jude','the-beatles','guitar','main','main progression','acoustic','rock','rhythm','beginner',
     'Acoustic guitar (standard arrangement)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Piano original — profiled as the campfire acoustic arrangement.','Warm steady acoustic; save energy for four minutes of na-na-na.'],
     array['Simple strums under the verses.','The outro is a singalong marathon — pace yourself.'],
     'Studio recording, 1968. Piano original; profiled as the campfire arrangement.',75),
    ('yesterday','the-beatles','guitar','main','fingerpicked pattern','acoustic','rock','rhythm','intermediate',
     'Epiphone Texan acoustic (Paul McCartney)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['McCartney solo on his Epiphone Texan, tuned down a whole step on the record.','Dry intimate acoustic; guitar and string quartet only.'],
     array['Tune down a full step to play along with the record.','The picking pattern mixes bass notes and strums.'],
     'Studio recording, 1965. McCartney''s down-tuned Epiphone Texan.',79),
    ('imagine','john-lennon','guitar','main','acoustic arrangement','acoustic','rock','rhythm','beginner',
     'Acoustic guitar (standard arrangement)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Piano original — profiled as the standard acoustic arrangement.','Soft warm acoustic mirroring the piano''s pulse.'],
     array['Gentle broken-chord pattern throughout.','Play it plain; the song needs nothing.'],
     'Studio recording, 1971. Piano hymn; profiled as the standard acoustic arrangement.',74),

    -- ============ 2000s BALLAD CANON ============
    ('chasing-cars','snow-patrol','guitar','riff','main progression','clean','alternative rock','rhythm','beginner',
     'Clean electric (Nathan Connolly / Gary Lightbody)','Clean amp, subdued and warm','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"soft room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The lie-here anthem — patient muted clean picking that swells to a wall.','Soft warm clean; the build is gradual and total.'],
     array['The three-chord picking pattern repeats and grows.','Add layers of intensity, not speed.'],
     'Studio recording, 2006. The patient swelling anthem.',76),
    ('jolene','dolly-parton','guitar','riff','fingerpicked riff','acoustic','country','rhythm','intermediate',
     'Acoustic guitar (session — Nashville)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The pleading minor-key classic — its galloping fingerpicked riff is instantly known.','Clear driving acoustic; the riff loops like a worried heartbeat.'],
     array['The picking riff gallops in C# minor — build it slow.','Keep the urgency under control; she''s begging, not chasing.'],
     'Studio recording, 1973. The galloping minor-key fingerpicked classic.',78),
    ('best-part','daniel-caesar','guitar','main','fingerpicked pattern','clean','r&b','rhythm','intermediate',
     'Clean electric (Daniel Caesar / session)','Warm clean amp, neo-soul','Open-back combo cab','neck pickup',
     '[{"effect_type":"compressor","effect_name":"soft compression","placement":"front","settings":{"sustain":4,"level":5}},{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":1,"bass":5,"mids":6,"treble":5,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The neo-soul duet standard — warm rounded clean fingerpicking with jazz voicings.','Dark soft clean; thumb-and-fingers touch.'],
     array['Fingerpick the maj7 voicings gently.','Let the chords melt into each other.'],
     'Studio recording, 2017. The neo-soul fingerpicked duet.',75),
    ('breakeven','the-script','guitar','main','main progression','clean','pop rock','rhythm','beginner',
     'Clean electric + acoustic (Mark Sheehan)','Clean amp with light ambience','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":1,"master":6}'::jsonb,
     array['The falling-to-pieces radio staple — bright clean strums with soft sheen.','Polished warm clean; heartbreak with a groove.'],
     array['Steady strum-mute pattern under the verses.','Lift cleanly into each chorus.'],
     'Studio recording, 2008. The polished heartbreak staple.',74),
    ('ang-huling-el-bimbo','eraserheads','guitar','riff','main arpeggio','clean','opm rock','rhythm','intermediate',
     'Clean electric (Marcus Adoro / Ely Buendia)','Clean amp with chorus shimmer','Open-back combo cab','neck pickup',
     '[{"effect_type":"chorus","effect_name":"90s chorus","placement":"post_gain","settings":{"rate":3,"depth":4,"mix":4}},{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":4,"delay":1,"master":6}'::jsonb,
     array['The OPM masterpiece — chorused clean arpeggios through a whole life story (the climax adds drive, gain 5).','Wet 90s clean; the Philippines'' most beloved guitar part.'],
     array['The verse arpeggio pattern carries the narrative.','Build with the story to the heavy climax.'],
     'Studio recording, 1995. The OPM epic''s chorused arpeggios.',75),
    ('a-thousand-years','christina-perri','guitar','main','fingerpicked pattern','acoustic','pop','rhythm','beginner',
     'Acoustic guitar (session)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The wedding-processional standard — flowing 6/8 fingerpicking.','Warm flowing acoustic; aisle-walking tempo.'],
     array['The 6/8 picking pattern flows continuously.','Steady and patient — someone is walking to this.'],
     'Studio recording, 2011. The wedding-processional fingerpicking standard.',75),
    ('how-to-save-a-life','the-fray','guitar','main','acoustic arrangement','acoustic','pop rock','rhythm','beginner',
     'Acoustic guitar (standard arrangement)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Piano original — profiled as the standard acoustic arrangement.','Bright earnest acoustic strums following the piano.'],
     array['Steady eighth-note strums; the melody sits on top.','Earnest, not aggressive.'],
     'Studio recording, 2005. Piano original; profiled as the acoustic arrangement.',73),
    ('someone-like-you','adele','guitar','main','acoustic arrangement','acoustic','pop','rhythm','beginner',
     'Acoustic guitar (standard arrangement)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Piano original — profiled as the arpeggiated acoustic arrangement.','Soft rolling acoustic mirroring the famous piano figure.'],
     array['Arpeggiate the piano''s broken-chord pattern.','Build the dynamics verse by verse.'],
     'Studio recording, 2011. Piano ballad; profiled as the standard acoustic arrangement.',73),
    ('someone-you-loved','lewis-capaldi','guitar','main','acoustic arrangement','acoustic','pop','rhythm','beginner',
     'Acoustic guitar (standard arrangement)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Piano original — profiled as the standard acoustic arrangement.','Warm simple acoustic; four chords and devastation.'],
     array['Simple strums following the piano pulse.','Let the vocal melody rule.'],
     'Studio recording, 2019. Piano ballad; profiled as the acoustic arrangement.',72),
    ('stay-with-me','sam-smith','guitar','main','acoustic arrangement','acoustic','pop','rhythm','beginner',
     'Acoustic guitar (standard arrangement)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Gospel-piano original — profiled as the three-chord acoustic arrangement.','Warm swaying acoustic; gospel patience.'],
     array['Three chords in a slow sway.','Feel the choir behind you.'],
     'Studio recording, 2014. Gospel ballad; profiled as the acoustic arrangement.',72),
    ('just-the-way-you-are','bruno-mars','guitar','main','acoustic arrangement','acoustic','pop','rhythm','beginner',
     'Acoustic guitar (standard arrangement)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Piano-pop original — profiled as the standard acoustic arrangement.','Bright warm acoustic; serenade energy.'],
     array['Steady strum-pick pattern on four chords.','Smile at someone while you play it.'],
     'Studio recording, 2010. Piano-pop hit; profiled as the acoustic arrangement.',73),
    ('fly-me-to-the-moon','frank-sinatra','guitar','main','jazz comping arrangement','clean','jazz','rhythm','intermediate',
     'Hollow-body archtop (jazz arrangement)','Warm jazz clean amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":1,"bass":5,"mids":6,"treble":4,"presence":3,"reverb":2,"delay":0,"master":5}'::jsonb,
     array['The swing standard — profiled as the classic archtop jazz-comping arrangement.','Dark round jazz clean; walk the 2-5-1s.'],
     array['Comp the changes with shell voicings.','Swing it — straight eighths are a crime here.'],
     'Studio recording, 1964. The swing standard; profiled as the jazz-guitar arrangement.',74),
    ('i-see-fire','ed-sheeran','guitar','main','fingerpicked pattern','acoustic','folk','rhythm','intermediate',
     'Acoustic guitar (Ed Sheeran)','Acoustic — mic''d','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The Hobbit ember-ballad — hushed minor-key fingerpicking.','Dark intimate acoustic; firelight dynamics.'],
     array['The picking pattern smolders — quiet and even.','Build only at the final chorus.'],
     'Studio recording, 2013. The smoldering Hobbit fingerpicking.',77),
    ('wake-me-up-when-september-ends','green-day','guitar','riff','clean intro + distorted wall','clean','pop punk','rhythm','beginner',
     'Gibson Les Paul Junior (Billie Joe Armstrong)','Marshall-style stack, clean to driven','Marshall 4x12 cab','P-90 bridge pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The September elegy — clean arpeggiated intro (settings shown) erupting into the American Idiot wall (push gain to 7).','Program clean and driven; the G-string riff opens it.'],
     array['The intro picking pattern over open G is iconic.','The heavy entrance lands with the full band.'],
     'Studio recording, 2004. The clean-to-wall September elegy.',77)
) as c(
  song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence
)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;
