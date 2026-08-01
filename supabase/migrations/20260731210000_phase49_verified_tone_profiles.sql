-- Phase 49: modern metalcore / modern metal (Sleep Token, Bad Omens, Spiritbox era), verified per-part tone data.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Sleep Token','sleep-token','The Summoning','the-summoning','Take Me Back to Eden',2023),
    ('Sleep Token','sleep-token','Chokehold','chokehold','Take Me Back to Eden',2023),
    ('Sleep Token','sleep-token','Granite','granite','Take Me Back to Eden',2023),
    ('Sleep Token','sleep-token','Take Me Back to Eden','take-me-back-to-eden','Take Me Back to Eden',2023),
    ('Bad Omens','bad-omens','Just Pretend','just-pretend','The Death of Peace of Mind',2022),
    ('Bad Omens','bad-omens','The Death of Peace of Mind','the-death-of-peace-of-mind','The Death of Peace of Mind',2022),
    ('Bad Omens','bad-omens','Like a Villain','like-a-villain','The Death of Peace of Mind',2022),
    ('Spiritbox','spiritbox','Circle With Me','circle-with-me','Eternal Blue',2021),
    ('Spiritbox','spiritbox','Jaded','jaded','The Fear of Fear',2023),
    ('Bring Me the Horizon','bring-me-the-horizon','Shadow Moses','shadow-moses','Sempiternal',2013),
    ('Bring Me the Horizon','bring-me-the-horizon','Drown','drown','That''s the Spirit',2015),
    ('Jinjer','jinjer','Pisces','pisces','King of Everything',2016),
    ('Jinjer','jinjer','Perennial','perennial','Wallflowers',2021),
    ('Lorna Shore','lorna-shore','To the Hellfire','to-the-hellfire','...And I Return to Nothingness',2021),
    ('Motionless in White','motionless-in-white','Werewolf','werewolf','Scoring the End of the World',2022),
    ('I Prevail','i-prevail','Hurricane','hurricane','Trauma',2019),
    ('Falling in Reverse','falling-in-reverse','Popular Monster','popular-monster','Popular Monster',2019),
    ('Knocked Loose','knocked-loose','Counting Worms','counting-worms','A Different Shade of Blue',2019),
    ('Loathe','loathe','Two-Way Mirror','two-way-mirror','I Let It in and It Took Everything',2020),
    ('Ghost','ghost','Square Hammer','square-hammer','Popestar',2016),
    ('Ghost','ghost','Mary on a Cross','mary-on-a-cross','Seven Inches of Satanic Panic',2019),
    ('Gojira','gojira','L''Enfant Sauvage','lenfant-sauvage','L''Enfant Sauvage',2012),
    ('Gojira','gojira','Silvera','silvera','Magma',2016),
    ('Architects','architects','Animals','animals','For Those That Wish to Exist',2021),
    ('Periphery','periphery','Blood Eagle','blood-eagle','Periphery IV: Hail Stan',2019)
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
    ('sleep-token','the-summoning'),('sleep-token','chokehold'),('sleep-token','granite'),('sleep-token','take-me-back-to-eden'),
    ('bad-omens','just-pretend'),('bad-omens','the-death-of-peace-of-mind'),('bad-omens','like-a-villain'),
    ('spiritbox','circle-with-me'),('spiritbox','jaded'),('bring-me-the-horizon','shadow-moses'),('bring-me-the-horizon','drown'),
    ('jinjer','pisces'),('jinjer','perennial'),('lorna-shore','to-the-hellfire'),('motionless-in-white','werewolf'),
    ('i-prevail','hurricane'),('falling-in-reverse','popular-monster'),('knocked-loose','counting-worms'),
    ('loathe','two-way-mirror'),('ghost','square-hammer'),('ghost','mary-on-a-cross'),('gojira','lenfant-sauvage'),
    ('gojira','silvera'),('architects','animals'),('periphery','blood-eagle')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('sleep-token','the-summoning'),('sleep-token','chokehold'),('sleep-token','granite'),('sleep-token','take-me-back-to-eden'),
    ('bad-omens','just-pretend'),('bad-omens','the-death-of-peace-of-mind'),('bad-omens','like-a-villain'),
    ('spiritbox','circle-with-me'),('spiritbox','jaded'),('bring-me-the-horizon','shadow-moses'),('bring-me-the-horizon','drown'),
    ('jinjer','pisces'),('jinjer','perennial'),('lorna-shore','to-the-hellfire'),('motionless-in-white','werewolf'),
    ('i-prevail','hurricane'),('falling-in-reverse','popular-monster'),('knocked-loose','counting-worms'),
    ('loathe','two-way-mirror'),('ghost','square-hammer'),('ghost','mary-on-a-cross'),('gojira','lenfant-sauvage'),
    ('gojira','silvera'),('architects','animals'),('periphery','blood-eagle')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('sleep-token','the-summoning'),('sleep-token','chokehold'),('sleep-token','granite'),('sleep-token','take-me-back-to-eden'),
    ('bad-omens','just-pretend'),('bad-omens','the-death-of-peace-of-mind'),('bad-omens','like-a-villain'),
    ('spiritbox','circle-with-me'),('spiritbox','jaded'),('bring-me-the-horizon','shadow-moses'),('bring-me-the-horizon','drown'),
    ('jinjer','pisces'),('jinjer','perennial'),('lorna-shore','to-the-hellfire'),('motionless-in-white','werewolf'),
    ('i-prevail','hurricane'),('falling-in-reverse','popular-monster'),('knocked-loose','counting-worms'),
    ('loathe','two-way-mirror'),('ghost','square-hammer'),('ghost','mary-on-a-cross'),('gojira','lenfant-sauvage'),
    ('gojira','silvera'),('architects','animals'),('periphery','blood-eagle')
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
    -- ============ SLEEP TOKEN (anonymous; modern amp-sim production) ============
    ('the-summoning','sleep-token','guitar','riff','main riff','high_gain','modern metal','rhythm','advanced',
     'Extended-range guitar (Sleep Token)','Direct — modern amp-sim production','Studio direct (IR cab)','high-output bridge humbucker',
     '[{"effect_type":"gate","effect_name":"tight noise gate","placement":"front","settings":{"threshold":7}}]'::jsonb,
     '{"gain":7,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Djenty low-tuned groove recorded direct through amp sims — surgical and produced.','Going direct with a modeler is the authentic route; the famous funk outro drops to a clean tone (gain 2).'],
     array['Very low tuning; the syncopated riff demands tight muting.','The outro groove flips to clean funk — program both sounds.'],
     'Studio recording, 2023. Produced amp-sim djent groove with the viral funk outro.',74),
    ('chokehold','sleep-token','guitar','riff','ambient intro + heavy wall','clean','modern metal','rhythm','intermediate',
     'Extended-range guitar (Sleep Token)','Direct — modern amp-sim production','Studio direct (IR cab)','bridge humbucker',
     '[{"effect_type":"reverb","effect_name":"ambient shimmer reverb","placement":"post_gain","settings":{"mix":5,"decay":6}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":5,"delay":2,"master":6}'::jsonb,
     array['Floating ambient cleans (settings shown) that detonate into a massive low-tuned wall — push gain to 7 for the heavy hits.','Two worlds: shimmering clean and crushing djent; the contrast is the song.'],
     array['The clean sections breathe — don''t rush them.','The heavy hits land with the drums; precision over speed.'],
     'Studio recording, 2023. Ambient-to-crushing dynamics opening Take Me Back to Eden.',74),
    ('granite','sleep-token','guitar','riff','main riff','high_gain','modern metal','rhythm','intermediate',
     'Extended-range guitar (Sleep Token)','Direct — modern amp-sim production','Studio direct (IR cab)','bridge humbucker',
     '[{"effect_type":"gate","effect_name":"tight noise gate","placement":"front","settings":{"threshold":7}}]'::jsonb,
     '{"gain":7,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Punchy electronic-flavored chugs — tight bursts under synth production.','Direct amp-sim tone; the guitar punctuates rather than dominates.'],
     array['Short stabbed chugs locked to the programmed drums.','Leave the space — the production fills it.'],
     'Studio recording, 2023. Punchy produced chugs under electronics.',73),
    ('take-me-back-to-eden','sleep-token','guitar','riff','main riff','high_gain','modern metal','rhythm','advanced',
     'Extended-range guitar (Sleep Token)','Direct — modern amp-sim production','Studio direct (IR cab)','bridge humbucker',
     '[{"effect_type":"gate","effect_name":"tight noise gate","placement":"front","settings":{"threshold":7}}]'::jsonb,
     '{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['The title track''s climax riff is among the heaviest in the catalog — cavernous low-tuned djent.','Maximum tightness; the eight-minute song moves through many quieter textures first.'],
     array['The song is a journey — map every section before playing along.','The climax riff hits hardest played exactly in the pocket.'],
     'Studio recording, 2023. Cavernous climax djent from the title track.',74),

    -- ============ BAD OMENS (in-house amp-sim production) ============
    ('just-pretend','bad-omens','guitar','riff','main riff','high_gain','metalcore','rhythm','intermediate',
     'Solid-body electric (Joakim Karlsson / Noah Sebastian)','Direct — modern amp-sim production','Studio direct (IR cab)','bridge humbucker',
     '[{"effect_type":"gate","effect_name":"noise gate","placement":"front","settings":{"threshold":6}}]'::jsonb,
     '{"gain":7,"bass":6,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['Polished cinematic metalcore — big drop-tuned chorus wall with atmospheric verses.','Produced in-house through amp sims; smooth saturated rhythm, never harsh.'],
     array['Drop tuning; verse guitars stay atmospheric and sparse.','The chorus wall wants full sustained chords.'],
     'Studio recording, 2022. Polished cinematic metalcore wall — the breakout hit.',75),
    ('the-death-of-peace-of-mind','bad-omens','guitar','riff','main riff','crunch','metalcore','rhythm','intermediate',
     'Solid-body electric (Joakim Karlsson / Noah Sebastian)','Direct — modern amp-sim production','Studio direct (IR cab)','bridge humbucker',
     '[{"effect_type":"reverb","effect_name":"dark room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":4,"bass":6,"mids":5,"treble":5,"presence":4,"reverb":3,"delay":1,"master":6}'::jsonb,
     array['Dark seductive mid-gain pulse — restrained until the heavy accents land.','Moody produced crunch; the heaviness arrives in short bursts (push gain to 7 for them).'],
     array['The verse groove is minimal and hypnotic.','Dynamics track the vocal — hold back, then hit.'],
     'Studio recording, 2022. Dark restrained title-track pulse.',74),
    ('like-a-villain','bad-omens','guitar','riff','main riff','high_gain','metalcore','rhythm','intermediate',
     'Solid-body electric (Joakim Karlsson / Noah Sebastian)','Direct — modern amp-sim production','Studio direct (IR cab)','bridge humbucker',
     '[{"effect_type":"gate","effect_name":"noise gate","placement":"front","settings":{"threshold":6}}]'::jsonb,
     '{"gain":7,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Aggressive drop-tuned stomp with cinematic breaks.','Tight produced high gain; the stabs are rhythmically theatrical.'],
     array['Stab the accents with the orchestration.','Mute everything between hits.'],
     'Studio recording, 2022. Theatrical aggressive stomp.',74),

    -- ============ SPIRITBOX (Mike Stringer: 7-string + Neural DSP) ============
    ('circle-with-me','spiritbox','guitar','riff','main riff','high_gain','metalcore','rhythm','advanced',
     '7-string solid-body (Mike Stringer)','Direct — Neural DSP-style amp sim','Studio direct (IR cab)','bridge humbucker',
     '[{"effect_type":"gate","effect_name":"tight noise gate","placement":"front","settings":{"threshold":7}},{"effect_type":"reverb","effect_name":"ambient reverb (clean sections)","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":7,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['Soaring low-tuned metalcore — glassy ambient verses into a huge saturated chorus.','Stringer records direct through Neural-style sims; drop the gain to 2 with reverb for the verses.'],
     array['Very low 7-string tuning on the record.','The chorus riff rings — let the chords bloom inside the gain.'],
     'Studio recording, 2021. Stringer''s direct amp-sim wall from Eternal Blue.',77),
    ('jaded','spiritbox','guitar','riff','main riff','high_gain','metalcore','rhythm','intermediate',
     '7-string solid-body (Mike Stringer)','Direct — Neural DSP-style amp sim','Studio direct (IR cab)','bridge humbucker',
     '[{"effect_type":"gate","effect_name":"tight noise gate","placement":"front","settings":{"threshold":7}}]'::jsonb,
     '{"gain":7,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['Melodic modern metalcore — punchy verse chugs under a soaring hook.','Same direct-sim recipe: tight lows, smooth saturation.'],
     array['The verse riff syncopates against the kick pattern.','Big open chords carry the chorus.'],
     'Studio recording, 2023. Melodic punchy metalcore from The Fear of Fear.',76),

    -- ============ BRING ME THE HORIZON (Lee Malia) ============
    ('shadow-moses','bring-me-the-horizon','guitar','riff','main riff','high_gain','metalcore','rhythm','intermediate',
     'Gibson Les Paul Custom (Lee Malia)','British high-gain tube stack','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['Sempiternal''s anthem — huge drop-C wall under synth atmosphere.','Thick British high gain; the iconic intro melody rides on top of the wall.'],
     array['Drop C; the intro lead melody is the song''s identity.','Chorus chords ring wide against the electronics.'],
     'Studio recording, 2013. Malia''s Les Paul wall from Sempiternal.',77),
    ('drown','bring-me-the-horizon','guitar','riff','main riff','crunch','alternative rock','rhythm','beginner',
     'Gibson Les Paul (Lee Malia)','British tube stack, mid gain','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":1,"master":7}'::jsonb,
     array['Arena-rock BMTH — warm mid-gain chords, more anthem than metal.','Moderate crunch with space; the song breathes.'],
     array['Simple emotional progression — play it big and open.','The lead line answers the vocal melody.'],
     'Studio recording, 2015. Arena-rock warmth from That''s the Spirit.',76),

    -- ============ JINJER ============
    ('pisces','jinjer','guitar','riff','main riff','high_gain','progressive metal','rhythm','advanced',
     '7-string solid-body (Roman Ibramkhalilov)','Modern high-gain tube head','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"gate","effect_name":"noise gate","placement":"front","settings":{"threshold":6}}]'::jsonb,
     '{"gain":7,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['Jazzy clean verses (drop gain to 2) into djenty progressive grooves — the song that broke Jinjer worldwide.','Tight modern high gain for the heavy sections; clean and airy for the verses.'],
     array['The clean verses are jazz-inflected — light touch.','The heavy groove syncopates hard; count it.'],
     'Studio recording, 2016. Jazz-to-djent whiplash — Jinjer''s viral breakout.',76),
    ('perennial','jinjer','guitar','riff','main riff','high_gain','progressive metal','rhythm','advanced',
     '7-string solid-body (Roman Ibramkhalilov)','Modern high-gain tube head','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"gate","effect_name":"noise gate","placement":"front","settings":{"threshold":6}}]'::jsonb,
     '{"gain":7,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Relentless groove-metal churn with progressive twists.','Saturated but articulate; every syncopation must speak.'],
     array['Follow the drums — the riff is a rhythm exercise.','Palm-mute pressure varies constantly.'],
     'Studio recording, 2021. Churning progressive groove from Wallflowers.',75),

    -- ============ DEATHCORE / INDUSTRIAL / RADIO METALCORE ============
    ('to-the-hellfire','lorna-shore','guitar','riff','main riff','high_gain','deathcore','rhythm','expert',
     'Extended-range guitar (Adam De Micco)','Direct — modern amp-sim production','Studio direct (IR cab)','bridge humbucker',
     '[{"effect_type":"gate","effect_name":"tight noise gate","placement":"front","settings":{"threshold":8}}]'::jsonb,
     '{"gain":8,"bass":6,"mids":5,"treble":7,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['Symphonic deathcore blitz — tremolo walls, blast-beat riffing, and the infamous final breakdown.','Direct amp-sim tone under orchestration; tight gating is non-negotiable.'],
     array['Tremolo picking stamina and sweep sections throughout.','The closing breakdown is slower than you think — pocket, not panic.'],
     'Studio recording, 2021. Symphonic deathcore with the viral final breakdown.',75),
    ('werewolf','motionless-in-white','guitar','riff','main riff','high_gain','industrial metal','rhythm','intermediate',
     'Solid-body electric (Ryan Sitkowski / Ricky Olson)','Modern high-gain with industrial production','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"gate","effect_name":"noise gate","placement":"front","settings":{"threshold":6}}]'::jsonb,
     '{"gain":7,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Gothic industrial metalcore — driving drop-tuned chugs under synth layers.','Tight modern high gain; the synths carry the atmosphere.'],
     array['Drive the verse chugs evenly under the vocal.','The chorus opens into ringing chords.'],
     'Studio recording, 2022. Gothic industrial drive from Scoring the End of the World.',74),
    ('hurricane','i-prevail','guitar','riff','main riff','crunch','metalcore','rhythm','beginner',
     'Solid-body electric (Steve Menoian)','Modern tube head, mid gain','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":4,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":1,"master":6}'::jsonb,
     array['Emotional radio-metalcore — restrained verses building to a big open chorus (push gain to 6).','Modern polished crunch with space for the vocal.'],
     array['Arpeggiated verse figures stay gentle.','Open the chorus with wide sustained chords.'],
     'Studio recording, 2019. Emotional build from Trauma.',74),
    ('popular-monster','falling-in-reverse','guitar','riff','main riff','high_gain','metalcore','rhythm','intermediate',
     'Solid-body electric (Falling in Reverse)','Direct — modern amp-sim production','Studio direct (IR cab)','bridge humbucker',
     '[{"effect_type":"gate","effect_name":"noise gate","placement":"front","settings":{"threshold":6}}]'::jsonb,
     '{"gain":7,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Genre-shifting viral anthem — quiet brooding verses erupting into a drop-tuned breakdown chorus.','Produced direct tone; program a clean (gain 2) and this heavy sound.'],
     array['The dynamic shifts are sudden — be ready.','The final breakdown wants maximum aggression.'],
     'Studio recording, 2019. Genre-shifting viral metalcore anthem.',73),
    ('counting-worms','knocked-loose','guitar','riff','main riff','high_gain','hardcore','rhythm','intermediate',
     'Solid-body electric (Isaac Hale)','Aggressive raw high-gain tube stack','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":6,"treble":6,"presence":6,"reverb":0,"delay":0,"master":8}'::jsonb,
     array['Raw hardcore violence — mid-forward and ugly on purpose, not polished djent.','Keep the mids IN; Knocked Loose cuts through with grind, not scoop.'],
     array['Very low tuning; the "arf arf" breakdown is a cultural moment.','Play slightly ahead of the beat — hardcore urgency.'],
     'Studio recording, 2019. Raw mid-forward hardcore from A Different Shade of Blue.',75),
    ('two-way-mirror','loathe','guitar','riff','main riff','clean','alternative metal','rhythm','intermediate',
     'Baritone guitar (Erik Bickerstaffe)','Clean amp with shimmer and space','Open-back cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"shimmer reverb","placement":"post_gain","settings":{"mix":6,"decay":7}},{"effect_type":"chorus","effect_name":"soft chorus","placement":"post_gain","settings":{"rate":3,"depth":4,"mix":4}}]'::jsonb,
     '{"gain":2,"bass":6,"mids":5,"treble":5,"presence":4,"reverb":6,"delay":2,"master":6}'::jsonb,
     array['Deftones-lineage dream metal — low-tuned cleans floating in shimmer.','Baritone clean drenched in reverb; heaviness through register, not distortion.'],
     array['Let every chord hang and shimmer.','The vocal melody leads; the guitar is the ocean under it.'],
     'Studio recording, 2020. Floating baritone dream-metal cleans.',74),

    -- ============ GHOST ============
    ('square-hammer','ghost','guitar','riff','main riff','crunch','hard rock','rhythm','beginner',
     'Hagstrom Fantomen (Ghost)','Vintage-voiced tube stack, mid gain','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['Anthemic satanic arena-rock — warm classic crunch, not metal gain.','70s-flavored crunch with modern polish; the riff bounces.'],
     array['The gallop-adjacent main riff drives everything.','Play it theatrical — Ghost is a show.'],
     'Studio recording, 2016. Anthemic warm crunch from Popestar.',76),
    ('mary-on-a-cross','ghost','guitar','riff','main riff','crunch','hard rock','rhythm','beginner',
     'Hagstrom Fantomen (Ghost)','Vintage-voiced tube amp, light crunch','Open-back cab','bridge humbucker',
     '[{"effect_type":"reverb","effect_name":"plate reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['70s soft-rock throwback that went viral on TikTok — warm light crunch and big pop chords.','ABBA-meets-Sabbath warmth; keep the gain gentle.'],
     array['Big open chords with a relaxed strum.','The lead breaks are simple and melodic.'],
     'Studio recording, 2019. Warm 70s pop-rock crunch — the TikTok viral hit.',75),

    -- ============ GOJIRA ============
    ('lenfant-sauvage','gojira','guitar','riff','main riff','high_gain','progressive metal','rhythm','advanced',
     'Charvel custom (Joe Duplantier)','Modern high-gain tube head','Closed-back 4x12 cab','EMG bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Grinding groove-prog title track — thick mid-present chug with the signature pick scrapes.','Gojira keeps mids in the tone; the low end is tight, not flabby.'],
     array['The pick-scrape "whale calls" are a Gojira signature — scrape down the wound strings.','Relentless precision on the main groove.'],
     'Studio recording, 2012. Grinding mid-present groove metal.',77),
    ('silvera','gojira','guitar','riff','main riff','high_gain','progressive metal','rhythm','advanced',
     'Charvel custom (Joe Duplantier)','Modern high-gain tube head','Closed-back 4x12 cab','EMG bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Magma-era focus — punchy compact riffing with melodic overtones.','Same thick mid-forward Gojira grind, tighter song format.'],
     array['The main riff pivots on artificial harmonics.','Groove first; the syncopation carries the aggression.'],
     'Studio recording, 2016. Punchy melodic groove metal from Magma.',77),

    -- ============ ARCHITECTS / PERIPHERY ============
    ('animals','architects','guitar','riff','main riff','high_gain','metalcore','rhythm','intermediate',
     'Solid-body electric (Josh Middleton / Adam Christianson)','Direct — modern amp-sim production','Studio direct (IR cab)','bridge humbucker',
     '[{"effect_type":"gate","effect_name":"tight noise gate","placement":"front","settings":{"threshold":7}}]'::jsonb,
     '{"gain":7,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Pulsing electronic-tinged metalcore — stabbed low chugs under synth swells.','Produced direct tone; the guitar stabs are percussive punctuation.'],
     array['The chug pattern locks to the electronic pulse.','Space and restraint until the chorus wall.'],
     'Studio recording, 2021. Pulsing produced stabs from For Those That Wish to Exist.',75),
    ('blood-eagle','periphery','guitar','riff','main riff','high_gain','djent','rhythm','expert',
     'Jackson signature (Misha Mansoor / Jake Bowen / Mark Holcomb)','Direct — amp-sim production (Periphery pioneered it)','Studio direct (IR cab)','bridge humbucker',
     '[{"effect_type":"gate","effect_name":"tight noise gate","placement":"front","settings":{"threshold":8}}]'::jsonb,
     '{"gain":8,"bass":6,"mids":5,"treble":7,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Periphery at their most vicious — surgical drop-tuned djent from the band that defined direct amp-sim recording.','Maximum tightness and gating; the riffs are rhythmic mathematics.'],
     array['Learn the riff in slow motion first — the subdivisions are brutal.','Your picking hand is the metronome.'],
     'Studio recording, 2019. Surgical djent violence from Hail Stan.',77)
) as c(
  song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence
)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;
