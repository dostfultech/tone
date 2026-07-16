create extension if not exists pg_trgm;

create or replace function public.slugify_gear(value text)
returns text
language sql
immutable
strict
as $$
  select trim(both '-' from regexp_replace(lower(coalesce(value, '')), '[^a-z0-9]+', '-', 'g'))
$$;

create table if not exists public.guitar_brands (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null,
  search_text text not null default '',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (slug)
);

create table if not exists public.amp_brands (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null,
  search_text text not null default '',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (slug)
);

create table if not exists public.pedal_brands (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null,
  search_text text not null default '',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (slug)
);

create table if not exists public.multifx_brands (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null,
  search_text text not null default '',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (slug)
);

alter table if exists public.guitar_models
  add column if not exists brand_id uuid references public.guitar_brands(id) on delete set null,
  add column if not exists name text,
  add column if not exists slug text,
  add column if not exists category text,
  add column if not exists pickup_configuration text,
  add column if not exists tags text[] not null default '{}'::text[],
  add column if not exists search_text text not null default '';

alter table if exists public.amp_models
  add column if not exists brand_id uuid references public.amp_brands(id) on delete set null,
  add column if not exists name text,
  add column if not exists slug text,
  add column if not exists category text,
  add column if not exists amp_type text,
  add column if not exists tags text[] not null default '{}'::text[],
  add column if not exists search_text text not null default '';

alter table if exists public.pedal_models
  add column if not exists brand_id uuid references public.pedal_brands(id) on delete set null,
  add column if not exists name text,
  add column if not exists slug text,
  add column if not exists category text,
  add column if not exists pedal_type text,
  add column if not exists tags text[] not null default '{}'::text[],
  add column if not exists search_text text not null default '';

create table if not exists public.multifx_models (
  id uuid primary key default gen_random_uuid(),
  brand_id uuid not null references public.multifx_brands(id) on delete cascade,
  name text not null,
  slug text not null,
  category text not null,
  tags text[] not null default '{}'::text[],
  search_text text not null default '',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (brand_id, name)
);

alter table public.profiles
  add column if not exists my_gear_profile jsonb not null default '{"schema_version":1,"guitar":null,"amp":null,"pedals":[],"multifx":null,"updated_at":null}'::jsonb;

comment on column public.profiles.my_gear_profile is
  'Stable My Gear selection payload used by searchable selectors. Stores model_id, brand_name, model_name, category, and pickup/amp/pedal metadata.';

create unique index if not exists guitar_models_brand_slug_unique_idx
  on public.guitar_models (brand_id, slug)
  where brand_id is not null and slug is not null;

create unique index if not exists amp_models_brand_slug_unique_idx
  on public.amp_models (brand_id, slug)
  where brand_id is not null and slug is not null;

create unique index if not exists pedal_models_brand_slug_unique_idx
  on public.pedal_models (brand_id, slug)
  where brand_id is not null and slug is not null;

create unique index if not exists multifx_models_brand_slug_unique_idx
  on public.multifx_models (brand_id, slug);

create index if not exists guitar_models_brand_idx on public.guitar_models (brand_id, is_active, name);
create index if not exists amp_models_brand_idx on public.amp_models (brand_id, is_active, name);
create index if not exists pedal_models_brand_idx on public.pedal_models (brand_id, is_active, name);
create index if not exists multifx_models_brand_idx on public.multifx_models (brand_id, is_active, name);

create index if not exists guitar_models_search_text_tsv_idx on public.guitar_models using gin (to_tsvector('simple', search_text));
create index if not exists amp_models_search_text_tsv_idx on public.amp_models using gin (to_tsvector('simple', search_text));
create index if not exists pedal_models_search_text_tsv_idx on public.pedal_models using gin (to_tsvector('simple', search_text));
create index if not exists multifx_models_search_text_tsv_idx on public.multifx_models using gin (to_tsvector('simple', search_text));

create index if not exists guitar_models_search_text_trgm_idx on public.guitar_models using gin (search_text gin_trgm_ops);
create index if not exists amp_models_search_text_trgm_idx on public.amp_models using gin (search_text gin_trgm_ops);
create index if not exists pedal_models_search_text_trgm_idx on public.pedal_models using gin (search_text gin_trgm_ops);
create index if not exists multifx_models_search_text_trgm_idx on public.multifx_models using gin (search_text gin_trgm_ops);

