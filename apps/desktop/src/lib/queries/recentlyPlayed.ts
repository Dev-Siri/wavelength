import { createQuery } from "@tanstack/svelte-query";

import { svelteQueryKeys } from "$lib/constants/keys";
import { recentlyPlayedSchema } from "$lib/schemas/home";
import { backendClient } from "$lib/utils/query-client";

export default function useRecentlyPlayedQuery() {
  return createQuery(() => ({
    queryKey: svelteQueryKeys.recentlyPlayed,
    queryFn: () => backendClient("/music/home/recents", recentlyPlayedSchema),
    // 20 minutes.
    networkMode: "offlineFirst",
  }));
}
