-- Add new pedal_types for expanded category coverage
insert into public.pedal_types (id, label, description, sort_order)
values
  ('modulation', 'Modulation', 'Chorus, flanger, phaser, tremolo, vibrato and other modulation effects.', 91),
  ('volume', 'Volume', 'Volume pedals and expression controllers.', 150),
  ('looper', 'Looper', 'Loop recording and playback pedals.', 160),
  ('utility', 'Utility', 'Tuners, buffers, switchers, power supplies and other utility pedals.', 170),
  ('preamp', 'Preamp', 'Standalone preamp pedals for tone shaping.', 180),
  ('amp_cab_sim', 'Amp/Cab Sim', 'Amp and cabinet simulation pedals for direct recording.', 190),
  ('acoustic', 'Acoustic', 'Acoustic guitar simulation and enhancement pedals.', 200),
  ('tremolo', 'Tremolo', 'Tremolo and vibrato effect pedals.', 92)
on conflict (id) do update set
  label = excluded.label,
  description = excluded.description,
  sort_order = excluded.sort_order,
  is_active = true,
  updated_at = now();

-- Add new columns to pedal_models for price, artist usage, description, status, and popularity
alter table public.pedal_models
  add column if not exists price_low integer,
  add column if not exists price_high integer,
  add column if not exists used_by_artists text[] not null default '{}'::text[],
  add column if not exists description text not null default '',
  add column if not exists status text not null default 'active',
  add column if not exists popularity integer not null default 50;

-- Update the search text trigger to include artist names and description
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
  new.used_by_artists := coalesce(new.used_by_artists, '{}'::text[]);

  normalized_pedal_type := coalesce(nullif(btrim(new.pedal_type), ''), nullif(btrim(new.pedal_type_id), ''), 'overdrive');
  new.pedal_type := normalized_pedal_type;
  new.pedal_type_id := coalesce(new.pedal_type_id, normalized_pedal_type);
  new.category := coalesce(nullif(btrim(new.category), ''), normalized_pedal_type);

  new.search_text := lower(regexp_replace(
    concat_ws(' ',
      resolved_brand,
      new.name,
      new.category,
      new.pedal_type,
      new.description,
      array_to_string(new.tags, ' '),
      array_to_string(new.used_by_artists, ' ')
    ),
    '\\s+', ' ', 'g'
  ));

  return new;
end;
$$;
