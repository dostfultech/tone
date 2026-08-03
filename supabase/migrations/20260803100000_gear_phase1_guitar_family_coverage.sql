-- Phase 1 (gear): full electric-guitar family coverage of the picker catalog.
--
-- Every active electric_guitar catalog display name is assigned to a tonal FAMILY row in
-- guitar_models. Match phrases live in tags (text[]): the sync_guitar_model_search_text trigger
-- folds tags into search_text on every write (see phase 0, 20260803090000), so the exact picker
-- display names below are guaranteed to ILIKE-match their family row.
--
-- Existing July-29 families keep their hand-tuned values; their tags are REPLACED with
-- original phrases + all assigned catalog names. New families are inserted with hand-tuned
-- output_level / brightness / warmth / compression chosen per archetype (rationale inline).
-- Data-only, idempotent.

insert into public.equipment_manufacturers (name, slug)
values
  ('Gibson', 'gibson'),
  ('Ibanez', 'ibanez'),
  ('ESP', 'esp'),
  ('Schecter', 'schecter'),
  ('Kramer', 'kramer'),
  ('B.C. Rich', 'bc-rich'),
  ('Harley Benton', 'harley-benton'),
  ('Cort', 'cort'),
  ('Reverend', 'reverend'),
  ('Sterling by Music Man', 'sterling-by-music-man'),
  ('D''Angelico', 'd-angelico'),
  ('Guild', 'guild'),
  ('Chapman', 'chapman'),
  ('Eastman', 'eastman'),
  ('Danelectro', 'danelectro'),
  ('Hagstrom', 'hagstrom'),
  ('Duesenberg', 'duesenberg'),
  ('Godin', 'godin'),
  ('Vintage', 'vintage'),
  ('Rickenbacker', 'rickenbacker'),
  ('Washburn', 'washburn'),
  ('Sire', 'sire'),
  ('Strandberg', 'strandberg'),
  ('FGN', 'fgn'),
  ('Aria', 'aria'),
  ('Jet', 'jet'),
  ('Mayones', 'mayones'),
  ('Ormsby', 'ormsby'),
  ('Kiesel', 'kiesel'),
  ('Eastwood', 'eastwood'),
  ('Balaguer', 'balaguer'),
  ('Peavey', 'peavey')
on conflict (slug) do nothing;

-- fender-strat: 75 catalog names
update public.guitar_models t
set tags = array['fender player stratocaster', 'fender player plus stratocaster', 'fender american professional ii stratocaster', 'fender american ultra stratocaster', 'fender american performer stratocaster', 'fender stratocaster', 'fender strat', 'fender american vintage ii 1961 stratocaster', 'fender vintera ii 50s stratocaster', 'fender vintera ii 60s stratocaster', 'fender player ii stratocaster', 'fender standard stratocaster', 'fender standard stratocaster hss', 'fender american professional ii stratocaster hss', 'fender american ultra ii stratocaster', 'fender american vintage ii 1957 stratocaster', 'fender eric clapton stratocaster', 'fender jeff beck stratocaster', 'fender player stratocaster hss', 'fender stevie ray vaughan stratocaster', 'fender aerodyne special stratocaster hss', 'fender american original 50s stratocaster', 'fender american original 60s stratocaster', 'fender american performer stratocaster hss', 'fender american professional i stratocaster', 'fender american professional ii stratocaster left-hand', 'fender american special stratocaster', 'fender american ultra ii stratocaster hss', 'fender american ultra ii stratocaster left-hand', 'fender american ultra luxe stratocaster', 'fender american ultra luxe stratocaster hss floyd rose', 'fender american ultra stratocaster hss', 'fender american vintage ii 1973 stratocaster', 'fender blacktop stratocaster hh', 'fender buddy guy stratocaster', 'fender ed obrien eob stratocaster', 'fender eric johnson signature virginia stratocaster', 'fender eric johnson stratocaster', 'fender eric johnson thinline stratocaster', 'fender h.e.r. stratocaster', 'fender highway one stratocaster', 'fender jim root stratocaster', 'fender jv modified 50s stratocaster hss', 'fender jv modified 60s stratocaster', 'fender made in japan elemental stratocaster', 'fender made in japan elemental stratocaster hh', 'fender made in japan hybrid ii stratocaster', 'fender made in japan traditional 50s stratocaster', 'fender made in japan traditional 60s stratocaster', 'fender made in japan traditional 70s stratocaster', 'fender michael landau coma stratocaster', 'fender mike mccready stratocaster', 'fender parallel universe ii strat jazz deluxe', 'fender parallel universe ii uptown strat', 'fender pawn shop 70s stratocaster deluxe', 'fender player ii modified stratocaster hss', 'fender player ii stratocaster hss', 'fender player plus stratocaster hss', 'fender player stratocaster hsh', 'fender player stratocaster left-hand', 'fender player stratocaster plus top', 'fender richie kotzen stratocaster', 'fender ritchie blackmore stratocaster', 'fender robert cray stratocaster', 'fender tash sultana stratocaster', 'fender tom morello soul power stratocaster', 'fender vintera 50s stratocaster', 'fender vintera 50s stratocaster modified', 'fender vintera 60s stratocaster', 'fender vintera 60s stratocaster modified', 'fender vintera 70s stratocaster', 'fender vintera ii 70s stratocaster', 'fender yngwie malmsteen stratocaster', 'fender john mayer stratocaster', 'fender nile rodgers hitmaker stratocaster', 'fender steve lacy people pleaser stratocaster', 'fender tom delonge stratocaster']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase1_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'fender'
  and t.model_name = 'Stratocaster' and t.instrument_type = 'guitar';

-- fender-tele: 54 catalog names
update public.guitar_models t
set tags = array['fender player telecaster', 'fender player plus telecaster', 'fender american professional ii telecaster', 'fender american ultra telecaster', 'fender american performer telecaster', 'fender telecaster', 'fender tele', 'fender american vintage ii 1951 telecaster', 'fender vintera ii 50s telecaster', 'fender vintera ii 60s telecaster', 'fender 75th anniversary player ii telecaster', 'fender 75th anniversary vintera road worn 1951 telecaster', 'fender american professional classic telecaster', 'fender limited vintera iii early ''60s custom telecaster', 'fender player ii telecaster', 'fender player ii telecaster hh', 'fender american ultra ii telecaster', 'fender aerodyne special telecaster', 'fender american original 50s telecaster', 'fender american original 60s telecaster', 'fender american performer telecaster hum', 'fender american professional i telecaster', 'fender american professional ii telecaster deluxe', 'fender american professional ii telecaster left-hand', 'fender american special telecaster', 'fender american ultra luxe telecaster', 'fender american ultra luxe telecaster hh floyd rose', 'fender american vintage ii 1963 telecaster', 'fender american vintage ii 1975 telecaster deluxe', 'fender blacktop telecaster hh', 'fender brad paisley road worn telecaster', 'fender highway one telecaster', 'fender jim root telecaster', 'fender jv modified 60s custom telecaster', 'fender made in japan hybrid ii telecaster', 'fender made in japan traditional 50s telecaster', 'fender made in japan traditional 60s telecaster', 'fender parallel universe ii jazz tele', 'fender parallel universe ii troublemaker tele', 'fender player ii modified telecaster sh', 'fender player plus nashville telecaster', 'fender player telecaster hh', 'fender player telecaster left-hand', 'fender richie kotzen telecaster', 'fender vintera 50s telecaster', 'fender vintera 50s telecaster modified', 'fender vintera 60s telecaster', 'fender vintera 60s telecaster bigsby', 'fender vintera 60s telecaster modified', 'fender vintera 70s telecaster custom', 'fender vintera 70s telecaster deluxe', 'fender vintera ii 50s nocaster', 'fender vintera ii 70s telecaster deluxe', 'fender vintera ii 70s telecaster thinline', 'fender chrissie hynde telecaster', 'fender jason isbell custom telecaster']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase1_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'fender'
  and t.model_name = 'Telecaster' and t.instrument_type = 'guitar';

