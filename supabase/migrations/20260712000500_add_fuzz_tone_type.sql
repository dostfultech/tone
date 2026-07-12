insert into public.tone_types (id, label, sort_order)
values ('fuzz', 'Fuzz', 105)
on conflict (id) do update set
  label = excluded.label,
  sort_order = excluded.sort_order,
  is_active = true,
  updated_at = now();
