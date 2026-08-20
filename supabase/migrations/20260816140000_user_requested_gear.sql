-- User-requested gear (from the "Can't find your gear?" form), admin-verified.
-- Guitars + amps -> public.equipment (the picker catalog; search_text + brand_slug
-- are built by the equipment_before_write trigger from search_terms, so we supply
-- search_terms only). Multi-FX (NUX MG-30, Boss ME-90) ALREADY exist and are
-- catalog_verified — users just couldn't find them because the search_text (built
-- from tags) lacked the no-hyphen forms "mg30"/"me90". We add those aliases so the
-- trigger rebuilds search_text and the units become findable.
-- Idempotent: equipment via on conflict (equipment_type, brand, model); multi-FX via
-- targeted slug updates.

begin;

-- ---------------- guitars + amps into the picker catalog ----------------
insert into public.equipment
  (equipment_type, brand, model, series, display_name, description, is_popular, sort_order, status,
   body_type, frets, scale_length_inches, bridge_type, pickup_configuration, pickup_type, output_level,
   amp_type, technology, power_rating_watts, channels, gain_range,
   genres, tone_characteristics, search_terms)
values
  -- Juarez Stratocaster — very popular budget beginner S-style in India (SSS + trem).
  ('electric_guitar','Juarez','Stratocaster','Stratocaster','Juarez Stratocaster',
   'Entry-level S-style electric guitar with three single-coil pickups and a synchronized tremolo — a popular beginner guitar in India.',
   false, 60, 'active',
   'solid_body', 22, 25.5, 'vintage_tremolo', 'sss', array['single_coil','passive_single_coil']::public.equipment_pickup_type[], 'low',
   null, null, null, null, null,
   array['rock','blues','pop']::public.equipment_genre[],
   array['bright','clean','balanced']::public.equipment_tone_characteristic[],
   array['juarez','stratocaster','strat','juarez strat','juarez stratocaster','sss','beginner electric']::text[]),

  -- Sqoe Seib 550 — budget S-style electric from Sqoe's Seib series.
  ('electric_guitar','Sqoe','Seib 550','Seib','Sqoe Seib 550',
   'Budget S-style electric guitar from Sqoe''s Seib series.',
   false, 70, 'active',
   'solid_body', 22, 25.5, 'vintage_tremolo', null, '{}'::public.equipment_pickup_type[], null,
   null, null, null, null, null,
   array['rock','blues','pop']::public.equipment_genre[],
   array['bright','balanced','clean']::public.equipment_tone_characteristic[],
   array['sqoe','seib','seib 550','seib550','sqoe seib','sqoe seib 550','s-style electric']::text[]),

  -- Palco 4444 — compact budget solid-state practice combo (popular in India).
  ('guitar_amp','Palco','4444','','Palco 4444',
   'Compact solid-state practice guitar amplifier — a budget entry-level combo popular in India.',
   false, 70, 'active',
   null, null, null, null, null, '{}'::public.equipment_pickup_type[], null,
   'combo', 'solid_state', null, null, 'medium',
   array['rock','blues','pop']::public.equipment_genre[],
   array['clean','warm','balanced']::public.equipment_tone_characteristic[],
   array['palco','palco 4444','4444','palco 4444 amp','practice guitar amp']::text[]),

  -- Harley Benton HB-20MFX — 20W practice combo with clean+drive channels and built-in multi-FX.
  ('guitar_amp','Harley Benton','HB-20MFX','HB','Harley Benton HB-20MFX',
   '20-watt solid-state practice combo with an 8-inch speaker, clean and drive channels, and built-in multi-effects (reverb, delay, chorus, flanger).',
   false, 70, 'active',
   null, null, null, null, null, '{}'::public.equipment_pickup_type[], null,
   'combo', 'solid_state', 20, 2, 'medium',
   array['rock','blues','pop']::public.equipment_genre[],
   array['clean','crunch','balanced']::public.equipment_tone_characteristic[],
   array['harley benton','hb-20mfx','hb 20mfx','hb20mfx','20mfx','20 watt practice combo','multi effects amp']::text[])
on conflict (equipment_type, brand, model) do update set
  series = excluded.series,
  display_name = excluded.display_name,
  description = excluded.description,
  status = 'active',
  body_type = excluded.body_type,
  frets = excluded.frets,
  scale_length_inches = excluded.scale_length_inches,
  bridge_type = excluded.bridge_type,
  pickup_configuration = excluded.pickup_configuration,
  pickup_type = excluded.pickup_type,
  output_level = excluded.output_level,
  amp_type = excluded.amp_type,
  technology = excluded.technology,
  power_rating_watts = excluded.power_rating_watts,
  channels = excluded.channels,
  gain_range = excluded.gain_range,
  genres = excluded.genres,
  tone_characteristics = excluded.tone_characteristics,
  search_terms = excluded.search_terms,
  updated_at = now();

-- ---------------- multi-FX findability fix (add no-hyphen search aliases) ----------------
-- The before-write trigger rebuilds search_text from brand + name + category + tags,
-- so adding aliases to tags makes "mg30" / "nux mg30" (and me90 variants) resolve.
update public.multifx_models set
  tags = array['nux','mg-30','mg30','mg 30','nux mg30','nux mg-30','amp modeler','ir loader','multi fx','direct','stage'],
  metadata = jsonb_build_object('catalog_verified', true, 'source', 'multifx_catalog_v2', 'version', 2),
  is_active = true
where slug = 'nux-mg-30';

update public.multifx_models set
  tags = array['boss','me-90','me90','me 90','boss me90','boss me-90','cosm','amp modeling','multi effects','floorboard','direct'],
  metadata = jsonb_build_object('catalog_verified', true, 'source', 'multifx_catalog_v2', 'version', 2),
  is_active = true
where slug = 'boss-me-90';

-- Post-conditions: fail loudly if anything didn't land.
do $$
declare
  eq_count int;
  mfx_count int;
begin
  select count(*) into eq_count from public.equipment
  where status = 'active' and (
    (brand = 'Juarez' and model = 'Stratocaster') or
    (brand = 'Sqoe' and model = 'Seib 550') or
    (brand = 'Palco' and model = '4444') or
    (brand = 'Harley Benton' and model = 'HB-20MFX')
  );
  if eq_count <> 4 then
    raise exception 'POST-CONDITION FAILED: expected 4 requested equipment rows, got %', eq_count;
  end if;

  select count(*) into mfx_count from public.multifx_models
  where slug in ('nux-mg-30','boss-me-90') and is_active = true
    and (search_text like '%mg30%' or search_text like '%me90%');
  if mfx_count <> 2 then
    raise exception 'POST-CONDITION FAILED: expected 2 multi-FX with no-hyphen alias in search_text, got %', mfx_count;
  end if;
end $$;

commit;
