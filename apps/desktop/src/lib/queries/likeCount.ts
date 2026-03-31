import { createQuery } from "@tanstack/svelte-query";
import { z } from "zod";

import { svelteQueryKeys } from "$lib/constants/keys";
import { backendClient } from "$lib/utils/query-client";

export default function useLikeCountQuery() {
  return createQuery(() => ({
    queryKey: svelteQueryKeys.likeCount,
    queryFn: () => backendClient("/music/track/likes/count", z.object({ likeCount: z.number() })),
  }));
}
