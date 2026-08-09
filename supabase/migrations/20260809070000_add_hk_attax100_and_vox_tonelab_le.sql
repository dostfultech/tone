-- Two requested gear items, both verified from manufacturer/retailer specs:
--   1) Hughes & Kettner Attax 100 -> equipment (guitar_amp), mapped into the Bandit 112
--      solid-state behavior family (100W SS 4-channel gigging combo — same class).
--   2) Vox ToneLab LE -> multifx_models (Valvetronix floor modeler); creates the Vox
--      multifx brand if it does not exist yet.
-- Sources: Gear4music + Reverb + H&K owner's manual (Attax 100 = 100W solid-state 1x12,
-- 4 channels Clean/Crunch/Lead/Ultra, onboard FX, CD in, phones). Vox + zZounds (ToneLab
-- LE = Valvetronix floor modeler, 16 amps/11 cabs, 12AX7 tube, expression pedal, 120 memories).
begin;

-- 1) Hughes & Kettner Attax 100 -------------------------------------------------
insert into public.equipment (
  id, equipment_type, brand, brand_slug, model, series, display_name, description,
  is_popular, search_terms, search_text, status, sort_order,
  amp_type, technology, power_rating_watts, channels, gain_range, genres, tone_characteristics
) values (
  gen_random_uuid(), 'guitar_amp', 'Hughes & Kettner', 'hughes-kettner', 'Attax 100', 'Attax', 'Hughes & Kettner Attax 100',
  'Verified: 100-watt solid-state 1x12 combo with 4 footswitchable channels (Clean, Crunch, Lead, Ultra) and onboard effects (chorus/flanger/tremolo/delay/reverb) assignable per channel, plus CD input and headphone out. 1990s H&K gigging combo.',
  false,
  array['hughes & kettner','hughes kettner','h&k','hk','attax','attax 100'],
  'hughes & kettner attax 100 h&k hk attax attax 100 solid state combo',
  'active', 100,
  'combo', 'solid_state', 100, 4, 'high'::public.equipment_gain_range,
  array['rock','hard_rock','blues']::public.equipment_genre[],
  array['clean','crunch','dynamic']::public.equipment_tone_characteristic[]
)
on conflict do nothing;

-- Map the Attax into the Bandit 112 solid-state family (tags drive resolution;
-- search_text is trigger-rebuilt from tags — do NOT write it directly on amp_models).
-- The exact lowercase display name is included so the exact-tag match resolves it.
update public.amp_models
set tags = (
  select array_agg(distinct t)
  from unnest(tags || array['hughes & kettner attax 100','hughes kettner attax 100','h&k attax 100','attax 100']) as t
)
where instrument_type = 'guitar' and model_name = 'Bandit 112';

-- 2) Vox ToneLab LE (multi-fx) --------------------------------------------------
insert into public.multifx_brands (id, name, slug, search_text, is_active)
select gen_random_uuid(), 'Vox', 'vox', 'vox', true
where not exists (select 1 from public.multifx_brands where slug = 'vox');

insert into public.multifx_models (id, brand_id, name, slug, category, tags, search_text, metadata, is_active)
select
  gen_random_uuid(), b.id, 'ToneLab LE', 'vox-tonelab-le', 'floorboard',
  array['tonelab le','vox tonelab le','vox tonelab','valvetronix','amp modeler','expression pedal','floorboard'],
  'vox tonelab le floorboard tonelab le vox tonelab valvetronix amp modeler expression pedal',
  '{"source":"multifx_catalog_v1","version":1,"catalog_verified":true}'::jsonb,
  true
from public.multifx_brands b
where b.slug = 'vox'
  and not exists (select 1 from public.multifx_models where slug = 'vox-tonelab-le');

-- Post-conditions
do $$
declare amp_ok int; fam_ok int; fx_ok int;
begin
  select count(*) into amp_ok from public.equipment
    where display_name = 'Hughes & Kettner Attax 100' and status = 'active';
  select count(*) into fam_ok from public.amp_models
    where model_name = 'Bandit 112' and instrument_type = 'guitar' and tags @> array['hughes & kettner attax 100'];
  select count(*) into fx_ok from public.multifx_models where slug = 'vox-tonelab-le' and is_active;
  if amp_ok < 1 then raise exception 'Attax 100 equipment row missing'; end if;
  if fam_ok < 1 then raise exception 'Attax 100 not mapped into Bandit 112 family'; end if;
  if fx_ok  < 1 then raise exception 'Vox ToneLab LE multifx row missing'; end if;
end $$;

commit;
