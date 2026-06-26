# Tonefex

Tonefex is a paid-only guitar and bass tone-matching SaaS built with Next.js, Supabase, Dodo Payments, and OpenAI.

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

- Tonefex brand, logo, metadata, and app copy
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
6. In Supabase Auth, enable Email auth and configure confirmation/reset redirects.
7. Optionally enable the Google provider and set `NEXT_PUBLIC_GOOGLE_AUTH_ENABLED=true`.
8. Apply the SQL files in `supabase/migrations` to your Supabase project.
9. Run the app locally.

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

Auth configuration:

- Enable Email provider for sign-up and password login.
- Set redirect URLs for:
	- `http://localhost:3000/auth/callback`
	- `http://localhost:3000/reset-password`
	- your production equivalents
- If you want Google sign-in, enable the Google provider in Supabase and set `NEXT_PUBLIC_GOOGLE_AUTH_ENABLED=true` in your environment.

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

## Bulk Importer

You can bulk import first-party tone profiles into the current Supabase schema with:

```bash
npm run import:tones -- --file ./path/to/profiles.json --dry-run
npm run import:tones -- --file ./path/to/profiles.json
```

The importer reads `NEXT_PUBLIC_SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` from `.env.local` or `.env`.

Supported input formats:

- JSON: either an array of profile objects or an object with a `profiles` array
- CSV: one row per profile, with complex fields encoded as JSON strings

Recommended profile fields:

- `artistName`, `artistSlug`, `artistCountry`, `artistExternalIds`
- `songTitle`, `songSlug`, `album`, `releaseYear`, `durationSeconds`, `songExternalIds`
- `mode`, `partType`, `partLabel`, `toneType`
- `originalGuitar`, `originalAmp`, `originalCab`, `originalPickup`
- `originalSettings`, `originalEffects`, `adaptationNotes`, `playingNotes`
- `confidence`, `verificationStatus`, `sourceSummary`, `isPublic`, `sources`

Example JSON record:

```json
{
	"artistName": "Pink Floyd",
	"songTitle": "Comfortably Numb",
	"mode": "guitar",
	"partType": "solo",
	"partLabel": "second solo",
	"toneType": "distorted",
	"originalGuitar": "Strat-style single-coil guitar",
	"originalAmp": "Hiwatt-style clean platform with sustain pedals",
	"originalSettings": {
		"gain": 6,
		"bass": 4,
		"mids": 6,
		"treble": 6
	},
	"originalEffects": [
		{
			"type": "delay",
			"name": "Tape-style delay",
			"placement": "post",
			"settings": {
				"mix": 3,
				"time": 4
			}
		}
	],
	"adaptationNotes": ["Prioritize sustain before adding gain."],
	"playingNotes": ["Use wide, controlled vibrato."],
	"confidence": 78,
	"verificationStatus": "needs_review",
	"sources": [
		{
			"sourceType": "rig_rundown",
			"title": "Example rundown",
			"url": "https://example.com",
			"credibility": 70
		}
	]
}
```

The importer upserts artists, songs, and tone profiles, then replaces related effects and sources so repeated imports stay deterministic.

## Local Paid Access

Because the product is paid-only, local testing is easiest with:

```env
TEST_ACCESS_EMAILS=you@example.com
```

After signing in with that email, the app bypasses subscription checks and grants Expert-style access.
