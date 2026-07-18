# Search Engine

Search is implemented by focused paths, not one standalone service: canonical guitar/amp search in `equipment-service.ts`, pedal/MultiFX route queries, song/community helpers, and compatibility iTunes search with a bounded ten-minute process cache.

Equipment `search_text` combines normalized identity, series, description, aliases, genres, tone traits, and type metadata. Full-text/trigram indexes produce candidates; application ranking favors exact, prefix, contains, popularity, and sort order. Aliases belong in search terms, not duplicate rows.

`SearchableGearDropdown` requests a common `GearSearchItem` shape. Search query length is capped at 80; pedal/MultiFX handlers escape LIKE wildcards and cap results at 200. Empty queries return ordered active rows.

Known gaps: no relevance corpus/latency budget, typo tolerance is not formally tested, pedal/MultiFX filtering is `ilike`-based, and legacy catch-all pedal/MultiFX catalog paths still return empty arrays.
