import { createQuery } from "@tanstack/svelte-query";

import { svelteQueryKeys } from "$lib/constants/keys";
import { playlistsSchema } from "$lib/schemas/playlist";
import { backendClient } from "$lib/utils/query-client";

export default function usePlaylistSearchQuery(q: string) {
  return createQuery(() => ({
    queryKey: svelteQueryKeys.search(q, "playlists"),
    queryFn: () =>
      backendClient("/playlists", playlistsSchema, {
        searchParams: { q },
      }),
  }));
}
