import type { ApiResponse, ArtistResponse } from "$lib/types.js";
import type { youtube_v3 } from "googleapis";

import { backendClient } from "$lib/utils/query-client.js";

export async function load({ fetch, params: { browseId } }) {
  const defaultResponse = backendClient<ApiResponse<ArtistResponse>>(
    `/artists/artist/${browseId}`,
    {
      customFetch: fetch,
    },
  );

  const extraResponse = backendClient<ApiResponse<youtube_v3.Schema$ChannelListResponse>>(
    `/artists/artist/${browseId}/extra`,
    { customFetch: fetch },
  );

  return {
    pageData: {
      defaultResponse,
      extraResponse,
    },
  };
}
