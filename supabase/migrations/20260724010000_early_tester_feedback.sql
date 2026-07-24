-- Early tester feedback submissions table
-- Stores structured feedback from early tester users after they exhaust their free adaptations.
-- Controlled by EARLY_TESTER_MODE feature flag.

create table if not exists public.feedback_submissions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  email text not null,
  full_name text,
  overall_rating smallint not null check (overall_rating between 1 and 5),
  tone_accuracy text not null check (tone_accuracy in ('excellent', 'good', 'average', 'needs_improvement', 'poor')),
  what_worked text,
  improvements text,
  bugs text,
  willing_to_call boolean not null default false,
  preferred_contact_method text check (preferred_contact_method is null or preferred_contact_method in ('email', 'discord', 'google_meet')),
  timezone text,
  status text not null default 'pending' check (status in ('pending', 'reviewed', 'upgraded')),
  reviewed_at timestamptz,
  reviewed_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists feedback_submissions_user_idx on public.feedback_submissions (user_id);
create index if not exists feedback_submissions_status_idx on public.feedback_submissions (status);

alter table public.feedback_submissions enable row level security;

-- Users can insert their own feedback
create policy "Users can submit feedback"
  on public.feedback_submissions for insert
  to authenticated
  with check (auth.uid() = user_id);

-- Users can read their own feedback
create policy "Users can read own feedback"
  on public.feedback_submissions for select
  to authenticated
  using (auth.uid() = user_id);

-- Admins can read all feedback
create policy "Admins can read all feedback"
  on public.feedback_submissions for select
  to authenticated
  using (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid()
        and profiles.role = 'admin'
    )
  );

-- Admins can update feedback (for marking reviewed/upgraded)
create policy "Admins can update feedback"
  on public.feedback_submissions for update
  to authenticated
  using (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid()
        and profiles.role = 'admin'
    )
  );

-- Updated at trigger
drop trigger if exists feedback_submissions_updated_at on public.feedback_submissions;
create trigger feedback_submissions_updated_at
  before update on public.feedback_submissions
  for each row execute function public.set_updated_at();
