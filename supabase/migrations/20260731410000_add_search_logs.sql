-- Search-gap tracking: log every song search so we can see which songs users
-- want that we don't have verified. Powers demand-driven tone batches.

create table if not exists public.search_logs (
  id uuid primary key default gen_random_uuid(),
  query text not null,
  normalized_query text not null,
  user_id uuid references public.profiles(id) on delete set null,
  db_match_count integer not null default 0,
  top_match text,
  created_at timestamptz not null default now()
);

create index if not exists search_logs_normalized_query_idx on public.search_logs (normalized_query);
create index if not exists search_logs_created_at_idx on public.search_logs (created_at);

comment on table public.search_logs is 'Every song search: query + whether the verified database had a match. Misses = songs to verify next.';

alter table public.search_logs enable row level security;

-- Inserts happen server-side with the service role (bypasses RLS).
-- Only admins can read.
create policy "Admins can read search logs"
  on public.search_logs for select
  to authenticated
  using (
    exists (select 1 from public.profiles where id = auth.uid() and role = 'admin')
  );
