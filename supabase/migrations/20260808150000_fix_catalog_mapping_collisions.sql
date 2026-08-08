-- Fix the Glarry GST prefix collision found in the Wave 1 mapping audit (2026-08-08).
-- "Glarry GST" (SSS Strat) resolved to the RG/S family because its tag "glarry gst"
-- is a substring of "glarry gst-e" (the HH super-Strat variant, tagged to RG/S) and
-- "RG / S" sorts before "Stratocaster / Telecaster". Move the GST-E tag into the
-- Strat family (a Strat-shaped HH, so tonally fine) — now both GST and GST-E resolve
-- to the Strat family and the base-model lookup is unambiguous.
-- (The Harley Benton base-vs-variant substring collisions are addressed by the
--  gear-repository lookup improvement, not data — see that code change.)
begin;

update public.guitar_models t
set tags = array_remove(coalesce(t.tags, array[]::text[]), 'glarry gst-e')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'ibanez'
  and t.model_name = 'RG / S' and t.instrument_type = 'guitar';

update public.guitar_models t
set tags = (select array(select distinct e from unnest(coalesce(t.tags, array[]::text[]) || array['glarry gst-e']) as e))
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'squier'
  and t.model_name = 'Stratocaster / Telecaster' and t.instrument_type = 'guitar';

do $$
declare fam text;
begin
  select model_name into fam from public.guitar_models
  where instrument_type='guitar' and is_active=true and search_text ilike '%glarry gst%'
  order by model_name asc limit 1;
  if fam is distinct from 'Stratocaster / Telecaster' then
    raise exception 'POST-CONDITION FAILED: Glarry GST resolves to % (expected Stratocaster / Telecaster)', fam;
  end if;
end $$;

commit;
