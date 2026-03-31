import { svelteQueryKeys } from "$lib/constants/keys";
import { albumLiveCoverSchema } from "$lib/schemas/album";
import { backendClient } from "$lib/utils/query-client";
import { createQuery } from "@tanstack/svelte-query";

export default function useLiveAlbumCover({
  albumId,
  videoId,
}: {
  albumId: string;
  videoId: string;
}) {
  return createQuery(() => ({
    queryKey: svelteQueryKeys.albumLiveCover(videoId),
    networkMode: "offlineFirst",
    queryFn: () => backendClient(`/albums/album/${albumId}/${videoId}/cover`, albumLiveCoverSchema),
  }));
}
