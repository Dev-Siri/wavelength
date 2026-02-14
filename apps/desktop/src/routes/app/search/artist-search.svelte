<script lang="ts">
  import { createQuery } from "@tanstack/svelte-query";

  import { svelteQueryKeys } from "$lib/constants/keys";
  import { backendClient } from "$lib/utils/query-client";

  import ArtistCard from "$lib/components/artist/ArtistCard.svelte";
  import ArtistCardSkeleton from "$lib/components/skeletons/ArtistCardSkeleton.svelte";
  import { artistSearchResponseSchema } from "$lib/utils/validation/search-response";

  const { q }: { q: string } = $props();

  const artistSearchQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.search(q, "artists"),
    queryFn: () =>
      backendClient("/artists/search", artistSearchResponseSchema, { searchParams: { q } }),
  }));
</script>

<div
  class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 w-full px-2.5"
>
  {#if artistSearchQuery.isLoading}
    {#each new Array(10) as _}
      <ArtistCardSkeleton />
    {/each}
  {:else if artistSearchQuery.isSuccess}
    {#each artistSearchQuery.data.artists as artist}
      <ArtistCard {...artist} name={artist.title} height={150} width={150} showName />
    {/each}
  {/if}
</div>
