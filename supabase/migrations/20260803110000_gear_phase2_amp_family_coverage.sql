-- Phase 2 (gear): full guitar-amp family coverage of the picker catalog.
--
-- Same mechanism as phase 1 (20260803100000): every active guitar_amp catalog display name is
-- assigned to a behavior family in amp_models; match phrases live in tags[], folded into
-- search_text by sync_amp_model_search_text. Existing July-29 families keep their hand-tuned
-- values; new families are inserted with values chosen per archetype (rationale inline).
-- gain_structure strings are chosen around the engine triggers:
--   /vintage|plexi|tweed|blackface/ => +gain +mid ; /modern|high|rectifier|5150/ => -gain -bass.
-- Data-only, idempotent.

insert into public.equipment_manufacturers (name, slug)
values
  ('Blackstar', 'blackstar'),
  ('Mesa Boogie', 'mesa-boogie'),
  ('Vox', 'vox'),
  ('PRS', 'prs'),
  ('Hughes & Kettner', 'hughes-kettner'),
  ('Laney', 'laney'),
  ('Victory', 'victory'),
  ('Randall', 'randall'),
  ('Friedman', 'friedman'),
  ('Supro', 'supro'),
  ('Bugera', 'bugera'),
  ('Yamaha', 'yamaha'),
  ('Bogner', 'bogner'),
  ('Joyo', 'joyo'),
  ('Engl', 'engl'),
  ('NUX', 'nux'),
  ('Quilter', 'quilter'),
  ('Carr', 'carr'),
  ('Magnatone', 'magnatone'),
  ('Two-Rock', 'two-rock'),
  ('Hotone', 'hotone'),
  ('Revv', 'revv'),
  ('Egnater', 'egnater'),
  ('Suhr', 'suhr'),
  ('Matchless', 'matchless'),
  ('Bad Cat', 'bad-cat'),
  ('Tone King', 'tone-king'),
  ('Fishman', 'fishman'),
  ('Harley Benton', 'harley-benton'),
  ('Mooer', 'mooer'),
  ('DV Mark', 'dv-mark'),
  ('Hiwatt', 'hiwatt'),
  ('Jet City', 'jet-city'),
  ('Dr. Z', 'dr-z'),
  ('Benson', 'benson'),
  ('Ibanez', 'ibanez'),
  ('ZT', 'zt'),
  ('65amps', '65amps'),
  ('Ampeg', 'ampeg'),
  ('Divided by 13', 'divided-by-13'),
  ('Milkman', 'milkman'),
  ('Splawn', 'splawn'),
  ('Sunn', 'sunn'),
  ('Swart', 'swart'),
  ('Morgan', 'morgan'),
  ('Koch', 'koch'),
  ('Krank', 'krank'),
  ('Kustom', 'kustom'),
  ('Monoprice', 'monoprice'),
  ('Sound City', 'sound-city'),
  ('Budda', 'budda'),
  ('Crate', 'crate'),
  ('Fuchs', 'fuchs'),
  ('Music Man', 'music-man'),
  ('Silvertone', 'silvertone'),
  ('Traynor', 'traynor')
on conflict (slug) do nothing;

-- marshall-ss: 15 catalog names
update public.amp_models t
set tags = array['marshall mg15fx', 'marshall mg30fx', 'marshall mg', 'marshall code', 'marshall code50', 'marshall code 25', 'marshall mg10g', 'marshall mg15gfx', 'marshall mg30gfx', 'marshall as50d', 'marshall code 100', 'marshall code 50', 'marshall mg10', 'marshall mg102gfx', 'marshall mg15', 'marshall mg50gfx', 'marshall ms-2', 'marshall ms-4']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase2_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'marshall'
  and t.model_name = 'MG Series' and t.instrument_type = 'guitar';

-- marshall-dsl: 23 catalog names
update public.amp_models t
set tags = array['marshall dsl1', 'marshall dsl5cr', 'marshall dsl20', 'marshall dsl20cr', 'marshall dsl40', 'marshall dsl40cr', 'marshall dsl100h', 'marshall jvm410h', 'marshall jvm', 'marshall dsl', 'marshall dsl1hr', 'marshall dsl20hr', 'marshall jvm205c', 'marshall jvm205h', 'marshall jvm410c', 'marshall dsl100hr', 'marshall dsl1cr', 'marshall jvm210c', 'marshall jvm210h', 'marshall dsl401', 'marshall tsl100', 'marshall tsl60', 'marshall valvestate 8080', 'marshall valvestate vs100', 'marshall avt150', 'marshall avt50']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase2_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'marshall'
  and t.model_name = 'DSL Series' and t.instrument_type = 'guitar';

