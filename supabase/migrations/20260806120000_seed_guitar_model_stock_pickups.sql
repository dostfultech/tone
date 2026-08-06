-- Stock pickup seed v1 (2026-08-06).
--
-- guitar_model_pickups was empty since creation (20260704193016), so the
-- findPickups stock-pickup fallback in the tone-adaptation repository never
-- returned rows and pickupProfileRule never fired for users who select a
-- guitar but no pickup. This migration maps every verified electric-guitar
-- behavior FAMILY row in guitar_models (metadata.verified=true, 59 rows;
-- picker display names ILIKE-resolve to these via tags folded into
-- search_text, see gear phase 1 20260803100000) to representative stock
-- pickups drawn from the 96 verified pickup_models rows
-- (20260806110000_pickup_verification_v1).
--
-- Positions follow each family's pickup_layout: hh -> bridge+neck,
-- hss/sss -> bridge+middle+neck, ss/hs/p90 -> bridge+neck, h -> bridge.
-- Where the actual OEM pickup exists in pickup_models the row is exact
-- (is_stock_equivalent=false); otherwise the closest verified pickup is
-- used and flagged is_stock_equivalent=true, with the real stock unit
-- named in the note.
--
-- Bass families (31 verified rows) are intentionally NOT seeded: pickup_models
-- currently contains no bass pickups (pickup_types: single_coil, humbucker,
-- p90 only). Seed those in a future phase once bass pickup rows exist.
--
-- Data-only, idempotent (upserts on the (guitar_model_id, pickup_position,
-- is_stock) unique key).

begin;

insert into public.guitar_model_pickups (guitar_model_id, pickup_model_id, pickup_position, is_stock, metadata)
select
  g.id,
  p.id,
  v.position,
  true,
  jsonb_build_object(
    'verified', true,
    'source', 'stock_pickup_seed_v1',
    'version', 1,
    'is_stock_equivalent', v.equiv,
    'note', v.note
  )