-- fender-offset: 54 catalog names
update public.guitar_models t
set tags = array['fender player jazzmaster', 'fender player jaguar', 'fender jazzmaster', 'fender jaguar', 'fender offset', 'fender kurt cobain jaguar', 'fender player mustang', 'fender mustang 90', 'fender vintera ii jaguar', 'fender aerodyne special jazzmaster', 'fender american original 60s jaguar', 'fender american original 60s jazzmaster', 'fender american performer jazzmaster', 'fender american performer mustang', 'fender american professional ii jaguar', 'fender american professional ii jazzmaster', 'fender american professional ii jazzmaster left-hand', 'fender american ultra ii jazzmaster', 'fender american ultra jazzmaster', 'fender american vintage ii 1966 jaguar', 'fender american vintage ii 1966 jazzmaster', 'fender blacktop jaguar hh', 'fender blacktop jazzmaster hs', 'fender jim root jazzmaster', 'fender kurt cobain jag-stang', 'fender kurt cobain mustang', 'fender made in japan elemental jazzmaster', 'fender made in japan traditional 60s jaguar', 'fender made in japan traditional 60s jazzmaster', 'fender meteora player plus', 'fender parallel universe ii maverick dorado', 'fender parallel universe ii meteora hh', 'fender pawn shop 72', 'fender pawn shop bass vi', 'fender pawn shop mustang special', 'fender player duo-sonic', 'fender player duo-sonic hs', 'fender player ii jaguar', 'fender player ii jazzmaster', 'fender player ii mustang', 'fender player lead ii', 'fender player lead iii', 'fender player mustang 90', 'fender player plus jazzmaster', 'fender player plus meteora hh', 'fender player plus meteora ss', 'fender vintera 60s jaguar', 'fender vintera 60s jaguar modified hh', 'fender vintera 60s jazzmaster', 'fender vintera 60s jazzmaster modified', 'fender vintera 60s mustang', 'fender vintera 70s mustang', 'fender vintera ii 50s jazzmaster', 'fender vintera ii 60s jazzmaster', 'fender vintera ii 70s competition mustang', 'fender vintera ii 70s jaguar', 'fender gold foil jazzmaster']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase1_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'fender'
  and t.model_name = 'Jazzmaster / Jaguar' and t.instrument_type = 'guitar';

-- squier: 70 catalog names
update public.guitar_models t
set tags = array['squier affinity stratocaster', 'squier affinity telecaster', 'squier classic vibe 50s stratocaster', 'squier classic vibe 60s stratocaster', 'squier classic vibe 50s telecaster', 'squier classic vibe 60s telecaster', 'squier stratocaster', 'squier telecaster', 'squier strat', 'squier tele', 'squier contemporary stratocaster hh', 'squier j mascis jazzmaster', 'squier affinity stratocaster hss', 'squier sonic stratocaster', 'squier sonic telecaster', 'squier 40th anniversary jazzmaster gold edition', 'squier 40th anniversary stratocaster gold edition', 'squier 40th anniversary stratocaster vintage edition', 'squier 40th anniversary telecaster gold edition', 'squier 40th anniversary telecaster vintage edition', 'squier affinity jaguar hh', 'squier affinity jazzmaster', 'squier affinity starcaster', 'squier affinity stratocaster hss pack', 'squier affinity telecaster deluxe', 'squier affinity telecaster left-hand', 'squier bullet mustang hh', 'squier bullet stratocaster hss', 'squier bullet telecaster', 'squier classic vibe 60s competition mustang', 'squier classic vibe 60s custom esquire', 'squier classic vibe 60s jazzmaster', 'squier classic vibe 60s jazzmaster left-hand', 'squier classic vibe 60s mustang', 'squier classic vibe 60s stratocaster hss', 'squier classic vibe 60s telecaster custom', 'squier classic vibe 60s telecaster thinline', 'squier classic vibe 70s jaguar', 'squier classic vibe 70s stratocaster hss', 'squier classic vibe 70s telecaster custom', 'squier classic vibe 70s telecaster deluxe', 'squier classic vibe 70s telecaster thinline', 'squier classic vibe starcaster', 'squier contemporary active jazzmaster hh', 'squier contemporary active starcaster', 'squier contemporary stratocaster hh fr', 'squier contemporary stratocaster hss', 'squier contemporary stratocaster special ht', 'squier contemporary telecaster rh', 'squier debut series stratocaster', 'squier debut series stratocaster hss', 'squier debut series telecaster', 'squier fsr bullet competition mustang hh', 'squier fsr classic vibe 60s competition mustang', 'squier fsr classic vibe 70s competition mustang', 'squier paranormal baritone cabronita telecaster', 'squier paranormal cabronita telecaster thinline', 'squier paranormal custom bass vi', 'squier paranormal custom nashville stratocaster', 'squier paranormal esquire deluxe', 'squier paranormal jazzmaster xii', 'squier paranormal offset telecaster', 'squier paranormal super-sonic', 'squier paranormal toronado', 'squier sonic bronco stratocaster', 'squier sonic esquire h', 'squier sonic mustang', 'squier sonic mustang hh', 'squier sonic stratocaster hss', 'squier sonic stratocaster ht', 'squier sonic stratocaster ht h', 'squier classic vibe bass vi', 'squier mini jazzmaster hh', 'squier mini stratocaster']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase1_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'squier'
  and t.model_name = 'Stratocaster / Telecaster' and t.instrument_type = 'guitar';

-- gl: 26 catalog names
update public.guitar_models t
set tags = array['g&l legacy', 'g&l asat classic', 'g&l asat', 'g&l tribute', 'g&l', 'g&l s-500', 'g&l asat special', 'g&l comanche', 'g&l fallout', 'g&l tribute asat classic', 'g&l asat classic bluesboy', 'g&l asat deluxe', 'g&l doheny', 'g&l espada', 'g&l invader', 'g&l legacy hb', 'g&l legacy special', 'g&l rampage', 'g&l sc-2', 'g&l skyhawk', 'g&l tribute asat classic bluesboy', 'g&l tribute asat deluxe carved top', 'g&l tribute asat special', 'g&l tribute comanche', 'g&l tribute doheny', 'g&l tribute fallout', 'g&l tribute legacy', 'g&l tribute legacy hb', 'g&l tribute s-500']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase1_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'g-l'
  and t.model_name = 'Legacy / ASAT' and t.instrument_type = 'guitar';

-- semi-hollow-335: 47 catalog names
update public.guitar_models t
set tags = array['gibson es-335', 'gibson es 335', 'epiphone es-335', 'epiphone casino', 'es-335', 'casino semi hollow', 'epiphone sheraton ii pro', 'gibson es-339', 'epiphone es-339 p-90 pro', 'epiphone casino coupe', 'epiphone dave grohl dg-335', 'epiphone dot', 'epiphone riviera', 'epiphone sheraton', 'epiphone 1959 es-355', 'epiphone b.b. king lucille', 'epiphone blueshawk deluxe', 'epiphone casino worn', 'epiphone century', 'epiphone dot deluxe', 'epiphone dot studio', 'epiphone emily wolfe sheraton stealth', 'epiphone es-335 figured', 'epiphone es-339', 'epiphone gary clark jr. blak & blu casino', 'epiphone genesis deluxe pro', 'epiphone nighthawk custom reissue', 'epiphone noel gallagher riviera', 'epiphone riviera custom p93', 'epiphone uptown kat es', 'epiphone usa casino', 'epiphone wildkat', 'gibson b.b. king lucille', 'gibson es-335 figured', 'gibson es-345', 'gibson es-355', 'gibson blueshawk', 'gibson es-135', 'gibson es-137 classic', 'gibson es-137 custom', 'gibson es-235', 'gibson es-330', 'gibson es-333', 'gibson es-335 satin', 'gibson es-335 studio', 'gibson es-339 figured', 'gibson es-347', 'gibson midtown custom', 'gibson nighthawk standard', 'gibson tom delonge es-333']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase1_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'gibson'
  and t.model_name = 'ES-335 / Casino' and t.instrument_type = 'guitar';

-- explorer-fv: 20 catalog names
update public.guitar_models t
set tags = array['gibson explorer', 'gibson flying v', 'epiphone explorer', 'epiphone flying v', 'explorer', 'flying v', 'epiphone 1958 korina explorer', 'epiphone 1958 korina flying v', 'epiphone 1984 explorer ex', 'epiphone brendon small thunderhorse explorer', 'epiphone dave mustaine flying v exp', 'epiphone flying v prophecy', 'epiphone joe bonamassa amos korina flying v', 'epiphone kirk hammett 1979 flying v', 'epiphone richie faulkner flying v custom', 'gibson 70s flying v', 'gibson 70s explorer', 'gibson 80s explorer', 'gibson 80s flying v', 'gibson dave mustaine flying v exp', 'gibson rd artist', 'gibson theodore standard']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase1_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'gibson'
  and t.model_name = 'Explorer / Flying V' and t.instrument_type = 'guitar';

