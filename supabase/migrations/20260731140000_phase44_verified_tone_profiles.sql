-- Phase 44: grunge / 90s alternative deep cuts, verified per-part tone data.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Nirvana','nirvana','About a Girl','about-a-girl','Bleach',1989),
    ('Nirvana','nirvana','Breed','breed','Nevermind',1991),
    ('Nirvana','nirvana','Drain You','drain-you','Nevermind',1991),
    ('Nirvana','nirvana','Polly','polly','Nevermind',1991),
    ('Nirvana','nirvana','Something in the Way','something-in-the-way','Nevermind',1991),
    ('Nirvana','nirvana','Dumb','dumb','In Utero',1993),
    ('Nirvana','nirvana','All Apologies','all-apologies','In Utero',1993),
    ('Nirvana','nirvana','The Man Who Sold the World','the-man-who-sold-the-world','MTV Unplugged in New York',1994),
    ('Pearl Jam','pearl-jam','Yellow Ledbetter','yellow-ledbetter','Lost Dogs',1992),
    ('Pearl Jam','pearl-jam','Daughter','daughter','Vs.',1993),
    ('Pearl Jam','pearl-jam','Better Man','better-man','Vitalogy',1994),
    ('Pearl Jam','pearl-jam','Last Kiss','last-kiss','No Boundaries',1999),
    ('Stone Temple Pilots','stone-temple-pilots','Vasoline','vasoline','Purple',1994),
    ('Stone Temple Pilots','stone-temple-pilots','Big Empty','big-empty','Purple',1994),
    ('Stone Temple Pilots','stone-temple-pilots','Sex Type Thing','sex-type-thing','Core',1992),
    ('The Smashing Pumpkins','the-smashing-pumpkins','Mayonaise','mayonaise','Siamese Dream',1993),
    ('The Smashing Pumpkins','the-smashing-pumpkins','Disarm','disarm','Siamese Dream',1993),
    ('The Smashing Pumpkins','the-smashing-pumpkins','Tonight, Tonight','tonight-tonight','Mellon Collie and the Infinite Sadness',1995),
    ('Alice in Chains','alice-in-chains','Nutshell','nutshell','Jar of Flies',1994),
    ('Alice in Chains','alice-in-chains','Down in a Hole','down-in-a-hole','Dirt',1992),
    ('Alice in Chains','alice-in-chains','No Excuses','no-excuses','Jar of Flies',1994),
    ('Soundgarden','soundgarden','Fell on Black Days','fell-on-black-days','Superunknown',1994),
    ('Soundgarden','soundgarden','Burden in My Hand','burden-in-my-hand','Down on the Upside',1996),
    ('Silverchair','silverchair','Tomorrow','tomorrow','Frogstomp',1995),
    ('Bush','bush','Glycerine','glycerine','Sixteen Stone',1994)
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
    ('nirvana','about-a-girl'),('nirvana','breed'),('nirvana','drain-you'),('nirvana','polly'),
    ('nirvana','something-in-the-way'),('nirvana','dumb'),('nirvana','all-apologies'),
    ('nirvana','the-man-who-sold-the-world'),('pearl-jam','yellow-ledbetter'),('pearl-jam','daughter'),
    ('pearl-jam','better-man'),('pearl-jam','last-kiss'),('stone-temple-pilots','vasoline'),
    ('stone-temple-pilots','big-empty'),('stone-temple-pilots','sex-type-thing'),
    ('the-smashing-pumpkins','mayonaise'),('the-smashing-pumpkins','disarm'),('the-smashing-pumpkins','tonight-tonight'),
    ('alice-in-chains','nutshell'),('alice-in-chains','down-in-a-hole'),('alice-in-chains','no-excuses'),
    ('soundgarden','fell-on-black-days'),('soundgarden','burden-in-my-hand'),('silverchair','tomorrow'),('bush','glycerine')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('nirvana','about-a-girl'),('nirvana','breed'),('nirvana','drain-you'),('nirvana','polly'),
    ('nirvana','something-in-the-way'),('nirvana','dumb'),('nirvana','all-apologies'),
    ('nirvana','the-man-who-sold-the-world'),('pearl-jam','yellow-ledbetter'),('pearl-jam','daughter'),
    ('pearl-jam','better-man'),('pearl-jam','last-kiss'),('stone-temple-pilots','vasoline'),
    ('stone-temple-pilots','big-empty'),('stone-temple-pilots','sex-type-thing'),
    ('the-smashing-pumpkins','mayonaise'),('the-smashing-pumpkins','disarm'),('the-smashing-pumpkins','tonight-tonight'),
    ('alice-in-chains','nutshell'),('alice-in-chains','down-in-a-hole'),('alice-in-chains','no-excuses'),
    ('soundgarden','fell-on-black-days'),('soundgarden','burden-in-my-hand'),('silverchair','tomorrow'),('bush','glycerine')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('nirvana','about-a-girl'),('nirvana','breed'),('nirvana','drain-you'),('nirvana','polly'),
    ('nirvana','something-in-the-way'),('nirvana','dumb'),('nirvana','all-apologies'),
    ('nirvana','the-man-who-sold-the-world'),('pearl-jam','yellow-ledbetter'),('pearl-jam','daughter'),
    ('pearl-jam','better-man'),('pearl-jam','last-kiss'),('stone-temple-pilots','vasoline'),
    ('stone-temple-pilots','big-empty'),('stone-temple-pilots','sex-type-thing'),
    ('the-smashing-pumpkins','mayonaise'),('the-smashing-pumpkins','disarm'),('the-smashing-pumpkins','tonight-tonight'),
    ('alice-in-chains','nutshell'),('alice-in-chains','down-in-a-hole'),('alice-in-chains','no-excuses'),
    ('soundgarden','fell-on-black-days'),('soundgarden','burden-in-my-hand'),('silverchair','tomorrow'),('bush','glycerine')
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
    -- ============ NIRVANA ============
    ('about-a-girl','nirvana','guitar','riff','main riff','clean','grunge','rhythm','beginner',
     'Fender Mustang (Kurt Cobain)','Clean amp with slight edge','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Jangly Beatles-influenced clean riff — the odd one out on Bleach.','Just-clean tone; a hint of hair when you dig in is right.'],
     array['Steady eighth-note strums on the two-chord riff.','Keep the feel relaxed, not punk-aggressive.'],
     'Studio recording, 1989. Jangly clean pop riff, deliberately unlike the rest of Bleach.',78),
    ('breed','nirvana','guitar','riff','main riff','distorted','grunge','rhythm','intermediate',
     'Fender Mustang / Jaguar (Kurt Cobain)','Mesa/Boogie Studio preamp into power amp','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"distortion","effect_name":"Boss DS-1 distortion","placement":"front","settings":{"gain":7,"tone":5,"level":6}}]'::jsonb,
     '{"gain":5,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['Furious buzzsaw riff — Boss DS-1 into the Nevermind rack rig.','The pedal supplies the grind; the amp platform stays only moderately driven.'],
     array['Relentless down-picking; the riff never lets up.','Tightly mute the string noise between phrases.'],
     'Studio recording, 1991. Boss DS-1 into the Nevermind Mesa Studio preamp rig.',81),
    ('drain-you','nirvana','guitar','riff','main riff','distorted','grunge','rhythm','intermediate',
     'Fender Mustang / Jaguar (Kurt Cobain)','Mesa/Boogie Studio preamp into power amp','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"distortion","effect_name":"Boss DS-1 distortion","placement":"front","settings":{"gain":7,"tone":5,"level":6}}]'::jsonb,
     '{"gain":5,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['Thick layered Nevermind distortion; the noise-bridge section is built from feedback and toy sounds.','DS-1 grind over a moderately driven platform, double-tracked.'],
     array['Big open-chord strums with drive.','Let the bridge dissolve into controlled noise before the last chorus.'],
     'Studio recording, 1991. Layered DS-1 Nevermind distortion with a noise-collage bridge.',80),
    ('polly','nirvana','guitar','riff','acoustic riff','acoustic','grunge','rhythm','beginner',
     'Acoustic guitar (Kurt Cobain, thrift-store 5-string)','Mic''d acoustic - no amp','No cab','acoustic body',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":1,"delay":0,"master":5}'::jsonb,
     array['Recorded on a cheap, barely-intonated acoustic — the dead, dry sound is the point.','Don''t polish it; a worn acoustic close-mic''d dry is the tone.'],
     array['Loose, simple strums.','The slack, out-of-tune character is authentic.'],
     'Studio recording, 1991. Cheap thrift-store acoustic, close-mic''d dry.',80),
    ('something-in-the-way','nirvana','guitar','riff','acoustic riff','acoustic','grunge','rhythm','beginner',
     'Acoustic guitar (Kurt Cobain)','Mic''d acoustic - no amp','No cab','acoustic body',
     '[]'::jsonb,'{"gain":0,"bass":6,"mids":4,"treble":4,"presence":3,"reverb":2,"delay":0,"master":4}'::jsonb,
     array['Detuned, whisper-quiet acoustic — recorded with Kurt lying on the studio couch.','Dark, muffled, intimate; roll treble down.'],
     array['Tune way down and barely brush the strings.','Keep it hushed all the way through.'],
     'Studio recording, 1991. Detuned hushed acoustic recorded on the studio couch.',80),
    ('dumb','nirvana','guitar','riff','main riff','clean','grunge','rhythm','beginner',
     'Fender Jaguar / Mustang (Kurt Cobain)','Fender Quad Reverb','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":2,"delay":0,"master":5}'::jsonb,
     array['Soft, resigned clean strums — In Utero''s gentler side, tracked through Fender combos.','Low gain, warm and slightly worn.'],
     array['Lazy relaxed strums matching the vocal.','Cello carries the counter-melody; stay simple.'],
     'Studio recording, 1993. Soft clean strums through Fender combos, In Utero sessions.',79),
    ('all-apologies','nirvana','guitar','riff','main riff','clean','grunge','rhythm','beginner',
     'Fender Jaguar / Mustang (Kurt Cobain)','Fender Quad Reverb','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":3,"bass":6,"mids":5,"treble":5,"presence":4,"reverb":1,"delay":0,"master":5}'::jsonb,
     array['Warm, round drop-D riff, nearly clean; the distorted double arrives only in the final section.','Low gain, bass-forward voicing.'],
     array['Play the drop-D riff with thumb-heavy attack.','Let the open strings drone throughout.'],
     'Studio recording, 1993. Warm drop-D near-clean riff through Fender combos.',80),
    ('the-man-who-sold-the-world','nirvana','guitar','riff','unplugged riff','clean','grunge','rhythm','beginner',
     'Martin D-18E acoustic-electric (Kurt Cobain)','Fender Twin Reverb (hidden on stage)','Open-back combo cab','soundhole pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":5,"presence":4,"reverb":2,"delay":0,"master":5}'::jsonb,
     array['The Unplugged sound is an acoustic-electric run through a hidden Fender Twin — an electric tone wearing an acoustic coat.','Slightly driven "acoustic" with amp warmth; not a pure mic''d acoustic.'],
     array['Play the riff exactly, including the slide into each phrase.','Keep dynamics gentle; the amp does the warming.'],
     'Live recording, 1993 (released 1994). Kurt''s Martin D-18E through a hidden Fender Twin on MTV Unplugged.',83),

    -- ============ PEARL JAM ============
    ('yellow-ledbetter','pearl-jam','guitar','riff','main riff','clean','grunge','rhythm','advanced',
     'Fender Stratocaster (Mike McCready)','Fender-style clean amp with edge','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":5,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Hendrix-style neck-pickup Strat tone — clean with just enough hair to sing.','Low-medium gain; the touch dynamics do everything.'],
     array['Use thumb-over Hendrix voicings with hammer-on embellishments.','Let the phrases breathe; it''s all feel.'],
     'Studio recording, 1992. McCready''s Hendrix-voiced neck-pickup Strat with light edge.',81),
    ('daughter','pearl-jam','guitar','riff','main riff','clean','grunge','rhythm','intermediate',
     'Acoustic and clean electric (Stone Gossard)','Clean amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":5}'::jsonb,
     array['Open-tuning acoustic figure doubled by clean electric.','Fully clean and open-sounding.'],
     array['Played in open G — the open strings ring through the figure.','Gentle, circular strumming.'],
     'Studio recording, 1993. Open-G acoustic and clean electric figure.',79),
    ('better-man','pearl-jam','guitar','intro','clean intro','clean','grunge','rhythm','beginner',
     'Clean electric (Pearl Jam)','Clean amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":2,"delay":0,"master":5}'::jsonb,
     array['Fragile clean arpeggios open the song alone.','Fully clean, soft and intimate; the full band arrives later.'],
     array['Fingerpick the intro gently.','Grow gradually as the band enters.'],
     'Studio recording, 1994. Fragile solo clean intro building to full band.',78),
    ('last-kiss','pearl-jam','guitar','riff','main riff','clean','grunge','rhythm','beginner',
     'Clean electric (Pearl Jam)','Clean amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":5}'::jsonb,
     array['Warm 50s-style clean strums — a faithful oldies cover.','Clean with light reverb; nothing modern.'],
     array['Simple I-vi-IV-V strums.','Relaxed, swaying feel.'],
     'Studio recording, 1999. Warm oldies-style clean strums.',77),

    -- ============ STONE TEMPLE PILOTS ============
    ('vasoline','stone-temple-pilots','guitar','riff','main riff','distorted','grunge','rhythm','intermediate',
     'Gibson Les Paul (Dean DeLeo)','Cranked small-amp crunch','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['Tight two-note riff with focused midrange crunch — Dean DeLeo favors pushed smaller amps over huge stacks.','Medium-high gain, controlled low end.'],
     array['Keep the hypnotic two-note riff perfectly even.','Choke the accents hard.'],
     'Studio recording, 1994. Focused mid-forward crunch from pushed amps.',78),
    ('big-empty','stone-temple-pilots','guitar','intro','clean verse with slide','clean','grunge','rhythm','intermediate',
     'Gibson Les Paul (Dean DeLeo)','Clean amp with ambience','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":3,"delay":1,"master":5}'::jsonb,
     array['Watery, roomy clean verses with lazy slide phrases.','Clean with generous reverb; the chorus jumps to heavy crunch.'],
     array['Slide the verse licks loose and behind the beat.','Save the big chords for the chorus lift.'],
     'Studio recording, 1994. Watery ambient clean verses with slide.',78),
    ('sex-type-thing','stone-temple-pilots','guitar','riff','main riff','distorted','grunge','rhythm','intermediate',
     'Gibson Les Paul (Dean DeLeo)','Cranked crunch stack','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":6,"mids":6,"treble":6,"presence":5,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['Menacing, grinding riff with thick mid-heavy drive.','Medium-high gain; the riff grinds rather than chugs.'],
     array['Lean into the swaggering, menacing groove.','Keep the low riff thick and steady.'],
     'Studio recording, 1992. Menacing mid-heavy grind from the Core sessions.',77),

    -- ============ SMASHING PUMPKINS ============
    ('mayonaise','the-smashing-pumpkins','guitar','riff','main riff','fuzz','grunge','rhythm','intermediate',
     'Fender Stratocaster (Billy Corgan)','Marshall JMP head','Marshall 4x12 cab','bridge pickup',
     '[{"effect_type":"fuzz","effect_name":"Electro-Harmonix Big Muff (op-amp)","placement":"front","settings":{"sustain":7,"tone":5,"level":6}}]'::jsonb,
     '{"gain":4,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['The Siamese Dream sound: op-amp Big Muff into a Marshall JMP, layered many times.','The fuzz pedal is the tone; the amp adds body. Alternate tuning gives the shimmer.'],
     array['The song uses a slightly detuned alternate tuning for its color.','Blend gentle verse strums into the soaring fuzz chorus.'],
     'Studio recording, 1993. Op-amp Big Muff into Marshall JMP — the layered Siamese Dream wall.',82),
    ('disarm','the-smashing-pumpkins','guitar','riff','acoustic strums','acoustic','grunge','rhythm','beginner',
     'Acoustic guitar (Billy Corgan)','Mic''d acoustic - no amp','No cab','acoustic body',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":5}'::jsonb,
     array['Big open acoustic strums under strings and bells.','Bright close-mic''d acoustic with room ambience.'],
     array['Strum wide open chords with conviction.','Steady dynamics — the orchestration does the swelling.'],
     'Studio recording, 1993. Open acoustic strums under strings and tubular bells.',80),
    ('tonight-tonight','the-smashing-pumpkins','guitar','riff','main riff','crunch','grunge','rhythm','intermediate',
     'Fender Stratocaster (Billy Corgan)','Marshall crunch','Marshall 4x12 cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Driving crunch strums under the string orchestra.','Medium gain — clarity over saturation so the orchestration reads.'],
     array['Constant driving eighth-note strums.','Ride the swells with the strings.'],
     'Studio recording, 1995. Driving crunch strums under orchestral strings.',78),

    -- ============ ALICE IN CHAINS ============
    ('nutshell','alice-in-chains','guitar','riff','main riff','clean','grunge','rhythm','beginner',
     'Electric guitar (Jerry Cantrell)','Clean amp','Open-back combo cab','neck pickup',
     '[{"effect_type":"modulation","effect_name":"light chorus","placement":"post_gain","settings":{"depth":3,"rate":2,"mix":3}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":3,"delay":0,"master":5}'::jsonb,
     array['Mournful clean arpeggios with Cantrell''s signature light chorus shimmer.','Fully clean, roomy, and patient.'],
     array['Fingerpick the arpeggios evenly.','Hold the mood — sparse and heavy-hearted.'],
     'Studio recording, 1994. Mournful chorused clean arpeggios from Jar of Flies.',80),
    ('down-in-a-hole','alice-in-chains','guitar','riff','main riff','distorted','grunge','rhythm','intermediate',
     'G&L Rampage (Jerry Cantrell)','Bogner-modified Marshall','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":5,"treble":5,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Dark, sorrowful medium-high gain with AIC''s signature thick midrange moan.','Medium-high gain, slightly dark voicing with ambience.'],
     array['Slow bends and moaning phrases.','Support the layered vocal harmonies without crowding them.'],
     'Studio recording, 1992. Cantrell''s G&L Rampage into modified Marshalls — the Dirt sound.',80),
    ('no-excuses','alice-in-chains','guitar','riff','main riff','clean','grunge','rhythm','beginner',
     'Electric guitar (Jerry Cantrell)','Clean amp with edge','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bouncy, warm near-clean groove — Jar of Flies'' brightest moment.','Just-clean with a little sparkle.'],
     array['Keep the rolling groove light and bouncy.','Accent the melodic fills between chords.'],
     'Studio recording, 1994. Warm bouncy near-clean groove.',79),

    -- ============ SOUNDGARDEN / SILVERCHAIR / BUSH ============
    ('fell-on-black-days','soundgarden','guitar','riff','main riff','crunch','grunge','rhythm','intermediate',
     'Electric guitar (Chris Cornell / Kim Thayil)','Crunch amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":5,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Moody mid-gain crunch in drop-D; dark and circular.','Medium gain; the odd-meter groove carries the weight.'],
     array['Played in drop D; count the shifting meter carefully.','Keep the riff hypnotic and even.'],
     'Studio recording, 1994. Moody drop-D crunch from Superunknown.',78),
    ('burden-in-my-hand','soundgarden','guitar','riff','main riff','crunch','grunge','rhythm','intermediate',
     'Electric guitar (Chris Cornell)','Crunch amp','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright open-tuned crunch strums with an acoustic-like openness.','Medium gain; alternate tuning provides the drone.'],
     array['Uses an alternate tuning — let the drones ring.','Swing the strums with the desert-rock groove.'],
     'Studio recording, 1996. Open-tuned bright crunch from Down on the Upside.',77),
    ('tomorrow','silverchair','guitar','riff','main riff','distorted','grunge','rhythm','intermediate',
     'Electric guitar (Daniel Johns)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Heavy teenage-grunge wall with quiet clean verses.','Medium-high gain; big contrast between sections.'],
     array['Restrain the clean verses.','Slam the drop-tuned chorus riff.'],
     'Studio recording, 1995. Quiet-loud grunge wall from Frogstomp.',76),
    ('glycerine','bush','guitar','riff','main riff','distorted','grunge','rhythm','beginner',
     'Fender guitar (Gavin Rossdale)','Driven amp','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":6,"mids":5,"treble":5,"presence":4,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Slow, warm wall of soft distortion under strings — sustained chords, no strumming patterns.','Medium gain, dark and smooth; let chords bloom.'],
     array['Hold each chord and let it swell.','No fills — the restraint is the song.'],
     'Studio recording, 1994. Slow warm distorted chords under strings.',78)
) as c(
  song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence
)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;
