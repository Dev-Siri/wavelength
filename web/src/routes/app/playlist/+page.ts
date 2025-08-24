import type { PlayList } from "$lib/db/schema.js";
import type { ApiResponse } from "$lib/utils/types.js";

import queryClient from "$lib/utils/query-client.js";

export async function load({ url, fetch }) {
  const publicPlaylistsResponse = queryClient<ApiResponse<PlayList[]>>(
    url.toString(),
    "/api/playlists",
    {
      customFetch: fetch,
      searchParams: {
        q: url.searchParams.get("q") || "",
      },
    },
  );

  return {
    pageData: { publicPlaylistsResponse },
  };
}
