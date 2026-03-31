import { createQuery } from "@tanstack/svelte-query";

import { svelteQueryKeys } from "$lib/constants/keys";
import { likedTracksSchema } from "$lib/schemas/liked-track";
import { backendClient } from "$lib/utils/query-client";

export default function useLikesQuery() {
  return createQuery(() => ({
    queryKey: svelteQueryKeys.likes,
    networkMode: "offlineFirst",
    queryFn: () => backendClient("/music/track/likes", likedTracksSchema),
  }));
}
