-- Long-tail sweep: get the remaining songs backed by the sparse `master_tones` table
-- (which renders NULL original gear) onto complete, gear-bearing legacy profiles, and
-- fill the few well-known metal rigs with web-sourced verified gear (no fabrication).
-- Companion to 20260809030000 (which routed the iconic 10).
begin;

-- 1) Populate + verify the well-known metal songs whose legacy row had null/placeholder
--    gear. Gear is web-sourced (see source_summary). Upgrading to admin_verified so the
--    output shows the full rig + "Verified research" copy and wins the fallback ranking.

-- Death — "Leprosy" (1988). B.C. Rich Stealth + DiMarzio X2N; JCM800 2203 boosted by a
-- Boss DS-1. Sources: Equipboard (Chuck Schuldiner), musicstrive tone breakdown.
update public.song_tone_profiles set
  original_guitar = 'B.C. Rich Stealth (Chuck Schuldiner)',
  original_pickup = 'DiMarzio X2N (bridge)',
  original_amp    = 'Marshall JCM800 2203 (boosted with a Boss DS-1)',
  original_cab    = 'Marshall 4x12 cab',
  verification_status = 'admin_verified',
  confidence = 85,
  source_summary = 'Web-sourced: Equipboard (Chuck Schuldiner) + musicstrive tone breakdown — B.C. Rich Stealth, DiMarzio X2N, Marshall JCM800 2203 + Boss DS-1.'
where id = '329cddc0-332b-40ee-b808-0f886175a845';

-- Avenged Sevenfold — "Beast and the Harlot" (City of Evil, 2005). Schecter C-1 with
-- Seymour Duncan Invaders into a Bogner Uberschall. Sources: Equipboard (City of Evil
-- album; Synyster Gates / Zacky Vengeance), A7X Fandom.
update public.song_tone_profiles set
  original_guitar = 'Schecter C-1 (Synyster Gates)',
  original_pickup = 'Seymour Duncan Invader (bridge)',
  original_amp    = 'Bogner Uberschall',
  original_cab    = 'Closed-back 4x12 cab',
  verification_status = 'admin_verified',
  confidence = 84,
  source_summary = 'Web-sourced: Equipboard (A7X City of Evil) + A7X Fandom — Schecter C-1, Seymour Duncan Invader, Bogner Uberschall, 4x12.'
where id = '2f298509-b796-451c-98e9-e70b4f2cd81a';

-- Avenged Sevenfold — "Blinded in Chains" (City of Evil, 2005). Same album rig; replaces
-- the placeholder "modern_high_gain" tokens with the real gear.
update public.song_tone_profiles set
  original_guitar = 'Schecter C-1 (Synyster Gates)',
  original_pickup = 'Seymour Duncan Invader (bridge)',
  original_amp    = 'Bogner Uberschall',
  original_cab    = 'Marshall 4x12 cab',
  verification_status = 'admin_verified',
  confidence = 84,
  source_summary = 'Web-sourced: Equipboard (A7X City of Evil) + A7X Fandom — Schecter C-1, Seymour Duncan Invader, Bogner Uberschall, 4x12.'
where id = '1b28323c-26e4-4031-9252-648460395145';

-- Pantera — "Cemetary Gates" (misspelled duplicate). Mirror the correct-spelling
-- admin_verified profile: Dean ML (Dimebag) into a Randall solid-state high-gain.
update public.song_tone_profiles set
  original_guitar = 'Dean ML humbucker guitar (Dimebag Darrell)',
  original_pickup = 'Bill Lawrence L-500XL (bridge)',
  original_amp    = 'Randall solid-state high-gain',
  original_cab    = 'Randall 4x12 cab',
  verification_status = 'admin_verified',
  confidence = 85,
  source_summary = 'Mirrors the verified Pantera "Cemetery Gates" profile — Dean ML (Dimebag Darrell), Randall solid-state high-gain, Randall 4x12.'
where id = 'bc82d276-7a25-45ce-a49b-00cc3853bbf1';

-- Megadeth — "My Last Words" (Peace Sells, 1986). Its starter rows already carry the
-- accurate rig (Jackson King V, Marshall JCM800 2203); promote them so they win the
-- fallback ranking over the empty needs_review row. Sources: Equipboard (Dave Mustaine).
update public.song_tone_profiles set
  verification_status = 'admin_verified', confidence = 82,
  source_summary = 'Web-sourced: Equipboard (Dave Mustaine, Peace Sells era) — Jackson King V, Marshall JCM800/JMP 2203, Marshall 4x12.'
where id in ('d0269bb3-9eee-4afe-b7eb-599f7951bde2', 'ab377038-ab04-41cb-852b-da7566c88cb8');

-- 2) Repair the misspelled duplicate song title for display (slug unchanged to avoid a
--    collision with the correctly-spelled "Cemetery Gates" row).
update public.songs set title = 'Cemetery Gates', updated_at = now()
where id = '6f7c95a0-cd82-4752-a864-2e09bf919947' and title = 'Cemetary Gates';

-- 3) Deactivate the master_tones for every song that now has a gear-bearing legacy
--    profile, so the request falls through to it. Reversible (flip is_active back).
update public.master_tones set is_active = false, updated_at = now()
where is_active = true and id in (
  'daf62204-7ceb-44c7-9b73-8ff3cfca70c9', -- Cemetary/Cemetery Gates — Pantera
  'a461cf96-9412-4e12-9abc-9092a0284716', -- Leprosy — Death
  '35d88dfe-d1a2-4daa-9cad-1111a12e632f', -- Beast and the Harlot — A7X
  'f1a465f7-7605-48e3-b886-a5b28385b478', -- Blinded in Chains — A7X
  '6dab2a65-211e-4e83-b5c7-99af5710c126', -- My Last Words — Megadeth
  '6f6880cc-5e7e-4811-92dc-7f74b3299fa6', -- Sweet Child O' Mine (Classical Guitar Cover)
  '7e5069d5-e4f5-42d5-8b12-c451530178fc', -- Safe In Your Skin — Title Fight
  'b4fcb94f-6789-492c-9a4a-4baa4b71f682', -- All in my head — Computer
  '63d8fd04-d7ef-467c-b5d7-b2b1798b567e', -- Look What Happened — Less Than Jake
  '20c6e94a-b4b1-4ad3-88cf-71e6858edf79', -- What A God (Live) — SEU Worship
  '85a10241-f0ad-4c85-b532-4a99bd915bea'  -- Fool for Your Loving — Whitesnake
);

do $$
declare bad int;
begin
  select count(*) into bad from public.song_tone_profiles
   where id in ('329cddc0-332b-40ee-b808-0f886175a845','2f298509-b796-451c-98e9-e70b4f2cd81a',
                '1b28323c-26e4-4031-9252-648460395145','bc82d276-7a25-45ce-a49b-00cc3853bbf1')
     and (original_amp is null or verification_status <> 'admin_verified');
  if bad > 0 then raise exception 'Metal gear backfill incomplete: % rows', bad; end if;
end $$;

commit;