create or replace function public.sync_guitar_model_search_text()
returns trigger
language plpgsql
as $$
declare
  resolved_brand text := '';
begin
  if new.brand_id is not null then
    select b.name into resolved_brand
    from public.guitar_brands b
    where b.id = new.brand_id;
  end if;

  new.name := coalesce(nullif(btrim(coalesce(new.name, new.model_name)), ''), 'Unknown Guitar');
  new.model_name := new.name;
  new.slug := coalesce(nullif(btrim(new.slug), ''), public.slugify_gear(new.name));
  new.category := coalesce(nullif(btrim(new.category), ''), nullif(btrim(new.body_type), ''), 'electric');
  new.pickup_configuration := coalesce(nullif(btrim(new.pickup_configuration), ''), nullif(btrim(new.pickup_layout), ''), 'unknown');
  new.tags := coalesce(new.tags, '{}'::text[]);
  new.search_text := lower(regexp_replace(concat_ws(' ', resolved_brand, new.name, new.category, new.pickup_configuration, array_to_string(new.tags, ' ')), '\\s+', ' ', 'g'));

  return new;
end;
$$;

create or replace function public.sync_amp_model_search_text()
returns trigger
language plpgsql
as $$
declare
  resolved_brand text := '';
  normalized_amp_type text;
begin
  if new.brand_id is not null then
    select b.name into resolved_brand
    from public.amp_brands b
    where b.id = new.brand_id;
  end if;

  new.name := coalesce(nullif(btrim(coalesce(new.name, new.model_name)), ''), 'Unknown Amp');
  new.model_name := new.name;
  new.slug := coalesce(nullif(btrim(new.slug), ''), public.slugify_gear(new.name));
  new.category := coalesce(nullif(btrim(new.category), ''), 'amp');
  new.tags := coalesce(new.tags, '{}'::text[]);

  normalized_amp_type := coalesce(nullif(btrim(new.amp_type), ''), nullif(btrim(new.amp_technology), ''), 'tube');
  normalized_amp_type := replace(normalized_amp_type, 'digital_modeling', 'modeling');
  new.amp_type := normalized_amp_type;

  if new.amp_technology is null or new.amp_technology = '' then
    new.amp_technology := case
      when normalized_amp_type = 'modeling' then 'digital_modeling'
      when normalized_amp_type = 'solid_state' then 'solid_state'
      when normalized_amp_type = 'hybrid' then 'hybrid'
      when normalized_amp_type = 'plugin' then 'plugin'
      else 'tube'
    end;
  end if;

  new.search_text := lower(regexp_replace(concat_ws(' ', resolved_brand, new.name, new.category, new.amp_type, array_to_string(new.tags, ' ')), '\\s+', ' ', 'g'));

  return new;
end;
$$;

create or replace function public.sync_pedal_model_search_text()
returns trigger
language plpgsql
as $$
declare
  resolved_brand text := '';
  normalized_pedal_type text;
begin
  if new.brand_id is not null then
    select b.name into resolved_brand
    from public.pedal_brands b
    where b.id = new.brand_id;
  end if;

  new.name := coalesce(nullif(btrim(coalesce(new.name, new.model_name)), ''), 'Unknown Pedal');
  new.model_name := new.name;
  new.slug := coalesce(nullif(btrim(new.slug), ''), public.slugify_gear(new.name));
  new.tags := coalesce(new.tags, '{}'::text[]);

  normalized_pedal_type := coalesce(nullif(btrim(new.pedal_type), ''), nullif(btrim(new.pedal_type_id), ''), 'overdrive');
  new.pedal_type := normalized_pedal_type;
  new.pedal_type_id := coalesce(new.pedal_type_id, normalized_pedal_type);
  new.category := coalesce(nullif(btrim(new.category), ''), normalized_pedal_type);

  new.search_text := lower(regexp_replace(concat_ws(' ', resolved_brand, new.name, new.category, new.pedal_type, array_to_string(new.tags, ' ')), '\\s+', ' ', 'g'));

  return new;
end;
$$;

create or replace function public.sync_multifx_model_search_text()
returns trigger
language plpgsql
as $$
declare
  resolved_brand text := '';
