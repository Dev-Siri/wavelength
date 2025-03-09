<script lang="ts">
  import { Skeleton } from "$lib/components/ui/skeleton";

  import type { PageData } from "./$types";

  import ArtistLabel from "$lib/components/ArtistLabel.svelte";
  import ArtistLabelSkeleton from "$lib/components/skeletons/ArtistLabelSkeleton.svelte";
  import TrackItemSkeleton from "$lib/components/skeletons/TrackItemSkeleton.svelte";
  import TopResult from "$lib/components/TopResult.svelte";
  import TrackItem from "$lib/components/TrackItem.svelte";
  import UVideoCard from "$lib/components/UVideoCard.svelte";

  const { data }: { data: PageData } = $props();
</script>

<div class="h-screen py-4 px-2 overflow-auto pb-[20%]">
  <div class="flex w-full gap-5">
    {#await data.pageData.songResponse}
      <div class="w-2/3">
        <h2 class="text-3xl mb-3 font-bold">Top Result</h2>
        <div class="w-full bg-muted bg-opacity-40 rounded-2xl pt-4 pb-6 pl-4">
          <Skeleton class="rounded-lg h-28 w-28" />
          <Skeleton class="w-4/5 h-4 mt-8" />
          <Skeleton class="w-2/5 h-3 mt-2" />
        </div>
      </div>
      <div class="w-2/3">
        <h2 class="text-3xl mb-3 font-bold">Songs</h2>
        <TrackItemSkeleton />
        <TrackItemSkeleton />
        <TrackItemSkeleton />
        <TrackItemSkeleton />
      </div>
    {:then songResponse}
      {#if songResponse.success}
        {@const topResult = songResponse.data.result[0]}
        <div class="w-2/4">
          <h2 class="text-3xl mb-3 font-bold">Top Result</h2>
          <TopResult {topResult} />
        </div>
        <div class="w-2/4">
          <h2 class="text-3xl mb-3 font-bold">Songs</h2>
          {#each songResponse.data.result.slice(0, 4) as music}
            <TrackItem {music} />
          {/each}
        </div>
      {/if}
    {/await}
  </div>
  <h2 class="text-3xl my-4 font-bold">YouTube Videos</h2>
  {#await data.pageData.uvideosResponse then uvideosResponse}
    {#if uvideosResponse.success}
      <div class="flex flex-wrap w-full gap-4">
        {#each uvideosResponse.data as uvideo}
          <UVideoCard {uvideo} />
        {/each}
      </div>
    {/if}
  {/await}
  <h2 class="text-3xl my-4 font-bold">Artists</h2>
  {#await data.pageData.artistResponse}
    <div class="flex flex-wrap w-full gap-4">
      <ArtistLabelSkeleton />
      <ArtistLabelSkeleton />
      <ArtistLabelSkeleton />
      <ArtistLabelSkeleton />
    </div>
  {:then artistResponse}
    {#if artistResponse.success}
      <div class="flex flex-wrap w-full gap-4">
        {#each artistResponse.data.result.slice(0, 5) as artist}
          <ArtistLabel {artist} />
        {/each}
      </div>
    {/if}
  {/await}
</div>
