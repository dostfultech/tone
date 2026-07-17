begin;

create extension if not exists pg_trgm;

-- ====================================================
-- COMPLETE REBUILD: single master equipment catalog
-- ====================================================

drop table if exists public.equipment cascade;

drop type if exists public.equipment_type cascade;
drop type if exists public.equipment_status cascade;
drop type if exists public.equipment_body_type cascade;
drop type if exists public.equipment_bridge_type cascade;
drop type if exists public.equipment_pickup_configuration cascade;
drop type if exists public.equipment_pickup_type cascade;
drop type if exists public.equipment_output_level cascade;
drop type if exists public.equipment_amp_type cascade;
drop type if exists public.equipment_amp_technology cascade;
drop type if exists public.equipment_gain_range cascade;
drop type if exists public.equipment_genre cascade;
drop type if exists public.equipment_tone_characteristic cascade;

create type public.equipment_type as enum (
  'electric_guitar',
  'bass_guitar',
  'guitar_amp',
  'bass_amp'
);

create type public.equipment_status as enum (
  'active',
  'discontinued'
);

create type public.equipment_body_type as enum (
  'solid_body',
  'semi_hollow',
  'hollow_body'
);

create type public.equipment_bridge_type as enum (
  'fixed',
  'vintage_tremolo',
  'two_point_tremolo',
  'floyd_rose',
  'string_through',
  'tune_o_matic',
  'bigsby',
  'evertune',
  'other'
);

create type public.equipment_pickup_configuration as enum (
  'sss',
  'hss',
  'hh',
  'hsh',
  'hs',
  'ssh',
  'p90',
  'hhh',
  'ss',
  'p',
  'j',
  'pj',
  'jj',
  'soapbar',
  'mm',
  'other'
);

create type public.equipment_pickup_type as enum (
  'single_coil',
  'humbucker',
  'p90',
  'active_humbucker',
  'passive_humbucker',
  'active_single_coil',
  'passive_single_coil',
  'mini_humbucker',
  'filtertron',
  'active',
  'passive',
  'active_pj',
  'passive_pj'
);

create type public.equipment_output_level as enum (
  'low',
  'medium',
  'high',
  'very_high'
);

create type public.equipment_amp_type as enum (
  'combo',
  'head',
  'rack',
  'power_amp'
);

create type public.equipment_amp_technology as enum (
  'tube',
  'solid_state',
  'hybrid',
  'digital'
);

create type public.equipment_gain_range as enum (
  'low',
  'medium',
  'high',
  'extreme'
);

create type public.equipment_genre as enum (
  'rock',
  'metal',
  'hard_rock',
  'classic_rock',
  'blues',
  'jazz',
  'country',
  'pop',
  'funk',
  'fusion',
  'progressive',
  'indie',
  'alternative',
  'punk'
);

create type public.equipment_tone_characteristic as enum (
  'warm',
  'bright',
  'balanced',
  'modern',
  'vintage',
  'aggressive',
  'tight',
  'punchy',
  'smooth',
  'crunchy',
  'scooped',
  'mid_focused',
  'articulate',
  'dynamic',
  'clean',
  'crunch',
  'high_gain',
  'clean_headroom'
);

create table public.equipment (
  id uuid primary key default gen_random_uuid(),
  equipment_type public.equipment_type not null,
  brand text not null,
  brand_slug text not null,
  model text not null,
  series text not null,
  display_name text not null,
  description text not null,
  is_popular boolean not null default false,
  search_terms text[] not null default '{}'::text[],
  search_text text not null default '',
  status public.equipment_status not null default 'active',
  sort_order integer not null default 100,

  body_type public.equipment_body_type,
  frets integer,
  scale_length_inches numeric(4,2),
  bridge_type public.equipment_bridge_type,
  pickup_configuration public.equipment_pickup_configuration,
  pickup_type public.equipment_pickup_type[] not null default '{}'::public.equipment_pickup_type[],
  output_level public.equipment_output_level,

  amp_type public.equipment_amp_type,
  technology public.equipment_amp_technology,
  power_rating_watts integer,
  channels integer,
  gain_range public.equipment_gain_range,

  genres public.equipment_genre[] not null default '{}'::public.equipment_genre[],
  tone_characteristics public.equipment_tone_characteristic[] not null default '{}'::public.equipment_tone_characteristic[],

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint equipment_unique_model unique (equipment_type, brand, model),
  constraint equipment_brand_not_blank check (char_length(trim(brand)) > 0),
  constraint equipment_model_not_blank check (char_length(trim(model)) > 0),
  constraint equipment_display_name_not_blank check (char_length(trim(display_name)) > 0),

  constraint equipment_required_guitar_metadata check (
    equipment_type not in ('electric_guitar', 'bass_guitar')
    or (
      body_type is not null
      and frets is not null
      and scale_length_inches is not null
      and bridge_type is not null
      and pickup_configuration is not null
      and cardinality(pickup_type) > 0
      and output_level is not null
    )
  ),

  constraint equipment_required_amp_metadata check (
    equipment_type not in ('guitar_amp', 'bass_amp')
    or (
      amp_type is not null
      and technology is not null
      and power_rating_watts is not null
      and channels is not null
      and gain_range is not null
    )
  )
);

create index equipment_type_idx on public.equipment (equipment_type);
create index equipment_brand_idx on public.equipment (brand);
create index equipment_brand_slug_idx on public.equipment (brand_slug);
create index equipment_model_idx on public.equipment (model);
create index equipment_popularity_idx on public.equipment (equipment_type, is_popular desc, sort_order, brand, model);
create index equipment_status_idx on public.equipment (status);
create index equipment_search_terms_gin_idx on public.equipment using gin (search_terms);
create index equipment_search_text_trgm_idx on public.equipment using gin (search_text gin_trgm_ops);

create or replace function public.normalize_equipment_text(value text)
returns text
language sql
immutable
as $$
  select trim(regexp_replace(coalesce(value, ''), '\\s+', ' ', 'g'))
$$;

create or replace function public.slugify_equipment(value text)
returns text
language sql
immutable
as $$
  select trim(both '-' from regexp_replace(lower(coalesce(value, '')), '[^a-z0-9]+', '-', 'g'))
$$;

create or replace function public.tokenize_equipment_text(value text)
returns text[]
language sql
immutable
as $$
  select coalesce(array_agg(distinct token), '{}'::text[])
  from (
    select trim(token) as token
    from unnest(regexp_split_to_array(lower(public.normalize_equipment_text(value)), '[^a-z0-9]+')) token
    where token is not null
      and char_length(trim(token)) >= 2
      and token not in ('the', 'with', 'and', 'for', 'of', 'to', 'in', 'on', 'at')
  ) t
$$;

create or replace function public.equipment_model_synonyms(model_text text)
returns text[]
language plpgsql
immutable
as $$
declare
  m text := lower(public.normalize_equipment_text(model_text));
  synonyms text[] := '{}'::text[];
begin
  if m like '%stratocaster%' then
    synonyms := synonyms || array['strat', 'fender strat'];
  end if;

  if m like '%telecaster%' then
    synonyms := synonyms || array['tele', 'fender tele'];
  end if;

  if m like '%jazzmaster%' then
    synonyms := synonyms || array['jm'];
  end if;

  if m like '%precision bass%' then
    synonyms := synonyms || array['p bass', 'pbass', 'precision'];
  end if;

  if m like '%jazz bass%' then
    synonyms := synonyms || array['j bass', 'jbass', 'jazz'];
  end if;

  if m like '%les paul%' then
    synonyms := synonyms || array['lp', 'lespaul'];
  end if;

  if m like '%american professional ii%' then
    synonyms := synonyms || array['american pro ii', 'professional ii', 'pro ii'];
  end if;

  if m like '%player plus%' then
    synonyms := synonyms || array['player plus'];
  end if;

  if m like '%pro bucker%' or m like '%pro buckers%' or m like '%probucker%' or m like '%probuckers%' then
    synonyms := synonyms || array['probucker', 'probuckers', 'pro bucker', 'pro buckers', 'buckers'];
  end if;

  if m like '%jcm%' then
    synonyms := synonyms || array['marshall jcm'];
  end if;

  if m like '%dsl%' then
    synonyms := synonyms || array['marshall dsl'];
  end if;

  return (select coalesce(array_agg(distinct trim(v)), '{}'::text[]) from unnest(synonyms) v where char_length(trim(v)) > 0);
