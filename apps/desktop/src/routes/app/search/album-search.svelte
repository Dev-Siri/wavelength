<script lang="ts">
  import { createQuery } from "@tanstack/svelte-query";

  import { svelteQueryKeys } from "$lib/constants/keys";
  import { backendClient } from "$lib/utils/query-client";
  import { albumSearchResponseSchema } from "$lib/utils/validation/search-response";

  import AlbumCard from "$lib/components/album/AlbumCard.svelte";
  import AlbumSkeleton from "$lib/components/skeletons/AlbumSkeleton.svelte";

  const { q }: { q: string } = $props();

  const albumSearchQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.search(q, "albums"),
    queryFn: () =>
      backendClient("/albums/search", albumSearchResponseSchema, {
        searchParams: { q },
      }),
  }));
</script>

<div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 w-full gap-8 px-2.5">
  {#if albumSearchQuery.isLoading}
    {#each new Array(15) as _}
      <AlbumSkeleton />
    {/each}
  {:else if albumSearchQuery.isSuccess}
    {#if albumSearchQuery.data.albums}
      {#each albumSearchQuery.data.albums as album}
        <AlbumCard {album} />
      {/each}
    {:else}
      <span class="text-2xl text-balance mt-[20%]"> No albums found with that query.</span>
    {/if}
  {/if}
</div>
