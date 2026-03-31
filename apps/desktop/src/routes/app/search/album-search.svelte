<script lang="ts">
  import useAlbumSearchQuery from "$lib/queries/albumSearch";

  import AlbumCard from "$lib/components/album/AlbumCard.svelte";
  import AlbumCardSkeleton from "$lib/components/skeletons/AlbumCardSkeleton.svelte";

  const { q }: { q: string } = $props();

  const albumSearchQuery = $derived(useAlbumSearchQuery(q));
</script>

<div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 w-full gap-8 px-2.5">
  {#if albumSearchQuery.isLoading}
    {#each new Array(15)}
      <AlbumCardSkeleton />
    {/each}
  {:else if albumSearchQuery.isSuccess}
    {#if albumSearchQuery.data.albums}
      {#each albumSearchQuery.data.albums as album (album.albumId)}
        <AlbumCard {album} />
      {/each}
    {:else}
      <span class="text-2xl text-balance mt-[20%]"> No albums found with that query.</span>
    {/if}
  {/if}
</div>
