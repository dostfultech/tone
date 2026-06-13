import { NextResponse, type NextRequest } from "next/server";
import { createServerClient } from "@supabase/ssr";
import { getTestAccessEmails, isSupabaseConfigured } from "@/lib/env";

const appRoutes = ["/app", "/library", "/gear", "/community", "/account"];
const authOnlyRoutes = ["/checkout"];

export async function middleware(request: NextRequest) {
  const pathname = request.nextUrl.pathname;
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

  if (requiresAuthOnly) {
    return response;
  }

  const email = user.email?.toLowerCase();
  if (email && getTestAccessEmails().has(email)) {
    return response;
  }

  const { data: subscription } = await supabase
    .from("subscriptions")
    .select("status, plan_id")
    .eq("user_id", user.id)
    .in("status", ["active", "trialing"])
    .order("updated_at", { ascending: false })
    .limit(1)
    .maybeSingle();

  if (!subscription) {
    const plansUrl = request.nextUrl.clone();
    plansUrl.pathname = "/plans";
    plansUrl.searchParams.set("required", "subscription");
    plansUrl.searchParams.set("redirect", pathname);
    return NextResponse.redirect(plansUrl);
  }

  return response;
}

export const config = {
  matcher: ["/app/:path*", "/library/:path*", "/gear/:path*", "/community/:path*", "/account/:path*", "/checkout/:path*"]
};
