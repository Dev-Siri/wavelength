import { createQuery } from "@tanstack/svelte-query";

import { svelteQueryKeys } from "$lib/constants/keys";
import { musicSearchResponseSchema } from "$lib/schemas/search-response";
import { backendClient } from "$lib/utils/query-client";

export default function useTrackSearch(q: string) {
  return createQuery(() => ({
    queryKey: svelteQueryKeys.search(q, "tracks"),
    queryFn: () =>
      backendClient("/music/search", musicSearchResponseSchema, { searchParams: { q } }),
  }));
}
