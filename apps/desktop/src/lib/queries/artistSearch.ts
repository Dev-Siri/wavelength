import { svelteQueryKeys } from "$lib/constants/keys";
import { artistSearchResponseSchema } from "$lib/schemas/search-response";
import { backendClient } from "$lib/utils/query-client";
import { createQuery } from "@tanstack/svelte-query";

export default function useArtistSearchQuery(q: string) {
  return createQuery(() => ({
    queryKey: svelteQueryKeys.search(q, "artists"),
    queryFn: () =>
      backendClient("/artists/search", artistSearchResponseSchema, { searchParams: { q } }),
  }));
}
