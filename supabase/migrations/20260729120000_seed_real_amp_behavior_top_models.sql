-- Seed REAL behavioral data for the most popular guitar amps.
--
-- Why: the rule engine (lib/rule-engine) reads amp "behavior" from public.amp_models
-- (brightness / warmth / clean_headroom / gain_structure / amp_technology). Until now that
-- table held ~1600 synthetic placeholder rows (e.g. "Titan MKI 001") with every value at a
-- flat 5.0, so a user picking a Boss Katana got no meaningful amp-specific adaptation --
-- the lookup missed and fell back to coarse keyword inference.
--
-- How matching works (verified against lib/backend/tone-adaptation):
--   * The frontend sends the amp as a NAME string (e.g. "Fender Blues Junior IV"), never an id.
--   * SupabaseGearRepository.findAmplifier -> queryEquipmentName runs
--       search_text ILIKE '%<user amp name>%'  (then model_name ILIKE '%...%').
--     So each row's search_text must CONTAIN the exact catalog display strings ("brand model")
--     a user can pick. We pack every popular variant phrase for a family into search_text.
--   * mappers.mapAmpRow derives era from gain_structure: contains "vintage"/"classic" => vintage,
--     "modern" => modern, else neutral. The amplifier rule (rules.ts) also regex-matches
--     gain_structure against /vintage|plexi|tweed|blackface/ (=> +gain,+mid) and
--     /modern|high|rectifier|5150/ (=> -gain,-bass). brightness>=6.5 maps to "bright"
--     (=> -treble,-presence); warmth>=7 => -bass; clean_headroom<=3.5 => -gain,-master.
--     The gain_structure strings below are chosen so those triggers fire correctly per amp.
--
-- No engine/code changes required -- this is a data-only migration and is idempotent.

-- 1) Ensure the manufacturers we reference exist (Boss + Line 6 already seeded; rest may not be).
insert into public.equipment_manufacturers (name, slug)
values
  ('Fender', 'fender'),
  ('Marshall', 'marshall'),
  ('Mesa Boogie', 'mesa-boogie'),
  ('Vox', 'vox'),
  ('Roland', 'roland'),
  ('Orange', 'orange'),
  ('Peavey', 'peavey'),
  ('EVH', 'evh'),
  ('Blackstar', 'blackstar'),
  ('Line 6', 'line-6'),
  ('Boss', 'boss'),
  ('Positive Grid', 'positive-grid'),
  ('PRS', 'prs'),
  ('Soldano', 'soldano'),
  ('Diezel', 'diezel')
on conflict (slug) do nothing;

-- 2) Upsert real amp behavior. Columns:
--    manufacturer_slug, model_name, amp_technology, gain_structure,
--    brightness, warmth, clean_headroom, compression, search_text
insert into public.amp_models (
  manufacturer_id, model_name, instrument_type, amp_technology, gain_structure,
  brightness, warmth, clean_headroom, compression,
  eq_behaviour, presence_behaviour, metadata, search_text, is_active
)
select
  m.id, v.model_name, 'guitar', v.amp_technology, v.gain_structure,
  v.brightness, v.warmth, v.clean_headroom, v.compression,
  '{}'::jsonb, '{}'::jsonb,
  jsonb_build_object('verified', true, 'source', 'curated_top_amps_v1', 'version', 1),
  v.search_text, true
