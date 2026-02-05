<script lang="ts">
  import { createQuery } from "@tanstack/svelte-query";

  import { svelteQueryKeys } from "$lib/constants/keys";
  import { backendClient } from "$lib/utils/query-client";
  import { musicSearchResponseSchema } from "$lib/utils/validation/search-response";

  import TopSearchResult from "$lib/components/search/TopSearchResult.svelte";
  import TrackItemSkeleton from "$lib/components/skeletons/TrackItemSkeleton.svelte";
  import TrackItem from "$lib/components/track/Track.svelte";
  import Skeleton from "$lib/components/ui/skeleton/skeleton.svelte";

  const { q }: { q: string } = $props();

  const trackSearchQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.search(q, "tracks"),
    queryFn: () =>
      backendClient("/music/search", musicSearchResponseSchema, { searchParams: { q } }),
  }));
</script>

{#if trackSearchQuery.isLoading}
  <div class="w-2/3">
    <h2 class="text-xl font-semibold select-none mb-2">Top Result</h2>
    <div class="w-full bg-muted bg-opacity-40 rounded-2xl pt-4 pb-6 pl-4">
      <Skeleton class="rounded-lg h-28 w-28" />
      <Skeleton class="w-4/5 h-4 mt-8" />
      <Skeleton class="w-2/5 h-3 mt-2" />
    </div>
    <div class="w-full bg-muted bg-opacity-40 rounded-2xl mt-2 pt-4 pb-6 pl-4">
      <Skeleton class="rounded-lg h-28 w-28" />
      <Skeleton class="w-4/5 h-4 mt-8" />
      <Skeleton class="w-2/5 h-3 mt-2" />
    </div>
  </div>
  <div class="w-2/3">
    <h2 class="text-xl font-semibold select-none mb-2">Songs</h2>
    <TrackItemSkeleton />
    <TrackItemSkeleton />
    <TrackItemSkeleton />
    <TrackItemSkeleton />
  </div>
{:else if trackSearchQuery.isSuccess && trackSearchQuery.data.tracks}
  {@const topResults = trackSearchQuery.data.tracks.slice(0, 2)}
  <div class="h-full w-1/2">
    <h2 class="text-xl font-semibold select-none mb-2">Top Results</h2>
    {#each topResults as topResult}
      <div class="mt-2">
        <TopSearchResult {topResult} />
      </div>
    {/each}
  </div>
  <div class="h-full w-1/2">
    <h2 class="text-xl font-semibold select-none mb-2">Songs</h2>
    {#each trackSearchQuery.data.tracks.slice(3) as music}
      <TrackItem {music} toggle={{ type: "add" }} />
    {/each}
  </div>
{/if}
