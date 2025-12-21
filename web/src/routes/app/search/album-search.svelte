<script lang="ts">
  import { createQuery } from "@tanstack/svelte-query";

  import { svelteQueryKeys } from "$lib/constants/keys";
  import { backendClient } from "$lib/utils/query-client";

  import AlbumTile from "$lib/components/AlbumTile.svelte";
  import AlbumSkeleton from "$lib/components/skeletons/AlbumSkeleton.svelte";
  import { albumSearchResponseSchema } from "$lib/utils/validation/search-response";

  const { q }: { q: string } = $props();

  const albumSearchQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.search(q, "albums"),
    queryFn: () =>
      backendClient("/albums/search", albumSearchResponseSchema, {
        searchParams: { q },
      }),
  }));
</script>

<div class="flex flex-col gap-4 h-full w-full">
  {#if albumSearchQuery.isLoading}
    {#each new Array(15) as _}
      <AlbumSkeleton />
    {/each}
  {:else if albumSearchQuery.isSuccess}
    {#if albumSearchQuery.data.result.length}
      {#each albumSearchQuery.data.result as album}
        <AlbumTile {album} />
      {/each}
    {:else}
      <span class="text-2xl text-balance mt-[20%]"> No albums found with that query.</span>
    {/if}
  {/if}
</div>
