import { createQuery } from "@tanstack/svelte-query";

import { svelteQueryKeys } from "$lib/constants/keys";
import { playlistSongRecommendationsSchema } from "$lib/schemas/playlist";
import { backendClient } from "$lib/utils/query-client";

export default function usePlaylistRecommendedSongsQuery(playlistId: string) {
  return createQuery(() => ({
    queryKey: svelteQueryKeys.playlistRecommendedSongs(playlistId),
    networkMode: "offlineFirst",
    queryFn: () =>
      backendClient(
        `/playlists/playlist/${playlistId}/recommendations`,
        playlistSongRecommendationsSchema,
      ),
  }));
}
