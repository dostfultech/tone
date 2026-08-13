-- Backfill search_text for gear rows that were inserted without it (search_text is a
-- plain `text not null default ''` column written directly at insert time — NOT
-- trigger-owned). Empty search_text = a row only matches by brand/model when the user
-- types; populating it from the specs makes tag/spec search work too
-- (e.g. "PJ", "5-string", "combo", "active", "punchy").
begin;

update public.gear_items
set search_text = trim(regexp_replace(
  lower(concat_ws(' ',
    brand, model, category, instrument_type, pickup_type, amp_type, gain_range,
    array_to_string(voicing_tags, ' '), array_to_string(notable_use_cases, ' ')
  )),
  '\s+', ' ', 'g'))
where coalesce(search_text, '') = '';

commit;
