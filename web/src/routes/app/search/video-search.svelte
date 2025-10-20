<script lang="ts">
  import { createQuery } from "@tanstack/svelte-query";

  import { svelteQueryKeys } from "$lib/constants/keys";
  import { backendClient } from "$lib/utils/query-client";
  import { youtubeVideosSchema } from "$lib/utils/validation/youtube-video";

  import UVideoCard from "$lib/components/UVideoCard.svelte";

  const { q }: { q: string } = $props();

  const videoSearchQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.search(q, "videos"),
    queryFn: () =>
      backendClient("/music/search/uvideos", youtubeVideosSchema, { searchParams: { q } }),
  }));
</script>

{#if videoSearchQuery.isSuccess}
  <div class="flex flex-wrap w-full gap-4">
    {#each videoSearchQuery.data as uvideo (uvideo.videoId)}
      <UVideoCard {uvideo} />
    {/each}
  </div>
{/if}
