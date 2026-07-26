-- Guard v2: re-run the verified-profile guard across the FULL admin_verified set.
-- The original guard (20260725260000) ran before phases 14-41 were added, so the
-- ~700 songs verified since then were never covered. The lookup tries the normalized
-- master_tones chain first and only falls back to the (verified) legacy
-- song_tone_profiles on NOT_FOUND, so any song that has BOTH an active normalized
-- master_tone AND a verified legacy profile would serve the (lower-quality) normalized
-- row. Deactivate competing normalized master_tones + song_parts for every song that
-- now has an admin_verified legacy profile. Idempotent: safe to re-run.

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
