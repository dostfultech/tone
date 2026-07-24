-- Add Ibanez as a pickup manufacturer and seed IBZ-LZ Active pickup model

-- Ensure Ibanez exists in equipment_manufacturers
INSERT INTO public.equipment_manufacturers (name, slug, country, is_active)
VALUES ('Ibanez', 'ibanez', 'JP', true)
ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name, is_active = true;

-- Seed IBZ-LZ Active humbucker into pickup_models
INSERT INTO public.pickup_models (
  manufacturer_id, model_name, pickup_type_id, circuit_type,
  output_level, brightness, bass, midrange, compression, noise,
  search_text
)
VALUES (
  (SELECT id FROM equipment_manufacturers WHERE slug = 'ibanez'),
  'IBZ-LZ Active',
  'humbucker',
  'active',
  8.0, 5.5, 7.0, 6.0, 7.5, 1.5,
  'Ibanez IBZ-LZ Active humbucker active ART300 high output metal rock'
)
ON CONFLICT (manufacturer_id, model_name, pickup_type_id) DO UPDATE
SET search_text = EXCLUDED.search_text,
    output_level = EXCLUDED.output_level,
    brightness = EXCLUDED.brightness,
    bass = EXCLUDED.bass,
    midrange = EXCLUDED.midrange,
    compression = EXCLUDED.compression,
    noise = EXCLUDED.noise,
    circuit_type = EXCLUDED.circuit_type,
    is_active = true;
