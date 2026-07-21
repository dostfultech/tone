-- Switch from "3 free adaptations" to "3-day free trial" model.
-- New users get free_adaptation_limit = 0 (must subscribe to start trial).
-- Existing users keep their current limit (grandfathered).
alter table public.profiles
  alter column free_adaptation_limit set default 0;
