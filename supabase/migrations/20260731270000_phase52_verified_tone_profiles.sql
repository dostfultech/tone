-- Phase 52: Indian indie / Bollywood guitar canon, verified per-part tone data.
-- Core market for Tonefex (India, IG Reels audience); previously one song of coverage.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('Prateek Kuhad','prateek-kuhad','cold/mess','cold-mess','cold/mess',2018),
    ('Prateek Kuhad','prateek-kuhad','Kasoor','kasoor','Kasoor',2020),
    ('Anuv Jain','anuv-jain','Baarishein','baarishein','Baarishein',2020),
    ('Anuv Jain','anuv-jain','Husn','husn','Husn',2023),
    ('Lucky Ali','lucky-ali','O Sanam','o-sanam','Sunoh',1996),
    ('KK','kk','Yaaron','yaaron','Pal',1999),
    ('KK','kk','Pal','pal','Pal',1999),
    ('Mohit Chauhan','mohit-chauhan','Tum Se Hi','tum-se-hi','Jab We Met',2007),
    ('Arijit Singh','arijit-singh','Tum Hi Ho','tum-hi-ho','Aashiqui 2',2013),
    ('Arijit Singh','arijit-singh','Channa Mereya','channa-mereya','Ae Dil Hai Mushkil',2016),
    ('Arijit Singh','arijit-singh','Kesariya','kesariya','Brahmastra',2022),
    ('The Local Train','the-local-train','Choo Lo','choo-lo','Aalas Ka Pedh',2015),
    ('The Local Train','the-local-train','Aaoge Tum Kabhi','aaoge-tum-kabhi','Aalas Ka Pedh',2015),
    ('When Chai Met Toast','when-chai-met-toast','Khoj (Passing By)','khoj-passing-by','Khoj',2018),
    ('Euphoria','euphoria','Maeri','maeri','Phir Dhoom',2000),
    ('Silk Route','silk-route','Dooba Dooba','dooba-dooba','Boondein',1998),
    ('Strings','strings','Duur','duur','Duur',2000),
    ('Jal','jal','Aadat','aadat','Aadat',2004),
    ('Atif Aslam','atif-aslam','Tu Jaane Na','tu-jaane-na','Ajab Prem Ki Ghazab Kahani',2009),
    ('Farhan Akhtar','farhan-akhtar','Rock On!!','rock-on','Rock On!!',2008),
    ('Taba Chake','taba-chake','Aao Chalein','aao-chalein','Bombay Dreams',2019),
    ('A.R. Rahman','ar-rahman','Sadda Haq','sadda-haq','Rockstar',2011),
    ('A.R. Rahman','ar-rahman','Nadaan Parindey','nadaan-parindey','Rockstar',2011),
    ('Amit Trivedi','amit-trivedi','Iktara','iktara','Wake Up Sid',2009),
    ('Gajendra Verma','gajendra-verma','Emptiness','emptiness','Emptiness',2011)
),
ins_artists as (
  insert into public.artists (name, slug, search_text, is_active)
  select distinct artist_name, artist_slug, artist_name, true from target
  on conflict (slug) do update set name = excluded.name, is_active = true
  returning id, slug
)
insert into public.songs (artist_id, title, slug, album, release_year, search_text, is_active)
select a.id, t.song_title, t.song_slug, t.album, t.release_year,
       concat_ws(' ', t.song_title, t.artist_name, t.album, 'bollywood indian indie hindi'), true
from target t join ins_artists a on a.slug = t.artist_slug
on conflict (artist_id, slug) do update set
  title = excluded.title, album = excluded.album, release_year = excluded.release_year,
  is_active = true, updated_at = now();