-- sg: 36 catalog names
update public.guitar_models t
set tags = array['gibson sg standard', 'gibson sg', 'epiphone sg standard', 'epiphone sg', 'gibson sg special', 'epiphone g-400 pro', 'epiphone tony iommi sg special', 'epiphone 1961 les paul sg standard', 'epiphone 1963 les paul sg custom', 'epiphone g-310', 'epiphone sg classic worn p-90s', 'epiphone sg custom', 'epiphone power players sg', 'epiphone sg modern figured', 'epiphone sg muse', 'epiphone sg prophecy', 'epiphone sg special', 'epiphone sg special satin e1', 'epiphone sg special ve', 'epiphone sg standard ''61', 'epiphone sg standard ''61 maestro vibrola', 'gibson angus young sg', 'gibson sg standard ''61', 'gibson tony iommi sg special', 'gibson gary clark jr. sg', 'gibson kirk douglas sg', 'gibson sg classic', 'gibson sg gothic', 'gibson sg junior', 'gibson sg modern', 'gibson sg special faded', 'gibson sg standard ''61 faded maestro vibrola', 'gibson sg standard ''61 maestro vibrola', 'gibson sg standard ''61 sideways vibrola', 'gibson sg standard hp', 'gibson sg supreme', 'gibson sg tribute', 'epiphone sg special p-90']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase1_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'gibson'
  and t.model_name = 'SG' and t.instrument_type = 'guitar';

-- epi-lp: 33 catalog names
update public.guitar_models t
set tags = array['epiphone les paul standard 50s', 'epiphone les paul standard 60s', 'epiphone les paul classic', 'epiphone les paul custom', 'epiphone les paul studio', 'epiphone les paul traditional pro ii', 'epiphone les paul traditional', 'epiphone les paul', 'epiphone les paul traditional pro ii with the pro buckers', 'epiphone les paul modern', 'epiphone 1959 les paul standard', 'epiphone kirk hammett greeny les paul standard', 'epiphone les paul muse', 'epiphone les paul standard', 'epiphone les paul standard plustop pro', 'epiphone slash les paul standard', 'epiphone adam jones les paul custom', 'epiphone alex lifeson les paul custom axcess', 'epiphone extura prophecy', 'epiphone jared james nichols gold glory les paul custom', 'epiphone jerry cantrell wino les paul custom', 'epiphone joe bonamassa black beauty les paul custom', 'epiphone les paul 100', 'epiphone les paul classic worn', 'epiphone les paul custom koa', 'epiphone les paul custom pro', 'epiphone les paul florentine pro', 'epiphone les paul modern figured', 'epiphone les paul prophecy', 'epiphone les paul studio e1', 'epiphone les paul tribute plus', 'epiphone les paul ultra-iii', 'epiphone matt heafy les paul custom origins', 'epiphone matt heafy les paul custom origins 7-string', 'epiphone vivian campbell holy diver les paul']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase1_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'epiphone'
  and t.model_name = 'Les Paul' and t.instrument_type = 'guitar';

-- gibson-lp: 38 catalog names
update public.guitar_models t
set tags = array['gibson les paul standard 50s', 'gibson les paul standard 60s', 'gibson les paul studio', 'gibson les paul classic', 'gibson les paul modern', 'gibson les paul standard', 'gibson les paul', 'gibson les paul custom', 'gibson jimmy page signature les paul', 'gibson kirk hammett greeny les paul standard', 'gibson les paul tribute', 'gibson slash les paul standard', 'gibson adam jones les paul standard', 'gibson les paul 70s deluxe', 'gibson les paul axcess custom', 'gibson les paul axcess standard', 'gibson les paul bfg', 'gibson les paul classic custom', 'gibson les paul deluxe', 'gibson les paul gothic', 'gibson les paul modern figured', 'gibson les paul modern lite', 'gibson les paul modern studio', 'gibson les paul recording', 'gibson les paul standard 50s faded', 'gibson les paul standard 50s figured top', 'gibson les paul standard 50s p-90', 'gibson les paul standard 60s faded', 'gibson les paul standard 60s figured top', 'gibson les paul standard hp', 'gibson les paul studio faded', 'gibson les paul studio lite', 'gibson les paul studio session', 'gibson les paul supreme', 'gibson les paul traditional', 'gibson les paul traditional pro v', 'gibson peter frampton phenix les paul custom', 'gibson slash jessica les paul standard', 'gibson slash victoria les paul standard goldtop']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase1_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'gibson'
  and t.model_name = 'Les Paul' and t.instrument_type = 'guitar';

-- prs-silver-sky: 2 catalog names
update public.guitar_models t
set tags = array['prs se silver sky', 'prs silver sky', 'silver sky']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase1_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'prs'
  and t.model_name = 'Silver Sky' and t.instrument_type = 'guitar';

-- prs: 65 catalog names
update public.guitar_models t
set tags = array['prs se custom 24', 'prs se custom 24-08', 'prs se standard 24', 'prs se mccarty 594', 'prs core custom 24', 'prs custom 24', 'prs mccarty', 'prs se', 'prs ce 24', 'prs s2 custom 24', 'prs s2 mccarty 594', 'prs se ce 24', 'prs se dgt', 'prs se mccarty 594 singlecut', 'prs mccarty 594', 'prs custom 22', 'prs dgt', 'prs hollowbody ii', 'prs paul''s guitar', 'prs s2 vela', 'prs se hollowbody ii', 'prs se paul''s guitar', 'prs se zach myers', 'prs tremonti', 'prs 509', 'prs ce 24 semi-hollow', 'prs custom 24 piezo', 'prs custom 24-08', 'prs dw ce 24 floyd', 'prs fiore', 'prs hollowbody ii piezo', 'prs mccarty 594 hollowbody ii', 'prs mccarty 594 singlecut', 'prs modern eagle v', 'prs myles kennedy', 'prs nf 53', 'prs s2 custom 22 semi-hollow', 'prs s2 custom 24-08', 'prs s2 mccarty 594 singlecut', 'prs s2 mccarty 594 thinline', 'prs s2 standard 22', 'prs s2 standard 24', 'prs s2 starla', 'prs s2 vela semi-hollow', 'prs santana', 'prs santana retro', 'prs se 245', 'prs se 277', 'prs se ce 24 standard satin', 'prs se custom 22 semi-hollow', 'prs se hollowbody ii piezo', 'prs se hollowbody standard', 'prs se mark holcomb', 'prs se mark holcomb svn', 'prs se mira', 'prs se nf3', 'prs se paul allender', 'prs se santana', 'prs se standard 24-08', 'prs se starla', 'prs se swamp ash special', 'prs se tremonti', 'prs special semi-hollow', 'prs studio', 'prs swamp ash special', 'prs se 277 baritone']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase1_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'prs'
  and t.model_name = 'SE Custom 24' and t.instrument_type = 'guitar';

-- ibanez-az: 10 catalog names
update public.guitar_models t
set tags = array['ibanez az2204', 'ibanez az224', 'ibanez az', 'ibanez az2402', 'ibanez azes40', 'ibanez az2204n', 'ibanez az226pb premium', 'ibanez az2407f', 'ibanez az242pbg premium', 'ibanez azes31', 'ibanez azs2200', 'ibanez azs2209']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase1_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'ibanez'
  and t.model_name = 'AZ' and t.instrument_type = 'guitar';

