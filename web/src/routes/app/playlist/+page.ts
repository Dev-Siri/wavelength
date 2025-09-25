import type { ApiResponse, Playlist } from "$lib/types.js";

import { backendClient } from "$lib/utils/query-client.js";

export async function load({ url, fetch }) {
  const publicPlaylistsResponse = backendClient<ApiResponse<Playlist[]>>("/api/playlists", {
    customFetch: fetch,
    searchParams: {
      q: url.searchParams.get("q") || "",
    },
  });

  return {
    pageData: { publicPlaylistsResponse },
  };
}
