-- Phase 3 (gear): full bass-guitar and bass-amp family coverage of the picker catalog.
--
-- Same mechanism as phases 1-2. Bass rows live in guitar_models / amp_models with
-- instrument_type = 'bass'; tags[] are folded into search_text by the sync triggers so the
-- exact picker display names always ILIKE-match. Existing July-29 bass families keep their
-- values; new families are inserted with hand-tuned values per archetype (rationale inline).
-- Data-only, idempotent.

insert into public.equipment_manufacturers (name, slug)
values
  ('Fender', 'fender'),
  ('Sire', 'sire'),
  ('Schecter', 'schecter'),
  ('Spector', 'spector'),
  ('Cort', 'cort'),
  ('ESP', 'esp'),
  ('G&L', 'g-l'),
  ('Lakland', 'lakland'),
  ('Sterling by Music Man', 'sterling-by-music-man'),
  ('Dingwall', 'dingwall'),
  ('Harley Benton', 'harley-benton'),
  ('Jackson', 'jackson'),
  ('Epiphone', 'epiphone'),
  ('Gibson', 'gibson'),
  ('Hofner', 'hofner'),
  ('Sandberg', 'sandberg'),
  ('Sadowsky', 'sadowsky'),
  ('Rickenbacker', 'rickenbacker'),
  ('Gretsch', 'gretsch'),
  ('Danelectro', 'danelectro'),
  ('MTD', 'mtd'),
  ('Dean', 'dean'),
  ('Guild', 'guild'),
  ('Peavey', 'peavey'),
  ('Ashdown', 'ashdown'),
  ('TC Electronic', 'tc-electronic'),
  ('Warwick', 'warwick'),
  ('EBS', 'ebs'),
  ('Eden', 'eden'),
  ('Blackstar', 'blackstar'),
  ('Phil Jones', 'phil-jones'),
  ('Trace Elliot', 'trace-elliot'),
  ('SWR', 'swr'),
  ('Boss', 'boss'),
  ('Genzler', 'genzler'),
  ('Laney', 'laney'),
  ('Genz Benz', 'genz-benz'),
  ('Bergantino', 'bergantino'),
  ('Vox', 'vox'),
  ('Behringer', 'behringer'),
  ('Ibanez', 'ibanez')
on conflict (slug) do nothing;

update public.guitar_models t
set tags = array['fender player precision bass', 'fender player plus precision bass', 'fender american professional ii precision bass', 'fender precision bass', 'fender p bass', 'p-bass', 'fender american ultra precision bass', 'fender player ii precision bass', 'fender aerodyne special precision bass', 'fender american performer precision bass', 'fender american professional ii precision bass left-hand', 'fender american ultra ii precision bass', 'fender american vintage ii 1954 precision bass', 'fender american vintage ii 1960 precision bass', 'fender duff mckagan deluxe precision bass', 'fender nate mendel precision bass', 'fender player ii precision bass left-hand', 'fender steve harris precision bass', 'fender vintera 50s precision bass', 'fender vintera 60s precision bass', 'fender vintera ii 50s precision bass', 'fender vintera ii 60s precision bass']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase3_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'fender'
  and t.model_name = 'Precision Bass' and t.instrument_type = 'bass';

update public.guitar_models t
set tags = array['fender player jazz bass', 'fender player plus jazz bass', 'fender american professional ii jazz bass', 'fender jazz bass', 'fender j bass', 'jazz bass', 'fender american ultra jazz bass', 'fender geddy lee jazz bass', 'fender player ii jazz bass', 'fender aerodyne special jazz bass', 'fender american performer jazz bass', 'fender american professional ii jazz bass left-hand', 'fender american professional ii jazz bass v', 'fender american ultra ii jazz bass', 'fender american ultra ii jazz bass v', 'fender american ultra jazz bass v', 'fender american vintage ii 1966 jazz bass', 'fender flea jazz bass', 'fender jaco pastorius jazz bass', 'fender player ii jazz bass v', 'fender player plus jazz bass v', 'fender vintera 60s jazz bass', 'fender vintera 70s jazz bass', 'fender vintera ii 60s jazz bass', 'fender vintera ii 70s jazz bass', 'fender player jazz bass v']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase3_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'fender'
  and t.model_name = 'Jazz Bass' and t.instrument_type = 'bass';