-- ibanez-rg: 62 catalog names
update public.guitar_models t
set tags = array['ibanez rg550', 'ibanez rg421', 'ibanez rg470dx', 'ibanez rg', 'ibanez s521', 'ibanez s series', 'ibanez superstrat', 'ibanez jem7v', 'ibanez jemjr', 'ibanez js140m', 'ibanez rg7421', 'ibanez rga42fm', 'ibanez s670qm', 'ibanez gio grx70qa', 'ibanez js240ps', 'ibanez grg170dx', 'ibanez pia3761', 'ibanez rg652ahm prestige', 'ibanez fr2020', 'ibanez fr400', 'ibanez grg121dx', 'ibanez grga120', 'ibanez grgm21 mikro', 'ibanez grx40', 'ibanez grx70qa', 'ibanez jem77', 'ibanez jem77p', 'ibanez js100', 'ibanez js1000', 'ibanez js2450', 'ibanez js3cr', 'ibanez pia3761c', 'ibanez ps120 paul stanley', 'ibanez q52', 'ibanez q54', 'ibanez q547', 'ibanez qx52', 'ibanez qx527pb', 'ibanez rg370ahmz', 'ibanez rg421ex', 'ibanez rg421msp', 'ibanez rg450dx', 'ibanez rg470ahm', 'ibanez rg5170b prestige', 'ibanez rg5320c prestige', 'ibanez rg550xh', 'ibanez rg565', 'ibanez rg752ahm prestige', 'ibanez rg8', 'ibanez rga61al axion label', 'ibanez rga8', 'ibanez rgd3127 prestige', 'ibanez rgd61al axion label', 'ibanez rgd71alms axion label', 'ibanez s1070pbz premium', 'ibanez s5470f prestige', 'ibanez s561', 'ibanez sa260fm', 'ibanez rg421ahm', 'ibanez rga42ex', 'ibanez rgaix6fm iron label', 'ibanez rgib6 iron label baritone', 'ibanez s621qm', 'ibanez grg131dx', 'ibanez rg350dxz']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase1_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'ibanez'
  and t.model_name = 'RG / S' and t.instrument_type = 'guitar';

-- ltd: 95 catalog names
update public.guitar_models t
set tags = array['ltd ec-256', 'ltd ec-1000', 'ltd ec', 'esp ltd', 'esp eclipse', 'esp', 'ltd m-1000', 'ltd mh-1000', 'ltd sn-1000', 'ltd ex-360', 'ltd alexi-600', 'ltd ec-1000 evertune', 'ltd h3-1000', 'ltd iron cross', 'ltd kh-202', 'ltd kh-602', 'ltd m-1001', 'ltd mh-1000 evertune', 'ltd snakebyte', 'ltd te-1000', 'ltd viper-1000', 'ltd vulture', 'ltd alexi greeny', 'ltd alexi hexed', 'ltd alexi ripped', 'ltd alexi-200', 'ltd arrow black metal', 'ltd arrow-1000', 'ltd arrow-200', 'ltd arrow-401', 'ltd bb-600 baritone', 'ltd ec arctic metal', 'ltd ec black metal', 'ltd ec-10', 'ltd ec-1000fr', 'ltd ec-1000t ctm', 'ltd ec-1007 evertune', 'ltd ec-100qm', 'ltd ec-200qm', 'ltd ec-201', 'ltd ec-257', 'ltd ec-400', 'ltd ec-401', 'ltd ec-407', 'ltd ec-50', 'ltd eclipse ''87', 'ltd ex-401', 'ltd f-10', 'ltd f-100fm', 'ltd f-250', 'ltd f-400fm', 'ltd f-50', 'ltd gh-600', 'ltd h-1001', 'ltd h-101fm', 'ltd h3-1007', 'ltd jh-600', 'ltd kh-3 spider', 'ltd kh-v', 'ltd kh-wz', 'ltd m-1 custom ''87', 'ltd m-10', 'ltd m-1007', 'ltd m-100fm', 'ltd m-200fm', 'ltd m-400', 'ltd m-50', 'ltd mh-1007 evertune', 'ltd mh-100qm', 'ltd mh-103qm', 'ltd mh-200', 'ltd mh-203qm', 'ltd mh-207', 'ltd mh-300', 'ltd mh-350fr', 'ltd mh-400', 'ltd mh-401', 'ltd mh-417', 'ltd mirage deluxe ''87', 'ltd phoenix black metal', 'ltd phoenix-1000', 'ltd phoenix-200', 'ltd phoenix-401', 'ltd sc-20', 'ltd sc-607b', 'ltd sn-1000fr', 'ltd sn-1000w', 'ltd sn-200ht', 'ltd sparrowhawk', 'ltd te-200', 'ltd te-401', 'ltd viper black metal', 'ltd viper-10', 'ltd viper-201b', 'ltd viper-256', 'ltd viper-400', 'ltd wa-200', 'ltd ec-256fm', 'ltd mh-400nt']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase1_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'ltd'
  and t.model_name = 'EC / Metal' and t.instrument_type = 'guitar';

-- jackson: 58 catalog names
update public.guitar_models t
set tags = array['jackson dinky js22', 'jackson dinky js32', 'jackson dinky', 'jackson soloist', 'jackson rhoads', 'jackson', 'jackson king v kvxmg', 'jackson rhoads js32', 'jackson soloist slx', 'jackson soloist sl2', 'jackson js22 dinky', 'jackson js32 dinky', 'jackson pro series dinky dk2', 'jackson pro series soloist sl2', 'jackson x series rhoads rrx24', 'jackson x series soloist slx dx', 'jackson american series soloist sl3', 'jackson american series virtuoso', 'jackson js22-7 dinky', 'jackson js32 dinky arch top', 'jackson js32 kelly', 'jackson js32 king v', 'jackson js32 rhoads', 'jackson js32 warrior', 'jackson js32-7 dinky', 'jackson js32q dinky', 'jackson mj series dinky dkr', 'jackson mj series rhoads rr24mg', 'jackson mj series soloist sl2', 'jackson pro plus series dinky mdk ht7', 'jackson pro plus series soloist sla3', 'jackson pro plus series soloist sla3q', 'jackson pro series dinky dk modern', 'jackson pro series king v kv', 'jackson pro series rhoads rr24', 'jackson pro series signature andreas kisser soloist', 'jackson pro series signature chris broderick soloist 6', 'jackson pro series signature chris broderick soloist 7', 'jackson pro series signature jeff loomis soloist sl7', 'jackson pro series signature misha mansoor juggernaut ht6fm', 'jackson pro series signature misha mansoor juggernaut ht7fm', 'jackson pro series soloist sl3', 'jackson usa signature jeff loomis soloist sl7', 'jackson usa signature misha mansoor juggernaut ht6', 'jackson usa signature misha mansoor juggernaut ht7', 'jackson usa signature phil collen pc1', 'jackson x series dinky dk2x', 'jackson x series dinky dk3xr hss', 'jackson x series kelly kex', 'jackson x series king v kvx', 'jackson x series rhoads rrx24-7', 'jackson x series signature brandon ellis kelly kexq', 'jackson x series signature chris broderick soloist 6', 'jackson x series signature chris broderick soloist 7', 'jackson x series signature corey beaulieu kv6', 'jackson x series signature corey beaulieu kv7', 'jackson x series signature marty friedman mf-1', 'jackson x series signature phil collen pc1', 'jackson x series soloist sl3x dx', 'jackson x series warrior wrx24', 'jackson js11 dinky']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase1_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'jackson'
  and t.model_name = 'Dinky / Soloist' and t.instrument_type = 'guitar';

-- schecter: 64 catalog names
update public.guitar_models t
set tags = array['schecter c-1 hellraiser', 'schecter c-1 platinum', 'schecter omen extreme-6', 'schecter c-1', 'schecter omen', 'schecter', 'schecter solo-ii custom', 'schecter sun valley super shredder', 'schecter demon-6', 'schecter banshee mach-6', 'schecter c-1 apocalypse', 'schecter c-1 silver mountain', 'schecter c-1 sls elite', 'schecter km-6 mk-iii', 'schecter omen-6', 'schecter reaper-6', 'schecter synyster custom-s', 'schecter banshee elite-6', 'schecter banshee elite-7', 'schecter banshee mach-7', 'schecter banshee-6 extreme', 'schecter c-1 blackjack', 'schecter c-1 blackjack atx', 'schecter c-1 classic', 'schecter c-1 custom', 'schecter c-1 e/a', 'schecter c-1 fr-s apocalypse', 'schecter c-1 hellraiser hybrid', 'schecter c-1 plus', 'schecter c-1 sls elite evil twin', 'schecter c-6 deluxe', 'schecter c-6 plus', 'schecter c-7 apocalypse', 'schecter c-7 deluxe', 'schecter c-7 hellraiser', 'schecter c-7 sls elite', 'schecter c-8 deluxe', 'schecter damien elite-6', 'schecter damien platinum-6', 'schecter damien-6', 'schecter damien-7', 'schecter demon-7', 'schecter demon-8', 'schecter e-1 custom', 'schecter km-6', 'schecter km-7 mk-iii', 'schecter omen elite-6', 'schecter omen elite-6 fr', 'schecter omen extreme-6 fr', 'schecter omen extreme-7', 'schecter omen-7', 'schecter omen-8', 'schecter reaper-6 custom', 'schecter reaper-7', 'schecter reaper-7 multiscale', 'schecter solo-ii special', 'schecter solo-ii supreme', 'schecter sun valley super shredder fr', 'schecter synyster standard', 'schecter ultra', 'schecter v-1 custom', 'schecter v-1 platinum', 'schecter zacky vengeance 6661', 'schecter c-1 sls elite fr', 'schecter c-6 pro', 'schecter hellraiser c-7', 'schecter km-7 mk-iii standard']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase1_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'schecter'
  and t.model_name = 'C-1 / Omen' and t.instrument_type = 'guitar';

