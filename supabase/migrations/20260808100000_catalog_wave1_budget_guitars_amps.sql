-- Catalog Wave 1: budget/beginner guitars + amps (generated 2026-08-06).
-- Budget/beginner catalog expansion. Each model maps to a verified behavior family.
-- Dedup-safe: on conflict do update, tag folding unions distinct phrases.
begin;

insert into public.equipment (
  equipment_type, brand, model, series, display_name, description,
  is_popular, sort_order, status,
  body_type, frets, scale_length_inches, bridge_type,
  pickup_configuration, pickup_type, output_level,
  genres, tone_characteristics, search_terms
) values
-- Cluster G1 — Squier (all lines) + Fender beginner/budget electric guitars
-- 40 electric_guitar rows. One matching tag row per model in g1-tags.sql.

-- Squier Sonic
('electric_guitar','Squier','Sonic Stratocaster','Sonic','Squier Sonic Stratocaster','Ultra-affordable SSS Strat-style beginner electric with poplar body and 6-point tremolo.',false,100,'active','solid_body',21,25.5,'vintage_tremolo','sss',array['single_coil']::equipment_pickup_type[],'medium',array['rock','blues','pop','funk']::equipment_genre[],array['bright','dynamic','articulate']::equipment_tone_characteristic[],array['squier','sonic','stratocaster','squier sonic stratocaster','sonic strat']::text[]),
('electric_guitar','Squier','Sonic Stratocaster HSS','Sonic','Squier Sonic Stratocaster HSS','Budget HSS Strat with a bridge humbucker for extra output and 6-point tremolo.',false,100,'active','solid_body',21,25.5,'vintage_tremolo','hss',array['humbucker','single_coil']::equipment_pickup_type[],'medium',array['rock','blues','alternative']::equipment_genre[],array['bright','punchy','dynamic']::equipment_tone_characteristic[],array['squier','sonic','stratocaster','hss','squier sonic stratocaster hss','sonic strat hss']::text[]),
('electric_guitar','Squier','Sonic Telecaster','Sonic','Squier Sonic Telecaster','Entry-level Tele with two single-coils, poplar body, and string-through hardtail.',false,100,'active','solid_body',21,25.5,'string_through','ss',array['single_coil']::equipment_pickup_type[],'medium',array['country','rock','blues','indie']::equipment_genre[],array['bright','articulate','balanced']::equipment_tone_characteristic[],array['squier','sonic','telecaster','squier sonic telecaster','sonic tele']::text[]),
('electric_guitar','Squier','Sonic Mustang','Sonic','Squier Sonic Mustang','Short-scale HH offset with dual humbuckers and hardtail bridge for beginners.',false,100,'active','solid_body',22,24.0,'fixed','hh',array['humbucker']::equipment_pickup_type[],'high',array['rock','alternative','punk','indie']::equipment_genre[],array['warm','punchy','crunch']::equipment_tone_characteristic[],array['squier','sonic','mustang','squier sonic mustang']::text[]),

-- Squier Bullet
('electric_guitar','Squier','Bullet Stratocaster','Bullet','Squier Bullet Stratocaster','Cheapest Squier SSS Strat, lightweight body with vintage-style tremolo.',false,100,'active','solid_body',21,25.5,'vintage_tremolo','sss',array['single_coil']::equipment_pickup_type[],'medium',array['rock','blues','pop']::equipment_genre[],array['bright','dynamic','articulate']::equipment_tone_characteristic[],array['squier','bullet','stratocaster','squier bullet stratocaster','bullet strat']::text[]),
('electric_guitar','Squier','Bullet Stratocaster HT HSS','Bullet','Squier Bullet Stratocaster HT HSS','Hardtail HSS Bullet Strat with a bridge humbucker and fixed six-saddle bridge.',false,100,'active','solid_body',21,25.5,'fixed','hss',array['humbucker','single_coil']::equipment_pickup_type[],'medium',array['rock','blues','alternative']::equipment_genre[],array['bright','punchy','tight']::equipment_tone_characteristic[],array['squier','bullet','stratocaster','ht','hss','squier bullet stratocaster ht hss','bullet strat hss']::text[]),
('electric_guitar','Squier','Bullet Mustang HH','Bullet','Squier Bullet Mustang HH','Short-scale offset with dual humbuckers and hardtail, a punchy beginner rocker.',false,100,'active','solid_body',22,24.0,'fixed','hh',array['humbucker']::equipment_pickup_type[],'high',array['rock','alternative','punk']::equipment_genre[],array['warm','punchy','crunch']::equipment_tone_characteristic[],array['squier','bullet','mustang','hh','squier bullet mustang hh','bullet mustang']::text[]),
('electric_guitar','Squier','Bullet Telecaster','Bullet','Squier Bullet Telecaster','Budget Tele with dual single-coils and string-through bridge for twang on a dime.',false,100,'active','solid_body',21,25.5,'string_through','ss',array['single_coil']::equipment_pickup_type[],'medium',array['country','rock','blues']::equipment_genre[],array['bright','articulate','balanced']::equipment_tone_characteristic[],array['squier','bullet','telecaster','squier bullet telecaster','bullet tele']::text[]),

-- Squier Affinity
('electric_guitar','Squier','Affinity Stratocaster','Affinity','Squier Affinity Stratocaster','Popular gateway SSS Strat with ceramic single-coils and vintage-style tremolo.',false,100,'active','solid_body',21,25.5,'vintage_tremolo','sss',array['single_coil']::equipment_pickup_type[],'medium',array['rock','blues','pop','funk']::equipment_genre[],array['bright','dynamic','articulate']::equipment_tone_characteristic[],array['squier','affinity','stratocaster','squier affinity stratocaster','affinity strat']::text[]),
('electric_guitar','Squier','Affinity Stratocaster HSS','Affinity','Squier Affinity Stratocaster HSS','Versatile HSS Affinity Strat with a bridge humbucker and vintage-style tremolo.',false,100,'active','solid_body',21,25.5,'vintage_tremolo','hss',array['humbucker','single_coil']::equipment_pickup_type[],'medium',array['rock','blues','alternative']::equipment_genre[],array['bright','punchy','dynamic']::equipment_tone_characteristic[],array['squier','affinity','stratocaster','hss','squier affinity stratocaster hss','affinity strat hss']::text[]),
('electric_guitar','Squier','Affinity Telecaster','Affinity','Squier Affinity Telecaster','Best-selling budget Tele with two single-coils and six-saddle string-through bridge.',false,100,'active','solid_body',21,25.5,'string_through','ss',array['single_coil']::equipment_pickup_type[],'medium',array['country','rock','blues','indie']::equipment_genre[],array['bright','articulate','balanced']::equipment_tone_characteristic[],array['squier','affinity','telecaster','squier affinity telecaster','affinity tele']::text[]),
('electric_guitar','Squier','Affinity Telecaster Deluxe','Affinity','Squier Affinity Telecaster Deluxe','HH Tele Deluxe with dual humbuckers and individual volume/tone for thicker tones.',false,100,'active','solid_body',21,25.5,'string_through','hh',array['humbucker']::equipment_pickup_type[],'high',array['rock','hard_rock','alternative']::equipment_genre[],array['warm','punchy','crunch']::equipment_tone_characteristic[],array['squier','affinity','telecaster','deluxe','tele hh','squier affinity telecaster deluxe','affinity tele deluxe']::text[]),
('electric_guitar','Squier','Affinity Jazzmaster','Affinity','Squier Affinity Jazzmaster','Offset Jazzmaster with two single-coils and a modern two-point vibrato bridge.',false,100,'active','solid_body',21,25.5,'two_point_tremolo','ss',array['single_coil']::equipment_pickup_type[],'medium',array['indie','alternative','rock','punk']::equipment_genre[],array['warm','bright','dynamic']::equipment_tone_characteristic[],array['squier','affinity','jazzmaster','squier affinity jazzmaster','affinity jazzmaster']::text[]),
('electric_guitar','Squier','Affinity Starcaster','Affinity','Squier Affinity Starcaster','Semi-hollow offset with dual Squier humbuckers and an adjustable bridge.',false,100,'active','semi_hollow',22,25.5,'tune_o_matic','hh',array['humbucker']::equipment_pickup_type[],'high',array['indie','rock','alternative','blues']::equipment_genre[],array['warm','smooth','punchy']::equipment_tone_characteristic[],array['squier','affinity','starcaster','squier affinity starcaster','affinity starcaster']::text[]),

