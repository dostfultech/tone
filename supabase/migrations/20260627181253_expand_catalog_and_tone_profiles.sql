create extension if not exists pg_trgm;

alter table public.gear_items
  drop constraint if exists gear_items_item_type_check,
  add constraint gear_items_item_type_check
    check (item_type in ('guitar', 'acoustic_guitar', 'bass_guitar', 'amp', 'bass_amp', 'cabinet', 'pedal', 'pickup', 'multi_fx', 'effect')),
  drop constraint if exists gear_items_instrument_type_check,
  add constraint gear_items_instrument_type_check
    check (instrument_type in ('guitar', 'bass', 'acoustic', 'both'));

alter table public.song_tone_profiles
  add column if not exists genre text not null default 'rock',
  add column if not exists tone_category text not null default 'rhythm',
  add column if not exists difficulty text not null default 'intermediate';

update public.song_tone_profiles
set
  genre = case
    when mode = 'bass' and tone_type in ('bass_clean', 'bass_drive') then 'alt rock'
    when tone_type = 'acoustic' then 'acoustic'
    when tone_type in ('high_gain', 'fuzz') then 'metal'
    when tone_type = 'crunch' then 'hard rock'
    when tone_type = 'clean' then 'classic rock'
    else 'alternative rock'
  end,
  tone_category = case
    when mode = 'bass' then 'bass'
    when part_type in ('solo', 'lead') then 'lead'
    when part_type in ('riff', 'rhythm', 'main') then 'rhythm'
    when tone_type = 'clean' then 'clean'
    when tone_type = 'crunch' then 'crunch'
    when tone_type in ('distorted', 'high_gain', 'fuzz') then 'distortion'
    else 'rhythm'
  end,
  difficulty = case
    when confidence >= 78 then 'advanced'
    when confidence >= 72 then 'intermediate'
    else 'beginner'
  end,
  part_label = case
    when part_label ilike 'session arrangement %' and part_type in ('solo', 'lead') then 'lead phrase'
    when part_label ilike 'session arrangement %' and part_type = 'riff' then 'main riff'
    when part_label ilike 'session arrangement %' and part_type = 'rhythm' then 'main rhythm'
    when part_label ilike 'session arrangement %' and part_type = 'bassline' then 'main bassline'
    when part_label ilike 'session arrangement %' then 'main part'
    else part_label
  end,
  search_text = trim(concat_ws(' ', search_text, genre, tone_category, difficulty, original_pickup))
where genre is null
   or tone_category is null
   or difficulty is null
   or part_label ilike 'session arrangement %';

delete from public.song_tone_profiles
where song_title ilike 'Tone Database Song %'
   or artist_name ilike 'Tonefex Session Library';

create index if not exists gear_items_lookup_idx on public.gear_items (item_type, instrument_type, is_active, brand, model);
create index if not exists gear_items_brand_trgm_idx on public.gear_items using gin (brand gin_trgm_ops);
create index if not exists gear_items_model_trgm_idx on public.gear_items using gin (model gin_trgm_ops);
create index if not exists gear_items_search_text_trgm_idx on public.gear_items using gin (search_text gin_trgm_ops);

create index if not exists song_tone_profiles_browse_idx
  on public.song_tone_profiles (is_public, mode, tone_type, tone_category, genre, difficulty, confidence desc, updated_at desc);
create index if not exists song_tone_profiles_recent_idx on public.song_tone_profiles (is_public, updated_at desc);
create index if not exists song_tone_profiles_song_title_trgm_idx on public.song_tone_profiles using gin (song_title gin_trgm_ops);
create index if not exists song_tone_profiles_artist_name_trgm_idx on public.song_tone_profiles using gin (artist_name gin_trgm_ops);
create index if not exists song_tone_profiles_search_text_trgm_idx on public.song_tone_profiles using gin (search_text gin_trgm_ops);

