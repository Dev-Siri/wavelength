<script lang="ts">
  import usePlaylistRecommendedSongsQuery from "$lib/queries/playlistRecommendedSongs";

  import type { Playlist } from "$lib/schemas/playlist";

  import TrackSkeleton from "$lib/components/skeletons/TrackSkeleton.svelte";
  import Track from "$lib/components/track/Track.svelte";

  const { playlist }: { playlist: Playlist } = $props();

  const playlistRecommendedSongsQuery = $derived(
    usePlaylistRecommendedSongsQuery(playlist.playlistId),
  );
</script>

<div class="select-none">
  {#if playlistRecommendedSongsQuery.isLoading}
    <h6 class="text-2xl font-semibold mt-4">Recommended</h6>
    <p class="text-muted-foreground mb-4">Based on what's in this playlist</p>
    {#each new Array(15)}
      <TrackSkeleton />
    {/each}
  {:else if playlistRecommendedSongsQuery.isSuccess}
    <h6 class="text-2xl font-semibold mt-4">Recommended</h6>
    <p class="text-muted-foreground mb-4">Based on what's in this playlist</p>
    {#each playlistRecommendedSongsQuery.data.tracks as music (music.videoId)}
      <Track {music} toggle={{ type: "add-direct", to: playlist }} />
    {/each}
  {/if}
</div>
