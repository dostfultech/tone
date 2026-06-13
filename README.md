# FretPilot

FretPilot is a paid-only guitar and bass tone-matching SaaS built with Next.js, Supabase, Dodo Payments, and OpenAI.

The app lets users choose a song, artist, part, guitar/bass, amp, pickups, pedals, or multi-FX unit, then generates a structured tone recipe with amp settings, effects order, pickup advice, confidence, and playing notes.

## Stack

- Next.js App Router
- React
- Tailwind CSS
- Supabase Auth, Postgres, RLS
- Dodo Payments subscriptions
- OpenAI structured JSON generation
- Vercel-ready deployment

## Implemented

- FretPilot brand, logo, metadata, and app copy
- Supabase SSR auth clients and middleware
- Paid-only app gate with `TEST_ACCESS_EMAILS` bypass for local testing
- Supabase migrations for profiles, plans, subscriptions, usage, tones, gear, song-tone profiles, reviews, feedback, and audit logs
- RLS policies for user-owned data and public approved catalog/review reads
- Dodo checkout, customer portal, and webhook routes
- OpenAI tone generation with deterministic fallback when no API key is configured
- Beginner plan usage enforcement
- Supabase-backed saved tones, gear presets, reviews, feedback, and gear lookup
- Live song autocomplete through the iTunes Search API with local fallback
- Researched initial gear catalog seed with source URLs
- Phase 1 song-tone profile database with starter profiles, original settings, effect chains, source records, missing-song requests, and community submissions

## Required Setup

1. Copy `.env.example` to `.env.local`.
2. Paste your Supabase keys.
3. Paste your Dodo Payments keys and product IDs.
4. Paste your OpenAI API key.
5. Add your test email to `TEST_ACCESS_EMAILS`.
6. Apply the SQL files in `supabase/migrations` to your Supabase project.
7. Run the app locally.

```bash
npm install --strict-ssl=false
npm run dev
```

Open `http://localhost:3000`.

## Vercel Deployment

The app includes Vercel deployment configuration in `vercel.json`, Node.js `20.x` pinning, and production URL handling for Vercel domains. Follow the full checklist in `docs/vercel-deployment.md`.

## Supabase

Apply migrations in order:

- `supabase/migrations/202606120001_initial_schema.sql`
- `supabase/migrations/202606120002_seed_gear_catalog.sql`
- `supabase/migrations/202606120003_song_tone_schema.sql`
- `supabase/migrations/202606120004_seed_song_tone_profiles.sql`

If you install the Supabase CLI later, use it to link your project and push migrations. Otherwise, paste the SQL into the Supabase SQL editor.

## Dodo Payments

Create four subscription products:

- Beginner monthly
- Beginner annual
- Expert monthly
- Expert annual

Add the product IDs to `.env.local`. Configure a webhook pointing to:

```text
https://your-domain.com/api/webhook/dodo-payments
```

For local webhook testing, expose localhost with a tunnel and use that URL in the Dodo dashboard.

## OpenAI

Default model:

```env
OPENAI_MODEL=gpt-4.1-nano
```

Change this later to a stronger model if tone quality needs improvement.

## Song Search

Song autocomplete uses the public iTunes Search API with no API key. Set `MUSIC_SEARCH_COUNTRY` to the two-letter storefront country you want to search, such as `IN`, `US`, or `GB`. Set `MUSIC_SEARCH_RESULT_LIMIT` to control how many results appear in the dropdown; the app clamps this between 10 and 50 and defaults to 30.

## Song-Tone Profiles

Phase 1 adds structured song-tone tables: `artists`, `songs`, `song_tone_profiles`, `tone_profile_effects`, `tone_profile_sources`, `song_requests`, and `community_submissions`.

The matcher first searches Supabase for a profile matching song, artist, instrument mode, part type, and tone type. If none exists, it queues a `song_requests` row when Supabase is configured and falls back to cautious AI/deterministic adaptation. Seeded profiles are marked `starter_estimate` until you verify them against reliable rig sources or approve community submissions.

## Local Paid Access

Because the product is paid-only, local testing is easiest with:

```env
TEST_ACCESS_EMAILS=you@example.com
```

After signing in with that email, the app bypasses subscription checks and grants Expert-style access.