begin
  if new.brand_id is not null then
    select b.name into resolved_brand
    from public.multifx_brands b
    where b.id = new.brand_id;
  end if;

  new.name := coalesce(nullif(btrim(new.name), ''), 'Unknown MultiFX');
  new.slug := coalesce(nullif(btrim(new.slug), ''), public.slugify_gear(new.name));
  new.category := coalesce(nullif(btrim(new.category), ''), 'multi-fx');
  new.tags := coalesce(new.tags, '{}'::text[]);
  new.search_text := lower(regexp_replace(concat_ws(' ', resolved_brand, new.name, new.category, array_to_string(new.tags, ' ')), '\\s+', ' ', 'g'));

  return new;
end;
$$;

drop trigger if exists guitar_models_search_text_before_write on public.guitar_models;
create trigger guitar_models_search_text_before_write
before insert or update on public.guitar_models
for each row execute function public.sync_guitar_model_search_text();

drop trigger if exists amp_models_search_text_before_write on public.amp_models;
create trigger amp_models_search_text_before_write
before insert or update on public.amp_models
for each row execute function public.sync_amp_model_search_text();

drop trigger if exists pedal_models_search_text_before_write on public.pedal_models;
create trigger pedal_models_search_text_before_write
before insert or update on public.pedal_models
for each row execute function public.sync_pedal_model_search_text();

drop trigger if exists multifx_models_updated_at on public.multifx_models;
create trigger multifx_models_updated_at
before update on public.multifx_models
for each row execute function public.set_updated_at();

drop trigger if exists multifx_models_search_text_before_write on public.multifx_models;
create trigger multifx_models_search_text_before_write
before insert or update on public.multifx_models
for each row execute function public.sync_multifx_model_search_text();

insert into public.guitar_brands (name, slug, search_text)
values
  ('Fender', 'fender', 'fender electric guitar'),
  ('Gibson', 'gibson', 'gibson electric guitar'),
  ('Epiphone', 'epiphone', 'epiphone electric guitar'),
  ('Ibanez', 'ibanez', 'ibanez electric guitar'),
  ('PRS', 'prs', 'prs electric guitar'),
  ('ESP/LTD', 'esp-ltd', 'esp ltd electric guitar'),
  ('Schecter', 'schecter', 'schecter electric guitar'),
  ('Jackson', 'jackson', 'jackson electric guitar'),
  ('Yamaha', 'yamaha', 'yamaha electric guitar'),
  ('Harley Benton', 'harley-benton', 'harley benton electric guitar'),
  ('Gretsch', 'gretsch', 'gretsch electric guitar'),
  ('Charvel', 'charvel', 'charvel electric guitar'),
  ('Suhr', 'suhr', 'suhr electric guitar'),
  ('Music Man', 'music-man', 'music man electric guitar'),
  ('Solar', 'solar', 'solar electric guitar'),
  ('Dean', 'dean', 'dean electric guitar'),
  ('Kiesel', 'kiesel', 'kiesel electric guitar'),
  ('Cort', 'cort', 'cort electric guitar'),
  ('Washburn', 'washburn', 'washburn electric guitar'),
  ('G&L', 'g-l', 'g and l electric guitar')
on conflict (slug) do update set
  name = excluded.name,
  search_text = excluded.search_text,
  is_active = true,
  updated_at = now();

insert into public.amp_brands (name, slug, search_text)
values
  ('Marshall', 'marshall', 'marshall guitar amp'),
  ('Mesa Boogie', 'mesa-boogie', 'mesa boogie guitar amp'),
  ('Fender', 'fender', 'fender guitar amp'),
  ('Orange', 'orange', 'orange guitar amp'),
  ('Peavey', 'peavey', 'peavey guitar amp'),
  ('EVH', 'evh', 'evh guitar amp'),
  ('Soldano', 'soldano', 'soldano guitar amp'),
  ('Laney', 'laney', 'laney guitar amp'),
  ('Blackstar', 'blackstar', 'blackstar guitar amp'),
  ('Bogner', 'bogner', 'bogner guitar amp'),
  ('Friedman', 'friedman', 'friedman guitar amp'),
  ('ENGL', 'engl', 'engl guitar amp'),
  ('Diezel', 'diezel', 'diezel guitar amp'),
  ('Vox', 'vox', 'vox guitar amp'),
  ('Hughes & Kettner', 'hughes-kettner', 'hughes kettner guitar amp'),
  ('PRS', 'prs', 'prs guitar amp'),
  ('Randall', 'randall', 'randall guitar amp'),
  ('Revv', 'revv', 'revv guitar amp'),
  ('Koch', 'koch', 'koch guitar amp'),
  ('Supro', 'supro', 'supro guitar amp')
