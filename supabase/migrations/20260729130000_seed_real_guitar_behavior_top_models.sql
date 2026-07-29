-- Seed REAL behavioral data for the most popular electric guitars.
--
-- Companion to 20260729120000 (amps). Same problem, same fix: the rule engine reads guitar
-- "behavior" from public.guitar_models (output_level / brightness / warmth / compression), but
-- that table held ~2200 synthetic placeholder rows with everything at 5.0, so every guitar
-- produced the same adaptation. This seeds the popular real guitars with hand-tuned values.
--
-- Matching (verified against lib/backend/tone-adaptation): the frontend sends the guitar as a
-- NAME string (buildToneAdaptationApiPayload -> `guitar: payload.guitar`); SupabaseGearRepository
-- .findGuitar -> queryEquipmentName runs search_text ILIKE '%<name>%' (then model_name), with
-- instrument_type = 'guitar'. So search_text packs the exact catalog "brand model" display strings.
--
-- Engine consumption (rules.ts guitarProfileRule + mappers.mapGuitarRow):
--   * brightness: numeric -> "dark" (<=3.5) / "balanced" / "bright" (>=6.5).
--       bright  => treble -1, presence -1   (tame a bright guitar)
--       dark    => treble +1, presence +1   (add highs a dark guitar lacks)
--   * output_level (numeric): <=3.5 => gain +0.5, compression +0.5 (quiet single-coils get pushed)
--                             >=7   => gain -0.5, compression -0.5 (hot humbuckers get backed off)
--   * warmth: >=7 => bass -0.5, middle -0.5 ; <=3.5 => bass +0.5, middle +0.5
--   * compression: >=7 => compression -0.5 ; <=3.5 => compression +0.5
-- Values below are chosen so single-coil vs humbucker guitars diverge the way real gear does.
--
-- Data-only, idempotent. No engine/code changes.

-- 1) Ensure referenced manufacturers exist.
insert into public.equipment_manufacturers (name, slug)
values
  ('Fender', 'fender'),
  ('Squier', 'squier'),
  ('Gibson', 'gibson'),
  ('Epiphone', 'epiphone'),
  ('PRS', 'prs'),
  ('Ibanez', 'ibanez'),
  ('ESP LTD', 'ltd'),
  ('Jackson', 'jackson'),
  ('Schecter', 'schecter'),
  ('Solar', 'solar'),
  ('Dean', 'dean'),
  ('Yamaha', 'yamaha'),
  ('Charvel', 'charvel'),
  ('Music Man', 'music-man'),
  ('Gretsch', 'gretsch'),
  ('EVH', 'evh'),
  ('Suhr', 'suhr'),
  ('G&L', 'g-l')
on conflict (slug) do nothing;

-- 2) Upsert real guitar behavior.
insert into public.guitar_models (
  manufacturer_id, model_name, instrument_type, body_type, pickup_layout,
  output_level, brightness, warmth, compression,
  noise_characteristics, metadata, search_text, is_active
)
select
  m.id, v.model_name, 'guitar', v.body_type, v.pickup_layout,
  v.output_level, v.brightness, v.warmth, v.compression,
  '{}'::jsonb,
  jsonb_build_object('verified', true, 'source', 'curated_top_guitars_v1', 'version', 1),
  v.search_text, true
