-- Add WestCreek Revenge guitar from user feedback (2026-08-06).
-- Explorer-shaped solid body, dual alnico humbuckers, mahogany body, tune-o-matic.
-- Behavior mapped to Gibson Explorer / Flying V family (identical tonal DNA).
begin;

-- 1. Equipment catalog entry
insert into public.equipment (
  equipment_type, brand, model, series, display_name, description,
  is_popular, sort_order, status,
  body_type, frets, scale_length_inches, bridge_type,
  pickup_configuration, pickup_type, output_level,
  genres, tone_characteristics, search_terms
) values (
  'electric_guitar', 'WestCreek', 'Revenge', null,
  'WestCreek Revenge',
  'Explorer-shaped solid body with alnico humbucker pickups, mahogany body, and tune-o-matic bridge.',
  false, 100, 'active',
  'solid_body', 22, 24.75, 'tune_o_matic',
  'hh', array['humbucker']::equipment_pickup_type[], 'medium',
  array['rock','metal','hard_rock']::equipment_genre[],
  array['aggressive','warm','punchy']::equipment_tone_characteristic[],
  array['westcreek', 'west creek', 'revenge', 'westcreek revenge']::text[]
)
on conflict (equipment_type, brand, model) do update set
  display_name = excluded.display_name,
  description = excluded.description,
  search_terms = excluded.search_terms,
  updated_at = now();

-- 2. Tag into Gibson Explorer / Flying V behavior family
--    (search_text matching is manufacturer-agnostic via ILIKE)
update public.guitar_models t
set tags = array_cat(t.tags, array['westcreek revenge', 'west creek revenge']::text[])
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'gibson'
  and t.model_name = 'Explorer / Flying V' and t.instrument_type = 'guitar'
  and not (t.tags @> array['westcreek revenge']::text[]);

-- Post-condition: verify WestCreek Revenge resolves in search_text
do $$
declare
  miss text;
begin
  select model_name into miss
  from public.guitar_models
  where instrument_type = 'guitar'
    and search_text ilike '%westcreek revenge%'
  limit 1;
  if miss is null then
    raise exception 'POST-CONDITION FAILED: westcreek revenge not in any guitar_models search_text';
  end if;

  perform 1 from public.equipment
  where equipment_type = 'electric_guitar'
    and brand = 'WestCreek'
    and model = 'Revenge'
    and status = 'active'
  limit 1;
  if not found then
    raise exception 'POST-CONDITION FAILED: WestCreek Revenge not in equipment catalog';
  end if;
end $$;

commit;
