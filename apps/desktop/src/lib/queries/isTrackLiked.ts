import { createQuery } from "@tanstack/svelte-query";
import { z } from "zod";

import { svelteQueryKeys } from "$lib/constants/keys";
import { backendClient } from "$lib/utils/query-client";

export interface IsTrackLikedQueryOptions {
  enabled?: boolean;
}

export default function useIsTrackLiked(videoId: string, { enabled }: IsTrackLikedQueryOptions) {
  return createQuery(() => ({
    queryKey: svelteQueryKeys.isTrackLiked(videoId),
    enabled: () => !!enabled,
    queryFn: () => {
      if (!enabled) return;
      return backendClient(
        `/music/track/likes/${videoId}/is-liked`,
        z.object({ isLiked: z.boolean() }),
      );
    },
  }));
}