update public.guitar_models t
set tags = array['squier affinity precision bass pj', 'squier affinity jazz bass', 'squier affinity bass', 'squier precision bass', 'squier jazz bass', 'squier p bass', 'squier j bass', 'squier classic vibe 60s precision bass', 'squier classic vibe 70s jazz bass', 'squier classic vibe 50s precision bass', 'squier classic vibe 60s jazz bass', 'squier affinity jazz bass v', 'squier classic vibe 60s mustang bass', 'squier classic vibe 70s jazz bass v', 'squier classic vibe starcaster bass', 'squier contemporary active jazz bass hh', 'squier contemporary active jazz bass hh v', 'squier contemporary active precision bass ph', 'squier paranormal jazz bass 32', 'squier paranormal rascal bass hh', 'squier sonic bronco bass', 'squier sonic mustang bass pj', 'squier sonic precision bass', 'squier affinity bronco bass']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase3_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'squier'
  and t.model_name = 'Affinity P/J Bass' and t.instrument_type = 'bass';

update public.guitar_models t
set tags = array['ibanez sr300e', 'ibanez sr500e', 'ibanez sr1350b', 'ibanez gsr200', 'ibanez sr', 'ibanez soundgear', 'ibanez btb745', 'ibanez ehb1000', 'ibanez sr600e', 'ibanez bass workshop ehb5msbsp', 'ibanez btb805ms', 'ibanez btb806ms', 'ibanez gio gsr200pc', 'ibanez gio gsr205b', 'ibanez iron label srms625ex', 'ibanez mikro gsrm20', 'ibanez mode mdm1006', 'ibanez premium sr1355b', 'ibanez premium sr2605', 'ibanez sr305edx', 'ibanez sr405epbdx', 'ibanez srf705', 'ibanez standard sr305e', 'ibanez standard sr500a', 'ibanez ehb1005sms', 'ibanez sr305e', 'ibanez sr505e', 'ibanez tmb100', 'ibanez adam nitti anb306e', 'ibanez btb605ms', 'ibanez btb846', 'ibanez ehb1000s', 'ibanez ehb1005ms', 'ibanez ehb1505ms', 'ibanez gary willis gwb35', 'ibanez gsr205', 'ibanez gsrm20 mikro', 'ibanez sr1100b premium', 'ibanez sr1200e premium', 'ibanez sr1305b premium', 'ibanez sr2600 premium', 'ibanez sr30th4ii anniversary', 'ibanez sr5005 prestige', 'ibanez sr506e', 'ibanez sr605e', 'ibanez srmd200 mezzo', 'ibanez srmd201', 'ibanez tmb110', 'ibanez tmb600', 'ibanez sr370e', 'ibanez sr405eqm', 'ibanez gsr205sm']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase3_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'ibanez'
  and t.model_name = 'SR' and t.instrument_type = 'bass';

update public.guitar_models t
set tags = array['music man stingray special hh', 'music man stingray special h', 'music man stingray', 'ernie ball stingray', 'stingray bass', 'music man bongo 5 hh', 'music man cutlass bass', 'music man stingray special 4 hh', 'music man stingray special 5 h', 'music man bongo 4 h', 'music man bongo 4 hh', 'music man bongo 5 h', 'music man darkray 4', 'music man darkray 5', 'music man joe dart artist series i', 'music man joe dart artist series ii', 'music man sterling 4 h', 'music man sterling 5 hh', 'music man stingray special 5 hh', 'music man stingray special 4 h']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase3_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'music-man'
  and t.model_name = 'StingRay' and t.instrument_type = 'bass';

update public.guitar_models t
set tags = array['yamaha trbx304', 'yamaha trbx504', 'yamaha trbx', 'yamaha bb734a', 'yamaha bb', 'yamaha bb434', 'yamaha bb234', 'yamaha trbx174', 'yamaha trbx305', 'yamaha bb235', 'yamaha bb435', 'yamaha bb735a', 'yamaha bbp34', 'yamaha bbp35', 'yamaha billy sheehan attitude limited 3', 'yamaha trbx174ew', 'yamaha trbx505', 'yamaha trbx604fm', 'yamaha trbx605fm']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase3_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'yamaha'
  and t.model_name = 'TRBX' and t.instrument_type = 'bass';

update public.guitar_models t
set tags = array['warwick rockbass corvette basic 4', 'warwick corvette', 'warwick rockbass', 'warwick', 'warwick rockbass streamer lx', 'warwick thumb bo 5', 'warwick german pro series corvette standard', 'warwick german pro series streamer lx 4', 'warwick german pro series thumb bo 4', 'warwick rockbass corvette $$', 'warwick rockbass corvette $$ 5', 'warwick rockbass corvette basic 5', 'warwick rockbass streamer lx 4', 'warwick rockbass streamer lx 5', 'warwick rockbass thumb bo 4', 'warwick rockbass thumb bo 5', 'warwick german pro series streamer stage i']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase3_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'warwick'
  and t.model_name = 'Corvette' and t.instrument_type = 'bass';

