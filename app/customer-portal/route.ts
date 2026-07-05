import { CustomerPortal } from "@dodopayments/nextjs";
import { resolveDodoEnvironment } from "@/lib/dodo";

export const GET = CustomerPortal({
  bearerToken: process.env.DODO_PAYMENTS_API_KEY,
  environment: resolveDodoEnvironment()
});
