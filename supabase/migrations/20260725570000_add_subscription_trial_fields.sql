-- Capture Dodo free-trial details so the app can render a ToneAdapt-style trial
-- (countdown, trial-end date, "then $X") and enforce trial adaptation limits.
alter table public.subscriptions
  add column if not exists trial_end timestamptz,
  add column if not exists trial_period_days integer not null default 0;

comment on column public.subscriptions.trial_end is
  'When the Dodo free trial ends and the first real charge occurs (null when there is no trial).';
comment on column public.subscriptions.trial_period_days is
  'Number of days in the Dodo trial period (0 when the product has no trial configured).';