on conflict (slug) do update set
  name = excluded.name,
  search_text = excluded.search_text,
  is_active = true,
  updated_at = now();

insert into public.pedal_brands (name, slug, search_text)
values
  ('Boss', 'boss', 'boss pedal'),
  ('MXR', 'mxr', 'mxr pedal'),
  ('Electro-Harmonix', 'electro-harmonix', 'electro harmonix pedal'),
  ('TC Electronic', 'tc-electronic', 'tc electronic pedal'),
  ('Strymon', 'strymon', 'strymon pedal'),
  ('JHS', 'jhs', 'jhs pedal'),
  ('Walrus Audio', 'walrus-audio', 'walrus audio pedal'),
  ('Keeley', 'keeley', 'keeley pedal'),
  ('EarthQuaker Devices', 'earthquaker-devices', 'earthquaker devices pedal'),
  ('Ibanez', 'ibanez', 'ibanez pedal'),
  ('Line 6', 'line-6', 'line 6 pedal'),
  ('Digitech', 'digitech', 'digitech pedal'),
  ('Wampler', 'wampler', 'wampler pedal'),
  ('Source Audio', 'source-audio', 'source audio pedal'),
  ('Darkglass', 'darkglass', 'darkglass pedal'),
  ('Eventide', 'eventide', 'eventide pedal'),
  ('Neunaber', 'neunaber', 'neunaber pedal'),
  ('Mooer', 'mooer', 'mooer pedal'),
  ('NUX', 'nux', 'nux pedal'),
  ('Behringer', 'behringer', 'behringer pedal')
on conflict (slug) do update set
  name = excluded.name,
  search_text = excluded.search_text,
  is_active = true,
  updated_at = now();

insert into public.multifx_brands (name, slug, search_text)
values
  ('Line 6', 'line-6', 'line 6 multi fx'),
  ('Fractal', 'fractal', 'fractal multi fx'),
  ('HeadRush', 'headrush', 'headrush multi fx'),
  ('Kemper', 'kemper', 'kemper multi fx'),
  ('Neural DSP', 'neural-dsp', 'neural dsp multi fx'),
  ('Boss', 'boss', 'boss multi fx'),
  ('Zoom', 'zoom', 'zoom multi fx'),
  ('Mooer', 'mooer', 'mooer multi fx'),
  ('Hotone', 'hotone', 'hotone multi fx'),
  ('Valeton', 'valeton', 'valeton multi fx'),
  ('NUX', 'nux', 'nux multi fx'),
  ('TC Electronic', 'tc-electronic', 'tc electronic multi fx'),
  ('Digitech', 'digitech', 'digitech multi fx'),
  ('Positive Grid', 'positive-grid', 'positive grid multi fx')
on conflict (slug) do update set
  name = excluded.name,
  search_text = excluded.search_text,
  is_active = true,
  updated_at = now();

insert into public.equipment_manufacturers (name, slug)
select distinct seed.name, public.slugify_gear(seed.name)
from (
  select name from public.guitar_brands
  union all
  select name from public.amp_brands
  union all
  select name from public.pedal_brands
  union all
  select name from public.multifx_brands
) as seed
on conflict (slug) do update set
  name = excluded.name,
  is_active = true,
  updated_at = now();

update public.guitar_models gm
set brand_id = gb.id
from public.equipment_manufacturers em
join public.guitar_brands gb on gb.slug = em.slug
where gm.manufacturer_id = em.id
  and gm.brand_id is null;

update public.amp_models am
set brand_id = ab.id
from public.equipment_manufacturers em
join public.amp_brands ab on ab.slug = em.slug
where am.manufacturer_id = em.id
  and am.brand_id is null;

update public.pedal_models pm
set brand_id = pb.id
from public.equipment_manufacturers em
join public.pedal_brands pb on pb.slug = em.slug
where pm.manufacturer_id = em.id
  and pm.brand_id is null;