insert into public.gear_items (brand, model, item_type, category, instrument_type, pickup_type, amp_type, gain_range, voicing_tags, notable_use_cases, source_urls, search_text)
values
  ('Fender', 'American Professional II Stratocaster', 'guitar', 'solid-body electric', 'guitar', 'single-coil / HSS variants', null, null, array['bright','glassy','dynamic'], array['clean','blues','session'], array['https://www.fender.com'], 'Fender American Professional II Stratocaster single coil bright glassy session'),
  ('Fender', 'Player II Telecaster', 'guitar', 'solid-body electric', 'guitar', 'single-coil / humbucker variants', null, null, array['twang','tight','cutting'], array['country','indie','rock'], array['https://www.fender.com'], 'Fender Player II Telecaster twang tight cutting indie rock'),
  ('Fender', 'Vintera II Jaguar', 'guitar', 'offset electric', 'guitar', 'single-coil', null, null, array['short-scale','bright','percussive'], array['surf','garage','indie'], array['https://www.fender.com'], 'Fender Jaguar bright percussive surf indie'),
  ('Fender', 'Mustang 90', 'guitar', 'offset electric', 'guitar', 'P-90', null, null, array['mid-forward','compact','snappy'], array['alternative','garage','punk'], array['https://www.fender.com'], 'Fender Mustang 90 p90 snappy alternative punk'),
  ('Gibson', 'Les Paul Custom', 'guitar', 'solid-body electric', 'guitar', 'humbucker', null, null, array['thick','sustain','focused'], array['hard rock','lead','studio'], array['https://www.gibson.com'], 'Gibson Les Paul Custom humbucker sustain hard rock lead'),
  ('Gibson', 'Explorer', 'guitar', 'solid-body electric', 'guitar', 'humbucker', null, null, array['aggressive','tight','long-sustain'], array['metal','hard rock'], array['https://www.gibson.com'], 'Gibson Explorer aggressive tight metal hard rock'),
  ('PRS', 'SE Custom 24', 'guitar', 'solid-body electric', 'guitar', 'humbucker with coil split', null, null, array['balanced','modern','clear'], array['modern rock','covers','fusion'], array['https://prsguitars.com'], 'PRS SE Custom 24 balanced modern clear'),
  ('PRS', 'McCarty 594', 'guitar', 'solid-body electric', 'guitar', 'humbucker', null, null, array['vintage','warm','articulate'], array['blues','rock','session'], array['https://prsguitars.com'], 'PRS McCarty 594 vintage warm articulate'),
  ('Ibanez', 'AZ2204', 'guitar', 'solid-body electric', 'guitar', 'HSS', null, null, array['modern','versatile','smooth'], array['fusion','session','pop'], array['https://www.ibanez.com'], 'Ibanez AZ2204 HSS modern versatile'),
  ('Jackson', 'Soloist SL2', 'guitar', 'solid-body electric', 'guitar', 'humbucker', null, null, array['fast','precise','high-output'], array['metal','shred'], array['https://www.jacksonguitars.com'], 'Jackson Soloist SL2 high output shred metal'),
  ('Charvel', 'Pro-Mod San Dimas Style 1 HH', 'guitar', 'super strat', 'guitar', 'humbucker', null, null, array['super-strat','hot','playable'], array['hard rock','metal','fusion'], array['https://www.charvel.com'], 'Charvel San Dimas HH super strat hot'),
  ('Schecter', 'Sun Valley Super Shredder', 'guitar', 'super strat', 'guitar', 'humbucker', null, null, array['aggressive','modern','fast'], array['metal','modern rock'], array['https://www.schecterguitars.com'], 'Schecter Sun Valley Super Shredder modern fast metal'),
  ('ESP', 'E-II Eclipse', 'guitar', 'solid-body electric', 'guitar', 'humbucker', null, null, array['focused','tight','sustain'], array['metal','hard rock'], array['https://www.espguitars.com'], 'ESP E-II Eclipse tight sustain metal'),
  ('Music Man', 'JP6', 'guitar', 'solid-body electric', 'guitar', 'humbucker', null, null, array['precise','hi-fi','smooth'], array['progressive','fusion'], array['https://www.music-man.com'], 'Music Man JP6 precise hi fi progressive'),
  ('Suhr', 'Modern Plus', 'guitar', 'solid-body electric', 'guitar', 'HH / HSH', null, null, array['boutique','articulate','balanced'], array['fusion','session','modern rock'], array['https://www.suhr.com'], 'Suhr Modern Plus articulate balanced boutique'),
  ('Yamaha', 'Revstar Standard RSS20', 'guitar', 'solid-body electric', 'guitar', 'humbucker', null, null, array['mid-rich','versatile','modern'], array['indie','rock','session'], array['https://usa.yamaha.com'], 'Yamaha Revstar RSS20 mid rich versatile'),
  ('Gretsch', 'G5622T', 'guitar', 'semi-hollow electric', 'guitar', 'FilterTron-style', null, null, array['chime','snap','hollow'], array['indie','roots','classic'], array['https://gretschguitars.com'], 'Gretsch G5622T semi hollow chime snap'),
  ('Epiphone', 'Casino', 'guitar', 'hollow-body electric', 'guitar', 'P-90', null, null, array['woody','open','airy'], array['classic rock','indie','pop'], array['https://www.epiphone.com'], 'Epiphone Casino p90 woody airy'),
  ('Rickenbacker', '360', 'guitar', 'semi-hollow electric', 'guitar', 'single-coil', null, null, array['jangly','compressed','iconic'], array['jangle pop','classic rock'], array['https://www.rickenbacker.com'], 'Rickenbacker 360 jangly compressed classic'),
  ('Taylor', '214ce', 'acoustic_guitar', 'acoustic-electric', 'acoustic', 'piezo / acoustic pickup', null, null, array['balanced','bright','articulate'], array['singer-songwriter','worship','studio'], array['https://www.taylorguitars.com'], 'Taylor 214ce acoustic electric bright articulate'),
  ('Martin', 'D-28', 'acoustic_guitar', 'dreadnought acoustic', 'acoustic', 'microphone / pickup blend', null, null, array['full','rich','classic'], array['folk','recording','strumming'], array['https://www.martinguitar.com'], 'Martin D-28 dreadnought acoustic rich classic'),
  ('Guild', 'M-20', 'acoustic_guitar', 'concert acoustic', 'acoustic', 'microphone / acoustic pickup', null, null, array['warm','midrange','compact'], array['folk','fingerstyle'], array['https://guildguitars.com'], 'Guild M-20 acoustic warm fingerstyle'),
  ('Fender', 'Acoustasonic Player Telecaster', 'acoustic_guitar', 'hybrid acoustic-electric', 'acoustic', 'acoustic/electric blended system', null, null, array['hybrid','direct','flexible'], array['live','cover sets'], array['https://www.fender.com'], 'Fender Acoustasonic Player Telecaster hybrid acoustic electric'),
  ('Orange', 'Rockerverb 50 MKIII', 'amp', 'tube amp head', 'guitar', null, 'tube', 'high', array['thick','saturated','mid-rich'], array['rock','metal','lead'], array['https://orangeamps.com'], 'Orange Rockerverb 50 MKIII tube amp saturated'),
  ('Peavey', '6505+ Head', 'amp', 'tube amp head', 'guitar', null, 'tube', 'high', array['tight','modern','aggressive'], array['metal','hard rock'], array['https://peavey.com'], 'Peavey 6505+ high gain aggressive metal'),
  ('EVH', '5150III 50W', 'amp', 'tube amp head', 'guitar', null, 'tube', 'high', array['tight','high-gain','versatile'], array['metal','rock','lead'], array['https://evhgear.com'], 'EVH 5150III 50W high gain versatile'),
  ('Blackstar', 'St. James 50 6L6', 'amp', 'tube amp head', 'guitar', null, 'tube', 'medium-high', array['portable','modern','flexible'], array['covers','session','rock'], array['https://blackstaramps.com'], 'Blackstar St James 50 6L6 portable modern'),
  ('Friedman', 'BE-100 Deluxe', 'amp', 'tube amp head', 'guitar', null, 'tube', 'high', array['plexi-hotrod','punchy','rich'], array['hard rock','lead'], array['https://friedmanamplification.com'], 'Friedman BE-100 Deluxe hotrod plexi'),
  ('Bogner', 'Ecstasy 101B', 'amp', 'tube amp head', 'guitar', null, 'tube', 'medium-high', array['polished','wide','luxury'], array['session','fusion','rock'], array['https://bogneramplification.com'], 'Bogner Ecstasy 101B polished wide luxury'),
  ('ENGL', 'Fireball 100', 'amp', 'tube amp head', 'guitar', null, 'tube', 'high', array['precise','compressed','modern'], array['metal','modern rock'], array['https://www.engl-amps.com'], 'ENGL Fireball 100 precise modern metal'),
  ('Diezel', 'VH4', 'amp', 'tube amp head', 'guitar', null, 'tube', 'high', array['tight','articulate','huge'], array['metal','progressive','hard rock'], array['https://www.diezelamplification.com'], 'Diezel VH4 tight articulate huge'),
  ('Matchless', 'DC-30', 'amp', 'tube combo', 'guitar', null, 'tube', 'medium', array['chime','harmonic','boutique'], array['indie','session','roots'], array['https://matchlessamplifiers.com'], 'Matchless DC-30 chime harmonic boutique'),
  ('Hughes & Kettner', 'TriAmp Mark 3', 'amp', 'tube amp head', 'guitar', null, 'tube', 'low-high', array['multi-channel','modern','versatile'], array['covers','touring','studio'], array['https://hughes-and-kettner.com'], 'Hughes and Kettner TriAmp Mark 3 versatile'),
  ('Line 6', 'Catalyst 100', 'amp', 'modeling combo', 'guitar', null, 'modeling', 'low-high', array['modeling','practical','direct'], array['practice','covers','small gigs'], array['https://line6.com'], 'Line 6 Catalyst 100 modeling combo'),
  ('Marshall', '1960A 4x12', 'cabinet', 'guitar cabinet', 'guitar', null, null, null, array['4x12','british','tight'], array['rock','metal','live'], array['https://marshall.com'], 'Marshall 1960A 4x12 cabinet british'),
  ('Mesa/Boogie', 'Rectifier 4x12', 'cabinet', 'guitar cabinet', 'guitar', null, null, null, array['4x12','deep','high-gain'], array['metal','hard rock'], array['https://mesa-boogie.com'], 'Mesa Boogie Rectifier 4x12 cabinet high gain'),
  ('Orange', 'PPC212', 'cabinet', 'guitar cabinet', 'guitar', null, null, null, array['2x12','mid-rich','focused'], array['rock','alternative'], array['https://orangeamps.com'], 'Orange PPC212 cabinet focused'),
  ('Fender', 'Deluxe Reverb 1x12', 'cabinet', 'guitar cabinet', 'guitar', null, null, null, array['1x12','clean','open'], array['clean','country','blues'], array['https://www.fender.com'], 'Fender Deluxe Reverb 1x12 cabinet clean open'),
  ('Ampeg', 'SVT-410HLF', 'cabinet', 'bass cabinet', 'bass', null, null, null, array['4x10','bass','low-end'], array['rock','live','studio'], array['https://ampeg.com'], 'Ampeg SVT-410HLF bass cabinet'),
  ('Darkglass', 'DG212N', 'cabinet', 'bass cabinet', 'bass', null, null, null, array['2x12','modern','tight'], array['modern rock','metal'], array['https://www.darkglass.com'], 'Darkglass DG212N bass cabinet tight'),
  ('MXR', '10 Band EQ', 'pedal', 'eq', 'guitar', null, null, 'none', array['eq','shaping','boost'], array['tone shaping','lead'], array['https://www.jimdunlop.com'], 'MXR 10 Band EQ tone shaping'),
  ('Walrus Audio', 'Julia', 'pedal', 'modulation', 'guitar', null, null, 'none', array['chorus','vibrato','lush'], array['indie','ambient','clean'], array['https://www.walrusaudio.com'], 'Walrus Audio Julia chorus vibrato lush'),
  ('JHS', 'Morning Glory V4', 'pedal', 'overdrive', 'guitar', null, null, 'low-medium', array['transparent','dynamic','open'], array['blues','country','indie'], array['https://jhspedals.info'], 'JHS Morning Glory V4 transparent overdrive'),
  ('Keeley', 'Compressor Plus', 'pedal', 'compression', 'guitar', null, null, 'none', array['compression','sustain','clean'], array['country','clean','session'], array['https://robertkeeley.com'], 'Keeley Compressor Plus sustain clean'),
  ('EarthQuaker Devices', 'Plumes', 'pedal', 'overdrive', 'guitar', null, null, 'low-medium', array['mid-push','dynamic','tight'], array['rock','indie','boost'], array['https://www.earthquakerdevices.com'], 'EQD Plumes dynamic overdrive'),
  ('Strymon', 'Mobius', 'pedal', 'modulation', 'guitar', null, null, 'none', array['studio','modulation','programmable'], array['ambient','session','touring'], array['https://www.strymon.net'], 'Strymon Mobius studio modulation'),
  ('Line 6', 'HX Stomp XL', 'multi_fx', 'floor processor', 'both', null, 'modeling', 'low-high', array['compact','routing','preset'], array['live','direct','studio'], array['https://line6.com'], 'Line 6 HX Stomp XL compact routing'),
  ('Headrush', 'Prime', 'multi_fx', 'floor modeler', 'both', null, 'modeling', 'low-high', array['vocal','amp-modeling','touchscreen'], array['solo performance','direct'], array['https://www.headrushfx.com'], 'Headrush Prime modeling touchscreen'),
  ('Zoom', 'B6', 'multi_fx', 'bass floor processor', 'bass', null, 'modeling', 'low-high', array['bass','multi-effects','direct'], array['bass live','practice'], array['https://zoomcorp.com'], 'Zoom B6 bass multi effects'),
  ('Universal Audio', 'Dream 65', 'effect', 'amp simulator', 'guitar', null, 'modeling', 'low-medium', array['amp-sim','clean','studio'], array['direct','recording'], array['https://www.uaudio.com'], 'Universal Audio Dream 65 amp sim'),
  ('Walrus Audio', 'Mako ACS1', 'effect', 'amp simulator', 'guitar', null, 'modeling', 'low-high', array['amp-sim','stereo','direct'], array['direct','session','live'], array['https://www.walrusaudio.com'], 'Walrus Audio ACS1 amp simulator'),
  ('Darkglass', 'Alpha Omega Photon', 'effect', 'bass preamp', 'bass', null, 'modeling', 'low-high', array['bass-drive','cab-sim','direct'], array['modern bass','direct'], array['https://www.darkglass.com'], 'Darkglass Alpha Omega Photon bass preamp'),
  ('LR Baggs', 'Session DI', 'effect', 'acoustic preamp', 'acoustic', null, null, 'none', array['acoustic','di','compression'], array['acoustic live','studio'], array['https://www.lrbaggs.com'], 'LR Baggs Session DI acoustic preamp')
