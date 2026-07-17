-- Backfill user-requested equipment from feedback into searchable catalog tables.
-- This keeps requested gear discoverable even when it exists only in one source table.

create extension if not exists pg_trgm;

-- Ensure key requested brands exist in canonical brand + manufacturer tables.
insert into public.equipment_manufacturers (name, slug)
values
  ('Epiphone', 'epiphone'),
  ('Harley Benton', 'harley-benton'),
  ('Marshall', 'marshall')
on conflict (slug) do update set
  name = excluded.name,
  is_active = true,
  updated_at = now();

insert into public.guitar_brands (name, slug, search_text)
values
  ('Epiphone', 'epiphone', 'epiphone electric guitar'),
  ('Harley Benton', 'harley-benton', 'harley benton electric guitar')
on conflict (slug) do update set
  name = excluded.name,
  search_text = excluded.search_text,
  is_active = true,
  updated_at = now();

insert into public.amp_brands (name, slug, search_text)
values
  ('Marshall', 'marshall', 'marshall guitar amp')
on conflict (slug) do update set
  name = excluded.name,
  search_text = excluded.search_text,
  is_active = true,
  updated_at = now();

-- Explicitly add known feedback requests from screenshots/user report.
with refs as (
  select
    (select id from public.equipment_manufacturers where slug = 'epiphone' limit 1) as epiphone_manufacturer_id,
    (select id from public.equipment_manufacturers where slug = 'harley-benton' limit 1) as harley_benton_manufacturer_id,
    (select id from public.equipment_manufacturers where slug = 'marshall' limit 1) as marshall_manufacturer_id,
    (select id from public.guitar_brands where slug = 'epiphone' limit 1) as epiphone_brand_id,
    (select id from public.guitar_brands where slug = 'harley-benton' limit 1) as harley_benton_brand_id,
    (select id from public.amp_brands where slug = 'marshall' limit 1) as marshall_brand_id
)
insert into public.guitar_models (
  manufacturer_id,
  brand_id,
  model_name,
  name,
  instrument_type,
  category,
  pickup_configuration,
  tags,
  is_active
)
select
  refs.epiphone_manufacturer_id,
  refs.epiphone_brand_id,
  'Les Paul Traditional Pro II',
  'Les Paul Traditional Pro II',
  'guitar',
  'electric',
  'HH',
  array['les paul', 'traditional', 'pro'],
  true
from refs
where refs.epiphone_manufacturer_id is not null and refs.epiphone_brand_id is not null
on conflict do nothing;

with refs as (
  select
    (select id from public.equipment_manufacturers where slug = 'harley-benton' limit 1) as harley_benton_manufacturer_id,
    (select id from public.guitar_brands where slug = 'harley-benton' limit 1) as harley_benton_brand_id
)
insert into public.guitar_models (
  manufacturer_id,
  brand_id,
  model_name,
  name,
  instrument_type,
  category,
  pickup_configuration,
  tags,
  is_active
)
select
  refs.harley_benton_manufacturer_id,
  refs.harley_benton_brand_id,
  'WL-20BK Rock Series',
  'WL-20BK Rock Series',
  'guitar',
  'electric',
  'HH',
  array['rock', 'wl-20bk'],
  true
from refs
where refs.harley_benton_manufacturer_id is not null and refs.harley_benton_brand_id is not null
on conflict do nothing;

with refs as (
  select
    (select id from public.equipment_manufacturers where slug = 'marshall' limit 1) as marshall_manufacturer_id,
    (select id from public.amp_brands where slug = 'marshall' limit 1) as marshall_brand_id
)
insert into public.amp_models (
  manufacturer_id,
  brand_id,
  model_name,
  name,
  instrument_type,
  amp_technology,
  category,
  amp_type,
  tags,
  is_active
)
select
  refs.marshall_manufacturer_id,
  refs.marshall_brand_id,
  'MG15FX',
  'MG15FX',
  'guitar',
  'solid_state',
  'combo',
  'solid_state',
  array['practice', 'fx'],
  true