-- Squier Classic Vibe
('electric_guitar','Squier','Classic Vibe ''50s Stratocaster','Classic Vibe','Squier Classic Vibe ''50s Stratocaster','Vintage-voiced ''50s Strat with alnico single-coils and 6-point tremolo.',false,100,'active','solid_body',21,25.5,'vintage_tremolo','sss',array['single_coil']::equipment_pickup_type[],'medium',array['rock','blues','country']::equipment_genre[],array['vintage','bright','articulate']::equipment_tone_characteristic[],array['squier','classic vibe','50s','stratocaster','squier classic vibe 50s stratocaster','cv 50s strat']::text[]),
('electric_guitar','Squier','Classic Vibe ''60s Stratocaster','Classic Vibe','Squier Classic Vibe ''60s Stratocaster','''60s-style Strat with warm alnico single-coils and vintage tremolo.',false,100,'active','solid_body',21,25.5,'vintage_tremolo','sss',array['single_coil']::equipment_pickup_type[],'medium',array['rock','blues','pop']::equipment_genre[],array['vintage','bright','dynamic']::equipment_tone_characteristic[],array['squier','classic vibe','60s','stratocaster','squier classic vibe 60s stratocaster','cv 60s strat']::text[]),
('electric_guitar','Squier','Classic Vibe ''70s Stratocaster','Classic Vibe','Squier Classic Vibe ''70s Stratocaster','''70s-style Strat with big headstock, alnico single-coils, and vintage tremolo.',false,100,'active','solid_body',21,25.5,'vintage_tremolo','sss',array['single_coil']::equipment_pickup_type[],'medium',array['rock','blues','funk']::equipment_genre[],array['vintage','bright','dynamic']::equipment_tone_characteristic[],array['squier','classic vibe','70s','stratocaster','squier classic vibe 70s stratocaster','cv 70s strat']::text[]),
('electric_guitar','Squier','Classic Vibe ''50s Telecaster','Classic Vibe','Squier Classic Vibe ''50s Telecaster','Blackguard-style ''50s Tele with alnico single-coils and string-through bridge.',false,100,'active','solid_body',21,25.5,'string_through','ss',array['single_coil']::equipment_pickup_type[],'medium',array['country','rock','blues']::equipment_genre[],array['vintage','bright','articulate']::equipment_tone_characteristic[],array['squier','classic vibe','50s','telecaster','squier classic vibe 50s telecaster','cv 50s tele']::text[]),
('electric_guitar','Squier','Classic Vibe ''60s Custom Telecaster','Classic Vibe','Squier Classic Vibe ''60s Custom Telecaster','Double-bound ''60s Custom Tele with alnico single-coils and string-through bridge.',false,100,'active','solid_body',21,25.5,'string_through','ss',array['single_coil']::equipment_pickup_type[],'medium',array['country','rock','blues']::equipment_genre[],array['vintage','bright','balanced']::equipment_tone_characteristic[],array['squier','classic vibe','60s','custom','telecaster','squier classic vibe 60s custom telecaster','cv 60s tele']::text[]),
('electric_guitar','Squier','Classic Vibe ''70s Telecaster Thinline','Classic Vibe','Squier Classic Vibe ''70s Telecaster Thinline','Semi-hollow ''70s Thinline Tele with Fender-designed single-coils and f-hole.',false,100,'active','semi_hollow',21,25.5,'string_through','ss',array['single_coil']::equipment_pickup_type[],'medium',array['rock','indie','blues']::equipment_genre[],array['vintage','warm','articulate']::equipment_tone_characteristic[],array['squier','classic vibe','70s','telecaster','thinline','squier classic vibe 70s telecaster thinline','cv 70s thinline']::text[]),
('electric_guitar','Squier','Classic Vibe Jazzmaster','Classic Vibe','Squier Classic Vibe Jazzmaster','Vintage-style offset Jazzmaster with alnico single-coils and floating tremolo.',false,100,'active','solid_body',21,25.5,'vintage_tremolo','ss',array['single_coil']::equipment_pickup_type[],'medium',array['indie','alternative','rock']::equipment_genre[],array['vintage','warm','dynamic']::equipment_tone_characteristic[],array['squier','classic vibe','jazzmaster','squier classic vibe jazzmaster','cv jazzmaster']::text[]),
('electric_guitar','Squier','Classic Vibe Jaguar','Classic Vibe','Squier Classic Vibe Jaguar','Short-scale offset Jaguar with bright alnico single-coils and floating tremolo.',false,100,'active','solid_body',22,24.0,'vintage_tremolo','ss',array['single_coil']::equipment_pickup_type[],'medium',array['indie','alternative','punk','rock']::equipment_genre[],array['vintage','bright','articulate']::equipment_tone_characteristic[],array['squier','classic vibe','jaguar','squier classic vibe jaguar','cv jaguar']::text[]),
('electric_guitar','Squier','Classic Vibe Bass VI','Classic Vibe','Squier Classic Vibe Bass VI','Six-string 30" baritone Bass VI with three single-coils and floating tremolo.',false,100,'active','solid_body',21,30.0,'vintage_tremolo','sss',array['single_coil']::equipment_pickup_type[],'medium',array['rock','indie','alternative']::equipment_genre[],array['vintage','warm','balanced']::equipment_tone_characteristic[],array['squier','classic vibe','bass vi','squier classic vibe bass vi','cv bass vi']::text[]),
('electric_guitar','Squier','Classic Vibe Starcaster','Classic Vibe','Squier Classic Vibe Starcaster','Semi-hollow offset with dual Fender-designed humbuckers and adjustable bridge.',false,100,'active','semi_hollow',22,25.5,'tune_o_matic','hh',array['humbucker']::equipment_pickup_type[],'high',array['indie','rock','jazz','blues']::equipment_genre[],array['vintage','warm','smooth']::equipment_tone_characteristic[],array['squier','classic vibe','starcaster','squier classic vibe starcaster','cv starcaster']::text[]),

-- Squier Paranormal
('electric_guitar','Squier','Paranormal Cabronita Telecaster Thinline','Paranormal','Squier Paranormal Cabronita Telecaster Thinline','Semi-hollow Cabronita Thinline with Fender-designed alnico single-coils.',false,100,'active','semi_hollow',22,25.5,'string_through','ss',array['single_coil']::equipment_pickup_type[],'medium',array['rock','indie','blues','country']::equipment_genre[],array['warm','bright','dynamic']::equipment_tone_characteristic[],array['squier','paranormal','cabronita','telecaster','thinline','squier paranormal cabronita telecaster thinline']::text[]),
('electric_guitar','Squier','Paranormal Baritone Cabronita Telecaster','Paranormal','Squier Paranormal Baritone Cabronita Telecaster','Baritone Cabronita Tele with soapbar single-coils and extended 27" scale.',false,100,'active','solid_body',22,27.0,'string_through','ss',array['single_coil']::equipment_pickup_type[],'medium',array['rock','indie','alternative']::equipment_genre[],array['warm','balanced','dynamic']::equipment_tone_characteristic[],array['squier','paranormal','baritone','cabronita','telecaster','squier paranormal baritone cabronita telecaster']::text[]),
('electric_guitar','Squier','Paranormal Super-Sonic','Paranormal','Squier Paranormal Super-Sonic','Reverse-body short-scale offset with dual Squier Atomic humbuckers.',false,100,'active','solid_body',22,24.0,'fixed','hh',array['humbucker']::equipment_pickup_type[],'high',array['rock','alternative','punk','indie']::equipment_genre[],array['warm','punchy','crunch']::equipment_tone_characteristic[],array['squier','paranormal','super-sonic','supersonic','squier paranormal super-sonic']::text[]),
('electric_guitar','Squier','Paranormal Toronado','Paranormal','Squier Paranormal Toronado','Offset dual-humbucker Toronado with 24.75" scale and string-through body.',false,100,'active','solid_body',22,24.75,'string_through','hh',array['humbucker']::equipment_pickup_type[],'high',array['rock','alternative','indie','hard_rock']::equipment_genre[],array['warm','punchy','crunch']::equipment_tone_characteristic[],array['squier','paranormal','toronado','squier paranormal toronado']::text[]),

-- Squier Contemporary
('electric_guitar','Squier','Contemporary Stratocaster Special HT','Contemporary','Squier Contemporary Stratocaster Special HT','Modern hardtail Strat with SQR alnico single-coils and roasted maple neck.',false,100,'active','solid_body',22,25.5,'string_through','sss',array['single_coil']::equipment_pickup_type[],'medium',array['rock','blues','funk','alternative']::equipment_genre[],array['bright','tight','dynamic']::equipment_tone_characteristic[],array['squier','contemporary','stratocaster','special','ht','squier contemporary stratocaster special ht']::text[]),
('electric_guitar','Squier','Contemporary Telecaster RH','Contemporary','Squier Contemporary Telecaster RH','High-output Tele with SQR rail bridge humbucker and Atomic neck humbucker.',false,100,'active','solid_body',22,25.5,'fixed','hh',array['humbucker']::equipment_pickup_type[],'high',array['rock','hard_rock','metal','alternative']::equipment_genre[],array['aggressive','tight','punchy']::equipment_tone_characteristic[],array['squier','contemporary','telecaster','rh','squier contemporary telecaster rh']::text[]),

-- Fender Player II
('electric_guitar','Fender','Player II Stratocaster','Player II','Fender Player II Stratocaster','MIM Strat with three Player II alnico single-coils and two-point tremolo.',false,100,'active','solid_body',22,25.5,'two_point_tremolo','sss',array['single_coil']::equipment_pickup_type[],'medium',array['rock','blues','pop','funk']::equipment_genre[],array['bright','dynamic','balanced']::equipment_tone_characteristic[],array['fender','player ii','player 2','stratocaster','fender player ii stratocaster','player ii strat']::text[]),
('electric_guitar','Fender','Player II Stratocaster HSS','Player II','Fender Player II Stratocaster HSS','MIM HSS Strat with a bridge humbucker and two-point tremolo for extra bite.',false,100,'active','solid_body',22,25.5,'two_point_tremolo','hss',array['humbucker','single_coil']::equipment_pickup_type[],'medium',array['rock','blues','hard_rock']::equipment_genre[],array['bright','punchy','dynamic']::equipment_tone_characteristic[],array['fender','player ii','player 2','stratocaster','hss','fender player ii stratocaster hss','player ii strat hss']::text[]),
('electric_guitar','Fender','Player II Telecaster','Player II','Fender Player II Telecaster','MIM Tele with two Player II single-coils and six-saddle string-through bridge.',false,100,'active','solid_body',22,25.5,'string_through','ss',array['single_coil']::equipment_pickup_type[],'medium',array['country','rock','blues','indie']::equipment_genre[],array['bright','articulate','balanced']::equipment_tone_characteristic[],array['fender','player ii','player 2','telecaster','fender player ii telecaster','player ii tele']::text[]),
('electric_guitar','Fender','Player II Telecaster HH','Player II','Fender Player II Telecaster HH','MIM HH Tele with dual humbuckers for thicker, higher-output rock tones.',false,100,'active','solid_body',22,25.5,'string_through','hh',array['humbucker']::equipment_pickup_type[],'high',array['rock','hard_rock','alternative']::equipment_genre[],array['warm','punchy','crunch']::equipment_tone_characteristic[],array['fender','player ii','player 2','telecaster','hh','fender player ii telecaster hh','player ii tele hh']::text[]),
('electric_guitar','Fender','Player II Jazzmaster','Player II','Fender Player II Jazzmaster','MIM offset Jazzmaster with two single-coils and floating vibrato tailpiece.',false,100,'active','solid_body',22,25.5,'vintage_tremolo','ss',array['single_coil']::equipment_pickup_type[],'medium',array['indie','alternative','rock','punk']::equipment_genre[],array['warm','bright','dynamic']::equipment_tone_characteristic[],array['fender','player ii','player 2','jazzmaster','fender player ii jazzmaster','player ii jazzmaster']::text[]),
('electric_guitar','Fender','Player II Jaguar','Player II','Fender Player II Jaguar','MIM short-scale offset Jaguar with bright single-coils and floating vibrato.',false,100,'active','solid_body',22,24.0,'vintage_tremolo','ss',array['single_coil']::equipment_pickup_type[],'medium',array['indie','alternative','punk','rock']::equipment_genre[],array['bright','articulate','vintage']::equipment_tone_characteristic[],array['fender','player ii','player 2','jaguar','fender player ii jaguar','player ii jaguar']::text[]),
('electric_guitar','Fender','Player II Mustang','Player II','Fender Player II Mustang','MIM short-scale Mustang with two single-coils and vintage-style vibrato.',false,100,'active','solid_body',22,24.0,'vintage_tremolo','ss',array['single_coil']::equipment_pickup_type[],'medium',array['indie','alternative','rock','punk']::equipment_genre[],array['bright','dynamic','punchy']::equipment_tone_characteristic[],array['fender','player ii','player 2','mustang','fender player ii mustang','player ii mustang']::text[]),

-- Fender Standard (2025)
('electric_guitar','Fender','Standard Stratocaster','Standard','Fender Standard Stratocaster','Budget Fender-branded SSS Strat with poplar body and vintage-style tremolo.',false,100,'active','solid_body',22,25.5,'vintage_tremolo','sss',array['single_coil']::equipment_pickup_type[],'medium',array['rock','blues','pop','funk']::equipment_genre[],array['bright','dynamic','balanced']::equipment_tone_characteristic[],array['fender','standard','stratocaster','fender standard stratocaster','standard strat']::text[]),
('electric_guitar','Fender','Standard Stratocaster HSS','Standard','Fender Standard Stratocaster HSS','Budget Fender HSS Strat with a bridge humbucker and vintage-style tremolo.',false,100,'active','solid_body',22,25.5,'vintage_tremolo','hss',array['humbucker','single_coil']::equipment_pickup_type[],'medium',array['rock','blues','hard_rock']::equipment_genre[],array['bright','punchy','dynamic']::equipment_tone_characteristic[],array['fender','standard','stratocaster','hss','fender standard stratocaster hss','standard strat hss']::text[]),
('electric_guitar','Fender','Standard Telecaster','Standard','Fender Standard Telecaster','Budget Fender-branded Tele with two single-coils and string-through hardtail.',false,100,'active','solid_body',22,25.5,'string_through','ss',array['single_coil']::equipment_pickup_type[],'medium',array['country','rock','blues','indie']::equipment_genre[],array['bright','articulate','balanced']::equipment_tone_characteristic[],array['fender','standard','telecaster','fender standard telecaster','standard tele']::text[]),
('electric_guitar','Yamaha','PAC012','Pacifica','Yamaha PAC012','Best-selling beginner HSS Pacifica with agathis body and vintage tremolo.',false,100,'active','solid_body',22,25.5,'vintage_tremolo','hss',array['single_coil','humbucker']::equipment_pickup_type[],'medium',array['rock','blues','pop','indie']::equipment_genre[],array['balanced','dynamic','bright']::equipment_tone_characteristic[],array['yamaha','pac012','pacifica','pacifica 012']::text[]),
('electric_guitar','Yamaha','PAC112J','Pacifica','Yamaha PAC112J','Entry HSS Pacifica with alder body, the classic first-guitar choice.',false,100,'active','solid_body',22,25.5,'vintage_tremolo','hss',array['single_coil','humbucker']::equipment_pickup_type[],'medium',array['rock','blues','pop','alternative']::equipment_genre[],array['balanced','dynamic','articulate']::equipment_tone_characteristic[],array['yamaha','pac112j','pacifica','pacifica 112j']::text[]),
('electric_guitar','Yamaha','PAC112V','Pacifica','Yamaha PAC112V','Upgraded HSS Pacifica with alnico pickups and coil-split for versatility.',false,100,'active','solid_body',22,25.5,'vintage_tremolo','hss',array['single_coil','humbucker']::equipment_pickup_type[],'medium',array['rock','blues','pop','funk']::equipment_genre[],array['balanced','dynamic','articulate','warm']::equipment_tone_characteristic[],array['yamaha','pac112v','pacifica','pacifica 112v']::text[]),
('electric_guitar','Yamaha','PAC112VM','Pacifica','Yamaha PAC112VM','HSS Pacifica 112V with maple fretboard for a brighter snap.',false,100,'active','solid_body',22,25.5,'vintage_tremolo','hss',array['single_coil','humbucker']::equipment_pickup_type[],'medium',array['rock','blues','pop','country']::equipment_genre[],array['bright','balanced','dynamic']::equipment_tone_characteristic[],array['yamaha','pac112vm','pacifica','pacifica 112vm']::text[]),
('electric_guitar','Yamaha','PAC120H','Pacifica','Yamaha PAC120H','Dual-humbucker hardtail Pacifica for rock and heavier tones.',false,100,'active','solid_body',22,25.5,'fixed','hh',array['humbucker']::equipment_pickup_type[],'high',array['rock','hard_rock','alternative','punk']::equipment_genre[],array['warm','punchy','crunchy']::equipment_tone_characteristic[],array['yamaha','pac120h','pacifica','pacifica 120h']::text[]),
('electric_guitar','Yamaha','PAC212VFM','Pacifica','Yamaha PAC212VFM','Flame-maple-top HSS Pacifica with alnico pickups and tremolo.',false,100,'active','solid_body',22,25.5,'vintage_tremolo','hss',array['single_coil','humbucker']::equipment_pickup_type[],'medium',array['rock','blues','pop','alternative']::equipment_genre[],array['balanced','warm','dynamic']::equipment_tone_characteristic[],array['yamaha','pac212vfm','pacifica','pacifica 212vfm']::text[]),
('electric_guitar','Yamaha','PAC311H','Pacifica','Yamaha PAC311H','Humbucker/P-90 hardtail Pacifica with coil-split for wide tonal range.',false,100,'active','solid_body',22,25.5,'fixed','hh',array['humbucker','p90']::equipment_pickup_type[],'high',array['rock','blues','alternative','indie']::equipment_genre[],array['warm','punchy','crunchy','dynamic']::equipment_tone_characteristic[],array['yamaha','pac311h','pacifica','pacifica 311h']::text[]),
('electric_guitar','Yamaha','PAC612VII','Pacifica','Yamaha PAC612VII','Pro-level HSS Pacifica with Seymour Duncan pickups and Wilkinson tremolo.',false,100,'active','solid_body',22,25.5,'two_point_tremolo','hss',array['single_coil','humbucker']::equipment_pickup_type[],'high',array['rock','blues','funk','fusion']::equipment_genre[],array['balanced','dynamic','articulate','warm']::equipment_tone_characteristic[],array['yamaha','pac612vii','pacifica','pacifica 612vii']::text[]),
('electric_guitar','Yamaha','PACS+','Pacifica','Yamaha PACS+','Pacifica Standard Plus HSS with Reflectone pickups and two-point tremolo.',false,100,'active','solid_body',22,25.5,'two_point_tremolo','hss',array['single_coil','humbucker']::equipment_pickup_type[],'medium',array['rock','blues','pop','indie']::equipment_genre[],array['balanced','dynamic','articulate','bright']::equipment_tone_characteristic[],array['yamaha','pacs+','pacifica','pacifica standard plus','pacs plus']::text[]),
('electric_guitar','Yamaha','PAC012DLX','Pacifica','Yamaha PAC012DLX','Deluxe HSS Pacifica 012 with agathis body and vintage tremolo.',false,100,'active','solid_body',22,25.5,'vintage_tremolo','hss',array['single_coil','humbucker']::equipment_pickup_type[],'medium',array['rock','blues','pop','alternative']::equipment_genre[],array['balanced','dynamic','bright']::equipment_tone_characteristic[],array['yamaha','pac012dlx','pacifica','pacifica 012 deluxe']::text[]),
('electric_guitar','Yamaha','Revstar Element RSE20','Revstar','Yamaha Revstar Element RSE20','Chambered dual-humbucker Revstar with VH3 pickups and Dry Switch.',false,100,'active','solid_body',22,24.75,'tune_o_matic','hh',array['humbucker']::equipment_pickup_type[],'high',array['rock','hard_rock','blues','alternative']::equipment_genre[],array['warm','punchy','balanced','crunchy']::equipment_tone_characteristic[],array['yamaha','revstar','element','rse20']::text[]),
('electric_guitar','Yamaha','Revstar Standard RSS02','Revstar','Yamaha Revstar Standard RSS02','P-90 Revstar Standard with alnico soapbars and 5-way switching.',false,100,'active','solid_body',22,24.75,'tune_o_matic','p90',array['p90']::equipment_pickup_type[],'medium',array['rock','blues','indie','alternative']::equipment_genre[],array['warm','crunchy','punchy','dynamic']::equipment_tone_characteristic[],array['yamaha','revstar','standard','rss02']::text[]),
('electric_guitar','Yamaha','Revstar Standard RSS20','Revstar','Yamaha Revstar Standard RSS20','Alnico V humbucker Revstar Standard with 5-way switching and Dry Switch.',false,100,'active','solid_body',22,24.75,'tune_o_matic','hh',array['humbucker']::equipment_pickup_type[],'high',array['rock','hard_rock','blues','alternative']::equipment_genre[],array['warm','punchy','balanced','crunchy']::equipment_tone_characteristic[],array['yamaha','revstar','standard','rss20']::text[]),
('electric_guitar','Ibanez','GRX70QA','GIO','Ibanez GRX70QA','Quilted-top GIO superstrat with HSH pickups and vintage tremolo.',false,100,'active','solid_body',24,25.5,'vintage_tremolo','hsh',array['humbucker','single_coil']::equipment_pickup_type[],'high',array['rock','metal','hard_rock','alternative']::equipment_genre[],array['aggressive','tight','punchy','bright']::equipment_tone_characteristic[],array['ibanez','grx70qa','gio','grx']::text[]),
('electric_guitar','Ibanez','GRX40','GIO','Ibanez GRX40','Budget GIO superstrat with SSH pickups and vintage tremolo.',false,100,'active','solid_body',24,25.5,'vintage_tremolo','ssh',array['single_coil','humbucker']::equipment_pickup_type[],'medium',array['rock','metal','hard_rock','alternative']::equipment_genre[],array['bright','tight','punchy']::equipment_tone_characteristic[],array['ibanez','grx40','gio','grx']::text[]),
('electric_guitar','Ibanez','GRG121DX','GIO','Ibanez GRG121DX','GIO RG metal starter with hot dual humbuckers and fixed bridge.',false,100,'active','solid_body',24,25.5,'fixed','hh',array['humbucker']::equipment_pickup_type[],'high',array['metal','hard_rock','rock','progressive']::equipment_genre[],array['aggressive','tight','high_gain','modern']::equipment_tone_characteristic[],array['ibanez','grg121dx','gio','grg']::text[]),
('electric_guitar','Ibanez','GRG131DX','GIO','Ibanez GRG131DX','GIO RG with dual humbuckers, sharktooth inlays and fixed bridge.',false,100,'active','solid_body',24,25.5,'fixed','hh',array['humbucker']::equipment_pickup_type[],'high',array['metal','hard_rock','rock','progressive']::equipment_genre[],array['aggressive','tight','high_gain','modern']::equipment_tone_characteristic[],array['ibanez','grg131dx','gio','grg']::text[]),
('electric_guitar','Ibanez','GRGM21','GIO','Ibanez GRGM21','Mikro short-scale GIO RG with dual humbuckers, great for small hands.',false,100,'active','solid_body',24,22.2,'fixed','hh',array['humbucker']::equipment_pickup_type[],'high',array['metal','rock','hard_rock','punk']::equipment_genre[],array['aggressive','tight','punchy']::equipment_tone_characteristic[],array['ibanez','grgm21','gio','mikro']::text[]),
('electric_guitar','Ibanez','GRGR221PA','GIO','Ibanez GRGR221PA','GIO RG with poplar-burl top, reverse headstock and dual humbuckers.',false,100,'active','solid_body',24,25.5,'fixed','hh',array['humbucker']::equipment_pickup_type[],'high',array['metal','hard_rock','rock','progressive']::equipment_genre[],array['aggressive','tight','high_gain','modern']::equipment_tone_characteristic[],array['ibanez','grgr221pa','gio','grgr']::text[]),
('electric_guitar','Ibanez','GAX30','GIO','Ibanez GAX30','Double-cut GAX with dual humbuckers and a Les-Paul-flavored voice.',false,100,'active','solid_body',22,24.75,'tune_o_matic','hh',array['humbucker']::equipment_pickup_type[],'high',array['rock','hard_rock','blues','punk']::equipment_genre[],array['warm','crunchy','punchy']::equipment_tone_characteristic[],array['ibanez','gax30','gax','gio']::text[]),
('electric_guitar','Ibanez','GRX20','GIO','Ibanez GRX20','Affordable GIO superstrat with dual humbuckers and tremolo.',false,100,'active','solid_body',22,25.5,'vintage_tremolo','hh',array['humbucker']::equipment_pickup_type[],'medium',array['rock','metal','hard_rock','alternative']::equipment_genre[],array['bright','tight','punchy']::equipment_tone_characteristic[],array['ibanez','grx20','gio','grx']::text[]),
('electric_guitar','Ibanez','GRGA120','GIO','Ibanez GRGA120','GIO RGA superstrat with dual humbuckers and synchronized tremolo.',false,100,'active','solid_body',24,25.5,'vintage_tremolo','hh',array['humbucker']::equipment_pickup_type[],'high',array['metal','hard_rock','rock','progressive']::equipment_genre[],array['aggressive','tight','modern','punchy']::equipment_tone_characteristic[],array['ibanez','grga120','gio','grga']::text[]),
('electric_guitar','Ibanez','RG421','RG','Ibanez RG421','RG Standard with dual humbuckers, fixed bridge and fast Wizard neck.',false,100,'active','solid_body',24,25.5,'fixed','hh',array['humbucker']::equipment_pickup_type[],'high',array['metal','hard_rock','rock','progressive']::equipment_genre[],array['aggressive','tight','high_gain','modern']::equipment_tone_characteristic[],array['ibanez','rg421','rg','standard']::text[]),
('electric_guitar','Ibanez','RG450DX','RG','Ibanez RG450DX','RG Standard superstrat with HSH pickups and Edge-Zero tremolo.',false,100,'active','solid_body',24,25.5,'floyd_rose','hsh',array['humbucker','single_coil']::equipment_pickup_type[],'high',array['metal','hard_rock','rock','progressive']::equipment_genre[],array['aggressive','tight','high_gain','articulate']::equipment_tone_characteristic[],array['ibanez','rg450dx','rg','standard']::text[]),
('electric_guitar','Ibanez','RG550','RG','Ibanez RG550','Reissued classic RG superstrat with HSH pickups and Edge tremolo.',false,100,'active','solid_body',24,25.5,'floyd_rose','hsh',array['humbucker','single_coil']::equipment_pickup_type[],'high',array['metal','hard_rock','rock','progressive']::equipment_genre[],array['aggressive','tight','articulate','modern']::equipment_tone_characteristic[],array['ibanez','rg550','rg','genesis']::text[]),
('electric_guitar','Ibanez','RGA42','RG','Ibanez RGA42','Arched-top RGA with dual humbuckers and fixed bridge for modern metal.',false,100,'active','solid_body',24,25.5,'fixed','hh',array['humbucker']::equipment_pickup_type[],'high',array['metal','hard_rock','rock','progressive']::equipment_genre[],array['aggressive','tight','high_gain','modern']::equipment_tone_characteristic[],array['ibanez','rga42','rga','rg']::text[]),
('electric_guitar','Ibanez','AZES31','AZ Essentials','Ibanez AZES31','AZ Essentials SSS with vintage tremolo and modern playability.',false,100,'active','solid_body',22,25.5,'two_point_tremolo','sss',array['single_coil']::equipment_pickup_type[],'medium',array['rock','blues','pop','funk']::equipment_genre[],array['bright','balanced','articulate','dynamic']::equipment_tone_characteristic[],array['ibanez','azes31','az','essentials']::text[]),
('electric_guitar','Ibanez','AZES40','AZ Essentials','Ibanez AZES40','AZ Essentials HSS with two-point tremolo and coil-split versatility.',false,100,'active','solid_body',22,25.5,'two_point_tremolo','hss',array['single_coil','humbucker']::equipment_pickup_type[],'medium',array['rock','blues','pop','fusion']::equipment_genre[],array['balanced','articulate','dynamic','bright']::equipment_tone_characteristic[],array['ibanez','azes40','az','essentials']::text[]),
('electric_guitar','Ibanez','AS53','Artcore','Ibanez AS53','Semi-hollow Artcore with Infinity R humbuckers, a budget ES-335 rival.',false,100,'active','semi_hollow',22,24.75,'tune_o_matic','hh',array['humbucker']::equipment_pickup_type[],'medium',array['jazz','blues','rock','indie']::equipment_genre[],array['warm','smooth','balanced','vintage']::equipment_tone_characteristic[],array['ibanez','as53','artcore','as']::text[]),
('electric_guitar','Ibanez','AM53','Artcore','Ibanez AM53','Small-body semi-hollow Artcore with dual humbuckers for jazz and blues.',false,100,'active','semi_hollow',22,24.75,'tune_o_matic','hh',array['humbucker']::equipment_pickup_type[],'medium',array['jazz','blues','rock','indie']::equipment_genre[],array['warm','smooth','balanced','vintage']::equipment_tone_characteristic[],array['ibanez','am53','artcore','am']::text[]),
('electric_guitar','Ibanez','AF55','Artcore','Ibanez AF55','Full hollow-body Artcore archtop with warm humbuckers for jazz.',false,100,'active','hollow_body',22,24.75,'tune_o_matic','hh',array['humbucker']::equipment_pickup_type[],'medium',array['jazz','blues','indie']::equipment_genre[],array['warm','smooth','vintage','mid_focused']::equipment_tone_characteristic[],array['ibanez','af55','artcore','af']::text[]),
('electric_guitar','Ibanez','AG75','Artcore','Ibanez AG75','Grand-auditorium hollow-body Artcore with humbuckers for jazz tones.',false,100,'active','hollow_body',22,24.75,'tune_o_matic','hh',array['humbucker']::equipment_pickup_type[],'medium',array['jazz','blues','indie']::equipment_genre[],array['warm','smooth','vintage','mid_focused']::equipment_tone_characteristic[],array['ibanez','ag75','artcore','ag']::text[]),
('electric_guitar','Cort','G250','G Series','Cort G250','Double-cut G-Series with basswood body and HSS pickups.',false,100,'active','solid_body',22,25.5,'vintage_tremolo','hss',array['single_coil','humbucker']::equipment_pickup_type[],'medium',array['rock','blues','pop','alternative']::equipment_genre[],array['balanced','bright','dynamic']::equipment_tone_characteristic[],array['cort','g250','g series','g-series']::text[]),
('electric_guitar','Cort','G290','G Series','Cort G290','G290 FAT with mahogany body, dual humbuckers and coil-split.',false,100,'active','solid_body',24,25.5,'string_through','hh',array['humbucker']::equipment_pickup_type[],'high',array['rock','hard_rock','metal','fusion']::equipment_genre[],array['warm','punchy','tight','modern']::equipment_tone_characteristic[],array['cort','g290','g series','g290 fat']::text[]),
('electric_guitar','Cort','X100','X Series','Cort X100','Beginner X-Series superstrat with dual humbuckers and string-through body.',false,100,'active','solid_body',24,25.5,'string_through','hh',array['humbucker']::equipment_pickup_type[],'high',array['metal','hard_rock','rock','progressive']::equipment_genre[],array['aggressive','tight','punchy','modern']::equipment_tone_characteristic[],array['cort','x100','x series','x-series']::text[]),
('electric_guitar','Cort','X250','X Series','Cort X250','X-Series superstrat with dual humbuckers built for modern metal.',false,100,'active','solid_body',24,25.5,'string_through','hh',array['humbucker']::equipment_pickup_type[],'high',array['metal','hard_rock','rock','progressive']::equipment_genre[],array['aggressive','tight','high_gain','modern']::equipment_tone_characteristic[],array['cort','x250','x series','x-series']::text[]),
('electric_guitar','Cort','KX300','KX Series','Cort KX300','KX-Series superstrat with EMG Retro Active humbuckers and string-through bridge.',false,100,'active','solid_body',24,25.5,'string_through','hh',array['active_humbucker']::equipment_pickup_type[],'very_high',array['metal','hard_rock','progressive','rock']::equipment_genre[],array['aggressive','tight','high_gain','modern']::equipment_tone_characteristic[],array['cort','kx300','kx series','kx']::text[]),
('electric_guitar','Cort','CR200','Classic Rock','Cort CR200','Classic Rock single-cut with dual humbuckers and vintage Les-Paul vibe.',false,100,'active','solid_body',22,24.75,'tune_o_matic','hh',array['humbucker']::equipment_pickup_type[],'high',array['rock','hard_rock','blues','classic_rock']::equipment_genre[],array['warm','crunchy','punchy','vintage']::equipment_tone_characteristic[],array['cort','cr200','classic rock','cr']::text[]),
('electric_guitar','Cort','Classic TC','Classic','Cort Classic TC','Tele-style Classic Series with dual single-coils and vintage twang.',false,100,'active','solid_body',22,25.5,'string_through','ss',array['single_coil']::equipment_pickup_type[],'medium',array['country','rock','blues','pop']::equipment_genre[],array['bright','articulate','dynamic','crunchy']::equipment_tone_characteristic[],array['cort','classic tc','classic','tc']::text[]),
('electric_guitar','Epiphone','Les Paul SL','Les Paul','Epiphone Les Paul SL','Ultra-affordable single-cut with dual single-coils, a top student model.',false,100,'active','solid_body',22,24.75,'tune_o_matic','ss',array['single_coil']::equipment_pickup_type[],'medium',array['rock','blues','pop','punk']::equipment_genre[],array['bright','balanced','crunchy']::equipment_tone_characteristic[],array['epiphone','les paul sl','lp sl','sl']::text[]),
('electric_guitar','Epiphone','Les Paul Special','Les Paul','Epiphone Les Paul Special','Satin single-cut with dual P-90s for classic gritty rock and roll.',false,100,'active','solid_body',22,24.75,'tune_o_matic','p90',array['p90']::equipment_pickup_type[],'medium',array['rock','blues','classic_rock','punk']::equipment_genre[],array['warm','crunchy','punchy','vintage']::equipment_tone_characteristic[],array['epiphone','les paul special','lp special','p90']::text[]),
('electric_guitar','Epiphone','Les Paul Studio','Les Paul','Epiphone Les Paul Studio','No-frills Les Paul with dual humbuckers and full mahogany body.',false,100,'active','solid_body',22,24.75,'tune_o_matic','hh',array['humbucker']::equipment_pickup_type[],'high',array['rock','hard_rock','blues','classic_rock']::equipment_genre[],array['warm','crunchy','punchy','balanced']::equipment_tone_characteristic[],array['epiphone','les paul studio','lp studio','studio']::text[]),
('electric_guitar','Epiphone','Les Paul Player Pack','Les Paul','Epiphone Les Paul Player Pack','Complete Les Paul starter pack with amp, humbuckers and accessories.',false,100,'active','solid_body',22,24.75,'tune_o_matic','hh',array['humbucker']::equipment_pickup_type[],'high',array['rock','hard_rock','blues','pop']::equipment_genre[],array['warm','crunchy','balanced']::equipment_tone_characteristic[],array['epiphone','les paul player pack','lp player pack','starter pack']::text[]),
('electric_guitar','Epiphone','Les Paul Standard 50s','Les Paul','Epiphone Les Paul Standard 50s','Classic 50s-spec Les Paul with ProBucker humbuckers and fat neck.',false,100,'active','solid_body',22,24.75,'tune_o_matic','hh',array['humbucker']::equipment_pickup_type[],'high',array['rock','hard_rock','blues','classic_rock']::equipment_genre[],array['warm','crunchy','punchy','vintage']::equipment_tone_characteristic[],array['epiphone','les paul standard 50s','lp standard 50s','standard 50s']::text[]),
('electric_guitar','Epiphone','Les Paul Standard 60s','Les Paul','Epiphone Les Paul Standard 60s','60s-spec Les Paul with ProBucker humbuckers and slim-taper neck.',false,100,'active','solid_body',22,24.75,'tune_o_matic','hh',array['humbucker']::equipment_pickup_type[],'high',array['rock','hard_rock','blues','classic_rock']::equipment_genre[],array['warm','crunchy','punchy','balanced']::equipment_tone_characteristic[],array['epiphone','les paul standard 60s','lp standard 60s','standard 60s']::text[]),
('electric_guitar','Epiphone','SG Special','SG','Epiphone SG Special','Lightweight double-cut SG with dual humbuckers and fast access.',false,100,'active','solid_body',22,24.75,'tune_o_matic','hh',array['humbucker']::equipment_pickup_type[],'high',array['rock','hard_rock','blues','classic_rock']::equipment_genre[],array['warm','crunchy','aggressive','punchy']::equipment_tone_characteristic[],array['epiphone','sg special','sg']::text[]),
('electric_guitar','Epiphone','SG Standard','SG','Epiphone SG Standard','Classic SG with dual ProBucker humbuckers and biting midrange.',false,100,'active','solid_body',22,24.75,'tune_o_matic','hh',array['humbucker']::equipment_pickup_type[],'high',array['rock','hard_rock','blues','classic_rock']::equipment_genre[],array['warm','crunchy','aggressive','mid_focused']::equipment_tone_characteristic[],array['epiphone','sg standard','sg']::text[]),
('electric_guitar','Epiphone','Les Paul Melody Maker','Les Paul','Epiphone Les Paul Melody Maker','Lightweight poplar single-cut with two ceramic humbuckers, most affordable 2-pickup LP.',false,100,'active','solid_body',22,24.75,'tune_o_matic','hh',array['humbucker']::equipment_pickup_type[],'high',array['rock','blues','pop','punk']::equipment_genre[],array['warm','crunchy','balanced']::equipment_tone_characteristic[],array['epiphone','les paul melody maker','melody maker','lp melody maker']::text[]),
('electric_guitar','Epiphone','Power Players Les Paul','Power Players','Epiphone Power Players Les Paul','3/4-scale Les Paul for young and travel players with dual humbuckers.',false,100,'active','solid_body',22,22.73,'tune_o_matic','hh',array['humbucker']::equipment_pickup_type[],'high',array['rock','hard_rock','blues','pop']::equipment_genre[],array['warm','crunchy','punchy']::equipment_tone_characteristic[],array['epiphone','power players les paul','power player','lp power players']::text[]),
('electric_guitar','Epiphone','Power Players SG','Power Players','Epiphone Power Players SG','3/4-scale SG for young and travel players with dual humbuckers.',false,100,'active','solid_body',22,22.73,'tune_o_matic','hh',array['humbucker']::equipment_pickup_type[],'high',array['rock','hard_rock','blues','pop']::equipment_genre[],array['warm','crunchy','aggressive']::equipment_tone_characteristic[],array['epiphone','power players sg','power player','sg power players']::text[]),
('electric_guitar','Epiphone','Dot','Inspired by Gibson','Epiphone Dot','Semi-hollow ES-335-style with dual humbuckers, warm and versatile.',false,100,'active','semi_hollow',22,24.75,'tune_o_matic','hh',array['humbucker']::equipment_pickup_type[],'medium',array['blues','jazz','rock','classic_rock']::equipment_genre[],array['warm','smooth','balanced','vintage']::equipment_tone_characteristic[],array['epiphone','dot','es-335','es335']::text[]),
('electric_guitar','Epiphone','ES-339','Inspired by Gibson','Epiphone ES-339','Compact semi-hollow with dual humbuckers, smaller ES-335 feel.',false,100,'active','semi_hollow',22,24.75,'tune_o_matic','hh',array['humbucker']::equipment_pickup_type[],'medium',array['blues','jazz','rock','classic_rock']::equipment_genre[],array['warm','smooth','balanced','vintage']::equipment_tone_characteristic[],array['epiphone','es-339','es339','339']),
-- Cluster G3 — import/budget starter guitar brands (equipment rows)
-- Glarry, Donner, Firefly, Harley Benton, Jackson JS, Kramer, Monoprice Indio, Gretsch Streamliner

-- Glarry (Amazon best-sellers)
('electric_guitar','Glarry','GST',null,'Glarry GST','Budget ST-style triple single-coil beginner electric',false,100,'active','solid_body',22,25.5,'vintage_tremolo','sss',array['single_coil']::equipment_pickup_type[],'medium',array['rock','blues','pop']::equipment_genre[],array['bright','vintage','balanced']::equipment_tone_characteristic[],array['glarry','gst','st','stratocaster','glarry gst','glarry st']::text[]),
('electric_guitar','Glarry','GST3',null,'Glarry GST3','ST-style SSS variant electric',false,100,'active','solid_body',22,25.5,'vintage_tremolo','sss',array['single_coil']::equipment_pickup_type[],'medium',array['rock','blues','pop']::equipment_genre[],array['bright','vintage','balanced']::equipment_tone_characteristic[],array['glarry','gst3','stratocaster','glarry gst3']::text[]),
('electric_guitar','Glarry','GST-E',null,'Glarry GST-E','HH super-strat version of the GST',false,100,'active','solid_body',22,25.5,'vintage_tremolo','hh',array['humbucker']::equipment_pickup_type[],'high',array['rock','hard_rock','metal']::equipment_genre[],array['modern','aggressive','tight']::equipment_tone_characteristic[],array['glarry','gst-e','gste','superstrat','glarry gst-e']::text[]),
('electric_guitar','Glarry','GTL',null,'Glarry GTL','Budget TL-style twin single-coil electric',false,100,'active','solid_body',22,25.5,'string_through','ss',array['single_coil']::equipment_pickup_type[],'medium',array['country','blues','rock']::equipment_genre[],array['bright','articulate','vintage']::equipment_tone_characteristic[],array['glarry','gtl','tl','telecaster','glarry gtl','glarry tele']::text[]),
('electric_guitar','Glarry','GLP',null,'Glarry GLP','Budget LP-style dual-humbucker electric',false,100,'active','solid_body',22,24.75,'tune_o_matic','hh',array['humbucker']::equipment_pickup_type[],'high',array['rock','blues','hard_rock']::equipment_genre[],array['warm','punchy','balanced']::equipment_tone_characteristic[],array['glarry','glp','glp101','les paul','glarry glp']::text[]),
('electric_guitar','Glarry','Burning Fire',null,'Glarry Burning Fire','24-fret flame-body super-strat',false,100,'active','solid_body',24,25.5,'fixed','hh',array['humbucker']::equipment_pickup_type[],'high',array['metal','hard_rock','rock']::equipment_genre[],array['aggressive','modern','tight']::equipment_tone_characteristic[],array['glarry','burning fire','superstrat','glarry burning fire']::text[]),

-- Donner
('electric_guitar','Donner','DST-152',null,'Donner DST-152','HSS beginner Strat kit with coil-split',false,100,'active','solid_body',22,25.5,'vintage_tremolo','hss',array['single_coil','humbucker']::equipment_pickup_type[],'medium',array['rock','blues','pop']::equipment_genre[],array['bright','balanced','dynamic']::equipment_tone_characteristic[],array['donner','dst-152','dst152','stratocaster','donner dst-152']::text[]),
('electric_guitar','Donner','DST-100',null,'Donner DST-100','SSS beginner Strat-style electric',false,100,'active','solid_body',22,25.5,'vintage_tremolo','sss',array['single_coil']::equipment_pickup_type[],'medium',array['rock','blues','pop']::equipment_genre[],array['bright','vintage','balanced']::equipment_tone_characteristic[],array['donner','dst-100','dst100','stratocaster','donner dst-100']::text[]),
('electric_guitar','Donner','DTC-100',null,'Donner DTC-100','TC-style twin single-coil beginner electric',false,100,'active','solid_body',22,25.5,'string_through','ss',array['single_coil']::equipment_pickup_type[],'medium',array['country','rock','blues']::equipment_genre[],array['bright','articulate','vintage']::equipment_tone_characteristic[],array['donner','dtc-100','dtc100','telecaster','donner dtc-100']::text[]),
('electric_guitar','Donner','DTL-100',null,'Donner DTL-100','Tele-style beginner electric kit',false,100,'active','solid_body',22,25.5,'string_through','ss',array['single_coil']::equipment_pickup_type[],'medium',array['country','rock','blues']::equipment_genre[],array['bright','articulate','vintage']::equipment_tone_characteristic[],array['donner','dtl-100','dtl100','telecaster','donner dtl-100']::text[]),
('electric_guitar','Donner','DLP-124',null,'Donner DLP-124','LP-style dual-humbucker beginner electric',false,100,'active','solid_body',22,24.75,'tune_o_matic','hh',array['humbucker']::equipment_pickup_type[],'high',array['rock','blues','hard_rock']::equipment_genre[],array['warm','punchy','balanced']::equipment_tone_characteristic[],array['donner','dlp-124','dlp124','les paul','donner dlp-124']::text[]),
('electric_guitar','Donner','DMT-100',null,'Donner DMT-100','24-fret HH metal-style electric',false,100,'active','solid_body',24,25.5,'fixed','hh',array['humbucker']::equipment_pickup_type[],'very_high',array['metal','hard_rock']::equipment_genre[],array['aggressive','high_gain','tight']::equipment_tone_characteristic[],array['donner','dmt-100','dmt100','metal','donner dmt-100']::text[]),

-- Firefly
('electric_guitar','Firefly','FF338',null,'Firefly FF338','Semi-hollow 335-style with dual humbuckers',false,100,'active','semi_hollow',22,24.75,'tune_o_matic','hh',array['humbucker']::equipment_pickup_type[],'medium',array['blues','jazz','rock']::equipment_genre[],array['warm','smooth','balanced']::equipment_tone_characteristic[],array['firefly','ff338','semi hollow','es-335','firefly ff338']::text[]),
('electric_guitar','Firefly','FFLP',null,'Firefly FFLP','LP-style set-neck dual-humbucker electric',false,100,'active','solid_body',22,24.75,'tune_o_matic','hh',array['humbucker']::equipment_pickup_type[],'high',array['rock','blues','hard_rock']::equipment_genre[],array['warm','punchy','balanced']::equipment_tone_characteristic[],array['firefly','fflp','les paul','firefly fflp']::text[]),
('electric_guitar','Firefly','FFTL',null,'Firefly FFTL','Tele-style budget electric',false,100,'active','solid_body',22,25.5,'string_through','ss',array['single_coil']::equipment_pickup_type[],'medium',array['country','rock','blues']::equipment_genre[],array['bright','articulate','vintage']::equipment_tone_characteristic[],array['firefly','fftl','telecaster','firefly fftl']::text[]),

-- Harley Benton (Thomann budget line)
('electric_guitar','Harley Benton','ST-20',null,'Harley Benton ST-20','Entry ST-style SSS electric',false,100,'active','solid_body',22,25.5,'vintage_tremolo','sss',array['single_coil']::equipment_pickup_type[],'medium',array['rock','blues','pop']::equipment_genre[],array['bright','vintage','balanced']::equipment_tone_characteristic[],array['harley benton','st-20','st20','stratocaster','harley benton st-20']::text[]),
('electric_guitar','Harley Benton','ST-59',null,'Harley Benton ST-59','ST-style with Roswell single-coils',false,100,'active','solid_body',22,25.5,'vintage_tremolo','sss',array['single_coil']::equipment_pickup_type[],'medium',array['rock','blues','pop']::equipment_genre[],array['bright','vintage','balanced']::equipment_tone_characteristic[],array['harley benton','st-59','st59','stratocaster','harley benton st-59']::text[]),
('electric_guitar','Harley Benton','ST-62',null,'Harley Benton ST-62','Vintage-spec ST-style SSS electric',false,100,'active','solid_body',22,25.5,'vintage_tremolo','sss',array['single_coil']::equipment_pickup_type[],'medium',array['rock','blues','pop']::equipment_genre[],array['bright','vintage','articulate']::equipment_tone_characteristic[],array['harley benton','st-62','st62','stratocaster','harley benton st-62']::text[]),
('electric_guitar','Harley Benton','TE-20',null,'Harley Benton TE-20','Entry TE-style twin single-coil electric',false,100,'active','solid_body',22,25.5,'string_through','ss',array['single_coil']::equipment_pickup_type[],'medium',array['country','rock','blues']::equipment_genre[],array['bright','articulate','vintage']::equipment_tone_characteristic[],array['harley benton','te-20','te20','telecaster','harley benton te-20']::text[]),
('electric_guitar','Harley Benton','TE-52',null,'Harley Benton TE-52','Vintage TE-style electric',false,100,'active','solid_body',22,25.5,'string_through','ss',array['single_coil']::equipment_pickup_type[],'medium',array['country','rock','blues']::equipment_genre[],array['bright','articulate','vintage']::equipment_tone_characteristic[],array['harley benton','te-52','te52','telecaster','harley benton te-52']::text[]),
('electric_guitar','Harley Benton','TE-62',null,'Harley Benton TE-62','TE-style with vintage single-coils',false,100,'active','solid_body',22,25.5,'string_through','ss',array['single_coil']::equipment_pickup_type[],'medium',array['country','rock','blues']::equipment_genre[],array['bright','articulate','vintage']::equipment_tone_characteristic[],array['harley benton','te-62','te62','telecaster','harley benton te-62']::text[]),
('electric_guitar','Harley Benton','SC-200',null,'Harley Benton SC-200','Single-cut LP-style dual-humbucker',false,100,'active','solid_body',22,24.75,'tune_o_matic','hh',array['humbucker']::equipment_pickup_type[],'high',array['rock','blues','hard_rock']::equipment_genre[],array['warm','punchy','balanced']::equipment_tone_characteristic[],array['harley benton','sc-200','sc200','les paul','harley benton sc-200']::text[]),
('electric_guitar','Harley Benton','SC-400',null,'Harley Benton SC-400','LP-style with flamed top and humbuckers',false,100,'active','solid_body',22,24.75,'tune_o_matic','hh',array['humbucker']::equipment_pickup_type[],'high',array['rock','blues','hard_rock']::equipment_genre[],array['warm','punchy','balanced']::equipment_tone_characteristic[],array['harley benton','sc-400','sc400','les paul','harley benton sc-400']::text[]),
('electric_guitar','Harley Benton','SC-450',null,'Harley Benton SC-450','LP-style Plus with dual humbuckers',false,100,'active','solid_body',22,24.75,'tune_o_matic','hh',array['humbucker']::equipment_pickup_type[],'high',array['rock','blues','hard_rock']::equipment_genre[],array['warm','punchy','balanced']::equipment_tone_characteristic[],array['harley benton','sc-450','sc450','les paul','harley benton sc-450']::text[]),
('electric_guitar','Harley Benton','DC-Junior',null,'Harley Benton DC-Junior','Double-cut junior with P-90 pickups',false,100,'active','solid_body',22,24.75,'tune_o_matic','p90',array['p90']::equipment_pickup_type[],'medium',array['rock','punk','blues']::equipment_genre[],array['warm','punchy','mid_focused']::equipment_tone_characteristic[],array['harley benton','dc-junior','dc junior','p90','harley benton dc-junior']::text[]),
('electric_guitar','Harley Benton','Fusion-II HH',null,'Harley Benton Fusion-II HH','Roasted-neck HH superstrat',false,100,'active','solid_body',24,25.5,'two_point_tremolo','hh',array['humbucker']::equipment_pickup_type[],'high',array['rock','metal','hard_rock']::equipment_genre[],array['modern','tight','articulate']::equipment_tone_characteristic[],array['harley benton','fusion-ii','fusion 2','superstrat','harley benton fusion-ii hh']::text[]),
('electric_guitar','Harley Benton','Fusion-III HSH',null,'Harley Benton Fusion-III HSH','HSH superstrat with stainless frets',false,100,'active','solid_body',24,25.5,'two_point_tremolo','hsh',array['single_coil','humbucker']::equipment_pickup_type[],'high',array['rock','metal','fusion']::equipment_genre[],array['modern','dynamic','articulate']::equipment_tone_characteristic[],array['harley benton','fusion-iii','fusion 3','superstrat','harley benton fusion-iii hsh']::text[]),
('electric_guitar','Harley Benton','Amarok',null,'Harley Benton Amarok','Metal superstrat with Floyd Rose',false,100,'active','solid_body',24,25.5,'floyd_rose','hh',array['humbucker']::equipment_pickup_type[],'very_high',array['metal','progressive','hard_rock']::equipment_genre[],array['aggressive','high_gain','tight']::equipment_tone_characteristic[],array['harley benton','amarok','superstrat','metal','harley benton amarok']::text[]),
('electric_guitar','Harley Benton','R-446',null,'Harley Benton R-446','Metal superstrat with ceramic humbuckers',false,100,'active','solid_body',24,25.5,'fixed','hh',array['humbucker']::equipment_pickup_type[],'very_high',array['metal','hard_rock']::equipment_genre[],array['aggressive','high_gain','tight']::equipment_tone_characteristic[],array['harley benton','r-446','r446','metal','harley benton r-446']::text[]),
('electric_guitar','Harley Benton','CST-24',null,'Harley Benton CST-24','PRS-style double-cut with humbuckers',false,100,'active','solid_body',24,25.0,'tune_o_matic','hh',array['humbucker']::equipment_pickup_type[],'high',array['rock','hard_rock','fusion']::equipment_genre[],array['balanced','modern','warm']::equipment_tone_characteristic[],array['harley benton','cst-24','cst24','prs','harley benton cst-24']::text[]),

-- Jackson JS Series (budget)
('electric_guitar','Jackson','JS11 Dinky','JS','Jackson JS11 Dinky','Entry Dinky HH superstrat',false,100,'active','solid_body',24,25.5,'fixed','hh',array['humbucker']::equipment_pickup_type[],'high',array['metal','hard_rock','rock']::equipment_genre[],array['aggressive','tight','modern']::equipment_tone_characteristic[],array['jackson','js11','dinky','superstrat','jackson js11 dinky']::text[]),
('electric_guitar','Jackson','JS12 Dinky','JS','Jackson JS12 Dinky','Dinky HH superstrat',false,100,'active','solid_body',24,25.5,'fixed','hh',array['humbucker']::equipment_pickup_type[],'high',array['metal','hard_rock','rock']::equipment_genre[],array['aggressive','tight','modern']::equipment_tone_characteristic[],array['jackson','js12','dinky','superstrat','jackson js12 dinky']::text[]),
('electric_guitar','Jackson','JS22 Dinky','JS','Jackson JS22 Dinky','Dinky arch-top HH superstrat',false,100,'active','solid_body',24,25.5,'fixed','hh',array['humbucker']::equipment_pickup_type[],'high',array['metal','hard_rock','rock']::equipment_genre[],array['aggressive','tight','modern']::equipment_tone_characteristic[],array['jackson','js22','dinky','superstrat','jackson js22 dinky']::text[]),
('electric_guitar','Jackson','JS32 Dinky','JS','Jackson JS32 Dinky','Dinky arch-top with Floyd Rose tremolo',false,100,'active','solid_body',24,25.5,'floyd_rose','hh',array['humbucker']::equipment_pickup_type[],'very_high',array['metal','hard_rock','progressive']::equipment_genre[],array['aggressive','high_gain','tight']::equipment_tone_characteristic[],array['jackson','js32','dinky','superstrat','jackson js32 dinky']::text[]),
('electric_guitar','Jackson','JS32 King V','JS','Jackson JS32 King V','V-shape metal electric with humbuckers',false,100,'active','solid_body',24,25.5,'string_through','hh',array['humbucker']::equipment_pickup_type[],'very_high',array['metal','hard_rock']::equipment_genre[],array['aggressive','high_gain','tight']::equipment_tone_characteristic[],array['jackson','js32','king v','flying v','jackson js32 king v']::text[]),
('electric_guitar','Jackson','JS32 Rhoads','JS','Jackson JS32 Rhoads','Offset-V metal electric with humbuckers',false,100,'active','solid_body',24,25.5,'string_through','hh',array['humbucker']::equipment_pickup_type[],'very_high',array['metal','hard_rock']::equipment_genre[],array['aggressive','high_gain','tight']::equipment_tone_characteristic[],array['jackson','js32','rhoads','jackson js32 rhoads']::text[]),
('electric_guitar','Jackson','JS32 Kelly','JS','Jackson JS32 Kelly','Explorer-style metal electric with humbuckers',false,100,'active','solid_body',24,25.5,'string_through','hh',array['humbucker']::equipment_pickup_type[],'very_high',array['metal','hard_rock']::equipment_genre[],array['aggressive','high_gain','tight']::equipment_tone_characteristic[],array['jackson','js32','kelly','jackson js32 kelly']::text[]),
('electric_guitar','Jackson','JS1X Dinky Minion','JS','Jackson JS1X Dinky Minion','Short-scale travel Dinky superstrat',false,100,'active','solid_body',24,22.5,'fixed','hh',array['humbucker']::equipment_pickup_type[],'high',array['metal','hard_rock','rock']::equipment_genre[],array['aggressive','tight','modern']::equipment_tone_characteristic[],array['jackson','js1x','minion','dinky','jackson js1x dinky minion']::text[]),

-- Kramer (budget)
('electric_guitar','Kramer','Focus VT-211S','Focus','Kramer Focus VT-211S','Budget S-style SSS with tremolo',false,100,'active','solid_body',22,25.5,'vintage_tremolo','sss',array['single_coil']::equipment_pickup_type[],'medium',array['rock','hard_rock','blues']::equipment_genre[],array['bright','punchy','dynamic']::equipment_tone_characteristic[],array['kramer','focus','vt-211s','vt211s','kramer focus vt-211s']::text[]),
('electric_guitar','Kramer','Striker HSS','Striker','Kramer Striker HSS','HSS superstrat with Floyd Rose',false,100,'active','solid_body',24,25.5,'floyd_rose','hss',array['single_coil','humbucker']::equipment_pickup_type[],'high',array['rock','hard_rock','metal']::equipment_genre[],array['modern','tight','punchy']::equipment_tone_characteristic[],array['kramer','striker','hss','superstrat','kramer striker hss']::text[]),

-- Monoprice Indio
('electric_guitar','Monoprice','Indio Cali Classic','Indio','Monoprice Indio Cali Classic','SSS Strat-style beginner electric',false,100,'active','solid_body',22,25.5,'vintage_tremolo','sss',array['single_coil']::equipment_pickup_type[],'medium',array['rock','blues','pop']::equipment_genre[],array['bright','vintage','balanced']::equipment_tone_characteristic[],array['monoprice','indio','cali classic','stratocaster','monoprice indio cali classic']::text[]),
('electric_guitar','Monoprice','Indio Cali Classic HSS','Indio','Monoprice Indio Cali Classic HSS','HSS Strat-style beginner electric',false,100,'active','solid_body',22,25.5,'vintage_tremolo','hss',array['single_coil','humbucker']::equipment_pickup_type[],'medium',array['rock','blues','pop']::equipment_genre[],array['bright','balanced','dynamic']::equipment_tone_characteristic[],array['monoprice','indio','cali classic hss','stratocaster','monoprice indio cali classic hss']::text[]),
('electric_guitar','Monoprice','Indio Retro Classic','Indio','Monoprice Indio Retro Classic','Semi-hollow offset with dual humbuckers',false,100,'active','semi_hollow',22,25.5,'fixed','hh',array['humbucker']::equipment_pickup_type[],'medium',array['indie','rock','blues']::equipment_genre[],array['warm','balanced','vintage']::equipment_tone_characteristic[],array['monoprice','indio','retro classic','offset','monoprice indio retro classic']::text[]),

-- Gretsch Streamliner (budget)
('electric_guitar','Gretsch','G2622 Streamliner','Streamliner','Gretsch G2622 Streamliner','Center-block double-cut with Broad Tron humbuckers',false,100,'active','semi_hollow',22,24.75,'fixed','hh',array['filtertron']::equipment_pickup_type[],'medium',array['rock','indie','blues']::equipment_genre[],array['bright','articulate','warm']::equipment_tone_characteristic[],array['gretsch','g2622','streamliner','electromatic','gretsch g2622 streamliner']::text[]),
('electric_guitar','Gretsch','G2655 Streamliner','Streamliner','Gretsch G2655 Streamliner','Junior center-block double-cut with humbuckers',false,100,'active','semi_hollow',22,24.75,'fixed','hh',array['filtertron']::equipment_pickup_type[],'medium',array['rock','indie','blues']::equipment_genre[],array['bright','articulate','warm']::equipment_tone_characteristic[],array['gretsch','g2655','streamliner','electromatic','gretsch g2655 streamliner']::text[]),
('electric_guitar','Gretsch','G2420 Streamliner','Streamliner','Gretsch G2420 Streamliner','Hollow-body single-cut with humbuckers',false,100,'active','hollow_body',22,24.75,'fixed','hh',array['filtertron']::equipment_pickup_type[],'medium',array['jazz','blues','rock']::equipment_genre[],array['warm','smooth','balanced']::equipment_tone_characteristic[],array['gretsch','g2420','streamliner','electromatic','gretsch g2420 streamliner']::text[])
on conflict (equipment_type, brand, model) do update set
  display_name = excluded.display_name,
  description = excluded.description,
  search_terms = excluded.search_terms,
  updated_at = now();

insert into public.equipment (
  equipment_type, brand, model, series, display_name, description,
  is_popular, sort_order, status,
  amp_type, technology, power_rating_watts, channels, gain_range,
  genres, tone_characteristics, search_terms
) values
('guitar_amp','Boss','Katana-50 MkII',null,'Boss Katana-50 MkII','50-watt 1x12 digital modeling combo, the classic beginner practice amp',false,100,'active','combo','digital',50,5,'high',array['rock','metal','hard_rock','blues','classic_rock']::equipment_genre[],array['crunch','high_gain','balanced','dynamic','articulate']::equipment_tone_characteristic[],array['boss','katana','katana-50','mkii','katana 50 mkii']::text[]),
('guitar_amp','Boss','Katana-100 MkII',null,'Boss Katana-100 MkII','100-watt 1x12 digital modeling combo with stereo expansion',false,100,'active','combo','digital',100,5,'high',array['rock','metal','hard_rock','blues','classic_rock']::equipment_genre[],array['crunch','high_gain','balanced','dynamic','articulate']::equipment_tone_characteristic[],array['boss','katana','katana-100','mkii','katana 100 mkii']::text[]),
('guitar_amp','Boss','Katana-100/212 MkII',null,'Boss Katana-100/212 MkII','100-watt 2x12 digital modeling combo for stage use',false,100,'active','combo','digital',100,5,'high',array['rock','metal','hard_rock','blues','classic_rock']::equipment_genre[],array['crunch','high_gain','balanced','dynamic','articulate']::equipment_tone_characteristic[],array['boss','katana','katana-100','212','mkii','katana 100 212']::text[]),
('guitar_amp','Boss','Katana-Head MkII',null,'Boss Katana-Head MkII','100-watt digital modeling amp head with built-in speaker',false,100,'active','head','digital',100,5,'high',array['rock','metal','hard_rock','blues','classic_rock']::equipment_genre[],array['crunch','high_gain','balanced','dynamic','articulate']::equipment_tone_characteristic[],array['boss','katana','katana-head','mkii','katana head mkii']::text[]),
('guitar_amp','Boss','Katana-Mini',null,'Boss Katana-Mini','7-watt battery-powered mini practice combo with Tube Logic tone',false,100,'active','combo','digital',7,3,'high',array['rock','blues','classic_rock','hard_rock']::equipment_genre[],array['crunch','balanced','warm','dynamic']::equipment_tone_characteristic[],array['boss','katana','katana-mini','mini','katana mini']::text[]),
('guitar_amp','Boss','Katana-Mini X',null,'Boss Katana-Mini X','10-watt portable mini combo with Bluetooth and dual effects',false,100,'active','combo','digital',10,3,'high',array['rock','blues','classic_rock','hard_rock']::equipment_genre[],array['crunch','balanced','warm','dynamic']::equipment_tone_characteristic[],array['boss','katana','katana-mini','mini x','katana mini x']::text[]),
('guitar_amp','Boss','Katana-Air',null,'Boss Katana-Air','30-watt wireless desktop modeling amp with dual speakers',false,100,'active','combo','digital',30,5,'high',array['rock','blues','classic_rock','hard_rock']::equipment_genre[],array['crunch','balanced','warm','dynamic']::equipment_tone_characteristic[],array['boss','katana','katana-air','air','katana air']::text[]),
('guitar_amp','Boss','Katana-Air EX',null,'Boss Katana-Air EX','35-watt wireless desktop modeling amp with 5-inch speakers',false,100,'active','combo','digital',35,5,'high',array['rock','blues','classic_rock','hard_rock']::equipment_genre[],array['crunch','balanced','warm','dynamic']::equipment_tone_characteristic[],array['boss','katana','katana-air','air ex','katana air ex']::text[]),
('guitar_amp','Boss','Katana-Artist MkII',null,'Boss Katana-Artist MkII','100-watt 1x12 flagship modeling combo with Waza speaker',false,100,'active','combo','digital',100,5,'high',array['rock','metal','hard_rock','blues','classic_rock']::equipment_genre[],array['crunch','high_gain','balanced','dynamic','articulate']::equipment_tone_characteristic[],array['boss','katana','katana-artist','mkii','katana artist mkii']::text[]),
('guitar_amp','Boss','Katana-Artist Head MkII',null,'Boss Katana-Artist Head MkII','100-watt flagship modeling amp head with Waza speaker',false,100,'active','head','digital',100,5,'high',array['rock','metal','hard_rock','blues','classic_rock']::equipment_genre[],array['crunch','high_gain','balanced','dynamic','articulate']::equipment_tone_characteristic[],array['boss','katana','katana-artist','head','mkii','katana artist head']::text[]),
('guitar_amp','Boss','Katana-50 Gen 3',null,'Boss Katana-50 Gen 3','50-watt 1x12 third-gen modeling combo with new Pushed amp model',false,100,'active','combo','digital',50,5,'high',array['rock','metal','hard_rock','blues','classic_rock']::equipment_genre[],array['crunch','high_gain','balanced','dynamic','articulate']::equipment_tone_characteristic[],array['boss','katana','katana-50','gen 3','katana 50 gen 3']::text[]),
('guitar_amp','Boss','Katana-50 EX',null,'Boss Katana-50 EX','50-watt Gen 3 modeling combo with upgraded speaker and foot control',false,100,'active','combo','digital',50,5,'high',array['rock','metal','hard_rock','blues','classic_rock']::equipment_genre[],array['crunch','high_gain','balanced','dynamic','articulate']::equipment_tone_characteristic[],array['boss','katana','katana-50','ex','katana 50 ex']::text[]),
('guitar_amp','Boss','Katana-100 Gen 3',null,'Boss Katana-100 Gen 3','100-watt 1x12 third-gen modeling combo, stage-ready',false,100,'active','combo','digital',100,5,'high',array['rock','metal','hard_rock','blues','classic_rock']::equipment_genre[],array['crunch','high_gain','balanced','dynamic','articulate']::equipment_tone_characteristic[],array['boss','katana','katana-100','gen 3','katana 100 gen 3']::text[]),
('guitar_amp','Boss','Katana-Head Gen 3',null,'Boss Katana-Head Gen 3','100-watt third-gen modeling amp head with Bloom switch',false,100,'active','head','digital',100,5,'high',array['rock','metal','hard_rock','blues','classic_rock']::equipment_genre[],array['crunch','high_gain','balanced','dynamic','articulate']::equipment_tone_characteristic[],array['boss','katana','katana-head','gen 3','katana head gen 3']::text[]),
('guitar_amp','Boss','Katana-Artist Gen 3',null,'Boss Katana-Artist Gen 3','100-watt 1x12 flagship Gen 3 combo with Waza G12W speaker',false,100,'active','combo','digital',100,5,'high',array['rock','metal','hard_rock','blues','classic_rock']::equipment_genre[],array['crunch','high_gain','balanced','dynamic','articulate']::equipment_tone_characteristic[],array['boss','katana','katana-artist','gen 3','katana artist gen 3']::text[]),
('guitar_amp','Boss','Katana-Artist Head Gen 3',null,'Boss Katana-Artist Head Gen 3','100-watt flagship Gen 3 amp head with evolved Tube Logic',false,100,'active','head','digital',100,5,'high',array['rock','metal','hard_rock','blues','classic_rock']::equipment_genre[],array['crunch','high_gain','balanced','dynamic','articulate']::equipment_tone_characteristic[],array['boss','katana','katana-artist','head','gen 3','katana artist head gen 3']::text[]),
('guitar_amp','Positive Grid','Spark',null,'Positive Grid Spark','40-watt smart practice amp with app-based amps and effects',false,100,'active','combo','digital',40,1,'high',array['rock','blues','pop','indie','classic_rock']::equipment_genre[],array['balanced','clean','crunch','warm','dynamic']::equipment_tone_characteristic[],array['positive grid','spark','spark 40','positive grid spark']::text[]),
('guitar_amp','Positive Grid','Spark Mini',null,'Positive Grid Spark Mini','10-watt portable smart practice amp with Bluetooth',false,100,'active','combo','digital',10,1,'high',array['rock','blues','pop','indie','classic_rock']::equipment_genre[],array['balanced','clean','crunch','warm','dynamic']::equipment_tone_characteristic[],array['positive grid','spark','spark mini','mini','spark mini']::text[]),
('guitar_amp','Positive Grid','Spark GO',null,'Positive Grid Spark GO','5-watt ultra-portable smart practice amp',false,100,'active','combo','digital',5,1,'high',array['rock','blues','pop','indie','classic_rock']::equipment_genre[],array['balanced','clean','crunch','warm','dynamic']::equipment_tone_characteristic[],array['positive grid','spark','spark go','go','spark go']::text[]),
('guitar_amp','Positive Grid','Spark 2',null,'Positive Grid Spark 2','50-watt smart practice amp with looper and Spark AI',false,100,'active','combo','digital',50,1,'high',array['rock','blues','pop','indie','classic_rock']::equipment_genre[],array['balanced','clean','crunch','warm','dynamic']::equipment_tone_characteristic[],array['positive grid','spark','spark 2','positive grid spark 2']::text[]),
('guitar_amp','Positive Grid','Spark CAB',null,'Positive Grid Spark CAB','140-watt powered cabinet for the Spark ecosystem',false,100,'active','power_amp','digital',140,1,'high',array['rock','blues','pop','indie','classic_rock']::equipment_genre[],array['balanced','clean','warm','dynamic']::equipment_tone_characteristic[],array['positive grid','spark','spark cab','cab','spark cab']::text[]),
('guitar_amp','Positive Grid','Spark LIVE',null,'Positive Grid Spark LIVE','150-watt smart amp and PA with four speakers',false,100,'active','combo','digital',150,1,'high',array['rock','blues','pop','indie','classic_rock']::equipment_genre[],array['balanced','clean','crunch','warm','dynamic']::equipment_tone_characteristic[],array['positive grid','spark','spark live','live','spark live']::text[]),
('guitar_amp','Line 6','Spider V 20 MkII',null,'Line 6 Spider V 20 MkII','20-watt 1x8 modeling combo with full-range speaker',false,100,'active','combo','digital',20,1,'high',array['rock','metal','hard_rock','classic_rock']::equipment_genre[],array['high_gain','crunch','scooped','aggressive','balanced']::equipment_tone_characteristic[],array['line 6','spider','spider v','20','spider v 20 mkii']::text[]),
('guitar_amp','Line 6','Spider V 30 MkII',null,'Line 6 Spider V 30 MkII','30-watt modeling combo with 200-plus amp and effect models',false,100,'active','combo','digital',30,1,'high',array['rock','metal','hard_rock','classic_rock']::equipment_genre[],array['high_gain','crunch','scooped','aggressive','balanced']::equipment_tone_characteristic[],array['line 6','spider','spider v','30','spider v 30 mkii']::text[]),
('guitar_amp','Line 6','Spider V 60 MkII',null,'Line 6 Spider V 60 MkII','60-watt 1x10 modeling combo with wireless-ready design',false,100,'active','combo','digital',60,1,'high',array['rock','metal','hard_rock','classic_rock']::equipment_genre[],array['high_gain','crunch','scooped','aggressive','balanced']::equipment_tone_characteristic[],array['line 6','spider','spider v','60','spider v 60 mkii']::text[]),
('guitar_amp','Line 6','Spider V 120 MkII',null,'Line 6 Spider V 120 MkII','120-watt modeling combo for gigging players',false,100,'active','combo','digital',120,1,'high',array['rock','metal','hard_rock','classic_rock']::equipment_genre[],array['high_gain','crunch','scooped','aggressive','balanced']::equipment_tone_characteristic[],array['line 6','spider','spider v','120','spider v 120 mkii']::text[]),
('guitar_amp','Line 6','Spider V 240 MkII',null,'Line 6 Spider V 240 MkII','240-watt 2x12 modeling combo with wireless and foot control',false,100,'active','combo','digital',240,1,'high',array['rock','metal','hard_rock','classic_rock']::equipment_genre[],array['high_gain','crunch','scooped','aggressive','balanced']::equipment_tone_characteristic[],array['line 6','spider','spider v','240','spider v 240 mkii']::text[]),
('guitar_amp','Line 6','Spider V 20',null,'Line 6 Spider V 20','20-watt 1x8 modeling combo, original Spider V generation',false,100,'active','combo','digital',20,1,'high',array['rock','metal','hard_rock','classic_rock']::equipment_genre[],array['high_gain','crunch','scooped','aggressive','balanced']::equipment_tone_characteristic[],array['line 6','spider','spider v','20','spider v 20']::text[]),
('guitar_amp','Line 6','Spider V 60',null,'Line 6 Spider V 60','60-watt 1x10 modeling combo, original Spider V generation',false,100,'active','combo','digital',60,1,'high',array['rock','metal','hard_rock','classic_rock']::equipment_genre[],array['high_gain','crunch','scooped','aggressive','balanced']::equipment_tone_characteristic[],array['line 6','spider','spider v','60','spider v 60']::text[]),
('guitar_amp','Line 6','Catalyst 60',null,'Line 6 Catalyst 60','60-watt 1x12 combo with six original Helix amp voicings',false,100,'active','combo','digital',60,2,'high',array['rock','metal','hard_rock','blues','classic_rock']::equipment_genre[],array['high_gain','crunch','articulate','balanced','dynamic']::equipment_tone_characteristic[],array['line 6','catalyst','catalyst 60','60','catalyst 60']::text[]),
('guitar_amp','Line 6','Catalyst 100',null,'Line 6 Catalyst 100','100-watt 1x12 dual-channel combo with Helix amp voicings',false,100,'active','combo','digital',100,2,'high',array['rock','metal','hard_rock','blues','classic_rock']::equipment_genre[],array['high_gain','crunch','articulate','balanced','dynamic']::equipment_tone_characteristic[],array['line 6','catalyst','catalyst 100','100','catalyst 100']::text[]),
('guitar_amp','Line 6','Catalyst 200',null,'Line 6 Catalyst 200','200-watt 2x12 dual-channel combo with Helix amp voicings',false,100,'active','combo','digital',200,2,'high',array['rock','metal','hard_rock','blues','classic_rock']::equipment_genre[],array['high_gain','crunch','articulate','balanced','dynamic']::equipment_tone_characteristic[],array['line 6','catalyst','catalyst 200','200','catalyst 200']::text[]),
('guitar_amp','Line 6','Catalyst CX 60',null,'Line 6 Catalyst CX 60','60-watt 1x12 combo with 12 Helix amp voicings and 24 effects',false,100,'active','combo','digital',60,2,'high',array['rock','metal','hard_rock','blues','classic_rock']::equipment_genre[],array['high_gain','crunch','articulate','balanced','dynamic']::equipment_tone_characteristic[],array['line 6','catalyst','catalyst cx','cx 60','catalyst cx 60']::text[]),
('guitar_amp','Line 6','Catalyst CX 100',null,'Line 6 Catalyst CX 100','100-watt 1x12 combo with 12 Helix amp voicings and 24 effects',false,100,'active','combo','digital',100,2,'high',array['rock','metal','hard_rock','blues','classic_rock']::equipment_genre[],array['high_gain','crunch','articulate','balanced','dynamic']::equipment_tone_characteristic[],array['line 6','catalyst','catalyst cx','cx 100','catalyst cx 100']::text[]),
('guitar_amp','Line 6','Catalyst CX 200',null,'Line 6 Catalyst CX 200','200-watt 2x12 combo with 12 Helix amp voicings and 24 effects',false,100,'active','combo','digital',200,2,'high',array['rock','metal','hard_rock','blues','classic_rock']::equipment_genre[],array['high_gain','crunch','articulate','balanced','dynamic']::equipment_tone_characteristic[],array['line 6','catalyst','catalyst cx','cx 200','catalyst cx 200']::text[]),
('guitar_amp','Line 6','Spider Classic 15',null,'Line 6 Spider Classic 15','15-watt 1x8 modeling practice combo with app control',false,100,'active','combo','digital',15,1,'high',array['rock','metal','hard_rock','classic_rock']::equipment_genre[],array['high_gain','crunch','scooped','balanced']::equipment_tone_characteristic[],array['line 6','spider','spider classic','15','spider classic 15']::text[]),
-- Cluster A2: Fender + Marshall + Orange beginner/practice amps
-- guitar_amp rows

-- ===== FENDER =====
('guitar_amp','Fender','Frontman 10G','Frontman','Fender Frontman 10G','10-watt solid-state practice combo with clean and drive channels',false,100,'active','combo','solid_state',10,2,'medium',array['rock','classic_rock','blues','pop']::equipment_genre[],array['clean','crunch','bright','balanced']::equipment_tone_characteristic[],array['fender','frontman','10g','frontman 10g','frontman 10']::text[]),
('guitar_amp','Fender','Frontman 20G','Frontman','Fender Frontman 20G','20-watt solid-state practice combo with two channels and overdrive',false,100,'active','combo','solid_state',20,2,'medium',array['rock','classic_rock','blues','pop']::equipment_genre[],array['clean','crunch','bright','balanced']::equipment_tone_characteristic[],array['fender','frontman','20g','frontman 20g','frontman 20']::text[]),
('guitar_amp','Fender','Champion 20','Champion','Fender Champion 20','20-watt solid-state combo with voicing knob and onboard effects',false,100,'active','combo','solid_state',20,1,'high',array['rock','classic_rock','blues','country','pop']::equipment_genre[],array['clean','crunch','balanced','dynamic']::equipment_tone_characteristic[],array['fender','champion','20','champion 20']::text[]),
('guitar_amp','Fender','Champion 40','Champion','Fender Champion 40','40-watt solid-state 1x12 combo with amp voicings and effects',false,100,'active','combo','solid_state',40,2,'high',array['rock','classic_rock','blues','country','pop']::equipment_genre[],array['clean','crunch','balanced','dynamic']::equipment_tone_characteristic[],array['fender','champion','40','champion 40']::text[]),
('guitar_amp','Fender','Champion 50XL','Champion','Fender Champion 50XL','50-watt solid-state 1x12 combo with expanded voicings and effects',false,100,'active','combo','solid_state',50,2,'high',array['rock','classic_rock','blues','hard_rock','pop']::equipment_genre[],array['clean','crunch','balanced','dynamic']::equipment_tone_characteristic[],array['fender','champion','50xl','champion 50xl','champion 50']::text[]),
('guitar_amp','Fender','Champion 100','Champion','Fender Champion 100','100-watt solid-state 2x12 combo with dual channels and effects',false,100,'active','combo','solid_state',100,2,'high',array['rock','classic_rock','blues','hard_rock','pop']::equipment_genre[],array['clean','crunch','balanced','dynamic']::equipment_tone_characteristic[],array['fender','champion','100','champion 100']::text[]),
('guitar_amp','Fender','Champion II 25','Champion II','Fender Champion II 25','25-watt solid-state modeling combo with Classic, British and Hi-Gain modes',false,100,'active','combo','solid_state',25,1,'high',array['rock','classic_rock','blues','metal','pop']::equipment_genre[],array['clean','crunch','high_gain','balanced']::equipment_tone_characteristic[],array['fender','champion','ii','champion ii 25','champion 2 25']::text[]),
('guitar_amp','Fender','Champion II 50','Champion II','Fender Champion II 50','50-watt solid-state modeling combo with two channels and onboard effects',false,100,'active','combo','solid_state',50,2,'high',array['rock','classic_rock','blues','metal','pop']::equipment_genre[],array['clean','crunch','high_gain','balanced']::equipment_tone_characteristic[],array['fender','champion','ii','champion ii 50','champion 2 50']::text[]),
('guitar_amp','Fender','Champion II 100','Champion II','Fender Champion II 100','100-watt solid-state modeling combo with dual channels and effects',false,100,'active','combo','solid_state',100,2,'high',array['rock','classic_rock','blues','metal','hard_rock']::equipment_genre[],array['clean','crunch','high_gain','balanced']::equipment_tone_characteristic[],array['fender','champion','ii','champion ii 100','champion 2 100']::text[]),
('guitar_amp','Fender','Mustang LT25','Mustang','Fender Mustang LT25','25-watt digital modeling combo with 30 presets and effects',false,100,'active','combo','digital',25,1,'high',array['rock','metal','classic_rock','blues','hard_rock']::equipment_genre[],array['clean','crunch','high_gain','modern']::equipment_tone_characteristic[],array['fender','mustang','lt25','mustang lt25','mustang lt 25']::text[]),
('guitar_amp','Fender','Mustang LT40S','Mustang','Fender Mustang LT40S','40-watt stereo digital modeling desktop combo with presets and effects',false,100,'active','combo','digital',40,1,'high',array['rock','metal','classic_rock','blues','hard_rock']::equipment_genre[],array['clean','crunch','high_gain','modern']::equipment_tone_characteristic[],array['fender','mustang','lt40s','mustang lt40s','mustang lt 40s']::text[]),
('guitar_amp','Fender','Mustang LT50','Mustang','Fender Mustang LT50','50-watt digital modeling 1x12 combo with 30 presets and effects',false,100,'active','combo','digital',50,1,'high',array['rock','metal','classic_rock','blues','hard_rock']::equipment_genre[],array['clean','crunch','high_gain','modern']::equipment_tone_characteristic[],array['fender','mustang','lt50','mustang lt50','mustang lt 50']::text[]),
('guitar_amp','Fender','Mustang GTX50','Mustang','Fender Mustang GTX50','50-watt digital modeling combo with color display, Wi-Fi and Celestion speaker',false,100,'active','combo','digital',50,1,'high',array['rock','metal','classic_rock','blues','hard_rock']::equipment_genre[],array['clean','crunch','high_gain','modern']::equipment_tone_characteristic[],array['fender','mustang','gtx50','mustang gtx50','mustang gtx 50']::text[]),
('guitar_amp','Fender','Mustang GTX100','Mustang','Fender Mustang GTX100','100-watt digital modeling combo with color display, Wi-Fi and effects',false,100,'active','combo','digital',100,1,'high',array['rock','metal','classic_rock','blues','hard_rock']::equipment_genre[],array['clean','crunch','high_gain','modern']::equipment_tone_characteristic[],array['fender','mustang','gtx100','mustang gtx100','mustang gtx 100']::text[]),
('guitar_amp','Fender','Mustang GT40','Mustang','Fender Mustang GT40','40-watt digital modeling stereo combo with Bluetooth and Wi-Fi',false,100,'active','combo','digital',40,1,'high',array['rock','metal','classic_rock','blues','hard_rock']::equipment_genre[],array['clean','crunch','high_gain','modern']::equipment_tone_characteristic[],array['fender','mustang','gt40','mustang gt40','mustang gt 40']::text[]),
('guitar_amp','Fender','Mustang GT100','Mustang','Fender Mustang GT100','100-watt digital modeling 1x12 combo with Bluetooth and Wi-Fi',false,100,'active','combo','digital',100,1,'high',array['rock','metal','classic_rock','blues','hard_rock']::equipment_genre[],array['clean','crunch','high_gain','modern']::equipment_tone_characteristic[],array['fender','mustang','gt100','mustang gt100','mustang gt 100']::text[]),
('guitar_amp','Fender','Mustang GT200','Mustang','Fender Mustang GT200','200-watt digital modeling 2x12 stereo combo with Bluetooth and Wi-Fi',false,100,'active','combo','digital',200,1,'high',array['rock','metal','classic_rock','blues','hard_rock']::equipment_genre[],array['clean','crunch','high_gain','modern']::equipment_tone_characteristic[],array['fender','mustang','gt200','mustang gt200','mustang gt 200']::text[]),
('guitar_amp','Fender','Mustang Micro','Mustang','Fender Mustang Micro','Plug-in headphone modeling amp with 12 amp voices and effects',false,100,'active','combo','digital',1,1,'high',array['rock','metal','classic_rock','blues','hard_rock']::equipment_genre[],array['clean','crunch','high_gain','modern']::equipment_tone_characteristic[],array['fender','mustang','micro','mustang micro']::text[]),
('guitar_amp','Fender','Mustang Micro Plus','Mustang','Fender Mustang Micro Plus','Plug-in headphone modeling amp with color screen, Bluetooth and effects',false,100,'active','combo','digital',1,1,'high',array['rock','metal','classic_rock','blues','hard_rock']::equipment_genre[],array['clean','crunch','high_gain','modern']::equipment_tone_characteristic[],array['fender','mustang','micro','plus','mustang micro plus']::text[]),
('guitar_amp','Fender','Frontman 212R','Frontman','Fender Frontman 212R','100-watt solid-state 2x12 combo with clean and drive channels and reverb',false,100,'active','combo','solid_state',100,2,'medium',array['rock','classic_rock','blues','country','pop']::equipment_genre[],array['clean','crunch','bright','balanced']::equipment_tone_characteristic[],array['fender','frontman','212r','frontman 212r','frontman 212']::text[]),
('guitar_amp','Fender','Super Champ X2','Champ','Fender Super Champ X2','15-watt tube combo with voicing and onboard digital effects',false,100,'active','combo','tube',15,2,'medium',array['rock','classic_rock','blues','country']::equipment_genre[],array['warm','clean','crunch','dynamic','vintage']::equipment_tone_characteristic[],array['fender','super','champ','x2','super champ x2']::text[]),

-- ===== MARSHALL =====
('guitar_amp','Marshall','MG10G','MG','Marshall MG10G','10-watt solid-state practice combo with clean and overdrive channels',false,100,'active','combo','solid_state',10,1,'high',array['rock','hard_rock','classic_rock','punk']::equipment_genre[],array['crunch','bright','mid_focused','clean']::equipment_tone_characteristic[],array['marshall','mg10g','mg10','mg 10']::text[]),
('guitar_amp','Marshall','MG15GR','MG','Marshall MG15GR','15-watt solid-state combo with clean and overdrive channels and reverb',false,100,'active','combo','solid_state',15,2,'high',array['rock','hard_rock','classic_rock','punk']::equipment_genre[],array['crunch','bright','mid_focused','clean']::equipment_tone_characteristic[],array['marshall','mg15gr','mg15','mg 15']::text[]),
('guitar_amp','Marshall','MG15GFX','MG','Marshall MG15GFX','15-watt solid-state combo with four channels and onboard effects',false,100,'active','combo','solid_state',15,4,'high',array['rock','hard_rock','classic_rock','metal']::equipment_genre[],array['crunch','bright','mid_focused','high_gain']::equipment_tone_characteristic[],array['marshall','mg15gfx','mg15','mg 15 fx']::text[]),
('guitar_amp','Marshall','MG15CFX','MG','Marshall MG15CFX','15-watt solid-state carbon fiber combo with four channels and effects',false,100,'active','combo','solid_state',15,4,'high',array['rock','hard_rock','classic_rock','metal']::equipment_genre[],array['crunch','bright','mid_focused','high_gain']::equipment_tone_characteristic[],array['marshall','mg15cfx','mg15','carbon fiber']::text[]),
('guitar_amp','Marshall','MG15CFR','MG','Marshall MG15CFR','15-watt solid-state carbon fiber combo with two channels and reverb',false,100,'active','combo','solid_state',15,2,'high',array['rock','hard_rock','classic_rock','punk']::equipment_genre[],array['crunch','bright','mid_focused','clean']::equipment_tone_characteristic[],array['marshall','mg15cfr','mg15','carbon fiber']::text[]),
('guitar_amp','Marshall','MG30GFX','MG','Marshall MG30GFX','30-watt solid-state combo with four channels and digital effects',false,100,'active','combo','solid_state',30,4,'high',array['rock','hard_rock','classic_rock','metal']::equipment_genre[],array['crunch','bright','mid_focused','high_gain']::equipment_tone_characteristic[],array['marshall','mg30gfx','mg30','mg 30']::text[]),
('guitar_amp','Marshall','MG50GFX','MG','Marshall MG50GFX','50-watt solid-state 1x12 combo with four channels and digital effects',false,100,'active','combo','solid_state',50,4,'high',array['rock','hard_rock','classic_rock','metal']::equipment_genre[],array['crunch','bright','mid_focused','high_gain']::equipment_tone_characteristic[],array['marshall','mg50gfx','mg50','mg 50']::text[]),
('guitar_amp','Marshall','MG100HGFX','MG','Marshall MG100HGFX','100-watt solid-state head with four channels and digital effects',false,100,'active','head','solid_state',100,4,'high',array['rock','hard_rock','classic_rock','metal']::equipment_genre[],array['crunch','bright','mid_focused','high_gain']::equipment_tone_characteristic[],array['marshall','mg100hgfx','mg100','mg 100 head']::text[]),
('guitar_amp','Marshall','Code 25','Code','Marshall Code 25','25-watt digital modeling combo with 100 presets and Bluetooth',false,100,'active','combo','digital',25,1,'high',array['rock','hard_rock','classic_rock','metal','blues']::equipment_genre[],array['modern','crunch','high_gain','clean']::equipment_tone_characteristic[],array['marshall','code','25','code 25']::text[]),
('guitar_amp','Marshall','Code 50','Code','Marshall Code 50','50-watt digital modeling 1x12 combo with 100 presets and Bluetooth',false,100,'active','combo','digital',50,1,'high',array['rock','hard_rock','classic_rock','metal','blues']::equipment_genre[],array['modern','crunch','high_gain','clean']::equipment_tone_characteristic[],array['marshall','code','50','code 50']::text[]),
('guitar_amp','Marshall','Code 100','Code','Marshall Code 100','100-watt digital modeling 2x12 combo with 100 presets and Bluetooth',false,100,'active','combo','digital',100,1,'high',array['rock','hard_rock','classic_rock','metal','blues']::equipment_genre[],array['modern','crunch','high_gain','clean']::equipment_tone_characteristic[],array['marshall','code','100','code 100']::text[]),
('guitar_amp','Marshall','DSL1CR','DSL','Marshall DSL1CR','1-watt all-tube combo with Classic Gain and Ultra Gain channels and reverb',false,100,'active','combo','tube',1,2,'high',array['rock','hard_rock','classic_rock','metal','blues']::equipment_genre[],array['crunch','warm','mid_focused','high_gain']::equipment_tone_characteristic[],array['marshall','dsl1cr','dsl1','dsl 1']::text[]),
('guitar_amp','Marshall','DSL5CR','DSL','Marshall DSL5CR','5-watt all-tube combo with Classic Gain and Ultra Gain channels and reverb',false,100,'active','combo','tube',5,2,'high',array['rock','hard_rock','classic_rock','metal','blues']::equipment_genre[],array['crunch','warm','mid_focused','high_gain']::equipment_tone_characteristic[],array['marshall','dsl5cr','dsl5','dsl 5']::text[]),
('guitar_amp','Marshall','DSL20CR','DSL','Marshall DSL20CR','20-watt all-tube 1x12 combo with two channels, reverb and power scaling',false,100,'active','combo','tube',20,2,'high',array['rock','hard_rock','classic_rock','metal','blues']::equipment_genre[],array['crunch','warm','mid_focused','high_gain']::equipment_tone_characteristic[],array['marshall','dsl20cr','dsl20','dsl 20']::text[]),
('guitar_amp','Marshall','DSL40CR','DSL','Marshall DSL40CR','40-watt all-tube 1x12 combo with two channels, reverb and Celestion speaker',false,100,'active','combo','tube',40,2,'high',array['rock','hard_rock','classic_rock','metal','blues']::equipment_genre[],array['crunch','warm','mid_focused','high_gain']::equipment_tone_characteristic[],array['marshall','dsl40cr','dsl40','dsl 40']::text[]),
('guitar_amp','Marshall','Origin 5','Origin','Marshall Origin 5','5-watt single-channel tube combo with vintage Marshall voicing and gain boost',false,100,'active','combo','tube',5,1,'medium',array['classic_rock','rock','blues','hard_rock']::equipment_genre[],array['vintage','crunchy','dynamic','warm','mid_focused']::equipment_tone_characteristic[],array['marshall','origin','5','origin 5','origin5c']::text[]),
('guitar_amp','Marshall','Origin 20','Origin','Marshall Origin 20','20-watt single-channel tube combo with vintage voicing and power scaling',false,100,'active','combo','tube',20,1,'medium',array['classic_rock','rock','blues','hard_rock']::equipment_genre[],array['vintage','crunchy','dynamic','warm','mid_focused']::equipment_tone_characteristic[],array['marshall','origin','20','origin 20','origin20c']::text[]),
('guitar_amp','Marshall','Origin 50','Origin','Marshall Origin 50','50-watt single-channel tube 1x12 combo with vintage voicing and gain boost',false,100,'active','combo','tube',50,1,'medium',array['classic_rock','rock','blues','hard_rock']::equipment_genre[],array['vintage','crunchy','dynamic','warm','mid_focused']::equipment_tone_characteristic[],array['marshall','origin','50','origin 50','origin50c']::text[]),

-- ===== ORANGE =====
('guitar_amp','Orange','Crush Mini','Crush','Orange Crush Mini','3-watt portable analog practice combo with tuner and headphone out',false,100,'active','combo','solid_state',3,1,'medium',array['rock','hard_rock','classic_rock','punk','indie']::equipment_genre[],array['crunchy','mid_focused','warm','dynamic']::equipment_tone_characteristic[],array['orange','crush','mini','crush mini']::text[]),
('guitar_amp','Orange','Micro Crush','Crush','Orange Micro Crush','3-watt 9-volt mini combo with clean and overdrive and built-in tuner',false,100,'active','combo','solid_state',3,1,'medium',array['rock','hard_rock','classic_rock','punk','indie']::equipment_genre[],array['crunchy','mid_focused','warm','dynamic']::equipment_tone_characteristic[],array['orange','micro','crush','micro crush']::text[]),
('guitar_amp','Orange','Crush 12','Crush','Orange Crush 12','12-watt all-analog practice combo with classic Orange voicing',false,100,'active','combo','solid_state',12,1,'medium',array['rock','hard_rock','classic_rock','punk','indie']::equipment_genre[],array['crunchy','mid_focused','warm','dynamic']::equipment_tone_characteristic[],array['orange','crush','12','crush 12']::text[]),
('guitar_amp','Orange','Crush 20','Crush','Orange Crush 20','20-watt twin-channel analog combo with footswitchable clean and dirty channels',false,100,'active','combo','solid_state',20,2,'high',array['rock','hard_rock','classic_rock','punk','indie']::equipment_genre[],array['crunchy','mid_focused','warm','dynamic']::equipment_tone_characteristic[],array['orange','crush','20','crush 20']::text[]),
('guitar_amp','Orange','Crush 20RT','Crush','Orange Crush 20RT','20-watt twin-channel analog combo with reverb and chromatic tuner',false,100,'active','combo','solid_state',20,2,'high',array['rock','hard_rock','classic_rock','punk','indie']::equipment_genre[],array['crunchy','mid_focused','warm','dynamic']::equipment_tone_characteristic[],array['orange','crush','20rt','crush 20rt']::text[]),
('guitar_amp','Orange','Crush 35RT','Crush','Orange Crush 35RT','35-watt twin-channel analog 1x10 combo with reverb and tuner',false,100,'active','combo','solid_state',35,2,'high',array['rock','hard_rock','classic_rock','punk','metal']::equipment_genre[],array['crunchy','mid_focused','warm','dynamic']::equipment_tone_characteristic[],array['orange','crush','35rt','crush 35rt']::text[]),
('guitar_amp','Orange','Crush Pro 60','Crush Pro','Orange Crush Pro 60','60-watt two-channel 1x12 combo with high-gain preamp and CabSim out',false,100,'active','combo','solid_state',60,2,'high',array['rock','hard_rock','classic_rock','metal','punk']::equipment_genre[],array['crunchy','mid_focused','warm','high_gain','aggressive']::equipment_tone_characteristic[],array['orange','crush','pro','60','crush pro 60']::text[]),
('guitar_amp','Orange','Crush Pro 120','Crush Pro','Orange Crush Pro 120','120-watt two-channel 2x12 combo with high-gain preamp and CabSim out',false,100,'active','combo','solid_state',120,2,'high',array['rock','hard_rock','classic_rock','metal','punk']::equipment_genre[],array['crunchy','mid_focused','warm','high_gain','aggressive']::equipment_tone_characteristic[],array['orange','crush','pro','120','crush pro 120']::text[]),
-- Cluster A3 — Blackstar + Vox + budget modeling brands (guitar amps)
-- AMP row column order per catalog-spec.md
('guitar_amp','Blackstar','Debut 15E','Debut','Blackstar Debut 15E','15W analogue combo with ISF tone shaping and voice switch',false,100,'active','combo','solid_state',15,2,'medium',array['rock','blues','classic_rock']::equipment_genre[],array['warm','crunch','vintage']::equipment_tone_characteristic[],array['blackstar','debut','15e','debut 15e']::text[]),
('guitar_amp','Blackstar','Debut 50R','Debut','Blackstar Debut 50R','50W analogue combo with reverb, ISF and 12" speaker',false,100,'active','combo','solid_state',50,2,'high',array['rock','blues','classic_rock','hard_rock']::equipment_genre[],array['warm','crunch','balanced']::equipment_tone_characteristic[],array['blackstar','debut','50r','debut 50r','reverb']::text[]),
('guitar_amp','Blackstar','Fly 3','Fly','Blackstar Fly 3','3W portable mini combo with clean and overdrive channels',false,100,'active','combo','solid_state',3,2,'medium',array['rock','blues','pop']::equipment_genre[],array['warm','crunch','balanced']::equipment_tone_characteristic[],array['blackstar','fly','fly 3','mini']::text[]),
('guitar_amp','Blackstar','Fly 3 Bluetooth','Fly','Blackstar Fly 3 Bluetooth','3W mini combo with Bluetooth streaming and MP3 line-in',false,100,'active','combo','solid_state',3,2,'medium',array['rock','blues','pop']::equipment_genre[],array['warm','crunch','balanced']::equipment_tone_characteristic[],array['blackstar','fly','fly 3','bluetooth','mini']::text[]),
('guitar_amp','Blackstar','ID Core 10 V4','ID Core','Blackstar ID Core 10 V4','10W stereo digital modeling combo with six voices',false,100,'active','combo','digital',10,2,'high',array['rock','metal','blues','pop']::equipment_genre[],array['modern','crunchy','high_gain','clean']::equipment_tone_characteristic[],array['blackstar','id core','id core 10','v4','modeling']::text[]),
('guitar_amp','Blackstar','ID Core 20 V4','ID Core','Blackstar ID Core 20 V4','20W stereo digital modeling combo with effects',false,100,'active','combo','digital',20,2,'high',array['rock','metal','hard_rock','pop']::equipment_genre[],array['modern','crunchy','high_gain','clean']::equipment_tone_characteristic[],array['blackstar','id core','id core 20','v4','stereo']::text[]),
('guitar_amp','Blackstar','ID Core 40 V4','ID Core','Blackstar ID Core 40 V4','40W stereo digital modeling combo with USB recording',false,100,'active','combo','digital',40,2,'high',array['rock','metal','hard_rock']::equipment_genre[],array['modern','high_gain','clean','balanced']::equipment_tone_characteristic[],array['blackstar','id core','id core 40','v4','stereo']::text[]),
('guitar_amp','Blackstar','Silverline Standard','Silverline','Blackstar Silverline Standard','20W digital modeling combo with TVP power-amp response',false,100,'active','combo','digital',20,2,'extreme',array['rock','metal','hard_rock','blues']::equipment_genre[],array['modern','high_gain','dynamic','clean']::equipment_tone_characteristic[],array['blackstar','silverline','standard','modeling']::text[]),
('guitar_amp','Blackstar','Silverline Special','Silverline','Blackstar Silverline Special','50W digital modeling combo with SHARC processor',false,100,'active','combo','digital',50,2,'extreme',array['rock','metal','hard_rock']::equipment_genre[],array['modern','high_gain','dynamic']::equipment_tone_characteristic[],array['blackstar','silverline','special','modeling']::text[]),
('guitar_amp','Blackstar','Silverline Deluxe','Silverline','Blackstar Silverline Deluxe','100W digital modeling combo with six voices and TVP',false,100,'active','combo','digital',100,2,'extreme',array['rock','metal','hard_rock','progressive']::equipment_genre[],array['modern','high_gain','dynamic','articulate']::equipment_tone_characteristic[],array['blackstar','silverline','deluxe','modeling']::text[]),
('guitar_amp','Blackstar','HT-1R','HT','Blackstar HT-1R','1W all-valve combo with reverb and speaker-emulated out',false,100,'active','combo','tube',1,2,'high',array['rock','blues','classic_rock']::equipment_genre[],array['warm','crunch','vintage','dynamic']::equipment_tone_characteristic[],array['blackstar','ht-1r','ht1r','tube','reverb']::text[]),
('guitar_amp','Blackstar','HT-5R MkII','HT','Blackstar HT-5R MkII','5W all-valve combo with reverb and two channels',false,100,'active','combo','tube',5,2,'high',array['rock','blues','hard_rock','classic_rock']::equipment_genre[],array['warm','crunch','vintage','dynamic']::equipment_tone_characteristic[],array['blackstar','ht-5r','mkii','tube','reverb']::text[]),
('guitar_amp','Blackstar','HT-20R MkII','HT','Blackstar HT-20R MkII','20W all-valve combo with reverb and EL34 power section',false,100,'active','combo','tube',20,2,'high',array['rock','hard_rock','blues','metal']::equipment_genre[],array['warm','crunchy','vintage','dynamic']::equipment_tone_characteristic[],array['blackstar','ht-20r','mkii','tube','reverb']::text[]),
('guitar_amp','Blackstar','Super Fly','Fly','Blackstar Super Fly','12W battery portable combo with Bluetooth and dual speakers',false,100,'active','combo','solid_state',12,2,'medium',array['rock','blues','pop']::equipment_genre[],array['warm','crunch','balanced']::equipment_tone_characteristic[],array['blackstar','super fly','superfly','bluetooth','portable']::text[]),
('guitar_amp','Blackstar','Amped 1','Amped','Blackstar Amped 1','100W compact modeling pedal-amp head with three voices',false,100,'active','head','digital',100,3,'extreme',array['rock','metal','hard_rock','progressive']::equipment_genre[],array['modern','high_gain','tight','articulate']::equipment_tone_characteristic[],array['blackstar','amped','amped 1','pedal amp','head']::text[]),
('guitar_amp','Blackstar','St. James 50','St. James','Blackstar St. James 50','50W lightweight all-valve combo with EL34 tubes and reverb',false,100,'active','combo','tube',50,2,'high',array['rock','hard_rock','classic_rock','blues']::equipment_genre[],array['warm','crunchy','dynamic','vintage']::equipment_tone_characteristic[],array['blackstar','st james','st. james','50','el34','tube']::text[]),
('guitar_amp','Vox','Pathfinder 10','Pathfinder','Vox Pathfinder 10','10W solid-state practice combo with classic Vox voicing',false,100,'active','combo','solid_state',10,2,'medium',array['rock','blues','pop','classic_rock']::equipment_genre[],array['bright','crunch','vintage']::equipment_tone_characteristic[],array['vox','pathfinder','pathfinder 10']::text[]),
('guitar_amp','Vox','Pathfinder 15R','Pathfinder','Vox Pathfinder 15R','15W solid-state combo with spring-style reverb',false,100,'active','combo','solid_state',15,2,'medium',array['rock','blues','pop','classic_rock']::equipment_genre[],array['bright','crunch','vintage']::equipment_tone_characteristic[],array['vox','pathfinder','pathfinder 15r','reverb']::text[]),
('guitar_amp','Vox','VX I','VX','Vox VX I','15W VET modeling combo with 11 amp models',false,100,'active','combo','digital',15,2,'high',array['rock','blues','pop','classic_rock']::equipment_genre[],array['bright','modern','crunchy','clean']::equipment_tone_characteristic[],array['vox','vx i','vx1','modeling']::text[]),
('guitar_amp','Vox','VX II','VX','Vox VX II','30W VET modeling combo with amp and effect models',false,100,'active','combo','digital',30,2,'high',array['rock','blues','hard_rock','pop']::equipment_genre[],array['bright','modern','crunchy','clean']::equipment_tone_characteristic[],array['vox','vx ii','vx2','modeling']::text[]),
('guitar_amp','Vox','VX50 GTV','VX','Vox VX50 GTV','50W Nutube-powered modeling combo with 11 amp models',false,100,'active','combo','digital',50,2,'high',array['rock','blues','hard_rock']::equipment_genre[],array['bright','modern','crunchy','clean']::equipment_tone_characteristic[],array['vox','vx50','gtv','nutube','modeling']::text[]),
('guitar_amp','Vox','Mini Go 3','Mini Go','Vox Mini Go 3','3W portable modeling combo with nine amp voices',false,100,'active','combo','digital',3,2,'high',array['rock','blues','pop']::equipment_genre[],array['bright','modern','clean','crunchy']::equipment_tone_characteristic[],array['vox','mini go','mini go 3','portable']::text[]),
('guitar_amp','Vox','Mini Go 10','Mini Go','Vox Mini Go 10','10W portable modeling combo with looper and effects',false,100,'active','combo','digital',10,2,'high',array['rock','blues','pop']::equipment_genre[],array['bright','modern','clean','crunchy']::equipment_tone_characteristic[],array['vox','mini go','mini go 10','portable']::text[]),
('guitar_amp','Vox','Mini Go 50','Mini Go','Vox Mini Go 50','50W portable modeling combo with mic and aux inputs',false,100,'active','combo','digital',50,2,'high',array['rock','blues','hard_rock','pop']::equipment_genre[],array['bright','modern','clean','crunchy']::equipment_tone_characteristic[],array['vox','mini go','mini go 50','portable']::text[]),
('guitar_amp','Vox','Adio Air GT','Adio','Vox Adio Air GT','50W Bluetooth modeling combo with BluGuitar tones',false,100,'active','combo','digital',50,2,'high',array['rock','blues','pop','funk']::equipment_genre[],array['bright','modern','clean','balanced']::equipment_tone_characteristic[],array['vox','adio','adio air','gt','bluetooth']::text[]),
('guitar_amp','Vox','Valvetronix VT20X','Valvetronix','Vox Valvetronix VT20X','20W Valvetronix modeling combo with 11 amp models',false,100,'active','combo','digital',20,2,'high',array['rock','blues','hard_rock','metal']::equipment_genre[],array['bright','modern','crunchy','high_gain']::equipment_tone_characteristic[],array['vox','valvetronix','vt20x','modeling']::text[]),
('guitar_amp','Vox','Valvetronix VT40X','Valvetronix','Vox Valvetronix VT40X','40W Valvetronix modeling combo with 12AX7 preamp',false,100,'active','combo','digital',40,2,'high',array['rock','blues','hard_rock','metal']::equipment_genre[],array['bright','modern','crunchy','high_gain']::equipment_tone_characteristic[],array['vox','valvetronix','vt40x','modeling']::text[]),
('guitar_amp','Vox','Valvetronix VT100X','Valvetronix','Vox Valvetronix VT100X','100W Valvetronix modeling combo for stage use',false,100,'active','combo','digital',100,2,'extreme',array['rock','hard_rock','metal','blues']::equipment_genre[],array['bright','modern','high_gain','dynamic']::equipment_tone_characteristic[],array['vox','valvetronix','vt100x','modeling']::text[]),
('guitar_amp','Vox','AC4C1','Custom','Vox AC4C1','4W Class A all-valve combo with EL84 power tube',false,100,'active','combo','tube',4,1,'medium',array['rock','blues','classic_rock','pop']::equipment_genre[],array['bright','warm','vintage','crunch']::equipment_tone_characteristic[],array['vox','ac4c1','ac4','custom','tube']::text[]),
('guitar_amp','Vox','AC10C1','Custom','Vox AC10C1','10W Class A all-valve combo with reverb and Celestion speaker',false,100,'active','combo','tube',10,1,'medium',array['rock','blues','classic_rock','pop']::equipment_genre[],array['bright','warm','vintage','crunch']::equipment_tone_characteristic[],array['vox','ac10c1','ac10','custom','tube']::text[]),
('guitar_amp','Vox','AC15C1','Custom','Vox AC15C1','15W Class A all-valve combo with Top Boost and reverb',false,100,'active','combo','tube',15,2,'high',array['rock','blues','classic_rock','indie']::equipment_genre[],array['bright','warm','vintage','crunchy']::equipment_tone_characteristic[],array['vox','ac15c1','ac15','custom','tube']::text[]),
('guitar_amp','Vox','AC30C2','Custom','Vox AC30C2','30W Class A all-valve combo with Top Boost and twin Celestions',false,100,'active','combo','tube',30,2,'high',array['rock','blues','classic_rock','pop']::equipment_genre[],array['bright','warm','vintage','crunchy']::equipment_tone_characteristic[],array['vox','ac30c2','ac30','custom','tube']::text[]),
('guitar_amp','Vox','MV50 AC','MV50','Vox MV50 AC','50W Nutube micro head voiced for classic AC30 chime',false,100,'active','head','hybrid',50,1,'high',array['rock','blues','classic_rock']::equipment_genre[],array['bright','warm','vintage','crunchy']::equipment_tone_characteristic[],array['vox','mv50','mv50 ac','nutube','head']::text[]),
('guitar_amp','Vox','MV50 Clean','MV50','Vox MV50 Clean','50W Nutube micro head with clean headroom',false,100,'active','head','hybrid',50,1,'medium',array['rock','blues','jazz','pop']::equipment_genre[],array['bright','clean','clean_headroom','balanced']::equipment_tone_characteristic[],array['vox','mv50','mv50 clean','nutube','head']::text[]),
('guitar_amp','Vox','MV50 Rock','MV50','Vox MV50 Rock','50W Nutube micro head with high-gain rock voicing',false,100,'active','head','hybrid',50,1,'extreme',array['rock','hard_rock','metal']::equipment_genre[],array['aggressive','crunchy','high_gain','tight']::equipment_tone_characteristic[],array['vox','mv50','mv50 rock','nutube','head']::text[]),
('guitar_amp','Vox','MV50 Boutique','MV50','Vox MV50 Boutique','50W Nutube micro head with boutique-style overdrive',false,100,'active','head','hybrid',50,1,'high',array['rock','blues','fusion']::equipment_genre[],array['warm','smooth','dynamic','articulate']::equipment_tone_characteristic[],array['vox','mv50','mv50 boutique','nutube','head']::text[]),
('guitar_amp','NUX','Mighty 8','Mighty','NUX Mighty 8','8W digital modeling practice combo with three voices',false,100,'active','combo','digital',8,2,'high',array['rock','metal','blues','pop']::equipment_genre[],array['modern','crunchy','high_gain','clean']::equipment_tone_characteristic[],array['nux','mighty','mighty 8','practice']::text[]),
('guitar_amp','NUX','Mighty 20','Mighty','NUX Mighty 20','20W Bluetooth modeling combo with amp models and effects',false,100,'active','combo','digital',20,2,'high',array['rock','metal','blues','pop']::equipment_genre[],array['modern','crunchy','high_gain','clean']::equipment_tone_characteristic[],array['nux','mighty','mighty 20','bt','bluetooth']::text[]),
('guitar_amp','NUX','Mighty 30','Mighty','NUX Mighty 30','30W modeling combo with multiple amp voices and effects',false,100,'active','combo','digital',30,2,'high',array['rock','metal','hard_rock','blues']::equipment_genre[],array['modern','high_gain','clean','balanced']::equipment_tone_characteristic[],array['nux','mighty','mighty 30','modeling']::text[]),
('guitar_amp','NUX','Mighty 40','Mighty','NUX Mighty 40','40W Bluetooth modeling combo with app control',false,100,'active','combo','digital',40,2,'high',array['rock','metal','hard_rock','blues']::equipment_genre[],array['modern','high_gain','clean','balanced']::equipment_tone_characteristic[],array['nux','mighty','mighty 40','bt','bluetooth']::text[]),
('guitar_amp','NUX','Mighty 50','Mighty','NUX Mighty 50','50W modeling combo with IR cabinets and Bluetooth',false,100,'active','combo','digital',50,2,'extreme',array['rock','metal','hard_rock']::equipment_genre[],array['modern','high_gain','tight','clean']::equipment_tone_characteristic[],array['nux','mighty','mighty 50','bt','modeling']::text[]),
('guitar_amp','NUX','Mighty Lite','Mighty','NUX Mighty Lite','3W desktop modeling combo with Bluetooth and drum machine',false,100,'active','combo','digital',3,2,'high',array['rock','metal','pop','blues']::equipment_genre[],array['modern','clean','crunchy','balanced']::equipment_tone_characteristic[],array['nux','mighty','mighty lite','bt','portable']::text[]),
('guitar_amp','NUX','Mighty Space','Mighty','NUX Mighty Space','30W stereo modeling combo with IR loader and wireless',false,100,'active','combo','digital',30,2,'high',array['rock','metal','blues','pop']::equipment_genre[],array['modern','clean','high_gain','balanced']::equipment_tone_characteristic[],array['nux','mighty','mighty space','ir','bluetooth']::text[]),
('guitar_amp','Mooer','Hornet 30','Hornet','Mooer Hornet 30','30W digital modeling combo with nine amp models',false,100,'active','combo','digital',30,2,'high',array['rock','metal','blues','pop']::equipment_genre[],array['modern','crunchy','high_gain','clean']::equipment_tone_characteristic[],array['mooer','hornet','hornet 30','modeling']::text[]),
('guitar_amp','Mooer','SD30','SD','Mooer SD30','30W modeling combo with 25 preamp models and effects',false,100,'active','combo','digital',30,2,'high',array['rock','metal','hard_rock','blues']::equipment_genre[],array['modern','high_gain','clean','balanced']::equipment_tone_characteristic[],array['mooer','sd30','sd 30','modeling']::text[]),
('guitar_amp','Valeton','Rushead Max','Rushead','Valeton Rushead Max','Pocket modeling headphone amp with three voices and effects',false,100,'active','combo','solid_state',3,2,'high',array['rock','metal','blues']::equipment_genre[],array['modern','crunchy','high_gain']::equipment_tone_characteristic[],array['valeton','rushead','rushead max','headphone','portable']::text[]),
('guitar_amp','Harley Benton','TUBE5','TUBE','Harley Benton TUBE5','5W/1W all-valve head with 6V6 power tube',false,100,'active','head','tube',5,1,'high',array['rock','blues','hard_rock','classic_rock']::equipment_genre[],array['warm','crunch','vintage','dynamic']::equipment_tone_characteristic[],array['harley benton','tube5','tube 5','head','tube']::text[]),
('guitar_amp','Harley Benton','TUBE15','TUBE','Harley Benton TUBE15','15W/1W all-valve combo with EL84 tubes and reverb',false,100,'active','combo','tube',15,1,'high',array['rock','blues','hard_rock','classic_rock']::equipment_genre[],array['warm','crunchy','vintage','dynamic']::equipment_tone_characteristic[],array['harley benton','tube15','tube 15','celestion','reverb']::text[]),
('guitar_amp','Harley Benton','HB-40R','HB','Harley Benton HB-40R','40W solid-state combo with tube-emulating circuit and reverb',false,100,'active','combo','solid_state',40,2,'high',array['rock','blues','hard_rock','metal']::equipment_genre[],array['warm','crunch','balanced','clean']::equipment_tone_characteristic[],array['harley benton','hb-40r','hb40r','reverb']::text[]),
('guitar_amp','Peavey','Vypyr X1','Vypyr','Peavey Vypyr X1','20W modeling combo with TransTube tone and effects',false,100,'active','combo','digital',20,2,'extreme',array['rock','metal','hard_rock','blues']::equipment_genre[],array['modern','high_gain','tight','clean']::equipment_tone_characteristic[],array['peavey','vypyr','vypyr x1','x1','modeling']::text[]),
('guitar_amp','Peavey','Vypyr X2','Vypyr','Peavey Vypyr X2','40W modeling combo with Bluetooth app control',false,100,'active','combo','digital',40,2,'extreme',array['rock','metal','hard_rock','progressive']::equipment_genre[],array['modern','high_gain','tight','clean']::equipment_tone_characteristic[],array['peavey','vypyr','vypyr x2','x2','bluetooth']::text[]),
('guitar_amp','Peavey','Vypyr X3','Vypyr','Peavey Vypyr X3','100W modeling combo with 12" speaker and amp models',false,100,'active','combo','digital',100,2,'extreme',array['rock','metal','hard_rock','progressive']::equipment_genre[],array['modern','high_gain','tight','articulate']::equipment_tone_characteristic[],array['peavey','vypyr','vypyr x3','x3','modeling']::text[]),
('guitar_amp','Peavey','Vypyr Tube 60','Vypyr','Peavey Vypyr Tube 60','60W tube-powered modeling combo with 6L6 power section',false,100,'active','combo','tube',60,2,'extreme',array['rock','metal','hard_rock']::equipment_genre[],array['aggressive','high_gain','tight','dynamic']::equipment_tone_characteristic[],array['peavey','vypyr','vypyr tube 60','tube 60','6l6']::text[]),
('guitar_amp','Peavey','Bandit 112','Bandit','Peavey Bandit 112','80W TransTube solid-state combo with two channels',false,100,'active','combo','solid_state',80,2,'high',array['rock','metal','hard_rock','blues']::equipment_genre[],array['modern','tight','crunchy','clean']::equipment_tone_characteristic[],array['peavey','bandit','bandit 112','transtube']::text[]),
('guitar_amp','Yamaha','THR5','THR','Yamaha THR5','10W desktop modeling combo with five amp voices',false,100,'active','combo','digital',10,2,'high',array['rock','blues','jazz','pop']::equipment_genre[],array['warm','clean','balanced','crunchy']::equipment_tone_characteristic[],array['yamaha','thr','thr5','desktop','practice']::text[]),
('guitar_amp','Yamaha','THR10','THR','Yamaha THR10','10W desktop modeling combo with stereo speakers and effects',false,100,'active','combo','digital',10,2,'high',array['rock','blues','jazz','pop']::equipment_genre[],array['warm','clean','balanced','crunchy']::equipment_tone_characteristic[],array['yamaha','thr','thr10','desktop','practice']::text[]),
('guitar_amp','Yamaha','THR10II','THR','Yamaha THR10II','20W desktop modeling combo with Bluetooth and app editing',false,100,'active','combo','digital',20,2,'high',array['rock','blues','jazz','pop']::equipment_genre[],array['warm','clean','balanced','modern']::equipment_tone_characteristic[],array['yamaha','thr','thr10ii','wireless','bluetooth']::text[]),
('guitar_amp','Yamaha','THR30II','THR','Yamaha THR30II','30W desktop modeling combo with wireless and stereo output',false,100,'active','combo','digital',30,2,'high',array['rock','blues','jazz','fusion']::equipment_genre[],array['warm','clean','balanced','dynamic']::equipment_tone_characteristic[],array['yamaha','thr','thr30ii','wireless','bluetooth']::text[])
on conflict (equipment_type, brand, model) do update set
  display_name = excluded.display_name,
  description = excluded.description,
  search_terms = excluded.search_terms,
  updated_at = now();

create temp table tmp_tags_guitar_models(instrument text, slug text, family_name text, phrase text) on commit drop;
insert into tmp_tags_guitar_models(instrument, slug, family_name, phrase) values
-- Cluster G1 — family tags. One row per equip model (40 total).
-- match phrase = lowercase "<brand> <model>" exactly as picker display_name.

-- Squier Sonic
('guitar','squier','Stratocaster / Telecaster','squier sonic stratocaster'),
('guitar','squier','Stratocaster / Telecaster','squier sonic stratocaster hss'),
('guitar','fender','Telecaster','squier sonic telecaster'),
('guitar','fender','Jazzmaster / Jaguar','squier sonic mustang'),

-- Squier Bullet
('guitar','squier','Stratocaster / Telecaster','squier bullet stratocaster'),
('guitar','squier','Stratocaster / Telecaster','squier bullet stratocaster ht hss'),
('guitar','fender','Jazzmaster / Jaguar','squier bullet mustang hh'),
('guitar','fender','Telecaster','squier bullet telecaster'),

-- Squier Affinity
('guitar','squier','Stratocaster / Telecaster','squier affinity stratocaster'),
('guitar','squier','Stratocaster / Telecaster','squier affinity stratocaster hss'),
('guitar','fender','Telecaster','squier affinity telecaster'),
('guitar','fender','Telecaster','squier affinity telecaster deluxe'),
('guitar','fender','Jazzmaster / Jaguar','squier affinity jazzmaster'),
('guitar','gibson','ES-335 / Casino','squier affinity starcaster'),

-- Squier Classic Vibe
('guitar','squier','Stratocaster / Telecaster','squier classic vibe ''50s stratocaster'),
('guitar','squier','Stratocaster / Telecaster','squier classic vibe ''60s stratocaster'),
('guitar','squier','Stratocaster / Telecaster','squier classic vibe ''70s stratocaster'),
('guitar','fender','Telecaster','squier classic vibe ''50s telecaster'),
('guitar','fender','Telecaster','squier classic vibe ''60s custom telecaster'),
('guitar','fender','Telecaster','squier classic vibe ''70s telecaster thinline'),
('guitar','fender','Jazzmaster / Jaguar','squier classic vibe jazzmaster'),
('guitar','fender','Jazzmaster / Jaguar','squier classic vibe jaguar'),
('guitar','fender','Jazzmaster / Jaguar','squier classic vibe bass vi'),
('guitar','gibson','ES-335 / Casino','squier classic vibe starcaster'),

-- Squier Paranormal
('guitar','fender','Telecaster','squier paranormal cabronita telecaster thinline'),
('guitar','fender','Telecaster','squier paranormal baritone cabronita telecaster'),
('guitar','fender','Jazzmaster / Jaguar','squier paranormal super-sonic'),
('guitar','fender','Jazzmaster / Jaguar','squier paranormal toronado'),

-- Squier Contemporary
('guitar','squier','Stratocaster / Telecaster','squier contemporary stratocaster special ht'),
('guitar','fender','Telecaster','squier contemporary telecaster rh'),

-- Fender Player II
('guitar','fender','Stratocaster','fender player ii stratocaster'),
('guitar','fender','Stratocaster','fender player ii stratocaster hss'),
('guitar','fender','Telecaster','fender player ii telecaster'),
('guitar','fender','Telecaster','fender player ii telecaster hh'),
('guitar','fender','Jazzmaster / Jaguar','fender player ii jazzmaster'),
('guitar','fender','Jazzmaster / Jaguar','fender player ii jaguar'),
('guitar','fender','Jazzmaster / Jaguar','fender player ii mustang'),

-- Fender Standard (2025)
('guitar','fender','Stratocaster','fender standard stratocaster'),
('guitar','fender','Stratocaster','fender standard stratocaster hss'),
('guitar','fender','Telecaster','fender standard telecaster'),
('guitar','yamaha','Pacifica / Revstar','yamaha pac012'),
('guitar','yamaha','Pacifica / Revstar','yamaha pac112j'),
('guitar','yamaha','Pacifica / Revstar','yamaha pac112v'),
('guitar','yamaha','Pacifica / Revstar','yamaha pac112vm'),
('guitar','yamaha','Pacifica / Revstar','yamaha pac120h'),
('guitar','yamaha','Pacifica / Revstar','yamaha pac212vfm'),
('guitar','yamaha','Pacifica / Revstar','yamaha pac311h'),
('guitar','yamaha','Pacifica / Revstar','yamaha pac612vii'),
('guitar','yamaha','Pacifica / Revstar','yamaha pacs+'),
('guitar','yamaha','Pacifica / Revstar','yamaha pac012dlx'),
('guitar','yamaha','Pacifica / Revstar','yamaha revstar element rse20'),
('guitar','yamaha','Pacifica / Revstar','yamaha revstar standard rss02'),
('guitar','yamaha','Pacifica / Revstar','yamaha revstar standard rss20'),
('guitar','ibanez','RG / S','ibanez grx70qa'),
('guitar','ibanez','RG / S','ibanez grx40'),
('guitar','ibanez','RG / S','ibanez grg121dx'),
('guitar','ibanez','RG / S','ibanez grg131dx'),
('guitar','ibanez','RG / S','ibanez grgm21'),
('guitar','ibanez','RG / S','ibanez grgr221pa'),
('guitar','ibanez','RG / S','ibanez gax30'),
('guitar','ibanez','RG / S','ibanez grx20'),
('guitar','ibanez','RG / S','ibanez grga120'),
('guitar','ibanez','RG / S','ibanez rg421'),
('guitar','ibanez','RG / S','ibanez rg450dx'),
('guitar','ibanez','RG / S','ibanez rg550'),
('guitar','ibanez','RG / S','ibanez rga42'),
('guitar','ibanez','AZ','ibanez azes31'),
('guitar','ibanez','AZ','ibanez azes40'),
('guitar','ibanez','Artcore / AR','ibanez as53'),
('guitar','ibanez','Artcore / AR','ibanez am53'),
('guitar','ibanez','Artcore / AR','ibanez af55'),
('guitar','ibanez','Artcore / AR','ibanez ag75'),
('guitar','cort','G / KX Series','cort g250'),
('guitar','cort','G / KX Series','cort g290'),
('guitar','cort','G / KX Series','cort x100'),
('guitar','cort','G / KX Series','cort x250'),
('guitar','cort','G / KX Series','cort kx300'),
('guitar','cort','G / KX Series','cort cr200'),
('guitar','cort','G / KX Series','cort classic tc'),
('guitar','epiphone','Les Paul','epiphone les paul sl'),
('guitar','epiphone','Les Paul','epiphone les paul special'),
('guitar','epiphone','Les Paul','epiphone les paul studio'),
('guitar','epiphone','Les Paul','epiphone les paul player pack'),
('guitar','epiphone','Les Paul','epiphone les paul standard 50s'),
('guitar','epiphone','Les Paul','epiphone les paul standard 60s'),
('guitar','gibson','SG','epiphone sg special'),
('guitar','gibson','SG','epiphone sg standard'),
('guitar','epiphone','Les Paul','epiphone les paul melody maker'),
('guitar','epiphone','Les Paul','epiphone power players les paul'),
('guitar','gibson','SG','epiphone power players sg'),
('guitar','gibson','ES-335 / Casino','epiphone dot'),
('guitar','gibson','ES-335 / Casino','epiphone es-339'),
-- Cluster G3 — import/budget starter guitar brands (family tags)
-- One tag row per equip row; match phrase = lowercase "<brand> <model>"

-- Glarry
('guitar','squier','Stratocaster / Telecaster','glarry gst'),
('guitar','squier','Stratocaster / Telecaster','glarry gst3'),
('guitar','ibanez','RG / S','glarry gst-e'),
('guitar','fender','Telecaster','glarry gtl'),
('guitar','epiphone','Les Paul','glarry glp'),
('guitar','ibanez','RG / S','glarry burning fire'),

-- Donner
('guitar','squier','Stratocaster / Telecaster','donner dst-152'),
('guitar','squier','Stratocaster / Telecaster','donner dst-100'),
('guitar','fender','Telecaster','donner dtc-100'),
('guitar','fender','Telecaster','donner dtl-100'),
('guitar','epiphone','Les Paul','donner dlp-124'),
('guitar','ibanez','RG / S','donner dmt-100'),

-- Firefly
('guitar','gibson','ES-335 / Casino','firefly ff338'),
('guitar','epiphone','Les Paul','firefly fflp'),
('guitar','fender','Telecaster','firefly fftl'),

-- Harley Benton
('guitar','squier','Stratocaster / Telecaster','harley benton st-20'),
('guitar','squier','Stratocaster / Telecaster','harley benton st-59'),
('guitar','squier','Stratocaster / Telecaster','harley benton st-62'),
('guitar','fender','Telecaster','harley benton te-20'),
('guitar','fender','Telecaster','harley benton te-52'),
('guitar','fender','Telecaster','harley benton te-62'),
('guitar','epiphone','Les Paul','harley benton sc-200'),
('guitar','epiphone','Les Paul','harley benton sc-400'),
('guitar','epiphone','Les Paul','harley benton sc-450'),
('guitar','gibson','Les Paul Junior / Special (P-90)','harley benton dc-junior'),
('guitar','ibanez','RG / S','harley benton fusion-ii hh'),
('guitar','ibanez','RG / S','harley benton fusion-iii hsh'),
('guitar','ibanez','RG / S','harley benton amarok'),
('guitar','ibanez','RG / S','harley benton r-446'),
('guitar','prs','SE Custom 24','harley benton cst-24'),

-- Jackson JS Series
('guitar','jackson','Dinky / Soloist','jackson js11 dinky'),
('guitar','jackson','Dinky / Soloist','jackson js12 dinky'),
('guitar','jackson','Dinky / Soloist','jackson js22 dinky'),
('guitar','jackson','Dinky / Soloist','jackson js32 dinky'),
('guitar','dean','ML','jackson js32 king v'),
('guitar','dean','ML','jackson js32 rhoads'),
('guitar','dean','ML','jackson js32 kelly'),
('guitar','jackson','Dinky / Soloist','jackson js1x dinky minion'),

-- Kramer
('guitar','kramer','Baretta / 84','kramer focus vt-211s'),
('guitar','kramer','Baretta / 84','kramer striker hss'),

-- Monoprice Indio
('guitar','squier','Stratocaster / Telecaster','monoprice indio cali classic'),
('guitar','squier','Stratocaster / Telecaster','monoprice indio cali classic hss'),
('guitar','squier','Stratocaster / Telecaster','monoprice indio retro classic'),

-- Gretsch Streamliner
('guitar','gretsch','Electromatic','gretsch g2622 streamliner'),
('guitar','gretsch','Electromatic','gretsch g2655 streamliner'),
('guitar','gretsch','Electromatic','gretsch g2420 streamliner');
with newtags as (
  select slug, family_name, array_agg(distinct phrase) as phrases
  from tmp_tags_guitar_models group by slug, family_name
)
update public.guitar_models t
set tags = (select array(select distinct e from unnest(coalesce(t.tags, array[]::text[]) || nt.phrases) as e))
from newtags nt
join public.equipment_manufacturers m on m.slug = nt.slug
where t.manufacturer_id = m.id
  and t.model_name = nt.family_name
  and t.instrument_type = 'guitar'
  and t.is_active = true;

create temp table tmp_tags_amp_models(instrument text, slug text, family_name text, phrase text) on commit drop;
insert into tmp_tags_amp_models(instrument, slug, family_name, phrase) values
('guitar','boss','Katana','boss katana-50 mkii'),
('guitar','boss','Katana','boss katana-100 mkii'),
('guitar','boss','Katana','boss katana-100/212 mkii'),
('guitar','boss','Katana','boss katana-head mkii'),
('guitar','boss','Katana','boss katana-mini'),
('guitar','boss','Katana','boss katana-mini x'),
('guitar','boss','Katana','boss katana-air'),
('guitar','boss','Katana','boss katana-air ex'),
('guitar','boss','Katana','boss katana-artist mkii'),
('guitar','boss','Katana','boss katana-artist head mkii'),
('guitar','boss','Katana','boss katana-50 gen 3'),
('guitar','boss','Katana','boss katana-50 ex'),
('guitar','boss','Katana','boss katana-100 gen 3'),
('guitar','boss','Katana','boss katana-head gen 3'),
('guitar','boss','Katana','boss katana-artist gen 3'),
('guitar','boss','Katana','boss katana-artist head gen 3'),
('guitar','positive-grid','Spark','positive grid spark'),
('guitar','positive-grid','Spark','positive grid spark mini'),
('guitar','positive-grid','Spark','positive grid spark go'),
('guitar','positive-grid','Spark','positive grid spark 2'),
('guitar','positive-grid','Spark','positive grid spark cab'),
('guitar','positive-grid','Spark','positive grid spark live'),
('guitar','line-6','Catalyst / Spider','line 6 spider v 20 mkii'),
('guitar','line-6','Catalyst / Spider','line 6 spider v 30 mkii'),
('guitar','line-6','Catalyst / Spider','line 6 spider v 60 mkii'),
('guitar','line-6','Catalyst / Spider','line 6 spider v 120 mkii'),
('guitar','line-6','Catalyst / Spider','line 6 spider v 240 mkii'),
('guitar','line-6','Catalyst / Spider','line 6 spider v 20'),
('guitar','line-6','Catalyst / Spider','line 6 spider v 60'),
('guitar','line-6','Catalyst / Spider','line 6 catalyst 60'),
('guitar','line-6','Catalyst / Spider','line 6 catalyst 100'),
('guitar','line-6','Catalyst / Spider','line 6 catalyst 200'),
('guitar','line-6','Catalyst / Spider','line 6 catalyst cx 60'),
('guitar','line-6','Catalyst / Spider','line 6 catalyst cx 100'),
('guitar','line-6','Catalyst / Spider','line 6 catalyst cx 200'),
('guitar','line-6','Catalyst / Spider','line 6 spider classic 15'),
-- Cluster A2: family tags (instrument_type 'guitar' for amps)

-- ===== FENDER =====
('guitar','fender','Champion 40','fender frontman 10g'),
('guitar','fender','Champion 40','fender frontman 20g'),
('guitar','fender','Champion 40','fender champion 20'),
('guitar','fender','Champion 40','fender champion 40'),
('guitar','fender','Champion 40','fender champion 50xl'),
('guitar','fender','Champion 40','fender champion 100'),
('guitar','fender','Champion 40','fender champion ii 25'),
('guitar','fender','Champion 40','fender champion ii 50'),
('guitar','fender','Champion 40','fender champion ii 100'),
('guitar','fender','Mustang GTX / LT','fender mustang lt25'),
('guitar','fender','Mustang GTX / LT','fender mustang lt40s'),
('guitar','fender','Mustang GTX / LT','fender mustang lt50'),
('guitar','fender','Mustang GTX / LT','fender mustang gtx50'),
('guitar','fender','Mustang GTX / LT','fender mustang gtx100'),
('guitar','fender','Mustang GTX / LT','fender mustang gt40'),
('guitar','fender','Mustang GTX / LT','fender mustang gt100'),
('guitar','fender','Mustang GTX / LT','fender mustang gt200'),
('guitar','fender','Champion 40','fender mustang micro'),
('guitar','fender','Champion 40','fender mustang micro plus'),
('guitar','fender','Champion 40','fender frontman 212r'),
('guitar','fender','Champion 40','fender super champ x2'),

-- ===== MARSHALL =====
('guitar','marshall','MG Series','marshall mg10g'),
('guitar','marshall','MG Series','marshall mg15gr'),
('guitar','marshall','MG Series','marshall mg15gfx'),
('guitar','marshall','MG Series','marshall mg15cfx'),
('guitar','marshall','MG Series','marshall mg15cfr'),
('guitar','marshall','MG Series','marshall mg30gfx'),
('guitar','marshall','MG Series','marshall mg50gfx'),
('guitar','marshall','MG Series','marshall mg100hgfx'),
('guitar','marshall','MG Series','marshall code 25'),
('guitar','marshall','MG Series','marshall code 50'),
('guitar','marshall','MG Series','marshall code 100'),
('guitar','marshall','DSL Series','marshall dsl1cr'),
('guitar','marshall','DSL Series','marshall dsl5cr'),
('guitar','marshall','DSL Series','marshall dsl20cr'),
('guitar','marshall','DSL Series','marshall dsl40cr'),
('guitar','marshall','Plexi / JCM800 Studio','marshall origin 5'),
('guitar','marshall','Plexi / JCM800 Studio','marshall origin 20'),
('guitar','marshall','Plexi / JCM800 Studio','marshall origin 50'),

-- ===== ORANGE =====
('guitar','orange','Tiny Terror / Crush','orange crush mini'),
('guitar','orange','Tiny Terror / Crush','orange micro crush'),
('guitar','orange','Tiny Terror / Crush','orange crush 12'),
('guitar','orange','Tiny Terror / Crush','orange crush 20'),
('guitar','orange','Tiny Terror / Crush','orange crush 20rt'),
('guitar','orange','Tiny Terror / Crush','orange crush 35rt'),
('guitar','orange','Tiny Terror / Crush','orange crush pro 60'),
('guitar','orange','Tiny Terror / Crush','orange crush pro 120'),
-- Cluster A3 — family tags (one per equip row, same brand+model match phrase)
('guitar','blackstar','ID / Debut (digital)','blackstar debut 15e'),
('guitar','blackstar','ID / Debut (digital)','blackstar debut 50r'),
('guitar','blackstar','ID / Debut (digital)','blackstar fly 3'),
('guitar','blackstar','ID / Debut (digital)','blackstar fly 3 bluetooth'),
('guitar','blackstar','ID / Debut (digital)','blackstar id core 10 v4'),
('guitar','blackstar','ID / Debut (digital)','blackstar id core 20 v4'),
('guitar','blackstar','ID / Debut (digital)','blackstar id core 40 v4'),
('guitar','blackstar','ID / Debut (digital)','blackstar silverline standard'),
('guitar','blackstar','ID / Debut (digital)','blackstar silverline special'),
('guitar','blackstar','ID / Debut (digital)','blackstar silverline deluxe'),
('guitar','blackstar','HT Series','blackstar ht-1r'),
('guitar','blackstar','HT Series','blackstar ht-5r mkii'),
('guitar','blackstar','HT Series','blackstar ht-20r mkii'),
('guitar','blackstar','ID / Debut (digital)','blackstar super fly'),
('guitar','blackstar','ID / Debut (digital)','blackstar amped 1'),
('guitar','blackstar','HT Series','blackstar st. james 50'),
('guitar','vox','Valvetronix / Pathfinder','vox pathfinder 10'),
('guitar','vox','Valvetronix / Pathfinder','vox pathfinder 15r'),
('guitar','vox','Valvetronix / Pathfinder','vox vx i'),
('guitar','vox','Valvetronix / Pathfinder','vox vx ii'),
('guitar','vox','Valvetronix / Pathfinder','vox vx50 gtv'),
('guitar','vox','Valvetronix / Pathfinder','vox mini go 3'),
('guitar','vox','Valvetronix / Pathfinder','vox mini go 10'),
('guitar','vox','Valvetronix / Pathfinder','vox mini go 50'),
('guitar','vox','Valvetronix / Pathfinder','vox adio air gt'),
('guitar','vox','Valvetronix / Pathfinder','vox valvetronix vt20x'),
('guitar','vox','Valvetronix / Pathfinder','vox valvetronix vt40x'),
('guitar','vox','Valvetronix / Pathfinder','vox valvetronix vt100x'),
('guitar','vox','AC30 / AC15','vox ac4c1'),
('guitar','vox','AC30 / AC15','vox ac10c1'),
('guitar','vox','AC30 / AC15','vox ac15c1'),
('guitar','vox','AC30 / AC15','vox ac30c2'),
('guitar','vox','AC30 / AC15','vox mv50 ac'),
('guitar','vox','AC30 / AC15','vox mv50 clean'),
('guitar','vox','AC30 / AC15','vox mv50 rock'),
('guitar','vox','AC30 / AC15','vox mv50 boutique'),
('guitar','nux','Mighty','nux mighty 8'),
('guitar','nux','Mighty','nux mighty 20'),
('guitar','nux','Mighty','nux mighty 30'),
('guitar','nux','Mighty','nux mighty 40'),
('guitar','nux','Mighty','nux mighty 50'),
('guitar','nux','Mighty','nux mighty lite'),
('guitar','nux','Mighty','nux mighty space'),
('guitar','mooer','Hornet / SD','mooer hornet 30'),
('guitar','mooer','Hornet / SD','mooer sd30'),
('guitar','nux','Mighty','valeton rushead max'),
('guitar','harley-benton','TUBE Series','harley benton tube5'),
('guitar','harley-benton','TUBE Series','harley benton tube15'),
('guitar','nux','Mighty','harley benton hb-40r'),
('guitar','peavey','Bandit 112','peavey vypyr x1'),
('guitar','peavey','Bandit 112','peavey vypyr x2'),
('guitar','peavey','Bandit 112','peavey vypyr x3'),
('guitar','peavey','Bandit 112','peavey vypyr tube 60'),
('guitar','peavey','Bandit 112','peavey bandit 112'),
('guitar','yamaha','THR','yamaha thr5'),
('guitar','yamaha','THR','yamaha thr10'),
('guitar','yamaha','THR','yamaha thr10ii'),
('guitar','yamaha','THR','yamaha thr30ii');
with newtags as (
  select slug, family_name, array_agg(distinct phrase) as phrases
  from tmp_tags_amp_models group by slug, family_name
)
update public.amp_models t
set tags = (select array(select distinct e from unnest(coalesce(t.tags, array[]::text[]) || nt.phrases) as e))
from newtags nt
join public.equipment_manufacturers m on m.slug = nt.slug
where t.manufacturer_id = m.id
  and t.model_name = nt.family_name
  and t.instrument_type = 'guitar'
  and t.is_active = true;

do $$
declare missing text;
begin
  select nt.slug || '::' || nt.family_name into missing
  from (select distinct slug, family_name from tmp_tags_guitar_models) nt
  left join public.equipment_manufacturers m on m.slug = nt.slug
  left join public.guitar_models g on g.manufacturer_id = m.id and g.model_name = nt.family_name and g.instrument_type='guitar' and g.is_active=true
  where g.id is null
  limit 1;
  if missing is not null then
    raise exception 'POST-CONDITION FAILED: guitar_models family not found for tag mapping: %', missing;
  end if;
end $$;

do $$
declare missing text;
begin
  select nt.slug || '::' || nt.family_name into missing
  from (select distinct slug, family_name from tmp_tags_amp_models) nt
  left join public.equipment_manufacturers m on m.slug = nt.slug
  left join public.amp_models g on g.manufacturer_id = m.id and g.model_name = nt.family_name and g.instrument_type='guitar' and g.is_active=true
  where g.id is null
  limit 1;
  if missing is not null then
    raise exception 'POST-CONDITION FAILED: amp_models family not found for tag mapping: %', missing;
  end if;
end $$;

commit;
