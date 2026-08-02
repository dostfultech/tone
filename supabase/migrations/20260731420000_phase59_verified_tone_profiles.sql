-- Phase 59: DEMAND-DRIVEN batch — top Ultimate Guitar (India) tab searches not yet covered.
-- Source: UG Top 100 by hits, 2026-08-01. First batch selected from real demand data.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Navjot Ahuja','navjot-ahuja','Khat','khat','Khat',2024),
    ('Anuv Jain','anuv-jain','Arz Kiya Hai','arz-kiya-hai','Arz Kiya Hai',2025),
    ('Anuv Jain','anuv-jain','Jo Tum Mere Ho','jo-tum-mere-ho','Jo Tum Mere Ho',2024),
    ('Arijit Singh','arijit-singh','Chahun Main Ya Naa','chahun-main-ya-naa','Aashiqui 2',2013),
    ('Faheem Abdullah','faheem-abdullah','Saiyaara (Title Song)','saiyaara-title-song','Saiyaara',2025),
    ('Jubin Nautiyal','jubin-nautiyal','Barbaad','barbaad','Saiyaara',2025),
    ('Roxen','roxen','Tera Mera Rishta','tera-mera-rishta','Rozen-e-Deewar',2006),
    ('Sharman Joshi','sharman-joshi','Give Me Some Sunshine','give-me-some-sunshine','3 Idiots',2009),
    ('Vishal Mishra','vishal-mishra','Kaise Hua','kaise-hua','Kabir Singh',2019),
    ('Sachet Tandon','sachet-tandon','Bekhayali','bekhayali','Kabir Singh',2019),
    ('Amit Trivedi','amit-trivedi','Yeh Fitoor Mera','yeh-fitoor-mera','Fitoor',2016),
    ('Gigi Perez','gigi-perez','Sailor Song','sailor-song','At the Beach, In Every Life',2024),
    ('Elliot James Reay','elliot-james-reay','I Think They Call This Love','i-think-they-call-this-love','I Think They Call This Love',2024),
    ('Atif Aslam','atif-aslam','Gulabi Aankhen','gulabi-aankhen','Gulabi Aankhen (Cover)',2016),
    ('Bombay Jayashri','bombay-jayashri','Zara Zara','zara-zara','Rehnaa Hai Terre Dil Mein',2001),
    ('Prateek Kuhad','prateek-kuhad','co2','co2','In Tokens & Charms',2015),
    ('Gajendra Verma','gajendra-verma','Mann Mera','mann-mera','Table No. 21',2013),
    ('KK','kk','Kya Mujhe Pyaar Hai','kya-mujhe-pyaar-hai','Woh Lamhe',2006),
    ('A.R. Rahman','ar-rahman','Agar Tum Saath Ho','agar-tum-saath-ho','Tamasha',2015),
    ('A.R. Rahman','ar-rahman','Tum Ho','tum-ho','Rockstar',2011),
    ('Pritam','pritam','Kabira','kabira','Yeh Jawaani Hai Deewani',2013),
    ('Udit Narayan','udit-narayan','Pehla Nasha','pehla-nasha','Jo Jeeta Wohi Sikandar',1992),
    ('Vishal Mishra','vishal-mishra','Pehle Bhi Main','pehle-bhi-main','Animal',2023),
    ('One Direction','one-direction','Night Changes','night-changes','Four',2014),
    ('Bethel Music','bethel-music','Goodness of God','goodness-of-god','Victory',2019)
),
ins_artists as (
  insert into public.artists (name, slug, search_text, is_active)
  select distinct artist_name, artist_slug, artist_name, true from target
  on conflict (slug) do update set name = excluded.name, is_active = true
  returning id, slug
)
insert into public.songs (artist_id, title, slug, album, release_year, search_text, is_active)
select a.id, t.song_title, t.song_slug, t.album, t.release_year,
       concat_ws(' ', t.song_title, t.artist_name, t.album, 'bollywood indian hindi'), true
