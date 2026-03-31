import { createQuery } from "@tanstack/svelte-query";
import { get, set } from "idb-keyval";

import { svelteQueryKeys } from "$lib/constants/keys";
import { isAlbumLosslessSchema } from "$lib/schemas/album";
import { backendClient } from "$lib/utils/query-client";

export default function useIsAlbumLosslessQuery(albumId: string) {
  return createQuery(() => ({
    queryKey: svelteQueryKeys.isAlbumLossless(albumId),
    async queryFn() {
      const cacheKey = `is-lossless-${albumId}`;
      const cachedLosslessResponse = await get(cacheKey);

      if (cachedLosslessResponse) {
        return { isLossless: true };
      }

      const isLosslessResponse = await backendClient(
        `/albums/album/${albumId}/is-lossless`,
        isAlbumLosslessSchema,
      );
      if (isLosslessResponse.isLossless) {
        await set(cacheKey, true);
      }

      return isLosslessResponse;
    },
    networkMode: "offlineFirst",
    refetchOnWindowFocus: false,
    refetchOnMount: false,
    refetchOnReconnect: false,
  }));
}
