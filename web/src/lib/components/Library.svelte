<script lang="ts">
  import { goto } from "$app/navigation";

  import type { PlayList } from "$lib/db/schema";
  import type { ApiResponse } from "$lib/utils/types";

  import playlistsStore from "$lib/stores/playlists.svelte";
  import userStore from "$lib/stores/user.svelte";
  import queryClient from "$lib/utils/query-client";

  import PlaylistCard from "./PlaylistCard.svelte";

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
          titleClasses=""
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
