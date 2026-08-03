-- Phase 0 (gear repair): restore gear-behavior name matching, wiped by search_text triggers.
--
-- REGRESSION: 20260716090000 added BEFORE INSERT OR UPDATE triggers (sync_guitar_model_search_text /
-- sync_amp_model_search_text) that REBUILD search_text from brand_id + name + category (+ amp_type /
-- pickup_configuration) + tags. The July-29 verified gear seeds (20260729120000/130000/150000) wrote
-- packed match phrases directly into search_text; the triggers overwrote them at insert time (brand_id
-- is null for these rows, so e.g. Katana became " katana amp modeling "). Result: the picker display
-- names ("Boss Katana-50 MkII") no longer ILIKE-match any verified row and every adaptation fell back
-- to generic keyword inference.
--
-- FIX: store the phrases in tags (text[]). The triggers concat array_to_string(tags, ' ') into
-- search_text on every write, so the phrases now SURVIVE any future rewrite. Each phrase stays a
-- contiguous substring after the space-join, so search_text ILIKE '%<picker display name>%' matches.
--
-- Data-only, idempotent: plain UPDATEs keyed by (manufacturer slug, model_name, instrument_type).
-- The BEFORE UPDATE trigger rebuilds search_text as a side effect of each UPDATE.

update public.amp_models t
set tags = array['fender ''65 twin reverb', 'fender 65 twin reverb', 'fender tone master twin reverb', 'fender twin reverb', 'fender twin', 'twin reverb blackface']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'fender'
  and t.model_name = '''65 Twin Reverb'
  and t.instrument_type = 'guitar';

update public.amp_models t
set tags = array['fender ''65 deluxe reverb', 'fender 65 deluxe reverb', 'fender tone master deluxe reverb', 'fender deluxe reverb', 'fender ''65 princeton reverb', 'fender 65 princeton reverb', 'fender tone master princeton reverb', 'fender princeton reverb', 'deluxe reverb blackface']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'fender'
  and t.model_name = '''65 Deluxe Reverb'
  and t.instrument_type = 'guitar';

update public.amp_models t
set tags = array['fender blues junior iv', 'fender blues junior', 'fender blues jr', 'blues junior tweed']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'fender'
  and t.model_name = 'Blues Junior IV'
  and t.instrument_type = 'guitar';

update public.amp_models t
set tags = array['fender hot rod deluxe iv', 'fender hot rod deluxe', 'fender hot rod deville', 'fender hot rod', 'hot rod deluxe']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'fender'
  and t.model_name = 'Hot Rod Deluxe IV'
  and t.instrument_type = 'guitar';

update public.amp_models t
set tags = array['fender champion 20', 'fender champion 40', 'fender champion', 'champion modeling combo']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'fender'
  and t.model_name = 'Champion 40'
  and t.instrument_type = 'guitar';

update public.amp_models t
set tags = array['fender mustang gtx100', 'fender mustang gtx50', 'fender mustang lt25', 'fender mustang lt40', 'fender mustang micro', 'fender mustang gt', 'fender mustang gtx', 'fender mustang lt', 'fender mustang modeling']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'fender'
  and t.model_name = 'Mustang GTX / LT'
  and t.instrument_type = 'guitar';

update public.amp_models t
set tags = array['marshall dsl1', 'marshall dsl5cr', 'marshall dsl20', 'marshall dsl20cr', 'marshall dsl40', 'marshall dsl40cr', 'marshall dsl100h', 'marshall jvm410h', 'marshall jvm', 'marshall dsl']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'marshall'
  and t.model_name = 'DSL Series'
  and t.instrument_type = 'guitar';

update public.amp_models t
set tags = array['marshall jcm800 2203', 'marshall jcm800', 'marshall sv20h studio vintage', 'marshall sc20h studio classic', 'marshall 2555x silver jubilee', 'marshall origin 20c', 'marshall origin 50h', 'marshall 1959slp', 'marshall plexi', 'marshall super lead']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'marshall'
  and t.model_name = 'Plexi / JCM800 Studio'
  and t.instrument_type = 'guitar';

