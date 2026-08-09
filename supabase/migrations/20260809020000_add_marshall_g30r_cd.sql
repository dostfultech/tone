-- Add Marshall G30R CD to the equipment catalog (verified specs) and map it to the
-- MG Series solid-state behavior family so it resolves during tone adaptation.
-- Specs verified: 30W solid-state 1x10 combo, 2 channels (clean + overdrive), spring reverb,
-- CD input (Marshall G-series). Sources: Reverb, Equipboard, Marshall G30RCD manual.
begin;

insert into public.equipment (
  id, equipment_type, brand, brand_slug, model, series, display_name, description,
  is_popular, search_terms, search_text, status, sort_order,
  amp_type, technology, power_rating_watts, channels, gain_range, genres, tone_characteristics
) values (
  gen_random_uuid(), 'guitar_amp', 'Marshall', 'marshall', 'G30R CD', 'G', 'Marshall G30R CD',
  'Verified: 30-watt solid-state 1x10 combo with clean + overdrive channels and spring reverb (Marshall G-series). Budget practice / small-venue amp with CD input.',
  false,
  array['marshall','g','g30','g30r','g30rcd','g30r cd','reverb','solid state','practice'],
  'marshall g30r cd g marshall g30r cd g30 g30r g30rcd reverb solid state practice',
  'active', 100,
  'combo', 'solid_state', 30, 2, 'medium'::public.equipment_gain_range,
  array['rock','hard_rock','classic_rock','punk']::public.equipment_genre[],
  array['clean','crunch','bright','mid_focused']::public.equipment_tone_characteristic[]
)
on conflict do nothing;

-- Map "Marshall G30R CD" (+ the no-space spelling) into the MG Series family's tags so the
-- amp resolves via exact-tag / search_text (search_text is trigger-rebuilt from tags — do NOT
-- write it directly on amp_models).
update public.amp_models
set tags = (select array_agg(distinct t) from unnest(tags || array['marshall g30r cd','marshall g30rcd']) as t)
where instrument_type = 'guitar' and model_name = 'MG Series';

-- Post-condition: the amp is present and active, and the family carries the tag.
do $$
declare eq_ok int; fam_ok int;
begin
  select count(*) into eq_ok from public.equipment where display_name = 'Marshall G30R CD' and status = 'active';
  select count(*) into fam_ok from public.amp_models where model_name = 'MG Series' and instrument_type = 'guitar' and tags @> array['marshall g30r cd'];
  if eq_ok < 1 then raise exception 'G30R CD equipment row missing'; end if;
  if fam_ok < 1 then raise exception 'G30R CD not mapped into MG Series family'; end if;
end $$;

commit;
