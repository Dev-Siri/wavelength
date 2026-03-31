import { createQuery } from "@tanstack/svelte-query";
import { z } from "zod";

import { svelteQueryKeys } from "$lib/constants/keys";
import { backendClient } from "$lib/utils/query-client";

export default function useIsFollowingQuery(browseId: string) {
  return createQuery(() => ({
    queryKey: svelteQueryKeys.isFollowingArtist(browseId),
    queryFn: () =>
      backendClient(
        `/artists/followed/${browseId}/is-following`,
        z.object({ isFollowing: z.boolean() }),
      ),
  }));
}
