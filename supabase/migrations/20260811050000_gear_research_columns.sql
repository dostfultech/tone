begin;

-- Step 4 (AI auto-adds missing gear): when a user picks gear that isn't in the catalog, the
-- app researches its real specs with AI and stores them HERE (the review queue) — never
-- directly into the live equipment catalog. Admin reviews the researched specs and approves
-- them into the catalog, keeping matching data clean (owner audit rule).
alter table public.gear_search_misses
  add column if not exists researched_specs jsonb,
  add column if not exists research_status text not null default 'pending',
  add column if not exists research_model text;

create index if not exists gear_search_misses_research_idx
  on public.gear_search_misses (research_status, match_count, search_count desc);

-- Admin review helper: the missing gear we've researched and that's ready to add, most-wanted first.
create or replace view public.gear_research_review as
select kind, query_text, search_count, research_status, researched_specs, last_searched_at
from public.gear_search_misses
where match_count = 0 and research_status = 'done' and reviewed = false
order by search_count desc, last_searched_at desc;

commit;
