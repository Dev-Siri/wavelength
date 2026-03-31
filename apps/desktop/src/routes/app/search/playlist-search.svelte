<script lang="ts">
  import usePlaylistSearchQuery from "$lib/queries/playlistSearch";

  import PlaylistTile from "$lib/components/playlist/PlaylistTile.svelte";
  import NoSearchResults from "$lib/components/search/NoSearchResults.svelte";
  import TrackSkeleton from "$lib/components/skeletons/TrackSkeleton.svelte";

  const { q }: { q: string } = $props();

  const playlistSearchQuery = $derived(usePlaylistSearchQuery(q));
</script>

<div class="flex flex-col w-full h-full items-center pb-32 rounded-2xl">
  {#if playlistSearchQuery.isLoading}
    {#each new Array(10)}
      <TrackSkeleton />
    {/each}
  {:else if playlistSearchQuery.isSuccess}
    {#if playlistSearchQuery.data.playlists}
      {#each playlistSearchQuery.data.playlists as playlist (playlist.playlistId)}
        <PlaylistTile {playlist} />
      {/each}
    {:else}
      <div class="mt-[14%]">
        <NoSearchResults message="No public playlists matched your search." />
      </div>
    {/if}
  {/if}
</div>
