insert into public.pedal_types (id, label, description, sort_order)
values
  ('wah', 'Wah', 'Wah and filter-expression pedals.', 115)
on conflict (id) do update set
  label = excluded.label,
  description = excluded.description,
  sort_order = excluded.sort_order,
  is_active = true,
  updated_at = now();

insert into public.pedal_brands (name, slug, search_text)
values
  ('Boss', 'boss', 'boss guitar effects pedal'),
  ('Ibanez', 'ibanez', 'ibanez guitar effects pedal'),
  ('MXR', 'mxr', 'mxr guitar effects pedal'),
  ('Electro-Harmonix', 'electro-harmonix', 'electro harmonix guitar effects pedal'),
  ('Pro Co', 'pro-co', 'pro co rat guitar effects pedal'),
  ('Wampler', 'wampler', 'wampler guitar effects pedal'),
  ('JHS', 'jhs', 'jhs guitar effects pedal'),
  ('Strymon', 'strymon', 'strymon guitar effects pedal'),
  ('TC Electronic', 'tc-electronic', 'tc electronic guitar effects pedal'),
  ('Walrus Audio', 'walrus-audio', 'walrus audio guitar effects pedal'),
  ('EarthQuaker Devices', 'earthquaker-devices', 'earthquaker devices guitar effects pedal'),
  ('Keeley', 'keeley', 'keeley guitar effects pedal'),
  ('Xotic', 'xotic', 'xotic guitar effects pedal'),
  ('Fulltone', 'fulltone', 'fulltone guitar effects pedal'),
  ('Dunlop', 'dunlop', 'dunlop guitar effects pedal'),
  ('DigiTech', 'digitech', 'digitech guitar effects pedal'),
  ('Line 6', 'line-6', 'line 6 guitar effects pedal'),
  ('NUX', 'nux', 'nux guitar effects pedal')
on conflict (slug) do update set
  name = excluded.name,
  search_text = excluded.search_text,
  is_active = true,
  updated_at = now();

insert into public.multifx_brands (name, slug, search_text)
values
  ('Line 6', 'line-6', 'line 6 multi fx guitar modeler'),
  ('Fractal Audio', 'fractal', 'fractal audio multi fx guitar modeler'),
  ('Kemper', 'kemper', 'kemper profiler multi fx guitar modeler'),
  ('Neural DSP', 'neural-dsp', 'neural dsp multi fx guitar modeler'),
  ('Boss', 'boss', 'boss multi fx guitar modeler'),
  ('HeadRush', 'headrush', 'headrush multi fx guitar modeler'),
  ('Zoom', 'zoom', 'zoom multi fx guitar modeler'),
  ('Valeton', 'valeton', 'valeton multi fx guitar modeler'),
  ('Mooer', 'mooer', 'mooer multi fx guitar modeler'),
  ('Hotone', 'hotone', 'hotone multi fx guitar modeler'),
  ('NUX', 'nux', 'nux multi fx guitar modeler')
on conflict (slug) do update set
  name = excluded.name,
  search_text = excluded.search_text,
  is_active = true,
  updated_at = now();

insert into public.equipment_manufacturers (name, slug)
select distinct seed.name, public.slugify_gear(seed.name)
from (
  select name from public.pedal_brands where slug in (
    'boss', 'ibanez', 'mxr', 'electro-harmonix', 'pro-co', 'wampler', 'jhs', 'strymon', 'tc-electronic',
    'walrus-audio', 'earthquaker-devices', 'keeley', 'xotic', 'fulltone', 'dunlop', 'digitech', 'line-6', 'nux'
  )
  union all
  select name from public.multifx_brands where slug in (
    'line-6', 'fractal', 'kemper', 'neural-dsp', 'boss', 'headrush', 'zoom', 'valeton', 'mooer', 'hotone', 'nux'
  )
) as seed
on conflict (slug) do update set
  name = excluded.name,
  is_active = true,
  updated_at = now();

delete from public.pedal_models
where model_name ~ '^(Drive|Color|Pulse|Shift|Phase|Signal|Echo|Tone) [A-Z]{3} [0-9]{3}$';

delete from public.multifx_models
where name ~ '^(Prime|Core|Flex|Apex|Axis|Vertex|Pulse|Nova) [0-9]{3}$';