-- marshall-plexi: 37 catalog names
update public.amp_models t
set tags = array['marshall jcm800 2203', 'marshall jcm800', 'marshall sv20h studio vintage', 'marshall sc20h studio classic', 'marshall 2555x silver jubilee', 'marshall origin 20c', 'marshall origin 50h', 'marshall 1959slp', 'marshall plexi', 'marshall super lead', 'marshall origin20c', 'marshall origin50h', 'marshall silver jubilee 2555x', 'marshall 1959 handwired', 'marshall 1962 bluesbreaker', 'marshall 2525c', 'marshall 2525h', 'marshall jcm800 2203x', 'marshall jcm900 4100', 'marshall jtm45 2245', 'marshall ori20c', 'marshall sc20c', 'marshall sc20h', 'marshall sv20c', 'marshall sv20h', 'marshall origin 20h', 'marshall origin 50c', 'marshall 1959hw', 'marshall 1987x', 'marshall 2525c mini jubilee', 'marshall 2525h mini jubilee', 'marshall sc20c studio classic', 'marshall st20c studio jtm', 'marshall st20h studio jtm', 'marshall sv20c studio vintage', 'marshall 1974x', 'marshall astoria classic', 'marshall astoria custom', 'marshall jcm800 2204', 'marshall jcm900 4500', 'marshall jmp 2203']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase2_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'marshall'
  and t.model_name = 'Plexi / JCM800 Studio' and t.instrument_type = 'guitar';

-- fender-mustang: 10 catalog names
update public.amp_models t
set tags = array['fender mustang gtx100', 'fender mustang gtx50', 'fender mustang lt25', 'fender mustang lt40', 'fender mustang micro', 'fender mustang gt', 'fender mustang gtx', 'fender mustang lt', 'fender mustang modeling', 'fender mustang lt50', 'fender mustang lt40s', 'fender mustang micro plus', 'fender mustang gt 100', 'fender mustang gt 200', 'fender mustang gt 40']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase2_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'fender'
  and t.model_name = 'Mustang GTX / LT' and t.instrument_type = 'guitar';

-- fender-hotrod: 4 catalog names
update public.amp_models t
set tags = array['fender hot rod deluxe iv', 'fender hot rod deluxe', 'fender hot rod deville', 'fender hot rod', 'hot rod deluxe', 'fender blues deluxe reissue', 'fender hot rod deville 212 iv', 'fender super-sonic 22']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase2_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'fender'
  and t.model_name = 'Hot Rod Deluxe IV' and t.instrument_type = 'guitar';

-- fender-tweed: 11 catalog names
update public.amp_models t
set tags = array['fender blues junior iv', 'fender blues junior', 'fender blues jr', 'blues junior tweed', 'fender bassbreaker 007', 'fender bassbreaker 15', 'fender bassbreaker 30r', 'fender pro junior iv', 'fender champion 600', 'fender pawn shop excelsior', 'fender pawn shop greta', 'fender super champ x2', 'fender super champ xd', 'fender champ 12']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase2_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'fender'
  and t.model_name = 'Blues Junior IV' and t.instrument_type = 'guitar';

-- fender-ss: 14 catalog names
update public.amp_models t
set tags = array['fender champion 20', 'fender champion 40', 'fender champion', 'champion modeling combo', 'fender champion 100', 'fender acoustasonic 40', 'fender acoustasonic 90', 'fender champion 50xl', 'fender frontman 10g', 'fender frontman 20g', 'fender bronco 40', 'fender deluxe 85', 'fender performer 1000', 'fender princeton chorus', 'fender stage 112se', 'fender ultimate chorus']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase2_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'fender'
  and t.model_name = 'Champion 40' and t.instrument_type = 'guitar';

-- fender-twin: 9 catalog names
update public.amp_models t
set tags = array['fender ''65 twin reverb', 'fender 65 twin reverb', 'fender tone master twin reverb', 'fender twin reverb', 'fender twin', 'twin reverb blackface', 'fender 57 custom twin-amp', 'fender 68 custom twin reverb', 'fender tone master pro', 'fender tone master super reverb', 'fender vibro-king', 'fender 59 bassman ltd']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase2_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'fender'
  and t.model_name = '''65 Twin Reverb' and t.instrument_type = 'guitar';

-- fender-deluxe: 15 catalog names
update public.amp_models t
set tags = array['fender ''65 deluxe reverb', 'fender 65 deluxe reverb', 'fender tone master deluxe reverb', 'fender deluxe reverb', 'fender ''65 princeton reverb', 'fender 65 princeton reverb', 'fender tone master princeton reverb', 'fender princeton reverb', 'deluxe reverb blackface', 'fender ''68 custom deluxe reverb', 'fender 57 custom champ', 'fender 57 custom deluxe', 'fender 64 custom deluxe reverb', 'fender 64 custom princeton reverb', 'fender 68 custom deluxe reverb', 'fender 68 custom princeton reverb', 'fender 68 custom vibro champ reverb', 'fender 68 custom vibrolux reverb', 'fender 68 custom pro reverb']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase2_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'fender'
  and t.model_name = '''65 Deluxe Reverb' and t.instrument_type = 'guitar';

-- blackstar-ht: 19 catalog names
update public.amp_models t
set tags = array['blackstar ht-20r mkiii', 'blackstar ht club 40 mkiii', 'blackstar ht-5r mkii', 'blackstar ht', 'blackstar id', 'blackstar isf', 'blackstar st. james 50 el34', 'blackstar st. james 50 6l6', 'blackstar ht club 40 mkii', 'blackstar ht stage 60 212 mkii', 'blackstar ht-1r mkii', 'blackstar ht-20r mkii', 'blackstar sonnet 120', 'blackstar sonnet 60', 'blackstar st. james 50 6l6 combo', 'blackstar st. james 50 6l6 head', 'blackstar st. james 50 el34 head', 'blackstar artisan 15', 'blackstar artisan 30', 'blackstar artist 15', 'blackstar artist 30', 'blackstar ht metal 5']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase2_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'blackstar'
  and t.model_name = 'HT Series' and t.instrument_type = 'guitar';

