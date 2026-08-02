-- Phase 89: US blues-legend gaps (B.B. King!) + 2000s emo/post-hardcore completions.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('B.B. King','bb-king','The Thrill Is Gone','the-thrill-is-gone','Completely Well',1969),
    ('B.B. King','bb-king','Every Day I Have the Blues','every-day-i-have-the-blues','Live at the Regal',1965),
    ('Howlin'' Wolf','howlin-wolf','Killing Floor','killing-floor','The Real Folk Blues',1966),
    ('Robert Johnson','robert-johnson','Cross Road Blues','cross-road-blues','King of the Delta Blues Singers',1936),
    ('Muddy Waters','muddy-waters','Rollin'' Stone','rollin-stone','The Anthology',1950),
    ('Prince','prince','Let''s Go Crazy','lets-go-crazy','Purple Rain',1984),
    ('Story of the Year','story-of-the-year','Until the Day I Die','until-the-day-i-die','Page Avenue',2003),
    ('Story of the Year','story-of-the-year','Anthem of Our Dying Day','anthem-of-our-dying-day','Page Avenue',2003),
    ('Hawthorne Heights','hawthorne-heights','Ohio Is for Lovers','ohio-is-for-lovers','The Silence in Black and White',2004),
    ('Hawthorne Heights','hawthorne-heights','Saying Sorry','saying-sorry','If Only You Were Lonely',2006),
    ('Pierce the Veil','pierce-the-veil','King for a Day','king-for-a-day','Collide with the Sky',2012),
    ('Sleeping with Sirens','sleeping-with-sirens','If I''m James Dean, You''re Audrey Hepburn','if-im-james-dean-youre-audrey-hepburn','With Ears to See and Eyes to Hear',2010),
    ('Escape the Fate','escape-the-fate','Situations','situations','Dying Is Your Latest Fashion',2006),
    ('Chiodos','chiodos','The Words "Best Friend" Become Redefined','the-words-best-friend-become-redefined','All''s Well That Ends Well',2005),
    ('Memphis May Fire','memphis-may-fire','The Sinner','the-sinner','The Hollow',2011),
    ('We Came As Romans','we-came-as-romans','To Plant a Seed','to-plant-a-seed','To Plant a Seed',2009),
    ('Thursday','thursday-band','Understanding in a Car Crash','understanding-in-a-car-crash','Full Collapse',2001),
    ('Finch','finch-band','What It Is to Burn','what-it-is-to-burn','What It Is to Burn',2002),
    ('The Used','the-used','Blue and Yellow','blue-and-yellow','The Used',2002),
    ('Senses Fail','senses-fail','Buried a Lie','buried-a-lie','Let It Enfold You',2004),
    ('Underoath','underoath','Writing on the Walls','writing-on-the-walls','Define the Great Line',2006),
    ('Silverstein','silverstein','Smile in Your Sleep','smile-in-your-sleep','Discovering the Waterfront',2005),
    ('Thrice','thrice','Deadbolt','deadbolt','The Illusion of Safety',2002),
    ('Saosin','saosin','You''re Not Alone','youre-not-alone','Saosin',2006),
    ('A Day to Remember','a-day-to-remember','Have Faith in Me','have-faith-in-me','Homesick',2009)
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
    ('bb-king','the-thrill-is-gone'),('bb-king','every-day-i-have-the-blues'),('howlin-wolf','killing-floor'),
    ('robert-johnson','cross-road-blues'),('muddy-waters','rollin-stone'),('prince','lets-go-crazy'),
    ('story-of-the-year','until-the-day-i-die'),('story-of-the-year','anthem-of-our-dying-day'),
    ('hawthorne-heights','ohio-is-for-lovers'),('hawthorne-heights','saying-sorry'),
    ('pierce-the-veil','king-for-a-day'),('sleeping-with-sirens','if-im-james-dean-youre-audrey-hepburn'),
    ('escape-the-fate','situations'),('chiodos','the-words-best-friend-become-redefined'),
    ('memphis-may-fire','the-sinner'),('we-came-as-romans','to-plant-a-seed'),
    ('thursday-band','understanding-in-a-car-crash'),('finch-band','what-it-is-to-burn'),
    ('the-used','blue-and-yellow'),('senses-fail','buried-a-lie'),('underoath','writing-on-the-walls'),
    ('silverstein','smile-in-your-sleep'),('thrice','deadbolt'),('saosin','youre-not-alone'),
    ('a-day-to-remember','have-faith-in-me')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
  where p.mode = 'guitar'
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('bb-king','the-thrill-is-gone'),('bb-king','every-day-i-have-the-blues'),('howlin-wolf','killing-floor'),
    ('robert-johnson','cross-road-blues'),('muddy-waters','rollin-stone'),('prince','lets-go-crazy'),
    ('story-of-the-year','until-the-day-i-die'),('story-of-the-year','anthem-of-our-dying-day'),
    ('hawthorne-heights','ohio-is-for-lovers'),('hawthorne-heights','saying-sorry'),
    ('pierce-the-veil','king-for-a-day'),('sleeping-with-sirens','if-im-james-dean-youre-audrey-hepburn'),
    ('escape-the-fate','situations'),('chiodos','the-words-best-friend-become-redefined'),
    ('memphis-may-fire','the-sinner'),('we-came-as-romans','to-plant-a-seed'),
    ('thursday-band','understanding-in-a-car-crash'),('finch-band','what-it-is-to-burn'),
    ('the-used','blue-and-yellow'),('senses-fail','buried-a-lie'),('underoath','writing-on-the-walls'),
    ('silverstein','smile-in-your-sleep'),('thrice','deadbolt'),('saosin','youre-not-alone'),
    ('a-day-to-remember','have-faith-in-me')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
  where p.mode = 'guitar'
);
delete from public.song_tone_profiles p where p.mode = 'guitar' and p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('bb-king','the-thrill-is-gone'),('bb-king','every-day-i-have-the-blues'),('howlin-wolf','killing-floor'),
    ('robert-johnson','cross-road-blues'),('muddy-waters','rollin-stone'),('prince','lets-go-crazy'),
    ('story-of-the-year','until-the-day-i-die'),('story-of-the-year','anthem-of-our-dying-day'),
    ('hawthorne-heights','ohio-is-for-lovers'),('hawthorne-heights','saying-sorry'),
    ('pierce-the-veil','king-for-a-day'),('sleeping-with-sirens','if-im-james-dean-youre-audrey-hepburn'),
    ('escape-the-fate','situations'),('chiodos','the-words-best-friend-become-redefined'),
    ('memphis-may-fire','the-sinner'),('we-came-as-romans','to-plant-a-seed'),
    ('thursday-band','understanding-in-a-car-crash'),('finch-band','what-it-is-to-burn'),
    ('the-used','blue-and-yellow'),('senses-fail','buried-a-lie'),('underoath','writing-on-the-walls'),
    ('silverstein','smile-in-your-sleep'),('thrice','deadbolt'),('saosin','youre-not-alone'),
    ('a-day-to-remember','have-faith-in-me')
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
    ('the-thrill-is-gone','bb-king','guitar','lead','Lucille lead','clean','blues','lead','intermediate',
     'Gibson ES-355 "Lucille" (B.B. King)','Fender/Gibson tube amp, singing clean','Closed-back cab','neck pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":5,"presence":4,"reverb":3,"delay":0,"master":7}'::jsonb,
     array['THE B.B. King record — Lucille''s singing vibrato over minor-blues strings.','Warm vocal clean; one note from B.B. says more than a hundred from anyone.'],
     array['The butterfly vibrato — from the wrist, wide and slow.','Leave space; B.B. never played while he sang.'],
     'Studio recording, 1969. The definitive B.B. King record.',80),
    ('every-day-i-have-the-blues','bb-king','guitar','lead','Regal opener','clean','blues','lead','intermediate',
     'Gibson ES-355 "Lucille" (B.B. King)','Tube amp, pushed live clean','Closed-back cab','neck pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The Live at the Regal opener — the most celebrated live blues set ever cut.','Bright pushed clean; the crowd screams at every bend.'],
     array['Fast jump-blues phrases, clean articulation.','Study this record — every blues player did.'],
     'Live at the Regal, 1965. The celebrated live opener.',78),
    ('killing-floor','howlin-wolf','guitar','riff','Hubert Sumlin riff','clean','blues','riff','intermediate',
     'Gibson Les Paul (Hubert Sumlin)','Small tube amp, biting clean','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Sumlin''s funky stinger — the riff Zeppelin turned into The Lemon Song.','Biting fingerpicked clean; no pick, all snap.'],
     array['Fingers, not pick — snap the riff.','The groove struts; stay behind the beat.'],
     'Studio recording, 1966. Sumlin''s funky stinger.',77),
    ('cross-road-blues','robert-johnson','guitar','main','Delta slide','acoustic','blues','rhythm','advanced',
     'Gibson L-1 acoustic (Robert Johnson)','Acoustic — one mic, one take','No cab (acoustic)','n/a (acoustic)',
     '[]'::jsonb,'{"gain":0,"bass":4,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":6}'::jsonb,
     array['The crossroads myth itself — slide and driving bass thumb, one man as a full band.','Dry haunted acoustic; the recording every guitarist eventually visits.'],
     array['Open tuning, slide on pinky, thumb drives the bass.','Cream''s Crossroads started here — go to the source.'],
     'Studio recording, 1936. The crossroads myth.',77),
    ('rollin-stone','muddy-waters','guitar','main','electric Delta drone','clean','blues','rhythm','intermediate',
     'Fender Telecaster (Muddy Waters)','Small tube amp, raw electric Delta','Open-back combo cab','bridge pickup',
     '[]'::jsonb,'{"gain":4,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['The song that named a band, a magazine, and an era — one-chord electric Delta drone.','Raw pushed clean; Chicago electricity meets Mississippi dirt.'],
     array['One chord, infinite menace — it''s all feel.','The fills answer the voice like a second singer.'],
     'Studio recording, 1950. The name-giver.',77),
    ('lets-go-crazy','prince','guitar','riff','purple riff + solo','distorted','pop rock','lead','intermediate',
     'Hohner Madcat Telecaster (Prince)','Tube amp, screaming purple rock','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['Dearly beloved — the Purple Rain opener with THE outro solo freakout.','Screaming bright saturation; Prince shreds Hendrix into new wave.'],
     array['Chuck the riff; then the outro solo goes supernova.','Look up the punchline: the elevator, the afterworld — play like both.'],
     'Studio recording, 1984. The purple freakout.',78),
    ('until-the-day-i-die','story-of-the-year','guitar','riff','main riff','distorted','post-hardcore','rhythm','intermediate',
     'Gibson/ESP electric (Ryan Phillips)','High-gain amp, 2003 emo-rock','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The Page Avenue promise — soaring St. Louis post-hardcore with the octave hook.','Tight bright saturation; until the day I die, I''ll spill my heart for you.'],
     array['Drive the verse chugs; lift the octave chorus.','Scream the harmony if you''ve got a friend.'],
     'Studio recording, 2003. The Page Avenue promise.',75),
    ('anthem-of-our-dying-day','story-of-the-year','guitar','riff','quiet-loud anthem','distorted','post-hardcore','rhythm','intermediate',
     'Electric guitar (Ryan Phillips)','High-gain amp with clean verses','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":5,"treble":6,"presence":6,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The sirens-over-the-city anthem — glassy clean intro (gain 2) detonating into the wall.','Big 2003 saturation; for a moment we were able to be still.'],
     array['Pick the clean intro delicately.','The drop hits at the chorus — full windmill.'],
     'Studio recording, 2003. The sirens anthem.',74),
    ('ohio-is-for-lovers','hawthorne-heights','guitar','riff','emo anthem','distorted','emo','rhythm','intermediate',
     'Electric guitars x3 (Hawthorne Heights)','High-gain amp, layered emo wall','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['THE MySpace-era monument — three-guitar wall under the cut-my-wrists scream.','Thick layered saturation; so cut my wrists and black my eyes.'],
     array['Three guitar parts — pick the octave lead if playing alone.','The screamed answer vocals made a generation.'],
     'Studio recording, 2004. The MySpace monument.',75),
    ('saying-sorry','hawthorne-heights','guitar','riff','uptempo emo','distorted','emo','rhythm','beginner',
     'Electric guitar (Hawthorne Heights)','High-gain amp, bright emo drive','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The radio follow-up — brighter, faster, hookier than Ohio.','Crisp emo drive; saying goodbye this time.'],
     array['Drive the chords straight ahead.','The chorus is pure 2006 radio — commit.'],
     'Studio recording, 2006. The radio follow-up.',73),
    ('king-for-a-day','pierce-the-veil','guitar','riff','frantic lead riff','distorted','post-hardcore','lead','advanced',
     'ESP/Fender electric (Vic & Tony Fuentes)','High-gain amp, frantic Mexicore','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The Kellin Quinn collab — frantic technical riffing, the scene''s defining duet.','Precise searing saturation; dare me to jump off of this Jersey bridge?'],
     array['The intro riff sprints — practice slow.','Tap and slide flourishes everywhere; it''s showing off, correctly.'],
     'Studio recording, 2012. The scene''s defining duet.',75),
    ('if-im-james-dean-youre-audrey-hepburn','sleeping-with-sirens','guitar','riff','soaring scene riff','distorted','post-hardcore','rhythm','intermediate',
     'Electric guitar (Sleeping with Sirens)','High-gain amp, glassy scene tone','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":5,"treble":6,"presence":6,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The Kellin falsetto showcase — glassy leads under the highest voice in the scene.','Bright modern saturation; these words are knives that often leave scars.'],
     array['Lead figures ring over the chugs.','The voice is the instrument — support it.'],
     'Studio recording, 2010. The falsetto showcase.',73),
    ('situations','escape-the-fate','guitar','riff','glam-core riff','distorted','post-hardcore','rhythm','intermediate',
     'Electric guitar (Monte Money)','High-gain amp, glam-core swagger','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The Ronnie-era swagger — Vegas glam-core with an 80s-metal wink.','Tight flashy saturation; darling, what is going on?'],
     array['Strut the riff; the solo quotes hair metal on purpose.','Whoa-ohs mandatory.'],
     'Studio recording, 2006. The Vegas glam-core single.',73),
    ('the-words-best-friend-become-redefined','chiodos','guitar','riff','theatrical post-hardcore','distorted','post-hardcore','rhythm','intermediate',
     'Electric guitar (Chiodos)','High-gain amp with piano theatrics','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The theatrical scene classic — guitars trading drama with grand piano under Craig Owens'' soar.','Dynamic saturation; the scene''s most operatic band.'],
     array['Trade phrases with the piano line.','Owens'' falsetto leads — leave the ceiling for it.'],
     'Studio recording, 2005. The theatrical classic.',72),
    ('the-sinner','memphis-may-fire','guitar','riff','southern metalcore','high_gain','metalcore','rhythm','intermediate',
     'ESP/PRS electric (Kellen McGregor)','High-gain amp, southern metalcore','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":6,"mids":4,"treble":6,"presence":6,"reverb":0,"delay":0,"master":8}'::jsonb,
     array['The Dallas breakout — southern-groove metalcore chugs with soaring cleans.','Percussive scooped high gain; the twang in the chug is the signature.'],
     array['Chug with a southern swing.','Clean chorus floats over drop-tuned verses.'],
     'Studio recording, 2011. The Dallas breakout.',72),
    ('to-plant-a-seed','we-came-as-romans','guitar','riff','hopeful metalcore','high_gain','metalcore','rhythm','intermediate',
     'Electric guitar (Joshua Moore)','High-gain amp, bright metalcore','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":5,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The hope-core anthem — bright leads over chugs, twin vocals trading light and dark.','Gleaming high gain; we came as romans, we''ll leave as legends... the scene believed it.'],
     array['Lead melody rings over the chug bed.','The build-and-release is the sermon.'],
     'Studio recording, 2009. The hope-core anthem.',72),
    ('understanding-in-a-car-crash','thursday-band','guitar','riff','post-hardcore origin riff','distorted','post-hardcore','rhythm','intermediate',
     'Fender/Gibson electric (Tom Keeley / Steve Pedulla)','Tube amp, raw emotive drive','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":8}'::jsonb,
     array['The Full Collapse flashpoint — angular interweaving guitars that invented a scene''s vocabulary.','Raw mid-forward drive; New Brunswick basements, amplified.'],
     array['Two guitars interlock — learn both parts.','The dissonance is intentional; the feelings aren''t resolved either.'],
     'Studio recording, 2001. The Full Collapse flashpoint.',74),
    ('what-it-is-to-burn','finch-band','guitar','riff','title-track anthem','distorted','post-hardcore','rhythm','intermediate',
     'Gibson electric (Randy Strohmeyer / Alex Linares)','High-gain amp, 2002 emo-core','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The burning-red closer — soaring emo-core with THE scream drop.','Thick 2002 saturation; she burns like the sun.'],
     array['Ride the chords to the final chorus.','The last scream is the whole song — save everything.'],
     'Studio recording, 2002. The burning-red anthem.',74),
    ('blue-and-yellow','the-used','guitar','main','bittersweet build','clean','emo','rhythm','beginner',
     'Electric guitar (Quinn Allman)','Clean amp building to drive','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":3,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":1,"master":7}'::jsonb,
     array['The should''ve-said-something ballad — chiming clean build to the cathartic wall (gain 7).','Bright wistful clean; it''s all in how you mix the two.'],
     array['Chime the intro figure.','The build is patient — the payoff earns it.'],
     'Studio recording, 2002. The bittersweet build.',74),
    ('buried-a-lie','senses-fail','guitar','riff','frantic emo riff','distorted','post-hardcore','rhythm','intermediate',
     'Electric guitar (Garrett Zablocki / Dave Miller)','High-gain amp, frantic emo-core','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The Let It Enfold You single — frantic riffing under Buddy''s bleeding-throat delivery.','Sharp urgent saturation; the lead hook stabs between lines.'],
     array['The riff sprints; the leads stab.','New Jersey emo at maximum caffeine.'],
     'Studio recording, 2004. The frantic single.',73),
    ('writing-on-the-walls','underoath','guitar','riff','chaotic metalcore','high_gain','metalcore','rhythm','advanced',
     'Electric guitar (Tim McTague / James Smith)','High-gain amp, chaotic art-metalcore','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":8,"bass":5,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The Define the Great Line single — dissonant art-metalcore, Spencer and Aaron trading heaven and hell.','Grinding textured high gain; the Grammy-nominated chaos.'],
     array['Dissonant chords ring against the chugs.','Dynamics are violent — whisper to roar in one bar.'],
     'Studio recording, 2006. The art-metalcore single.',74),
    ('smile-in-your-sleep','silverstein','guitar','riff','melodic screamo riff','distorted','post-hardcore','rhythm','intermediate',
     'Electric guitar (Neil Boshart / Josh Bradford)','High-gain amp, melodic screamo','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The Discovering the Waterfront opener-single — melodic screamo with the knife-twist chorus.','Bright driving saturation; you killed me in your sleep.'],
     array['Melodic lead over driving chords.','Scream/sing trade — the Silverstein blueprint.'],
     'Studio recording, 2005. The knife-twist single.',73),
    ('deadbolt','thrice','guitar','riff','technical burner','distorted','post-hardcore','riff','advanced',
     'Gibson Les Paul (Teppei Teranishi)','High-gain amp, technical burn','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The scene''s favorite finger-buster — Teppei''s frantic intro riff into the ambient bridge.','Precise aggressive saturation; then the water section floats (gain 2).'],
     array['The intro riff is legendary homework — metronome up slowly.','The quiet bridge is the trap door.'],
     'Studio recording, 2002. The finger-buster.',75),
    ('youre-not-alone','saosin','guitar','riff','glassy anthem','distorted','post-hardcore','rhythm','intermediate',
     'Electric guitar (Beau Burchell / Justin Shekoski)','High-gain amp, glassy soar','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":5,"treble":7,"presence":6,"reverb":2,"delay":1,"master":8}'::jsonb,
     array['The Cove Reber-era anthem — glassy ringing leads built for arenas the scene never got.','Shimmering saturation; you''re not alone, there is more to this I know.'],
     array['Let the lead figures ring wide open.','It''s a hug in drop C# — play it generous.'],
     'Studio recording, 2006. The glassy anthem.',74),
    ('have-faith-in-me','a-day-to-remember','guitar','riff','pop-core anthem','distorted','pop punk','rhythm','beginner',
     'Gibson electric (Neil Westfall / Tom Denney)','High-gain amp, polished pop-core','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The Homesick heart-song — ADTR''s pop-core formula at its warmest.','Thick warm saturation; have faith in me, ''cause there are things that I''ve seen I don''t believe.'],
     array['Chug the verses; open the chorus wide.','The breakdown still hits — but gently, for once.'],
     'Studio recording, 2009. The Homesick heart-song.',74)
) as c(
  song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence
)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;