from (
  values
    -- ===== FENDER (clean/blackface + American combos + modeling) =====
    ('fender', '''65 Twin Reverb', 'tube', 'vintage_blackface_clean',
      7.5, 5.0, 9.0, 3.0,
      'fender ''65 twin reverb | fender 65 twin reverb | fender tone master twin reverb | fender twin reverb | fender twin | twin reverb blackface'),
    ('fender', '''65 Deluxe Reverb', 'tube', 'vintage_blackface_clean',
      7.5, 5.5, 6.5, 3.5,
      'fender ''65 deluxe reverb | fender 65 deluxe reverb | fender tone master deluxe reverb | fender deluxe reverb | fender ''65 princeton reverb | fender 65 princeton reverb | fender tone master princeton reverb | fender princeton reverb | deluxe reverb blackface'),
    ('fender', 'Blues Junior IV', 'tube', 'vintage_tweed_breakup',
      6.5, 6.5, 5.0, 4.0,
      'fender blues junior iv | fender blues junior | fender blues jr | blues junior tweed'),
    ('fender', 'Hot Rod Deluxe IV', 'tube', 'american_hot_rod_drive',
      6.5, 5.5, 7.0, 4.0,
      'fender hot rod deluxe iv | fender hot rod deluxe | fender hot rod deville | fender hot rod | hot rod deluxe'),
    ('fender', 'Champion 40', 'solid_state', 'solid_state_modeling',
      6.0, 5.0, 7.0, 4.5,
      'fender champion 20 | fender champion 40 | fender champion | champion modeling combo'),
    ('fender', 'Mustang GTX / LT', 'digital_modeling', 'digital_modeling',
      6.0, 5.0, 7.0, 4.5,
      'fender mustang gtx100 | fender mustang gtx50 | fender mustang lt25 | fender mustang lt40 | fender mustang micro | fender mustang gt | fender mustang gtx | fender mustang lt | fender mustang modeling'),

    -- ===== MARSHALL (modern DSL/JVM high gain + vintage plexi/JCM800) =====
    ('marshall', 'DSL Series', 'tube', 'british_high_gain',
      6.5, 5.0, 4.0, 5.5,
      'marshall dsl1 | marshall dsl5cr | marshall dsl20 | marshall dsl20cr | marshall dsl40 | marshall dsl40cr | marshall dsl100h | marshall jvm410h | marshall jvm | marshall dsl'),
    ('marshall', 'Plexi / JCM800 Studio', 'tube', 'vintage_plexi_crunch',
      6.5, 5.5, 4.5, 5.0,
      'marshall jcm800 2203 | marshall jcm800 | marshall sv20h studio vintage | marshall sc20h studio classic | marshall 2555x silver jubilee | marshall origin 20c | marshall origin 50h | marshall 1959slp | marshall plexi | marshall super lead'),
    ('marshall', 'MG Series', 'solid_state', 'solid_state_crunch',
      6.5, 5.0, 5.5, 5.0,
      'marshall mg15fx | marshall mg30fx | marshall mg | marshall code'),

    -- ===== VOX (class A chime) =====
    ('vox', 'AC30 / AC15', 'tube', 'vintage_class_a_chime',
      8.0, 5.0, 5.5, 5.0,
      'vox ac30c2 | vox ac30 | vox ac15c1 | vox ac15 | vox ac30s1 | vox mv50 ac | vox ac class a'),

    -- ===== ROLAND / JAZZ CHORUS (pristine solid-state clean) =====
    ('roland', 'JC-120 Jazz Chorus', 'solid_state', 'solid_state_clean',
      7.5, 4.5, 9.5, 3.0,
      'roland jc-120 | roland jc120 | roland jc-40 | roland jc40 | roland jazz chorus | jc-120 | jazz chorus clean'),

    -- ===== MESA BOOGIE (modern high gain) =====
    ('mesa-boogie', 'Dual Rectifier', 'tube', 'modern_high_gain_rectifier',
      5.5, 4.5, 6.0, 6.0,
      'mesa boogie dual rectifier solo head | mesa boogie dual rectifier | mesa dual rectifier | mesa boogie mini rectifier 25 | mesa mini rectifier | mesa recto | mesa rectifier'),
    ('mesa-boogie', 'Mark V', 'tube', 'modern_high_gain_mark',
      6.0, 5.0, 6.0, 6.0,
      'mesa boogie mark v 90 | mesa boogie mark v 35 | mesa boogie mark v 25 | mesa boogie mark v | mesa mark v | mesa mark iv | mesa mark series'),

    -- ===== PEAVEY (5150 high gain + classic combo + solid state) =====
    ('peavey', '6505', 'tube', 'modern_high_gain_5150',
      5.5, 4.0, 3.0, 6.5,
      'peavey 6505 mh | peavey 6505+ 112 combo | peavey 6505 plus | peavey 6505 | peavey 5150 | 6505 metal'),
    ('peavey', 'Classic 30', 'tube', 'vintage_class_a_chime',
      7.0, 5.5, 5.0, 4.5,
      'peavey classic 30 | peavey classic 20 | peavey classic'),
    ('peavey', 'Bandit 112', 'solid_state', 'solid_state_crunch',
      6.5, 4.5, 7.0, 4.0,
      'peavey bandit 112 | peavey bandit | peavey transtube'),

    -- ===== ORANGE (warm British mid/high gain + terror/crush) =====
    ('orange', 'Rockerverb / TH', 'tube', 'british_mid_gain',
      5.0, 7.0, 4.5, 6.0,
      'orange rockerverb 50 mkiii | orange rockerverb 50 mkiii head | orange rockerverb | orange th30 | orange th | orange rocker 15 | orange rocker 32 | orange super crush 100 | orange super crush'),
    ('orange', 'Tiny Terror / Crush', 'hybrid', 'british_crunch',
      5.5, 6.0, 3.5, 5.5,
      'orange tiny terror | orange micro terror | orange micro dark | orange crush 12 | orange crush 20 | orange crush 35rt | orange terror | orange crush'),

    -- ===== EVH (modern 5150 high gain) =====
    ('evh', '5150III', 'tube', 'modern_high_gain_5150',
      5.5, 4.5, 3.5, 6.5,
      'evh 5150iii 50w el34 head | evh 5150iii 100s 6l6 head | evh 5150iii 50w 6l6 head | evh 5150iii 100w | evh iconic 40w 1x12 combo | evh 5150iii | evh 5150 | evh iconic'),

    -- ===== BLACKSTAR (modern gain, ISF) =====
    ('blackstar', 'HT Series', 'tube', 'modern_gain_isf',
      6.0, 5.5, 5.0, 5.5,
      'blackstar ht-20r mkiii | blackstar ht club 40 mkiii | blackstar ht-5r mkii | blackstar ht | blackstar id | blackstar isf'),

    -- ===== LINE 6 (digital modeling) =====
    ('line-6', 'Catalyst / Spider', 'digital_modeling', 'digital_modeling',
      6.0, 5.0, 8.0, 4.5,
      'line 6 catalyst 60 | line 6 catalyst 100 | line 6 catalyst 200 | line 6 catalyst | line 6 spider v 60 mkii | line 6 spider v | line 6 spider | line 6 modeling'),

    -- ===== BOSS KATANA (digital modeling) =====
    ('boss', 'Katana', 'digital_modeling', 'digital_modeling',
      6.0, 5.0, 7.0, 4.5,
      'boss katana-50 mkii | boss katana-100 mkii | boss katana artist mkii | boss katana-50 gen 3 | boss katana-100 gen 3 | boss katana-100/212 gen 3 | boss katana artist gen 3 | boss katana head mkii | boss katana-50 | boss katana-100 | boss katana-mini | boss katana artist | boss katana | katana modeling'),

    -- ===== POSITIVE GRID SPARK (digital modeling, bedroom/beginner) =====
    ('positive-grid', 'Spark', 'digital_modeling', 'digital_modeling',
      6.0, 5.0, 7.0, 4.5,
      'positive grid spark 40 | positive grid spark mini | positive grid spark 2 | positive grid spark | spark 40 | spark amp'),

    -- ===== PRS (modern high gain head) =====
    ('prs', 'MT 15', 'tube', 'modern_high_gain',
      6.0, 5.0, 3.5, 6.0,
      'prs mt 15 | prs mt15 | prs mark tremonti | prs archon'),

    -- ===== SOLDANO (boutique high gain) =====
    ('soldano', 'SLO-100', 'tube', 'boutique_high_gain',
      6.0, 5.0, 3.5, 6.0,
      'soldano slo-100 | soldano slo 100 | soldano slo | soldano super lead overdrive'),

    -- ===== DIEZEL (modern boutique high gain) =====
    ('diezel', 'VH4', 'tube', 'modern_high_gain_boutique',
      5.5, 5.0, 3.5, 6.5,
      'diezel vh4 | diezel herbert | diezel vh')
) as v(
  manufacturer_slug, model_name, amp_technology, gain_structure,
  brightness, warmth, clean_headroom, compression, search_text
)
join public.equipment_manufacturers m on m.slug = v.manufacturer_slug
on conflict (manufacturer_id, model_name, instrument_type) do update set
  amp_technology = excluded.amp_technology,
  gain_structure = excluded.gain_structure,
  brightness = excluded.brightness,
  warmth = excluded.warmth,
  clean_headroom = excluded.clean_headroom,
  compression = excluded.compression,
  metadata = excluded.metadata,
  search_text = excluded.search_text,
  is_active = true,
  updated_at = now();
