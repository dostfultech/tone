insert into public.equipment (
  equipment_type, brand, model, series, is_popular, description,
  body_type, frets, scale_length_inches, bridge_type,
  pickup_configuration, pickup_type, output_level,
  genres, tone_characteristics
) values (
  'electric_guitar',
  'Ibanez',
  'ART300',
  'ART',
  true,
  'ART series with set neck, mahogany body, and IBZ-LZ active humbuckers for aggressive modern tone.',
  'solid_body',
  22,
  24.75,
  'tune_o_matic',
  'hh',
  array['active_humbucker']::public.equipment_pickup_type[],
  'high',
  array['rock', 'metal', 'hard_rock']::public.equipment_genre[],
  array['aggressive', 'tight', 'modern', 'high_gain']::public.equipment_tone_characteristic[]
)
on conflict (equipment_type, brand, model) do nothing;
