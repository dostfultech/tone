-- Route Harley Benton base models to their archetype families (2026-08-08).
-- These 8 base models were double-tagged: exact phrase in BOTH the HB "Electric
-- Series" catch-all (phase-1) AND their specific archetype (Wave 1). Paired with
-- the gear-repository exact-tag lookup (prefers tags @> {phrase} over a search_text
-- substring), removing the Electric Series copy makes the exact-tag match resolve
-- to the specific archetype (Strat/Tele/LP/RG/PRS). The remaining variant tags
-- (st-20 hss, sc-450 cs, te-62cc, amarok-6, fusion-ii hh fr, cst-24t) stay in
-- Electric Series for those distinct HB models.
begin;

update public.guitar_models t
set tags = (
  select array(select e from unnest(coalesce(t.tags, array[]::text[])) as e
               where e <> all(array[
                 'harley benton st-20','harley benton st-62',
                 'harley benton te-20','harley benton te-52',
                 'harley benton dc-junior','harley benton r-446',
                 'harley benton fusion-iii hsh','harley benton cst-24'
               ]))
)
from public.equipment_manufacturers m
where m.id = t.manufacturer_id and m.slug = 'harley-benton'
  and t.model_name = 'Electric Series' and t.instrument_type = 'guitar';

-- Post-conditions: simulate the deployed exact-tag lookup (tags @> {phrase},
-- order by model_name asc). Each HB base model must now resolve to its archetype.
do $$
declare fam text;
  cases text[][] := array[
    array['harley benton st-20','Stratocaster / Telecaster'],
    array['harley benton te-52','Telecaster'],
    array['harley benton sc-450','Les Paul'],
    array['harley benton dc-junior','Les Paul Junior / Special (P-90)'],
    array['harley benton amarok','RG / S'],
    array['harley benton fusion-ii hh','RG / S'],
    array['harley benton te-62','Telecaster'],
    array['harley benton cst-24','SE Custom 24']
  ];
  c text[];
begin
  foreach c slice 1 in array cases loop
    select model_name into fam from public.guitar_models
    where instrument_type='guitar' and is_active=true and tags @> array[c[1]]::text[]
    order by model_name asc limit 1;
    if fam is distinct from c[2] then
      raise exception 'POST-CONDITION FAILED: exact-tag "%" resolves to % (expected %)', c[1], fam, c[2];
    end if;
  end loop;
end $$;

commit;
