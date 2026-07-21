begin;

-- Records every song search that missed the curated database and triggered
-- AI hydration. Reviewed weekly to convert real user demand into verified
-- tone profiles.
create table if not exists public.song_search_misses (
  id uuid primary key default gen_random_uuid(),
  song_title text not null,
  artist_name text not null,
  normalized_key text generated always as (lower(btrim(song_title)) || ' | ' || lower(btrim(artist_name))) stored,
  part_label text,
  part_type text,
  tone_type text,
  mode text,
  search_count integer not null default 1,
  hydration_succeeded boolean not null default false,
  hydrated_master_tone_id uuid,
  reviewed boolean not null default false,
  first_searched_at timestamptz not null default now(),
  last_searched_at timestamptz not null default now()
);

create unique index if not exists song_search_misses_normalized_key_idx
  on public.song_search_misses (normalized_key);

create index if not exists song_search_misses_review_idx
  on public.song_search_misses (reviewed, search_count desc);

alter table public.song_search_misses enable row level security;

create or replace function public.record_song_search_miss(
  p_song text,
  p_artist text,
  p_part text default null,
  p_part_type text default null,
  p_tone_type text default null,
  p_mode text default null,
  p_hydration_succeeded boolean default false,
  p_master_tone_id uuid default null
) returns void
language sql
security definer
set search_path = public
as $$
  insert into public.song_search_misses (
    song_title, artist_name, part_label, part_type, tone_type, mode,
    hydration_succeeded, hydrated_master_tone_id
  )
  values (
    btrim(coalesce(p_song, 'Unknown Song')),
    btrim(coalesce(p_artist, 'Unknown Artist')),
    p_part, p_part_type, p_tone_type, p_mode,
    coalesce(p_hydration_succeeded, false),
    p_master_tone_id
  )
  on conflict (normalized_key) do update set
    search_count = public.song_search_misses.search_count + 1,
    last_searched_at = now(),
    hydration_succeeded = public.song_search_misses.hydration_succeeded or excluded.hydration_succeeded,
    hydrated_master_tone_id = coalesce(public.song_search_misses.hydrated_master_tone_id, excluded.hydrated_master_tone_id);
$$;

-- Weekly review helper: most-demanded unreviewed misses first.
create or replace view public.song_search_miss_review as
select
  song_title,
  artist_name,
  search_count,
  hydration_succeeded,
  first_searched_at,
  last_searched_at
from public.song_search_misses
where reviewed = false
order by search_count desc, last_searched_at desc;

commit;
