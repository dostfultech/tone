-- Hide duplicate song entries (2026-08-06).
-- "One (Remastered)" / "Creeping Death (Remastered)" duplicate the verified
-- originals; "Little By Little" duplicates "Little by Little" (case dup).
-- Soft-hide instead of delete: real users' saved tone_results may reference
-- these profiles (cascade delete would erase user data).
begin;

update public.song_tone_profiles p
set is_public = false
from public.songs s, public.artists a
where p.song_id = s.id and s.artist_id = a.id
  and (
    (a.slug = 'metallica' and s.title in ('One (Remastered)', 'Creeping Death (Remastered)')) or
    (a.slug = 'oasis' and s.title = 'Little By Little')
  );

update public.songs s
set is_active = false
from public.artists a
where s.artist_id = a.id
  and (
    (a.slug = 'metallica' and s.title in ('One (Remastered)', 'Creeping Death (Remastered)')) or
    (a.slug = 'oasis' and s.title = 'Little By Little')
  );

do $$
declare
  n int;
begin
  -- The canonical originals must remain active and verified.
  select count(*) into n
  from public.song_tone_profiles p
  join public.songs s on s.id = p.song_id
  join public.artists a on a.id = s.artist_id
  where a.slug = 'metallica' and s.title in ('One', 'Creeping Death')
    and s.is_active = true and p.verification_status = 'admin_verified';
  if n = 0 then
    raise exception 'POST-CONDITION FAILED: canonical Metallica originals missing/inactive';
  end if;

  select count(*) into n
  from public.songs s join public.artists a on a.id = s.artist_id
  where s.is_active = true
    and ((a.slug = 'metallica' and s.title like '%(Remastered)')
      or (a.slug = 'oasis' and s.title = 'Little By Little'));
  if n > 0 then
    raise exception 'POST-CONDITION FAILED: % duplicate songs still active', n;
  end if;
end $$;

commit;
