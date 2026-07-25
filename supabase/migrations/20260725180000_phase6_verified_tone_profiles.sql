-- Phase 6: 25 grunge / alt / modern-rock staples, verified per-part tone data.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Pearl Jam','pearl-jam','Black','black','Ten',1991),
    ('Pearl Jam','pearl-jam','Even Flow','even-flow','Ten',1991),
    ('Pearl Jam','pearl-jam','Jeremy','jeremy','Ten',1991),
    ('Alice in Chains','alice-in-chains','Would?','would','Dirt',1992),
    ('Alice in Chains','alice-in-chains','Rooster','rooster','Dirt',1992),
    ('Alice in Chains','alice-in-chains','Them Bones','them-bones','Dirt',1992),
    ('Nirvana','nirvana','Heart-Shaped Box','heart-shaped-box','In Utero',1993),
    ('Nirvana','nirvana','In Bloom','in-bloom','Nevermind',1991),
    ('Nirvana','nirvana','Lithium','lithium','Nevermind',1991),
    ('Soundgarden','soundgarden','Black Hole Sun','black-hole-sun','Superunknown',1994),
    ('Soundgarden','soundgarden','Spoonman','spoonman','Superunknown',1994),
    ('Soundgarden','soundgarden','Outshined','outshined','Badmotorfinger',1991),
    ('Stone Temple Pilots','stone-temple-pilots','Interstate Love Song','interstate-love-song','Purple',1994),
    ('The Smashing Pumpkins','the-smashing-pumpkins','Bullet with Butterfly Wings','bullet-with-butterfly-wings','Mellon Collie and the Infinite Sadness',1995),
    ('The Smashing Pumpkins','the-smashing-pumpkins','1979','1979','Mellon Collie and the Infinite Sadness',1995),
    ('The Smashing Pumpkins','the-smashing-pumpkins','Today','today','Siamese Dream',1993),
    ('The Smashing Pumpkins','the-smashing-pumpkins','Cherub Rock','cherub-rock','Siamese Dream',1993),
    ('Radiohead','radiohead','Karma Police','karma-police','OK Computer',1997),
    ('Radiohead','radiohead','Paranoid Android','paranoid-android','OK Computer',1997),
    ('Foo Fighters','foo-fighters','Monkey Wrench','monkey-wrench','The Colour and the Shape',1997),
    ('Foo Fighters','foo-fighters','The Pretender','the-pretender','Echoes, Silence, Patience & Grace',2007),
    ('Foo Fighters','foo-fighters','Learn to Fly','learn-to-fly','There Is Nothing Left to Lose',1999),
    ('Foo Fighters','foo-fighters','My Hero','my-hero','The Colour and the Shape',1997),
    ('Foo Fighters','foo-fighters','Times Like These','times-like-these','One by One',2002),
    ('Foo Fighters','foo-fighters','Best of You','best-of-you','In Your Honor',2005)
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
    ('pearl-jam','black'),('pearl-jam','even-flow'),('pearl-jam','jeremy'),('alice-in-chains','would'),
    ('alice-in-chains','rooster'),('alice-in-chains','them-bones'),('nirvana','heart-shaped-box'),
    ('nirvana','in-bloom'),('nirvana','lithium'),('soundgarden','black-hole-sun'),('soundgarden','spoonman'),
    ('soundgarden','outshined'),('stone-temple-pilots','interstate-love-song'),('the-smashing-pumpkins','bullet-with-butterfly-wings'),
    ('the-smashing-pumpkins','1979'),('the-smashing-pumpkins','today'),('the-smashing-pumpkins','cherub-rock'),
    ('radiohead','karma-police'),('radiohead','paranoid-android'),('foo-fighters','monkey-wrench'),
    ('foo-fighters','the-pretender'),('foo-fighters','learn-to-fly'),('foo-fighters','my-hero'),
    ('foo-fighters','times-like-these'),('foo-fighters','best-of-you')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('pearl-jam','black'),('pearl-jam','even-flow'),('pearl-jam','jeremy'),('alice-in-chains','would'),
    ('alice-in-chains','rooster'),('alice-in-chains','them-bones'),('nirvana','heart-shaped-box'),
    ('nirvana','in-bloom'),('nirvana','lithium'),('soundgarden','black-hole-sun'),('soundgarden','spoonman'),
    ('soundgarden','outshined'),('stone-temple-pilots','interstate-love-song'),('the-smashing-pumpkins','bullet-with-butterfly-wings'),
    ('the-smashing-pumpkins','1979'),('the-smashing-pumpkins','today'),('the-smashing-pumpkins','cherub-rock'),
    ('radiohead','karma-police'),('radiohead','paranoid-android'),('foo-fighters','monkey-wrench'),
    ('foo-fighters','the-pretender'),('foo-fighters','learn-to-fly'),('foo-fighters','my-hero'),
    ('foo-fighters','times-like-these'),('foo-fighters','best-of-you')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('pearl-jam','black'),('pearl-jam','even-flow'),('pearl-jam','jeremy'),('alice-in-chains','would'),
    ('alice-in-chains','rooster'),('alice-in-chains','them-bones'),('nirvana','heart-shaped-box'),
    ('nirvana','in-bloom'),('nirvana','lithium'),('soundgarden','black-hole-sun'),('soundgarden','spoonman'),
    ('soundgarden','outshined'),('stone-temple-pilots','interstate-love-song'),('the-smashing-pumpkins','bullet-with-butterfly-wings'),
    ('the-smashing-pumpkins','1979'),('the-smashing-pumpkins','today'),('the-smashing-pumpkins','cherub-rock'),
    ('radiohead','karma-police'),('radiohead','paranoid-android'),('foo-fighters','monkey-wrench'),
    ('foo-fighters','the-pretender'),('foo-fighters','learn-to-fly'),('foo-fighters','my-hero'),
    ('foo-fighters','times-like-these'),('foo-fighters','best-of-you')
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
    ('black','pearl-jam','guitar','riff','main chordal riff','crunch','rock','rhythm','intermediate',
     'Fender Stratocaster / Les Paul (McCready / Gossard)','Marshall at edge of breakup','Marshall 4x12 cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm edge-of-breakup crunch; let the emotional chord work breathe.','Roll guitar volume for the cleaner verse.'],
     array['Let the chords ring with dynamics.','Build intensity into the outro.'],
     'Studio recording, 1991. Warm, dynamic edge-of-breakup tone into cranked Marshalls.',80),
    ('even-flow','pearl-jam','guitar','riff','main riff','distorted','rock','rhythm','advanced',
     'Gibson Les Paul (Mike McCready / Stone Gossard)','Marshall high-gain','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Punchy, mid-forward Marshall distortion; keep the funky riff tight.','Medium-high gain with clarity.'],
     array['Lock the syncopated riff to the groove.','Tight muting between accents.'],
     'Studio recording, 1991. Les Pauls into cranked Marshalls.',78),
    ('jeremy','pearl-jam','guitar','riff','twelve-string riff','crunch','rock','rhythm','intermediate',
     'Twelve-string and electric guitar (Gossard / McCready)','Clean-to-crunch amp','Open-back combo cab','neck or bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The intro layers 12-string; the verses build to crunch.','For 6-string, add slight chorus to imply the 12-string shimmer.'],
     array['Let the intro figure ring open.','Build dynamics into the chorus.'],
     'Studio recording, 1991. A 12-string underpins the arrangement, building from clean to crunch.',77),
    ('would','alice-in-chains','guitar','riff','main riff','distorted','metal','rhythm','intermediate',
     'G&L Rampage (Jerry Cantrell)','Bogner / Mesa high-gain','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Thick, sludgy distortion; keep the low end heavy but controlled.','Medium gain with weight for the dark riff.'],
     array['Play the descending riff with weight.','Let the vocal harmonies frame the dynamics.'],
     'Studio recording, 1992. Jerry Cantrell used a G&L into a high-gain amp.',78),
    ('rooster','alice-in-chains','guitar','riff','main riff','distorted','metal','rhythm','intermediate',
     'G&L Rampage (Jerry Cantrell)','Bogner / Mesa high-gain','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Dynamic from atmospheric clean verse to heavy chorus; keep the riff thick.','Add ambience for the cleans.'],
     array['Contrast the eerie verse with the heavy chorus.','Let the bends sit in the pocket.'],
     'Studio recording, 1992. Jerry Cantrell used a G&L into a high-gain amp.',78),
    ('them-bones','alice-in-chains','guitar','riff','main riff','distorted','metal','rhythm','advanced',
     'G&L Rampage in a dropped tuning (Jerry Cantrell)','Bogner / Mesa high-gain','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Heavy, off-kilter dropped-tuning riff; keep the low end controlled.','Medium-high gain with weight.'],
     array['Lock the odd-time riff tightly.','Firm palm muting for the chug.'],
     'Studio recording, 1992. Jerry Cantrell used a dropped tuning into a high-gain amp.',78),
    ('heart-shaped-box','nirvana','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Fender Jaguar / Mustang (Kurt Cobain)','Clean amp pushed by distortion','Open-back / 4x12 blend','bridge pickup',
     '[{"effect_type":"distortion","effect_name":"Boss DS distortion","placement":"front","settings":{"gain":6,"tone":5,"level":6}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Big dynamic jump from clean verse to distorted chorus via a distortion pedal.','Keep the chorus ragged, not tight.'],
     array['Hit the chorus chords hard.','Keep the verse thin for contrast.'],
     'Studio recording, 1993. Kurt Cobain used a distortion pedal into a clean amp.',80),
    ('in-bloom','nirvana','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Fender Mustang / Jaguar (Kurt Cobain)','Clean amp pushed by distortion','Open-back / 4x12 blend','bridge pickup',
     '[{"effect_type":"distortion","effect_name":"Boss DS-1 distortion","placement":"front","settings":{"gain":6,"tone":5,"level":6}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Pedal distortion into a clean amp keeps the ragged edge.','Big verse-to-chorus dynamic jump.'],
     array['Drive the chorus power chords.','Keep the verse cleaner and thinner.'],
     'Studio recording, 1991. Kurt Cobain used a Boss distortion into a clean amp.',80),
    ('lithium','nirvana','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Fender Jaguar / Mustang (Kurt Cobain)','Clean amp pushed by distortion','Open-back / 4x12 blend','bridge pickup',
     '[{"effect_type":"distortion","effect_name":"Boss distortion","placement":"front","settings":{"gain":6,"tone":5,"level":6}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Clean verse, distorted chorus; the quiet-loud dynamic is the identity.','Keep the distortion loose.'],
     array['Let the clean verse breathe.','Slam the chorus chords.'],
     'Studio recording, 1991. Kurt Cobain used a distortion pedal into a clean amp.',80),
    ('black-hole-sun','soundgarden','guitar','riff','main chordal riff','crunch','rock','rhythm','intermediate',
     'Gibson / Guild guitar in a dropped tuning (Kim Thayil)','Clean-to-crunch amp with rotary/chorus','Open-back combo cab','neck or bridge pickup',
     '[{"effect_type":"modulation","effect_name":"Leslie / rotary shimmer","placement":"post_gain","settings":{"depth":4,"rate":3,"mix":4}}]'::jsonb,
     '{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['A swirling rotary/chorus shimmer over a clean-to-crunch tone defines the verse.','Build to heavier gain for the chorus.'],
     array['Let the dreamy chords swirl in the verse.','Push into the heavier chorus dynamically.'],
     'Studio recording, 1994. Kim Thayil used a dropped tuning with a rotary/chorus shimmer.',78),
    ('spoonman','soundgarden','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Gibson guitar in a dropped tuning (Kim Thayil)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Heavy, dropped-tuning riff; keep the odd-time groove tight.','Medium-high gain with weight.'],
     array['Lock the syncopated riff to the drums.','Firm palm muting.'],
     'Studio recording, 1994. Kim Thayil used a dropped tuning into a high-gain amp.',77),
    ('outshined','soundgarden','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Gibson guitar in Drop D (Kim Thayil)','High-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Heavy, sludgy Drop-D groove; keep the low end controlled.','Medium-high gain with weight.'],
     array['Play the heavy groove with swagger.','Firm palm muting on the low string.'],
     'Studio recording, 1991. Kim Thayil used Drop D into a high-gain amp.',77),
    ('interstate-love-song','stone-temple-pilots','guitar','riff','main riff','crunch','rock','rhythm','intermediate',
     'Gibson Les Paul (Dean DeLeo)','Vox / Marshall crunch amp','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm, classic-rock-flavored crunch; keep it dynamic and clear.','Medium gain so the chord riff rings.'],
     array['Let the main riff swing.','Keep the chord changes clean.'],
     'Studio recording, 1994. Dean DeLeo used a warm mid-gain crunch tone.',77),
    ('bullet-with-butterfly-wings','the-smashing-pumpkins','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Fender / custom guitar (Billy Corgan)','High-gain amp with Big Muff-style fuzz','Closed-back 4x12 cab','bridge pickup',
     '[{"effect_type":"fuzz","effect_name":"Big Muff-style fuzz","placement":"front","settings":{"gain":7,"tone":5,"level":6}}]'::jsonb,
     '{"gain":7,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['A wall of fuzz distortion for the chorus; keep the verse dynamics quieter.','The Big Muff-style fuzz is the identity.'],
     array['Slam the chorus power chords.','Keep the verse restrained for contrast.'],
     'Studio recording, 1995. Billy Corgan layered a wall of fuzz distortion.',78),
    ('1979','the-smashing-pumpkins','guitar','riff','main clean riff','clean','rock','clean','intermediate',
     'Fender / custom guitar (Billy Corgan)','Clean amp with modulation','Open-back combo cab','neck pickup',
     '[{"effect_type":"modulation","effect_name":"chorus / flange shimmer","placement":"post_gain","settings":{"depth":4,"rate":3,"mix":4}}]'::jsonb,
     '{"gain":3,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Dreamy clean tone with modulation; keep the amp clean so the shimmer stays clear.','Low gain for the hazy, nostalgic feel.'],
     array['Let the clean riff loop hypnotically.','Keep the picking soft and even.'],
     'Studio recording, 1995. Billy Corgan used a clean, modulated tone for the dreamy riff.',77),
    ('today','the-smashing-pumpkins','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Fender Stratocaster (Billy Corgan)','High-gain amp with Big Muff-style fuzz','Closed-back 4x12 cab','bridge pickup',
     '[{"effect_type":"fuzz","effect_name":"Big Muff-style fuzz","placement":"front","settings":{"gain":6,"tone":5,"level":6}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Clean, bright intro that explodes into a fuzzy chorus.','The Big Muff-style fuzz drives the heavy sections.'],
     array['Let the clean intro riff ring.','Slam the fuzzy chorus chords.'],
     'Studio recording, 1993. Billy Corgan contrasted a bright clean intro with a fuzz chorus.',77),
    ('cherub-rock','the-smashing-pumpkins','guitar','riff','main riff','distorted','rock','rhythm','advanced',
     'Fender Stratocaster (Billy Corgan)','High-gain amp with Big Muff-style fuzz','Closed-back 4x12 cab','bridge pickup',
     '[{"effect_type":"fuzz","effect_name":"Big Muff-style fuzz","placement":"front","settings":{"gain":7,"tone":5,"level":6}}]'::jsonb,
     '{"gain":7,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['A dense wall of fuzz distortion; keep the riff tight underneath the saturation.','The layered fuzz is the signature.'],
     array['Drive the riff with a strong attack.','Keep the picking tight under the fuzz.'],
     'Studio recording, 1993. Billy Corgan layered a wall of fuzz distortion.',77),
    ('karma-police','radiohead','guitar','riff','arpeggiated chords','clean','rock','clean','intermediate',
     'Fender Telecaster / acoustic (Jonny Greenwood / Ed OBrien)','Clean amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm clean arpeggios; keep gain near zero and let the chords ring.','A touch of ambience adds depth.'],
     array['Let the arpeggiated chords ring evenly.','Keep the picking gentle.'],
     'Studio recording, 1997. Clean arpeggiated chords underpin the song.',78),
    ('paranoid-android','radiohead','guitar','riff','heavy section riff','distorted','rock','rhythm','advanced',
     'Fender Telecaster (Jonny Greenwood)','Clean amp pushed by fuzz/distortion','Closed-back cab','bridge pickup',
     '[{"effect_type":"fuzz","effect_name":"fuzz / distortion","placement":"front","settings":{"gain":7,"tone":5,"level":6}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Aggressive, jagged fuzz for the heavy sections; the song swings clean to heavy.','Keep the fuzz raw for the explosive part.'],
     array['Attack the heavy riff aggressively.','Contrast with the clean sections.'],
     'Studio recording, 1997. Jonny Greenwood used aggressive fuzz for the heavy sections.',78),
    ('monkey-wrench','foo-fighters','guitar','riff','main riff','distorted','rock','rhythm','advanced',
     'Gibson guitar (Dave Grohl)','Mesa/Boogie or Vox high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, driving distortion; keep the fast riff articulate.','Medium-high gain with clarity.'],
     array['Drive the riff with fast, tight picking.','Keep the palm mutes clean.'],
     'Studio recording, 1997. Dave Grohl tracked the driving riff through a high-gain amp.',78),
    ('the-pretender','foo-fighters','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Gibson guitar (Grohl / Shiflett)','Mesa/Boogie high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Punchy, bright distortion; keep the riff tight and driving.','Medium-high gain with clarity.'],
     array['Drive the riff with confident picking.','Build dynamics into the explosive chorus.'],
     'Studio recording, 2007. Tracked through high-gain Mesa amps.',77),
    ('learn-to-fly','foo-fighters','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Gibson guitar (Grohl / Shiflett)','Vox / Mesa crunch amp','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, poppy crunch; keep it clean and ringing for the chord riff.','Medium gain so the chords stay clear.'],
     array['Let the chord riff ring.','Keep the strumming even.'],
     'Studio recording, 1999. Bright mid-gain crunch tone.',76),
    ('my-hero','foo-fighters','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Gibson guitar (Dave Grohl)','Mesa/Boogie high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Driving, anthemic distortion; keep the riff bright and punchy.','Medium-high gain with clarity.'],
     array['Drive the chord riff with energy.','Keep the picking tight.'],
     'Studio recording, 1997. Driving high-gain rock tone.',77),
    ('times-like-these','foo-fighters','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Gibson guitar (Grohl / Shiflett)','Mesa/Boogie amp','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, driving tone that builds from a picked intro to full chords.','Keep it dynamic across the sections.'],
     array['Let the syncopated intro figure ring.','Build into the big chorus chords.'],
     'Studio recording, 2002. Bright driving rock tone.',76),
    ('best-of-you','foo-fighters','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Gibson guitar (Grohl / Shiflett)','Mesa/Boogie high-gain amp','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Big, driving anthemic distortion; keep the chords ringing and powerful.','Medium-high gain with clarity.'],
     array['Drive the chords with full energy.','Build intensity through the song.'],
     'Studio recording, 2005. Big driving high-gain rock tone.',77)
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
  ('pearl-jam','black'),('pearl-jam','even-flow'),('pearl-jam','jeremy'),('alice-in-chains','would'),
  ('alice-in-chains','rooster'),('alice-in-chains','them-bones'),('nirvana','heart-shaped-box'),
  ('nirvana','in-bloom'),('nirvana','lithium'),('soundgarden','black-hole-sun'),('soundgarden','spoonman'),
  ('soundgarden','outshined'),('stone-temple-pilots','interstate-love-song'),('the-smashing-pumpkins','bullet-with-butterfly-wings'),
  ('the-smashing-pumpkins','1979'),('the-smashing-pumpkins','today'),('the-smashing-pumpkins','cherub-rock'),
  ('radiohead','karma-police'),('radiohead','paranoid-android'),('foo-fighters','monkey-wrench'),
  ('foo-fighters','the-pretender'),('foo-fighters','learn-to-fly'),('foo-fighters','my-hero'),
  ('foo-fighters','times-like-these'),('foo-fighters','best-of-you')
) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
cross join (values
  ('artist_interview', 'Documented artist interviews and gear discussions', null::text,
   'Researched from widely-documented interviews about this recording and player.', 72),
  ('rig_rundown', 'Published rig rundowns and community gear databases', null::text,
   'Cross-referenced against rig features and community-maintained gear databases.', 66)
) as x(source_type, title, url, notes, credibility)
where p.verification_status = 'admin_verified'
on conflict do nothing;
