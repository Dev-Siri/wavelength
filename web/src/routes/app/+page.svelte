<script lang="ts">
  import type { PageData } from "./$types.js";

  import { codeToCountryName } from "$lib/utils/countries.js";

  import VideoCard from "$lib/components/MusicCard.svelte";
  import MusicCardSkeleton from "$lib/components/skeletons/MusicCardSkeleton.svelte";

  const { data }: { data: PageData } = $props();
</script>

<div class="p-6 h-screen w-full pb-[20%] overflow-auto">
  <h3 class="scroll-m-20 text-3xl tracking-tight my-4 text-balance">
    Popular Music in {codeToCountryName(data.region)}
  </h3>
  <div class="flex flex-wrap w-full justify-between">
    {#await data.pageData}
      {#each new Array(10) as _}
        <MusicCardSkeleton />
      {/each}
    {:then pageData}
      {#if pageData.success}
        {#each pageData.data as music}
          <VideoCard {music} />
        {/each}
      {/if}
    {/await}
  </div>
</div>
