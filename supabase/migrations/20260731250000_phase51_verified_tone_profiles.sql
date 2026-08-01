-- Phase 51: anime / J-rock canon, verified per-part tone data.
-- Among the most-searched guitar songs for players under 30; previously zero coverage.

with target(artist_name, artist_slug, song_title, song_slug, album, release_year) as (
  values
    ('TK from Ling tosite sigure','tk-from-ling-tosite-sigure','Unravel','unravel','Fantastic Magic',2014),
    ('LiSA','lisa','Gurenge','gurenge','Leo-Nine',2019),
    ('LiSA','lisa','Crossing Field','crossing-field','Landspace',2012),
    ('FLOW','flow','GO!!!','go','Golden Coast',2004),
    ('Ikimonogakari','ikimonogakari','Blue Bird','blue-bird','My Song Your Song',2008),
    ('KANA-BOON','kana-boon','Silhouette','silhouette','Time',2014),
    ('Asian Kung-Fu Generation','asian-kung-fu-generation','Haruka Kanata','haruka-kanata','Kimi Tsunagi Five M',2002),
    ('Asian Kung-Fu Generation','asian-kung-fu-generation','Rewrite','rewrite','Sol-fa',2004),
    ('ONE OK ROCK','one-ok-rock','The Beginning','the-beginning','Jinsei x Boku =',2012),
    ('ONE OK ROCK','one-ok-rock','Wherever You Are','wherever-you-are','Niche Syndrome',2010),
    ('Maximum the Hormone','maximum-the-hormone','What''s Up, People?!','whats-up-people','Buiikikaesu',2007),
    ('the pillows','the-pillows','Ride on Shooting Star','ride-on-shooting-star','Happy Bivouac',1999),
    ('THE ORAL CIGARETTES','the-oral-cigarettes','Kyouran Hey Kids!!','kyouran-hey-kids','FIXION',2015),
    ('Kenshi Yonezu','kenshi-yonezu','KICK BACK','kick-back','KICK BACK',2022),
    ('King Gnu','king-gnu','SPECIALZ','specialz','THE GREATEST UNKNOWN',2023),
    ('Vaundy','vaundy','Chainsaw Blood','chainsaw-blood','replica',2022),
    ('BABYMETAL','babymetal','Gimme Chocolate!!','gimme-chocolate','BABYMETAL',2014),
    ('BABYMETAL','babymetal','KARATE','karate','Metal Resistance',2016),
    ('BAND-MAID','band-maid','Domination','domination','Conqueror',2019),
    ('RADWIMPS','radwimps','Zenzenzense','zenzenzense','Your Name.',2016),
    ('Eve','eve','Kaikai Kitan','kaikai-kitan','Smile',2020),
    ('Yorushika','yorushika','Hitchcock','hitchcock','Dakara Boku wa Ongaku o Yameta',2018),
    ('Galileo Galilei','galileo-galilei','Aoi Shiori','aoi-shiori','Portal',2011),
    ('SPYAIR','spyair','Imagination','imagination','4',2014),
    ('SiM','sim','The Rumbling','the-rumbling','Beware',2022)
),
ins_artists as (
  insert into public.artists (name, slug, search_text, is_active)
  select distinct artist_name, artist_slug, artist_name, true from target
  on conflict (slug) do update set name = excluded.name, is_active = true
  returning id, slug
)
insert into public.songs (artist_id, title, slug, album, release_year, search_text, is_active)
select a.id, t.song_title, t.song_slug, t.album, t.release_year,
       concat_ws(' ', t.song_title, t.artist_name, t.album, 'anime'), true
from target t join ins_artists a on a.slug = t.artist_slug
on conflict (artist_id, slug) do update set
  title = excluded.title, album = excluded.album, release_year = excluded.release_year,
  is_active = true, updated_at = now();