from target t join ins_artists a on a.slug = t.artist_slug
on conflict (artist_id, slug) do update set
  title = excluded.title, album = excluded.album, release_year = excluded.release_year,
  is_active = true, updated_at = now();

delete from public.tone_profile_effects e where e.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('navjot-ahuja','khat'),('anuv-jain','arz-kiya-hai'),('anuv-jain','jo-tum-mere-ho'),
    ('arijit-singh','chahun-main-ya-naa'),('faheem-abdullah','saiyaara-title-song'),('jubin-nautiyal','barbaad'),
    ('roxen','tera-mera-rishta'),('sharman-joshi','give-me-some-sunshine'),('vishal-mishra','kaise-hua'),
    ('sachet-tandon','bekhayali'),('amit-trivedi','yeh-fitoor-mera'),('gigi-perez','sailor-song'),
    ('elliot-james-reay','i-think-they-call-this-love'),('atif-aslam','gulabi-aankhen'),('bombay-jayashri','zara-zara'),
    ('prateek-kuhad','co2'),('gajendra-verma','mann-mera'),('kk','kya-mujhe-pyaar-hai'),
    ('ar-rahman','agar-tum-saath-ho'),('ar-rahman','tum-ho'),('pritam','kabira'),('udit-narayan','pehla-nasha'),
    ('vishal-mishra','pehle-bhi-main'),('one-direction','night-changes'),('bethel-music','goodness-of-god')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('navjot-ahuja','khat'),('anuv-jain','arz-kiya-hai'),('anuv-jain','jo-tum-mere-ho'),
    ('arijit-singh','chahun-main-ya-naa'),('faheem-abdullah','saiyaara-title-song'),('jubin-nautiyal','barbaad'),
    ('roxen','tera-mera-rishta'),('sharman-joshi','give-me-some-sunshine'),('vishal-mishra','kaise-hua'),
    ('sachet-tandon','bekhayali'),('amit-trivedi','yeh-fitoor-mera'),('gigi-perez','sailor-song'),
    ('elliot-james-reay','i-think-they-call-this-love'),('atif-aslam','gulabi-aankhen'),('bombay-jayashri','zara-zara'),
    ('prateek-kuhad','co2'),('gajendra-verma','mann-mera'),('kk','kya-mujhe-pyaar-hai'),
    ('ar-rahman','agar-tum-saath-ho'),('ar-rahman','tum-ho'),('pritam','kabira'),('udit-narayan','pehla-nasha'),
    ('vishal-mishra','pehle-bhi-main'),('one-direction','night-changes'),('bethel-music','goodness-of-god')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('navjot-ahuja','khat'),('anuv-jain','arz-kiya-hai'),('anuv-jain','jo-tum-mere-ho'),
    ('arijit-singh','chahun-main-ya-naa'),('faheem-abdullah','saiyaara-title-song'),('jubin-nautiyal','barbaad'),
    ('roxen','tera-mera-rishta'),('sharman-joshi','give-me-some-sunshine'),('vishal-mishra','kaise-hua'),
    ('sachet-tandon','bekhayali'),('amit-trivedi','yeh-fitoor-mera'),('gigi-perez','sailor-song'),
    ('elliot-james-reay','i-think-they-call-this-love'),('atif-aslam','gulabi-aankhen'),('bombay-jayashri','zara-zara'),
    ('prateek-kuhad','co2'),('gajendra-verma','mann-mera'),('kk','kya-mujhe-pyaar-hai'),
    ('ar-rahman','agar-tum-saath-ho'),('ar-rahman','tum-ho'),('pritam','kabira'),('udit-narayan','pehla-nasha'),
    ('vishal-mishra','pehle-bhi-main'),('one-direction','night-changes'),('bethel-music','goodness-of-god')
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
  concat_ws(' ', s.title, a.name, c.part_label, c.tone_type, c.original_guitar, c.original_amp, 'bollywood indian researched verified tone'),
  true
