<script lang="ts">
  import { createQuery } from "@tanstack/svelte-query";

  import { svelteQueryKeys } from "$lib/constants/keys";
  import { backendClient } from "$lib/utils/query-client";

  import ArtistLabel from "$lib/components/ArtistLabel.svelte";
  import ArtistLabelSkeleton from "$lib/components/skeletons/ArtistLabelSkeleton.svelte";
  import { artistSearchResponseSchema } from "$lib/utils/validation/search-response";

  const { q }: { q: string } = $props();

  const artistSearchQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.search(q, "artists"),
    queryFn: () =>
      backendClient("/artists/search", artistSearchResponseSchema, { searchParams: { q } }),
  }));
</script>

{#if artistSearchQuery.isFetching}
  <div class="flex flex-wrap w-full gap-4">
    <ArtistLabelSkeleton />
    <ArtistLabelSkeleton />
    <ArtistLabelSkeleton />
    <ArtistLabelSkeleton />
  </div>
{:else if artistSearchQuery.isSuccess}
  <div class="flex flex-wrap w-full gap-4">
    {#each artistSearchQuery.data.result as artist}
      <ArtistLabel {artist} />
    {/each}
  </div>
{/if}