update public.amp_models t
set tags = array['marshall mg15fx', 'marshall mg30fx', 'marshall mg', 'marshall code']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'marshall'
  and t.model_name = 'MG Series'
  and t.instrument_type = 'guitar';

update public.amp_models t
set tags = array['vox ac30c2', 'vox ac30', 'vox ac15c1', 'vox ac15', 'vox ac30s1', 'vox mv50 ac', 'vox ac class a']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'vox'
  and t.model_name = 'AC30 / AC15'
  and t.instrument_type = 'guitar';

update public.amp_models t
set tags = array['roland jc-120', 'roland jc120', 'roland jc-40', 'roland jc40', 'roland jazz chorus', 'jc-120', 'jazz chorus clean']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'roland'
  and t.model_name = 'JC-120 Jazz Chorus'
  and t.instrument_type = 'guitar';

update public.amp_models t
set tags = array['mesa boogie dual rectifier solo head', 'mesa boogie dual rectifier', 'mesa dual rectifier', 'mesa boogie mini rectifier 25', 'mesa mini rectifier', 'mesa recto', 'mesa rectifier']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'mesa-boogie'
  and t.model_name = 'Dual Rectifier'
  and t.instrument_type = 'guitar';

update public.amp_models t
set tags = array['mesa boogie mark v 90', 'mesa boogie mark v 35', 'mesa boogie mark v 25', 'mesa boogie mark v', 'mesa mark v', 'mesa mark iv', 'mesa mark series']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'mesa-boogie'
  and t.model_name = 'Mark V'
  and t.instrument_type = 'guitar';

update public.amp_models t
set tags = array['peavey 6505 mh', 'peavey 6505+ 112 combo', 'peavey 6505 plus', 'peavey 6505', 'peavey 5150', '6505 metal']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'peavey'
  and t.model_name = '6505'
  and t.instrument_type = 'guitar';

update public.amp_models t
set tags = array['peavey classic 30', 'peavey classic 20', 'peavey classic']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'peavey'
  and t.model_name = 'Classic 30'
  and t.instrument_type = 'guitar';

update public.amp_models t
set tags = array['peavey bandit 112', 'peavey bandit', 'peavey transtube']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'peavey'
  and t.model_name = 'Bandit 112'
  and t.instrument_type = 'guitar';

update public.amp_models t
set tags = array['orange rockerverb 50 mkiii', 'orange rockerverb 50 mkiii head', 'orange rockerverb', 'orange th30', 'orange th', 'orange rocker 15', 'orange rocker 32', 'orange super crush 100', 'orange super crush']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'orange'
  and t.model_name = 'Rockerverb / TH'
  and t.instrument_type = 'guitar';

update public.amp_models t
set tags = array['orange tiny terror', 'orange micro terror', 'orange micro dark', 'orange crush 12', 'orange crush 20', 'orange crush 35rt', 'orange terror', 'orange crush']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'orange'
  and t.model_name = 'Tiny Terror / Crush'
  and t.instrument_type = 'guitar';

update public.amp_models t
set tags = array['evh 5150iii 50w el34 head', 'evh 5150iii 100s 6l6 head', 'evh 5150iii 50w 6l6 head', 'evh 5150iii 100w', 'evh iconic 40w 1x12 combo', 'evh 5150iii', 'evh 5150', 'evh iconic']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'evh'
  and t.model_name = '5150III'
  and t.instrument_type = 'guitar';

update public.amp_models t
set tags = array['blackstar ht-20r mkiii', 'blackstar ht club 40 mkiii', 'blackstar ht-5r mkii', 'blackstar ht', 'blackstar id', 'blackstar isf']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'blackstar'
  and t.model_name = 'HT Series'
  and t.instrument_type = 'guitar';

