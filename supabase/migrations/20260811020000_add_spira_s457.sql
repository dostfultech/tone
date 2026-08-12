-- Add the Spira S-457 (7-string extended-range metal guitar) to the equipment catalog and map
-- it into the "RG / S" super-strat behavior family (Ibanez RG/S-style metal super-strats,
-- which already includes 7-strings like the RG7421). Verified specs: roasted poplar body,
-- roasted maple neck/fretboard, 26.5" scale, 24 jumbo frets, fixed bridge, locking tuners, and
-- Spira Villain ceramic humbuckers (HH, ~12k output). Built for modern rock/metal.
-- Sources: Spira Guitars official (450 Series page), Reverb listings.
begin;

insert into public.equipment (
  id, equipment_type, brand, brand_slug, model, series, display_name, description,
  is_popular, search_terms, search_text, status, sort_order,
  body_type, frets, scale_length_inches, bridge_type, pickup_configuration, pickup_type, output_level, genres, tone_characteristics
) values (
  gen_random_uuid(), 'electric_guitar', 'Spira', 'spira', 'S-457', '450 Series', 'Spira S-457',
  'Verified: 7-string extended-range electric guitar with a roasted poplar body, roasted maple neck and fretboard, 26.5" scale, 24 jumbo frets, fixed bridge, locking tuners, and Spira Villain ceramic humbuckers (HH, ~12k output). Built for modern rock and metal.',
  false,
  array['spira','s457','s-457','spira s457','spira s-457','7 string','seven string','baritone','metal'],
  'spira s-457 s457 spira s457 7 string seven string baritone metal humbucker',
  'active', 100,
  'solid_body', 24, 26.5, 'fixed', 'hh',
  array['passive_humbucker']::public.equipment_pickup_type[],
  'high',
  array['metal','hard_rock','rock']::public.equipment_genre[],
  array['aggressive','punchy','articulate']::public.equipment_tone_characteristic[]
)
on conflict do nothing;

-- Map "Spira S-457" (+ the no-hyphen spelling) into the RG / S family tags so it resolves
-- during adaptation. search_text is trigger-rebuilt from tags — only tags are written here.
update public.guitar_models
set tags = (select array_agg(distinct t) from unnest(tags || array['spira s-457','spira s457']) as t)
where instrument_type = 'guitar' and model_name = 'RG / S';

do $$
declare eq_ok int; fam_ok int;
begin
  select count(*) into eq_ok from public.equipment where display_name = 'Spira S-457' and status = 'active';
  select count(*) into fam_ok from public.guitar_models where model_name = 'RG / S' and instrument_type = 'guitar' and tags @> array['spira s-457'];
  if eq_ok < 1 then raise exception 'Spira S-457 equipment row missing'; end if;
  if fam_ok < 1 then raise exception 'Spira S-457 not mapped into RG / S family'; end if;
end $$;

commit;
