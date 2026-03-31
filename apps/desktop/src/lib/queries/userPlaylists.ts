import { createQuery } from "@tanstack/svelte-query";

import { svelteQueryKeys } from "$lib/constants/keys";
import { playlistsSchema } from "$lib/schemas/playlist";
import { backendClient } from "$lib/utils/query-client";

export default function useUserPlaylistsQuery(email: string) {
  return createQuery(() => ({
    queryKey: svelteQueryKeys.userPlaylists,
    networkMode: "offlineFirst",
    async queryFn() {
      return backendClient(`/playlists/user/${email}`, playlistsSchema);
    },
  }));
}