-- mesa-recto: 9 catalog names
update public.amp_models t
set tags = array['mesa boogie dual rectifier solo head', 'mesa boogie dual rectifier', 'mesa dual rectifier', 'mesa boogie mini rectifier 25', 'mesa mini rectifier', 'mesa recto', 'mesa rectifier', 'mesa boogie badlander 50', 'mesa boogie badlander 25', 'mesa boogie badlander 100', 'mesa boogie rectoverb 25', 'mesa boogie roadster', 'mesa boogie stiletto ace', 'mesa boogie single rectifier solo 50']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase2_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'mesa-boogie'
  and t.model_name = 'Dual Rectifier' and t.instrument_type = 'guitar';

-- mesa-mark: 8 catalog names
update public.amp_models t
set tags = array['mesa boogie mark v 90', 'mesa boogie mark v 35', 'mesa boogie mark v 25', 'mesa boogie mark v', 'mesa mark v', 'mesa mark iv', 'mesa mark series', 'mesa boogie jp-2c', 'mesa boogie mark vii', 'mesa boogie mark five 25', 'mesa boogie mark five 35', 'mesa boogie mark five 90', 'mesa boogie mark iv']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase2_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'mesa-boogie'
  and t.model_name = 'Mark V' and t.instrument_type = 'guitar';

-- orange-terror: 18 catalog names
update public.amp_models t
set tags = array['orange tiny terror', 'orange micro terror', 'orange micro dark', 'orange crush 12', 'orange crush 20', 'orange crush 35rt', 'orange terror', 'orange crush', 'orange super crush 100', 'orange crush 20rt', 'orange crush pro cr120c', 'orange crush pro cr120h', 'orange crush pro cr60c', 'orange dual terror', 'orange pedal baby 100', 'orange rocker 15 terror', 'orange super crush 100 combo', 'orange super crush 100 head', 'orange terror stamp', 'orange tremlord 30']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase2_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'orange'
  and t.model_name = 'Tiny Terror / Crush' and t.instrument_type = 'guitar';

-- orange-rockerverb: 14 catalog names
update public.amp_models t
set tags = array['orange rockerverb 50 mkiii', 'orange rockerverb 50 mkiii head', 'orange rockerverb', 'orange th30', 'orange th', 'orange rocker 15', 'orange rocker 32', 'orange super crush 100', 'orange super crush', 'orange ad30htc', 'orange or15h', 'orange rockerverb 100 mkiii head', 'orange rockerverb 50 mkiii combo', 'orange o-tone 40', 'orange or50', 'orange rocker 30', 'orange thunderverb 200', 'orange thunderverb 50']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase2_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'orange'
  and t.model_name = 'Rockerverb / TH' and t.instrument_type = 'guitar';

-- vox-ac: 21 catalog names
update public.amp_models t
set tags = array['vox ac30c2', 'vox ac30', 'vox ac15c1', 'vox ac15', 'vox ac30s1', 'vox mv50 ac', 'vox ac class a', 'vox ac10c1', 'vox ac15c2', 'vox ac15hw1', 'vox ac30c2x', 'vox ac30hw2', 'vox ac4c1-12', 'vox mini superbeetle', 'vox mv50 boutique', 'vox mv50 clean', 'vox mv50 high gain', 'vox mv50 rock', 'vox ac15c1x', 'vox ac30vr', 'vox ac4tv', 'vox lil night train nt2h', 'vox night train nt15h g2', 'vox ac30ch']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase2_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'vox'
  and t.model_name = 'AC30 / AC15' and t.instrument_type = 'guitar';

-- roland-jc: 3 catalog names
update public.amp_models t
set tags = array['roland jc-120', 'roland jc120', 'roland jc-40', 'roland jc40', 'roland jazz chorus', 'jc-120', 'jazz chorus clean', 'roland jc-22']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase2_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'roland'
  and t.model_name = 'JC-120 Jazz Chorus' and t.instrument_type = 'guitar';

-- boss-katana: 32 catalog names
update public.amp_models t
set tags = array['boss katana-50 mkii', 'boss katana-100 mkii', 'boss katana artist mkii', 'boss katana-50 gen 3', 'boss katana-100 gen 3', 'boss katana-100/212 gen 3', 'boss katana artist gen 3', 'boss katana head mkii', 'boss katana-50', 'boss katana-100', 'boss katana-mini', 'boss katana artist', 'boss katana', 'katana modeling', 'roland blues cube artist', 'roland blues cube hot', 'roland blues cube stage', 'roland cube street ex', 'roland cube street ii', 'roland micro cube gx', 'boss cube street ii', 'boss dual cube lx', 'boss katana-50 mkii ex', 'boss katana-air', 'boss katana-air ex', 'boss katana-mini x', 'boss nextone artist', 'boss nextone special', 'boss nextone stage', 'boss waza amp head', 'boss acoustic singer live', 'boss acoustic singer live lt', 'boss acoustic singer pro', 'roland cube 10gx', 'roland cube 40gx', 'roland cube 80gx', 'boss katana-100/212 mkii']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase2_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'boss'
  and t.model_name = 'Katana' and t.instrument_type = 'guitar';

