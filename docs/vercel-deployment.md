# Vercel Deployment Guide

## 1. Prepare the Repository

This project is configured for Vercel with:

- `vercel.json` using the Next.js framework, `npm ci`, and `npm run build`
- Node.js pinned to `20.x` through `package.json` and `.nvmrc`
- Server-side URL fallback for Vercel system URLs in `lib/env.ts`
- A 60 second max duration for the OpenAI-backed API route

Push the project to GitHub before importing it into Vercel.

## 2. Create the Vercel Project

1. Open Vercel.
2. Click **Add New** > **Project**.
3. Import your GitHub repository.
4. Keep **Framework Preset** as **Next.js**.
5. Confirm these settings:
   - Install Command: `npm ci`
   - Build Command: `npm run build`
   - Output Directory: default

## 3. Add Vercel Environment Variables

Add these in **Project Settings** > **Environment Variables** for Production and Preview as needed.

```env
NEXT_PUBLIC_SITE_URL=https://your-domain.com

NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
NEXT_PUBLIC_GOOGLE_AUTH_ENABLED=false

TEST_ACCESS_EMAILS=your-test-email@example.com

DODO_PAYMENTS_API_KEY=
DODO_PAYMENTS_WEBHOOK_KEY=
DODO_PAYMENTS_ENVIRONMENT=test_mode
DODO_PAYMENTS_RETURN_URL=https://your-domain.com/checkout/success
DODO_BEGINNER_MONTHLY_PRODUCT_ID=
DODO_BEGINNER_ANNUAL_PRODUCT_ID=
DODO_EXPERT_MONTHLY_PRODUCT_ID=
DODO_EXPERT_ANNUAL_PRODUCT_ID=

OPENAI_API_KEY=
OPENAI_MODEL=gpt-4.1-nano

MUSIC_SEARCH_COUNTRY=IN
MUSIC_SEARCH_RESULT_LIMIT=30
MUSIC_SEARCH_ALLOW_INSECURE_TLS=false

NEXT_PUBLIC_POSTHOG_KEY=
NEXT_PUBLIC_POSTHOG_HOST=
```

Do not expose `SUPABASE_SERVICE_ROLE_KEY`, `DODO_PAYMENTS_API_KEY`, `DODO_PAYMENTS_WEBHOOK_KEY`, or `OPENAI_API_KEY` with a `NEXT_PUBLIC_` prefix.

## 4. Configure Supabase

1. Apply all SQL files in `supabase/migrations` to your Supabase project.
2. In Supabase Auth URL configuration, set:
   - Site URL: `https://your-domain.com`
   - Redirect URLs:
     - `https://your-domain.com/auth/callback`
     - `https://*.vercel.app/auth/callback` for preview deployments
     - `http://localhost:3000/auth/callback` for local testing
3. Keep RLS enabled.
4. To use Google sign-in, enable Google under Supabase Auth providers, add your Google OAuth client ID and secret, and then set `NEXT_PUBLIC_GOOGLE_AUTH_ENABLED=true` in Vercel.

## 5. Configure Dodo Payments

1. Create four subscription products:
   - Beginner monthly
   - Beginner annual
   - Expert monthly
   - Expert annual
2. Paste their product IDs into Vercel environment variables.
3. Add the webhook endpoint in Dodo:

```text
https://your-domain.com/api/webhook/dodo-payments
```

4. Keep `DODO_PAYMENTS_ENVIRONMENT=test_mode` until checkout, webhook, and subscription access are verified.
5. When ready for real payments, switch to live Dodo keys/product IDs and set:

```env
DODO_PAYMENTS_ENVIRONMENT=live_mode
```

## 6. Deploy and Verify

1. Click **Deploy** in Vercel.
2. Open the deployed URL.
3. Test these flows:
   - Home page loads cleanly.
   - Sign up and login work.
   - Your `TEST_ACCESS_EMAILS` account can open `/app`.
   - Song search returns results.
   - Tone adaptation returns output.
   - Save tone works.
   - Checkout opens a Dodo payment session.
   - Dodo webhook updates the Supabase subscription row.

After verification, remove or narrow `TEST_ACCESS_EMAILS` before public launch.
