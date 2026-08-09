-- Phase 112: deduplicate equipment catalog — hide format-variant twins of the SAME product
-- (apostrophe / hyphen / spacing / casing / colon differences with an IDENTICAL alphanumeric
-- skeleton). Distinct products that only look similar (e.g. Mesa Subway D-800 vs D-800+) are
-- EXCLUDED by the skeleton-equality gate. The best-formatted variant stays active; the twin is set
-- inactive (reversible, FK-safe; gear resolution is token-fuzzy at request time, so hiding a
-- display-name twin cannot break tone matching).
begin;
update public.equipment set status = 'discontinued', updated_at = now()
where status = 'active' and id in (
  '0145d778-bce2-4e3b-a082-005b56301c1d',
  '043094b5-9be7-415f-bac2-66ec7cdeacf5',
  '05c0bf1f-4028-4660-a4a8-c9c2e97d24ed',
  '884d4ffb-44b0-4fa1-9f6a-eb29180628f1',
  '65eff008-1b0e-4c3f-8531-2754aae3bdb3',
  'ede61a96-fe2d-49a7-a04d-ea2d61a178b1',
  '1449f336-1dfa-429e-90e3-da6f91435468',
  'cb613c8a-caf3-41ae-ad49-533606e61fe1',
  '17d9c190-aae1-42f9-9373-ba889a8962df',
  '7371f9b9-fcbf-49e9-8f2a-83713f927545',
  '779dda70-eaa8-4810-ae26-8b4795b7b014',
  '4975dba2-3a90-4837-8c51-6de01ea1a1df',
  '9bcc8d7f-dad3-4ebc-bdbf-1fdf1f9c43e7',
  '99868fd5-3080-4839-9fdc-bc0243861f59',
  '7e5e5ea2-3627-4cad-af25-4fb7909634d7',
  '33c04203-5bce-4ce1-81b8-9e4855629c33',
  'ce9d2dc4-e422-49b5-be1b-93836957d312',
  '40f2e7f6-f15a-4b62-b7fd-3e74165a63a5',
  '8b597b4e-b644-451d-84f6-3ed5424a33c0',
  '78b7d8d0-b2bc-4231-8676-694ee32a049e',
  'c0837e60-31b0-456a-b8f8-a3802d980cef',
  'c041e2e5-cdd7-4cc1-97fc-9f99570c36a5',
  '623e43b8-d817-49a8-abf0-5c6e6ac8b33b',
  'ef7c3013-96b8-4e03-ba34-160b49bad12e',
  'aa45ed09-d2d2-4f80-b337-5a2b46aa350b',
  '9c971c0d-e196-4516-8e6b-8d4e4c169ea7',
  '7a1a2b66-c862-4085-883f-cc81bf30b4a9',
  '8bcb787a-79f4-4e56-ab9e-081fd1881222',
  '8d65429a-95ec-4df7-b0df-a76b52b1b794',
  'b2072231-7946-4673-9046-884bf355c685',
  'a15f45ac-ee52-4f3a-925e-183b2093a65b',
  'bf851d2b-0fb9-47eb-a2ed-6cc0fd54d157',
  'd820456f-c720-4599-9f04-55e612fe7909',
  'f5bd0e31-2a2f-41ce-bf83-8314abf26dca'
);
commit;