-- peavey-6505: 11 catalog names
update public.amp_models t
set tags = array['peavey 6505 mh', 'peavey 6505+ 112 combo', 'peavey 6505 plus', 'peavey 6505', 'peavey 5150', '6505 metal', 'peavey invective.120', 'peavey 6505+ head', 'peavey 6505 ii head', 'peavey 6505 mh mini head', 'peavey invective mh', 'peavey 5150 head', 'peavey 5150 212 combo', 'peavey 6534+', 'peavey jsx']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase2_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'peavey'
  and t.model_name = '6505' and t.instrument_type = 'guitar';

-- peavey-classic: 4 catalog names
update public.amp_models t
set tags = array['peavey classic 30', 'peavey classic 20', 'peavey classic', 'peavey classic 30 112', 'peavey classic 50 212', 'peavey delta blues 210 ii']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase2_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'peavey'
  and t.model_name = 'Classic 30' and t.instrument_type = 'guitar';

-- peavey-ss: 7 catalog names
update public.amp_models t
set tags = array['peavey bandit 112', 'peavey bandit', 'peavey transtube', 'peavey vypyr x2', 'peavey valveking ii 20 micro head', 'peavey vypyr x1', 'peavey vypyr x3', 'peavey envoy 110', 'peavey studio pro 112']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase2_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'peavey'
  and t.model_name = 'Bandit 112' and t.instrument_type = 'guitar';

-- line6: 18 catalog names
update public.amp_models t
set tags = array['line 6 catalyst 60', 'line 6 catalyst 100', 'line 6 catalyst 200', 'line 6 catalyst', 'line 6 spider v 60 mkii', 'line 6 spider v', 'line 6 spider', 'line 6 modeling', 'line 6 spider v 120 mkii', 'line 6 catalyst cx 100', 'line 6 catalyst cx 200', 'line 6 catalyst cx 60', 'line 6 powercab 112', 'line 6 powercab 112 plus', 'line 6 spider v 20 mkii', 'line 6 spider v 240 mkii', 'line 6 spider v 30 mkii', 'line 6 dt25 112 combo', 'line 6 dt25 head', 'line 6 dt50 head', 'line 6 flextone iii', 'line 6 vetta ii']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase2_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'line-6'
  and t.model_name = 'Catalyst / Spider' and t.instrument_type = 'guitar';

-- evh: 11 catalog names
update public.amp_models t
set tags = array['evh 5150iii 50w el34 head', 'evh 5150iii 100s 6l6 head', 'evh 5150iii 50w 6l6 head', 'evh 5150iii 100w', 'evh iconic 40w 1x12 combo', 'evh 5150iii', 'evh 5150', 'evh iconic', 'evh 5150 iconic 15w 1x10', 'evh 5150 iconic 40w 1x12', 'evh 5150 iconic 60w head', 'evh 5150iii 100w head', 'evh 5150iii 50w 6l6 combo', 'evh 5150iii lbx', 'evh 5150iii lbxii']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase2_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'evh'
  and t.model_name = '5150III' and t.instrument_type = 'guitar';

-- diezel: 7 catalog names
update public.amp_models t
set tags = array['diezel vh4', 'diezel herbert', 'diezel vh', 'diezel d-moll', 'diezel hagen', 'diezel herbert mkiii', 'diezel paul', 'diezel vhx']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase2_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'diezel'
  and t.model_name = 'VH4' and t.instrument_type = 'guitar';

-- soldano: 7 catalog names
update public.amp_models t
set tags = array['soldano slo-100', 'soldano slo 100', 'soldano slo', 'soldano super lead overdrive', 'soldano slo-30', 'soldano slo-100 classic', 'soldano astro-20', 'soldano slo-30 1x12 combo', 'soldano slo-30 head', 'soldano slo mini']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase2_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'soldano'
  and t.model_name = 'SLO-100' and t.instrument_type = 'guitar';

-- spark: 7 catalog names
update public.amp_models t
set tags = array['positive grid spark 40', 'positive grid spark mini', 'positive grid spark 2', 'positive grid spark', 'spark 40', 'spark amp', 'positive grid spark go', 'positive grid spark live', 'positive grid spark neo']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase2_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'positive-grid'
  and t.model_name = 'Spark' and t.instrument_type = 'guitar';

-- prs-mt: 3 catalog names
update public.amp_models t
set tags = array['prs mt 15', 'prs mt15', 'prs mark tremonti', 'prs archon', 'prs archon 50', 'prs archon 100']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase2_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'prs'
  and t.model_name = 'MT 15' and t.instrument_type = 'guitar';

insert into public.amp_models (
  manufacturer_id, model_name, instrument_type, amp_technology, gain_structure,
  brightness, warmth, clean_headroom, compression,
  eq_behaviour, presence_behaviour, metadata, tags, search_text, is_active
)
select
  m.id, v.model_name, 'guitar', v.amp_technology, v.gain_structure,
  v.brightness, v.warmth, v.clean_headroom, v.compression,
  '{}'::jsonb, '{}'::jsonb,
  jsonb_build_object('verified', true, 'source', 'curated_gear_phase2_v1', 'version', 1),
  v.tags, '', true
