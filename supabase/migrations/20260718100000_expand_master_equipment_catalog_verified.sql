begin;

-- ====================================================
-- Verified expansion for the master equipment catalog
-- Sources:
-- - Existing manufacturer-backed legacy gear seeds in earlier migrations
-- - Trusted retailer catalog pages reviewed during this expansion pass
-- This migration only inserts new rows into public.equipment.
-- ====================================================

with seed(equipment_type, brand, model, series, is_popular, description) as (
  values
  -- Electric Guitars
  ('electric_guitar', 'Fender', 'Player II Telecaster', 'Player II', false, 'Production electric guitar model verified from trusted retailer listings.'),
  ('electric_guitar', 'Fender', 'Player II Telecaster HH', 'Player II', false, 'Production electric guitar model verified from trusted retailer listings.'),
  ('electric_guitar', 'Fender', 'Player II Stratocaster', 'Player II', false, 'Production electric guitar model verified from trusted retailer listings.'),
  ('electric_guitar', 'Fender', 'Standard Stratocaster', 'Standard', false, 'Production electric guitar model verified from trusted retailer listings.'),
  ('electric_guitar', 'Fender', 'Standard Stratocaster HSS', 'Standard', false, 'Production electric guitar model verified from trusted retailer listings.'),
  ('electric_guitar', 'Fender', '75th Anniversary Player II Telecaster', '75th Anniversary', false, 'Production electric guitar model verified from trusted retailer listings.'),
  ('electric_guitar', 'Fender', 'American Professional Classic Telecaster', 'American Professional Classic', false, 'Production electric guitar model verified from trusted retailer listings.'),
  ('electric_guitar', 'Fender', '75th Anniversary Vintera Road Worn 1951 Telecaster', '75th Anniversary Vintera Road Worn', false, 'Production electric guitar model verified from trusted retailer listings.'),
  ('electric_guitar', 'Fender', 'Limited Vintera III Early ''60s Custom Telecaster', 'Vintera III', false, 'Production electric guitar model verified from trusted retailer listings.'),
  ('electric_guitar', 'Fender', 'Vintera II Jaguar', 'Vintera II', false, 'Production electric guitar model verified from trusted retailer listings.'),
  ('electric_guitar', 'Fender', 'Mustang 90', 'Mustang', false, 'Production electric guitar model verified from trusted retailer listings.'),
  ('electric_guitar', 'Gibson', 'Les Paul Standard', 'Les Paul', false, 'Production electric guitar model verified from trusted retailer listings.'),
  ('electric_guitar', 'Gibson', 'Les Paul Custom', 'Les Paul', false, 'Production electric guitar model verified from trusted retailer listings.'),
  ('electric_guitar', 'PRS', 'Custom 24', 'Core', false, 'Production electric guitar model verified from trusted retailer listings.'),
  ('electric_guitar', 'PRS', 'McCarty 594', 'McCarty', false, 'Production electric guitar model verified from trusted retailer listings.'),
  ('electric_guitar', 'Gretsch', 'G5420T', 'Electromatic', false, 'Production electric guitar model verified from trusted retailer listings.'),
  ('electric_guitar', 'Gretsch', 'G5622T', 'Electromatic', false, 'Production electric guitar model verified from trusted retailer listings.'),
  ('electric_guitar', 'Jackson', 'Soloist SL2', 'Soloist', false, 'Production electric guitar model verified from trusted retailer listings.'),
  ('electric_guitar', 'Jackson', 'Dinky', 'Dinky', false, 'Production electric guitar model verified from trusted retailer listings.'),
  ('electric_guitar', 'Charvel', 'Pro-Mod San Dimas Style 1 HH', 'Pro-Mod', false, 'Production electric guitar model verified from trusted retailer listings.'),
  ('electric_guitar', 'Music Man', 'JP6', 'JP', false, 'Production electric guitar model verified from trusted retailer listings.'),
  ('electric_guitar', 'Suhr', 'Modern Plus', 'Modern', false, 'Production electric guitar model verified from trusted retailer listings.'),
  ('electric_guitar', 'Yamaha', 'Revstar Standard RSS20', 'Revstar Standard', false, 'Production electric guitar model verified from trusted retailer listings.'),
  ('electric_guitar', 'Yamaha', 'Pacifica 012', 'Pacifica', false, 'Production electric guitar model verified from trusted retailer listings.'),
  ('electric_guitar', 'Harley Benton', 'SC-450 CS', 'SC', false, 'Production electric guitar model verified from trusted retailer listings.'),
  ('electric_guitar', 'ESP LTD', 'MH-10', 'MH', false, 'Production electric guitar model verified from trusted retailer listings.'),
  ('electric_guitar', 'ESP LTD', 'EC-256', 'EC', false, 'Production electric guitar model verified from trusted retailer listings.'),
  ('electric_guitar', 'Schecter', 'Demon-6', 'Demon', false, 'Production electric guitar model verified from trusted retailer listings.'),
  ('electric_guitar', 'Rickenbacker', '330', '300 Series', false, 'Production electric guitar model verified from trusted retailer listings.'),
  ('electric_guitar', 'Rickenbacker', '360', '300 Series', false, 'Production electric guitar model verified from trusted retailer listings.'),
  ('electric_guitar', 'Epiphone', 'ES-339 P-90 PRO', 'ES', false, 'Production electric guitar model verified from trusted retailer listings.'),
  ('electric_guitar', 'Ibanez', 'GIO GRX70QA', 'Gio', false, 'Production electric guitar model verified from trusted retailer listings.'),

  -- Bass Guitars
  ('bass_guitar', 'Music Man', 'StingRay', 'StingRay', false, 'Production bass guitar model verified from trusted retailer listings.'),
  ('bass_guitar', 'Rickenbacker', '4003', '4000 Series', false, 'Production bass guitar model verified from trusted retailer listings.'),
  ('bass_guitar', 'Ibanez', 'SRF705', 'SRF', false, 'Production bass guitar model verified from trusted retailer listings.'),
  ('bass_guitar', 'Ibanez', 'SR305EDX', 'SR', false, 'Production bass guitar model verified from trusted retailer listings.'),
  ('bass_guitar', 'Ibanez', 'Premium SR2605', 'Premium', false, 'Production bass guitar model verified from trusted retailer listings.'),
  ('bass_guitar', 'Ibanez', 'Gio GSR200PC', 'Gio', false, 'Production bass guitar model verified from trusted retailer listings.'),
  ('bass_guitar', 'Ibanez', 'Standard SR305E', 'Standard', false, 'Production bass guitar model verified from trusted retailer listings.'),
  ('bass_guitar', 'Ibanez', 'miKro GSRM20', 'miKro', false, 'Production bass guitar model verified from trusted retailer listings.'),
  ('bass_guitar', 'Ibanez', 'SR405EPBDX', 'SR', false, 'Production bass guitar model verified from trusted retailer listings.'),
  ('bass_guitar', 'Ibanez', 'Gio GSR205B', 'Gio', false, 'Production bass guitar model verified from trusted retailer listings.'),
  ('bass_guitar', 'Ibanez', 'BTB805MS', 'BTB', false, 'Production bass guitar model verified from trusted retailer listings.'),
  ('bass_guitar', 'Ibanez', 'Mode MDM1006', 'Mode', false, 'Production bass guitar model verified from trusted retailer listings.'),
  ('bass_guitar', 'Ibanez', 'Iron Label SRMS625EX', 'Iron Label', false, 'Production bass guitar model verified from trusted retailer listings.'),
  ('bass_guitar', 'Ibanez', 'Standard SR500A', 'Standard', false, 'Production bass guitar model verified from trusted retailer listings.'),
  ('bass_guitar', 'Ibanez', 'BTB806MS', 'BTB', false, 'Production bass guitar model verified from trusted retailer listings.'),
  ('bass_guitar', 'Ibanez', 'Premium SR1355B', 'Premium', false, 'Production bass guitar model verified from trusted retailer listings.'),
  ('bass_guitar', 'Ibanez', 'Bass Workshop EHB5MSBSP', 'Bass Workshop', false, 'Production bass guitar model verified from trusted retailer listings.'),

  -- Guitar Amps
  ('guitar_amp', 'Marshall', 'SV20H', 'Studio Vintage', false, 'Production guitar amplifier model verified from trusted retailer listings.'),
  ('guitar_amp', 'Marshall', '2525H', 'Studio Jubilee', false, 'Production guitar amplifier model verified from trusted retailer listings.'),
  ('guitar_amp', 'Marshall', 'MG30GFX', 'MG', false, 'Production guitar amplifier model verified from trusted retailer listings.'),
  ('guitar_amp', 'Marshall', 'DSL1HR', 'DSL', false, 'Production guitar amplifier model verified from trusted retailer listings.'),
  ('guitar_amp', 'Marshall', 'DSL20HR', 'DSL', false, 'Production guitar amplifier model verified from trusted retailer listings.'),
  ('guitar_amp', 'Marshall', 'SC20H', 'Studio Classic', false, 'Production guitar amplifier model verified from trusted retailer listings.'),
  ('guitar_amp', 'Marshall', 'DSL5CR', 'DSL', false, 'Production guitar amplifier model verified from trusted retailer listings.'),
  ('guitar_amp', 'Marshall', 'JVM410C', 'JVM', false, 'Production guitar amplifier model verified from trusted retailer listings.'),
  ('guitar_amp', 'Marshall', 'DSL20CR', 'DSL', false, 'Production guitar amplifier model verified from trusted retailer listings.'),
  ('guitar_amp', 'Marshall', 'JTM45 2245', 'JTM45', false, 'Production guitar amplifier model verified from trusted retailer listings.'),
  ('guitar_amp', 'Marshall', 'MG10G', 'MG', false, 'Production guitar amplifier model verified from trusted retailer listings.'),
  ('guitar_amp', 'Marshall', '2525C', 'Studio Jubilee', false, 'Production guitar amplifier model verified from trusted retailer listings.'),
  ('guitar_amp', 'Marshall', 'ORI20C', 'Origin', false, 'Production guitar amplifier model verified from trusted retailer listings.'),
  ('guitar_amp', 'Marshall', 'SV20C', 'Studio Vintage', false, 'Production guitar amplifier model verified from trusted retailer listings.'),
  ('guitar_amp', 'Marshall', 'SC20C', 'Studio Classic', false, 'Production guitar amplifier model verified from trusted retailer listings.'),
  ('guitar_amp', 'Marshall', 'Code 25', 'Code', false, 'Production guitar amplifier model verified from trusted retailer listings.'),
  ('guitar_amp', 'Marshall', 'JCM900 4100', 'JCM900', false, 'Production guitar amplifier model verified from trusted retailer listings.'),
  ('guitar_amp', 'Marshall', 'JVM205C', 'JVM', false, 'Production guitar amplifier model verified from trusted retailer listings.'),
  ('guitar_amp', 'Marshall', 'JVM205H', 'JVM', false, 'Production guitar amplifier model verified from trusted retailer listings.'),
  ('guitar_amp', 'Marshall', '1962 Bluesbreaker', 'Bluesbreaker', false, 'Production guitar amplifier model verified from trusted retailer listings.'),
  ('guitar_amp', 'Marshall', '1959 Handwired', 'Handwired', false, 'Production guitar amplifier model verified from trusted retailer listings.'),
  ('guitar_amp', 'Marshall', 'MG15GFX', 'MG', false, 'Production guitar amplifier model verified from trusted retailer listings.'),
  ('guitar_amp', 'Marshall', 'JCM800 2203X', 'JCM800', false, 'Production guitar amplifier model verified from trusted retailer listings.'),
  ('guitar_amp', 'Peavey', '6505+ Head', '6505', false, 'Production guitar amplifier model verified from trusted retailer listings.'),
  ('guitar_amp', 'Blackstar', 'St. James 50 6L6', 'St. James', false, 'Production guitar amplifier model verified from trusted retailer listings.'),
  ('guitar_amp', 'Friedman', 'BE-100 Deluxe', 'BE', false, 'Production guitar amplifier model verified from trusted retailer listings.'),
  ('guitar_amp', 'Bogner', 'Ecstasy 101B', 'Ecstasy', false, 'Production guitar amplifier model verified from trusted retailer listings.'),
  ('guitar_amp', 'Matchless', 'DC-30', 'DC', false, 'Production guitar amplifier model verified from trusted retailer listings.'),
  ('guitar_amp', 'Hughes & Kettner', 'TriAmp Mark 3', 'TriAmp', false, 'Production guitar amplifier model verified from trusted retailer listings.'),
  ('guitar_amp', 'Vox', 'Mini GO 50', 'Mini GO', false, 'Production guitar amplifier model verified from trusted retailer listings.'),
  ('guitar_amp', 'Joyo', 'DC-15', 'DC', false, 'Production guitar amplifier model verified from trusted retailer listings.'),
  ('guitar_amp', 'Orange', 'Crush 12', 'Crush', false, 'Production guitar amplifier model verified from trusted retailer listings.'),
  ('guitar_amp', 'Blackstar', 'ID:Core V4', 'ID:Core', false, 'Production guitar amplifier model verified from trusted retailer listings.'),
  ('guitar_amp', 'Vox', 'VT40X', 'VT', false, 'Production guitar amplifier model verified from trusted retailer listings.'),
  ('guitar_amp', 'Fender', 'Mustang LT50', 'Mustang LT', false, 'Production guitar amplifier model verified from trusted retailer listings.'),
  ('guitar_amp', 'NUX', 'Mighty 60', 'Mighty', false, 'Production guitar amplifier model verified from trusted retailer listings.'),
  ('guitar_amp', 'Fender', 'Champion 100', 'Champion', false, 'Production guitar amplifier model verified from trusted retailer listings.'),
  ('guitar_amp', 'Positive Grid', 'Spark', 'Spark', false, 'Production guitar amplifier model verified from trusted retailer listings.'),

  -- Bass Amps
  ('bass_amp', 'Ampeg', 'Rocket Bass RB-108', 'Rocket Bass', false, 'Production bass amplifier model verified from trusted retailer listings.'),
  ('bass_amp', 'Ampeg', 'Rocket Bass RB-110', 'Rocket Bass', false, 'Production bass amplifier model verified from trusted retailer listings.'),
  ('bass_amp', 'Ampeg', 'Rocket Bass RB-115', 'Rocket Bass', false, 'Production bass amplifier model verified from trusted retailer listings.'),
  ('bass_amp', 'Ampeg', 'PF-50T', 'Portaflex', false, 'Production bass amplifier model verified from trusted retailer listings.'),
  ('bass_amp', 'Ampeg', 'Venture V12', 'Venture', false, 'Production bass amplifier model verified from trusted retailer listings.'),
  ('bass_amp', 'Ampeg', 'Heritage 50th Anniversary SVT', 'Heritage', false, 'Production bass amplifier model verified from trusted retailer listings.'),
  ('bass_amp', 'Ampeg', 'SVT Micro VR', 'SVT', false, 'Production bass amplifier model verified from trusted retailer listings.'),
  ('bass_amp', 'Ampeg', 'SVT-4PRO', 'SVT', false, 'Production bass amplifier model verified from trusted retailer listings.'),
  ('bass_amp', 'Gallien Krueger', '800RB', 'RB', false, 'Production bass amplifier model verified from trusted retailer listings.'),
  ('bass_amp', 'Darkglass', 'Microtubes 900', 'Microtubes', false, 'Production bass amplifier model verified from trusted retailer listings.')
)
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
select
  seed.equipment_type::public.equipment_type,
  seed.brand,
  seed.model,
  seed.series,
  concat_ws(' ', seed.brand, seed.model),
  seed.description,
  seed.is_popular,
  row_number() over (
    partition by seed.equipment_type, seed.brand
    order by seed.is_popular desc, seed.model asc
  ),
  'active'::public.equipment_status,
  case
    when seed.equipment_type in ('electric_guitar', 'guitar_amp') then array['rock', 'hard_rock', 'blues']::public.equipment_genre[]
    when seed.equipment_type in ('bass_guitar', 'bass_amp') then array['rock', 'pop', 'funk']::public.equipment_genre[]
    else array['rock']::public.equipment_genre[]
  end,
  case
    when seed.equipment_type = 'electric_guitar' then array['balanced', 'dynamic', 'articulate']::public.equipment_tone_characteristic[]
    when seed.equipment_type = 'bass_guitar' then array['punchy', 'tight', 'balanced']::public.equipment_tone_characteristic[]
    when seed.equipment_type = 'guitar_amp' then array['clean', 'crunch', 'dynamic']::public.equipment_tone_characteristic[]
    when seed.equipment_type = 'bass_amp' then array['clean_headroom', 'punchy', 'tight']::public.equipment_tone_characteristic[]
    else array['balanced']::public.equipment_tone_characteristic[]
  end,
  '{}'::text[]
from seed
on conflict (equipment_type, brand, model)
do nothing;

commit;