update public.amp_models t
set tags = array['ampeg svt-cl', 'ampeg svt-vr', 'ampeg svt-3pro', 'ampeg svt-7pro', 'ampeg portaflex pf-500', 'ampeg pf-500', 'ampeg pf-800', 'ampeg micro-vr', 'ampeg micro-cl', 'ampeg svt', 'ampeg', 'ampeg rocket bass rb-210', 'ampeg v-4b', 'ampeg heritage 50th anniversary svt', 'ampeg pf-50t', 'ampeg rocket bass rb-108', 'ampeg rocket bass rb-110', 'ampeg rocket bass rb-115', 'ampeg svt micro vr', 'ampeg svt-4pro', 'ampeg venture v12', 'ampeg ba-108v2', 'ampeg ba-110v2', 'ampeg ba-112v2', 'ampeg ba-115v2', 'ampeg ba-210v2', 'ampeg heritage svt-cl', 'ampeg pf-20t', 'ampeg pf-350', 'ampeg rb-108', 'ampeg rb-110', 'ampeg rb-112', 'ampeg rb-115', 'ampeg venture v3', 'ampeg venture v7', 'ampeg b2re', 'ampeg svt-6pro', 'ampeg heritage b-15n', 'ampeg svt-2pro']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase3_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'ampeg'
  and t.model_name = 'SVT' and t.instrument_type = 'bass';

update public.amp_models t
set tags = array['gallien krueger mb200', 'gallien krueger mb500', 'gallien krueger mb800', 'gallien krueger mb', 'gk mb', 'gallien krueger', 'gk', 'gallien krueger fusion 800s', 'gallien krueger 800rb', 'gallien krueger legacy 1200', 'gallien krueger legacy 500', 'gallien krueger legacy 800', 'gallien krueger mb108', 'gallien krueger mb110', 'gallien krueger mb112-ii', 'gallien krueger mb115-ii', 'gallien krueger rb1001-ii', 'gallien krueger rb700-ii', 'gallien krueger 1001rb-ii', 'gallien krueger 700rb-ii', 'gallien krueger backline 600', 'gallien krueger mb fusion 500', 'gallien krueger mb fusion 800', 'gallien krueger 400rb-iv', 'gallien krueger fusion 550', 'gallien krueger mb210-ii']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase3_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'gallien-krueger'
  and t.model_name = 'MB Series' and t.instrument_type = 'bass';

update public.amp_models t
set tags = array['markbass little mark iv', 'markbass little mark iii', 'markbass little mark', 'markbass cmd 121p', 'markbass', 'markbass little mark tube 800', 'markbass big bang iii', 'markbass cmd 101 micro 60', 'markbass cmd 102p', 'markbass little marcus 1000', 'markbass little marcus 500', 'markbass little marcus 58r', 'markbass little mark 58r', 'markbass little mark vintage', 'markbass mb58r cmd 102 pure', 'markbass mini cmd 121p', 'markbass nano mark 300', 'markbass little mark 250 black line', 'markbass little mark ninja']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase3_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'markbass'
  and t.model_name = 'Little Mark' and t.instrument_type = 'bass';

update public.amp_models t
set tags = array['hartke lh500', 'hartke lh1000', 'hartke ha3500', 'hartke lh', 'hartke ha', 'hartke', 'hartke tx300', 'hartke hd15', 'hartke hd150', 'hartke hd25', 'hartke hd50', 'hartke hd500', 'hartke hd75', 'hartke kickback kb12', 'hartke kickback kb15', 'hartke lx5500', 'hartke lx8500', 'hartke tx600', 'hartke ha5500']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase3_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'hartke'
  and t.model_name = 'LH / HA' and t.instrument_type = 'bass';

update public.amp_models t
set tags = array['fender rumble 40', 'fender rumble 100', 'fender rumble 500', 'fender rumble 200', 'fender rumble', 'fender rumble 15', 'fender rumble 25', 'fender rumble 800 combo', 'fender rumble 800 hd', 'fender rumble lt25', 'fender rumble stage 800', 'fender rumble studio 40', 'fender bassman 500', 'fender bassman 800', 'fender super bassman']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase3_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'fender'
  and t.model_name = 'Rumble' and t.instrument_type = 'bass';

