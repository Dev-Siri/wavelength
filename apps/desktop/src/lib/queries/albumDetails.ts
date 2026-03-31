import { createQuery } from "@tanstack/svelte-query";

import { svelteQueryKeys } from "$lib/constants/keys";
import { albumDetailsSchema } from "$lib/schemas/album";
import { backendClient } from "$lib/utils/query-client";

export default function useAlbumDetailsQuery(albumId: string) {
  return createQuery(() => ({
    queryKey: svelteQueryKeys.album(albumId),
    queryFn: () => backendClient(`/albums/album/${albumId}`, albumDetailsSchema),
    refetchOnWindowFocus: false,
    refetchOnMount: false,
    refetchOnReconnect: false,
  }));
}
