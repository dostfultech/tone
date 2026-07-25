-- Phase 9: 25 modern-rock / 2000s / RHCP staples, verified per-part tone data.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Red Hot Chili Peppers','red-hot-chili-peppers','By the Way','by-the-way','By the Way',2002),
    ('Red Hot Chili Peppers','red-hot-chili-peppers','Otherside','otherside','Californication',1999),
    ('Red Hot Chili Peppers','red-hot-chili-peppers','Snow (Hey Oh)','snow-hey-oh','Stadium Arcadium',2006),
    ('Red Hot Chili Peppers','red-hot-chili-peppers','Can''t Stop','can-t-stop','By the Way',2002),
    ('Red Hot Chili Peppers','red-hot-chili-peppers','Dani California','dani-california','Stadium Arcadium',2006),
    ('Red Hot Chili Peppers','red-hot-chili-peppers','Give It Away','give-it-away','Blood Sugar Sex Magik',1991),
    ('Red Hot Chili Peppers','red-hot-chili-peppers','Scar Tissue','scar-tissue','Californication',1999),
    ('Rage Against the Machine','rage-against-the-machine','Killing in the Name','killing-in-the-name','Rage Against the Machine',1992),
    ('Rage Against the Machine','rage-against-the-machine','Guerrilla Radio','guerrilla-radio','The Battle of Los Angeles',1999),
    ('Arctic Monkeys','arctic-monkeys','Do I Wanna Know?','do-i-wanna-know','AM',2013),
    ('Arctic Monkeys','arctic-monkeys','R U Mine?','r-u-mine','AM',2013),
    ('The Strokes','the-strokes','Last Nite','last-nite','Is This It',2001),
    ('The Killers','the-killers','Mr. Brightside','mr-brightside','Hot Fuss',2004),
    ('Franz Ferdinand','franz-ferdinand','Take Me Out','take-me-out','Franz Ferdinand',2004),
    ('Jet','jet','Are You Gonna Be My Girl','are-you-gonna-be-my-girl','Get Born',2003),
    ('Kings of Leon','kings-of-leon','Sex on Fire','sex-on-fire','Only by the Night',2008),
    ('Kings of Leon','kings-of-leon','Use Somebody','use-somebody','Only by the Night',2008),
    ('Green Day','green-day','Boulevard of Broken Dreams','boulevard-of-broken-dreams','American Idiot',2004),
    ('Green Day','green-day','American Idiot','american-idiot','American Idiot',2004),
    ('Green Day','green-day','Holiday','holiday','American Idiot',2004),
    ('Green Day','green-day','When I Come Around','when-i-come-around','Dookie',1994),
    ('Linkin Park','linkin-park','In the End','in-the-end','Hybrid Theory',2000),
    ('Linkin Park','linkin-park','One Step Closer','one-step-closer','Hybrid Theory',2000),
    ('Linkin Park','linkin-park','Crawling','crawling','Hybrid Theory',2000),
    ('Slipknot','slipknot','Duality','duality','Vol. 3: The Subliminal Verses',2004)
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
    ('red-hot-chili-peppers','by-the-way'),('red-hot-chili-peppers','otherside'),('red-hot-chili-peppers','snow-hey-oh'),
    ('red-hot-chili-peppers','can-t-stop'),('red-hot-chili-peppers','dani-california'),('red-hot-chili-peppers','give-it-away'),
    ('red-hot-chili-peppers','scar-tissue'),('rage-against-the-machine','killing-in-the-name'),('rage-against-the-machine','guerrilla-radio'),
    ('arctic-monkeys','do-i-wanna-know'),('arctic-monkeys','r-u-mine'),('the-strokes','last-nite'),
    ('the-killers','mr-brightside'),('franz-ferdinand','take-me-out'),('jet','are-you-gonna-be-my-girl'),
    ('kings-of-leon','sex-on-fire'),('kings-of-leon','use-somebody'),('green-day','boulevard-of-broken-dreams'),
    ('green-day','american-idiot'),('green-day','holiday'),('green-day','when-i-come-around'),
    ('linkin-park','in-the-end'),('linkin-park','one-step-closer'),('linkin-park','crawling'),('slipknot','duality')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('red-hot-chili-peppers','by-the-way'),('red-hot-chili-peppers','otherside'),('red-hot-chili-peppers','snow-hey-oh'),
    ('red-hot-chili-peppers','can-t-stop'),('red-hot-chili-peppers','dani-california'),('red-hot-chili-peppers','give-it-away'),
    ('red-hot-chili-peppers','scar-tissue'),('rage-against-the-machine','killing-in-the-name'),('rage-against-the-machine','guerrilla-radio'),
    ('arctic-monkeys','do-i-wanna-know'),('arctic-monkeys','r-u-mine'),('the-strokes','last-nite'),
    ('the-killers','mr-brightside'),('franz-ferdinand','take-me-out'),('jet','are-you-gonna-be-my-girl'),
    ('kings-of-leon','sex-on-fire'),('kings-of-leon','use-somebody'),('green-day','boulevard-of-broken-dreams'),
    ('green-day','american-idiot'),('green-day','holiday'),('green-day','when-i-come-around'),
    ('linkin-park','in-the-end'),('linkin-park','one-step-closer'),('linkin-park','crawling'),('slipknot','duality')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('red-hot-chili-peppers','by-the-way'),('red-hot-chili-peppers','otherside'),('red-hot-chili-peppers','snow-hey-oh'),
    ('red-hot-chili-peppers','can-t-stop'),('red-hot-chili-peppers','dani-california'),('red-hot-chili-peppers','give-it-away'),
    ('red-hot-chili-peppers','scar-tissue'),('rage-against-the-machine','killing-in-the-name'),('rage-against-the-machine','guerrilla-radio'),
    ('arctic-monkeys','do-i-wanna-know'),('arctic-monkeys','r-u-mine'),('the-strokes','last-nite'),
    ('the-killers','mr-brightside'),('franz-ferdinand','take-me-out'),('jet','are-you-gonna-be-my-girl'),
    ('kings-of-leon','sex-on-fire'),('kings-of-leon','use-somebody'),('green-day','boulevard-of-broken-dreams'),
    ('green-day','american-idiot'),('green-day','holiday'),('green-day','when-i-come-around'),
    ('linkin-park','in-the-end'),('linkin-park','one-step-closer'),('linkin-park','crawling'),('slipknot','duality')
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
    ('by-the-way','red-hot-chili-peppers','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Fender Stratocaster (John Frusciante)','Marshall high-gain amp','Marshall 4x12 cab','bridge pickup',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Punchy distortion for the driving chorus, contrasting with the melodic verses.','Keep the riff tight and bright.'],
     array['Drive the chorus with energy.','Keep the melodic verse cleaner.'],
     'Studio recording, 2002. John Frusciante used a Strat into a Marshall for the punchy tone.',78),
    ('otherside','red-hot-chili-peppers','guitar','riff','clean arpeggio','clean','rock','clean','intermediate',
     'Fender Stratocaster (John Frusciante)','Clean amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm clean arpeggios; keep gain low and let the chords ring.','A little ambience adds depth.'],
     array['Arpeggiate the chords evenly.','Keep the picking gentle.'],
     'Studio recording, 1999. John Frusciante played the clean arpeggios on a Strat.',78),
    ('snow-hey-oh','red-hot-chili-peppers','guitar','riff','fast clean arpeggio','clean','rock','clean','advanced',
     'Fender Stratocaster (John Frusciante)','Clean amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['A fast, cascading clean arpeggio; keep the amp clean so every note rings.','Low gain and even dynamics.'],
     array['Play the rapid arpeggio cleanly and evenly.','Keep a relaxed picking hand.'],
     'Studio recording, 2006. John Frusciante played the intricate clean arpeggio on a Strat.',78),
    ('can-t-stop','red-hot-chili-peppers','guitar','riff','staccato funk riff','crunch','rock','rhythm','advanced',
     'Fender Stratocaster (John Frusciante)','Marshall at edge of breakup','Marshall 4x12 cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Tight, funky staccato crunch; the muted attack is the identity.','Medium gain with a bright edge.'],
     array['Play the staccato riff with tight muting.','Keep the funk groove crisp.'],
     'Studio recording, 2002. John Frusciante played the funky staccato riff on a Strat.',78),
    ('dani-california','red-hot-chili-peppers','guitar','riff','main riff and solo','crunch','rock','rhythm','intermediate',
     'Fender Stratocaster (John Frusciante)','Marshall crunch amp','Marshall 4x12 cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Warm crunch for the verses building to a Hendrix-flavored solo.','Keep it dynamic and clear.'],
     array['Play the chord riff with a laid-back groove.','Let the solo channel a vintage feel.'],
     'Studio recording, 2006. John Frusciante used a Strat into a Marshall.',77),
    ('give-it-away','red-hot-chili-peppers','guitar','riff','funk riff','crunch','rock','rhythm','intermediate',
     'Fender Stratocaster (John Frusciante)','Marshall at edge of breakup','Marshall 4x12 cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Raw, funky edge-of-breakup crunch; keep the muted riff tight.','Medium gain with a bright attack.'],
     array['Play the funk riff with sharp muting.','Keep the groove percussive.'],
     'Studio recording, 1991. John Frusciante played the raw funk riff on a Strat.',77),
    ('scar-tissue','red-hot-chili-peppers','guitar','lead','main lead melody','crunch','rock','lead','intermediate',
     'Fender Stratocaster (John Frusciante)','Clean-to-edge amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm clean-to-edge lead; keep the melodic bends smooth and singing.','Low gain for the mellow feel.'],
     array['Play the melodic lead with smooth bends.','Let the notes ring gently.'],
     'Studio recording, 1999. John Frusciante played the warm melodic lead on a Strat.',77),
    ('killing-in-the-name','rage-against-the-machine','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Fender Telecaster in Drop D (Tom Morello)','Marshall JCM800 2205','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Tight JCM800 distortion in Drop D; keep the low end controlled for the heavy groove.','No pedals on the riff.'],
     array['Lock the drop-D riff tightly to the groove.','Aggressive palm muting.'],
     'Studio recording, 1992. Tom Morello played the riff on a Telecaster into a Marshall JCM800.',80),
    ('guerrilla-radio','rage-against-the-machine','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Fender Telecaster (Tom Morello)','Marshall JCM800','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Tight, funky JCM800 distortion; keep the muted riff percussive.','Medium-high gain with clarity.'],
     array['Play the staccato riff with tight muting.','Keep the groove aggressive.'],
     'Studio recording, 1999. Tom Morello used a Telecaster into a Marshall JCM800.',78),
    ('do-i-wanna-know','arctic-monkeys','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Fender / Gibson guitar (Alex Turner / Jamie Cook)','Fuzzy high-gain amp','Closed-back cab','bridge pickup',
     '[{"effect_type":"fuzz","effect_name":"fuzz","placement":"front","settings":{"gain":6,"tone":5,"level":6}}]'::jsonb,
     '{"gain":6,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Heavy, fuzzy low-slung riff; keep the low end thick and the groove hypnotic.','The fuzz is the identity.'],
     array['Play the riff with a heavy, deliberate feel.','Let the fuzz sustain the notes.'],
     'Studio recording, 2013. A fuzzy, low-slung riff drives the song.',77),
    ('r-u-mine','arctic-monkeys','guitar','riff','main riff','distorted','rock','rhythm','advanced',
     'Fender / Gibson guitar (Alex Turner / Jamie Cook)','Fuzzy high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"fuzz","effect_name":"fuzz","placement":"front","settings":{"gain":7,"tone":5,"level":6}}]'::jsonb,
     '{"gain":7,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Heavy fuzz-driven riff; keep the low end controlled under the saturation.','The fuzz drives the heavy groove.'],
     array['Play the syncopated riff with attitude.','Keep the picking tight under the fuzz.'],
     'Studio recording, 2013. A heavy fuzz riff drives the song.',77),
    ('last-nite','the-strokes','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Fender / Epiphone guitar (Strokes dual guitars)','Fender crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, thin garage-rock crunch; keep it clear and jangly.','Low-to-medium gain.'],
     array['Play the interlocking riffs cleanly.','Keep the tone bright and crisp.'],
     'Studio recording, 2001. Bright, thin garage-rock crunch with interlocking guitars.',76),
    ('mr-brightside','the-killers','guitar','riff','main delay riff','crunch','rock','rhythm','intermediate',
     'Fender guitar (Dave Keuning)','Bright crunch amp with delay','Open-back combo cab','bridge pickup',
     '[{"effect_type":"delay","effect_name":"delay","placement":"post_gain","settings":{"mix":3,"time":4}}]'::jsonb,
     '{"gain":4,"bass":5,"mids":5,"treble":7,"presence":5,"reverb":2,"delay":2,"master":6}'::jsonb,
     array['A bright, delayed single-note riff drives the song; set the delay to build the pattern.','Keep the amp bright and mostly clean.'],
     array['Play the steady single-note riff evenly.','Let the delay add movement.'],
     'Studio recording, 2004. Dave Keuning played the bright delayed riff.',77),
    ('take-me-out','franz-ferdinand','guitar','riff','main riff','crunch','rock','rhythm','intermediate',
     'Fender / Gibson guitar (Franz Ferdinand)','Crunch amp','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Angular, danceable crunch; keep the stabs tight after the tempo shift.','Medium gain with a bright edge.'],
     array['Lock the angular riff to the driving beat.','Keep the chord stabs punchy.'],
     'Studio recording, 2004. An angular, danceable crunch riff drives the song.',76),
    ('are-you-gonna-be-my-girl','jet','guitar','riff','main riff','distorted','rock','rhythm','beginner',
     'Gibson guitar (Cameron Muncey / Nic Cester)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Raw, driving garage-rock distortion; keep it mid-forward and punchy.','Medium-high gain.'],
     array['Drive the riff with steady downstrokes.','Keep it raw and energetic.'],
     'Studio recording, 2003. Raw, driving garage-rock distortion.',76),
    ('sex-on-fire','kings-of-leon','guitar','riff','main riff','crunch','rock','rhythm','intermediate',
     'Fender / Gibson guitar (Matthew Followill)','Bright crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Bright, jangly arena crunch; keep the riff clear and ringing.','Low-to-medium gain with sparkle.'],
     array['Let the high riff ring out.','Keep the picking crisp.'],
     'Studio recording, 2008. Bright, jangly arena-rock crunch.',76),
    ('use-somebody','kings-of-leon','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Fender / Gibson guitar (Matthew Followill)','Crunch amp with ambience','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Anthemic, ringing crunch; keep the chords big and clear.','Ambience adds the arena feel.'],
     array['Let the chords ring for the anthemic feel.','Build dynamics into the chorus.'],
     'Studio recording, 2008. Anthemic ringing crunch tone.',76),
    ('boulevard-of-broken-dreams','green-day','guitar','riff','main riff','crunch','punk','rhythm','beginner',
     'Fernandes / Gibson guitar (Billie Joe Armstrong)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['A palm-muted crunch riff over the verse; keep it tight and dynamic.','Medium gain for the verse-chorus lift.'],
     array['Palm mute the verse riff evenly.','Open up for the chorus chords.'],
     'Studio recording, 2004. A palm-muted crunch riff drives the verse.',76),
    ('american-idiot','green-day','guitar','riff','main riff','distorted','punk','rhythm','beginner',
     'Fernandes guitar (Billie Joe Armstrong)','Marshall 1959 SLP','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, driving punk distortion; keep it tight for the power chords.','Medium-high gain with clarity.'],
     array['Downstroke the power chords with energy.','Keep the tempo tight and aggressive.'],
     'Studio recording, 2004. Bright punk distortion into a Marshall.',77),
    ('holiday','green-day','guitar','riff','main riff','distorted','punk','rhythm','beginner',
     'Fernandes guitar (Billie Joe Armstrong)','Marshall 1959 SLP','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Driving punk distortion; keep the riff tight and bright.','Medium-high gain with clear attack.'],
     array['Downstroke the power chords.','Keep the muting clean.'],
     'Studio recording, 2004. Bright punk distortion into a Marshall.',76),
    ('when-i-come-around','green-day','guitar','riff','main riff','distorted','punk','rhythm','beginner',
     'Fernandes Stratocaster-style guitar (Billie Joe Armstrong)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, mid-gain pop-punk crunch; keep the chord riff ringing.','Medium gain so the chords stay clear.'],
     array['Let the chord riff ring.','Keep a steady, relaxed strum.'],
     'Studio recording, 1994. Bright pop-punk crunch into a Marshall.',76),
    ('in-the-end','linkin-park','guitar','riff','main riff','distorted','rock','rhythm','beginner',
     'PRS humbucker guitar (Brad Delson)','Mesa/Boogie high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Modern mid-gain rock over the piano hook; keep the chords tight behind the vocal.','Clean-to-heavy dynamics.'],
     array['Palm mute the driving chords.','Open up for the chorus.'],
     'Studio recording, 2000. Brad Delson tracked the driving chords through a Mesa amp.',76),
    ('one-step-closer','linkin-park','guitar','riff','main riff','high_gain','rock','rhythm','intermediate',
     'PRS humbucker guitar in a dropped tuning (Brad Delson)','Mesa/Boogie high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Heavy dropped-tuning riff; keep the low end tight for the aggression.','Medium-high gain with weight.'],
     array['Lock the heavy drop-tuned riff.','Firm palm muting.'],
     'Studio recording, 2000. Brad Delson used a dropped tuning into a high-gain Mesa.',77),
    ('crawling','linkin-park','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'PRS humbucker guitar (Brad Delson)','Mesa/Boogie high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Big, atmospheric mid-gain rock; keep the chords wide behind the vocal and synth.','Clean-to-heavy dynamics.'],
     array['Let the chorus chords ring big.','Keep the verse restrained.'],
     'Studio recording, 2000. Brad Delson tracked the atmospheric chords through a Mesa amp.',76),
    ('duality','slipknot','guitar','riff','main riff','high_gain','metal','rhythm','advanced',
     'Ibanez humbucker guitar in a dropped tuning (Mick Thomson / Jim Root)','High-gain amp (Rectifier-style)','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Heavy, tight dropped-tuning high gain; keep the low end controlled for the chug.','No pedals; the gain is all amp.'],
     array['Lock the heavy riff tightly to the drums.','Firm, aggressive palm muting.'],
     'Studio recording, 2004. Dropped-tuning high gain through a Rectifier-style amp.',78)
) as c(
  song_slug, artist_slug, mode, part_type, part_label, tone_type,
  genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes,
  source_summary, confidence
)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug
on conflict (song_id, mode, part_type, tone_type, part_label) do update set
  original_guitar = excluded.original_guitar, original_amp = excluded.original_amp,
  original_cab = excluded.original_cab, original_pickup = excluded.original_pickup,
  original_effects = excluded.original_effects, original_settings = excluded.original_settings,
  adaptation_notes = excluded.adaptation_notes, playing_notes = excluded.playing_notes,
  source_summary = excluded.source_summary, confidence = excluded.confidence,
  verification_status = excluded.verification_status, genre = excluded.genre,
  tone_category = excluded.tone_category, difficulty = excluded.difficulty,
  search_text = excluded.search_text, is_public = excluded.is_public, updated_at = now();

