-- Tonefex AI ingestion pipeline.
-- Additive only: this stores admin/background ingestion jobs and review decisions.
-- Normal user tone adaptation must continue to use master_tones + rule engine + cache, not AI.

create table if not exists public.ai_ingestion_jobs (
  id uuid primary key default gen_random_uuid(),
  job_type text not null check (job_type in (
    'song_generation',
    'metadata_enrichment',
    'gear_matching',
    'cache_prewarming'
  )),
  status text not null default 'queued' check (status in (
    'queued',
    'running',
    'succeeded',
    'failed',
    'cancelled'
  )),
  priority integer not null default 100,
  payload jsonb not null default '{}'::jsonb,
  result jsonb not null default '{}'::jsonb,
  error_message text,
  attempts integer not null default 0 check (attempts >= 0),
  max_attempts integer not null default 3 check (max_attempts > 0),
  requested_by uuid references public.profiles(id) on delete set null,
  locked_by text,
  locked_at timestamptz,
  started_at timestamptz,
  finished_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.ai_ingestion_job_events (
  id uuid primary key default gen_random_uuid(),
  job_id uuid not null references public.ai_ingestion_jobs(id) on delete cascade,
  event_type text not null,
  message text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.master_tone_review_decisions (
  id uuid primary key default gen_random_uuid(),
  master_tone_id uuid not null references public.master_tones(id) on delete cascade,
  status text not null check (status in ('approved', 'rejected')),
  reviewed_by uuid references public.profiles(id) on delete set null,
  reason text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists ai_ingestion_jobs_claim_idx
  on public.ai_ingestion_jobs (status, priority, created_at)
  where status = 'queued';

create index if not exists ai_ingestion_jobs_type_status_idx
  on public.ai_ingestion_jobs (job_type, status, created_at desc);

create index if not exists ai_ingestion_job_events_job_idx
  on public.ai_ingestion_job_events (job_id, created_at);

create index if not exists master_tone_review_decisions_tone_idx
  on public.master_tone_review_decisions (master_tone_id, created_at desc);

drop trigger if exists ai_ingestion_jobs_updated_at on public.ai_ingestion_jobs;
create trigger ai_ingestion_jobs_updated_at
before update on public.ai_ingestion_jobs
for each row execute function public.set_updated_at();

alter table public.ai_ingestion_jobs enable row level security;
alter table public.ai_ingestion_job_events enable row level security;
alter table public.master_tone_review_decisions enable row level security;

revoke all on public.ai_ingestion_jobs from anon, authenticated;
revoke all on public.ai_ingestion_job_events from anon, authenticated;
revoke all on public.master_tone_review_decisions from anon, authenticated;

grant select, insert, update, delete on public.ai_ingestion_jobs to service_role;
grant select, insert, update, delete on public.ai_ingestion_job_events to service_role;
grant select, insert, update, delete on public.master_tone_review_decisions to service_role;

drop policy if exists ai_ingestion_jobs_admin_read on public.ai_ingestion_jobs;
create policy ai_ingestion_jobs_admin_read on public.ai_ingestion_jobs
for select to authenticated
using (exists (
  select 1 from public.profiles p
  where p.id = (select auth.uid())
    and p.role = 'admin'
));

drop policy if exists ai_ingestion_job_events_admin_read on public.ai_ingestion_job_events;
create policy ai_ingestion_job_events_admin_read on public.ai_ingestion_job_events
for select to authenticated
using (exists (
  select 1 from public.profiles p
  where p.id = (select auth.uid())
    and p.role = 'admin'
));

drop policy if exists master_tone_review_decisions_admin_read on public.master_tone_review_decisions;
create policy master_tone_review_decisions_admin_read on public.master_tone_review_decisions
for select to authenticated
using (exists (
  select 1 from public.profiles p
  where p.id = (select auth.uid())
    and p.role = 'admin'
));

comment on table public.ai_ingestion_jobs is
  'Durable admin/background jobs for AI-only database ingestion. These jobs never run during normal user tone adaptation.';

comment on table public.ai_ingestion_job_events is
  'Event log for ingestion workers, including AI call attempts, validation, storage, enrichment, and cache prewarming.';

comment on table public.master_tone_review_decisions is
  'Admin approval/rejection decisions for normalized master tones.';
