import { NextRequest } from "next/server";
import { resultsResponse } from "../_shared";

export const dynamic = "force-dynamic";

export async function GET(_request: NextRequest) {
  return resultsResponse([]);
}