-- solar: 15 catalog names
update public.guitar_models t
set tags = array['solar a1.6', 'solar a series', 'solar guitars', 'solar a', 'solar a1.7', 'solar s1.6', 'solar a2.6', 'solar e1.6', 'solar gc1.6', 'solar a2.6c', 'solar a2.7', 'solar e2.6', 'solar gc2.6', 'solar gf1.6', 'solar s2.6', 'solar t1.6', 'solar v1.6', 'solar v2.6']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase1_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'solar'
  and t.model_name = 'A-Series' and t.instrument_type = 'guitar';

-- dean: 36 catalog names
update public.guitar_models t
set tags = array['dean ml select', 'dean ml', 'dean guitars', 'dean', 'dean hardtail', 'dean dimebag razorback', 'dean v 79', 'dean icon', 'dean evo xm', 'dean exile select', 'dean cadillac 1980', 'dean dave mustaine vmnt', 'dean dean from hell cfh', 'dean md24', 'dean ml 79', 'dean z 79', 'dean baby ml', 'dean cadillac select', 'dean cadillac x', 'dean custom 350', 'dean custom zone', 'dean dime o flame', 'dean dime slime', 'dean evo', 'dean icon x', 'dean kerry king v', 'dean md24 floyd', 'dean michael schenker standard', 'dean mlx', 'dean razorback v', 'dean splittail', 'dean thoroughbred deluxe', 'dean thoroughbred select', 'dean thoroughbred x', 'dean vendetta 1.0', 'dean vendetta xm', 'dean vx', 'dean z select', 'dean zx']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase1_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'dean'
  and t.model_name = 'ML' and t.instrument_type = 'guitar';

-- yamaha: 35 catalog names
update public.guitar_models t
set tags = array['yamaha pacifica 112v', 'yamaha pacifica', 'yamaha revstar rss20', 'yamaha revstar', 'yamaha pacifica 612viifm', 'yamaha revstar rsp20', 'yamaha pacifica 012', 'yamaha revstar standard rss20', 'yamaha pacifica 311h', 'yamaha pacifica professional', 'yamaha pacifica standard plus', 'yamaha revstar element rse20', 'yamaha revstar standard rss02t', 'yamaha sa2200', 'yamaha sg2000', 'yamaha aes620', 'yamaha pacifica 112j', 'yamaha pacifica 112vm', 'yamaha pacifica 120h', 'yamaha pacifica 1611ms mike stern', 'yamaha pacifica 212vfm', 'yamaha pacifica 212vqm', 'yamaha pacifica 510v', 'yamaha pacifica 611hfm', 'yamaha pacifica 611vfm', 'yamaha revstar professional rsp02t', 'yamaha revstar rs320', 'yamaha revstar rs420', 'yamaha revstar rs502', 'yamaha revstar rs502t', 'yamaha revstar rs620', 'yamaha revstar rs720b', 'yamaha revstar rs820cr', 'yamaha rgx220dz', 'yamaha rgxa2', 'yamaha sg1802', 'yamaha sg1820']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase1_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'yamaha'
  and t.model_name = 'Pacifica / Revstar' and t.instrument_type = 'guitar';

-- charvel: 38 catalog names
update public.guitar_models t
set tags = array['charvel pro-mod dk24', 'charvel pro-mod so-cal', 'charvel pro-mod san dimas', 'charvel pro-mod', 'charvel', 'charvel pro-mod dk24 hss 2pt cm', 'charvel pro-mod san dimas style 1 hh fr m', 'charvel pro-mod so-cal style 1 hh fr m', 'charvel pro-mod dk24 hh fr m', 'charvel pro-mod san dimas style 1 hh', 'charvel mj san dimas sd24 cm', 'charvel pro-mod dk22 sss 2pt', 'charvel pro-mod san dimas style 1 hh fr', 'charvel pro-mod so-cal style 1 hh fr', 'charvel henrik danhage signature pro-mod limited edition', 'charvel marco sfogli signature pro-mod so-cal style 1', 'charvel mj dk24 hh 2pt', 'charvel mj dk24 hsh 2pt', 'charvel mj san dimas sd24 cm guthrie govan signature', 'charvel mj san dimas sd24 ht', 'charvel pro-mod dk ash', 'charvel pro-mod dk24 hh fr e', 'charvel pro-mod dk24 hh ht e', 'charvel pro-mod dk24 hsh 2pt', 'charvel pro-mod dk24 hsh fr', 'charvel pro-mod dk24 hss 2pt e', 'charvel pro-mod dk24 hss 2pt m', 'charvel pro-mod dk24-7 angel vivaldi', 'charvel pro-mod dk24-7 hh 2pt', 'charvel pro-mod san dimas style 1 hh e', 'charvel pro-mod san dimas style 1 hh ht', 'charvel pro-mod san dimas style 1 hss fr', 'charvel pro-mod san dimas style 1 hss ht', 'charvel pro-mod san dimas style 2 hh fr', 'charvel pro-mod so-cal style 1 hss fr e', 'charvel pro-mod so-cal style 1 hss fr m', 'charvel usa select dk24 hh 2pt', 'charvel usa select san dimas style 1 hss fr', 'charvel usa signature guthrie govan hsh caramelized ash', 'charvel usa signature guthrie govan hsh flame maple', 'charvel usa signature joe duplantier san dimas style 2', 'charvel usa signature warren demartini san dimas', 'charvel pro-mod dk24 hh 2pt cm']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase1_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'charvel'
  and t.model_name = 'Pro-Mod' and t.instrument_type = 'guitar';

-- music-man: 25 catalog names
update public.guitar_models t
set tags = array['music man axis', 'music man jp15', 'music man jp', 'ernie ball music man', 'musicman', 'music man cutlass hss', 'music man majesty', 'music man jp6', 'music man axis super sport', 'music man jp16', 'music man silhouette', 'music man st. vincent', 'music man albert lee', 'music man cutlass rs hss', 'music man cutlass rs sss', 'music man cutlass sss', 'music man kaizen', 'music man luke 4', 'music man luke iii', 'music man mariposa', 'music man sabre', 'music man silhouette special', 'music man st. vincent goldie', 'music man steve morse signature', 'music man stingray rs', 'music man valentine', 'music man kaizen 6', 'music man kaizen 7']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase1_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'music-man'
  and t.model_name = 'Axis / JP' and t.instrument_type = 'guitar';

-- evh: 17 catalog names
update public.guitar_models t
set tags = array['evh wolfgang standard', 'evh wolfgang special', 'evh wolfgang', 'wolfgang', 'evh 5150 standard', 'evh striped series', 'evh striped series frankenstein frankie', 'evh wolfgang usa', 'evh 5150 series deluxe', 'evh 5150 series deluxe ash', 'evh sa-126 special', 'evh striped series ''78 eruption', 'evh striped series circles', 'evh striped series shark', 'evh striped series star', 'evh wolfgang special qm', 'evh wolfgang standard qm', 'evh wolfgang usa edward van halen signature', 'evh wolfgang wg standard']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase1_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'evh'
  and t.model_name = 'Wolfgang' and t.instrument_type = 'guitar';

-- suhr: 14 catalog names
update public.guitar_models t
set tags = array['suhr classic s', 'suhr classic', 'suhr modern', 'suhr', 'suhr classic t', 'suhr modern plus', 'suhr alt t', 'suhr pete thorn signature', 'suhr standard', 'suhr andy wood modern t', 'suhr classic jm', 'suhr classic s antique', 'suhr classic t antique', 'suhr modern satin', 'suhr modern terra', 'suhr standard plus']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase1_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'suhr'
  and t.model_name = 'Classic S / Modern' and t.instrument_type = 'guitar';

