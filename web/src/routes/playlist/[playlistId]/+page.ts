import type { PlayList, PlayListTrack } from "$lib/db/schema";
import type { ApiResponse } from "$lib/utils/types";
import type { PlaylistTracksLength } from "../../api/playlists/[playlistId]/length/types";

import queryClient from "$lib/utils/query-client";

export async function load({ fetch, url, params: { playlistId } }) {
  const playlistInfoResponse = queryClient<ApiResponse<PlayList>>(
    url.toString(),
    `/api/playlists/${playlistId}`,
    {
      customFetch: fetch,
    },
  );
  const playlistTracksResponse = queryClient<ApiResponse<PlayListTrack[]>>(
    url.toString(),
    `/api/playlists/${playlistId}/tracks`,
    {
      customFetch: fetch,
    },
  );
  const playlistPlaylengthResponse = queryClient<ApiResponse<PlaylistTracksLength>>(
    url.toString(),
    `/api/playlists/${playlistId}/length`,
    {
      customFetch: fetch,
    },
  );

  return {
    pageData: {
      playlistInfoResponse,
      playlistTracksResponse,
      playlistPlaylengthResponse,
    },
  };
}
