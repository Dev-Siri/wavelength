<script lang="ts">
  import { createQuery } from "@tanstack/svelte-query";

  import { svelteQueryKeys } from "$lib/constants/keys";
  import { backendClient } from "$lib/utils/query-client";
  import { playlistsSchema } from "$lib/utils/validation/playlists";

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
  {#if playlistSearchQuery.isFetching}
    <TrackItemSkeleton />
    <TrackItemSkeleton />
    <TrackItemSkeleton />
  {:else if playlistSearchQuery.isSuccess}
    {#if playlistSearchQuery.data.length}
      {#each playlistSearchQuery.data as playlist}
        <PlaylistCard imageClasses="h-10 w-11" {playlist} />
      {/each}
    {:else}
      <span class="text-2xl text-balance mt-[20%]"> No public playlists found.</span>
    {/if}
  {/if}
</div>
