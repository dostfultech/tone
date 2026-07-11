import { NextResponse, type NextRequest } from "next/server";
import { createServerClient } from "@supabase/ssr";
import { getSiteUrl, isSupabaseConfigured } from "@/lib/env";

const appRoutes = ["/app", "/library", "/account"];
const authOnlyRoutes = ["/checkout"];

export async function middleware(request: NextRequest) {
  const pathname = request.nextUrl.pathname;
  const canonicalRedirect = redirectToCanonicalHost(request);
  if (canonicalRedirect) {
    return canonicalRedirect;
  }

  const requiresAppAccess = appRoutes.some((route) => pathname === route || pathname.startsWith(`${route}/`));
  const requiresAuthOnly = authOnlyRoutes.some((route) => pathname === route || pathname.startsWith(`${route}/`));

  if (!requiresAppAccess && !requiresAuthOnly) {
    return NextResponse.next();
  }

  if (!isSupabaseConfigured()) {
    return NextResponse.next();
  }

  let response = NextResponse.next({
    request
  });

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll();
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) => request.cookies.set(name, value));
          response = NextResponse.next({ request });
          cookiesToSet.forEach(({ name, value, options }) => {
            response.cookies.set(name, value, options);
          });
        }
      }
    }
  );

  const {
    data: { user }
  } = await supabase.auth.getUser();

  if (!user) {
    const loginUrl = request.nextUrl.clone();
    loginUrl.pathname = "/login";
    loginUrl.searchParams.set("redirect", pathname);
    return NextResponse.redirect(loginUrl);
  }

  return response;
}

function redirectToCanonicalHost(request: NextRequest) {
  if (process.env.NODE_ENV !== "production") {
    return null;
  }

  const configuredSiteUrl = getSiteUrl();
  const canonical = new URL(configuredSiteUrl);
  const current = request.nextUrl;
  const hostname = current.hostname.toLowerCase();
  if (hostname === canonical.hostname.toLowerCase()) {
    return null;
  }

  if (hostname === "localhost" || hostname === "127.0.0.1") {
    return null;
  }

  const target = new URL(current.pathname + current.search, canonical.origin);
  return NextResponse.redirect(target, 308);
}

export const config = {
  matcher: ["/((?!api|_next/static|_next/image|favicon.ico|.*\\..*).*)"]
};
