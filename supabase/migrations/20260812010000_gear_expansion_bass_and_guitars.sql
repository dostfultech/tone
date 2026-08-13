-- Gear coverage expansion: bass amps (the big gap — was only 4), bass guitars (was
-- only 4), and the handful of missing guitars. Real, verified specs only. Idempotent:
-- each row is skipped if a matching brand+model already exists. search_text is
-- trigger-owned, so it is never written here.

begin;

-- ============================ BASS AMPLIFIERS ============================
insert into gear_items (brand, model, item_type, category, instrument_type, pickup_type, amp_type, gain_range, voicing_tags, notable_use_cases, source_urls, is_active)
select v.brand, v.model, 'bass_amp', v.category, 'bass', null::text, v.amp_type::text, v.gain_range::text,
       v.voicing_tags::text[], v.notable_use_cases::text[], v.source_urls::text[], true
from (values
  ('Fender','Rumble 40','solid-state 1x10 bass combo (40W)','solid-state','clean',array['punchy','warm','scooped'],array['practice','rehearsal'],array['https://www.fender.com/']),
  ('Fender','Rumble 100','solid-state 1x12 bass combo (100W)','solid-state','clean-to-overdrive',array['punchy','warm','flexible'],array['rehearsal','small gigs'],array['https://www.fender.com/']),
  ('Fender','Rumble 500','solid-state 2x10 bass combo (500W)','solid-state','clean-to-overdrive',array['loud','punchy','modern'],array['gigging','rock','funk'],array['https://www.fender.com/']),
  ('Ampeg','BA-108','solid-state 1x8 bass combo (20W)','solid-state','clean',array['warm','round','vintage'],array['practice','bedroom'],array['https://www.ampeg.com/']),
  ('Ampeg','BA-110','solid-state 1x10 bass combo (40W)','solid-state','clean',array['warm','round','punchy'],array['practice','rehearsal'],array['https://www.ampeg.com/']),
  ('Ampeg','BA-115','solid-state 1x15 bass combo (100W)','solid-state','clean-to-overdrive',array['deep','warm','fat'],array['rehearsal','small gigs'],array['https://www.ampeg.com/']),
  ('Ampeg','BA-210','solid-state 2x10 bass combo (450W)','solid-state','clean-to-overdrive',array['punchy','loud','modern'],array['gigging','rock'],array['https://www.ampeg.com/']),
  ('Ampeg','Rocket Bass RB-108','solid-state 1x8 bass combo (30W)','solid-state','clean-to-overdrive',array['warm','vintage','grindy'],array['practice','bedroom'],array['https://www.ampeg.com/']),
  ('Ampeg','Rocket Bass RB-110','solid-state 1x10 bass combo (50W)','solid-state','clean-to-overdrive',array['warm','punchy','grindy'],array['practice','rehearsal'],array['https://www.ampeg.com/']),
  ('Ampeg','Rocket Bass RB-115','solid-state 1x15 bass combo (200W)','solid-state','clean-to-overdrive',array['deep','fat','grindy'],array['rehearsal','gigging'],array['https://www.ampeg.com/']),
  ('Ampeg','PF-500','hybrid Portaflex bass head (500W)','hybrid','clean-to-overdrive',array['warm','punchy','classic'],array['gigging','studio'],array['https://www.ampeg.com/']),
  ('Ampeg','B-1','hybrid bass head (150W, 12AX7 preamp)','hybrid','clean-to-overdrive',array['warm','fat','vintage'],array['gigging','studio'],array['https://www.ampeg.com/']),
  ('Ampeg','B1-RE','solid-state rackmount bass head (300W)','solid-state','clean',array['warm','punchy','clean'],array['gigging','touring'],array['https://www.ampeg.com/']),
  ('Gallien-Krueger','MB110','ultralight solid-state 1x10 bass combo (100W)','solid-state','clean',array['punchy','clear','modern'],array['practice','gigging'],array['https://www.gallien-krueger.com/']),
  ('Gallien-Krueger','MB210','ultralight solid-state 2x10 bass combo (500W)','solid-state','clean',array['punchy','clear','loud'],array['gigging','rock'],array['https://www.gallien-krueger.com/']),
  ('Hartke','HD25','solid-state 1x8 bass combo (25W)','solid-state','clean',array['bright','punchy','aluminum-cone'],array['practice','bedroom'],array['https://www.hartke.com/']),
  ('Hartke','HD50','solid-state 1x10 bass combo (50W)','solid-state','clean',array['bright','punchy','aluminum-cone'],array['practice','rehearsal'],array['https://www.hartke.com/']),
  ('TC Electronic','BG250-112','solid-state 1x12 bass combo (250W, TonePrint)','solid-state','clean-to-overdrive',array['modern','flexible','punchy'],array['gigging','rehearsal'],array['https://www.tcelectronic.com/']),
  ('Orange','Crush Bass 25','solid-state 1x8 bass combo (25W)','solid-state','clean-to-overdrive',array['warm','gritty','british'],array['practice','bedroom'],array['https://orangeamps.com/']),
  ('Orange','Crush Bass 50','solid-state 1x12 bass combo (50W)','solid-state','clean-to-overdrive',array['warm','gritty','british'],array['practice','rehearsal'],array['https://orangeamps.com/']),
  ('Orange','Crush Bass 100','solid-state 1x15 bass combo (100W)','solid-state','clean-to-overdrive',array['warm','gritty','british'],array['rehearsal','small gigs'],array['https://orangeamps.com/']),
  ('Aguilar','Tone Hammer 350','solid-state bass head (350W, AGS drive)','solid-state','clean-to-overdrive',array['warm','punchy','studio'],array['gigging','studio'],array['https://aguilaramp.com/']),
  ('Aguilar','DB 750','hybrid bass head (750W, all-tube preamp)','hybrid','clean-to-overdrive',array['warm','fat','powerful'],array['touring','studio'],array['https://aguilaramp.com/']),
  ('Markbass','Little Mark III','solid-state bass head (500W)','solid-state','clean',array['punchy','clear','italian'],array['gigging','studio'],array['https://www.markbass.it/']),
  ('Peavey','MAX 126','solid-state 1x8 bass combo (10W)','solid-state','clean',array['punchy','simple','beginner'],array['practice','bedroom'],array['https://peavey.com/']),
  ('Acoustic','B200','solid-state 1x15 bass combo with horn (200W)','solid-state','clean',array['deep','loud','value'],array['rehearsal','gigging'],array['https://www.acousticamplification.com/']),
  ('Acoustic','B25C','solid-state 1x8 bass combo (25W)','solid-state','clean',array['warm','simple','value'],array['practice','bedroom'],array['https://www.acousticamplification.com/']),
  ('Ashdown','Five Fifteen 100','solid-state 1x15 bass combo (100W, BlueLine)','solid-state','clean-to-overdrive',array['warm','deep','british'],array['rehearsal','gigging'],array['https://ashdownmusic.com/']),
  ('Behringer','Ultrabass BXD3000H','Class-D 2-channel bass head (300W)','solid-state','clean-to-overdrive',array['flexible','value','modern'],array['rehearsal','gigging'],array['https://www.behringer.com/']),
  ('Boss','Katana-210 Bass','solid-state 2x10 bass combo with tweeter (160W)','solid-state','clean-to-overdrive',array['modern','flexible','punchy'],array['gigging','rehearsal'],array['https://www.boss.info/']),
  ('Carvin','PB500','solid-state bass head (500W, 9-band graphic EQ)','solid-state','clean',array['clear','flexible','powerful'],array['gigging','studio'],array['https://www.carvinaudio.com/']),
  ('Cort','CM40B','solid-state 1x10 bass combo (40W, 4-band EQ)','solid-state','clean',array['warm','value','flexible'],array['practice','rehearsal'],array['https://www.cort.com/']),
  ('Cort','CM20B','solid-state 1x8 bass combo (20W, 3-band EQ)','solid-state','clean',array['warm','value','simple'],array['practice','bedroom'],array['https://www.cort.com/']),
  ('Cort','GE15B','solid-state bass combo (15W)','solid-state','clean',array['warm','value','simple'],array['practice','bedroom'],array['https://www.cort.com/']),
  ('Crate','BX-15','solid-state 1x8 bass combo (12W)','solid-state','clean',array['punchy','simple','beginner'],array['practice','bedroom'],array['https://crateamps.com/']),
  ('Carlsbro','Kickstart Bass 30','solid-state 1x8 bass combo (30W)','solid-state','clean',array['punchy','value','beginner'],array['practice','rehearsal'],array['https://www.carlsbro.com/']),
  ('Trace Elliot','ELF','micro solid-state bass head (200W)','solid-state','clean',array['compact','clear','punchy'],array['gigging','travel'],array['https://traceelliot.com/'])
) as v(brand, model, category, amp_type, gain_range, voicing_tags, notable_use_cases, source_urls)
where not exists (select 1 from gear_items g where lower(g.brand)=lower(v.brand) and lower(g.model)=lower(v.model));

