<script lang="ts">
  import { goto } from "$app/navigation";
  import { resolve } from "$app/paths";

  import useFollowedArtistsQuery from "$lib/queries/followedArtists";
  import useUserPlaylistsQuery from "$lib/queries/userPlaylists";
  import useSavedAlbumsQuery from "$lib/queries/useSavedAlbumsQuery";
  import userStore from "$lib/stores/user.svelte";
  import AlbumTile from "./album/AlbumTile.svelte";

  import ArtistCard from "./artist/ArtistCard.svelte";
  import ArtistTile from "./artist/ArtistTile.svelte";
  import LikedTracksLink from "./LikedTracksLink.svelte";
  import PlaylistTile from "./playlist/PlaylistTile.svelte";
  import Button from "./ui/button/button.svelte";

  const { isCollapsed }: { isCollapsed?: boolean } = $props();

  const playlistsQuery = $derived(useUserPlaylistsQuery(userStore.user?.email ?? ""));
  const savedAlbumsQuery = $derived(useSavedAlbumsQuery());
  const followedArtistsQuery = useFollowedArtistsQuery();

  let shownSection = $state<"playlists" | "albums" | "artists">("playlists");
</script>

<div
  class="h-full w-full overflow-y-auto scrollbar-hidden {isCollapsed ? 'pb-[300%]' : 'pb-[45%]'}"
>
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
      {#if !isCollapsed}
        <div class="flex px-2 items-center gap-2">
          <Button
            size="sm"
            variant={shownSection === "playlists" ? "secondary" : "ghost"}
            onclick={() => (shownSection = "playlists")}
          >
            Playlists
          </Button>
          <Button
            size="sm"
            variant={shownSection === "albums" ? "secondary" : "ghost"}
            onclick={() => (shownSection = "albums")}
          >
            Albums
          </Button>
          <Button
            size="sm"
            variant={shownSection === "artists" ? "secondary" : "ghost"}
            onclick={() => (shownSection = "artists")}
          >
            Artists
          </Button>
        </div>
      {/if}
      {#if shownSection === "albums"}
        {#key savedAlbumsQuery.data}
          {#each savedAlbumsQuery.data?.albums as album (album.albumId)}
            <AlbumTile mode={isCollapsed ? "icon" : "card"} {...album} />
          {/each}
        {/key}
      {/if}
      {#if shownSection === "playlists"}
        {#key playlistsQuery.data}
          {#each playlistsQuery.data.playlists as playlist (playlist.playlistId)}
            <PlaylistTile
              {playlist}
              wrapperClick={() =>
                window.innerWidth <= 968 && goto(resolve(`/app/playlist/${playlist.playlistId}`))}
              mode={isCollapsed ? "icon" : "full"}
            />
          {/each}
        {/key}
      {/if}
      {#if shownSection === "artists"}
        {#key followedArtistsQuery.data}
          {#each followedArtistsQuery?.data.artists as artist (`followed-lib-${artist.browseId}`)}
            {#if isCollapsed}
              <div class="my-4 flex justify-center">
                <ArtistCard height={80} width={80} {...artist} />
              </div>
            {:else}
              <ArtistTile {...artist} />
            {/if}
          {/each}
        {/key}
      {/if}
    {:else}
      <p class="text-center mt-40 font-semibold text-muted-foreground cursor-default">
        Your Library is empty.
      </p>
    {/if}
  {/if}
</div>
