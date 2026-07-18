-- Seed pickup_models with common aftermarket pickups
-- First ensure manufacturers exist for pickup brands

INSERT INTO public.equipment_manufacturers (name, slug, country, is_active)
VALUES
  ('Seymour Duncan', 'seymour-duncan', 'US', true),
  ('DiMarzio', 'dimarzio', 'US', true),
  ('EMG', 'emg', 'US', true),
  ('Fender', 'fender', 'US', true),
  ('Gibson', 'gibson', 'US', true),
  ('Bare Knuckle', 'bare-knuckle', 'GB', true),
  ('Lace', 'lace', 'US', true),
  ('Fishman', 'fishman', 'US', true),
  ('TV Jones', 'tv-jones', 'US', true),
  ('Lindy Fralin', 'lindy-fralin', 'US', true),
  ('Mojotone', 'mojotone', 'US', true),
  ('Porter Pickups', 'porter-pickups', 'US', true)
ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name, country = EXCLUDED.country;

-- Now seed pickup_models
-- Seymour Duncan
INSERT INTO public.pickup_models (manufacturer_id, model_name, pickup_type_id, circuit_type, output_level, brightness, bass, midrange, compression, noise, search_text)
VALUES
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'seymour-duncan'), 'JB (SH-4)', 'humbucker', 'passive', 8.0, 5.5, 6.0, 6.5, 5.0, 3.0, 'Seymour Duncan JB SH-4 humbucker passive'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'seymour-duncan'), '59 (SH-1n)', 'humbucker', 'passive', 5.5, 6.5, 5.0, 6.0, 4.5, 3.5, 'Seymour Duncan 59 SH-1n humbucker passive PAF'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'seymour-duncan'), '59 (SH-1b)', 'humbucker', 'passive', 6.0, 6.0, 5.5, 6.0, 4.5, 3.5, 'Seymour Duncan 59 SH-1b humbucker passive PAF bridge'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'seymour-duncan'), 'Jazz (SH-2n)', 'humbucker', 'passive', 5.0, 7.0, 4.5, 5.5, 4.0, 3.5, 'Seymour Duncan Jazz SH-2n humbucker passive neck'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'seymour-duncan'), 'Pearly Gates (SH-PG1)', 'humbucker', 'passive', 6.5, 7.0, 5.0, 6.5, 5.0, 3.5, 'Seymour Duncan Pearly Gates SH-PG1 humbucker passive'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'seymour-duncan'), 'Custom (SH-5)', 'humbucker', 'passive', 7.5, 5.0, 7.0, 6.0, 5.5, 3.0, 'Seymour Duncan Custom SH-5 humbucker passive'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'seymour-duncan'), 'Custom 5 (SH-14)', 'humbucker', 'passive', 7.5, 5.5, 6.5, 6.0, 5.5, 3.0, 'Seymour Duncan Custom 5 SH-14 humbucker passive'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'seymour-duncan'), 'Distortion (SH-6)', 'humbucker', 'passive', 9.0, 4.5, 7.5, 6.5, 6.5, 2.5, 'Seymour Duncan Distortion SH-6 humbucker passive high output'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'seymour-duncan'), 'Invader (SH-8)', 'humbucker', 'passive', 9.5, 4.0, 8.0, 7.0, 7.0, 2.0, 'Seymour Duncan Invader SH-8 humbucker passive metal'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'seymour-duncan'), 'Full Shred (SH-10)', 'humbucker', 'passive', 8.5, 6.0, 6.5, 6.5, 5.5, 3.0, 'Seymour Duncan Full Shred SH-10 humbucker passive'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'seymour-duncan'), 'Blackout (AHB-1)', 'humbucker', 'active', 9.0, 5.5, 7.0, 6.5, 7.5, 1.5, 'Seymour Duncan Blackout AHB-1 humbucker active metal'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'seymour-duncan'), 'SSL-1 Vintage Staggered', 'single_coil', 'passive', 5.0, 7.5, 4.5, 5.5, 3.5, 5.0, 'Seymour Duncan SSL-1 Vintage Staggered single coil passive strat'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'seymour-duncan'), 'SSL-5 Custom Staggered', 'single_coil', 'passive', 6.5, 6.5, 5.5, 6.0, 4.5, 4.5, 'Seymour Duncan SSL-5 Custom Staggered single coil passive hot'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'seymour-duncan'), 'Quarter Pound (SSL-4)', 'single_coil', 'passive', 8.0, 5.0, 7.0, 5.5, 5.5, 4.0, 'Seymour Duncan Quarter Pound SSL-4 single coil passive hot strat'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'seymour-duncan'), 'Hot Rails (SHR-1)', 'single_coil', 'passive', 8.5, 5.0, 7.0, 6.5, 6.0, 2.5, 'Seymour Duncan Hot Rails SHR-1 single coil sized humbucker'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'seymour-duncan'), 'Little 59 (SL59-1)', 'single_coil', 'passive', 6.0, 6.0, 5.5, 6.0, 4.5, 3.0, 'Seymour Duncan Little 59 SL59-1 single coil sized humbucker'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'seymour-duncan'), 'Antiquity Tele (bridge)', 'single_coil', 'passive', 5.5, 7.0, 4.5, 5.5, 3.5, 5.0, 'Seymour Duncan Antiquity Telecaster bridge single coil passive vintage'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'seymour-duncan'), 'Seth Lover (SH-55)', 'humbucker', 'passive', 5.0, 6.5, 5.0, 5.5, 4.0, 3.5, 'Seymour Duncan Seth Lover SH-55 humbucker passive PAF vintage'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'seymour-duncan'), 'Nazgul (SH-7)', 'humbucker', 'passive', 9.5, 5.5, 7.5, 7.0, 7.0, 2.5, 'Seymour Duncan Nazgul SH-7 humbucker passive metal djent'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'seymour-duncan'), 'Sentient (SH-15)', 'humbucker', 'passive', 5.5, 7.0, 5.0, 6.0, 4.0, 3.5, 'Seymour Duncan Sentient SH-15 humbucker passive neck clean'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'seymour-duncan'), 'Pegasus (SH-PG)', 'humbucker', 'passive', 7.0, 6.0, 6.0, 6.5, 5.0, 3.0, 'Seymour Duncan Pegasus SH-PG humbucker passive progressive metal'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'seymour-duncan'), 'P-Rails (SHPR-1)', 'humbucker', 'passive', 6.0, 6.5, 5.5, 6.0, 4.5, 3.5, 'Seymour Duncan P-Rails SHPR-1 humbucker P90 single coil triple shot'),

  -- DiMarzio
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'dimarzio'), 'Super Distortion (DP100)', 'humbucker', 'passive', 9.0, 4.5, 7.5, 6.5, 6.5, 2.5, 'DiMarzio Super Distortion DP100 humbucker passive high output'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'dimarzio'), 'PAF 36th Anniversary (DP103)', 'humbucker', 'passive', 5.5, 7.0, 5.0, 5.5, 4.0, 3.5, 'DiMarzio PAF 36th Anniversary DP103 humbucker passive vintage'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'dimarzio'), 'Tone Zone (DP155)', 'humbucker', 'passive', 8.5, 5.0, 8.0, 6.5, 6.0, 3.0, 'DiMarzio Tone Zone DP155 humbucker passive rock'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'dimarzio'), 'Air Norton (DP193)', 'humbucker', 'passive', 6.5, 6.5, 5.5, 6.0, 4.5, 3.5, 'DiMarzio Air Norton DP193 humbucker passive neck warm'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'dimarzio'), 'Evolution (DP159)', 'humbucker', 'passive', 8.0, 7.0, 5.5, 7.0, 6.0, 3.0, 'DiMarzio Evolution DP159 humbucker passive Steve Vai'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'dimarzio'), 'Illuminator (DP257)', 'humbucker', 'passive', 7.5, 7.0, 5.5, 7.0, 5.5, 3.0, 'DiMarzio Illuminator DP257 humbucker passive Steve Vai'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'dimarzio'), 'Crunch Lab (DP228)', 'humbucker', 'passive', 8.0, 6.0, 6.5, 7.0, 6.0, 3.0, 'DiMarzio Crunch Lab DP228 humbucker passive John Petrucci'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'dimarzio'), 'LiquiFire (DP227)', 'humbucker', 'passive', 6.5, 6.5, 5.5, 6.0, 4.5, 3.5, 'DiMarzio LiquiFire DP227 humbucker passive John Petrucci neck'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'dimarzio'), 'Norton (DP160)', 'humbucker', 'passive', 7.0, 6.5, 5.5, 6.5, 5.0, 3.0, 'DiMarzio Norton DP160 humbucker passive versatile'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'dimarzio'), 'D Activator (DP219)', 'humbucker', 'passive', 8.5, 6.0, 7.0, 6.5, 6.0, 2.5, 'DiMarzio D Activator DP219 humbucker passive metal'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'dimarzio'), 'Gravity Storm (DP252)', 'humbucker', 'passive', 7.0, 6.5, 6.0, 6.5, 5.0, 3.0, 'DiMarzio Gravity Storm DP252 humbucker passive Guthrie Govan'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'dimarzio'), 'Fred (DP153)', 'humbucker', 'passive', 6.5, 6.5, 5.5, 6.5, 5.0, 3.5, 'DiMarzio Fred DP153 humbucker passive Joe Satriani'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'dimarzio'), 'Area 61 (DP416)', 'single_coil', 'passive', 5.5, 7.0, 4.5, 5.5, 3.5, 2.5, 'DiMarzio Area 61 DP416 single coil passive noiseless strat'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'dimarzio'), 'Virtual Vintage Blues (DP402)', 'single_coil', 'passive', 5.0, 7.5, 4.5, 5.5, 3.5, 2.5, 'DiMarzio Virtual Vintage Blues DP402 single coil passive noiseless'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'dimarzio'), 'HS-3 (DP117)', 'single_coil', 'passive', 5.0, 5.5, 5.0, 5.5, 4.0, 2.0, 'DiMarzio HS-3 DP117 single coil passive noiseless Yngwie'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'dimarzio'), 'Chopper (DP184)', 'single_coil', 'passive', 7.5, 5.5, 6.5, 6.0, 5.5, 2.5, 'DiMarzio Chopper DP184 single coil sized humbucker'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'dimarzio'), 'Twang King (DP172)', 'single_coil', 'passive', 5.0, 8.0, 4.0, 5.0, 3.5, 5.0, 'DiMarzio Twang King DP172 single coil passive tele country'),

  -- EMG
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'emg'), '81', 'humbucker', 'active', 9.0, 6.0, 6.5, 7.0, 8.0, 1.0, 'EMG 81 humbucker active metal high output'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'emg'), '85', 'humbucker', 'active', 8.0, 5.5, 7.0, 6.5, 7.5, 1.0, 'EMG 85 humbucker active warm neck'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'emg'), '60', 'humbucker', 'active', 7.5, 7.0, 5.5, 6.5, 7.0, 1.0, 'EMG 60 humbucker active clean versatile'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'emg'), '57', 'humbucker', 'active', 6.5, 6.5, 6.0, 6.0, 6.5, 1.0, 'EMG 57 humbucker active vintage PAF'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'emg'), '66', 'humbucker', 'active', 7.0, 6.0, 6.5, 6.0, 7.0, 1.0, 'EMG 66 humbucker active warm neck PAF'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'emg'), 'Het Set (81/60)', 'humbucker', 'active', 8.5, 6.0, 6.5, 7.0, 8.0, 1.0, 'EMG Het Set 81 60 humbucker active James Hetfield metal'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'emg'), 'Zakk Wylde Set (81/85)', 'humbucker', 'active', 9.0, 5.5, 7.0, 7.0, 8.0, 1.0, 'EMG Zakk Wylde Set 81 85 humbucker active metal'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'emg'), 'SA', 'single_coil', 'active', 5.5, 7.5, 4.5, 5.5, 6.0, 1.0, 'EMG SA single coil active strat noiseless'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'emg'), 'S', 'single_coil', 'active', 5.0, 7.0, 5.0, 5.5, 6.0, 1.0, 'EMG S single coil active vintage strat'),

  -- Fender
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'fender'), 'Custom Shop 69', 'single_coil', 'passive', 5.0, 7.5, 4.5, 5.0, 3.5, 5.5, 'Fender Custom Shop 69 single coil passive strat vintage Woodstock'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'fender'), 'Custom Shop Fat 50s', 'single_coil', 'passive', 5.5, 7.0, 5.0, 5.5, 3.5, 5.5, 'Fender Custom Shop Fat 50s single coil passive strat vintage'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'fender'), 'Tex-Mex', 'single_coil', 'passive', 6.0, 7.0, 5.0, 6.0, 4.0, 5.0, 'Fender Tex-Mex single coil passive strat hot'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'fender'), 'Noiseless (Gen 4)', 'single_coil', 'passive', 5.5, 7.0, 5.0, 5.5, 4.0, 2.0, 'Fender Noiseless Gen 4 single coil passive strat noiseless'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'fender'), 'Ultra Noiseless Vintage', 'single_coil', 'passive', 5.5, 7.5, 4.5, 5.5, 3.5, 1.5, 'Fender Ultra Noiseless Vintage single coil passive strat noiseless'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'fender'), 'V-Mod II Tele', 'single_coil', 'passive', 5.5, 7.5, 5.0, 5.5, 3.5, 4.5, 'Fender V-Mod II Telecaster single coil passive tele'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'fender'), 'Pure Vintage 65 Tele', 'single_coil', 'passive', 5.0, 8.0, 4.0, 5.0, 3.5, 5.5, 'Fender Pure Vintage 65 Telecaster single coil passive vintage'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'fender'), 'ShawBucker', 'humbucker', 'passive', 6.0, 6.5, 5.5, 6.0, 4.5, 3.0, 'Fender ShawBucker humbucker passive versatile'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'fender'), 'Wide Range Humbucker', 'humbucker', 'passive', 6.0, 7.0, 5.0, 6.0, 4.0, 3.0, 'Fender Wide Range Humbucker humbucker passive tele deluxe vintage'),

  -- Gibson
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'gibson'), '57 Classic', 'humbucker', 'passive', 5.5, 6.5, 5.0, 6.0, 4.0, 3.5, 'Gibson 57 Classic humbucker passive PAF vintage'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'gibson'), '57 Classic Plus', 'humbucker', 'passive', 6.5, 6.0, 5.5, 6.0, 4.5, 3.5, 'Gibson 57 Classic Plus humbucker passive PAF bridge'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'gibson'), 'Burstbucker 1', 'humbucker', 'passive', 5.5, 7.0, 5.0, 5.5, 4.0, 3.5, 'Gibson Burstbucker 1 humbucker passive PAF vintage neck'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'gibson'), 'Burstbucker 2', 'humbucker', 'passive', 6.0, 6.5, 5.5, 6.0, 4.5, 3.5, 'Gibson Burstbucker 2 humbucker passive PAF vintage'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'gibson'), 'Burstbucker 3', 'humbucker', 'passive', 7.0, 6.0, 6.0, 6.5, 5.0, 3.0, 'Gibson Burstbucker 3 humbucker passive PAF hot bridge'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'gibson'), 'Burstbucker Pro', 'humbucker', 'passive', 6.5, 6.5, 5.5, 6.0, 5.0, 3.0, 'Gibson Burstbucker Pro humbucker passive PAF Alnico V'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'gibson'), '490R', 'humbucker', 'passive', 6.0, 6.5, 5.0, 6.0, 4.5, 3.5, 'Gibson 490R humbucker passive modern neck'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'gibson'), '490T', 'humbucker', 'passive', 7.0, 6.0, 5.5, 6.5, 5.0, 3.0, 'Gibson 490T humbucker passive modern bridge'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'gibson'), '498T Hot Alnico', 'humbucker', 'passive', 8.0, 5.5, 6.5, 6.5, 5.5, 3.0, 'Gibson 498T Hot Alnico humbucker passive hot bridge'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'gibson'), 'Dirty Fingers', 'humbucker', 'passive', 9.0, 5.0, 7.5, 6.5, 6.5, 2.5, 'Gibson Dirty Fingers humbucker passive high output ceramic'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'gibson'), 'P-90', 'p90', 'passive', 6.0, 7.0, 5.5, 6.5, 4.5, 5.5, 'Gibson P-90 p90 passive soapbar dogear vintage'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'gibson'), 'P-94', 'humbucker', 'passive', 6.0, 7.0, 5.5, 6.5, 4.5, 5.0, 'Gibson P-94 humbucker sized P90 passive'),

  -- Bare Knuckle
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'bare-knuckle'), 'Nailbomb', 'humbucker', 'passive', 8.5, 6.0, 6.5, 7.5, 6.0, 3.0, 'Bare Knuckle Nailbomb humbucker passive rock metal'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'bare-knuckle'), 'Warpig', 'humbucker', 'passive', 9.5, 4.5, 8.5, 7.0, 7.0, 2.5, 'Bare Knuckle Warpig humbucker passive doom sludge metal'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'bare-knuckle'), 'Aftermath', 'humbucker', 'passive', 9.0, 6.5, 7.0, 7.5, 6.5, 2.5, 'Bare Knuckle Aftermath humbucker passive metal djent tight'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'bare-knuckle'), 'Mule', 'humbucker', 'passive', 5.5, 7.0, 5.0, 6.0, 4.0, 3.5, 'Bare Knuckle Mule humbucker passive PAF vintage'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'bare-knuckle'), 'Rebel Yell', 'humbucker', 'passive', 7.5, 6.5, 6.0, 7.0, 5.5, 3.0, 'Bare Knuckle Rebel Yell humbucker passive classic rock'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'bare-knuckle'), 'Holy Diver', 'humbucker', 'passive', 7.0, 6.5, 5.5, 7.0, 5.0, 3.0, 'Bare Knuckle Holy Diver humbucker passive versatile'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'bare-knuckle'), 'The Pig', 'p90', 'passive', 7.5, 6.5, 6.5, 7.0, 5.0, 5.0, 'Bare Knuckle The Pig P90 passive hot'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'bare-knuckle'), 'Mississippi Queen', 'p90', 'passive', 5.5, 7.5, 5.0, 6.0, 4.0, 5.5, 'Bare Knuckle Mississippi Queen P90 passive vintage'),

  -- Lace
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'lace'), 'Sensor Gold', 'single_coil', 'passive', 5.0, 7.5, 4.5, 5.5, 3.5, 1.5, 'Lace Sensor Gold single coil passive noiseless vintage strat'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'lace'), 'Sensor Blue', 'single_coil', 'passive', 5.0, 8.0, 4.0, 5.0, 3.5, 1.5, 'Lace Sensor Blue single coil passive noiseless bright tele'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'lace'), 'Sensor Red', 'single_coil', 'passive', 6.5, 6.0, 6.0, 6.0, 5.0, 1.5, 'Lace Sensor Red single coil passive noiseless hot'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'lace'), 'Alumitone Humbucker', 'humbucker', 'passive', 6.0, 7.5, 4.5, 5.5, 3.5, 2.0, 'Lace Alumitone Humbucker passive aluminum noiseless'),

  -- Fishman
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'fishman'), 'Fluence Modern (bridge)', 'humbucker', 'active', 9.0, 6.5, 7.0, 7.5, 8.0, 1.0, 'Fishman Fluence Modern bridge humbucker active metal'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'fishman'), 'Fluence Modern (neck)', 'humbucker', 'active', 6.5, 7.0, 5.5, 6.0, 7.0, 1.0, 'Fishman Fluence Modern neck humbucker active clean'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'fishman'), 'Fluence Classic (bridge)', 'humbucker', 'active', 7.0, 6.5, 6.0, 6.5, 7.0, 1.0, 'Fishman Fluence Classic bridge humbucker active PAF vintage'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'fishman'), 'Fluence Classic (neck)', 'humbucker', 'active', 5.5, 7.0, 5.0, 5.5, 6.5, 1.0, 'Fishman Fluence Classic neck humbucker active PAF warm'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'fishman'), 'Fluence Single Width', 'single_coil', 'active', 5.5, 7.5, 4.5, 5.5, 6.5, 1.0, 'Fishman Fluence Single Width single coil active noiseless'),

  -- TV Jones
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'tv-jones'), 'Classic', 'humbucker', 'passive', 6.0, 7.0, 5.0, 6.0, 4.0, 3.5, 'TV Jones Classic humbucker passive Gretsch filtertron'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'tv-jones'), 'Classic Plus', 'humbucker', 'passive', 7.0, 6.5, 5.5, 6.5, 4.5, 3.5, 'TV Jones Classic Plus humbucker passive Gretsch filtertron hot'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'tv-jones'), 'Power''Tron', 'humbucker', 'passive', 8.0, 5.5, 6.5, 7.0, 5.5, 3.0, 'TV Jones PowerTron humbucker passive Gretsch hot'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'tv-jones'), 'Starwood', 'humbucker', 'passive', 5.5, 7.5, 4.5, 5.5, 3.5, 3.5, 'TV Jones Starwood humbucker passive bright vintage'),

  -- Lindy Fralin
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'lindy-fralin'), 'Vintage Hot Strat', 'single_coil', 'passive', 6.0, 7.0, 5.0, 6.0, 4.0, 5.0, 'Lindy Fralin Vintage Hot Strat single coil passive overwound'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'lindy-fralin'), 'Blues Special Strat', 'single_coil', 'passive', 5.5, 7.5, 4.5, 5.5, 3.5, 5.0, 'Lindy Fralin Blues Special Strat single coil passive vintage'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'lindy-fralin'), 'Real 54s Strat', 'single_coil', 'passive', 5.0, 8.0, 4.0, 5.0, 3.5, 5.5, 'Lindy Fralin Real 54s Strat single coil passive vintage'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'lindy-fralin'), 'Pure PAF', 'humbucker', 'passive', 5.5, 7.0, 5.0, 5.5, 4.0, 3.5, 'Lindy Fralin Pure PAF humbucker passive vintage'),
  ((SELECT id FROM equipment_manufacturers WHERE slug = 'lindy-fralin'), 'High Output P-90', 'p90', 'passive', 7.0, 6.5, 6.0, 7.0, 5.0, 5.0, 'Lindy Fralin High Output P-90 passive hot')

ON CONFLICT (manufacturer_id, model_name, pickup_type_id) DO UPDATE
SET search_text = EXCLUDED.search_text,
    output_level = EXCLUDED.output_level,
    brightness = EXCLUDED.brightness,
    bass = EXCLUDED.bass,
    midrange = EXCLUDED.midrange,
    compression = EXCLUDED.compression,
    noise = EXCLUDED.noise,
    is_active = true;
