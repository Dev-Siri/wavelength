import type {
  ApiResponse,
  ArtistSearchResponse,
  MusicSearchResponse,
  YouTubeVideo,
} from "$lib/types.js";

import { backendClient } from "$lib/utils/query-client.js";

export function load({ url, fetch }) {
  const q = url.searchParams.get("q");
  const searchOptions = {
    searchParams: { q },
    customFetch: fetch,
  };

  const songResponse = backendClient<ApiResponse<MusicSearchResponse>>(
    "/music/search",
    searchOptions,
  );
  const artistResponse = backendClient<ApiResponse<ArtistSearchResponse>>(
    "/artists/search",
    searchOptions,
  );
  const uvideosResponse = backendClient<ApiResponse<YouTubeVideo[]>>(
    "/music/search/uvideos",
    searchOptions,
  );

  return {
    pageData: {
      songResponse,
      artistResponse,
      uvideosResponse,
    },
  };
}
