-- Add user-requested guitars from feedback_messages (2026-08-06).
-- 1. Ibanez AZ47P1QM-BIB: new equipment row + behavior tag in AZ family
-- 2. Epiphone Les Paul Traditional: standalone equipment row (behavior already covered)
-- 3. Ibanez ART300: fix body type mismatch (solid, not semi-hollow)
begin;

-- ============================================================
-- 1. Ibanez AZ47P1QM-BIB — equipment catalog entry
-- ============================================================
insert into public.equipment (
  equipment_type, brand, model, series, display_name, description,
  is_popular, sort_order, status,
  body_type, frets, scale_length_inches, bridge_type,
  pickup_configuration, pickup_type, output_level,
  genres, tone_characteristics, search_terms
) values (
  'electric_guitar', 'Ibanez', 'AZ47P1QM-BIB', 'AZ Premium',
  'Ibanez AZ47P1QM-BIB',
  'Premium AZ with quilted maple top, Seymour Duncan Hyperion pickups, and Edge tremolo.',
  false, 100, 'active',
  'solid_body', 24, 25.5, 'two_point_tremolo',
  'hss', array['humbucker','single_coil']::equipment_pickup_type[], 'medium',
  array['rock','blues','fusion','jazz']::equipment_genre[],
  array['bright','warm','dynamic','articulate']::equipment_tone_characteristic[],
  array['ibanez', 'az47', 'az47p1qm', 'az premium', 'bib', 'hyperion']::text[]
)
on conflict (equipment_type, brand, model) do update set
  display_name = excluded.display_name,
  description = excluded.description,
  search_terms = excluded.search_terms,
  updated_at = now();

-- Add AZ47 variants to the Ibanez AZ behavior family tags
update public.guitar_models t
set tags = array_cat(t.tags, array['ibanez az47p1qm-bib', 'ibanez az47p1qm', 'ibanez az47']::text[])
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'ibanez'
  and t.model_name = 'AZ' and t.instrument_type = 'guitar'
  and not (t.tags @> array['ibanez az47p1qm-bib']::text[]);

-- ============================================================
-- 2. Epiphone Les Paul Traditional — standalone equipment row
-- ============================================================
insert into public.equipment (
  equipment_type, brand, model, series, display_name, description,
  is_popular, sort_order, status,
  body_type, frets, scale_length_inches, bridge_type,
  pickup_configuration, pickup_type, output_level,
  genres, tone_characteristics, search_terms
) values (
  'electric_guitar', 'Epiphone', 'Les Paul Traditional', 'Les Paul',
  'Epiphone Les Paul Traditional',
  'Epiphone Les Paul Traditional with ProBucker humbuckers and classic LP feel.',
  false, 100, 'active',
  'solid_body', 22, 24.75, 'tune_o_matic',
  'hh', array['humbucker']::equipment_pickup_type[], 'medium',
  array['rock','blues','hard_rock','classic_rock']::equipment_genre[],
  array['warm','smooth','punchy','vintage']::equipment_tone_characteristic[],
  array['epiphone', 'les paul', 'traditional', 'lp', 'probuckers']::text[]
)
on conflict (equipment_type, brand, model) do update set
  display_name = excluded.display_name,
  description = excluded.description,
  search_terms = excluded.search_terms,
  updated_at = now();

-- ============================================================
-- 3. Ibanez ART300 — move out of Artcore/semi-hollow family
--    ART300 is a solid-body with active humbuckers, not a semi-hollow.
--    Remove from Artcore tags and ensure correct behavior via ART tag
--    on a more fitting family (RG/S — hot output solid body).
-- ============================================================
update public.guitar_models t
set tags = array_remove(t.tags, 'ibanez art300')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'ibanez'
  and t.model_name = 'Artcore / AR' and t.instrument_type = 'guitar'
  and t.tags @> array['ibanez art300']::text[];

-- Add ART300 to the RG/S family (hot output solid body humbuckers, better match)
update public.guitar_models t
set tags = array_cat(t.tags, array['ibanez art300']::text[])
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'ibanez'
  and t.model_name = 'RG / S' and t.instrument_type = 'guitar'
  and not (t.tags @> array['ibanez art300']::text[]);

-- ============================================================
-- Post-condition: verify all three guitars resolve in search_text
-- ============================================================
do $$
declare
  miss text;
begin
  -- Check AZ47 in AZ family search_text
  select model_name into miss
  from public.guitar_models
  where instrument_type = 'guitar'
    and search_text ilike '%ibanez az47p1qm-bib%'
  limit 1;
  if miss is null then
    raise exception 'POST-CONDITION FAILED: ibanez az47p1qm-bib not in any guitar_models search_text';
  end if;

  -- Check ART300 is in RG/S, not Artcore
  select model_name into miss
  from public.guitar_models
  where instrument_type = 'guitar'
    and model_name = 'RG / S'
    and search_text ilike '%ibanez art300%'
  limit 1;
  if miss is null then
    raise exception 'POST-CONDITION FAILED: ibanez art300 not in RG / S family search_text';
  end if;

  -- Check Epiphone Les Paul Traditional in equipment
  perform 1 from public.equipment
  where equipment_type = 'electric_guitar'
    and brand = 'Epiphone'
    and model = 'Les Paul Traditional'
    and status = 'active'
  limit 1;
  if not found then
    raise exception 'POST-CONDITION FAILED: Epiphone Les Paul Traditional not in equipment catalog';
  end if;
end $$;

commit;
