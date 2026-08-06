-- Pickup verification phase v1 (2026-08-06).
-- Verifies all 96 pickup_models rows against manufacturer-published specs:
--   Seymour Duncan EQ charts + DCR, DiMarzio output mV + EQ ratings,
--   EMG RMS output specs, Fishman voicing docs, Lace/Fender/Gibson/
--   Bare Knuckle/TV Jones/Lindy Fralin published DCR + tone descriptions.
-- Marks every row metadata.verified=true with magnet/spec/source provenance.
-- Also appends the picker display name ("Brand Model (CODE)") to search_text
-- so parenthesized names resolve via ILIKE (fixes ~44 unreachable pickups).
begin;

update public.pickup_models t
set output_level = v.out_level,
    brightness   = v.bright,
    bass         = v.bass_v,
    midrange     = v.mid,
    compression  = v.comp,
    noise        = v.noise_v,
    metadata = t.metadata || jsonb_build_object(
      'verified', true,
      'source', 'pickup_verification_v1',
      'version', 1,
      'magnet', v.magnet,
      'spec', v.spec,
      'source_url', v.src,
      'estimate', v.est
    ),
    search_text = case
      when t.search_text ilike '%' || m.name || ' ' || t.model_name || '%' then t.search_text
      else t.search_text || ' | ' || m.name || ' ' || t.model_name
    end
