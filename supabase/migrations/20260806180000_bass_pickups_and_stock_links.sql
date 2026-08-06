-- Phase E: bass pickup catalog + stock links (2026-08-06).
-- pickup_models previously had zero bass pickups, so the 31 verified bass
-- families had no stock-pickup rows and the pickup rule stage never fired
-- for bass. Adds 23 researched bass pickups (manufacturer-published DCR/
-- output where available) + stock links for all 31 bass families.
begin;

-- 1. Bass pickup form-factor types
insert into public.pickup_types (id, label, coil_type)
values
  ('split_coil', 'Split-Coil (P-Bass)', 'other'),
  ('j_single', 'Jazz Bass Single', 'single_coil'),
  ('mm_humbucker', 'Music Man Humbucker', 'humbucker'),
  ('soapbar', 'Bass Soapbar', 'other')
on conflict (id) do update set label = excluded.label, coil_type = excluded.coil_type, is_active = true;

-- 2. New manufacturers
insert into public.equipment_manufacturers (name, slug, country, is_active)
values
  ('Bartolini', 'bartolini', 'US', true),
  ('Aguilar', 'aguilar', 'US', true),
  ('Nordstrand', 'nordstrand', 'US', true)
on conflict (slug) do update set name = excluded.name, is_active = true;

-- 3. Bass pickup models (scores researched 2026-08-06; metadata carries provenance)
insert into public.pickup_models (
  manufacturer_id, model_name, pickup_type_id, circuit_type,
  output_level, brightness, bass, midrange, compression, noise,
  search_text, metadata
)
select m.id, v.model, v.ptype, v.circuit,
       v.out_l, v.bright, v.bass_v, v.mid, v.comp, v.noise_v,
       v.stext,
       jsonb_build_object('verified', true, 'source', 'bass_pickup_verification_v1', 'version', 1,
                          'spec', v.spec, 'estimate', v.est, 'instrument', 'bass')