end;
$$;

create or replace function public.array_text_distinct(input_arr text[])
returns text[]
language sql
immutable
as $$
  select coalesce(array_agg(distinct trim(v)), '{}'::text[])
  from unnest(coalesce(input_arr, '{}'::text[])) v
  where char_length(trim(v)) > 0
$$;

create or replace function public.apply_equipment_defaults()
returns trigger
language plpgsql
as $$
declare
  normalized_model text;
  guessed_watts integer;
  all_terms text[];
begin
  new.brand := public.normalize_equipment_text(new.brand);
  new.model := public.normalize_equipment_text(new.model);
  new.series := public.normalize_equipment_text(coalesce(nullif(new.series, ''), split_part(new.model, ' ', 1)));
  new.display_name := public.normalize_equipment_text(coalesce(nullif(new.display_name, ''), concat_ws(' ', new.brand, new.model)));
  new.description := public.normalize_equipment_text(new.description);
  new.brand_slug := public.slugify_equipment(new.brand);

  normalized_model := lower(new.model);

  if new.equipment_type in ('electric_guitar', 'bass_guitar') then
    new.body_type := coalesce(
      new.body_type,
      case
        when normalized_model like '%es-%' or normalized_model like '%semi%' then 'semi_hollow'::public.equipment_body_type
        when normalized_model like '%hollow%' or normalized_model like '%casino%' or normalized_model like '%falcon%' then 'hollow_body'::public.equipment_body_type
        else 'solid_body'::public.equipment_body_type
      end
    );

    new.pickup_configuration := coalesce(
      new.pickup_configuration,
      case
        when new.equipment_type = 'bass_guitar' and normalized_model like '%precision%' then 'p'::public.equipment_pickup_configuration
        when new.equipment_type = 'bass_guitar' and normalized_model like '%jazz%' then 'j'::public.equipment_pickup_configuration
        when new.equipment_type = 'bass_guitar' and normalized_model like '%pj%' then 'pj'::public.equipment_pickup_configuration
        when new.equipment_type = 'bass_guitar' and normalized_model like '%stingray%' then 'mm'::public.equipment_pickup_configuration
        when new.equipment_type = 'bass_guitar' then 'other'::public.equipment_pickup_configuration
        when normalized_model like '%strat%' then 'sss'::public.equipment_pickup_configuration
        when normalized_model like '%tele%' then 'ss'::public.equipment_pickup_configuration
        when normalized_model like '%jaguar%' or normalized_model like '%jazzmaster%' or normalized_model like '%mustang%' then 'ss'::public.equipment_pickup_configuration
        when normalized_model like '%p90%' then 'p90'::public.equipment_pickup_configuration
        when normalized_model like '%hss%' then 'hss'::public.equipment_pickup_configuration
        when normalized_model like '%hsh%' then 'hsh'::public.equipment_pickup_configuration
        when normalized_model like '%les paul%' or normalized_model like '%sg%' or normalized_model like '%explorer%' or normalized_model like '%flying v%' then 'hh'::public.equipment_pickup_configuration
        else 'other'::public.equipment_pickup_configuration
      end
    );

    if cardinality(new.pickup_type) = 0 then
      if new.equipment_type = 'bass_guitar' then
        if normalized_model like '%active%' then
          new.pickup_type := array['active'::public.equipment_pickup_type];
        else
          new.pickup_type := array['passive'::public.equipment_pickup_type];
        end if;
      else
        new.pickup_type := case
          when new.pickup_configuration in ('sss', 'ss', 'hs', 'ssh') then array['passive_single_coil'::public.equipment_pickup_type]
          when new.pickup_configuration = 'p90' then array['p90'::public.equipment_pickup_type]
          else array['passive_humbucker'::public.equipment_pickup_type]
        end;
      end if;
    end if;

    new.output_level := coalesce(
      new.output_level,
      case
        when normalized_model like '%active%' or normalized_model like '%metal%' or normalized_model like '%hellraiser%' then 'high'::public.equipment_output_level
        else 'medium'::public.equipment_output_level
      end
    );

    new.bridge_type := coalesce(
      new.bridge_type,
      case
        when normalized_model like '%floyd%' then 'floyd_rose'::public.equipment_bridge_type
        when normalized_model like '%bigsby%' then 'bigsby'::public.equipment_bridge_type
        when normalized_model like '%trem%' then 'vintage_tremolo'::public.equipment_bridge_type
        else 'fixed'::public.equipment_bridge_type
      end
    );

    new.frets := coalesce(
      new.frets,
      case
        when new.equipment_type = 'bass_guitar' then 21
        when new.brand in ('Ibanez', 'Jackson', 'Schecter', 'ESP', 'LTD', 'Solar', 'Kiesel', 'Charvel') then 24
        else 22
      end
    );

    new.scale_length_inches := coalesce(
      new.scale_length_inches,
      case
        when new.equipment_type = 'bass_guitar' and normalized_model like '%mustang%' then 30.00
        when new.equipment_type = 'bass_guitar' then 34.00
        when new.brand in ('Gibson', 'Epiphone', 'PRS', 'Gretsch', 'Dean') then 24.75
        else 25.50
      end
    );

    new.amp_type := null;
    new.technology := null;
    new.power_rating_watts := null;
    new.channels := null;
    new.gain_range := null;

    if cardinality(new.genres) = 0 then
      new.genres := case
        when new.equipment_type = 'bass_guitar' then array['rock', 'pop', 'funk']::public.equipment_genre[]
        else array['rock', 'blues', 'pop']::public.equipment_genre[]
      end;
    end if;

    if cardinality(new.tone_characteristics) = 0 then
      new.tone_characteristics := case
        when new.equipment_type = 'bass_guitar' then array['punchy', 'balanced', 'tight']::public.equipment_tone_characteristic[]
        else array['balanced', 'dynamic', 'articulate']::public.equipment_tone_characteristic[]
      end;
    end if;
  end if;

  if new.equipment_type in ('guitar_amp', 'bass_amp') then
    new.amp_type := coalesce(
      new.amp_type,
      case
        when normalized_model like '%head%' or normalized_model like '%h%' then 'head'::public.equipment_amp_type
        when normalized_model like '%rack%' then 'rack'::public.equipment_amp_type
        else 'combo'::public.equipment_amp_type
      end
    );

    new.technology := coalesce(
      new.technology,
      case
        when new.brand in ('Line 6', 'Boss', 'Darkglass') then 'digital'::public.equipment_amp_technology
        when new.brand in ('Markbass', 'Hartke', 'Gallien Krueger', 'TC Electronic') then 'solid_state'::public.equipment_amp_technology
        when normalized_model like '%mustang%' or normalized_model like '%katana%' or normalized_model like '%spider%' or normalized_model like '%id:%' then 'digital'::public.equipment_amp_technology
        when normalized_model like '%mini%' and new.brand in ('Peavey', 'Orange') then 'hybrid'::public.equipment_amp_technology
        else 'tube'::public.equipment_amp_technology
      end
    );

    guessed_watts := nullif(substring(normalized_model from '([0-9]{2,4})w'), '')::integer;
    if guessed_watts is null then
      guessed_watts := nullif(substring(normalized_model from '([0-9]{2,4})'), '')::integer;
    end if;

    new.power_rating_watts := coalesce(new.power_rating_watts, guessed_watts, case when new.equipment_type = 'bass_amp' then 500 else 50 end);
    new.channels := coalesce(new.channels, case when new.equipment_type = 'bass_amp' then 1 else 2 end);

    new.gain_range := coalesce(
      new.gain_range,
      case
        when normalized_model like '%6505%' or normalized_model like '%5150%' or normalized_model like '%rectifier%' or normalized_model like '%powerball%' or normalized_model like '%fireball%' then 'extreme'::public.equipment_gain_range
        when new.brand in ('Mesa Boogie', 'EVH', 'Soldano', 'Diezel', 'Engl') then 'high'::public.equipment_gain_range
        when new.brand in ('Fender', 'Ampeg', 'Markbass', 'Hartke', 'TC Electronic') then 'medium'::public.equipment_gain_range
        else 'high'::public.equipment_gain_range
      end
    );

    new.body_type := null;
    new.frets := null;
    new.scale_length_inches := null;
    new.bridge_type := null;
    new.pickup_configuration := null;
    new.pickup_type := '{}'::public.equipment_pickup_type[];
    new.output_level := null;

    if cardinality(new.genres) = 0 then
      new.genres := case
        when new.equipment_type = 'bass_amp' then array['rock', 'funk', 'pop']::public.equipment_genre[]
        else array['rock', 'hard_rock', 'blues']::public.equipment_genre[]
      end;
    end if;

    if cardinality(new.tone_characteristics) = 0 then
      new.tone_characteristics := case
        when new.equipment_type = 'bass_amp' then array['clean_headroom', 'punchy', 'tight']::public.equipment_tone_characteristic[]
        else array['clean', 'crunch', 'dynamic']::public.equipment_tone_characteristic[]
      end;
    end if;
  end if;

  all_terms := public.array_text_distinct(
    coalesce(new.search_terms, '{}'::text[])
    || public.tokenize_equipment_text(concat_ws(' ', new.brand, new.model, new.series, new.display_name))
    || public.equipment_model_synonyms(concat_ws(' ', new.model, new.series))
  );

  new.search_terms := all_terms;
  new.search_text := lower(public.normalize_equipment_text(concat_ws(' ', new.brand, new.model, new.series, new.display_name, array_to_string(all_terms, ' '))));
  new.updated_at := now();

  return new;
