alter table public.tone_adaptation_cache
  add column if not exists effects_mode text,
  add column if not exists multi_fx_name text,
  add column if not exists selected_fx_name text,
  add column if not exists going_direct boolean not null default false,
  add column if not exists pickup_profile_id uuid references public.tone_equipment_profiles(id) on delete set null,
  add column if not exists cabinet_profile_id uuid references public.tone_equipment_profiles(id) on delete set null,
  add column if not exists multi_fx_profile_id uuid references public.tone_equipment_profiles(id) on delete set null,
  add column if not exists pickup_profile_version integer not null default 0 check (pickup_profile_version >= 0),
  add column if not exists cabinet_profile_version integer not null default 0 check (cabinet_profile_version >= 0),
  add column if not exists multi_fx_profile_version integer not null default 0 check (multi_fx_profile_version >= 0);

create index if not exists tone_adaptation_cache_direct_idx
  on public.tone_adaptation_cache (going_direct, multi_fx_profile_id, schema_version, expires_at);

create index if not exists tone_adaptation_cache_pickup_cabinet_idx
  on public.tone_adaptation_cache (pickup_profile_id, cabinet_profile_id, schema_version, expires_at);

with cabinet_profiles as (
  select
    gi.id as gear_item_id,
    gi.item_type as equipment_type,
    case
      when gi.voicing_tags && array['open', 'clean', '1x12'] then 'open_bright_cabinet'
      when gi.voicing_tags && array['deep', 'low-end', 'high-gain'] then 'deep_closed_cabinet'
      when gi.voicing_tags && array['mid-rich', 'focused'] then 'focused_mid_cabinet'
      when gi.instrument_type = 'bass' then 'bass_cabinet'
      else 'general_cabinet'
    end as transfer_class,
    jsonb_build_object(
      'knobScale', '0-10',
      'controls', jsonb_build_array(
        jsonb_build_object('key', 'cabBlock', 'label', 'Cab / IR', 'type', 'model'),
        jsonb_build_object('key', 'micPosition', 'label', 'Mic position', 'type', 'selector'),
        jsonb_build_object('key', 'lowCut', 'label', 'Low cut', 'type', 'eq'),
        jsonb_build_object('key', 'highCut', 'label', 'High cut', 'type', 'eq')
      )
    ) as control_schema,
    jsonb_build_object(
      'displayName', concat(gi.brand, ' ', gi.model),
      'brand', gi.brand,
      'model', gi.model,
      'category', gi.category,
      'instrumentType', gi.instrument_type,
      'voicingTags', to_jsonb(gi.voicing_tags),
      'eqBias', jsonb_build_object(
        'bass', case when gi.voicing_tags && array['deep', 'low-end', 'bass'] then -1 else 0 end,
        'mids', case when gi.voicing_tags && array['mid-rich', 'focused'] then -1 when gi.voicing_tags && array['scooped'] then 1 else 0 end,
        'treble', case when gi.voicing_tags && array['open', 'clean', 'bright'] then -1 when gi.voicing_tags && array['deep', 'dark', 'low-end'] then 1 else 0 end,
        'presence', case when gi.voicing_tags && array['open', 'clean', 'bright'] then -1 when gi.voicing_tags && array['deep', 'dark', 'low-end'] then 1 else 0 end
      ),
      'toneTypeAdjustments', jsonb_build_object(
        'clean', jsonb_build_object('treble', case when gi.voicing_tags && array['open', 'clean'] then -1 else 0 end),
        'crunch', jsonb_build_object('mids', case when gi.voicing_tags && array['mid-rich', 'focused'] then -1 else 0 end),
        'distorted', jsonb_build_object('bass', case when gi.voicing_tags && array['deep', 'high-gain'] then -1 else 0 end),
        'high_gain', jsonb_build_object('bass', case when gi.voicing_tags && array['deep', 'high-gain'] then -1 else 0 end, 'presence', 1),
        'bass_clean', jsonb_build_object('bass', case when gi.voicing_tags && array['low-end', 'bass'] then -1 else 0 end),
        'bass_drive', jsonb_build_object('bass', case when gi.voicing_tags && array['low-end', 'bass'] then -1 else 0 end, 'mids', 1)
      ),
      'advice', to_jsonb(array[
        'Cabinet brightness changes treble and presence after pickup and amp compensation.',
        'For direct patches, choose the closest cab IR before adding post EQ.'
      ])
    ) as behavior_profile,
    case when gi.source_urls <> '{}'::text[] then 74 else 66 end as confidence,
    lower(regexp_replace(concat_ws(
      ' ',
      gi.brand,
      gi.model,
      gi.item_type,
      gi.category,
      gi.instrument_type,
      array_to_string(gi.voicing_tags, ' '),
      array_to_string(gi.notable_use_cases, ' '),
      gi.search_text
    ), '\s+', ' ', 'g')) as search_text
  from public.gear_items gi
  where gi.is_active = true
    and gi.item_type = 'cabinet'
)
insert into public.tone_equipment_profiles (
  gear_item_id,
  equipment_type,
  schema_version,
  profile_version,
  transfer_class,
  control_schema,
  behavior_profile,
  confidence,
  source,
  is_active,
  search_text
)
select
  gear_item_id,
  equipment_type,
  1,
  1,
  transfer_class,
  control_schema,
  behavior_profile,
  confidence,
  'seed',
  true,
  search_text
from cabinet_profiles
on conflict (gear_item_id, equipment_type) do update set
  schema_version = excluded.schema_version,
  profile_version = greatest(public.tone_equipment_profiles.profile_version, excluded.profile_version),
  transfer_class = excluded.transfer_class,
  control_schema = excluded.control_schema,
  behavior_profile = excluded.behavior_profile,
  confidence = excluded.confidence,
  source = excluded.source,
  is_active = true,
  search_text = excluded.search_text,
  updated_at = now();

comment on column public.tone_adaptation_cache.going_direct is
  'True when the cached adaptation was generated for a direct/modeler or MultiFX workflow.';

comment on column public.tone_adaptation_cache.multi_fx_profile_id is
  'Matched MultiFX equipment profile used when going_direct is true.';
