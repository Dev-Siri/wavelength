<script lang="ts">
  import { goto } from "$app/navigation";
  import { createQuery } from "@tanstack/svelte-query";

  import { svelteQueryKeys } from "$lib/constants/keys";
  import userStore from "$lib/stores/user.svelte";
  import { backendClient } from "$lib/utils/query-client.js";
  import { followedArtistResponseSchema } from "$lib/utils/validation/artist-response";
  import { playlistsSchema } from "$lib/utils/validation/playlists.js";

  import ArtistCard from "./artist/ArtistCard.svelte";
  import ArtistTile from "./artist/ArtistTile.svelte";
  import LikedTracksLink from "./LikedTracksLink.svelte";
  import PlaylistTile from "./playlist/PlaylistTile.svelte";

  const { isCollapsed }: { isCollapsed?: boolean } = $props();

  const playlistsQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.userPlaylists,
    async queryFn() {
      if (!userStore.user) return;

      return backendClient(`/playlists/user/${userStore.user.email}`, playlistsSchema);
    },
  }));

  const followedArtistsQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.followedArtists,
    queryFn: () => backendClient("/artists/followed", followedArtistResponseSchema),
  }));
</script>

<div class="h-full w-full">
  {#if playlistsQuery.isLoading || followedArtistsQuery.isLoading}
    <p class="text-center mt-40 font-semibold text-muted-foreground cursor-default">
      Your Library is loading...
    </p>
  {:else if playlistsQuery.isError}
    <p class="text-center mt-40 font-semibold text-red-500 cursor-default">
      Error: {playlistsQuery.error.message}
    </p>
  {:else if playlistsQuery.isSuccess && followedArtistsQuery.isSuccess}
    {#if playlistsQuery.data}
      <LikedTracksLink mode={isCollapsed ? "icon" : "full"} />
      {#key playlistsQuery.data}
        {#each playlistsQuery.data.playlists as playlist}
          <PlaylistTile
            {playlist}
            wrapperClick={() =>
              window.innerWidth <= 968 && goto(`/app/playlist/${playlist.playlistId}`)}
            mode={isCollapsed ? "icon" : "full"}
          />
        {/each}
      {/key}
      {#key followedArtistsQuery.data}
        {#each followedArtistsQuery?.data.artists as artist}
          {#if isCollapsed}
            <div class="my-4 flex justify-center">
              <ArtistCard height={80} width={80} {...artist} />
            </div>
          {:else}
            <ArtistTile {...artist} />
          {/if}
        {/each}
      {/key}
    {:else}
      <p class="text-center mt-40 font-semibold text-muted-foreground cursor-default">
        Your Library is empty.
      </p>
    {/if}
  {/if}
</div>
