-- Add the Yamaha GA15II to the equipment catalog (verified specs) and map it into the
-- MG Series solid-state behavior family (budget SS practice combo, clean + crunch — the
-- same behavior class as the Marshall MG15 already in that family) so it resolves during
-- tone adaptation. Specs verified: 15W (19W peak) solid-state 1x8 combo, 2 channels
-- (clean + distortion), 3-band EQ, headphone out + Aux in. Sources: Yamaha official specs
-- (usa.yamaha.com / europe.yamaha.com GA15II), Reverb listings.
begin;

insert into public.equipment (
  id, equipment_type, brand, brand_slug, model, series, display_name, description,
  is_popular, search_terms, search_text, status, sort_order,
  amp_type, technology, power_rating_watts, channels, gain_range, genres, tone_characteristics
) values (
  gen_random_uuid(), 'guitar_amp', 'Yamaha', 'yamaha', 'GA15II', 'GA', 'Yamaha GA15II',
  'Verified: 15-watt (19W peak) solid-state practice combo with 2 channels (clean + distortion), 3-band EQ, headphone out and Aux in. Compact budget home/practice amp.',
  false,
  array['yamaha','ga','ga15','ga15ii','ga-15','ga 15 ii','practice','solid state'],
  'yamaha ga15ii ga ga15 ga-15 ga 15 ii practice solid state',
  'active', 100,
  'combo', 'solid_state', 15, 2, 'medium'::public.equipment_gain_range,
  array['rock','hard_rock','blues','classic_rock']::public.equipment_genre[],
  array['clean','crunch','bright','dynamic']::public.equipment_tone_characteristic[]
)
on conflict do nothing;

-- Map "Yamaha GA15II" (+ the no-space spelling) into the MG Series family's tags so the
-- amp resolves via exact-tag / search_text. search_text is trigger-rebuilt from tags — do
-- NOT write it directly on amp_models.
update public.amp_models
set tags = (select array_agg(distinct t) from unnest(tags || array['yamaha ga15ii','yamaha ga15 ii']) as t)
where instrument_type = 'guitar' and model_name = 'MG Series';

-- Post-condition: the amp is present and active, and the family carries the tag.
do $$
declare eq_ok int; fam_ok int;
begin
  select count(*) into eq_ok from public.equipment where display_name = 'Yamaha GA15II' and status = 'active';
  select count(*) into fam_ok from public.amp_models where model_name = 'MG Series' and instrument_type = 'guitar' and tags @> array['yamaha ga15ii'];
  if eq_ok < 1 then raise exception 'GA15II equipment row missing'; end if;
  if fam_ok < 1 then raise exception 'GA15II not mapped into MG Series family'; end if;
end $$;

commit;
