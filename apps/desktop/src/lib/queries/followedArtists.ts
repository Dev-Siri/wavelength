import { createQuery } from "@tanstack/svelte-query";

import { svelteQueryKeys } from "$lib/constants/keys";
import { followedArtistResponseSchema } from "$lib/schemas/artist";
import { backendClient } from "$lib/utils/query-client";

export default function useFollowedArtistsQuery() {
  return createQuery(() => ({
    queryKey: svelteQueryKeys.followedArtists,
    queryFn: () => backendClient("/artists/followed", followedArtistResponseSchema),
  }));
}
