import { createQuery } from "@tanstack/svelte-query";

import { svelteQueryKeys } from "$lib/constants/keys";
import { youtubeVideosSchema } from "$lib/schemas/youtube-video";
import { backendClient } from "$lib/utils/query-client";

export default function useVideosSearchQuery(q: string) {
  return createQuery(() => ({
    queryKey: svelteQueryKeys.search(q, "videos"),
    queryFn: () =>
      backendClient("/music/search/uvideos", youtubeVideosSchema, { searchParams: { q } }),
  }));
}
