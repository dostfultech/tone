-- Per-tone accuracy feedback: the closed loop that tells us WHICH adaptations
-- sound wrong and in WHICH direction, tied to the exact song + gear pair.
-- This is the tuning signal for the rule engine's compensation constants.

create table if not exists public.tone_accuracy_feedback (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  song_title text not null,
  artist_name text not null,
  part_label text,
  tone_type text,
  verdict text not null check (verdict in ('close', 'off')),
  -- Directional signals, only present when verdict = 'off'.
  directions text[] not null default '{}',
  guitar_name text,
  amp_name text,
  going_direct boolean not null default false,
  multi_fx_name text,
  pedal_names text[] not null default '{}',
  adapted_settings jsonb not null default '{}'::jsonb,
  confidence_shown smallint,
  verification_status text,
  rule_engine_version text,
  notes text,
  created_at timestamptz not null default now()
);

create index if not exists tone_accuracy_feedback_song_idx on public.tone_accuracy_feedback (artist_name, song_title);
create index if not exists tone_accuracy_feedback_amp_idx on public.tone_accuracy_feedback (amp_name);
create index if not exists tone_accuracy_feedback_verdict_idx on public.tone_accuracy_feedback (verdict);
create index if not exists tone_accuracy_feedback_created_idx on public.tone_accuracy_feedback (created_at desc);

alter table public.tone_accuracy_feedback enable row level security;

-- Signed-in users can submit feedback about their own adaptations.
create policy "Users can submit tone feedback"
  on public.tone_accuracy_feedback for insert
  to authenticated
  with check (auth.uid() = user_id);

-- Users can read their own submissions.
create policy "Users can read own tone feedback"
  on public.tone_accuracy_feedback for select
  to authenticated
  using (auth.uid() = user_id);

-- Admins can read everything (tuning dashboard).
create policy "Admins can read all tone feedback"
  on public.tone_accuracy_feedback for select
  to authenticated
  using (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid()
        and profiles.role = 'admin'
    )
  );