update public.amp_models t
set tags = array['line 6 catalyst 60', 'line 6 catalyst 100', 'line 6 catalyst 200', 'line 6 catalyst', 'line 6 spider v 60 mkii', 'line 6 spider v', 'line 6 spider', 'line 6 modeling']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'line-6'
  and t.model_name = 'Catalyst / Spider'
  and t.instrument_type = 'guitar';

update public.amp_models t
set tags = array['boss katana-50 mkii', 'boss katana-100 mkii', 'boss katana artist mkii', 'boss katana-50 gen 3', 'boss katana-100 gen 3', 'boss katana-100/212 gen 3', 'boss katana artist gen 3', 'boss katana head mkii', 'boss katana-50', 'boss katana-100', 'boss katana-mini', 'boss katana artist', 'boss katana', 'katana modeling']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'boss'
  and t.model_name = 'Katana'
  and t.instrument_type = 'guitar';

update public.amp_models t
set tags = array['positive grid spark 40', 'positive grid spark mini', 'positive grid spark 2', 'positive grid spark', 'spark 40', 'spark amp']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'positive-grid'
  and t.model_name = 'Spark'
  and t.instrument_type = 'guitar';

update public.amp_models t
set tags = array['prs mt 15', 'prs mt15', 'prs mark tremonti', 'prs archon']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'prs'
  and t.model_name = 'MT 15'
  and t.instrument_type = 'guitar';

update public.amp_models t
set tags = array['soldano slo-100', 'soldano slo 100', 'soldano slo', 'soldano super lead overdrive']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'soldano'
  and t.model_name = 'SLO-100'
  and t.instrument_type = 'guitar';

update public.amp_models t
set tags = array['diezel vh4', 'diezel herbert', 'diezel vh']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'diezel'
  and t.model_name = 'VH4'
  and t.instrument_type = 'guitar';

update public.guitar_models t
set tags = array['fender player stratocaster', 'fender player plus stratocaster', 'fender american professional ii stratocaster', 'fender american ultra stratocaster', 'fender american performer stratocaster', 'fender stratocaster', 'fender strat']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'fender'
  and t.model_name = 'Stratocaster'
  and t.instrument_type = 'guitar';

update public.guitar_models t
set tags = array['fender player telecaster', 'fender player plus telecaster', 'fender american professional ii telecaster', 'fender american ultra telecaster', 'fender american performer telecaster', 'fender telecaster', 'fender tele']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'fender'
  and t.model_name = 'Telecaster'
  and t.instrument_type = 'guitar';

update public.guitar_models t
set tags = array['fender player jazzmaster', 'fender player jaguar', 'fender jazzmaster', 'fender jaguar', 'fender offset']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'fender'
  and t.model_name = 'Jazzmaster / Jaguar'
  and t.instrument_type = 'guitar';

update public.guitar_models t
set tags = array['squier affinity stratocaster', 'squier affinity telecaster', 'squier classic vibe 50s stratocaster', 'squier classic vibe 60s stratocaster', 'squier classic vibe 50s telecaster', 'squier classic vibe 60s telecaster', 'squier stratocaster', 'squier telecaster', 'squier strat', 'squier tele']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'squier'
  and t.model_name = 'Stratocaster / Telecaster'
  and t.instrument_type = 'guitar';

update public.guitar_models t
set tags = array['g&l legacy', 'g&l asat classic', 'g&l asat', 'g&l tribute', 'g&l']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'g-l'
  and t.model_name = 'Legacy / ASAT'
  and t.instrument_type = 'guitar';

update public.guitar_models t
set tags = array['gibson les paul standard 50s', 'gibson les paul standard 60s', 'gibson les paul studio', 'gibson les paul classic', 'gibson les paul modern', 'gibson les paul standard', 'gibson les paul']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'gibson'
  and t.model_name = 'Les Paul'
  and t.instrument_type = 'guitar';

