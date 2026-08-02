-- Guard re-run after phase 58: deactivate competing normalized master_tones/song_parts
-- for any song that now has an admin_verified legacy profile.

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
