<script lang="ts">
  import { onMount } from "svelte";

  import type { PlayList } from "$lib/db/schema";
  import type { ApiResponse } from "$lib/utils/types";

  import { playlists } from "$lib/stores/playlists";
  import { user } from "$lib/stores/user";
  import queryClient from "$lib/utils/query-client";

  import { goto } from "$app/navigation";
  import PlaylistCard from "./PlaylistCard.svelte";

  onMount(async () => {
    if ($user) {
      const response = await queryClient<ApiResponse<PlayList[]>>(
        location.toString(),
        `/api/playlists/user/${$user.email}`,
      );

      if (response.success) $playlists = response.data;
    }
  });
</script>

<div class="h-full w-full">
  {#if $playlists.length}
    {#key $playlists}
      {#each $playlists as playlist}
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
