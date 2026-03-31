import { createQuery } from "@tanstack/svelte-query";

import { svelteQueryKeys } from "$lib/constants/keys";
import { likedTracksLengthSchema } from "$lib/schemas/track-length";
import { backendClient } from "$lib/utils/query-client";

export default function useLikesPlaylengthQuery() {
  return createQuery(() => ({
    queryKey: svelteQueryKeys.likesLength,
    networkMode: "offlineFirst",
    queryFn: () => backendClient("/music/track/likes/length", likedTracksLengthSchema),
  }));
}
