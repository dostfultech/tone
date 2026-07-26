-- Reviews had no moderation: submitReview() inserted rows as status='approved',
-- so anything submitted (including a spam solicitation) showed publicly on the
-- homepage immediately. New submissions now insert as 'pending'. Un-approve every
-- existing review so nothing unmoderated stays public; the owner can re-approve the
-- genuine ones. With zero approved reviews, the homepage falls back to its curated
-- starter reviews. Idempotent + guarded so it is safe even if the table is absent.

do $$
begin
  if exists (
    select 1 from information_schema.tables
    where table_schema = 'public' and table_name = 'reviews'
  ) then
    update public.reviews set status = 'pending' where status = 'approved';
  end if;
end $$;
