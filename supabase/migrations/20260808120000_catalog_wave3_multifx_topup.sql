-- Catalog Wave 3a: multi-FX top-up (2026-08-06).
-- Adds recent/missing budget + flagship modelers users own. Multi-FX has no
-- behavior family (used via goingDirect / generic mapping), so this is a
-- catalog-presence insert only. Dedup-safe via on conflict.
begin;

insert into public.multifx_brands (name, slug, search_text)
values
  ('Harley Benton', 'harley-benton', 'harley benton dnafx budget modeler multi fx'),
  ('Flamma', 'flamma', 'flamma budget multi fx modeler'),
  ('Fender', 'fender-mfx', 'fender tone master pro modeler')
on conflict (slug) do update set name = excluded.name, search_text = excluded.search_text, is_active = true, updated_at = now();

with seed(brand_name, model_name, category, tags) as (
  values
    ('Harley Benton', 'DNAfx GiT', 'floor modeler', array['harley benton','dnafx','dnafx git','budget modeler','amp sim','direct']),
    ('Harley Benton', 'DNAfx GiT Core', 'compact modeler', array['harley benton','dnafx core','compact modeler','amp sim','direct']),
    ('Line 6', 'HX Stomp XL', 'compact modeler', array['line 6','hx stomp xl','helix','amp sim','direct']),
    ('Line 6', 'POD Express Guitar', 'compact modeler', array['line 6','pod express','budget modeler','amp sim','direct']),
    ('IK Multimedia', 'TONEX Pedal', 'amp modeler', array['ik multimedia','tonex pedal','ai capture','amp sim','direct']),
    ('IK Multimedia', 'TONEX One', 'compact modeler', array['ik multimedia','tonex one','ai capture','amp sim','direct']),
    ('Fender', 'Tone Master Pro', 'floor modeler', array['fender','tone master pro','modeler','amp sim','direct']),
    ('Mooer', 'GE1000', 'floor modeler', array['mooer','ge1000','touchscreen modeler','amp sim','direct']),
    ('Mooer', 'GE1000 Li', 'floor modeler', array['mooer','ge1000 li','battery modeler','amp sim','direct']),
    ('Mooer', 'Prime P1', 'compact modeler', array['mooer','prime p1','pocket modeler','amp sim','direct']),
    ('Mooer', 'GE150', 'floor modeler', array['mooer','ge150','budget modeler','amp sim','direct']),
    ('Mooer', 'GE100', 'floor modeler', array['mooer','ge100','budget modeler','amp sim','direct']),
    ('NUX', 'MG-400', 'floor modeler', array['nux','mg-400','dual dsp modeler','amp sim','direct']),
    ('NUX', 'Trident', 'floor modeler', array['nux','trident','flagship modeler','amp sim','direct']),
    ('Flamma', 'FX100', 'floor modeler', array['flamma','fx100','budget modeler','amp sim','direct']),
    ('Flamma', 'FX200', 'floor modeler', array['flamma','fx200','budget modeler','amp sim','direct']),
    ('Flamma', 'Preamp X', 'compact modeler', array['flamma','preamp x','ir loader','amp sim','direct']),
    ('Boss', 'GX-10', 'floor modeler', array['boss','gx-10','compact gx modeler','amp sim','direct']),
    ('Zoom', 'G6', 'floor modeler', array['zoom','g6','touchscreen modeler','amp sim','direct']),
    ('Zoom', 'G11', 'floor modeler', array['zoom','g11','flagship modeler','amp sim','direct']),
    ('HeadRush', 'Flex Prime', 'floor modeler', array['headrush','flex prime','modeler','amp sim','direct']),
    ('HeadRush', 'MX5', 'compact modeler', array['headrush','mx5','compact modeler','amp sim','direct'])
),
brand_lookup as (
  select id as brand_id, name as brand_name from public.multifx_brands
)
insert into public.multifx_models (brand_id, name, slug, category, tags, is_active, metadata)
select lookup.brand_id, seed.model_name,
       public.slugify_gear(concat(seed.brand_name, ' ', seed.model_name)),
       seed.category, seed.tags, true,
       jsonb_build_object('catalog_verified', true, 'source', 'multifx_catalog_v2', 'version', 2)
from seed join brand_lookup lookup on lookup.brand_name = seed.brand_name
on conflict (brand_id, slug) do update set
  category = excluded.category, tags = excluded.tags, is_active = true,
  metadata = excluded.metadata, updated_at = now();

do $$
declare n int;
begin
  select count(*) into n from public.multifx_models
  where is_active = true and metadata->>'source' = 'multifx_catalog_v2';
  if n < 18 then
    raise exception 'POST-CONDITION FAILED: expected >=18 new multifx rows, got %', n;
  end if;
end $$;

commit;
