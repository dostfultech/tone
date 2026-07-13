-- Capture front-end navigation and interaction telemetry for product analytics.

create table if not exists public.app_activity_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id) on delete set null,
  session_id text,
  event_category text not null check (event_category in ('page_view', 'ui_action', 'custom_event')),
  event_name text not null,
  path text,
  referrer text,
  element text,
  metadata jsonb not null default '{}'::jsonb,
  client_ip text,
  user_agent text,
  occurred_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create index if not exists app_activity_events_occurred_idx
  on public.app_activity_events (occurred_at desc);

create index if not exists app_activity_events_user_occurred_idx
  on public.app_activity_events (user_id, occurred_at desc);

alter table public.app_activity_events enable row level security;

revoke all on public.app_activity_events from anon, authenticated;
grant select, insert on public.app_activity_events to service_role;

drop policy if exists app_activity_events_admin_read on public.app_activity_events;
create policy app_activity_events_admin_read on public.app_activity_events
for select to authenticated
using (exists (
  select 1 from public.profiles p
  where p.id = (select auth.uid())
    and p.role = 'admin'
));

comment on table public.app_activity_events is
  'Front-end telemetry: page views plus user interactions captured asynchronously by the web app.';
