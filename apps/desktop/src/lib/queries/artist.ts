import { createQuery } from "@tanstack/svelte-query";

import { svelteQueryKeys } from "$lib/constants/keys";
import { artistResponseSchema } from "$lib/schemas/artist";
import { backendClient } from "$lib/utils/query-client";

export default function useArtistQuery(browseId: string) {
  return createQuery(() => ({
    queryKey: svelteQueryKeys.artist(browseId),
    queryFn: () => backendClient(`/artists/artist/${browseId}`, artistResponseSchema),
  }));
}
