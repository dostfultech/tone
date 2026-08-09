-- Add the Kadence KAD-AMP-DA15 to the equipment catalog (verified specs) and map it into
-- the MG Series solid-state behavior family (budget SS practice combo with built-in effects
-- — same behavior class as the Yamaha GA15II / Marshall MG15) so it resolves during tone
-- adaptation. Kadence is a popular India budget MI brand. Verified: 15W electric-guitar
-- practice combo with built-in studio-quality effects. Sources: Kadence official product
-- page (kadence.in — "Electric Guitar Amplifier with Effects 15W", model KAD-AMP-DA15).
begin;

insert into public.equipment (
  id, equipment_type, brand, brand_slug, model, series, display_name, description,
  is_popular, search_terms, search_text, status, sort_order,
  amp_type, technology, power_rating_watts, channels, gain_range, genres, tone_characteristics
) values (
  gen_random_uuid(), 'guitar_amp', 'Kadence', 'kadence', 'KAD-AMP-DA15', 'KAD-AMP', 'Kadence KAD-AMP-DA15',
  'Verified: 15-watt solid-state electric guitar practice combo with built-in studio-quality effects (Kadence KAD-AMP-DA15, India). Budget home/practice amp with EQ, headphone out and AUX in.',
  false,
  array['kadence','kad','kad-amp','kad-amp-da15','da15','kadence 15w','practice','solid state'],
  'kadence kad-amp-da15 kad amp da15 kadence 15w practice solid state effects',
  'active', 100,
  'combo', 'solid_state', 15, 2, 'medium'::public.equipment_gain_range,
  array['rock','hard_rock','blues','classic_rock']::public.equipment_genre[],
  array['clean','crunch','bright','dynamic']::public.equipment_tone_characteristic[]
)
on conflict do nothing;

-- Map "Kadence KAD-AMP-DA15" (+ the short spelling) into the MG Series family's tags so the
-- amp resolves via exact-tag / search_text. search_text is trigger-rebuilt from tags — do
-- NOT write it directly on amp_models.
update public.amp_models
set tags = (select array_agg(distinct t) from unnest(tags || array['kadence kad-amp-da15','kadence da15']) as t)
where instrument_type = 'guitar' and model_name = 'MG Series';

-- Post-condition: the amp is present and active, and the family carries the tag.
do $$
declare eq_ok int; fam_ok int;
begin
  select count(*) into eq_ok from public.equipment where display_name = 'Kadence KAD-AMP-DA15' and status = 'active';
  select count(*) into fam_ok from public.amp_models where model_name = 'MG Series' and instrument_type = 'guitar' and tags @> array['kadence kad-amp-da15'];
  if eq_ok < 1 then raise exception 'Kadence KAD-AMP-DA15 equipment row missing'; end if;
  if fam_ok < 1 then raise exception 'Kadence KAD-AMP-DA15 not mapped into MG Series family'; end if;
end $$;

commit;
