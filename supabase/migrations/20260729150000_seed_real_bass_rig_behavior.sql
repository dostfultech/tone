-- Seed REAL behavioral data for popular BASS rigs (bass amps + bass guitars).
--
-- Companion to the guitar-mode amp/guitar seeds. Bass mode uses the SAME tables:
--   * bass amps  -> amp_models   with instrument_type = 'bass'
--   * bass guitars -> guitar_models with instrument_type = 'bass'
-- Both were synthetic placeholders, so bass adaptation was generic. The frontend sends bass gear
-- by NAME (default guitar "Fender Precision Bass", default amp "Ampeg SVT-CL"); lookup is the same
-- search_text ILIKE '%<name>%' path. The amp query filters instrument_type IN (mode,'both') and the
-- guitar query filters instrument_type = mode, so these rows only surface in bass mode.
--
-- Engine consumption is identical to the guitar-mode seeds (see 20260729120000 / 20260729130000):
-- amp gain_structure drives era + gain deltas; brightness/warmth/clean_headroom thresholds apply;
-- guitar output_level/brightness/warmth/compression thresholds apply. Values are tuned for bass
-- voicings (e.g. Ampeg SVT warm+tube; Precision Bass thumpy+warm; StingRay hot+bright).
--
-- Data-only, idempotent. No engine/code changes.

-- 1) Ensure referenced manufacturers exist.
insert into public.equipment_manufacturers (name, slug)
values
  ('Ampeg', 'ampeg'),
  ('Darkglass', 'darkglass'),
  ('Markbass', 'markbass'),
  ('Hartke', 'hartke'),
  ('Gallien Krueger', 'gallien-krueger'),
  ('Aguilar', 'aguilar'),
  ('Orange', 'orange'),
  ('Mesa Boogie', 'mesa-boogie'),
  ('Fender', 'fender'),
  ('Music Man', 'music-man'),
  ('Ibanez', 'ibanez'),
  ('Yamaha', 'yamaha'),
  ('Squier', 'squier'),
  ('Warwick', 'warwick')
on conflict (slug) do nothing;

-- 2) Bass AMPS -> amp_models (instrument_type = 'bass').
insert into public.amp_models (
  manufacturer_id, model_name, instrument_type, amp_technology, gain_structure,
  brightness, warmth, clean_headroom, compression,
  eq_behaviour, presence_behaviour, metadata, search_text, is_active
)
select
  m.id, v.model_name, 'bass', v.amp_technology, v.gain_structure,
  v.brightness, v.warmth, v.clean_headroom, v.compression,
  '{}'::jsonb, '{}'::jsonb,
  jsonb_build_object('verified', true, 'source', 'curated_top_bass_amps_v1', 'version', 1),
  v.search_text, true
from (
  values
    ('ampeg', 'SVT', 'tube', 'bass_tube_svt', 5.0, 7.0, 7.0, 5.0,
      'ampeg svt-cl | ampeg svt-vr | ampeg svt-3pro | ampeg svt-7pro | ampeg portaflex pf-500 | ampeg pf-500 | ampeg pf-800 | ampeg micro-vr | ampeg micro-cl | ampeg svt | ampeg'),
    ('darkglass', 'Microtubes / Alpha-Omega', 'solid_state', 'bass_modern_drive', 6.5, 4.5, 7.0, 5.5,
      'darkglass microtubes 500 v2 | darkglass microtubes 900 v2 | darkglass alpha-omega 500 | darkglass alpha omega 900 | darkglass microtubes | darkglass alpha omega | darkglass'),
    ('markbass', 'Little Mark', 'solid_state', 'bass_solid_state_clean', 6.0, 5.0, 8.0, 4.5,
      'markbass little mark iv | markbass little mark iii | markbass little mark | markbass cmd 121p | markbass'),
    ('hartke', 'LH / HA', 'solid_state', 'bass_solid_state_punch', 6.5, 4.5, 8.0, 4.5,
      'hartke lh500 | hartke lh1000 | hartke ha3500 | hartke lh | hartke ha | hartke'),
    ('gallien-krueger', 'MB Series', 'solid_state', 'bass_solid_state_clean', 6.0, 5.0, 8.0, 4.5,
      'gallien krueger mb200 | gallien krueger mb500 | gallien krueger mb800 | gallien krueger mb | gk mb | gallien krueger | gk'),
    ('fender', 'Rumble', 'solid_state', 'bass_solid_state_clean', 5.5, 5.5, 7.0, 4.5,
      'fender rumble 40 | fender rumble 100 | fender rumble 500 | fender rumble 200 | fender rumble'),
    ('aguilar', 'Tone Hammer', 'solid_state', 'bass_solid_state_hifi', 6.0, 5.5, 8.0, 4.5,
      'aguilar tone hammer 350 | aguilar tone hammer 500 | aguilar tone hammer | aguilar ag700 | aguilar'),
    ('orange', 'Terror Bass', 'hybrid', 'bass_tube_drive', 5.5, 6.0, 5.0, 5.5,
      'orange terror bass 500 | orange terror bass | orange ob1-500 | orange ob1 | orange bass'),
    ('mesa-boogie', 'Subway', 'solid_state', 'bass_solid_state_clean', 6.0, 5.0, 8.0, 4.5,
      'mesa boogie subway d-800 | mesa boogie subway | mesa subway d-800 | mesa subway | mesa bass')
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

-- 3) Bass GUITARS -> guitar_models (instrument_type = 'bass').
insert into public.guitar_models (
  manufacturer_id, model_name, instrument_type, body_type, pickup_layout,
  output_level, brightness, warmth, compression,
  noise_characteristics, metadata, search_text, is_active
)
select
  m.id, v.model_name, 'bass', v.body_type, v.pickup_layout,
  v.output_level, v.brightness, v.warmth, v.compression,
  '{}'::jsonb,
  jsonb_build_object('verified', true, 'source', 'curated_top_bass_guitars_v1', 'version', 1),
  v.search_text, true
from (
  values
    ('fender', 'Precision Bass', 'solid', 'p', 5.5, 4.5, 7.0, 5.0,
      'fender player precision bass | fender player plus precision bass | fender american professional ii precision bass | fender precision bass | fender p bass | p-bass'),
    ('fender', 'Jazz Bass', 'solid', 'jj', 5.0, 6.0, 5.5, 4.5,
      'fender player jazz bass | fender player plus jazz bass | fender american professional ii jazz bass | fender jazz bass | fender j bass | jazz bass'),
    ('music-man', 'StingRay', 'solid', 'h', 7.0, 6.5, 5.0, 5.0,
      'music man stingray special hh | music man stingray special h | music man stingray | ernie ball stingray | stingray bass'),
    ('ibanez', 'SR', 'solid', 'jj', 6.0, 6.5, 4.5, 5.0,
      'ibanez sr300e | ibanez sr500e | ibanez sr1350b | ibanez gsr200 | ibanez sr | ibanez soundgear'),
    ('yamaha', 'TRBX', 'solid', 'jj', 6.0, 6.0, 5.0, 5.0,
      'yamaha trbx304 | yamaha trbx504 | yamaha trbx | yamaha bb734a | yamaha bb'),
    ('squier', 'Affinity P/J Bass', 'solid', 'pj', 5.0, 5.5, 6.0, 4.5,
      'squier affinity precision bass pj | squier affinity jazz bass | squier affinity bass | squier precision bass | squier jazz bass | squier p bass | squier j bass'),
    ('warwick', 'Corvette', 'solid', 'jj', 6.5, 6.0, 5.0, 5.0,
      'warwick rockbass corvette basic 4 | warwick corvette | warwick rockbass | warwick')
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