from (values
  -- ============================================================
  -- Fender-style single-coil families
  -- ============================================================
  -- Player-series strats ship Player Alnico 5 singles; Tex-Mex is Fender's
  -- closest verified alnico-5 set with the same slightly-hot MIM voicing.
  ('fender', 'Stratocaster', 'bridge', 'fender', 'Tex-Mex', true,  'Stock: Player Series Alnico 5 singles; Tex-Mex is the closest verified Fender alnico-5 set'),
  ('fender', 'Stratocaster', 'middle', 'fender', 'Tex-Mex', true,  'Stock: Player Series Alnico 5 singles; Tex-Mex is the closest verified Fender alnico-5 set'),
  ('fender', 'Stratocaster', 'neck',   'fender', 'Tex-Mex', true,  'Stock: Player Series Alnico 5 singles; Tex-Mex is the closest verified Fender alnico-5 set'),
  -- American Professional II Telecaster ships V-Mod II; representative for the family.
  ('fender', 'Telecaster', 'bridge', 'fender', 'V-Mod II Tele', false, 'Stock on American Professional II Telecaster; representative for the Telecaster family'),
  ('fender', 'Telecaster', 'neck',   'fender', 'V-Mod II Tele', false, 'Stock on American Professional II Telecaster; representative for the Telecaster family'),
  -- Jazzmaster/Jaguar wide flat coils: warm vintage single voicing ~ Fat 50s.
  ('fender', 'Jazzmaster / Jaguar', 'bridge', 'fender', 'Custom Shop Fat 50s', true, 'Stock: Pure Vintage 65 Jazzmaster wide coils; Fat 50s is the closest verified warm vintage single'),
  ('fender', 'Jazzmaster / Jaguar', 'neck',   'fender', 'Custom Shop Fat 50s', true, 'Stock: Pure Vintage 65 Jazzmaster wide coils; Fat 50s is the closest verified warm vintage single'),
  -- Squier Fender-designed alnico singles sit closest to Tex-Mex output/voicing.
  ('squier', 'Stratocaster / Telecaster', 'bridge', 'fender', 'Tex-Mex', true, 'Stock: Fender-Designed Alnico singles (Classic Vibe); Tex-Mex is the closest verified set'),
  ('squier', 'Stratocaster / Telecaster', 'middle', 'fender', 'Tex-Mex', true, 'Stock: Fender-Designed Alnico singles (Classic Vibe); Tex-Mex is the closest verified set'),
  ('squier', 'Stratocaster / Telecaster', 'neck',   'fender', 'Tex-Mex', true, 'Stock: Fender-Designed Alnico singles (Classic Vibe); Tex-Mex is the closest verified set'),
  -- G&L CLF-100 alnico legacy singles: vintage 50s wind ~ Fat 50s.
  ('g-l', 'Legacy / ASAT', 'bridge', 'fender', 'Custom Shop Fat 50s', true, 'Stock: G&L CLF-100 alnico singles; Fat 50s is the closest verified vintage-wind set'),
  ('g-l', 'Legacy / ASAT', 'middle', 'fender', 'Custom Shop Fat 50s', true, 'Stock: G&L CLF-100 alnico singles; Fat 50s is the closest verified vintage-wind set'),
  ('g-l', 'Legacy / ASAT', 'neck',   'fender', 'Custom Shop Fat 50s', true, 'Stock: G&L CLF-100 alnico singles; Fat 50s is the closest verified vintage-wind set'),
  -- PRS 635JM singles are voiced on early-60s Strat sets ~ CS 69.
  ('prs', 'Silver Sky', 'bridge', 'fender', 'Custom Shop 69', true, 'Stock: PRS 635JM singles (early-60s voicing); Custom Shop 69 is the closest verified set'),
  ('prs', 'Silver Sky', 'middle', 'fender', 'Custom Shop 69', true, 'Stock: PRS 635JM singles (early-60s voicing); Custom Shop 69 is the closest verified set'),
  ('prs', 'Silver Sky', 'neck',   'fender', 'Custom Shop 69', true, 'Stock: PRS 635JM singles (early-60s voicing); Custom Shop 69 is the closest verified set'),
  -- Jet budget alnico strat singles: bright low output ~ CS 69.
  ('jet', 'JT Series', 'bridge', 'fender', 'Custom Shop 69', true, 'Stock: Jet OEM alnico singles; Custom Shop 69 is the closest verified bright low-output single'),
  ('jet', 'JT Series', 'middle', 'fender', 'Custom Shop 69', true, 'Stock: Jet OEM alnico singles; Custom Shop 69 is the closest verified bright low-output single'),
  ('jet', 'JT Series', 'neck',   'fender', 'Custom Shop 69', true, 'Stock: Jet OEM alnico singles; Custom Shop 69 is the closest verified bright low-output single'),
  -- Danelectro lipstick tubes: low-output ultra-bright singles ~ CS 69.
  ('danelectro', '''59 / Lipstick', 'bridge', 'fender', 'Custom Shop 69', true, 'Stock: lipstick-tube singles; Custom Shop 69 is the closest verified low-output bright single'),
  ('danelectro', '''59 / Lipstick', 'neck',   'fender', 'Custom Shop 69', true, 'Stock: lipstick-tube singles; Custom Shop 69 is the closest verified low-output bright single'),
  -- Rickenbacker Hi-Gain toasters: bright jangly vintage singles ~ SSL-1.
  ('rickenbacker', '330 / 360', 'bridge', 'seymour-duncan', 'SSL-1 Vintage Staggered', true, 'Stock: Rickenbacker Hi-Gain singles; SSL-1 is the closest verified bright vintage single'),
  ('rickenbacker', '330 / 360', 'neck',   'seymour-duncan', 'SSL-1 Vintage Staggered', true, 'Stock: Rickenbacker Hi-Gain singles; SSL-1 is the closest verified bright vintage single'),

  -- ============================================================
  -- Gibson / Epiphone families
  -- ============================================================
  ('gibson', 'Les Paul', 'bridge', 'gibson', 'Burstbucker Pro', false, 'Stock on Les Paul Standard (Burstbucker Pro bridge)'),
  ('gibson', 'Les Paul', 'neck',   'gibson', 'Burstbucker Pro', false, 'Stock on Les Paul Standard (Burstbucker Pro neck)'),
  ('gibson', 'SG', 'bridge', 'gibson', '490T', false, 'Stock on SG Standard (490T bridge)'),
  ('gibson', 'SG', 'neck',   'gibson', '490R', false, 'Stock on SG Standard (490R neck)'),
  ('gibson', 'Explorer / Flying V', 'bridge', 'gibson', '498T Hot Alnico', false, 'Stock on Gibson Explorer / Flying V (498T bridge)'),
  ('gibson', 'Explorer / Flying V', 'neck',   'gibson', '490R', false, 'Stock on Gibson Explorer / Flying V (490R neck)'),
  ('gibson', 'Les Paul Junior / Special (P-90)', 'bridge', 'gibson', 'P-90', false, 'Stock P-90 (dogear/soapbar) on Junior / Special'),
  ('gibson', 'Les Paul Junior / Special (P-90)', 'neck',   'gibson', 'P-90', false, 'Stock P-90 (dogear/soapbar) on Junior / Special'),
  ('gibson', 'ES-335 / Casino', 'bridge', 'gibson', '57 Classic Plus', true, 'Stock: Calibrated T-Type on current ES-335; 57 Classic Plus is the closest verified bridge'),
  ('gibson', 'ES-335 / Casino', 'neck',   'gibson', '57 Classic', true, 'Stock: Calibrated T-Type on current ES-335; 57 Classic is the closest verified neck'),
  ('gibson', 'Jazz Archtop', 'bridge', 'gibson', '57 Classic', false, 'Stock on ES-175 / L-5 style archtops (57 Classic)'),
  ('gibson', 'Jazz Archtop', 'neck',   'gibson', '57 Classic', false, 'Stock on ES-175 / L-5 style archtops (57 Classic)'),
  -- Firebird mini-humbuckers: bright, clear, low-wind - closest verified voice is TV Jones.
  ('gibson', 'Firebird', 'bridge', 'tv-jones', 'Classic Plus', true, 'Stock: Firebird mini-humbuckers; TV Jones Classic Plus is the closest verified bright clear bridge'),
  ('gibson', 'Firebird', 'neck',   'tv-jones', 'Classic',      true, 'Stock: Firebird mini-humbuckers; TV Jones Classic is the closest verified bright clear neck'),
  -- Epiphone ProBucker 2/3 are Burstbucker 2/3 clones by design.
  ('epiphone', 'Les Paul', 'bridge', 'gibson', 'Burstbucker 3', true, 'Stock: ProBucker 3 bridge, an alnico-2 Burstbucker 3 clone'),
  ('epiphone', 'Les Paul', 'neck',   'gibson', 'Burstbucker 2', true, 'Stock: ProBucker 2 neck, an alnico-2 Burstbucker 2 clone'),

  -- ============================================================
  -- Modern metal / shred families
  -- ============================================================
  ('ltd', 'EC / Metal', 'bridge', 'emg', '81', false, 'Stock on LTD EC-1000 and EMG-equipped LTD models (81 bridge)'),
  ('ltd', 'EC / Metal', 'neck',   'emg', '60', false, 'Stock on LTD EC-1000 (60 neck)'),
  ('esp', 'E-II / Eclipse', 'bridge', 'emg', '57', false, 'Stock on current E-II Eclipse (EMG 57 bridge); older Eclipse ship 81'),
  ('esp', 'E-II / Eclipse', 'neck',   'emg', '66', false, 'Stock on current E-II Eclipse (EMG 66 neck); older Eclipse ship 60'),
  -- Schecter family spans Omen (Diamond passives) to Hellraiser (EMG 81/89).
  ('schecter', 'C-1 / Omen', 'bridge', 'emg', '81', true, 'Stock on C-1 Hellraiser (EMG 81); Omen ships Schecter Diamond passives'),
  ('schecter', 'C-1 / Omen', 'neck',   'emg', '85', true, 'Stock on C-1 Hellraiser is EMG 89R; 85 is the closest verified neck'),
  -- Ibanez Quantum set: hot tight ceramic ~ D Activator; Air Norton is the classic Ibanez neck voice.
  ('ibanez', 'RG / S', 'bridge', 'dimarzio', 'D Activator (DP219)', true, 'Stock: Ibanez Quantum bridge (hot tight ceramic); D Activator is the closest verified DiMarzio'),
  ('ibanez', 'RG / S', 'neck',   'dimarzio', 'Air Norton (DP193)', true, 'Stock: Ibanez Quantum neck; Air Norton is the classic DiMarzio Ibanez neck voice'),
  ('jackson', 'Dinky / Soloist', 'bridge', 'seymour-duncan', 'JB (SH-4)',   false, 'Stock on Jackson Pro/USA Soloist and Dinky (Duncan JB bridge)'),
  ('jackson', 'Dinky / Soloist', 'neck',   'seymour-duncan', 'Jazz (SH-2n)', false, 'Stock on Jackson Pro/USA Soloist and Dinky (Duncan Jazz neck)'),
  ('kramer', 'Baretta / 84', 'bridge', 'seymour-duncan', 'JB (SH-4)', false, 'Stock on Kramer The 84 / Baretta (single Duncan JB bridge)'),
  ('charvel', 'Pro-Mod', 'bridge', 'seymour-duncan', 'Full Shred (SH-10)', false, 'Stock on Pro-Mod DK24 HSS (Duncan Full Shred bridge)'),
  ('charvel', 'Pro-Mod', 'middle', 'seymour-duncan', 'SSL-5 Custom Staggered', true, 'Stock: Duncan Custom Flat SSL-6 singles; SSL-5 is the closest verified hot single'),
  ('charvel', 'Pro-Mod', 'neck',   'seymour-duncan', 'SSL-5 Custom Staggered', true, 'Stock: Duncan Custom Flat SSL-6 singles; SSL-5 is the closest verified hot single'),
  ('music-man', 'Axis / JP', 'bridge', 'dimarzio', 'Crunch Lab (DP228)', false, 'Stock on Music Man JP6/JP models (DiMarzio Crunch Lab bridge)'),
  ('music-man', 'Axis / JP', 'neck',   'dimarzio', 'LiquiFire (DP227)', false, 'Stock on Music Man JP6/JP models (DiMarzio LiquiFire neck)'),
  ('sterling-by-music-man', 'Cutlass / JP', 'bridge', 'dimarzio', 'Crunch Lab (DP228)', true, 'Stock: licensed JP-voiced humbuckers; Crunch Lab is the reference bridge voice'),
  ('sterling-by-music-man', 'Cutlass / JP', 'neck',   'dimarzio', 'LiquiFire (DP227)', true, 'Stock: licensed JP-voiced humbuckers; LiquiFire is the reference neck voice'),
  ('evh', 'Wolfgang', 'bridge', 'seymour-duncan', 'Custom 5 (SH-14)', true, 'Stock: EVH Wolfgang humbuckers (hot alnico, tight); Custom 5 is the closest verified bridge'),
  ('evh', 'Wolfgang', 'neck',   'seymour-duncan', '59 (SH-1n)', true, 'Stock: EVH Wolfgang neck humbucker; Duncan 59 is the closest verified neck'),
  ('strandberg', 'Boden', 'bridge', 'fishman', 'Fluence Modern (bridge)', true, 'Stock on Boden Original/Metal NX (Fluence Modern); Standard ships strandberg MF passives'),
  ('strandberg', 'Boden', 'neck',   'fishman', 'Fluence Modern (neck)',   true, 'Stock on Boden Original/Metal NX (Fluence Modern); Standard ships strandberg MF passives'),
  ('kiesel', 'Aries / Vader', 'bridge', 'seymour-duncan', 'Nazgul (SH-7)',    true, 'Stock: Kiesel Lithium bridge (hot clear passive); Nazgul is the closest verified bridge'),
  ('kiesel', 'Aries / Vader', 'neck',   'seymour-duncan', 'Sentient (SH-15)', true, 'Stock: Kiesel Lithium neck; Sentient is the closest verified moderate-output neck'),
  ('chapman', 'ML / Ghost Fret', 'bridge', 'seymour-duncan', 'Nazgul (SH-7)',    true, 'Stock: Chapman-designed hot humbuckers; Nazgul is the closest verified modern-metal bridge'),
  ('chapman', 'ML / Ghost Fret', 'neck',   'seymour-duncan', 'Sentient (SH-15)', true, 'Stock: Chapman-designed humbuckers; Sentient is the closest verified neck'),
  ('ormsby', 'Hype / Goliath', 'bridge', 'seymour-duncan', 'Nazgul (SH-7)',    true, 'Stock: Ormsby custom-wound hot bridge; Nazgul is the closest verified modern-metal bridge'),
  ('ormsby', 'Hype / Goliath', 'neck',   'seymour-duncan', 'Sentient (SH-15)', true, 'Stock: Ormsby custom-wound neck; Sentient is the closest verified neck'),
  ('mayones', 'Regius / Duvell', 'bridge', 'bare-knuckle', 'Aftermath',  true, 'Frequent factory option on Regius/Duvell (Bare Knuckle); Aftermath is the representative bridge'),
  ('mayones', 'Regius / Duvell', 'neck',   'bare-knuckle', 'Rebel Yell', true, 'Frequent factory option on Regius/Duvell (Bare Knuckle); Rebel Yell is the representative neck'),
  ('solar', 'A-Series', 'bridge', 'seymour-duncan', 'Distortion (SH-6)', true, 'Stock: Duncan Solar high-output ceramic bridge; Duncan Distortion is the closest verified'),
  ('solar', 'A-Series', 'neck',   'seymour-duncan', 'Sentient (SH-15)',  true, 'Stock: Duncan Solar neck; Sentient is the closest verified modern neck'),
  ('dean', 'ML', 'bridge', 'seymour-duncan', 'Distortion (SH-6)', true, 'Stock: Dean DMT/Dimebucker-style hot ceramic bridge; Duncan Distortion is the closest verified'),
  ('dean', 'ML', 'neck',   'seymour-duncan', '59 (SH-1n)',        true, 'Stock: Dean DMT neck humbucker; Duncan 59 is the closest verified neck'),
  ('bc-rich', 'Warlock / Mockingbird', 'bridge', 'seymour-duncan', 'Distortion (SH-6)', true, 'Stock: B.C. Rich BDSM hot ceramic bridge; Duncan Distortion is the closest verified'),
  ('bc-rich', 'Warlock / Mockingbird', 'neck',   'seymour-duncan', '59 (SH-1n)',        true, 'Stock: B.C. Rich BDSM neck; Duncan 59 is the closest verified neck'),
  ('washburn', 'Nuno / Dime', 'bridge', 'seymour-duncan', 'Distortion (SH-6)', true, 'Stock on N4: Bill Lawrence L-500 hot blade bridge; Duncan Distortion is the closest verified'),
  ('washburn', 'Nuno / Dime', 'neck',   'seymour-duncan', '59 (SH-1n)',        false, 'Stock on Washburn N4 (Duncan 59 neck)'),

  -- ============================================================
  -- PAF-style / classic humbucker families
  -- ============================================================
  ('prs', 'SE Custom 24', 'bridge', 'seymour-duncan', 'Custom 5 (SH-14)', true, 'Stock: PRS 85/15 S humbuckers; Custom 5 is the closest verified balanced alnico-5 bridge'),
  ('prs', 'SE Custom 24', 'neck',   'seymour-duncan', '59 (SH-1n)',       true, 'Stock: PRS 85/15 S neck; Duncan 59 is the closest verified vintage-clarity neck'),
  ('aria', 'Pro II', 'bridge', 'seymour-duncan', '59 (SH-1b)', true, 'Stock: Aria OEM PAF-style humbuckers; Duncan 59 set is the closest verified reference'),
  ('aria', 'Pro II', 'neck',   'seymour-duncan', '59 (SH-1n)', true, 'Stock: Aria OEM PAF-style humbuckers; Duncan 59 set is the closest verified reference'),
  ('fgn', 'Neo Classic / Boundary', 'bridge', 'seymour-duncan', '59 (SH-1b)', true, 'Stock: FGN OEM vintage-modern humbuckers; Duncan 59 set is the closest verified reference'),
  ('fgn', 'Neo Classic / Boundary', 'neck',   'seymour-duncan', '59 (SH-1n)', true, 'Stock: FGN OEM vintage-modern humbuckers; Duncan 59 set is the closest verified reference'),
  ('harley-benton', 'Electric Series', 'bridge', 'seymour-duncan', '59 (SH-1b)', true, 'Stock: Roswell HAF alnico-5 PAF clones; Duncan 59 set is the closest verified reference'),
  ('harley-benton', 'Electric Series', 'neck',   'seymour-duncan', '59 (SH-1n)', true, 'Stock: Roswell HAF alnico-5 PAF clones; Duncan 59 set is the closest verified reference'),
  ('reverend', 'Set-Neck / Signature', 'bridge', 'seymour-duncan', '59 (SH-1b)', true, 'Stock: Reverend HA5 alnico-5 humbuckers; Duncan 59 set is the closest verified reference'),
  ('reverend', 'Set-Neck / Signature', 'neck',   'seymour-duncan', '59 (SH-1n)', true, 'Stock: Reverend HA5 alnico-5 humbuckers; Duncan 59 set is the closest verified reference'),
  ('d-angelico', 'Excel / Premier', 'bridge', 'seymour-duncan', '59 (SH-1b)', true, 'Stock: Duncan 59s on Excel line; Premier ships D''Angelico OEM humbuckers'),
  ('d-angelico', 'Excel / Premier', 'neck',   'seymour-duncan', '59 (SH-1n)', true, 'Stock: Duncan 59s on Excel line; Premier ships D''Angelico OEM humbuckers'),
  ('godin', '5th Avenue / Session', 'bridge', 'seymour-duncan', '59 (SH-1b)', true, 'Stock: Godin custom humbuckers; Duncan 59 set is the closest verified balanced reference'),
  ('godin', '5th Avenue / Session', 'neck',   'seymour-duncan', '59 (SH-1n)', true, 'Stock: Godin custom humbuckers; Duncan 59 set is the closest verified balanced reference'),
  ('peavey', 'HP / Raptor', 'bridge', 'seymour-duncan', 'Custom (SH-5)', true, 'Stock: Peavey OEM medium-hot humbuckers; Duncan Custom is the closest verified bridge'),
  ('peavey', 'HP / Raptor', 'neck',   'seymour-duncan', '59 (SH-1n)',    true, 'Stock: Peavey OEM neck humbucker; Duncan 59 is the closest verified neck'),
  ('balaguer', 'Growler / Espada', 'bridge', 'seymour-duncan', 'Custom (SH-5)', true, 'Stock: Balaguer OEM hot humbuckers; Duncan Custom is the closest verified bridge'),
  ('balaguer', 'Growler / Espada', 'neck',   'seymour-duncan', '59 (SH-1n)',    true, 'Stock: Balaguer OEM neck humbucker; Duncan 59 is the closest verified neck'),
  ('cort', 'G / KX Series', 'bridge', 'seymour-duncan', 'Custom (SH-5)', true, 'Stock: Cort Voiced Tone / EMG-designed humbuckers; Duncan Custom is the closest verified bridge'),
  ('cort', 'G / KX Series', 'neck',   'seymour-duncan', '59 (SH-1n)',    true, 'Stock: Cort Voiced Tone neck; Duncan 59 is the closest verified neck'),
  ('hagstrom', 'Fantomen / Swede', 'bridge', 'gibson', '57 Classic Plus', true, 'Stock: Hagstrom Custom 58 humbuckers (dark warm); 57 Classic Plus is the closest verified bridge'),
  ('hagstrom', 'Fantomen / Swede', 'neck',   'gibson', '57 Classic',      true, 'Stock: Hagstrom Custom 58 humbuckers; 57 Classic is the closest verified neck'),
  ('vintage', 'V100 / ReIssued', 'bridge', 'gibson', '57 Classic Plus', true, 'Stock: Wilkinson WVC alnico PAF clones; 57 Classic Plus is the closest verified bridge'),
  ('vintage', 'V100 / ReIssued', 'neck',   'gibson', '57 Classic',      true, 'Stock: Wilkinson WVC alnico PAF clones; 57 Classic is the closest verified neck'),
  ('sire', 'Larry Carlton', 'bridge', 'gibson', '57 Classic', true, 'Stock: Sire OEM 335-style humbuckers; 57 Classic is the closest verified reference'),
  ('sire', 'Larry Carlton', 'neck',   'gibson', '57 Classic', true, 'Stock: Sire OEM 335-style humbuckers; 57 Classic is the closest verified reference'),
  ('ibanez', 'Artcore / AR', 'bridge', 'gibson', '57 Classic', true, 'Stock: Ibanez Classic Elite / ACH warm humbuckers; 57 Classic is the closest verified reference'),
  ('ibanez', 'Artcore / AR', 'neck',   'gibson', '57 Classic', true, 'Stock: Ibanez Classic Elite / ACH warm humbuckers; 57 Classic is the closest verified reference'),
  ('guild', 'Polara / Starfire', 'bridge', 'seymour-duncan', 'Seth Lover (SH-55)', true, 'Stock: Guild HB-1 low-wind PAF; Seth Lover is the closest verified reference'),
  ('guild', 'Polara / Starfire', 'neck',   'seymour-duncan', 'Seth Lover (SH-55)', true, 'Stock: Guild HB-1 low-wind PAF; Seth Lover is the closest verified reference'),
  ('eastman', 'Romeo / SB', 'bridge', 'lindy-fralin', 'Pure PAF', true, 'Stock: Lollar Imperial humbuckers; Fralin Pure PAF is the closest verified boutique PAF'),
  ('eastman', 'Romeo / SB', 'neck',   'lindy-fralin', 'Pure PAF', true, 'Stock: Lollar Imperial humbuckers; Fralin Pure PAF is the closest verified boutique PAF'),

  -- ============================================================
  -- Retro / Filter'Tron-voiced families
  -- ============================================================
  ('gretsch', 'Electromatic', 'bridge', 'tv-jones', 'Classic', true, 'Stock: Black Top Filter''Tron; TV Jones Classic is the reference Filter''Tron voice'),
  ('gretsch', 'Electromatic', 'neck',   'tv-jones', 'Classic', true, 'Stock: Black Top Filter''Tron; TV Jones Classic is the reference Filter''Tron voice'),
  ('eastwood', 'Retro Series', 'bridge', 'tv-jones', 'Starwood', true, 'Stock: Eastwood vintage-voiced OEM humbuckers; TV Jones Starwood is the closest verified retro voice'),
  ('eastwood', 'Retro Series', 'neck',   'tv-jones', 'Starwood', true, 'Stock: Eastwood vintage-voiced OEM humbuckers; TV Jones Starwood is the closest verified retro voice'),
  ('duesenberg', 'Julia / Starplayer', 'bridge', 'seymour-duncan', 'Seth Lover (SH-55)', true, 'Stock: Duesenberg GrandVintage humbucker; Seth Lover is the closest verified PAF bridge'),
  ('duesenberg', 'Julia / Starplayer', 'neck',   'gibson', 'P-94', true, 'Stock: Duesenberg Domino P-90 neck; Gibson P-94 is the closest verified humbucker-size P-90'),

  -- ============================================================
  -- HSS versatile families
  -- ============================================================
  ('suhr', 'Classic S / Modern', 'bridge', 'seymour-duncan', 'Custom 5 (SH-14)', true, 'Stock: Suhr SSV/SSH+ bridge humbucker; Custom 5 is the closest verified alnico-5 bridge'),
  ('suhr', 'Classic S / Modern', 'middle', 'lindy-fralin', 'Vintage Hot Strat', true, 'Stock: Suhr V60LP singles; Fralin Vintage Hot is the closest verified boutique 60s single'),
  ('suhr', 'Classic S / Modern', 'neck',   'lindy-fralin', 'Vintage Hot Strat', true, 'Stock: Suhr V60LP singles; Fralin Vintage Hot is the closest verified boutique 60s single'),
  ('ibanez', 'AZ', 'bridge', 'seymour-duncan', '59 (SH-1b)', true, 'Stock: Duncan Hyperion bridge (moderate alnico); Duncan 59 is the closest verified bridge'),
  ('ibanez', 'AZ', 'middle', 'seymour-duncan', 'SSL-1 Vintage Staggered', true, 'Stock: Duncan Hyperion singles; SSL-1 is the closest verified vintage single'),
  ('ibanez', 'AZ', 'neck',   'seymour-duncan', 'SSL-1 Vintage Staggered', true, 'Stock: Duncan Hyperion singles; SSL-1 is the closest verified vintage single'),
  ('schecter', 'PT / Traditional', 'bridge', 'seymour-duncan', '59 (SH-1b)', true, 'Stock: Schecter Diamond vintage-voiced bridge; Duncan 59 is the closest verified'),
  ('schecter', 'PT / Traditional', 'middle', 'seymour-duncan', 'SSL-1 Vintage Staggered', true, 'Stock: Schecter Diamond singles; SSL-1 is the closest verified vintage single'),
  ('schecter', 'PT / Traditional', 'neck',   'seymour-duncan', 'SSL-1 Vintage Staggered', true, 'Stock: Schecter Diamond singles; SSL-1 is the closest verified vintage single'),
  ('yamaha', 'Pacifica / Revstar', 'bridge', 'seymour-duncan', '59 (SH-1b)', true, 'Stock: Yamaha alnico bridge humbucker (Pacifica 112V); Duncan 59 is the closest verified'),
  ('yamaha', 'Pacifica / Revstar', 'middle', 'seymour-duncan', 'SSL-1 Vintage Staggered', true, 'Stock: Yamaha alnico singles; SSL-1 is the closest verified vintage single'),
  ('yamaha', 'Pacifica / Revstar', 'neck',   'seymour-duncan', 'SSL-1 Vintage Staggered', true, 'Stock: Yamaha alnico singles; SSL-1 is the closest verified vintage single')
) as v(guitar_slug, guitar_model, position, pickup_slug, pickup_model, equiv, note)
join public.equipment_manufacturers gm on gm.slug = v.guitar_slug
join public.guitar_models g
  on g.manufacturer_id = gm.id
 and g.model_name = v.guitar_model
 and g.instrument_type = 'guitar'
join public.equipment_manufacturers pm on pm.slug = v.pickup_slug
join public.pickup_models p
  on p.manufacturer_id = pm.id
 and p.model_name = v.pickup_model
on conflict (guitar_model_id, pickup_position, is_stock) do update set
  pickup_model_id = excluded.pickup_model_id,
  metadata = excluded.metadata,
  is_active = true;

-- ============================================================
-- Post-conditions
-- ============================================================
do $$
declare
  seeded int;
  fams int;
  missing int;
  sample text;
begin
  -- Every VALUES row must have resolved both its family and its pickup:
  -- 42 hh x2 + 5 hss x3 + 5 sss x3 + 4 ss x2 + 1 p90 x2 + 1 hs x2 + 1 h x1 = 127.
  select count(*) into seeded
  from public.guitar_model_pickups
  where metadata->>'source' = 'stock_pickup_seed_v1';
  if seeded <> 127 then
    raise exception 'POST-CONDITION FAILED: expected 127 seeded stock pickup rows, got % (a family or pickup name failed to join)', seeded;
  end if;

  select count(distinct guitar_model_id) into fams
  from public.guitar_model_pickups
  where metadata->>'source' = 'stock_pickup_seed_v1';
  if fams <> 59 then
    raise exception 'POST-CONDITION FAILED: expected 59 guitar families covered, got %', fams;
  end if;

  -- Every verified electric-guitar family row must now have a bridge pickup.
  select count(*) into missing
  from public.guitar_models g
  where g.is_active
    and g.instrument_type = 'guitar'
    and g.metadata->>'verified' = 'true'
    and not exists (
      select 1 from public.guitar_model_pickups gp
      where gp.guitar_model_id = g.id
        and gp.pickup_position = 'bridge'
        and gp.is_active
        and gp.pickup_model_id is not null
    );
  if missing > 0 then
    raise exception 'POST-CONDITION FAILED: % verified guitar families still lack a bridge stock pickup', missing;
  end if;

  -- Spot check: Gibson Les Paul family resolves to Burstbucker Pro at the bridge.
  select p.model_name into sample
  from public.guitar_model_pickups gp
  join public.guitar_models g on g.id = gp.guitar_model_id
  join public.equipment_manufacturers gm on gm.id = g.manufacturer_id
  join public.pickup_models p on p.id = gp.pickup_model_id
  where gm.slug = 'gibson' and g.model_name = 'Les Paul' and g.instrument_type = 'guitar'
    and gp.pickup_position = 'bridge' and gp.is_stock;
  if sample is distinct from 'Burstbucker Pro' then
    raise exception 'POST-CONDITION FAILED: Gibson Les Paul bridge stock pickup is %, expected Burstbucker Pro', coalesce(sample, '(none)');
  end if;

  -- Spot check: LTD EC / Metal family resolves to EMG 81 at the bridge.
  select p.model_name into sample
  from public.guitar_model_pickups gp
  join public.guitar_models g on g.id = gp.guitar_model_id
  join public.equipment_manufacturers gm on gm.id = g.manufacturer_id
  join public.pickup_models p on p.id = gp.pickup_model_id
  where gm.slug = 'ltd' and g.model_name = 'EC / Metal' and g.instrument_type = 'guitar'
    and gp.pickup_position = 'bridge' and gp.is_stock;
  if sample is distinct from '81' then
    raise exception 'POST-CONDITION FAILED: LTD EC / Metal bridge stock pickup is %, expected EMG 81', coalesce(sample, '(none)');
  end if;

  -- Spot check: Fender Stratocaster family carries all three positions.
  select count(*) into seeded
  from public.guitar_model_pickups gp
  join public.guitar_models g on g.id = gp.guitar_model_id
  join public.equipment_manufacturers gm on gm.id = g.manufacturer_id
  where gm.slug = 'fender' and g.model_name = 'Stratocaster' and g.instrument_type = 'guitar'
    and gp.is_stock and gp.is_active;
  if seeded <> 3 then
    raise exception 'POST-CONDITION FAILED: Fender Stratocaster has % stock pickup positions, expected 3', seeded;
  end if;
end $$;

commit;
