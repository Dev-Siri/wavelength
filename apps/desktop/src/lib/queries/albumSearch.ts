import { createQuery } from "@tanstack/svelte-query";

import { svelteQueryKeys } from "$lib/constants/keys";
import { albumSearchResponseSchema } from "$lib/schemas/search-response";
import { backendClient } from "$lib/utils/query-client";

export default function useAlbumSearchQuery(q: string) {
  return createQuery(() => ({
    queryKey: svelteQueryKeys.search(q, "albums"),
    queryFn: () =>
      backendClient("/albums/search", albumSearchResponseSchema, {
        searchParams: { q },
      }),
  }));
}
