import { createQuery } from "@tanstack/svelte-query";

import { svelteQueryKeys } from "$lib/constants/keys";
import { quickPicksResponseSchema } from "$lib/schemas/quick-picks-response";
import { backendClient } from "$lib/utils/query-client";

export default function useQuickPicksQuery(regionCode: string) {
  return createQuery(() => ({
    queryKey: svelteQueryKeys.quickPicks,
    queryFn: () =>
      backendClient("/music/quick-picks", quickPicksResponseSchema, {
        searchParams: { regionCode },
      }),
    // 20 minutes.
    staleTime: 20 * 60 * 1000,
    refetchOnWindowFocus: false,
  }));
}
