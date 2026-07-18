# Subscriptions

`beginner` provides 20 monthly adaptations, 15 saved tones, and 10 gear presets. `expert` uses `null` for unlimited limits. Development-only `TEST_ACCESS_EMAILS` grants Expert-style access and is disabled in production. Users without a subscription get three manual-generation adaptations; adapt-to-my-gear and saved-tone re-adaptation are paid workflows.

Pricing calls Dodo checkout, the verified webhook synchronizes `subscriptions`, and Account resolves a Dodo customer portal. Product IDs are configured by plan and monthly/annual interval.

Eligibility is checked server-side. Successful v1 adaptation persists a result before idempotent usage recording keyed by `tone_result_id`. Beginner increments `monthly_usage`; free usage updates profile counters and emits a `plan: free` event; Expert consumes no quota. Never trust client plan or count values.
