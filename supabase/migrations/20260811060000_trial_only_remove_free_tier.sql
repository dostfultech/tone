begin;

-- Trial-only model (ToneAdapt-style): remove the free, no-card adaptation tier. To adapt a
-- tone the user must start the 7-day free trial (card on file, converts after 7 days).
-- New profiles get 0 free adaptations; existing NON-subscribed free users are zeroed too.
-- Active/trialing subscribers are untouched.
alter table public.profiles
  alter column free_adaptation_limit set default 0;

update public.profiles p
set free_adaptation_limit = 0
where coalesce(p.free_adaptation_limit, 0) > 0
  and not exists (
    select 1 from public.subscriptions s
    where s.user_id = p.id and s.status in ('active', 'trialing')
  );

commit;
