import { createQuery } from "@tanstack/svelte-query";

import { svelteQueryKeys } from "$lib/constants/keys";
import { isAlbumSavedSchema } from "$lib/schemas/album";
import { backendClient } from "$lib/utils/query-client";

export default function useIsAlbumSavedQuery(albumId: string) {
  return createQuery(() => ({
    queryKey: svelteQueryKeys.isAlbumSaved(albumId),
    queryFn: () => backendClient(`/albums/album/${albumId}/is-saved`, isAlbumSavedSchema),
    networkMode: "offlineFirst",
    refetchOnWindowFocus: false,
    refetchOnMount: false,
    refetchOnReconnect: false,
  }));
}
