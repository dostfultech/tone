-- Map the 5 Fender Acoustasonic models to their electric-voice families (2026-08-08).
-- Acoustasonics were the by-design gap in phase-1 family coverage (acoustic hybrids).
-- Their magnetic "Fender N4" mode is Tele/Strat-voiced, so tag them there so a
-- user who owns one gets a sensible electric adaptation instead of a fallback.
begin;

update public.guitar_models t
set tags = (select array(select distinct e from unnest(coalesce(t.tags, array[]::text[]) || v.phrases) as e))
from (values
  ('fender','Stratocaster', array['fender acoustasonic stratocaster']),
  ('fender','Telecaster', array['fender acoustasonic telecaster','fender acoustasonic player telecaster']),
  ('fender','Jazzmaster / Jaguar', array['fender acoustasonic jazzmaster','fender acoustasonic player jazzmaster'])
) as v(slug, family_name, phrases)
join public.equipment_manufacturers m on m.slug = v.slug
where t.manufacturer_id = m.id and t.model_name = v.family_name
  and t.instrument_type = 'guitar' and t.is_active = true;

do $$
declare miss int;
begin
  select count(*) into miss from (values
    ('Fender Acoustasonic Stratocaster'),('Fender Acoustasonic Telecaster'),
    ('Fender Acoustasonic Jazzmaster'),('Fender Acoustasonic Player Jazzmaster'),
    ('Fender Acoustasonic Player Telecaster')
  ) as n(dn)
  where not exists (
    select 1 from public.guitar_models g
    where g.instrument_type='guitar' and g.is_active=true and g.search_text ilike '%'||n.dn||'%'
  );
  if miss > 0 then
    raise exception 'POST-CONDITION FAILED: % Acoustasonic(s) still unresolved', miss;
  end if;
end $$;

commit;
