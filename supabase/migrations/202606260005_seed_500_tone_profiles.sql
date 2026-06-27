with artist_rows(name, slug) as (
  values
    ('North Avenue', 'north-avenue'),
    ('Silver Line', 'silver-line'),
    ('Midnight Arcade', 'midnight-arcade'),
    ('Velvet Echo', 'velvet-echo'),
    ('Neon Harbour', 'neon-harbour'),
    ('Atlas Fire', 'atlas-fire'),
    ('Paper Satellites', 'paper-satellites'),
    ('Golden Static', 'golden-static'),
    ('Afterglow Parade', 'afterglow-parade'),
    ('Hollow Avenue', 'hollow-avenue'),
    ('Blue Cinema', 'blue-cinema'),
    ('Signal Hearts', 'signal-hearts'),
    ('Wild Meridian', 'wild-meridian'),
    ('Electric Letters', 'electric-letters'),
    ('The Last Seasons', 'the-last-seasons'),
    ('Lowlight District', 'lowlight-district'),
    ('Cassette Bloom', 'cassette-bloom'),
    ('Crimson Youth', 'crimson-youth'),
    ('Polar Fires', 'polar-fires'),
    ('Sunday Lights', 'sunday-lights')
),
upsert_artists as (
  insert into public.artists (name, slug, country, search_text)
  select name, slug, 'Global', name
  from artist_rows
  on conflict (slug) do update set
    name = excluded.name,
    country = excluded.country,
    search_text = excluded.search_text
  returning id, slug, name
),
generated_song_rows as (
  select
    idx,
    trim(
      (array['Midnight','Silver','Golden','Electric','Quiet','Restless','Velvet','Neon','Falling','Broken','Static','Young','Wild','Secret','Blue','Crimson','Open','Dark','Shallow','Northern'])[((idx - 1) % 20) + 1]
      || ' ' ||
      (array['Horizon','Cinema','Signal','Letters','Highway','Ghost','River','Fever','Seasons','Dreams','Mercy','Thunder','Satellite','Mirrors','Motion','Fire','Crown','Ocean','Echo','Run','Silence','Street','Lights','Colour','Gravity'])[(((idx - 1) / 20) % 25) + 1]
    ) as title,
    lower(regexp_replace(trim(
      (array['Midnight','Silver','Golden','Electric','Quiet','Restless','Velvet','Neon','Falling','Broken','Static','Young','Wild','Secret','Blue','Crimson','Open','Dark','Shallow','Northern'])[((idx - 1) % 20) + 1]
      || ' ' ||
      (array['Horizon','Cinema','Signal','Letters','Highway','Ghost','River','Fever','Seasons','Dreams','Mercy','Thunder','Satellite','Mirrors','Motion','Fire','Crown','Ocean','Echo','Run','Silence','Street','Lights','Colour','Gravity'])[(((idx - 1) / 20) % 25) + 1]
    )), '[^a-zA-Z0-9]+', '-', 'g')) as slug,
    format('Studio Sessions Vol. %s', ((idx - 1) / 25) + 1) as album,
    2010 + (idx % 15) as release_year,
    150 + (idx % 120) as duration_seconds,
    (array['north-avenue','silver-line','midnight-arcade','velvet-echo','neon-harbour','atlas-fire','paper-satellites','golden-static','afterglow-parade','hollow-avenue','blue-cinema','signal-hearts','wild-meridian','electric-letters','the-last-seasons','lowlight-district','cassette-bloom','crimson-youth','polar-fires','sunday-lights'])[((idx - 1) % 20) + 1] as artist_slug
  from generate_series(1, 500) as idx
),
upsert_songs as (
  insert into public.songs (
    artist_id,
    title,
    slug,
    album,
    release_year,
    duration_seconds,
    search_text,
    is_active
  )
  select
    a.id,
    s.title,
    s.slug,
    s.album,
    s.release_year,
    s.duration_seconds,
    concat_ws(' ', s.title, a.name, s.album, 'tone database'),
    true
  from generated_song_rows s
  join upsert_artists a on a.slug = s.artist_slug
  on conflict (artist_id, slug) do update set
    title = excluded.title,
    album = excluded.album,
    release_year = excluded.release_year,
    duration_seconds = excluded.duration_seconds,
    search_text = excluded.search_text,
    is_active = true,
    updated_at = now()
  returning id, slug, title
),
upsert_profiles as (
  insert into public.song_tone_profiles (
    song_id,
    song_title,
    artist_name,
    mode,
    part_type,
    part_label,
    tone_type,
    original_guitar,
    original_amp,
    original_cab,
    original_pickup,
    original_effects,
    original_settings,
    adaptation_notes,
    playing_notes,
    source_summary,
    confidence,
    verification_status,
    search_text,
    is_public
  )
  select
    song.id,
    song.title,
    artist.name,
    case when generated.idx % 6 = 0 then 'bass' else 'guitar' end as mode,
    case
      when generated.idx % 7 = 0 then 'solo'
      when generated.idx % 5 = 0 then 'riff'
      when generated.idx % 3 = 0 then 'rhythm'
      else 'main'
    end as part_type,
    format('session arrangement %s', generated.idx) as part_label,
    case
      when generated.idx % 6 = 0 and generated.idx % 2 = 0 then 'bass_drive'
      when generated.idx % 6 = 0 then 'bass_clean'
      when generated.idx % 8 = 0 then 'high_gain'
      when generated.idx % 5 = 0 then 'crunch'
      when generated.idx % 4 = 0 then 'distorted'
      else 'clean'
    end as tone_type,
    case
      when generated.idx % 6 = 0 then '4-string bass with medium-output pickups'
      when generated.idx % 2 = 0 then 'Humbucker electric guitar'
      else 'Single-coil electric guitar'
    end as original_guitar,
    case
      when generated.idx % 6 = 0 then 'Bass amp head with DI blend'
      when generated.idx % 8 = 0 then 'High-gain 100W tube amp'
      when generated.idx % 5 = 0 then 'Crunch-style British amp'
      else 'Clean channel tube combo'
    end as original_amp,
    case when generated.idx % 6 = 0 then '4x10 bass cab' else '2x12 guitar cab' end as original_cab,
    case
      when generated.idx % 6 = 0 then 'neck and bridge blend'
      when generated.idx % 2 = 0 then 'bridge humbucker'
      else 'bridge or middle single-coil'
    end as original_pickup,
    case
      when generated.idx % 6 = 0 then
        '[{"type":"compression","name":"bass compressor","placement":"front","settings":{"ratio":4,"level":5}},{"type":"eq","name":"bass contour EQ","placement":"post","settings":{"low":6,"mid":6,"high":4}}]'::jsonb
      else
        '[{"type":"drive","name":"amp drive","placement":"amp","settings":{"gain":5}},{"type":"reverb","name":"small room","placement":"post","settings":{"mix":2,"decay":3}}]'::jsonb
    end as original_effects,
    case
      when generated.idx % 6 = 0 then '{"gain":5,"bass":6,"mids":6,"treble":4,"presence":4,"compression":5,"reverb":0,"delay":0}'::jsonb
      else '{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":2,"delay":0}'::jsonb
    end as original_settings,
    array[
      'Starter estimate generated for broad catalog coverage.',
      'Refine this profile with specific rig details when community data is available.'
    ] as adaptation_notes,
    array[
      'Start with moderate picking dynamics and adjust gain to fit your rig.',
      'Treat this profile as a practical baseline for rehearsal and tweak by ear.'
    ] as playing_notes,
    'Large-scale starter profile generated for the Tonefex tone database expansion.' as source_summary,
    66 + (generated.idx % 14) as confidence,
    'starter_estimate' as verification_status,
    concat_ws(' ', song.title, artist.name, 'session arrangement', generated.idx::text, 'tone database') as search_text,
    true as is_public
  from upsert_songs song
  join generated_song_rows generated on generated.slug = song.slug
  join upsert_artists artist on artist.slug = generated.artist_slug
  on conflict (song_id, mode, part_type, tone_type, part_label) do update set
    song_title = excluded.song_title,
    artist_name = excluded.artist_name,
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
    is_public = true,
    updated_at = now()
  returning id
)
insert into public.tone_profile_sources (profile_id, source_type, title, url, notes, credibility)
select
  profile.id,
  'internal_seed',
  'Tonefex expanded starter profile',
  null,
  'Auto-seeded profile added to provide broad searchable coverage in the tone database.',
  52
from upsert_profiles profile
on conflict do nothing;
