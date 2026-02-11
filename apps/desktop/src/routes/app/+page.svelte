<script lang="ts">
  import { createQuery } from "@tanstack/svelte-query";
  import { z } from "zod";

  import { DEFAULT_REGION } from "$lib/constants/countries.js";
  import { svelteQueryKeys } from "$lib/constants/keys.js";
  import { codeToCountryName } from "$lib/utils/countries.js";
  import { backendClient } from "$lib/utils/query-client.js";
  import { followedArtistResponseSchema } from "$lib/utils/validation/artist-response";
  import { quickPicksResponseSchema } from "$lib/utils/validation/quick-picks-response.js";

  import ArtistCard from "$lib/components/artist/ArtistCard.svelte";
  import QuickPickCard from "$lib/components/QuickPickCard.svelte";
  import QuickPickCardSkeleton from "$lib/components/skeletons/QuickPickCardSkeleton.svelte";
  import Button from "$lib/components/ui/button/button.svelte";

  let isFollowingListCollapsed = $state(true);

  const regionQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.region,
    queryFn: () => backendClient("/region", z.string()),
    staleTime: Infinity,
    gcTime: Infinity,
  }));

  const quickPicksQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.quickPicks,
    queryFn: () =>
      backendClient("/music/quick-picks", quickPicksResponseSchema, {
        searchParams: { regionCode: regionQuery.isSuccess ? regionQuery.data : DEFAULT_REGION },
      }),
    // 20 minutes.
    staleTime: 20 * 60 * 1000,
    refetchOnWindowFocus: false,
  }));

  const followedArtistsQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.followedArtists,
    queryFn: () => backendClient("/artists/followed", followedArtistResponseSchema),
  }));
</script>

<div class="p-6 bg-black h-screen w-full pb-[20%] overflow-auto">
  {#if followedArtistsQuery.data?.artists?.length}
    <h2 class="text-xl font-semibold select-none mb-4">Your Follows</h2>
    <div
      class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 xl:grid-cols-7 gap-2 overflow-hidden {isFollowingListCollapsed
        ? 'h-32'
        : ''}"
    >
      {#each followedArtistsQuery.data.artists as artist}
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
  <h3 class="text-xl font-semibold select-none">
    Popular Music in {codeToCountryName(regionQuery.isSuccess ? regionQuery.data : DEFAULT_REGION)}
  </h3>
  <div
    class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 w-full gap-12 px-2.5"
  >
    {#if quickPicksQuery.isLoading}
      {#each new Array(10)}
        <QuickPickCardSkeleton />
      {/each}
    {:else if quickPicksQuery.isSuccess}
      {#each quickPicksQuery.data.quickPicks as quickPick}
        <QuickPickCard {quickPick} />
      {/each}
    {/if}
  </div>
</div>
