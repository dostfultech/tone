create extension if not exists pgcrypto;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  full_name text,
  avatar_url text,
  role text not null default 'user' check (role in ('user', 'admin')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.plans (
  id text primary key,
  name text not null,
  description text not null,
  monthly_price_cents integer not null,
  annual_price_cents integer not null,
  monthly_adaptations integer,
  saved_tones_limit integer,
  gear_presets_limit integer,
  features jsonb not null default '[]'::jsonb,
  dodo_monthly_product_id text,
  dodo_annual_product_id text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  plan_id text references public.plans(id),
  status text not null default 'inactive' check (status in ('inactive', 'trialing', 'active', 'on_hold', 'cancelled', 'failed', 'expired')),
  billing_interval text check (billing_interval in ('monthly', 'annual')),
  dodo_customer_id text,
  dodo_subscription_id text unique,
  dodo_product_id text,
  current_period_start timestamptz,
  current_period_end timestamptz,
  cancel_at_period_end boolean not null default false,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.gear_items (
  id uuid primary key default gen_random_uuid(),
  brand text not null,
  model text not null,
  item_type text not null check (item_type in ('guitar', 'bass_guitar', 'amp', 'bass_amp', 'pedal', 'pickup', 'multi_fx')),
  category text,
  instrument_type text check (instrument_type in ('guitar', 'bass', 'both')),
  pickup_type text,
  amp_type text,
  gain_range text,
  voicing_tags text[] not null default '{}',
  notable_use_cases text[] not null default '{}',
  source_urls text[] not null default '{}',
  search_text text not null default '',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (brand, model, item_type)
);

create index gear_items_search_idx on public.gear_items using gin (to_tsvector('english', search_text));
create index gear_items_type_idx on public.gear_items (item_type);

create table public.gear_presets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  name text not null,
  instrument_type text not null check (instrument_type in ('guitar', 'bass')),
  guitar_id uuid references public.gear_items(id),
  amp_id uuid references public.gear_items(id),
  pickup_id uuid references public.gear_items(id),
  guitar_name text,
  amp_name text,
  pickup_name text,
  effects jsonb not null default '[]'::jsonb,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.tone_jobs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  mode text not null check (mode in ('guitar', 'bass')),
  song text not null,
  artist text not null,
  part text not null,
  input_gear jsonb not null default '{}'::jsonb,
  status text not null default 'queued' check (status in ('queued', 'running', 'succeeded', 'failed')),
  model text,
  error_message text,
  prompt_tokens integer,
  completion_tokens integer,
  estimated_cost_usd numeric(10, 6),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.tone_results (
  id uuid primary key default gen_random_uuid(),
  job_id uuid not null references public.tone_jobs(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  result jsonb not null,
  confidence integer not null default 75 check (confidence between 0 and 100),
  created_at timestamptz not null default now()
);

create table public.saved_tones (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  tone_result_id uuid references public.tone_results(id) on delete set null,
  song text not null,
  artist text not null,
  part text not null,
  mode text not null check (mode in ('guitar', 'bass')),
  request jsonb not null,
  result jsonb not null,
  notes text check (char_length(coalesce(notes, '')) <= 2000),
  is_public boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.usage_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  event_type text not null check (event_type in ('tone_adaptation', 'saved_tone', 'gear_preset', 'login', 'checkout_started')),
  quantity integer not null default 1,
  tone_job_id uuid references public.tone_jobs(id) on delete set null,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table public.monthly_usage (
  user_id uuid not null references public.profiles(id) on delete cascade,
  usage_month date not null,
  adaptations_used integer not null default 0,
  saved_tones_created integer not null default 0,
  gear_presets_created integer not null default 0,
  updated_at timestamptz not null default now(),
  primary key (user_id, usage_month)
);

create table public.reviews (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id) on delete set null,
  rating integer not null check (rating between 1 and 5),
  display_name text not null default 'FretPilot user',
  body text not null check (char_length(body) between 10 and 1000),
  status text not null default 'pending' check (status in ('pending', 'approved', 'rejected')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.feedback_messages (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id) on delete set null,
  topic text not null,
  email text,
  message text not null check (char_length(message) between 5 and 4000),
  status text not null default 'open' check (status in ('open', 'reviewing', 'closed')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.admin_audit_logs (
  id uuid primary key default gen_random_uuid(),
  actor_id uuid references public.profiles(id) on delete set null,
  action text not null,
  target_table text,
  target_id text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create trigger profiles_updated_at before update on public.profiles for each row execute function public.set_updated_at();
create trigger plans_updated_at before update on public.plans for each row execute function public.set_updated_at();
create trigger subscriptions_updated_at before update on public.subscriptions for each row execute function public.set_updated_at();
create trigger gear_items_updated_at before update on public.gear_items for each row execute function public.set_updated_at();
create trigger gear_presets_updated_at before update on public.gear_presets for each row execute function public.set_updated_at();
create trigger tone_jobs_updated_at before update on public.tone_jobs for each row execute function public.set_updated_at();
create trigger saved_tones_updated_at before update on public.saved_tones for each row execute function public.set_updated_at();
create trigger monthly_usage_updated_at before update on public.monthly_usage for each row execute function public.set_updated_at();
create trigger reviews_updated_at before update on public.reviews for each row execute function public.set_updated_at();
create trigger feedback_messages_updated_at before update on public.feedback_messages for each row execute function public.set_updated_at();

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email, full_name, avatar_url)
  values (
    new.id,
    coalesce(new.email, ''),
    coalesce(new.raw_user_meta_data ->> 'full_name', new.raw_user_meta_data ->> 'name'),
    new.raw_user_meta_data ->> 'avatar_url'
  )
  on conflict (id) do update set
    email = excluded.email,
    full_name = coalesce(public.profiles.full_name, excluded.full_name),
    avatar_url = coalesce(public.profiles.avatar_url, excluded.avatar_url),
    updated_at = now();
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

insert into public.plans (id, name, description, monthly_price_cents, annual_price_cents, monthly_adaptations, saved_tones_limit, gear_presets_limit, features)
values
  ('beginner', 'Beginner', 'Focused tone matching for players dialing in a few songs each month.', 699, 3999, 20, 15, 10, '["20 adaptations/month", "15 saved tones/month", "Gear preset creation", "Guitar and bass mode"]'::jsonb),
  ('expert', 'Expert', 'Unlimited tone work for gigging players, creators, and studio sessions.', 1099, 4999, null, null, null, '["Unlimited adaptations", "Unlimited saved tones", "Multi-FX preset translation", "Tone database access"]'::jsonb)
on conflict (id) do update set
  name = excluded.name,
  description = excluded.description,
  monthly_price_cents = excluded.monthly_price_cents,
  annual_price_cents = excluded.annual_price_cents,
  monthly_adaptations = excluded.monthly_adaptations,
  saved_tones_limit = excluded.saved_tones_limit,
  gear_presets_limit = excluded.gear_presets_limit,
  features = excluded.features,
  updated_at = now();

alter table public.profiles enable row level security;
alter table public.plans enable row level security;
alter table public.subscriptions enable row level security;
alter table public.gear_items enable row level security;
alter table public.gear_presets enable row level security;
alter table public.tone_jobs enable row level security;
alter table public.tone_results enable row level security;
alter table public.saved_tones enable row level security;
alter table public.usage_events enable row level security;
alter table public.monthly_usage enable row level security;
alter table public.reviews enable row level security;
alter table public.feedback_messages enable row level security;
alter table public.admin_audit_logs enable row level security;

create policy "profiles_select_own" on public.profiles for select using (auth.uid() = id);
create policy "profiles_update_own" on public.profiles for update using (auth.uid() = id) with check (auth.uid() = id);

create policy "plans_public_read_active" on public.plans for select using (is_active = true);

create policy "subscriptions_select_own" on public.subscriptions for select using (auth.uid() = user_id);

create policy "gear_items_public_read_active" on public.gear_items for select using (is_active = true);

create policy "gear_presets_select_own" on public.gear_presets for select using (auth.uid() = user_id);
create policy "gear_presets_insert_own" on public.gear_presets for insert with check (auth.uid() = user_id);
create policy "gear_presets_update_own" on public.gear_presets for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "gear_presets_delete_own" on public.gear_presets for delete using (auth.uid() = user_id);

create policy "tone_jobs_select_own" on public.tone_jobs for select using (auth.uid() = user_id);
create policy "tone_results_select_own" on public.tone_results for select using (auth.uid() = user_id);

create policy "saved_tones_select_own_or_public" on public.saved_tones for select using (auth.uid() = user_id or is_public = true);
create policy "saved_tones_insert_own" on public.saved_tones for insert with check (auth.uid() = user_id);
create policy "saved_tones_update_own" on public.saved_tones for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "saved_tones_delete_own" on public.saved_tones for delete using (auth.uid() = user_id);

create policy "usage_events_select_own" on public.usage_events for select using (auth.uid() = user_id);
create policy "monthly_usage_select_own" on public.monthly_usage for select using (auth.uid() = user_id);

create policy "reviews_public_read_approved" on public.reviews for select using (status = 'approved' or auth.uid() = user_id);
create policy "reviews_insert_own_or_anonymous" on public.reviews for insert with check ((auth.uid() = user_id) or user_id is null);
create policy "reviews_update_own_pending" on public.reviews for update using (auth.uid() = user_id and status = 'pending') with check (auth.uid() = user_id);

create policy "feedback_insert_own_or_anonymous" on public.feedback_messages for insert with check ((auth.uid() = user_id) or user_id is null);
create policy "feedback_select_own" on public.feedback_messages for select using (auth.uid() = user_id);

create policy "admin_audit_logs_admin_read" on public.admin_audit_logs for select using (
  exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin')
);