update public.guitar_models t
set tags = array['epiphone les paul standard 50s', 'epiphone les paul standard 60s', 'epiphone les paul classic', 'epiphone les paul custom', 'epiphone les paul studio', 'epiphone les paul traditional pro ii', 'epiphone les paul traditional', 'epiphone les paul']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'epiphone'
  and t.model_name = 'Les Paul'
  and t.instrument_type = 'guitar';

update public.guitar_models t
set tags = array['gibson sg standard', 'gibson sg', 'epiphone sg standard', 'epiphone sg']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'gibson'
  and t.model_name = 'SG'
  and t.instrument_type = 'guitar';

update public.guitar_models t
set tags = array['gibson es-335', 'gibson es 335', 'epiphone es-335', 'epiphone casino', 'es-335', 'casino semi hollow']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'gibson'
  and t.model_name = 'ES-335 / Casino'
  and t.instrument_type = 'guitar';

update public.guitar_models t
set tags = array['gibson explorer', 'gibson flying v', 'epiphone explorer', 'epiphone flying v', 'explorer', 'flying v']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'gibson'
  and t.model_name = 'Explorer / Flying V'
  and t.instrument_type = 'guitar';

update public.guitar_models t
set tags = array['prs se custom 24', 'prs se custom 24-08', 'prs se standard 24', 'prs se mccarty 594', 'prs core custom 24', 'prs custom 24', 'prs mccarty', 'prs se']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'prs'
  and t.model_name = 'SE Custom 24'
  and t.instrument_type = 'guitar';

update public.guitar_models t
set tags = array['prs se silver sky', 'prs silver sky', 'silver sky']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'prs'
  and t.model_name = 'Silver Sky'
  and t.instrument_type = 'guitar';

update public.guitar_models t
set tags = array['ibanez rg550', 'ibanez rg421', 'ibanez rg470dx', 'ibanez rg', 'ibanez s521', 'ibanez s series', 'ibanez superstrat']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'ibanez'
  and t.model_name = 'RG / S'
  and t.instrument_type = 'guitar';

update public.guitar_models t
set tags = array['ibanez az2204', 'ibanez az224', 'ibanez az']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'ibanez'
  and t.model_name = 'AZ'
  and t.instrument_type = 'guitar';

update public.guitar_models t
set tags = array['ltd ec-256', 'ltd ec-1000', 'ltd ec', 'esp ltd', 'esp eclipse', 'esp']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'ltd'
  and t.model_name = 'EC / Metal'
  and t.instrument_type = 'guitar';

update public.guitar_models t
set tags = array['jackson dinky js22', 'jackson dinky js32', 'jackson dinky', 'jackson soloist', 'jackson rhoads', 'jackson']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'jackson'
  and t.model_name = 'Dinky / Soloist'
  and t.instrument_type = 'guitar';

update public.guitar_models t
set tags = array['schecter c-1 hellraiser', 'schecter c-1 platinum', 'schecter omen extreme-6', 'schecter c-1', 'schecter omen', 'schecter']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'schecter'
  and t.model_name = 'C-1 / Omen'
  and t.instrument_type = 'guitar';

update public.guitar_models t
set tags = array['solar a1.6', 'solar a series', 'solar guitars', 'solar a']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'solar'
  and t.model_name = 'A-Series'
  and t.instrument_type = 'guitar';

update public.guitar_models t
set tags = array['dean ml select', 'dean ml', 'dean guitars', 'dean']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'dean'
  and t.model_name = 'ML'
  and t.instrument_type = 'guitar';

update public.guitar_models t
set tags = array['yamaha pacifica 112v', 'yamaha pacifica', 'yamaha revstar rss20', 'yamaha revstar']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'yamaha'
  and t.model_name = 'Pacifica / Revstar'
  and t.instrument_type = 'guitar';

