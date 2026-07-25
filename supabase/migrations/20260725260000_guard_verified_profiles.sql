-- Guard: admin_verified legacy tone profiles must never be bypassed by a competing
-- normalized master_tone on the same song. The lookup tries the normalized
-- (master_tones) chain first and only falls back to song_tone_profiles on NOT_FOUND,
-- so if a song has BOTH a normalized master_tone AND a verified legacy profile, the
-- (often lower-quality) normalized row would win. Deactivate normalized master_tones
-- and their song_parts for any song that has a verified legacy profile so the
-- verified data is always served.

update public.master_tones mt
set is_active = false, updated_at = now()
from public.song_parts sp
where mt.song_part_id = sp.id
  and mt.is_active = true
  and sp.song_id in (
    select distinct song_id
    from public.song_tone_profiles
    where verification_status = 'admin_verified'
  );

update public.song_parts sp
set is_active = false, updated_at = now()
where sp.is_active = true
  and sp.song_id in (
    select distinct song_id
    from public.song_tone_profiles
    where verification_status = 'admin_verified'
  );
