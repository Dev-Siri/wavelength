import type { ApiResponse } from "$lib/utils/types";
import type { PlaylistTracksLength } from "../../../api/playlists/[playlistId]/length/types";

import { DB_PLAYLISTS_STORE_NAME, DB_TRACKS_STORE_NAME } from "$lib/constants/db";
import getClientDB from "$lib/db/client-indexed-db";
import queryClient from "$lib/utils/query-client";

export async function load({ fetch, url, params: { playlistId } }) {
  try {
    const db = await getClientDB();

    const [cachedPlaylist, cachedTracks] = await Promise.all([
      db.get(DB_PLAYLISTS_STORE_NAME, playlistId),
      db.getAllFromIndex(DB_TRACKS_STORE_NAME, "by_playlistId", playlistId),
    ]);

    const playlistPlaylengthResponse = queryClient<ApiResponse<PlaylistTracksLength>>(
      url.toString(),
      `/api/playlists/${playlistId}/length`,
      {
        customFetch: fetch,
      },
    );

    return {
      success: true,
      pageData: {
        cachedPlaylist: cachedPlaylist,
        cachedPlaylistTracks: cachedTracks,
        playlistPlaylengthResponse,
      },
    };
  } catch (err) {
    console.log(err);
    return {
      success: false,
      pageData: {
        cachedPlaylist: null,
        cachedPlaylistTracks: null,
        playlistPlaylengthResponse: null,
      },
    };
  }
}