update public.guitar_models t
set tags = array['charvel pro-mod dk24', 'charvel pro-mod so-cal', 'charvel pro-mod san dimas', 'charvel pro-mod', 'charvel']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'charvel'
  and t.model_name = 'Pro-Mod'
  and t.instrument_type = 'guitar';

update public.guitar_models t
set tags = array['music man axis', 'music man jp15', 'music man jp', 'ernie ball music man', 'musicman']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'music-man'
  and t.model_name = 'Axis / JP'
  and t.instrument_type = 'guitar';

update public.guitar_models t
set tags = array['evh wolfgang standard', 'evh wolfgang special', 'evh wolfgang', 'wolfgang']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'evh'
  and t.model_name = 'Wolfgang'
  and t.instrument_type = 'guitar';

update public.guitar_models t
set tags = array['suhr classic s', 'suhr classic', 'suhr modern', 'suhr']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'suhr'
  and t.model_name = 'Classic S / Modern'
  and t.instrument_type = 'guitar';

update public.guitar_models t
set tags = array['gretsch g5420t electromatic', 'gretsch g5220 electromatic jet', 'gretsch electromatic', 'gretsch jet', 'gretsch']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'gretsch'
  and t.model_name = 'Electromatic'
  and t.instrument_type = 'guitar';

update public.amp_models t
set tags = array['ampeg svt-cl', 'ampeg svt-vr', 'ampeg svt-3pro', 'ampeg svt-7pro', 'ampeg portaflex pf-500', 'ampeg pf-500', 'ampeg pf-800', 'ampeg micro-vr', 'ampeg micro-cl', 'ampeg svt', 'ampeg']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'ampeg'
  and t.model_name = 'SVT'
  and t.instrument_type = 'bass';

update public.amp_models t
set tags = array['darkglass microtubes 500 v2', 'darkglass microtubes 900 v2', 'darkglass alpha-omega 500', 'darkglass alpha omega 900', 'darkglass microtubes', 'darkglass alpha omega', 'darkglass']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'darkglass'
  and t.model_name = 'Microtubes / Alpha-Omega'
  and t.instrument_type = 'bass';

update public.amp_models t
set tags = array['markbass little mark iv', 'markbass little mark iii', 'markbass little mark', 'markbass cmd 121p', 'markbass']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'markbass'
  and t.model_name = 'Little Mark'
  and t.instrument_type = 'bass';

update public.amp_models t
set tags = array['hartke lh500', 'hartke lh1000', 'hartke ha3500', 'hartke lh', 'hartke ha', 'hartke']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'hartke'
  and t.model_name = 'LH / HA'
  and t.instrument_type = 'bass';

update public.amp_models t
set tags = array['gallien krueger mb200', 'gallien krueger mb500', 'gallien krueger mb800', 'gallien krueger mb', 'gk mb', 'gallien krueger', 'gk']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'gallien-krueger'
  and t.model_name = 'MB Series'
  and t.instrument_type = 'bass';

update public.amp_models t
set tags = array['fender rumble 40', 'fender rumble 100', 'fender rumble 500', 'fender rumble 200', 'fender rumble']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'fender'
  and t.model_name = 'Rumble'
  and t.instrument_type = 'bass';

update public.amp_models t
set tags = array['aguilar tone hammer 350', 'aguilar tone hammer 500', 'aguilar tone hammer', 'aguilar ag700', 'aguilar']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'aguilar'
  and t.model_name = 'Tone Hammer'
  and t.instrument_type = 'bass';

update public.amp_models t
set tags = array['orange terror bass 500', 'orange terror bass', 'orange ob1-500', 'orange ob1', 'orange bass']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'orange'
  and t.model_name = 'Terror Bass'
  and t.instrument_type = 'bass';

update public.amp_models t
set tags = array['mesa boogie subway d-800', 'mesa boogie subway', 'mesa subway d-800', 'mesa subway', 'mesa bass']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'mesa-boogie'
  and t.model_name = 'Subway'
  and t.instrument_type = 'bass';