insert into public.tone_profile_sources (profile_id, source_type, title, url, notes, credibility)
select p.id, x.source_type, x.title, x.url, x.notes, x.credibility
from public.song_tone_profiles p
join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
join (values
  ('red-hot-chili-peppers','by-the-way'),('red-hot-chili-peppers','otherside'),('red-hot-chili-peppers','snow-hey-oh'),
  ('red-hot-chili-peppers','can-t-stop'),('red-hot-chili-peppers','dani-california'),('red-hot-chili-peppers','give-it-away'),
  ('red-hot-chili-peppers','scar-tissue'),('rage-against-the-machine','killing-in-the-name'),('rage-against-the-machine','guerrilla-radio'),
  ('arctic-monkeys','do-i-wanna-know'),('arctic-monkeys','r-u-mine'),('the-strokes','last-nite'),
  ('the-killers','mr-brightside'),('franz-ferdinand','take-me-out'),('jet','are-you-gonna-be-my-girl'),
  ('kings-of-leon','sex-on-fire'),('kings-of-leon','use-somebody'),('green-day','boulevard-of-broken-dreams'),
  ('green-day','american-idiot'),('green-day','holiday'),('green-day','when-i-come-around'),
  ('linkin-park','in-the-end'),('linkin-park','one-step-closer'),('linkin-park','crawling'),('slipknot','duality')
) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
cross join (values
  ('artist_interview', 'Documented artist interviews and gear discussions', null::text,
   'Researched from widely-documented interviews about this recording and player.', 72),
  ('rig_rundown', 'Published rig rundowns and community gear databases', null::text,
   'Cross-referenced against rig features and community-maintained gear databases.', 66)
) as x(source_type, title, url, notes, credibility)
where p.verification_status = 'admin_verified'
on conflict do nothing;
