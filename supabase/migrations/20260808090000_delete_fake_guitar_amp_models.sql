-- Delete fake procedurally-generated guitar_models / amp_models rows (2026-08-08).
--
-- Migration 20260716090000_master_gear_catalog_and_search.sql bulk-generated the
-- gear behavior catalog with a cross-join over generate_series, producing model
-- names of the exact shape  concat(family,' ',series,' ',lpad(seq,3,'0'))  e.g.
-- "Nova Studio 001", "Orbit MKII 002", "Vector MKIII 013". These carry no verified
-- flag (metadata='{}') and are the same class of fake data already purged from
-- artists and pedal_models. The real verified families (metadata->>'verified'
-- = 'true') must be KEPT.
--
-- FK check (performed before writing this migration — grep for
-- 'references public.guitar_models' / 'references public.amp_models'):
-- NO user-data table cascades on delete of a gear row.
--   * user_instruments.guitar_model_id  -> ON DELETE SET NULL  (user data, safe)
--   * user_rigs.amp_model_id            -> ON DELETE SET NULL  (user data, safe)
--   * multifx_amp_models.amp_model_id   -> ON DELETE SET NULL  (catalog)
-- The only ON DELETE CASCADE FKs are catalog tables that shed fake links harmlessly:
--   * guitar_model_pickups.guitar_model_id   -> ON DELETE CASCADE (catalog)
--   * amp_recommended_cabinets.amp_model_id  -> ON DELETE CASCADE (catalog)
-- Deleting fake gear only nulls user references; it never removes user rows.
--
-- Scope: instrument_type='guitar' ONLY. bass rows (guitar_models/bass 31,
-- amp_models/bass 27) are all real and are left untouched.
--
-- Fake predicate — the procedural generator's exact output shape:
--   coalesce(metadata->>'verified','') <> 'true'
--   AND model_name ~ '^[A-Za-z]+ [A-Za-z]+ [0-9]{3}$'
--
-- NOTE on the predicate: the naive form `model_name ~ '[0-9]{3}$'` is too broad.
-- It matches the verified Rickenbacker family '330 / 360' (a real row), so the
-- generic form both trips the safety guard AND is imprecise. The anchored form
-- above matches exactly the 2200 guitar + 1600 amp procedural rows and nothing else.
--
-- Non-fake rows deliberately KEPT (real gear that merely lacks a verified flag —
-- NOT part of the procedural fake class, so out of scope for deletion):
--   guitar: 'Les Paul Traditional Pro II', 'WL-20BK Rock Series'
--   amp:    'MG15FX'
-- Because these 3 real rows survive, guitar-type total lands at 61 (59 verified
-- + 2) and amp-type total at 83 (82 verified + 1) — NOT the bare verified counts.
begin;

-- Safety guard: abort if the fake predicate would touch ANY verified row.
do $$
declare
  bad int;
begin
  select count(*) into bad
  from public.guitar_models
  where instrument_type = 'guitar'
    and metadata->>'verified' = 'true'
    and model_name ~ '^[A-Za-z]+ [A-Za-z]+ [0-9]{3}$';
  if bad > 0 then
    raise exception 'SAFETY ABORT: % verified guitar_models/guitar rows match the fake predicate', bad;
  end if;

  select count(*) into bad
  from public.amp_models
  where instrument_type = 'guitar'
    and metadata->>'verified' = 'true'
    and model_name ~ '^[A-Za-z]+ [A-Za-z]+ [0-9]{3}$';
  if bad > 0 then
    raise exception 'SAFETY ABORT: % verified amp_models/guitar rows match the fake predicate', bad;
  end if;
end $$;

-- Delete the procedural fakes and record how many went, so we can assert the
-- exact expected volumes below (belt-and-suspenders against a mis-scoped predicate).
do $$
declare
  g_deleted int;
  a_deleted int;
  g_verified int;
  a_verified int;
  g_fake_left int;
  a_fake_left int;
begin
  delete from public.guitar_models
  where instrument_type = 'guitar'
    and coalesce(metadata->>'verified','') <> 'true'
    and model_name ~ '^[A-Za-z]+ [A-Za-z]+ [0-9]{3}$';
  get diagnostics g_deleted = row_count;

  delete from public.amp_models
  where instrument_type = 'guitar'
    and coalesce(metadata->>'verified','') <> 'true'
    and model_name ~ '^[A-Za-z]+ [A-Za-z]+ [0-9]{3}$';
  get diagnostics a_deleted = row_count;

  -- Post-condition 1: exactly the known procedural volumes were removed.
  if g_deleted <> 2200 then
    raise exception 'POST-CONDITION FAILED: expected to delete 2200 fake guitar_models, deleted %', g_deleted;
  end if;
  if a_deleted <> 1600 then
    raise exception 'POST-CONDITION FAILED: expected to delete 1600 fake amp_models, deleted %', a_deleted;
  end if;

  -- Post-condition 2: the verified families are fully intact.
  select count(*) into g_verified
  from public.guitar_models
  where instrument_type = 'guitar' and metadata->>'verified' = 'true';
  if g_verified <> 59 then
    raise exception 'POST-CONDITION FAILED: expected 59 verified guitar families, found %', g_verified;
  end if;

  select count(*) into a_verified
  from public.amp_models
  where instrument_type = 'guitar' and metadata->>'verified' = 'true';
  if a_verified <> 82 then
    raise exception 'POST-CONDITION FAILED: expected 82 verified amp families, found %', a_verified;
  end if;

  -- Post-condition 3: no procedural-fake rows survive the cleanup.
  select count(*) into g_fake_left
  from public.guitar_models
  where instrument_type = 'guitar'
    and coalesce(metadata->>'verified','') <> 'true'
    and model_name ~ '^[A-Za-z]+ [A-Za-z]+ [0-9]{3}$';
  if g_fake_left <> 0 then
    raise exception 'POST-CONDITION FAILED: % fake guitar_models rows remain', g_fake_left;
  end if;

  select count(*) into a_fake_left
  from public.amp_models
  where instrument_type = 'guitar'
    and coalesce(metadata->>'verified','') <> 'true'
    and model_name ~ '^[A-Za-z]+ [A-Za-z]+ [0-9]{3}$';
  if a_fake_left <> 0 then
    raise exception 'POST-CONDITION FAILED: % fake amp_models rows remain', a_fake_left;
  end if;
end $$;

commit;
