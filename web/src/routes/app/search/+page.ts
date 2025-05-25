import type { MusicSearchResponse } from "$lib/server/api/interface/search/search-music";
import type { ApiResponse } from "$lib/utils/types";
import type { youtube_v3 } from "googleapis";

import queryClient from "$lib/utils/query-client";

export function load({ url, fetch }) {
  const q = url.searchParams.get("q");

  const songResponse = queryClient<ApiResponse<MusicSearchResponse<"song">>>(
    url.toString(),
    "/api/music/search",
    {
      searchParams: { q, searchType: "song" },
      customFetch: fetch,
    },
  );

  const artistResponse = queryClient<ApiResponse<MusicSearchResponse<"artists">>>(
    url.toString(),
    "/api/music/search",
    {
      searchParams: { q, searchType: "artists" },
      customFetch: fetch,
    },
  );

  const uvideosResponse = queryClient<ApiResponse<youtube_v3.Schema$SearchResult[]>>(
    url.toString(),
    "/api/music/search/uvideos",
    {
      searchParams: { q },
      customFetch: fetch,
    },
  );

  return {
    pageData: {
      songResponse,
      artistResponse,
      uvideosResponse,
    },
  };
}