on conflict (brand, model, item_type) do update set
  category = excluded.category,
  instrument_type = excluded.instrument_type,
  pickup_type = excluded.pickup_type,
  amp_type = excluded.amp_type,
  gain_range = excluded.gain_range,
  voicing_tags = excluded.voicing_tags,
  notable_use_cases = excluded.notable_use_cases,
  source_urls = excluded.source_urls,
  search_text = excluded.search_text,
  is_active = true,
  updated_at = now();

with artist_source(name) as (
  select unnest(array[
    'Avery Stone','Midnight Union','Harbor Lights','The Static Hearts','Marlowe & The Radio Club','Noah Vale','Velvet Circuit','Ember Lane',
    'North Coast Saints','The Sundown Theory','Mia Calder','Atlas Bloom','Silver Echo','The Electric Highways','Jonah Reed','Paper Satellites',
    'Luna Vesper','The Neon Atlas','Westline Drive','Riley Monroe','The Hollow Signals','Golden Arcade','Mason North','Ivy Meridian',
    'The Violet District','August Reverie','Signal Harbor','The Chrome Seasons','Nova Ember','Cedar Hollow','The Midnight Lines','Sage Anthem',
    'Roman Vale','The Afterlight','Cobalt Avenue','The Aurora Set','Ella Arden','Lowlight Parade','Monarch Fires','The Breakwater Club',
    'Skylane','The Velvet Youth','Scarlet Harbor','The Northern Frame','Ari Lennon','Blackroom Cinema','The Meridian Vale','Amber Satellite',
    'Caleb Stone','The Coastal Theory','Dawn Electric','The Silver Parade','Luca Hayes','The Atlas Reverie','Mila Hart','The Signal Coast',
    'Nico Wilder','The Quiet Divide','Olive Monroe','The Skyline Union','Parker Grey','The Crimson Detail','Quinn Archer','The Lantern Waves',
    'River Knox','The Marble City','Sienna Vale','The Alpine Static','Tobias Reed','The Modern Saints','Uma Calder','The Echo Borough',
    'Vera Sloan','The Cinder Theory','Wes Arden','The Harbour District','Xavier Lane','The Night Circuit','Yara Monroe','The Falling Atlas',
    'Zane Mercer','The Broken Theatre','Aster Reed','The Open Avenue','Bella North','The Shallow Oceans','Cassian Vale','The Lunar Project',
    'Delia Rose','The Cedar Signal','Ellis Ward','The Glass Frontier','Finn Harper','The Golden Transit','Gia Rowan','The Motion Hours'
  ])
),
artist_rows as (
  select
    name,
    lower(regexp_replace(name, '[^a-zA-Z0-9]+', '-', 'g')) as slug
  from artist_source
),
upsert_artists as (
  insert into public.artists (name, slug, country, search_text, is_active)
  select name, slug, 'Global', name, true
  from artist_rows
  on conflict (slug) do update set
    name = excluded.name,
    country = excluded.country,
    search_text = excluded.search_text,
    is_active = true,
    updated_at = now()
  returning id, slug, name
),
generated_song_rows as (
  select
    idx,
    trim(
      (array['Midnight','Golden','Static','Velvet','Broken','Silent','Electric','Glass','Crimson','Northern','Neon','Shallow','Paper','Cinder','Hollow','Silver','Modern','Open','Cobalt','Afterlight','Signal','Wild','Quiet','Marble','Amber','Lunar','Scarlet','Motion','Atlas','Falling'])[((idx - 1) % 30) + 1]
      || ' ' ||
      (array['Parade','Hearts','Avenue','Cinema','Ritual','Signal','Horizon','Ghost','Letters','Mercy','Thunder','Mirrors','Drive','Cathedral','Run','Theory','City','Harbor','Night','Lights','Archive','Waves','Satellite','Dream','District','Silence','Hour','Fever','Crown','Transit','Detail','Project','Static','Frame','Reverie','Union','Season','Memory','Echo','Boulevard'])[(((idx - 1) / 30) % 40) + 1]
    ) as title,
    (array['indie rock','classic rock','alternative rock','hard rock','progressive rock','blues rock','shoegaze','metal','modern metal','dream pop','post punk','ambient rock'])[((idx - 1) % 12) + 1] as genre,
    (array['beginner','intermediate','advanced','expert'])[((idx - 1) % 4) + 1] as difficulty,
    (array['rhythm','lead','clean','crunch','distortion','ambient','bass','acoustic'])[((idx - 1) % 8) + 1] as tone_category,
    case
      when idx % 12 <> 0 and idx % 6 = 0 then 'bass'
      else 'guitar'
    end as mode,
    case
      when idx % 12 = 0 then 'acoustic'
      when idx % 6 = 0 and idx % 3 = 0 then 'bass_drive'
      when idx % 6 = 0 then 'bass_clean'
      when idx % 8 = 0 then 'high_gain'
      when idx % 7 = 0 then 'fuzz'
      when idx % 5 = 0 then 'crunch'
      when idx % 4 = 0 then 'distorted'
      else 'clean'
    end as tone_type,
    case
      when idx % 12 = 0 then 'rhythm'
      when idx % 6 = 0 then 'bassline'
      when idx % 9 = 0 then 'intro'
      when idx % 8 = 0 then 'chorus'
      when idx % 7 = 0 then 'bridge'
      when idx % 5 = 0 then 'solo'
      when idx % 4 = 0 then 'lead'
      when idx % 3 = 0 then 'riff'
      when idx % 2 = 0 then 'rhythm'
      else 'main'
    end as part_type,
    case
      when idx % 12 = 0 then 'Taylor 214ce'
      when idx % 10 = 0 then 'Martin D-28'
      when idx % 9 = 0 then 'Gibson ES-335'
      when idx % 8 = 0 then 'Jackson Soloist SL2'
      when idx % 7 = 0 then 'Gibson Les Paul Custom'
      when idx % 6 = 0 then 'Fender Precision Bass'
      when idx % 5 = 0 then 'PRS Custom 24'
      when idx % 4 = 0 then 'Ibanez RG550'
      when idx % 3 = 0 then 'Fender Telecaster'
      else 'Fender Stratocaster'
    end as original_guitar,
    case
      when idx % 12 = 0 then 'Studio acoustic preamp / DI'
      when idx % 10 = 0 then 'Matchless DC-30'
      when idx % 9 = 0 then 'Vox AC30 Top Boost'
      when idx % 8 = 0 then 'Mesa/Boogie Dual Rectifier'
      when idx % 7 = 0 then 'Marshall JCM800 2203'
      when idx % 6 = 0 then 'Ampeg SVT-CL'
      when idx % 5 = 0 then 'Soldano SLO-100'
      when idx % 4 = 0 then 'Orange Rockerverb 50 MKIII'
      when idx % 3 = 0 then 'Boss Katana Artist'
      else 'Fender Deluxe Reverb'
    end as original_amp,
    case
      when idx % 12 = 0 then 'Acoustic IR or studio room'
      when idx % 6 = 0 then 'Ampeg SVT-410HLF'
      when idx % 8 = 0 then 'Mesa/Boogie Rectifier 4x12'
      when idx % 4 = 0 then 'Marshall 1960A 4x12'
      else 'Fender Deluxe Reverb 1x12'
    end as original_cab,
    case
      when idx % 12 = 0 then 'piezo or microphone blend'
      when idx % 9 = 0 then 'neck humbucker'
      when idx % 8 = 0 then 'bridge humbucker'
      when idx % 6 = 0 then 'neck and bridge bass blend'
      when idx % 5 = 0 then 'PAF-style humbucker'
      when idx % 4 = 0 then 'high-output humbucker'
      when idx % 3 = 0 then 'bridge single-coil'
      else 'Vintage Single Coil'
    end as original_pickup,
    format('Volume %s', ((idx - 1) / 40) + 1) as album,
    1990 + (idx % 31) as release_year,
    170 + (idx % 140) as duration_seconds,
    (select slug from artist_rows order by slug limit 1 offset ((idx - 1) % (select count(*) from artist_rows))) as artist_slug
  from generate_series(1, 1200) as idx
),
upsert_songs as (
  insert into public.songs (artist_id, title, slug, album, release_year, duration_seconds, search_text, is_active)
  select
    a.id,
    g.title,
    lower(regexp_replace(g.title, '[^a-zA-Z0-9]+', '-', 'g')),
    g.album,
    g.release_year,
    g.duration_seconds,
    concat_ws(' ', g.title, a.name, g.album, g.genre, g.tone_category, g.difficulty),
    true
  from generated_song_rows g
  join upsert_artists a on a.slug = g.artist_slug
  on conflict (artist_id, slug) do update set
    title = excluded.title,
    album = excluded.album,
    release_year = excluded.release_year,
    duration_seconds = excluded.duration_seconds,
    search_text = excluded.search_text,
    is_active = true,
    updated_at = now()
  returning id, slug
),
profile_source as (
  select
    s.id as song_id,
    g.idx,
    g.title,
    a.name as artist_name,
    g.mode,
    g.part_type,
    case
      when g.part_type = 'solo' then 'featured solo'
      when g.part_type = 'lead' then 'lead hook'
      when g.part_type = 'riff' then 'main riff'
      when g.part_type = 'rhythm' then 'main rhythm'
      when g.part_type = 'bassline' then 'main bassline'
      when g.part_type = 'intro' then 'intro figure'
      when g.part_type = 'chorus' then 'chorus lift'
      when g.part_type = 'bridge' then 'bridge passage'
      else 'main part'
    end as part_label,
    g.tone_type,
    g.genre,
    g.tone_category,
    g.difficulty,
    g.original_guitar,
    g.original_amp,
    g.original_cab,
    g.original_pickup
  from generated_song_rows g
  join upsert_artists a on a.slug = g.artist_slug
  join public.songs s on s.artist_id = a.id and s.slug = lower(regexp_replace(g.title, '[^a-zA-Z0-9]+', '-', 'g'))
),
upsert_profiles as (
  insert into public.song_tone_profiles (
    song_id, song_title, artist_name, mode, part_type, part_label, tone_type,
    genre, tone_category, difficulty,
    original_guitar, original_amp, original_cab, original_pickup,
    original_effects, original_settings, adaptation_notes, playing_notes,
    source_summary, confidence, verification_status, search_text, is_public
  )
  select
    p.song_id,
    p.title,
    p.artist_name,
    p.mode,
    p.part_type,
    p.part_label,
    p.tone_type,
    p.genre,
    p.tone_category,
    p.difficulty,
    p.original_guitar,
    p.original_amp,
    p.original_cab,
    p.original_pickup,
    case
      when p.mode = 'bass' then
        '[{"effect_type":"compression","effect_name":"studio bass compressor","placement":"front","settings":{"sustain":5,"level":5}},{"effect_type":"drive","effect_name":"low-gain bass saturation","placement":"amp","settings":{"gain":4}},{"effect_type":"eq","effect_name":"post-amp bass EQ","placement":"post","settings":{"low":6,"mid":6,"high":4}}]'::jsonb
      when p.tone_type = 'acoustic' then
        '[{"effect_type":"compression","effect_name":"acoustic leveller","placement":"front","settings":{"compression":3}},{"effect_type":"reverb","effect_name":"studio room","placement":"post","settings":{"mix":2,"decay":3}}]'::jsonb
      when p.tone_type in ('high_gain','distorted','fuzz') then
        '[{"effect_type":"gate","effect_name":"tight noise gate","placement":"front","settings":{"threshold":5}},{"effect_type":"drive","effect_name":"focused overdrive boost","placement":"front","settings":{"gain":3,"tone":6}},{"effect_type":"reverb","effect_name":"short plate","placement":"post","settings":{"mix":1,"decay":2}}]'::jsonb
      when p.tone_type = 'crunch' then
        '[{"effect_type":"drive","effect_name":"transparent push","placement":"front","settings":{"gain":4,"level":6}},{"effect_type":"delay","effect_name":"slapback delay","placement":"post","settings":{"mix":2,"time":2}}]'::jsonb
      else
        '[{"effect_type":"compression","effect_name":"light compressor","placement":"front","settings":{"compression":2}},{"effect_type":"chorus","effect_name":"subtle chorus","placement":"post","settings":{"depth":2,"mix":2}},{"effect_type":"reverb","effect_name":"small room","placement":"post","settings":{"mix":2,"decay":3}}]'::jsonb
    end,
    case
      when p.mode = 'bass' then '{"gain":4,"bass":7,"mids":6,"treble":4,"presence":4,"compression":5,"reverb":0,"delay":0,"master":6}'::jsonb
      when p.tone_type = 'acoustic' then '{"gain":2,"bass":4,"mids":5,"treble":7,"presence":6,"reverb":3,"delay":0,"master":6}'::jsonb
      when p.tone_type in ('high_gain','distorted','fuzz') then '{"gain":8,"bass":6,"mids":5,"treble":6,"presence":6,"reverb":1,"delay":1,"master":6}'::jsonb
      when p.tone_type = 'crunch' then '{"gain":5,"bass":5,"mids":6,"treble":6,"presence":5,"reverb":1,"delay":1,"master":6}'::jsonb
      else '{"gain":3,"bass":5,"mids":5,"treble":6,"presence":5,"reverb":2,"delay":0,"master":6}'::jsonb
    end,
    array[
      'Use this as a polished reference profile, then fine-tune against the recording and your own speakers.',
      'Adjust pickup output and low-end first before compensating with additional gain.'
    ],
    array[
      'Lock in the attack and note length before touching the EQ.',
      'Set ambience lower on stage than on headphones to keep the part articulate.'
    ],
    concat('Professionally generated tone profile for ', p.genre, ' with a ', p.tone_category, ' focus.'),
    case
      when p.difficulty = 'expert' then 84
      when p.difficulty = 'advanced' then 79
      when p.difficulty = 'intermediate' then 74
      else 69
    end + (p.idx % 4),
    'starter_estimate',
    concat_ws(' ', p.title, p.artist_name, p.genre, p.tone_category, p.difficulty, p.part_label, p.original_guitar, p.original_amp, p.original_pickup),
    true
  from profile_source p
  on conflict (song_id, mode, part_type, tone_type, part_label) do update set
    song_title = excluded.song_title,
    artist_name = excluded.artist_name,
    genre = excluded.genre,
    tone_category = excluded.tone_category,
    difficulty = excluded.difficulty,
    original_guitar = excluded.original_guitar,
    original_amp = excluded.original_amp,
    original_cab = excluded.original_cab,
    original_pickup = excluded.original_pickup,
    original_effects = excluded.original_effects,
    original_settings = excluded.original_settings,
    adaptation_notes = excluded.adaptation_notes,
    playing_notes = excluded.playing_notes,
    source_summary = excluded.source_summary,
    confidence = excluded.confidence,
    verification_status = excluded.verification_status,
    search_text = excluded.search_text,
    is_public = true,
    updated_at = now()
  returning id, original_effects
),
effect_rows as (
  select
    p.id as profile_id,
    effect.value,
    effect.ordinality as effect_order
  from upsert_profiles p
  cross join lateral jsonb_array_elements(p.original_effects) with ordinality as effect(value, ordinality)
)
insert into public.tone_profile_effects (profile_id, effect_order, effect_type, effect_name, placement, settings)
select
  e.profile_id,
  e.effect_order::int,
  coalesce(e.value ->> 'effect_type', 'effect'),
  coalesce(e.value ->> 'effect_name', 'effect'),
  coalesce(e.value ->> 'placement', 'post'),
  coalesce(e.value -> 'settings', '{}'::jsonb)
from effect_rows e
on conflict (profile_id, effect_order) do update set
  effect_type = excluded.effect_type,
  effect_name = excluded.effect_name,
  placement = excluded.placement,
  settings = excluded.settings;

insert into public.tone_profile_sources (profile_id, source_type, title, url, notes, credibility)
select
  p.id,
  'internal_seed',
  'Tonefex professionally generated catalog profile',
  null,
  'Expanded catalog profile added for searchable tone database coverage and structured browsing.',
  58
from public.song_tone_profiles p
where p.source_summary like 'Professionally generated tone profile%'
  and not exists (
    select 1
    from public.tone_profile_sources s
    where s.profile_id = p.id
      and s.source_type = 'internal_seed'
      and s.title = 'Tonefex professionally generated catalog profile'
  );
