<script lang="ts">
  import { createQuery } from "@tanstack/svelte-query";
  import { z } from "zod";

  import { svelteQueryKeys } from "$lib/constants/keys.js";
  import { codeToCountryName } from "$lib/utils/countries.js";
  import { backendClient } from "$lib/utils/query-client.js";
  import { quickPicksResponseSchema } from "$lib/utils/validation/quick-picks-response.js";

  import VideoCard from "$lib/components/MusicCard.svelte";
  import MusicCardSkeleton from "$lib/components/skeletons/MusicCardSkeleton.svelte";
  import { DEFAULT_REGION } from "$lib/constants/countries.js";

  const regionQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.region,
    queryFn: () => backendClient("/region", z.string()),
    staleTime: Infinity,
  }));

  const quickPicksQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.quickPicks,
    queryFn: () =>
      backendClient("/music/quick-picks", quickPicksResponseSchema, {
        searchParams: { regionCode: regionQuery.isSuccess ? regionQuery.data : DEFAULT_REGION },
      }),
  }));
</script>

<div class="p-6 h-screen w-full pb-[20%] overflow-auto">
  <h3 class="scroll-m-20 text-3xl tracking-tight my-4 text-balance">
    Popular Music in {codeToCountryName(regionQuery.isSuccess ? regionQuery.data : DEFAULT_REGION)}
  </h3>
  <div class="flex flex-wrap w-full justify-between">
    {#if quickPicksQuery.isFetching}
      {#each new Array(10)}
        <MusicCardSkeleton />
      {/each}
    {:else if quickPicksQuery.isSuccess}
      {#each quickPicksQuery.data as music}
        <VideoCard {music} />
      {/each}
    {/if}
  </div>
</div>
