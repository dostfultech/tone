-- Phase 45: indie rock deep cuts, verified per-part tone data.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Arctic Monkeys','arctic-monkeys','Arabella','arabella','AM',2013),
    ('Arctic Monkeys','arctic-monkeys','Crying Lightning','crying-lightning','Humbug',2009),
    ('Arctic Monkeys','arctic-monkeys','Mardy Bum','mardy-bum','Whatever People Say I Am, That''s What I''m Not',2006),
    ('Arctic Monkeys','arctic-monkeys','Teddy Picker','teddy-picker','Favourite Worst Nightmare',2007),
    ('Arctic Monkeys','arctic-monkeys','Snap Out of It','snap-out-of-it','AM',2013),
    ('The Strokes','the-strokes','Hard to Explain','hard-to-explain','Is This It',2001),
    ('The Strokes','the-strokes','You Only Live Once','you-only-live-once','First Impressions of Earth',2006),
    ('The Strokes','the-strokes','Juicebox','juicebox','First Impressions of Earth',2006),
    ('The Strokes','the-strokes','Under Cover of Darkness','under-cover-of-darkness','Angles',2011),
    ('The White Stripes','the-white-stripes','Fell in Love with a Girl','fell-in-love-with-a-girl','White Blood Cells',2001),
    ('The White Stripes','the-white-stripes','Dead Leaves and the Dirty Ground','dead-leaves-and-the-dirty-ground','White Blood Cells',2001),
    ('The White Stripes','the-white-stripes','Blue Orchid','blue-orchid','Get Behind Me Satan',2005),
    ('The White Stripes','the-white-stripes','Icky Thump','icky-thump','Icky Thump',2007),
    ('Interpol','interpol','Obstacle 1','obstacle-1','Turn On the Bright Lights',2002),
    ('Interpol','interpol','Slow Hands','slow-hands','Antics',2004),
    ('Interpol','interpol','PDA','pda','Turn On the Bright Lights',2002),
    ('The Killers','the-killers','Read My Mind','read-my-mind','Sam''s Town',2006),
    ('The Killers','the-killers','Smile Like You Mean It','smile-like-you-mean-it','Hot Fuss',2004),
    ('Bloc Party','bloc-party','Banquet','banquet','Silent Alarm',2005),
    ('Bloc Party','bloc-party','Helicopter','helicopter','Silent Alarm',2005),
    ('Bloc Party','bloc-party','This Modern Love','this-modern-love','Silent Alarm',2005),
    ('Vampire Weekend','vampire-weekend','Oxford Comma','oxford-comma','Vampire Weekend',2008),
    ('Vampire Weekend','vampire-weekend','Cape Cod Kwassa Kwassa','cape-cod-kwassa-kwassa','Vampire Weekend',2008),
    ('Vampire Weekend','vampire-weekend','Cousins','cousins','Contra',2010),
    ('Yeah Yeah Yeahs','yeah-yeah-yeahs','Maps','maps','Fever to Tell',2003)
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
    ('arctic-monkeys','arabella'),('arctic-monkeys','crying-lightning'),('arctic-monkeys','mardy-bum'),
    ('arctic-monkeys','teddy-picker'),('arctic-monkeys','snap-out-of-it'),('the-strokes','hard-to-explain'),
    ('the-strokes','you-only-live-once'),('the-strokes','juicebox'),('the-strokes','under-cover-of-darkness'),
    ('the-white-stripes','fell-in-love-with-a-girl'),('the-white-stripes','dead-leaves-and-the-dirty-ground'),
    ('the-white-stripes','blue-orchid'),('the-white-stripes','icky-thump'),('interpol','obstacle-1'),
    ('interpol','slow-hands'),('interpol','pda'),('the-killers','read-my-mind'),('the-killers','smile-like-you-mean-it'),
    ('bloc-party','banquet'),('bloc-party','helicopter'),('bloc-party','this-modern-love'),
    ('vampire-weekend','oxford-comma'),('vampire-weekend','cape-cod-kwassa-kwassa'),('vampire-weekend','cousins'),
    ('yeah-yeah-yeahs','maps')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('arctic-monkeys','arabella'),('arctic-monkeys','crying-lightning'),('arctic-monkeys','mardy-bum'),
    ('arctic-monkeys','teddy-picker'),('arctic-monkeys','snap-out-of-it'),('the-strokes','hard-to-explain'),
    ('the-strokes','you-only-live-once'),('the-strokes','juicebox'),('the-strokes','under-cover-of-darkness'),
    ('the-white-stripes','fell-in-love-with-a-girl'),('the-white-stripes','dead-leaves-and-the-dirty-ground'),
    ('the-white-stripes','blue-orchid'),('the-white-stripes','icky-thump'),('interpol','obstacle-1'),
    ('interpol','slow-hands'),('interpol','pda'),('the-killers','read-my-mind'),('the-killers','smile-like-you-mean-it'),
    ('bloc-party','banquet'),('bloc-party','helicopter'),('bloc-party','this-modern-love'),
    ('vampire-weekend','oxford-comma'),('vampire-weekend','cape-cod-kwassa-kwassa'),('vampire-weekend','cousins'),
    ('yeah-yeah-yeahs','maps')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('arctic-monkeys','arabella'),('arctic-monkeys','crying-lightning'),('arctic-monkeys','mardy-bum'),
    ('arctic-monkeys','teddy-picker'),('arctic-monkeys','snap-out-of-it'),('the-strokes','hard-to-explain'),
    ('the-strokes','you-only-live-once'),('the-strokes','juicebox'),('the-strokes','under-cover-of-darkness'),
    ('the-white-stripes','fell-in-love-with-a-girl'),('the-white-stripes','dead-leaves-and-the-dirty-ground'),
    ('the-white-stripes','blue-orchid'),('the-white-stripes','icky-thump'),('interpol','obstacle-1'),
    ('interpol','slow-hands'),('interpol','pda'),('the-killers','read-my-mind'),('the-killers','smile-like-you-mean-it'),
    ('bloc-party','banquet'),('bloc-party','helicopter'),('bloc-party','this-modern-love'),
    ('vampire-weekend','oxford-comma'),('vampire-weekend','cape-cod-kwassa-kwassa'),('vampire-weekend','cousins'),
    ('yeah-yeah-yeahs','maps')
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
    -- ============ ARCTIC MONKEYS ============
    ('arabella','arctic-monkeys','guitar','riff','main riff','distorted','indie rock','rhythm','intermediate',
     'Humbucker electric (Alex Turner / Jamie Cook)','Vox AC30-style amp pushed hard','Open-back 2x12 cab','bridge humbucker',
     '[{"effect_type":"fuzz","effect_name":"fuzz pedal","placement":"front","settings":{"gain":6,"tone":5,"level":6}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":6,"treble":5,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Thick fuzzy AM-era riff — Sabbath-flavored bends with a modern polish.','Fuzz into a British chime amp; keep mids present, not scooped.'],
     array['The chorus riff leans on half-step bends — land them in tune.','The Hendrix-style outro licks want looser, vocal phrasing.'],
     'Studio recording, 2013. Fuzzy Sabbath-leaning riff from the AM sessions.',73),
    ('crying-lightning','arctic-monkeys','guitar','riff','main riff','crunch','indie rock','rhythm','intermediate',
     'Solid-body electric (Alex Turner)','British tube amp with dark crunch','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":6,"mids":5,"treble":4,"presence":4,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Dark desert-rock crunch from the Josh Homme-produced Humbug sessions.','Roll treble back — this tone is rounder and murkier than early AM.'],
     array['The verse rides the bass line; guitar stabs stay sparse.','Dig into the swung chorus riff.'],
     'Studio recording, 2009. Dark desert crunch, produced by Josh Homme in the Mojave.',72),
    ('mardy-bum','arctic-monkeys','guitar','riff','main riff','crunch','indie rock','rhythm','beginner',
     'Solid-body electric (Alex Turner / Jamie Cook)','British crunch amp','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bouncy, bright light crunch — cheeky and clean-edged.','Low-medium gain; chords should stay articulate.'],
     array['Skank the upstroke rhythm lightly.','The lead fills are melodic and simple — sing them.'],
     'Studio recording, 2006. Bright bouncy light crunch from the debut album.',71),
    ('teddy-picker','arctic-monkeys','guitar','riff','main riff','crunch','indie rock','rhythm','intermediate',
     'Solid-body electric (Alex Turner / Jamie Cook)','British crunch amp pushed','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Gritty strutting riff — tighter and punchier than the debut record.','Medium gain with strong attack; palm muting does the shaping.'],
     array['Lock the descending riff with the bass.','Snap the muted verse groove hard.'],
     'Studio recording, 2007. Punchy gritty riff from Favourite Worst Nightmare.',72),
    ('snap-out-of-it','arctic-monkeys','guitar','riff','main riff','crunch','indie rock','rhythm','beginner',
     'Humbucker electric (Jamie Cook)','Vox AC30-style amp with grit','Open-back 2x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":5,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Rolling piano-backed groove with warm mid-gain stabs.','AM-era polish: warm, compressed, never harsh.'],
     array['Stay in the pocket — the groove is the song.','Keep chord stabs short and confident.'],
     'Studio recording, 2013. Warm mid-gain groove from AM.',72),

    -- ============ THE STROKES ============
    ('hard-to-explain','the-strokes','guitar','riff','main riff','crunch','indie rock','rhythm','intermediate',
     'Fender Stratocaster (Albert Hammond Jr.)','Direct/amp-sim style compressed drive (Is This It production)','Small combo cab','bridge single-coil',
     '[{"effect_type":"compressor","effect_name":"heavy studio compression","placement":"post_gain","settings":{"sustain":7,"level":6}}]'::jsonb,
     '{"gain":4,"bass":4,"mids":7,"treble":6,"presence":4,"reverb":0,"delay":0,"master":6}'::jsonb,
     array['The Is This It sound: flat, boxy, heavily compressed mid-forward drive — deliberately lo-fi.','Cut lows, push mids, squash it with compression; no reverb at all.'],
     array['Machine-tight eighth-note downstrokes throughout.','Both guitars interlock — keep your part metronomic.'],
     'Studio recording, 2001. Gordon Raphael''s deliberately boxy, compressed Is This It production.',76),
    ('you-only-live-once','the-strokes','guitar','riff','main riff','clean','indie rock','rhythm','beginner',
     'Epiphone Riviera P-94 (Nick Valensi)','Fender tube combo, edge of breakup','Open-back combo cab','P-90 bridge pickup',
     '[{"effect_type":"compressor","effect_name":"light compression","placement":"front","settings":{"sustain":4,"level":5}}]'::jsonb,
     '{"gain":3,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Chiming just-clean P-90 arpeggio hook.','Edge-of-breakup: clean until you dig in.'],
     array['Let the opening chord arpeggios ring evenly.','Palm-mute the verse chug lightly.'],
     'Studio recording, 2006. Valensi''s P-90 Riviera chime into a Fender combo.',77),
    ('juicebox','the-strokes','guitar','riff','main riff','distorted','indie rock','rhythm','intermediate',
     'Epiphone Riviera P-94 (Nick Valensi)','Fender tube combo pushed into drive','Open-back combo cab','P-90 bridge pickup',
     '[{"effect_type":"distortion","effect_name":"drive pedal","placement":"front","settings":{"gain":6,"tone":5,"level":6}}]'::jsonb,
     '{"gain":6,"bass":6,"mids":6,"treble":5,"presence":5,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['Menacing surf-noir riff — the heaviest Strokes tone.','More aggressive than the early records but still mid-focused, not scooped.'],
     array['The octave riff wants precision, not sloppiness.','Choke the strings between stabs.'],
     'Studio recording, 2006. The Strokes at their heaviest — driven P-90 menace.',75),
    ('under-cover-of-darkness','the-strokes','guitar','lead','lead hook','crunch','indie rock','lead','intermediate',
     'Fender Stratocaster (Albert Hammond Jr. / Nick Valensi)','Fender tube combo with light drive','Open-back combo cab','bridge single-coil',
     '[]'::jsonb,'{"gain":4,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright interlocking dual-lead lines — classic Strokes counterpoint, cleaner production than 2001.','Light crunch with treble sparkle; the notes must separate.'],
     array['Two lead lines weave — learn both parts to hear the conversation.','Keep string bends quick and precise.'],
     'Studio recording, 2011. Bright interlocking Strat leads from Angles.',74),

    -- ============ THE WHITE STRIPES ============
    ('fell-in-love-with-a-girl','the-white-stripes','guitar','riff','main riff','fuzz','garage rock','rhythm','beginner',
     '1964 Airline JB Hutto (Jack White)','Fender Twin-style amp cranked with fuzz','Open-back 2x12 cab','bridge pickup',
     '[{"effect_type":"fuzz","effect_name":"Big Muff-style fuzz","placement":"front","settings":{"gain":7,"tone":5,"level":6}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['Raw garage fuzz blast — Airline plastic guitar into Big Muff.','Loose and explosive; precision is not the point.'],
     array['Full-arm strums, maximum energy, 1:50 of chaos.','Don''t clean it up — the rawness is the tone.'],
     'Studio recording, 2001. Jack White''s Airline into Big Muff fuzz, recorded fast and raw.',79),
    ('dead-leaves-and-the-dirty-ground','the-white-stripes','guitar','riff','main riff','fuzz','garage rock','rhythm','intermediate',
     '1964 Airline JB Hutto (Jack White)','Fender Twin-style amp cranked with fuzz','Open-back 2x12 cab','bridge pickup',
     '[{"effect_type":"fuzz","effect_name":"Big Muff-style fuzz","placement":"front","settings":{"gain":7,"tone":5,"level":6}}]'::jsonb,
     '{"gain":6,"bass":6,"mids":6,"treble":5,"presence":5,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['Slow-grinding open-tuned fuzz riff.','Big Muff sustain with the amp doing some of the work.'],
     array['Open A tuning on the record — slide-friendly.','Let the big chords decay naturally between phrases.'],
     'Studio recording, 2001. Grinding open-tuned Big Muff riff from White Blood Cells.',78),
    ('blue-orchid','the-white-stripes','guitar','riff','main riff','fuzz','garage rock','rhythm','intermediate',
     '1964 Airline JB Hutto (Jack White)','Driven amp with octave-up effect','Open-back cab','bridge pickup',
     '[{"effect_type":"pitch","effect_name":"DigiTech Whammy (octave up)","placement":"front","settings":{"mode":"octave_up","mix":10}},{"effect_type":"fuzz","effect_name":"Big Muff-style fuzz","placement":"front","settings":{"gain":7,"tone":6,"level":6}}]'::jsonb,
     '{"gain":6,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['The signature squealing tone is a Whammy pedal set to octave-up feeding fuzz.','Without a Whammy, play the riff an octave up with fuzz — the pedal is the sound.'],
     array['Stuttering disco-riff rhythm — tight sixteenth pickup.','The octave-up squeal should feel synthetic; that''s correct.'],
     'Studio recording, 2005. Whammy octave-up into fuzz — the defining Blue Orchid squeal.',80),
    ('icky-thump','the-white-stripes','guitar','riff','main riff','fuzz','garage rock','rhythm','advanced',
     '1964 Airline JB Hutto (Jack White)','Cranked tube amp with fuzz and octave effects','Open-back 2x12 cab','bridge pickup',
     '[{"effect_type":"fuzz","effect_name":"Big Muff-style fuzz","placement":"front","settings":{"gain":8,"tone":5,"level":6}},{"effect_type":"pitch","effect_name":"DigiTech Whammy","placement":"front","settings":{"mode":"dive_effects","mix":8}}]'::jsonb,
     '{"gain":7,"bass":6,"mids":6,"treble":6,"presence":5,"reverb":0,"delay":0,"master":7}'::jsonb,
     array['Heavy squalling fuzz riff with Whammy dive-bomb interjections.','Thick fuzz foundation; the pitch chaos is pedal-driven, not amp-driven.'],
     array['The main riff is rhythmically tricky — count it slow first.','The solo squeals use Whammy sweeps; improvise the chaos.'],
     'Studio recording, 2007. Heavy fuzz with Whammy pitch chaos from the Icky Thump sessions.',78),

    -- ============ INTERPOL ============
    ('obstacle-1','interpol','guitar','riff','main riff','crunch','indie rock','rhythm','intermediate',
     'Hollow-body electric (Daniel Kessler)','Bright tube amp, edge of breakup','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":4,"mids":5,"treble":7,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['Icy, bright edge-of-breakup jangle — hollow-body sparkle with urgency.','Treble-forward, low gain; aggression comes from the picking hand.'],
     array['Hard, insistent downstrokes on the high-string figures.','Keep both guitar parts stark and separated.'],
     'Studio recording, 2002. Bright urgent jangle from Turn On the Bright Lights.',72),
    ('slow-hands','interpol','guitar','riff','main riff','crunch','indie rock','rhythm','intermediate',
     'Hollow-body electric (Daniel Kessler)','Bright tube amp with light drive','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":5,"treble":7,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Taut dancey post-punk drive — bright and wiry.','Light crunch; the staccato rhythm supplies the energy.'],
     array['Choke the staccato chords precisely.','Lock with the hi-hat, not the kick.'],
     'Studio recording, 2004. Wiry dance-punk drive from Antics.',72),
    ('pda','interpol','guitar','riff','main riff','crunch','indie rock','rhythm','intermediate',
     'Hollow-body electric (Daniel Kessler)','Bright tube amp pushed','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":4,"mids":5,"treble":7,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['Driving bright wall — relentless eighth-note momentum.','More gain than Obstacle 1 but still trebly and cold.'],
     array['Relentless eighth notes; build the outro layer by layer.','Precision over aggression.'],
     'Studio recording, 2002. Driving bright post-punk wall.',71),

    -- ============ THE KILLERS ============
    ('read-my-mind','the-killers','guitar','riff','verse arpeggio','clean','indie rock','rhythm','beginner',
     'Solid-body electric (Dave Keuning)','Chimey British-voiced amp','Open-back 2x12 cab','bridge pickup',
     '[{"effect_type":"delay","effect_name":"dotted-eighth digital delay","placement":"post_gain","settings":{"time":5,"mix":4,"feedback":4}},{"effect_type":"reverb","effect_name":"plate reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":3,"bass":5,"mids":5,"treble":6,"presence":6,"reverb":3,"delay":4,"master":6}'::jsonb,
     array['Shimmering U2-style arpeggios — the delay is part of the riff.','Set delay to dotted eighths; clean with just a hint of hair.'],
     array['Play sparse arpeggios and let the delay fill the space.','Timing with the delay repeats matters more than speed.'],
     'Studio recording, 2006. Shimmering delay-driven arpeggios from Sam''s Town.',72),
    ('smile-like-you-mean-it','the-killers','guitar','riff','main riff','clean','indie rock','rhythm','beginner',
     'Solid-body electric (Dave Keuning)','Chimey British-voiced amp','Open-back 2x12 cab','bridge pickup',
     '[{"effect_type":"delay","effect_name":"digital delay","placement":"post_gain","settings":{"time":4,"mix":3,"feedback":3}}]'::jsonb,
     '{"gain":3,"bass":5,"mids":5,"treble":7,"presence":6,"reverb":2,"delay":3,"master":6}'::jsonb,
     array['Glassy melancholy arpeggio hook over synth pad.','Bright clean with delay sheen; no grit until the chorus.'],
     array['The signature riff is high up the neck — keep it delicate.','Support the vocal; don''t crowd it.'],
     'Studio recording, 2004. Glassy delayed arpeggio hook from Hot Fuss.',71),

    -- ============ BLOC PARTY ============
    ('banquet','bloc-party','guitar','riff','main riff','crunch','indie rock','rhythm','intermediate',
     'Solid-body electric (Russell Lissack / Kele Okereke)','Bright amp with tight crunch','Closed-back cab','bridge pickup',
     '[{"effect_type":"delay","effect_name":"Line 6 DL4 delay","placement":"post_gain","settings":{"time":3,"mix":3,"feedback":3}}]'::jsonb,
     '{"gain":5,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":2,"master":7}'::jsonb,
     array['Angular dance-punk riff — bright, tight, rhythmic.','Lissack''s DL4 adds movement; keep the core tone dry and cutting.'],
     array['The two guitars trade angular figures — pick one and lock in.','Mute aggressively between stabs.'],
     'Studio recording, 2005. Angular dance-punk with Lissack''s ever-present DL4.',73),
    ('helicopter','bloc-party','guitar','riff','main riff','crunch','indie rock','rhythm','advanced',
     'Solid-body electric (Russell Lissack / Kele Okereke)','Bright amp with tight crunch','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Frantic sixteenth-note riff — treble-heavy and dry.','Tight crunch; the speed demands note separation.'],
     array['The intro riff is a finger-twister — build speed slowly.','Stamina matters: the riff barely stops.'],
     'Studio recording, 2005. Frantic treble-forward riff from Silent Alarm.',73),
    ('this-modern-love','bloc-party','guitar','riff','main riff','clean','indie rock','rhythm','intermediate',
     'Solid-body electric (Russell Lissack / Kele Okereke)','Bright clean amp','Open-back combo cab','neck pickup',
     '[{"effect_type":"delay","effect_name":"Line 6 DL4 delay","placement":"post_gain","settings":{"time":4,"mix":3,"feedback":3}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":3,"master":6}'::jsonb,
     array['Delicate interweaving clean lines with delay halo.','Pure clean; dynamics come from touch.'],
     array['Two clean lines answer each other — space is everything.','Build gradually into the loud finale.'],
     'Studio recording, 2005. Delicate clean interplay building to a wall.',72),

    -- ============ VAMPIRE WEEKEND ============
    ('oxford-comma','vampire-weekend','guitar','riff','main riff','clean','indie rock','rhythm','beginner',
     'Epiphone Sheraton II (Ezra Koenig)','Bright clean amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Dry, bright Afro-pop-inflected clean — almost no effects.','Sparkling clean with trebly snap; any drive is wrong.'],
     array['Light, bouncy single-note lines and small chords.','The feel is conversational — relaxed, precise.'],
     'Studio recording, 2008. Dry bright Afro-pop clean from the debut.',75),
    ('cape-cod-kwassa-kwassa','vampire-weekend','guitar','riff','main riff','clean','indie rock','rhythm','intermediate',
     'Epiphone Sheraton II (Ezra Koenig)','Bright clean amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Soukous-style clean picking — bright, dry, bouncy.','Zero drive; the tone is all fingers and treble.'],
     array['The high-life picking pattern is the song — practice the loop.','Feather-light touch keeps it dancing.'],
     'Studio recording, 2008. Soukous-inspired dry clean picking.',75),
    ('cousins','vampire-weekend','guitar','riff','main riff','clean','indie rock','rhythm','advanced',
     'Epiphone Sheraton II (Ezra Koenig)','Bright clean amp, slightly pushed','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":3,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Frantic surf-speed clean runs — bright and percussive.','Just-clean with attack; compression from playing hard.'],
     array['The descending chromatic runs are fast — build up with a metronome.','Keep the frantic energy controlled.'],
     'Studio recording, 2010. Frantic bright surf-speed runs from Contra.',74),

    -- ============ YEAH YEAH YEAHS ============
    ('maps','yeah-yeah-yeahs','guitar','riff','main riff','clean','indie rock','rhythm','beginner',
     'Solid-body electric (Nick Zinner)','Clean amp with wide reverb','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":5,"decay":6}},{"effect_type":"delay","effect_name":"subtle delay","placement":"post_gain","settings":{"time":4,"mix":2,"feedback":2}}]'::jsonb,
     '{"gain":3,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":5,"delay":2,"master":6}'::jsonb,
     array['Aching clean arpeggio in a wash of reverb.','Clean with big reverb; the tremolo-picked walls come from layering.'],
     array['Steady arpeggio under the vocal — consistency is the emotion.','The climax wall is tremolo picking; keep the wrist loose.'],
     'Studio recording, 2003. Reverb-washed clean arpeggio, one of indie''s defining tones.',74)
) as c(
  song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence
)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;
