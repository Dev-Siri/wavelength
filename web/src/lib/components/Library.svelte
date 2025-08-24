<script lang="ts">
  import { goto } from "$app/navigation";

  import type { PlayList } from "$lib/db/schema.js";
  import type { ApiResponse } from "$lib/utils/types.js";

  import playlistsStore from "$lib/stores/playlists.svelte";
  import userStore from "$lib/stores/user.svelte";
  import queryClient from "$lib/utils/query-client.js";

  import PlaylistCard from "./PlaylistCard.svelte";

  const { paneWidth }: { paneWidth: number } = $props();

  $effect(() => {
    async function fetchPlaylists() {
      if (!userStore.user) return;

      const response = await queryClient<ApiResponse<PlayList[]>>(
        location.toString(),
        `/api/playlists/user/${userStore.user.email}`,
      );

      if (response.success) playlistsStore.playlists = response.data;
    }

    fetchPlaylists();
  });
</script>

<div class="h-full w-full">
  {#if playlistsStore.playlists.length}
    {#key playlistsStore.playlists}
      {#each playlistsStore.playlists as playlist}
        <PlaylistCard
          {playlist}
          titleClasses={paneWidth < 11 ? "hidden" : "w-10 overflow-hidden"}
          imageClasses={paneWidth < 11 ? "h-10 w-10" : "h-full w-14"}
          wrapperClick={() => window.innerWidth <= 968 && goto(`/playlist/${playlist.playlistId}`)}
        />
      {/each}
    {/key}
  {:else}
    <p class="text-center mt-40 font-semibold text-muted-foreground cursor-default">
      Your Library is empty.
    </p>
  {/if}
</div>
