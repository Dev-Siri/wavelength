<script lang="ts">
  import { createQuery } from "@tanstack/svelte-query";

  import { svelteQueryKeys } from "$lib/constants/keys";
  import { backendClient } from "$lib/utils/query-client";
  import { youtubeVideosSchema } from "$lib/utils/validation/youtube-video";

  import LoadingSpinner from "$lib/components/LoadingSpinner.svelte";
  import NoResults from "$lib/components/NoResults.svelte";
  import UVideoCard from "$lib/components/UVideoCard.svelte";

  const { q }: { q: string } = $props();

  const videoSearchQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.search(q, "videos"),
    queryFn: () =>
      backendClient("/music/search/uvideos", youtubeVideosSchema, { searchParams: { q } }),
  }));
</script>

{#if videoSearchQuery.isSuccess}
  {#if videoSearchQuery.data.length}
    <div class="flex flex-wrap w-full gap-4">
      {#each videoSearchQuery.data as uvideo}
        <UVideoCard {uvideo} />
      {/each}
    </div>
  {:else}
    <NoResults />
  {/if}
{:else}
  <div class="flex flex-col h-full pt-[20%] w-full items-center justify-center">
    <LoadingSpinner />
  </div>
{/if}