from (
  values
    -- ===== FENDER / single-coil brights (quiet, need gain push, tame highs) =====
    ('fender', 'Stratocaster', 'solid', 'sss', 3.5, 7.5, 4.0, 3.0,
      'fender player stratocaster | fender player plus stratocaster | fender american professional ii stratocaster | fender american ultra stratocaster | fender american performer stratocaster | fender stratocaster | fender strat'),
    ('fender', 'Telecaster', 'solid', 'ss', 3.5, 8.0, 3.5, 3.0,
      'fender player telecaster | fender player plus telecaster | fender american professional ii telecaster | fender american ultra telecaster | fender american performer telecaster | fender telecaster | fender tele'),
    ('fender', 'Jazzmaster / Jaguar', 'solid', 'ss', 3.5, 7.0, 4.5, 3.5,
      'fender player jazzmaster | fender player jaguar | fender jazzmaster | fender jaguar | fender offset'),
    ('squier', 'Stratocaster / Telecaster', 'solid', 'sss', 3.0, 7.0, 4.0, 3.0,
      'squier affinity stratocaster | squier affinity telecaster | squier classic vibe 50s stratocaster | squier classic vibe 60s stratocaster | squier classic vibe 50s telecaster | squier classic vibe 60s telecaster | squier stratocaster | squier telecaster | squier strat | squier tele'),
    ('g-l', 'Legacy / ASAT', 'solid', 'sss', 3.5, 7.5, 4.0, 3.0,
      'g&l legacy | g&l asat classic | g&l asat | g&l tribute | g&l'),

    -- ===== GIBSON / EPIPHONE humbuckers (hot, dark, warm -> back off gain, add highs) =====
    ('gibson', 'Les Paul', 'solid', 'hh', 7.0, 3.5, 7.0, 6.0,
      'gibson les paul standard 50s | gibson les paul standard 60s | gibson les paul studio | gibson les paul classic | gibson les paul modern | gibson les paul standard | gibson les paul'),
    ('epiphone', 'Les Paul', 'solid', 'hh', 6.5, 3.5, 6.5, 5.5,
      'epiphone les paul standard 50s | epiphone les paul standard 60s | epiphone les paul classic | epiphone les paul custom | epiphone les paul studio | epiphone les paul traditional pro ii | epiphone les paul traditional | epiphone les paul'),
    ('gibson', 'SG', 'solid', 'hh', 6.5, 5.0, 6.0, 5.0,
      'gibson sg standard | gibson sg | epiphone sg standard | epiphone sg'),
    ('gibson', 'ES-335 / Casino', 'semi_hollow', 'hh', 5.0, 4.5, 7.5, 5.0,
      'gibson es-335 | gibson es 335 | epiphone es-335 | epiphone casino | es-335 | casino semi hollow'),
    ('gibson', 'Explorer / Flying V', 'solid', 'hh', 7.0, 4.5, 6.5, 5.5,
      'gibson explorer | gibson flying v | epiphone explorer | epiphone flying v | explorer | flying v'),

    -- ===== PRS =====
    ('prs', 'SE Custom 24', 'solid', 'hh', 6.0, 5.5, 5.5, 5.0,
      'prs se custom 24 | prs se custom 24-08 | prs se standard 24 | prs se mccarty 594 | prs core custom 24 | prs custom 24 | prs mccarty | prs se'),
    ('prs', 'Silver Sky', 'solid', 'sss', 3.5, 7.0, 4.5, 3.5,
      'prs se silver sky | prs silver sky | silver sky'),

    -- ===== IBANEZ (superstrat) =====
    ('ibanez', 'RG / S', 'solid', 'hh', 8.0, 6.0, 4.5, 5.0,
      'ibanez rg550 | ibanez rg421 | ibanez rg470dx | ibanez rg | ibanez s521 | ibanez s series | ibanez superstrat'),
    ('ibanez', 'AZ', 'solid', 'hss', 5.5, 6.5, 5.0, 4.5,
      'ibanez az2204 | ibanez az224 | ibanez az'),

    -- ===== MODERN METAL (high-output humbucker superstrats) =====
    ('ltd', 'EC / Metal', 'solid', 'hh', 8.0, 5.5, 5.0, 6.0,
      'ltd ec-256 | ltd ec-1000 | ltd ec | esp ltd | esp eclipse | esp'),
    ('jackson', 'Dinky / Soloist', 'solid', 'hh', 8.0, 6.0, 4.5, 5.5,
      'jackson dinky js22 | jackson dinky js32 | jackson dinky | jackson soloist | jackson rhoads | jackson'),
    ('schecter', 'C-1 / Omen', 'solid', 'hh', 8.0, 5.5, 5.0, 6.0,
      'schecter c-1 hellraiser | schecter c-1 platinum | schecter omen extreme-6 | schecter c-1 | schecter omen | schecter'),
    ('solar', 'A-Series', 'solid', 'hh', 8.0, 5.5, 4.5, 6.0,
      'solar a1.6 | solar a series | solar guitars | solar a'),
    ('dean', 'ML', 'solid', 'hh', 8.0, 5.5, 5.0, 6.0,
      'dean ml select | dean ml | dean guitars | dean'),

    -- ===== HSS / mixed & boutique =====
    ('yamaha', 'Pacifica / Revstar', 'solid', 'hss', 4.5, 6.5, 5.0, 4.0,
      'yamaha pacifica 112v | yamaha pacifica | yamaha revstar rss20 | yamaha revstar'),
    ('charvel', 'Pro-Mod', 'solid', 'hss', 7.0, 6.5, 4.5, 5.0,
      'charvel pro-mod dk24 | charvel pro-mod so-cal | charvel pro-mod san dimas | charvel pro-mod | charvel'),
    ('music-man', 'Axis / JP', 'solid', 'hh', 6.5, 6.0, 5.0, 5.0,
      'music man axis | music man jp15 | music man jp | ernie ball music man | musicman'),
    ('evh', 'Wolfgang', 'solid', 'hh', 7.5, 5.5, 5.0, 5.5,
      'evh wolfgang standard | evh wolfgang special | evh wolfgang | wolfgang'),
    ('suhr', 'Classic S / Modern', 'solid', 'hss', 5.0, 6.5, 4.5, 4.5,
      'suhr classic s | suhr classic | suhr modern | suhr'),

    -- ===== GRETSCH (hollow / Filtertron jangle) =====
    ('gretsch', 'Electromatic', 'hollow', 'hh', 4.5, 7.0, 5.5, 4.0,
      'gretsch g5420t electromatic | gretsch g5220 electromatic jet | gretsch electromatic | gretsch jet | gretsch')
) as v(
  manufacturer_slug, model_name, body_type, pickup_layout,
  output_level, brightness, warmth, compression, search_text
)
join public.equipment_manufacturers m on m.slug = v.manufacturer_slug
on conflict (manufacturer_id, model_name, instrument_type) do update set
  body_type = excluded.body_type,
  pickup_layout = excluded.pickup_layout,
  output_level = excluded.output_level,
  brightness = excluded.brightness,
  warmth = excluded.warmth,
  compression = excluded.compression,
  metadata = excluded.metadata,
  search_text = excluded.search_text,
  is_active = true,
  updated_at = now();