update public.amp_models t
set tags = array['orange terror bass 500', 'orange terror bass', 'orange ob1-500', 'orange ob1', 'orange bass', 'orange little bass thing', 'orange 4 stroke 300', 'orange 4 stroke 500', 'orange crush bass 100', 'orange crush bass 25', 'orange crush bass 50', 'orange ob1-300', 'orange ad200b mk3']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase3_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'orange'
  and t.model_name = 'Terror Bass' and t.instrument_type = 'bass';

update public.amp_models t
set tags = array['darkglass microtubes 500 v2', 'darkglass microtubes 900 v2', 'darkglass alpha-omega 500', 'darkglass alpha omega 900', 'darkglass microtubes', 'darkglass alpha omega', 'darkglass', 'darkglass microtubes 900', 'darkglass element', 'darkglass exponent 500', 'darkglass microtubes x 900']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase3_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'darkglass'
  and t.model_name = 'Microtubes / Alpha-Omega' and t.instrument_type = 'bass';

update public.amp_models t
set tags = array['mesa boogie subway d-800', 'mesa boogie subway', 'mesa subway d-800', 'mesa subway', 'mesa bass', 'mesa boogie subway d-800+', 'mesa boogie subway tt-800', 'mesa boogie subway wd-800', 'mesa boogie big block 750', 'mesa boogie walkabout', 'mesa boogie prodigy four:88', 'mesa boogie strategy eight:88']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase3_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'mesa-boogie'
  and t.model_name = 'Subway' and t.instrument_type = 'bass';

update public.amp_models t
set tags = array['aguilar tone hammer 350', 'aguilar tone hammer 500', 'aguilar tone hammer', 'aguilar ag700', 'aguilar', 'aguilar ag 500', 'aguilar ag 700', 'aguilar db 751', 'aguilar tone hammer 700', 'aguilar db 750']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase3_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'aguilar'
  and t.model_name = 'Tone Hammer' and t.instrument_type = 'bass';

insert into public.guitar_models (
  manufacturer_id, model_name, instrument_type, body_type, pickup_layout,
  output_level, brightness, warmth, compression,
  noise_characteristics, metadata, tags, search_text, is_active
)
select
  m.id, v.model_name, 'bass', v.body_type, v.pickup_layout,
  v.output_level, v.brightness, v.warmth, v.compression,
  '{}'::jsonb,
  jsonb_build_object('verified', true, 'source', 'curated_gear_phase3_v1', 'version', 1),
  v.tags, '', true