from (
  values
    -- Blackstar's digital/practice line: flexible modeling voicings, generous clean headroom.
    ('blackstar', 'ID / Debut (digital)', 'digital_modeling', 'digital_modeling', 6, 5, 7, 4.5,
      array['blackstar id:core 40 v4', 'blackstar id:core v4', 'blackstar fly 3', 'blackstar debut 10e', 'blackstar debut 15e', 'blackstar debut 50r', 'blackstar dept.10 amped 1', 'blackstar dept.10 amped 2', 'blackstar dept.10 amped 3', 'blackstar id:core 10 v3', 'blackstar id:core 20 v3', 'blackstar id:core 40 v3', 'blackstar silverline deluxe', 'blackstar silverline special', 'blackstar silverline stage']::text[]),
    -- Boogie's vintage-American side (Fillmore, Lone Star, California Tweed, Triple Crown): warm tube drive, decent headroom.
    ('mesa-boogie', 'Fillmore / Lone Star', 'tube', 'vintage_american_drive', 6, 6, 6.5, 4.5,
      array['mesa boogie fillmore 25', 'mesa boogie california tweed 6v6 2:20', 'mesa boogie california tweed 6v6 4:40', 'mesa boogie fillmore 100', 'mesa boogie fillmore 50', 'mesa boogie lone star special', 'mesa boogie tc-50 triple crown', 'mesa boogie electra dyne', 'mesa boogie express 5:25 plus', 'mesa boogie express 5:50 plus', 'mesa boogie triple crown tc-100', 'mesa boogie blue angel', 'mesa boogie maverick', 'mesa boogie royal atlantic ra-100', 'mesa boogie subway rocket', 'mesa boogie transatlantic ta-15', 'mesa boogie transatlantic ta-30']::text[]),
    -- Vox practice/modeling line: bright-ish modeling platform with solid cleans.
    ('vox', 'Valvetronix / Pathfinder', 'digital_modeling', 'digital_modeling', 6, 5, 7, 4.5,
      array['vox mini go 50', 'vox vt40x', 'vox valvetronix vt20x', 'vox valvetronix vt40x', 'vox adio air gt', 'vox cambridge50', 'vox pathfinder 10', 'vox valvetronix vt100x', 'vox pathfinder 15r']::text[]),
    -- PRS's vintage-voiced heads (Hendrix plexi lineage): pushed mids, moderate headroom.
    ('prs', 'HDRX / Sonzera', 'tube', 'vintage_plexi_crunch', 6.5, 5.5, 5, 4.5,
      array['prs hdrx 100', 'prs hdrx 20', 'prs hdrx 50', 'prs sonzera 20', 'prs sonzera 50']::text[]),
    -- German tight modern rock/metal voicing with usable cleans.
    ('hughes-kettner', 'TubeMeister / Black Spirit', 'tube', 'modern_high_gain', 6, 5, 6, 5.5,
      array['hughes & kettner black spirit 200', 'hughes & kettner tubemeister deluxe 20', 'hughes & kettner grandmeister deluxe 40', 'hughes & kettner triamp mark 3', 'hughes & kettner black spirit 200 head', 'hughes & kettner ampman classic', 'hughes & kettner ampman modern', 'hughes & kettner black spirit 200 combo', 'hughes & kettner black spirit 200 floor', 'hughes & kettner spirit of metal nano', 'hughes & kettner spirit of rock nano', 'hughes & kettner spirit of vintage nano', 'hughes & kettner tubemeister deluxe 40', 'hughes & kettner statesman dual 6l6']::text[]),
    -- British metal heritage (Iommi): thick mids, tight high gain; Lionheart side keeps it warm.
    ('laney', 'Ironheart / Lionheart', 'tube', 'british_high_gain', 6, 5.5, 5, 5.5,
      array['laney cub-super12', 'laney ironheart irt60h', 'laney lionheart l20t-212', 'laney cub super 10', 'laney cub super 12r', 'laney ironheart irt120h', 'laney irt studio', 'laney lionheart l20h', 'laney lionheart l5t-112', 'laney lx65r', 'laney gh100l', 'laney gh50l', 'laney vc30-112']::text[]),
    -- Boutique British modern: focused tight gain (Kraken) to sparkling vintage (Duchess).
    ('victory', 'V4 / Duchess / Kraken', 'tube', 'modern_high_gain', 6, 5, 5.5, 5.5,
      array['victory v40 the duchess', 'victory sheriff 22', 'victory v30 the countess', 'victory rk50 richie kotzen head', 'victory the sheriff 44', 'victory v4 the duchess guitar amp', 'victory v4 the jack guitar amp', 'victory v4 the kraken guitar amp', 'victory v4 the sheriff guitar amp', 'victory v40 the duchess deluxe combo', 'victory v40 the duchess deluxe head', 'victory vc35 the copper deluxe head']::text[]),
    -- Metal-first voicing, scooped tight low end (Dimebag lineage on the SS RG side).
    ('randall', 'Diavlo / RG', 'tube', 'modern_high_gain', 5.5, 4.5, 5, 6,
      array['randall rd20h', 'randall rg1503h', 'randall diavlo rd20h', 'randall diavlo rd45h', 'randall diavlo rd5h', 'randall rg80', 'randall satan 50', 'randall thrasher 120', 'randall nb king 100', 'randall rg1003h', 'randall rg100es']::text[]),
    -- Hot-rodded plexi: pushed mids and saturation with vintage feel.
    ('friedman', 'BE / Smallbox', 'tube', 'vintage_plexi_hotrod', 6.5, 5.5, 4.5, 5.5,
      array['friedman be-100 deluxe', 'friedman be-50 deluxe', 'friedman be-mini', 'friedman dirty shirley 40 head', 'friedman dirty shirley combo', 'friedman jj-100 jerry cantrell', 'friedman pt-20 pink taco', 'friedman runt-20 head', 'friedman runt-50 head', 'friedman smallbox 50 head']::text[]),
    -- Vintage-American small amps: early warm breakup, low headroom.
    ('supro', 'Delta King / Black Magick', 'tube', 'vintage_tweed_breakup', 6, 6.5, 3.5, 5,
      array['supro amulet', 'supro blues king 10', 'supro blues king 12', 'supro blues king 8', 'supro delegate', 'supro delta king 10', 'supro delta king 12', 'supro delta king 8', 'supro black magick']::text[]),
    -- Affordable takes on classic high-gain circuits (6262=5150-style, Trirec=recto-style).
    ('bugera', 'Infinium', 'tube', 'modern_high_gain', 5.5, 5, 5, 5.5,
      array['bugera 333xl infinium', 'bugera 6262 infinium', 'bugera t50 infinium', 'bugera v22 infinium', 'bugera v5 infinium', 'bugera v55 infinium', 'bugera g20 infinium', 'bugera trirec infinium']::text[]),
    -- Desktop modeling: hi-fi cleans and polite gain at low volume.
    ('yamaha', 'THR', 'digital_modeling', 'digital_modeling', 6, 5, 7.5, 4.5,
      array['yamaha thr10ii', 'yamaha thr30ii wireless', 'yamaha thr10ii wireless', 'yamaha thr30iia wireless', 'yamaha thr5', 'yamaha thr5a', 'yamaha thr100h', 'yamaha thr100hd']::text[]),
    -- Boutique LA high gain: rich harmonics, elastic feel.
    ('bogner', 'Ecstasy / Shiva', 'tube', 'boutique_high_gain', 6, 5.5, 5, 5.5,
      array['bogner ecstasy 101b', 'bogner atma head', 'bogner goldfinger 45', 'bogner helios 100', 'bogner helios 50', 'bogner shiva 20th anniversary', 'bogner uberschall revision blue']::text[]),
    -- Mini hybrid heads cloning classic voicings; limited headroom.
    ('joyo', 'BanTamP', 'hybrid', 'british_crunch', 5.5, 5, 4.5, 5.5,
      array['joyo dc-15', 'joyo bantamp atomic atm-7', 'joyo bantamp bluejay blj-5', 'joyo bantamp jackman jma-10', 'joyo bantamp meteor met-8', 'joyo bantamp vivo viv-3', 'joyo bantamp zombie zom-6']::text[]),
    -- German precision metal: tight compressed gain, controlled lows.
    ('engl', 'Fireball / Powerball', 'tube', 'modern_high_gain', 5.5, 4.5, 5.5, 6,
      array['engl fireball 25', 'engl powerball ii', 'engl fireball 100', 'engl fireball 60', 'engl ironball se 20', 'engl savage 120 mkii']::text[]),
    -- Budget desktop modeling: flexible, clean-leaning.
    ('nux', 'Mighty', 'digital_modeling', 'digital_modeling', 6, 5, 7, 4.5,
      array['nux mighty 60', 'nux mighty 20bt', 'nux mighty 40bt', 'nux mighty 8bt mkii', 'nux mighty lite bt mkii', 'nux mighty space']::text[]),
    -- High-headroom SS pedal platforms voiced like vintage American tube.
    ('quilter', 'Tone Block / Aviator', 'solid_state', 'solid_state_clean', 6, 5.5, 8.5, 4,
      array['quilter 101 reverb head', 'quilter aviator cub', 'quilter overdrive 202', 'quilter superblock uk', 'quilter superblock us', 'quilter tone block 202']::text[]),
    -- Boutique American vintage cleans with lively breakup.
    ('carr', 'Mercury / Rambler', 'tube', 'vintage_blackface_clean', 6.5, 5.5, 6.5, 4,
      array['carr mercury v', 'carr rambler', 'carr sportsman', 'carr telstar', 'carr skylark']::text[]),
    -- Vintage American pitch-vibrato amps: warm dimensional cleans.
    ('magnatone', 'Twilighter / Super', 'tube', 'vintage_american_clean', 6.5, 6, 6.5, 4,
      array['magnatone panoramic stereo 212', 'magnatone starlite', 'magnatone super fifteen', 'magnatone super fifty-nine m-80', 'magnatone twilighter 112']::text[]),
    -- D-style boutique: huge clean headroom, singing smooth drive.
    ('two-rock', 'Classic Reverb / Studio', 'tube', 'boutique_clean_headroom', 6.5, 5.5, 8, 4,
      array['two-rock classic reverb signature', 'two-rock studio signature', 'two-rock vintage deluxe', 'two-rock bloomfield drive', 'two-rock traditional clean']::text[]),
    -- Mini SS heads cloning classic voicings.
    ('hotone', 'Nano Legacy / Pulze', 'solid_state', 'solid_state_crunch', 6, 5, 5.5, 5,
      array['hotone nano legacy british invasion', 'hotone nano legacy heart attack', 'hotone nano legacy mojo diamond', 'hotone nano legacy purple wind', 'hotone pulze luna']::text[]),
    -- Canadian modern metal: surgical tight high gain.
    ('revv', 'Generator / G20', 'tube', 'modern_high_gain', 5.5, 4.5, 5.5, 6,
      array['revv d20', 'revv g20', 'revv generator 100p mkii', 'revv generator 100r mkii', 'revv generator 120 mkiii']::text[]),
    -- Versatile boutique-ish tube: blendable British/American voicing.
    ('egnater', 'Rebel / Tweaker', 'tube', 'british_mid_gain', 6, 5.5, 5.5, 5,
      array['egnater rebel-20', 'egnater rebel-30', 'egnater renegade 65', 'egnater tweaker 15', 'egnater tweaker 40']::text[]),
    -- Boutique plexi-lineage: pushed mids, dynamic crunch.
    ('suhr', 'Badger / SL68', 'tube', 'vintage_plexi_crunch', 6.5, 5.5, 5, 4.5,
      array['suhr badger 18', 'suhr badger 30', 'suhr bella', 'suhr hombre', 'suhr sl68']::text[]),
    -- Class-A chime benchmark: bright, touch-sensitive.
    ('matchless', 'DC-30 / Spitfire', 'tube', 'vintage_class_a_chime', 7, 5, 5.5, 4.5,
      array['matchless dc-30', 'matchless hc-30', 'matchless laurel canyon 1x12', 'matchless spitfire 1x12']::text[]),
    -- Class-A boutique: chimey cleans, harmonically rich drive.
    ('bad-cat', 'Cub / Hot Cat', 'tube', 'vintage_class_a_chime', 7, 5, 5.5, 4.5,
      array['bad cat black cat 1x12', 'bad cat cub 1x12', 'bad cat hot cat 1x12', 'bad cat lynx head']::text[]),
    -- Vintage American recreations: blackface cleans, tweed breakup.
    ('tone-king', 'Imperial / Falcon', 'tube', 'vintage_blackface_clean', 6.5, 5.5, 6, 4,
      array['tone king falcon grande', 'tone king gremlin', 'tone king imperial mkii', 'tone king royalist mkiii']::text[]),
    -- Acoustic amplification: flat, clean, feedback-controlled.
    ('fishman', 'Loudbox', 'solid_state', 'solid_state_clean', 6, 5.5, 8.5, 4,
      array['fishman loudbox mini', 'fishman loudbox artist', 'fishman loudbox mini charge', 'fishman loudbox performer']::text[]),
    -- Budget small tube amps: early breakup, simple voicing.
    ('harley-benton', 'TUBE Series', 'tube', 'vintage_tweed_breakup', 6, 5.5, 4.5, 5,
      array['harley benton hb-20r', 'harley benton tube15 head', 'harley benton tube30c', 'harley benton tube5 celestion']::text[]),
    -- Budget digital modeling combos.
    ('mooer', 'Hornet / SD', 'digital_modeling', 'digital_modeling', 6, 5, 7, 4.5,
      array['mooer hornet 15i', 'mooer hornet white', 'mooer sd30', 'mooer sd75']::text[]),
    -- Lightweight jazz-clean SS: neutral, high headroom.
    ('dv-mark', 'Little Jazz / Micro', 'solid_state', 'solid_state_clean', 6, 5.5, 8.5, 4,
      array['dv mark dv jazz 12', 'dv mark little jazz', 'dv mark micro 50 ii', 'dv mark triple 6']::text[]),
    -- Hiwatt loud clean: massive headroom, articulate top (Gilmour/Townshend).
    ('hiwatt', 'Custom DR', 'tube', 'classic_british_clean', 6.5, 5, 8.5, 4,
      array['hiwatt custom 100 dr103', 'hiwatt custom 20 combo', 'hiwatt custom 20 head', 'hiwatt custom 50 dr504']::text[]),
    -- Soldano-designed budget line: SLO-style crunch.
    ('jet-city', 'JCA', 'tube', 'boutique_high_gain', 6, 5, 4.5, 5.5,
      array['jet city jca20h', 'jet city jca2112rc', 'jet city jca22h', 'jet city jca50h']::text[]),
    -- Boutique class-A: chimey, touch-responsive.
    ('dr-z', 'Maz / Carmen Ghia', 'tube', 'vintage_class_a_chime', 7, 5, 5.5, 4.5,
      array['dr. z carmen ghia', 'dr. z maz 18 jr', 'dr. z z-28 mkii']::text[]),
    -- Modern boutique vintage-American: hi-fi cleans, smooth breakup.
    ('benson', 'Monarch / Chimera', 'tube', 'vintage_american_clean', 6.5, 5.5, 6, 4,
      array['benson chimera', 'benson monarch', 'benson vinny']::text[]),
    -- Tube Screamer-fronted tube combos: warm pushed mids.
    ('ibanez', 'TSA', 'tube', 'vintage_tweed_breakup', 6, 6, 5, 4.5,
      array['ibanez tsa15', 'ibanez tsa30']::text[]),
    -- Tiny high-output SS: surprisingly loud clean platform.
    ('zt', 'Lunchbox', 'solid_state', 'solid_state_clean', 6, 5, 7.5, 4.5,
      array['zt lunchbox', 'zt lunchbox junior']::text[]),
    -- Boutique British class-A: chime with grind.
    ('65amps', 'London / Empire', 'tube', 'vintage_class_a_chime', 7, 5, 5, 4.5,
      array['65amps empire', '65amps london']::text[]),
    -- Ampeg's guitar tube amps: fat vintage American crunch.
    ('ampeg', 'GVT / VT', 'tube', 'vintage_american_crunch', 6, 6, 6, 4.5,
      array['ampeg gvt52-112', 'ampeg vt-22']::text[]),
    -- Boutique class-A/AB hybrids: chime into raunch.
    ('divided-by-13', 'CJ / FTR', 'tube', 'vintage_class_a_chime', 6.5, 5.5, 5.5, 4.5,
      array['divided by 13 cj 11', 'divided by 13 ftr 37']::text[]),
    -- Boutique vintage-American: sparkling cleans.
    ('milkman', 'Creamer / The Amp', 'tube', 'vintage_blackface_clean', 6.5, 5.5, 6.5, 4,
      array['milkman creamer', 'milkman the amp 100']::text[]),
    -- Hot-rodded Marshall lineage: aggressive mids, tight gain.
    ('splawn', 'Quick Rod / Nitro', 'tube', 'british_high_gain', 6, 5, 4, 5.5,
      array['splawn nitro', 'splawn quick rod']::text[]),
    -- Doom/stoner staple: huge dark low-mid weight.
    ('sunn', 'Model T / Beta Lead', 'tube', 'vintage_plexi_crunch', 5, 6.5, 6, 5,
      array['sunn beta lead', 'sunn model t']::text[]),
    -- Boutique tweed-flavored: lush tremolo/reverb, early breakup.
    ('swart', 'AST / STR', 'tube', 'vintage_tweed_breakup', 6, 6, 4, 4.5,
      array['swart atomic space tone', 'swart str-tremolo']::text[]),
    -- Boutique AC-style chime.
    ('morgan', 'AC20', 'tube', 'vintage_class_a_chime', 7, 5, 5.5, 4.5,
      array['morgan ac20 deluxe']::text[]),
    -- Dutch versatile studio tube amp.
    ('koch', 'Studiotone', 'tube', 'british_mid_gain', 6, 5.5, 5.5, 5,
      array['koch studiotone xl']::text[]),
    -- 2000s metal: scooped aggressive high gain (Dimebag association).
    ('krank', 'Krankenstein', 'tube', 'modern_high_gain', 5.5, 4.5, 4, 6,
      array['krank krankenstein']::text[]),
    -- Budget small tube: simple early-breakup design.
    ('kustom', 'Defender', 'tube', 'vintage_tweed_breakup', 6, 5.5, 4.5, 4.5,
      array['kustom defender v5']::text[]),
    -- Budget tube combo: tweed-ish breakup.
    ('monoprice', 'Stage Right', 'tube', 'vintage_tweed_breakup', 6, 5.5, 4.5, 4.5,
      array['monoprice stage right 15w 1x12']::text[]),
    -- Hiwatt-adjacent British clean power.
    ('sound-city', 'SC30', 'tube', 'classic_british_clean', 6.5, 5, 7.5, 4,
      array['sound city sc30']::text[]),
    -- Class-A-ish drive with vocal mids.
    ('budda', 'Superdrive', 'tube', 'british_mid_gain', 6, 5.5, 5, 5,
      array['budda superdrive 30']::text[]),
    -- 90s American high gain.
    ('crate', 'Blue Voodoo', 'tube', 'modern_high_gain', 5.5, 5, 4.5, 5.5,
      array['crate blue voodoo bv120h']::text[]),
    -- D-style smooth singing overdrive with clean headroom.
    ('fuchs', 'Overdrive Supreme', 'tube', 'boutique_smooth_overdrive', 6, 6, 6.5, 5,
      array['fuchs overdrive supreme 50']::text[]),
    -- 70s hybrid: loud punchy cleans.
    ('music-man', 'HD-130', 'hybrid', 'classic_british_clean', 6.5, 5, 8, 4,
      array['music man hd-130']::text[]),
    -- Vintage garage-rock grind: raw early breakup.
    ('silvertone', '1484 Twin Twelve', 'tube', 'vintage_tweed_breakup', 5.5, 6, 4.5, 4.5,
      array['silvertone 1484 twin twelve']::text[]),
    -- Canadian workhorse: clean-to-crunch British-ish voicing.
    ('traynor', 'YCV50', 'tube', 'classic_british_clean', 6.5, 5.5, 6.5, 4.5,
      array['traynor ycv50 blue']::text[])
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

-- Post-condition: all guitar-mode amp rows with tags must carry them inside search_text.
do $$
declare
  bad int;
begin
  select count(*) into bad
  from public.amp_models a
  where (a.metadata->>'verified') = 'true'
    and a.is_active and a.instrument_type = 'guitar'
    and coalesce(array_length(a.tags, 1), 0) > 0
    and position(lower(a.tags[1]) in lower(a.search_text)) = 0;
  if bad > 0 then
    raise exception 'gear phase2: % amp rows missing tag phrases in search_text', bad;
  end if;
end $$;
