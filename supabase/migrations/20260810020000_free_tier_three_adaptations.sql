begin;

-- Free tier 1 -> 3 adaptations. Behavioral data showed one free adaptation was too thin:
-- users got their single answer and left, few reached the paywall, ~0 converted. Give a
-- fuller taste (3) before the wall so people get hooked and come back.
alter table public.profiles
  alter column free_adaptation_limit set default 3;

-- Re-engage existing FREE users (no active paid plan) by raising them to 3, so everyone who
-- bounced at the 1-adaptation wall gets more free tries. Leaves anyone with a higher
-- grandfathered limit untouched, and never touches active subscribers.
update public.profiles p
set free_adaptation_limit = 3
where coalesce(p.free_adaptation_limit, 0) < 3
  and not exists (
    select 1 from public.subscriptions s
    where s.user_id = p.id and s.status = 'active'
  );

commit;
