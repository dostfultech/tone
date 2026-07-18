# Security

## Authentication

Supabase Auth is the identity provider. SSR clients use cookies and `auth.getUser()`; middleware refreshes sessions and redirects unauthenticated `/app`, `/library`, `/account`, and `/checkout` requests. Auth callbacks exchange codes server-side and constrain redirects to safe app paths.

## Authorization

- RLS is enabled for public-schema tables in migrations.
- User data policies compare `auth.uid()` with owner IDs.
- Public catalogs expose active rows; public tones expose approved/public rows.
- Admin ingestion checks `profiles.role = 'admin'` or an exact worker secret header.
- Subscription entitlements and quotas are checked server-side, not trusted from the client.
- Account deletion uses the admin Auth API only after current-user verification and audit logging.

## Supabase clients

- Browser/SSR: anon key, constrained by RLS.
- Admin: service role, no persisted session/refresh, server-only.
- Configuration code checks project refs across URL, anon JWT, service JWT, and optional expected ref to prevent cross-project key mistakes.

## Secrets

Never expose service-role, Dodo API/webhook, OpenAI, or worker secrets through `NEXT_PUBLIC_*`, logs, response bodies, source maps, or committed env files. Rotate a secret immediately if exposed.

## Input and webhook safety

- v1 tone and ingestion requests have explicit validators and bounded enum/number handling.
- Activity ingestion caps event count, text lengths, metadata keys/depth/arrays, and normalizes paths/timestamps.
- Dodo webhook processing must verify `DODO_PAYMENTS_WEBHOOK_KEY` before state changes.
- Search queries are length-limited and `%`/`_` are escaped before `ilike` filters.

## RLS review rules

- Keep `USING` and `WITH CHECK` ownership predicates on updates.
- Do not use user-editable metadata for authorization.
- Treat `SECURITY DEFINER` functions as privileged APIs: fixed `search_path`, internal auth checks, and restricted execute grants.
- Remember Data API grants and RLS are separate; validate both.
- Views must be security-invoker or withheld from exposed roles.

## Data and privacy

Activity events may contain IP, user agent, path, and metadata. Keep metadata allowlisted/minimal, establish retention before broad analytics use, and avoid secrets or sensitive free text. Account deletion cascades most owned records through foreign keys; verify external Dodo obligations and any set-null audit/history rows as part of privacy operations.

## Security validation

Before release, run Supabase security/performance advisors, test owner isolation with two users, test anonymous catalog-only access, test admin denial, verify webhook rejection with bad signatures, and inspect the browser bundle/environment for secrets.
