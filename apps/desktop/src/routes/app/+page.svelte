<script lang="ts">
  import useFollowedArtistsQuery from "$lib/queries/followedArtists";
  import useQuickPicksQuery from "$lib/queries/quickPicks";
  import useRegionQuery from "$lib/queries/region";

  import ArtistCard from "$lib/components/artist/ArtistCard.svelte";
  import QuickPickCard from "$lib/components/QuickPickCard.svelte";
  import QuickPickCardSkeleton from "$lib/components/skeletons/QuickPickCardSkeleton.svelte";
  import Button from "$lib/components/ui/button/button.svelte";

  let isFollowingListCollapsed = $state(true);

  const regionQuery = useRegionQuery();
  const followedArtistsQuery = useFollowedArtistsQuery();
  const quickPicksQuery = $derived(
    useQuickPicksQuery(regionQuery.isSuccess ? regionQuery.data : "US"),
  );
</script>

<div class="p-6 bg-secondary/30 h-screen w-full pb-[20%] overflow-auto">
  {#if followedArtistsQuery.data?.artists?.length}
    <h2 class="text-xl font-semibold select-none mb-4">Your favorite artists</h2>
    <div
      class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 xl:grid-cols-7 gap-2 overflow-hidden {isFollowingListCollapsed
        ? 'h-32'
        : ''}"
    >
      {#each followedArtistsQuery.data.artists as artist (`followed-list-${artist.browseId}`)}
        <div class="shrink-0">
          <ArtistCard {...artist} />
        </div>
      {/each}
    </div>
    <div class="flex justify-end w-full">
      <Button
        onclick={() => (isFollowingListCollapsed = !isFollowingListCollapsed)}
        variant="ghost"
        class="mt-2"
      >
        {isFollowingListCollapsed ? "Show All" : "Show Less"}
      </Button>
    </div>
  {/if}
  <h3 class="text-xl font-semibold select-none">Popular Picks</h3>
  <div
    class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 w-full gap-12 px-2.5"
  >
    {#if quickPicksQuery.isLoading}
      {#each new Array(10)}
        <QuickPickCardSkeleton />
      {/each}
    {:else if quickPicksQuery.isSuccess}
      {#each quickPicksQuery.data.quickPicks as quickPick (quickPick.videoId)}
        <QuickPickCard {quickPick} />
      {/each}
    {/if}
  </div>
</div>
