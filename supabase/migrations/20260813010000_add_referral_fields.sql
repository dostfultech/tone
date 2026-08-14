-- Referral MVP ("just track"): each profile gets a shareable referral_code, and referred_by
-- records who referred them. No automated reward yet — attribution + stats only. The code is
-- deterministic from the user id (md5 slice) so it is stable and easy to backfill.
begin;

alter table public.profiles add column if not exists referral_code text;
alter table public.profiles add column if not exists referred_by uuid;

-- Backfill a stable code for every existing profile.
update public.profiles
set referral_code = upper(substring(md5('tonefex-ref:' || id::text) from 1 for 8))
where referral_code is null;

create unique index if not exists profiles_referral_code_key on public.profiles (referral_code);
create index if not exists profiles_referred_by_idx on public.profiles (referred_by);

do $$
declare missing int;
begin
  select count(*) into missing from public.profiles where referral_code is null;
  if missing > 0 then raise exception 'Referral code backfill incomplete: % profiles', missing; end if;
end $$;

commit;