delete from public.tone_profile_effects e where e.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('prateek-kuhad','cold-mess'),('prateek-kuhad','kasoor'),('anuv-jain','baarishein'),('anuv-jain','husn'),
    ('lucky-ali','o-sanam'),('kk','yaaron'),('kk','pal'),('mohit-chauhan','tum-se-hi'),('arijit-singh','tum-hi-ho'),
    ('arijit-singh','channa-mereya'),('arijit-singh','kesariya'),('the-local-train','choo-lo'),
    ('the-local-train','aaoge-tum-kabhi'),('when-chai-met-toast','khoj-passing-by'),('euphoria','maeri'),
    ('silk-route','dooba-dooba'),('strings','duur'),('jal','aadat'),('atif-aslam','tu-jaane-na'),
    ('farhan-akhtar','rock-on'),('taba-chake','aao-chalein'),('ar-rahman','sadda-haq'),('ar-rahman','nadaan-parindey'),
    ('amit-trivedi','iktara'),('gajendra-verma','emptiness')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('prateek-kuhad','cold-mess'),('prateek-kuhad','kasoor'),('anuv-jain','baarishein'),('anuv-jain','husn'),
    ('lucky-ali','o-sanam'),('kk','yaaron'),('kk','pal'),('mohit-chauhan','tum-se-hi'),('arijit-singh','tum-hi-ho'),
    ('arijit-singh','channa-mereya'),('arijit-singh','kesariya'),('the-local-train','choo-lo'),
    ('the-local-train','aaoge-tum-kabhi'),('when-chai-met-toast','khoj-passing-by'),('euphoria','maeri'),
    ('silk-route','dooba-dooba'),('strings','duur'),('jal','aadat'),('atif-aslam','tu-jaane-na'),
    ('farhan-akhtar','rock-on'),('taba-chake','aao-chalein'),('ar-rahman','sadda-haq'),('ar-rahman','nadaan-parindey'),
    ('amit-trivedi','iktara'),('gajendra-verma','emptiness')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('prateek-kuhad','cold-mess'),('prateek-kuhad','kasoor'),('anuv-jain','baarishein'),('anuv-jain','husn'),
    ('lucky-ali','o-sanam'),('kk','yaaron'),('kk','pal'),('mohit-chauhan','tum-se-hi'),('arijit-singh','tum-hi-ho'),
    ('arijit-singh','channa-mereya'),('arijit-singh','kesariya'),('the-local-train','choo-lo'),
    ('the-local-train','aaoge-tum-kabhi'),('when-chai-met-toast','khoj-passing-by'),('euphoria','maeri'),
    ('silk-route','dooba-dooba'),('strings','duur'),('jal','aadat'),('atif-aslam','tu-jaane-na'),
    ('farhan-akhtar','rock-on'),('taba-chake','aao-chalein'),('ar-rahman','sadda-haq'),('ar-rahman','nadaan-parindey'),
    ('amit-trivedi','iktara'),('gajendra-verma','emptiness')
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
    -- ============ INDIAN INDIE (acoustic singer-songwriter) ============
    ('cold-mess','prateek-kuhad','guitar','main','main fingerpicking','acoustic','indie folk','rhythm','intermediate',
     'Acoustic guitar (Prateek Kuhad)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Intimate fingerpicked acoustic — soft, warm, and close-mic''d.','Acoustic or piezo with light room ambience; nothing else.'],
     array['The fingerpicking pattern flows continuously under the vocal.','Feather-light dynamics; the intimacy is the sound.'],
     'Studio recording, 2018. Intimate fingerpicked acoustic — India''s indie anthem.',73),
    ('kasoor','prateek-kuhad','guitar','main','main fingerpicking','acoustic','indie folk','rhythm','beginner',
     'Acoustic guitar (Prateek Kuhad)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Sunny fingerpicked acoustic with a gentle bounce.','Bright warm acoustic; keep the pattern light.'],
     array['Steady travis-style picking with hammer-on colors.','Smile through it — the song is warm.'],
     'Studio recording, 2020. Sunny fingerpicked acoustic.',72),
    ('baarishein','anuv-jain','guitar','main','main progression','acoustic','indie folk','rhythm','beginner',
     'Acoustic guitar (Anuv Jain)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Rainy-day acoustic — soft strums and picking in gentle reverb.','Warm acoustic with room ambience; simplicity is the point.'],
     array['Simple open-chord pattern any beginner can reach.','Let the chords breathe with the vocal.'],
     'Studio recording, 2020. Soft rainy-day acoustic — an Indian bedroom-pop staple.',72),
    ('husn','anuv-jain','guitar','main','main progression','acoustic','indie folk','rhythm','beginner',
     'Acoustic guitar (Anuv Jain)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Hushed melancholy acoustic — the viral heartbreak ballad.','Soft warm acoustic; dynamics stay small and tender.'],
     array['Gentle picking under the verse, soft strums in the hook.','Restraint carries the emotion.'],
     'Studio recording, 2023. Hushed viral heartbreak acoustic.',72),
    ('aao-chalein','taba-chake','guitar','main','fingerstyle pattern','acoustic','indie folk','rhythm','intermediate',
     'Acoustic guitar (Taba Chake)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Dancing fingerstyle acoustic — percussive thumb and melody together.','Bright articulate acoustic; every note of the pattern must speak.'],
     array['Taba''s fingerstyle blends bass, rhythm, and melody — learn it in layers.','Keep the lilting waltz feel light.'],
     'Studio recording, 2019. Dancing fingerstyle from Bombay Dreams.',72),

    -- ============ CLASSIC INDIPOP / 90s-2000s ============
    ('o-sanam','lucky-ali','guitar','main','main progression + lead','clean','indipop','rhythm','beginner',
     'Acoustic + clean electric (session)','Warm clean amp','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":4,"decay":5}}]'::jsonb,
     '{"gain":1,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":4,"delay":1,"master":6}'::jsonb,
     array['The 90s indipop classic — acoustic strums with a haunting clean lead hook.','Warm clean electric for the lead; generous hall reverb is period-correct.'],
     array['The lead melody is the song''s signature — phrase it vocally.','Relaxed strumming under the verses.'],
     'Studio recording, 1996. The haunting indipop classic from Sunoh.',71),
    ('yaaron','kk','guitar','main','main progression','clean','indipop','rhythm','beginner',
     'Clean electric + acoustic (session)','Warm clean amp','Open-back combo cab','neck pickup',
     '[{"effect_type":"chorus","effect_name":"soft chorus","placement":"post_gain","settings":{"rate":3,"depth":3,"mix":3}},{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":1,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":4,"delay":1,"master":6}'::jsonb,
     array['The friendship anthem — glassy 90s clean arpeggios with chorus sheen.','Clean with soft chorus and hall; pure nostalgia tone.'],
     array['Arpeggiate the verses gently.','Everyone sings this one — leave room for the chorus.'],
     'Studio recording, 1999. The friendship-anthem clean from Pal.',71),
    ('pal','kk','guitar','main','main progression','acoustic','indipop','rhythm','beginner',
     'Acoustic guitar (session)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Farewell-song acoustic — warm strums under KK''s vocal.','Simple warm acoustic with light hall.'],
     array['Open-chord strumming; keep it flowing.','The farewell school-anthem of India — play it with heart.'],
     'Studio recording, 1999. The graduation-farewell acoustic.',71),
    ('dooba-dooba','silk-route','guitar','main','main fingerpicking','acoustic','indipop','rhythm','intermediate',
     'Acoustic guitar (Mohit Chauhan / Silk Route)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Monsoon fingerpicked acoustic — one of India''s most-learned picking patterns.','Warm intimate acoustic; the pattern is the hook.'],
     array['The signature picking pattern loops all song — get it fluid.','Sway with it; the feel is a gentle drizzle.'],
     'Studio recording, 1998. The monsoon fingerpicking classic from Boondein.',72),
    ('maeri','euphoria','guitar','riff','acoustic verse + rock chorus','crunch','indian rock','rhythm','intermediate',
     'Acoustic + electric (Euphoria)','Tube amp, driven chorus sections','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['India''s pioneering rock anthem — acoustic verses erupting into driven choruses (push gain to 6).','Program acoustic-clean and crunch; the folk-rock blend defined Indian rock.'],
     array['The chorus riff slams after the restrained verses.','Sing along or you''re doing it wrong.'],
     'Studio recording, 2000. The pioneering Hindi rock anthem.',71),
    ('duur','strings','guitar','main','main progression','clean','pop rock','rhythm','beginner',
     'Clean electric + acoustic (Bilal Maqsood)','Warm clean amp','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":4,"delay":1,"master":6}'::jsonb,
     array['Warm South-Asian pop-rock clean — gentle arpeggios and strums.','Soft clean with hall; breezy and unhurried.'],
     array['Alternate arpeggios and light strums.','The melody floats — support it.'],
     'Studio recording, 2000. Warm pop-rock clean from the Strings comeback.',70),
    ('aadat','jal','guitar','riff','main arpeggio','clean','pop rock','rhythm','beginner',
     'Clean electric (Goher Mumtaz)','Clean amp with big reverb','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"large hall reverb","placement":"post_gain","settings":{"mix":5,"decay":6}},{"effect_type":"delay","effect_name":"subtle delay","placement":"post_gain","settings":{"time":3,"mix":2,"feedback":2}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":5,"delay":2,"master":6}'::jsonb,
     array['THE subcontinent arpeggio — haunting clean picking in cavernous reverb (the chorus adds drive: gain 6).','Every South Asian guitarist''s first electric riff; clean, wet, and mournful.'],
     array['The iconic arpeggio must ring evenly — let the reverb blur it.','Build into the driven chorus strums.'],
     'Studio recording, 2004. The iconic haunting arpeggio that launched a thousand guitarists.',73),
    ('tu-jaane-na','atif-aslam','guitar','main','main progression','acoustic','bollywood','rhythm','beginner',
     'Acoustic guitar (session)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Warm Bollywood ballad acoustic — flowing strums under Atif''s vocal.','Warm acoustic with soft hall; the strum pattern rolls.'],
     array['Continuous flowing strum with dynamic swells.','Follow the vocal''s push and pull.'],
     'Studio recording, 2009. Warm ballad strums from Ajab Prem Ki Ghazab Kahani.',70),

    -- ============ BOLLYWOOD GUITAR MOMENTS ============
    ('tum-se-hi','mohit-chauhan','guitar','main','main progression','acoustic','bollywood','rhythm','beginner',
     'Acoustic guitar (session)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['The Jab We Met classic — gentle acoustic strums with monsoon warmth.','Simple warm acoustic; among India''s most-learned campfire songs.'],
     array['Easy open chords in a rolling pattern.','Keep it soft and steady under the melody.'],
     'Studio recording, 2007. The campfire classic from Jab We Met.',71),
    ('tum-hi-ho','arijit-singh','guitar','main','arpeggio accompaniment','clean','bollywood','rhythm','beginner',
     'Clean electric / acoustic (session)','Warm clean amp','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":4,"decay":5}}]'::jsonb,
     '{"gain":1,"bass":5,"mids":5,"treble":5,"presence":4,"reverb":4,"delay":0,"master":6}'::jsonb,
     array['The Aashiqui 2 mega-ballad — piano-led on record, but the guitar arpeggio arrangement is what everyone plays.','Soft warm clean with hall; slow 6/8 sway.'],
     array['Arpeggiate the iconic progression in 6/8.','Dynamics build verse by verse.'],
     'Studio recording, 2013. The mega-ballad every Indian guitarist gets requested.',71),
    ('channa-mereya','arijit-singh','guitar','main','main progression','acoustic','bollywood','rhythm','beginner',
     'Acoustic guitar (session)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Heartbreak anthem — warm acoustic under layered production.','Simple warm acoustic; the song carries itself.'],
     array['Gentle strums and picking around the vocal.','Hold back; the ache is in the restraint.'],
     'Studio recording, 2016. The heartbreak anthem from Ae Dil Hai Mushkil.',70),
    ('kesariya','arijit-singh','guitar','main','main progression','acoustic','bollywood','rhythm','beginner',
     'Acoustic guitar (session)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The Brahmastra love theme — bright bouncing acoustic pattern.','Warm bright acoustic; the strum-pick hybrid bounces.'],
     array['The intro hook is a picking pattern everyone recognizes.','Keep the bounce light and romantic.'],
     'Studio recording, 2022. The viral love-theme acoustic from Brahmastra.',70),
    ('iktara','amit-trivedi','guitar','main','main progression','acoustic','bollywood','rhythm','beginner',
     'Acoustic guitar (session)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['Wake Up Sid''s wistful folk theme — gentle acoustic under the iktara motif.','Soft warm acoustic; unhurried and dreamy.'],
     array['Simple pattern with lots of space.','Sway with the folk lilt.'],
     'Studio recording, 2009. Wistful folk acoustic from Wake Up Sid.',70),
    ('emptiness','gajendra-verma','guitar','riff','main arpeggio','clean','pop rock','rhythm','beginner',
     'Clean electric (Gajendra Verma / session)','Clean amp with big reverb','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"large hall reverb","placement":"post_gain","settings":{"mix":5,"decay":6}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":4,"reverb":5,"delay":1,"master":6}'::jsonb,
     array['The viral heartbreak arpeggio of early-2010s India — mournful clean picking in deep reverb.','Clean and wet; the sadness is in the space.'],
     array['The arpeggio loop is hypnotic — keep it even.','Minimal dynamics; let it drone beautifully.'],
     'Studio recording, 2011. The viral heartbreak arpeggio (Tune Mere Jaana).',70),

    -- ============ INDIAN ROCK ============
    ('choo-lo','the-local-train','guitar','riff','main riff','crunch','indian rock','rhythm','intermediate',
     'Solid-body electric (Paras Thakur)','Tube amp, warm crunch','Closed-back cab','bridge humbucker',
     '[{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":3,"delay":1,"master":7}'::jsonb,
     array['The Hindi indie-rock anthem — warm anthemic crunch with soaring leads.','Mid-forward warm drive; the chorus opens wide.'],
     array['The lead hooks answer the vocal — phrase them melodically.','Big open chorus strums; this song fills stadiums of singalongs.'],
     'Studio recording, 2015. The Hindi indie-rock anthem from Aalas Ka Pedh.',72),
    ('aaoge-tum-kabhi','the-local-train','guitar','riff','main arpeggio','clean','indian rock','rhythm','beginner',
     'Clean electric (Paras Thakur)','Clean amp with ambience','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":4,"decay":5}},{"effect_type":"delay","effect_name":"subtle delay","placement":"post_gain","settings":{"time":3,"mix":2,"feedback":2}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":4,"delay":2,"master":6}'::jsonb,
     array['Longing clean arpeggios in gentle ambience — builds to a driven climax (gain 5).','Wet clean picking; patience until the final lift.'],
     array['The arpeggio pattern repeats and grows.','Save your energy for the last chorus.'],
     'Studio recording, 2015. Longing ambient arpeggios from Aalas Ka Pedh.',72),
    ('khoj-passing-by','when-chai-met-toast','guitar','main','main progression','acoustic','indie folk','rhythm','beginner',
     'Acoustic guitar (Achyuth Jaigopal)','Acoustic — mic''d/DI','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":5,"mids":6,"treble":7,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['Sunny happy-folk acoustic — bright strums with banjo-adjacent bounce.','Bright cheerful acoustic; the energy is a hillside morning.'],
     array['Upbeat strumming with quick hammer-on colors.','Grin while you play — it''s that kind of song.'],
     'Studio recording, 2018. Sunny happy-folk from Khoj.',71),
    ('rock-on','farhan-akhtar','guitar','riff','main riff','distorted','indian rock','rhythm','intermediate',
     'Solid-body electric (session — film band)','Driven tube stack','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['Bollywood''s rock-band moment — big arena drive from the film that put garage bands on screen.','Straightforward warm distortion; anthemic power chords.'],
     array['Power-chord drive with palm-muted verses.','The title hook is a full-band shout.'],
     'Studio recording, 2008. The Bollywood band-movie anthem.',70),
    ('sadda-haq','ar-rahman','guitar','riff','main riff + solo','distorted','indian rock','lead','advanced',
     'Solid-body electric (session — Rockstar sessions)','Driven tube stack, singing lead voice','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"delay","effect_name":"lead delay","placement":"post_gain","settings":{"time":4,"mix":3,"feedback":3}}]'::jsonb,
     '{"gain":6,"bass":5,"mids":7,"treble":6,"presence":6,"reverb":2,"delay":3,"master":7}'::jsonb,
     array['India''s defining electric-guitar anthem — protest-rock riff with a wailing sustained lead.','Mid-heavy singing drive with delay; the lead lines cry.'],
     array['The main riff stomps; the solo soars — two different energies.','Sustain and vibrato make the lead vocal-like.'],
     'Studio recording, 2011. The Rockstar protest anthem — India''s defining guitar moment.',72),
    ('nadaan-parindey','ar-rahman','guitar','riff','intro lead + main progression','crunch','indian rock','lead','intermediate',
     'Solid-body electric (session — Rockstar sessions)','Tube amp, warm crunch with ambience','Closed-back cab','bridge humbucker',
     '[{"effect_type":"delay","effect_name":"ambient delay","placement":"post_gain","settings":{"time":4,"mix":3,"feedback":3}},{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":4}}]'::jsonb,
     '{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":4,"delay":3,"master":7}'::jsonb,
     array['The soaring Rockstar closer — aching lead melody over ambient crunch.','Warm singing drive with delay and hall; every note sustains.'],
     array['The intro lead is the emotional thesis — phrase it patiently.','Big slow chords under the chorus.'],
     'Studio recording, 2011. The aching Rockstar closer lead.',71)
) as c(
  song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence
)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;
