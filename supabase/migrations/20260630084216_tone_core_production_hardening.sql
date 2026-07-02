alter table public.tone_equipment_profiles
  add column if not exists search_text text not null default '';

update public.tone_equipment_profiles tep
set search_text = lower(regexp_replace(concat_ws(
  ' ',
  gi.brand,
  gi.model,
  gi.item_type,
  gi.category,
  gi.instrument_type,
  gi.pickup_type,
  gi.amp_type,
  gi.gain_range,
  array_to_string(gi.voicing_tags, ' '),
  array_to_string(gi.notable_use_cases, ' '),
  gi.search_text
), '\s+', ' ', 'g'))
from public.gear_items gi
where tep.gear_item_id = gi.id;

create index if not exists tone_equipment_profiles_type_active_idx
  on public.tone_equipment_profiles (equipment_type, is_active, profile_version);

create index if not exists tone_equipment_profiles_search_text_idx
  on public.tone_equipment_profiles using gin (to_tsvector('simple', search_text));

create index if not exists tone_adaptation_cache_equipment_idx
  on public.tone_adaptation_cache (guitar_profile_id, amp_profile_id, schema_version, expires_at);

revoke all on public.tone_equipment_profiles from anon, authenticated;
revoke all on public.tone_adaptation_cache from anon, authenticated;
revoke all on public.tone_generation_telemetry from anon, authenticated;

grant select, insert, update, delete on public.tone_equipment_profiles to service_role;
grant select, insert, update, delete on public.tone_adaptation_cache to service_role;
grant select, insert on public.tone_generation_telemetry to service_role;

comment on column public.tone_equipment_profiles.search_text is
  'Normalized indexed text used by the Tonefex core resolver for fast equipment profile candidate lookup.';
