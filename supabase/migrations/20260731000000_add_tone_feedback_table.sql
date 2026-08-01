-- Tone-specific feedback from beta testers and users.
-- Tracks what the engine recommended vs what the user actually used,
-- so we can calibrate the rule engine over time.

create table if not exists public.tone_feedback (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id) on delete set null,
  song_tone_profile_id uuid references public.song_tone_profiles(id) on delete set null,
  user_gear_summary text,
  overall_rating smallint check (overall_rating between 1 and 10),
  adjustments jsonb not null default '{}',
  feedback_notes text,
  source text not null default 'discord' check (source in ('discord', 'in_app', 'email', 'other')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.tone_feedback is 'Per-adaptation feedback: rating + what settings the user changed from recommended values';
comment on column public.tone_feedback.adjustments is 'JSON of setting changes, e.g. {"gain": {"recommended": 5, "actual": 7}}';

alter table public.tone_feedback enable row level security;

create policy "Users can insert own feedback"
  on public.tone_feedback for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy "Users can read own feedback"
  on public.tone_feedback for select
  to authenticated
  using (auth.uid() = user_id);

create policy "Admins can read all feedback"
  on public.tone_feedback for select
  to authenticated
  using (
    exists (select 1 from public.profiles where id = auth.uid() and role = 'admin')
  );
