import { Suspense } from "react";
import { AuthCompleteClient } from "@/components/auth-complete-client";

type AuthCompletePageProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

export default async function AuthCompletePage({ searchParams }: AuthCompletePageProps) {
  const resolvedSearchParams = await searchParams;

  return (
    <Suspense fallback={null}>
      <AuthCompleteClient searchParams={resolvedSearchParams} />
    </Suspense>
  );
}
