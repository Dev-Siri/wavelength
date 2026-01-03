<script lang="ts">
  import { createQuery } from "@tanstack/svelte-query";

  import { svelteQueryKeys } from "$lib/constants/keys";
  import { backendClient } from "$lib/utils/query-client";
  import { playlistsSchema } from "$lib/utils/validation/playlists";

  import NoResults from "$lib/components/NoResults.svelte";
  import PlaylistCard from "$lib/components/PlaylistCard.svelte";
  import TrackItemSkeleton from "$lib/components/skeletons/TrackItemSkeleton.svelte";

  const { q }: { q: string } = $props();

  const playlistSearchQuery = createQuery(() => ({
    queryKey: svelteQueryKeys.search(q, "playlists"),
    queryFn: () =>
      backendClient("/playlists", playlistsSchema, {
        searchParams: { q },
      }),
  }));
</script>

<div class="flex flex-col w-full h-full items-center pb-32 rounded-2xl">
  {#if playlistSearchQuery.isLoading}
    <TrackItemSkeleton />
    <TrackItemSkeleton />
    <TrackItemSkeleton />
  {:else if playlistSearchQuery.isSuccess}
    {#if playlistSearchQuery.data.playlists.length}
      {#each playlistSearchQuery.data.playlists as playlist}
        <PlaylistCard {playlist} />
      {/each}
    {:else}
      <div class="mt-[14%]">
        <NoResults />
      </div>
    {/if}
  {/if}
</div>