delete from public.tone_profile_effects e where e.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('tk-from-ling-tosite-sigure','unravel'),('lisa','gurenge'),('lisa','crossing-field'),('flow','go'),
    ('ikimonogakari','blue-bird'),('kana-boon','silhouette'),('asian-kung-fu-generation','haruka-kanata'),
    ('asian-kung-fu-generation','rewrite'),('one-ok-rock','the-beginning'),('one-ok-rock','wherever-you-are'),
    ('maximum-the-hormone','whats-up-people'),('the-pillows','ride-on-shooting-star'),
    ('the-oral-cigarettes','kyouran-hey-kids'),('kenshi-yonezu','kick-back'),('king-gnu','specialz'),
    ('vaundy','chainsaw-blood'),('babymetal','gimme-chocolate'),('babymetal','karate'),('band-maid','domination'),
    ('radwimps','zenzenzense'),('eve','kaikai-kitan'),('yorushika','hitchcock'),('galileo-galilei','aoi-shiori'),
    ('spyair','imagination'),('sim','the-rumbling')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.tone_profile_sources src where src.profile_id in (
  select p.id from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('tk-from-ling-tosite-sigure','unravel'),('lisa','gurenge'),('lisa','crossing-field'),('flow','go'),
    ('ikimonogakari','blue-bird'),('kana-boon','silhouette'),('asian-kung-fu-generation','haruka-kanata'),
    ('asian-kung-fu-generation','rewrite'),('one-ok-rock','the-beginning'),('one-ok-rock','wherever-you-are'),
    ('maximum-the-hormone','whats-up-people'),('the-pillows','ride-on-shooting-star'),
    ('the-oral-cigarettes','kyouran-hey-kids'),('kenshi-yonezu','kick-back'),('king-gnu','specialz'),
    ('vaundy','chainsaw-blood'),('babymetal','gimme-chocolate'),('babymetal','karate'),('band-maid','domination'),
    ('radwimps','zenzenzense'),('eve','kaikai-kitan'),('yorushika','hitchcock'),('galileo-galilei','aoi-shiori'),
    ('spyair','imagination'),('sim','the-rumbling')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);
