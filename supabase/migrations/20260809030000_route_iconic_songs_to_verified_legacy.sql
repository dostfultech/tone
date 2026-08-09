-- Route iconic demo songs to the rich, admin-verified legacy catalog.
--
-- Context: the tone lookup has two data systems. The PRIMARY path walks
-- artists -> songs -> song_parts -> master_tones; only if that throws NOT_FOUND does it
-- fall back to the mature `song_tone_profiles` legacy catalog (16,972 rows, 100% of the
-- 7,734 admin_verified rows carry real original gear text). The primary `master_tones`
-- table holds only ~28 early rows that carry archetype IDs, NOT original-gear text, so
-- every song backed by one renders with a NULL original amp/cab -> no Cabinet card and a
-- generic "Match to original" amp-model instruction. That degraded output shadows the
-- verified legacy data for exactly the songs most likely to be demoed for marketing
-- (Sweet Child O' Mine, One, Smoke on the Water, Creeping Death, Riviera Paradise...).
--
-- Fix: soft-deactivate ONLY the master_tones whose song ALSO has rich admin_verified
-- legacy data. With the master_tone inactive, findMasterToneForPart throws NOT_FOUND and
-- the request falls through to the verified legacy profile (richer gear + effects) — the
-- song gains the full output and loses nothing. Fully reversible (flip is_active back).
-- master_tones without a confirmed verified legacy match are intentionally left active so
-- they keep their curated settings.
begin;

update public.master_tones
set is_active = false, updated_at = now()
where is_active = true
  and id in (
    '45b25b44-23f2-49c4-831e-570d015b8e48', -- Levitating — Dua Lipa (legacy: Fender Twin Reverb)
    '7e1bb294-96c7-49a0-86f2-53fe5c780ca3', -- One — Metallica (legacy: Mesa/Boogie Mark IIC+)
    '3ea57a59-e5a0-4de5-bf85-7edb95f8fc07', -- Creeping Death — Metallica (legacy: Mesa/Boogie high-gain)
    '9bbad298-9710-45de-8827-c1bd8252406f', -- Give Me Faith — Elevation Worship (legacy: Vox AC30C2)
    'ddd3e6e7-cc81-45f4-bc6c-fea38b5cd24f', -- Smoke on the Water — Deep Purple (legacy: Marshall Major modified)
    '772e8d7a-b792-4090-98ad-2803b784c69f', -- Go Away — Weezer (legacy: high-gain amp)
    '03b549c1-5005-4096-a7b3-601bf8a7f195', -- Flutter — Julie (legacy: Fender Twin Reverb)
    'a71a620e-6df2-4eb0-a959-dae5a20fe444', -- Earrings — Malcolm Todd (legacy: Roland JC-120)
    '7bf0c2fe-cc37-4a85-9ccc-472e9dbae132', -- Sweet Child O' Mine — Guns N' Roses (legacy: Marshall mod 1959 / Silver Jubilee)
    'f704c601-b6aa-47ee-8866-49dde13da7c6'  -- Riviera Paradise — SRV (legacy: Fender Vibroverb)
  );

-- Repair the malformed duplicate song title (a stray leading apostrophe+space) so it no
-- longer appears in search as "' Sweet Child O' Mine". Slug is unchanged.
update public.songs
set title = 'Sweet Child O'' Mine', updated_at = now()
where id = 'c3f1ac92-81a8-4ffc-858e-e3e549538406'
  and title = ''' Sweet Child O'' Mine';

do $$
declare still_active int;
begin
  select count(*) into still_active from public.master_tones
   where is_active = true
     and id in (
       '45b25b44-23f2-49c4-831e-570d015b8e48','7e1bb294-96c7-49a0-86f2-53fe5c780ca3',
       '3ea57a59-e5a0-4de5-bf85-7edb95f8fc07','9bbad298-9710-45de-8827-c1bd8252406f',
       'ddd3e6e7-cc81-45f4-bc6c-fea38b5cd24f','772e8d7a-b792-4090-98ad-2803b784c69f',
       '03b549c1-5005-4096-a7b3-601bf8a7f195','a71a620e-6df2-4eb0-a959-dae5a20fe444',
       '7bf0c2fe-cc37-4a85-9ccc-472e9dbae132','f704c601-b6aa-47ee-8866-49dde13da7c6'
     );
  if still_active > 0 then
    raise exception 'Expected all 10 iconic master_tones inactive, % still active', still_active;
  end if;
end $$;

commit;
