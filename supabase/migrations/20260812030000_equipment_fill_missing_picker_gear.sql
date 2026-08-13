-- Fill the genuine gaps in the PICKER catalog (public.equipment — the table
-- searchEquipmentModels/the gear dropdowns actually read). The catalog was already
-- comprehensive (1567 guitars / 411 basses / 657 guitar amps / 259 bass amps); these
-- are the specific budget models from the ToneAdapt gear lists that were missing, plus
-- the generic Squier Strat/Tele. search_text is built by the equipment_before_write
-- trigger from search_terms — so we supply search_terms and never write search_text.
-- Idempotent via on conflict (equipment_type, brand, model).

begin;

insert into public.equipment
  (equipment_type, brand, model, series, display_name, description, is_popular, sort_order, status, genres, tone_characteristics, search_terms)
values
  -- ---------------- bass amps ----------------
  ('bass_amp','Cort','CM40B','CM','Cort CM40B','40-watt solid-state bass combo with a 10-inch speaker and 4-band EQ.',false,300,'active',
    array['rock','funk','pop']::public.equipment_genre[], array['clean_headroom','punchy','tight']::public.equipment_tone_characteristic[],
    array['cort','cm40b','cm 40b','40 watt bass combo']::text[]),
  ('bass_amp','Cort','GE15B','GE','Cort GE15B','15-watt solid-state bass practice combo.',false,300,'active',
    array['rock','funk','pop']::public.equipment_genre[], array['clean_headroom','warm','tight']::public.equipment_tone_characteristic[],
    array['cort','ge15b','ge 15b','15 watt bass practice']::text[]),
  ('bass_amp','Crate','BX-15','BX','Crate BX-15','12-watt solid-state bass combo with an 8-inch speaker.',false,300,'active',
    array['rock','funk','pop']::public.equipment_genre[], array['clean_headroom','punchy','warm']::public.equipment_tone_characteristic[],
    array['crate','bx-15','bx15','12 watt bass combo']::text[]),
  ('bass_amp','Carlsbro','Kickstart Bass 30','Kickstart','Carlsbro Kickstart Bass 30','30-watt solid-state bass combo with a single 8-inch speaker.',false,300,'active',
    array['rock','funk','pop']::public.equipment_genre[], array['clean_headroom','punchy','tight']::public.equipment_tone_characteristic[],
    array['carlsbro','kickstart bass 30','kickstart 30b','30 watt bass combo']::text[]),
  ('bass_amp','Carvin','PB500','PB','Carvin PB500','500-watt solid-state bass head with a 9-band graphic EQ and compressor.',false,300,'active',
    array['rock','funk','pop']::public.equipment_genre[], array['clean_headroom','punchy','tight']::public.equipment_tone_characteristic[],
    array['carvin','pb500','pb 500','500 watt bass head']::text[]),
  ('bass_amp','Acoustic','B200','B','Acoustic B200','200-watt solid-state bass combo with a 15-inch speaker and high-frequency horn.',false,300,'active',
    array['rock','funk','pop']::public.equipment_genre[], array['clean_headroom','punchy','warm']::public.equipment_tone_characteristic[],
    array['acoustic','b200','b 200','200 watt bass combo 15']::text[]),
  ('bass_amp','Gear4music','15W Bass Combo','','Gear4music 15W Bass Combo','15-watt solid-state bass combo with a 6.5-inch speaker and 3-band EQ.',false,300,'active',
    array['rock','funk','pop']::public.equipment_genre[], array['clean_headroom','warm','tight']::public.equipment_tone_characteristic[],
    array['gear4music','15w bass combo','15 watt bass practice']::text[]),
  -- ---------------- bass guitars ----------------
  ('bass_guitar','Douglas','WOB 826','WOB','Douglas WOB 826','6-string bass with dual humbucker pickups and active electronics.',false,300,'active',
    array['rock','metal','funk']::public.equipment_genre[], array['modern','punchy','aggressive']::public.equipment_tone_characteristic[],
    array['douglas','wob 826','wob826','6 string bass','6-string bass']::text[]),
  ('bass_guitar','Donner','DPJ-100','DPJ','Donner DPJ-100','Entry-level 4-string PJ bass with an active preamp and slim neck.',false,300,'active',
    array['rock','pop','punk']::public.equipment_genre[], array['punchy','balanced','warm']::public.equipment_tone_characteristic[],
    array['donner','dpj-100','dpj100','pj bass']::text[]),
  ('bass_guitar','Aria','Pro II Magna','Pro II','Aria Pro II Magna Series','Versatile bass series known for comfortable playability and a balanced tone.',false,300,'active',
    array['rock','funk','pop']::public.equipment_genre[], array['balanced','warm','punchy']::public.equipment_tone_characteristic[],
    array['aria','aria pro ii','magna','pro ii magna']::text[]),
  ('bass_guitar','Challenge','VP Bass','VP','Challenge VP Bass','Short-scale violin-shaped bass with original single-coil pickups.',false,300,'active',
    array['pop','rock','jazz']::public.equipment_genre[], array['warm','vintage','balanced']::public.equipment_tone_characteristic[],
    array['challenge','vp bass','violin bass','short scale bass']::text[]),
  ('bass_guitar','B.C. Rich','NJ Series Mockingbird Bass','NJ Series','B.C. Rich NJ Series Mockingbird Bass','NJ Series Mockingbird bass with dual P-style active pickups.',false,300,'active',
    array['metal','hard_rock','rock']::public.equipment_genre[], array['aggressive','punchy','tight']::public.equipment_tone_characteristic[],
    array['b.c. rich','bc rich','nj series','mockingbird bass']::text[]),
  -- ---------------- electric guitars ----------------
  ('electric_guitar','Squier','Stratocaster','Stratocaster','Squier Stratocaster','Affordable Stratocaster with three single-coil pickups and a 5-way selector.',true,50,'active',
    array['rock','blues','pop']::public.equipment_genre[], array['bright','clean','balanced']::public.equipment_tone_characteristic[],
    array['squier','stratocaster','strat','squier strat','sss']::text[]),
  ('electric_guitar','Squier','Telecaster','Telecaster','Squier Telecaster','Affordable Telecaster with two single-coil pickups — twangy and bright.',true,50,'active',
    array['rock','blues','pop']::public.equipment_genre[], array['bright','articulate','clean']::public.equipment_tone_characteristic[],
    array['squier','telecaster','tele','squier tele','twang']::text[]),
  ('electric_guitar','Squier','Bullet Stratocaster','Bullet','Squier Bullet Stratocaster','Beginner-friendly Stratocaster with three single-coils and a hardtail bridge.',true,60,'active',
    array['rock','blues','pop']::public.equipment_genre[], array['bright','clean','balanced']::public.equipment_tone_characteristic[],
    array['squier','bullet stratocaster','bullet strat','beginner strat']::text[]),
  ('electric_guitar','Squier','Sonic Stratocaster','Sonic','Squier Sonic Stratocaster','Entry-level Sonic-series Stratocaster with three single-coil pickups.',true,60,'active',
    array['rock','blues','pop']::public.equipment_genre[], array['bright','clean','balanced']::public.equipment_tone_characteristic[],
    array['squier','sonic stratocaster','sonic strat','beginner strat']::text[])
on conflict (equipment_type, brand, model)
do update set
  display_name = excluded.display_name,
  description = excluded.description,
  is_popular = excluded.is_popular,
  genres = excluded.genres,
  tone_characteristics = excluded.tone_characteristics,
  search_terms = excluded.search_terms,
  updated_at = now();

commit;