update public.guitar_models gm
set
  name = coalesce(nullif(gm.name, ''), gm.model_name),
  model_name = coalesce(nullif(gm.model_name, ''), gm.name),
  slug = coalesce(nullif(gm.slug, ''), public.slugify_gear(coalesce(nullif(gm.name, ''), gm.model_name))),
  category = coalesce(nullif(gm.category, ''), nullif(gm.body_type, ''), 'electric'),
  pickup_configuration = coalesce(nullif(gm.pickup_configuration, ''), nullif(gm.pickup_layout, ''), 'unknown'),
  tags = coalesce(gm.tags, '{}'::text[]),
  search_text = lower(regexp_replace(concat_ws(' ', (select gb.name from public.guitar_brands gb where gb.id = gm.brand_id), coalesce(nullif(gm.name, ''), gm.model_name), coalesce(gm.category, ''), coalesce(gm.pickup_configuration, ''), array_to_string(coalesce(gm.tags, '{}'::text[]), ' ')), '\\s+', ' ', 'g'));

update public.amp_models am
set
  name = coalesce(nullif(am.name, ''), am.model_name),
  model_name = coalesce(nullif(am.model_name, ''), am.name),
  slug = coalesce(nullif(am.slug, ''), public.slugify_gear(coalesce(nullif(am.name, ''), am.model_name))),
  category = coalesce(nullif(am.category, ''), 'amp'),
  amp_type = coalesce(nullif(am.amp_type, ''), replace(coalesce(am.amp_technology, ''), 'digital_modeling', 'modeling'), 'tube'),
  tags = coalesce(am.tags, '{}'::text[]),
  search_text = lower(regexp_replace(concat_ws(' ', (select ab.name from public.amp_brands ab where ab.id = am.brand_id), coalesce(nullif(am.name, ''), am.model_name), coalesce(am.category, ''), coalesce(am.amp_type, ''), array_to_string(coalesce(am.tags, '{}'::text[]), ' ')), '\\s+', ' ', 'g'));

update public.pedal_models pm
set
  name = coalesce(nullif(pm.name, ''), pm.model_name),
  model_name = coalesce(nullif(pm.model_name, ''), pm.name),
  slug = coalesce(nullif(pm.slug, ''), public.slugify_gear(coalesce(nullif(pm.name, ''), pm.model_name))),
  pedal_type = coalesce(nullif(pm.pedal_type, ''), pm.pedal_type_id, 'overdrive'),
  category = coalesce(nullif(pm.category, ''), coalesce(nullif(pm.pedal_type, ''), pm.pedal_type_id, 'pedal')),
  tags = coalesce(pm.tags, '{}'::text[]),
  search_text = lower(regexp_replace(concat_ws(' ', (select pb.name from public.pedal_brands pb where pb.id = pm.brand_id), coalesce(nullif(pm.name, ''), pm.model_name), coalesce(pm.category, ''), coalesce(pm.pedal_type, ''), array_to_string(coalesce(pm.tags, '{}'::text[]), ' ')), '\\s+', ' ', 'g'));

with guitar_seed as (
  select
    gb.id as brand_id,
    em.id as manufacturer_id,
    gs.n as seq,
    (array['Apex', 'Nova', 'Vertex', 'Horizon', 'Pulse', 'Orbit', 'Summit', 'Phoenix', 'Atlas', 'Falcon'])[(gs.n % 10) + 1] as family,
    (array['Standard', 'Studio', 'Custom', 'Vintage', 'Modern', 'Elite', 'Artist', 'Deluxe', 'Core', 'Signature'])[(gs.n % 10) + 1] as series,
    (array['solid-body', 'super-strat', 'semi-hollow', 'offset'])[(gs.n % 4) + 1] as category,
    (array['SSS', 'HSS', 'HH', 'HSH', 'P90', 'Active HH'])[(gs.n % 6) + 1] as pickup_configuration,
    (array['classic', 'modern', 'high-output', 'vintage', 'touring', 'session'])[(gs.n % 6) + 1] as tag_one,
    (array['rock', 'metal', 'blues', 'indie', 'fusion', 'pop'])[((gs.n + 2) % 6) + 1] as tag_two
  from public.guitar_brands gb
  join public.equipment_manufacturers em on em.slug = gb.slug
  cross join generate_series(1, 260) as gs(n)
),
ranked_guitars as (
  select *, row_number() over (order by brand_id, seq) as rn
  from guitar_seed
)
insert into public.guitar_models (
  manufacturer_id,
  brand_id,
  model_name,
  name,
  slug,
  category,
  pickup_configuration,
  tags,
  instrument_type,
  is_active
)
select
  manufacturer_id,
  brand_id,
  concat(family, ' ', series, ' ', lpad(seq::text, 3, '0')),
  concat(family, ' ', series, ' ', lpad(seq::text, 3, '0')),
  public.slugify_gear(concat(family, ' ', series, ' ', lpad(seq::text, 3, '0'))),
  category,
  pickup_configuration,
  array[tag_one, tag_two],
  'guitar',
  true