with pedal_seed(brand_name, model_name, category, pedal_type, tags) as (
  values
    -- Boss
    ('Boss', 'DS-1 Distortion', 'distortion', 'distortion', array['ds-1','orange distortion','boss distortion','classic rock']),
    ('Boss', 'DS-2 Turbo Distortion', 'distortion', 'distortion', array['ds-2','turbo distortion','grunge','lead']),
    ('Boss', 'DS-1X Distortion', 'distortion', 'distortion', array['ds-1x','modern distortion','articulate','stacked gain']),
    ('Boss', 'SD-1 Super OverDrive', 'overdrive', 'overdrive', array['sd-1','super overdrive','mid hump','boost']),
    ('Boss', 'OD-3 OverDrive', 'overdrive', 'overdrive', array['od-3','dynamic drive','transparent','classic overdrive']),
    ('Boss', 'BD-2 Blues Driver', 'overdrive', 'overdrive', array['bd-2','blues driver','touch sensitive','blues']),
    ('Boss', 'BD-2W Blues Driver', 'overdrive', 'overdrive', array['bd-2w','waza','blues driver','dynamic']),
    ('Boss', 'JB-2 Angry Driver', 'overdrive', 'overdrive', array['jb-2','angry driver','blues driver','jhs']),
    ('Boss', 'OS-2 OverDrive/Distortion', 'overdrive', 'overdrive', array['os-2','overdrive distortion','hybrid drive','versatile']),
    ('Boss', 'MT-2 Metal Zone', 'distortion', 'distortion', array['mt-2','metal zone','high gain','scooped']),
    ('Boss', 'MT-2W Metal Zone', 'distortion', 'distortion', array['mt-2w','metal zone waza','high gain','tight']),
    ('Boss', 'ML-2 Metal Core', 'distortion', 'distortion', array['ml-2','metal core','modern metal','saturation']),
    ('Boss', 'ST-2 Power Stack', 'distortion', 'distortion', array['st-2','power stack','amp-like','british drive']),
    ('Boss', 'FZ-1W Fuzz', 'fuzz', 'fuzz', array['fz-1w','waza fuzz','vintage fuzz','silicon']),
    ('Boss', 'PW-3 Wah Pedal', 'wah', 'wah', array['pw-3','wah pedal','expression filter','sweep']),
    ('Boss', 'AW-3 Dynamic Wah', 'wah', 'wah', array['aw-3','dynamic wah','auto wah','filter']),
    ('Boss', 'CP-1X Compressor', 'compressor', 'compressor', array['cp-1x','compressor','studio compression','transparent']),
    ('Boss', 'CS-3 Compression Sustainer', 'compressor', 'compressor', array['cs-3','compression sustainer','sustain','country']),
    ('Boss', 'NS-2 Noise Suppressor', 'noise_gate', 'noise_gate', array['ns-2','noise suppressor','gate','high gain cleanup']),
    ('Boss', 'GE-7 Equalizer', 'eq', 'eq', array['ge-7','seven band eq','graphic eq','tone shaping']),
    ('Boss', 'EQ-200 Graphic Equalizer', 'eq', 'eq', array['eq-200','graphic equalizer','dual eq','midi']),
    ('Boss', 'PH-3 Phase Shifter', 'phaser', 'phaser', array['ph-3','phase shifter','step phaser','modulation']),
    ('Boss', 'BF-3 Flanger', 'flanger', 'flanger', array['bf-3','flanger','jet sweep','modulation']),
    ('Boss', 'CH-1 Super Chorus', 'chorus', 'chorus', array['ch-1','super chorus','stereo chorus','clean']),
    ('Boss', 'CE-2W Chorus', 'chorus', 'chorus', array['ce-2w','waza chorus','ce2','analog chorus']),
    ('Boss', 'DC-2W Dimension C', 'chorus', 'chorus', array['dc-2w','dimension c','dimension','spatial chorus']),
    ('Boss', 'MO-2 Multi Overtone', 'pitch', 'pitch', array['mo-2','multi overtone','harmonic enhancer','octave textures']),
    ('Boss', 'OC-5 Octave', 'octaver', 'octaver', array['oc-5','octave','sub octave','riff']),
    ('Boss', 'PS-6 Harmonist', 'pitch', 'pitch', array['ps-6','harmonist','pitch shift','intelligent harmony']),
    ('Boss', 'DD-3T Digital Delay', 'delay', 'delay', array['dd-3t','digital delay','tap tempo','rhythm delay']),
    ('Boss', 'DD-8 Digital Delay', 'delay', 'delay', array['dd-8','digital delay','stereo delay','versatile']),
    ('Boss', 'DM-2W Delay', 'delay', 'delay', array['dm-2w','analog delay','bucket brigade','waza']),
    ('Boss', 'SDE-3 Dual Digital Delay', 'delay', 'delay', array['sde-3','dual digital delay','rack echo','stereo']),
    ('Boss', 'RE-2 Space Echo', 'delay', 'delay', array['re-2','space echo','tape echo','ambient']),
    ('Boss', 'TE-2 Tera Echo', 'delay', 'delay', array['te-2','tera echo','pad-like echo','ambient']),
    ('Boss', 'RV-6 Reverb', 'reverb', 'reverb', array['rv-6','reverb','hall plate spring','ambient']),
    ('Boss', 'RV-200 Reverb', 'reverb', 'reverb', array['rv-200','reverb','stereo reverb','midi']),
    ('Boss', 'BP-1W Booster/Preamp', 'boost', 'boost', array['bp-1w','booster preamp','always on','waza']),

    -- Ibanez
    ('Ibanez', 'TS808 Tube Screamer', 'overdrive', 'overdrive', array['ts808','tube screamer','mid hump','legendary overdrive']),
    ('Ibanez', 'TS9 Tube Screamer', 'overdrive', 'overdrive', array['ts9','tube screamer','tighten low end','mid boost']),
    ('Ibanez', 'TS9DX Turbo Tube Screamer', 'overdrive', 'overdrive', array['ts9dx','turbo tube screamer','multi mode','lead']),
    ('Ibanez', 'Tube Screamer Mini', 'overdrive', 'overdrive', array['tube screamer mini','mini ts','compact overdrive','ts mini']),
    ('Ibanez', 'TS808HW Tube Screamer Hand-Wired', 'overdrive', 'overdrive', array['ts808hw','hand wired','tube screamer','boutique']),
    ('Ibanez', 'TS808DX Overdrive Pro', 'overdrive', 'overdrive', array['ts808dx','overdrive pro','tube screamer','boost']),
    ('Ibanez', 'JD9 Jet Driver', 'distortion', 'distortion', array['jd9','jet driver','gain boost','lead']),
    ('Ibanez', 'BB9 Bottom Booster', 'boost', 'boost', array['bb9','bottom booster','low end boost','fatter tone']),
    ('Ibanez', 'DE7 Delay/Echo', 'delay', 'delay', array['de7','delay echo','digital delay','slapback']),
    ('Ibanez', 'CF7 Chorus/Flanger', 'chorus', 'chorus', array['cf7','chorus flanger','modulation','stereo']),
    ('Ibanez', 'PH7 Phaser', 'phaser', 'phaser', array['ph7','phaser','sweep','modulation']),
    ('Ibanez', 'WD7 Weeping Demon', 'wah', 'wah', array['wd7','weeping demon','wah','expression']),

    -- MXR
    ('MXR', 'Phase 90', 'phaser', 'phaser', array['phase 90','script phaser','evh style','one knob']),
    ('MXR', 'Phase 95', 'phaser', 'phaser', array['phase 95','phase 45','mini phaser','script']),
    ('MXR', 'EVH Phase 90', 'phaser', 'phaser', array['evh phase 90','eddie van halen','script block','brown sound']),
    ('MXR', 'Carbon Copy Analog Delay', 'delay', 'delay', array['carbon copy','analog delay','dark repeats','mod switch']),
    ('MXR', 'Carbon Copy Mini', 'delay', 'delay', array['carbon copy mini','analog delay','compact','modulated']),
    ('MXR', 'Carbon Copy Deluxe', 'delay', 'delay', array['carbon copy deluxe','tap tempo','analog delay','bright switch']),
    ('MXR', 'Joshua Ambient Echo', 'delay', 'delay', array['joshua','ambient echo','preset delay','midi']),
    ('MXR', 'M108S Ten Band EQ', 'eq', 'eq', array['m108s','10 band eq','graphic eq','post gain']),
    ('MXR', 'M109S Six Band EQ', 'eq', 'eq', array['m109s','6 band eq','graphic eq','tone shaping']),
    ('MXR', 'Micro Amp', 'boost', 'boost', array['micro amp','clean boost','always on','solo boost']),
    ('MXR', 'Smart Gate', 'noise_gate', 'noise_gate', array['smart gate','noise gate','tracking gate','tight stops']),
    ('MXR', 'Dyna Comp', 'compressor', 'compressor', array['dyna comp','compressor','country squash','sustain']),
    ('MXR', 'Dyna Comp Mini', 'compressor', 'compressor', array['dyna comp mini','compressor','compact','attack switch']),
    ('MXR', 'Studio Compressor', 'compressor', 'compressor', array['studio compressor','transparent compression','studio','clean']),
    ('MXR', 'Distortion+', 'distortion', 'distortion', array['distortion plus','distortion+','vintage distortion','classic']),
    ('MXR', 'Distortion III', 'distortion', 'distortion', array['distortion iii','distortion 3','tight distortion','classic rock']),
    ('MXR', 'Custom Badass ''78 Distortion', 'distortion', 'distortion', array['78 distortion','custom badass','marshall style','hard rock']),
    ('MXR', 'Fullbore Metal', 'distortion', 'distortion', array['fullbore metal','high gain','metal','scoop']),
    ('MXR', 'GT-OD', 'overdrive', 'overdrive', array['gt-od','green overdrive','tube style','boost']),
    ('MXR', 'Timmy Overdrive', 'overdrive', 'overdrive', array['timmy','transparent overdrive','paul cochrane','low gain']),
    ('MXR', 'Super Badass Dynamic O.D.', 'overdrive', 'overdrive', array['super badass dynamic od','dynamic drive','amp like','touch sensitive']),
    ('MXR', 'Sugar Drive', 'overdrive', 'overdrive', array['sugar drive','klon style','transparent','compact']),
    ('MXR', 'Double-Double Overdrive', 'overdrive', 'overdrive', array['double double','overdrive','two voicings','gain']),
    ('MXR', 'Custom Badass Modified O.D.', 'overdrive', 'overdrive', array['custom badass modified od','overdrive','100hz bump','classic']),
    ('MXR', 'Super Badass Distortion', 'distortion', 'distortion', array['super badass distortion','distortion','three band eq','modern rock']),
    ('MXR', 'Classic 108 Fuzz', 'fuzz', 'fuzz', array['classic 108 fuzz','fuzz face style','buffered fuzz','hendrix']),
    ('MXR', 'Classic 108 Fuzz Mini', 'fuzz', 'fuzz', array['classic 108 fuzz mini','mini fuzz','silicon fuzz','compact']),
    ('MXR', 'Octavio Fuzz', 'fuzz', 'fuzz', array['octavio fuzz','octave fuzz','hendrix fuzz','upper octave']),
    ('MXR', 'Poly Blue Octave', 'octaver', 'octaver', array['poly blue octave','poly octave','detune','organ']),
    ('MXR', 'Analog Chorus', 'chorus', 'chorus', array['analog chorus','chorus','bucket brigade','clean']),
    ('MXR', 'Micro Flanger', 'flanger', 'flanger', array['micro flanger','compact flanger','jet sweep','modulation']),

    -- Electro-Harmonix
    ('Electro-Harmonix', 'Big Muff Pi', 'fuzz', 'fuzz', array['big muff pi','sustain fuzz','wall of sound','lead']),
    ('Electro-Harmonix', 'Nano Big Muff Pi', 'fuzz', 'fuzz', array['nano big muff','compact big muff','sustain fuzz','grunge']),
    ('Electro-Harmonix', 'Op-Amp Big Muff Pi', 'fuzz', 'fuzz', array['op amp big muff','smashing pumpkins','aggressive fuzz','big muff']),
    ('Electro-Harmonix', 'Triangle Big Muff Pi', 'fuzz', 'fuzz', array['triangle big muff','vintage fuzz','triangle muff','lead']),
    ('Electro-Harmonix', 'Ram''s Head Big Muff Pi', 'fuzz', 'fuzz', array['rams head big muff','gilmour fuzz','sustain','vintage']),
    ('Electro-Harmonix', 'Sovtek Deluxe Big Muff Pi', 'fuzz', 'fuzz', array['sovtek deluxe big muff','green russian','mids control','heavy']),
    ('Electro-Harmonix', 'Lizard Queen Octave Fuzz', 'fuzz', 'fuzz', array['lizard queen','octave fuzz','retro fuzz','upper octave']),
    ('Electro-Harmonix', 'Satisfaction Plus Fuzz', 'fuzz', 'fuzz', array['satisfaction plus','garage fuzz','vintage fuzz','bias']),
    ('Electro-Harmonix', 'Soul Food', 'overdrive', 'overdrive', array['soul food','klon style','transparent overdrive','boost']),
    ('Electro-Harmonix', 'East River Drive', 'overdrive', 'overdrive', array['east river drive','tube screamer style','mid hump','drive']),
    ('Electro-Harmonix', 'OD Glove', 'overdrive', 'overdrive', array['od glove','amp style drive','brown sound','gain']),
    ('Electro-Harmonix', 'Hot Wax', 'overdrive', 'overdrive', array['hot wax','dual overdrive','crayon hot tubes','stacked drive']),
    ('Electro-Harmonix', 'Crayon', 'overdrive', 'overdrive', array['crayon','independent bass treble','transparent drive','boost']),
    ('Electro-Harmonix', 'Nano Metal Muff', 'distortion', 'distortion', array['nano metal muff','high gain','metal','noise gate']),
    ('Electro-Harmonix', 'Metal Muff with Noise Gate', 'distortion', 'distortion', array['metal muff','noise gate','high gain','scoop']),
    ('Electro-Harmonix', 'Holy Grail', 'reverb', 'reverb', array['holy grail','reverb','spring hall flerb','classic']),
    ('Electro-Harmonix', 'Holy Grail Neo', 'reverb', 'reverb', array['holy grail neo','compact reverb','spring hall plate','ambient']),
    ('Electro-Harmonix', 'Oceans 11', 'reverb', 'reverb', array['oceans 11','reverb','multi reverb','shimmer']),
    ('Electro-Harmonix', 'Oceans 12', 'reverb', 'reverb', array['oceans 12','stereo reverb','dual engine','ambient']),
    ('Electro-Harmonix', 'Canyon', 'delay', 'delay', array['canyon','delay looper','compact delay','mod echo']),
    ('Electro-Harmonix', 'Grand Canyon', 'delay', 'delay', array['grand canyon','delay looper','multi delay','midi']),
    ('Electro-Harmonix', 'Memory Toy', 'delay', 'delay', array['memory toy','analog delay','dark repeats','compact']),
    ('Electro-Harmonix', 'Memory Boy', 'delay', 'delay', array['memory boy','analog delay','modulation','bucket brigade']),
    ('Electro-Harmonix', 'Deluxe Memory Boy', 'delay', 'delay', array['deluxe memory boy','tap tempo','analog delay','expression']),
    ('Electro-Harmonix', 'Stereo Memory Man with Hazarai', 'delay', 'delay', array['memory man with hazarai','stereo delay','reverse delay','loop']),
    ('Electro-Harmonix', 'Nano Clone', 'chorus', 'chorus', array['nano clone','chorus','small footprint','clean']),
    ('Electro-Harmonix', 'Small Clone', 'chorus', 'chorus', array['small clone','chorus','nirvana','analog']),
    ('Electro-Harmonix', 'Small Stone', 'phaser', 'phaser', array['small stone','phaser','color switch','vintage']),
    ('Electro-Harmonix', 'Bad Stone', 'phaser', 'phaser', array['bad stone','six stage phaser','manual shift','modulation']),
    ('Electro-Harmonix', 'Neo Mistress', 'flanger', 'flanger', array['neo mistress','flanger','electro harmonix flanger','modulation']),
    ('Electro-Harmonix', 'Electric Mistress', 'flanger', 'flanger', array['electric mistress','flanger filter matrix','andy summers','modulation']),
    ('Electro-Harmonix', 'Pitch Fork', 'pitch', 'pitch', array['pitch fork','pitch shifter','detune','octave']),
    ('Electro-Harmonix', 'Pitch Fork+', 'pitch', 'pitch', array['pitch fork plus','dual pitch','intelligent harmony','expression']),
    ('Electro-Harmonix', 'Nano POG', 'octaver', 'octaver', array['nano pog','polyphonic octave','organ tones','tracking']),
    ('Electro-Harmonix', 'Micro POG', 'octaver', 'octaver', array['micro pog','poly octave','organ','clean tracking']),
    ('Electro-Harmonix', 'POG2', 'octaver', 'octaver', array['pog2','poly octave generator','organ','synth textures']),
    ('Electro-Harmonix', 'Tone Corset Analog Compressor', 'compressor', 'compressor', array['tone corset','analog compressor','blend','sustain']),
    ('Electro-Harmonix', 'Platform Compressor/Limiter', 'compressor', 'compressor', array['platform','compressor limiter','studio compressor','swell']),
    ('Electro-Harmonix', 'Cock Fight', 'wah', 'wah', array['cock fight','talk wah','cocked wah','filter']),
    ('Electro-Harmonix', 'Cock Fight Plus', 'wah', 'wah', array['cock fight plus','talk wah','expression','filter']),

    -- Pro Co
    ('Pro Co', 'RAT 2', 'distortion', 'distortion', array['rat 2','rat','hard clipping','classic distortion']),
    ('Pro Co', 'Lil'' RAT', 'distortion', 'distortion', array['lil rat','mini rat','compact distortion','rat']),
    ('Pro Co', 'FAT RAT', 'distortion', 'distortion', array['fat rat','mosfet rat','fatter distortion','rat']),
    ('Pro Co', 'Deucetone RAT', 'distortion', 'distortion', array['deucetone rat','dual rat','distortion','stacked rat']),

    -- Wampler
    ('Wampler', 'Tumnus', 'overdrive', 'overdrive', array['tumnus','klon style','transparent overdrive','boost']),
    ('Wampler', 'Tumnus Deluxe', 'overdrive', 'overdrive', array['tumnus deluxe','klon style','eq controls','transparent']),
    ('Wampler', 'Belle', 'overdrive', 'overdrive', array['belle','single coil overdrive','transparent','low gain']),
    ('Wampler', 'Plexi-Drive', 'overdrive', 'overdrive', array['plexi-drive','marshall style','british crunch','amp like']),
    ('Wampler', 'Plexi-Drive Deluxe', 'overdrive', 'overdrive', array['plexi-drive deluxe','marshall style','boost','stacked drive']),
    ('Wampler', 'Euphoria', 'overdrive', 'overdrive', array['euphoria','smooth drive','dumble style','transparent']),
    ('Wampler', 'Pantheon', 'overdrive', 'overdrive', array['pantheon','bluesbreaker style','open drive','mid control']),
    ('Wampler', 'Pantheon Deluxe', 'overdrive', 'overdrive', array['pantheon deluxe','dual bluesbreaker','stacked drive','midi ready']),
    ('Wampler', 'Pinnacle Deluxe', 'distortion', 'distortion', array['pinnacle deluxe','brown sound','high gain','van halen']),
    ('Wampler', 'Ratsbane', 'distortion', 'distortion', array['ratsbane','rat style','compact distortion','hard clipping']),
    ('Wampler', 'Dracarys', 'distortion', 'distortion', array['dracarys','modern metal','tight lows','high gain']),
    ('Wampler', 'Triumph Overdrive', 'overdrive', 'overdrive', array['triumph','overdrive','two voicings','mid contour']),
    ('Wampler', 'Dual Fusion', 'overdrive', 'overdrive', array['dual fusion','tom quayle','dual overdrive','fusion']),
    ('Wampler', 'Paisley Drive', 'overdrive', 'overdrive', array['paisley drive','brad paisley','country drive','edge of breakup']),
    ('Wampler', 'Moxie', 'overdrive', 'overdrive', array['moxie','tube screamer style','fat switch','boost']),
    ('Wampler', 'Ego Compressor', 'compressor', 'compressor', array['ego compressor','blend compressor','country','sustain']),
    ('Wampler', 'Cory Wong Compressor', 'compressor', 'compressor', array['cory wong compressor','compressor','clean funk','boost']),
    ('Wampler', 'Metaverse', 'delay', 'delay', array['metaverse','multi delay','preset delay','ambient']),
    ('Wampler', 'Ethereal', 'delay', 'delay', array['ethereal','delay reverb','stacked delay','ambient']),
    ('Wampler', 'Catacombs', 'reverb', 'reverb', array['catacombs','reverb delay','ambient','spatial']),
    ('Wampler', 'Terraform', 'chorus', 'chorus', array['terraform','multi modulation','chorus phaser flanger','modulation']),

    -- JHS
    ('JHS', 'Morning Glory V4', 'overdrive', 'overdrive', array['morning glory','bluesbreaker style','transparent','low gain']),
    ('JHS', 'Angry Charlie V3', 'distortion', 'distortion', array['angry charlie','marshall in a box','high gain','jcm800']),
    ('JHS', 'Charlie Brown V4', 'overdrive', 'overdrive', array['charlie brown','marshall style','amp like','classic rock']),
    ('JHS', 'Double Barrel V4', 'overdrive', 'overdrive', array['double barrel','morning glory moonshine','dual overdrive','stacked']),
    ('JHS', 'Moonshine V2', 'overdrive', 'overdrive', array['moonshine','modified tube screamer','more gain','mid hump']),
    ('JHS', 'The Kilt V2', 'overdrive', 'overdrive', array['kilt','expandora style','fuzzy drive','versatile']),
    ('JHS', 'AT+', 'distortion', 'distortion', array['at plus','andy timmons','amp like distortion','boost']),
    ('JHS', 'Bonsai', 'overdrive', 'overdrive', array['bonsai','nine tube screamers','ts style','mid hump']),
    ('JHS', 'PackRat', 'distortion', 'distortion', array['packrat','rat variants','distortion','hard clipping']),
    ('JHS', 'Muffuletta', 'fuzz', 'fuzz', array['muffuletta','big muff variants','fuzz','sustain']),
    ('JHS', 'Cheese Ball', 'fuzz', 'fuzz', array['cheese ball','fuzz','gated fuzz','vintage']),
    ('JHS', 'Pulp ''N'' Peel V4', 'compressor', 'compressor', array['pulp n peel','compressor','blend','preamp']),
    ('JHS', 'Clover Preamp', 'boost', 'boost', array['clover','preamp boost','always on','eq']),
    ('JHS', 'Emperor V2', 'chorus', 'chorus', array['emperor','chorus vibrato','tap tempo','analog']),
    ('JHS', 'Prestige', 'boost', 'boost', array['prestige','boost','always on','touch enhancer']),
    ('JHS', '3 Series Overdrive', 'overdrive', 'overdrive', array['3 series overdrive','budget overdrive','gain','simple']),
    ('JHS', '3 Series Distortion', 'distortion', 'distortion', array['3 series distortion','budget distortion','rock','simple']),
    ('JHS', '3 Series Fuzz', 'fuzz', 'fuzz', array['3 series fuzz','budget fuzz','bias control','simple']),
    ('JHS', '3 Series Chorus', 'chorus', 'chorus', array['3 series chorus','budget chorus','vibrato','simple']),
    ('JHS', '3 Series Delay', 'delay', 'delay', array['3 series delay','budget delay','800ms','simple']),
    ('JHS', '3 Series Reverb', 'reverb', 'reverb', array['3 series reverb','budget reverb','verb','simple']),
    ('JHS', '3 Series Phaser', 'phaser', 'phaser', array['3 series phaser','budget phaser','modulation','simple']),
    ('JHS', '3 Series Compressor', 'compressor', 'compressor', array['3 series compressor','budget compressor','blend','simple']),

    -- Strymon
    ('Strymon', 'Timeline', 'delay', 'delay', array['timeline','multi delay','preset delay','midi']),
    ('Strymon', 'BigSky', 'reverb', 'reverb', array['bigsky','ambient reverb','shimmer','preset']),
    ('Strymon', 'El Capistan', 'delay', 'delay', array['el capistan','tape echo','wow flutter','ambient']),
    ('Strymon', 'blueSky', 'reverb', 'reverb', array['bluesky','plate spring room','reverb','ambient']),
    ('Strymon', 'Deco', 'chorus', 'chorus', array['deco','doubletracker','tape saturation','chorus']),
    ('Strymon', 'Flint', 'reverb', 'reverb', array['flint','tremolo reverb','vintage ambience','spring']),
    ('Strymon', 'Riverside', 'overdrive', 'overdrive', array['riverside','overdrive','amp feel','midi']),
    ('Strymon', 'Sunset', 'overdrive', 'overdrive', array['sunset','dual overdrive','stacked drive','midi']),
    ('Strymon', 'Mobius', 'chorus', 'chorus', array['mobius','multi modulation','chorus phaser flanger','preset']),
    ('Strymon', 'Volante', 'delay', 'delay', array['volante','drum echo','tape delay','ambient']),
    ('Strymon', 'Cloudburst', 'reverb', 'reverb', array['cloudburst','ensemble reverb','ambient','pad']),
    ('Strymon', 'Brig', 'delay', 'delay', array['brig','bucket brigade delay','analog delay','compact']),
    ('Strymon', 'Zelzah', 'phaser', 'phaser', array['zelzah','phaser','multi phase','stereo']),
    ('Strymon', 'Compadre', 'compressor', 'compressor', array['compadre','compressor boost','studio comp','boost']),
    ('Strymon', 'Lex V2', 'chorus', 'chorus', array['lex','rotary speaker','chorale tremolo','modulation']),

    -- TC Electronic
    ('TC Electronic', 'Hall of Fame 2 Reverb', 'reverb', 'reverb', array['hall of fame 2','hof2','reverb','toneprint']),
    ('TC Electronic', 'Hall of Fame 2 X4 Reverb', 'reverb', 'reverb', array['hall of fame 2 x4','hof2 x4','stereo reverb','toneprint']),
    ('TC Electronic', 'Flashback 2 Delay', 'delay', 'delay', array['flashback 2','delay','toneprint','mash']),
    ('TC Electronic', 'Flashback 2 X4 Delay', 'delay', 'delay', array['flashback 2 x4','delay','preset delay','stereo']),
    ('TC Electronic', 'Corona Chorus', 'chorus', 'chorus', array['corona chorus','chorus','toneprint','tri chorus']),
    ('TC Electronic', 'Vortex Flanger', 'flanger', 'flanger', array['vortex flanger','flanger','toneprint','modulation']),
    ('TC Electronic', 'Sub ''N'' Up Octaver', 'octaver', 'octaver', array['sub n up','octaver','poly octave','toneprint']),
    ('TC Electronic', 'HyperGravity Compressor', 'compressor', 'compressor', array['hypergravity','compressor','multiband','toneprint']),
    ('TC Electronic', 'Spark Mini Booster', 'boost', 'boost', array['spark mini','clean boost','one knob','solo boost']),
    ('TC Electronic', 'Spark Booster', 'boost', 'boost', array['spark booster','boost','eq switch','always on']),
    ('TC Electronic', 'Sentry Noise Gate', 'noise_gate', 'noise_gate', array['sentry','noise gate','toneprint','tight metal']),
    ('TC Electronic', 'MojoMojo Overdrive', 'overdrive', 'overdrive', array['mojomojo','overdrive','thick drive','budget']),
    ('TC Electronic', 'Dark Matter Distortion', 'distortion', 'distortion', array['dark matter','distortion','marshall style','gain']),
    ('TC Electronic', 'Skysurfer Reverb', 'reverb', 'reverb', array['skysurfer','reverb','budget reverb','plate spring room']),
    ('TC Electronic', 'Rusty Fuzz', 'fuzz', 'fuzz', array['rusty fuzz','budget fuzz','vintage fuzz','garage']),
    ('TC Electronic', 'June-60 Chorus', 'chorus', 'chorus', array['june 60','chorus','juno style','stereo']),

    -- Walrus Audio
    ('Walrus Audio', '385 Overdrive MKII', 'overdrive', 'overdrive', array['385','amp like overdrive','cinematic','preamp']),
    ('Walrus Audio', 'Voyager', 'overdrive', 'overdrive', array['voyager','overdrive','transparent','klon adjacent']),
    ('Walrus Audio', 'Ages', 'overdrive', 'overdrive', array['ages','multi stage overdrive','five modes','stacked']),
    ('Walrus Audio', 'Warhorn', 'overdrive', 'overdrive', array['warhorn','overdrive','soft clipping','amp like']),
    ('Walrus Audio', 'Iron Horse V3', 'distortion', 'distortion', array['iron horse','rat style','distortion','three clipping modes']),
    ('Walrus Audio', 'Eons', 'fuzz', 'fuzz', array['eons','fuzz','five fuzz modes','voltage control']),
    ('Walrus Audio', 'Silt', 'fuzz', 'fuzz', array['silt','fuzz','harmonic fuzz','earthquaker']),
    ('Walrus Audio', 'EB-10', 'boost', 'boost', array['eb-10','eq boost','preset eq','solo boost']),
    ('Walrus Audio', 'Deep Six V3', 'compressor', 'compressor', array['deep six','compressor','blend','studio']),
    ('Walrus Audio', 'Mira', 'compressor', 'compressor', array['mira','optical compressor','studio comp','threshold']),
    ('Walrus Audio', 'ARP-87', 'delay', 'delay', array['arp 87','delay','digital analog lofi slap','ambient']),
    ('Walrus Audio', 'Mako D1', 'delay', 'delay', array['mako d1','stereo delay','preset delay','midi']),
    ('Walrus Audio', 'Mako R1', 'reverb', 'reverb', array['mako r1','stereo reverb','preset reverb','midi']),
    ('Walrus Audio', 'Fathom', 'reverb', 'reverb', array['fathom','ambient reverb','hall plate shimmer','modulated']),
    ('Walrus Audio', 'Slö', 'reverb', 'reverb', array['slo','ambient reverb','dream mode','pad']),
    ('Walrus Audio', 'Slöer', 'reverb', 'reverb', array['sloer','stereo ambient reverb','pad','sustain']),
    ('Walrus Audio', 'Lore', 'delay', 'delay', array['lore','reverse delay','storytelling','ambient']),
    ('Walrus Audio', 'Fable', 'delay', 'delay', array['fable','granular delay','sample based','ambient']),
    ('Walrus Audio', 'Julia V2', 'chorus', 'chorus', array['julia','chorus vibrato','analog chorus','modulation']),
    ('Walrus Audio', 'Julianna', 'chorus', 'chorus', array['julianna','stereo chorus','vibrato','tap tempo']),
    ('Walrus Audio', 'Fundamental Drive', 'overdrive', 'overdrive', array['fundamental drive','overdrive','budget series','simple']),
    ('Walrus Audio', 'Fundamental Distortion', 'distortion', 'distortion', array['fundamental distortion','distortion','budget series','simple']),
    ('Walrus Audio', 'Fundamental Fuzz', 'fuzz', 'fuzz', array['fundamental fuzz','fuzz','budget series','simple']),
    ('Walrus Audio', 'Fundamental Chorus', 'chorus', 'chorus', array['fundamental chorus','chorus','budget series','simple']),
    ('Walrus Audio', 'Fundamental Delay', 'delay', 'delay', array['fundamental delay','delay','budget series','simple']),
    ('Walrus Audio', 'Fundamental Reverb', 'reverb', 'reverb', array['fundamental reverb','reverb','budget series','simple']),

    -- EarthQuaker Devices
    ('EarthQuaker Devices', 'Plumes', 'overdrive', 'overdrive', array['plumes','tube screamer style','three clipping modes','boost']),
    ('EarthQuaker Devices', 'Special Cranker', 'overdrive', 'overdrive', array['special cranker','low gain drive','touch sensitive','amp like']),
    ('EarthQuaker Devices', 'Zoar', 'distortion', 'distortion', array['zoar','distortion','three band eq','gain']),
    ('EarthQuaker Devices', 'Acapulco Gold', 'distortion', 'distortion', array['acapulco gold','one knob distortion','amp destruction','doom']),
    ('EarthQuaker Devices', 'Westwood', 'overdrive', 'overdrive', array['westwood','transparent overdrive','eq controls','amp like']),
    ('EarthQuaker Devices', 'Hoof', 'fuzz', 'fuzz', array['hoof','hybrid muff fuzz','mid control','sustain']),
    ('EarthQuaker Devices', 'Hizumitas', 'fuzz', 'fuzz', array['hizumitas','fuzz sustainer','thick fuzz','doom']),
    ('EarthQuaker Devices', 'Bit Commander', 'octaver', 'octaver', array['bit commander','analog octave synth','sub octave','organ']),
    ('EarthQuaker Devices', 'Rainbow Machine', 'pitch', 'pitch', array['rainbow machine','pitch shifting modulation','magic','detune']),
    ('EarthQuaker Devices', 'Dispatch Master', 'delay', 'delay', array['dispatch master','delay reverb','ambient','post rock']),
    ('EarthQuaker Devices', 'Avalanche Run', 'delay', 'delay', array['avalanche run','stereo delay reverb','expression','ambient']),
    ('EarthQuaker Devices', 'Afterneath', 'reverb', 'reverb', array['afterneath','otherworldly reverb','cavern','ambient']),
    ('EarthQuaker Devices', 'Ghost Echo', 'reverb', 'reverb', array['ghost echo','reverb','haunted spring','ambient']),
    ('EarthQuaker Devices', 'Sea Machine', 'chorus', 'chorus', array['sea machine','chorus','pitch modulation','experimental']),
    ('EarthQuaker Devices', 'Grand Orbiter', 'phaser', 'phaser', array['grand orbiter','phaser','lfo sweep','vintage']),
    ('EarthQuaker Devices', 'Pyramids', 'flanger', 'flanger', array['pyramids','stereo flanger','preset flanger','modulation']),
    ('EarthQuaker Devices', 'Aurelius', 'chorus', 'chorus', array['aurelius','tri voice chorus','vibrato','modulation']),
    ('EarthQuaker Devices', 'Data Corrupter', 'pitch', 'pitch', array['data corrupter','harmonic synth','octave pitch','wild']),
    ('EarthQuaker Devices', 'Tone Job', 'eq', 'eq', array['tone job','eq boost','three band eq','utility']),
    ('EarthQuaker Devices', 'Blumes', 'fuzz', 'fuzz', array['blumes','bass fuzz drive','clipping modes','heavy']),
    ('EarthQuaker Devices', 'Ledges', 'reverb', 'reverb', array['ledges','three mode reverb','ambient','preset']),
    ('EarthQuaker Devices', 'Silos', 'delay', 'delay', array['silos','multi delay','mod reverse tape','ambient']),
    ('EarthQuaker Devices', 'Arrows', 'boost', 'boost', array['arrows','preamp booster','always on','clarity']),

    -- Keeley
    ('Keeley', 'Compressor Plus', 'compressor', 'compressor', array['compressor plus','compressor','blend','country']),
    ('Keeley', 'Katana Clean Boost', 'boost', 'boost', array['katana','clean boost','always on','touch enhancer']),
    ('Keeley', 'Noble Screamer', 'overdrive', 'overdrive', array['noble screamer','ts and odr blend','mid push','versatile']),
    ('Keeley', 'D&M Drive', 'overdrive', 'overdrive', array['dm drive','dual overdrive','boost','dan and mick']),
    ('Keeley', 'Oxblood', 'overdrive', 'overdrive', array['oxblood','transparent overdrive','mid sculpt','amp like']),
    ('Keeley', 'Fuzz Bender', 'fuzz', 'fuzz', array['fuzz bender','bias fuzz','active eq','vintage to gated']),
    ('Keeley', 'Halo', 'delay', 'delay', array['halo','andy timmons delay','dual echo','ambient lead']),
    ('Keeley', 'ECCOS', 'delay', 'delay', array['eccos','delay looper','tape style','modulation']),
    ('Keeley', 'Caverns V2', 'delay', 'delay', array['caverns','delay reverb','ambient','post rock']),
    ('Keeley', 'Hydra', 'reverb', 'reverb', array['hydra','reverb tremolo','stereo','ambient']),
    ('Keeley', 'Seafoam Plus', 'chorus', 'chorus', array['seafoam plus','chorus','double tracker','vibrato']),
    ('Keeley', 'Dyno My Roto', 'chorus', 'chorus', array['dyno my roto','tri chorus rotary flange','modulation','80s']),
    ('Keeley', 'Super AT Mod', 'chorus', 'chorus', array['super at mod','andy timmons','chorus delay reverb','modulation']),
    ('Keeley', 'DDR Drive-Delay-Reverb', 'delay', 'delay', array['ddr','drive delay reverb','three effects','compact']),
    ('Keeley', 'Neutrino V2', 'wah', 'wah', array['neutrino','envelope filter','auto wah','funk']),
    ('Keeley', 'Luna Overdrive', 'overdrive', 'overdrive', array['luna','overdrive','transparent','low gain']),

    -- Xotic
    ('Xotic', 'EP Booster', 'boost', 'boost', array['ep booster','echoplex preamp','clean boost','always on']),
    ('Xotic', 'RC Booster V2', 'boost', 'boost', array['rc booster','transparent boost','eq','always on']),
    ('Xotic', 'AC Booster V2', 'overdrive', 'overdrive', array['ac booster','smooth overdrive','mid rich','lead']),
    ('Xotic', 'BB Preamp V1.5', 'overdrive', 'overdrive', array['bb preamp','mid gain','lead boost','amp like']),
    ('Xotic', 'SP Compressor', 'compressor', 'compressor', array['sp compressor','mini compressor','blend','country']),
    ('Xotic', 'SL Drive', 'overdrive', 'overdrive', array['sl drive','marshall style','mini drive','classic rock']),
    ('Xotic', 'Soul Driven', 'overdrive', 'overdrive', array['soul driven','smooth overdrive','dumble style','lead']),
    ('Xotic', 'XW-1 Wah', 'wah', 'wah', array['xw-1','wah','multi contour','expression']),

    -- Fulltone
    ('Fulltone', 'OCD', 'overdrive', 'overdrive', array['ocd','obsessive compulsive drive','amp like','dynamic']),
    ('Fulltone', 'Full-Drive 2 MOSFET', 'overdrive', 'overdrive', array['full-drive 2','mosfet overdrive','boost','tube style']),
    ('Fulltone', 'Full-Drive 3', 'overdrive', 'overdrive', array['full-drive 3','overdrive boost','mosfet','stacked']),
    ('Fulltone', 'Plimsoul', 'overdrive', 'overdrive', array['plimsoul','soft hard clipping','overdrive','gain']),
    ('Fulltone', 'Soul-Bender', 'fuzz', 'fuzz', array['soul-bender','tone bender style','vintage fuzz','sustain']),
    ('Fulltone', '''69 MKII', 'fuzz', 'fuzz', array['69 mkii','fuzz face style','germanium fuzz','cleanup']),
    ('Fulltone', 'Clyde Deluxe Wah', 'wah', 'wah', array['clyde deluxe','wah','three voices','sweep']),
    ('Fulltone', 'Secret Freq', 'overdrive', 'overdrive', array['secret freq','overdrive','mid boost','lead']),

    -- Dunlop
    ('Dunlop', 'Cry Baby GCB95', 'wah', 'wah', array['gcb95','cry baby','wah','classic sweep']),
    ('Dunlop', 'Cry Baby 535Q', 'wah', 'wah', array['535q','cry baby 535q','wah','q control']),
    ('Dunlop', 'Cry Baby Mini 535Q', 'wah', 'wah', array['mini 535q','cry baby mini','wah','compact']),
    ('Dunlop', 'Cry Baby Junior', 'wah', 'wah', array['cry baby junior','wah','compact','three voices']),
    ('Dunlop', 'Cry Baby From Hell', 'wah', 'wah', array['cry baby from hell','dimebag','wah','metal']),
    ('Dunlop', 'Jimi Hendrix Fuzz Face', 'fuzz', 'fuzz', array['jimi hendrix fuzz face','fuzz face','hendrix','silicon fuzz']),
    ('Dunlop', 'Germanium Fuzz Face Mini', 'fuzz', 'fuzz', array['germanium fuzz face mini','fuzz face mini','cleanup','vintage']),
    ('Dunlop', 'Silicon Fuzz Face Mini', 'fuzz', 'fuzz', array['silicon fuzz face mini','fuzz face mini','bright fuzz','lead']),
    ('Dunlop', 'Band of Gypsys Fuzz Face Mini', 'fuzz', 'fuzz', array['band of gypsys fuzz face','hendrix','aggressive fuzz','mini']),
    ('Dunlop', 'Joe Bonamassa Fuzz Face Mini', 'fuzz', 'fuzz', array['bonamassa fuzz face','fuzz face mini','silicon','lead']),
    ('Dunlop', 'Echoplex Delay', 'delay', 'delay', array['echoplex delay','ep103','tape echo','ambient']),
    ('Dunlop', 'Echoplex Preamp', 'boost', 'boost', array['echoplex preamp','ep101','preamp boost','always on']),
    ('Dunlop', 'Uni-Vibe Chorus/Vibrato', 'chorus', 'chorus', array['uni-vibe','chorus vibrato','hendrix swirl','modulation']),
    ('Dunlop', 'Octavio Mini', 'fuzz', 'fuzz', array['octavio mini','octave fuzz','hendrix fuzz','mini']),

    -- DigiTech
    ('DigiTech', 'Whammy 5', 'pitch', 'pitch', array['whammy 5','whammy','expression pitch','harmonizer']),
    ('DigiTech', 'Whammy Ricochet', 'pitch', 'pitch', array['whammy ricochet','momentary pitch','drop rise','compact']),
    ('DigiTech', 'Drop', 'pitch', 'pitch', array['drop','drop tune','poly pitch','down tuning']),
    ('DigiTech', 'FreqOut', 'pitch', 'pitch', array['freqout','feedback creator','synthetic feedback','lead']),
    ('DigiTech', 'Mosaic', 'pitch', 'pitch', array['mosaic','12 string emulator','octave','chime']),
    ('DigiTech', 'Polara', 'reverb', 'reverb', array['polara','reverb','lexicon reverb','ambient']),
    ('DigiTech', 'Obscura', 'delay', 'delay', array['obscura','delay','analog tape lofi reverse','ambient']),
    ('DigiTech', 'Nautila', 'chorus', 'chorus', array['nautila','chorus flanger','stereo','modulation']),
    ('DigiTech', 'Dirty Robot', 'pitch', 'pitch', array['dirty robot','synth pedal','vocoder style','filter']),
    ('DigiTech', 'Bad Monkey', 'overdrive', 'overdrive', array['bad monkey','overdrive','tube style','budget classic']),

    -- Line 6 pedals
    ('Line 6', 'DL4 MkII', 'delay', 'delay', array['dl4 mkii','delay modeler','looper','classic line 6 delay']),
    ('Line 6', 'DL4 Delay Modeler', 'delay', 'delay', array['dl4','delay modeler','green delay','looper']),
    ('Line 6', 'MM4 Modulation Modeler', 'chorus', 'chorus', array['mm4','modulation modeler','chorus phase flange','preset']),
    ('Line 6', 'DM4 Distortion Modeler', 'distortion', 'distortion', array['dm4','distortion modeler','multiple drives','preset']),
    ('Line 6', 'FM4 Filter Modeler', 'wah', 'wah', array['fm4','filter modeler','auto wah','synth filter']),
    ('Line 6', 'M5 Stompbox Modeler', 'delay', 'delay', array['m5','stompbox modeler','single effect','multi fx pedal']),
    ('Line 6', 'M9 Stompbox Modeler', 'delay', 'delay', array['m9','stompbox modeler','multi effect','scene']),
    ('Line 6', 'M13 Stompbox Modeler', 'delay', 'delay', array['m13','stompbox modeler','multi effect floorboard','scene']),
    ('Line 6', 'Echo Park', 'delay', 'delay', array['echo park','delay','tape analog digital','compact']),
    ('Line 6', 'Liqua-Flange', 'flanger', 'flanger', array['liqua flange','flanger','modulation','compact']),
    ('Line 6', 'Space Chorus', 'chorus', 'chorus', array['space chorus','chorus','stereo modulation','compact']),
    ('Line 6', 'Uber Metal', 'distortion', 'distortion', array['uber metal','metal distortion','high gain','scoop']),

    -- NUX pedals
    ('NUX', 'Cerberus', 'overdrive', 'overdrive', array['cerberus','multi effect pedalboard','overdrive delay reverb','compact rig']),
    ('NUX', 'Horseman', 'overdrive', 'overdrive', array['horseman','klon style','transparent','boost']),
    ('NUX', 'Queen of Tone', 'overdrive', 'overdrive', array['queen of tone','dual overdrive','bluesbreaker klon','stacked']),
    ('NUX', 'Morning Star', 'overdrive', 'overdrive', array['morning star','low gain overdrive','transparent','blues']),
    ('NUX', 'Brownie', 'distortion', 'distortion', array['brownie','marshall style distortion','british drive','gain']),
    ('NUX', 'Atlantic Delay & Reverb', 'delay', 'delay', array['atlantic','delay reverb','ambient','post effects']),
    ('NUX', 'Tape Core Deluxe', 'delay', 'delay', array['tape core deluxe','tape echo','delay','wow flutter']),
    ('NUX', 'Duotime', 'delay', 'delay', array['duotime','dual delay','tap tempo','ambient']),
    ('NUX', 'Mod Core Deluxe MKII', 'chorus', 'chorus', array['mod core deluxe','modulation','chorus phaser flanger','stereo']),
    ('NUX', 'Masamune', 'compressor', 'compressor', array['masamune','compressor boost','dual effect','clean']),
    ('NUX', 'Steel Singer Drive', 'overdrive', 'overdrive', array['steel singer','smooth overdrive','dumble style','lead']),
    ('NUX', 'Sculpture', 'compressor', 'compressor', array['sculpture','compressor','blend compressor','clean'])
),
pedal_brand_lookup as (
  select pb.id as brand_id, pb.name as brand_name, pb.slug as brand_slug, em.id as manufacturer_id
  from public.pedal_brands pb
  join public.equipment_manufacturers em on em.slug = pb.slug
),
upsert_pedals as (
  insert into public.pedal_models (
    manufacturer_id,
    brand_id,
    model_name,
    name,
    slug,
    category,
    pedal_type,
    pedal_type_id,
    tags,
    metadata,
    is_active
  )
  select
    lookup.manufacturer_id,
    lookup.brand_id,
    seed.model_name,
    seed.model_name,
    public.slugify_gear(concat(seed.brand_name, ' ', seed.model_name)),
    seed.category,
    seed.pedal_type,
    seed.pedal_type,
    seed.tags,
    jsonb_build_object(
      'catalog', 'verified_real_world',
      'source', 'manufacturer_and_retailer_curation',
      'seed_version', '20260718123000',
      'brand', seed.brand_name
    ),
    true
  from pedal_seed seed
  join pedal_brand_lookup lookup on lookup.brand_name = seed.brand_name
  on conflict (brand_id, slug)
  where brand_id is not null and slug is not null
  do nothing
  returning 1
)
select count(*) from upsert_pedals;

with multifx_seed(brand_name, model_name, category, tags) as (
  values
    -- Line 6
    ('Line 6', 'Helix Floor', 'floorboard', array['helix floor','helix','amp modeler','stage rig']),
    ('Line 6', 'Helix LT', 'floorboard', array['helix lt','helix','amp modeler','stage rig']),
    ('Line 6', 'Helix Rack', 'rack', array['helix rack','helix','rack modeler','studio']),
    ('Line 6', 'HX Stomp', 'stomp', array['hx stomp','helix stomp','amp modeler','compact']),
    ('Line 6', 'HX Stomp XL', 'stomp', array['hx stomp xl','helix stomp','more footswitches','compact']),
    ('Line 6', 'HX Effects', 'stomp', array['hx effects','helix effects','multi effects','pedalboard']),
    ('Line 6', 'POD Go', 'floorboard', array['pod go','line 6 pod','amp modeler','budget modeler']),
    ('Line 6', 'POD Go Wireless', 'floorboard', array['pod go wireless','pod go','wireless modeler','floorboard']),
    ('Line 6', 'POD HD500X', 'floorboard', array['pod hd500x','pod hd','multi fx','stage']),
    ('Line 6', 'POD HD500', 'floorboard', array['pod hd500','pod hd','multi fx','stage']),
    ('Line 6', 'POD HD Pro X', 'rack', array['pod hd pro x','pod hd rack','rack modeler','studio']),
    ('Line 6', 'POD HD Pro', 'rack', array['pod hd pro','pod hd rack','rack modeler','studio']),
    ('Line 6', 'Firehawk FX', 'floorboard', array['firehawk fx','wireless modeler','multi fx','stage']),
    ('Line 6', 'AMPLIFi FX100', 'floorboard', array['amplifi fx100','desktop modeler','multi fx','practice']),
    ('Line 6', 'M13 Stompbox Modeler', 'floorboard', array['m13','stompbox modeler','effects modeler','scene']),
    ('Line 6', 'M9 Stompbox Modeler', 'floorboard', array['m9','stompbox modeler','effects modeler','compact']),
    ('Line 6', 'M5 Stompbox Modeler', 'stomp', array['m5','stompbox modeler','single effect','compact']),

    -- Fractal Audio
    ('Fractal Audio', 'Axe-Fx III', 'rack', array['axe-fx iii','fractal','rack modeler','studio']),
    ('Fractal Audio', 'Axe-Fx III Mark II', 'rack', array['axe-fx iii mark ii','fractal','rack modeler','studio']),
    ('Fractal Audio', 'Axe-Fx III Turbo', 'rack', array['axe-fx iii turbo','fractal','rack modeler','touring']),
    ('Fractal Audio', 'FM9', 'floorboard', array['fm9','fractal','floor modeler','stage']),
    ('Fractal Audio', 'FM9 Turbo', 'floorboard', array['fm9 turbo','fractal','floor modeler','stage']),
    ('Fractal Audio', 'FM3', 'stomp', array['fm3','fractal','compact modeler','stage']),
    ('Fractal Audio', 'FM3 Turbo', 'stomp', array['fm3 turbo','fractal','compact modeler','stage']),
    ('Fractal Audio', 'AX8', 'floorboard', array['ax8','fractal','floorboard modeler','stage']),
    ('Fractal Audio', 'FX8', 'floorboard', array['fx8','fractal','effects processor','four cable method']),
    ('Fractal Audio', 'Axe-Fx II XL+', 'rack', array['axe-fx ii xl+','fractal','rack modeler','studio']),
    ('Fractal Audio', 'Axe-Fx II XL', 'rack', array['axe-fx ii xl','fractal','rack modeler','studio']),

    -- Kemper
    ('Kemper', 'Profiler Head', 'head', array['profiler head','kemper','profiling amp','stage']),
    ('Kemper', 'Profiler Rack', 'rack', array['profiler rack','kemper','profiling amp','studio']),
    ('Kemper', 'Profiler Stage', 'floorboard', array['profiler stage','kemper','profiling amp','floorboard']),
    ('Kemper', 'Profiler Player', 'stomp', array['profiler player','kemper','compact profiler','pedalboard']),
    ('Kemper', 'PowerHead', 'head', array['powerhead','kemper','powered profiler','stage']),
    ('Kemper', 'PowerRack', 'rack', array['powerrack','kemper','powered profiler','rack']),

    -- Neural DSP
    ('Neural DSP', 'Quad Cortex', 'floorboard', array['quad cortex','neural dsp','modeler','capture']),
    ('Neural DSP', 'Quad Cortex Mini', 'stomp', array['quad cortex mini','neural dsp','compact modeler','capture']),

    -- Boss
    ('Boss', 'GT-1000', 'floorboard', array['gt-1000','boss modeler','multi fx','stage']),
    ('Boss', 'GT-1000CORE', 'stomp', array['gt-1000core','boss modeler','compact multi fx','pedalboard']),
    ('Boss', 'GX-100', 'floorboard', array['gx-100','boss gx','touchscreen modeler','stage']),
    ('Boss', 'GX-10', 'floorboard', array['gx-10','boss gx','compact floorboard','multi fx']),
    ('Boss', 'GT-100', 'floorboard', array['gt-100','boss gt','multi fx','stage']),
    ('Boss', 'GT-10', 'floorboard', array['gt-10','boss gt','multi fx','stage']),
    ('Boss', 'GT-1', 'floorboard', array['gt-1','boss gt','compact multi fx','practice']),
    ('Boss', 'ME-90', 'floorboard', array['me-90','boss me','multi effects','pedal style']),
    ('Boss', 'ME-80', 'floorboard', array['me-80','boss me','multi effects','pedal style']),
    ('Boss', 'ME-50', 'floorboard', array['me-50','boss me','multi effects','pedal style']),
    ('Boss', 'ME-25', 'floorboard', array['me-25','boss me','multi effects','practice']),

    -- HeadRush
    ('HeadRush', 'Pedalboard', 'floorboard', array['pedalboard','headrush','amp modeler','touchscreen']),
    ('HeadRush', 'Gigboard', 'floorboard', array['gigboard','headrush','compact touch modeler','stage']),
    ('HeadRush', 'MX5', 'stomp', array['mx5','headrush','compact modeler','touchscreen']),
    ('HeadRush', 'Prime', 'floorboard', array['prime','headrush prime','amp cloning','vocal guitar processor']),
    ('HeadRush', 'Core', 'floorboard', array['core','headrush core','amp cloning','compact prime']),

    -- Zoom
    ('Zoom', 'MS-50G+', 'stomp', array['ms-50g plus','zoom multistomp','guitar effects','compact']),
    ('Zoom', 'MS-70CDR+', 'stomp', array['ms-70cdr plus','zoom multistomp','chorus delay reverb','compact']),
    ('Zoom', 'MS-80IR+', 'stomp', array['ms-80ir plus','zoom amp modeler','ir loader','compact']),
    ('Zoom', 'G1 FOUR', 'floorboard', array['g1 four','zoom multi fx','practice','budget']),
    ('Zoom', 'G1X FOUR', 'floorboard', array['g1x four','zoom multi fx','expression pedal','budget']),
    ('Zoom', 'G2 FOUR', 'floorboard', array['g2 four','zoom multi fx','amp modeler','practice']),
    ('Zoom', 'G2X FOUR', 'floorboard', array['g2x four','zoom multi fx','expression pedal','practice']),
    ('Zoom', 'G3n', 'floorboard', array['g3n','zoom multi fx','stomp layout','practice']),
    ('Zoom', 'G3Xn', 'floorboard', array['g3xn','zoom multi fx','expression pedal','practice']),
    ('Zoom', 'G5n', 'floorboard', array['g5n','zoom multi fx','floorboard','stage']),
    ('Zoom', 'G6', 'floorboard', array['g6','zoom multi fx','touchscreen','stage']),
    ('Zoom', 'G11', 'floorboard', array['g11','zoom flagship','touchscreen','stage']),

    -- Valeton
    ('Valeton', 'GP-100', 'floorboard', array['gp-100','valeton','multi fx','budget modeler']),
    ('Valeton', 'GP-100VT', 'floorboard', array['gp-100vt','valeton','multi fx','desktop edit']),
    ('Valeton', 'GP-200', 'floorboard', array['gp-200','valeton','amp modeler','floorboard']),
    ('Valeton', 'GP-200LT', 'floorboard', array['gp-200lt','valeton','lighter floorboard','multi fx']),
    ('Valeton', 'GP-200JR', 'stomp', array['gp-200jr','valeton','compact modeler','pedalboard']),

    -- Mooer
    ('Mooer', 'GE100', 'floorboard', array['ge100','mooer multi fx','budget','practice']),
    ('Mooer', 'GE150', 'floorboard', array['ge150','mooer multi fx','amp modeler','practice']),
    ('Mooer', 'GE200', 'floorboard', array['ge200','mooer amp modeler','compact floorboard','stage']),
    ('Mooer', 'GE250', 'floorboard', array['ge250','mooer amp modeler','floorboard','stage']),
    ('Mooer', 'GE300', 'floorboard', array['ge300','mooer flagship','synth modeler','stage']),
    ('Mooer', 'GE300 Lite', 'floorboard', array['ge300 lite','mooer flagship','lighter floorboard','stage']),
    ('Mooer', 'GE300M', 'rack', array['ge300m','mooer rack modeler','rack','studio']),
    ('Mooer', 'Prime P1', 'stomp', array['prime p1','mooer prime','portable modeler','practice']),
    ('Mooer', 'Prime P2', 'stomp', array['prime p2','mooer prime','portable modeler','headphone rig']),
    ('Mooer', 'Prime S1', 'stomp', array['prime s1','mooer prime','portable modeler','pedalboard']),

    -- Hotone
    ('Hotone', 'Ampero', 'floorboard', array['ampero','hotone modeler','touchscreen','floorboard']),
    ('Hotone', 'Ampero One', 'stomp', array['ampero one','hotone modeler','compact','pedalboard']),
    ('Hotone', 'Ampero II', 'floorboard', array['ampero ii','hotone modeler','touchscreen','stage']),
    ('Hotone', 'Ampero II Stomp', 'stomp', array['ampero ii stomp','hotone modeler','compact','pedalboard']),
    ('Hotone', 'Ampero II Stage', 'floorboard', array['ampero ii stage','hotone modeler','large floorboard','stage']),
    ('Hotone', 'Ampero Mini', 'stomp', array['ampero mini','hotone modeler','mini modeler','pedalboard']),

    -- NUX
    ('NUX', 'MG-30', 'floorboard', array['mg-30','nux multi fx','amp modeler','stage']),
    ('NUX', 'MG-300', 'floorboard', array['mg-300','nux multi fx','amp modeler','budget']),
    ('NUX', 'MG-300 MKII', 'floorboard', array['mg-300 mkii','nux multi fx','updated modeler','budget']),
    ('NUX', 'MG-400', 'floorboard', array['mg-400','nux multi fx','dual dsp','stage']),
    ('NUX', 'MG-101', 'floorboard', array['mg-101','nux multi fx','entry modeler','practice']),
    ('NUX', 'Trident', 'stomp', array['trident','nux amp modeler','amp academy style','pedalboard']),
    ('NUX', 'Cerberus', 'floorboard', array['cerberus','nux multi fx','analog drive digital ambience','pedalboard'])
),
multifx_brand_lookup as (
  select id as brand_id, name as brand_name
  from public.multifx_brands
),
upsert_multifx as (
  insert into public.multifx_models (
    brand_id,
    name,
    slug,
    category,
    tags,
    is_active
  )
  select
    lookup.brand_id,
    seed.model_name,
    public.slugify_gear(concat(seed.brand_name, ' ', seed.model_name)),
    seed.category,
    seed.tags,
    true
  from multifx_seed seed
  join multifx_brand_lookup lookup on lookup.brand_name = seed.brand_name
  on conflict (brand_id, slug) do nothing
  returning 1
)
select count(*) from upsert_multifx;