from (
  values
    -- Short-scale offsets: thumpy warm PJ voicing, less top-end zing than a Jazz.
    ('fender', 'Mustang / Jaguar Bass', 'solid', 'pj', 5.5, 5, 6.5, 5,
      array['fender mustang bass pj', 'fender player mustang bass pj', 'fender american performer mustang bass', 'fender meteora bass', 'fender player jaguar bass', 'fender player plus active meteora bass', 'fender vintera ii 70s mustang bass', 'fender vintera ii 60s bass vi']::text[]),
    -- Active-preamp Jazz platform: hot, bright, studio-slap ready.
    ('sire', 'Marcus Miller V/P/M', 'solid', 'jj', 6.5, 6.5, 5, 5,
      array['sire marcus miller m7 4', 'sire marcus miller v3 4', 'sire marcus miller v3 5', 'sire marcus miller v7 4', 'sire marcus miller d5 4', 'sire marcus miller m2 4', 'sire marcus miller m2 5', 'sire marcus miller m5 4', 'sire marcus miller m5 5', 'sire marcus miller m7 5', 'sire marcus miller p5 4', 'sire marcus miller p5 5', 'sire marcus miller p7 4', 'sire marcus miller p7 5', 'sire marcus miller u5 4', 'sire marcus miller v10 4', 'sire marcus miller v10 5', 'sire marcus miller v5 4', 'sire marcus miller v5 5', 'sire marcus miller v7 5', 'sire marcus miller v7 vintage 4', 'sire marcus miller v7 vintage 5', 'sire marcus miller v8 4', 'sire marcus miller v8 5', 'sire marcus miller z3 4', 'sire marcus miller z7 4']::text[]),
    -- Active modern rock/metal basses: hot tight output.
    ('schecter', 'Stiletto / Riot', 'solid', 'hh', 7, 6, 4.5, 5.5,
      array['schecter stiletto studio-4', 'schecter riot-5 session', 'schecter stiletto extreme-5', 'schecter omen-4', 'schecter c-4 gt', 'schecter c-5 gt', 'schecter dug pinnick dp-12', 'schecter michael anthony ma-4', 'schecter model-t session-4', 'schecter model-t session-5', 'schecter omen-5', 'schecter riot-4', 'schecter stiletto custom-4', 'schecter stiletto custom-5', 'schecter stiletto extreme-4', 'schecter stiletto studio-5']::text[]),
    -- Curved-body active rock machines: aggressive punch, tight lows.
    ('spector', 'NS / Euro / Legend', 'solid', 'pj', 7, 6, 4.5, 5.5,
      array['spector legend 4 classic', 'spector euro5 lx', 'spector ns pulse 5', 'spector ns ethos 4', 'spector bantam 4', 'spector euro 4 lt', 'spector euro 5 lt', 'spector legend 4 standard', 'spector legend 5 standard', 'spector ns dimension 4', 'spector ns dimension 5', 'spector ns ethos 5', 'spector performer 4', 'spector performer 5', 'spector euro 4 lx', 'spector ns-2']::text[]),
    -- Modern versatile imports: balanced active voicing.
    ('cort', 'Artisan / Action Bass', 'solid', 'jj', 6, 6, 5, 5,
      array['cort action pj', 'cort a5 plus fmmh', 'cort b4 element', 'cort gb74jj', 'cort a4 plus artisan', 'cort a5 plus artisan', 'cort a6 plus artisan', 'cort action bass plus', 'cort b4 plus', 'cort b5 plus', 'cort gb75jj', 'cort gb modern 4']::text[]),
    -- Metal-focused basses: hot pickups, controlled lows.
    ('esp', 'B / AP Series Bass', 'solid', 'hh', 7, 5.5, 5, 5.5,
      array['esp ltd b-204sm', 'esp ltd b-205sm', 'esp ltd f-204', 'esp ltd ap-204', 'esp ltd ap-4', 'esp ltd b-1004se', 'esp ltd b-4e', 'esp ltd frank bello fb-4', 'esp ltd surveyor 87', 'esp ltd b-1005se', 'esp ltd d-4', 'esp ltd d-5']::text[]),
    -- MFD humbucker punch (L-2000) and vintage-plus JB: strong midrange growl.
    ('g-l', 'L-2000 / JB Bass', 'solid', 'hh', 6.5, 5.5, 6, 5,
      array['g&l l-2500', 'g&l l-2000', 'g&l jb', 'g&l tribute l-2000', 'g&l fullerton deluxe jb', 'g&l fullerton deluxe l-2000', 'g&l tribute fallout bass', 'g&l tribute jb', 'g&l tribute kiloton', 'g&l tribute l-2500', 'g&l tribute lb-100']::text[]),
    -- Refined US-designed J/P platforms: polished even response.
    ('lakland', 'Skyline', 'solid', 'jj', 5.5, 6, 6, 4.5,
      array['lakland skyline 44-60', 'lakland skyline 44-64', 'lakland skyline 55-02', 'lakland skyline 44-01', 'lakland skyline 44-02', 'lakland skyline 44-64 custom', 'lakland skyline 55-01', 'lakland skyline darryl jones dj4', 'lakland skyline darryl jones dj5', 'lakland skyline duck dunn']::text[]),
    -- Import StingRay: bright scooped humbucker sting.
    ('sterling-by-music-man', 'Ray4 / Ray34', 'solid', 'h', 6.5, 6.5, 5, 5,
      array['sterling by music man ray34', 'sterling by music man ray4', 'sterling by music man ray5', 'sterling by music man ray24ca', 'sterling by music man ray34 hh', 'sterling by music man ray35', 'sterling by music man ray4 hh', 'sterling by music man stingray short scale rayss4', 'sterling by music man sub series ray4', 'sterling by music man sub series ray5']::text[]),
    -- Fanned-fret moderns: piano-tight lows, hot clear output (djent staple).
    ('dingwall', 'NG / Combustion', 'solid', 'hh', 7, 6.5, 4, 5.5,
      array['dingwall ng-2 4', 'dingwall combustion 4', 'dingwall combustion 5', 'dingwall d-roc standard 4', 'dingwall d-roc standard 5', 'dingwall ng-2 5', 'dingwall ng-3 4', 'dingwall ng-3 5', 'dingwall ng-3 6']::text[]),
    -- Budget P/J copies: modest output, warm passive voicing.
    ('harley-benton', 'PB / JB Bass', 'solid', 'pj', 5, 5.5, 6, 4.5,
      array['harley benton jb-20', 'harley benton pb-20', 'harley benton b-450', 'harley benton b-550', 'harley benton jb-40', 'harley benton jb-75', 'harley benton mb-4', 'harley benton mp-4', 'harley benton pb-50']::text[]),
    -- Modern rock basses: punchy active options.
    ('jackson', 'Spectra / Concert', 'solid', 'jj', 6.5, 6, 5, 5,
      array['jackson spectra bass js2', 'jackson spectra bass js3', 'jackson concert bass cbxnt dx iv', 'jackson concert bass js2', 'jackson concert bass js3', 'jackson spectra js3', 'jackson spectra js3v', 'jackson x series spectra iv']::text[]),
    -- Gibson-school humbucker basses: dark, woolly, vintage weight.
    ('epiphone', 'EB / Thunderbird / Viola', 'solid', 'hh', 6.5, 4.5, 7, 5,
      array['epiphone thunderbird 64', 'epiphone eb-0', 'epiphone eb-3', 'epiphone embassy', 'epiphone newport', 'epiphone viola bass']::text[]),
    -- Thunderbird growl: dark warm humbuckers, big low mids.
    ('gibson', 'Thunderbird / SG Bass', 'solid', 'hh', 6.5, 4.5, 7, 5,
      array['gibson thunderbird', 'gibson les paul junior tribute dc bass', 'gibson non-reverse thunderbird', 'gibson sg standard bass']::text[]),
    -- Hollow short-scale thump (McCartney): dark, round, compressed.
    ('hofner', 'Violin / Club Bass', 'hollow', 'hh', 4.5, 3.5, 7.5, 5.5,
      array['hofner violin bass contemporary hct-500', 'hofner violin bass ignition se', 'hofner club bass ignition', 'hofner german 500/1 v62 vintage', 'hofner violin bass ignition pro']::text[]),
    -- German modern classics: crisp active P/J punch.
    ('sandberg', 'California', 'solid', 'pj', 6, 6, 5.5, 4.5,
      array['sandberg california ii tt 4', 'sandberg california ii tt 5', 'sandberg california ii vm 4', 'sandberg california ii vs 4', 'sandberg electra ii tt']::text[]),
    -- NYC-school hi-fi active Jazz: polished sheen, tight lows.
    ('sadowsky', 'MetroExpress / MetroLine', 'solid', 'jj', 6, 6.5, 5.5, 4.5,
      array['sadowsky metroexpress vintage j/j 4', 'sadowsky metroexpress vintage j/j 5', 'sadowsky metroexpress vintage p/j 4', 'sadowsky metroline vintage j/j 4']::text[]),
    -- The grind benchmark: bright clanky top with piano lows (Geddy/Lemmy).
    ('rickenbacker', '4003', 'solid', 'ss', 6, 7, 5, 4.5,
      array['rickenbacker 4003', 'rickenbacker 4003s', 'rickenbacker 4003w']::text[]),
    -- Retro short-scale warmth.
    ('gretsch', 'Electromatic Bass', 'semi_hollow', 'hh', 5, 5, 6.5, 5,
      array['gretsch g2220 electromatic junior jet bass ii', 'gretsch g5440lsb electromatic']::text[]),
    -- Lipstick-pickup twang: light, bright, vintage quirk.
    ('danelectro', 'Longhorn / 59DC Bass', 'semi_hollow', 'ss', 4.5, 7, 4.5, 4,
      array['danelectro longhorn bass', 'danelectro 59dc long scale bass']::text[]),
    -- Modern boutique-designed imports: articulate wide-range voicing.
    ('mtd', 'Kingston', 'solid', 'h', 6.5, 6.5, 5, 4.5,
      array['mtd kingston heir 4', 'mtd kingston z4']::text[]),
    -- Affordable modern rock bass.
    ('dean', 'Edge Bass', 'solid', 'hh', 6, 5.5, 5.5, 5,
      array['dean edge 09']::text[]),
    -- Semi-hollow vintage warmth (Jack Casady lineage).
    ('guild', 'Starfire Bass', 'semi_hollow', 'hh', 5, 4.5, 7, 5,
      array['guild starfire bass ii']::text[]),
    -- Budget P-style: simple warm passive thump.
    ('peavey', 'Milestone', 'solid', 'p', 5, 5.5, 6, 4.5,
      array['peavey milestone']::text[])
) as v(manufacturer_slug, model_name, body_type, pickup_layout, output_level, brightness, warmth, compression, tags)
join public.equipment_manufacturers m on m.slug = v.manufacturer_slug
on conflict (manufacturer_id, model_name, instrument_type) do update set
  body_type = excluded.body_type,
  pickup_layout = excluded.pickup_layout,
  output_level = excluded.output_level,
  brightness = excluded.brightness,
  warmth = excluded.warmth,
  compression = excluded.compression,
  metadata = excluded.metadata,
  tags = excluded.tags,
  is_active = true,
  updated_at = now();