from ranked_guitars
where rn <= 2200
on conflict (manufacturer_id, model_name, instrument_type) do update set
  brand_id = excluded.brand_id,
  name = excluded.name,
  slug = excluded.slug,
  category = excluded.category,
  pickup_configuration = excluded.pickup_configuration,
  tags = excluded.tags,
  is_active = true,
  updated_at = now();

with amp_seed as (
  select
    ab.id as brand_id,
    em.id as manufacturer_id,
    gs.n as seq,
    (array['Titan', 'Orbit', 'Vector', 'Signal', 'Atlas', 'Voltage', 'Summit', 'Axion'])[(gs.n % 8) + 1] as family,
    (array['MKI', 'MKII', 'MKIII', 'Legacy', 'Pro', 'Artist', 'Tour', 'Studio'])[(gs.n % 8) + 1] as series,
    (array['head', 'combo', 'lunchbox', 'rack'])[(gs.n % 4) + 1] as category,
    (array['tube', 'solid_state', 'hybrid', 'modeling'])[(gs.n % 4) + 1] as amp_type,
    (array['vintage', 'modern', 'high-gain', 'clean', 'tight', 'dynamic'])[(gs.n % 6) + 1] as tag_one,
    (array['rock', 'metal', 'blues', 'session', 'touring', 'direct'])[((gs.n + 3) % 6) + 1] as tag_two
  from public.amp_brands ab
  join public.equipment_manufacturers em on em.slug = ab.slug
  cross join generate_series(1, 180) as gs(n)
),
ranked_amps as (
  select *, row_number() over (order by brand_id, seq) as rn
  from amp_seed
)
insert into public.amp_models (
  manufacturer_id,
  brand_id,
  model_name,
  name,
  slug,
  category,
  amp_type,
  tags,
  instrument_type,
  amp_technology,
  is_active
)
select
  manufacturer_id,
  brand_id,
  concat(family, ' ', series, ' ', lpad(seq::text, 3, '0')),
  concat(family, ' ', series, ' ', lpad(seq::text, 3, '0')),
  public.slugify_gear(concat(family, ' ', series, ' ', lpad(seq::text, 3, '0'))),
  category,
  amp_type,
  array[tag_one, tag_two],
  'guitar',
  case
    when amp_type = 'modeling' then 'digital_modeling'
    when amp_type = 'solid_state' then 'solid_state'
    when amp_type = 'hybrid' then 'hybrid'
    else 'tube'
  end,
  true
from ranked_amps
where rn <= 1600
on conflict (manufacturer_id, model_name, instrument_type) do update set
  brand_id = excluded.brand_id,
  name = excluded.name,
  slug = excluded.slug,
  category = excluded.category,
  amp_type = excluded.amp_type,
  tags = excluded.tags,
  amp_technology = excluded.amp_technology,
  is_active = true,
  updated_at = now();

with pedal_seed as (
  select
    pb.id as brand_id,
    em.id as manufacturer_id,
    gs.n as seq,
    (array['Drive', 'Color', 'Pulse', 'Shift', 'Phase', 'Signal', 'Echo', 'Tone'])[(gs.n % 8) + 1] as family,
    (array['overdrive', 'distortion', 'fuzz', 'delay', 'reverb', 'chorus', 'compressor', 'eq', 'noise_gate', 'phaser'])[(gs.n % 10) + 1] as pedal_type,
    (array['classic', 'modern', 'warm', 'tight', 'ambient', 'studio'])[(gs.n % 6) + 1] as tag_one,
    (array['lead', 'rhythm', 'ambient', 'metal', 'rock', 'indie'])[((gs.n + 1) % 6) + 1] as tag_two
  from public.pedal_brands pb
  join public.equipment_manufacturers em on em.slug = pb.slug
  cross join generate_series(1, 120) as gs(n)
),
ranked_pedals as (
  select *, row_number() over (order by brand_id, seq) as rn
  from pedal_seed
)
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
  is_active
)
select
  manufacturer_id,
  brand_id,
  concat(family, ' ', upper(substr(pedal_type, 1, 3)), ' ', lpad(seq::text, 3, '0')),
  concat(family, ' ', upper(substr(pedal_type, 1, 3)), ' ', lpad(seq::text, 3, '0')),
  public.slugify_gear(concat(family, ' ', upper(substr(pedal_type, 1, 3)), ' ', lpad(seq::text, 3, '0'))),
  pedal_type,
  pedal_type,
  pedal_type,
  array[tag_one, tag_two],
  true
