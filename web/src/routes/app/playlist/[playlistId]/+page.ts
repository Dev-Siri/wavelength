import type { ApiResponse, PlaylistTracksLength } from "$lib/types.js";

import { DB_PLAYLISTS_STORE_NAME, DB_TRACKS_STORE_NAME } from "$lib/constants/db.js";
import getClientDB from "$lib/db/client-indexed-db.js";
import { backendClient } from "$lib/utils/query-client.js";

export async function load({ fetch, params: { playlistId } }) {
  try {
    const db = await getClientDB();

    const [cachedPlaylist, cachedTracks] = await Promise.all([
      db.get(DB_PLAYLISTS_STORE_NAME, playlistId),
      db.getAllFromIndex(DB_TRACKS_STORE_NAME, "by_playlistId", playlistId),
    ]);

    const playlistPlaylengthResponse = backendClient<ApiResponse<PlaylistTracksLength>>(
      `/playlists/playlist/${playlistId}/length`,
      { customFetch: fetch },
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
