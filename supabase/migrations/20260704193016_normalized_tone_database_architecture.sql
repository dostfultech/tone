-- Tonefex normalized tone database architecture.
-- This migration is intentionally additive and non-destructive.
-- It does not implement UI, rule-engine logic, AI logic, or adaptation caching.

create extension if not exists pgcrypto;

create table if not exists public.tone_part_types (
  id text primary key,
  label text not null,
  description text,
  sort_order integer not null default 100,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.tone_types (
  id text primary key,
  label text not null,
  description text,
  sort_order integer not null default 100,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.tone_archetypes (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  name text not null,
  instrument_type text check (instrument_type in ('guitar', 'bass', 'both')),
  description text,
  metadata jsonb not null default '{}'::jsonb,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.equipment_manufacturers (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  slug text not null unique,
  country text,
  website_url text,
  metadata jsonb not null default '{}'::jsonb,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.frequency_curves (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  name text not null,
  low_end numeric(5,2) not null default 5 check (low_end between 0 and 10),
  low_mid numeric(5,2) not null default 5 check (low_mid between 0 and 10),
  midrange numeric(5,2) not null default 5 check (midrange between 0 and 10),
  high_mid numeric(5,2) not null default 5 check (high_mid between 0 and 10),
  high_end numeric(5,2) not null default 5 check (high_end between 0 and 10),
  curve jsonb not null default '{}'::jsonb,
  metadata jsonb not null default '{}'::jsonb,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.amp_archetypes (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  name text not null,
  gain_profile text,
  eq_profile text,
  description text,
  metadata jsonb not null default '{}'::jsonb,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.cabinet_archetypes (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  name text not null,
  cabinet_format text,
  back_type text check (back_type is null or back_type in ('open_back', 'closed_back', 'semi_open')),
  description text,
  metadata jsonb not null default '{}'::jsonb,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.pickup_types (
  id text primary key,
  label text not null,
  coil_type text not null check (coil_type in ('single_coil', 'humbucker', 'p90', 'other')),
  description text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.pickup_preferences (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  label text not null,
  preferred_position text check (preferred_position is null or preferred_position in ('neck', 'middle', 'bridge', 'any')),
  pickup_type_id text references public.pickup_types(id) on delete set null,
  description text,
  metadata jsonb not null default '{}'::jsonb,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.pedal_types (
  id text primary key,
  label text not null,
  description text,
  sort_order integer not null default 100,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.song_parts (
  id uuid primary key default gen_random_uuid(),
  song_id uuid not null references public.songs(id) on delete cascade,
  part_type_id text not null references public.tone_part_types(id),
  label text not null,
  sort_order integer not null default 0,
  start_seconds numeric(8,2),
  end_seconds numeric(8,2),
  metadata jsonb not null default '{}'::jsonb,
  search_text text not null default '',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (song_id, part_type_id, label)
);

create table if not exists public.master_tones (
  id uuid primary key default gen_random_uuid(),
  song_part_id uuid not null references public.song_parts(id) on delete cascade,
  instrument_type text not null check (instrument_type in ('guitar', 'bass')),
  tone_type_id text not null references public.tone_types(id),
  tone_archetype_id uuid references public.tone_archetypes(id) on delete set null,
  pickup_preference_id uuid references public.pickup_preferences(id) on delete set null,
  suggested_amp_archetype_id uuid references public.amp_archetypes(id) on delete set null,
  suggested_cabinet_archetype_id uuid references public.cabinet_archetypes(id) on delete set null,
  gain numeric(5,2) check (gain between 0 and 10),
  bass numeric(5,2) check (bass between 0 and 10),
  middle numeric(5,2) check (middle between 0 and 10),
  treble numeric(5,2) check (treble between 0 and 10),
  presence numeric(5,2) check (presence between 0 and 10),
  resonance numeric(5,2) check (resonance between 0 and 10),
  depth numeric(5,2) check (depth between 0 and 10),
  master_volume numeric(5,2) check (master_volume between 0 and 10),
  noise_gate numeric(5,2) check (noise_gate between 0 and 10),
  compression numeric(5,2) check (compression between 0 and 10),
  delay numeric(5,2) check (delay between 0 and 10),
  reverb numeric(5,2) check (reverb between 0 and 10),
  eq_profile jsonb not null default '{}'::jsonb,
  modulation_profile jsonb not null default '{}'::jsonb,
  tempo_bpm numeric(7,2),
  metadata jsonb not null default '{}'::jsonb,
  source_summary text,
  confidence integer not null default 65 check (confidence between 0 and 100),
  verification_status text not null default 'needs_review' check (verification_status in ('needs_review', 'starter_estimate', 'research_verified', 'admin_verified')),
  version integer not null default 1,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (song_part_id, instrument_type, tone_type_id, version)
);

create table if not exists public.master_tone_suggested_pedals (
  id uuid primary key default gen_random_uuid(),
  master_tone_id uuid not null references public.master_tones(id) on delete cascade,
  pedal_type_id text not null references public.pedal_types(id),
  position_order integer not null default 0,
  purpose text,
  intensity numeric(5,2) check (intensity between 0 and 10),
  metadata jsonb not null default '{}'::jsonb,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (master_tone_id, pedal_type_id, position_order)
);

create table if not exists public.guitar_models (
  id uuid primary key default gen_random_uuid(),
  manufacturer_id uuid not null references public.equipment_manufacturers(id),
  model_name text not null,
  instrument_type text not null default 'guitar' check (instrument_type in ('guitar', 'bass')),
  body_type text,
  scale_length_inches numeric(5,2),
  bridge_type text,
  pickup_layout text,
  output_level numeric(5,2) not null default 5 check (output_level between 0 and 10),
  brightness numeric(5,2) not null default 5 check (brightness between 0 and 10),
  warmth numeric(5,2) not null default 5 check (warmth between 0 and 10),
  compression numeric(5,2) not null default 5 check (compression between 0 and 10),
  frequency_curve_id uuid references public.frequency_curves(id) on delete set null,
  noise_characteristics jsonb not null default '{}'::jsonb,
  tone_archetype_id uuid references public.tone_archetypes(id) on delete set null,
  metadata jsonb not null default '{}'::jsonb,
  search_text text not null default '',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (manufacturer_id, model_name, instrument_type)
);

create table if not exists public.pickup_models (
  id uuid primary key default gen_random_uuid(),
  manufacturer_id uuid not null references public.equipment_manufacturers(id),
  model_name text not null,
  pickup_type_id text not null references public.pickup_types(id),
  circuit_type text not null check (circuit_type in ('active', 'passive')),
  output_level numeric(5,2) not null default 5 check (output_level between 0 and 10),
  brightness numeric(5,2) not null default 5 check (brightness between 0 and 10),
  bass numeric(5,2) not null default 5 check (bass between 0 and 10),
  midrange numeric(5,2) not null default 5 check (midrange between 0 and 10),
  compression numeric(5,2) not null default 5 check (compression between 0 and 10),
  frequency_curve_id uuid references public.frequency_curves(id) on delete set null,
  noise numeric(5,2) not null default 5 check (noise between 0 and 10),
  tone_archetype_id uuid references public.tone_archetypes(id) on delete set null,
  metadata jsonb not null default '{}'::jsonb,
  search_text text not null default '',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (manufacturer_id, model_name, pickup_type_id)
);

create table if not exists public.guitar_model_pickups (
  id uuid primary key default gen_random_uuid(),
  guitar_model_id uuid not null references public.guitar_models(id) on delete cascade,
  pickup_model_id uuid references public.pickup_models(id) on delete set null,
  pickup_position text not null check (pickup_position in ('neck', 'middle', 'bridge')),
  is_stock boolean not null default true,
  metadata jsonb not null default '{}'::jsonb,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (guitar_model_id, pickup_position, is_stock)
);

create table if not exists public.amp_models (
  id uuid primary key default gen_random_uuid(),
  manufacturer_id uuid not null references public.equipment_manufacturers(id),
  model_name text not null,
  instrument_type text not null default 'guitar' check (instrument_type in ('guitar', 'bass', 'both')),
  amp_technology text not null check (amp_technology in ('tube', 'solid_state', 'hybrid', 'digital_modeling', 'plugin')),
  gain_structure text,
  eq_behaviour jsonb not null default '{}'::jsonb,
  presence_behaviour jsonb not null default '{}'::jsonb,
  compression numeric(5,2) not null default 5 check (compression between 0 and 10),
  brightness numeric(5,2) not null default 5 check (brightness between 0 and 10),
  warmth numeric(5,2) not null default 5 check (warmth between 0 and 10),
  clean_headroom numeric(5,2) not null default 5 check (clean_headroom between 0 and 10),
  tone_archetype_id uuid references public.tone_archetypes(id) on delete set null,
  metadata jsonb not null default '{}'::jsonb,
  search_text text not null default '',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (manufacturer_id, model_name, instrument_type)
);

create table if not exists public.cabinet_formats (
  id text primary key,
  label text not null,
  speaker_count integer not null check (speaker_count > 0),
  speaker_size_inches integer not null check (speaker_size_inches > 0),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.speaker_models (
  id uuid primary key default gen_random_uuid(),
  manufacturer_id uuid references public.equipment_manufacturers(id) on delete set null,
  model_name text not null,
  frequency_curve_id uuid references public.frequency_curves(id) on delete set null,
  brightness numeric(5,2) not null default 5 check (brightness between 0 and 10),
  warmth numeric(5,2) not null default 5 check (warmth between 0 and 10),
  metadata jsonb not null default '{}'::jsonb,
  search_text text not null default '',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (manufacturer_id, model_name)
);

create table if not exists public.cabinet_models (
  id uuid primary key default gen_random_uuid(),
  manufacturer_id uuid references public.equipment_manufacturers(id) on delete set null,
  model_name text not null,
  cabinet_format_id text not null references public.cabinet_formats(id),
  back_type text not null check (back_type in ('open_back', 'closed_back', 'semi_open')),
  speaker_model_id uuid references public.speaker_models(id) on delete set null,
  frequency_curve_id uuid references public.frequency_curves(id) on delete set null,
  low_end numeric(5,2) not null default 5 check (low_end between 0 and 10),
  high_end numeric(5,2) not null default 5 check (high_end between 0 and 10),
  brightness numeric(5,2) not null default 5 check (brightness between 0 and 10),
  warmth numeric(5,2) not null default 5 check (warmth between 0 and 10),
  metadata jsonb not null default '{}'::jsonb,
  search_text text not null default '',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (manufacturer_id, model_name, cabinet_format_id)
);

create table if not exists public.amp_recommended_cabinets (
  id uuid primary key default gen_random_uuid(),
  amp_model_id uuid not null references public.amp_models(id) on delete cascade,
  cabinet_model_id uuid not null references public.cabinet_models(id) on delete cascade,
  priority integer not null default 100,
  notes text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (amp_model_id, cabinet_model_id)
);

create table if not exists public.pedal_models (
  id uuid primary key default gen_random_uuid(),
  manufacturer_id uuid not null references public.equipment_manufacturers(id),
  model_name text not null,
  pedal_type_id text not null references public.pedal_types(id),
  gain_change numeric(5,2) not null default 0 check (gain_change between -10 and 10),
  eq_influence jsonb not null default '{}'::jsonb,
  compression numeric(5,2) not null default 0 check (compression between 0 and 10),
  noise numeric(5,2) not null default 0 check (noise between 0 and 10),
  tone_color jsonb not null default '{}'::jsonb,
  metadata jsonb not null default '{}'::jsonb,
  search_text text not null default '',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (manufacturer_id, model_name, pedal_type_id)
);

create table if not exists public.multifx_devices (
  id uuid primary key default gen_random_uuid(),
  manufacturer_id uuid not null references public.equipment_manufacturers(id),
  model_name text not null,
  dsp_limits jsonb not null default '{}'::jsonb,
  routing jsonb not null default '{}'::jsonb,
  patch_structure jsonb not null default '{}'::jsonb,
  parameter_mapping jsonb not null default '{}'::jsonb,
  metadata jsonb not null default '{}'::jsonb,
  search_text text not null default '',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (manufacturer_id, model_name)
);

create table if not exists public.multifx_amp_models (
  id uuid primary key default gen_random_uuid(),
  multifx_device_id uuid not null references public.multifx_devices(id) on delete cascade,
  model_name text not null,
  amp_model_id uuid references public.amp_models(id) on delete set null,
  parameter_mapping jsonb not null default '{}'::jsonb,
  metadata jsonb not null default '{}'::jsonb,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (multifx_device_id, model_name)
);

create table if not exists public.multifx_cab_models (
  id uuid primary key default gen_random_uuid(),
  multifx_device_id uuid not null references public.multifx_devices(id) on delete cascade,
  model_name text not null,
  cabinet_model_id uuid references public.cabinet_models(id) on delete set null,
  parameter_mapping jsonb not null default '{}'::jsonb,
  metadata jsonb not null default '{}'::jsonb,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (multifx_device_id, model_name)
);

create table if not exists public.multifx_effects (
  id uuid primary key default gen_random_uuid(),
  multifx_device_id uuid not null references public.multifx_devices(id) on delete cascade,
  effect_name text not null,
  pedal_type_id text references public.pedal_types(id) on delete set null,
  parameter_mapping jsonb not null default '{}'::jsonb,
  metadata jsonb not null default '{}'::jsonb,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (multifx_device_id, effect_name)
);

create table if not exists public.user_instruments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  guitar_model_id uuid references public.guitar_models(id) on delete set null,
  nickname text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.user_instrument_pickups (
  id uuid primary key default gen_random_uuid(),
  user_instrument_id uuid not null references public.user_instruments(id) on delete cascade,
  pickup_model_id uuid references public.pickup_models(id) on delete set null,
  pickup_position text not null check (pickup_position in ('neck', 'middle', 'bridge')),
  is_stock boolean not null default false,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_instrument_id, pickup_position)
);

create table if not exists public.user_rigs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  name text not null,
  instrument_type text not null check (instrument_type in ('guitar', 'bass')),
  user_instrument_id uuid references public.user_instruments(id) on delete set null,
  amp_model_id uuid references public.amp_models(id) on delete set null,
  cabinet_model_id uuid references public.cabinet_models(id) on delete set null,
  multifx_device_id uuid references public.multifx_devices(id) on delete set null,
  going_direct boolean not null default false,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.user_rig_pedals (
  id uuid primary key default gen_random_uuid(),
  user_rig_id uuid not null references public.user_rigs(id) on delete cascade,
  pedal_model_id uuid references public.pedal_models(id) on delete set null,
  position_order integer not null default 0,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_rig_id, position_order)
);

create table if not exists public.rule_sets (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  name text not null,
  description text,
  version integer not null default 1,
  status text not null default 'draft' check (status in ('draft', 'active', 'archived')),
  metadata jsonb not null default '{}'::jsonb,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.rule_profiles (
  id uuid primary key default gen_random_uuid(),
  rule_set_id uuid not null references public.rule_sets(id) on delete cascade,
  name text not null,
  equipment_scope text not null check (equipment_scope in ('global', 'guitar', 'pickup', 'amp', 'cabinet', 'pedal', 'multifx')),
  priority integer not null default 100,
  metadata jsonb not null default '{}'::jsonb,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (rule_set_id, name, equipment_scope)
);

create table if not exists public.rule_profile_archetypes (
  id uuid primary key default gen_random_uuid(),
  rule_profile_id uuid not null references public.rule_profiles(id) on delete cascade,
  tone_archetype_id uuid references public.tone_archetypes(id) on delete cascade,
  amp_archetype_id uuid references public.amp_archetypes(id) on delete cascade,
  cabinet_archetype_id uuid references public.cabinet_archetypes(id) on delete cascade,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.cache_key_definitions (
  id uuid primary key default gen_random_uuid(),
  namespace text not null,
  key_name text not null,
  key_version integer not null default 1,
  input_shape jsonb not null default '{}'::jsonb,
  description text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (namespace, key_name, key_version)
);

insert into public.tone_part_types (id, label, sort_order)
values
  ('intro', 'Intro', 10),
  ('verse', 'Verse', 20),
  ('chorus', 'Chorus', 30),
  ('bridge', 'Bridge', 40),
  ('solo', 'Solo', 50),
  ('lead', 'Lead', 60),
  ('rhythm', 'Rhythm', 70),
  ('riff', 'Riff', 80),
  ('breakdown', 'Breakdown', 90),
  ('outro', 'Outro', 100),
  ('clean', 'Clean', 110)
on conflict (id) do update set
  label = excluded.label,
  sort_order = excluded.sort_order,
  is_active = true,
  updated_at = now();

insert into public.tone_types (id, label, sort_order)
values
  ('auto_detect', 'Auto Detect', 10),
  ('clean', 'Clean', 20),
  ('crunch', 'Crunch', 30),
  ('edge_of_breakup', 'Edge of Breakup', 40),
  ('classic_rock', 'Classic Rock', 50),
  ('heavy', 'Heavy', 60),
  ('high_gain', 'High Gain', 70),
  ('metal', 'Metal', 80),
  ('modern_metal', 'Modern Metal', 90),
  ('distorted', 'Distorted', 100),
  ('ambient', 'Ambient', 110),
  ('acoustic', 'Acoustic', 120)
on conflict (id) do update set
  label = excluded.label,
  sort_order = excluded.sort_order,
  is_active = true,
  updated_at = now();

insert into public.pickup_types (id, label, coil_type)
values
  ('single_coil', 'Single Coil', 'single_coil'),
  ('humbucker', 'Humbucker', 'humbucker'),
  ('p90', 'P90', 'p90')
on conflict (id) do update set
  label = excluded.label,
  coil_type = excluded.coil_type,
  is_active = true,
  updated_at = now();

insert into public.pedal_types (id, label, sort_order)
values
  ('overdrive', 'Overdrive', 10),
  ('boost', 'Boost', 20),
  ('distortion', 'Distortion', 30),
  ('compressor', 'Compressor', 40),
  ('eq', 'EQ', 50),
  ('delay', 'Delay', 60),
  ('reverb', 'Reverb', 70),
  ('noise_gate', 'Noise Gate', 80),
  ('chorus', 'Chorus', 90),
  ('flanger', 'Flanger', 100),
  ('phaser', 'Phaser', 110),
  ('pitch', 'Pitch', 120),
  ('octaver', 'Octaver', 130),
  ('fuzz', 'Fuzz', 140)
on conflict (id) do update set
  label = excluded.label,
  sort_order = excluded.sort_order,
  is_active = true,
  updated_at = now();

insert into public.cabinet_formats (id, label, speaker_count, speaker_size_inches)
values
  ('1x12', '1x12', 1, 12),
  ('2x12', '2x12', 2, 12),
  ('4x12', '4x12', 4, 12)
on conflict (id) do update set
  label = excluded.label,
  speaker_count = excluded.speaker_count,
  speaker_size_inches = excluded.speaker_size_inches,
  is_active = true,
  updated_at = now();

insert into public.equipment_manufacturers (name, slug)
values
  ('Boss', 'boss'),
  ('Line 6', 'line-6'),
  ('Fractal Audio', 'fractal-audio'),
  ('Neural DSP', 'neural-dsp'),
  ('HeadRush', 'headrush'),
  ('Kemper', 'kemper')
on conflict (slug) do update set
  name = excluded.name,
  is_active = true,
  updated_at = now();

insert into public.multifx_devices (manufacturer_id, model_name, search_text)
select m.id, v.model_name, concat_ws(' ', m.name, v.model_name, 'multifx multi fx modeler direct unit')
from (
  values
    ('boss', 'Boss GT-1000'),
    ('line-6', 'HX Stomp'),
    ('line-6', 'Helix'),
    ('fractal-audio', 'FM3'),
    ('fractal-audio', 'FM9'),
    ('neural-dsp', 'Quad Cortex'),
    ('headrush', 'Headrush'),
    ('kemper', 'Kemper'),
    ('neural-dsp', 'Neural DSP')
) as v(manufacturer_slug, model_name)
join public.equipment_manufacturers m on m.slug = v.manufacturer_slug
on conflict (manufacturer_id, model_name) do update set
  search_text = excluded.search_text,
  is_active = true,
  updated_at = now();

create index if not exists song_parts_song_idx on public.song_parts (song_id, part_type_id, is_active);
create index if not exists song_parts_search_idx on public.song_parts using gin (to_tsvector('english', search_text));
create index if not exists master_tones_lookup_idx on public.master_tones (song_part_id, instrument_type, tone_type_id, is_active);
create index if not exists master_tones_archetype_idx on public.master_tones (tone_archetype_id, suggested_amp_archetype_id, suggested_cabinet_archetype_id);
create index if not exists guitar_models_lookup_idx on public.guitar_models (manufacturer_id, instrument_type, is_active);
create index if not exists guitar_models_search_idx on public.guitar_models using gin (to_tsvector('english', search_text));
create index if not exists pickup_models_lookup_idx on public.pickup_models (manufacturer_id, pickup_type_id, circuit_type, is_active);
create index if not exists pickup_models_search_idx on public.pickup_models using gin (to_tsvector('english', search_text));
create index if not exists amp_models_lookup_idx on public.amp_models (manufacturer_id, instrument_type, amp_technology, is_active);
create index if not exists amp_models_search_idx on public.amp_models using gin (to_tsvector('english', search_text));
create index if not exists cabinet_models_lookup_idx on public.cabinet_models (cabinet_format_id, back_type, is_active);
create index if not exists cabinet_models_search_idx on public.cabinet_models using gin (to_tsvector('english', search_text));
create index if not exists pedal_models_lookup_idx on public.pedal_models (manufacturer_id, pedal_type_id, is_active);
create index if not exists pedal_models_search_idx on public.pedal_models using gin (to_tsvector('english', search_text));
create index if not exists multifx_devices_search_idx on public.multifx_devices using gin (to_tsvector('english', search_text));
create index if not exists user_instruments_user_idx on public.user_instruments (user_id, guitar_model_id);
create index if not exists user_rigs_user_idx on public.user_rigs (user_id, instrument_type, going_direct);
create index if not exists rule_profiles_lookup_idx on public.rule_profiles (rule_set_id, equipment_scope, priority, is_active);
create index if not exists cache_key_definitions_lookup_idx on public.cache_key_definitions (namespace, key_name, key_version, is_active);

drop trigger if exists tone_part_types_updated_at on public.tone_part_types;
create trigger tone_part_types_updated_at before update on public.tone_part_types for each row execute function public.set_updated_at();
drop trigger if exists tone_types_updated_at on public.tone_types;
create trigger tone_types_updated_at before update on public.tone_types for each row execute function public.set_updated_at();
drop trigger if exists tone_archetypes_updated_at on public.tone_archetypes;
create trigger tone_archetypes_updated_at before update on public.tone_archetypes for each row execute function public.set_updated_at();
drop trigger if exists equipment_manufacturers_updated_at on public.equipment_manufacturers;
create trigger equipment_manufacturers_updated_at before update on public.equipment_manufacturers for each row execute function public.set_updated_at();
drop trigger if exists frequency_curves_updated_at on public.frequency_curves;
create trigger frequency_curves_updated_at before update on public.frequency_curves for each row execute function public.set_updated_at();
drop trigger if exists amp_archetypes_updated_at on public.amp_archetypes;
create trigger amp_archetypes_updated_at before update on public.amp_archetypes for each row execute function public.set_updated_at();
drop trigger if exists cabinet_archetypes_updated_at on public.cabinet_archetypes;
create trigger cabinet_archetypes_updated_at before update on public.cabinet_archetypes for each row execute function public.set_updated_at();
drop trigger if exists pickup_types_updated_at on public.pickup_types;
create trigger pickup_types_updated_at before update on public.pickup_types for each row execute function public.set_updated_at();
drop trigger if exists pickup_preferences_updated_at on public.pickup_preferences;
create trigger pickup_preferences_updated_at before update on public.pickup_preferences for each row execute function public.set_updated_at();
drop trigger if exists pedal_types_updated_at on public.pedal_types;
create trigger pedal_types_updated_at before update on public.pedal_types for each row execute function public.set_updated_at();
drop trigger if exists song_parts_updated_at on public.song_parts;
create trigger song_parts_updated_at before update on public.song_parts for each row execute function public.set_updated_at();
drop trigger if exists master_tones_updated_at on public.master_tones;
create trigger master_tones_updated_at before update on public.master_tones for each row execute function public.set_updated_at();
drop trigger if exists guitar_models_updated_at on public.guitar_models;
create trigger guitar_models_updated_at before update on public.guitar_models for each row execute function public.set_updated_at();
drop trigger if exists pickup_models_updated_at on public.pickup_models;
create trigger pickup_models_updated_at before update on public.pickup_models for each row execute function public.set_updated_at();
drop trigger if exists amp_models_updated_at on public.amp_models;
create trigger amp_models_updated_at before update on public.amp_models for each row execute function public.set_updated_at();
drop trigger if exists cabinet_formats_updated_at on public.cabinet_formats;
create trigger cabinet_formats_updated_at before update on public.cabinet_formats for each row execute function public.set_updated_at();
drop trigger if exists speaker_models_updated_at on public.speaker_models;
create trigger speaker_models_updated_at before update on public.speaker_models for each row execute function public.set_updated_at();
drop trigger if exists cabinet_models_updated_at on public.cabinet_models;
create trigger cabinet_models_updated_at before update on public.cabinet_models for each row execute function public.set_updated_at();
drop trigger if exists pedal_models_updated_at on public.pedal_models;
create trigger pedal_models_updated_at before update on public.pedal_models for each row execute function public.set_updated_at();
drop trigger if exists multifx_devices_updated_at on public.multifx_devices;
create trigger multifx_devices_updated_at before update on public.multifx_devices for each row execute function public.set_updated_at();
drop trigger if exists user_instruments_updated_at on public.user_instruments;
create trigger user_instruments_updated_at before update on public.user_instruments for each row execute function public.set_updated_at();
drop trigger if exists user_instrument_pickups_updated_at on public.user_instrument_pickups;
create trigger user_instrument_pickups_updated_at before update on public.user_instrument_pickups for each row execute function public.set_updated_at();
drop trigger if exists user_rigs_updated_at on public.user_rigs;
create trigger user_rigs_updated_at before update on public.user_rigs for each row execute function public.set_updated_at();
drop trigger if exists rule_sets_updated_at on public.rule_sets;
create trigger rule_sets_updated_at before update on public.rule_sets for each row execute function public.set_updated_at();
drop trigger if exists rule_profiles_updated_at on public.rule_profiles;
create trigger rule_profiles_updated_at before update on public.rule_profiles for each row execute function public.set_updated_at();
drop trigger if exists cache_key_definitions_updated_at on public.cache_key_definitions;
create trigger cache_key_definitions_updated_at before update on public.cache_key_definitions for each row execute function public.set_updated_at();

do $$
declare
  table_name text;
  policy_name text;
begin
  foreach table_name in array array[
    'tone_part_types',
    'tone_types',
    'tone_archetypes',
    'equipment_manufacturers',
    'frequency_curves',
    'amp_archetypes',
    'cabinet_archetypes',
    'pickup_types',
    'pickup_preferences',
    'pedal_types',
    'song_parts',
    'master_tones',
    'master_tone_suggested_pedals',
    'guitar_models',
    'pickup_models',
    'guitar_model_pickups',
    'amp_models',
    'cabinet_formats',
    'speaker_models',
    'cabinet_models',
    'amp_recommended_cabinets',
    'pedal_models',
    'multifx_devices',
    'multifx_amp_models',
    'multifx_cab_models',
    'multifx_effects'
  ]
  loop
    execute format('alter table public.%I enable row level security', table_name);
    execute format('grant select on public.%I to anon, authenticated', table_name);
    execute format('grant select, insert, update, delete on public.%I to service_role', table_name);
    policy_name := table_name || '_public_read_active';
    execute format('drop policy if exists %I on public.%I', policy_name, table_name);
    execute format('create policy %I on public.%I for select to anon, authenticated using (is_active = true)', policy_name, table_name);
  end loop;

  foreach table_name in array array[
    'rule_sets',
    'rule_profiles',
    'rule_profile_archetypes',
    'cache_key_definitions'
  ]
  loop
    execute format('alter table public.%I enable row level security', table_name);
    execute format('revoke all on public.%I from anon, authenticated', table_name);
    execute format('grant select, insert, update, delete on public.%I to service_role', table_name);
  end loop;
end $$;

alter table public.user_instruments enable row level security;
alter table public.user_instrument_pickups enable row level security;
alter table public.user_rigs enable row level security;
alter table public.user_rig_pedals enable row level security;

grant select, insert, update, delete on public.user_instruments to authenticated, service_role;
grant select, insert, update, delete on public.user_instrument_pickups to authenticated, service_role;
grant select, insert, update, delete on public.user_rigs to authenticated, service_role;
grant select, insert, update, delete on public.user_rig_pedals to authenticated, service_role;

drop policy if exists user_instruments_select_own on public.user_instruments;
create policy user_instruments_select_own on public.user_instruments
for select to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists user_instruments_insert_own on public.user_instruments;
create policy user_instruments_insert_own on public.user_instruments
for insert to authenticated
with check ((select auth.uid()) = user_id);

drop policy if exists user_instruments_update_own on public.user_instruments;
create policy user_instruments_update_own on public.user_instruments
for update to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

drop policy if exists user_instruments_delete_own on public.user_instruments;
create policy user_instruments_delete_own on public.user_instruments
for delete to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists user_instrument_pickups_select_own on public.user_instrument_pickups;
create policy user_instrument_pickups_select_own on public.user_instrument_pickups
for select to authenticated
using (exists (
  select 1 from public.user_instruments ui
  where ui.id = user_instrument_pickups.user_instrument_id
    and ui.user_id = (select auth.uid())
));

drop policy if exists user_instrument_pickups_insert_own on public.user_instrument_pickups;
create policy user_instrument_pickups_insert_own on public.user_instrument_pickups
for insert to authenticated
with check (exists (
  select 1 from public.user_instruments ui
  where ui.id = user_instrument_pickups.user_instrument_id
    and ui.user_id = (select auth.uid())
));

drop policy if exists user_instrument_pickups_update_own on public.user_instrument_pickups;
create policy user_instrument_pickups_update_own on public.user_instrument_pickups
for update to authenticated
using (exists (
  select 1 from public.user_instruments ui
  where ui.id = user_instrument_pickups.user_instrument_id
    and ui.user_id = (select auth.uid())
))
with check (exists (
  select 1 from public.user_instruments ui
  where ui.id = user_instrument_pickups.user_instrument_id
    and ui.user_id = (select auth.uid())
));

drop policy if exists user_instrument_pickups_delete_own on public.user_instrument_pickups;
create policy user_instrument_pickups_delete_own on public.user_instrument_pickups
for delete to authenticated
using (exists (
  select 1 from public.user_instruments ui
  where ui.id = user_instrument_pickups.user_instrument_id
    and ui.user_id = (select auth.uid())
));

drop policy if exists user_rigs_select_own on public.user_rigs;
create policy user_rigs_select_own on public.user_rigs
for select to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists user_rigs_insert_own on public.user_rigs;
create policy user_rigs_insert_own on public.user_rigs
for insert to authenticated
with check ((select auth.uid()) = user_id);

drop policy if exists user_rigs_update_own on public.user_rigs;
create policy user_rigs_update_own on public.user_rigs
for update to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

drop policy if exists user_rigs_delete_own on public.user_rigs;
create policy user_rigs_delete_own on public.user_rigs
for delete to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists user_rig_pedals_select_own on public.user_rig_pedals;
create policy user_rig_pedals_select_own on public.user_rig_pedals
for select to authenticated
using (exists (
  select 1 from public.user_rigs ur
  where ur.id = user_rig_pedals.user_rig_id
    and ur.user_id = (select auth.uid())
));

drop policy if exists user_rig_pedals_insert_own on public.user_rig_pedals;
create policy user_rig_pedals_insert_own on public.user_rig_pedals
for insert to authenticated
with check (exists (
  select 1 from public.user_rigs ur
  where ur.id = user_rig_pedals.user_rig_id
    and ur.user_id = (select auth.uid())
));

drop policy if exists user_rig_pedals_update_own on public.user_rig_pedals;
create policy user_rig_pedals_update_own on public.user_rig_pedals
for update to authenticated
using (exists (
  select 1 from public.user_rigs ur
  where ur.id = user_rig_pedals.user_rig_id
    and ur.user_id = (select auth.uid())
))
with check (exists (
  select 1 from public.user_rigs ur
  where ur.id = user_rig_pedals.user_rig_id
    and ur.user_id = (select auth.uid())
));

drop policy if exists user_rig_pedals_delete_own on public.user_rig_pedals;
create policy user_rig_pedals_delete_own on public.user_rig_pedals
for delete to authenticated
using (exists (
  select 1 from public.user_rigs ur
  where ur.id = user_rig_pedals.user_rig_id
    and ur.user_id = (select auth.uid())
));

comment on table public.master_tones is
  'Normalized song tone target. Contains musical tone controls only; never stores amplifier-specific adaptations.';
comment on table public.guitar_models is
  'Normalized guitar and bass model behavior profiles independent of user rigs.';
comment on table public.pickup_models is
  'Independent pickup model database so stock pickups and user replacements can be represented by relation.';
comment on table public.amp_models is
  'Normalized amplifier model behavior profiles. Song master tones reference amp archetypes, not concrete amp models.';
comment on table public.cabinet_models is
  'Normalized cabinet and speaker profiles for later rule-engine adaptation.';
comment on table public.pedal_models is
  'Individual pedal profiles with gain, EQ, compression, noise, and tone-color influence.';
comment on table public.multifx_devices is
  'MultiFX/modeler devices with routing, DSP limits, patch structure, and parameter mapping.';
comment on table public.rule_sets is
  'Placeholder for future deterministic rule-engine versions. No rule logic is implemented by this migration.';
comment on table public.cache_key_definitions is
  'Placeholder for future cache-key contracts. This table does not store adaptation results.';
