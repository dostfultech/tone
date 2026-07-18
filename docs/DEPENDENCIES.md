# Dependencies

Versions below are declared ranges in `package.json`; `package-lock.json` is the exact install source.

## Runtime

| Package | Declared version | Purpose |
|---|---:|---|
| `next` | `^15.1.0` | App Router framework, server rendering and route handlers. |
| `react`, `react-dom` | `^19.0.0` | UI runtime. |
| `@supabase/supabase-js` | `^2.45.4` | Postgres/Auth API client. |
| `@supabase/ssr` | `^0.7.0` | Cookie-aware browser/server auth clients. |
| `dodopayments` | `^2.36.0` | Dodo server API/client portal. |
| `@dodopayments/nextjs` | `^0.3.6` | Dodo Next.js integration support. |
| `openai` | `^4.72.0` | Admin ingestion and approved provider paths. |
| `framer-motion` | `^11.11.17` | UI animation. |
| `lucide-react` | `^0.468.0` | Icons. |
| `clsx`, `tailwind-merge` | `^2.1.1`, `^2.5.4` | Conditional and conflict-safe class composition. |
| `@vercel/analytics`, `@vercel/speed-insights` | `^1.5.0`, `^2.0.0` | Production web analytics/performance. |
| `posthog-js` | `^1.181.0` | Optional client product analytics. |
| `@next/third-parties` | `^16.2.10` | Next third-party integration helpers. Note major differs from Next 15; keep build-tested. |

## Development

| Package | Declared version | Purpose |
|---|---:|---|
| `typescript` | `^5.7.2` | Strict typechecking and isolated test compilation. |
| `eslint`, `eslint-config-next` | `^9.16.0`, `^15.1.0` | Static analysis; current `next lint` script compatibility should be verified. |
| `tailwindcss` | `^3.4.16` | Utility CSS. |
| `postcss`, `autoprefixer` | `^8.4.49`, `^10.4.20` | CSS processing. |
| `@types/node`, `@types/react`, `@types/react-dom` | `^22.10.2`, `^19.0.1`, `^19.0.2` | Type declarations. |

## Platform dependencies

- Node engine: `24.x`.
- Supabase Postgres: major version 15 with `pgcrypto` and `pg_trgm`.
- Vercel: deployment/runtime host.
- Dodo Payments: billing provider.
- iTunes Search API: compatibility music search.

Do not upgrade dependencies casually. Review release notes, preserve the lockfile, run build/tests, and update this file when declared versions change.
