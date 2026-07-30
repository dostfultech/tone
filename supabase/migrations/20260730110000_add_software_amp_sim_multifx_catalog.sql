-- Add software amp simulators (AmpliTube, BIAS FX, Guitar Rig, etc.) to the Multi-FX catalog.
-- These are desktop/plugin amp sims used in "Going Direct" workflows — functionally
-- identical to hardware modelers for tone adaptation purposes.

insert into public.multifx_brands (name, slug, search_text)
values
  ('IK Multimedia', 'ik-multimedia', 'ik multimedia amplitube software amp sim plugin'),
  ('Overloud', 'overloud', 'overloud th-u software amp sim plugin'),
  ('Native Instruments', 'native-instruments', 'native instruments guitar rig software amp sim plugin'),
  ('STL Tones', 'stl-tones', 'stl tones tonehub software amp sim plugin')
on conflict (slug) do update set
  name = excluded.name,
  search_text = excluded.search_text,
  is_active = true,
  updated_at = now();

with software_sim_seed(brand_name, model_name, category, tags) as (
  values
    -- IK Multimedia AmpliTube
    ('IK Multimedia', 'AmpliTube 5', 'software amp sim', array['amplitube','amplitube 5','ik multimedia','amp sim','plugin','vst','direct']),
    ('IK Multimedia', 'AmpliTube 5 SE', 'software amp sim', array['amplitube','amplitube se','ik multimedia','free amp sim','plugin','vst','direct']),
    ('IK Multimedia', 'AmpliTube 5 MAX', 'software amp sim', array['amplitube','amplitube max','ik multimedia','full bundle','plugin','vst','direct']),
    ('IK Multimedia', 'TONEX', 'software amp sim', array['tonex','ik multimedia','ai tone model','capture','plugin','vst','direct']),

    -- Positive Grid (brand already exists)
    ('Positive Grid', 'BIAS FX 2', 'software amp sim', array['bias fx','bias fx 2','positive grid','amp sim','plugin','vst','direct']),
    ('Positive Grid', 'BIAS Amp 2', 'software amp sim', array['bias amp','bias amp 2','positive grid','amp designer','plugin','vst','direct']),

    -- Neural DSP plugins (brand already exists)
    ('Neural DSP', 'Archetype: Nolly', 'software amp sim', array['archetype','nolly','neural dsp','djent','metal','plugin','vst','direct']),
    ('Neural DSP', 'Archetype: Plini', 'software amp sim', array['archetype','plini','neural dsp','prog','fusion','plugin','vst','direct']),
    ('Neural DSP', 'Archetype: Gojira', 'software amp sim', array['archetype','gojira','neural dsp','metal','progressive','plugin','vst','direct']),
    ('Neural DSP', 'Archetype: Tim Henson', 'software amp sim', array['archetype','tim henson','neural dsp','polyphia','prog','plugin','vst','direct']),
    ('Neural DSP', 'Archetype: Cory Wong', 'software amp sim', array['archetype','cory wong','neural dsp','funk','clean','plugin','vst','direct']),
    ('Neural DSP', 'Archetype: Rabea', 'software amp sim', array['archetype','rabea','neural dsp','modern rock','plugin','vst','direct']),
    ('Neural DSP', 'Archetype: Petrucci', 'software amp sim', array['archetype','petrucci','neural dsp','prog metal','plugin','vst','direct']),
    ('Neural DSP', 'NAM (Neural Amp Modeler)', 'software amp sim', array['nam','neural amp modeler','open source','capture','machine learning','plugin','vst','direct']),

    -- Line 6 (brand already exists)
    ('Line 6', 'Helix Native', 'software amp sim', array['helix native','line 6','helix plugin','amp sim','vst','direct']),
    ('Line 6', 'POD Farm 2', 'software amp sim', array['pod farm','line 6','legacy amp sim','plugin','vst','direct']),

    -- Native Instruments
    ('Native Instruments', 'Guitar Rig 7', 'software amp sim', array['guitar rig','guitar rig 7','native instruments','amp sim','plugin','vst','direct']),
    ('Native Instruments', 'Guitar Rig 6', 'software amp sim', array['guitar rig','guitar rig 6','native instruments','amp sim','plugin','vst','direct']),

    -- Overloud
    ('Overloud', 'TH-U', 'software amp sim', array['th-u','overloud','amp sim','plugin','vst','direct']),
    ('Overloud', 'TH-U SuperCabinet', 'software amp sim', array['th-u','overloud','cabinet sim','ir loader','plugin','vst','direct']),

    -- STL Tones
    ('STL Tones', 'ToneHub', 'software amp sim', array['tonehub','stl tones','amp sim','tone capture','plugin','vst','direct']),
    ('STL Tones', 'AmpHub', 'software amp sim', array['amphub','stl tones','amp sim','subscription','plugin','vst','direct']),

    -- Boss (brand already exists)
    ('Boss', 'Tone Studio', 'software amp sim', array['tone studio','boss','katana editor','amp editor','desktop','direct']),

    -- Fractal (brand already exists)
    ('Fractal', 'Axe-Edit', 'software amp sim', array['axe-edit','fractal','axe fx editor','desktop','direct'])
),
brand_lookup as (
  select id as brand_id, name as brand_name
  from public.multifx_brands
)
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
from software_sim_seed seed
join brand_lookup lookup on lookup.brand_name = seed.brand_name
on conflict (brand_id, slug) do update set
  category = excluded.category,
  tags = excluded.tags,
  is_active = true,
  updated_at = now();
