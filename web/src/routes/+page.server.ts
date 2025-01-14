import type { QuickPicksResponse } from "$lib/server/api/interface/home/quick-picks";
import type { ApiResponse } from "$lib/utils/types";

import configureRegion from "$lib/server/utils/configure-region";
import queryClient from "$lib/utils/query-client";

export function load({ url, cookies, getClientAddress }) {
  const region = configureRegion(cookies, getClientAddress());

  const response = queryClient<ApiResponse<QuickPicksResponse["results"]>>(
    url.toString(),
    "/api/music/quick-picks",
    {
      searchParams: {
        regionCode: region,
      },
    },
  );

  return { pageData: response };
}