end;
$$;

drop trigger if exists equipment_before_write on public.equipment;
create trigger equipment_before_write
before insert or update on public.equipment
for each row execute function public.apply_equipment_defaults();

alter table public.equipment enable row level security;

grant select on public.equipment to anon, authenticated;
grant select, insert, update, delete on public.equipment to service_role;

drop policy if exists equipment_public_read_active on public.equipment;
create policy equipment_public_read_active on public.equipment
for select to anon, authenticated
using (status = 'active');

-- ====================================================
-- Fresh curated production catalog seed (real models only)
-- ====================================================
with seed(equipment_type, brand, model, series, is_popular, description) as (
  values
  -- Electric Guitars: Fender
  ('electric_guitar', 'Fender', 'Player Stratocaster', 'Player', true, 'Modern Stratocaster with versatile tones for rock, blues, and pop.'),
  ('electric_guitar', 'Fender', 'Player Telecaster', 'Player', true, 'Classic Telecaster feel with articulate attack and bright rhythm tones.'),
  ('electric_guitar', 'Fender', 'Player Plus Stratocaster', 'Player Plus', true, 'Upgraded Stratocaster with modern switching and broad genre coverage.'),
  ('electric_guitar', 'Fender', 'Player Plus Telecaster', 'Player Plus', true, 'Modern Tele platform with expanded tonal flexibility.'),
  ('electric_guitar', 'Fender', 'American Professional II Stratocaster', 'American Professional II', true, 'Flagship Stratocaster balancing vintage feel with modern reliability.'),
  ('electric_guitar', 'Fender', 'American Professional II Telecaster', 'American Professional II', true, 'Professional-grade Telecaster with dynamic response and tight lows.'),
  ('electric_guitar', 'Fender', 'American Ultra Stratocaster', 'American Ultra', true, 'Premium Stratocaster with refined ergonomics and modern voicing.'),
  ('electric_guitar', 'Fender', 'American Ultra Telecaster', 'American Ultra', true, 'High-end Telecaster tuned for articulate cleans and cutting drive tones.'),
  ('electric_guitar', 'Fender', 'American Vintage II 1961 Stratocaster', 'American Vintage II', false, 'Vintage-correct Strat platform with classic single-coil character.'),
  ('electric_guitar', 'Fender', 'American Vintage II 1951 Telecaster', 'American Vintage II', false, 'Early-era Telecaster voice with direct attack and strong mid presence.'),
  ('electric_guitar', 'Fender', 'Vintera II 50s Stratocaster', 'Vintera II', false, '50s-inspired Stratocaster with bright attack and vintage feel.'),
  ('electric_guitar', 'Fender', 'Vintera II 60s Stratocaster', 'Vintera II', false, '60s-style Strat with chimey highs and clear clean articulation.'),
  ('electric_guitar', 'Fender', 'Vintera II 50s Telecaster', 'Vintera II', false, '50s Telecaster style with classic twang and quick transient response.'),
  ('electric_guitar', 'Fender', 'Vintera II 60s Telecaster', 'Vintera II', false, '60s Telecaster flavor for tight rhythm and cutting lead work.'),
  ('electric_guitar', 'Fender', 'Player Jazzmaster', 'Player', true, 'Offset design with broad frequency range and smooth driven character.'),
  ('electric_guitar', 'Fender', 'Player Jaguar', 'Player', true, 'Compact offset voice with percussive attack and punchy response.'),
  ('electric_guitar', 'Fender', 'Player Mustang', 'Player', false, 'Short-scale offset with fast feel and focused midrange.'),
  ('electric_guitar', 'Fender', 'American Performer Stratocaster', 'American Performer', true, 'USA Stratocaster focused on practical stage-ready versatility.'),
  ('electric_guitar', 'Fender', 'American Performer Telecaster', 'American Performer', true, 'USA Tele platform with balanced output and strong note definition.'),
  ('electric_guitar', 'Fender', 'Kurt Cobain Jaguar', 'Artist', false, 'Signature Jaguar with high-output voice for aggressive alternative tones.'),

  -- Electric Guitars: Gibson
  ('electric_guitar', 'Gibson', 'Les Paul Standard 50s', 'Les Paul Standard', true, 'Classic Les Paul with warm sustain and rich mid-focused tone.'),
  ('electric_guitar', 'Gibson', 'Les Paul Standard 60s', 'Les Paul Standard', true, 'Les Paul voice with articulate highs and modern playability.'),
  ('electric_guitar', 'Gibson', 'Les Paul Studio', 'Les Paul', true, 'Studio-oriented Les Paul with powerful rock-ready humbucker output.'),
  ('electric_guitar', 'Gibson', 'Les Paul Classic', 'Les Paul', true, 'Les Paul platform blending vintage flavor and modern switching options.'),
  ('electric_guitar', 'Gibson', 'Les Paul Modern', 'Les Paul', true, 'Modernized Les Paul with expanded tonal flexibility and comfort.'),
  ('electric_guitar', 'Gibson', 'SG Standard', 'SG', true, 'Iconic SG with upper-mid bite and dynamic crunch response.'),
  ('electric_guitar', 'Gibson', 'SG Special', 'SG', false, 'SG variant tuned for direct attack and expressive midrange.'),
  ('electric_guitar', 'Gibson', 'Explorer', 'Explorer', true, 'High-output Explorer voice designed for hard rock and metal.'),
  ('electric_guitar', 'Gibson', 'Flying V', 'Flying V', true, 'Aggressive V-shaped platform with focused high-gain articulation.'),
  ('electric_guitar', 'Gibson', 'ES-335', 'ES', true, 'Semi-hollow classic with smooth sustain and versatile genre coverage.'),
  ('electric_guitar', 'Gibson', 'ES-339', 'ES', false, 'Compact semi-hollow with controlled low end and clear upper mids.'),
  ('electric_guitar', 'Gibson', 'Les Paul Junior', 'Les Paul', false, 'Straightforward single-pickup platform with punchy rock response.'),
  ('electric_guitar', 'Gibson', 'Les Paul Special', 'Les Paul', false, 'Classic dual-pickup workhorse with direct and dynamic feel.'),
  ('electric_guitar', 'Gibson', 'Firebird', 'Firebird', false, 'Distinctive Gibson platform with tight lows and articulate highs.'),

  -- Electric Guitars: Epiphone
  ('electric_guitar', 'Epiphone', 'Les Paul Standard 50s', 'Les Paul Standard', true, 'Epiphone Les Paul built for classic rock sustain and warm mids.'),
  ('electric_guitar', 'Epiphone', 'Les Paul Standard 60s', 'Les Paul Standard', true, 'Versatile Les Paul with articulate response for modern and classic tones.'),
  ('electric_guitar', 'Epiphone', 'Les Paul Classic', 'Les Paul', true, 'Affordable Les Paul voice with balanced output and punchy attack.'),
  ('electric_guitar', 'Epiphone', 'Les Paul Custom', 'Les Paul', true, 'Flagship Epiphone Les Paul for polished rock and lead tones.'),
  ('electric_guitar', 'Epiphone', 'Les Paul Studio', 'Les Paul', true, 'Practical studio-ready Les Paul tuned for broad genre use.'),
  ('electric_guitar', 'Epiphone', 'Les Paul Modern', 'Les Paul', false, 'Modern Epiphone Les Paul with expanded flexibility and sustain.'),
  ('electric_guitar', 'Epiphone', 'SG Standard', 'SG', true, 'Classic SG style with crisp attack and focused midrange.'),
  ('electric_guitar', 'Epiphone', 'ES-335', 'ES', true, 'Semi-hollow ES model with smooth highs and warm resonance.'),
  ('electric_guitar', 'Epiphone', 'Casino', 'Casino', true, 'Hollow-body classic for dynamic clean and crunchy edge tones.'),
  ('electric_guitar', 'Epiphone', 'Sheraton II Pro', 'Sheraton', false, 'Semi-hollow Sheraton voice with rich harmonic detail.'),
  ('electric_guitar', 'Epiphone', 'Explorer', 'Explorer', false, 'Aggressive Explorer shape with strong output and tight lows.'),
  ('electric_guitar', 'Epiphone', 'Flying V', 'Flying V', false, 'V-style platform with focused high-gain cut.'),
  ('electric_guitar', 'Epiphone', 'Les Paul Traditional Pro II', 'Les Paul Traditional', true, 'Les Paul Traditional Pro II with ProBuckers and warm articulate drive.'),
  ('electric_guitar', 'Epiphone', 'Les Paul Traditional Pro II with the pro buckers', 'Les Paul Traditional', true, 'Les Paul Traditional Pro II variant indexed for ProBuckers search discovery.'),

  -- Electric Guitars: PRS
  ('electric_guitar', 'PRS', 'SE Custom 24', 'SE', true, 'Versatile PRS platform with balanced output for modern rock and fusion.'),
  ('electric_guitar', 'PRS', 'SE Custom 24-08', 'SE', true, 'SE Custom variant with expanded switching and broad tonal range.'),
  ('electric_guitar', 'PRS', 'SE Standard 24', 'SE', true, 'Reliable 24-fret PRS platform for stage and studio applications.'),
  ('electric_guitar', 'PRS', 'SE McCarty 594', 'SE', true, 'Vintage-inspired PRS with smooth sustain and warm mid character.'),
  ('electric_guitar', 'PRS', 'SE McCarty 594 Singlecut', 'SE', false, 'Singlecut McCarty voice with classic feel and focused low mids.'),
  ('electric_guitar', 'PRS', 'SE DGT', 'SE', false, 'Signature-inspired PRS tuned for articulate gain and dynamic touch response.'),
  ('electric_guitar', 'PRS', 'SE CE 24', 'SE', false, 'Bolt-on PRS variant for snappy attack and modern flexibility.'),
  ('electric_guitar', 'PRS', 'SE Silver Sky', 'SE', true, 'PRS single-coil platform with bright cleans and expressive dynamics.'),
  ('electric_guitar', 'PRS', 'CE 24', 'Core', false, 'USA CE platform delivering modern precision and articulate highs.'),
  ('electric_guitar', 'PRS', 'S2 Custom 24', 'S2', false, 'USA S2 model balancing performance and tonal versatility.'),
  ('electric_guitar', 'PRS', 'S2 McCarty 594', 'S2', false, 'S2 McCarty with vintage-forward response and rich harmonics.'),
  ('electric_guitar', 'PRS', 'Core Custom 24', 'Core', true, 'Flagship PRS voice with polished clarity and dynamic range.'),
  ('electric_guitar', 'PRS', 'Silver Sky', 'Core', true, 'Core Silver Sky known for articulate single-coil character.'),

  -- Electric Guitars: Ibanez
  ('electric_guitar', 'Ibanez', 'RG550', 'RG', true, 'Iconic RG platform with fast neck profile and high-gain articulation.'),
  ('electric_guitar', 'Ibanez', 'RG421', 'RG', true, 'Accessible RG model tuned for modern rock and metal versatility.'),
  ('electric_guitar', 'Ibanez', 'RG470DX', 'RG', true, 'RG model with tremolo-focused performance and aggressive attack.'),
  ('electric_guitar', 'Ibanez', 'RGA42FM', 'RGA', false, 'Arched-top RG variant with tight lows and clear lead response.'),
  ('electric_guitar', 'Ibanez', 'RG7421', 'RG', false, 'Seven-string RG delivering extended-range tight metal tones.'),
  ('electric_guitar', 'Ibanez', 'AZ2204', 'AZ', true, 'Premium AZ platform with balanced modern voicing and flexibility.'),
  ('electric_guitar', 'Ibanez', 'AZ2402', 'AZ', false, 'AZ platform optimized for articulate fusion and progressive tones.'),
  ('electric_guitar', 'Ibanez', 'S521', 'S', true, 'Slim-body S series with fast response and focused midrange.'),
  ('electric_guitar', 'Ibanez', 'S670QM', 'S', false, 'S series configured for expressive tremolo and modern rock tones.'),
  ('electric_guitar', 'Ibanez', 'JEMJR', 'JEM', false, 'JEM-inspired model with high-gain clarity and fast upper-fret access.'),
  ('electric_guitar', 'Ibanez', 'JEM7V', 'JEM', false, 'Signature JEM platform designed for articulate technical lead work.'),
  ('electric_guitar', 'Ibanez', 'JS140M', 'JS', false, 'Satriani-inspired model with smooth attack and dynamic response.'),

  -- Electric Guitars: ESP / LTD / Jackson / Schecter / Yamaha / Charvel / Music Man / Gretsch / EVH / Suhr / Solar / Dean / Kiesel / G&L / Squier
  ('electric_guitar', 'ESP', 'E-II Horizon NT', 'E-II', false, 'High-performance ESP model with modern precision and sustain.'),
  ('electric_guitar', 'ESP', 'E-II Eclipse', 'E-II', false, 'Singlecut ESP platform with tight lows and articulate gain.'),
  ('electric_guitar', 'ESP', 'E-II M-II', 'E-II', false, 'ESP super-strat design for fast technical and high-gain playing.'),
  ('electric_guitar', 'LTD', 'EC-256', 'EC', true, 'Popular LTD singlecut with solid modern rock coverage.'),
  ('electric_guitar', 'LTD', 'EC-1000', 'EC', true, 'Flagship LTD workhorse for tight modern distortion tones.'),
  ('electric_guitar', 'LTD', 'M-1000', 'M', false, 'LTD super-strat with fast neck and metal-focused response.'),
  ('electric_guitar', 'LTD', 'MH-1000', 'MH', false, 'LTD MH platform balancing aggressive gain and clean articulation.'),
  ('electric_guitar', 'LTD', 'SN-1000', 'SN', false, 'Modern LTD with flexible switching and expressive attack.'),
  ('electric_guitar', 'Jackson', 'Dinky JS22', 'Dinky', true, 'Entry Jackson platform with focused high-gain response.'),
  ('electric_guitar', 'Jackson', 'Dinky JS32', 'Dinky', true, 'Affordable Jackson super-strat with modern metal voicing.'),
  ('electric_guitar', 'Jackson', 'Soloist SLX', 'Soloist', false, 'Neck-through Soloist built for precise technical lead work.'),
  ('electric_guitar', 'Jackson', 'Rhoads JS32', 'Rhoads', false, 'Classic V-shape platform with aggressive attack and cut.'),
  ('electric_guitar', 'Jackson', 'King V KVXMG', 'King V', false, 'King V variant optimized for high-gain articulation.'),
  ('electric_guitar', 'Schecter', 'C-1 Hellraiser', 'C-1', true, 'Modern Schecter favorite with high-output aggressive voice.'),
  ('electric_guitar', 'Schecter', 'C-1 Platinum', 'C-1', true, 'C-1 model balancing clarity and heavy rhythm punch.'),
  ('electric_guitar', 'Schecter', 'Omen Extreme-6', 'Omen', true, 'Widely used Schecter model for hard rock and modern metal.'),
  ('electric_guitar', 'Schecter', 'Solo-II Custom', 'Solo-II', false, 'Singlecut Schecter with punchy mids and smooth sustain.'),
  ('electric_guitar', 'Schecter', 'Sun Valley Super Shredder', 'Sun Valley', false, 'Shred-focused model with fast attack and modern feel.'),
  ('electric_guitar', 'Yamaha', 'Pacifica 112V', 'Pacifica', true, 'Popular Yamaha platform with bright cleans and practical versatility.'),
  ('electric_guitar', 'Yamaha', 'Pacifica 612VIIFM', 'Pacifica', false, 'Premium Pacifica variant with expanded tonal flexibility.'),
  ('electric_guitar', 'Yamaha', 'Revstar RSS20', 'Revstar', true, 'Modern Revstar with punchy mids and balanced dynamic response.'),
  ('electric_guitar', 'Yamaha', 'Revstar RSP20', 'Revstar', false, 'High-end Revstar with articulate attack and modern voicing.'),
  ('electric_guitar', 'Charvel', 'Pro-Mod DK24 HSS 2PT CM', 'Pro-Mod', true, 'DK24 platform tuned for versatile modern rock and fusion tones.'),
  ('electric_guitar', 'Charvel', 'Pro-Mod DK24 HH FR M', 'Pro-Mod', false, 'DK24 HH variant built for precision high-gain response.'),
  ('electric_guitar', 'Charvel', 'Pro-Mod So-Cal Style 1 HH FR M', 'Pro-Mod', true, 'So-Cal style with Floyd setup for expressive aggressive playing.'),
  ('electric_guitar', 'Charvel', 'Pro-Mod San Dimas Style 1 HH FR M', 'Pro-Mod', true, 'San Dimas HH platform with tight modern attack and sustain.'),
  ('electric_guitar', 'Music Man', 'Axis', 'Axis', true, 'Classic Music Man model with tight lows and articulate lead voice.'),
  ('electric_guitar', 'Music Man', 'JP15', 'JP', true, 'John Petrucci platform for progressive precision and clarity.'),
  ('electric_guitar', 'Music Man', 'Majesty', 'Majesty', false, 'Progressive flagship with refined ergonomics and broad dynamic range.'),
  ('electric_guitar', 'Music Man', 'Cutlass HSS', 'Cutlass', false, 'Modern HSS platform with strong clean-to-crunch versatility.'),
  ('electric_guitar', 'Gretsch', 'G5420T Electromatic', 'Electromatic', true, 'Gretsch hollow-body voice with dynamic clean and vintage edge tones.'),
  ('electric_guitar', 'Gretsch', 'G5220 Electromatic Jet BT', 'Electromatic', true, 'Jet platform with punchy drive response and focused midrange.'),
  ('electric_guitar', 'Gretsch', 'G6136 White Falcon', 'Professional Collection', false, 'Iconic Gretsch hollow platform with broad dynamic expression.'),
  ('electric_guitar', 'EVH', 'Wolfgang Standard', 'Wolfgang', true, 'EVH platform optimized for aggressive modern rock articulation.'),
  ('electric_guitar', 'EVH', 'Wolfgang Special', 'Wolfgang', true, 'Refined Wolfgang model with tight rhythm response and sustain.'),
  ('electric_guitar', 'EVH', '5150 Standard', '5150', false, 'Modern EVH platform for high-gain precision and attack.'),
  ('electric_guitar', 'Suhr', 'Classic S', 'Classic', true, 'Boutique-style single-coil platform with high-end articulation.'),
  ('electric_guitar', 'Suhr', 'Classic T', 'Classic', false, 'Suhr T-style model with polished transient response.'),
  ('electric_guitar', 'Suhr', 'Modern', 'Modern', true, 'Modern Suhr platform with tight lows and balanced lead clarity.'),
  ('electric_guitar', 'Solar', 'A1.6', 'A', true, 'Solar A-series guitar designed for modern metal precision.'),
  ('electric_guitar', 'Solar', 'A1.7', 'A', false, 'Extended-range Solar built for tight progressive rhythm work.'),
  ('electric_guitar', 'Solar', 'S1.6', 'S', false, 'Solar S-series with balanced attack and modern voicing.'),
  ('electric_guitar', 'Dean', 'ML Select', 'ML', true, 'Dean ML design with aggressive output and tight metal response.'),
  ('electric_guitar', 'Dean', 'Dimebag Razorback', 'Dimebag', false, 'Signature platform tuned for extreme high-gain articulation.'),
  ('electric_guitar', 'Dean', 'V 79', 'V', false, 'Dean V-style model with focused upper mids and punchy attack.'),
  ('electric_guitar', 'Kiesel', 'Aries', 'Aries', true, 'Modern Kiesel platform with articulate response and precision feel.'),
  ('electric_guitar', 'Kiesel', 'Delos', 'Delos', false, 'S-style Kiesel model balancing clean clarity and driven punch.'),
  ('electric_guitar', 'Kiesel', 'Vader', 'Vader', false, 'Headless platform optimized for technical modern playability.'),
  ('electric_guitar', 'G&L', 'Legacy', 'Legacy', true, 'G&L Legacy with bright cleans and expressive dynamic range.'),
  ('electric_guitar', 'G&L', 'ASAT Classic', 'ASAT', true, 'G&L T-style platform with direct attack and articulate response.'),
  ('electric_guitar', 'G&L', 'S-500', 'S-500', false, 'Expanded S-style platform with strong clean-to-drive versatility.'),
  ('electric_guitar', 'Squier', 'Affinity Stratocaster', 'Affinity', true, 'Accessible Stratocaster platform for core clean and crunch tones.'),
  ('electric_guitar', 'Squier', 'Affinity Telecaster', 'Affinity', true, 'Accessible Tele platform with focused attack and rhythm clarity.'),
  ('electric_guitar', 'Squier', 'Classic Vibe 50s Stratocaster', 'Classic Vibe', true, 'Vintage-inspired Strat with bright single-coil response.'),
  ('electric_guitar', 'Squier', 'Classic Vibe 60s Stratocaster', 'Classic Vibe', true, '60s-style Strat flavor with articulate highs and smooth mids.'),
  ('electric_guitar', 'Squier', 'Classic Vibe 50s Telecaster', 'Classic Vibe', true, 'Classic Tele twang with tight dynamics and cutting attack.'),
  ('electric_guitar', 'Squier', 'Classic Vibe 60s Telecaster', 'Classic Vibe', true, '60s Tele voice for crisp rhythm and expressive lead tones.'),
  ('electric_guitar', 'Squier', 'Contemporary Stratocaster HH', 'Contemporary', false, 'Modern HH Squier tuned for higher gain flexibility.'),
  ('electric_guitar', 'Squier', 'J Mascis Jazzmaster', 'Artist', false, 'Offset model with smooth sustain and broad dynamic response.'),

  -- Bass Guitars
  ('bass_guitar', 'Fender', 'Player Precision Bass', 'Player', true, 'Popular P-Bass platform with punchy lows and classic mix presence.'),
  ('bass_guitar', 'Fender', 'Player Jazz Bass', 'Player', true, 'Player Jazz Bass with articulate mids and flexible groove response.'),
  ('bass_guitar', 'Fender', 'Player Plus Precision Bass', 'Player Plus', true, 'Modernized Precision voice with expanded tonal control.'),
  ('bass_guitar', 'Fender', 'Player Plus Jazz Bass', 'Player Plus', true, 'Enhanced Jazz Bass platform for modern stage and session use.'),
  ('bass_guitar', 'Fender', 'American Professional II Precision Bass', 'American Professional II', true, 'Flagship Precision Bass with tight punch and premium feel.'),
  ('bass_guitar', 'Fender', 'American Professional II Jazz Bass', 'American Professional II', true, 'Flagship Jazz Bass with dynamic articulation and strong clarity.'),
  ('bass_guitar', 'Fender', 'American Ultra Precision Bass', 'American Ultra', false, 'Modern Ultra Precision with high performance ergonomics.'),
  ('bass_guitar', 'Fender', 'American Ultra Jazz Bass', 'American Ultra', false, 'Premium Ultra Jazz Bass with refined modern voicing.'),
  ('bass_guitar', 'Fender', 'Mustang Bass PJ', 'Mustang', false, 'Short-scale PJ bass with tight attack and compact feel.'),
  ('bass_guitar', 'Squier', 'Affinity Precision Bass PJ', 'Affinity', true, 'Widely used entry PJ bass with practical all-round performance.'),
  ('bass_guitar', 'Squier', 'Affinity Jazz Bass', 'Affinity', true, 'Accessible Jazz Bass with clear note separation and punch.'),
  ('bass_guitar', 'Squier', 'Classic Vibe 60s Precision Bass', 'Classic Vibe', false, 'Vintage-style Precision bass with warm low-mid authority.'),
  ('bass_guitar', 'Squier', 'Classic Vibe 70s Jazz Bass', 'Classic Vibe', false, '70s Jazz-inspired voicing with articulate top-end detail.'),
  ('bass_guitar', 'Music Man', 'StingRay Special HH', 'StingRay', true, 'Modern StingRay tone with punchy lows and strong articulation.'),
  ('bass_guitar', 'Music Man', 'StingRay Special H', 'StingRay', true, 'Single-pickup StingRay response with focused modern attack.'),
  ('bass_guitar', 'Music Man', 'Bongo 5 HH', 'Bongo', false, 'Extended-range Bongo with aggressive output and modern control.'),
  ('bass_guitar', 'Music Man', 'Cutlass Bass', 'Cutlass', false, 'Balanced Music Man bass platform for modern groove work.'),
  ('bass_guitar', 'Ibanez', 'SR300E', 'SR', true, 'Popular SR bass with slim feel and punchy modern response.'),
  ('bass_guitar', 'Ibanez', 'SR500E', 'SR', true, 'Mid-tier SR with articulate low end and dynamic clarity.'),
  ('bass_guitar', 'Ibanez', 'SR600E', 'SR', false, 'Versatile SR model with broad tonal coverage for live work.'),
  ('bass_guitar', 'Ibanez', 'BTB745', 'BTB', false, 'Extended-range BTB platform with tight progressive voicing.'),
  ('bass_guitar', 'Ibanez', 'EHB1000', 'EHB', false, 'Ergonomic headless bass with precise note definition.'),
  ('bass_guitar', 'Ibanez', 'GSR200', 'GSR', true, 'Entry-level Ibanez bass with practical punch and clarity.'),
  ('bass_guitar', 'Warwick', 'RockBass Corvette Basic 4', 'RockBass', true, 'Warwick Corvette voice with tight growl and dynamic response.'),
  ('bass_guitar', 'Warwick', 'RockBass Streamer LX', 'RockBass', false, 'Streamer platform with punchy low mids and fast attack.'),
  ('bass_guitar', 'Warwick', 'Thumb BO 5', 'Thumb', false, 'Thumb bass voice with focused mids and modern articulation.'),
  ('bass_guitar', 'Yamaha', 'TRBX304', 'TRBX', true, 'Widely used active bass platform with strong live versatility.'),
  ('bass_guitar', 'Yamaha', 'TRBX504', 'TRBX', true, 'TRBX model balancing punch, clarity, and broad genre use.'),
  ('bass_guitar', 'Yamaha', 'BB434', 'BB', true, 'Modern BB bass with tight lows and classic punch.'),
  ('bass_guitar', 'Yamaha', 'BB734A', 'BB', false, 'Advanced BB model for articulate stage and session use.'),
  ('bass_guitar', 'Schecter', 'Stiletto Studio-4', 'Stiletto', true, 'Schecter Studio bass with modern attack and focused clarity.'),
  ('bass_guitar', 'Schecter', 'Stiletto Extreme-5', 'Stiletto', false, 'Five-string Stiletto platform for extended low-range punch.'),
  ('bass_guitar', 'Schecter', 'Riot-5 Session', 'Riot', false, 'Riot session model for balanced modern groove tones.'),
  ('bass_guitar', 'Spector', 'Legend 4 Classic', 'Legend', true, 'Popular Spector Legend bass with punchy, modern low end.'),
  ('bass_guitar', 'Spector', 'Euro5 LX', 'Euro', false, 'Premium Spector bass with aggressive articulation.'),
  ('bass_guitar', 'Spector', 'NS Pulse 5', 'NS Pulse', false, 'Modern NS Pulse platform built for tight contemporary tones.'),
  ('bass_guitar', 'Lakland', 'Skyline 44-64', 'Skyline', true, 'Lakland P-style platform with solid punch and strong presence.'),
  ('bass_guitar', 'Lakland', 'Skyline 44-60', 'Skyline', true, 'Lakland J-style voice with articulate detail and flexibility.'),
  ('bass_guitar', 'Lakland', 'Skyline 55-02', 'Skyline', false, 'Five-string skyline platform for modern extended-range bass work.'),
  ('bass_guitar', 'G&L', 'L-2000', 'L', true, 'Iconic G&L bass with broad output and tight articulation.'),
  ('bass_guitar', 'G&L', 'L-2500', 'L', false, 'Five-string G&L platform with strong low-end authority.'),
  ('bass_guitar', 'G&L', 'JB', 'JB', false, 'G&L Jazz-style bass with clear, dynamic note separation.'),
  ('bass_guitar', 'ESP LTD', 'B-204SM', 'B', true, 'LTD bass tuned for modern punch and practical flexibility.'),
  ('bass_guitar', 'ESP LTD', 'B-205SM', 'B', false, 'Five-string LTD bass with extended-range modern response.'),
  ('bass_guitar', 'ESP LTD', 'F-204', 'F', false, 'LTD bass with focused attack and aggressive stage presence.'),
  ('bass_guitar', 'Cort', 'Action PJ', 'Action', true, 'Popular Cort PJ platform for foundational bass tones.'),
  ('bass_guitar', 'Cort', 'B4 Element', 'B', false, 'Cort bass with balanced response and modern clarity.'),
  ('bass_guitar', 'Cort', 'A5 Plus FMMH', 'A', false, 'Five-string Cort model for modern low-end articulation.'),
  ('bass_guitar', 'Cort', 'GB74JJ', 'GB', false, 'JJ bass layout tuned for articulate dynamics and versatility.'),
  ('bass_guitar', 'Jackson', 'Spectra Bass JS2', 'Spectra', true, 'Affordable Jackson bass platform with focused punch.'),
  ('bass_guitar', 'Jackson', 'Spectra Bass JS3', 'Spectra', true, 'Expanded Spectra bass with modern output and clarity.'),
  ('bass_guitar', 'Jackson', 'Concert Bass CBXNT DX IV', 'Concert', false, 'Concert platform with tight response for aggressive rhythm work.'),

  -- Guitar Amps
  ('guitar_amp', 'Marshall', 'DSL1', 'DSL', true, 'Compact DSL tube amp delivering classic Marshall crunch response.'),
  ('guitar_amp', 'Marshall', 'DSL20', 'DSL', true, 'Popular DSL platform with modern gain and classic Marshall bite.'),
  ('guitar_amp', 'Marshall', 'DSL40CR', 'DSL', true, 'Widely used combo with flexible channels and rock-ready gain.'),
  ('guitar_amp', 'Marshall', 'DSL100H', 'DSL', true, 'High-power DSL head for stage-ready high gain and punch.'),
  ('guitar_amp', 'Marshall', 'JCM800 2203', 'JCM800', true, 'Legendary JCM800 head known for classic hard rock aggression.'),
  ('guitar_amp', 'Marshall', 'JVM410H', 'JVM', true, 'Multi-channel Marshall head covering clean to extreme gain.'),
  ('guitar_amp', 'Marshall', 'Origin20C', 'Origin', false, 'Classic-voiced Marshall combo with dynamic edge-of-breakup response.'),
  ('guitar_amp', 'Marshall', 'Origin50H', 'Origin', false, 'Vintage-inspired Marshall head for classic rock and blues tones.'),
  ('guitar_amp', 'Marshall', 'Silver Jubilee 2555X', 'Silver Jubilee', false, 'Signature Marshall voice with thick mids and singing lead gain.'),
  ('guitar_amp', 'Marshall', 'MG15FX', 'MG', true, 'Popular practice combo with built-in effects and Marshall voicing.'),
  ('guitar_amp', 'Marshall', 'Code50', 'CODE', false, 'Digital Marshall combo with broad modeled amp/effect coverage.'),
  ('guitar_amp', 'Mesa Boogie', 'Dual Rectifier Solo Head', 'Rectifier', true, 'Industry-standard high-gain head with tight modern low end.'),
  ('guitar_amp', 'Mesa Boogie', 'Mini Rectifier 25', 'Rectifier', true, 'Compact Rectifier tone with aggressive modern articulation.'),
  ('guitar_amp', 'Mesa Boogie', 'Mark V 90', 'Mark', true, 'Flagship Mark platform with deep control and versatile channels.'),
  ('guitar_amp', 'Mesa Boogie', 'Mark V 35', 'Mark', false, 'Compact Mark architecture for articulate modern and classic tones.'),
  ('guitar_amp', 'Mesa Boogie', 'JP-2C', 'JP', false, 'Petrucci-focused Mark-style head with precision high-gain response.'),
  ('guitar_amp', 'Mesa Boogie', 'Badlander 50', 'Badlander', false, 'Modern Mesa platform tuned for tight, articulate heavy tones.'),
  ('guitar_amp', 'Mesa Boogie', 'Fillmore 25', 'Fillmore', false, 'Vintage-leaning Mesa amp with rich clean and smooth breakup.'),
  ('guitar_amp', 'Peavey', '6505 MH', '6505', true, 'Compact 6505 high-gain tone for modern metal rhythm precision.'),
  ('guitar_amp', 'Peavey', '6505+ 112 Combo', '6505', true, 'Combo implementation of classic Peavey high-gain character.'),
  ('guitar_amp', 'Peavey', 'Invective.120', 'Invective', false, 'Feature-rich high-gain platform for modern metal control.'),
  ('guitar_amp', 'Peavey', 'Classic 30', 'Classic', true, 'Well-known Peavey combo for blues and classic rock dynamics.'),
  ('guitar_amp', 'Peavey', 'Bandit 112', 'Bandit', true, 'Long-standing solid-state combo for practical gigging use.'),
  ('guitar_amp', 'Peavey', 'Vypyr X2', 'Vypyr', false, 'Digital modeling combo with broad high-gain and clean options.'),
  ('guitar_amp', 'Orange', 'Rocker 15', 'Rocker', true, 'Compact Orange tube combo with punchy British crunch.'),
  ('guitar_amp', 'Orange', 'Rockerverb 50 MKIII', 'Rockerverb', true, 'Modern Orange head with thick high-gain and dynamic clean channel.'),
  ('guitar_amp', 'Orange', 'TH30', 'TH', true, 'Orange TH platform balancing modern gain and practical flexibility.'),
  ('guitar_amp', 'Orange', 'Tiny Terror', 'Terror', true, 'Compact Orange head delivering classic British drive character.'),
  ('guitar_amp', 'Orange', 'Super Crush 100', 'Super Crush', true, 'Solid-state Orange platform with high-gain punch and reliability.'),
  ('guitar_amp', 'EVH', '5150III 50W EL34 Head', '5150III', true, 'EL34 5150III head with tight modern high-gain articulation.'),
  ('guitar_amp', 'EVH', '5150III 100S 6L6 Head', '5150III', true, 'High-power 5150III platform for aggressive stage-ready tones.'),
  ('guitar_amp', 'EVH', 'Iconic 40W 1x12 Combo', 'Iconic', true, 'Accessible EVH combo with signature modern rock gain structure.'),
  ('guitar_amp', 'Fender', '''65 Deluxe Reverb', 'Deluxe Reverb', true, 'Classic Fender clean platform with sparkling highs and pedal-friendly dynamics.'),
  ('guitar_amp', 'Fender', '''68 Custom Deluxe Reverb', 'Deluxe Reverb', false, 'Modified Deluxe Reverb voice balancing vintage and modern response.'),
  ('guitar_amp', 'Fender', '''65 Twin Reverb', 'Twin Reverb', true, 'Legendary high-headroom clean amp for articulate stage tones.'),
  ('guitar_amp', 'Fender', 'Blues Junior IV', 'Blues Junior', true, 'Compact tube combo with smooth blues breakup and dynamic feel.'),
  ('guitar_amp', 'Fender', 'Hot Rod Deluxe IV', 'Hot Rod Deluxe', true, 'Popular gigging combo with loud clean channel and punchy drive.'),
  ('guitar_amp', 'Fender', 'Tone Master Deluxe Reverb', 'Tone Master', true, 'Digital re-creation of Deluxe Reverb with practical stage reliability.'),
  ('guitar_amp', 'Fender', 'Mustang GTX100', 'Mustang GTX', true, 'Modeling combo with broad amp/effect library and modern usability.'),
  ('guitar_amp', 'Boss', 'Katana-50 MkII', 'Katana', true, 'Most-used Boss modeling combo for practical clean-to-high-gain workflows.'),
  ('guitar_amp', 'Boss', 'Katana-100 MkII', 'Katana', true, 'Stage-capable Katana with strong flexibility and reliable response.'),
  ('guitar_amp', 'Boss', 'Katana Artist MkII', 'Katana', true, 'Premium Katana format for broad tone shaping and articulation.'),
  ('guitar_amp', 'Blackstar', 'HT-20R MKIII', 'HT', true, 'Tube combo balancing modern gain and articulate clean response.'),
  ('guitar_amp', 'Blackstar', 'HT Club 40 MKIII', 'HT', true, 'Popular Blackstar combo for versatile rock and metal tones.'),
  ('guitar_amp', 'Blackstar', 'St. James 50 EL34', 'St. James', false, 'Lightweight modern tube platform with classic EL34 character.'),
  ('guitar_amp', 'Blackstar', 'ID:Core 40 V4', 'ID:Core', false, 'Digital combo focused on practical multi-voice home and practice use.'),
  ('guitar_amp', 'Line 6', 'Catalyst 60', 'Catalyst', true, 'Digital combo with modern amp voices and direct-friendly workflow.'),
  ('guitar_amp', 'Line 6', 'Catalyst 100', 'Catalyst', true, 'Stage-ready Catalyst with broad clean-to-high-gain range.'),
  ('guitar_amp', 'Line 6', 'Spider V 60 MkII', 'Spider', true, 'Popular Spider modeling combo with broad preset flexibility.'),
  ('guitar_amp', 'Line 6', 'Spider V 120 MkII', 'Spider', false, 'Higher-power Spider format for full-range modeled tone workflows.'),
  ('guitar_amp', 'Laney', 'Cub-Super12', 'Cub', true, 'Compact Laney tube combo with classic British response.'),
  ('guitar_amp', 'Laney', 'Lionheart L20T-212', 'Lionheart', false, 'Laney Lionheart combo with chime and expressive breakup.'),
  ('guitar_amp', 'Laney', 'Ironheart IRT60H', 'Ironheart', false, 'High-gain Laney head with tight modern metal articulation.'),
  ('guitar_amp', 'Victory', 'V40 The Duchess', 'The Duchess', true, 'Victory amp focused on premium clean headroom and dynamic feel.'),
  ('guitar_amp', 'Victory', 'V30 The Countess', 'The Countess', false, 'Compact Victory platform for modern gain and practical power scaling.'),
  ('guitar_amp', 'Victory', 'Sheriff 22', 'Sheriff', false, 'British-inspired gain structure with classic rock authority.'),
  ('guitar_amp', 'PRS', 'MT 15', 'MT', true, 'High-gain PRS platform with articulate rhythm and lead channels.'),
  ('guitar_amp', 'PRS', 'Archon 50', 'Archon', false, 'Powerful PRS high-gain amp with tight modern response.'),
  ('guitar_amp', 'Soldano', 'SLO-100', 'SLO', true, 'Legendary Soldano high-gain head with saturated articulate lead tone.'),
  ('guitar_amp', 'Soldano', 'SLO-30', 'SLO', false, 'Compact SLO architecture preserving classic Soldano aggression.'),
  ('guitar_amp', 'Diezel', 'VH4', 'VH', true, 'Reference high-gain multi-channel head for modern heavy tones.'),
  ('guitar_amp', 'Diezel', 'Herbert', 'Herbert', false, 'High-power Diezel platform with tight low-end control.'),
  ('guitar_amp', 'Engl', 'Fireball 25', 'Fireball', true, 'Compact Engl with tight focused high-gain modern response.'),
  ('guitar_amp', 'Engl', 'Powerball II', 'Powerball', false, 'Multi-channel Engl head for aggressive articulate metal tones.'),
  ('guitar_amp', 'Randall', 'RD20H', 'Diavlo', false, 'Modern Randall gain platform with tight attack and clarity.'),
  ('guitar_amp', 'Randall', 'RG1503H', 'RG', false, 'Solid-state Randall head with aggressive modern voicing.'),
  ('guitar_amp', 'Hughes & Kettner', 'Tubemeister Deluxe 20', 'Tubemeister', true, 'Compact tube head with practical channel flexibility.'),
  ('guitar_amp', 'Hughes & Kettner', 'Grandmeister Deluxe 40', 'Grandmeister', false, 'Advanced programmable tube platform for modern workflows.'),
  ('guitar_amp', 'Hughes & Kettner', 'Black Spirit 200', 'Black Spirit', true, 'Compact high-power amp with modern direct-ready flexibility.'),

  -- Bass Amps
  ('bass_amp', 'Ampeg', 'SVT-CL', 'SVT', true, 'Classic Ampeg bass head with iconic punch and authoritative low end.'),
  ('bass_amp', 'Ampeg', 'SVT-VR', 'SVT', false, 'Vintage-style SVT voice with warm tube-driven bass authority.'),
  ('bass_amp', 'Ampeg', 'SVT-3PRO', 'SVT', true, 'Hybrid Ampeg head balancing clean headroom and classic grit.'),
  ('bass_amp', 'Ampeg', 'SVT-7PRO', 'SVT', true, 'High-power Ampeg platform for modern stage-ready bass output.'),
  ('bass_amp', 'Ampeg', 'V-4B', 'V', false, 'Tube Ampeg bass head with dynamic feel and vintage punch.'),
  ('bass_amp', 'Ampeg', 'Portaflex PF-500', 'Portaflex', true, 'Portable Ampeg bass head with practical live flexibility.'),
  ('bass_amp', 'Ampeg', 'Rocket Bass RB-210', 'Rocket Bass', true, 'Popular Ampeg combo with clear punch and stage-friendly power.'),
  ('bass_amp', 'Darkglass', 'Microtubes 500 v2', 'Microtubes', true, 'Modern Darkglass bass head with focused attack and aggressive definition.'),
  ('bass_amp', 'Darkglass', 'Microtubes 900 v2', 'Microtubes', true, 'High-power Darkglass platform for modern metal and rock bass tones.'),
  ('bass_amp', 'Darkglass', 'Alpha-Omega 500', 'Alpha-Omega', true, 'Darkglass platform with tight saturation and modern low-end control.'),
  ('bass_amp', 'Markbass', 'Little Mark IV', 'Little Mark', true, 'Reference Markbass head with clean articulation and strong portability.'),
  ('bass_amp', 'Markbass', 'Little Mark Tube 800', 'Little Mark', false, 'Tube-assisted Markbass head with punch and warm edge.'),
  ('bass_amp', 'Markbass', 'CMD 121P', 'CMD', true, 'Widely used Markbass combo with clear transient response.'),
  ('bass_amp', 'Hartke', 'LH500', 'LH', true, 'Popular Hartke bass head with practical power and strong punch.'),
  ('bass_amp', 'Hartke', 'TX300', 'TX', false, 'Compact Hartke head with modern clarity and live reliability.'),
  ('bass_amp', 'Hartke', 'HA3500', 'HA', true, 'Classic Hartke preamp voice with punchy low-mid response.'),
  ('bass_amp', 'Gallien Krueger', 'MB200', 'MB', true, 'Compact GK head known for fast attack and clean articulation.'),
  ('bass_amp', 'Gallien Krueger', 'MB500', 'MB', true, 'Popular GK platform with punchy modern response for live bass.'),
  ('bass_amp', 'Gallien Krueger', 'Fusion 800S', 'Fusion', false, 'Hybrid GK architecture with strong dynamic control and headroom.'),
  ('bass_amp', 'Fender', 'Rumble 40', 'Rumble', true, 'Best-selling Fender bass combo with practical clean bass tone.'),
  ('bass_amp', 'Fender', 'Rumble 100', 'Rumble', true, 'Widely used Rumble combo for rehearsal and small stage use.'),
  ('bass_amp', 'Fender', 'Rumble 500', 'Rumble', true, 'High-power lightweight combo with reliable bass stage performance.'),
  ('bass_amp', 'Orange', 'Terror Bass 500', 'Terror Bass', true, 'Orange bass head with strong punch and aggressive modern edge.'),
  ('bass_amp', 'Orange', 'Little Bass Thing', 'Little Bass Thing', false, 'Compact Orange bass head with clean headroom and tight control.'),
  ('bass_amp', 'Orange', 'OB1-500', 'OB1', false, 'Orange OB1 bass amp with blended grit and clear low-end punch.'),
  ('bass_amp', 'Peavey', 'MiniMAX 500', 'MiniMAX', true, 'Portable Peavey bass head with practical modern stage output.'),
  ('bass_amp', 'Peavey', 'MiniMEGA 1000', 'MiniMEGA', false, 'High-power Peavey bass platform with advanced shaping controls.'),
  ('bass_amp', 'Peavey', 'MAX 250', 'MAX', true, 'Popular Peavey bass combo with punchy practical rehearsal tone.'),
  ('bass_amp', 'Ashdown', 'Rootmaster 500 EVO III', 'Rootmaster', true, 'Ashdown bass head with balanced punch and flexible modern voicing.'),
  ('bass_amp', 'Ashdown', 'ABM 600 EVO IV', 'ABM', false, 'Flagship Ashdown bass platform with rich low-end authority.'),
  ('bass_amp', 'Ashdown', 'Studio 15', 'Studio', false, 'Portable Ashdown combo with tight punch and clean bass response.'),
  ('bass_amp', 'TC Electronic', 'BAM200', 'BAM', true, 'Ultra-compact bass head with practical clean power output.'),
  ('bass_amp', 'TC Electronic', 'BQ500', 'BQ', true, 'Modern TC bass head with clear articulation and compact format.'),
  ('bass_amp', 'TC Electronic', 'BG250-208', 'BG', false, 'TC combo platform with flexible EQ and practical gig power.')
)
insert into public.equipment (
  equipment_type,
  brand,
  model,
  series,
  display_name,
  description,
  is_popular,
  sort_order,
  status,
  genres,
  tone_characteristics,
  search_terms
)
select
  seed.equipment_type::public.equipment_type,
  seed.brand,
  seed.model,
  seed.series,
  concat_ws(' ', seed.brand, seed.model),
  seed.description,
  seed.is_popular,
  row_number() over (
    partition by seed.equipment_type, seed.brand
    order by seed.is_popular desc, seed.model asc
  ),
  'active'::public.equipment_status,
  case
    when seed.equipment_type in ('electric_guitar', 'guitar_amp') then array['rock', 'hard_rock', 'blues']::public.equipment_genre[]
    when seed.equipment_type in ('bass_guitar', 'bass_amp') then array['rock', 'pop', 'funk']::public.equipment_genre[]
    else array['rock']::public.equipment_genre[]
  end,
  case
    when seed.equipment_type = 'electric_guitar' then array['balanced', 'dynamic', 'articulate']::public.equipment_tone_characteristic[]
    when seed.equipment_type = 'bass_guitar' then array['punchy', 'tight', 'balanced']::public.equipment_tone_characteristic[]
    when seed.equipment_type = 'guitar_amp' then array['clean', 'crunch', 'dynamic']::public.equipment_tone_characteristic[]
    when seed.equipment_type = 'bass_amp' then array['clean_headroom', 'punchy', 'tight']::public.equipment_tone_characteristic[]
    else array['balanced']::public.equipment_tone_characteristic[]
  end,
  '{}'::text[]
from seed
on conflict (equipment_type, brand, model)
do update set
  series = excluded.series,
  display_name = excluded.display_name,
  description = excluded.description,
  is_popular = excluded.is_popular,
  sort_order = excluded.sort_order,
  status = excluded.status,
  genres = excluded.genres,
  tone_characteristics = excluded.tone_characteristics,
  updated_at = now();

commit;
