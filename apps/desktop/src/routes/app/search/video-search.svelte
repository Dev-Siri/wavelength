<script lang="ts">
  import useVideosSearchQuery from "$lib/queries/videosSearch";

  import NoSearchResults from "$lib/components/search/NoSearchResults.svelte";
  import Spinner from "$lib/components/ui/spinner/spinner.svelte";
  import UVideoCard from "$lib/components/UVideoCard.svelte";

  const { q }: { q: string } = $props();

  const videosSearchQuery = $derived(useVideosSearchQuery(q));
</script>

{#if videosSearchQuery.isSuccess}
  {#if videosSearchQuery.data.youtubeVideos.length}
    <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 w-full gap-4">
      {#each videosSearchQuery.data.youtubeVideos as uvideo (uvideo.videoId)}
        <UVideoCard {uvideo} />
      {/each}
    </div>
  {:else}
    <NoSearchResults message="No YouTube videos matched your search." />
  {/if}
{:else}
  <div class="flex flex-col h-full pt-[20%] w-full items-center justify-center">
    <Spinner class="size-28" />
  </div>
{/if}