from (values
  ('fender', 'Player Precision Split-Coil', 'split_coil', 'passive', 5.5, 5.5, 7.5, 7.0, 4.0, 3.0, 'Fender Player Precision Split-Coil bass P split coil passive', 'alnico 5', false),
  ('fender', 'Pure Vintage 63 P', 'split_coil', 'passive', 5.0, 5.0, 7.5, 7.0, 3.5, 3.0, 'Fender Pure Vintage 63 P bass split coil passive vintage', '12.0k DCR, 7.0H', false),
  ('fender', 'Player Jazz Single Coils', 'j_single', 'passive', 5.0, 6.5, 6.5, 6.0, 3.5, 4.5, 'Fender Player Jazz Single Coils bass J single coil passive', 'alnico 5', false),
  ('fender', 'V-Mod II P', 'split_coil', 'passive', 6.0, 6.0, 7.5, 7.0, 4.0, 3.0, 'Fender V-Mod II P bass split coil passive american professional', 'mixed alnico', true),
  ('fender', 'V-Mod II J', 'j_single', 'passive', 5.5, 6.5, 6.5, 6.0, 3.5, 4.5, 'Fender V-Mod II J bass single coil passive american professional', 'mixed alnico', true),
  ('seymour-duncan', 'SPB-1 Vintage P', 'split_coil', 'passive', 5.0, 5.5, 7.0, 7.0, 3.5, 3.0, 'Seymour Duncan SPB-1 Vintage P bass split coil passive', '11.6k DCR', false),
  ('seymour-duncan', 'SPB-3 Quarter Pound P', 'split_coil', 'passive', 8.0, 6.5, 8.0, 5.5, 5.5, 3.0, 'Seymour Duncan SPB-3 Quarter Pound P bass split coil passive hot', '12.5k DCR', false),
  ('seymour-duncan', 'SJB-3 Quarter Pound J', 'j_single', 'passive', 8.0, 6.5, 7.5, 5.0, 5.5, 4.5, 'Seymour Duncan SJB-3 Quarter Pound J bass single coil passive hot', '13.9k/14.6k DCR', false),
  ('seymour-duncan', 'Apollo Jazz', 'j_single', 'passive', 6.0, 6.0, 6.5, 6.5, 4.0, 2.0, 'Seymour Duncan Apollo Jazz bass linear humbucker noiseless', '8.79k/9.25k DCR', false),
  ('emg', 'P (Active)', 'split_coil', 'active', 8.0, 6.5, 7.5, 6.0, 6.0, 1.0, 'EMG P Active bass split coil active', 'ceramic active', false),
  ('emg', 'J Set (Active)', 'j_single', 'active', 7.5, 7.0, 6.5, 6.0, 6.0, 1.0, 'EMG J Set Active bass single coil active', 'ceramic active', false),
  ('emg', 'PJ Set (Active)', 'split_coil', 'active', 8.0, 6.5, 7.5, 6.5, 6.0, 1.0, 'EMG PJ Set Active bass split coil active spector', 'ceramic active', false),
  ('dimarzio', 'Model P (DP122)', 'split_coil', 'passive', 7.0, 5.5, 8.0, 7.0, 5.0, 3.0, 'DiMarzio Model P DP122 bass split coil passive', '163mV, 11.54k DCR', false),
  ('dimarzio', 'Model J (DP123)', 'j_single', 'passive', 6.5, 5.5, 7.5, 6.5, 4.5, 2.0, 'DiMarzio Model J DP123 bass hum-canceling passive', '150mV, 6.82k DCR', false),
  ('dimarzio', 'Split P (DP127)', 'split_coil', 'passive', 8.5, 6.0, 8.0, 7.0, 6.0, 2.0, 'DiMarzio Split P DP127 bass split coil passive high output', '250mV, 19.16k DCR', false),
  ('music-man', 'StingRay Alnico Humbucker', 'mm_humbucker', 'passive', 7.0, 7.5, 8.0, 4.5, 4.5, 2.0, 'Music Man StingRay Alnico Humbucker bass mm humbucker scooped', 'alnico 5 parallel coils', false),
  ('bartolini', '9J1', 'j_single', 'passive', 5.5, 5.0, 7.0, 6.5, 4.5, 2.0, 'Bartolini 9J1 bass J hum-canceling passive warm', '6.1k/6.7k DCR', false),
  ('bartolini', 'Classic Bass Soapbar', 'soapbar', 'passive', 6.0, 5.0, 7.5, 6.5, 5.0, 2.0, 'Bartolini Classic Bass Soapbar dual coil passive', '~5.6k/coil', false),
  ('aguilar', 'AG 4P-60', 'split_coil', 'passive', 5.5, 5.5, 7.5, 7.0, 3.5, 3.0, 'Aguilar AG 4P-60 bass split coil passive 60s', '11.6k DCR', false),
  ('aguilar', 'AG 4J-HC', 'j_single', 'passive', 6.0, 6.0, 7.0, 6.5, 4.0, 2.0, 'Aguilar AG 4J-HC bass hum-canceling J passive', 'alnico 5 split', true),
  ('nordstrand', 'Big Single', 'soapbar', 'passive', 6.5, 6.5, 7.0, 6.5, 4.0, 4.5, 'Nordstrand Big Single bass soapbar single passive', 'alnico 5', true),
  ('ibanez', 'Dynamix P/J', 'split_coil', 'passive', 6.0, 6.0, 7.0, 6.5, 4.5, 4.0, 'Ibanez Dynamix PJ bass split coil passive gsr200 budget', 'ceramic', true),
  ('yamaha', 'YGD H5 Soapbar', 'soapbar', 'passive', 6.0, 6.5, 7.0, 6.0, 4.5, 2.0, 'Yamaha YGD H5 Soapbar bass dual coil passive trbx', 'alnico', true)
) as v(mslug, model, ptype, circuit, out_l, bright, bass_v, mid, comp, noise_v, stext, spec, est)
join public.equipment_manufacturers m on m.slug = v.mslug
on conflict (manufacturer_id, model_name, pickup_type_id) do update set
  output_level = excluded.output_level, brightness = excluded.brightness,
  bass = excluded.bass, midrange = excluded.midrange,
  compression = excluded.compression, noise = excluded.noise,
  search_text = excluded.search_text, metadata = excluded.metadata, is_active = true;