-- gretsch: 44 catalog names
update public.guitar_models t
set tags = array['gretsch g5420t electromatic', 'gretsch g5220 electromatic jet', 'gretsch electromatic', 'gretsch jet', 'gretsch', 'gretsch g5220 electromatic jet bt', 'gretsch g6136 white falcon', 'gretsch g5420t', 'gretsch g5622t', 'gretsch g2622 streamliner center block', 'gretsch g5422tg electromatic hollow body double-cut', 'gretsch g6120t-bssmk brian setzer signature nashville', 'gretsch g6122t-62 vintage select country gentleman', 'gretsch g6128t-89 vintage select duo jet', 'gretsch g6136t players edition falcon', 'gretsch g2210 streamliner junior jet club', 'gretsch g2215-p90 streamliner junior jet club', 'gretsch g2420 streamliner hollow body', 'gretsch g2420t streamliner hollow body with bigsby', 'gretsch g2622t streamliner center block with bigsby', 'gretsch g2622t-p90 streamliner center block p90', 'gretsch g2655 streamliner center block jr.', 'gretsch g2655t streamliner center block jr. with bigsby', 'gretsch g5210-p90 electromatic jet two 90', 'gretsch g5222 electromatic double jet', 'gretsch g5230t electromatic jet ft', 'gretsch g5232t electromatic double jet ft', 'gretsch g5260 electromatic jet baritone', 'gretsch g5260t electromatic jet baritone with bigsby', 'gretsch g5410t electromatic rat rod', 'gretsch g5422g-12 electromatic hollow body 12-string', 'gretsch g5422t electromatic hollow body double-cut', 'gretsch g5622 electromatic center block double-cut', 'gretsch g5655t electromatic center block jr.', 'gretsch g5655tg electromatic center block jr.', 'gretsch g6118t players edition anniversary', 'gretsch g6119t-62 vintage select tennessee rose', 'gretsch g6120t players edition nashville', 'gretsch g6128t players edition jet ft', 'gretsch g6129t-89 vintage select sparkle jet', 'gretsch g6131-my malcolm young signature jet', 'gretsch g6134t-58 vintage select penguin', 'gretsch g6136tg players edition falcon', 'gretsch g6609tg players edition broadkaster', 'gretsch g6636t players edition falcon center block', 'gretsch g6659t players edition broadkaster jr.', 'gretsch g2622t streamliner center block', 'gretsch g6659t players edition broadkaster jr']::text[],
    metadata = t.metadata || jsonb_build_object('coverage', 'gear_phase1_v1')
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'gretsch'
  and t.model_name = 'Electromatic' and t.instrument_type = 'guitar';

insert into public.guitar_models (
  manufacturer_id, model_name, instrument_type, body_type, pickup_layout,
  output_level, brightness, warmth, compression,
  noise_characteristics, metadata, tags, search_text, is_active
)
select
  m.id, v.model_name, 'guitar', v.body_type, v.pickup_layout,
  v.output_level, v.brightness, v.warmth, v.compression,
  '{}'::jsonb,
  jsonb_build_object('verified', true, 'source', 'curated_gear_phase1_v1', 'version', 1),
  v.tags, '', true