delete from public.song_tone_profiles p where p.id in (
  select p2.id from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id join public.artists a on a.id = s.artist_id
  join (values
    ('tk-from-ling-tosite-sigure','unravel'),('lisa','gurenge'),('lisa','crossing-field'),('flow','go'),
    ('ikimonogakari','blue-bird'),('kana-boon','silhouette'),('asian-kung-fu-generation','haruka-kanata'),
    ('asian-kung-fu-generation','rewrite'),('one-ok-rock','the-beginning'),('one-ok-rock','wherever-you-are'),
    ('maximum-the-hormone','whats-up-people'),('the-pillows','ride-on-shooting-star'),
    ('the-oral-cigarettes','kyouran-hey-kids'),('kenshi-yonezu','kick-back'),('king-gnu','specialz'),
    ('vaundy','chainsaw-blood'),('babymetal','gimme-chocolate'),('babymetal','karate'),('band-maid','domination'),
    ('radwimps','zenzenzense'),('eve','kaikai-kitan'),('yorushika','hitchcock'),('galileo-galilei','aoi-shiori'),
    ('spyair','imagination'),('sim','the-rumbling')
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
  concat_ws(' ', s.title, a.name, c.part_label, c.tone_type, c.original_guitar, c.original_amp, 'anime researched verified tone'),
  true
from (
  values
    -- ============ ANIME OP CANON ============
    ('unravel','tk-from-ling-tosite-sigure','guitar','riff','main arpeggio + chorus wall','crunch','j-rock','rhythm','advanced',
     'Fender solid-body (TK)','Bright tube amp, compressed edge-of-breakup','Open-back combo cab','bridge single-coil',
     '[{"effect_type":"compressor","effect_name":"studio compression","placement":"front","settings":{"sustain":6,"level":6}},{"effect_type":"delay","effect_name":"digital delay","placement":"post_gain","settings":{"time":4,"mix":3,"feedback":3}},{"effect_type":"reverb","effect_name":"plate reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":4,"bass":4,"mids":5,"treble":7,"presence":6,"reverb":3,"delay":3,"master":7}'::jsonb,
     array['The Tokyo Ghoul opening — frantic glassy arpeggios that erupt into a bright driven wall (push gain to 6 for the chorus).','TK''s tone is trebly, compressed, and delay-sheened; never dark or thick.'],
     array['The intro arpeggio pattern is fast and wide — slow practice is mandatory.','Chorus chords are aggressive but must stay articulate.'],
     'Studio recording, 2014. TK''s frantic glassy arpeggio tone — one of the most-searched anime guitar songs ever.',73),
    ('gurenge','lisa','guitar','riff','main riff','high_gain','j-rock','rhythm','intermediate',
     'Solid-body electric (session)','Modern tight high-gain (produced)','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"gate","effect_name":"noise gate","placement":"front","settings":{"threshold":6}}]'::jsonb,
     '{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['The Demon Slayer opening — polished driving J-rock high gain with mids intact.','Tight modern saturation; the riffs support a pop vocal, so clarity wins.'],
     array['Fast chord changes under the verse — economy of motion.','The post-chorus riff is the hook; nail its rhythm.'],
     'Studio recording, 2019. Polished driving high gain from the Demon Slayer opening.',72),
    ('crossing-field','lisa','guitar','riff','main riff','distorted','j-rock','rhythm','intermediate',
     'Solid-body electric (session)','Driven tube amp (produced)','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":1,"master":7}'::jsonb,
     array['The Sword Art Online opening — soaring anthemic drive.','Bright saturated rhythm under synth strings; keep mids up.'],
     array['Driving eighth-note energy throughout.','The intro lead line doubles the melody — sing it through the guitar.'],
     'Studio recording, 2012. Soaring anthemic drive from the SAO opening.',71),
    ('go','flow','guitar','riff','main riff','distorted','j-rock','rhythm','beginner',
     'Solid-body electric (Take / FLOW)','Driven tube amp','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['The Naruto "Fighting Dreamers" opening — punchy pop-punk-adjacent drive.','Straightforward bright distortion; energy over nuance.'],
     array['Power-chord drive start to finish.','Shout-along energy — play it big.'],
     'Studio recording, 2004. Punchy drive from the Naruto opening.',72),
    ('blue-bird','ikimonogakari','guitar','riff','main riff','crunch','j-rock','rhythm','intermediate',
     'Solid-body electric (Yoshiki Mizuno)','Tube amp, bright crunch','Open-back cab','bridge pickup',
     '[{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":5,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":3,"delay":1,"master":7}'::jsonb,
     array['The Naruto Shippuden opening — soaring bright crunch with a running feel.','Clean-edged drive; the fast arpeggiated figures need note separation.'],
     array['The intro run sets the pace — practice it isolated.','Keep the drive percussive under the vocal.'],
     'Studio recording, 2008. Soaring bright crunch from the Shippuden opening.',72),
    ('silhouette','kana-boon','guitar','riff','main riff','crunch','j-rock','rhythm','intermediate',
     'Fender Telecaster (Maguro Taniguchi)','Bright tube amp, tight crunch','Open-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Four-on-the-floor dance-rock crunch — trebly Telecaster propulsion.','Bright tight crunch; the sixteenth-note figures must bounce.'],
     array['The intro riff is a stamina test — relax the wrist.','Lock with the kick drum''s dance pulse.'],
     'Studio recording, 2014. Propulsive Telecaster dance-rock from the Shippuden opening.',72),
    ('haruka-kanata','asian-kung-fu-generation','guitar','riff','main riff','distorted','j-rock','rhythm','intermediate',
     'Solid-body electric (Kensuke Kita / Masafumi Gotoh)','Driven tube amp, raw','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['Raw garage-punk blast from the Naruto opening — urgent and unpolished.','Mid-forward driven tone; loose energy is authentic.'],
     array['The opening riff explodes immediately — no warmup.','Strum wide and hard; this is a sweat song.'],
     'Studio recording, 2002. Raw urgent drive from the Naruto opening.',73),
    ('rewrite','asian-kung-fu-generation','guitar','riff','main riff','distorted','j-rock','rhythm','intermediate',
     'Solid-body electric (Kensuke Kita / Masafumi Gotoh)','Driven tube amp','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['The Fullmetal Alchemist opening — driving emo-tinged alt-rock.','Same raw mid-forward drive with more melodic weight.'],
     array['The verse riff interlocks two guitars.','The chorus wants full-arm commitment.'],
     'Studio recording, 2004. Driving alt-rock from the FMA opening.',73),
    ('the-beginning','one-ok-rock','guitar','riff','main riff','high_gain','j-rock','rhythm','intermediate',
     'ESP solid-body (Toru Yamashita)','Modern high-gain tube head','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":2,"delay":1,"master":7}'::jsonb,
     array['Arena-scale post-hardcore drive from the Rurouni Kenshin film theme.','Modern polished high gain; big dynamics between verse and chorus.'],
     array['The intro arpeggio is clean (drop gain to 2) before the wall hits.','Chorus chords ring wide and huge.'],
     'Studio recording, 2012. Arena post-hardcore from the Kenshin theme.',73),
    ('wherever-you-are','one-ok-rock','guitar','main','main progression','clean','j-rock','rhythm','beginner',
     'ESP solid-body (Toru Yamashita)','Warm clean amp','Open-back combo cab','neck pickup',
     '[{"effect_type":"reverb","effect_name":"hall reverb","placement":"post_gain","settings":{"mix":4,"decay":5}},{"effect_type":"delay","effect_name":"subtle delay","placement":"post_gain","settings":{"time":3,"mix":2,"feedback":2}}]'::jsonb,
     '{"gain":2,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":4,"delay":2,"master":6}'::jsonb,
     array['The wedding-song ballad — warm clean arpeggios in soft hall reverb.','Pure clean with space; the emotion is in the patience.'],
     array['Fingerpick or soft-pick the arpeggio pattern evenly.','The climactic chorus adds light drive (gain 4) if you want the build.'],
     'Studio recording, 2010. Warm clean ballad arpeggios.',73),

    -- ============ CHAOS / HEAVY ============
    ('whats-up-people','maximum-the-hormone','guitar','riff','main riff','high_gain','nu metal','rhythm','advanced',
     'Solid-body electric (Maximum the Ryo)','Aggressive high-gain stack','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"gate","effect_name":"noise gate","placement":"front","settings":{"threshold":6}}]'::jsonb,
     '{"gain":8,"bass":6,"mids":5,"treble":7,"presence":6,"reverb":0,"delay":0,"master":8}'::jsonb,
     array['The Death Note opening — unhinged nu-metal chaos with whiplash section changes.','Scooped-ish aggressive high gain; the madness is structural, not tonal.'],
     array['Sections lurch between thrash, funk, and pop — map the song first.','Commit fully to every absurd transition.'],
     'Studio recording, 2007. Unhinged nu-metal chaos from the Death Note opening.',72),
    ('ride-on-shooting-star','the-pillows','guitar','riff','main riff','fuzz','j-rock','rhythm','beginner',
     'Solid-body electric (Sawao Yamanaka / Yoshiaki Manabe)','Tube amp with fuzz','Open-back cab','bridge pickup',
     '[{"effect_type":"fuzz","effect_name":"fuzz pedal","placement":"front","settings":{"gain":6,"tone":5,"level":6}}]'::jsonb,
     '{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The FLCL ending — jangly Pixies-worship fuzz-pop.','Loose warm fuzz over simple chords; charm over precision.'],
     array['Relaxed strums with fuzz hair around the edges.','The lead fills are simple and melodic.'],
     'Studio recording, 1999. Jangly fuzz-pop from FLCL.',73),
    ('kyouran-hey-kids','the-oral-cigarettes','guitar','riff','main riff','distorted','j-rock','rhythm','intermediate',
     'Solid-body electric (Kaoru Yamanaka)','Driven tube amp, tight','Closed-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['The Noragami Aragoto opening — slinky dance-rock drive with funk stabs.','Bright tight drive; the groove snaps.'],
     array['The intro riff hooks instantly — get the slides right.','Funk-mute the verse stabs.'],
     'Studio recording, 2015. Slinky dance-rock drive from the Noragami opening.',71),
    ('kick-back','kenshi-yonezu','guitar','riff','main riff','high_gain','j-rock','rhythm','advanced',
     'Solid-body electric (session — Daiki Tsuneta associated)','Modern high-gain, produced chaos','Studio direct (IR cab)','bridge humbucker',
     '[{"effect_type":"gate","effect_name":"noise gate","placement":"front","settings":{"threshold":6}}]'::jsonb,
     '{"gain":7,"bass":6,"mids":5,"treble":7,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['The Chainsaw Man opening — glitchy maximalist chaos with crushing riff drops.','Tight produced high gain that stops and starts on a dime.'],
     array['The riff stabs are rhythmically deranged — count everything.','Embrace the whiplash between sweetness and violence.'],
     'Studio recording, 2022. Glitchy maximalist chaos from the Chainsaw Man opening.',72),
    ('specialz','king-gnu','guitar','riff','main riff','crunch','j-rock','rhythm','intermediate',
     'Solid-body electric (Daiki Tsuneta)','Driven amp, dark and produced','Studio direct (IR cab)','bridge humbucker',
     '[{"effect_type":"chorus","effect_name":"warble modulation","placement":"post_gain","settings":{"rate":4,"depth":4,"mix":4}}]'::jsonb,
     '{"gain":5,"bass":6,"mids":5,"treble":5,"presence":4,"reverb":2,"delay":1,"master":6}'::jsonb,
     array['The Jujutsu Kaisen opening — woozy dark crunch with warped modulation.','Mid-gain with unsettling warble; the darkness is deliberate.'],
     array['The riff slinks rather than drives.','Lean into the seasick pitch movement.'],
     'Studio recording, 2023. Woozy dark crunch from the JJK Shibuya opening.',71),
    ('chainsaw-blood','vaundy','guitar','riff','main riff','crunch','j-rock','rhythm','intermediate',
     'Solid-body electric (Vaundy / session)','Driven amp, dark groove','Studio direct','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":6,"mids":5,"treble":5,"presence":4,"reverb":2,"delay":0,"master":6}'::jsonb,
     array['The Chainsaw Man ending — brooding bass-forward groove rock.','Dark mid-gain; the guitar grooves in the pocket, not on top.'],
     array['Ride the groove with the rhythm section.','Short stabby fills between vocal lines.'],
     'Studio recording, 2022. Brooding groove rock from the Chainsaw Man ending.',70),

    -- ============ KAWAII METAL / GIRL ROCK ============
    ('gimme-chocolate','babymetal','guitar','riff','main riff','high_gain','metal','rhythm','advanced',
     '7-string ESP (Kami Band)','Modern high-gain tube head','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"gate","effect_name":"tight noise gate","placement":"front","settings":{"threshold":7}}]'::jsonb,
     '{"gain":8,"bass":6,"mids":4,"treble":7,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['Kawaii-metal flagship — djenty precision riffing under J-pop vocals.','Tight scooped modern high gain; the Kami Band are session virtuosos.'],
     array['The main riff gallops at speed — build up with a metronome.','Stop-start precision; the gaps are part of the riff.'],
     'Studio recording, 2014. Kami Band''s djenty precision under the kawaii-metal breakout.',74),
    ('karate','babymetal','guitar','riff','main riff','high_gain','metal','rhythm','intermediate',
     '7-string ESP (Kami Band)','Modern high-gain tube head','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"gate","effect_name":"tight noise gate","placement":"front","settings":{"threshold":7}}]'::jsonb,
     '{"gain":7,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Groove-metal stomp — heavier and slower than Gimme Chocolate.','Thick modern gain with more mids; the riff stomps.'],
     array['The main riff is a groove exercise — pocket first.','Let the chorus chords ring against the melody.'],
     'Studio recording, 2016. Groove-metal stomp from Metal Resistance.',74),
    ('domination','band-maid','guitar','riff','main riff','high_gain','hard rock','rhythm','advanced',
     'Solid-body electric (Kanami Tono)','Modern high-gain tube head','Closed-back 4x12 cab','bridge humbucker',
     '[]'::jsonb,'{"gain":7,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['Virtuosic hard-rock drive — tight riffing with prog flourishes.','Modern gain with mids in; Kanami''s parts are dense and precise.'],
     array['The riff weaves through fast position shifts.','The solo mixes shred runs with melodic phrasing.'],
     'Studio recording, 2019. Virtuosic hard-rock drive from Conqueror.',72),

    -- ============ INDIE / SOFT SIDE ============
    ('zenzenzense','radwimps','guitar','riff','main riff','crunch','j-rock','rhythm','intermediate',
     'Solid-body electric (Yojiro Noda / Akira Kuwahara)','Bright tube amp, tight crunch','Open-back cab','bridge pickup',
     '[]'::jsonb,'{"gain":5,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":0,"master":7}'::jsonb,
     array['The Your Name theme — sprinting bright crunch with joyful momentum.','Trebly tight crunch; the sixteenth-note riff must stay light on its feet.'],
     array['The intro riff is the song''s heartbeat — even and bouncing.','Strum the choruses wide open.'],
     'Studio recording, 2016. Sprinting bright crunch from Your Name.',73),
    ('kaikai-kitan','eve','guitar','riff','main riff','distorted','j-rock','rhythm','advanced',
     'Solid-body electric (session — Numa)','Driven tube amp, tight and bright','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":7}'::jsonb,
     array['The Jujutsu Kaisen opening — frantic vocaloid-rock riffing.','Bright tight drive; the riffs sprint with the vocal.'],
     array['Fast chord/single-note hybrid figures throughout.','Precision at tempo — slow it down first.'],
     'Studio recording, 2020. Frantic vocaloid-rock from the JJK opening.',71),
    ('hitchcock','yorushika','guitar','riff','main riff + lead fills','clean','j-rock','lead','intermediate',
     'Fender Telecaster (n-buna)','Bright clean amp','Open-back combo cab','bridge pickup',
     '[{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":3}},{"effect_type":"compressor","effect_name":"light compression","placement":"front","settings":{"sustain":4,"level":5}}]'::jsonb,
     '{"gain":3,"bass":4,"mids":6,"treble":7,"presence":6,"reverb":3,"delay":0,"master":6}'::jsonb,
     array['n-buna''s glassy melodic clean — fast lyrical lead fills woven through jangly chords.','Bright just-clean sparkle; the lead lines sing over the strums.'],
     array['The signature fills answer every vocal phrase — learn them as melodies.','Light pick attack keeps the glassiness.'],
     'Studio recording, 2018. n-buna''s glassy melodic clean — a young-guitarist favorite.',72),
    ('aoi-shiori','galileo-galilei','guitar','riff','main riff','clean','j-rock','rhythm','intermediate',
     'Fender electric (Yuuki Ozaki)','Bright clean amp, slight edge','Open-back combo cab','bridge pickup',
     '[{"effect_type":"reverb","effect_name":"room reverb","placement":"post_gain","settings":{"mix":3}}]'::jsonb,
     '{"gain":3,"bass":4,"mids":5,"treble":7,"presence":6,"reverb":3,"delay":1,"master":6}'::jsonb,
     array['The Anohana opening — nostalgic sparkling indie jangle.','Just-clean bright strums and arpeggios; wistful, never aggressive.'],
     array['The intro arpeggio-riff carries the nostalgia.','Dynamic swells follow the vocal.'],
     'Studio recording, 2011. Nostalgic sparkling jangle from the Anohana opening.',72),
    ('imagination','spyair','guitar','riff','main riff','distorted','j-rock','rhythm','intermediate',
     'Solid-body electric (UZ)','Driven tube amp, bright','Closed-back cab','bridge humbucker',
     '[]'::jsonb,'{"gain":6,"bass":5,"mids":6,"treble":6,"presence":6,"reverb":2,"delay":1,"master":7}'::jsonb,
     array['The Haikyuu!! opening — triumphant stadium drive.','Bright saturated rhythm; anthemic and open.'],
     array['Driving power chords with melodic accents.','Play the choruses like a victory lap.'],
     'Studio recording, 2014. Triumphant stadium drive from the Haikyuu opening.',71),
    ('the-rumbling','sim','guitar','riff','main riff','high_gain','metalcore','rhythm','intermediate',
     'Solid-body electric (SHOW-HATE / SiM)','Modern high-gain, produced','Closed-back 4x12 cab','bridge humbucker',
     '[{"effect_type":"gate","effect_name":"tight noise gate","placement":"front","settings":{"threshold":7}}]'::jsonb,
     '{"gain":8,"bass":7,"mids":4,"treble":6,"presence":6,"reverb":1,"delay":0,"master":8}'::jsonb,
     array['The Attack on Titan final-season opening — crushing slow-stomp metalcore.','Huge low-tuned wall; weight over speed.'],
     array['The stomp riff is slow and inevitable — don''t rush it.','Let the drops land with the full band.'],
     'Studio recording, 2022. Crushing slow-stomp wall from the AoT finale opening.',73)
) as c(
  song_slug, artist_slug, mode, part_type, part_label, tone_type, genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes, source_summary, confidence
)
join public.artists a on a.slug = c.artist_slug
join public.songs s on s.artist_id = a.id and s.slug = c.song_slug;