from refs
where refs.marshall_manufacturer_id is not null and refs.marshall_brand_id is not null
on conflict do nothing;

-- Keep legacy gear_items in sync so old and new search paths both return these models.
insert into public.gear_items (
  brand,
  model,
  item_type,
  category,
  instrument_type,
  pickup_type,
  amp_type,
  gain_range,
  voicing_tags,
  notable_use_cases,
  source_urls,
  search_text,
  is_active
)
values
  (
    'Epiphone',
    'Les Paul Traditional Pro II',
    'guitar',
    'electric',
    'guitar',
    'humbucker',
    null,
    null,
    array['les paul', 'traditional', 'pro'],
    array['feedback-request'],
    array[]::text[],
    'epiphone les paul traditional pro ii electric guitar humbucker',
    true
  ),
  (
    'Harley Benton',
    'WL-20BK Rock Series',
    'guitar',
    'electric',
    'guitar',
    'humbucker',
    null,
    null,
    array['rock', 'wl-20bk'],
    array['feedback-request'],
    array[]::text[],
    'harley benton wl-20bk rock series electric guitar',
    true
  ),
  (
    'Marshall',
    'MG15FX',
    'amp',
    'combo',
    'guitar',
    null,
    'solid_state',
    null,
    array['practice', 'fx'],
    array['feedback-request'],
    array[]::text[],
    'marshall mg15fx guitar amp combo solid state',
    true
  )
on conflict (brand, model, item_type) do update set
  category = excluded.category,
  instrument_type = excluded.instrument_type,
  pickup_type = excluded.pickup_type,
  amp_type = excluded.amp_type,
  voicing_tags = excluded.voicing_tags,
  notable_use_cases = excluded.notable_use_cases,
  search_text = excluded.search_text,
  is_active = true,
  updated_at = now();

-- Optional generic import from feedback_messages for newly requested gear that was not yet modeled.
with parsed_feedback as (
  select distinct
    trim(message) as message,
    case
      when message ~* '^\s*request\s*:\s*(guitar\s*amp|amp|amplifier)\s*-' then 'amp'
      when message ~* '^\s*request\s*:\s*guitar\s*-' then 'guitar'
      when message ~* '^\s*request\s*:\s*pickup\s*-' then 'pickup'
      when message ~* '^\s*request\s*:\s*pedal\s*-' then 'pedal'
      when message ~* '^\s*request\s*:\s*(multi\s*fx|multifx|multi-fx)\s*-' then 'multi_fx'
      else null
    end as item_type,
    trim(regexp_replace(message, '^\s*request\s*:\s*[^-]+-\s*', '', 'i')) as requested_name
  from public.feedback_messages
  where message ~* '^\s*request\s*:'
), normalized_feedback as (
  select
    item_type,
    requested_name,
    split_part(requested_name, ' ', 1) as brand,
    trim(regexp_replace(requested_name, '^\S+\s*', '')) as model
  from parsed_feedback
  where item_type is not null
    and requested_name is not null
    and requested_name <> ''
)
insert into public.gear_items (
  brand,
  model,
  item_type,
  category,
  instrument_type,
  search_text,
  voicing_tags,
  notable_use_cases,
  source_urls,
  is_active
)
select
  coalesce(nullif(brand, ''), 'Unknown'),
  coalesce(nullif(model, ''), requested_name),
  item_type,
  case
    when item_type = 'amp' then 'amp'
    when item_type = 'guitar' then 'electric'
    when item_type = 'pickup' then 'pickup'
    when item_type = 'pedal' then 'pedal'
    when item_type = 'multi_fx' then 'multi_fx'
    else item_type
  end as category,
  case
    when item_type = 'amp' then 'guitar'
    when item_type = 'guitar' then 'guitar'
    else 'both'
  end as instrument_type,
  lower(regexp_replace(concat_ws(' ', brand, requested_name, item_type), '\\s+', ' ', 'g')) as search_text,
  array['feedback-request'],
  array['feedback_messages'],
  array[]::text[],
  true
from normalized_feedback
on conflict (brand, model, item_type) do update set
  is_active = true,
  updated_at = now();