update public.guitar_models t
set tags = array['fender player precision bass', 'fender player plus precision bass', 'fender american professional ii precision bass', 'fender precision bass', 'fender p bass', 'p-bass']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'fender'
  and t.model_name = 'Precision Bass'
  and t.instrument_type = 'bass';

update public.guitar_models t
set tags = array['fender player jazz bass', 'fender player plus jazz bass', 'fender american professional ii jazz bass', 'fender jazz bass', 'fender j bass', 'jazz bass']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'fender'
  and t.model_name = 'Jazz Bass'
  and t.instrument_type = 'bass';

update public.guitar_models t
set tags = array['music man stingray special hh', 'music man stingray special h', 'music man stingray', 'ernie ball stingray', 'stingray bass']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'music-man'
  and t.model_name = 'StingRay'
  and t.instrument_type = 'bass';

update public.guitar_models t
set tags = array['ibanez sr300e', 'ibanez sr500e', 'ibanez sr1350b', 'ibanez gsr200', 'ibanez sr', 'ibanez soundgear']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'ibanez'
  and t.model_name = 'SR'
  and t.instrument_type = 'bass';

update public.guitar_models t
set tags = array['yamaha trbx304', 'yamaha trbx504', 'yamaha trbx', 'yamaha bb734a', 'yamaha bb']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'yamaha'
  and t.model_name = 'TRBX'
  and t.instrument_type = 'bass';

update public.guitar_models t
set tags = array['squier affinity precision bass pj', 'squier affinity jazz bass', 'squier affinity bass', 'squier precision bass', 'squier jazz bass', 'squier p bass', 'squier j bass']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'squier'
  and t.model_name = 'Affinity P/J Bass'
  and t.instrument_type = 'bass';

update public.guitar_models t
set tags = array['warwick rockbass corvette basic 4', 'warwick corvette', 'warwick rockbass', 'warwick']::text[]
from public.equipment_manufacturers m
where m.id = t.manufacturer_id
  and m.slug = 'warwick'
  and t.model_name = 'Corvette'
  and t.instrument_type = 'bass';

-- Post-conditions:
--  (a) no verified row may be left with EMPTY tags (would mean an UPDATE above missed its row);
--  (b) every verified row's search_text must contain its first match phrase (trigger folded tags in).
do $$
declare
  bad int;
begin
  select count(*) into bad
  from public.guitar_models g
  where (g.metadata->>'verified') = 'true'
    and g.is_active
    and coalesce(array_length(g.tags, 1), 0) = 0;
  if bad > 0 then
    raise exception 'gear phase0: % verified guitar_models rows still have empty tags (update missed)', bad;
  end if;

  select count(*) into bad
  from public.amp_models a
  where (a.metadata->>'verified') = 'true'
    and a.is_active
    and coalesce(array_length(a.tags, 1), 0) = 0;
  if bad > 0 then
    raise exception 'gear phase0: % verified amp_models rows still have empty tags (update missed)', bad;
  end if;

  select count(*) into bad
  from public.guitar_models g
  where (g.metadata->>'verified') = 'true'
    and g.is_active
    and coalesce(array_length(g.tags, 1), 0) > 0
    and position(lower(g.tags[1]) in lower(g.search_text)) = 0;
  if bad > 0 then
    raise exception 'gear phase0: % guitar_models rows missing tag phrases in search_text', bad;
  end if;

  select count(*) into bad
  from public.amp_models a
  where (a.metadata->>'verified') = 'true'
    and a.is_active
    and coalesce(array_length(a.tags, 1), 0) > 0
    and position(lower(a.tags[1]) in lower(a.search_text)) = 0;
  if bad > 0 then
    raise exception 'gear phase0: % amp_models rows missing tag phrases in search_text', bad;
  end if;
end $$;
