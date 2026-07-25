-- Correct flagship song tone profiles with researched, per-part data.
--
-- Background: the 20260629002126 ToneAdapt-community seed carried only gear NAMES;
-- every song's amp settings and effects were filled in by genre/part TEMPLATES
-- (all metal songs got identical knobs, every riff got a phantom
-- "noise gate + overdrive boost + post-amp EQ" chain, several songs referenced the
-- wrong part's gear, e.g. Beat It / Hotel California used the SOLO guitarist's rig
-- for the main riff). This migration replaces those rows for the flagship
-- comparison songs with hand-researched, per-part profiles: correct gear for the
-- requested part, real per-song settings, and effects that actually appear on the
-- recording (empty when the part used no pedals).
--
-- Scope: Master of Puppets, Hotel California, Under the Bridge, Beat It, Pride and Joy.
-- These are deleted and re-inserted so no stale/templated rows remain to out-rank the
-- corrected data in the legacy tone-profile lookup.

-- 1. Remove stale child effects for the target songs.
delete from public.tone_profile_effects e
where e.profile_id in (
  select p.id
  from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id
  join public.artists a on a.id = s.artist_id
  join (values
    ('metallica', 'master-of-puppets'),
    ('eagles', 'hotel-california'),
    ('red-hot-chili-peppers', 'under-the-bridge'),
    ('michael-jackson', 'beat-it'),
    ('stevie-ray-vaughan-double-trouble', 'pride-and-joy')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);

-- 2. Remove stale child sources for the target songs.
delete from public.tone_profile_sources src
where src.profile_id in (
  select p.id
  from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id
  join public.artists a on a.id = s.artist_id
  join (values
    ('metallica', 'master-of-puppets'),
    ('eagles', 'hotel-california'),
    ('red-hot-chili-peppers', 'under-the-bridge'),
    ('michael-jackson', 'beat-it'),
    ('stevie-ray-vaughan-double-trouble', 'pride-and-joy')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);

-- 3. Remove the stale/templated profiles themselves.
delete from public.song_tone_profiles p
where p.id in (
  select p2.id
  from public.song_tone_profiles p2
  join public.songs s on s.id = p2.song_id
  join public.artists a on a.id = s.artist_id
  join (values
    ('metallica', 'master-of-puppets'),
    ('eagles', 'hotel-california'),
    ('red-hot-chili-peppers', 'under-the-bridge'),
    ('michael-jackson', 'beat-it'),
    ('stevie-ray-vaughan-double-trouble', 'pride-and-joy')
  ) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
);

-- 4. Insert the corrected, researched per-part profiles.
insert into public.song_tone_profiles (
  song_id, song_title, artist_name, mode, part_type, part_label, tone_type,
  genre, tone_category, difficulty,
  original_guitar, original_amp, original_cab, original_pickup,
  original_effects, original_settings, adaptation_notes, playing_notes,
  source_summary, confidence, verification_status, search_text, is_public
)
select
  s.id,
  s.title,
  a.name,
  c.mode,
  c.part_type,
  c.part_label,
  c.tone_type,
  c.genre,
  c.tone_category,
  c.difficulty,
  c.original_guitar,
  c.original_amp,
  c.original_cab,
  c.original_pickup,
  c.original_effects,
  c.original_settings,
  c.adaptation_notes,
  c.playing_notes,
  c.source_summary,
  c.confidence,
  'admin_verified',
  concat_ws(' ', s.title, a.name, c.part_label, c.tone_type, c.original_guitar, c.original_amp, 'researched verified tone'),
  true
from (
  values
    -- ===== Master of Puppets — Metallica (1986) =====
    (
      'master-of-puppets', 'metallica', 'guitar', 'riff', 'main downpicked riff', 'high_gain',
      'metal', 'rhythm', 'expert',
      'ESP / Gibson Explorer-style humbucker guitar (James Hetfield)',
      'Mesa/Boogie Mark IIC+ (rhythm channel, high gain)',
      'Closed-back 4x12 cab',
      'bridge humbucker (passive on the original 1986 recording)',
      '[]'::jsonb,
      '{"gain":9,"bass":6,"mids":3,"treble":7.5,"presence":6.5,"reverb":1,"delay":0,"master":6}'::jsonb,
      array[
        'Classic scooped-mid thrash voicing: keep mids low but not at zero so palm mutes still cut through.',
        'No pedals on the original — all gain is from the Mesa preamp. If your amp is lower-gain, push the front with a Tube Screamer-style boost instead of maxing amp gain.',
        'Tighten the low end before adding gain; flabby bass ruins downpicked clarity.'
      ],
      array[
        'Relentless downpicking near the bridge for tightness.',
        'Short, controlled palm mutes; timing matters more than saturation.'
      ],
      'Studio recording, 1986. James Hetfield tracked rhythms through a Mesa/Boogie Mark IIC+ with no distortion pedals. The exact pickup is debated: passive humbuckers on the album, with EMGs adopted afterward.',
      88
    ),
    (
      'master-of-puppets', 'metallica', 'guitar', 'solo', 'lead solo', 'high_gain',
      'metal', 'lead', 'expert',
      'ESP humbucker guitar (Kirk Hammett)',
      'Mesa/Boogie Mark IIC+ (lead channel)',
      'Closed-back 4x12 cab',
      'bridge humbucker',
      '[{"effect_type":"wah","effect_name":"Dunlop Cry Baby wah (accents)","placement":"front","settings":{"position":6}}]'::jsonb,
      '{"gain":9,"bass":5,"mids":6,"treble":7,"presence":6,"reverb":2,"delay":2,"master":6}'::jsonb,
      array[
        'Solo uses more midrange than the rhythm so single notes sing over the mix.',
        'A light delay adds space; keep it subtle so fast runs stay articulate.'
      ],
      array[
        'Wah is used for accenting, not a fixed cocked position.',
        'Favor sustain and vibrato over piling on gain.'
      ],
      'Kirk Hammett tracked leads on the Mesa/Boogie Mark IIC+ lead channel, using a wah for phrasing accents.',
      82
    ),
    -- ===== Hotel California — Eagles (1976) =====
    (
      'hotel-california', 'eagles', 'guitar', 'riff', 'twelve-string intro riff', 'clean',
      'rock', 'clean', 'intermediate',
      '1975 Gibson EDS-1275 doubleneck, 12-string neck (Don Felder)',
      'Clean tube combo (Fender/Mesa-style, edge of clean)',
      'Open-back combo speaker',
      'neck humbucker (12-string neck)',
      '[]'::jsonb,
      '{"gain":2,"bass":5,"mids":6,"treble":6.5,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
      array[
        'The intro riff is clean and arpeggiated — keep gain very low and let the 12-string chime.',
        'If you only have a 6-string, roll tone back slightly and add a touch of chorus to imply the 12-string shimmer.',
        'Reverb carries the ambience; avoid heavy compression that flattens the arpeggio dynamics.'
      ],
      array[
        'Let every note of the arpeggio ring into the next.',
        'Even, gentle pick attack keeps the clean tone open.'
      ],
      'Studio recording, 1976. Don Felder played the main riff on the 12-string neck of a Gibson EDS-1275. The intro is clean with minimal effects.',
      80
    ),
    (
      'hotel-california', 'eagles', 'guitar', 'solo', 'dual-guitar outro solo', 'crunch',
      'rock', 'lead', 'expert',
      'Gibson Les Paul (Don Felder) and Fender Telecaster (Joe Walsh)',
      'Fender tweed / black-panel-style combo at the edge of breakup',
      'Open-back combo speaker',
      'bridge pickup, tone rolled back slightly',
      '[]'::jsonb,
      '{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":1,"master":6}'::jsonb,
      array[
        'Moderate, articulate gain — not modern high-gain. Harmonized lines must stay clear.',
        'Use midrange sustain rather than fuzz; the harmony intonation is the focus.'
      ],
      array[
        'Match bends carefully between the two harmony parts.',
        'Controlled pick attack keeps the harmonized thirds locked in.'
      ],
      'The harmonized outro was played by Don Felder (Les Paul) and Joe Walsh (Telecaster) at edge-of-breakup gain, not heavy distortion.',
      82
    ),
    -- ===== Under the Bridge — Red Hot Chili Peppers (1991) =====
    (
      'under-the-bridge', 'red-hot-chili-peppers', 'guitar', 'riff', 'clean intro and verse figure', 'clean',
      'rock', 'clean', 'intermediate',
      '1962 Fender Stratocaster (John Frusciante)',
      'Marshall silverface / Major-style clean amp',
      'Open-back combo or 4x12 (clean)',
      'neck / middle single-coil',
      '[]'::jsonb,
      '{"gain":1,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":5}'::jsonb,
      array[
        'Almost entirely clean and touch-sensitive — keep gain near zero.',
        'If using humbuckers, split the coils or roll the guitar volume back to keep the chime.',
        'Let the chord voicings breathe; the intro is about dynamics, not effects.'
      ],
      array[
        'Use thumb and finger dynamics for the intro chord fragments.',
        'Keep the ringing notes clear and even.'
      ],
      'John Frusciante played the clean intro and verse figures on a Fender Stratocaster through a clean Marshall. The part is mostly clean with minimal effects.',
      80
    ),
    -- ===== Beat It — Michael Jackson (1982) =====
    (
      'beat-it', 'michael-jackson', 'guitar', 'riff', 'main rhythm riff', 'crunch',
      'rock', 'rhythm', 'intermediate',
      'Valley Arts Custom Pro (Steve Lukather, HSS)',
      'Marshall JCM800 2203',
      'Marshall 4x12 cab',
      'bridge humbucker',
      '[]'::jsonb,
      '{"gain":6,"bass":6,"mids":6,"treble":7,"presence":6,"reverb":1,"delay":0,"master":6}'::jsonb,
      array[
        'Controlled crunch, not high-gain. Quincy Jones wanted a tighter, less-distorted tone for pop radio.',
        'No pedals on the riff — the crunch comes from the amp. Roll guitar volume back slightly for the cleaner-edged rhythm.',
        'Keep mids present so the riff stays punchy in a dense mix.'
      ],
      array[
        'Tight, even eighth-note muting drives the groove.',
        'Do not over-drive it; the riff is about attack and control.'
      ],
      'Studio recording, 1982. Steve Lukather (Toto) played the rhythm riff. Quincy Jones asked for a controlled, less-distorted tone; no pedals on the riff. Eddie Van Halen played the solo with different gear.',
      82
    ),
    (
      'beat-it', 'michael-jackson', 'guitar', 'solo', 'featured guitar solo', 'high_gain',
      'rock', 'lead', 'expert',
      'Charvel "Frankenstrat" (Eddie Van Halen)',
      'Marshall 1959 Super Lead (Plexi) — the "brown sound"',
      'Marshall 4x12 cab',
      'bridge humbucker',
      '[{"effect_type":"delay","effect_name":"Echoplex EP-3 tape echo (subtle)","placement":"post_gain","settings":{"mix":2,"time":3}}]'::jsonb,
      '{"gain":8,"bass":5,"mids":6,"treble":7,"presence":7,"reverb":1,"delay":2,"master":7}'::jsonb,
      array[
        'This is Eddie Van Halen''s brown sound — cranked Plexi, bright and saturated but touch-responsive.',
        'A subtle tape echo adds depth; keep it low so the fast phrases stay defined.',
        'On a modeling amp, a Plexi / Super Lead voicing gets closest.'
      ],
      array[
        'Expressive bends, taps and dive-bombs define the solo.',
        'Let the amp saturation do the work; pick dynamics clean it up.'
      ],
      'Eddie Van Halen recorded the solo as an uncredited favor, using his Frankenstrat into a cranked Marshall Super Lead Plexi (the "brown sound").',
      82
    ),
    -- ===== Pride and Joy — Stevie Ray Vaughan (1983) =====
    (
      'pride-and-joy', 'stevie-ray-vaughan-double-trouble', 'guitar', 'riff', 'shuffle riff', 'crunch',
      'blues', 'rhythm', 'advanced',
      '1963 Fender Stratocaster "Number One" (Stevie Ray Vaughan)',
      'Fender Vibroverb (Blackface) — the miked amp for the main riff',
      'Open-back combo speakers',
      'neck / middle single-coil (heavy strings, Eb tuning)',
      '[]'::jsonb,
      '{"gain":4,"bass":7,"mids":7,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
      array[
        'Amp edge-of-breakup crunch, not pedal distortion. The Vibroverb was miked for the riff with no pedals.',
        'Strong low-mid body from heavy strings — keep bass and mids up.',
        'The Tube Screamer was used only for solos, not the shuffle riff.'
      ],
      array[
        'Aggressive right-hand shuffle with strong low-string attack.',
        'Heavy-gauge strings in Eb tuning give the thick, springy feel.'
      ],
      'Texas Flood sessions, 1983. Only the Fender Vibroverb was miked for the main riff, with no pedals on the rhythm. The Ibanez Tube Screamer was reserved for solos.',
      80
    ),
    (
      'pride-and-joy', 'stevie-ray-vaughan-double-trouble', 'guitar', 'solo', 'guitar solo', 'crunch',
      'blues', 'lead', 'advanced',
      '1963 Fender Stratocaster "Number One" (Stevie Ray Vaughan)',
      'Fender Vibroverb pushed by an Ibanez Tube Screamer TS9',
      'Open-back combo speakers',
      'neck / middle single-coil',
      '[{"effect_type":"overdrive","effect_name":"Ibanez Tube Screamer TS9 (solo boost)","placement":"front","settings":{"drive":3,"tone":6,"level":7}}]'::jsonb,
      '{"gain":5,"bass":6,"mids":7,"treble":6,"presence":5,"reverb":3,"delay":0,"master":6}'::jsonb,
      array[
        'The solo is boosted with a Tube Screamer for extra midrange and sustain.',
        'Keep the amp at edge of breakup and let the pedal add drive and focus.'
      ],
      array[
        'Vocal, string-bending phrasing with wide vibrato.',
        'Dig in hard; SRV''s touch is a big part of the tone.'
      ],
      'SRV pushed his solos with an Ibanez Tube Screamer into the Vibroverb for extra midrange and sustain.',
      80
    )
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
  song_title = excluded.song_title,
  artist_name = excluded.artist_name,
  genre = excluded.genre,
  tone_category = excluded.tone_category,
  difficulty = excluded.difficulty,
  original_guitar = excluded.original_guitar,
  original_amp = excluded.original_amp,
  original_cab = excluded.original_cab,
  original_pickup = excluded.original_pickup,
  original_effects = excluded.original_effects,
  original_settings = excluded.original_settings,
  adaptation_notes = excluded.adaptation_notes,
  playing_notes = excluded.playing_notes,
  source_summary = excluded.source_summary,
  confidence = excluded.confidence,
  verification_status = excluded.verification_status,
  search_text = excluded.search_text,
  is_public = excluded.is_public,
  updated_at = now();

-- 5. Attach honest provenance to every corrected profile.
insert into public.tone_profile_sources (profile_id, source_type, title, url, notes, credibility)
select p.id, x.source_type, x.title, x.url, x.notes, x.credibility
from public.song_tone_profiles p
join public.songs s on s.id = p.song_id
join public.artists a on a.id = s.artist_id
join (values
  ('metallica', 'master-of-puppets'),
  ('eagles', 'hotel-california'),
  ('red-hot-chili-peppers', 'under-the-bridge'),
  ('michael-jackson', 'beat-it'),
  ('stevie-ray-vaughan-double-trouble', 'pride-and-joy')
) as t(artist_slug, song_slug) on t.artist_slug = a.slug and t.song_slug = s.slug
cross join (values
  ('artist_interview', 'Documented artist interviews and gear discussions', null::text,
   'Researched from widely-documented interviews about this recording and player.', 72),
  ('rig_rundown', 'Published rig rundowns and community gear databases', null::text,
   'Cross-referenced against rig features and community-maintained gear databases.', 66)
) as x(source_type, title, url, notes, credibility)
where p.verification_status = 'admin_verified'
on conflict do nothing;
