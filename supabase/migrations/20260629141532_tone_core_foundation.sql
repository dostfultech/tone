create table if not exists public.tone_equipment_profiles (
  id uuid primary key default gen_random_uuid(),
  gear_item_id uuid not null references public.gear_items(id) on delete cascade,
  equipment_type text not null check (equipment_type in ('guitar', 'bass_guitar', 'amp', 'bass_amp', 'cabinet', 'pickup', 'multi_fx')),
  schema_version integer not null default 1 check (schema_version > 0),
  profile_version integer not null default 1 check (profile_version > 0),
  transfer_class text not null default 'general',
  control_schema jsonb not null default '{}'::jsonb,
  behavior_profile jsonb not null default '{}'::jsonb,
  confidence integer not null default 60 check (confidence between 0 and 100),
  source text not null default 'manual' check (source in ('manual', 'seed', 'ai_assisted')),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (gear_item_id, equipment_type)
);

create table if not exists public.tone_adaptation_cache (
  id uuid primary key default gen_random_uuid(),
  source_profile_id uuid not null references public.song_tone_profiles(id) on delete cascade,
  request_signature text not null,
  cache_key text not null unique,
  mode text not null check (mode in ('guitar', 'bass')),
  song_title text not null,
  artist_name text not null,
  part_label text not null,
  guitar_name text,
  amp_name text,
  cabinet_name text,
  pickup_name text,
  schema_version integer not null default 1 check (schema_version > 0),
  source_profile_version integer not null default 1 check (source_profile_version > 0),
  guitar_profile_id uuid references public.tone_equipment_profiles(id) on delete set null,
  amp_profile_id uuid references public.tone_equipment_profiles(id) on delete set null,
  guitar_profile_version integer not null default 0 check (guitar_profile_version >= 0),
  amp_profile_version integer not null default 0 check (amp_profile_version >= 0),
  result_json jsonb not null,
  result_source text not null check (result_source in ('rule', 'ai_fallback', 'manual')),
  confidence integer not null default 70 check (confidence between 0 and 100),
  hit_count bigint not null default 0 check (hit_count >= 0),
  last_hit_at timestamptz,
  expires_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (
    source_profile_id,
    request_signature,
    schema_version,
    source_profile_version,
    guitar_profile_version,
    amp_profile_version
  )
);

create table if not exists public.tone_generation_telemetry (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id) on delete set null,
  request_id text,
  source_profile_id uuid references public.song_tone_profiles(id) on delete set null,
  cache_id uuid references public.tone_adaptation_cache(id) on delete set null,
  mode text not null check (mode in ('guitar', 'bass')),
  hit_type text not null check (hit_type in ('exact', 'miss', 'bypass', 'fallback')),
  result_source text not null check (result_source in ('cache', 'rule', 'ai_fallback', 'legacy_ai', 'manual')),
  latency_ms integer not null default 0 check (latency_ms >= 0),
  ai_used boolean not null default false,
  estimated_cost_usd numeric(10, 6),
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists tone_equipment_profiles_lookup_idx
  on public.tone_equipment_profiles (equipment_type, gear_item_id, is_active, profile_version);

create index if not exists tone_adaptation_cache_exact_idx
  on public.tone_adaptation_cache (source_profile_id, request_signature, schema_version, source_profile_version);

create index if not exists tone_adaptation_cache_fresh_idx
  on public.tone_adaptation_cache (cache_key, expires_at);

create index if not exists tone_generation_telemetry_created_idx
  on public.tone_generation_telemetry (created_at desc);

drop trigger if exists tone_equipment_profiles_updated_at on public.tone_equipment_profiles;
create trigger tone_equipment_profiles_updated_at
before update on public.tone_equipment_profiles
for each row execute function public.set_updated_at();

drop trigger if exists tone_adaptation_cache_updated_at on public.tone_adaptation_cache;
create trigger tone_adaptation_cache_updated_at
before update on public.tone_adaptation_cache
for each row execute function public.set_updated_at();

alter table public.tone_equipment_profiles enable row level security;
alter table public.tone_adaptation_cache enable row level security;
alter table public.tone_generation_telemetry enable row level security;

revoke all on public.tone_equipment_profiles from anon, authenticated;
revoke all on public.tone_adaptation_cache from anon, authenticated;
revoke all on public.tone_generation_telemetry from anon, authenticated;

grant select, insert, update, delete on public.tone_equipment_profiles to service_role;
grant select, insert, update, delete on public.tone_adaptation_cache to service_role;
grant select, insert on public.tone_generation_telemetry to service_role;

comment on table public.tone_equipment_profiles is 'Core Tonefex equipment behavior profiles used by the rule-first resolver.';
comment on table public.tone_adaptation_cache is 'Exact cached song + user gear adaptations for the core cost-saving resolver.';
comment on table public.tone_generation_telemetry is 'Minimal resolver telemetry for cache/rule/AI source tracking.';