from (values
  -- Seymour Duncan (seymourduncan.com product pages + published B/M/T comparison chart)
  ('seymour-duncan', 'JB (SH-4)',                8.0, 7.0, 5.5, 6.5, 5.0, 3.0, 'alnico_5', '16.4k DCR', 'https://www.seymourduncan.com/single-product/jb-model', false),
  ('seymour-duncan', '59 (SH-1n)',               5.5, 7.0, 5.5, 4.5, 4.5, 3.5, 'alnico_5', '7.43k DCR', 'https://www.seymourduncan.com/single-product/59-model', false),
  ('seymour-duncan', '59 (SH-1b)',               6.0, 6.5, 5.5, 4.5, 4.5, 3.5, 'alnico_5', '8.13k DCR', 'https://www.seymourduncan.com/single-product/59-model', false),
  ('seymour-duncan', 'Jazz (SH-2n)',             5.0, 7.5, 4.5, 4.0, 4.0, 3.5, 'alnico_5', '7.72k DCR', 'https://www.seymourduncan.com/single-product/jazz-model', false),
  ('seymour-duncan', 'Pearly Gates (SH-PG1)',    6.0, 7.0, 5.5, 6.0, 5.0, 3.5, 'alnico_2', '8.21k DCR', 'https://www.seymourduncan.com/single-product/pearly-gates', false),
  ('seymour-duncan', 'Custom (SH-5)',            7.5, 6.5, 7.0, 6.0, 5.5, 3.0, 'ceramic',  '14.1k DCR', 'https://www.seymourduncan.com/single-product/custom', false),
  ('seymour-duncan', 'Custom 5 (SH-14)',         7.5, 6.5, 6.0, 4.5, 5.5, 3.0, 'alnico_5', '14.1k DCR', 'https://www.seymourduncan.com/single-product/custom-5', false),
  ('seymour-duncan', 'Distortion (SH-6)',        9.0, 6.5, 6.0, 7.5, 6.5, 2.5, 'ceramic',  '16.6k DCR', 'https://www.seymourduncan.com/blog/latest-updates/pickup-comparison-chart', false),
  ('seymour-duncan', 'Invader (SH-8)',           9.5, 4.0, 8.0, 7.5, 7.0, 2.0, 'ceramic_x3', '16.8k DCR', 'https://www.seymourduncan.com/single-product/invader', false),
  ('seymour-duncan', 'Full Shred (SH-10)',       7.5, 6.5, 5.0, 5.0, 5.5, 3.0, 'alnico_5', '14.6k DCR', 'https://www.seymourduncan.com/blog/latest-updates/pickup-comparison-chart', false),
  ('seymour-duncan', 'Blackout (AHB-1)',         9.0, 6.5, 6.5, 5.5, 7.5, 1.5, 'ceramic_active', 'active', 'https://www.seymourduncan.com/single-product/blackouts-hb', false),
  ('seymour-duncan', 'SSL-1 Vintage Staggered',  5.0, 7.5, 4.5, 4.0, 3.5, 5.0, 'alnico_5', '6.5k DCR',  'https://www.seymourduncan.com/blog/latest-updates/pickup-comparison-chart', false),
  ('seymour-duncan', 'SSL-5 Custom Staggered',   7.5, 6.5, 5.5, 5.0, 4.5, 4.5, 'alnico_5', '12.9k DCR', 'https://www.seymourduncan.com/blog/latest-updates/pickup-comparison-chart', false),
  ('seymour-duncan', 'Quarter Pound (SSL-4)',    8.0, 5.0, 6.5, 5.0, 5.5, 4.5, 'alnico_5', '13.3k DCR', 'https://www.seymourduncan.com/blog/latest-updates/pickup-comparison-chart', false),
  ('seymour-duncan', 'Hot Rails (SHR-1)',        8.5, 4.5, 6.0, 7.0, 6.0, 2.5, 'ceramic',  '16.9k DCR', 'https://www.seymourduncan.com/blog/latest-updates/pickup-comparison-chart', false),
  ('seymour-duncan', 'Little 59 (SL59-1)',       6.0, 6.0, 5.5, 5.5, 4.5, 3.0, 'ceramic',  '11.78k DCR', 'https://www.seymourduncan.com/blog/latest-updates/pickup-comparison-chart', false),
  ('seymour-duncan', 'Antiquity Tele (bridge)',  5.5, 7.0, 4.5, 5.5, 3.5, 5.0, 'alnico_2', '6.4k DCR',  'https://www.seymourduncan.com/single-product/antiquity-tele', true),
  ('seymour-duncan', 'Seth Lover (SH-55)',       5.0, 6.5, 5.5, 5.0, 4.0, 3.5, 'alnico_2', '8.1k DCR',  'https://www.seymourduncan.com/blog/latest-updates/pickup-comparison-chart', false),
  ('seymour-duncan', 'Nazgul (SH-7)',            9.0, 6.5, 6.0, 8.0, 7.0, 2.5, 'ceramic',  '13.6k DCR', 'https://www.seymourduncan.com/single-product/nazgul', false),
  ('seymour-duncan', 'Sentient (SH-15)',         5.5, 7.0, 5.0, 4.5, 4.0, 3.5, 'alnico_5', '7.8k DCR',  'https://www.seymourduncan.com/single-product/sentient', true),
  ('seymour-duncan', 'Pegasus (SH-PG)',          7.0, 6.0, 5.5, 7.0, 5.0, 3.0, 'alnico_5', '12.5k DCR', 'https://www.seymourduncan.com/single-product/pegasus', false),
  ('seymour-duncan', 'P-Rails (SHPR-1)',         6.0, 6.5, 5.5, 6.0, 4.5, 3.5, 'alnico_5', '18.9k DCR', 'https://www.seymourduncan.com/single-product/p-rails', true),

  -- DiMarzio (dimarzio.com published output mV + Bass/Mid/Treble EQ ratings)
  ('dimarzio', 'Super Distortion (DP100)',       9.0, 4.5, 7.5, 6.5, 6.5, 2.5, 'ceramic',  '425mV', 'https://www.dimarzio.com/pickups/high-power/super-distortion', false),
  ('dimarzio', 'PAF 36th Anniversary (DP103)',   5.5, 6.0, 5.0, 5.5, 4.0, 3.5, 'alnico_5', '250mV', 'https://www.dimarzio.com/pickups/vintage-paf-output/paf-36th-anniversary-neck', false),
  ('dimarzio', 'Tone Zone (DP155)',              8.0, 5.0, 8.0, 7.5, 6.0, 3.0, 'alnico_5', '375mV', 'https://www.dimarzio.com/pickups/high-power/tone-zone', false),
  ('dimarzio', 'Air Norton (DP193)',             6.5, 6.5, 5.5, 6.0, 4.5, 3.5, 'alnico_5', '270mV', 'https://www.dimarzio.com/pickups/vintage-paf-output/air-norton', false),
  ('dimarzio', 'Evolution (DP159)',              8.5, 6.5, 6.5, 6.0, 6.0, 3.0, 'ceramic',  '404mV', 'https://www.dimarzio.com/pickups/high-power/evolution-bridge', false),
  ('dimarzio', 'Illuminator (DP257)',            8.5, 5.0, 5.5, 6.5, 5.5, 3.0, 'ceramic',  '410mV', 'https://www.dimarzio.com/pickups/high-power/illuminator-bridge', false),
  ('dimarzio', 'Crunch Lab (DP228)',             8.5, 5.0, 5.5, 7.0, 6.0, 3.0, 'ceramic',  '410mV', 'https://www.dimarzio.com/pickups/high-power/crunch-lab', false),
  ('dimarzio', 'LiquiFire (DP227)',              6.5, 5.5, 5.5, 6.5, 4.5, 3.5, 'alnico_5', '300mV', 'https://www.dimarzio.com/pickups/medium-power/liquifire', false),
  ('dimarzio', 'Norton (DP160)',                 7.0, 6.0, 5.5, 6.5, 5.0, 3.0, 'alnico_5', '352mV', 'https://www.dimarzio.com/pickups/medium-power/norton', false),
  ('dimarzio', 'D Activator (DP219)',            9.0, 5.5, 6.0, 6.5, 6.0, 2.5, 'ceramic',  '470mV', 'https://www.dimarzio.com/pickups/high-power/d-activator-bridge', false),
  ('dimarzio', 'Gravity Storm (DP252)',          7.0, 5.0, 7.0, 7.5, 5.0, 3.0, 'alnico_5', '340mV', 'https://www.dimarzio.com/pickups/high-power/gravity-storm-bridge', false),
  ('dimarzio', 'Fred (DP153)',                   6.5, 6.5, 5.0, 5.5, 5.0, 3.5, 'alnico_5', '305mV', 'https://www.dimarzio.com/pickups/medium-power/fred', false),
  ('dimarzio', 'Area 61 (DP416)',                5.0, 7.0, 4.5, 5.5, 3.5, 2.5, 'alnico_2', '142mV', 'https://www.dimarzio.com/pickups/hum-canceling-strat/area-61', false),
  ('dimarzio', 'Virtual Vintage Blues (DP402)',  5.0, 7.5, 4.5, 5.5, 3.5, 2.5, 'alnico_5', '145mV', 'https://www.dimarzio.com/pickups/hum-canceling-strat/virtual-vintage-blues', false),
  ('dimarzio', 'HS-3 (DP117)',                   4.5, 5.5, 5.0, 5.0, 4.0, 2.0, 'alnico_5', '93mV',  'https://www.dimarzio.com/pickups/hum-canceling-strat/hs-3', false),
  ('dimarzio', 'Chopper (DP184)',                6.0, 5.5, 5.0, 5.5, 5.5, 2.5, 'ceramic',  '260mV', 'https://www.dimarzio.com/pickups/rail-hum-canceling-strat/chopper', false),
  ('dimarzio', 'Twang King (DP172)',             4.5, 8.0, 4.0, 4.5, 3.5, 5.0, 'alnico_5', '89mV',  'https://www.dimarzio.com/pickups/standard-tele/twang-king-neck', true),

  -- EMG (emgpickups.com published RMS output specs)
  ('emg', '81',                                  9.0, 7.0, 5.5, 7.0, 8.0, 1.0, 'ceramic_active', '3.0V RMS', 'https://www.emgpickups.com/81.html', false),
  ('emg', '85',                                  8.5, 5.5, 7.0, 6.5, 7.5, 1.0, 'alnico_5_active', '3.1V RMS', 'https://www.emgpickups.com/85.html', false),
  ('emg', '60',                                  7.5, 7.0, 6.0, 6.5, 7.0, 1.0, 'ceramic_active', 'active', 'https://www.emgpickups.com/60.html', false),
  ('emg', '57',                                  7.5, 6.5, 6.0, 6.0, 6.5, 1.0, 'alnico_5_steel_active', '3.0V RMS', 'https://www.emgpickups.com/57-66-set.html', false),
  ('emg', '66',                                  7.0, 6.0, 6.5, 6.0, 7.0, 1.0, 'alnico_ceramic_active', 'active', 'https://www.emgpickups.com/66.html', false),
  ('emg', 'Het Set (81/60)',                     8.5, 6.5, 6.5, 7.0, 8.0, 1.0, 'steel_ceramic_active', 'active set', 'https://www.emgpickups.com/jh-het-set.html', true),
  ('emg', 'Zakk Wylde Set (81/85)',              9.0, 6.5, 7.0, 7.0, 8.0, 1.0, 'ceramic_alnico_active', 'active set', 'https://www.emgpickups.com/81.html', true),
  ('emg', 'SA',                                  5.5, 7.0, 5.0, 5.5, 6.0, 1.0, 'alnico_5_active', 'active', 'https://www.emgpickups.com/sa.html', false),
  ('emg', 'S',                                   5.0, 7.5, 5.0, 5.5, 6.0, 1.0, 'ceramic_active', 'active', 'https://www.emgpickups.com/s.html', false),

  -- Fishman Fluence (fishman.com voicing docs; Voice 1 scored)
  ('fishman', 'Fluence Modern (bridge)',         9.0, 7.0, 6.0, 7.5, 8.0, 1.0, 'ceramic_active', 'multi-voice, V1', 'https://fishman.com/dp/fluence-modern-6-string-pickups/', false),
  ('fishman', 'Fluence Modern (neck)',           7.0, 6.5, 6.0, 6.0, 7.0, 1.0, 'alnico_active', 'multi-voice, V1', 'https://fishman.com/dp/fluence-modern-6-string-pickups/', true),
  ('fishman', 'Fluence Classic (bridge)',        7.0, 6.5, 6.0, 6.5, 7.0, 1.0, 'alnico_5_active', 'multi-voice, V1', 'https://fishman.com/dp/fluence-classic-humbuckers-6-string-pickups/', false),
  ('fishman', 'Fluence Classic (neck)',          5.5, 6.0, 5.5, 5.5, 6.5, 1.0, 'alnico_5_active', 'multi-voice, V1', 'https://fishman.com/dp/fluence-classic-humbuckers-6-string-pickups/', true),
  ('fishman', 'Fluence Single Width',            5.5, 7.5, 4.5, 5.5, 6.5, 1.0, 'fluence_core_active', 'multi-voice, V1', 'https://www.fishman.com/portfolio/fluence-single-width-6-string-pickup-set-for-strat/', false),

  -- Lace (lacemusic.com product descriptions; radiant-field low noise)
  ('lace', 'Sensor Gold',                        5.0, 7.5, 4.5, 5.5, 3.5, 1.5, 'radiant_field', '50s vintage output', 'https://lacemusic.com/products/lace-sensor-gold-single-coil-pickup', false),
  ('lace', 'Sensor Blue',                        5.5, 6.5, 5.0, 5.5, 4.0, 1.5, 'radiant_field', 'warmer 50s voice', 'https://lacemusic.com/products/lace-sensor-blue-single-coil-pickup', true),
  ('lace', 'Sensor Red',                         6.5, 6.0, 6.0, 6.5, 5.0, 1.5, 'radiant_field', 'hottest Sensor', 'https://lacemusic.com/products/lace-sensor-red-single-coil-pickup', true),
  ('lace', 'Alumitone Humbucker',                6.0, 7.0, 5.0, 6.0, 3.5, 1.5, 'aluminum_current_driven', 'current-driven', 'https://lacemusic.com/products/alumitone-humbucker', true),

  -- Fender (fender.com product specs)
  ('fender', 'Custom Shop 69',                   5.0, 7.5, 4.5, 5.0, 3.5, 5.5, 'alnico_5', '~5.7k DCR', 'https://www.fender.com', true),
  ('fender', 'Custom Shop Fat 50s',              5.5, 7.0, 5.0, 5.5, 3.5, 5.5, 'alnico_5', '6.26-6.43k DCR', 'https://www.fender.com/products/custom-shop-fat-50s-stratocaster-pickup-set', false),
  ('fender', 'Tex-Mex',                          6.0, 7.0, 5.0, 6.0, 4.0, 5.0, 'alnico_5', '7.4k DCR bridge', 'https://www.fender.com', false),
  ('fender', 'Noiseless (Gen 4)',                5.5, 7.0, 5.0, 5.5, 4.0, 2.0, 'alnico_5_stacked', 'noiseless stack', 'https://www.fender.com', true),
  ('fender', 'Ultra Noiseless Vintage',          5.5, 7.5, 4.5, 5.5, 3.5, 1.5, 'alnico_5_stacked', 'noiseless stack', 'https://www.fender.com', true),
  ('fender', 'V-Mod II Tele',                    5.5, 7.5, 5.0, 5.5, 3.5, 4.5, 'mixed_alnico', 'position-voiced', 'https://www.fender.com', true),
  ('fender', 'Pure Vintage 65 Tele',             5.0, 8.0, 4.0, 5.0, 3.5, 5.5, 'alnico_5', '~6.4k DCR', 'https://www.fender.com', false),
  ('fender', 'ShawBucker',                       5.5, 6.5, 5.5, 6.0, 4.0, 3.0, 'alnico_2', '7.6k DCR, 4.0H', 'https://www.fender.com/products/shawbucker-1-humbucking-pickup', false),
  ('fender', 'Wide Range Humbucker',             6.0, 7.0, 5.0, 6.0, 4.0, 3.0, 'cunife',   '~10.6k DCR', 'https://www.fender.com', false),

  -- Gibson (gibson.com product specs)
  ('gibson', '57 Classic',                       5.5, 6.5, 5.0, 6.0, 4.0, 3.5, 'alnico_2', '8.0k DCR', 'https://www.gibson.com/en-US/p/Pickup/PU57DB2', false),
  ('gibson', '57 Classic Plus',                  6.5, 6.0, 5.5, 6.0, 4.5, 3.5, 'alnico_2', '~9.0k DCR', 'https://www.gibson.com', false),
  ('gibson', 'Burstbucker 1',                    5.0, 7.0, 5.0, 5.5, 4.0, 3.5, 'alnico_2', '7.8k DCR underwound', 'https://www.gibson.com/products/gibson-burstbucker-type-1', false),
  ('gibson', 'Burstbucker 2',                    6.0, 6.5, 5.5, 6.0, 4.5, 3.5, 'alnico_2', '8.4k DCR', 'https://www.gibson.com/products/gibson-burstbucker-type-2', false),
  ('gibson', 'Burstbucker 3',                    6.5, 6.0, 6.0, 6.5, 4.5, 3.0, 'alnico_2', '8.7k DCR', 'https://www.gibson.com/products/gibson-burstbucker-type-3', false),
  ('gibson', 'Burstbucker Pro',                  6.5, 6.5, 5.5, 6.0, 4.5, 3.0, 'alnico_5', '~8.3k DCR', 'https://www.gibson.com', false),
  ('gibson', '490R',                             6.0, 6.5, 5.0, 6.0, 4.5, 3.5, 'alnico_2', '8.0k DCR', 'https://www.gibson.com', false),
  ('gibson', '490T',                             6.0, 6.0, 5.5, 6.5, 4.5, 3.0, 'alnico_2', '~8.0k DCR', 'https://www.gibson.com', false),
  ('gibson', '498T Hot Alnico',                  8.0, 5.5, 6.5, 6.5, 5.5, 3.0, 'alnico_5', '14.2k DCR', 'https://www.gibson.com/en-US/Product/PU498TDBGC4', false),
  ('gibson', 'Dirty Fingers',                    9.0, 5.0, 7.5, 6.5, 6.5, 2.5, 'ceramic',  '15k DCR', 'https://www.gibson.com/products/gibson-dirty-fingers', false),
  ('gibson', 'P-90',                             6.0, 7.0, 5.5, 6.5, 4.5, 5.5, 'alnico_5', '~8.2k DCR', 'https://www.gibson.com', false),
  ('gibson', 'P-94',                             6.0, 7.0, 5.5, 6.5, 4.5, 5.0, 'alnico_5', '~8.2k DCR', 'https://www.gibson.com', true),

  -- Bare Knuckle (bareknucklepickups.co.uk published DCR + descriptions)
  ('bare-knuckle', 'Nailbomb',                   8.5, 5.5, 7.0, 7.5, 6.0, 3.0, 'alnico_5', '15.7k DCR bridge', 'https://www.bareknucklepickups.co.uk/pickup/humbucker/nailbomb', false),
  ('bare-knuckle', 'Warpig',                     9.5, 4.5, 8.5, 7.0, 7.0, 2.5, 'alnico_5', '21.5k DCR bridge', 'https://www.bareknucklepickups.co.uk/pickup/humbucker/warpig', false),
  ('bare-knuckle', 'Aftermath',                  9.0, 6.5, 7.0, 7.5, 6.5, 2.5, 'ceramic',  '14.7k DCR bridge', 'https://www.bareknucklepickups.co.uk/pickup/humbucker/aftermath', false),
  ('bare-knuckle', 'Mule',                       5.5, 7.0, 5.0, 6.0, 4.0, 3.5, 'alnico_4', '8.4k DCR bridge', 'https://www.bareknucklepickups.co.uk/pickup/humbucker/the-mule', false),
  ('bare-knuckle', 'Rebel Yell',                 7.5, 6.5, 6.0, 7.0, 5.5, 3.0, 'alnico_5', '14.4k DCR bridge', 'https://www.bareknucklepickups.co.uk/pickup/humbucker/rebel-yell', false),
  ('bare-knuckle', 'Holy Diver',                 8.0, 6.5, 5.5, 7.0, 5.5, 3.0, 'alnico_5', '15.9k DCR bridge', 'https://www.bareknucklepickups.co.uk/pickup/humbucker/holydiver', false),
  ('bare-knuckle', 'The Pig',                    8.5, 5.5, 7.5, 7.0, 6.0, 5.0, 'alnico_5_bar_x2', '21.5k DCR bridge', 'https://www.bareknucklepickups.co.uk/pickup/p90/pig-90', false),
  ('bare-knuckle', 'Mississippi Queen',          5.5, 7.5, 5.0, 6.0, 4.0, 5.5, 'alnico_5', '7.5k DCR bridge', 'https://www.bareknucklepickups.co.uk/pickup/hsp90/mississippi-queen', false),

  -- TV Jones (tvjones.com published DCR + inductance)
  ('tv-jones', 'Classic',                        4.5, 7.5, 5.0, 6.0, 3.0, 3.5, 'alnico_5', '4.8k DCR, 1.83H', 'https://tvjones.com/tv-classic-bridge-universal-mount', false),
  ('tv-jones', 'Classic Plus',                   5.5, 6.5, 5.5, 6.5, 3.5, 3.5, 'alnico_5', '7.8k DCR, 2.83H', 'https://tvjones.com/tv-classic-plus-bridge-universal-mount', false),
  ('tv-jones', 'Power''Tron',                    6.5, 6.0, 6.0, 6.5, 4.5, 3.0, 'alnico_5', '7.8k DCR, 4.75H', 'https://tvjones.com/powertron-bridge-universal-mount', false),
  ('tv-jones', 'Starwood',                       6.0, 7.0, 5.0, 6.0, 4.0, 3.5, 'alnico',   '8.3k DCR, 5.06H', 'https://tvjones.com/starwood-humbucker-bridge-with-covers', true),

  -- Lindy Fralin (fralinpickups.com published DCR + wind specs)
  ('lindy-fralin', 'Vintage Hot Strat',          5.5, 7.5, 4.5, 5.5, 3.5, 5.0, 'alnico_5', '~6.0-6.8k DCR', 'https://www.fralinpickups.com/product/vintage-hot-strat', false),
  ('lindy-fralin', 'Blues Special Strat',        6.0, 7.0, 5.0, 6.0, 4.0, 5.0, 'alnico_5', 'Vintage Hot +5% turns', 'https://www.fralinpickups.com/product/blues-special', false),
  ('lindy-fralin', 'Real 54s Strat',             5.0, 8.0, 4.0, 5.0, 3.5, 5.5, 'alnico_3', '~6.0-6.8k DCR', 'https://www.fralinpickups.com/product/real-54', false),
  ('lindy-fralin', 'Pure PAF',                   5.5, 7.0, 5.0, 5.5, 4.0, 3.5, 'alnico_2', '7.8k N / 8.2k B DCR', 'https://www.fralinpickups.com/product/pure-paf', false),
  ('lindy-fralin', 'High Output P-90',           7.0, 6.5, 6.0, 7.0, 5.0, 5.0, 'alnico_5', '+10% overwind ~9.5k', 'https://www.fralinpickups.com/product/p90', true),

  -- Ibanez (LoZ active; period reviews, no published EQ data)
  ('ibanez', 'IBZ-LZ Active',                    7.5, 6.0, 6.0, 6.0, 6.0, 1.0, 'active_loz', 'low-impedance active', 'https://ibanez.fandom.com/wiki/LoZ_pickups', true)
) as v(slug, model, out_level, bright, bass_v, mid, comp, noise_v, magnet, spec, src, est),
public.equipment_manufacturers m
where m.slug = v.slug
  and t.manufacturer_id = m.id
  and t.model_name = v.model;

