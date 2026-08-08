-- Catalog Wave 3b: budget pedal brands + recent pedals (2026-08-08).
-- Adds Caline + Flamma (budget brands users own, were missing) + recent viral
-- pedals. Behavior comes from the pedal_type switch in the rule engine (no
-- per-model tuning needed). Dedup-safe via on conflict.
begin;

insert into public.equipment_manufacturers (name, slug, is_active) values
  ('Caline','caline',true),('Flamma','flamma',true),('Universal Audio','universal-audio',true)
on conflict (slug) do update set name=excluded.name, is_active=true;

insert into public.pedal_brands (name, slug) values
  ('Caline','caline'),('Flamma','flamma'),('Universal Audio','universal-audio')
on conflict (slug) do update set name=excluded.name, is_active=true;

with pedal_seed(brand_name, model_name, category, pedal_type, tags, price_low, price_high, used_by_artists, description, status, popularity) as (
  values
-- Pedal catalog top-up: Caline + Flamma budget lineups plus recent viral pedals.
-- Column order: brand, model, category, pedal_type, tags, price_low, price_high, features(empty), description, status, popularity
-- Trailing comma on EVERY line including the last (wrapper strips it).

-- ===== Caline (budget, ~25-55 USD) =====
('Caline','CP-04 Pure Sky','overdrive','overdrive',array['transparent','timmy']::text[],35,45,array[]::text[],'Transparent low-gain overdrive in the Timmy style; keeps your amp''s natural voice and is one of Caline''s best-selling pedals.','active',42),
('Caline','American Sound','preamp','preamp',array['amp-sim','di']::text[],39,49,array[]::text[],'Amp-in-a-box preamp and DI voiced after a Tech 21 Blonde/Fender-style clean, great for direct recording.','active',40),
('Caline','CP-11 Puffer Fuzz','fuzz','fuzz',array['silicon','fuzz-face']::text[],29,39,array[]::text[],'Silicon Fuzz Face-style fuzz with thick vintage grit and a wide gain range for the money.','active',30),
('Caline','DC Fabricator','distortion','distortion',array['high-gain','crunch']::text[],29,39,array[]::text[],'Crunch Box-style high-gain distortion delivering tight British-flavored rhythm and lead tones.','active',33),
('Caline','CP-13 Pure Boost','boost','boost',array['clean-boost','eq']::text[],29,39,array[]::text[],'Clean boost with active two-band EQ and up to ~30dB of gain to push an amp or tighten a signal chain.','active',31),
('Caline','CP-14 English Man','distortion','distortion',array['plexi','marshall']::text[],35,45,array[]::text[],'Plexi-flavored distortion delivering searing 70s/80s Marshall-style high-gain rock and lead tones.','active',34),
('Caline','CP-18 Orange Burst','overdrive','overdrive',array['boost','eq']::text[],29,39,array[]::text[],'Overdrive with a built-in clean boost and active two-band EQ for versatile crunch and lead push.','active',32),
('Caline','CP-20 Crazy Cacti','overdrive','overdrive',array['fulldrive','dual']::text[],35,45,array[]::text[],'Fulltone Fulldrive 2-style overdrive with boost and multiple clipping modes for stacked gain.','active',36),
('Caline','CP-10 Compressor Limiter','compressor','compressor',array['sustain','limiter']::text[],35,45,array[]::text[],'Compact compressor/limiter that evens out dynamics and adds sustain for clean and country-style playing.','active',28),
('Caline','CP-17 Time Space','delay','delay',array['digital','dd-3']::text[],35,45,array[]::text[],'Boss DD-3-style digital delay with mix, repeat and time controls and up to ~600ms of delay.','active',33),
('Caline','CP-19 Blue Ocean','delay','delay',array['digital','echo']::text[],35,45,array[]::text[],'Warm digital delay with analog-voiced repeats for slapback, echo and ambient trails.','active',31),
('Caline','CP-24 10-Band EQ','eq','eq',array['graphic','31hz-16khz']::text[],39,49,array[]::text[],'Ten-band graphic equalizer covering 31Hz to 16kHz with volume slider for guitar or bass tone shaping.','active',30),
('Caline','CP-26 Snake Bite','reverb','reverb',array['ambient','hall']::text[],39,49,array[]::text[],'Ambient hall reverb with a six-knob interface for lush spatial washes and true bypass.','active',32),
('Caline','CP-44 Reflector','reverb','reverb',array['spring','dwell']::text[],39,49,array[]::text[],'Spring reverb emulating classic amp-style ambience with dwell and mix controls.','active',31),
('Caline','CP-508 Wonderland','reverb','reverb',array['shimmer','ambient']::text[],45,55,array[]::text[],'Deep modulated shimmer/ambient reverb in the Strymon BigSky vein, ideal for shoegaze and pad swells.','active',34),

-- ===== Flamma (budget, ~40-90 USD) =====
('Flamma','FS02 Reverb','reverb','reverb',array['stereo','presets']::text[],79,89,array[]::text[],'Stereo digital reverb with seven algorithms (room, hall, church, cave, plate, spring, mod) and storable presets.','active',38),
('Flamma','FS03 Delay','delay','delay',array['stereo','looper']::text[],79,89,array[]::text[],'Stereo digital delay with six delay modes, tap tempo, a built-in looper and storable presets.','active',37),
('Flamma','FS04 Chorus','chorus','chorus',array['stereo','modulation']::text[],59,69,array[]::text[],'Stereo chorus offering lush classic and modern modulation voicings with true bypass.','active',33),
('Flamma','FS05 Multi Modulation','modulation','modulation',array['chorus','flanger']::text[],59,69,array[]::text[],'Multi-modulation pedal with 11 stereo effects spanning chorus, flanger, phaser, tremolo and more.','active',33),
('Flamma','FS06 Digital Preamp','preamp','preamp',array['amp-sim','cab']::text[],59,69,array[]::text[],'Digital preamp with seven amp models and built-in cabinet simulation, from Fender clean to Vox chime.','active',35),
('Flamma','FS07 Cab Loader','utility','utility',array['ir','cab-sim']::text[],59,69,array[]::text[],'Stereo cabinet/IR loader with seven user preset slots and software editing for direct recording.','active',30),
('Flamma','FS08 Polyphonic Octave','octaver','octaver',array['polyphonic','presets']::text[],49,59,array[]::text[],'Polyphonic octave pedal with four octave voices (-2/-1/+1/+2), independent volumes and a dry blend.','active',31),
('Flamma','FS21 Looper Drum Machine','looper','looper',array['drum-machine','stereo']::text[],79,89,array[]::text[],'Stereo 2-in-1 looper and drum machine with 160 minutes of recording and 100 drum grooves.','active',34),
('Flamma','FS22 Ekoverb','reverb','reverb',array['delay','freeze']::text[],79,89,array[]::text[],'Dual-footswitch stereo delay and reverb with three paired effects, tap tempo and infinite freeze.','active',33),
('Flamma','FC05 Mini Modulation','modulation','modulation',array['mini','multi']::text[],45,55,array[]::text[],'Mini multi-modulation pedal packing chorus, flanger, tremolo, phaser, vibrato and rotary voices.','active',30),
('Flamma','FC06 Distortion','distortion','distortion',array['mini','high-gain']::text[],45,55,array[]::text[],'Mini high-gain distortion delivering tight modern crunch and lead tones in a compact enclosure.','active',30),
('Flamma','FC07 Overdrive','overdrive','overdrive',array['mini','crunch']::text[],45,55,array[]::text[],'Mini overdrive covering transparent boost to dirty crunch, sized for tight pedalboards.','active',30),

-- ===== Recent viral extras (verified real, 2022-2025) =====
('JHS','Hard Drive','distortion','distortion',array['hard-rock','high-gain']::text[],189,199,array[]::text[],'JHS''s take on 80s hard rock distortion with tight, aggressive high-gain crunch and cutting leads.','active',45),
('Boss','OD-1X','overdrive','overdrive',array['transparent','multi-dimensional']::text[],129,149,array[]::text[],'Premium overdrive using Boss MDP for clear, dynamic drive with rich harmonics and note definition.','active',42),
('Boss','DS-1W','distortion','distortion',array['waza-craft','vintage']::text[],139,159,array[]::text[],'Waza Craft evolution of the classic DS-1 with Standard and Custom modes for richer, punchier distortion.','active',46),
('Boss','DD-8','delay','delay',array['digital','stereo']::text[],169,189,array[]::text[],'Flagship compact digital delay with 11 modes including shimmer and looper, plus stereo output.','active',47),
('Walrus Audio','Fundamental Reverb','reverb','reverb',array['ambient','sliders']::text[],129,149,array[]::text[],'Streamlined reverb with slider controls and Hall, Spring and Plate modes for approachable ambience.','active',43),
('Walrus Audio','Fundamental Tremolo','tremolo','tremolo',array['harmonic','sliders']::text[],129,149,array[]::text[],'Simple slider-based tremolo with Sine, Square and Harmonic modes for classic to choppy pulses.','active',38),
('Walrus Audio','Fundamental Chorus','chorus','chorus',array['vibrato','sliders']::text[],129,149,array[]::text[],'Slider-driven chorus with Standard, Vibrato and Multi modes for lush, easy modulation.','active',39),
('EarthQuaker Devices','Ghost Echo','reverb','reverb',array['ambient','haunting']::text[],149,179,array[]::text[],'Compact ambient reverb serving up short haunting splashes to cavernous washes with three controls.','active',40),
('Fender','Hammertone Overdrive','overdrive','overdrive',array['budget','mid-boost']::text[],99,109,array[]::text[],'Affordable overdrive with a mid-boost switch for transparent low-gain drive to thicker crunch.','active',37),
('Fender','Hammertone Reverb','reverb','reverb',array['budget','multi-mode']::text[],99,109,array[]::text[],'Budget-friendly reverb with Hall, Room and Plate modes plus a damping control for tone shaping.','active',36),
('Keeley','Halo','delay','delay',array['dual','andy-timmons']::text[],229,249,array[]::text[],'Andy Timmons dual-echo delay with two independent A/B sides and the signature dotted-eighth halo sound.','active',44),
('Strymon','Cloudburst','reverb','reverb',array['ambient','ensemble']::text[],279,299,array[]::text[],'Compact ambient reverb with a recalibrated cloud algorithm and an ensemble mode for shimmering pads.','active',46),
('Universal Audio','UAFX Golden Reverberator','reverb','reverb',array['spring','plate']::text[],379,399,array[]::text[],'Stereo studio reverb with dual-processor Spring, Plate and Vintage Digital modes for pristine ambience.','active',44),
('Universal Audio','UAFX Dream ''65','preamp','preamp',array['amp-sim','fender']::text[],379,399,array[]::text[],'Dual-engine emulation of a blackface Fender-style combo with mic and room modeling for amp-in-a-box tones.','active',48),
('Universal Audio','UAFX Ruby ''63','preamp','preamp',array['amp-sim','vox']::text[],379,399,array[]::text[],'Dual-engine emulation of a Vox AC30 Top Boost with chiming British breakup and speaker modeling.','active',45),
('Universal Audio','UAFX Del-Verb','reverb','reverb',array['delay','ambience']::text[],349,399,array[]::text[],'Ambience companion pairing studio delays and reverbs in one stereo pedal for lush spatial textures.','active',41),
('Universal Audio','UAFX Orion','delay','delay',array['tape-echo','stereo']::text[],379,399,array[]::text[],'Tape-echo delay modeling classic units like the Echoplex and Space Echo with authentic wow and flutter.','active',42),
('Universal Audio','UAFX MAX','compressor','compressor',array['preamp','dual-comp']::text[],299,349,array[]::text[],'Preamp and dual compressor combining studio 1176/LA-2A-style dynamics with a boostable front end.','active',40)
),
pedal_brand_lookup as (
  select pb.id as brand_id, pb.name as brand_name, em.id as manufacturer_id
  from public.pedal_brands pb
  join public.equipment_manufacturers em on em.slug = pb.slug
)
insert into public.pedal_models (
  manufacturer_id, brand_id, name, model_name, slug, category, pedal_type, pedal_type_id,
  tags, price_low, price_high, used_by_artists, description, status, popularity,
  metadata
)
select bl.manufacturer_id, bl.brand_id, ps.model_name, ps.model_name,
  public.slugify_gear(concat(ps.brand_name,' ',ps.model_name)),
  ps.category, ps.pedal_type, ps.pedal_type,
  ps.tags, ps.price_low, ps.price_high, ps.used_by_artists, ps.description, ps.status, ps.popularity,
  jsonb_build_object('catalog_verified',true,'source','pedal_catalog_v3','version',3)
from pedal_seed ps
join pedal_brand_lookup bl on bl.brand_name = ps.brand_name
on conflict (brand_id, slug) where brand_id is not null and slug is not null
do update set category=excluded.category, pedal_type=excluded.pedal_type, pedal_type_id=excluded.pedal_type_id,
  tags=excluded.tags, price_low=excluded.price_low, price_high=excluded.price_high,
  description=excluded.description, status=excluded.status, popularity=excluded.popularity;

do $$
declare n int;
begin
  select count(*) into n from public.pedal_models where metadata->>'source'='pedal_catalog_v3' and is_active=true;
  if n < 30 then raise exception 'POST-CONDITION FAILED: expected >=30 new pedals, got %', n; end if;
end $$;

commit;
