-- Pedal + Multi-FX catalog cleanup (2026-08-06).
-- 1. Remove surviving synthetic placeholder pedals. The 20260718123000 cleanup
--    regex used [A-Z]{3}, but eq-type placeholders abbreviate to 2 letters
--    ("Tone EQ 007"), so ~110 fake rows survived and are live in the picker.
-- 2. Add metadata to multifx_models and stamp catalog provenance.
-- 3. Insert Fractal Axe-Edit — dropped by 20260730110000 because its seed
--    joined on brand name 'Fractal' after the brand was renamed 'Fractal Audio'.
begin;

-- ============================================================
-- 1. Delete synthetic placeholder pedals (2-or-3-letter type codes)
-- ============================================================
delete from public.pedal_models
where model_name ~ '^(Drive|Color|Pulse|Shift|Phase|Signal|Echo|Tone) [A-Z]{2,3} [0-9]{3}$'
  and metadata = '{}'::jsonb;

-- ============================================================
-- 2. Multi-FX metadata column + catalog provenance
-- ============================================================
alter table public.multifx_models
  add column if not exists metadata jsonb not null default '{}'::jsonb;

update public.multifx_models
set metadata = metadata || jsonb_build_object(
  'catalog_verified', true,
  'source', 'multifx_catalog_v1',
  'version', 1
)
where coalesce(metadata->>'source', '') <> 'multifx_catalog_v1';

-- ============================================================
-- 3. Fractal Axe-Edit (software amp sim, joined by slug this time)
-- ============================================================
insert into public.multifx_models (brand_id, name, slug, category, tags, is_active, metadata)
select
  b.id,
  'Axe-Edit',
  public.slugify_gear('Fractal Audio Axe-Edit'),
  'software amp sim',
  array['axe-edit','fractal','axe fx editor','desktop','direct']::text[],
  true,
  jsonb_build_object('catalog_verified', true, 'source', 'multifx_catalog_v1', 'version', 1)
from public.multifx_brands b
where b.slug = 'fractal'
on conflict (brand_id, slug) do update set
  category = excluded.category,
  tags = excluded.tags,
  is_active = true,
  metadata = excluded.metadata,
  updated_at = now();

-- ============================================================
-- Post-conditions
-- ============================================================
do $$
declare
  leftover int;
  missing int;
begin
  select count(*) into leftover
  from public.pedal_models
  where model_name ~ '^(Drive|Color|Pulse|Shift|Phase|Signal|Echo|Tone) [A-Z]{2,3} [0-9]{3}$';
  if leftover > 0 then
    raise exception 'POST-CONDITION FAILED: % placeholder pedal rows remain', leftover;
  end if;

  select count(*) into missing
  from public.multifx_models
  where name = 'Axe-Edit' and is_active = true;
  if missing = 0 then
    raise exception 'POST-CONDITION FAILED: Fractal Axe-Edit not in multifx catalog';
  end if;

  select count(*) into missing
  from public.multifx_models
  where is_active = true and coalesce(metadata->>'source', '') <> 'multifx_catalog_v1';
  if missing > 0 then
    raise exception 'POST-CONDITION FAILED: % multifx rows lack catalog provenance', missing;
  end if;
end $$;

commit;