insert into public.amp_models (
  manufacturer_id, model_name, instrument_type, amp_technology, gain_structure,
  brightness, warmth, clean_headroom, compression,
  eq_behaviour, presence_behaviour, metadata, tags, search_text, is_active
)
select
  m.id, v.model_name, 'bass', v.amp_technology, v.gain_structure,
  v.brightness, v.warmth, v.clean_headroom, v.compression,
  '{}'::jsonb, '{}'::jsonb,
  jsonb_build_object('verified', true, 'source', 'curated_gear_phase3_v1', 'version', 1),
  v.tags, '', true
from (
  values
    -- British warmth with VU-meter mojo: round, mid-forward.
    ('ashdown', 'ABM / Rootmaster', 'solid_state', 'bass_warm_british', 5.5, 6.5, 7, 5,
      array['ashdown rootmaster 500 evo iii', 'ashdown abm 600 evo iv', 'ashdown studio 15', 'ashdown abm 300 evo iv', 'ashdown ctm-100', 'ashdown five fifteen', 'ashdown original c112t-300', 'ashdown original hd-1', 'ashdown rm-500 evo ii', 'ashdown rootmaster rm-c112t-500', 'ashdown studio 10', 'ashdown studio 12', 'ashdown studio 8', 'ashdown little bastard lb-30']::text[]),
    -- Compact clean Danish platforms with TonePrint flexibility.
    ('tc-electronic', 'BH / BQ Series', 'solid_state', 'bass_solid_state_clean', 6, 5, 8, 4.5,
      array['tc electronic bam200', 'tc electronic bq500', 'tc electronic bg250-208', 'tc electronic bg250-112', 'tc electronic bg250-115', 'tc electronic bh250', 'tc electronic bh550', 'tc electronic bh800', 'tc electronic rh450', 'tc electronic bq250']::text[]),
    -- Compact clean German heads.
    ('warwick', 'Gnome / LWA', 'solid_state', 'bass_solid_state_clean', 6, 5.5, 7.5, 4.5,
      array['warwick gnome', 'warwick bc 10', 'warwick bc 150', 'warwick bc 20', 'warwick bc 40', 'warwick bc 80', 'warwick gnome i', 'warwick gnome i pro', 'warwick lwa 1000', 'warwick lwa 500']::text[]),
    -- Workhorse combos: punchy reliable SS voicing.
    ('peavey', 'MAX Series', 'solid_state', 'bass_solid_state_punch', 5.5, 5.5, 7, 4.5,
      array['peavey max 250', 'peavey minimax 500', 'peavey minimega 1000', 'peavey max 100', 'peavey max 150', 'peavey max 208', 'peavey max 300', 'peavey minimega 600', 'peavey tko 115']::text[]),
    -- Scandinavian hi-fi: crisp clean articulation.
    ('ebs', 'Reidmar / Session', 'solid_state', 'bass_solid_state_hifi', 6.5, 5, 8, 4.5,
      array['ebs magni 500 210', 'ebs reidmar 502', 'ebs reidmar 752', 'ebs session 120', 'ebs session 30 mkii', 'ebs session 60 mkii', 'ebs fafner ii', 'ebs td660']::text[]),
    -- Smooth hi-fi warmth: polished studio-friendly voicing.
    ('eden', 'WT / Terra Nova', 'solid_state', 'bass_solid_state_hifi', 6, 6, 7.5, 4.5,
      array['eden terra nova tn226', 'eden terra nova tn501', 'eden wtx-264', 'eden wtx500', 'eden wt550 traveler', 'eden wt-800']::text[]),
    -- Flexible modern combos with drive voicings.
    ('blackstar', 'Unity', 'solid_state', 'bass_solid_state_punch', 6, 5.5, 7, 5,
      array['blackstar unity 120', 'blackstar unity 250', 'blackstar unity 30', 'blackstar unity 500', 'blackstar unity 60']::text[]),
    -- Small-driver hi-fi arrays: ultra-clean detail.
    ('phil-jones', 'Suitcase / BG', 'solid_state', 'bass_solid_state_hifi', 6.5, 5, 7.5, 4.5,
      array['phil jones bass cub bg-100', 'phil jones bass cub pro bg-120', 'phil jones briefcase bg-100', 'phil jones double four bg-75', 'phil jones suitcase compact bg-400']::text[]),
    -- British pre-shape punch: scooped fast attack.
    ('trace-elliot', 'Elf / Series', 'solid_state', 'bass_solid_state_punch', 6, 5.5, 7.5, 4.5,
      array['trace elliot elf', 'trace elliot elf combo 1x10', 'trace elliot elf combo 2x8', 'trace elliot transit b', 'trace elliot ah350smx']::text[]),
    -- Bright aluminum-cone hi-fi: crisp slap-ready top.
    ('swr', 'Marcus / Redhead', 'solid_state', 'bass_solid_state_hifi', 7, 4.5, 8, 4,
      array['swr sm-500', 'swr super redhead', 'swr workingman''s 12', 'swr sm-900']::text[]),
    -- Digital bass amps: flexible amp-type modeling.
    ('boss', 'Katana Bass', 'digital_modeling', 'digital_modeling', 6, 5, 7.5, 4.5,
      array['boss dual cube bass lx', 'boss katana-110 bass', 'boss katana-210 bass']::text[]),
    -- Modern boutique clean with contour shaping.
    ('genzler', 'Magellan', 'solid_state', 'bass_solid_state_clean', 6, 5.5, 7.5, 4.5,
      array['genzler magellan 350', 'genzler magellan 800', 'genzler magellan 800 combo']::text[]),
    -- British warm/drive hybrid path.
    ('laney', 'Digbeth', 'solid_state', 'bass_warm_british', 5.5, 6, 7, 5,
      array['laney digbeth db200-210', 'laney digbeth db300-210', 'laney digbeth db500h']::text[]),
    -- Lightweight clean workhorses.
    ('genz-benz', 'Shuttle', 'solid_state', 'bass_solid_state_clean', 6, 5.5, 7.5, 4.5,
      array['genz benz shuttle 6.0', 'genz benz shuttle 9.0', 'genz benz streamliner 900']::text[]),
    -- High-end hi-fi DSP heads.
    ('bergantino', 'Forte', 'solid_state', 'bass_solid_state_hifi', 6, 5.5, 8, 4,
      array['bergantino b|amp ii', 'bergantino forte hp2']::text[]),
    -- Compact modeling bass combos.
    ('vox', 'VX Bass', 'digital_modeling', 'digital_modeling', 5.5, 5.5, 7, 4.5,
      array['vox pathfinder bass 10', 'vox vx50 ba']::text[]),
    -- Budget SS clean.
    ('behringer', 'Ultrabass', 'solid_state', 'bass_solid_state_clean', 5.5, 5, 7, 4.5,
      array['behringer ultrabass bxd3000h']::text[]),
    -- Compact clean combos.
    ('ibanez', 'Promethean', 'solid_state', 'bass_solid_state_clean', 6, 5.5, 7, 4.5,
      array['ibanez promethean p3110']::text[])
) as v(manufacturer_slug, model_name, amp_technology, gain_structure, brightness, warmth, clean_headroom, compression, tags)
join public.equipment_manufacturers m on m.slug = v.manufacturer_slug
on conflict (manufacturer_id, model_name, instrument_type) do update set
  amp_technology = excluded.amp_technology,
  gain_structure = excluded.gain_structure,
  brightness = excluded.brightness,
  warmth = excluded.warmth,
  clean_headroom = excluded.clean_headroom,
  compression = excluded.compression,
  metadata = excluded.metadata,
  tags = excluded.tags,
  is_active = true,
  updated_at = now();

-- Post-condition: all bass rows with tags must carry them inside search_text.
do $$
declare
  bad int;
begin
  select count(*) into bad from public.guitar_models g
  where (g.metadata->>'verified') = 'true' and g.is_active and g.instrument_type = 'bass'
    and coalesce(array_length(g.tags, 1), 0) > 0
    and position(lower(g.tags[1]) in lower(g.search_text)) = 0;
  if bad > 0 then raise exception 'gear phase3: % bass guitar rows missing tag phrases', bad; end if;

  select count(*) into bad from public.amp_models a
  where (a.metadata->>'verified') = 'true' and a.is_active and a.instrument_type = 'bass'
    and coalesce(array_length(a.tags, 1), 0) > 0
    and position(lower(a.tags[1]) in lower(a.search_text)) = 0;
  if bad > 0 then raise exception 'gear phase3: % bass amp rows missing tag phrases', bad; end if;
end $$;
