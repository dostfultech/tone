-- Pedal behavior verification v1 (2026-08-06).
-- Until now every pedal_models row had gain_change=0 / eq_influence={} /
-- compression=0 / noise=0 — the engine only ever used the generic type switch.
-- This migration:
--   1. Backfills pedal_type_id where null (engine reads pedal_type_id).
--   2. Seeds per-model verified behavior for ~190 iconic drive-family pedals,
--      grounded in documented circuit behavior (ElectroSmash analyses,
--      manufacturer product pages/manuals, published reviews).
--   3. Applies category-physics defaults to every remaining active pedal so
--      all rows carry behavior values + provenance.
-- Value semantics (rule engine, lib/rule-engine/rules.ts pedalContribution):
--   gain_change: delta on 0-10 amp gain knob (clamped ±2.5/pedal)
--   eq_influence: jsonb ToneDeltas {bass, middle, treble, presence}
--   compression: 0-1.5 delta; noise: raw 0-10 floor (noiseGate = noise/4, cap 1.5)
begin;

-- ============================================================
-- 1. Backfill pedal_type_id so the engine type stage fires everywhere
-- ============================================================
update public.pedal_models t
set pedal_type_id = t.pedal_type
where t.pedal_type_id is null
  and t.pedal_type is not null
  and exists (select 1 from public.pedal_types pt where pt.id = t.pedal_type);

-- ============================================================
-- 2. Per-model verified behavior (drive family)
-- ============================================================
update public.pedal_models t
set gain_change  = v.gain_c,
    eq_influence = v.eq::jsonb,
    compression  = v.comp,
    noise        = v.noise_v,
    metadata = t.metadata || jsonb_build_object(
      'verified', true,
      'source', 'pedal_verification_v1',
      'version', 1,
      'estimate', v.est
    )
