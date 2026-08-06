-- Hide title-variant duplicate songs found during tier-2 backlog analysis (2026-08-06).
-- Canonical titles keep/get verified profiles; punctuation/prefix variants are hidden.
begin;

update public.song_tone_profiles p
set is_public = false
from public.songs s, public.artists a
where p.song_id = s.id and s.artist_id = a.id
  and (
    (a.slug = 'bad-company' and s.title = 'Silver Blue and Gold') or
    (a.slug = 'joe-bonamassa' and s.title = 'Ballad of John Henry') or
    (a.slug = 'stevie-ray-vaughan' and s.title = 'Tin Pan Alley') or
    (a.slug = 'king-crimson' and s.title = 'In the Court of the Crimson King')
  );

update public.songs s
set is_active = false
from public.artists a
where s.artist_id = a.id
  and (
    (a.slug = 'bad-company' and s.title = 'Silver Blue and Gold') or
    (a.slug = 'joe-bonamassa' and s.title = 'Ballad of John Henry') or
    (a.slug = 'stevie-ray-vaughan' and s.title = 'Tin Pan Alley') or
    (a.slug = 'king-crimson' and s.title = 'In the Court of the Crimson King')
  );

do $$
declare
  n int;
begin
  select count(*) into n
  from public.songs s join public.artists a on a.id = s.artist_id
  where s.is_active = true
    and ((a.slug = 'bad-company' and s.title = 'Silver Blue and Gold')
      or (a.slug = 'joe-bonamassa' and s.title = 'Ballad of John Henry')
      or (a.slug = 'stevie-ray-vaughan' and s.title = 'Tin Pan Alley')
      or (a.slug = 'king-crimson' and s.title = 'In the Court of the Crimson King'));
  if n > 0 then
    raise exception 'POST-CONDITION FAILED: % variant duplicates still active', n;
  end if;
end $$;

commit;