-- ============================ BASS GUITARS ============================
insert into gear_items (brand, model, item_type, category, instrument_type, pickup_type, amp_type, gain_range, voicing_tags, notable_use_cases, source_urls, is_active)
select v.brand, v.model, 'bass_guitar', v.category, 'bass', v.pickup_type::text, null::text, null::text,
       v.voicing_tags::text[], v.notable_use_cases::text[], v.source_urls::text[], true
from (values
  ('Squier','Affinity Jazz Bass','4-string electric bass','JJ single-coil (passive)',array['bright','growly','versatile'],array['rock','funk','pop'],array['https://www.fender.com/squier']),
  ('Squier','Affinity Precision Bass PJ','4-string electric bass','PJ (split-P + single-J, passive)',array['punchy','warm','versatile'],array['rock','pop','punk'],array['https://www.fender.com/squier']),
  ('Squier','Classic Vibe 60s Jazz Bass','4-string electric bass','JJ single-coil (passive)',array['vintage','growly','warm'],array['rock','soul','funk'],array['https://www.fender.com/squier']),
  ('Squier','Classic Vibe 50s Precision Bass','4-string electric bass','split-coil P (passive)',array['vintage','thick','warm'],array['rock','blues','country'],array['https://www.fender.com/squier']),
  ('Fender','Player Jazz Bass','4-string electric bass','JJ single-coil (passive)',array['bright','growly','versatile'],array['rock','funk','pop'],array['https://www.fender.com/']),
  ('Fender','Player Precision Bass','4-string electric bass','split-coil P (passive)',array['punchy','thick','warm'],array['rock','punk','pop'],array['https://www.fender.com/']),
  ('Fender','Mustang Bass PJ','short-scale 4-string electric bass','PJ (split-P + single-J, passive)',array['punchy','round','compact'],array['indie','pop','rock'],array['https://www.fender.com/']),
  ('Fender','American Professional II Jazz Bass','4-string electric bass','JJ single-coil (passive)',array['bright','articulate','premium'],array['studio','rock','funk'],array['https://www.fender.com/']),
  ('Fender','Aerodyne Jazz Bass PJ','4-string electric bass','PJ (split-P + single-J, passive)',array['punchy','modern','sleek'],array['rock','pop','studio'],array['https://www.fender.com/']),
  ('Yamaha','TRBX304','4-string electric bass','dual humbucker (active/passive, 2-band EQ)',array['modern','flexible','punchy'],array['rock','metal','funk'],array['https://www.yamaha.com/']),
  ('Yamaha','BB434','4-string electric bass','PJ (split-P + single-J, passive)',array['punchy','warm','studio'],array['rock','pop','session'],array['https://www.yamaha.com/']),
  ('Ibanez','GSR200','4-string electric bass','PJ + active Phat II EQ',array['punchy','value','flexible'],array['rock','metal','beginner'],array['https://www.ibanez.com/']),
  ('Ibanez','SR300E','4-string electric bass','dual PowerSpan humbucker (active 3-band)',array['modern','punchy','fast'],array['rock','metal','funk'],array['https://www.ibanez.com/']),
  ('Ibanez','SR500E','4-string electric bass','dual Bartolini humbucker (active 3-band)',array['modern','articulate','premium'],array['rock','metal','fusion'],array['https://www.ibanez.com/']),
  ('Sterling by Music Man','Ray4','4-string electric bass','MM humbucker (active 2-band)',array['punchy','aggressive','slap'],array['funk','rock','pop'],array['https://www.sterlingbymusicman.com/']),
  ('ESP','LTD B-10','4-string electric bass','PJ (passive)',array['punchy','value','beginner'],array['rock','metal','pop'],array['https://www.espguitars.com/']),
  ('ESP','LTD B-155DX','5-string electric bass','SB-5 passive + ABQ-3 active EQ',array['modern','deep','flexible'],array['metal','rock','funk'],array['https://www.espguitars.com/']),
  ('ESP','LTD B-205SM','5-string electric bass','SB-5 passive + ABQ-3 active EQ',array['modern','deep','clear'],array['metal','rock','funk'],array['https://www.espguitars.com/']),
  ('ESP','LTD Surveyor 87','4-string electric bass','PJ (active)',array['punchy','aggressive','vintage-modern'],array['rock','metal','punk'],array['https://www.espguitars.com/']),
  ('ESP','LTD AP-204','4-string electric bass','PJ + active 2-band EQ',array['punchy','modern','flexible'],array['rock','metal','funk'],array['https://www.espguitars.com/']),
  ('Epiphone','Thunderbird Pro','4-string electric bass','dual T-Pro humbucker (active)',array['deep','growly','aggressive'],array['rock','metal','hard rock'],array['https://www.epiphone.com/']),
  ('Epiphone','Toby Deluxe IV','4-string electric bass','dual soapbar humbucker (active)',array['modern','punchy','flexible'],array['rock','funk','metal'],array['https://www.epiphone.com/']),
  ('Epiphone','Viola Bass','short-scale hollow 4-string bass','dual mini-humbucker (passive)',array['warm','round','vintage'],array['beatle','pop','motown'],array['https://www.epiphone.com/']),
  ('Cort','Action Bass Plus','4-string electric bass','PJ + active 2-band EQ',array['punchy','value','flexible'],array['rock','pop','beginner'],array['https://www.cort.com/']),
  ('Cort','B4 Element','4-string electric bass','Bartolini MK-1 pickups + preamp',array['modern','articulate','flexible'],array['rock','funk','fusion'],array['https://www.cort.com/']),
  ('Dean','Edge 09','4-string electric bass','single soapbar (passive)',array['deep','simple','value'],array['rock','metal','beginner'],array['https://www.deanguitars.com/']),
  ('Ampeg','Dan Armstrong Bass','Lucite-body 4-string electric bass','single interchangeable pickup (passive)',array['clear','sustaining','unique'],array['rock','studio','vintage'],array['https://www.ampeg.com/']),
  ('B.C. Rich','NJ Series Mockingbird Bass','4-string electric bass','dual P-style humbucker (active)',array['aggressive','deep','metal'],array['metal','hard rock'],array['https://bcrich.com/']),
  ('Warwick','RockBass Corvette Basic','4-string electric bass','JJ MEC (active 2-band)',array['growly','punchy','german'],array['rock','funk','metal'],array['https://www.warwick.de/']),
  ('Sire','Marcus Miller V7','4-string electric bass','JJ + Marcus preamp (active)',array['bright','slap','premium-value'],array['funk','pop','session'],array['https://www.sire-usa.com/']),
  ('Hofner','Ignition Violin Bass','short-scale hollow 4-string bass','dual mini-humbucker (passive)',array['warm','round','vintage'],array['beatle','pop','motown'],array['https://www.hofner-guitars.com/'])
) as v(brand, model, category, pickup_type, voicing_tags, notable_use_cases, source_urls)
where not exists (select 1 from gear_items g where lower(g.brand)=lower(v.brand) and lower(g.model)=lower(v.model));