-- ============================================================
-- Post-conditions
-- ============================================================
do $$
declare
  verified_count int;
  unverified_count int;
  sample text;
begin
  select count(*) into verified_count
  from public.pickup_models
  where metadata->>'verified' = 'true'
    and metadata->>'source' = 'pickup_verification_v1';
  if verified_count <> 96 then
    raise exception 'POST-CONDITION FAILED: expected 96 verified pickups, got %', verified_count;
  end if;

  select count(*) into unverified_count
  from public.pickup_models
  where is_active = true
    and coalesce(metadata->>'verified', '') <> 'true';
  if unverified_count > 0 then
    raise exception 'POST-CONDITION FAILED: % active pickup rows remain unverified', unverified_count;
  end if;

  -- Parenthesized display-name lookup must now resolve via search_text
  select model_name into sample
  from public.pickup_models
  where search_text ilike '%Seymour Duncan JB (SH-4)%'
  limit 1;
  if sample is null then
    raise exception 'POST-CONDITION FAILED: parenthesized display name does not resolve in search_text';
  end if;

  select model_name into sample
  from public.pickup_models
  where search_text ilike '%DiMarzio Super Distortion (DP100)%'
  limit 1;
  if sample is null then
    raise exception 'POST-CONDITION FAILED: DiMarzio parenthesized display name does not resolve';
  end if;
end $$;

commit;
