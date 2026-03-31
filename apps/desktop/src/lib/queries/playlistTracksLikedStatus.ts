import { createQuery } from "@tanstack/svelte-query";

import { svelteQueryKeys } from "$lib/constants/keys";
import { playlistTracksLikedStatusSchema } from "$lib/schemas/playlist";
import { backendClient } from "$lib/utils/query-client";

export default function usePlaylistTracksLikedStatusQuery(playlistId: string) {
  return createQuery(() => ({
    networkMode: "offlineFirst",
    queryKey: svelteQueryKeys.playlistLikedStatus(playlistId),
    queryFn: () =>
      backendClient(`/playlists/playlist/${playlistId}/likes`, playlistTracksLikedStatusSchema),
  }));
}
