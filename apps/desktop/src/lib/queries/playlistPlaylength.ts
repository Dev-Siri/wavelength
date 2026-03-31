import { createQuery } from "@tanstack/svelte-query";

import { svelteQueryKeys } from "$lib/constants/keys";
import { playlistTracksLengthSchema } from "$lib/schemas/track-length";
import { backendClient } from "$lib/utils/query-client";

export default function usePlaylistPlaylengthQuery(playlistId: string) {
  return createQuery(() => ({
    queryKey: svelteQueryKeys.playlistTrackLength(playlistId),
    networkMode: "offlineFirst",
    queryFn: () =>
      backendClient(`/playlists/playlist/${playlistId}/length`, playlistTracksLengthSchema),
  }));
}
