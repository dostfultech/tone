# Authentication

Supabase Auth is used through browser and cookie-aware SSR clients. Middleware calls `auth.getUser()` and protects `/app`, `/library`, `/account`, and `/checkout`. `/auth/callback` exchanges auth codes and constrains the destination. A database trigger creates `profiles` rows for new auth users.

Authorization layers are session identity, RLS ownership, subscription/free entitlement, admin role or worker secret, and finally service-role access for privileged operations. `profiles.role`, not editable user metadata, grants admin access.

Configure local/preview/production callback and reset URLs. Runtime configuration rejects detectable cross-project URL/key mismatches. Test two-user isolation, expired sessions, redirect safety, resets, logout, and account deletion.
