<script lang="ts">
  import useArtistSearchQuery from "$lib/queries/artistSearch";

  import ArtistCard from "$lib/components/artist/ArtistCard.svelte";
  import ArtistCardSkeleton from "$lib/components/skeletons/ArtistCardSkeleton.svelte";

  const { q }: { q: string } = $props();

  const artistSearchQuery = $derived(useArtistSearchQuery(q));
</script>

<div
  class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 w-full gap-4 px-2.5"
>
  {#if artistSearchQuery.isLoading}
    {#each new Array(10)}
      <ArtistCardSkeleton />
    {/each}
  {:else if artistSearchQuery.isSuccess}
    {#each artistSearchQuery.data.artists as artist (artist.browseId)}
      <ArtistCard {...artist} name={artist.title} height={150} width={150} showName />
    {/each}
  {/if}
</div>
