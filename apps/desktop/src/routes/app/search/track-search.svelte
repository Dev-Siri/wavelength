<script lang="ts">
  import useTrackSearch from "$lib/queries/trackSearch";

  import PlaylistTrackListHeader from "$lib/components/playlist-track-list/PlaylistTrackListHeader.svelte";
  import TrackSkeleton from "$lib/components/skeletons/TrackSkeleton.svelte";
  import Track from "$lib/components/track/Track.svelte";

  const { q }: { q: string } = $props();

  const trackSearchQuery = $derived(useTrackSearch(q));
</script>

<div class="h-full w-full">
  <PlaylistTrackListHeader albumColShown={false} />
  {#if trackSearchQuery.isLoading}
    {#each new Array(8)}
      <TrackSkeleton />
    {/each}
  {:else if trackSearchQuery.isSuccess && trackSearchQuery.data.tracks}
    {#each trackSearchQuery.data.tracks as music, i (music.videoId)}
      <Track
        showAlbum={false}
        context={{ type: "none" }}
        {music}
        toggle={{ type: "add" }}
        positionInList={i + 1}
      />
    {/each}
  {/if}
</div>
