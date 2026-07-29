-- Seed REAL cabinet behavior. The cabinet_models table was EMPTY (0 rows), so the cabinet stage
-- of the rule engine only ever fired via coarse inference (format + back type guessed from the
-- name) and never applied real low-end / brightness character.
--
-- The cabinet picker is a fixed 6-item list (lib/mock-data.ts); the frontend sends the cabinet by
-- NAME (buildToneAdaptationApiPayload -> `cabinet: payload.cabinet`), resolved via
-- findCabinet -> queryEquipmentName: search_text ILIKE '%<name>%' (then model_name). We seed all 6
-- picker cabinets plus common free-typed aliases, keyed to the exact picker display strings.
--
-- Engine consumption (rules.ts cabinetProfileRule + mappers.mapCabinetRow):
--   * back_type: open_back => bass -0.75, depth -0.5, presence +0.25 ; closed_back => the inverse
--   * format (cabinet_format_id): 1x12 => bass -0.5 ; 4x12 => bass +0.5, resonance +0.5
--   * brightness >= 7 => treble -0.5, presence -0.5
--   * low_end   >= 7 => bass -0.5, depth -0.5   (tame a deep/boomy cab)
--   * high_end  <= 3.5 => treble +0.5, presence +0.5 (add air to a dark cab)
--
-- Data-only, idempotent. No engine/code changes.

-- 1) cabinet_format_id is a NOT NULL FK to cabinet_formats. Add the bass formats we need
--    (guitar 1x12/2x12/4x12 already exist).
insert into public.cabinet_formats (id, label, speaker_count, speaker_size_inches)
values
  ('4x10', '4x10', 4, 10),
  ('2x10', '2x10', 2, 10),
  ('1x15', '1x15', 1, 15),
  ('8x10', '8x10', 8, 10)
on conflict (id) do nothing;

-- 2) Ensure referenced manufacturers exist.
insert into public.equipment_manufacturers (name, slug)
values
  ('Mesa Boogie', 'mesa-boogie'),
  ('Marshall', 'marshall'),
  ('Orange', 'orange'),
  ('Fender', 'fender'),
  ('Ampeg', 'ampeg'),
  ('Darkglass', 'darkglass')
on conflict (slug) do nothing;

-- 3) Upsert the cabinet catalog with real behavioral values.
insert into public.cabinet_models (
  manufacturer_id, model_name, cabinet_format_id, back_type,
  low_end, high_end, brightness, warmth,
  metadata, search_text, is_active
)
select
  m.id, v.model_name, v.cabinet_format_id, v.back_type,
  v.low_end, v.high_end, v.brightness, v.warmth,
  jsonb_build_object('verified', true, 'source', 'curated_top_cabinets_v1', 'version', 1),
  v.search_text, true
from (
  values
    -- Guitar cabinets
    ('mesa-boogie', 'Rectifier 4x12', '4x12', 'closed_back', 7.5, 6.0, 5.5, 5.5,
      'mesa/boogie rectifier 4x12 | mesa boogie rectifier 4x12 | mesa recto 4x12 | mesa oversized 4x12 | mesa 4x12'),
    ('marshall', '1960A 4x12', '4x12', 'closed_back', 6.0, 6.5, 6.0, 5.0,
      'marshall 1960a 4x12 | marshall 1960b 4x12 | marshall 1960 | marshall 4x12'),
    ('orange', 'PPC212', '2x12', 'closed_back', 6.0, 5.5, 5.0, 6.0,
      'orange ppc212 | orange ppc 212 | orange 2x12 | orange ppc412 | orange 4x12'),
    ('fender', 'Deluxe Reverb 1x12', '1x12', 'open_back', 4.0, 7.5, 7.0, 4.5,
      'fender deluxe reverb 1x12 | fender 1x12 | fender open back | deluxe reverb cab | fender combo cab'),
    -- Bass cabinets
    ('ampeg', 'SVT-410HLF', '4x10', 'closed_back', 8.0, 6.0, 5.0, 5.5,
      'ampeg svt-410hlf | ampeg 410 | ampeg svt-810e | ampeg svt-810 | ampeg 810 | ampeg 8x10 | ampeg 4x10 | ampeg bass cab'),
    ('darkglass', 'DG212N', '2x12', 'closed_back', 7.0, 7.0, 7.0, 4.5,
      'darkglass dg212n | darkglass 2x12 | darkglass bass cab')
) as v(
  manufacturer_slug, model_name, cabinet_format_id, back_type,
  low_end, high_end, brightness, warmth, search_text
)
join public.equipment_manufacturers m on m.slug = v.manufacturer_slug
on conflict (manufacturer_id, model_name, cabinet_format_id) do update set
  back_type = excluded.back_type,
  low_end = excluded.low_end,
  high_end = excluded.high_end,
  brightness = excluded.brightness,
  warmth = excluded.warmth,
  metadata = excluded.metadata,
  search_text = excluded.search_text,
  is_active = true,
  updated_at = now();