from (values
  -- Boss (boss.info + ElectroSmash DS-1/TS analyses)
  ('Boss', 'DS-1 Distortion',            1.75, '{"bass":0.25,"middle":-0.75,"treble":0.5}',  0.75, 4.0, false),
  ('Boss', 'DS-1X Distortion',           1.75, '{"bass":0.5,"middle":-0.25,"treble":0.25}',  0.75, 3.0, false),
  ('Boss', 'DS-2 Turbo Distortion',      1.75, '{"middle":-0.5,"treble":0.5}',               0.8,  4.0, false),
  ('Boss', 'MT-2 Metal Zone',            2.4,  '{"bass":0.75,"middle":-1.25,"treble":0.75}', 1.0,  6.0, false),
  ('Boss', 'MT-2W Metal Zone',           2.4,  '{"bass":0.75,"middle":-1.0,"treble":0.5}',   1.0,  5.0, false),
  ('Boss', 'SD-1 Super OverDrive',       1.1,  '{"bass":-0.5,"middle":0.75,"treble":0.25}',  0.5,  2.0, false),
  ('Boss', 'BD-2 Blues Driver',          1.0,  '{"bass":-0.25,"treble":0.75}',               0.35, 2.0, false),
  ('Boss', 'BD-2W Blues Driver',         1.1,  '{"bass":0.25,"treble":0.5}',                 0.4,  2.0, false),
  ('Boss', 'OD-3 OverDrive',             1.25, '{"middle":0.5,"treble":0.25}',               0.5,  2.0, false),
  ('Boss', 'OS-2 OverDrive/Distortion',  1.5,  '{"middle":0.25,"treble":0.25}',              0.6,  3.0, false),
  ('Boss', 'JB-2 Angry Driver',          1.5,  '{"middle":0.5,"treble":0.5}',                0.5,  3.0, false),
  ('Boss', 'ML-2 Metal Core',            2.5,  '{"bass":1.0,"middle":-1.25,"treble":0.5}',   1.0,  6.0, false),
  ('Boss', 'ST-2 Power Stack',           1.75, '{"middle":0.5,"presence":0.5}',              0.7,  4.0, false),
  ('Boss', 'FZ-1W Fuzz',                 2.0,  '{"middle":-0.25,"treble":0.25}',             1.1,  6.0, false),
  ('Boss', 'CS-3 Compression Sustainer', 0.25, '{"bass":-0.25,"treble":0.25}',               1.3,  2.0, false),
  ('Boss', 'CP-1X Compressor',           0.25, '{}',                                          1.2,  1.0, false),
  -- Ibanez / Maxon Tube Screamer family (ElectroSmash TS analysis, maxonfx.com)
  ('Ibanez', 'TS808 Tube Screamer',      1.0,  '{"bass":-0.5,"middle":0.75}',                0.5,  2.0, false),
  ('Ibanez', 'TS9 Tube Screamer',        1.0,  '{"bass":-0.5,"middle":0.75,"treble":0.25}',  0.5,  2.0, false),
  ('Ibanez', 'TS9DX Turbo Tube Screamer',1.25, '{"bass":-0.25,"middle":0.75}',               0.55, 2.0, false),
  ('Ibanez', 'TS808DX Overdrive Pro',    1.25, '{"bass":-0.5,"middle":0.75}',                0.5,  2.0, false),
  ('Ibanez', 'Tube Screamer Mini',       1.0,  '{"bass":-0.5,"middle":0.75}',                0.5,  2.0, false),
  ('Ibanez', 'TS808HW Tube Screamer Hand-Wired', 1.0, '{"bass":-0.5,"middle":0.75}',         0.5,  2.0, true),
  ('Maxon', 'OD808',                     1.0,  '{"bass":-0.5,"middle":0.75}',                0.5,  2.0, false),
  ('Maxon', 'OD820',                     1.1,  '{"bass":0.25,"middle":0.5}',                 0.45, 2.0, false),
  ('Maxon', 'OD9 Overdrive',             1.0,  '{"bass":-0.5,"middle":0.75}',                0.5,  2.0, false),
  ('Maxon', 'OD-9 Overdrive',            1.0,  '{"bass":-0.5,"middle":0.75}',                0.5,  2.0, true),
  ('Maxon', 'SD9 Sonic Distortion',      1.75, '{"middle":0.25,"treble":0.5}',               0.7,  4.0, false),
  ('Maxon', 'SD-9 Sonic Distortion',     1.75, '{"middle":0.25,"treble":0.5}',               0.7,  4.0, true),
  ('Maxon', 'SM9 Super Metal',           2.1,  '{"bass":0.5,"middle":-0.5,"treble":0.5}',    0.9,  5.0, true),
  ('DigiTech', 'Bad Monkey',             1.0,  '{"middle":0.5}',                              0.5,  2.0, false),
  ('DOD', '250 Overdrive Preamp',        1.4,  '{"bass":-0.25,"middle":0.5,"treble":0.25}',  0.5,  4.0, false),
  ('DOD', 'Overdrive Preamp 250 Reissue',1.4,  '{"bass":-0.25,"middle":0.5,"treble":0.25}',  0.5,  4.0, true),
  ('DOD', 'FX69B Grunge',                2.25, '{"bass":0.75,"middle":-1.25,"treble":0.75}', 1.0,  6.0, false),
  ('DOD', 'FX86B Death Metal',           2.5,  '{"bass":1.0,"middle":-1.5,"treble":0.75}',   1.0,  7.0, false),
  ('DOD', 'Yngwie Malmsteen YJM308',     1.5,  '{"bass":-0.5,"middle":0.5,"treble":0.5}',    0.5,  5.0, false),
  ('Pro Co', 'RAT 2',                    1.9,  '{"middle":0.25,"treble":-0.5}',              0.85, 4.0, false),
  ('Pro Co', 'FAT RAT',                  1.9,  '{"bass":0.5,"treble":-0.5}',                 0.8,  4.0, false),
  ('Pro Co', 'Deucetone RAT',            2.0,  '{"treble":-0.5}',                             0.85, 4.0, false),
  -- MXR / Dunlop / Way Huge (jimdunlop.com pages + manuals)
  ('MXR', 'Distortion+',                 1.5,  '{"treble":-0.5}',                             0.75, 4.0, false),
  ('MXR', 'Distortion III',              1.5,  '{"treble":-0.25}',                            0.6,  4.0, false),
  ('MXR', 'Super Badass Distortion',     1.75, '{}',                                          0.75, 4.0, false),
  ('MXR', 'Fullbore Metal',              2.5,  '{"middle":-1.0,"presence":0.5}',             1.0,  5.0, false),
  ('MXR', 'Micro Amp',                   0.75, '{}',                                          0.1,  1.0, false),
  ('MXR', 'Dyna Comp',                   0.25, '{"treble":-0.25}',                            1.25, 2.0, false),
  ('MXR', 'Dyna Comp Mini',              0.25, '{"treble":-0.25}',                            1.25, 2.0, false),
  ('MXR', 'Timmy Overdrive',             1.0,  '{}',                                          0.4,  2.0, false),
  ('MXR', 'Sugar Drive',                 1.0,  '{"treble":0.25,"middle":0.25}',              0.4,  2.0, false),
  ('MXR', 'GT-OD',                       1.0,  '{}',                                          0.5,  2.0, false),
  ('MXR', 'Double-Double Overdrive',     1.5,  '{"middle":0.5}',                              0.6,  3.0, false),
  ('MXR', 'Custom Badass Modified O.D.', 1.25, '{"middle":0.5,"bass":0.25}',                 0.6,  3.0, false),
  ('MXR', 'Classic 108 Fuzz',            2.0,  '{"treble":0.25}',                             1.1,  6.0, false),
  ('MXR', 'Classic 108 Fuzz Mini',       2.0,  '{"treble":0.25}',                             1.1,  6.0, true),
  ('MXR', 'Octavio Fuzz',                2.0,  '{"treble":0.5,"bass":-0.5}',                 1.1,  6.0, false),
  ('MXR', 'Studio Compressor',           0.25, '{}',                                          1.3,  1.0, false),
  ('Dunlop', 'Jimi Hendrix Fuzz Face',   1.75, '{"bass":0.25}',                               1.1,  6.0, false),
  ('Dunlop', 'Germanium Fuzz Face Mini', 1.5,  '{"treble":-0.5,"bass":0.25}',                1.0,  5.0, false),
  ('Dunlop', 'Silicon Fuzz Face Mini',   2.0,  '{"treble":0.5}',                              1.1,  6.0, false),
  ('Dunlop', 'Band of Gypsys Fuzz Face Mini', 2.0, '{"treble":0.25,"bass":0.25}',            1.1,  6.0, false),
  ('Dunlop', 'Joe Bonamassa Fuzz Face Mini', 1.5, '{"treble":-0.5,"bass":0.25}',             1.0,  5.0, true),
  ('Dunlop', 'Octavio Mini',             2.0,  '{"treble":0.5,"bass":-0.5}',                 1.1,  6.0, true),
  ('Dunlop', 'Echoplex Preamp',          0.75, '{"middle":0.25}',                             0.25, 1.0, false),
  ('Way Huge', 'Swollen Pickle',         2.25, '{"middle":-1.25,"bass":0.75}',               1.25, 6.0, false),
  ('Way Huge', 'Swollen Pickle Jumbo Fuzz MkIIS', 2.25, '{"middle":-1.25,"bass":0.75}',      1.25, 6.0, true),
  ('Way Huge', 'Smalls Swollen Pickle Jumbo Fuzz MkIII', 2.25, '{"middle":-1.25,"bass":0.75}', 1.25, 6.0, true),
  ('Way Huge', 'Red Llama',              1.5,  '{"treble":0.25}',                             0.5,  3.0, false),
  ('Way Huge', 'Red Llama 25th Anniversary', 1.5, '{"treble":0.25}',                          0.5,  3.0, true),
  ('Way Huge', 'Smalls Red Llama MkIII', 1.5,  '{"treble":0.25}',                             0.5,  3.0, true),
  ('Way Huge', 'Green Rhino MkV',        1.25, '{"middle":0.5,"bass":0.25}',                 0.6,  3.0, false),
  ('Way Huge', 'Green Rhino',            1.25, '{"middle":0.5,"bass":0.25}',                 0.6,  3.0, true),
  ('Way Huge', 'Smalls Green Rhino MkIV',1.25, '{"middle":0.5,"bass":0.25}',                 0.6,  3.0, true),
  ('Way Huge', 'Pork Loin',              1.0,  '{"treble":-0.5,"bass":0.25}',                0.5,  2.0, true),
  ('Way Huge', 'Smalls Pork Loin',       1.0,  '{"treble":-0.5,"bass":0.25}',                0.5,  2.0, true),
  ('Way Huge', 'Saucy Box',              1.0,  '{}',                                          0.4,  2.0, true),
  ('Way Huge', 'Smalls Saucy Box',       1.0,  '{}',                                          0.4,  2.0, true),
  ('Way Huge', 'Angry Troll',            1.0,  '{}',                                          0.25, 2.0, false),
  ('Way Huge', 'Smalls Angry Troll',     1.0,  '{}',                                          0.25, 2.0, true),
  ('Way Huge', 'Fat Sandwich',           1.75, '{"middle":-0.5}',                             0.8,  4.0, true),
  ('Way Huge', 'Smalls Fat Sandwich',    1.75, '{"middle":-0.5}',                             0.8,  4.0, true),
  -- Electro-Harmonix (ehx.com pages, Aion FX / Wampler DIY circuit docs)
  ('Electro-Harmonix', 'Big Muff Pi',            2.0,  '{"middle":-1.0,"bass":0.5}',         1.2,  6.0, false),
  ('Electro-Harmonix', 'Triangle Big Muff Pi',   2.0,  '{"middle":-0.75,"bass":0.75}',       1.1,  6.0, false),
  ('Electro-Harmonix', 'Op-Amp Big Muff Pi',     2.0,  '{"middle":-0.75,"treble":0.25}',     1.0,  5.0, false),
  ('Electro-Harmonix', 'Sovtek Deluxe Big Muff Pi', 2.0, '{"middle":-0.75,"bass":0.75}',     1.2,  5.0, false),
  ('Electro-Harmonix', 'Nano Big Muff Pi',       2.0,  '{"middle":-1.0,"bass":0.5}',         1.2,  6.0, false),
  ('Electro-Harmonix', 'Metal Muff with Noise Gate', 2.25, '{"middle":-1.0,"treble":0.5}',   0.9,  5.0, false),
  ('Electro-Harmonix', 'Nano Metal Muff',        2.25, '{"middle":-1.0,"treble":0.5}',       0.9,  5.0, false),
  ('Electro-Harmonix', 'Soul Food',              1.0,  '{"treble":0.5}',                      0.4,  2.0, false),
  ('Electro-Harmonix', 'East River Drive',       1.0,  '{"middle":0.75,"bass":-0.5}',        0.6,  2.0, false),
  ('Electro-Harmonix', 'Crayon',                 1.0,  '{}',                                  0.5,  2.0, false),
  ('Electro-Harmonix', 'Hot Wax',                1.5,  '{"middle":0.25}',                     0.6,  3.0, false),
  ('Electro-Harmonix', 'OD Glove',               1.5,  '{"middle":0.5}',                      0.6,  3.0, false),
  ('Electro-Harmonix', 'Satisfaction Plus Fuzz', 1.75, '{"treble":0.25,"bass":-0.25}',       1.0,  6.0, false),
  ('Electro-Harmonix', 'Lizard Queen Octave Fuzz', 1.75, '{"treble":0.25}',                  1.0,  6.0, false),
  ('Electro-Harmonix', 'Tone Corset Analog Compressor', 0.25, '{}',                           1.2,  1.0, false),
  -- Klon-family (ElectroSmash Klon analysis)
  ('Klon', 'Klon Centaur',               1.0,  '{"middle":0.5,"treble":0.5}',                0.4,  2.0, false),
  ('Klon', 'Klon Centaur Gold',          1.0,  '{"middle":0.5,"treble":0.5}',                0.4,  2.0, true),
  ('Klon', 'Klon Centaur Silver',        1.0,  '{"middle":0.5,"treble":0.5}',                0.4,  2.0, true),
  ('Klon', 'KTR',                        1.0,  '{"middle":0.5,"treble":0.5}',                0.4,  2.0, false),
  -- Analog Man (analog.man)
  ('Analog Man', 'King of Tone',         1.0,  '{"treble":0.25}',                             0.35, 2.0, false),
  ('Analog Man', 'Prince of Tone',       1.1,  '{"treble":0.25}',                             0.4,  2.0, false),
  ('Analog Man', 'Sun Face NKT275',      1.75, '{"bass":0.5,"treble":-0.5}',                 1.1,  6.0, false),
  ('Analog Man', 'Sun Face',             1.75, '{"bass":0.5,"treble":-0.5}',                 1.1,  6.0, true),
  ('Analog Man', 'Sun Face BC108',       2.0,  '{"treble":0.5}',                              1.1,  6.0, true),
  ('Analog Man', 'Bi-CompROSSor',        0.25, '{"treble":-0.25}',                            1.4,  2.0, true),
  ('Analog Man', 'TS9 Silver Mod',       1.0,  '{"bass":-0.25,"middle":0.5}',                0.5,  2.0, true),
  -- Fulltone
  ('Fulltone', 'OCD',                    1.5,  '{"bass":0.25,"treble":0.5,"presence":0.25}', 0.5,  3.0, false),
  ('Fulltone', 'Full-Drive 2 MOSFET',    1.25, '{"middle":0.75,"bass":-0.5,"treble":0.25}',  0.6,  3.0, true),
  -- Wampler (wamplerpedals.com)
  ('Wampler', 'Tumnus',                  1.0,  '{"middle":0.5,"treble":0.5}',                0.4,  2.0, false),
  ('Wampler', 'Tumnus Deluxe',           1.1,  '{"middle":0.5,"treble":0.5}',                0.4,  2.0, false),
  ('Wampler', 'Euphoria',                1.25, '{"middle":0.5,"treble":-0.25}',              0.6,  2.0, false),
  ('Wampler', 'Pantheon',                1.25, '{"treble":0.25,"presence":0.25}',            0.5,  3.0, false),
  ('Wampler', 'Pantheon Deluxe',         1.25, '{"treble":0.25,"presence":0.25}',            0.5,  3.0, true),
  ('Wampler', 'Plexi-Drive',             1.5,  '{"middle":0.5,"presence":0.5,"bass":-0.25}', 0.5,  4.0, false),
  ('Wampler', 'Plexi-Drive Deluxe',      1.5,  '{"middle":0.5,"presence":0.5,"bass":-0.25}', 0.5,  4.0, true),
  ('Wampler', 'Dracarys',                2.25, '{"bass":0.5,"middle":-0.5,"presence":0.5}',  0.9,  6.0, false),
  ('Wampler', 'Pinnacle Deluxe',         2.0,  '{"middle":0.5,"presence":0.5}',              0.8,  5.0, false),
  ('Wampler', 'Ego Compressor',          0.25, '{}',                                          1.3,  1.5, false),
  ('Wampler', 'Paisley Drive',           1.25, '{"middle":0.5,"treble":0.25}',               0.5,  2.0, false),
  -- JHS (jhspedals.info)
  ('JHS', 'Morning Glory V4',            1.0,  '{"treble":0.5}',                              0.35, 2.0, false),
  ('JHS', 'Angry Charlie V3',            2.0,  '{"middle":0.5,"presence":0.5,"bass":-0.25}', 0.75, 5.0, false),
  ('JHS', 'Bonsai',                      1.25, '{"middle":0.75,"bass":-0.5}',                0.6,  3.0, false),
  ('JHS', 'Muffuletta',                  2.0,  '{"bass":0.5,"middle":-0.75,"treble":0.25}',  1.1,  6.0, false),
  ('JHS', 'PackRat',                     1.9,  '{"middle":0.25,"treble":-0.5,"bass":-0.25}', 0.85, 5.0, false),
  ('JHS', 'Double Barrel V4',            1.5,  '{"middle":0.5,"treble":0.25}',               0.6,  3.0, false),
  ('JHS', '3 Series Overdrive',          1.25, '{"middle":0.5,"bass":-0.25}',                0.5,  2.0, false),
  -- Keeley (robertkeeley.com)
  ('Keeley', 'Noble Screamer',           1.25, '{"middle":0.5}',                              0.5,  2.0, false),
  ('Keeley', 'Katana Clean Boost',       0.75, '{"treble":0.25}',                             0.15, 1.0, false),
  ('Keeley', 'Compressor Plus',          0.25, '{"treble":0.25}',                             1.3,  1.5, false),
  ('Keeley', 'D&M Drive',                1.5,  '{"middle":0.5,"treble":0.25}',               0.55, 3.0, false),
  ('Keeley', 'Oxblood',                  1.1,  '{"middle":0.5,"treble":0.5}',                0.4,  2.0, false),
  -- Xotic (xotic.us)
  ('Xotic', 'EP Booster',                0.75, '{"treble":0.5,"bass":0.25}',                 0.2,  1.0, false),
  ('Xotic', 'RC Booster V2',             0.75, '{}',                                          0.2,  1.0, false),
  ('Xotic', 'AC Booster V2',             1.0,  '{"middle":0.5}',                              0.4,  2.0, false),
  ('Xotic', 'BB Preamp V1.5',            1.4,  '{"middle":0.75,"treble":0.25}',              0.55, 3.0, false),
  ('Xotic', 'SL Drive',                  1.5,  '{"middle":0.5,"presence":0.5}',              0.55, 4.0, false),
  ('Xotic', 'SP Compressor',             0.25, '{}',                                          1.2,  1.5, false),
  -- EarthQuaker Devices (earthquakerdevices.com)
  ('EarthQuaker Devices', 'Plumes',          1.2,  '{"middle":0.5,"bass":-0.25}',            0.5,  2.0, false),
  ('EarthQuaker Devices', 'Westwood',        1.0,  '{"treble":0.25}',                         0.45, 2.0, false),
  ('EarthQuaker Devices', 'Acapulco Gold',   2.25, '{"bass":0.75,"middle":0.25,"treble":0.25}', 1.0, 6.0, false),
  ('EarthQuaker Devices', 'Hoof',            2.0,  '{"bass":0.5,"middle":-0.5,"treble":0.25}', 1.1, 6.0, false),
  ('EarthQuaker Devices', 'Hizumitas',       2.1,  '{"bass":0.5,"middle":0.25,"treble":0.25}', 1.15, 6.0, false),
  ('EarthQuaker Devices', 'Special Cranker', 1.0,  '{"middle":0.25}',                         0.4,  2.0, false),
  -- Strymon (strymon.net)
  ('Strymon', 'Riverside',               1.5,  '{"middle":0.25,"presence":0.25}',            0.6,  3.0, false),
  ('Strymon', 'Sunset',                  1.5,  '{"middle":0.5}',                              0.6,  3.0, false),
  ('Strymon', 'Compadre',                0.5,  '{}',                                          1.2,  1.5, false),
  -- Walrus Audio (walrusaudio.com)
  ('Walrus Audio', '385 Overdrive MKII', 1.25, '{"middle":0.25,"treble":0.25}',              0.55, 3.0, false),
  ('Walrus Audio', 'Iron Horse V3',      1.9,  '{"middle":0.25,"treble":-0.5}',              0.85, 5.0, false),
  ('Walrus Audio', 'Ages',               1.25, '{"middle":0.25}',                             0.5,  3.0, false),
  ('Walrus Audio', 'Warhorn',            1.1,  '{"middle":0.5}',                              0.5,  2.0, false),
  ('Walrus Audio', 'Deep Six V3',        0.25, '{}',                                          1.4,  1.5, false),
  -- Friedman (friedmanamplification.com)
  ('Friedman', 'BE-OD',                  2.25, '{"bass":-0.25,"middle":0.5,"treble":0.5,"presence":0.5}', 0.9, 6.0, false),
  ('Friedman', 'BE-OD Deluxe',           2.4,  '{"bass":-0.25,"middle":0.5,"treble":0.5,"presence":0.5}', 0.95, 6.0, false),
  ('Friedman', 'BE-OD Deluxe Pedal',     2.4,  '{"bass":-0.25,"middle":0.5,"treble":0.5,"presence":0.5}', 0.95, 6.0, true),
  ('Friedman', 'Dirty Shirley',          1.25, '{"middle":0.5,"treble":0.25,"presence":0.25}', 0.6, 3.0, false),
  ('Friedman', 'Small Box Distortion',   1.75, '{"bass":-0.25,"middle":0.5,"treble":0.5,"presence":0.25}', 0.7, 4.0, false),
  ('Friedman', 'Small Box',              1.75, '{"bass":-0.25,"middle":0.5,"treble":0.5,"presence":0.25}', 0.7, 4.0, true),
  ('Friedman', 'Smallbox Pedal',         1.75, '{"bass":-0.25,"middle":0.5,"treble":0.5,"presence":0.25}', 0.7, 4.0, true),
  ('Friedman', 'Buxom Betty',            0.5,  '{}',                                          0.15, 1.0, true),
  -- Bogner (bogneramplification.com)
  ('Bogner', 'Ecstasy Red',              2.0,  '{"bass":0.25,"middle":0.5,"treble":0.25,"presence":0.25}', 0.85, 5.0, false),
  ('Bogner', 'Ecstasy Blue',             1.25, '{"middle":0.25,"treble":0.25,"presence":0.25}', 0.6, 3.0, false),
  ('Bogner', 'La Grange',                1.5,  '{"bass":-0.25,"middle":0.5,"treble":0.5,"presence":0.5}', 0.6, 3.0, false),
  ('Bogner', 'La Grange Overdrive',      1.5,  '{"bass":-0.25,"middle":0.5,"treble":0.5,"presence":0.5}', 0.6, 3.0, true),
  ('Bogner', 'Uberschall',               2.5,  '{"bass":0.5,"middle":-0.25,"treble":0.5,"presence":0.5}', 0.95, 7.0, false),
  ('Bogner', 'Uberschall Distortion',    2.5,  '{"bass":0.5,"middle":-0.25,"treble":0.5,"presence":0.5}', 0.95, 7.0, true),
  ('Bogner', 'Harlow Boost',             0.75, '{"treble":0.25}',                             0.5,  1.0, false),
  ('Bogner', 'Harlow',                   0.75, '{"treble":0.25}',                             0.5,  1.0, true),
  ('Bogner', 'Burnley Distortion',       1.75, '{"bass":0.25,"middle":0.5,"treble":0.25}',   0.75, 4.0, false),
  ('Bogner', 'Burnley',                  1.75, '{"bass":0.25,"middle":0.5,"treble":0.25}',   0.75, 4.0, true),
  -- Suhr (suhr.com)
  ('Suhr', 'Riot',                       1.9,  '{"middle":0.5,"treble":0.25}',               0.8,  4.5, false),
  ('Suhr', 'Riot Mini',                  1.9,  '{"middle":0.5,"treble":0.25}',               0.8,  4.5, true),
  ('Suhr', 'Riot Mini V2',               1.9,  '{"middle":0.5,"treble":0.25}',               0.8,  4.5, true),
  ('Suhr', 'Riot Reloaded',              2.1,  '{"middle":0.5,"treble":0.25}',               0.85, 5.0, false),
  ('Suhr', 'Shiba Drive Reloaded',       1.0,  '{"middle":0.25,"treble":-0.25}',             0.6,  2.5, false),
  ('Suhr', 'Shiba Drive',                1.0,  '{"middle":0.25,"treble":-0.25}',             0.6,  2.5, true),
  ('Suhr', 'Koko Boost',                 0.75, '{"middle":0.5}',                              0.15, 1.0, false),
  ('Suhr', 'Koko Boost Mini',            0.75, '{"middle":0.5}',                              0.15, 1.0, true),
  ('Suhr', 'Koko Boost Reloaded',        0.75, '{"middle":0.5}',                              0.15, 1.0, true),
  ('Suhr', 'Eclipse',                    2.0,  '{"middle":0.25,"treble":0.25}',              0.85, 5.0, false),
  ('Suhr', 'Rufus',                      2.0,  '{"bass":0.5,"treble":0.25}',                 1.1,  6.0, false),
  -- Revv (revvamplification.com)
  ('Revv', 'G2',                         1.25, '{"middle":0.25,"treble":0.25}',              0.5,  3.0, false),
  ('Revv', 'G2 Signature',               1.25, '{"middle":0.25,"treble":0.25}',              0.5,  3.0, true),
  ('Revv', 'G3',                         2.25, '{"bass":-0.25,"middle":0.5,"treble":0.25,"presence":0.5}', 0.9, 6.0, false),
  ('Revv', 'G4',                         2.5,  '{"bass":0.25,"middle":0.25,"treble":0.25,"presence":0.5}', 0.95, 6.5, false),
  -- Fortin (fortinamps.com)
  ('Fortin', '33',                       1.0,  '{"bass":-1.0,"middle":0.25,"treble":0.75,"presence":0.5}', 0.2, 1.5, false),
  ('Fortin', 'Grind',                    0.9,  '{"bass":-1.0,"treble":0.75}',                0.2,  1.5, false),
  ('Fortin', 'Natas',                    2.5,  '{"bass":0.25,"middle":-0.25,"treble":0.25,"presence":0.5}', 0.9, 7.0, false),
  ('Fortin', 'Hexdrive',                 1.0,  '{"bass":-0.75,"middle":0.75,"treble":0.25}', 0.4,  2.0, false),
  -- Mesa/Boogie (legacy.mesaboogie.com + published reviews)
  ('Mesa/Boogie', 'Flux-Drive Overdrive',   1.25, '{"middle":0.5,"treble":0.25}',            0.65, 3.0, false),
  ('Mesa/Boogie', 'Grid Slammer Overdrive', 1.0,  '{"middle":0.75,"treble":0.25}',           0.6,  2.5, false),
  ('Mesa/Boogie', 'Grid Slammer',           1.0,  '{"middle":0.75,"treble":0.25}',           0.6,  2.5, true),
  ('Mesa/Boogie', 'Throttle Box Distortion',2.0,  '{"bass":0.25,"middle":-0.5,"treble":0.25}', 0.85, 5.0, false),
  ('Mesa/Boogie', 'Throttle Box',           2.0,  '{"bass":0.25,"middle":-0.5,"treble":0.25}', 0.85, 5.0, true),
  ('Mesa/Boogie', 'Throttle Box EQ',        2.0,  '{"bass":0.25,"middle":-0.5,"treble":0.25}', 0.85, 5.0, true),
  ('Mesa/Boogie', 'Tone Burst',             0.6,  '{}',                                       0.1,  1.0, false),
  ('Mesa/Boogie', 'Tone-Burst Boost',       0.6,  '{}',                                       0.1,  1.0, true),
  -- Diezel (diezelamplification.com)
  ('Diezel', 'VH4 Pedal',                2.4,  '{"bass":0.5,"middle":-0.5,"treble":0.5,"presence":0.5}', 0.9, 6.5, false),
  ('Diezel', 'VH4-2 Pedal',              2.4,  '{"bass":0.5,"middle":-0.5,"treble":0.5,"presence":0.5}', 0.9, 6.5, true),
  ('Diezel', 'Herbert Pedal',            2.5,  '{"bass":0.5,"middle":-0.75,"treble":0.5,"presence":0.5}', 0.9, 7.0, false),
  ('Diezel', 'Zerrer Distortion',        2.25, '{"bass":0.5,"middle":-0.25,"treble":0.25,"presence":0.5}', 0.85, 6.0, false),
  ('Diezel', 'Zerrer',                   2.25, '{"bass":0.5,"middle":-0.25,"treble":0.25,"presence":0.5}', 0.85, 6.0, true),
  -- KHDK (khdkelectronics.com)
  ('KHDK', 'Ghoul Screamer',             1.1,  '{"middle":0.75,"treble":0.25}',              0.6,  2.5, false),
  ('KHDK', 'No. 1',                      1.5,  '{"middle":0.5,"treble":0.25}',               0.65, 3.0, true),
  ('KHDK', 'Dark Blood',                 2.4,  '{"bass":0.25,"middle":0.5,"treble":0.25}',   0.9,  4.5, false),
  -- Catalinbread (catalinbread.com)
  ('Catalinbread', 'Dirty Little Secret',1.5,  '{"bass":-0.25,"middle":0.5,"treble":0.5,"presence":0.5}', 0.6, 3.5, false),
  ('Catalinbread', 'SFT',                1.4,  '{"bass":0.75,"middle":0.25}',                0.65, 3.5, false),
  ('Catalinbread', 'SFT V2',             1.4,  '{"bass":0.75,"middle":0.25}',                0.65, 3.5, true),
  ('Catalinbread', 'Formula 5F6',        1.0,  '{"bass":0.25}',                               0.5,  2.5, false),
  ('Catalinbread', 'Sabbra Cadabra',     1.75, '{"bass":-0.25,"middle":0.5,"treble":0.75}',  0.8,  5.0, false),
  -- Zvex (zvex.com)
  ('Zvex', 'Box of Rock',                1.5,  '{"middle":0.25,"treble":0.25}',              0.6,  3.5, false),
  ('Zvex', 'Vexter Box of Rock',         1.5,  '{"middle":0.25,"treble":0.25}',              0.6,  3.5, true),
  ('Zvex', 'Fuzz Factory',               2.25, '{"bass":0.25,"middle":-0.25,"treble":0.5}',  1.25, 7.0, false),
  ('Zvex', 'Vexter Fuzz Factory',        2.25, '{"bass":0.25,"middle":-0.25,"treble":0.5}',  1.25, 7.0, true),
  ('Zvex', 'Fat Fuzz Factory',           2.25, '{"bass":0.5,"middle":-0.25,"treble":0.25}',  1.25, 7.0, true),
  ('Zvex', 'Vertical Fuzz Factory',      2.25, '{"bass":0.25,"middle":-0.25,"treble":0.5}',  1.25, 7.0, true),
  ('Zvex', 'Woolly Mammoth',             2.0,  '{"bass":1.0,"treble":-0.25}',                1.2,  6.0, false),
  ('Zvex', 'Vexter Woolly Mammoth',      2.0,  '{"bass":1.0,"treble":-0.25}',                1.2,  6.0, true),
  ('Zvex', 'Super Hard On',              0.9,  '{"treble":0.25}',                             0.1,  1.5, false),
  ('Zvex', 'Vexter Super Hard On',       0.9,  '{"treble":0.25}',                             0.1,  1.5, true),
  -- Vox Valvenergy (voxamps.com)
  ('Vox', 'Valvenergy Copperhead Drive', 1.75, '{"middle":0.5,"treble":0.5}',                0.7,  4.0, false),
  ('Vox', 'Valvenergy Mystic Edge',      1.25, '{"bass":-0.25,"middle":-0.25,"treble":0.75}', 0.55, 3.0, false),
  ('Vox', 'Valvenergy Cutting Edge',     2.25, '{"bass":0.5,"middle":-0.75,"treble":0.25,"presence":0.5}', 0.85, 6.0, false),
  ('Vox', 'Valvenergy Silk Drive',       1.0,  '{"middle":0.5,"treble":-0.25}',              0.6,  2.5, false),
  -- Origin Effects (origineffects.com)
  ('Origin Effects', 'Cali76 Compact',   0.1,  '{}',                                          1.3,  1.0, false),
  ('Origin Effects', 'Cali76',           0.1,  '{}',                                          1.3,  1.0, true),
  ('Origin Effects', 'Cali76 Stacked Edition', 0.1, '{}',                                     1.4,  1.0, true),
  ('Origin Effects', 'Cali76 Bass',      0.1,  '{}',                                          1.3,  1.0, true),
  ('Origin Effects', 'RevivalDRIVE Compact', 1.5, '{"bass":0.25,"middle":0.5,"treble":0.25}', 0.6, 3.0, false),
  ('Origin Effects', 'RevivalDRIVE',     1.5,  '{"bass":0.25,"middle":0.5,"treble":0.25}',   0.6,  3.0, true),
  ('Origin Effects', 'RevivalDRIVE Custom', 1.5, '{"bass":0.25,"middle":0.5,"treble":0.25}', 0.6,  3.0, true),
  ('Origin Effects', 'SlideRIG Compact', 0.25, '{}',                                          1.5,  2.0, false),
  ('Origin Effects', 'SlideRIG',         0.25, '{}',                                          1.5,  2.0, true),
  -- TC Electronic (tcelectronic.com)
  ('TC Electronic', 'MojoMojo Overdrive',    1.0,  '{"bass":0.5,"treble":0.25}',             0.5,  2.5, false),
  ('TC Electronic', 'Dark Matter Distortion',1.75, '{"bass":0.25,"middle":0.25,"treble":0.25}', 0.75, 4.5, false),
  ('TC Electronic', 'Spark Booster',         1.0,  '{}',                                      0.2,  1.0, false),
  ('TC Electronic', 'Spark Mini Booster',    1.0,  '{}',                                      0.2,  1.0, true),
  ('TC Electronic', 'HyperGravity Compressor', 0.1, '{}',                                     1.2,  1.0, false),
  -- Fender (fender.com)
  ('Fender', 'Pugilist Distortion',      1.75, '{"bass":0.25}',                               0.75, 4.5, false),
  ('Fender', 'Santa Ana Overdrive',      1.25, '{"middle":0.25,"presence":0.25}',            0.6,  3.0, false),
  ('Fender', 'MTG Tube Distortion',      2.0,  '{"bass":-0.25,"middle":0.25,"treble":0.25}', 0.8,  5.0, false),
  ('Fender', 'The Bends Compressor',     0.1,  '{}',                                          1.1,  1.0, false),
  -- Seymour Duncan (seymourduncan.com)
  ('Seymour Duncan', '805 Overdrive',    1.1,  '{"middle":0.5}',                              0.6,  2.5, false),
  ('Seymour Duncan', 'Palladium Gain Stage V2', 2.4, '{"bass":0.25,"presence":0.5}',         0.9,  6.0, true),
  ('Seymour Duncan', 'Palladium',        2.4,  '{"bass":0.25,"presence":0.5}',               0.9,  6.0, true),
  ('Seymour Duncan', 'Pickup Booster',   0.75, '{}',                                          0.1,  1.0, false),
  ('Seymour Duncan', 'Vise Grip Compressor', 0.1, '{}',                                       1.2,  1.0, false)
) as v(brand_name, model, gain_c, eq, comp, noise_v, est),
public.pedal_brands b
where b.name = v.brand_name
  and t.brand_id = b.id
  and t.model_name = v.model;

