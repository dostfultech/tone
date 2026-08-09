begin;

-- Records every gear search that our catalog could NOT satisfy (zero matches),
-- including partial / half-typed names. Deduped by (kind + query) with a running
-- count, so the most-demanded missing guitars / amps / pedals rise to the top.
-- Mirrors public.song_search_misses (songs) — this is the gear equivalent.
create table if not exists public.gear_search_misses (
  id uuid primary key default gen_random_uuid(),
  kind text not null,                        -- guitar | bass_guitar | amp | bass_amp | cabinet | pickup | pedal | multifx
  query_text text not null,
  normalized_key text generated always as (lower(btrim(kind)) || ' | ' || lower(btrim(query_text))) stored,
  match_count integer not null default 0,    -- catalog results the latest search returned (0 = we don't have it)
  search_count integer not null default 1,   -- how many times this exact query was searched
  sample_user_id uuid references public.profiles(id) on delete set null,
  reviewed boolean not null default false,
  first_searched_at timestamptz not null default now(),
  last_searched_at timestamptz not null default now()
);

create unique index if not exists gear_search_misses_key_idx
  on public.gear_search_misses (normalized_key);

create index if not exists gear_search_misses_review_idx
  on public.gear_search_misses (reviewed, search_count desc);

create index if not exists gear_search_misses_kind_idx
  on public.gear_search_misses (kind, search_count desc);

alter table public.gear_search_misses enable row level security;

-- Upsert helper: increments the count on repeat searches for the same gear.
-- security definer so the anon/authenticated caller can log without direct table grants;
-- server routes call it with the service role.
create or replace function public.record_gear_search_miss(
  p_kind text,
  p_query text,
  p_match_count integer default 0,
  p_user_id uuid default null
) returns void
language sql
security definer
set search_path = public
as $$
  insert into public.gear_search_misses (kind, query_text, match_count, sample_user_id)
  values (btrim(coalesce(p_kind, 'unknown')), btrim(p_query), coalesce(p_match_count, 0), p_user_id)
  on conflict (normalized_key) do update set
    search_count = public.gear_search_misses.search_count + 1,
    match_count = excluded.match_count,
    last_searched_at = now(),
    sample_user_id = coalesce(public.gear_search_misses.sample_user_id, excluded.sample_user_id);
$$;

-- Weekly review helper: the gear people want that we don't have, most-demanded first.
create or replace view public.gear_search_miss_review as
select kind, query_text, match_count, search_count, first_searched_at, last_searched_at
from public.gear_search_misses
where reviewed = false and match_count = 0
order by search_count desc, last_searched_at desc;

-- Reads are admin-only; inserts happen server-side via the service role (bypasses RLS).
drop policy if exists "Admins can read gear search misses" on public.gear_search_misses;
create policy "Admins can read gear search misses"
  on public.gear_search_misses for select
  to authenticated
  using (exists (select 1 from public.profiles where id = auth.uid() and role = 'admin'));

commit;
