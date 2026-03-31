import { createQuery } from "@tanstack/svelte-query";

import { svelteQueryKeys } from "$lib/constants/keys";
import { musicTrackStatsResponseSchema } from "$lib/schemas/music-track-stats";
import { backendClient } from "$lib/utils/query-client";

export default function useMusicTrackStatsQuery(videoId: string) {
  return createQuery(() => ({
    queryKey: svelteQueryKeys.musicStats(videoId),
    queryFn: () => backendClient(`/music/track/${videoId}/stats`, musicTrackStatsResponseSchema),
  }));
}
