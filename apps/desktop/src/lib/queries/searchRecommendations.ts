import { createQuery } from "@tanstack/svelte-query";

import { svelteQueryKeys } from "$lib/constants/keys";
import { searchRecommendationsSchema } from "$lib/schemas/search-recommendations";
import { backendClient } from "$lib/utils/query-client";

const cachedQueries = new Set<string>();

export default function useSearchRecommendationsQuery(q: string) {
  return createQuery(() => ({
    staleTime: () => (cachedQueries.has(q) ? 1000 * 60 * 5 : 0),
    refetchOnMount: false,
    refetchOnWindowFocus: false,
    refetchOnReconnect: false,
    queryKey: svelteQueryKeys.searchRecommendations(q),
    queryFn: () => {
      if (!cachedQueries.has(q)) cachedQueries.add(q);
      return backendClient("/music/search/search-recommendations", searchRecommendationsSchema, {
        searchParams: { q },
      });
    },
  }));
}
