import type { ApiResponse, QuickPicksResponse } from "$lib/types.js";

import { DEFAULT_REGION } from "$lib/constants/countries.js";
import { backendClient } from "$lib/utils/query-client.js";

export async function load({ fetch }) {
  const regionResponse = await backendClient<ApiResponse<string>>("/region", {
    customFetch: fetch,
  });

  const response = backendClient<ApiResponse<QuickPicksResponse["results"]>>("/music/quick-picks", {
    customFetch: fetch,
    searchParams: { regionCode: regionResponse.success ? regionResponse.data : DEFAULT_REGION },
  });

  return { pageData: response };
}