from ranked_pedals
where rn <= 1100
on conflict (manufacturer_id, model_name, pedal_type_id) do update set
  brand_id = excluded.brand_id,
  name = excluded.name,
  slug = excluded.slug,
  category = excluded.category,
  pedal_type = excluded.pedal_type,
  tags = excluded.tags,
  is_active = true,
  updated_at = now();

with multifx_seed as (
  select
    mb.id as brand_id,
    gs.n as seq,
    (array['Prime', 'Core', 'Flex', 'Apex', 'Axis', 'Vertex', 'Pulse', 'Nova'])[(gs.n % 8) + 1] as family,
    (array['Floor', 'Rack', 'Studio', 'Tour', 'Compact'])[(gs.n % 5) + 1] as category,
    (array['modeling', 'capture', 'direct', 'routing', 'studio'])[(gs.n % 5) + 1] as tag_one,
    (array['live', 'touring', 'recording', 'practice', 'hybrid'])[((gs.n + 2) % 5) + 1] as tag_two
  from public.multifx_brands mb
  cross join generate_series(1, 80) as gs(n)
),
ranked_multifx as (
  select *, row_number() over (order by brand_id, seq) as rn
  from multifx_seed
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
  brand_id,
  concat(family, ' ', lpad(seq::text, 3, '0')),
  public.slugify_gear(concat(family, ' ', lpad(seq::text, 3, '0'))),
  category,
  array[tag_one, tag_two],
  true
from ranked_multifx
where rn <= 750
on conflict (brand_id, name) do update set
  slug = excluded.slug,
  category = excluded.category,
  tags = excluded.tags,
  is_active = true,
  updated_at = now();

alter table public.guitar_brands enable row level security;
alter table public.amp_brands enable row level security;
alter table public.pedal_brands enable row level security;
alter table public.multifx_brands enable row level security;
alter table public.multifx_models enable row level security;

grant select on public.guitar_brands to anon, authenticated;
grant select on public.amp_brands to anon, authenticated;
grant select on public.pedal_brands to anon, authenticated;
grant select on public.multifx_brands to anon, authenticated;
grant select on public.multifx_models to anon, authenticated;

grant select, insert, update, delete on public.guitar_brands to service_role;
grant select, insert, update, delete on public.amp_brands to service_role;
grant select, insert, update, delete on public.pedal_brands to service_role;
grant select, insert, update, delete on public.multifx_brands to service_role;
grant select, insert, update, delete on public.multifx_models to service_role;

drop policy if exists guitar_brands_public_read_active on public.guitar_brands;
create policy guitar_brands_public_read_active on public.guitar_brands
for select to anon, authenticated
using (is_active = true);

drop policy if exists amp_brands_public_read_active on public.amp_brands;
create policy amp_brands_public_read_active on public.amp_brands
for select to anon, authenticated
using (is_active = true);

drop policy if exists pedal_brands_public_read_active on public.pedal_brands;
create policy pedal_brands_public_read_active on public.pedal_brands
for select to anon, authenticated
using (is_active = true);

drop policy if exists multifx_brands_public_read_active on public.multifx_brands;
create policy multifx_brands_public_read_active on public.multifx_brands
for select to anon, authenticated
using (is_active = true);

drop policy if exists multifx_models_public_read_active on public.multifx_models;
create policy multifx_models_public_read_active on public.multifx_models
for select to anon, authenticated
using (is_active = true);

drop trigger if exists guitar_brands_updated_at on public.guitar_brands;
create trigger guitar_brands_updated_at before update on public.guitar_brands for each row execute function public.set_updated_at();

drop trigger if exists amp_brands_updated_at on public.amp_brands;
create trigger amp_brands_updated_at before update on public.amp_brands for each row execute function public.set_updated_at();

drop trigger if exists pedal_brands_updated_at on public.pedal_brands;
create trigger pedal_brands_updated_at before update on public.pedal_brands for each row execute function public.set_updated_at();

drop trigger if exists multifx_brands_updated_at on public.multifx_brands;
create trigger multifx_brands_updated_at before update on public.multifx_brands for each row execute function public.set_updated_at();
