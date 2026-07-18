# Supabase

Supabase provides Postgres 15, Auth, RLS, and the Data API. `supabase/config.toml` exposes `public` and identifies the local project as `fretpilot`; do not infer the live ref from this.

- `browser.ts`: anon browser client.
- `server.ts`: anon SSR cookie client.
- `admin.ts`: server-only service-role client.
- `config.ts`: env aliases and project-ref mismatch detection.

Timestamped migrations are authoritative for tables, extensions, functions, triggers, indexes, RLS, grants, and seeds. Add new migrations rather than rewriting deployed history. Public catalogs read active rows, user data is owner-scoped, and cache/rule/ingestion operations are privileged.

No application Storage bucket or Realtime subscription exists in the inspected repository. Before release, compare migration history, run advisors, test anon/user/admin/service access, inspect search plans/counts, and verify no service key reaches the client.