-- ============================================================
-- 3. Category-physics defaults for every remaining active pedal
-- ============================================================
update public.pedal_models t
set gain_change  = d.gain_c,
    eq_influence = d.eq::jsonb,
    compression  = d.comp,
    noise        = d.noise_v,
    metadata = t.metadata || jsonb_build_object(
      'verified', true,
      'source', 'pedal_type_defaults_v1',
      'version', 1,
      'estimate', true,
      'basis', 'category-level physics default'
    )
from (values
  ('boost',       0.75, '{"treble":0.25}',               0.2,  1.0),
  ('overdrive',   1.25, '{"middle":0.5}',                0.5,  2.5),
  ('distortion',  1.75, '{}',                            0.75, 4.0),
  ('fuzz',        1.75, '{"middle":-0.5,"bass":0.25}',   1.0,  6.0),
  ('compressor',  0.25, '{}',                            1.25, 1.5),
  ('compression', 0.25, '{}',                            1.25, 1.5),
  ('preamp',      0.75, '{}',                            0.25, 1.5),
  ('eq',          0.0,  '{}',                            0.0,  0.0),
  ('wah',         0.0,  '{"middle":0.5}',                0.0,  0.0),
  ('chorus',      0.0,  '{}',                            0.0,  0.0),
  ('flanger',     0.0,  '{}',                            0.0,  0.0),
  ('phaser',      0.0,  '{}',                            0.0,  0.0),
  ('tremolo',     0.0,  '{}',                            0.0,  0.0),
  ('modulation',  0.0,  '{}',                            0.0,  0.0),
  ('delay',       0.0,  '{}',                            0.0,  0.0),
  ('reverb',      0.0,  '{}',                            0.0,  0.0),
  ('pitch',       0.0,  '{}',                            0.0,  0.0),
  ('octaver',     0.0,  '{}',                            0.0,  1.0),
  ('volume',      0.0,  '{}',                            0.0,  0.0),
  ('utility',     0.0,  '{}',                            0.0,  0.0),
  ('looper',      0.0,  '{}',                            0.0,  0.0),
  ('acoustic',    0.0,  '{}',                            0.0,  0.0),
  ('amp_cab_sim', 0.0,  '{}',                            0.0,  0.0),
  ('noise_gate',  0.0,  '{}',                            0.0,  0.0)
) as d(ptype, gain_c, eq, comp, noise_v)
where coalesce(t.pedal_type_id, t.pedal_type) = d.ptype
  and t.is_active = true
  and coalesce(t.metadata->>'source', '') <> 'pedal_verification_v1';

