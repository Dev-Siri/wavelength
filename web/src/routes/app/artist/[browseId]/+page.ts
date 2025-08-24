import type { ArtistResponse } from "$lib/server/api/interface/artists/get-artist-details.js";
import type { ApiResponse } from "$lib/utils/types.js";
import type { youtube_v3 } from "googleapis";

import queryClient from "$lib/utils/query-client.js";

export async function load({ fetch, url, params: { browseId } }) {
  const defaultResponse = queryClient<ApiResponse<ArtistResponse>>(
    url.toString(),
    `/api/artists/${browseId}`,
    { customFetch: fetch },
  );

  const extraResponse = queryClient<ApiResponse<youtube_v3.Schema$ChannelListResponse>>(
    url.toString(),
    `/api/artists/${browseId}/extra`,
    { customFetch: fetch },
  );

  return {
    pageData: {
      defaultResponse,
      extraResponse,
    },
  };
}
