import { createQuery } from "@tanstack/svelte-query";
import { z } from "zod";

import { svelteQueryKeys } from "$lib/constants/keys";
import { playlistSchema } from "$lib/schemas/playlist";
import { backendClient } from "$lib/utils/query-client";

export default function usePlaylistQuery(playlistId: string) {
  return createQuery(() => ({
    queryKey: svelteQueryKeys.playlist(playlistId),
    networkMode: "offlineFirst",
    queryFn: () =>
      backendClient(`/playlists/playlist/${playlistId}`, z.object({ playlist: playlistSchema })),
  }));
}
