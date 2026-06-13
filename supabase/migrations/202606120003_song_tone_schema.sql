create table public.artists (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  country text,
  external_ids jsonb not null default '{}'::jsonb,
  search_text text not null default '',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.songs (
  id uuid primary key default gen_random_uuid(),
  artist_id uuid not null references public.artists(id) on delete cascade,
  title text not null,
  slug text not null,
  album text,
  release_year integer,
  duration_seconds integer,
  external_ids jsonb not null default '{}'::jsonb,
  search_text text not null default '',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (artist_id, slug)
);

create table public.song_tone_profiles (
  id uuid primary key default gen_random_uuid(),
  song_id uuid not null references public.songs(id) on delete cascade,
  song_title text not null,
  artist_name text not null,
  mode text not null check (mode in ('guitar', 'bass')),
  part_type text not null check (part_type in ('main', 'riff', 'solo', 'lead', 'rhythm', 'intro', 'chorus', 'bridge', 'bassline')),
  part_label text not null,
  tone_type text not null check (tone_type in ('auto', 'clean', 'crunch', 'distorted', 'high_gain', 'fuzz', 'acoustic', 'bass_clean', 'bass_drive')),
  original_guitar text,
  original_amp text,
  original_cab text,
  original_pickup text,
  original_effects jsonb not null default '[]'::jsonb,
  original_settings jsonb not null default '{}'::jsonb,
  adaptation_notes text[] not null default '{}',
  playing_notes text[] not null default '{}',
  source_summary text,
  confidence integer not null default 65 check (confidence between 0 and 100),
  verification_status text not null default 'starter_estimate' check (verification_status in ('starter_estimate', 'needs_review', 'community_submitted', 'admin_verified')),
  search_text text not null default '',
  is_public boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (song_id, mode, part_type, tone_type, part_label)
);

create table public.tone_profile_effects (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.song_tone_profiles(id) on delete cascade,
  effect_order integer not null,
  effect_type text not null,
  effect_name text not null,
  placement text not null default 'post_gain',
  settings jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  unique (profile_id, effect_order)
);

create table public.tone_profile_sources (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.song_tone_profiles(id) on delete cascade,
  source_type text not null check (source_type in ('artist_interview', 'rig_rundown', 'community_forum', 'video_tutorial', 'tone_pack', 'internal_seed', 'user_submission')),
  title text not null,
  url text,
  notes text,
  credibility integer not null default 50 check (credibility between 0 and 100),
  created_at timestamptz not null default now()
);

create table public.song_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id) on delete set null,
  song_title text not null,
  artist_name text not null,
  mode text not null default 'guitar' check (mode in ('guitar', 'bass')),
  part_type text not null default 'main',
  tone_type text not null default 'auto',
  requested_gear jsonb not null default '{}'::jsonb,
  status text not null default 'open' check (status in ('open', 'researching', 'fulfilled', 'closed')),
  votes integer not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.community_submissions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id) on delete set null,
  song_title text not null,
  artist_name text not null,
  mode text not null default 'guitar' check (mode in ('guitar', 'bass')),
  part_type text not null default 'main',
  tone_type text not null default 'auto',
  gear jsonb not null default '{}'::jsonb,
  settings jsonb not null default '{}'::jsonb,
  effects jsonb not null default '[]'::jsonb,
  notes text check (char_length(coalesce(notes, '')) <= 4000),
  source_urls text[] not null default '{}',
  status text not null default 'pending' check (status in ('pending', 'approved', 'rejected')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index artists_search_idx on public.artists using gin (to_tsvector('english', search_text));
create index songs_search_idx on public.songs using gin (to_tsvector('english', search_text));
create index songs_artist_idx on public.songs (artist_id);
create index song_tone_profiles_lookup_idx on public.song_tone_profiles (mode, part_type, tone_type, is_public);
create index song_tone_profiles_search_idx on public.song_tone_profiles using gin (to_tsvector('english', search_text));
create index song_requests_status_idx on public.song_requests (status, created_at desc);
create index community_submissions_status_idx on public.community_submissions (status, created_at desc);

create trigger artists_updated_at before update on public.artists for each row execute function public.set_updated_at();
create trigger songs_updated_at before update on public.songs for each row execute function public.set_updated_at();
create trigger song_tone_profiles_updated_at before update on public.song_tone_profiles for each row execute function public.set_updated_at();
create trigger song_requests_updated_at before update on public.song_requests for each row execute function public.set_updated_at();
create trigger community_submissions_updated_at before update on public.community_submissions for each row execute function public.set_updated_at();

alter table public.artists enable row level security;
alter table public.songs enable row level security;
alter table public.song_tone_profiles enable row level security;
alter table public.tone_profile_effects enable row level security;
alter table public.tone_profile_sources enable row level security;
alter table public.song_requests enable row level security;
alter table public.community_submissions enable row level security;

grant select on public.artists to anon, authenticated;
grant select on public.songs to anon, authenticated;
grant select on public.song_tone_profiles to anon, authenticated;
grant select on public.tone_profile_effects to anon, authenticated;
grant select on public.tone_profile_sources to anon, authenticated;
grant select, insert on public.song_requests to anon, authenticated;
grant select, insert, update on public.community_submissions to anon, authenticated;

create policy "artists_public_read_active" on public.artists for select using (is_active = true);
create policy "songs_public_read_active" on public.songs for select using (is_active = true);
create policy "song_tone_profiles_public_read" on public.song_tone_profiles for select using (is_public = true);
create policy "tone_profile_effects_public_read" on public.tone_profile_effects for select using (
  exists (
    select 1 from public.song_tone_profiles p
    where p.id = tone_profile_effects.profile_id and p.is_public = true
  )
);
create policy "tone_profile_sources_public_read" on public.tone_profile_sources for select using (
  exists (
    select 1 from public.song_tone_profiles p
    where p.id = tone_profile_sources.profile_id and p.is_public = true
  )
);

create policy "song_requests_insert_own_or_anonymous" on public.song_requests for insert with check ((auth.uid() = user_id) or user_id is null);
create policy "song_requests_select_own_or_admin" on public.song_requests for select using (
  auth.uid() = user_id or
  exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin')
);

create policy "community_submissions_insert_own_or_anonymous" on public.community_submissions for insert with check ((auth.uid() = user_id) or user_id is null);
create policy "community_submissions_select_approved_or_own" on public.community_submissions for select using (
  status = 'approved' or auth.uid() = user_id or
  exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin')
);
create policy "community_submissions_update_own_pending" on public.community_submissions for update using (
  auth.uid() = user_id and status = 'pending'
) with check (
  auth.uid() = user_id and status = 'pending'
);
