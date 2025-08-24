import type { QuickPicksResponse } from "$lib/server/api/interface/home/quick-picks.js";
import type { ApiResponse } from "$lib/utils/types.js";

import { DEFAULT_REGION } from "$lib/constants/countries.js";
import queryClient from "$lib/utils/query-client.js";

export async function load({ url, fetch }) {
  const regionResponse = await queryClient<ApiResponse<string>>(url.toString(), "/api/region", {
    customFetch: fetch,
  });

  const response = queryClient<ApiResponse<QuickPicksResponse["results"]>>(
    url.toString(),
    "/api/music/quick-picks",
    {
      customFetch: fetch,
      searchParams: {
        regionCode: regionResponse.success ? regionResponse.data : DEFAULT_REGION,
      },
    },
  );

  return { pageData: response };
}