from (
  values
    -- ============ INDIAN INDIE (demand ranks 1-6) ============
    ('khat','navjot-ahuja','guitar','main','main progression','acoustic','indie folk','rhythm','beginner',
     'Acoustic guitar (Navjot Ahuja)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The current #1 most-searched tab in India — soft letter-writing acoustic ballad.','Warm intimate acoustic with light room; bedroom-recording feel.'],
     array['Gentle strum-pick pattern under a confessional vocal.','Keep it hushed and sincere.'],
     'Studio recording, 2024. The viral letter-ballad topping Indian tab searches.',70),
    ('arz-kiya-hai','anuv-jain','guitar','main','main progression','acoustic','indie folk','rhythm','beginner',
     'Acoustic guitar (Anuv Jain)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Anuv''s shayari-styled ballad — the #2 most-searched tab in India right now.','Signature Anuv warmth: soft acoustic, small dynamics.'],
     array['Simple open chords with his characteristic gentle pattern.','The poetry leads; the guitar follows.'],
     'Studio recording, 2025. The shayari ballad dominating Indian tab searches.',71),
    ('jo-tum-mere-ho','anuv-jain','guitar','main','main progression','acoustic','indie folk','rhythm','beginner',
     'Acoustic guitar (Anuv Jain)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The 2024 breakout — tender belonging-ballad acoustic.','Same warm hushed Anuv recipe; let it breathe.'],
     array['Soft picking into gentle strums.','Dynamics rise only at the hook.'],
     'Studio recording, 2024. The tender breakout ballad.',71),
    ('chahun-main-ya-naa','arijit-singh','guitar','main','arpeggio accompaniment','clean','bollywood','rhythm','beginner',
     'Clean electric / acoustic (session)','Warm clean amp','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":4,"decay":5}}]'::jsonb,
     '{"gain":1,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":4,"delay":0,"master":6}'::jsonb,
     array['The other Aashiqui 2 giant — soft clean arpeggios in 6/8 sway.','Warm wet clean; sister tone to Tum Hi Ho.'],
     array['Arpeggiate the progression in the slow 6/8.','Swell with each verse.'],
     'Studio recording, 2013. The Aashiqui 2 companion ballad.',71),
    ('saiyaara-title-song','faheem-abdullah','guitar','main','main progression','clean','bollywood','rhythm','beginner',
     'Clean electric + acoustic (session)','Clean amp with ambience','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":5,"decay":6}},{"effect_type":"delay","effect_name":"subtle delay","placement":"post_gain","settings":{"time":3,"mix":2,"feedback":2}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":5,"delay":2,"master":6}'::jsonb,
     array['2025''s biggest Bollywood romance theme — washy ambient clean under a soaring melody.','Wet spacious clean; the ache is in the reverb.'],
     array['Slow arpeggios and swells; nothing hurried.','Build gently to the title hook.'],
     'Studio recording, 2025. The Saiyaara romance theme.',70),
    ('barbaad','jubin-nautiyal','guitar','main','main progression','acoustic','bollywood','rhythm','beginner',
     'Acoustic guitar (session)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The Saiyaara heartbreak number — dark acoustic under a ruined-love vocal.','Warm dark acoustic; the devastation does the rest.'],
     array['Slow deliberate strums.','Follow the vocal''s breaking points.'],
     'Studio recording, 2025. The Saiyaara heartbreak ballad.',69),

    -- ============ PAKISTANI / 2000s BOLLYWOOD (ranks 7-15) ============
    ('tera-mera-rishta','roxen','guitar','riff','main arpeggio','clean','pop rock','rhythm','beginner',
     'Clean electric (Roxen)','Clean amp with big reverb','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"large hall reverb","placement":"post_gain","settings":{"mix":5,"decay":6}},{"effect_type":"delay","effect_name":"subtle delay","placement":"post_gain","settings":{"time":3,"mix":2,"feedback":2}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":5,"delay":2,"master":6}'::jsonb,
     array['The Pakistani rock ballad staple — mournful clean arpeggios in deep reverb (chorus adds drive, gain 5).','Same school as Jal''s Aadat: wet, sad, and beautiful.'],
     array['The arpeggio pattern carries the verses.','Lift into driven chords for the chorus.'],
     'Studio recording, 2006. The mournful Pakistani rock ballad.',70),
    ('give-me-some-sunshine','sharman-joshi','guitar','main','main progression','acoustic','bollywood','rhythm','beginner',
     'Acoustic guitar (session)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The 3 Idiots campus anthem — simple wistful acoustic strums.','Plain warm acoustic; every Indian college has sung this.'],
     array['Easy open chords in a relaxed strum.','Sing the hook; that''s the whole point.'],
     'Studio recording, 2009. The campus anthem from 3 Idiots.',71),
    ('kaise-hua','vishal-mishra','guitar','main','arpeggio accompaniment','clean','bollywood','rhythm','beginner',
     'Clean electric / acoustic (session)','Warm clean amp','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":1,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":4,"delay":0,"master":6}'::jsonb,
     array['The Kabir Singh falling-in-love song — soft clean arpeggios.','Warm intimate clean; wonder in every chord.'],
     array['Gentle arpeggio pattern under the vocal.','Small dynamics; it''s a whisper of a song.'],
     'Studio recording, 2019. The Kabir Singh romance arpeggio.',70),
    ('bekhayali','sachet-tandon','guitar','riff','intro lead + progression','clean','bollywood','lead','intermediate',
     'Clean electric (session)','Clean amp with ambience','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":4,"decay":5}},{"effect_type":"delay","effect_name":"lead delay","placement":"post_gain","settings":{"time":3,"mix":3,"feedback":2}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":4,"delay":3,"master":6}'::jsonb,
     array['The Kabir Singh rage-ballad — its clean electric intro motif is one of India''s most-copied riffs (bridge sections push to crunch, gain 5).','Wet singing clean lead over strummed bed.'],
     array['The intro lead motif is the identity — learn it note-perfect.','The song builds from ache to fury; track the arc.'],
     'Studio recording, 2019. The rage-ballad with the iconic intro motif.',71),
    ('yeh-fitoor-mera','amit-trivedi','guitar','main','arpeggio accompaniment','clean','bollywood','rhythm','beginner',
     'Clean electric (session)','Warm clean amp','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":1,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":4,"delay":1,"master":6}'::jsonb,
     array['Obsessive-love waltz — glassy clean arpeggios under Arijit''s vocal.','Soft wet clean in 6/8.'],
     array['Roll the arpeggios evenly.','Let the passion stay underneath.'],
     'Studio recording, 2016. The obsessive-love waltz.',70),
    ('sailor-song','gigi-perez','guitar','main','main progression','clean','indie folk','rhythm','beginner',
     'Clean electric (Gigi Perez)','Clean amp, dark and intimate','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":1,"bass":5,"mids":5,"treble":4,"presence":3,"reverb":4,"delay":0,"master":6}'::jsonb,
     array['The 2024 viral slow-burn — dark hushed clean loop.','Muted warm clean; low-lit and intimate.'],
     array['The fingerpicked loop repeats hypnotically.','Sink into the slow pulse.'],
     'Studio recording, 2024. The viral dark-clean slow burn.',71),
    ('i-think-they-call-this-love','elliot-james-reay','guitar','main','main progression','clean','indie pop','rhythm','beginner',
     'Hollow-body electric (Elliot James Reay)','Vintage-voiced clean amp','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"spring reverb","placement":"post_gain","settings":{"mix":4}},{"effect_type":"tremolo","effect_name":"light tremolo","placement":"post_gain","settings":{"rate":3,"depth":3}}]'::jsonb,
     '{"gain":1,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":4,"delay":0,"master":6}'::jsonb,
     array['The Elvis-revival viral hit — 50s-styled warm clean with spring splash.','Vintage doo-wop clean; same family as Until I Found You.'],
     array['Slow 6/8 arpeggios with crooner patience.','Play it like 1958.'],
     'Studio recording, 2024. The Elvis-revival viral ballad.',71),
    ('gulabi-aankhen','atif-aslam','guitar','main','main progression','acoustic','bollywood','rhythm','beginner',
     'Acoustic guitar (Atif Aslam / session)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The R.D. Burman classic in its beloved Atif unplugged form — breezy acoustic strums.','Bright relaxed acoustic; the retro melody does the charming.'],
     array['Easy swinging strum pattern.','Keep the 70s bounce alive.'],
     'Studio recording, 2016. The beloved unplugged take on the Rafi/Burman classic.',69),
    ('zara-zara','bombay-jayashri','guitar','riff','main arpeggio','clean','bollywood','rhythm','intermediate',
     'Clean electric (session — Harris Jayaraj arrangement)','Clean amp with lush reverb','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"lush hall reverb","placement":"post_gain","settings":{"mix":5,"decay":6}},{"effect_type":"delay","effect_name":"subtle delay","placement":"post_gain","settings":{"time":3,"mix":2,"feedback":2}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":5,"delay":2,"master":6}'::jsonb,
     array['The RHTDM longing theme — its liquid clean arpeggio intro is one of India''s most-learned electric parts.','Glassy wet clean; sensual and unhurried.'],
     array['The intro arpeggio figure is the song — learn it flowing, not note-by-note.','Keep the touch feather-light.'],
     'Studio recording, 2001. The liquid arpeggio classic from RHTDM.',71),

    -- ============ 2010s BOLLYWOOD / CLASSICS (ranks 16-23) ============
    ('co2','prateek-kuhad','guitar','main','fingerpicked pattern','acoustic','indie folk','rhythm','intermediate',
     'Acoustic guitar (Prateek Kuhad)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Early Prateek gem — brisk intricate fingerpicking.','Bright articulate acoustic; the pattern dances.'],
     array['The picking pattern is quicker than his ballads — build it slowly.','Keep the momentum airy.'],
     'Studio recording, 2015. The brisk fingerpicked gem from In Tokens & Charms.',71),
    ('mann-mera','gajendra-verma','guitar','riff','main arpeggio','clean','pop rock','rhythm','beginner',
     'Clean electric (Gajendra Verma / session)','Clean amp with big reverb','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"large hall reverb","placement":"post_gain","settings":{"mix":5,"decay":6}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":5,"delay":1,"master":6}'::jsonb,
     array['The other Gajendra Verma arpeggio classic — wet mournful clean picking.','Sister tone to Emptiness: clean, drenched, heartbroken.'],
     array['Even arpeggio loop under the vocal.','Let the reverb carry the sadness.'],
     'Studio recording, 2013. The wet arpeggio classic from Table No. 21.',70),
    ('kya-mujhe-pyaar-hai','kk','guitar','riff','main arpeggio','clean','bollywood','rhythm','beginner',
     'Clean electric (session — Pritam arrangement)','Clean amp with chorus and reverb','Open-back combo cab','neck pickup',
     '[{"effect_type":"chorus","effect_name":"soft chorus","placement":"post_gain","settings":{"rate":3,"depth":3,"mix":3}},{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":4,"delay":1,"master":6}'::jsonb,
     array['The mid-2000s KK romance — chorused clean arpeggios (adapted from the Korean original Sarang Hae Yo).','Wet chorused clean; soft-rock warmth.'],
     array['Arpeggiate the verse; strum the lift.','The wondering-if-it''s-love mood is gentle, not dramatic.'],
     'Studio recording, 2006. The chorused KK romance classic.',70),
    ('agar-tum-saath-ho','ar-rahman','guitar','main','arpeggio accompaniment','clean','bollywood','rhythm','beginner',
     'Clean electric / acoustic (Rahman session)','Warm clean amp','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":1,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":4,"delay":0,"master":6}'::jsonb,
     array['The Tamasha devastation duet — soft clean arpeggios under Alka and Arijit.','Warm restrained clean; Rahman leaves huge space.'],
     array['Sparse arpeggios; the silences matter.','Serve the two voices completely.'],
     'Studio recording, 2015. The Tamasha devastation duet.',70),
    ('tum-ho','ar-rahman','guitar','main','arpeggio accompaniment','clean','bollywood','rhythm','beginner',
     'Clean electric (Rahman session)','Warm clean amp with ambience','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":4,"decay":5}}]'::jsonb,
     '{"gain":1,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":4,"delay":1,"master":6}'::jsonb,
     array['The quiet heart of Rockstar — floating clean arpeggios.','Soft wet clean; intimacy after the film''s fury.'],
     array['Slow floating arpeggios throughout.','Play it like a secret.'],
     'Studio recording, 2011. The quiet heart of Rockstar.',70),
    ('kabira','pritam','guitar','main','main progression','acoustic','bollywood','rhythm','beginner',
     'Acoustic guitar (session)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The YJHD wanderer''s hymn — sparse folk acoustic.','Warm spare acoustic; Sufi-folk stillness.'],
     array['Minimal strums with space between.','The longing is in what you don''t play.'],
     'Studio recording, 2013. The wanderer''s hymn from YJHD.',71),
    ('pehla-nasha','udit-narayan','guitar','main','arpeggio accompaniment','clean','bollywood','rhythm','beginner',
     'Clean electric (session)','Warm clean amp with chorus','Open-back combo cab','neck pickup',
     '[{"effect_type":"chorus","effect_name":"90s chorus","placement":"post_gain","settings":{"rate":3,"depth":4,"mix":4}},{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":1,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":4,"delay":1,"master":6}'::jsonb,
     array['The first-love waltz of 90s Bollywood — glassy chorused clean arpeggios.','Wet 90s clean with chorus shimmer; pure slow-motion romance.'],
     array['Arpeggiate the waltz gently.','Play it like the world just went slow-mo.'],
     'Studio recording, 1992. The first-love waltz of a generation.',70),
    ('pehle-bhi-main','vishal-mishra','guitar','main','arpeggio accompaniment','clean','bollywood','rhythm','beginner',
     'Clean electric (session)','Warm clean amp with ambience','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":5,"decay":5}}]'::jsonb,
     '{"gain":1,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":5,"delay":1,"master":6}'::jsonb,
     array['The Animal obsession ballad — dark wet clean arpeggios.','Spacious dark clean; brooding romance.'],
     array['Slow arpeggios under the confession.','Keep the mood heavy and still.'],
     'Studio recording, 2023. The Animal obsession ballad.',70),

    -- ============ ENGLISH DEMAND GAPS (ranks 24-25) ============
    ('night-changes','one-direction','guitar','main','main progression','clean','pop','rhythm','beginner',
     'Clean electric + acoustic (session)','Warm clean amp','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"plate reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":1,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The slow-dance 1D staple — warm soft clean over acoustic strums.','Gentle produced clean; prom-night warmth.'],
     array['Soft arpeggio-strum hybrid throughout.','Sway; do not rock.'],
     'Studio recording, 2014. The slow-dance staple from Four.',72),
    ('goodness-of-god','bethel-music','guitar','main','main progression','clean','worship','rhythm','beginner',
     'Clean electric (worship session)','Clean amp with ambient wash','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"ambient shimmer reverb","placement":"post_gain","settings":{"mix":5,"decay":7}},{"effect_type":"delay","effect_name":"dotted-eighth delay","placement":"post_gain","settings":{"time":4,"mix":3,"feedback":3}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":5,"delay":3,"master":6}'::jsonb,
     array['The modern worship standard — ambient clean pads and dotted-eighth shimmer.','Wet worship clean: shimmer reverb plus rhythmic delay swells.'],
     array['Swell chords under the verses; arpeggiate the build.','Serve the congregation — dynamics follow the room.'],
     'Studio recording, 2019. The modern worship standard.',72)
) as c(
  song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence
)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;
