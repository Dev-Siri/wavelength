import { createQuery } from "@tanstack/svelte-query";

import { svelteQueryKeys } from "$lib/constants/keys";
import { savedAlbumResponseSchema } from "$lib/schemas/album";
import { backendClient } from "$lib/utils/query-client";

export default function useSavedAlbumsQuery() {
  return createQuery(() => ({
    queryKey: svelteQueryKeys.savedAlbums,
    networkMode: "offlineFirst",
    async queryFn() {
      return backendClient("/albums/saves", savedAlbumResponseSchema);
    },
  }));
}