-- ============================================================
-- Post-conditions
-- ============================================================
do $$
declare
  verified_models int;
  uncovered int;
  ts_gain numeric;
  muff_mid text;
begin
  select count(*) into verified_models
  from public.pedal_models
  where metadata->>'source' = 'pedal_verification_v1';
  if verified_models < 150 then
    raise exception 'POST-CONDITION FAILED: only % per-model verified pedals (expected >= 150)', verified_models;
  end if;

  select count(*) into uncovered
  from public.pedal_models
  where is_active = true
    and coalesce(metadata->>'verified', '') <> 'true';
  if uncovered > 0 then
    raise exception 'POST-CONDITION FAILED: % active pedals lack behavior provenance', uncovered;
  end if;

  select gain_change into ts_gain
  from public.pedal_models t
  join public.pedal_brands b on b.id = t.brand_id
  where b.name = 'Ibanez' and t.model_name = 'TS808 Tube Screamer';
  if ts_gain is distinct from 1.0 then
    raise exception 'POST-CONDITION FAILED: TS808 gain_change is % (expected 1.0)', ts_gain;
  end if;

  select eq_influence->>'middle' into muff_mid
  from public.pedal_models t
  join public.pedal_brands b on b.id = t.brand_id
  where b.name = 'Electro-Harmonix' and t.model_name = 'Big Muff Pi';
  if muff_mid is null or muff_mid::numeric is distinct from -1.0 then
    raise exception 'POST-CONDITION FAILED: Big Muff middle is % (expected -1.0)', muff_mid;
  end if;
end $$;

commit;
