<script lang="ts">
  import { goto } from "$app/navigation";
  import { createQuery } from "@tanstack/svelte-query";

  import { svelteQueryKeys } from "$lib/constants/keys";
  import userStore from "$lib/stores/user.svelte";
  import { backendClient } from "$lib/utils/query-client.js";
  import { playlistsSchema } from "$lib/utils/validation/playlists.js";

  import PlaylistCard from "./PlaylistCard.svelte";

  const { sidebarWidth }: { sidebarWidth: number } = $props();

  const playlistsQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.userPlaylists,
    refetchOnWindowFocus: true,
    async queryFn() {
      if (!userStore.user) return;

      return backendClient(`/playlists/user/${userStore.user.email}`, playlistsSchema);
    },
  }));
</script>

<div class="h-full w-full">
  {#if playlistsQuery.isLoading}
    <p class="text-center mt-40 font-semibold text-muted-foreground cursor-default">
      Your Library is loading...
    </p>
  {:else if playlistsQuery.isError}
    <p class="text-center mt-40 font-semibold text-red-500 cursor-default">
      Error: {playlistsQuery.error.message}
    </p>
  {:else if playlistsQuery.isSuccess}
    {#if playlistsQuery.data}
      {#key playlistsQuery.data}
        {#each playlistsQuery.data as playlist}
          <PlaylistCard
            {playlist}
            titleClasses={sidebarWidth < 11 ? "hidden" : "w-10 overflow-hidden"}
            imageClasses={sidebarWidth < 11 ? "h-10 w-10" : "h-9.5 w-14"}
            wrapperClick={() =>
              window.innerWidth <= 968 && goto(`/playlist/${playlist.playlistId}`)}
          />
        {/each}
      {/key}
    {:else}
      <p class="text-center mt-40 font-semibold text-muted-foreground cursor-default">
        Your Library is empty.
      </p>
    {/if}
  {/if}
</div>
