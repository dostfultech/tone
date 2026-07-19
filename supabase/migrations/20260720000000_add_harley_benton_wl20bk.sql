begin;

insert into public.equipment (
  equipment_type,
  brand,
  model,
  series,
  display_name,
  description,
  is_popular,
  sort_order,
  status,
  genres,
  tone_characteristics,
  search_terms
)
values (
  'electric_guitar',
  'Harley Benton',
  'WL-20BK Rock Series',
  'Rock Series',
  'Harley Benton WL-20BK Rock Series',
  'Affordable double-cutaway rock guitar with dual humbuckers and a slim neck for fast playing.',
  false,
  10,
  'active',
  array['rock', 'hard_rock', 'metal']::public.equipment_genre[],
  array['warm', 'punchy', 'aggressive']::public.equipment_tone_characteristic[],
  array['harley benton', 'wl-20bk', 'rock series', 'hb', 'wl20']::text[]
),
(
  'electric_guitar',
  'Harley Benton',
  'SC-450 CS',
  'SC',
  'Harley Benton SC-450 CS',
  'Single-cutaway guitar with classic humbucker voicing and cherry sunburst finish.',
  false,
  11,
  'active',
  array['rock', 'blues', 'hard_rock']::public.equipment_genre[],
  array['warm', 'balanced', 'smooth']::public.equipment_tone_characteristic[],
  array['harley benton', 'sc-450', 'sc450', 'cherry sunburst', 'les paul style']::text[]
)
on conflict (equipment_type, brand, model)
do update set
  display_name = excluded.display_name,
  description = excluded.description,
  genres = excluded.genres,
  tone_characteristics = excluded.tone_characteristics,
  search_terms = excluded.search_terms,
  updated_at = now();

commit;
