-- Switch to the "1 free lifetime adaptation, then upgrade" model (2026-08-06).
-- Trials are retired. New signed-in users get exactly one free adaptation; after
-- that they must subscribe. Backfills existing free users who never spent their
-- old credit so they also get the single free taste.
begin;

-- New profiles default to 1 free adaptation.
alter table public.profiles
  alter column free_adaptation_limit set default 1;

-- Give the single free credit to existing free users who have not used any
-- adaptation yet (limit currently 0/null and nothing consumed). Users who already
-- hold a higher grandfathered limit, or who have already used adaptations, are left
-- untouched so this can't hand anyone a second free run.
update public.profiles
set free_adaptation_limit = 1
where coalesce(free_adaptation_limit, 0) < 1
  and coalesce(free_adaptations_used, 0) = 0
  and first_adaptation_completed_at is null
  and not exists (
    select 1 from public.usage_events e
    where e.user_id = profiles.id
      and e.event_type = 'tone_adaptation'
      and e.metadata @> '{"plan":"free"}'::jsonb
  );

-- Post-conditions
do $$
declare
  col_default text;
  leftover int;
begin
  select column_default into col_default
  from information_schema.columns
  where table_schema = 'public' and table_name = 'profiles' and column_name = 'free_adaptation_limit';
  if col_default is null or position('1' in col_default) = 0 then
    raise exception 'POST-CONDITION FAILED: free_adaptation_limit default is % (expected 1)', col_default;
  end if;

  -- No fresh, never-used free profile should still sit at limit 0.
  select count(*) into leftover
  from public.profiles
  where coalesce(free_adaptation_limit, 0) = 0
    and coalesce(free_adaptations_used, 0) = 0
    and first_adaptation_completed_at is null;
  if leftover > 0 then
    raise exception 'POST-CONDITION FAILED: % never-used free profiles remain at limit 0', leftover;
  end if;
end $$;

commit;
