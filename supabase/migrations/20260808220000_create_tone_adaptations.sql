-- Adaptation Analytics / History: one permanent row per successful (or failed)
-- tone adaptation. Denormalized on purpose — it stores SNAPSHOTS of the song,
-- artist, tone, user email, gear and settings as they were at adaptation time, so
-- historical records stay accurate even if songs/gear/tones/users change later.
-- Reuses existing tables via FKs (profiles, tone_results) but never depends on them
-- for the analytics values themselves.
create table public.tone_adaptations (
  id uuid primary key default gen_random_uuid(),

  -- Who (FK kept for joins; email snapshot survives profile changes/deletion)
  user_id uuid references public.profiles(id) on delete set null,
  user_email text,

  -- What song / tone (ids for reference, names as durable snapshots)
  song_id text,
  song_name text,
  artist_name text,
  tone_id text,
  tone_name text,

  -- Selected gear (ids where available; full config snapshot in JSONB)
  guitar_id text,
  pickup_id text,
  amp_id text,
  cabinet_id text,
  pedals jsonb not null default '[]'::jsonb,
  selected_gear jsonb not null default '{}'::jsonb,

  -- Settings snapshots: exactly what went in vs. what Tonefex returned
  original_tone_settings jsonb not null default '{}'::jsonb,
  adapted_tone_settings jsonb not null default '{}'::jsonb,

  -- Which engine / version produced it (for A/B of adaptation logic over time)
  adaptation_engine text,
  adaptation_version text,
  mode text,
  request_source text,
  confidence numeric,
  source_summary jsonb not null default '{}'::jsonb, -- finalSource, aiUsed, timings, cache status

  -- Link to the full stored result blob (reuses existing tone_results), nullable
  tone_result_id uuid references public.tone_results(id) on delete set null,

  -- Outcome
  status text not null default 'success' check (status in ('success', 'failed')),
  error_message text,
  generation_time_ms integer,

  -- Feedback (recorded later)
  feedback_rating integer check (feedback_rating between 1 and 5),
  feedback_comment text,

  created_at timestamptz not null default now()
);

-- Indexes for the common analytics queries (kept lean — no over-indexing).
create index tone_adaptations_user_id_idx on public.tone_adaptations (user_id);
create index tone_adaptations_created_at_idx on public.tone_adaptations (created_at desc);
create index tone_adaptations_song_name_idx on public.tone_adaptations (song_name);       -- most-adapted songs
create index tone_adaptations_artist_name_idx on public.tone_adaptations (artist_name);    -- popular artists
create index tone_adaptations_status_idx on public.tone_adaptations (status);              -- success vs failure
create index tone_adaptations_version_idx on public.tone_adaptations (adaptation_version); -- version performance
create index tone_adaptations_tone_id_idx on public.tone_adaptations (tone_id);
create index tone_adaptations_user_created_idx on public.tone_adaptations (user_id, created_at desc); -- a user's history

-- Row Level Security: a user may read ONLY their own history. All writes go through
-- the service role (from the adapt route), which bypasses RLS — that same role is
-- the admin/analytics layer that can read every row. Existing policies are untouched.
alter table public.tone_adaptations enable row level security;
grant select on public.tone_adaptations to authenticated;

create policy "tone_adaptations_select_own" on public.tone_adaptations
  for select using (auth.uid() = user_id);
