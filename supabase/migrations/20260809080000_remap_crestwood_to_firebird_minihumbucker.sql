-- Accuracy fix: the Epiphone Crestwood Custom has MINI-HUMBUCKERS (see its own catalog
-- description) but was filed under the "Les Paul Junior / Special (P-90)" behavior family.
-- Mini-humbuckers voice brighter/tighter than P-90s — the correct behavior family is
-- "Firebird" (Gibson/Epiphone Firebird = mini-humbucker). Move the Crestwood there.
-- The Epiphone Wilshire (dual P-90s) correctly STAYS in the P-90 family and is untouched.
-- guitar_models.search_text is trigger-rebuilt from tags — only tags are edited here.
begin;

-- Remove the Crestwood from the P-90 family.
update public.guitar_models
set tags = array_remove(array_remove(tags, 'epiphone crestwood custom'), 'crestwood custom')
where instrument_type = 'guitar' and model_name = 'Les Paul Junior / Special (P-90)';

-- Add the Crestwood to the Firebird (mini-humbucker) family.
update public.guitar_models
set tags = (
  select array_agg(distinct t)
  from unnest(tags || array['epiphone crestwood custom','crestwood custom']) as t
)
where instrument_type = 'guitar' and model_name = 'Firebird';

do $$
declare in_fb int; in_p90_cw int; in_p90_wil int;
begin
  select count(*) into in_fb from public.guitar_models
    where model_name = 'Firebird' and instrument_type = 'guitar' and tags @> array['epiphone crestwood custom'];
  select count(*) into in_p90_cw from public.guitar_models
    where model_name = 'Les Paul Junior / Special (P-90)' and instrument_type = 'guitar' and tags @> array['epiphone crestwood custom'];
  select count(*) into in_p90_wil from public.guitar_models
    where model_name = 'Les Paul Junior / Special (P-90)' and instrument_type = 'guitar' and tags @> array['epiphone wilshire'];
  if in_fb     < 1 then raise exception 'Crestwood not added to Firebird family'; end if;
  if in_p90_cw > 0 then raise exception 'Crestwood still present in P-90 family'; end if;
  if in_p90_wil < 1 then raise exception 'Wilshire unexpectedly removed from P-90 family'; end if;
end $$;

commit;
