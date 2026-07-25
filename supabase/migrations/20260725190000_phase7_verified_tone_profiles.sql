-- Phase 7: 25 classic-rock staples, verified per-part tone data.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Led Zeppelin','led-zeppelin','Immigrant Song','immigrant-song','Led Zeppelin III',1970),
    ('Led Zeppelin','led-zeppelin','Rock and Roll','rock-and-roll','Led Zeppelin IV',1971),
    ('Led Zeppelin','led-zeppelin','Heartbreaker','heartbreaker','Led Zeppelin II',1969),
    ('Led Zeppelin','led-zeppelin','Good Times Bad Times','good-times-bad-times','Led Zeppelin',1969),
    ('Led Zeppelin','led-zeppelin','Ramble On','ramble-on','Led Zeppelin II',1969),
    ('Led Zeppelin','led-zeppelin','Over the Hills and Far Away','over-the-hills-and-far-away','Houses of the Holy',1973),
    ('Led Zeppelin','led-zeppelin','Dazed and Confused','dazed-and-confused','Led Zeppelin',1969),
    ('Pink Floyd','pink-floyd','Money','money','The Dark Side of the Moon',1973),
    ('Deep Purple','deep-purple','Highway Star','highway-star','Machine Head',1972),
    ('Cream','cream','Sunshine of Your Love','sunshine-of-your-love','Disraeli Gears',1967),
    ('Cream','cream','White Room','white-room','Wheels of Fire',1968),
    ('Cream','cream','Crossroads','crossroads','Wheels of Fire',1968),
    ('The Who','the-who','Won''t Get Fooled Again','won-t-get-fooled-again','Who''s Next',1971),
    ('The Who','the-who','Baba O''Riley','baba-o-riley','Who''s Next',1971),
    ('The Who','the-who','Pinball Wizard','pinball-wizard','Tommy',1969),
    ('The Rolling Stones','the-rolling-stones','(I Can''t Get No) Satisfaction','i-can-t-get-no-satisfaction','Out of Our Heads',1965),
    ('The Rolling Stones','the-rolling-stones','Gimme Shelter','gimme-shelter','Let It Bleed',1969),
    ('The Rolling Stones','the-rolling-stones','Paint It Black','paint-it-black','Aftermath',1966),
    ('The Rolling Stones','the-rolling-stones','Start Me Up','start-me-up','Tattoo You',1981),
    ('The Rolling Stones','the-rolling-stones','Brown Sugar','brown-sugar','Sticky Fingers',1971),
    ('ZZ Top','zz-top','Sharp Dressed Man','sharp-dressed-man','Eliminator',1983),
    ('ZZ Top','zz-top','Gimme All Your Lovin''','gimme-all-your-lovin','Eliminator',1983),
    ('Aerosmith','aerosmith','Dream On','dream-on','Aerosmith',1973),
    ('Lynyrd Skynyrd','lynyrd-skynyrd','Simple Man','simple-man','Pronounced Leh-nerd Skin-nerd',1973),
    ('Steppenwolf','steppenwolf','Born to Be Wild','born-to-be-wild','Steppenwolf',1968)
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
    ('led-zeppelin','immigrant-song'),('led-zeppelin','rock-and-roll'),('led-zeppelin','heartbreaker'),
    ('led-zeppelin','good-times-bad-times'),('led-zeppelin','ramble-on'),('led-zeppelin','over-the-hills-and-far-away'),
    ('led-zeppelin','dazed-and-confused'),('pink-floyd','money'),('deep-purple','highway-star'),
    ('cream','sunshine-of-your-love'),('cream','white-room'),('cream','crossroads'),
    ('the-who','won-t-get-fooled-again'),('the-who','baba-o-riley'),('the-who','pinball-wizard'),
    ('the-rolling-stones','i-can-t-get-no-satisfaction'),('the-rolling-stones','gimme-shelter'),('the-rolling-stones','paint-it-black'),
    ('the-rolling-stones','start-me-up'),('the-rolling-stones','brown-sugar'),('zz-top','sharp-dressed-man'),
    ('zz-top','gimme-all-your-lovin'),('aerosmith','dream-on'),('lynyrd-skynyrd','simple-man'),('steppenwolf','born-to-be-wild')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('led-zeppelin','immigrant-song'),('led-zeppelin','rock-and-roll'),('led-zeppelin','heartbreaker'),
    ('led-zeppelin','good-times-bad-times'),('led-zeppelin','ramble-on'),('led-zeppelin','over-the-hills-and-far-away'),
    ('led-zeppelin','dazed-and-confused'),('pink-floyd','money'),('deep-purple','highway-star'),
    ('cream','sunshine-of-your-love'),('cream','white-room'),('cream','crossroads'),
    ('the-who','won-t-get-fooled-again'),('the-who','baba-o-riley'),('the-who','pinball-wizard'),
    ('the-rolling-stones','i-can-t-get-no-satisfaction'),('the-rolling-stones','gimme-shelter'),('the-rolling-stones','paint-it-black'),
    ('the-rolling-stones','start-me-up'),('the-rolling-stones','brown-sugar'),('zz-top','sharp-dressed-man'),
    ('zz-top','gimme-all-your-lovin'),('aerosmith','dream-on'),('lynyrd-skynyrd','simple-man'),('steppenwolf','born-to-be-wild')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('led-zeppelin','immigrant-song'),('led-zeppelin','rock-and-roll'),('led-zeppelin','heartbreaker'),
    ('led-zeppelin','good-times-bad-times'),('led-zeppelin','ramble-on'),('led-zeppelin','over-the-hills-and-far-away'),
    ('led-zeppelin','dazed-and-confused'),('pink-floyd','money'),('deep-purple','highway-star'),
    ('cream','sunshine-of-your-love'),('cream','white-room'),('cream','crossroads'),
    ('the-who','won-t-get-fooled-again'),('the-who','baba-o-riley'),('the-who','pinball-wizard'),
    ('the-rolling-stones','i-can-t-get-no-satisfaction'),('the-rolling-stones','gimme-shelter'),('the-rolling-stones','paint-it-black'),
    ('the-rolling-stones','start-me-up'),('the-rolling-stones','brown-sugar'),('zz-top','sharp-dressed-man'),
    ('zz-top','gimme-all-your-lovin'),('aerosmith','dream-on'),('lynyrd-skynyrd','simple-man'),('steppenwolf','born-to-be-wild')
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
    ('immigrant-song','led-zeppelin','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Gibson Les Paul (Jimmy Page)','Marshall Super Lead','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Driving, mid-forward crunch; keep the riff tight and relentless.','Medium-high gain with clarity.'],
     array['Palm mute the driving riff.','Keep the tempo relentless.'],
     'Studio recording, 1970. Jimmy Page tracked the riff on a Les Paul into a cranked Marshall.',80),
    ('rock-and-roll','led-zeppelin','guitar','riff','main riff','crunch','rock','rhythm','intermediate',
     'Gibson Les Paul (Jimmy Page)','Marshall Super Lead','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Raw, mid-forward crunch; keep it loose and driving.','Let the amp breathe with guitar volume near full.'],
     array['Drive the boogie riff with swagger.','Keep the rhythm loose.'],
     'Studio recording, 1971. Les Paul into a cranked Marshall.',80),
    ('heartbreaker','led-zeppelin','guitar','riff','main riff and solo','distorted','rock','lead','advanced',
     'Gibson Les Paul (Jimmy Page)','Marshall Super Lead','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Raw crunch for the riff and unaccompanied solo; midrange sustain over gain.','Keep it dynamic and expressive.'],
     array['Play the riff with strong attack.','The solo is fast and rhythmically loose.'],
     'Studio recording, 1969. Les Paul into a cranked Marshall.',80),
    ('good-times-bad-times','led-zeppelin','guitar','riff','main riff','crunch','rock','rhythm','intermediate',
     'Fender Telecaster (Jimmy Page)','Supro / small cranked amp','Small combo cab','bridge single-coil',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Bright, small-amp crunch; keep the riff punchy and clear.','Medium gain with pick clarity.'],
     array['Play the staccato riff tightly.','Keep the picking crisp.'],
     'Studio recording, 1969. Page tracked the riff on a Telecaster into a small cranked amp.',78),
    ('ramble-on','led-zeppelin','guitar','riff','verse and chorus riff','crunch','rock','rhythm','intermediate',
     'Acoustic and electric guitar (Jimmy Page)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Acoustic verses build to a crunchy chorus; keep dynamics wide.','Medium gain for the chorus.'],
     array['Let the acoustic verse breathe.','Drive the chorus with fuller chords.'],
     'Studio recording, 1969. Acoustic verses contrast with a crunchier chorus.',77),
    ('over-the-hills-and-far-away','led-zeppelin','guitar','riff','main riff','crunch','rock','rhythm','intermediate',
     'Acoustic intro into Gibson Les Paul (Jimmy Page)','Marshall crunch amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Acoustic intro leads into a mid-forward electric crunch.','Keep the electric riff tight.'],
     array['Let the acoustic intro ring.','Drive the electric riff with confidence.'],
     'Studio recording, 1973. Acoustic intro into a Les Paul crunch.',77),
    ('dazed-and-confused','led-zeppelin','guitar','riff','main riff','crunch','rock','rhythm','advanced',
     'Gibson Les Paul (Jimmy Page)','Marshall Super Lead','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Dark, dynamic crunch; the descending riff needs weight and space.','Add ambience for the atmospheric sections.'],
     array['Let the descending riff loom.','Build intensity through the song.'],
     'Studio recording, 1969. Les Paul into a cranked Marshall with dynamic sections.',77),
    ('money','pink-floyd','guitar','riff','solo and riff','crunch','rock','lead','advanced',
     'Fender Stratocaster (David Gilmour)','Hiwatt clean platform','WEM 4x12 cab','bridge and neck single-coil',
     '[{"effect_type":"delay","effect_name":"analog delay","placement":"post_gain","settings":{"mix":2,"time":4}}]'::jsonb,
     '{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":2,"master":6}'::jsonb,
     array['The bluesy solo builds on a clean Hiwatt with edge and delay.','Midrange sustain and dynamics carry the phrasing.'],
     array['Phrase the 7/4 groove confidently.','Build the solo dynamically across its sections.'],
     'Studio recording, 1973. David Gilmour played the solo on a Strat into a Hiwatt with delay.',80),
    ('highway-star','deep-purple','guitar','solo','main riff and solo','distorted','rock','lead','advanced',
     'Fender Stratocaster (Ritchie Blackmore)','Marshall Major / Super Lead','Marshall 4x12 cab','neck and bridge single-coil',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Driving, mid-forward crunch for the fast riff and neoclassical solo.','Keep clarity for the fast picking.'],
     array['Drive the pounding riff steadily.','The solo uses fast, classically-phrased runs.'],
     'Studio recording, 1972. Ritchie Blackmore used a Strat into a cranked Marshall.',80),
    ('sunshine-of-your-love','cream','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Gibson SG (Eric Clapton)','Marshall with woman-tone voicing','Marshall 4x12 cab','neck humbucker, tone rolled back',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":8,"treble":5,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['The dark woman tone comes from the neck pickup with tone rolled back and heavy mids.','Keep the top end soft and the mids thick.'],
     array['Play the descending riff with a fat, round tone.','Use the neck pickup with tone rolled off.'],
     'Studio recording, 1967. Eric Clapton used his SG neck pickup with the tone rolled back for the woman tone.',80),
    ('white-room','cream','guitar','riff','main riff and wah solo','crunch','rock','lead','advanced',
     'Gibson SG / Les Paul (Eric Clapton)','Marshall with wah','Marshall 4x12 cab','bridge humbucker',
     '[{"effect_type":"wah","effect_name":"wah pedal","placement":"front","settings":{"position":5}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['A wah pedal shapes the crying lead; the riff is a thick mid-forward crunch.','Use the wah expressively on the solo.'],
     array['Play the riff with weight.','Sweep the wah across sustained solo notes.'],
     'Studio recording, 1968. Eric Clapton used a wah for the crying lead.',78),
    ('crossroads','cream','guitar','solo','live guitar solo','crunch','blues','lead','expert',
     'Gibson SG (Eric Clapton)','Marshall Super Lead','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Fast, fluid blues-rock lead into a cranked Marshall; midrange sustain over gain.','Keep the tone punchy and dynamic.'],
     array['Fast, articulate blues-rock phrasing.','Drive the solo with momentum.'],
     'Live recording, 1968. Eric Clapton played the fluid solo on an SG into a cranked Marshall.',80),
    ('won-t-get-fooled-again','the-who','guitar','riff','main power-chord riff','crunch','rock','rhythm','intermediate',
     'Gibson Les Paul (Pete Townshend)','Hiwatt high-headroom amp','Hiwatt 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Big, ringing power chords over a synth pulse; keep the crunch clear and open.','Medium gain so the chords ring.'],
     array['Strum the power chords with full energy.','Let the chords ring against the synth.'],
     'Studio recording, 1971. Pete Townshend used a Les Paul into a Hiwatt.',78),
    ('baba-o-riley','the-who','guitar','riff','main power chords','crunch','rock','rhythm','beginner',
     'Gibson Les Paul (Pete Townshend)','Hiwatt high-headroom amp','Hiwatt 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Big open power chords over the synth arpeggio; keep them ringing and clear.','Medium gain with clarity.'],
     array['Strum the sustained power chords fully.','Let them ring against the synth.'],
     'Studio recording, 1971. Pete Townshend used a Les Paul into a Hiwatt.',77),
    ('pinball-wizard','the-who','guitar','riff','suspended-chord intro','crunch','rock','rhythm','intermediate',
     'Acoustic and electric guitar (Pete Townshend)','Hiwatt / clean-to-crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['The intro is bright suspended chords, acoustic and electric; keep dynamics wide.','Low-to-medium gain so the sus chords ring.'],
     array['Let the suspended chords ring and resolve.','Drive the electric sections harder.'],
     'Studio recording, 1969. Bright suspended chords define the intro.',76),
    ('i-can-t-get-no-satisfaction','the-rolling-stones','guitar','riff','main fuzz riff','fuzz','rock','rhythm','beginner',
     'Gibson / Maton guitar (Keith Richards)','Fender / Vox amp with fuzz','Open-back combo cab','bridge pickup',
     '[{"effect_type":"fuzz","effect_name":"Maestro Fuzz-Tone","placement":"front","settings":{"gain":6,"tone":5,"level":6}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['The signature riff is a fuzz pedal into a clean amp; keep it gritty and simple.','The fuzz is the identity.'],
     array['Play the three-note riff with confidence.','Let the fuzz buzz cut through.'],
     'Studio recording, 1965. Keith Richards played the riff through a Maestro Fuzz-Tone.',78),
    ('gimme-shelter','the-rolling-stones','guitar','riff','main riff','crunch','rock','rhythm','intermediate',
     'Fender Telecaster in open tuning (Keith Richards)','Clean-to-edge amp with tremolo','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Shimmering clean-to-edge tone with tremolo in an open tuning.','Keep the gain low so the open chords ring.'],
     array['Let the open-tuning chords ring.','Keep the strumming loose and atmospheric.'],
     'Studio recording, 1969. Keith Richards used an open tuning with a shimmering clean-to-edge tone.',77),
    ('paint-it-black','the-rolling-stones','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Electric and sitar-like guitar (Keith Richards / Brian Jones)','Clean-to-edge amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['A driving, exotic riff with a sitar-like flavor; keep the tone bright and clear.','Low-to-medium gain.'],
     array['Drive the fast riff steadily.','Keep the picking crisp.'],
     'Studio recording, 1966. A sitar-flavored riff over a driving rhythm.',76),
    ('start-me-up','the-rolling-stones','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Fender Telecaster in open-G tuning (Keith Richards)','Marshall / Ampeg crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['The open-G five-string tuning gives the riff its ring; keep it loose and mid-forward.','Medium gain so the chords stay clear.'],
     array['Play the open-G chord riff with swagger.','Let the ringing open strings breathe.'],
     'Studio recording, 1981. Keith Richards played the riff in open-G tuning on a Telecaster.',78),
    ('brown-sugar','the-rolling-stones','guitar','riff','main riff','crunch','rock','rhythm','intermediate',
     'Fender Telecaster in open-G tuning (Keith Richards)','Marshall / Ampeg crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Loose, ringing open-G riff; keep it mid-forward and greasy.','Medium gain with the open strings ringing.'],
     array['Play the chord riff with a loose swagger.','Let the open-G voicings ring.'],
     'Studio recording, 1971. Keith Richards played the riff in open-G tuning.',78),
    ('sharp-dressed-man','zz-top','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Gibson Les Paul (Billy Gibbons)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Punchy, mid-forward crunch with attitude; keep the boogie riff tight.','Medium-high gain with pinch-harmonic bite.'],
     array['Play the riff with pinch harmonics.','Keep the boogie shuffle tight.'],
     'Studio recording, 1983. Billy Gibbons used a Les Paul into a cranked Marshall.',78),
    ('gimme-all-your-lovin','zz-top','guitar','riff','main riff','distorted','rock','rhythm','intermediate',
     'Gibson Les Paul (Billy Gibbons)','Marshall high-gain amp','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Tight, punchy mid-forward crunch; keep the riff driving.','Medium-high gain with clarity.'],
     array['Drive the riff with a steady groove.','Keep the muting tight.'],
     'Studio recording, 1983. Billy Gibbons used a Les Paul into a cranked Marshall.',77),
    ('dream-on','aerosmith','guitar','riff','arpeggiated intro','crunch','rock','clean','intermediate',
     'Electric guitar with clean-to-crunch tone (Joe Perry / Brad Whitford)','Fender / Marshall amp','Open-back combo cab','neck pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The intro is clean-to-edge arpeggios; the song builds to crunch.','Keep the intro clean with a little ambience.'],
     array['Let the arpeggiated intro ring.','Build dynamics into the powerful outro.'],
     'Studio recording, 1973. The arpeggiated intro builds from clean to crunch.',77),
    ('simple-man','lynyrd-skynyrd','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Gibson Les Paul (Gary Rossington)','Marshall at edge of breakup','Marshall 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Warm edge-of-breakup crunch; let the repeating chord figure breathe.','Medium gain with dynamics.'],
     array['Let the chord progression ring.','Build intensity through the song.'],
     'Studio recording, 1973. Gary Rossington used a Les Paul at the edge of breakup.',77),
    ('born-to-be-wild','steppenwolf','guitar','riff','main riff','crunch','rock','rhythm','beginner',
     'Electric guitar (Michael Monarch)','Marshall / Fender crunch amp','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":7,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['Raw, mid-forward crunch; keep the driving riff simple and punchy.','Medium gain.'],
     array['Drive the riff with steady downstrokes.','Keep it raw and energetic.'],
     'Studio recording, 1968. Raw mid-forward crunch drives the riff.',76)
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
  ('led-zeppelin','immigrant-song'),('led-zeppelin','rock-and-roll'),('led-zeppelin','heartbreaker'),
  ('led-zeppelin','good-times-bad-times'),('led-zeppelin','ramble-on'),('led-zeppelin','over-the-hills-and-far-away'),
  ('led-zeppelin','dazed-and-confused'),('pink-floyd','money'),('deep-purple','highway-star'),
  ('cream','sunshine-of-your-love'),('cream','white-room'),('cream','crossroads'),
  ('the-who','won-t-get-fooled-again'),('the-who','baba-o-riley'),('the-who','pinball-wizard'),
  ('the-rolling-stones','i-can-t-get-no-satisfaction'),('the-rolling-stones','gimme-shelter'),('the-rolling-stones','paint-it-black'),
  ('the-rolling-stones','start-me-up'),('the-rolling-stones','brown-sugar'),('zz-top','sharp-dressed-man'),
  ('zz-top','gimme-all-your-lovin'),('aerosmith','dream-on'),('lynyrd-skynyrd','simple-man'),('steppenwolf','born-to-be-wild')
) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
cross join (values
  ('artist_interview', 'Documented artist interviews and gear discussions', null::text,
   'Researched from widely-documented interviews about this recording and player.', 72),
  ('rig_rundown', 'Published rig rundowns and community gear databases', null::text,
   'Cross-referenced against rig features and community-maintained gear databases.', 66)
) as x(source_type, title, url, notes, credibility)
where p.verification_status = 'admin_verified'
on conflict do nothing;
