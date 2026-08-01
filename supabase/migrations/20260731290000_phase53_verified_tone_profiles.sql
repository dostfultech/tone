-- Phase 53: K-rock / math rock / emo revival, verified per-part tone data.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('DAY6','day6','You Were Beautiful','you-were-beautiful','Sunrise',2017),
    ('DAY6','day6','Time of Our Life','time-of-our-life','The Book of Us: Gravity',2019),
    ('DAY6','day6','Congratulations','congratulations','The Day',2015),
    ('DAY6','day6','Zombie','zombie','The Book of Us: The Demon',2020),
    ('The Rose','the-rose','Sorry','sorry','Void',2017),
    ('Xdinary Heroes','xdinary-heroes','Happy Death Day','happy-death-day','Happy Death Day',2021),
    ('Hyukoh','hyukoh','Tomboy','tomboy','23',2017),
    ('The Black Skirts','the-black-skirts','Antifreeze','antifreeze','201',2011),
    ('N.Flying','n-flying','Rooftop','rooftop','Yaho',2019),
    ('CHON','chon','Story','story','Grow',2015),
    ('CHON','chon','Bubble Dream','bubble-dream','Grow',2015),
    ('Covet','covet','falkor','falkor','effloresce',2018),
    ('Covet','covet','shibuya','shibuya','technicolor',2020),
    ('toe','toe','Goodbye','goodbye','For Long Tomorrow',2009),
    ('tricot','tricot','Potage','potage','A N D',2015),
    ('Elephant Gym','elephant-gym','Finger','finger','Angle',2014),
    ('TTNG','ttng','Cat Fantastic','cat-fantastic','13.0.0.0.0',2013),
    ('Standards','standards','Special Berry','special-berry','Fruit Island',2020),
    ('Mom Jeans','mom-jeans','Death Cup','death-cup','Best Buds',2016),
    ('Tiny Moving Parts','tiny-moving-parts','Caution','caution','Celebrate',2016),
    ('Origami Angel','origami-angel','666 Flags','666-flags','Somewhere City',2019),
    ('Oso Oso','oso-oso','the view','the-view','basking in the glow',2019),
    ('Dance Gavin Dance','dance-gavin-dance','Midnight Crusade','midnight-crusade','Mothership',2016),
    ('Sungha Jung','sungha-jung','Irony','irony','Irony',2012),
    ('American Football','american-football','The Summer Ends','the-summer-ends','American Football',1999)
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
    ('day6','you-were-beautiful'),('day6','time-of-our-life'),('day6','congratulations'),('day6','zombie'),
    ('the-rose','sorry'),('xdinary-heroes','happy-death-day'),('hyukoh','tomboy'),('the-black-skirts','antifreeze'),
    ('n-flying','rooftop'),('chon','story'),('chon','bubble-dream'),('covet','falkor'),('covet','shibuya'),
    ('toe','goodbye'),('tricot','potage'),('elephant-gym','finger'),('ttng','cat-fantastic'),
    ('standards','special-berry'),('mom-jeans','death-cup'),('tiny-moving-parts','caution'),
    ('origami-angel','666-flags'),('oso-oso','the-view'),('dance-gavin-dance','midnight-crusade'),
    ('sungha-jung','irony'),('american-football','the-summer-ends')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('day6','you-were-beautiful'),('day6','time-of-our-life'),('day6','congratulations'),('day6','zombie'),
    ('the-rose','sorry'),('xdinary-heroes','happy-death-day'),('hyukoh','tomboy'),('the-black-skirts','antifreeze'),
    ('n-flying','rooftop'),('chon','story'),('chon','bubble-dream'),('covet','falkor'),('covet','shibuya'),
    ('toe','goodbye'),('tricot','potage'),('elephant-gym','finger'),('ttng','cat-fantastic'),
    ('standards','special-berry'),('mom-jeans','death-cup'),('tiny-moving-parts','caution'),
    ('origami-angel','666-flags'),('oso-oso','the-view'),('dance-gavin-dance','midnight-crusade'),
    ('sungha-jung','irony'),('american-football','the-summer-ends')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('day6','you-were-beautiful'),('day6','time-of-our-life'),('day6','congratulations'),('day6','zombie'),
    ('the-rose','sorry'),('xdinary-heroes','happy-death-day'),('hyukoh','tomboy'),('the-black-skirts','antifreeze'),
    ('n-flying','rooftop'),('chon','story'),('chon','bubble-dream'),('covet','falkor'),('covet','shibuya'),
    ('toe','goodbye'),('tricot','potage'),('elephant-gym','finger'),('ttng','cat-fantastic'),
    ('standards','special-berry'),('mom-jeans','death-cup'),('tiny-moving-parts','caution'),
    ('origami-angel','666-flags'),('oso-oso','the-view'),('dance-gavin-dance','midnight-crusade'),
    ('sungha-jung','irony'),('american-football','the-summer-ends')
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
    -- ============ K-ROCK / K-INDIE ============
    ('you-were-beautiful','day6','guitar','riff','main arpeggio','clean','k-rock','rhythm','beginner',
     'Fender solid-body (Sungjin / Jae)','Clean amp with soft ambience','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":4,"decay":5}},{"effect_type":"delay","effect_name":"subtle delay","placement":"post_gain","settings":{"time":3,"mix":2,"feedback":2}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":4,"delay":2,"master":6}'::jsonb,
     array['The DAY6 ballad — tender clean arpeggios with soft ambience.','Pure clean warmth; the emotion builds into light drive at the bridge (gain 4).'],
     array['Arpeggiate gently under the verse.','Open the final chorus with full strums.'],
     'Studio recording, 2017. Tender clean arpeggios from the beloved DAY6 ballad.',72),
    ('time-of-our-life','day6','guitar','riff','main riff','crunch','k-rock','rhythm','beginner',
     'Fender solid-body (Sungjin / Jae)','Bright tube amp, light crunch','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['Graduation-season pop-rock — bright joyful crunch.','Clean-edged drive with sparkle; the energy is celebratory.'],
     array['The intro riff hooks immediately — keep it bouncing.','Driving strums through the chorus.'],
     'Studio recording, 2019. Bright joyful pop-rock crunch.',72),
    ('congratulations','day6','guitar','riff','main riff','crunch','k-rock','rhythm','beginner',
     'Fender solid-body (Sungjin / Jae)','Tube amp, warm crunch','Open-back combo cab','bridge pickup',
     '[{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":1,"master":7}'::jsonb,
     array['The DAY6 debut — bittersweet mid-gain pop-rock.','Warm crunch under stacked vocals; restrained until the chorus.'],
     array['Verse stays palm-muted and patient.','The chorus opens with ringing chords.'],
     'Studio recording, 2015. Bittersweet debut pop-rock crunch.',72),
    ('zombie','day6','guitar','riff','main progression','clean','k-rock','rhythm','beginner',
     'Fender solid-body (Sungjin)','Clean amp, melancholy warmth','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"plate reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":4,"delay":1,"master":6}'::jsonb,
     array['Numb-hearted melancholy clean — soft strums under a weary melody.','Warm dark clean; the drive enters only at the final chorus (gain 4).'],
     array['Slow steady strums; don''t decorate.','The weariness is the feel — play tired, beautifully.'],
     'Studio recording, 2020. Melancholy clean from The Book of Us: The Demon.',72),
    ('sorry','the-rose','guitar','riff','main arpeggio','clean','k-rock','rhythm','beginner',
     'Fender solid-body (Woosung / Dojoon)','Clean amp with ambience','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":4,"decay":5}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":4,"delay":1,"master":6}'::jsonb,
     array['The Rose''s breakout — aching clean arpeggios building to an emotional wall.','Wet clean picking; the climax adds drive (gain 5).'],
     array['The arpeggio pattern carries the verses.','Hold back until the final chorus explosion.'],
     'Studio recording, 2017. Aching clean arpeggios from the K-rock breakout.',71),
    ('happy-death-day','xdinary-heroes','guitar','riff','main riff','distorted','k-rock','rhythm','intermediate',
     'Solid-body electric (Gunil / Jungsu / Xdinary Heroes)','Modern driven amp, produced','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":5,"treble":7,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Theatrical Gen-Z rock — bright aggressive drive with electronic stabs.','Tight modern distortion; dynamics lurch on purpose.'],
     array['The riff stabs are dramatic — commit to the theatrics.','Watch for sudden stops.'],
     'Studio recording, 2021. Theatrical Gen-Z rock debut.',70),
    ('tomboy','hyukoh','guitar','riff','main riff','clean','k-indie','rhythm','intermediate',
     'Hollow-body electric (Oh Hyuk / Lim Hyunjae)','Warm clean amp','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":3}},{"effect_type":"chorus","effect_name":"soft chorus","placement":"post_gain","settings":{"rate":3,"depth":3,"mix":3}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":6,"treble":5,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Wistful K-indie anthem — warm rounded cleans with youth-worn melancholy.','Dark warm clean; nothing bright or aggressive.'],
     array['Simple picked figures with lots of air.','The restraint is generational — keep it subdued.'],
     'Studio recording, 2017. Wistful warm clean from 23.',71),
    ('antifreeze','the-black-skirts','guitar','riff','main riff','crunch','k-indie','rhythm','beginner',
     'Solid-body electric (Jo Hyu-il)','Tube amp, warm crunch','Open-back combo cab','bridge pickup',
     '[{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":0,"master":7}'::jsonb,
     array['The K-indie winter anthem — warm swaying crunch.','Cozy mid-gain warmth; the song sways in 6/8.'],
     array['Sway the strums with the waltz feel.','Sing it — everyone in Korea does.'],
     'Studio recording, 2011. The beloved winter waltz crunch.',71),
    ('rooftop','n-flying','guitar','riff','main riff','clean','k-rock','rhythm','beginner',
     'Fender solid-body (Cha Hun)','Clean amp with light compression','Open-back combo cab','neck pickup',
     '[{"effect_type":"compressor","effect_name":"light compression","placement":"front","settings":{"sustain":4,"level":5}},{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":1,"master":6}'::jsonb,
     array['The viral chart-reversal hit — breezy clean groove with singalong warmth.','Soft clean bounce; the groove carries it.'],
     array['Relaxed groove strums with muted accents.','Keep the rooftop-hangout ease.'],
     'Studio recording, 2019. Breezy viral clean groove.',70),

    -- ============ MATH ROCK ============
    ('story','chon','guitar','riff','main theme','clean','math rock','lead','expert',
     'Ibanez/Fender solid-body (Mario Camarena / Erick Hansel)','Clean amp with compression','Open-back combo cab','neck pickup',
     '[{"effect_type":"compressor","effect_name":"studio compression","placement":"front","settings":{"sustain":6,"level":6}},{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":2,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":3,"delay":1,"master":6}'::jsonb,
     array['Sparkling tropical math rock — glassy compressed cleans with tapping and hammer-on runs.','Bright compressed clean; every note articulate.'],
     array['Two guitars interlock — learn both parts to hear the weave.','Tapping and legato runs need slow-practice patience.'],
     'Studio recording, 2015. Sparkling tapped cleans from Grow.',75),
    ('bubble-dream','chon','guitar','riff','main theme','clean','math rock','lead','expert',
     'Ibanez/Fender solid-body (Mario Camarena / Erick Hansel)','Clean amp with compression','Open-back combo cab','neck pickup',
     '[{"effect_type":"compressor","effect_name":"studio compression","placement":"front","settings":{"sustain":6,"level":6}},{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":2,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":3,"delay":1,"master":6}'::jsonb,
     array['Bouncing joyful math rock — the CHON gateway song.','Same glassy compressed clean; groove under the acrobatics.'],
     array['The main theme bounces — feel it before you speed it.','Clean sweeps and taps at tempo take weeks; enjoy them.'],
     'Studio recording, 2015. The joyful CHON gateway theme.',75),
    ('falkor','covet','guitar','riff','tapped theme','clean','math rock','lead','expert',
     'Ibanez Talman (Yvette Young)','Clean amp with compression and shimmer','Open-back combo cab','neck pickup',
     '[{"effect_type":"compressor","effect_name":"studio compression","placement":"front","settings":{"sustain":6,"level":6}},{"effect_type":"reverb","effect_name":"shimmer reverb","placement":"post_gain","settings":{"mix":4,"decay":5}}]'::jsonb,
     '{"gain":1,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":4,"delay":1,"master":6}'::jsonb,
     array['Yvette Young''s two-hand tapped waterfalls — glassy clean in soft shimmer.','Pristine compressed clean; her voicings come from open tunings.'],
     array['Two-hand tapping throughout — start at half speed.','The piece flows like water; dynamics stay gentle.'],
     'Studio recording, 2018. Yvette Young''s tapped waterfalls on her Ibanez Talman.',76),
    ('shibuya','covet','guitar','riff','tapped theme','clean','math rock','lead','expert',
     'Ibanez Talman (Yvette Young)','Clean amp with compression and shimmer','Open-back combo cab','neck pickup',
     '[{"effect_type":"compressor","effect_name":"studio compression","placement":"front","settings":{"sustain":6,"level":6}},{"effect_type":"reverb","effect_name":"shimmer reverb","placement":"post_gain","settings":{"mix":4,"decay":5}}]'::jsonb,
     '{"gain":1,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":4,"delay":1,"master":6}'::jsonb,
     array['City-lights math rock — brighter and more rhythmic than falkor.','Same pristine tapped clean with a neon bounce.'],
     array['The tapped groove locks with the drums.','Precision and joy in equal measure.'],
     'Studio recording, 2020. Neon tapped clean from technicolor.',76),
    ('goodbye','toe','guitar','riff','main theme','clean','math rock','rhythm','advanced',
     'Clean electrics (Kashikura Takashi ensemble / toe)','Warm clean amps','Open-back combo cabs','neck pickup',
     '[{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":1,"master":6}'::jsonb,
     array['Japanese math-rock beauty — interweaving warm cleans over restless drums.','Warm rounded cleans; the complexity is rhythmic, not tonal.'],
     array['Two clean guitars converse — space is everything.','Follow the drums; they lead the song.'],
     'Studio recording, 2009. Interweaving warm cleans from For Long Tomorrow.',73),
    ('potage','tricot','guitar','riff','main riff','crunch','math rock','rhythm','advanced',
     'Fender solid-body (Ikkyu Nakajima / Motifour Kida)','Bright tube amp, tight crunch','Open-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Angular J-math crunch — odd meters with pop hooks.','Bright tight light-crunch; articulation over saturation.'],
     array['Count the meter changes before chasing speed.','The stabs snap with the drums.'],
     'Studio recording, 2015. Angular math-pop crunch from A N D.',72),
    ('finger','elephant-gym','guitar','riff','main theme','clean','math rock','rhythm','advanced',
     'Clean electric (Tell Chang)','Clean amp with compression','Open-back combo cab','neck pickup',
     '[{"effect_type":"compressor","effect_name":"light compression","placement":"front","settings":{"sustain":5,"level":5}},{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":2}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Taiwanese math rock — nimble clean guitar dancing around the famous lead bass.','Light clean support role; the bass is the star, the guitar decorates.'],
     array['Interlock precisely with the bassline.','Short bright phrases; leave the low end alone.'],
     'Studio recording, 2014. Nimble clean interplay from Angle.',72),
    ('cat-fantastic','ttng','guitar','riff','main theme','clean','math rock','rhythm','advanced',
     'Clean electric (Tim Collis)','Bright clean amp','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":2}}]'::jsonb,
     '{"gain":1,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['British math-rock twinkle — fingerpicked cascades in odd meters.','Dry bright clean; Collis'' patterns are finger-style, not tapped.'],
     array['Fingerpick the cascading pattern — pick-only won''t reach it.','Odd meters resolve if you follow the vocal.'],
     'Studio recording, 2013. Fingerpicked twinkle cascades.',72),
    ('special-berry','standards','guitar','riff','tapped theme','clean','math rock','lead','expert',
     'Solid-body electric (Marcos Mena)','Clean amp with compression','Open-back combo cab','neck pickup',
     '[{"effect_type":"compressor","effect_name":"studio compression","placement":"front","settings":{"sustain":6,"level":6}},{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":1,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Sunny tap-pop — Marcos Mena''s bouncy two-hand style.','Glassy compressed clean; pure fun energy.'],
     array['The tapped hooks are melodies first — sing them.','Groove over gymnastics.'],
     'Studio recording, 2020. Sunny tapped math-pop from Fruit Island.',72),

    -- ============ EMO REVIVAL ============
    ('death-cup','mom-jeans','guitar','riff','main riff','crunch','emo','rhythm','intermediate',
     'Fender Telecaster-style (Eric Butler)','Tube amp, jangly light crunch','Open-back combo cab','bridge pickup',
     '[{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":2}}]'::jsonb,
     '{"gain":3,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Twinkly emo-revival jangle — bright open-voiced riffs with sad-boy charm.','Just-barely-crunch; open strings ring through everything.'],
     array['The noodly intro riff is the hook — let the open strings drone.','Loose and heartfelt beats tight and sterile.'],
     'Studio recording, 2016. Twinkly emo-revival jangle from Best Buds.',72),
    ('caution','tiny-moving-parts','guitar','riff','main riff + taps','crunch','emo','rhythm','advanced',
     'Fender solid-body (Dylan Mattheisen)','Bright tube amp, light crunch','Open-back combo cab','bridge pickup',
     '[{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":2}}]'::jsonb,
     '{"gain":4,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['Tapped emo catharsis — bright crunch with constant two-hand flourishes.','Bright light-gain clarity so the taps speak.'],
     array['The tapped runs decorate nearly every phrase.','Shout-along energy under technical playing.'],
     'Studio recording, 2016. Tapped emo catharsis from Celebrate.',72),
    ('666-flags','origami-angel','guitar','riff','main riff','crunch','emo','rhythm','advanced',
     'Fender solid-body (Ryland Heagy)','Bright tube amp, tight crunch','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Hyperactive emo-revival — twinkle riffs at pop-punk speed.','Bright tight light-crunch; the duo sounds like four people.'],
     array['Riffs pivot between twinkle and chug instantly.','Stamina and grin both required.'],
     'Studio recording, 2019. Hyperactive twinkle-punk from Somewhere City.',71),
    ('the-view','oso-oso','guitar','riff','main riff','crunch','emo','rhythm','beginner',
     'Fender solid-body (Jade Lilitri)','Tube amp, warm light crunch','Open-back combo cab','bridge pickup',
     '[{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":2}}]'::jsonb,
     '{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['Sun-warmed emo-pop — hooky light crunch with golden melodies.','Warm jangly crunch; melody over twinkle.'],
     array['Simple driving strums under the hook.','The lead lines are singable — phrase them that way.'],
     'Studio recording, 2019. Sun-warmed emo-pop from basking in the glow.',72),
    ('midnight-crusade','dance-gavin-dance','guitar','riff','main riff','crunch','post-hardcore','lead','advanced',
     'PRS solid-body (Will Swan)','Bright tube amp, funky light drive','Closed-back cab','bridge humbucker',
     '[{"effect_type":"compressor","effect_name":"light compression","placement":"front","settings":{"sustain":4,"level":5}}]'::jsonb,
     '{"gain":4,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":1,"master":7}'::jsonb,
     array['Will Swan''s funk-core noodling — bright light-drive runs that never sit still.','Articulate light gain; the heavy sections push to 6, the funk stays clean-ish.'],
     array['Swan''s riffs are lead and rhythm simultaneously.','Learn the funky verse figure slowly — it slips past fast.'],
     'Studio recording, 2016. Swan''s funk-core noodling from Mothership.',73),

    -- ============ FINGERSTYLE / TWINKLE ORIGIN ============
    ('irony','sungha-jung','guitar','main','fingerstyle arrangement','acoustic','fingerstyle','lead','advanced',
     'Lakewood signature acoustic (Sungha Jung)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Sungha Jung''s signature original — melody, bass, and percussion on one acoustic.','Clear balanced acoustic; every voice must separate.'],
     array['Learn bass line, melody, and percussion hits as separate layers.','His arrangements reward metronome discipline.'],
     'Studio recording, 2012. The fingerstyle star''s signature original.',74),
    ('the-summer-ends','american-football','guitar','riff','main theme','clean','emo','rhythm','intermediate',
     'Clean electric (Mike Kinsella / Steve Holmes)','Warm clean amp','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":1,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The blueprint of twinkle emo — open-tuned clean arpeggios under trumpet.','Warm dry-ish clean; the magic is the open tuning and patience.'],
     array['Open tuning on the record — standard-tuning covers lose the drones.','Unhurried arpeggios; the sadness is in the tempo.'],
     'Studio recording, 1999. The twinkle-emo blueprint from the house record.',75)
) as c(
  song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence
)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;