-- 4. Stock links for all 31 verified bass families
--    (family manufacturer slug, family model_name, pickup manufacturer slug,
--     pickup model, position, is exact OEM, note)
insert into public.guitar_model_pickups (guitar_model_id, pickup_model_id, pickup_position, is_stock, metadata)
select g.id, p.id, v.pos, true,
       jsonb_build_object('verified', true, 'source', 'bass_stock_pickups_v1', 'version', 1,
                          'is_stock_equivalent', not v.exact, 'note', v.note)
from (values
  ('fender', 'Precision Bass', 'fender', 'Player Precision Split-Coil', 'middle', true, 'stock Player-series P split-coil'),
  ('fender', 'Jazz Bass', 'fender', 'Player Jazz Single Coils', 'neck', true, 'stock Player-series J single'),
  ('fender', 'Jazz Bass', 'fender', 'Player Jazz Single Coils', 'bridge', true, 'stock Player-series J single'),
  ('fender', 'Mustang / Jaguar Bass', 'fender', 'Player Precision Split-Coil', 'middle', true, 'PJ config: P split-coil'),
  ('fender', 'Mustang / Jaguar Bass', 'fender', 'Player Jazz Single Coils', 'bridge', true, 'PJ config: J bridge'),
  ('squier', 'Affinity P/J Bass', 'fender', 'Player Precision Split-Coil', 'middle', false, 'actual OEM: Squier ceramic P (Player-class equivalent)'),
  ('squier', 'Affinity P/J Bass', 'fender', 'Player Jazz Single Coils', 'bridge', false, 'actual OEM: Squier ceramic J'),
  ('harley-benton', 'PB / JB Bass', 'ibanez', 'Dynamix P/J', 'middle', false, 'actual OEM: HB Standard/Roswell budget PJ class'),
  ('harley-benton', 'PB / JB Bass', 'fender', 'Player Jazz Single Coils', 'bridge', false, 'actual OEM: HB budget J class'),
  ('sandberg', 'California', 'aguilar', 'AG 4P-60', 'middle', false, 'actual OEM: Sandberg/Delano P — boutique alnico class'),
  ('sandberg', 'California', 'aguilar', 'AG 4J-HC', 'bridge', false, 'actual OEM: Sandberg/Delano J — hum-canceling class'),
  ('spector', 'NS / Euro / Legend', 'emg', 'PJ Set (Active)', 'middle', true, 'Spector ships EMG PJ actives on Euro/NS'),
  ('spector', 'NS / Euro / Legend', 'emg', 'PJ Set (Active)', 'bridge', true, 'Spector ships EMG PJ actives on Euro/NS'),
  ('ibanez', 'SR', 'bartolini', 'Classic Bass Soapbar', 'neck', false, 'actual OEM: Bartolini BH2 (SR500+) / PowerSpan'),
  ('ibanez', 'SR', 'bartolini', 'Classic Bass Soapbar', 'bridge', false, 'actual OEM: Bartolini BH2 (SR500+) / PowerSpan'),
  ('sire', 'Marcus Miller V/P/M', 'fender', 'V-Mod II J', 'neck', false, 'actual OEM: Sire Marcus Super J revolution'),
  ('sire', 'Marcus Miller V/P/M', 'fender', 'V-Mod II J', 'bridge', false, 'actual OEM: Sire Marcus Super J revolution'),
  ('yamaha', 'TRBX', 'yamaha', 'YGD H5 Soapbar', 'neck', true, 'TRBX500-series stock YGD H5'),
  ('yamaha', 'TRBX', 'yamaha', 'YGD H5 Soapbar', 'bridge', true, 'TRBX500-series stock YGD H5'),
  ('cort', 'Artisan / Action Bass', 'bartolini', 'Classic Bass Soapbar', 'neck', false, 'actual OEM: Bartolini MK-1 (Artisan)'),
  ('cort', 'Artisan / Action Bass', 'bartolini', 'Classic Bass Soapbar', 'bridge', false, 'actual OEM: Bartolini MK-1 (Artisan)'),
  ('warwick', 'Corvette', 'fender', 'Player Jazz Single Coils', 'neck', false, 'actual OEM: MEC J singles'),
  ('warwick', 'Corvette', 'fender', 'Player Jazz Single Coils', 'bridge', false, 'actual OEM: MEC J singles'),
  ('lakland', 'Skyline', 'bartolini', '9J1', 'neck', false, 'actual OEM: Lakland/Hanson J class'),
  ('lakland', 'Skyline', 'bartolini', '9J1', 'bridge', false, 'actual OEM: Lakland/Hanson J class'),
  ('sadowsky', 'MetroExpress / MetroLine', 'aguilar', 'AG 4J-HC', 'neck', false, 'actual OEM: Sadowsky hum-canceling J'),
  ('sadowsky', 'MetroExpress / MetroLine', 'aguilar', 'AG 4J-HC', 'bridge', false, 'actual OEM: Sadowsky hum-canceling J'),
  ('jackson', 'Spectra / Concert', 'fender', 'Player Jazz Single Coils', 'neck', false, 'actual OEM: Jackson J-style'),
  ('jackson', 'Spectra / Concert', 'fender', 'Player Jazz Single Coils', 'bridge', false, 'actual OEM: Jackson J-style'),
  ('rickenbacker', '4003', 'nordstrand', 'Big Single', 'neck', false, 'actual OEM: Rickenbacker hi-gain singles (fat single equivalent)'),
  ('rickenbacker', '4003', 'nordstrand', 'Big Single', 'bridge', false, 'actual OEM: Rickenbacker hi-gain singles (fat single equivalent)'),
  ('danelectro', 'Longhorn / 59DC Bass', 'fender', 'Player Jazz Single Coils', 'neck', false, 'actual OEM: lipstick singles (bright single equivalent)'),
  ('danelectro', 'Longhorn / 59DC Bass', 'fender', 'Player Jazz Single Coils', 'bridge', false, 'actual OEM: lipstick singles (bright single equivalent)'),
  ('music-man', 'StingRay', 'music-man', 'StingRay Alnico Humbucker', 'bridge', true, 'stock StingRay alnico humbucker'),
  ('sterling-by-music-man', 'Ray4 / Ray34', 'music-man', 'StingRay Alnico Humbucker', 'bridge', false, 'actual OEM: Sterling ceramic/alnico Ray humbucker'),
  ('mtd', 'Kingston', 'music-man', 'StingRay Alnico Humbucker', 'bridge', false, 'actual OEM: MTD dual-coil MM-style'),
  ('dingwall', 'NG / Combustion', 'bartolini', 'Classic Bass Soapbar', 'neck', false, 'actual OEM: Dingwall FD-3 soapbars'),
  ('dingwall', 'NG / Combustion', 'bartolini', 'Classic Bass Soapbar', 'bridge', false, 'actual OEM: Dingwall FD-3 soapbars'),
  ('esp', 'B / AP Series Bass', 'bartolini', 'Classic Bass Soapbar', 'neck', false, 'actual OEM: ESP SB-4 soapbars'),
  ('esp', 'B / AP Series Bass', 'bartolini', 'Classic Bass Soapbar', 'bridge', false, 'actual OEM: ESP SB-4 soapbars'),
  ('schecter', 'Stiletto / Riot', 'emg', 'J Set (Active)', 'neck', false, 'actual OEM: EMG 35DC/HZ soapbar actives'),
  ('schecter', 'Stiletto / Riot', 'emg', 'J Set (Active)', 'bridge', false, 'actual OEM: EMG 35DC/HZ soapbar actives'),
  ('gibson', 'Thunderbird / SG Bass', 'dimarzio', 'Model J (DP123)', 'neck', false, 'actual OEM: Thunderbird humbuckers (warm hum-canceling equivalent)'),
  ('gibson', 'Thunderbird / SG Bass', 'dimarzio', 'Model J (DP123)', 'bridge', false, 'actual OEM: Thunderbird humbuckers'),
  ('epiphone', 'EB / Thunderbird / Viola', 'dimarzio', 'Model J (DP123)', 'neck', false, 'actual OEM: Epiphone T-bird/EB humbuckers'),
  ('epiphone', 'EB / Thunderbird / Viola', 'dimarzio', 'Model J (DP123)', 'bridge', false, 'actual OEM: Epiphone T-bird/EB humbuckers'),
  ('hofner', 'Violin / Club Bass', 'bartolini', '9J1', 'neck', false, 'actual OEM: Hofner staple mini-humbuckers (warm low-output equivalent)'),
  ('hofner', 'Violin / Club Bass', 'bartolini', '9J1', 'bridge', false, 'actual OEM: Hofner staple mini-humbuckers'),
  ('gretsch', 'Electromatic Bass', 'dimarzio', 'Model J (DP123)', 'neck', false, 'actual OEM: Gretsch mini-humbuckers'),
  ('gretsch', 'Electromatic Bass', 'dimarzio', 'Model J (DP123)', 'bridge', false, 'actual OEM: Gretsch mini-humbuckers'),
  ('guild', 'Starfire Bass', 'nordstrand', 'Big Single', 'neck', false, 'actual OEM: Guild Bisonic/BS-1 (Big Single is its modern descendant)'),
  ('guild', 'Starfire Bass', 'nordstrand', 'Big Single', 'bridge', false, 'actual OEM: Guild Bisonic/BS-1'),
  ('dean', 'Edge Bass', 'bartolini', 'Classic Bass Soapbar', 'neck', false, 'actual OEM: Dean soapbars'),
  ('dean', 'Edge Bass', 'bartolini', 'Classic Bass Soapbar', 'bridge', false, 'actual OEM: Dean soapbars'),
  ('g-l', 'L-2000 / JB Bass', 'music-man', 'StingRay Alnico Humbucker', 'neck', false, 'actual OEM: G&L MFD humbuckers (big bold humbucker equivalent)'),
  ('g-l', 'L-2000 / JB Bass', 'music-man', 'StingRay Alnico Humbucker', 'bridge', false, 'actual OEM: G&L MFD humbuckers'),
  ('peavey', 'Milestone', 'seymour-duncan', 'SPB-1 Vintage P', 'middle', false, 'actual OEM: Peavey P split-coil (vintage-wind equivalent)')
) as v(gslug, gmodel, pslug, pmodel, pos, exact, note)
join public.equipment_manufacturers gm on gm.slug = v.gslug
join public.guitar_models g on g.manufacturer_id = gm.id and g.model_name = v.gmodel
  and g.instrument_type = 'bass' and g.is_active = true
join public.equipment_manufacturers pm on pm.slug = v.pslug
join public.pickup_models p on p.manufacturer_id = pm.id and p.model_name = v.pmodel
where not exists (
  select 1 from public.guitar_model_pickups x
  where x.guitar_model_id = g.id and x.pickup_model_id = p.id and x.pickup_position = v.pos
);

-- Post-conditions
do $$
declare
  n int;
begin
  select count(*) into n from public.pickup_models
  where metadata->>'source' = 'bass_pickup_verification_v1' and is_active = true;
  if n <> 23 then
    raise exception 'POST-CONDITION FAILED: expected 23 bass pickups, got %', n;
  end if;

  select count(distinct g.id) into n
  from public.guitar_models g
  join public.guitar_model_pickups l on l.guitar_model_id = g.id
  where g.instrument_type = 'bass' and g.is_active = true and g.metadata->>'verified' = 'true';
  if n < 31 then
    raise exception 'POST-CONDITION FAILED: only % of 31 bass families have stock pickups', n;
  end if;
end $$;

commit;
