import { createQuery } from "@tanstack/svelte-query";

import { svelteQueryKeys } from "$lib/constants/keys";
import { playlistTracksSchema } from "$lib/schemas/playlist";
import { backendClient } from "$lib/utils/query-client";

export default function usePlaylistTracksQuery(playlistId: string) {
  return createQuery(() => ({
    networkMode: "offlineFirst",
    queryKey: svelteQueryKeys.playlistTrack(playlistId),
    queryFn: () => backendClient(`/playlists/playlist/${playlistId}/tracks`, playlistTracksSchema),
  }));
}