-- ============================ MISSING GUITARS ============================
insert into gear_items (brand, model, item_type, category, instrument_type, pickup_type, amp_type, gain_range, voicing_tags, notable_use_cases, source_urls, is_active)
select v.brand, v.model, 'guitar', v.category, 'guitar', v.pickup_type::text, null::text, null::text,
       v.voicing_tags::text[], v.notable_use_cases::text[], v.source_urls::text[], true
from (values
  ('EVH','Wolfgang Special','solid-body electric','dual EVH Wolfgang humbucker',array['hot','tight','articulate'],array['hard rock','metal','shred'],array['https://evhgear.com/']),
  ('Ibanez','AZES40','solid-body electric','HSS (single/single/humbucker)',array['bright','versatile','modern'],array['pop','funk','rock'],array['https://www.ibanez.com/']),
  ('Ibanez','RG','superstrat solid-body electric','dual humbucker (HH, high-output)',array['tight','aggressive','fast'],array['metal','hard rock','shred'],array['https://www.ibanez.com/']),
  ('Squier','Stratocaster','solid-body electric','SSS single-coil',array['bright','glassy','versatile'],array['clean','blues','pop'],array['https://www.fender.com/squier']),
  ('Squier','Telecaster','solid-body electric','SS single-coil',array['twangy','bright','snappy'],array['country','rock','indie'],array['https://www.fender.com/squier']),
  ('Epiphone','Les Paul Standard','solid-body electric','dual humbucker',array['thick','warm','sustaining'],array['rock','blues','metal'],array['https://www.epiphone.com/'])
) as v(brand, model, category, pickup_type, voicing_tags, notable_use_cases, source_urls)
where not exists (select 1 from gear_items g where lower(g.brand)=lower(v.brand) and lower(g.model)=lower(v.model));

commit;
