alter table public.profiles
  add column if not exists free_adaptation_limit integer not null default 3 check (free_adaptation_limit >= 0),
  add column if not exists free_adaptations_used integer not null default 0 check (free_adaptations_used >= 0),
  add column if not exists welcome_completed_at timestamptz,
  add column if not exists gear_onboarding_completed_at timestamptz,
  add column if not exists tone_database_seen_at timestamptz,
  add column if not exists first_adaptation_completed_at timestamptz;

update public.profiles
set
  free_adaptation_limit = greatest(coalesce(free_adaptation_limit, 3), 0),
  free_adaptations_used = least(
    greatest(coalesce(free_adaptations_used, 0), 0),
    greatest(coalesce(free_adaptation_limit, 3), 0)
  );

alter table public.tone_results
  add column if not exists usage_confirmed_at timestamptz;

create index if not exists tone_results_user_confirmation_idx
  on public.tone_results (user_id, usage_confirmed_at, created_at desc);

comment on column public.profiles.free_adaptation_limit is
  'Free-plan adaptation credits granted to the account. Tonefex onboarding uses 3 by default.';

comment on column public.profiles.free_adaptations_used is
  'Free-plan adaptation credits consumed after the frontend confirms a successful tone response.';

comment on column public.tone_results.usage_confirmed_at is
  'Set only after the client confirms that a successful adaptation response reached the frontend.';