from (
  values
    -- Deep hollowbody jazz boxes: low output, very dark and warm — engine should add treble/presence and trim bass.
    ('gibson', 'Jazz Archtop', 'hollow', 'hh', 4, 3.5, 8, 4.5,
      array['gibson es-175', 'epiphone broadway', 'epiphone emperor swingster', 'epiphone joe pass emperor-ii pro', 'gibson byrdland', 'gibson es-275', 'gibson es-295', 'gibson l-5 ces', 'gibson super 400 ces']::text[]),
    -- P-90 slab bodies: mid output, rawer and brighter than humbucker LPs, low compression.
    ('gibson', 'Les Paul Junior / Special (P-90)', 'solid', 'p90', 5.5, 6, 5.5, 4,
      array['gibson les paul junior', 'gibson les paul special', 'epiphone les paul special ii', 'epiphone billie joe armstrong les paul junior', 'epiphone coronet', 'epiphone crestwood custom', 'epiphone joan jett olympic special', 'epiphone les paul junior', 'epiphone les paul sl', 'epiphone les paul special', 'epiphone les paul special satin e1', 'epiphone les paul special ve', 'epiphone power players les paul', 'epiphone slash afd les paul special-ii', 'epiphone wilshire', 'gibson billie joe armstrong les paul junior', 'gibson les paul junior tribute dc', 'gibson les paul special double cut', 'gibson les paul special tribute humbucker', 'gibson les paul special tribute p-90', 'gibson marauder', 'gibson melody maker', 'gibson rick beato les paul special double cut', 'gibson s-1']::text[]),
    -- Mini-humbuckers: tighter and brighter than full-size buckers, moderate output.
    ('gibson', 'Firebird', 'solid', 'hh', 6, 6, 5, 4.5,
      array['gibson firebird', 'epiphone 1963 firebird v', 'epiphone firebird', 'epiphone firebird studio', 'epiphone lzzy hale explorerbird', 'gibson firebird v', 'gibson firebird studio', 'gibson firebird vii', 'gibson firebird zero', 'gibson lzzy hale explorerbird']::text[]),
    -- Artcore hollow/semi-hollow + AR solid retro: warm humbuckers, moderate output.
    ('ibanez', 'Artcore / AR', 'semi_hollow', 'hh', 5, 4.5, 7, 5,
      array['ibanez af95', 'ibanez ag75g', 'ibanez ar420', 'ibanez arz400', 'ibanez af75', 'ibanez as53', 'ibanez as73', 'ibanez af200ltd', 'ibanez as93fm', 'ibanez tm302', 'ibanez tm303', 'ibanez am53', 'ibanez am93qm', 'ibanez as113', 'ibanez art300']::text[]),
    -- ESP standard/E-II line: hot passive/active humbuckers voiced for metal, compressed attack.
    ('esp', 'E-II / Eclipse', 'solid', 'hh', 8, 5.5, 5, 6,
      array['esp e-ii eclipse', 'esp e-ii horizon nt', 'esp e-ii m-ii', 'esp ltd ec-256', 'esp ltd mh-10', 'esp e-ii horizon fr', 'esp eclipse-ii', 'esp horizon-iii', 'esp kamikaze-1', 'esp kh-2', 'esp snakebyte', 'esp snapper', 'esp arrow', 'esp e-ii arrow', 'esp e-ii eclipse db', 'esp e-ii frx', 'esp e-ii horizon nt-7b', 'esp e-ii horizon nt-ii', 'esp e-ii m-i thru nt', 'esp e-ii mystique', 'esp e-ii st-1', 'esp e-ii st-2', 'esp e-ii vintage plus', 'esp e-ii viper', 'esp forest-gt', 'esp iron cross', 'esp kh-2 vintage', 'esp mirage deluxe', 'esp phoenix', 'esp random star', 'esp snapper-ctm', 'esp viper', 'esp vulture']::text[]),
    -- Schecter's vintage-voiced line (Nick Johnston, PT, Corsair): lower output, brighter, open dynamics.
    ('schecter', 'PT / Traditional', 'solid', 'hss', 5, 6.5, 5, 4,
      array['schecter nick johnston traditional', 'schecter pt', 'schecter corsair', 'schecter coupe', 'schecter jerry horton tempest', 'schecter nick johnston traditional hss', 'schecter pt fastback', 'schecter pt fastback ii b', 'schecter pt special', 'schecter tempest custom', 'schecter ultracure']::text[]),
    -- Hot-rodded 80s shred: single hot bridge humbucker, bright aggressive attack.
    ('kramer', 'Baretta / 84', 'solid', 'h', 8, 6, 4.5, 5.5,
      array['kramer baretta vintage', 'kramer baretta', 'kramer nightswan', 'kramer pacer classic', 'kramer the 84', 'kramer assault 220', 'kramer baretta special', 'kramer charlie parra vanguard', 'kramer dave snake sabo baretta', 'kramer focus vt-111s', 'kramer focus vt-211s', 'kramer jersey star', 'kramer nite-v', 'kramer pacer', 'kramer pacer carrera', 'kramer pacer vintage', 'kramer sm-1', 'kramer sm-1 figured', 'kramer sm-1 h', 'kramer striker figured hss', 'kramer striker hss', 'kramer tracii guns gunstar voyager', 'kramer voyager']::text[]),
    -- Metal shapes with hot humbuckers, thick compressed voicing.
    ('bc-rich', 'Warlock / Mockingbird', 'solid', 'hh', 8, 5.5, 5, 6,
      array['b.c. rich ironbird', 'b.c. rich bich', 'b.c. rich kerry king wartribe', 'b.c. rich mockingbird st', 'b.c. rich stealth', 'b.c. rich warlock extreme', 'b.c. rich assassin', 'b.c. rich beast', 'b.c. rich bich 10', 'b.c. rich draco', 'b.c. rich eagle', 'b.c. rich gunslinger retro', 'b.c. rich ironbird extreme', 'b.c. rich jr. v extreme', 'b.c. rich mockingbird extreme', 'b.c. rich mockingbird mk3', 'b.c. rich seagull', 'b.c. rich shredzilla extreme', 'b.c. rich shredzilla prophecy exotic archtop', 'b.c. rich villain deluxe', 'b.c. rich warbeast', 'b.c. rich warbeast extreme', 'b.c. rich warlock mk3', 'b.c. rich warlock mk5']::text[]),
    -- Budget copies across archetypes: mid-hot output, balanced middle-of-road voicing.
    ('harley-benton', 'Electric Series', 'solid', 'hh', 6.5, 5.5, 5.5, 5,
      array['harley benton wl-20bk rock series', 'harley benton sc-450 cs', 'harley benton amarok-6', 'harley benton fusion-iii hsh', 'harley benton hb-35', 'harley benton sc-550', 'harley benton te-52', 'harley benton cst-24', 'harley benton cst-24t', 'harley benton dc-580', 'harley benton dc-60', 'harley benton dc-junior', 'harley benton dullahan-at 24', 'harley benton dullahan-ft 24', 'harley benton ex-76 classic', 'harley benton extreme-84', 'harley benton fusion-t hh', 'harley benton hb-35plus', 'harley benton ja-60', 'harley benton r-446', 'harley benton r-457', 'harley benton r-458', 'harley benton sc-1000', 'harley benton sc-450plus', 'harley benton sc-550 ii', 'harley benton sc-custom ii', 'harley benton st-20', 'harley benton st-20 hss', 'harley benton st-62', 'harley benton te-20', 'harley benton te-62cc', 'harley benton te-70rw deluxe', 'harley benton te-90flt', 'harley benton fusion-ii hh fr', 'harley benton te-70 black paisley']::text[]),
    -- Modern versatile superstrats: medium-hot, slightly bright.
    ('cort', 'G / KX Series', 'solid', 'hh', 6.5, 6, 5, 5,
      array['cort cr200', 'cort g290 fat', 'cort g300 pro', 'cort kx500', 'cort mbm-1', 'cort x700 duality', 'cort classic tc', 'cort cr100', 'cort cr250', 'cort cr300', 'cort g110', 'cort g200', 'cort g250', 'cort g260cs', 'cort g280 select', 'cort g300 glam', 'cort kx100', 'cort kx300', 'cort kx300 etched', 'cort kx507ms', 'cort mbc-1', 'cort mbm-2', 'cort source', 'cort x100', 'cort x250', 'cort x300', 'cort x700 duality ii', 'cort yorktown', 'cort x700 mutility']::text[]),
    -- Korina bodies, bass contour circuit: articulate medium output, open top end.
    ('reverend', 'Set-Neck / Signature', 'solid', 'hh', 5.5, 6, 5.5, 4.5,
      array['reverend billy corgan signature', 'reverend double agent og', 'reverend greg koch gristlemaster', 'reverend jetstream 390', 'reverend airsonic', 'reverend buckshot', 'reverend charger 290', 'reverend charger hb', 'reverend club king 290', 'reverend contender hb', 'reverend crosscut', 'reverend descent ra', 'reverend double agent w', 'reverend greg koch gristle 90', 'reverend jetstream hb', 'reverend pete anderson eastsider s', 'reverend pete anderson eastsider t', 'reverend reeves gabrels signature', 'reverend roundhouse', 'reverend sensei ra', 'reverend six gun hpp', 'reverend tricky gomez rt', 'reverend warhawk 390', 'reverend contender rb', 'reverend six gun']::text[]),
    -- Import Music Man designs: same modern balanced voicing, slightly hotter ceramic pickups.
    ('sterling-by-music-man', 'Cutlass / JP', 'solid', 'hh', 6.5, 6, 5, 5,
      array['sterling by music man jp150', 'sterling by music man majesty x', 'sterling by music man axis ax3s', 'sterling by music man axis ax40', 'sterling by music man cutlass ct30hss', 'sterling by music man cutlass ct30sss', 'sterling by music man cutlass ct50 plus', 'sterling by music man cutlass ct50hss', 'sterling by music man jason richardson cutlass', 'sterling by music man jp60', 'sterling by music man jp70', 'sterling by music man kaizen', 'sterling by music man mariposa', 'sterling by music man sabre', 'sterling by music man st. vincent', 'sterling by music man stingray sr30', 'sterling by music man stingray sr50', 'sterling by music man valentine', 'sterling by music man cutlass ct50 hss']::text[]),
    -- New-York archtop heritage: warm semi/hollow voicing, moderate output.
    ('d-angelico', 'Excel / Premier', 'semi_hollow', 'hh', 4.5, 5, 7, 4.5,
      array['d''angelico deluxe atlantic', 'd''angelico excel ss', 'd''angelico premier dc', 'd''angelico deluxe bedford', 'd''angelico deluxe dc', 'd''angelico deluxe ss', 'd''angelico excel 59', 'd''angelico excel dc', 'd''angelico excel exl-1', 'd''angelico excel mini dc tour', 'd''angelico premier atlantic', 'd''angelico premier bedford', 'd''angelico premier bedford sh', 'd''angelico premier brighton', 'd''angelico premier exl-1', 'd''angelico premier mini dc', 'd''angelico premier ss']::text[]),
    -- LB-1 style humbuckers: warm vintage crunch, medium-hot.
    ('guild', 'Polara / Starfire', 'semi_hollow', 'hh', 6, 5, 6.5, 5,
      array['guild s-100 polara', 'guild starfire v', 'guild surfliner', 'guild a-150 savoy', 'guild bluesbird', 'guild m-75 aristocrat', 'guild s-100 polara kim thayil', 'guild s-200 t-bird', 'guild starfire i dc', 'guild starfire i jet 90', 'guild starfire i sc', 'guild starfire ii st', 'guild starfire iv st', 'guild starfire vi', 'guild surfliner deluxe', 'guild x-175 manhattan', 'guild polara kim thayil']::text[]),
    -- Modern British metal designs: hot but articulate humbuckers.
    ('chapman', 'ML / Ghost Fret', 'solid', 'hh', 7.5, 5.5, 5, 5.5,
      array['chapman ghost fret', 'chapman ml1 modern', 'chapman ml3 bea', 'chapman ghost fret 7', 'chapman ghost fret pro', 'chapman ml1 cap10 america', 'chapman ml1 modern baritone', 'chapman ml1 norseman', 'chapman ml1 pro modern', 'chapman ml1 pro traditional', 'chapman ml1 traditional', 'chapman ml1 x', 'chapman ml2', 'chapman ml3 modern', 'chapman ml3 pro bea', 'chapman ml3 pro traditional', 'chapman ml3 traditional']::text[]),
    -- Boutique carved builds: warm woody response, moderate output.
    ('eastman', 'Romeo / SB', 'semi_hollow', 'hh', 5.5, 4.5, 7, 5,
      array['eastman juliet', 'eastman romeo', 'eastman sb59', 'eastman t486', 'eastman ar372ce', 'eastman romeo la', 'eastman romeo sc', 'eastman sb55/v', 'eastman sb55dc/v', 'eastman sb56/v', 'eastman sb59/v', 'eastman t185mx', 'eastman t386', 'eastman t484', 'eastman t486b', 'eastman t59/v', 'eastman t64/v']::text[]),
    -- Lipstick single coils in masonite bodies: low output, jangly and bright.
    ('danelectro', '''59 / Lipstick', 'semi_hollow', 'ss', 3.5, 7.5, 4, 3.5,
      array['danelectro ''59m nos+', 'danelectro ''59xt', 'danelectro ''57', 'danelectro ''59 divine', 'danelectro ''64', 'danelectro ''66', 'danelectro ''66bt', 'danelectro ''84', 'danelectro blackout ''59', 'danelectro convertible', 'danelectro fifty niner', 'danelectro hodad', 'danelectro longhorn baritone', 'danelectro stock ''59', 'danelectro stock 59']::text[]),
    -- Swedish LP-style builds: dark warm humbuckers, sustain-heavy.
    ('hagstrom', 'Fantomen / Swede', 'solid', 'hh', 6.5, 4.5, 6.5, 5.5,
      array['hagstrom fantomen', 'hagstrom super swede', 'hagstrom viking', 'hagstrom alvar', 'hagstrom condor', 'hagstrom impala', 'hagstrom pat smear signature', 'hagstrom retroscape h-ii', 'hagstrom retroscape h-iii', 'hagstrom super viking', 'hagstrom swede', 'hagstrom tremar viking deluxe', 'hagstrom ultra max', 'hagstrom ultra swede', 'hagstrom viking deluxe']::text[]),
    -- German retro semi-hollows: P-90/humbucker mix, chimey but full.
    ('duesenberg', 'Julia / Starplayer', 'semi_hollow', 'hs', 5, 6, 6, 4.5,
      array['duesenberg julia', 'duesenberg starplayer tv', 'duesenberg 49er', 'duesenberg alliance joe walsh', 'duesenberg bonneville', 'duesenberg caribou', 'duesenberg double cat', 'duesenberg falken', 'duesenberg fullerton elite', 'duesenberg gran majesto', 'duesenberg paloma', 'duesenberg starplayer special', 'duesenberg starplayer tv phonic', 'duesenberg starplayer tv plus']::text[]),
    -- Canadian builds from jazz boxes to sessions: balanced warm voicing.
    ('godin', '5th Avenue / Session', 'semi_hollow', 'hh', 5, 5.5, 6, 4.5,
      array['godin 5th avenue kingpin', 'godin session ht', 'godin 5th avenue cw kingpin ii', 'godin 5th avenue jazz', 'godin lgxt', 'godin montreal premiere ht', 'godin radiator', 'godin stadium ''59', 'godin stadium ht', 'godin summit classic', 'godin xtsa', 'godin summit classic ht']::text[]),
    -- Wilkinson-equipped LP/strat copies: dark warm humbucker voicing on the V100 flagship.
    ('vintage', 'V100 / ReIssued', 'solid', 'hh', 6.5, 4, 6.5, 5.5,
      array['vintage v100', 'vintage v100afd paradise', 'vintage v6', 'vintage v100 icon', 'vintage v100 lemon drop', 'vintage v120', 'vintage v130', 'vintage v52', 'vintage v52 icon', 'vintage v6 icon', 'vintage v6m24', 'vintage vsa500']::text[]),
    -- Toaster/Hi-gain single coils: the jangle benchmark — low output, very bright.
    ('rickenbacker', '330 / 360', 'semi_hollow', 'ss', 4.5, 7.5, 4.5, 4,
      array['rickenbacker 330', 'rickenbacker 360', 'rickenbacker 330/12', 'rickenbacker 360/12', 'rickenbacker 350v63 liverpool', 'rickenbacker 360/12c63', 'rickenbacker 381v69', 'rickenbacker 620', 'rickenbacker 650c colorado', 'rickenbacker 660', 'rickenbacker 660/12']::text[]),
    -- Shred/metal signatures: hot humbuckers, aggressive midrange.
    ('washburn', 'Nuno / Dime', 'solid', 'hh', 7.5, 5.5, 5, 5.5,
      array['washburn dime 333', 'washburn n24 nuno bettencourt', 'washburn n4', 'washburn hb30', 'washburn hb35', 'washburn idol wi64', 'washburn n1', 'washburn n2', 'washburn parallaxe solar 160', 'washburn sonamaster s1', 'washburn x50 pro']::text[]),
    -- Affordable 335/L-5 style line: warm balanced humbuckers.
    ('sire', 'Larry Carlton', 'semi_hollow', 'hh', 5.5, 5.5, 6, 4.5,
      array['sire larry carlton h7', 'sire larry carlton s7', 'sire larry carlton t7', 'sire larry carlton h7v', 'sire larry carlton l7', 'sire larry carlton l7v', 'sire larry carlton s3', 'sire larry carlton s7 fm', 'sire larry carlton t7 fm']::text[]),
    -- Headless modern-fusion builds: hot articulate pickups, tight low end.
    ('strandberg', 'Boden', 'solid', 'hh', 7, 6, 4.5, 5.5,
      array['strandberg boden standard nx 6', 'strandberg boden essential 6', 'strandberg boden metal nx 6', 'strandberg boden metal nx 7', 'strandberg boden original nx 6', 'strandberg boden original nx 7', 'strandberg boden prog nx 6', 'strandberg boden standard nx 7']::text[]),
    -- Fujigen Japanese builds: balanced modern-vintage voicing.
    ('fgn', 'Neo Classic / Boundary', 'solid', 'hh', 6, 5.5, 5.5, 5,
      array['fgn boundary odyssey', 'fgn boundary iliad', 'fgn j-standard iliad', 'fgn j-standard mythic', 'fgn j-standard odyssey', 'fgn neo classic nst10', 'fgn neo classic ntl10']::text[]),
    -- Japanese classic PE/RS line: balanced medium-output humbuckers.
    ('aria', 'Pro II', 'solid', 'hh', 5.5, 5.5, 5.5, 5,
      array['aria pro ii pe-350', 'aria 615-frontier', 'aria 714-fullerton', 'aria stg-003', 'aria stg-004', 'aria teg-002']::text[]),
    -- Budget strat/tele copies with bright low-output single coils.
    ('jet', 'JT Series', 'solid', 'sss', 4, 7, 4.5, 3.5,
      array['jet jt-300', 'jet js-300', 'jet js-400', 'jet jt-350', 'jet jt-450']::text[]),
    -- Polish boutique metal: hot pickups, tight modern low end.
    ('mayones', 'Regius / Duvell', 'solid', 'hh', 8, 5.5, 4.5, 5.5,
      array['mayones duvell elite 6', 'mayones duvell elite 7', 'mayones regius 6', 'mayones regius 7', 'mayones setius 6']::text[]),
    -- Australian multiscale metal: hot bright modern voicing.
    ('ormsby', 'Hype / Goliath', 'solid', 'hh', 8, 6, 4.5, 5.5,
      array['ormsby goliath gtr 6', 'ormsby hype gtr 6', 'ormsby hype gtr 7', 'ormsby tx gtr 6']::text[]),
    -- US direct-order modern metal: hot clear pickups, tight response.
    ('kiesel', 'Aries / Vader', 'solid', 'hh', 8, 6, 4.5, 5.5,
      array['kiesel aries', 'kiesel delos', 'kiesel vader']::text[]),
    -- Reissues of oddball vintage designs: moderate output, retro bite.
    ('eastwood', 'Retro Series', 'semi_hollow', 'hh', 5, 6, 5.5, 4.5,
      array['eastwood airline 59 2p', 'eastwood classic 6', 'eastwood sidejack baritone dlx']::text[]),
    -- Modern metal designs: hot humbuckers, scooped tight voicing.
    ('balaguer', 'Growler / Espada', 'solid', 'hh', 7.5, 5.5, 5, 5.5,
      array['balaguer espada standard', 'balaguer growler standard']::text[]),
    -- Hot-rodded US designs: medium-hot humbuckers.
    ('peavey', 'HP / Raptor', 'solid', 'hh', 7, 5.5, 5, 5,
      array['peavey hp2', 'peavey raptor plus']::text[])
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

-- Post-condition: all phase-1 rows must carry their tags inside search_text.
do $$
declare
  bad int;
begin
  select count(*) into bad
  from public.guitar_models g
  where (g.metadata->>'verified') = 'true'
    and g.is_active and g.instrument_type = 'guitar'
    and coalesce(array_length(g.tags, 1), 0) > 0
    and position(lower(g.tags[1]) in lower(g.search_text)) = 0;
  if bad > 0 then
    raise exception 'gear phase1: % guitar rows missing tag phrases in search_text', bad;
  end if;
end $$;
