-- Add user-requested gear (2026-08-06):
--   1. Donner DMT-66 — budget 39" HSS Strat-style electric (poplar, maple neck,
--      25.5", 6-point tremolo). Behavior mapped to the Squier Stratocaster
--      family (budget bright single-coil-forward Strat voice).
--   2. Peavey Vypyr 75 — 75W 1x12 solid-state modeling combo (TransTube, SHARC
--      DSP, 24 amp models). Behavior mapped to the existing Peavey Bandit 112
--      family that already carries the Vypyr X-series tags.
begin;

-- ============================================================
-- 1. Donner DMT-66 — equipment catalog entry
-- ============================================================
insert into public.equipment (
  equipment_type, brand, model, series, display_name, description,
  is_popular, sort_order, status,
  body_type, frets, scale_length_inches, bridge_type,
  pickup_configuration, pickup_type, output_level,
  genres, tone_characteristics, search_terms
) values (
  'electric_guitar', 'Donner', 'DMT-66', null,
  'Donner DMT-66',
  'Budget 39" HSS Strat-style electric with poplar body, maple neck, and 6-point tremolo.',
  false, 100, 'active',
  'solid_body', 22, 25.5, 'vintage_tremolo',
  'hss', array['humbucker','single_coil']::equipment_pickup_type[], 'medium',
  array['rock','blues','metal']::equipment_genre[],
  array['bright','dynamic','balanced']::equipment_tone_characteristic[],
  array['donner', 'dmt-66', 'dmt66', 'dmt', 'donner dmt-66']::text[]
)
on conflict (equipment_type, brand, model) do update set
  display_name = excluded.display_name,
  description = excluded.description,
  search_terms = excluded.search_terms,
  updated_at = now();

-- Tag Donner DMT-66 into the Squier Stratocaster behavior family
update public.guitar_models t
set tags = array_cat(t.tags, array['donner dmt-66', 'donner dmt66', 'donner dmt']::text[])
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'squier'
  and t.model_name = 'Stratocaster / Telecaster' and t.instrument_type = 'guitar'
  and not (t.tags @> array['donner dmt-66']::text[]);

-- ============================================================
-- 2. Peavey Vypyr 75 — equipment catalog entry
-- ============================================================
insert into public.equipment (
  equipment_type, brand, model, series, display_name, description,
  is_popular, sort_order, status,
  amp_type, technology, power_rating_watts, channels, gain_range,
  genres, tone_characteristics, search_terms
) values (
  'guitar_amp', 'Peavey', 'Vypyr 75', 'Vypyr',
  'Peavey Vypyr 75',
  '75W 1x12 solid-state modeling combo with TransTube voicing, 24 amp models, and onboard effects.',
  false, 100, 'active',
  'combo', 'digital', 75, 4, 'high',
  array['rock','hard_rock','blues','metal']::equipment_genre[],
  array['clean','crunch','high_gain','dynamic']::equipment_tone_characteristic[],
  array['peavey', 'vypyr', 'vypyr 75', '75', 'transtube']::text[]
)
on conflict (equipment_type, brand, model) do update set
  display_name = excluded.display_name,
  description = excluded.description,
  search_terms = excluded.search_terms,
  updated_at = now();

-- Tag Peavey Vypyr 75 into the Peavey Bandit 112 (solid_state_crunch) family
update public.amp_models t
set tags = array_cat(t.tags, array['peavey vypyr 75', 'peavey vypyr']::text[])
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'peavey'
  and t.model_name = 'Bandit 112' and t.instrument_type = 'guitar'
  and not (t.tags @> array['peavey vypyr 75']::text[]);

-- ============================================================
-- Post-conditions: both resolve in behavior search_text
-- ============================================================
do $$
declare
  hit text;
begin
  select model_name into hit
  from public.guitar_models
  where instrument_type = 'guitar' and search_text ilike '%donner dmt-66%'
  limit 1;
  if hit is null then
    raise exception 'POST-CONDITION FAILED: Donner DMT-66 not in any guitar_models search_text';
  end if;

  select model_name into hit
  from public.amp_models
  where instrument_type = 'guitar' and search_text ilike '%peavey vypyr 75%'
  limit 1;
  if hit is null then
    raise exception 'POST-CONDITION FAILED: Peavey Vypyr 75 not in any amp_models search_text';
  end if;

  perform 1 from public.equipment
  where equipment_type = 'electric_guitar' and brand = 'Donner' and model = 'DMT-66' and status = 'active';
  if not found then
    raise exception 'POST-CONDITION FAILED: Donner DMT-66 not in equipment catalog';
  end if;

  perform 1 from public.equipment
  where equipment_type = 'guitar_amp' and brand = 'Peavey' and model = 'Vypyr 75' and status = 'active';
  if not found then
    raise exception 'POST-CONDITION FAILED: Peavey Vypyr 75 not in equipment catalog';
  end if;
end $$;

commit;
