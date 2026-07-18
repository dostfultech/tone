# Gear Catalog

## Ownership

`public.equipment` is the single master source for `electric_guitar`, `bass_guitar`, `guitar_amp`, and `bass_amp`. Do not split, rename, drop, recreate, or replace it. Pedals and MultiFX remain in their normalized catalogs: `pedal_brands` + `pedal_models` and `multifx_brands` + `multifx_models`.

## Contract and search

All rows contain brand/model/series/display name/description, popularity, search terms/text, status/order, genres, and tone characteristics. Guitar rows require body/frets/scale/bridge/pickup/output metadata; amp rows require amp type/technology/watts/channels/gain range. Uniqueness is `(equipment_type, brand, model)`.

`lib/equipment-service.ts` maps UI guitar/amp filters to equipment enums, retrieves indexed candidates, and ranks exact, prefix, and contains matches with popularity/order tie-breakers. The same service now also powers pedal and Multi-FX search so UI selectors and legacy compatibility endpoints no longer diverge.

- `/api/search/guitars`, `/api/search/amps` -> `equipment`.
- `/api/search/pedals`, `/api/equipment/search?type=pedal`, `/api/pedals/catalog` -> `pedal_models` + `pedal_brands`.
- `/api/search/multifx`, `/api/equipment/search?type=multifx`, `/api/multi-fx/catalog` -> `multifx_models` + `multifx_brands`.

## Expansion

Verify every production model, reject duplicates, fill model-specific metadata, put aliases in `search_terms` or pedal/Multi-FX `tags`, use conflict-safe migrations, and run `node scripts/validate-equipment-catalog.mjs` for the master `equipment` table. Repository validation currently reports 385 seed rows (165 electric guitars, 69 bass guitars, 107 guitar amps, 44 bass amps); this is not a live database count.

The current normalized pedal/Multi-FX migration adds 329 real pedal models and 92 real Multi-FX units, while deleting rows that match the earlier synthetic placeholder naming patterns.

Detailed rule behavior still comes from normalized gear profile tables. Do not assume an `equipment` row alone supplies all adaptation deltas.
